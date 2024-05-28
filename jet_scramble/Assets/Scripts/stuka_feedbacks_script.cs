using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VInspector;
using MoreMountains.Feedbacks;



public class stuka_feedbacks_script : MonoBehaviour
{
    [Foldout("Player Stuffs")]
    public EasyAirplaneControls myPlayer;

    [Foldout("ParticleSystems")]
    public ParticleSystem dustLeft;
    public ParticleSystem dustRight;

    [Foldout("Bools")]
    public bool isGrounded;

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
            
            dustLeft.Stop();
            dustRight.Stop();
            
        }
    }
}
