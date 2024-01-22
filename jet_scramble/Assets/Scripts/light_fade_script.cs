using UnityEngine;

public class LightFade : MonoBehaviour
{
    public float fadeDuration = 2f; // Duration of each fade
    public float startIntensity = 0f; // Starting intensity of the light
    public float endIntensity = 1f; // Ending intensity of the light

    private Light lightComponent;
    private float timer = 0f;
    private bool isFadingIn = true;

    void Start()
    {
        lightComponent = GetComponent<Light>();

        // Set the initial intensity
        lightComponent.intensity = startIntensity;
    }

    void Update()
    {
        // Update the timer
        timer += Time.deltaTime;

        // Calculate the progress of the fade
        float progress = timer / fadeDuration;

        // Check if the fade is complete
        if (progress >= 1f)
        {
            // Switch between fading in and fading out
            isFadingIn = !isFadingIn;

            // Reset the timer
            timer = 0f;
        }

        // Update the light intensity based on the fade progress
        float targetIntensity = isFadingIn ? Mathf.Lerp(startIntensity, endIntensity, progress) : Mathf.Lerp(endIntensity, startIntensity, progress);
        lightComponent.intensity = targetIntensity;
    }
}

