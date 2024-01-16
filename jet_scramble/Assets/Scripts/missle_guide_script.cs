using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using Unity.PlasticSCM.Editor.WebApi;
using UnityEngine;
using VHierarchy;
using VInspector;

public class missle_guide_script : MonoBehaviour
{

    public EasyAirplaneControls myPlayer;

    [Foldout("Floats")]
    public float playerSpeed;
    public float missileSpeed;
    public float rotationSpeed;
    public float trackingDelay;
    public float movingSpeed;

    public Transform myTarget;

    [Foldout("Bools")]
    public bool lockedOn;
    public bool targetTracking;

    [Foldout("Gameobjects")]
    public GameObject fxExplode;
    


    // Start is called before the first frame update
    void Start()
    {   
        myPlayer= GameObject.FindGameObjectWithTag("Player").GetComponent<EasyAirplaneControls>();
        myTarget = myPlayer.GetComponent<missle_launch_script>().target.transform;
        Debug.Log("Target is: " + myTarget.name);
        //StartCoroutine("TargetTrackingDelay");

        fxExplode.SetActive(false);

        
    }

    //Update is called once per frame
    void FixedUpdate()
    {

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
        playerSpeed = myPlayer.currentSpeed;
        movingSpeed = playerSpeed + missileSpeed;
        Debug.Log(movingSpeed);
        
        Run();
        
        //Debug.Log(playerSpeed);

    }
    float PlayerSpeed(float _currentSpeed)
    {
        float speed = myPlayer.currentSpeed;
        Debug.Log("Player speed: " + speed);
        return speed;
        
    }
    public void Run()
    {
        
        // Move the missile forward
        //re work this for moving speed of the plane
        transform.Translate(Vector3.forward  * movingSpeed * Time.deltaTime);
        //Debug.Log(missileSpeed);

        StartCoroutine("TargetTrackingDelay");
        

        
    }

    public void StartGuiding()
    {
        Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

        // Calculate the rotation step towards the target
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
    }
    IEnumerator TargetTrackingDelay()
    {
        yield return new WaitForSeconds(trackingDelay);
        lockedOn = true;
        targetTracking = true;
        StartGuiding();
    }

    public void ActivateMissle()
    {
        Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

        // Calculate the rotation step towards the target
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

        // Move the missile forward
        transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
        Debug.Log(missileSpeed);
    }

    private void OnCollisionEnter(Collision col)
    {
        Debug.Log("Missle hit target: " + col.gameObject);
        fxExplode.SetActive(true);
        //Destroy(gameObject);
        Destroy(myTarget.gameObject);
    }




}
