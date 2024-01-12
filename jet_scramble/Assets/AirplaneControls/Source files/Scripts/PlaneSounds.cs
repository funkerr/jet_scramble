using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneSounds : MonoBehaviour
{
    private EasyAirplaneControls planeMovement;
    public AudioSource idle;
    public AudioSource mid;
    public AudioSource high;
    public AudioSource far;
    public AudioSource planeRoll;

    public AnimationCurve idle_volume;
    public AnimationCurve planeRoll_Pitch;
    public AnimationCurve planeRoll_Volume;

    public AudioSource land;

    // Use this for initialization
    void Start () {
        planeMovement = GetComponentInParent<EasyAirplaneControls>();
		
	}
	
	// Update is called once per frame
	void Update () {

        far.volume = planeMovement.throttle * 0.38f;
        far.pitch = 0.7f + planeMovement.throttle*0.3f;

        idle.volume = idle_volume.Evaluate(planeMovement.throttle);
        idle.pitch = 0.8f + planeMovement.throttle*1.6f;


        mid.volume = planeMovement.throttle;
        mid.pitch = 0.8f + planeMovement.throttle * 0.6f + planeMovement.maxSpeedPercent * 0.3f - planeMovement.stallingPercent * 0.6f;

        high.volume = planeMovement.throttle;
        high.pitch = 0.8f + planeMovement.throttle * 0.6f + planeMovement.maxSpeedPercent * 0.3f - planeMovement.stallingPercent * 0.6f;
        if (planeMovement.grounded)
        {
                planeRoll.volume = planeRoll_Volume.Evaluate(planeMovement.currentSpeed);
            planeRoll.pitch = planeRoll_Pitch.Evaluate(planeMovement.currentSpeed);
            
        }
        else
        {
            planeRoll.volume = Mathf.Lerp(planeRoll.volume, 0, 5 * Time.deltaTime);
        }
    }
}
