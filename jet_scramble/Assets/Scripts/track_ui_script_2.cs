using QFSW.QC;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;

public class track_ui_script_2 : MonoBehaviour
{

    public Transform _myTargetTransform;
    public Camera _myCamera;
    public Vector3 myOffset;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.position  = _myCamera.WorldToScreenPoint(_myTargetTransform.position + myOffset);
        //transform.position = _myCamera.WorldToScreenPoint(_myTargetTransform.position );
        //transform.rotation = Quaternion.LookRotation(transform.position - _myTargetTransform.transform.position);
        //Vector3 pos = _myCamera.WorldToScreenPoint(_myTargetTransform.position + myOffset);
        //Debug.Log(pos);
    }
}
