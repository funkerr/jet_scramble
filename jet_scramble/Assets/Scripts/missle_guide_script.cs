using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using UnityEngine;

public class missle_guide_script : MonoBehaviour
{

    public GameObject myPlayer;

    public float missileSpeed;
    public float rotationSpeed;
    public float lockOnRadius;

    public Transform myTarget;

    public bool lockedOn;
    


    // Start is called before the first frame update
    void Start()
    {

        //myTarget = myML.target;
        Debug.Log(myTarget.name);

        
    }

    //Update is called once per frame
    void Update()
    {

        Vector3 directionToTarget = (myTarget.position - transform.position).normalized;

        // Calculate the rotation step towards the target
        Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

        // Move the missile forward
        transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
        Debug.Log(missileSpeed);

    }
    


    
}
