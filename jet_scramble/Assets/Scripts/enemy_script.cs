using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class enemy_script : MonoBehaviour

{
    public EnemyManager myEnemyManager;
    public GameObject _myEnemyPrefab;
    public EnemyManager.Enemy EnemyStats = new EnemyManager.Enemy(100, 100);
    //public 
    //
    // Start is called before the first frame update
    void Start()
    {

        _myEnemyPrefab = myEnemyManager.EnemyPrefab1;
        EnemyStats.enemyPrefab = _myEnemyPrefab;
        
        
    }

    // Update is called once per frame
    void Update()
    {
        myEnemyManager.EnemyObject.health = 50;
    }
}
