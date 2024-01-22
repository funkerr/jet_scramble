// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distant Lands/Cozy/Stylized Clouds Desktop"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Front
		AlphaToMask Off

		Stencil
		{
			Ref 221
			Comp Always
			Pass Zero
			Fail Keep
			ZFail Keep
		}

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float4 CZY_CloudColor;
			float CZY_FilterSaturation;
			float CZY_FilterValue;
			float4 CZY_FilterColor;
			float4 CZY_CloudFilterColor;
			float4 CZY_CloudHighlightColor;
			float4 CZY_SunFilterColor;
			float CZY_WindSpeed;
			float CZY_MainCloudScale;
			float CZY_CumulusCoverageMultiplier;
			float3 CZY_SunDirection;
			half CZY_SunFlareFalloff;
			float3 CZY_MoonDirection;
			half CZY_CloudMoonFalloff;
			float4 CZY_CloudMoonColor;
			float CZY_DetailScale;
			float CZY_DetailAmount;
			float CZY_BorderHeight;
			float CZY_BorderVariation;
			float CZY_BorderEffect;
			float3 CZY_StormDirection;
			float CZY_NimbusHeight;
			float CZY_NimbusMultiplier;
			float CZY_NimbusVariation;
			sampler2D CZY_ChemtrailsTexture;
			float CZY_ChemtrailsMoveSpeed;
			float CZY_ChemtrailsMultiplier;
			sampler2D CZY_CirrusTexture;
			float CZY_CirrusMoveSpeed;
			float CZY_CirrusMultiplier;
			float CZY_ClippingThreshold;
			float4 CZY_AltoCloudColor;
			sampler2D CZY_AltocumulusTexture;
			float2 CZY_AltocumulusWindSpeed;
			float CZY_AltocumulusScale;
			float CZY_AltocumulusMultiplier;
			sampler2D CZY_CirrostratusTexture;
			float CZY_CirrostratusMoveSpeed;
			float CZY_CirrostratusMultiplier;


			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
					float2 voronoihash148( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi148( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash148( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			
					float2 voronoihash234( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi234( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash234( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			
					float2 voronoihash77( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi77( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash77( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash601( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi601( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash601( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			
					float2 voronoihash492( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi492( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash492( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 hsvTorgb2_g2 = RGBToHSV( CZY_CloudColor.rgb );
				float3 hsvTorgb3_g2 = HSVToRGB( float3(hsvTorgb2_g2.x,saturate( ( hsvTorgb2_g2.y + CZY_FilterSaturation ) ),( hsvTorgb2_g2.z + CZY_FilterValue )) );
				float4 temp_output_10_0_g2 = ( float4( hsvTorgb3_g2 , 0.0 ) * CZY_FilterColor );
				float4 CloudColor332 = ( temp_output_10_0_g2 * CZY_CloudFilterColor );
				float3 hsvTorgb2_g1 = RGBToHSV( CZY_CloudHighlightColor.rgb );
				float3 hsvTorgb3_g1 = HSVToRGB( float3(hsvTorgb2_g1.x,saturate( ( hsvTorgb2_g1.y + CZY_FilterSaturation ) ),( hsvTorgb2_g1.z + CZY_FilterValue )) );
				float4 temp_output_10_0_g1 = ( float4( hsvTorgb3_g1 , 0.0 ) * CZY_FilterColor );
				float4 CloudHighlightColor334 = ( temp_output_10_0_g1 * CZY_SunFilterColor );
				float2 texCoord94 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 Pos159 = texCoord94;
				float mulTime61 = _TimeParameters.x * ( 0.001 * CZY_WindSpeed );
				float TIme152 = mulTime61;
				float simplePerlin2D37 = snoise( ( Pos159 + ( TIme152 * float2( 0.2,-0.4 ) ) )*( 100.0 / CZY_MainCloudScale ) );
				simplePerlin2D37 = simplePerlin2D37*0.5 + 0.5;
				float SimpleCloudDensity314 = simplePerlin2D37;
				float time148 = 0.0;
				float2 voronoiSmoothId148 = 0;
				float2 temp_output_66_0 = ( Pos159 + ( TIme152 * float2( 0.3,0.2 ) ) );
				float2 coords148 = temp_output_66_0 * ( 140.0 / CZY_MainCloudScale );
				float2 id148 = 0;
				float2 uv148 = 0;
				float voroi148 = voronoi148( coords148, time148, id148, uv148, 0, voronoiSmoothId148 );
				float time234 = 0.0;
				float2 voronoiSmoothId234 = 0;
				float2 coords234 = temp_output_66_0 * ( 500.0 / CZY_MainCloudScale );
				float2 id234 = 0;
				float2 uv234 = 0;
				float voroi234 = voronoi234( coords234, time234, id234, uv234, 0, voronoiSmoothId234 );
				float2 appendResult312 = (float2(voroi148 , voroi234));
				float2 VoroDetails313 = appendResult312;
				float CumulusCoverage376 = CZY_CumulusCoverageMultiplier;
				float ComplexCloudDensity344 = (0.0 + (min( SimpleCloudDensity314 , ( 1.0 - VoroDetails313.x ) ) - ( 1.0 - CumulusCoverage376 )) * (1.0 - 0.0) / (1.0 - ( 1.0 - CumulusCoverage376 )));
				float4 lerpResult53 = lerp( CloudHighlightColor334 , CloudColor332 , saturate( (2.0 + (ComplexCloudDensity344 - 0.0) * (0.7 - 2.0) / (1.0 - 0.0)) ));
				float3 normalizeResult259 = normalize( ( WorldPosition - _WorldSpaceCameraPos ) );
				float dotResult261 = dot( normalizeResult259 , CZY_SunDirection );
				float temp_output_264_0 = abs( (dotResult261*0.5 + 0.5) );
				half LightMask267 = saturate( pow( temp_output_264_0 , CZY_SunFlareFalloff ) );
				float CloudThicknessDetails329 = ( VoroDetails313.y * saturate( ( CumulusCoverage376 - 0.8 ) ) );
				float3 normalizeResult779 = normalize( ( WorldPosition - _WorldSpaceCameraPos ) );
				float dotResult780 = dot( normalizeResult779 , CZY_MoonDirection );
				half MoonlightMask790 = saturate( pow( abs( (dotResult780*0.5 + 0.5) ) , CZY_CloudMoonFalloff ) );
				float3 hsvTorgb2_g3 = RGBToHSV( CZY_CloudMoonColor.rgb );
				float3 hsvTorgb3_g3 = HSVToRGB( float3(hsvTorgb2_g3.x,saturate( ( hsvTorgb2_g3.y + CZY_FilterSaturation ) ),( hsvTorgb2_g3.z + CZY_FilterValue )) );
				float4 temp_output_10_0_g3 = ( float4( hsvTorgb3_g3 , 0.0 ) * CZY_FilterColor );
				float4 MoonlightColor797 = ( temp_output_10_0_g3 * CZY_CloudFilterColor );
				float4 lerpResult227 = lerp( ( lerpResult53 + ( LightMask267 * CloudHighlightColor334 * ( 1.0 - CloudThicknessDetails329 ) ) + ( MoonlightMask790 * MoonlightColor797 * ( 1.0 - CloudThicknessDetails329 ) ) ) , ( CloudColor332 * float4( 0.5660378,0.5660378,0.5660378,0 ) ) , CloudThicknessDetails329);
				float time77 = 0.0;
				float2 voronoiSmoothId77 = 0;
				float2 coords77 = ( Pos159 + ( TIme152 * float2( 0.3,0.2 ) ) ) * ( 100.0 / CZY_DetailScale );
				float2 id77 = 0;
				float2 uv77 = 0;
				float fade77 = 0.5;
				float voroi77 = 0;
				float rest77 = 0;
				for( int it77 = 0; it77 <3; it77++ ){
				voroi77 += fade77 * voronoi77( coords77, time77, id77, uv77, 0,voronoiSmoothId77 );
				rest77 += fade77;
				coords77 *= 2;
				fade77 *= 0.5;
				}//Voronoi77
				voroi77 /= rest77;
				float temp_output_47_0 = ( (0.0 + (( 1.0 - voroi77 ) - 0.3) * (0.5 - 0.0) / (1.0 - 0.3)) * 0.1 * CZY_DetailAmount );
				float DetailedClouds347 = saturate( ( ComplexCloudDensity344 + temp_output_47_0 ) );
				float CloudDetail294 = temp_output_47_0;
				float2 texCoord113 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_114_0 = ( texCoord113 - float2( 0.5,0.5 ) );
				float dotResult140 = dot( temp_output_114_0 , temp_output_114_0 );
				float BorderHeight386 = ( 1.0 - CZY_BorderHeight );
				float temp_output_392_0 = ( -2.0 * ( 1.0 - CZY_BorderVariation ) );
				float clampResult420 = clamp( ( ( ( CloudDetail294 + SimpleCloudDensity314 ) * saturate( (( BorderHeight386 * temp_output_392_0 ) + (dotResult140 - 0.0) * (( temp_output_392_0 * -4.0 ) - ( BorderHeight386 * temp_output_392_0 )) / (0.5 - 0.0)) ) ) * 10.0 * CZY_BorderEffect ) , -1.0 , 1.0 );
				float BorderLightTransport418 = clampResult420;
				float3 normalizeResult745 = normalize( ( WorldPosition - _WorldSpaceCameraPos ) );
				float3 normalizeResult773 = normalize( CZY_StormDirection );
				float dotResult743 = dot( normalizeResult745 , normalizeResult773 );
				float2 texCoord721 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_726_0 = ( texCoord721 - float2( 0.5,0.5 ) );
				float dotResult728 = dot( temp_output_726_0 , temp_output_726_0 );
				float temp_output_763_0 = ( -2.0 * ( 1.0 - ( CZY_NimbusVariation * 0.9 ) ) );
				float NimbusLightTransport739 = saturate( ( ( ( CloudDetail294 + SimpleCloudDensity314 ) * saturate( (( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_763_0 ) + (( dotResult743 + ( CZY_NimbusHeight * 4.0 * dotResult728 ) ) - 0.5) * (( temp_output_763_0 * -4.0 ) - ( ( 1.0 - CZY_NimbusMultiplier ) * temp_output_763_0 )) / (7.0 - 0.5)) ) ) * 10.0 ) );
				float mulTime566 = _TimeParameters.x * 0.01;
				float simplePerlin2D563 = snoise( (Pos159*1.0 + mulTime566)*2.0 );
				float mulTime560 = _TimeParameters.x * CZY_ChemtrailsMoveSpeed;
				float cos553 = cos( ( mulTime560 * 0.01 ) );
				float sin553 = sin( ( mulTime560 * 0.01 ) );
				float2 rotator553 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos553 , -sin553 , sin553 , cos553 )) + float2( 0.5,0.5 );
				float cos561 = cos( ( mulTime560 * -0.02 ) );
				float sin561 = sin( ( mulTime560 * -0.02 ) );
				float2 rotator561 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos561 , -sin561 , sin561 , cos561 )) + float2( 0.5,0.5 );
				float mulTime568 = _TimeParameters.x * 0.01;
				float simplePerlin2D570 = snoise( (Pos159*1.0 + mulTime568)*4.0 );
				float4 ChemtrailsPattern576 = ( ( saturate( simplePerlin2D563 ) * tex2D( CZY_ChemtrailsTexture, (rotator553*0.5 + 0.0) ) ) + ( tex2D( CZY_ChemtrailsTexture, rotator561 ) * saturate( simplePerlin2D570 ) ) );
				float2 texCoord583 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_581_0 = ( texCoord583 - float2( 0.5,0.5 ) );
				float dotResult584 = dot( temp_output_581_0 , temp_output_581_0 );
				float ChemtrailsFinal590 = ( ( ChemtrailsPattern576 * saturate( (0.4 + (dotResult584 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - ( CZY_ChemtrailsMultiplier * 0.5 ) ) ? 1.0 : 0.0 );
				float mulTime673 = _TimeParameters.x * 0.01;
				float simplePerlin2D681 = snoise( (Pos159*1.0 + mulTime673)*2.0 );
				float mulTime666 = _TimeParameters.x * CZY_CirrusMoveSpeed;
				float cos677 = cos( ( mulTime666 * 0.01 ) );
				float sin677 = sin( ( mulTime666 * 0.01 ) );
				float2 rotator677 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos677 , -sin677 , sin677 , cos677 )) + float2( 0.5,0.5 );
				float cos676 = cos( ( mulTime666 * -0.02 ) );
				float sin676 = sin( ( mulTime666 * -0.02 ) );
				float2 rotator676 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos676 , -sin676 , sin676 , cos676 )) + float2( 0.5,0.5 );
				float mulTime670 = _TimeParameters.x * 0.01;
				float simplePerlin2D682 = snoise( (Pos159*1.0 + mulTime670) );
				simplePerlin2D682 = simplePerlin2D682*0.5 + 0.5;
				float4 CirrusPattern696 = ( ( saturate( simplePerlin2D681 ) * tex2D( CZY_CirrusTexture, (rotator677*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrusTexture, (rotator676*1.0 + 0.0) ) * saturate( simplePerlin2D682 ) ) );
				float2 texCoord685 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_690_0 = ( texCoord685 - float2( 0.5,0.5 ) );
				float dotResult694 = dot( temp_output_690_0 , temp_output_690_0 );
				float4 temp_output_701_0 = ( CirrusPattern696 * saturate( (0.0 + (dotResult694 - 0.0) * (2.0 - 0.0) / (0.2 - 0.0)) ) );
				float Clipping515 = CZY_ClippingThreshold;
				float CirrusAlpha715 = ( ( temp_output_701_0 * ( CZY_CirrusMultiplier * 10.0 ) ).r > Clipping515 ? 1.0 : 0.0 );
				float SimpleRadiance506 = saturate( ( DetailedClouds347 + BorderLightTransport418 + NimbusLightTransport739 + ChemtrailsFinal590 + CirrusAlpha715 ) );
				float4 lerpResult171 = lerp( CloudColor332 , lerpResult227 , ( 1.0 - SimpleRadiance506 ));
				float CloudLight271 = saturate( pow( temp_output_264_0 , CZY_SunFlareFalloff ) );
				float4 lerpResult272 = lerp( float4( 0,0,0,0 ) , CloudHighlightColor334 , ( saturate( ( CumulusCoverage376 - 1.0 ) ) * CloudDetail294 * CloudLight271 ));
				float4 SunThroughClouds273 = ( lerpResult272 * 1.3 );
				float3 hsvTorgb2_g4 = RGBToHSV( CZY_AltoCloudColor.rgb );
				float3 hsvTorgb3_g4 = HSVToRGB( float3(hsvTorgb2_g4.x,saturate( ( hsvTorgb2_g4.y + CZY_FilterSaturation ) ),( hsvTorgb2_g4.z + CZY_FilterValue )) );
				float4 temp_output_10_0_g4 = ( float4( hsvTorgb3_g4 , 0.0 ) * CZY_FilterColor );
				float4 CirrusCustomLightColor512 = ( CloudColor332 * ( temp_output_10_0_g4 * CZY_CloudFilterColor ) );
				float time601 = 0.0;
				float2 voronoiSmoothId601 = 0;
				float mulTime602 = _TimeParameters.x * 0.003;
				float2 coords601 = (Pos159*1.0 + ( float2( 1,-2 ) * mulTime602 )) * 10.0;
				float2 id601 = 0;
				float2 uv601 = 0;
				float voroi601 = voronoi601( coords601, time601, id601, uv601, 0, voronoiSmoothId601 );
				float time492 = ( 10.0 * mulTime602 );
				float2 voronoiSmoothId492 = 0;
				float2 coords492 = IN.ase_texcoord3.xy * 10.0;
				float2 id492 = 0;
				float2 uv492 = 0;
				float voroi492 = voronoi492( coords492, time492, id492, uv492, 0, voronoiSmoothId492 );
				float AltoCumulusPlacement461 = saturate( ( ( ( 1.0 - 0.0 ) - (1.0 + (voroi601 - 0.0) * (-0.5 - 1.0) / (1.0 - 0.0)) ) - voroi492 ) );
				float temp_output_490_0 = ( AltoCumulusPlacement461 * (0.0 + (tex2D( CZY_AltocumulusTexture, ((Pos159*1.0 + ( CZY_AltocumulusWindSpeed * TIme152 ))*( 1.0 / CZY_AltocumulusScale ) + 0.0) ).r - 0.0) * (1.0 - 0.0) / (0.2 - 0.0)) * CZY_AltocumulusMultiplier );
				float AltoCumulusLightTransport447 = temp_output_490_0;
				float ACCustomLightsClipping521 = ( AltoCumulusLightTransport447 * ( SimpleRadiance506 > Clipping515 ? 0.0 : 1.0 ) );
				float mulTime611 = _TimeParameters.x * 0.01;
				float simplePerlin2D620 = snoise( (Pos159*1.0 + mulTime611)*2.0 );
				float mulTime607 = _TimeParameters.x * CZY_CirrostratusMoveSpeed;
				float cos615 = cos( ( mulTime607 * 0.01 ) );
				float sin615 = sin( ( mulTime607 * 0.01 ) );
				float2 rotator615 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos615 , -sin615 , sin615 , cos615 )) + float2( 0.5,0.5 );
				float cos621 = cos( ( mulTime607 * -0.02 ) );
				float sin621 = sin( ( mulTime607 * -0.02 ) );
				float2 rotator621 = mul( Pos159 - float2( 0.5,0.5 ) , float2x2( cos621 , -sin621 , sin621 , cos621 )) + float2( 0.5,0.5 );
				float mulTime612 = _TimeParameters.x * 0.01;
				float simplePerlin2D618 = snoise( (Pos159*10.0 + mulTime612)*4.0 );
				float4 CirrostratPattern634 = ( ( saturate( simplePerlin2D620 ) * tex2D( CZY_CirrostratusTexture, (rotator615*1.5 + 0.75) ) ) + ( tex2D( CZY_CirrostratusTexture, (rotator621*1.5 + 0.75) ) * saturate( simplePerlin2D618 ) ) );
				float2 texCoord625 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_629_0 = ( texCoord625 - float2( 0.5,0.5 ) );
				float dotResult630 = dot( temp_output_629_0 , temp_output_629_0 );
				float clampResult798 = clamp( ( CZY_CirrostratusMultiplier * 0.5 ) , 0.0 , 0.98 );
				float CirrostratLightTransport641 = ( ( CirrostratPattern634 * saturate( (0.4 + (dotResult630 - 0.0) * (2.0 - 0.4) / (0.1 - 0.0)) ) ).r > ( 1.0 - clampResult798 ) ? 1.0 : 0.0 );
				float CSCustomLightsClipping648 = ( CirrostratLightTransport641 * ( SimpleRadiance506 > Clipping515 ? 0.0 : 1.0 ) );
				float CustomRadiance657 = saturate( ( ACCustomLightsClipping521 + CSCustomLightsClipping648 ) );
				float4 lerpResult522 = lerp( ( lerpResult171 + SunThroughClouds273 ) , CirrusCustomLightColor512 , CustomRadiance657);
				float FinalAlpha408 = saturate( ( DetailedClouds347 + BorderLightTransport418 + AltoCumulusLightTransport447 + ChemtrailsFinal590 + CirrostratLightTransport641 + CirrusAlpha715 + NimbusLightTransport739 ) );
				clip( FinalAlpha408 - Clipping515);
				float4 FinalCloudColor351 = lerpResult522;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = FinalCloudColor351.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			float4 _SelectionID;


			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_SRP_VERSION 120108


			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
						#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "EmptyShaderGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;597;3513.774,-2825.563;Inherit;False;2340.552;1688.827;;2;596;595;Chemtrails Block;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;423;-250.2423,-1430.506;Inherit;False;2974.933;2000.862;;5;371;396;397;395;373;Cumulus Cloud Block;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;603;3180.966,811.0074;Inherit;False;2654.838;1705.478;;3;651;605;604;Cirrostratus Block;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;774;-479.6465,-4338.578;Inherit;False;3038.917;2502.995;;4;407;652;500;369;Finalization Block;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;663;6128.124,-2822.822;Inherit;False;2297.557;1709.783;;2;678;664;Cirrus Block;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;528;-228.5223,860.652;Inherit;False;3128.028;1619.676;;3;527;496;462;Altocumulus Cloud Block;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;372;-4255.697,-4622.015;Inherit;False;2254.259;1199.93;;45;790;789;786;784;783;781;780;779;778;777;776;775;267;266;271;270;265;269;263;264;268;262;261;259;260;258;257;256;332;334;52;36;376;375;159;94;152;61;150;70;796;797;815;814;813;Variable Declaration;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;605;3238.901,1879.241;Inherit;False;1600.229;583.7008;Final;13;641;639;638;637;636;633;632;630;629;625;642;658;798;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;462;-162.0468,961.969;Inherit;False;2021.115;830.0204;Placement Noise;18;452;433;435;429;438;455;461;457;458;442;451;454;491;492;494;600;601;602;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;718;5760,-768;Inherit;False;2713.637;1035.553;;30;769;760;739;750;737;735;733;734;731;730;758;765;766;743;763;761;745;744;746;762;748;747;768;759;728;721;726;770;771;773;Nimbus Block;0.5,0.5,0.5,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;373;-203.3957,-786.2642;Inherit;False;1226.633;651.0015;Simple Density;20;149;314;37;42;313;63;312;60;157;148;62;234;65;66;235;68;161;41;67;156;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;595;3555.786,-2771.983;Inherit;False;2197.287;953.2202;Pattern;24;576;573;587;588;593;551;556;592;563;561;555;570;553;562;569;565;567;554;559;568;564;566;560;571;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;527;1904.552,952.911;Inherit;False;939.7803;621.1177;Lighting & Clipping;11;512;510;511;524;521;516;509;519;518;520;816;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;395;-191.1863,19.66455;Inherit;False;1813.036;453.4427;Final Detailing;17;44;49;51;346;92;48;294;47;91;46;155;162;347;77;93;78;43;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;371;1099.14,-1213.321;Inherit;False;1576.124;399.0991;Highlights;11;383;273;283;272;284;274;335;295;282;277;279;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;369;-414.8885,-2846.547;Inherit;False;2881.345;950.1069;Final Coloring;35;795;794;793;792;791;205;214;340;236;330;351;56;350;522;280;513;523;281;171;336;349;227;331;225;216;415;53;339;55;337;338;54;345;515;151;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;500;-403.2868,-3511.748;Inherit;False;1393.195;555.0131;Simple Radiance;8;501;502;504;505;506;599;712;741;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;496;-150.0306,1829.663;Inherit;False;2120.291;565.6142;Main Noise;15;473;447;495;490;484;499;817;479;480;476;477;818;478;474;475;;0.6637449,0.4708971,0.6981132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;396;-213.2237,-1240.208;Inherit;False;1283.597;293.2691;Thickness Details;7;223;329;222;379;316;315;224;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;422;3408,-752;Inherit;False;2111.501;762.0129;;21;418;420;417;406;399;401;421;398;402;128;389;393;140;392;114;386;113;394;390;387;391;Cloud Border Block;1,0.5882353,0.685091,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;397;1082.985,-632.3273;Inherit;False;1154;500;Complex Density;9;50;344;326;328;69;327;321;381;58;;0.4392157,1,0.7085855,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;652;1051.16,-3520.311;Inherit;False;1393.195;555.0131;Custom Radiance;5;654;655;656;657;653;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;604;3222.978,864.5875;Inherit;False;2197.287;953.2202;Pattern;25;634;631;628;627;626;624;623;622;621;620;619;618;617;616;615;614;613;612;611;610;609;608;607;606;643;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;596;3571.709,-1757.329;Inherit;False;1600.229;583.7008;Final;12;590;574;580;578;577;586;591;594;583;581;582;584;;1,0.9935331,0.4575472,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;664;6170.135,-2769.242;Inherit;False;2197.287;953.2202;Pattern;25;696;693;691;688;687;686;684;683;682;681;680;679;677;676;675;674;673;672;671;670;669;668;667;666;665;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;651;4864.461,1878.709;Inherit;False;916.8853;383.8425;Lighting & Clipping;6;648;650;649;647;646;645;;0.4588236,0.584294,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;678;6186.058,-1754.588;Inherit;False;1735.998;586.5895;Final;14;715;714;695;689;706;701;698;700;697;694;690;685;716;717;;1,0.6554637,0.4588236,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;407;-422.4442,-4222.23;Inherit;False;951.3906;629.7021;Final Alpha;10;713;644;408;411;410;598;497;414;409;740;;0.6196079,0.9508546,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;61;-3039.942,-4244.458;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-2871.501,-4248.563;Inherit;False;TIme;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;94;-3079.566,-4417.043;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-3172.891,-4247.994;Inherit;False;2;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-2876.129,-4422.287;Inherit;False;Pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;376;-2284.34,-4479.701;Inherit;False;CumulusCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;256;-4188.176,-4013.731;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;257;-4118.765,-4162.82;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;777;-3938.89,-3775.418;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;776;-4118.636,-3837.629;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;258;-3939.019,-4100.609;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;259;-3811.901,-4101.856;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;332;-3599.176,-4511.369;Inherit;False;CloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;261;-3667.157,-4091.93;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;779;-3811.772,-3776.665;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;269;-3152.916,-3962.071;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;775;-4188.047,-3688.54;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;780;-3667.028,-3766.739;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;262;-3527.523,-4095.134;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;781;-3527.394,-3769.943;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;264;-3304.19,-4092.997;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;783;-3304.061,-3767.806;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;266;-3023.711,-4097.528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;271;-2849.713,-3962.671;Inherit;False;CloudLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;786;-3169.658,-3770.558;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;270;-2991.713,-3956.771;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;-3601.647,-4327.585;Inherit;False;CloudHighlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;267;-2875.538,-4104.635;Half;False;LightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;-2875.409,-3779.444;Half;False;MoonlightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;789;-3023.582,-3772.337;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;265;-3169.787,-4095.749;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;797;-2912,-4528;Inherit;False;MoonlightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;813;-3841.155,-4333.999;Inherit;False;Filter Color;-1;;1;84bcc1baa84e09b4fba5ba52924b2334;2,13,1,14,0;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;814;-3888,-4512;Inherit;False;Filter Color;-1;;2;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;815;-3120,-4528;Inherit;False;Filter Color;-1;;3;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;36;-4144,-4512;Inherit;False;Global;CZY_CloudColor;CZY_CloudColor;0;3;[HideInInspector];[HDR];[Header];Create;True;1;General Cloud Settings;0;0;False;0;False;0.7264151,0.7264151,0.7264151,0;0.9776345,0.9776345,0.9776345,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;52;-4144,-4336;Inherit;False;Global;CZY_CloudHighlightColor;CZY_CloudHighlightColor;1;2;[HideInInspector];[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;4.919352,4.204114,3.550287,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;70;-3392,-4224;Inherit;False;Global;CZY_WindSpeed;CZY_WindSpeed;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;4.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-3408,-3968;Half;False;Global;CZY_SunFlareFalloff;CZY_SunFlareFalloff;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-2588.193,-4479.109;Inherit;False;Global;CZY_CumulusCoverageMultiplier;CZY_CumulusCoverageMultiplier;5;2;[HideInInspector];[Header];Create;False;1;Cumulus Clouds;0;0;False;0;False;1;0.16;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;260;-3865.421,-3964.893;Inherit;False;Global;CZY_SunDirection;CZY_SunDirection;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.5211577,0.7329126,0.4373034;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;67;-160.9557,-410.9344;Inherit;False;Constant;_CloudWind2;Cloud Wind 2;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.3,0.2;0.1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;156;-158.4826,-479.7553;Inherit;False;152;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;293.5053,-376.8996;Inherit;False;2;0;FLOAT;140;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;50.75578,-713.4048;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;87.06122,-412.8354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;666;6438.377,-2267.659;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;58.07913,229.1355;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-159.114,196.3215;Inherit;False;152;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;668;6727.173,-2399.059;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;113;3552,-480;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;673;6789.709,-2538.93;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;148;480.1892,-443.5733;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;157;-157.0807,-680.7291;Inherit;False;152;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;19.69116,116.4622;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;77;353.8299,169.9679;Inherit;True;0;0;1;0;3;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;235;293.0141,-270.2905;Inherit;False;2;0;FLOAT;500;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;672;6766.873,-2026.124;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;218.4492,268.0113;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;234;478.0144,-307.2905;Inherit;False;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;671;6787.709,-2618.931;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;220.5464,171.2449;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;667;6686.708,-2214.932;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;6670.173,-2304.059;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;560;3824.028,-2270.4;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;286.643,-496.0274;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;312;667.2,-359.5185;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;87.51923,-534.9066;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;553;4292.823,-2396.799;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;721;5969.644,-260.1304;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;283.9169,-707.6729;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;675;7016.874,-2007.124;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;677;6907.173,-2394.059;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;747;5861.095,-678.9246;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;42;282.7172,-600.2411;Inherit;False;2;0;FLOAT;100;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;566;4175.361,-2541.671;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;554;4112.825,-2401.799;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;564;4173.361,-2621.671;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;568;4154.524,-1948.865;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;4055.824,-2306.799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;808.2874,-365.6784;Inherit;False;VoroDetails;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;674;7037.709,-2599.93;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;748;5802.087,-531.1355;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;676;6909.71,-2237.932;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;680;7106.417,-2230.332;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;326;1098.988,-476.1505;Inherit;False;313;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;569;4402.524,-2009.865;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;745;6217.36,-604.9607;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;686;7304.139,-2228.64;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;684;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;683;7448.496,-1998.098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;4152.524,-2028.865;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;717;7294.466,-1417.338;Inherit;False;515;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;768;6679.782,116.2336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;682;7241.874,-2002.124;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;538.305,169.8402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;726;6193.644,-276.1304;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;728;6385.644,-260.1304;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;681;7262.709,-2594.93;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;555;4496.824,-2397.799;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;746;6079.842,-607.6136;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;762;6810.42,108.4931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;51;695.7791,170.1474;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;561;4394.36,-2237.672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;394;3760,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;643;4159.26,1403.498;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;685;6238.183,-1544.158;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;670;6768.874,-1946.124;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;390;3760,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;696;8069.139,-2343.64;Inherit;False;CirrusPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;615;3960.015,1239.771;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;583;3646.834,-1544.899;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;763;6965.42,83.49312;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;344;1993.289,-535.4535;Inherit;False;ComplexCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;770;6648.459,-360.0035;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;4;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;563;4648.36,-2597.671;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;687;7445.01,-2584.845;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;327;1266.989,-472.1505;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;773;6261.161,-476.4007;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;570;4627.524,-2004.865;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;556;4689.789,-2231.38;Inherit;True;Property;_ChemtrailsTex2;Chemtrails Tex 2;2;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;551;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;328;1382.99,-475.1505;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;743;6442.698,-600.2336;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;3936,-160;Inherit;False;2;2;0;FLOAT;-2;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;761;6903.42,-10.50688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;699.5449,-698.9639;Inherit;False;SimpleCloudDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;3920,-240;Inherit;False;BorderHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;592;4834.146,-2000.839;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;588;5057.789,-2231.38;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;694;6600.185,-1548.158;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;688;7672.139,-2228.64;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;593;4830.659,-2587.586;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;691;7672.139,-2452.64;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;3776,-480;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;581;3878.834,-1543.899;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;602;-39.72644,1648.263;Inherit;False;1;0;FLOAT;0.003;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;690;6444.183,-1545.158;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;765;7122.42,-12.50689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;458;157.3604,1538.603;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;393;4128,-160;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;587;5057.789,-2455.38;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;1297.474,-558.5957;Inherit;False;314;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;766;7122.42,83.49312;Inherit;False;2;2;0;FLOAT;-4;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;128;4320,-400;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;-2;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;610;3819.715,1607.705;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;882.0814,183.5532;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;771;6816.106,-441.474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;1637.088,-299.8031;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;173.7564,1387.099;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;4128,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;607;3491.22,1366.17;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;1046.829,82.25906;Inherit;False;CloudDetail;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;698;6921.737,-1650.425;Inherit;False;696;CirrusPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;700;6992.107,-1542.236;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;695;7157.684,-1493.445;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;609;3840.552,1014.899;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;612;3821.716,1687.705;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;613;3780.016,1234.771;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;758;7315.526,-79.20961;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;697;6738.487,-1547.458;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;3723.016,1329.771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;402;4336,-496;Inherit;False;314;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;454;335.4072,1438.633;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;50;1817.57,-531.1767;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;617;3739.55,1418.898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;611;3842.552,1094.899;Inherit;False;1;0;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;731;7342.492,-194.6436;Inherit;False;314;SimpleCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;582;4194.137,-1546.199;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;616;4069.716,1626.705;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;401;4560,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;621;3962.552,1395.898;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;734;7590.39,-79.34389;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;601;515.2736,1436.263;Inherit;True;0;0;1;3;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GetLocalVarNode;730;7390.492,-283.6436;Inherit;False;294;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;693;7848.139,-2340.64;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;5233.789,-2343.38;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;398;4384,-576;Inherit;False;294;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;614;4090.552,1033.899;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;4720,-432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;584;4054.835,-1544.899;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;515;1719.722,-2199.649;Inherit;False;Clipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;733;7580.492,-237.6435;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;576;5454.789,-2346.38;Inherit;False;ChemtrailsPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;421;4592,-400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;140;3968,-480;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;591;4307.387,-1653.166;Inherit;False;576;ChemtrailsPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;594;4377.758,-1544.977;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;600;740.4915,1401.016;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;618;4294.716,1631.705;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;701;7157.289,-1608.256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;776.4108,82.35074;Inherit;False;344;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;619;4156.017,1234.771;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;735;7732.492,-141.6436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;451;872.4244,1165.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;494;809.8984,1624.261;Inherit;False;2;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;679;7103.175,-2399.059;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;2;FLOAT;0.75;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;620;4315.552,1038.899;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;149;665.326,-444.6863;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;750;8024.268,-128.1811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;438;657.3745,1155.66;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;714;7317.954,-1523.05;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;452;1018.591,1168.67;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;737;7875.492,-139.6436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;626;4501.338,1635.731;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;492;1069.963,1399.258;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;12.27;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.OneMinusNode;580;4532.836,-1348.799;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;625;3314.026,2091.671;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;48;1041.384,162.4458;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;624;4497.852,1048.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;622;4356.981,1405.19;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Instance;623;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;630;3722.027,2091.671;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;316;512.2098,-1191.688;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;350;1731.07,-2356.739;Inherit;False;408;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;628;4724.981,1405.19;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;491;1172.962,1166.258;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;629;3546.026,2092.671;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;49;1255.108,160.9476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;716;7496.466,-1523.338;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;627;4724.981,1181.19;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;420;5072,-400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;590;4933.604,-1517.458;Inherit;False;ChemtrailsFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;642;4425.152,2119.222;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5754717;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;715;7675.589,-1523.182;Inherit;False;CirrusAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;442;1330.143,1165.87;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;347;1406.535,150.6825;Inherit;False;DetailedClouds;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;631;4900.981,1293.19;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;222;338.5966,-1080.611;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;638;4240,2288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;633;3861.329,2090.371;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0.4;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;712;-79.14536,-3110.654;Inherit;False;715;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;637;3974.579,1983.404;Inherit;False;634;CirrostratPattern;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;636;4044.949,2091.593;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;502;-124.6149,-3338.545;Inherit;False;418;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;634;5121.981,1290.19;Inherit;False;CirrostratPattern;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;741;-129.5553,-3264.852;Inherit;False;739;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;504;155.9575,-3319.181;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;798;4096,2288;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;3936,2288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;501;-92.01058,-3421.37;Inherit;False;347;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;599;-97.9974,-3188.554;Inherit;False;590;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;506;445.0833,-3320.804;Inherit;False;SimpleRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;739;8191.493,-129.6436;Inherit;True;NimbusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;505;302.9577,-3317.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;287.7378,-1198.101;Inherit;False;313;VoroDetails;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;706;7444.954,-1634.717;Inherit;False;CirrusLightTransport;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;565;4423.36,-2602.671;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;639;4210.131,2025.573;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;223;503.6977,-1079.311;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;574;4764.736,-1519.199;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;497;-380.3787,-4004.726;Inherit;False;447;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;418;5296,-428;Inherit;False;BorderLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;415;595.0764,-2173.415;Inherit;False;506;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;279;1491.307,-1081.408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;641;4589.796,2119.112;Inherit;False;CirrostratLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;649;4928.082,2154.064;Inherit;False;515;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;654.6831,-1165.677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;645;4913.45,2071.161;Inherit;False;506;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;520;1986.173,1474.267;Inherit;False;515;Clipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;791.4005,-1176.404;Inherit;False;CloudThicknessDetails;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;417;4928,-416;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;519;2195.976,1392.761;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;791;-93.353,-2010.958;Inherit;False;329;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;509;2072.735,1300.613;Inherit;False;447;AltoCumulusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-331.1171,-2578.821;Inherit;False;344;ComplexCloudDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;1828.58,-1135.693;Inherit;False;334;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;646;5137.885,2072.559;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;578;4388.836,-1348.799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;586;4542.938,-1610.997;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;650;5014.644,1980.411;Inherit;False;641;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;4072.359,-2217.672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;295;1604.073,-993.6925;Inherit;False;294;CloudDetail;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;330;-108.4593,-2286.136;Inherit;False;329;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;54;-93.45968,-2574.136;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;50.5418,-2670.136;Inherit;False;332;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;99.5421,-2478.136;Inherit;False;267;LightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;51.5418,-2382.136;Inherit;False;334;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;55;98.54169,-2574.136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;2274.191,-1078.471;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;349;855.6476,-2326.646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-26.53247,-4013.235;Inherit;False;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;277;1640.36,-1082.697;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;648;5484.254,1998.892;Inherit;False;CSCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;793;66.6481,-2106.958;Inherit;False;797;MoonlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;284;2070.191,-965.471;Inherit;False;Constant;_2;2;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;294.542,-2402.136;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;654;1283.608,-3214.672;Inherit;False;648;CSCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;653;1283.745,-3305.013;Inherit;False;521;ACCustomLightsClipping;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;53;274.542,-2654.136;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;272;2069.881,-1094.994;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;339;472.0735,-2356.739;Inherit;False;332;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;795;309.6483,-2126.958;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;56;1955.07,-2452.739;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;713;-295.3558,-3758.184;Inherit;False;715;CirrusAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;-360.3445,-3835.637;Inherit;False;641;CirrostratLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;655;1578.962,-3265.042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;652.0735,-2372.739;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5660378,0.5660378,0.5660378,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;647;5324.791,2006.867;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;351;2178.019,-2458.207;Inherit;False;FinalCloudColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;794;90.64841,-2195.958;Inherit;False;790;MoonlightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;740;-351.8044,-3684.929;Inherit;False;739;NimbusLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;216;473.1443,-2493.871;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;554.0735,-2266.739;Inherit;False;329;CloudThicknessDetails;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;598;-315.3723,-3920.486;Inherit;False;590;ChemtrailsFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;522;1563.299,-2429.213;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;523;1307.463,-2231.542;Inherit;False;657;CustomRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;337;2.541811,-2750.136;Inherit;False;334;CloudHighlightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;792;146.648,-2010.958;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;1271.647,-2422.646;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;1830.143,-1051.032;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;336;823.6486,-2582.646;Inherit;False;332;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;227;800.0724,-2485.739;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;1031.646,-2326.646;Inherit;False;273;SunThroughClouds;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;657;1874.599,-3274.224;Inherit;False;CustomRadiance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;411;116.4676,-4001.235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;171;1031.646,-2454.646;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;1272.852,-2307.405;Inherit;False;512;CirrusCustomLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;656;1713.599,-3268.224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;414;-349.1048,-4092.599;Inherit;False;418;BorderLightTransport;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;236;131.5417,-2286.136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;-322.5005,-4171.425;Inherit;False;347;DetailedClouds;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;510;2432,1072;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.7159576,0.8624095,0.8773585,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;511;2240,1008;Inherit;False;332;CloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;512;2592,1072;Inherit;False;CirrusCustomLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;816;2160,1120;Inherit;False;Filter Color;-1;;4;84bcc1baa84e09b4fba5ba52924b2334;2,13,0,14,1;1;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;62;-154.5866,-604.686;Inherit;False;Constant;_CloudWind1;Cloud Wind 1;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.2,-0.4;0.6,-0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;43;36.27663,333.869;Inherit;False;Global;CZY_DetailScale;CZY_DetailScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;1.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;698.9319,344.7032;Inherit;False;Global;CZY_DetailAmount;CZY_DetailAmount;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;91;-154.8089,298.2306;Inherit;False;Constant;_DetailWind;Detail Wind;17;0;Create;True;0;0;0;False;0;False;0.3,0.2;0.3,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;391;3488,-128;Inherit;False;Global;CZY_BorderVariation;CZY_BorderVariation;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.95;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;3488,-240;Inherit;False;Global;CZY_BorderHeight;CZY_BorderHeight;4;2;[HideInInspector];[Header];Create;False;1;Border Clouds;0;0;False;0;False;1;0.553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;35.16191,-625.1489;Inherit;False;Global;CZY_MainCloudScale;CZY_MainCloudScale;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;10;12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;406;4608,-288;Inherit;False;Global;CZY_BorderEffect;CZY_BorderEffect;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;744;6069.037,-466.4966;Inherit;False;Global;CZY_StormDirection;CZY_StormDirection;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0;-0.9075221,0,-0.4200044;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;759;6409.42,110.4931;Inherit;False;Global;CZY_NimbusVariation;CZY_NimbusVariation;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0.945;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;689;6792.185,-1317.058;Inherit;False;Global;CZY_CirrusMultiplier;CZY_CirrusMultiplier;11;2;[HideInInspector];[Header];Create;False;1;Cirrus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;577;4100.836,-1348.799;Inherit;False;Global;CZY_ChemtrailsMultiplier;CZY_ChemtrailsMultiplier;14;1;[HideInInspector];Create;False;1;Chemtrails;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;665;6202.655,-2272.49;Inherit;False;Global;CZY_CirrusMoveSpeed;CZY_CirrusMoveSpeed;12;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.297;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;1419.588,-2095.822;Inherit;False;Global;CZY_ClippingThreshold;CZY_ClippingThreshold;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;571;3588.306,-2275.23;Inherit;False;Global;CZY_ChemtrailsMoveSpeed;CZY_ChemtrailsMoveSpeed;15;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.289;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;524;1936,1120;Inherit;False;Global;CZY_AltoCloudColor;CZY_AltoCloudColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;1.083397,1.392001,1.382235,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;457;-36.07951,1389.731;Inherit;False;Constant;_ACMoveSpeed;ACMoveSpeed;14;0;Create;True;0;0;0;False;0;False;1,-2;5,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;632;3664,2288;Inherit;False;Global;CZY_CirrostratusMultiplier;CZY_CirrostratusMultiplier;4;2;[HideInInspector];[Header];Create;False;1;Cirrostratus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;606;3255.498,1361.34;Inherit;False;Global;CZY_CirrostratusMoveSpeed;CZY_CirrostratusMoveSpeed;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;0;0.281;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;112,-1088;Inherit;False;376;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;1248,-1088;Inherit;False;376;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;1408,-304;Inherit;False;376;CumulusCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;69;1582.449,-520.7233;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;293.5934,-4008.04;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;803;-678.2959,-671.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;802;-678.2959,-671.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;801;-678.2959,-671.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;804;-677.2959,-599.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;805;-677.2959,-599.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;806;-677.2959,-599.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;807;-677.2959,-599.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;808;-677.2959,-599.1561;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;461;1507.859,1165.986;Inherit;False;AltoCumulusPlacement;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;475;112,1888;Inherit;False;159;Pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;474;288,1904;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;478;-128,1968;Inherit;False;Global;CZY_AltocumulusWindSpeed;CZY_AltocumulusWindSpeed;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1,-2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;818;480,1936;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;477;144,2016;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;476;-48,2096;Inherit;False;152;TIme;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;480;192,2128;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;479;-64,2240;Inherit;False;Global;CZY_AltocumulusScale;CZY_AltocumulusScale;2;1;[HideInInspector];Create;False;0;0;0;False;0;False;3;0.371;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;516;2382.882,1327.069;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;518;1973.541,1390.363;Inherit;False;506;SimpleRadiance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;521;2540.446,1325.394;Inherit;True;ACCustomLightsClipping;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;817;688,1920;Inherit;True;Global;CZY_AltocumulusTexture;CZY_AltocumulusTexture;3;0;Create;False;0;0;0;False;0;False;-1;b03bb03c5876b954ba45feffa4aaad63;b03bb03c5876b954ba45feffa4aaad63;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;499;992,2224;Inherit;False;Global;CZY_AltocumulusMultiplier;CZY_AltocumulusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Altocumulus Clouds;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;484;992,1920;Inherit;False;461;AltoCumulusPlacement;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;490;1232,1936;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;495;1392,1936;Inherit;True;2;4;0;FLOAT;0.1;False;1;FLOAT;0.2;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;1664,1936;Inherit;False;AltoCumulusLightTransport;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;473;1040,2000;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;623;4356.981,1197.19;Inherit;True;Global;CZY_CirrostratusTexture;CZY_CirrostratusTexture;0;0;Create;False;0;0;0;False;0;False;-1;None;bf43c8d7b74e204469465f36dfff7d6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;551;4689.789,-2439.38;Inherit;True;Global;CZY_ChemtrailsTexture;CZY_ChemtrailsTexture;2;0;Create;False;0;0;0;False;0;False;-1;None;9b3476b4df9abf8479476bae1bcd8a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;684;7304.139,-2436.64;Inherit;True;Global;CZY_CirrusTexture;CZY_CirrusTexture;1;0;Create;False;0;0;0;False;0;False;-1;None;302629ebb64a0e345948779662fc2cf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;769;6375.541,-363.9453;Inherit;False;Global;CZY_NimbusHeight;CZY_NimbusHeight;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;273;2435.788,-1085.51;Inherit;False;SunThroughClouds;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;282;1609.722,-915.0801;Inherit;False;271;CloudLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-3408,-3888;Half;False;Global;CZY_CloudFlareFalloff;CZY_CloudFlareFalloff;5;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;796;-3354.791,-4527.796;Inherit;False;Global;CZY_CloudMoonColor;CZY_CloudMoonColor;0;2;[HideInInspector];[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;760;6540.42,-3.20688;Inherit;False;Global;CZY_NimbusMultiplier;CZY_NimbusMultiplier;1;2;[HideInInspector];[Header];Create;False;1;Nimbus Clouds;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;778;-3888.292,-3647.702;Inherit;False;Global;CZY_MoonDirection;CZY_MoonDirection;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0.1246749,0.9482574,0.2919996;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;784;-3424,-3648;Half;False;Global;CZY_CloudMoonFalloff;CZY_CloudMoonFalloff;3;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;11.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;429;-78.02525,1079.905;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;435;339.8155,1083.927;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;433;141.4556,1073.34;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;37;466.9412,-696.6409;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;799;-3024,-880;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;352;-3552,-672;Inherit;False;351;FinalCloudColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;800;-3296,-672;Float;False;True;-1;2;EmptyShaderGUI;0;13;Distant Lands/Cozy/Stylized Clouds Desktop;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;1;False;;False;False;False;False;False;False;False;False;True;True;True;221;False;;255;False;;255;False;;7;False;;2;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;3;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;23;Surface;1;638295390293297003;  Blend;0;0;Two Sided;2;638295390676621873;Forward Only;1;638295390392913430;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;False;True;True;True;True;False;;False;0
WireConnection;61;0;150;0
WireConnection;152;0;61;0
WireConnection;150;1;70;0
WireConnection;159;0;94;0
WireConnection;376;0;375;0
WireConnection;777;0;776;0
WireConnection;777;1;775;0
WireConnection;258;0;257;0
WireConnection;258;1;256;0
WireConnection;259;0;258;0
WireConnection;332;0;814;0
WireConnection;261;0;259;0
WireConnection;261;1;260;0
WireConnection;779;0;777;0
WireConnection;269;0;264;0
WireConnection;269;1;263;0
WireConnection;780;0;779;0
WireConnection;780;1;778;0
WireConnection;262;0;261;0
WireConnection;781;0;780;0
WireConnection;264;0;262;0
WireConnection;783;0;781;0
WireConnection;266;0;265;0
WireConnection;271;0;270;0
WireConnection;786;0;783;0
WireConnection;786;1;784;0
WireConnection;270;0;269;0
WireConnection;334;0;813;0
WireConnection;267;0;266;0
WireConnection;790;0;789;0
WireConnection;789;0;786;0
WireConnection;265;0;264;0
WireConnection;265;1;263;0
WireConnection;797;0;815;0
WireConnection;813;1;52;0
WireConnection;814;1;36;0
WireConnection;815;1;796;0
WireConnection;65;1;41;0
WireConnection;68;0;156;0
WireConnection;68;1;67;0
WireConnection;666;0;665;0
WireConnection;92;0;155;0
WireConnection;92;1;91;0
WireConnection;148;0;66;0
WireConnection;148;2;65;0
WireConnection;77;0;93;0
WireConnection;77;2;44;0
WireConnection;235;1;41;0
WireConnection;44;1;43;0
WireConnection;234;0;66;0
WireConnection;234;2;235;0
WireConnection;93;0;162;0
WireConnection;93;1;92;0
WireConnection;667;0;666;0
WireConnection;669;0;666;0
WireConnection;560;0;571;0
WireConnection;66;0;161;0
WireConnection;66;1;68;0
WireConnection;312;0;148;0
WireConnection;312;1;234;0
WireConnection;60;0;157;0
WireConnection;60;1;62;0
WireConnection;553;0;554;0
WireConnection;553;2;559;0
WireConnection;63;0;161;0
WireConnection;63;1;60;0
WireConnection;675;0;672;0
WireConnection;675;2;670;0
WireConnection;677;0;668;0
WireConnection;677;2;669;0
WireConnection;42;1;41;0
WireConnection;559;0;560;0
WireConnection;313;0;312;0
WireConnection;674;0;671;0
WireConnection;674;2;673;0
WireConnection;676;0;668;0
WireConnection;676;2;667;0
WireConnection;680;0;676;0
WireConnection;569;0;567;0
WireConnection;569;2;568;0
WireConnection;745;0;746;0
WireConnection;686;1;680;0
WireConnection;683;0;682;0
WireConnection;768;0;759;0
WireConnection;682;0;675;0
WireConnection;78;0;77;0
WireConnection;726;0;721;0
WireConnection;728;0;726;0
WireConnection;728;1;726;0
WireConnection;681;0;674;0
WireConnection;555;0;553;0
WireConnection;746;0;747;0
WireConnection;746;1;748;0
WireConnection;762;0;768;0
WireConnection;51;0;78;0
WireConnection;561;0;554;0
WireConnection;561;2;562;0
WireConnection;394;0;391;0
WireConnection;643;0;621;0
WireConnection;390;0;387;0
WireConnection;696;0;693;0
WireConnection;615;0;613;0
WireConnection;615;2;608;0
WireConnection;763;1;762;0
WireConnection;344;0;50;0
WireConnection;770;0;769;0
WireConnection;770;2;728;0
WireConnection;563;0;565;0
WireConnection;687;0;681;0
WireConnection;327;0;326;0
WireConnection;773;0;744;0
WireConnection;570;0;569;0
WireConnection;556;1;561;0
WireConnection;328;0;327;0
WireConnection;743;0;745;0
WireConnection;743;1;773;0
WireConnection;392;1;394;0
WireConnection;761;0;760;0
WireConnection;314;0;37;0
WireConnection;386;0;390;0
WireConnection;592;0;570;0
WireConnection;588;0;556;0
WireConnection;588;1;592;0
WireConnection;694;0;690;0
WireConnection;694;1;690;0
WireConnection;688;0;686;0
WireConnection;688;1;683;0
WireConnection;593;0;563;0
WireConnection;691;0;687;0
WireConnection;691;1;684;0
WireConnection;114;0;113;0
WireConnection;581;0;583;0
WireConnection;690;0;685;0
WireConnection;765;0;761;0
WireConnection;765;1;763;0
WireConnection;458;0;457;0
WireConnection;458;1;602;0
WireConnection;393;0;392;0
WireConnection;587;0;593;0
WireConnection;587;1;551;0
WireConnection;766;0;763;0
WireConnection;128;0;140;0
WireConnection;128;3;389;0
WireConnection;128;4;393;0
WireConnection;47;0;51;0
WireConnection;47;2;46;0
WireConnection;771;0;743;0
WireConnection;771;1;770;0
WireConnection;58;0;381;0
WireConnection;389;0;386;0
WireConnection;389;1;392;0
WireConnection;607;0;606;0
WireConnection;294;0;47;0
WireConnection;700;0;697;0
WireConnection;695;0;689;0
WireConnection;758;0;771;0
WireConnection;758;3;765;0
WireConnection;758;4;766;0
WireConnection;697;0;694;0
WireConnection;608;0;607;0
WireConnection;454;0;455;0
WireConnection;454;2;458;0
WireConnection;50;0;69;0
WireConnection;50;1;58;0
WireConnection;617;0;607;0
WireConnection;582;0;584;0
WireConnection;616;0;610;0
WireConnection;616;2;612;0
WireConnection;401;0;398;0
WireConnection;401;1;402;0
WireConnection;621;0;613;0
WireConnection;621;2;617;0
WireConnection;734;0;758;0
WireConnection;601;0;454;0
WireConnection;693;0;691;0
WireConnection;693;1;688;0
WireConnection;573;0;587;0
WireConnection;573;1;588;0
WireConnection;614;0;609;0
WireConnection;614;2;611;0
WireConnection;399;0;401;0
WireConnection;399;1;421;0
WireConnection;584;0;581;0
WireConnection;584;1;581;0
WireConnection;515;0;151;0
WireConnection;733;0;730;0
WireConnection;733;1;731;0
WireConnection;576;0;573;0
WireConnection;421;0;128;0
WireConnection;140;0;114;0
WireConnection;140;1;114;0
WireConnection;594;0;582;0
WireConnection;600;0;601;0
WireConnection;618;0;616;0
WireConnection;701;0;698;0
WireConnection;701;1;700;0
WireConnection;619;0;615;0
WireConnection;735;0;733;0
WireConnection;735;1;734;0
WireConnection;494;1;602;0
WireConnection;679;0;677;0
WireConnection;620;0;614;0
WireConnection;149;0;148;0
WireConnection;750;0;737;0
WireConnection;438;0;435;0
WireConnection;714;0;701;0
WireConnection;714;1;695;0
WireConnection;452;0;451;0
WireConnection;452;1;600;0
WireConnection;737;0;735;0
WireConnection;626;0;618;0
WireConnection;492;1;494;0
WireConnection;580;0;578;0
WireConnection;48;0;346;0
WireConnection;48;1;47;0
WireConnection;624;0;620;0
WireConnection;622;1;643;0
WireConnection;630;0;629;0
WireConnection;630;1;629;0
WireConnection;316;0;315;0
WireConnection;628;0;622;0
WireConnection;628;1;626;0
WireConnection;491;0;452;0
WireConnection;491;1;492;0
WireConnection;629;0;625;0
WireConnection;49;0;48;0
WireConnection;716;0;714;0
WireConnection;716;1;717;0
WireConnection;627;0;624;0
WireConnection;627;1;623;0
WireConnection;420;0;417;0
WireConnection;590;0;574;0
WireConnection;642;0;639;0
WireConnection;642;1;638;0
WireConnection;715;0;716;0
WireConnection;442;0;491;0
WireConnection;347;0;49;0
WireConnection;631;0;627;0
WireConnection;631;1;628;0
WireConnection;222;0;379;0
WireConnection;638;0;798;0
WireConnection;633;0;630;0
WireConnection;636;0;633;0
WireConnection;634;0;631;0
WireConnection;504;0;501;0
WireConnection;504;1;502;0
WireConnection;504;2;741;0
WireConnection;504;3;599;0
WireConnection;504;4;712;0
WireConnection;798;0;658;0
WireConnection;658;0;632;0
WireConnection;506;0;505;0
WireConnection;739;0;750;0
WireConnection;505;0;504;0
WireConnection;706;0;701;0
WireConnection;565;0;564;0
WireConnection;565;2;566;0
WireConnection;639;0;637;0
WireConnection;639;1;636;0
WireConnection;223;0;222;0
WireConnection;574;0;586;0
WireConnection;574;1;580;0
WireConnection;418;0;420;0
WireConnection;279;0;383;0
WireConnection;641;0;642;0
WireConnection;224;0;316;1
WireConnection;224;1;223;0
WireConnection;329;0;224;0
WireConnection;417;0;399;0
WireConnection;417;2;406;0
WireConnection;519;0;518;0
WireConnection;519;1;520;0
WireConnection;646;0;645;0
WireConnection;646;1;649;0
WireConnection;578;0;577;0
WireConnection;586;0;591;0
WireConnection;586;1;594;0
WireConnection;562;0;560;0
WireConnection;54;0;345;0
WireConnection;55;0;54;0
WireConnection;283;0;272;0
WireConnection;283;1;284;0
WireConnection;349;0;415;0
WireConnection;410;0;409;0
WireConnection;410;1;414;0
WireConnection;410;2;497;0
WireConnection;410;3;598;0
WireConnection;410;4;644;0
WireConnection;410;5;713;0
WireConnection;410;6;740;0
WireConnection;277;0;279;0
WireConnection;648;0;647;0
WireConnection;205;0;214;0
WireConnection;205;1;340;0
WireConnection;205;2;236;0
WireConnection;53;0;337;0
WireConnection;53;1;338;0
WireConnection;53;2;55;0
WireConnection;272;1;335;0
WireConnection;272;2;274;0
WireConnection;795;0;794;0
WireConnection;795;1;793;0
WireConnection;795;2;792;0
WireConnection;56;0;522;0
WireConnection;56;1;350;0
WireConnection;56;2;515;0
WireConnection;655;0;653;0
WireConnection;655;1;654;0
WireConnection;225;0;339;0
WireConnection;647;0;650;0
WireConnection;647;1;646;0
WireConnection;351;0;56;0
WireConnection;216;0;53;0
WireConnection;216;1;205;0
WireConnection;216;2;795;0
WireConnection;522;0;280;0
WireConnection;522;1;513;0
WireConnection;522;2;523;0
WireConnection;792;0;791;0
WireConnection;280;0;171;0
WireConnection;280;1;281;0
WireConnection;274;0;277;0
WireConnection;274;1;295;0
WireConnection;274;2;282;0
WireConnection;227;0;216;0
WireConnection;227;1;225;0
WireConnection;227;2;331;0
WireConnection;657;0;656;0
WireConnection;411;0;410;0
WireConnection;171;0;336;0
WireConnection;171;1;227;0
WireConnection;171;2;349;0
WireConnection;656;0;655;0
WireConnection;236;0;330;0
WireConnection;510;0;511;0
WireConnection;510;1;816;0
WireConnection;512;0;510;0
WireConnection;816;1;524;0
WireConnection;69;0;321;0
WireConnection;69;1;328;0
WireConnection;408;0;411;0
WireConnection;461;0;442;0
WireConnection;474;0;475;0
WireConnection;474;2;477;0
WireConnection;818;0;474;0
WireConnection;818;1;480;0
WireConnection;477;0;478;0
WireConnection;477;1;476;0
WireConnection;480;1;479;0
WireConnection;516;0;509;0
WireConnection;516;1;519;0
WireConnection;521;0;516;0
WireConnection;817;1;818;0
WireConnection;490;0;484;0
WireConnection;490;1;473;0
WireConnection;490;2;499;0
WireConnection;495;0;490;0
WireConnection;447;0;490;0
WireConnection;473;0;817;1
WireConnection;623;1;619;0
WireConnection;551;1;555;0
WireConnection;684;1;679;0
WireConnection;273;0;283;0
WireConnection;435;0;433;0
WireConnection;435;1;433;0
WireConnection;433;0;429;0
WireConnection;37;0;63;0
WireConnection;37;1;42;0
WireConnection;800;2;352;0
ASEEND*/
//CHKSM=A445D3280D61E3EB45A1D7CBE255E61A932AF2F5