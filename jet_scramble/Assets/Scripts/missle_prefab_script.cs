using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VHierarchy;

public class missle_script : MonoBehaviour
{
    public float acceleration;
    public float accelerationTime;
    public float missleSpeed;

    public bool missleActive = false;
    public bool isAccelerating;
    public float accelerateActiveTime;

    public Rigidbody rb;

    public Transform myTarget;

    public Quaternion guideRotation;
    public bool targetTracking;

    public float turnRate;

    public float trackingDelay;


    // Start is called before the first frame update
    void Start()
    {
        ActivateMissle();
        accelerateActiveTime = Time.time;
        StartCoroutine("TargetTrackingDelay");

    }

    public void ActivateMissle()
    {
        missleActive = true;
        accelerateActiveTime = Time.time;
    }

    public void GuideMissle()
    {
        if (myTarget == null) return;

        if (targetTracking)
        {
            Vector3 relativePosition = myTarget.position - transform.position;
            guideRotation = Quaternion.LookRotation(relativePosition, transform.forward);
        }

        Debug.Log("Tracking");

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.F))
        {
            FireMissle();

        }

        Run();
        GuideMissle();
    }

    public void Run()
    {
        if (Since(accelerateActiveTime) > accelerationTime)
            isAccelerating = false;
        else
            isAccelerating = true;

        if (!missleActive) return;

        if (isAccelerating)
            missleSpeed += acceleration * Time.deltaTime;

        rb.velocity = transform.forward * missleSpeed;
        Debug.Log("MissleSpeed " + missleSpeed);

        if (targetTracking)
            transform.rotation = Quaternion.RotateTowards(transform.rotation, guideRotation, turnRate * Time.deltaTime);
    }

    public void FireMissle()
    {
        //if(Since)
        //rb.velocity = transform.forward * missleSpeed;

    }

    public float Since(float since)
    {
        return Time.time - since;
    }

    IEnumerator TargetTrackingDelay()
    {
        yield return new WaitForSeconds(trackingDelay);
        targetTracking = true;
    }

    private void OnCollisionEnter(Collision col)
    {
        Destroy(gameObject);
        Destroy(myTarget.gameObject);
    }
}

