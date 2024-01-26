using Mono.CSharp;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using VInspector;

public class fog_height_script : MonoBehaviour
{
    public EasyAirplaneControls _myAirplane;
    public float _fogDensityCurrent;
    public float _fogIncrease;

    public bool setFogEnabled = true;
    

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //_fogDensityCurrent = RenderSettings.fogDensity;
        Debug.Log(_fogDensityCurrent);
        Debug.Log("The RenderSetting.FogDensity is set at" + RenderSettings.fogDensity);
        //StartCoroutine("FogFadingCoRoutine");
        //RenderSettings.fogDensity = _fogDensityCurrent * _fogIncrease * Time.deltaTime;

    }

    [Foldout("Bool")]
    public bool setFog()
    {
        return RenderSettings.fog;
    }

    IEnumerator FogFadingCoRoutine()
    {
        while(_myAirplane.currentHeight > 150)
        {
            RenderSettings.fogDensity = _fogDensityCurrent * _fogIncrease * Time.deltaTime;
        }
        return null;
    }
}
