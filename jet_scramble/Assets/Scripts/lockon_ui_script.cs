using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using VInspector;
using Febucci.UI;


public class lockon_ui__script : MonoBehaviour
{

    public Camera myCamera;
    public Transform myTarget;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //Vector3 myTargetPos = myTarget.position;
        //myTransform = myCamera.WorldToScreenPoint(myCamera.transform.position);            
        Vector3 screenPos = myCamera.WorldToScreenPoint(myTarget.position);
    }
}
