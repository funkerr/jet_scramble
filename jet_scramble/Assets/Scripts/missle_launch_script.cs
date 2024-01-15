using UnityEngine;
using VHierarchy;
using VInspector;

public class missle_launch_script : MonoBehaviour
{
    public GameObject missilePrefab;
    public Transform target;

    [Foldout("Floats")]
    public float missileSpeed = 10f;
    public float rotationSpeed = 5f;
    public float lockOnRadius = 1000f;

    public Transform firePoint;

    public bool lockedOn = false;

    void Update()
    {
        //FireMissile();
    }

    void FixedUpdate()
    {
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


                //if (target != null && lockedOn)
                //{
                //    // Calculate the direction towards the target
                //    Debug.Log("got here");
                //    Vector3 directionToTarget = (missle.transform.position - transform.position).normalized;

                //    // Calculate the rotation step towards the target
                //    Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
                //    missle.transform.rotation = Quaternion.Slerp(missle.transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

                //    // Move the missile forward
                //    missle.transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
                //    Debug.Log(missileSpeed);
                //}
            }
               

            // Instantiate and fire the missile from the firePoint position and rotation
            
            //missle.GetComponent<Missle>().SetTarget(target);

            // Reset the locked-on state
            //target = null;
            //lockedOn = false;
        }
    }

    
}
