using UnityEngine;

public class PlayerShooting : MonoBehaviour
{
    public GameObject bulletPrefab;
    public Transform firePoint;
    public float bulletSpeedMultiplier = 1.0f;

    private Rigidbody playerRigidbody;

    public EasyAirplaneControls myPlayerRef;
    public float playerSpeed;

    void Start()
    {
        playerRigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        Shoot();

    }

    void Shoot()
    {
        playerSpeed = myPlayerRef.currentSpeed;
        if (Input.GetKeyDown(KeyCode.Mouse0)) // Change "Fire1" to your desired fire button
        {

            GameObject bullet = Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);
            Rigidbody bulletRigidbody = bullet.GetComponent<Rigidbody>();

            // Get the player's current velocity
            Vector3 playerVelocity = playerRigidbody.velocity;

            // Calculate the magnitude of the player's velocity
           // rbSpeed = bulletRigidbody.velocity.magnitude;
            //float playerSpeed2 = playerSpeed.
            // Calculate the direction in which the bullet should travel
            Vector3 bulletDirection = playerVelocity.normalized;

            // Set the bullet's velocity based on the player's speed and the bullet speed multiplier
            //bulletRigidbody.velocity.magnitude = playerSpeed * bulletSpeedMultiplier;

        }
    }
}



//veloctity needs to be set to the player speed + another speed/multiplier
//maybe velocity to a float?

