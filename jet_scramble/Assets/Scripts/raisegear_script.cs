using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class raisegear_script : MonoBehaviour
{
    public TMP_Text raisegearText;
    public EasyAirplaneControls myPlaneRef;
    private float planespeed;
    private LandingGearScript gearScriptRef;


    
    void Start()
    {
        raisegearText.enabled = false;
        gearScriptRef = myPlaneRef.GetComponent<LandingGearScript>();
    }

    // Update is called once per frame
    void Update()
    {
        GearAlert();
    }

    public void GearAlert()
    {
        if((myPlaneRef.currentSpeed >= 40) && gearScriptRef.gearLowered)
        {
            Debug.Log("Gear should be raised");
            raisegearText.enabled = true;
        }
    }
}
