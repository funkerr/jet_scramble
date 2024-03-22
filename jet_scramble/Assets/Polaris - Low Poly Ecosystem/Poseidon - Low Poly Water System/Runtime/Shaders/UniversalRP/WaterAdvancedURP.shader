Shader "Poseidon/URP/WaterAdvancedURP"
{
    Properties
    {
        [HideInInspector] _MeshNoise("Mesh Noise", Range(0.0, 1.0)) = 0

        [HideInInspector] _Color("Color", Color) = (0.0, 0.8, 1.0, 0.5)
        [HideInInspector] _Specular("Specular Color", Color) = (0.1, 0.1, 0.1, 1)
        [HideInInspector] _Smoothness("Smoothness", Range(0.0, 1.0)) = 1

        [HideInInspector] _DepthColor("Depth Color", Color) = (0.0, 0.45, 0.65, 0.85)
        [HideInInspector] _MaxDepth("Max Depth", Float) = 5

        [HideInInspector] _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _FoamDistance("Foam Distance", Float) = 1.2
        [HideInInspector] _FoamNoiseScaleHQ("Foam Noise Scale HQ", Float) = 3
        [HideInInspector] _FoamNoiseSpeedHQ("Foam Noise Speed HQ", Float) = 1
        [HideInInspector] _ShorelineFoamStrength("Shoreline Foam Strength", Float) = 1

        [HideInInspector] _RippleHeight("Ripple Height", Range(0, 1)) = 0.1
        [HideInInspector] _RippleSpeed("Ripple Speed", Float) = 5
        [HideInInspector] _RippleNoiseScale("Ripple Noise Scale", Float) = 1

        [HideInInspector] _FresnelStrength("Fresnel Strength", Range(0.0, 5.0)) = 1
        [HideInInspector] _FresnelBias("Fresnel Bias", Range(0.0, 1.0)) = 0

        [HideInInspector] _ReflectionTex("Reflection Texture", 2D) = "black" {}
        [HideInInspector] _ReflectionDistortionStrength("Reflection Distortion Strength", Float) = 1

        [HideInInspector] _RefractionTex("Refraction Texture", 2D) = "black" {}
        [HideInInspector] _RefractionDistortionStrength("Refraction Distortion Strength", Float) = 1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+0" }

        Pass
        {
            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward" }

            Blend One Zero
            Cull Back
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _SPECULAR_SETUP
            #define SHADERPASS_FORWARD

            #pragma shader_feature_local MESH_NOISE
            #pragma shader_feature_local LIGHT_ABSORPTION
            #pragma shader_feature_local FOAM
            #pragma shader_feature_local FOAM_HQ
            #pragma shader_feature_local REFLECTION
            #pragma shader_feature_local REFRACTION
            #pragma shader_feature_local LIGHTING_BLINN_PHONG
            #pragma shader_feature_local LIGHTING_LAMBERT
            #pragma shader_feature_local FLAT_LIGHTING

            #if LIGHT_ABSORPTION || FOAM
                #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if REFRACTION
                #define REQUIRE_OPAQUE_TEXTURE
            #endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            #define POSEIDON_WATER_ADVANCED
            #undef POSEIDON_BACK_FACE
            #define POSEIDON_SRP
            #include "../CGIncludes/PUniforms.cginc"
            #include "../CGIncludes/PMeshNoise.cginc"
            #include "../CGIncludes/PRipple.cginc"
            #include "../CGIncludes/PDepth.cginc"
            #include "../CGIncludes/PLightAbsorption.cginc"
            #include "../CGIncludes/PFresnel.cginc"
            #include "../CGIncludes/PFoam.cginc"
            #include "../CGIncludes/PReflection.cginc"
            #include "../CGIncludes/PRefraction.cginc"

            #include "UniversalRP_SurfaceFunction.cginc"
            #include "UniversalRP_Forward.cginc"
            ENDHLSL
        }
    }
}
