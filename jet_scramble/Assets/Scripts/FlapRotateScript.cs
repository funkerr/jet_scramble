using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using VHierarchy;
using VInspector;

public class FlapRotateScript : MonoBehaviour
{

    //public float tailRotateAngle;
    [Foldout("RightWings")]
    public GameObject flap_r1;
    public GameObject flap_r2;

    [Foldout("LeftWings")]
    public GameObject flap_l1;
    public GameObject flap_l2;
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
            flap_r1.transform.DOLocalRotate(new Vector3(-29.898f, -13.042f, -14.198f), 1, RotateMode.Fast);
        }
        else
        {
            flap_r1.transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 1, RotateMode.Fast);
        }

        if (Input.GetKey(KeyCode.D))
        {
            flap_r1.transform.DOLocalRotate(new Vector3(24.593f, -25.945f, -13.523f), 1, RotateMode.Fast);
        }
        else
        {
            flap_r1.transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 1, RotateMode.Fast);
        }

  

        if (Input.GetKey(KeyCode.A))
        {
            flap_r2.transform.DOLocalRotate(new Vector3(-13.126f, -23.743f, 9.568f), 1, RotateMode.Fast);
        }
        else
        {
            flap_r2.transform.DOLocalRotate(new Vector3(-0.412f, -21.618f, 9.316f), 1, RotateMode.Fast);
        }


        if (Input.GetKey(KeyCode.D))
        {
            flap_r2.transform.DOLocalRotate(new Vector3(24.561f, -17.252f, 10.252f), 1, RotateMode.Fast);
        }
        else
        {
            flap_r2.transform.DOLocalRotate(new Vector3(-0.412f, -21.618f, 9.316f), 1, RotateMode.Fast);
        }

        if (Input.GetKey(KeyCode.A))
        {
            flap_l1.transform.DOLocalRotate(new Vector3(29.914f, -166.963f, -14.2f), 1);
        }
        else
        {
            flap_l1.transform.DOLocalRotate(new Vector3(-0.652f, -159.912f, -12.277f), 1, RotateMode.Fast);
        }

    }
}
