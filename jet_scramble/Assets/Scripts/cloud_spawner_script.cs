using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class cloud_spawner_script : MonoBehaviour
{
    public GameObject[] cloudPrefabs = new GameObject[5];
    public float radius;
    //public sphere

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Instantiate(cloudPrefabs[Random.Range(0,cloudPrefabs.Length)],Random.insideUnitSphere * radius, transform.rotation);
    }
}
