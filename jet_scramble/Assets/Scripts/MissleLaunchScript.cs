using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VHierarchy;
using VInspector;

public class MissleLaunchScript : MonoBehaviour

{
    public Rigidbody missle_Prefab;

    public float missle_Speed;
    public float rotationSpeed;

    [Tab("Transforms")]     
    public Transform launch_location;
    public Transform target;



    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void FixedUpdate()
    {
        FireMissle();
        //FollowTarget();
    }

    void FireMissle()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {

            //Debug.Log("Mouse 0 Pressed");   
            Rigidbody clone = Instantiate(missle_Prefab, launch_location.position, launch_location.rotation);
            // Calculate the direction towards the target
            Vector3 directionToTarget = (target.position - clone.transform.position).normalized;

            // Calculate the rotation step towards the target
            Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);


            clone.velocity = transform.forward * missle_Speed;
            clone.transform.rotation = Quaternion.Slerp(clone.transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);



        }
    }

    public void FollowTarget()
    {
        // Calculate the direction towards the target
        Vector3 directionToTarget = (target.position - transform.position).normalized;

        // Calculate the rotation step towards the target
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

        // Move the missile forward
        //transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
        // Reset the locked-on state
        //target = null;
        // lockedOn = false;
    }

}
