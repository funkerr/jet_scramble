using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneTrails : MonoBehaviour {

    public EasyAirplaneControls planeMovement;
    public TrailRenderer trail1;
    public TrailRenderer trail2;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        float w = Mathf.Clamp((planeMovement.maxSpeedPercent - 0.1f), 0, 1) * 5;
        trail1.startWidth = w;
        trail2.startWidth = w;
    }
}
