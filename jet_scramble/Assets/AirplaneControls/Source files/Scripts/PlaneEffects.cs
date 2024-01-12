using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneEffects : MonoBehaviour {
    public EasyAirplaneControls planeMovement;
    public List<ParticleSystem> tyreSkid = new List<ParticleSystem>();
    public List<ParticleSystem> engineSmoke = new List<ParticleSystem>();

    void Start () {
        planeMovement = GetComponentInParent<EasyAirplaneControls>();

	}

    public void Landed() {
        foreach (ParticleSystem p in tyreSkid) {
            p.Play();
        }
    }
    public void EngineSmoke() {
        foreach (ParticleSystem p in engineSmoke) {
            p.Play();
        }
    }
}
