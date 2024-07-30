using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using VHierarchy;
using VInspector;

public class FlapRotateScript_Synty_Jet : MonoBehaviour
{

    //public float tailRotateAngle;
    [Foldout("RightWings")]
    public GameObject flap_r1;
    public GameObject flap_r2;


    [Foldout("LeftWings")]
    public GameObject flap_l1;
    public GameObject flap_l2;

    [Foldout("Rudders")]
    public GameObject rudder_left;
    public GameObject rudder_right;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
        //rotate rudder left or right, back to 0 if button isnt pressed

        //if(Input.GetKey(KeyCode.A))
        //{
        //    //DOTween.ClearCachedTweens();
        //    DOTween.KillAll();
        //    flap_r1.transform.DOLocalRotate(new Vector3(40, 0, 0), 1);
        //    flap_l1.transform.DOLocalRotate(new Vector3(40,0,0), 1);
        //    //flap_r1.transform.DOLocalRotate(new Vector3(-40.2f, -9.633f, -16.164f), 1);
        //    //flap_l1.transform.DOLocalRotate(new Vector3(-38.918f, -149.651f, -15.86f), 1);
        //    flap_r2.transform.DOLocalRotate(new Vector3(40, 0, 0), 1);
        //    flap_l2.transform.DOLocalRotate(new Vector3(40, 0, 0), 1);

        //}
        //else
        //{
        //    flap_r1.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    flap_l1.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    //    DOTween.ClearCachedTweens();
        //    //    flap_r1.transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 1, RotateMode.Fast);
        //    //    flap_l1.transform.DOLocalRotate(new Vector3(0.652f, -159.912f, -12.277f), 1, RotateMode.Fast);
        //    flap_r2.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    flap_l2.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //}

        //if (Input.GetKey(KeyCode.D))
        //{
            
        //    flap_r1.transform.DOLocalRotate(new Vector3(-30, 0, 0), 1);
        //    flap_l1.transform.DOLocalRotate(new Vector3(-30, 0, 0), 1);
        //    //flap_r1.transform.DOLocalRotate(new Vector3(41.999f, -31.529f, -16.626f), 1, RotateMode.Fast);
        //    //flap_l1.transform.DOLocalRotate(new Vector3(43.276f, -171.594f, -16.981f), 1, RotateMode.Fast);
        //    flap_r2.transform.DOLocalRotate(new Vector3(-30, 0, 0), 1);
        //    flap_l2.transform.DOLocalRotate(new Vector3(-30, 0, 0), 1);
        //}
        //else
        //{
           
        //    flap_r1.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    flap_l1.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    //    flap_r1.transform.DOLocalRotate(new Vector3(-0.652f, -20.088f, -12.277f), 1, RotateMode.Fast);
        //    //    flap_l1.transform.DOLocalRotate(new Vector3(0.652f, -159.912f, -12.277f), 1, RotateMode.Fast);
        //    flap_r2.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //    flap_l2.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        //}

        if (Input.GetKey(KeyCode.Q))
        {
            
            rudder_left.transform.DOLocalRotate(new Vector3(0, 25, 0), 1);
        }
        else
        {
            rudder_left.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);      
        }

        if (Input.GetKey(KeyCode.E))
        {
            Debug.Log("Pressed Q");
            rudder_left.transform.DOLocalRotate(new Vector3(0,-20, 0), 1);
        }
        else
        {
            rudder_left.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        }

        if (Input.GetKey(KeyCode.Q))
        {
            Debug.Log("Pressed Q");
            rudder_right.transform.DOLocalRotate(new Vector3(0, 25, 0), 1);
        }
        else
        {
            rudder_right.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        }

        if (Input.GetKey(KeyCode.E))
        {
            Debug.Log("Pressed Q");
            rudder_right.transform.DOLocalRotate(new Vector3(0, -20, 0), 1);
        }
        else
        {
            rudder_right.transform.DOLocalRotate(new Vector3(0, 0, 0), 1);
        }


        //if (Input.GetKey(KeyCode.A))
        //{
        //    flap_r2.transform.DOLocalRotate(new Vector3(-13.126f, -23.743f, 9.568f), 1, RotateMode.Fast);
        //}
        //else
        //{
        //    flap_r2.transform.DOLocalRotate(new Vector3(-0.412f, -21.618f, 9.316f), 1, RotateMode.Fast);
        //}


        //if (Input.GetKey(KeyCode.D))
        //{
        //    flap_r2.transform.DOLocalRotate(new Vector3(24.561f, -17.252f, 10.252f), 1, RotateMode.Fast);
        //}
        //else
        //{
        //    flap_r2.transform.DOLocalRotate(new Vector3(-0.412f, -21.618f, 9.316f), 1, RotateMode.Fast);
        //}

        //if (Input.GetKey(KeyCode.A))
        //{
        //    flap_l1.transform.DOLocalRotate(new Vector3(43.276f, -171.594f, -16.981f), 1,RotateMode.Fast);
        //}
        //else
        //{
        //    flap_l1.transform.DOLocalRotate(new Vector3(0.652f, -159.912f, -12.277f), 1, RotateMode.Fast);
        //}

    }
}
