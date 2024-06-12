using VFolders;
using VInspector;
using UnityEngine;

public class german_flak_rotate_script : MonoBehaviour
{
    public float rotationSpeed = 50f; // Speed of rotation
    public float maxAngle = 30f; // Maximum rotation angle
    public float minAngle = -30f; // Minimum rotation angle

    public float currentAngle; // Current angle of rotation
    public bool rotatingForward; // Flag to indicate if currently rotating forward

    private void Start()
    {
        rotatingForward = true;
    }

    void Update()
    {
        // Calculate the rotation direction based on the current state
        float targetAngle = rotatingForward ? maxAngle : minAngle;

        // Smoothly interpolate the rotation towards the target angle
        currentAngle = Mathf.MoveTowardsAngle(currentAngle, targetAngle, rotationSpeed * Time.deltaTime);

        // Clamp the current angle within the specified range
        currentAngle = Mathf.Clamp(currentAngle, minAngle, maxAngle);

        // Apply the rotation to the object
        transform.rotation = Quaternion.Euler(0f, currentAngle, 0f);

        // If the object reaches the target angle, reverse the rotation direction
        if (Mathf.Approximately(currentAngle, targetAngle))
        {
            rotatingForward = !rotatingForward;
        }
    }
}


