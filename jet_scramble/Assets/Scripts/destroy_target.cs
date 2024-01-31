using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SickscoreGames.HUDNavigationSystem;

public class destroy_target : MonoBehaviour
{

    public GameObject fxExplode;
    public float destroyDelay;
    public HUDNavigationElement HUDElement;

    public Canvas myTargetCanvasRef;

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
        HUDElement.SetIndicatorActive(false);
        myTargetCanvasRef.enabled = false;
        fxExplode.SetActive(true);
        Destroy(gameObject, destroyDelay);
      
    }
}
