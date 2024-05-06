using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ignore_physics_script : MonoBehaviour
{
    // Start is called before the first frame update

    public Collider colToIgnore;
    public GameObject IgnoreRadar;
    void Start()
    {
        IgnoreRadar = GameObject.FindGameObjectWithTag("Radar");
    }

    // Update is called once per frame
    void Update()
    {
        Physics.IgnoreCollision(this.gameObject.GetComponent<Collider>(), IgnoreRadar.GetComponent<Collider>());
    }
}
