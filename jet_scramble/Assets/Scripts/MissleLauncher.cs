using System.Runtime.CompilerServices;
using UnityEngine;
using VInspector;

public class MissleLauncher : MonoBehaviour
{
    public Rigidbody missilePrefab;
    public Transform target;
    public float missileSpeed = 10f;
    public float rotationSpeed = 5f;
    public float lockOnRadius = 5f;
    public float m_thrust;
    public Transform firePoint;

    [Tab("Bools")]
    public bool lockedOn = false;

    void Update()
    {
        
    }

    void FixedUpdate()
    {
        FireMissile();
        
        if (target == null || !lockedOn)
        {
            // Look for a target within the lock-on radius
            Collider[] targets = Physics.OverlapSphere(transform.position, lockOnRadius);

            // Check if any targets are valid and within the lock-on radius
            foreach (Collider potentialTarget in targets)
            {
                if (potentialTarget.CompareTag("Enemy")) // Change "Enemy" to the tag used for target objects
                {
                    target = potentialTarget.transform;
                    lockedOn = true;
                    FollowTarget();
                    break;
                }
            }
        }
    }

    public void FireMissile()
    {
        if (lockedOn && (Input.GetMouseButtonDown(0)))
        {
            
                Debug.Log("Pressed Mouse0");
                if (target != null && lockedOn)
                {
                    Debug.Log("Got here");
                // Instantiate and fire the missile from the firePoint position and rotation
                //Rigidbody missle_rb = Instantiate(missilePrefab, firePoint.position, firePoint.rotation) as Rigidbody;
                //
                //missilePrefab.useGravity = true;
                missilePrefab.AddForce(transform.forward * m_thrust,ForceMode.Force);
                

                    
                
                    //missle.SetTarget(target);

                   
                    
            }
                
            
            
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
        target = null;
        lockedOn = false;
    }
}
