using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneFlaps_Synty_Jet : MonoBehaviour {
    public EasyAirplaneControls planeMovement;
    public Transform elevator_left;
    public Transform elevator_right;
    //public Transform rudder_left;
    //public Transform rudder_right;

    // public Transform aileronR;
    //public Transform aileronL;
    // Use this for initialization
    void Start () {
        planeMovement = GetComponentInParent<EasyAirplaneControls>();
	}
	
	// Update is called once per frame
	void Update () {
        elevator_left.transform.localRotation = Quaternion.Euler(30*(planeMovement.currentElevatorRotation / planeMovement.maxElevatorRotation), 0, 0);
        elevator_right.transform.localRotation = Quaternion.Euler(30 * (planeMovement.currentElevatorRotation / planeMovement.maxElevatorRotation), 0, 0);
       // aileronL.transform.localRotation = Quaternion.Euler(45f * (planeMovement.currentAileronRotation / planeMovement.maxAileronRotation), 0, 0);
        //aileronR.transform.localRotation = Quaternion.Euler(45f * (-planeMovement.currentAileronRotation / planeMovement.maxAileronRotation), 0, 0);
        //rudder_left.transform.localRotation = Quaternion.Euler(0, Mathf.Clamp(45f * (-planeMovement.currentRudderRotation / planeMovement.maxRudderRotation), -45, 45), 0);
        //rudder_right.transform.localRotation = Quaternion.Euler(0, Mathf.Clamp(45f * (-planeMovement.currentRudderRotation / planeMovement.maxRudderRotation), -45, 45), 0);
    }
}
