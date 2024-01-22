using UnityEngine;
using DG.Tweening;
using System.Collections;
using VInspector;

public class LightFadeTween : MonoBehaviour
{
    public float fadeDuration = 2f; // Duration of each fade
    public float startIntensity = 0f; // Starting intensity of the light
    public float endIntensity = 1f; // Ending intensity of the light

    private Light lightComponent;

    void Start()
    {
        lightComponent = GetComponent<Light>();

        // Set the initial intensity
        lightComponent.intensity = startIntensity;

        // Start the fade in/out loop
        StartFadeLoop();
    }

    void StartFadeLoop()
    {
        // Sequence for fade in and out
        Sequence sequence = DOTween.Sequence();

        // Fade in
        sequence.Append(lightComponent.DOIntensity(endIntensity, fadeDuration))
                .SetEase(Ease.Linear);

        // Fade out
        sequence.Append(lightComponent.DOIntensity(startIntensity, fadeDuration))
                .SetEase(Ease.Linear)
                .OnComplete(StartFadeLoop); // Restart the loop
    }
}
