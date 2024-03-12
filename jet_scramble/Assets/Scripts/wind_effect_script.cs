using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class wind_effect_script : MonoBehaviour
{

    public GameObject wind_left;
    public GameObject wind_right;
    public EasyAirplaneControls myPlaneRef;

    // Start is called before the first frame update
    void Start()
    {
        wind_left.SetActive(false);
        wind_right.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if(myPlaneRef.currentSpeed > 40)
        {
            wind_left.SetActive(true);
            wind_right.SetActive(true);

        }
    }
}
