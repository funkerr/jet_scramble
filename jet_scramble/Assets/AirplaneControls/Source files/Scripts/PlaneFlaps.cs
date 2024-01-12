using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneFlaps : MonoBehaviour {
    public EasyAirplaneControls planeMovement;
    public Transform elevator;

    public Transform rudder;

    public Transform aileronR;
    public Transform aileronL;
    // Use this for initialization
    void Start () {
        planeMovement = GetComponentInParent<EasyAirplaneControls>();
	}
	
	// Update is called once per frame
	void Update () {
        elevator.transform.localRotation = Quaternion.Euler(30*(-planeMovement.currentElevatorRotation / planeMovement.maxElevatorRotation), 0, 0);
        aileronL.transform.localRotation = Quaternion.Euler(45f * (planeMovement.currentAileronRotation / planeMovement.maxAileronRotation), 0, 0);
        aileronR.transform.localRotation = Quaternion.Euler(45f * (-planeMovement.currentAileronRotation / planeMovement.maxAileronRotation), 0, 0);
        rudder.transform.localRotation = Quaternion.Euler(0, Mathf.Clamp(45f * (-planeMovement.currentRudderRotation / planeMovement.maxRudderRotation), -45, 45), 0);
    }
}
