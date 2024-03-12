using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class speed_text_script : MonoBehaviour
{

    public TMP_Text speedtext;
    public EasyAirplaneControls myPlaneRef;
    public float planeSpeed;
    // Start is called before the first frame update
    void Start()
    {
        planeSpeed = myPlaneRef.currentSpeed;
    }

    // Update is called once per frame
    void Update()
    {
        planeSpeed = myPlaneRef.currentSpeed;
        
        speedtext.SetText(planeSpeed.ToString());   
    }
}
