﻿#if PLAYMAKER

using System.Collections;
using System.Collections.Generic;
using HutongGames.PlayMaker;

namespace SensorToolkit.PlayMaker
{
    [ActionCategory("Sensors")]
    [Tooltip("Query a Ray Sensor for the RaycastHit details of a GameObject it has detected.")]
    public class RaySensorGetRaycastHit : SensorToolkitComponentAction<RaySensor>
    {
        [RequiredField]
        [CheckForComponent(typeof(RaySensor))]
        [Tooltip("The game object owning the Ray Sensor.")]
        public FsmOwnerDefault gameObject;

        [UIHint(UIHint.Variable)]
        [Tooltip("A GameObject detected by this sensor to get the RaycastHit details for.")]
        public FsmGameObject detectedGameObject;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the rays distance to the detected GameObject, if there is one.")]
        public FsmFloat storeDistance;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the position of the ray intersection point, if there is one.")]
        public FsmVector3 storePoint;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the normal to the ray intersection point, if there is one.")]
        public FsmVector3 storeNormal;

        public override void Reset()
        {
            gameObject = null;
            detectedGameObject = null;
            storeDistance = null;
            storePoint = null;
            storeNormal = null;
        }

        public override void OnEnter()
        {
            doCheck();
            Finish();
        }

        void doCheck()
        {
            if (!UpdateCache(Fsm.GetOwnerDefaultTarget(gameObject))) return;

            if (detectedGameObject.IsNone)
            {
                return;
            }
            else
            {
                var hit = raySensor.GetRayHit(detectedGameObject.Value);
                storeDistance.Value = hit.distance;
                storePoint.Value = hit.point;
                storeNormal.Value = hit.normal;
            }
        }
    }
}

#endif