using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test_move : MonoBehaviour
{
    public float moveSpeed;
    public Rigidbody myRB;
    public float currentSpeed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {


        myRB.velocity = myRB.velocity + currentSpeed * (transform.forward * moveSpeed);
    }
}
