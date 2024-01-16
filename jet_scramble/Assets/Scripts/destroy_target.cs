using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class destroy_target : MonoBehaviour
{

    public GameObject fxExplode;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision col)
    {
        Debug.Log("Target hit by: " + col.gameObject);
       
        gameObject.GetComponent<Renderer>().enabled = false;
        fxExplode.SetActive(true);
        Destroy(gameObject, 2f);
      
    }
}
