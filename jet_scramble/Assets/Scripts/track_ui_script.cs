using QFSW.QC;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class track_ui_script : MonoBehaviour
{

    public Transform _myTargetTransform;
    //public Camera _myCamera;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //transform.position = _myCamera.WorldToScreenPoint(_myTargetTransform.position);
        transform.rotation = Quaternion.LookRotation(transform.position - _myTargetTransform.transform.position);
    }
}
