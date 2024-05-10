using SensorToolkit.Example;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using Unity.PlasticSCM.Editor.WebApi;
using UnityEngine;
using VHierarchy;
using VInspector;
using MoreMountains.Feedbacks;

public class missle_guide_script : MonoBehaviour
{

    public EasyAirplaneControls myPlayer;

    [Foldout("Floats")]
    public float playerSpeed;
    public float missileSpeed;
    public float rotationSpeed;
    public float trackingDelay;
    public float missleRotateSpeed;
    //public float acceleration;
    //public float accelerationTime;
    //public float accelerateActiveTime;
    //public float missleSpeedmodifer;
    //public float missleForce;

    public Transform myTarget;

    [Foldout("Bools")]
    public bool lockedOn;
    public bool targetTracking;
    public bool isAccelerating;

    [Foldout("Gameobjects")]
    public GameObject fxExplode;

    [Foldout("RigidBodies")]
    public Rigidbody myMissleRb;

    [Foldout("Lists")]
    public List<GameObject> targetList = new List<GameObject>();

    [Foldout("Feedbacks")]
    //public MMF_Player missle_feedback;

    
    


    // Start is called before the first frame update
    void Start()
    {   
        myPlayer= GameObject.FindGameObjectWithTag("Player").GetComponent<EasyAirplaneControls>();
        targetList = myPlayer.GetComponent<missle_launch_script>().targetsFound;

        //temp disabled - shooting working - 4/17
        //myTarget = myPlayer.GetComponent<missle_launch_script>().target.transform;
        //Debug.Log("Target is: " + myTarget.name);

        // myTarget = myPlayer.GetComponent<missle_launch_script>().
       
        // kinda working, speed is off 4/29
        // myTarget = targetList[0].transform;

        fxExplode.SetActive(false);

        playerSpeed = myPlayer.currentSpeed;
        missileSpeed = missileSpeed + playerSpeed;
        Debug.Log("Player Speed is: " + playerSpeed);
        Debug.Log("Current missle speed should be " + missileSpeed);
        

        //missle_feedback.PlayFeedbacks();


    }
    public void Update()
    {
        Run();
    }
    //Update is called once per frame
    void FixedUpdate()
    {
        RotateMissle();
        //works for now
        //if(lockedOn)
        //{
        //    Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

        //    // Calculate the rotation step towards the target
        //    Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        //    transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

        //    // Move the missile forward
        //    transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
        //   //Debug.Log(missileSpeed);
        //}
        //playerSpeed = myPlayer.currentSpeed;
        
        
        //speedTomagnitude = 
        //movingSpeed = playerSpeed + missileSpeed;
        ////Debug.Log(movingSpeed);
        
        
        //float playerCurrentSpeed = PlayerSpeed();
        
        //Debug.Log("Player curret speed is: " + playerCurrentSpeed);

    }
    float PlayerSpeed()
    {
        float speed = myPlayer.currentSpeed;
        //("Player speed: " + speed);
        return speed;
        
    }
    public void Run()
    {

        // Move the missile forward
        //re work this for moving speed of the planes
        //Debug.Log(missileSpeed);

        //this works just testing moving better with plane moving
        //need to add players current speed
        
       
        transform.Translate(new Vector3(0,0,1) * missileSpeed * Time.deltaTime);
        
        // disabling accelration for now, works i think but is wonky
        // myMissleRb.AddForce(new Vector3(0,0,1) * missleForce, ForceMode.Acceleration);

      

        //testing RB velocity instead so I can add multiplier and Acceleration
        //Rigidbody missleRB = GetComponent<Rigidbody>();
        //missleRB.velocity = missleRB.velocity * missleSpeedmodifer;


        //transform.Translate(Vector3.forward.y + 5f);

        //temp disabled to figure out speed 4/12
        StartCoroutine("TargetTrackingDelay");

      

        // used to destroy, temp disabled 5/2
        //Destroy(gameObject,6f);
        

        
    }

    public void StartGuiding()
    {
        Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

        // Calculate the rotation step towards the target
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
    }

    //temp disabled 4/12 till testing missle speed + player speed

    IEnumerator TargetTrackingDelay()
    {
        yield return new WaitForSeconds(trackingDelay);
        lockedOn = true;
        targetTracking = true;
       // StartGuiding();
    }

    //public void ActivateMissle()
    //{
    //    Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

    //    // Calculate the rotation step towards the target
    //    Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
    //    transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

    //    // Move the missile forward
    //    transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
    //    //Debug.Log(missileSpeed);
    //}

    private void OnCollisionEnter(Collision col)
    {
          Debug.Log("Missle hit target: " + col.gameObject);
          Destroy(gameObject,.005f);
    
    }

    public void RotateMissle()
    {
        transform.Rotate(0, 0, missleRotateSpeed * Time.deltaTime);
    }




}
