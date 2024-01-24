using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class target_camera_render_script : MonoBehaviour
{
    public Vector2 size;
    public Camera cam;
    public RenderTexture TargetRenderTexture;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {


        
        TargetRenderTexture = new RenderTexture((int)size.x, (int)size.y, 16, RenderTextureFormat.ARGB32);
        cam.targetTexture = TargetRenderTexture;
        cam.aspect = size.x / size.y;
    }
}
