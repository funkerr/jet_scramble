using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VInspector;
using MoreMountains.Feedbacks;



public class jet_wheelrotate_script : MonoBehaviour
{
    [Foldout("Player Stuffs")]
    public EasyAirplaneControls myPlayer;

    [Foldout("Wheels")]
    public GameObject frontWheel;

    [Foldout("Bools")]
    public bool isGrounded;

    [Foldout("Feedbacks")]
    public MMF_Player frontWheelFB;

    // Start is called before the first frame update
    void Start()
    {
        
       // isGrounded = myPlayer.grounded;
    }

    // Update is called once per frame
    void Update()
    {


        isGrounded = myPlayer.GetComponent<EasyAirplaneControls>().grounded;
        


        if (myPlayer.currentSpeed > .05f && !isGrounded)
        {
           frontWheelFB.PlayFeedbacks();
            
        }
    }
}
