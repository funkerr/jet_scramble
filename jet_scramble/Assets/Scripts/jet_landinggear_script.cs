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

    [Foldout("Gameobjects")]
    public GameObject frontWheelAxel;
    //public Material  frontWheelAxel_mat;




    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.Alpha8))
        {
            RaiseFrontWheel(frontWheel, frontWheelAxel);
        }
    }

    public void RaiseFrontWheel(Transform fw, GameObject go)
    {
        Sequence test_sequence = DOTween.Sequence();
        test_sequence.Append(fw.transform.DOLocalMove(new Vector3(0, 1.3f, 0), gearTime));
        
        test_sequence.AppendInterval(.001f);
        test_sequence.Insert(5f, fw.transform.DOLocalRotate(new Vector3(-35f, 0, 0), test_sequence.Duration()));
        //
        //fw.transform.DOLocalMove(new Vector3(0,1.3f,0),gearTime);
        //fw.transform.DOLocalRotate(new Vector3(-35f, 0, 0), 5);
        //elevator_right.transform.localRotation = Quaternion.Euler(30 * (planeMovement.currentElevatorRotation / planeMovement.maxElevatorRotation), 0, 0);
    }
}

