using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class stuka_bomb_script : MonoBehaviour
{

    public GameObject myBomb;
    public ParticleSystem myBombExplosion;

  


    // Start is called before the first frame update
    void Start()
    {
        myBomb.GetComponent<TrailRenderer>().emitting = false;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.B))
        {
            myBomb.GetComponent<Rigidbody>().useGravity = true;

            StartCoroutine("DelayBombCollider");

            //myBomb.GetComponent<BoxCollider>().enabled = true;
            myBomb.GetComponent<TrailRenderer>().emitting = true;
           
        }
    }

    void OnCollisionEnter(Collision col)
    {
        ContactPoint contact = col.contacts[0];
        //Debug.Log(col.gameObject.name);

        Debug.Log("Hit something: " + col.gameObject.name);
        Instantiate(myBombExplosion, transform.position, transform.rotation);
        myBomb.GetComponent<MeshRenderer>().enabled = false;
       // myPlayerScript.myPlayerAmmo.bombs = 0;
        Destroy(gameObject, 2f);


        if (col.gameObject.tag == "Terrain")
        {
            Debug.Log("Hit terrain: " + col.gameObject.name);
            Instantiate(myBombExplosion, transform.position, transform.rotation);
            myBomb.GetComponent<MeshRenderer>().enabled = false;
           //myPlayerScript.myPlayerAmmo.bombs = 0;
            Destroy(gameObject, 2f);
            

        }

        if (col.gameObject.tag == "Building")
        {
            Debug.Log("Hit Building: " + col.gameObject.name);
            Instantiate(myBombExplosion, transform.position, transform.rotation);
            myBomb.GetComponent<MeshRenderer>().enabled = false;
            //myPlayerScript.myPlayerAmmo.bombs = 0;
            Destroy(gameObject, 2f);


        }
    }

    IEnumerator DelayBombCollider()
    {
        yield return new WaitForSeconds(1f);
        myBomb.GetComponent<BoxCollider>().enabled = true;

    }

}
