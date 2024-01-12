using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanePropeller : MonoBehaviour {

    EasyAirplaneControls planeMovement;
    public float power;

    public GameObject low;
    public GameObject high;

    public float lowrot;
    public float randomizer;
    // Use this for initialization
    void Start () {
        planeMovement = GetComponentInParent<EasyAirplaneControls>();
        lowrot = UnityEngine.Random.Range(0, 360);
        randomizer = UnityEngine.Random.Range(0.7f, 1.3f);
	}
	
	// Update is called once per frame
	void Update () {
        power = Mathf.Lerp(power, planeMovement.throttle, 1*Time.deltaTime);
        if (power > 0.5f) {
            high.SetActive(true);
            low.SetActive(false);
        } else {
            high.SetActive(false);
            low.SetActive(true);
            lowrot += (power+0.05f) * 8000f * randomizer * Time.deltaTime;
            low.transform.localRotation = Quaternion.Euler(0, 0, lowrot);
        }
	}
}
