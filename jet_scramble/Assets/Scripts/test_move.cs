using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test_move : MonoBehaviour
{
    public float moveSpeed;
    public Rigidbody myRB;
    public float currentSpeed;
    public EasyAirplaneControls myPlaneControls;
    [SerializeField]
    public const int testInt = 3;
    // Start is called before the first frame update
    void Start()
    {
        myPlaneControls = GameObject.FindGameObjectWithTag("Player").GetComponent<EasyAirplaneControls>();
        currentSpeed = myPlaneControls.currentSpeed;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        currentSpeed = myPlaneControls.currentSpeed;
        myRB.velocity = new Vector3(0, 0, currentSpeed) * moveSpeed;
        //myRB.MovePosition(new Vector3(0, 0, currentSpeed) * moveSpeed);
        Debug.Log(myRB.velocity);

        //easy ap control how it moves
        transform.position += -transform.forward * currentSpeed * Time.deltaTime;
    }
}
