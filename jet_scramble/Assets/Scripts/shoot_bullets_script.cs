using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using MoreMountains.Feedbacks;
using VInspector;


public class shoot_bullets_script : MonoBehaviour
{
    [Foldout("Transforms")]
    public Transform bulletSpawnPoint;
    public Transform spentShell_right1;
    public Transform explodeEffectSpawn1;
    public Transform gunFlashParent;

    [Foldout("Rigidbodies")]
    public Rigidbody bulletPrefab;

    [Foldout("ParticleSystems")]
    public ParticleSystem spentShells;
    public ParticleSystem bulletEffect;

    [Foldout("Floats")]
    public float currentBulletSpeed;
    public float bulletForce;
    public float bulletCount;
    public float airSpeed;

    //public PlayerManagerScript myPlayerManagerScript;

    //public PhotonView myPhotonview;

    //public bool hasAmmo = true;
    [Foldout("FireAttributes")]
    public float fireRate;
    public bool allowFire;

    [Foldout("Feels")]
    public MMF_Player bulletFeel;


    [Tab("Player Refs")]
    public EasyAirplaneControls airPlaneScript;


    [Button("PlayFeels")]
    void StartFeels()
    {
        bulletFeel.PlayFeedbacks();
    }

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

           
            bulletFeel.PlayFeedbacks();
        

            gunFlash = Instantiate(bulletEffect, transform.position, transform.rotation);  //work on the gun flash moving //yes!! tranform move to parent upon instantiate  works!
            gunFlash.transform.parent = gunFlashParent.transform;
            
                       
            bulletClone = Instantiate(bulletPrefab, transform.position, transform.rotation) as Rigidbody;
           

            

            bulletShellClone = Instantiate(spentShells, transform.position, transform.rotation);
            bulletShellClone.transform.parent = gunFlashParent.transform; //test 5/10

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

    private void OnCollisionEnter(Collision col)
    {
        Debug.Log("Bullet hit something: " + col.gameObject);
        //Destroy(gameObject, .005f);

    }




}
