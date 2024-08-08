using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using MagicPigGames.ProjectileFactory;

public class pf_missle_script : MonoBehaviour
{
    [FoldoutGroup("Projectile Factory")]
    public ProjectileSpawner mySpawner;

    [FoldoutGroup("Keys")]
    public KeyCode shootKey = KeyCode.F;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(shootKey)) 
        {

            mySpawner.SpawnProjectile();

        }
    }
}
