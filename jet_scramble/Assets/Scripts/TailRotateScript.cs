using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class TailRotateScript : MonoBehaviour
{

public float tailRotateAngle;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
        //rotate rudder left or right, back to 0 if button isnt pressed

        if(Input.GetKey(KeyCode.A))
        {
            transform.DOLocalRotate(new Vector3(-29.227f, -13.236f, -14.102f), 2, RotateMode.Fast);
        }
        else
        {
            transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 2, RotateMode.Fast);
        }

        if (Input.GetKey(KeyCode.D))
        {
            transform.DOLocalRotate(new Vector3(24.593f, -25.945f, -13.523f), 2, RotateMode.Fast);
        }
        else
        {
            transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 2, RotateMode.Fast);
        }

        //if (Input.GetKey(KeyCode.D))
        //{
        //    transform.DOLocalRotate(new Vector3(0, -tailRotateAngle, 0), 1, RotateMode.Fast);
        //}
        //else
        //{
        //    transform.DOLocalRotate(new Vector3(0, 0, 0), 2, RotateMode.Fast);
        //}

    }
}
