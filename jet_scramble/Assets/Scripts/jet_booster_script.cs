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

    [Foldout("PS")]
    public ParticleSystem jet_cloudpuff_left;
    public ParticleSystem jet_cloudpuff_right;

    [Foldout("Player Ref")]
    public EasyAirplaneControls myPlayerControls;

    [Foldout("Feedbacks")]
    public MMFeedback jet_booster_feedback;

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

        if (myPlayerControls.currentSpeed >= 45f)
        {
            Debug.Log("speed is 45");
            //jet_cloudpuff_left.loop = false;
            jet_cloudpuff_left.Play();
            

        }
        else
        {
           //jet_cloudpuff_left.Stop();
        }

    }
}
