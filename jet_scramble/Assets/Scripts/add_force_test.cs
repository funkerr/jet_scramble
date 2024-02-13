using JetBrains.Annotations;
using Mono.CSharp;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class add_force_test : MonoBehaviour
{
    public float force;
    public Rigidbody myRB;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void FixedUpdate()
    {
        transform.Translate(new Vector3(0, 0, 1) * force * Time.deltaTime);
        
    }

    private void addtheforce()
    {
        myRB.AddForce(Vector3.up * force, ForceMode.Impulse);
        return;
        
    }
}
