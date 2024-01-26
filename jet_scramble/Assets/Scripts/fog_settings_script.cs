using UnityEngine;
using System.Collections;

public class fog_settings_script : MonoBehaviour
{
    public float _myFogDens;

    void Start()
    {
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Exponential;
        RenderSettings.fogDensity = 0.00f;
        StartCoroutine(updateTheFog());
    }

    IEnumerator updateTheFog()
    {
        while (true)
        {
            //this makes the loop itself yield 
            yield return new WaitForSeconds(3);
            //testing LERP
            _myFogDens = Mathf.Lerp(RenderSettings.fogDensity, .002f, .25f) + .001f;

            RenderSettings.fogDensity = _myFogDens;
            Debug.Log(RenderSettings.fogDensity);
        }
        //if you want to stop the loop, use: break;
    }
}