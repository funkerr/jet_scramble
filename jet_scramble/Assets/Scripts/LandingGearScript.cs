using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class LandingGearScript : MonoBehaviour
{
    public float wheelRotation;
    public float timeRotation;
    public GameObject wheelLeft;
    public GameObject wheelRight;
    public GameObject wheelCoverL;
    public GameObject wheelCoverR;

    public bool gearRaised;
    public bool gearLowered;


    // Start is called before the first frame update
    void Start()
    {
        gearLowered = true;
        gearRaised = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha8) && gearLowered)
        {
            RaiseGear();
        }
        if (Input.GetKeyDown(KeyCode.Alpha9) && gearRaised)
        {
           LowerWheelCover();
        }
    }
   
    
    //RAISE LANDING GEAR


    void RaiseGear()
    {
        wheelLeft.transform.DOLocalRotate(new Vector3(0, 0, wheelRotation), timeRotation, RotateMode.Fast);
        wheelRight.transform.DOLocalRotate(new Vector3(0, 180, -70), timeRotation, RotateMode.Fast);
        StartCoroutine("RaiseWheelCover");
       
    }

    IEnumerator RaiseWheelCover()
    {
        yield return new WaitForSeconds(3);
        wheelCoverR.transform.DOLocalRotate(new Vector3(0, 0, 0), 2, RotateMode.Fast);
        wheelCoverL.transform.DOLocalRotate(new Vector3(0, 180, 0), 2, RotateMode.Fast);
        yield return new WaitForSeconds(2);
        Debug.Log("Gear Raised");
        gearRaised = true;
        gearLowered = false;
    }


    //LOWER LANDING GEAR
    //testing

    void LowerWheelCover()
    {

        wheelCoverR.transform.DOLocalRotate(new Vector3(0, 0, -80), 2, RotateMode.Fast);
        wheelCoverL.transform.DOLocalRotate(new Vector3(0, 180, -80), 2, RotateMode.Fast);
        StartCoroutine("LowerGear");


    }

    IEnumerator LowerGear()
    {
        yield return new WaitForSeconds(2f); 
        wheelLeft.transform.DOLocalRotate(new Vector3(0, 180, 100), timeRotation, RotateMode.Fast);
        wheelRight.transform.DOLocalRotate(new Vector3(0, 0, 100), timeRotation, RotateMode.Fast);
        Debug.Log("Gear Lowered");
        gearLowered = true;
        gearRaised = false;
    }

   
}
