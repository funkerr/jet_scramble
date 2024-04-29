using UnityEngine;
using VHierarchy;
using VInspector;
using SensorToolkit;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.UIElements;
using UnityEngine.Rendering;
using QFSW.QC;
using JetBrains.Annotations;
using MoreMountains.Feedbacks;

public class missle_launch_script : MonoBehaviour
{
    [Foldout("Gameobjects")]
    public GameObject missilePrefab;
    public GameObject missilePrefab2;
    //public GameObject[] targets = new GameObject[2];

    [Foldout("Transforms")]
    public Transform firePoint_left;
    public Transform firePoint_right;
    public Transform target;
    public Transform DebugLineTransform;

    [Foldout("Bools")]
    public bool lockedOn = false;

    [Foldout("Sensors")]
    public TriggerSensor sensor;

    [Foldout("Targets")]
    public List<GameObject> targetsFound = new List<GameObject>();

    [Foldout("Feedbacks")]
    public MMF_Player missle_left_fb;
    public MMF_Player missle_right_fb;

    void Update()
    {
        //var d = sensor.GetDetected();  //<--- THIS RETURNS A LIST
        //Debug.Log($"Detected: {d}");

        //Testing what is detected by Triggersensor
        Debug.DrawLine(this.transform.position, DebugLineTransform.position, Color.red);
        foreach (GameObject x in sensor.GetDetected())
        {
      
            if(!targetsFound.Contains(x))
            {
                targetsFound.Add(x);
            }
            
            
        }

        FireMissile();
    }

    //temp disabling 4/17
    //void FixedUpdate()
    //{
    //    if (target == null || !lockedOn)
    //    {
    //        // Look for a target within the lock-on radius
    //        // temp workingn till i get sensor working better
    //        Collider[] targets = Physics.OverlapSphere(transform.position, 1000);

    //        // Check if any targets are valid and within the lock-on radius
    //        foreach (Collider potentialTarget in targets)
    //        {
    //            if (potentialTarget.CompareTag("Enemy")) // Change "Enemy" to the tag used for target objects
    //            {
    //                target = potentialTarget.transform;
    //                lockedOn = true;

    //                //Debug.Log(target.name);
    //                break;
    //            }
    //        }
    //    }

    //    //TestMissle();

    //}

    [Command]
    public void FireMissile()
    {
        //test disable lock on 4/13
        //if (lockedOn)
        //{
            if (Input.GetKeyDown(KeyCode.G))
            {
            
                GameObject missle_left = Instantiate(missilePrefab, firePoint_left.position, firePoint_left.rotation);
                missle_left_fb.PlayFeedbacks();
                StartCoroutine("FireSecondMissle");
                Debug.Log("Fired Missle!");

            }
        //}

    }

    IEnumerator FireSecondMissle() 

    {
        yield return new WaitForSeconds(1f);
        GameObject missle_right = Instantiate(missilePrefab, firePoint_right.position, firePoint_right.rotation);
        missle_right_fb.PlayFeedbacks();
        Debug.Log("Fired Second Missle");

    }  
}
