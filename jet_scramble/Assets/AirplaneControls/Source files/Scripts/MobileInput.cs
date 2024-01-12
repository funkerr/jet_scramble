using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MobileInput {
	public bool isMovingGamepad;
	public float gamePadSize;//relative to screen height
	public Vector2 gamePadPosition; //top left, relative
	public float gamePadThumbSize; // relative to gamepad size
	public Texture2D gamePadTexture;
	public Texture2D gamePadThumbTexture;

	private float actualGamePadSize;
	private Vector2 actualGamePadPosition;

    public float sensitivityFactor;
    public int fingerId;

    public MobileInput(float x, float y, float size, float sens, Texture2D gamepad, Texture2D thumb) {
        gamePadPosition = new Vector2(x, y);
        gamePadSize = size;
        gamePadThumbSize = 0.3f;
        sensitivityFactor = sens;
        gamePadTexture = gamepad;
        gamePadThumbTexture = thumb;
    }
	public Vector2 GetGamepadVector ()
	{
		Vector2 result = Vector2.zero;
		if (isMovingGamepad) {
			if (Application.isMobilePlatform) {
                foreach (Touch t in Input.touches) {
                    if (t.fingerId == fingerId) {
                        Vector2 GamepadCenter = actualGamePadPosition + new Vector2(actualGamePadSize, actualGamePadSize) * 0.5f;
                        result = new Vector2(t.position.x, Screen.height - t.position.y) - GamepadCenter;
                        result = result * 2 / actualGamePadSize;
                    }
                }
			} else {
				Vector2 GamepadCenter = actualGamePadPosition + new Vector2 (actualGamePadSize, actualGamePadSize) * 0.5f;
				result = GetMousePosition () - GamepadCenter;
				result = result * 2 / actualGamePadSize;
			}
		}
		return result * sensitivityFactor;
	}

    public static Vector2 GetMousePosition() {
        if (Application.isMobilePlatform) {
            foreach (Touch t in Input.touches) {
                return new Vector2(t.position.x, Screen.height - t.position.y);
            }
            return new Vector2(0, 0);
        } else {
            return new Vector2(Input.mousePosition.x, Screen.height - Input.mousePosition.y);
        }
    }


	public void DrawGamePad ()
	{
		GUI.DrawTexture (new Rect (actualGamePadPosition, new Vector2 (actualGamePadSize, actualGamePadSize)), gamePadTexture);
		if (isMovingGamepad) {
			GUI.DrawTexture (new Rect (GetMousePosition() - new Vector2(actualGamePadSize*gamePadThumbSize*0.5f, actualGamePadSize*gamePadThumbSize*0.5f), new Vector3(actualGamePadSize*gamePadThumbSize, actualGamePadSize*gamePadThumbSize)), gamePadThumbTexture);
		}
	}

    public bool GetTouchDown(Rect rect) {
        foreach (Touch t in Input.touches) {
            if (t.phase == TouchPhase.Began) {
                if (rect.Contains(new Vector2(t.position.x, Screen.height- t.position.y))) {//t.phase == TouchPhase. && 
                    return true;
                }
            }
        }
        return false;
    }
    public bool GetTouch(Rect rect) {
        foreach (Touch t in Input.touches) {
            if (t.fingerId== fingerId) {
                if (rect.Contains(new Vector2(t.position.x, Screen.height - t.position.y))) {//t.phase == TouchPhase. && 
                    return true;
                }
            }
        }
        return false;
    }
    public void UpdateGamePad ()
	{
		actualGamePadSize = Screen.height * gamePadSize;
		actualGamePadPosition = new Vector2 (Screen.width * gamePadPosition.x, Screen.height * gamePadPosition.y);
			if (GetTouchDown(new Rect(actualGamePadPosition, new Vector2(actualGamePadSize, actualGamePadSize)))) {
                foreach(Touch t in Input.touches) {
                    fingerId = t.fingerId;
                }
				isMovingGamepad = true;
			
		} else if(GetTouch(new Rect(actualGamePadPosition, new Vector2(actualGamePadSize, actualGamePadSize)))==false){
			isMovingGamepad = false;
		}

	}
}
