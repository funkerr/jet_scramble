using UnityEngine;
using Mono.CSharp;
using System.Collections;
using System.Collections.Generic;
using VHierarchy.Libs;
using VInspector;

public class CloudSpawner : MonoBehaviour
{
    public GameObject cloudPrefab; // The prefab of the cloud to spawn
    public int numClouds = 10; // Number of clouds to spawn
    public float spawnRadius = 20f; // Radius around the player to spawn clouds
    public float minHeight = 5f; // Minimum height of clouds
    public float maxHeight = 15f; // Maximum height of clouds

    private GameObject player; // Reference to the player GameObject

    void Start()
    {
        // Find the player GameObject using a tag, assuming your player GameObject has a "Player" tag
        player = GameObject.FindGameObjectWithTag("Player");

        // Spawn clouds
        //SpawnClouds();
    }

    private void FixedUpdate()
    {
        SpawnClouds();
    }

    void SpawnClouds()
    {
        for (int i = 0; i < numClouds; i++)
        {
            // Calculate random position around the player within spawnRadius
            Vector3 randomPos = player.transform.position + Random.insideUnitSphere * spawnRadius;
            randomPos.y = Mathf.Clamp(randomPos.y, minHeight, maxHeight); // Clamp Y position between minHeight and maxHeight

            // Instantiate a cloud at the random position
            GameObject cloud = Instantiate(cloudPrefab, randomPos, Quaternion.identity);

            // Parent the cloud to the CloudSpawner GameObject for organization
            cloud.transform.parent = transform;
            Destroy(cloud,2f);
        }
    }
}
