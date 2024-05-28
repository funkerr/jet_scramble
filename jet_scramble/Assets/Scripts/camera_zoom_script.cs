using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MoreMountains.Feedbacks;
using Unity.VisualScripting;

public class camera_zoom_script : MonoBehaviour
{

    public MMF_Player cameraZoomIn;
    public MMF_Player cameraZoomOut;

 

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            
            cameraZoomIn.PlayFeedbacks();
        }
        else
        {
            cameraZoomOut.PlayFeedbacks();
            
        }
    }
}
