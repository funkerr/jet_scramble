using UnityEngine;
using System.Collections;
using DG.Tweening;
using System.Security.Cryptography;

public class fog_settings_script : MonoBehaviour
{
    public float _myFogDens;
    public float _myFogDensEnd = .003f;
    float test;

    void Start()
    {


        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Exponential;
        _myFogDens = RenderSettings.fogDensity;
        Debug.Log("My fog value is: " + _myFogDens);
        //enderSettings.fogDensity
        Debug.Log("My fog end value is: " + _myFogDensEnd);
        StartCoroutine("updateTheFog");




    }

    private void Update()
    {
        //_myFogDens = RenderSettings.fogDensity;
        //DOTween.To(x => RenderSettings.fogDensity = x, 0, 0.1f, 5f);


        //RenderSettings.fogDensity = _myFogDens;
        //Debug.Log("Fog Density is " + RenderSettings.fogDensity);
    }

    IEnumerator updateTheFog()
    {
        while (true)
        {
            //this makes the loop itself yield 
            yield return new WaitForSeconds(3);
            //testing LERP
            Debug.Log("got here");
            //DOTween.To(x => RenderSettings.fogDensity = x, 0.0f, 0.1f, 10f);

            // Tween a float called myFloat to 52 in 1 second
            //DOTween.To(() => RenderSettings.fogDensity, x => RenderSettings.fogDensity = x, .1, 10);


            //RenderSettings.fogDensity = _myFogDens;
            Debug.Log("Fog Density is " + RenderSettings.fogDensity);
            break;
        }
        //if you want to stop the loop, use: break;
    }
}