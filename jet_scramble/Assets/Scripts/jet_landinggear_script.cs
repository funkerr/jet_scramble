using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using VInspector;
using MoreMountains.Feedbacks;
using UnityEngine.UIElements;

public class jet_landinggear_script : MonoBehaviour
{


    [Foldout("floats")]
    public float gearTime;

    [Foldout("Transforms")]
    public Transform frontWheel;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.Alpha8))
        {
            RaiseFrontWheel(frontWheel);
        }
    }

    public void RaiseFrontWheel(Transform fw)
    {
        fw.transform.DOLocalMove(new Vector3(0,1.3f,0),gearTime);
        //elevator_right.transform.localRotation = Quaternion.Euler(30 * (planeMovement.currentElevatorRotation / planeMovement.maxElevatorRotation), 0, 0);
    }
}

