using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;


public class shoot_bullets_script : MonoBehaviour
{

    public Transform bulletSpawnPoint;

    public Rigidbody bulletPrefab;
 
    public ParticleSystem spentShells;
    public ParticleSystem bulletEffect;

    public float currentBulletSpeed;
    public float bulletForce;
    public float bulletCount;
    public float airSpeed;

    public Transform spentShell_right1;
    public Transform explodeEffectSpawn1;
    public Transform gunFlashParent;


    public EasyAirplaneControls airPlaneScript;
    //public PlayerManagerScript myPlayerManagerScript;

    //public PhotonView myPhotonview;

    public AudioSource bulletSound;

    //public bool hasAmmo = true;

    public float fireRate;

    public bool allowFire;



    // Start is called before the first frame update
    void Start()
    {
       // bulletCount = myPlayerManagerScript.myPlayerAmmo.bullets;
      


    }

        // Update is called once per frame
        void FixedUpdate()
    {
        //if (PhotonNetwork.InRoom && !myPhotonview.IsMine)
        //{
        //    return;
        //}

        Shoot();
        
    }

    IEnumerator FiringRate()
    {
        allowFire = false;
        yield return new WaitForSeconds(fireRate);
        allowFire = true;
    }

    void Shoot()
    {
        airSpeed = airPlaneScript.currentSpeed;

        if (airSpeed < 20)
        {
            currentBulletSpeed = 20;
        }
        else
        {
            currentBulletSpeed = airSpeed;
        }

        if (Input.GetKey(KeyCode.Mouse0) && (allowFire))
        {
            Rigidbody bulletClone;
            ParticleSystem gunFlash;
            ParticleSystem  bulletShellClone;
            bulletSound.Play();

            gunFlash = Instantiate(bulletEffect, transform.position, transform.rotation);  //work on the gun flash moving //yes!! tranform move to parent upon instantiate  works!
            gunFlash.transform.parent = gunFlashParent.transform;
            
                       
            bulletClone = Instantiate(bulletPrefab, transform.position, transform.rotation) as Rigidbody;

            

            bulletShellClone = Instantiate(spentShells, transform.position, transform.rotation);

            //myPlayerManagerScript.myPlayerAmmo.bullets--;


            //bulletCount = bulletCount - 4f;

            //Debug.Log(myPlayerManager.myPlayerAmmo.bullets);

            bulletClone.AddForce(transform.forward * bulletForce * currentBulletSpeed, ForceMode.Impulse);
        
            StartCoroutine("FiringRate");

            Destroy(bulletClone.gameObject, 2f);
        }
    }

    //void CheckBulletCount()
    //    {
    //        if(myPlayerManagerScript.myPlayerAmmo.bullets == 0)
    //        allowFire = false;
    //    }
   



}
