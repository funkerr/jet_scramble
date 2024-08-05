using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
//using VInspector;
using MoreMountains.Feedbacks;
using UnityEngine.UIElements;
using Sirenix.OdinInspector;

public class jet_landinggear_script : MonoBehaviour
{


    [FoldoutGroup("Floats")]
    public float gearTime;
    [FoldoutGroup("Floats")]
    public float disableTime;

    [FoldoutGroup("Transforms")]
    public Transform frontWheel;
    [FoldoutGroup("Transforms")]
    public Transform frontWheelCover;
    [FoldoutGroup("Transforms")]
    public Transform rearWheel_L;
    [FoldoutGroup("Transforms")]
    public Transform rearWheelCover_L;
    [FoldoutGroup("Transforms")]
    public Transform rearWheel_R;
    [FoldoutGroup("Transforms")]
    public Transform rearWheelCover_R;
    

    [FoldoutGroup("Gameobjects")]
    //[HorizontalGroup("Split", Width = 50), PreviewField(50)]
    public GameObject frontWheelAxel;
    [FoldoutGroup("Gameobjects")]
    public GameObject rearWheelAxel_L;
    [FoldoutGroup("Gameobjects")]
    public GameObject rearWheelAxel_R;

    [FoldoutGroup("Feedbacks")]
    public MMF_Player wheelCoverFeedBack;

    // Start is called before the first frame update
    [Button(ButtonSizes.Small)]
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.Alpha8))
        {
            RaiseFrontWheel(frontWheel, frontWheelAxel, frontWheelCover);
            RaiseRearWheelLeft(rearWheel_L, rearWheelAxel_L, rearWheelCover_L);
            RaiseRearWheelRight(rearWheel_R, rearWheelAxel_R, rearWheelCover_R);
        }
    }
    [Button(ButtonSizes.Small)]
    void RaiseFrontWheel(Transform fw, GameObject go,Transform fwc)
    {
        
        Sequence fw_gear_sequence = DOTween.Sequence();
        fw_gear_sequence.Append(fw.transform.DOLocalRotate(new Vector3(-15f, 0, 0), gearTime -.25f, RotateMode.Fast));
        StartCoroutine("DisableAxelRenderer",frontWheelAxel);
        fw_gear_sequence.Append(fw.transform.DOLocalMove(new Vector3(0, 2f, 0), 2f));

        // Insert a rotation tween which will last half the duration
        // and will loop forward and backward twice
        fw_gear_sequence.Insert(2, fwc.DOLocalRotate(new Vector3(0, 0, 0),1.85f).SetEase(Ease.OutQuad));

   

    }

    void RaiseRearWheelLeft(Transform fw, GameObject go, Transform fwc)
    {

        Sequence fw_gear_sequence = DOTween.Sequence();
        fw_gear_sequence.Append(fw.transform.DOLocalRotate(new Vector3(0f, 0, -12f), gearTime - .25f, RotateMode.Fast));
        StartCoroutine("DisableAxelRenderer", rearWheelAxel_L);
        fw_gear_sequence.Append(fw.transform.DOLocalMove(new Vector3(0, 1.575f, 0), 2f));

        // Insert a rotation tween which will last half the duration
        // and will loop forward and backward twice
        fw_gear_sequence.Insert(2, fwc.DOLocalRotate(new Vector3(0, 0, 0), 2f).SetEase(Ease.OutQuad));



    }

    void RaiseRearWheelRight(Transform fw, GameObject go, Transform fwc)
    {

        Sequence fw_gear_sequence = DOTween.Sequence();
        fw_gear_sequence.Append(fw.transform.DOLocalRotate(new Vector3(0f, 0, -12f), gearTime - .25f, RotateMode.Fast));
        StartCoroutine("DisableAxelRenderer", rearWheelAxel_R);
        fw_gear_sequence.Append(fw.transform.DOLocalMove(new Vector3(0, 1.575f, 0), 2f));

        // Insert a rotation tween which will last half the duration
        // and will loop forward and backward twice
        fw_gear_sequence.Insert(2, fwc.DOLocalRotate(new Vector3(0, 0, 0), 2f).SetEase(Ease.OutQuad));
        StartCoroutine("PlayDustFeedbacks", wheelCoverFeedBack);



    }



    IEnumerator DisableAxelRenderer(GameObject go)

    {
        yield return new WaitForSeconds(disableTime);
        go.gameObject.GetComponent<MeshRenderer>().enabled = false;
        
    }

    IEnumerator PlayDustFeedbacks(MMF_Player fb_player)
    {
        yield return new WaitForSeconds(3.5f);
        fb_player.PlayFeedbacks();
    }
}

