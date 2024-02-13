using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class flare_script : MonoBehaviour
{
    public Rigidbody flare_prefab;
    public GameObject flare;
    public Transform flare_launch_location;

    public float flare_force;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.X))
        {
            Rigidbody rb =  Instantiate(flare_prefab, flare_launch_location.position, flare_launch_location.transform.rotation) as Rigidbody;
            //GameObject go = Instantiate(flare, flare_launch_location.position, flare_launch_location.rotation);
            //rb.transform.Translate(new Vector3(0, 0, 1) * flare_force * Time.deltaTime);

            //go.transform.Translate(new Vector3(0, 0, 1) * 500 * Time.deltaTime);
        }
    }
}
