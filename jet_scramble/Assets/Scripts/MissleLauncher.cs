using UnityEngine;

public class MissleLauncher : MonoBehaviour
{
    public GameObject missilePrefab;
    public Transform target;
    public float missileSpeed = 10f;
    public float rotationSpeed = 5f;
    public float lockOnRadius = 5f;
    public Transform firePoint;

    private bool lockedOn = false;

    void Update()
    {
        if (target != null && lockedOn)
        {
            // Calculate the direction towards the target
            Vector3 directionToTarget = (target.position - transform.position).normalized;

            // Calculate the rotation step towards the target
            Quaternion targetRotation = Quaternion.LookRotation(directionToTarget);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

            // Move the missile forward
            transform.Translate(Vector3.forward * missileSpeed * Time.deltaTime);
        }
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
                    break;
                }
            }
        }
    }

    public void FireMissile()
    {
        if (lockedOn)
        {
            // Instantiate and fire the missile from the firePoint position and rotation
            GameObject missle = Instantiate(missilePrefab, firePoint.position, firePoint.rotation);
            //missle.GetComponent<Missle>().SetTarget(target);

            // Reset the locked-on state
            target = null;
            lockedOn = false;
        }
    }
}
