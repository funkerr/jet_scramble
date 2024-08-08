using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using UnityEngine.Rendering;

public class pj_missle_script : MonoBehaviour
{
    [FoldoutGroup("ParticleSystems")]
    public ParticleSystem missleTrailsPS;
    public GameObject parentObject;
    public float movetime;
    // Start is called before the first frame update
    void Start()
    {
        ParticleSystem ps =  Instantiate(missleTrailsPS, transform.position,transform.rotation);
        ps.Play();
        ps.transform.parent = parentObject.gameObject.transform;

    }

    // Update is called once per frame
    void Update()
    {
        //transform.Translate(Vector3.forward * movetime);
        //missleTrailsPS.Play();
        //missleTrailsPS.transform.parent= this.gameObject.transform;
    }
}
