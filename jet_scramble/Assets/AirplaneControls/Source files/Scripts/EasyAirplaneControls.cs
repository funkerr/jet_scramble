using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EasyAirplaneControls : MonoBehaviour
{

    public float aileronRotationSpeed; // how fast rotations reach their maximum
    public float elevatorRotationSpeed;
    public float rudderRotationSpeed;

    [HideInInspector]
    public float currentAileronRotation; // where the rotations are currently at
    [HideInInspector]
    public float currentElevatorRotation;
    [HideInInspector]

    public float currentRudderRotation;

    public float maxAileronRotation; // maximum rotations
    public float maxElevatorRotation;
    public float maxRudderRotation;



    public float topSpeed; // maximum speed when flying straight

    public float stallingSpeed; // lower altitude if current speed is lower than this



    public float groundAccelerationSpeed = 0.5f; // how fast the plane accelerates on ground when taking off

    float lastHeight; // checking height changes
    public float heightChange;
    public float currentHeight;

    float speedBoost; // current speed boost from gravity
    float gravityMultiplier; //current gravity


    float desiredSpeed; // speed to which the plane is accelerating/deaccelerating towards

    
    public float currentSpeed; // the speed we're currently at

    [HideInInspector]
    public float throttle; // throttle input from user

    public Transform landingGearPosition; // where the landing gear is located, to place the plane correctly on ground when landing

    public float maxSpeed; // absolute maximum speed after applying gravity and speed boosts

    [HideInInspector]
    public float maxSpeedPercent; // how close we are to reaching the maximum speed, used to slow down controls in extremely high speeds

    
     float currentTerrainY; // raycasted terrain height to check for collisions

    [HideInInspector]
     public float stallingPercent; // how badly we are stalling (=losing altitude and controllability)


    public float takeOffSpeed; // what is the speed when the plane can take off

    
    public bool grounded; // on ground or in air?


     Vector3 terrainNormal; // slope of the terrain to rotate the plane on ground

    public bool disableCrashing;
     float canCrashTimer; //not to spam crash messages if crashing is disabled

    public GameObject planeModel;//plane gameobject


     PlaneSounds planeSounds;
     PlaneEffects planeEffects;

    public bool tiltPlaneWhenLanded;
    public float tiltAngle;

    public bool debug = true;


    float input_aileron; // user input
    float input_elevator;
    float input_rudder;

    public Transform lockedCameraPosition;
    public Transform lockedCameraLookAt;


    public bool enableMobileInput;
    public MobileInput mobileInput_elevator;
    public MobileInput mobileInput_rudder;
    public MobileInput mobileInput_camera;
    public MobileInput mobileInput_throttle;
    public Texture2D gamepad;
    public Texture2D gamepadThumb;
    public Texture2D gamepad_rudder;
    public Texture2D gamepadThumb_rudder;
    public Texture2D gamepad_throttle;

    void Awake () {
        lastHeight = transform.position.y;
        throttle = 0;
        currentSpeed = 0;
        planeSounds = GetComponentInChildren<PlaneSounds>();
        planeEffects = GetComponentInChildren<PlaneEffects>();

        if (enableMobileInput) {
            mobileInput_elevator = new MobileInput(0.05f, 0.65f, 0.3f, 0.5f, gamepad, gamepadThumb);
            mobileInput_rudder = new MobileInput(0.5f, 0.8f, 0.25f, 0.5f, gamepad_rudder, gamepadThumb_rudder);
            mobileInput_camera = new MobileInput(0.75f, 0.75f, 0.25f, 1f, gamepad, gamepadThumb);
            mobileInput_throttle = new MobileInput(0.75f, 0.0f, 0.25f, 1f, gamepad_throttle, gamepadThumb);
        }
    }

    void Update () {
        if (enableMobileInput) {
            mobileInput_elevator.UpdateGamePad();
            mobileInput_rudder.UpdateGamePad();
            mobileInput_camera.UpdateGamePad();
            mobileInput_throttle.UpdateGamePad();
        }
        if (canCrashTimer > 0)
        {
            canCrashTimer -= 1 * Time.deltaTime;
        }


        WingInputs();
        UpdateThrottle();
        ClampMaxRotations();
        UpdateHeightChange();
        UpdateSpeedBoosts();
        RotateModel();
        UpdateBrake();
        PlaneMovement();
        PlaneRotations();
        CheckCollisions();
        GetCurrentHeight();

    }

    public void GetCurrentHeight()
    {
        currentHeight = transform.position.y;
    }
    void WingInputs() {
        input_aileron = Input.GetAxis("Horizontal");
        input_elevator = Input.GetAxis("Vertical");
        input_rudder = Input.GetAxis("Rudder");


        if (enableMobileInput) {
            input_elevator = -mobileInput_elevator.GetGamepadVector().y;
            input_aileron = mobileInput_elevator.GetGamepadVector().x;
            input_rudder = mobileInput_rudder.GetGamepadVector().x;
        }
        if (input_aileron < 0) {
            currentAileronRotation += -Time.deltaTime * aileronRotationSpeed * (1 - stallingPercent) * Mathf.Abs(input_aileron);
        } else if (input_aileron > 0) {

            currentAileronRotation += Time.deltaTime * aileronRotationSpeed * (1 - stallingPercent) * Mathf.Abs(input_aileron);
        } else {
            currentAileronRotation = Mathf.Lerp(currentAileronRotation, 0, 5 * Time.deltaTime);
        }



        if (input_elevator > 0) {
            currentElevatorRotation += -Time.deltaTime * elevatorRotationSpeed * (1 - stallingPercent) * (1 - maxSpeedPercent) * Mathf.Abs(input_elevator); ;
        } else if (input_elevator < 0) {
            currentElevatorRotation += Time.deltaTime * elevatorRotationSpeed * (1 - stallingPercent) * (1 - maxSpeedPercent) * Mathf.Abs(input_elevator);
        } else {
            currentElevatorRotation = Mathf.Lerp(currentElevatorRotation, 0, 5 * Time.deltaTime);
        }

        if (input_rudder < 0) {
            if (grounded && currentSpeed < 8) {
                currentRudderRotation += -Time.deltaTime * rudderRotationSpeed * 5 * (1 - stallingPercent) * Mathf.Abs(input_rudder);
            } else {
                currentRudderRotation += -Time.deltaTime * rudderRotationSpeed * (1 - stallingPercent) * Mathf.Abs(input_rudder);
            }
        } else if (input_rudder > 0) {
            if (grounded && currentSpeed < 8) {
                currentRudderRotation += Time.deltaTime * rudderRotationSpeed * 5 * (1 - stallingPercent);
            } else {
                currentRudderRotation += Time.deltaTime * rudderRotationSpeed * (1 - stallingPercent);
            }
        } else {
            currentRudderRotation = Mathf.Lerp(currentRudderRotation, 0, 5 * Time.deltaTime);
        }
    }

    void PlaneMovement() {
        if (grounded) {
            desiredSpeed = Mathf.Clamp(speedBoost + topSpeed, -30, 100) * throttle;
        } else {
            desiredSpeed = Mathf.Clamp(speedBoost + topSpeed, -30, 100) * Mathf.Clamp(throttle, 0.25f, 1);//clamp throttle at 0.25 when in air to simulate gliding when throttle is zero
        }
        transform.position += -transform.forward * currentSpeed * Time.deltaTime;
    }

    void PlaneRotations() {
        Vector3 pivot = transform.position;
        if (grounded) {
            transform.position = new Vector3(transform.position.x, currentTerrainY + Mathf.Abs(landingGearPosition.transform.localPosition.y), transform.position.z); // when grounded, stick to terrain and rotate plane to match the slope
            Quaternion rot = Quaternion.FromToRotation(transform.up, terrainNormal) * transform.rotation;
            float oldRot = transform.localEulerAngles.y;
            transform.rotation = Quaternion.Slerp(transform.rotation, rot, 5 * Time.deltaTime);
            transform.rotation = Quaternion.Euler(transform.localEulerAngles.x, oldRot, transform.localEulerAngles.z);
            transform.root.RotateAround(pivot, transform.up, Time.deltaTime * currentRudderRotation * (currentSpeed / 8f));
            stallingPercent = 0;
        } else {
            transform.root.RotateAround(pivot, transform.forward, Time.deltaTime * currentAileronRotation);
            transform.root.RotateAround(pivot, transform.right, Time.deltaTime * currentElevatorRotation);
            transform.root.RotateAround(pivot, transform.up, Time.deltaTime * currentRudderRotation);
            ApplyStall();
        }

        if (transform.localEulerAngles.z > 30 && transform.localEulerAngles.z <= 180) { //rotate down when going sideways
            transform.root.RotateAround(pivot, transform.up, Time.deltaTime * 15);
        }
        else if (transform.localEulerAngles.z < 330 && transform.localEulerAngles.z > 270) {
            transform.root.RotateAround(pivot, transform.up, Time.deltaTime * -15);
        }
    }
    void UpdateBrake() {

        if (grounded && Input.GetButton("Brake")) {
            desiredSpeed = 0;
        }
        if (currentSpeed < desiredSpeed) {
            if (grounded) {

                currentSpeed = Mathf.Lerp(currentSpeed, desiredSpeed, throttle * groundAccelerationSpeed * Time.deltaTime);
            } else {

                currentSpeed = Mathf.Clamp(Mathf.Lerp(currentSpeed, desiredSpeed, throttle * 0.5f * Time.deltaTime), float.MinValue, maxSpeed);
            }
        } else {
            if (grounded && (Input.GetButton("Brake") || (enableMobileInput && throttle == 0))) {
                currentSpeed = Mathf.Lerp(currentSpeed, desiredSpeed, 0.5f * Time.deltaTime);
            } else {
                currentSpeed = Mathf.Lerp(currentSpeed, desiredSpeed, 0.2f * Time.deltaTime);
            }
        }
    }

    void RotateModel() {
        
        if (tiltPlaneWhenLanded && grounded && currentSpeed < 20) { //tilt plane when landed
            planeModel.transform.localRotation = Quaternion.RotateTowards(planeModel.transform.localRotation, Quaternion.Euler(tiltAngle, 0, 0), 10 * Time.deltaTime);
            planeModel.transform.localPosition = Vector3.MoveTowards(planeModel.transform.localPosition, new Vector3(0, -0.15f, 0), 0.1f * Time.deltaTime);
        } else { 
            planeModel.transform.localRotation = Quaternion.RotateTowards(planeModel.transform.localRotation, Quaternion.Euler(0, 0, 0), 10 * Time.deltaTime);
            planeModel.transform.localPosition = Vector3.MoveTowards(planeModel.transform.localPosition, new Vector3(0, 0, 0), 0.1f * Time.deltaTime);
        }
    }
    void CheckCollisions()
    {
        float dist = 150;
        RaycastHit hit;
        Vector3 dir = new Vector3(0, -10, 0);
        if (Physics.Raycast(transform.position + new Vector3(0, 100, 0), dir, out hit, dist)) { // raycast from above to detect terrain collisions
            if (hit.collider.gameObject.tag == "Terrain") {
                currentTerrainY = hit.point.y;
                terrainNormal = hit.normal;
                if(grounded && Vector3.Distance(transform.position, hit.point)>5) { //set grounded to false if we're landed and detected terrain is too far (e.g. when driving off a sudden cliff)
                    grounded = false;
                    DebugPlane("Terrain too far, hit point "+hit.point+", "+transform.position+", "+ Vector3.Distance(transform.position, hit.point));
                }
            }

            if (grounded && currentSpeed >= takeOffSpeed && input_elevator<0) { // take off
                grounded = false;
                transform.position += new Vector3(0, 5 * Time.deltaTime, 0);
                DebugPlane("Take off!");
            } else if (hit.collider.gameObject.tag == "Terrain") { 
                if (hit.distance < 100 + Mathf.Abs(landingGearPosition.transform.localPosition.y)) { // landing
                    if (currentSpeed < takeOffSpeed && (transform.localEulerAngles.x < 30 || transform.localEulerAngles.x > 345)) { // check that we're coming in slow enough and in a decent angle
                        if (grounded == false) {
                            if (Mathf.Abs(heightChange) < 0.4f) { // check that our height change isn't too big
                                Landed();
                            } else {
                                grounded = true; //dropping too fast > crash
                                Crash();
                            }
                        }
                    } else if(grounded==false){
                        grounded = true; //coming in too fast or in a weird angle > crash
                        Crash();
                    }
                }
            }
        } else {
            grounded = false; //reset if terrain is not detected (too high up for raycast to hit)
            currentTerrainY = 0;
        }
    }

    void Landed() {
        grounded = true;
        DebugPlane("Landed!");
        planeSounds.land.Play();
        planeEffects.Landed();
    }
    void DebugPlane(string s) {
        if(debug)
        Debug.Log(s);
    }
    void Crash()
    {
        if (canCrashTimer <= 0)
        {
            canCrashTimer = 1;
            DebugPlane("Crashed!");
            // your crash code goes here
        }
        transform.rotation = Quaternion.Euler(15, transform.localEulerAngles.y, transform.localEulerAngles.z);
        transform.position = new Vector3(transform.position.x, currentTerrainY + Mathf.Abs(landingGearPosition.transform.localPosition.y), transform.position.z);
    }
    void ApplyStall()
    {
        if (currentSpeed<stallingSpeed)
        {
            stallingPercent = (1 - currentSpeed/ stallingSpeed);
            transform.position -= new Vector3(0, (stallingSpeed - currentSpeed)*Time.deltaTime, 0); // going too slow, drop altitude
        }
        else
        {
            stallingPercent = 0;
        }
    }

    void UpdateThrottle()
    {
        if (enableMobileInput) {
            if (mobileInput_throttle.isMovingGamepad) {
                throttle = 1-mobileInput_throttle.GetGamepadVector().y;
            }
        }
        if (Input.GetAxis("Throttle") > 0)
        {
            bool under = false;
            if (throttle < 0.5f) under = true;

            throttle += 0.5f * Time.deltaTime;

            if (grounded && under && throttle > 0.5f) { // smoke effect from engine when taking off
                planeEffects.EngineSmoke();
            }

        }
        if (Input.GetAxis("Throttle") < 0)
        {
            throttle -= 0.5f * Time.deltaTime;
        }
        throttle = Mathf.Clamp(throttle, 0, 1);
    }


    void UpdateHeightChange()
    {
        heightChange = (transform.position.y - lastHeight);
        gravityMultiplier += (heightChange*3) * Time.deltaTime; // apply gravity multiplier based on how how steeply up or down we're going

        if (transform.localEulerAngles.x > 45 && transform.localEulerAngles.x <= 90) // plane is going (almost) straight up
        {
            gravityMultiplier += ((transform.localEulerAngles.x - 45) / 45) * 20 * Time.deltaTime; // apply lots of gravity to slow down
        }
        else if (heightChange < 0 && transform.localEulerAngles.x < 315 && transform.localEulerAngles.x>270) {//going straight down
            gravityMultiplier += (heightChange *1.5f) * Time.deltaTime; //  increase speed
        }
        else
        {

            gravityMultiplier = Mathf.Lerp(gravityMultiplier, 0, 1 / (Mathf.Abs(heightChange) + 0.1f) * 0.5f * Time.deltaTime); //going straight forward, reset gravity
        }

        lastHeight = transform.position.y;
    }

    void UpdateSpeedBoosts()
    {

        if (currentSpeed > topSpeed) {
            maxSpeedPercent = Mathf.Clamp(((currentSpeed - topSpeed) / (maxSpeed - topSpeed))*0.5f, 0, 0.8f); // if we're going over top speed, increase maxSpeedPercentage (to lower plane controllability in high speeds)
        } else {
            maxSpeedPercent = Mathf.Lerp(maxSpeedPercent, 0, 1 * Time.deltaTime); // reset percentage if we're going lower than the top speed
        }
        speedBoost = -gravityMultiplier*5; // increase / decrease speed based on the gravity multiplier
    }

    void ClampMaxRotations()
    {

        if (currentElevatorRotation > 0 && currentElevatorRotation > maxElevatorRotation * (1-maxSpeedPercent))
        {
            currentElevatorRotation = maxElevatorRotation * (1 - maxSpeedPercent);
        }
        if (currentElevatorRotation < 0 && currentElevatorRotation < -maxElevatorRotation * (1 - maxSpeedPercent))
        {
            currentElevatorRotation = -maxElevatorRotation * (1 - maxSpeedPercent);
        }
        if (currentAileronRotation > 0 && currentAileronRotation > maxAileronRotation)
        {
            currentAileronRotation = maxAileronRotation;
        }
        if (currentAileronRotation < 0 && currentAileronRotation < -maxAileronRotation)
        {
            currentAileronRotation = -maxAileronRotation;
        }
        
        float oldRudderMax = maxRudderRotation;
        if (grounded && currentSpeed<8) maxRudderRotation = 45;
        if (currentRudderRotation > 0 && currentRudderRotation > maxRudderRotation)
        {
            currentRudderRotation = maxRudderRotation;
        }
        if (currentRudderRotation < 0 && currentRudderRotation < -maxRudderRotation)
        {
            currentRudderRotation = -maxRudderRotation;
        }
        maxRudderRotation = oldRudderMax;
        
    }
}
