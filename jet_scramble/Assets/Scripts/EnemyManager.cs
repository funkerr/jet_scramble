using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using VHierarchy;




public class EnemyManager : MonoBehaviour
{
    public GameObject EnemyPrefab1;
    public GameObject EnemyPrefab2;

    //public List<GameObject> EnemyPrefabsToLoad = new List<GameObject>();
    //public GameObject[] EnemyPrefabs = new GameObject[3];

    
    public class Enemy
    {

        public GameObject enemyPrefab;
        public int health;
        public int speed;

        public Enemy(int _health, int _speed)
        {
            GameObject _enemyPrefab = enemyPrefab;
            health = _health;
            speed = _speed;
        }
    }
    [SerializeField]
    //public Enemy EnemyGO = new Enemy(en,100,100);
    public Enemy EnemyObject = new Enemy(100, 100);
    

    public void TestClass()
    {
        if(Input.GetKeyDown(KeyCode.F))
            {
            Debug.Log("Pressed F");
            //sDebug.Log(EnemyGO.EnemyPrefabs[1].name);
            Debug.Log(EnemyObject.health);
            }
    }

    public void Update()
    {
        TestClass();
    }

}