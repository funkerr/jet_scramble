using UnityEngine;

public class DemoUI : MonoBehaviour {
    EasyAirplaneControls plane;

	void Start () {
        plane = GetComponent<EasyAirplaneControls>();
	}

    private void OnGUI() {

        GUI.Label(new Rect(0, 0, 200, 200), "Speed: " + plane.currentSpeed);
        GUI.Label(new Rect(0, 25, 200, 200), "Throttle: " + plane.throttle);
        GUI.Label(new Rect(0, 50, 200, 200), "Landed: " + plane.grounded);


        GUI.Label(new Rect(0, 75, 400, 200), "Controls not working? Please check the readme file :)");
        GUI.Label(new Rect(0, 100, 400, 200), "Disable mobile input by setting enableMobileInput to false in the plane prefab");
        GUI.Label(new Rect(0, 150, 200, 200), "Default controls:\nAileron - A, D\nElevator - W, S \nThrottle - R, F\nBrake - B\nToggle camera - T");

        if (plane.enableMobileInput) {
            plane.mobileInput_elevator.DrawGamePad();
            plane.mobileInput_rudder.DrawGamePad();
            plane.mobileInput_camera.DrawGamePad();
            plane.mobileInput_throttle.DrawGamePad();
        }
        foreach(Touch t in Input.touches) {
            GUI.Label(new Rect(t.position.x, t.position.y, 200, 200), "             " + t.fingerId);
        }
    }
    // Update is called once per frame
    void Update () {
		
	}
}
