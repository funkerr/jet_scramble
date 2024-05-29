using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MoreMountains.Feedbacks;
using VInspector;

public class stuka_bomb_script : MonoBehaviour
{

    public Rigidbody myBomb;
    public ParticleSystem myBombExplosion;
    public float bombVelocity;

    [Foldout("Feedbacks")]
    public MMF_Player stukaBombFeebackPlayer;

  


    // Start is called before the first frame update
    void Start()
    {
        //myBomb.GetComponent<TrailRenderer>().emitting = false;
    }

    void OnCollisionEnter(Collision col)
    {
        //ContactPoint contact = col.contacts[0];
        Debug.Log(col.gameObject.name);


        if (col.gameObject.tag == "Ground")
        {
            Debug.Log("Hit terrain: " + col.gameObject.name);
            Instantiate(myBombExplosion, transform.position, transform.rotation);

            stukaBombFeebackPlayer.PlayFeedbacks();

            myBomb.GetComponent<MeshRenderer>().enabled = false;
            myBomb.GetComponent<BoxCollider>().enabled = false;
            //myPlayerScript.myPlayerAmmo.bombs = 0;
            Destroy(gameObject, 2f);


        }

    }

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.B))
        {
           // Rigidbody bombClone = Instantiate(myBomb, transform.position,transform.rotation) as Rigidbody;
           

            myBomb.GetComponent<Rigidbody>().useGravity = true;
            myBomb.velocity  = transform.TransformDirection(Vector3.forward * bombVelocity);
            //myBomb.transform.DOLocalRotate(new Vector3(45, 0, 0), 2, RotateMode.Fast);

            StartCoroutine("DelayBombCollider");

            //myBomb.GetComponent<BoxCollider>().enabled = true;
            //myBomb.GetComponent<TrailRenderer>().emitting = true;
           
        }
    }

   

    IEnumerator DelayBombCollider()
    {
        yield return new WaitForSeconds(1f);
        myBomb.GetComponent<BoxCollider>().enabled = true;

    }

}
