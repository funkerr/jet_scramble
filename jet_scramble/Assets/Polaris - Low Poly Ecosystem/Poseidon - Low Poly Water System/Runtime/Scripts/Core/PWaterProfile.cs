using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Serialization;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Pinwheel.Poseidon
{
    [CreateAssetMenu(menuName = "Poseidon/Water Profile")]
    public class PWaterProfile : ScriptableObject
    {
        [SerializeField]
        private PLightingModel lightingModel;
        public PLightingModel LightingModel
        {
            get
            {
                return lightingModel;
            }
            set
            {
                lightingModel = value;
            }
        }

        [SerializeField]
        private bool useFlatLighting;
        public bool UseFlatLighting
        {
            get
            {
                return useFlatLighting;
            }
            set
            {
                useFlatLighting = value;
            }
        }

        [SerializeField]
        private int renderQueueIndex;
        public int RenderQueueIndex
        {
            get
            {
                return renderQueueIndex;
            }
            set
            {
                renderQueueIndex = value;
            }
        }

        [SerializeField]
        private Color color;
        public Color Color
        {
            get
            {
                return color;
            }
            set
            {
                color = value;
            }
        }

        [SerializeField]
        private Color specColor;
        public Color SpecColor
        {
            get
            {
                return specColor;
            }
            set
            {
                specColor = value;
            }
        }

        [SerializeField]
        private float smoothness;
        public float Smoothness
        {
            get
            {
                return smoothness;
            }
            set
            {
                smoothness = Mathf.Clamp01(value);
            }
        }

        [FormerlySerializedAs("enableLightAbsorbtion")]
        [SerializeField]
        private bool enableLightAbsorption;
        public bool EnableLightAbsorption
        {
            get
            {
                return enableLightAbsorption;
            }
            set
            {
                enableLightAbsorption = value;
            }
        }

        [SerializeField]
        private Color depthColor;
        public Color DepthColor
        {
            get
            {
                return depthColor;
            }
            set
            {
                depthColor = value;
            }
        }

        [SerializeField]
        private float maxDepth;
        public float MaxDepth
        {
            get
            {
                return maxDepth;
            }
            set
            {
                maxDepth = Mathf.Max(0, value);
            }
        }

        [SerializeField]
        private bool enableFoam;
        public bool EnableFoam
        {
            get
            {
                return enableFoam;
            }
            set
            {
                enableFoam = value;
            }
        }

        [SerializeField]
        private Color foamColor;
        public Color FoamColor
        {
            get
            {
                return foamColor;
            }
            set
            {
                foamColor = value;
            }
        }

        [SerializeField]
        private float foamDistance;
        public float FoamDistance
        {
            get
            {
                return foamDistance;
            }
            set
            {
                foamDistance = Mathf.Max(0, value);
            }
        }

        [SerializeField]
        private bool enableFoamHQ;
        public bool EnableFoamHQ
        {
            get
            {
                return enableFoamHQ;
            }
            set
            {
                enableFoamHQ = value;
            }
        }

        [SerializeField]
        private float foamNoiseScaleHQ;
        public float FoamNoiseScaleHQ
        {
            get
            {
                return foamNoiseScaleHQ;
            }
            set
            {
                foamNoiseScaleHQ = value;
            }
        }

        [SerializeField]
        private float foamNoiseSpeedHQ;
        public float FoamNoiseSpeedHQ
        {
            get
            {
                return foamNoiseSpeedHQ;
            }
            set
            {
                foamNoiseSpeedHQ = value;
            }
        }

        [SerializeField]
        private float shorelineFoamStrength;
        public float ShorelineFoamStrength
        {
            get
            {
                return shorelineFoamStrength;
            }
            set
            {
                shorelineFoamStrength = Mathf.Clamp01(value);
            }
        }

        [SerializeField]
        private float rippleHeight;
        public float RippleHeight
        {
            get
            {
                return rippleHeight;
            }
            set
            {
                rippleHeight = Mathf.Clamp01(value);
            }
        }

        [SerializeField]
        private float rippleSpeed;
        public float RippleSpeed
        {
            get
            {
                return rippleSpeed;
            }
            set
            {
                rippleSpeed = value;
            }
        }

        [SerializeField]
        private float rippleNoiseScale;
        public float RippleNoiseScale
        {
            get
            {
                return rippleNoiseScale;
            }
            set
            {
                rippleNoiseScale = value;
            }
        }
               
        [SerializeField]
        private float fresnelStrength;
        public float FresnelStrength
        {
            get
            {
                return fresnelStrength;
            }
            set
            {
                fresnelStrength = Mathf.Max(0, value);
            }
        }

        [SerializeField]
        private float fresnelBias;
        public float FresnelBias
        {
            get
            {
                return fresnelBias;
            }
            set
            {
                fresnelBias = Mathf.Clamp01(value);
            }
        }

        [SerializeField]
        private bool enableReflection;
        public bool EnableReflection
        {
            get
            {
                return enableReflection;
            }
            set
            {
                enableReflection = value;
            }
        }

        [SerializeField]
        private int reflectionTextureResolution;
        public int ReflectionTextureResolution
        {
            get
            {
                return reflectionTextureResolution;
            }
            set
            {
                reflectionTextureResolution = Mathf.Clamp(Mathf.ClosestPowerOfTwo(value), 32, 2048);
            }
        }

        [SerializeField]
        private bool enableReflectionPixelLight;
        public bool EnableReflectionPixelLight
        {
            get
            {
                return enableReflectionPixelLight;
            }
            set
            {
                enableReflectionPixelLight = value;
            }
        }

        [SerializeField]
        private float reflectionClipPlaneOffset;
        public float ReflectionClipPlaneOffset
        {
            get
            {
                return reflectionClipPlaneOffset;
            }
            set
            {
                reflectionClipPlaneOffset = value;
            }
        }

        [SerializeField]
        private LayerMask reflectionLayers;
        public LayerMask ReflectionLayers
        {
            get
            {
                return reflectionLayers;
            }
            set
            {
                reflectionLayers = value;
            }
        }

        [SerializeField]
        private bool reflectCustomSkybox;
        public bool ReflectCustomSkybox
        {
            get
            {
                return reflectCustomSkybox;
            }
            set
            {
                reflectCustomSkybox = value;
            }
        }

        [SerializeField]
        private float reflectionDistortionStrength;
        public float ReflectionDistortionStrength
        {
            get
            {
                return reflectionDistortionStrength;
            }
            set
            {
                reflectionDistortionStrength = value;
            }
        }

        [SerializeField]
        private bool enableRefraction;
        public bool EnableRefraction
        {
            get
            {
                return enableRefraction;
            }
            set
            {
                enableRefraction = value;
            }
        }

        [SerializeField]
        private float refractionDistortionStrength;
        public float RefractionDistortionStrength
        {
            get
            {
                return refractionDistortionStrength;
            }
            set
            {
                refractionDistortionStrength = value;
            }
        }

        public void Reset()
        {
            PWaterProfile defaultProfile = PPoseidonSettings.Instance.CalmWaterProfile;
            if (defaultProfile != null)
            {
                CopyFrom(defaultProfile);
            }
        }

        public void UpdateMaterialProperties(Material mat)
        {
            if (mat == null)
                return;
            PMat.SetActiveMaterial(mat);

            PMat.SetKeywordEnable(PMat.KW_LIGHTING_BLINN_PHONG, lightingModel == PLightingModel.BlinnPhong);
            PMat.SetKeywordEnable(PMat.KW_LIGHTING_LAMBERT, lightingModel == PLightingModel.Lambert);

            PMat.SetKeywordEnable(PMat.KW_FLAT_LIGHTING, useFlatLighting);

            PMat.SetRenderQueue(PMat.QUEUE_TRANSPARENT + RenderQueueIndex);

            PMat.SetColor(PMat.COLOR, color);
            PMat.SetColor(PMat.SPEC_COLOR, specColor);
            PMat.SetColor(PMat.SPEC_COLOR_BLINN_PHONG, specColor);
            PMat.SetFloat(PMat.SMOOTHNESS, smoothness);

            PMat.SetKeywordEnable(PMat.KW_LIGHT_ABSORPTION, enableLightAbsorption);
            PMat.SetColor(PMat.DEPTH_COLOR, depthColor);
            PMat.SetFloat(PMat.MAX_DEPTH, maxDepth);

            PMat.SetKeywordEnable(PMat.KW_FOAM, enableFoam);
            PMat.SetKeywordEnable(PMat.KW_FOAM_HQ, enableFoamHQ);
            PMat.SetColor(PMat.FOAM_COLOR, foamColor);
            PMat.SetFloat(PMat.FOAM_DISTANCE, foamDistance);
            PMat.SetFloat(PMat.FOAM_NOISE_SCALE_HQ, foamNoiseScaleHQ);
            PMat.SetFloat(PMat.FOAM_NOISE_SPEED_HQ, foamNoiseSpeedHQ);
            PMat.SetFloat(PMat.SHORELINE_FOAM_STRENGTH, shorelineFoamStrength);

            PMat.SetFloat(PMat.RIPPLE_HEIGHT, rippleHeight);
            PMat.SetFloat(PMat.RIPPLE_NOISE_SCALE, rippleNoiseScale);
            PMat.SetFloat(PMat.RIPPLE_SPEED, rippleSpeed);

            PMat.SetFloat(PMat.FRESNEL_STRENGTH, fresnelStrength);
            PMat.SetFloat(PMat.FRESNEL_BIAS, fresnelBias);

            PMat.SetKeywordEnable(PMat.KW_REFLECTION, enableReflection);
            PMat.SetFloat(PMat.REFLECTION_DISTORTION_STRENGTH, reflectionDistortionStrength);

            PMat.SetKeywordEnable(PMat.KW_REFRACTION, enableRefraction);
            PMat.SetFloat(PMat.REFRACTION_DISTORTION_STRENGTH, enableRefraction ? refractionDistortionStrength : 0);

            PMat.SetActiveMaterial(null);
        }

        public void CopyFrom(PWaterProfile p)
        {
            LightingModel = p.LightingModel;
            RenderQueueIndex = p.RenderQueueIndex;
            UseFlatLighting = p.UseFlatLighting;

            Color = p.Color;
            SpecColor = p.SpecColor;
            Smoothness = p.Smoothness;

            EnableLightAbsorption = p.EnableLightAbsorption;
            DepthColor = p.DepthColor;
            MaxDepth = p.MaxDepth;

            EnableFoam = p.EnableFoam;
            FoamColor = p.FoamColor;
            FoamDistance = p.FoamDistance;
            EnableFoamHQ = p.EnableFoamHQ;
            FoamNoiseScaleHQ = p.FoamNoiseScaleHQ;
            FoamNoiseSpeedHQ = p.FoamNoiseSpeedHQ;
            ShorelineFoamStrength = p.ShorelineFoamStrength;

            RippleHeight = p.RippleHeight;
            RippleSpeed = p.RippleSpeed;
            RippleNoiseScale = p.RippleNoiseScale;

            FresnelStrength = p.FresnelStrength;
            FresnelBias = p.FresnelBias;

            EnableReflection = p.EnableReflection;
            ReflectionTextureResolution = p.ReflectionTextureResolution;
            EnableReflectionPixelLight = p.EnableReflectionPixelLight;
            ReflectionClipPlaneOffset = p.ReflectionClipPlaneOffset;
            ReflectionLayers = p.ReflectionLayers;
            ReflectCustomSkybox = p.ReflectCustomSkybox;
            ReflectionDistortionStrength = p.ReflectionDistortionStrength;

            EnableRefraction = p.EnableRefraction;
            RefractionDistortionStrength = p.RefractionDistortionStrength;
        }
    }
}
