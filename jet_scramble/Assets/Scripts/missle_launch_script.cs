using UnityEngine;
using VHierarchy;
using VInspector;
using SensorToolkit;
using System.Collections.Generic;
using UnityEngine.UIElements;

public class missle_launch_script : MonoBehaviour
{
    [Foldout("Gameobjects")]
    public GameObject missilePrefab;
    public GameObject[] targets = new GameObject[2];

    [Foldout("Transforms")]
    public Transform firePoint;
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
        FireMissile();

    }


    public void FireMissile()
    {
        if (lockedOn)
        {
            if (Input.GetKeyDown(KeyCode.G))
            {

                GameObject missle = Instantiate(missilePrefab, firePoint.position, firePoint.rotation);

                Debug.Log("Fired Missle!");

            }
        }

    }
}
