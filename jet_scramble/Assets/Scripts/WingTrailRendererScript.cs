using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WingTrailRendererScript : MonoBehaviour


{

    public TrailRenderer myTrail;

    public EasyAirplaneControls easyAirplaneControls;


    // Update is called once per frame
    void Update()
    {
 
        if (easyAirplaneControls.currentSpeed > 25 && (Input.GetKey(KeyCode.S)))
        {
            StartCoroutine("DelayTrail",.5f);
            //myTrail.emitting = true;
        }
        else
        {
            StartCoroutine("DelayTrailOff", .5f);
            //myTrail.emitting = false;
        }

    }

    IEnumerator DelayTrail(float my_secs)
    {
        yield return new WaitForSeconds(my_secs);
        myTrail.emitting = true;
    }

    IEnumerator DelayTrailOff(float my_secs)
    {
        yield return new WaitForSeconds(my_secs);
        myTrail.emitting = false;
    }
}
