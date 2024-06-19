using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.TextCore;


    [System.Serializable]
    public class Weapon
    {
        public int damage;
        public string name;
        public string description;
        public GameObject myObj;


        public Weapon(int dmg, string ID, string desc, GameObject obj)
        {
            damage = dmg;
            name = ID;
            description = desc;
            myObj = obj;

        }
    }


