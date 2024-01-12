using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{


    public static CameraController instance;
    private void Awake() {
        instance = this;
    }


    public bool freeCamera;
    public EasyAirplaneControls player;

    public float rigRotationY;
    public float rigRotationX;
    public Transform cameraRig;
    public float rotationSpeed;
    public float rotationSlerpSpeed;

    public float cameraSensitivty=1f;

    void LateUpdate() {
        if (Input.GetButtonDown("ToggleCamera")) {
            freeCamera = !freeCamera;
        }
        if (freeCamera && Input.GetKeyDown(KeyCode.Escape)) {
            freeCamera = false;
        }

        if (player.enableMobileInput) {
            if (player.mobileInput_camera.isMovingGamepad) {
                freeCamera = true;
            } else {
                freeCamera = false;
            }
        }

        if (freeCamera) {

            cameraRig.transform.position = player.transform.position;
            cameraRig.transform.rotation = Quaternion.Slerp(cameraRig.transform.rotation, Quaternion.Euler(rigRotationX, rigRotationY, 0), rotationSlerpSpeed * Time.deltaTime);

            Cursor.lockState = CursorLockMode.Locked;
            transform.localPosition = Vector3.Slerp(transform.localPosition, new Vector3(0, 0, 15), 3 * Time.deltaTime);
            if (player.enableMobileInput) {
                rigRotationY += -player.mobileInput_camera.GetGamepadVector().x * cameraSensitivty * rotationSpeed * 5 * Time.deltaTime;
                rigRotationX += player.mobileInput_camera.GetGamepadVector().y * cameraSensitivty * rotationSpeed * 5 * Time.deltaTime;
            } else {
                rigRotationY += Input.GetAxis("CameraHorizontal") * cameraSensitivty * rotationSpeed * Time.deltaTime;
                rigRotationX += Input.GetAxis("CameraVertical") * cameraSensitivty * rotationSpeed * Time.deltaTime;
            }
        } else {

            cameraRig.transform.position = player.transform.position;
            cameraRig.transform.rotation = Quaternion.Slerp(cameraRig.transform.rotation, Quaternion.Euler(player.transform.localEulerAngles.x, player.transform.localEulerAngles.y, 0), rotationSlerpSpeed * Time.deltaTime);

            Cursor.lockState = CursorLockMode.None;

            rigRotationX = cameraRig.transform.rotation.eulerAngles.x;
            rigRotationY = cameraRig.transform.rotation.eulerAngles.y;

            transform.position = Vector3.Slerp(transform.position, player.lockedCameraPosition.position, 3 * Time.deltaTime);

        }
    }
}
