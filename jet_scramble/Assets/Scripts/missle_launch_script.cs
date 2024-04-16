using UnityEngine;
using VHierarchy;
using VInspector;
using SensorToolkit;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.UIElements;
using UnityEngine.Rendering;

public class missle_launch_script : MonoBehaviour
{
    [Foldout("Gameobjects")]
    public GameObject missilePrefab;
    public GameObject missilePrefab2;
    public GameObject[] targets = new GameObject[2];

    [Foldout("Transforms")]
    public Transform firePoint_left;
    public Transform firePoint_right;
    public Transform target;

    [Foldout("Bools")]
    public bool lockedOn = false;

    [Foldout("Sensors")]
    public TriggerSensor sensor;

    //testing EnemyManager Class stuff
    //public EnemyManager enemyManager;


    void Start()
    {
      
    }

  

    void Update()
    {
        //var d = sensor.GetDetected();  //<--- THIS RETURNS A LIST
        //Debug.Log($"Detected: {d}");

        //Testing what is detected by Triggersensor
        foreach (var x in sensor.GetDetected())
        {
            Debug.Log(x.ToString());
        }

        FireMissile();
    }

    void FixedUpdate()
    {
        if (target == null || !lockedOn)
        {
            // Look for a target within the lock-on radius
            // temp workingn till i get sensor working better
            Collider[] targets = Physics.OverlapSphere(transform.position, 1000);

            // Check if any targets are valid and within the lock-on radius
            foreach (Collider potentialTarget in targets)
            {
                if (potentialTarget.CompareTag("Enemy")) // Change "Enemy" to the tag used for target objects
                {
                    target = potentialTarget.transform;
                    lockedOn = true;

                    //Debug.Log(target.name);
                    break;
                }
            }
        }
        
        //TestMissle();

    }


    public void FireMissile()
    {
        //test disable lock on 4/13
        //if (lockedOn)
        //{
            if (Input.GetKeyDown(KeyCode.G))
            {

                GameObject missle_left = Instantiate(missilePrefab, firePoint_left.position, firePoint_left.rotation);
                StartCoroutine("FireSecondMissle");
                

            Debug.Log("Fired Missle!");

            }
        //}

    }

    //public void TestMissle()
    //{
        
    //    {
    //        if (Input.GetKeyDown(KeyCode.O))
    //        {

    //            GameObject missle = Instantiate(missilePrefab2, firePoint.position, firePoint.rotation);

    //            Debug.Log("Fired Missle!");

    //        }
    //    }
    //}

    IEnumerator FireSecondMissle() 

    {
        yield return new WaitForSeconds(1f);
        GameObject missle_right = Instantiate(missilePrefab, firePoint_right.position, firePoint_right.rotation);
        Debug.Log("Fired Second Missle");

    }  
}
