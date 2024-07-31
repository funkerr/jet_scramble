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

    //[Foldout("PS")]
    //public ParticleSystem jet_cloudpuff_left;
    
    ////public ParticleSystem jet_cloudpuff_right;

    [Foldout("Player Ref")]
    public EasyAirplaneControls myPlayerControls;

    [Foldout("Feedbacks")]
    public MMF_Player feedback_test_player;
    public MMF_Feedbacks jet_booster_feedbacks;
    public MMF_Feedbacks jet_booster_feedbacks2;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
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

        if (myPlayerControls.currentSpeed == 45f)
        {
            Debug.Log("speed is 45");
            //jet_cloudpuff_left.loop = false;
            //jet_booster_feedbacks.PlayFeedbacks();
            jet_booster_feedbacks.Play(transform.position,1);
            

        }
        else
        {
           //jet_cloudpuff_left.Stop();
           //jet_booster_feedbacks.StopFeedbacks();
        }

    }
}
