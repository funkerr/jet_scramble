using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using VInspector;
using UnityEngine.UIElements;
using MoreMountains.Tools;
using MoreMountains.Feedbacks;

public class jet_booster_script : MonoBehaviour
{
    [Foldout("Gameobjects")]
    public GameObject booster_left;
    public GameObject booster_right;

    [Foldout("Ints")]
    public int planeSpeedint;

    //[Foldout("PS")]
    //public ParticleSystem jet_cloudpuff_left;

    ////public ParticleSystem jet_cloudpuff_right;

    [Foldout("Player Ref")]
    public EasyAirplaneControls myPlayer;

    [Foldout("Feedbacks")]
    public MMF_Player feedback_test_player;
  


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float planeSpeed = myPlayer.currentSpeed;
        planeSpeedint = (int)planeSpeed;

        if(Input.GetKey(KeyCode.R))
        {
            booster_left.transform.DOScale(1.25f, 1f);
            booster_right.transform.DOScale(1.25f, 1f);

            //dustLeft.Stop();
            //dustRight.Stop();

        }
        else
        {
            booster_left.transform.DOScale(.5f, .5f);
            booster_right.transform.DOScale(.5f, .5f);
        }

        if (planeSpeedint == 45f)
        {
            Debug.Log("getting here");
            Debug.Log("speed is 45");
            feedback_test_player.PlayFeedbacks();
            

        }
        else
        {
           //jet_cloudpuff_left.Stop();
           //jet_booster_feedbacks.StopFeedbacks();
        }

    }
}
