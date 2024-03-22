using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine.Rendering;

namespace Pinwheel.Poseidon
{
    [CustomEditor(typeof(PWater))]
    public class PWaterInspector : Editor
    {
        private PWater water;
        private PWaterProfile profile;
        private bool willDrawDebugGUI = false;

        private SerializedObject so;
        private SerializedProperty reflectionLayersSO;
        private SerializedProperty refractionLayersSO;

        private readonly int[] renderTextureSizes = new int[] { 128, 256, 512, 1024, 2048 };
        private readonly string[] renderTextureSizeLabels = new string[] { "128", "256", "512", "1024", "2048*" };

        private readonly int[] meshTypes = new int[]
        {
            (int)PWaterMeshType.TileablePlane
        };
        private readonly string[] meshTypeLabels = new string[]
        {
            "Tilealbe Plane"
        };

        private bool isEditingTileIndices = false;

        private PTilesEditingGUIDrawer tileEditingGUIDrawer;

        private static Mesh quadMesh;
        private static Mesh QuadMesh
        {
            get
            {
                if (quadMesh == null)
                {
                    quadMesh = Resources.GetBuiltinResource<Mesh>("Quad.fbx");
                }
                return quadMesh;
            }
        }

        private static Material maskVisualizerMaterial;
        private static Material MaskVisualizerMaterial
        {
            get
            {
                if (maskVisualizerMaterial == null)
                {
                    maskVisualizerMaterial = new Material(Shader.Find("Hidden/Poseidon/WaveMaskVisualizer"));
                }
                return maskVisualizerMaterial;
            }
        }

        private enum PWaveMaskVisualizationMode
        {
            None,
            //Flow, 
            Crest,
            Height
        }

        private PWaveMaskVisualizationMode waveMaskVisMode;

        private void OnEnable()
        {
            LoadPrefs();
            water = target as PWater;
            if (water.Profile != null)
            {
                water.ReCalculateBounds();
            }

            tileEditingGUIDrawer = new PTilesEditingGUIDrawer(water);

            SceneView.duringSceneGui += DuringSceneGUI;
            Camera.onPreCull += OnRenderCamera;
            RenderPipelineManager.beginCameraRendering += OnRenderCameraSRP;
        }

        private void OnDisable()
        {
            SavePrefs();
            isEditingTileIndices = false;

            SceneView.duringSceneGui -= DuringSceneGUI;
            Camera.onPreCull -= OnRenderCamera;
            RenderPipelineManager.beginCameraRendering -= OnRenderCameraSRP;
        }

        private void LoadPrefs()
        {
            waveMaskVisMode = (PWaveMaskVisualizationMode)SessionState.GetInt("poseidon-wave-mask-vis-mode", 0);
        }

        private void SavePrefs()
        {
            SessionState.SetInt("poseidon-wave-mask-vis-mode", (int)waveMaskVisMode);
        }

        public override void OnInspectorGUI()
        {
            if (water.transform.rotation != Quaternion.identity)
            {
                string warning = "The water object is designed to work without rotation. Some features may not work correctly.";
                EditorGUILayout.LabelField(warning, PEditorCommon.WarningLabel);
            }

            water.Profile = PEditorCommon.ScriptableObjectField<PWaterProfile>("Profile", water.Profile);
            profile = water.Profile;
            if (water.Profile == null)
                return;
            so = new SerializedObject(profile);
            reflectionLayersSO = so.FindProperty("reflectionLayers");
            refractionLayersSO = so.FindProperty("refractionLayers");

            EditorGUI.BeginChangeCheck();
            DrawMeshSettingsGUI();
            DrawRenderingSettingsGUI();
            DrawTimeSettingsGUI();
            DrawColorsSettingsGUI();
            DrawFresnelSettingsGUI();
            DrawRippleSettingsGUI();
            DrawLightAbsorbtionSettingsGUI();
            DrawFoamSettingsGUI();
            DrawReflectionSettingsGUI();
            DrawRefractionSettingsGUI();

            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(water);
                EditorUtility.SetDirty(profile);
                water.UpdateMaterial();
            }

            if (willDrawDebugGUI)
                DrawDebugGUI();

            if (so != null)
            {
                so.Dispose();
            }

            if (reflectionLayersSO != null)
            {
                reflectionLayersSO.Dispose();
            }

            if (refractionLayersSO != null)
            {
                refractionLayersSO.Dispose();
            }
        }

        private void DrawMeshSettingsGUI()
        {
            string label = "Mesh";
            string id = "water-profile-mesh";
            GenericMenu menu = new GenericMenu();
            menu.AddItem(
                new GUIContent("Generate"),
                false,
                () => { water.GenerateMesh(); });

            PEditorCommon.Foldout(label, true, id, () =>
            {
                if (water.MeshType == PWaterMeshType.TileablePlane)
                {
                    DrawTilableMeshGUI();
                }
            }, menu);
        }

        private void DrawTilableMeshGUI()
        {
            if (!isEditingTileIndices)
            {
                EditorGUI.BeginChangeCheck();
                water.MeshType = (PWaterMeshType)EditorGUILayout.IntPopup("Mesh Type", (int)water.MeshType, meshTypeLabels, meshTypes);
                water.PlanePattern = (PPlaneMeshPattern)EditorGUILayout.EnumPopup("Pattern", water.PlanePattern);
                water.MeshResolution = EditorGUILayout.DelayedIntField("Resolution", water.MeshResolution);
                if (EditorGUI.EndChangeCheck())
                {
                    water.GenerateMesh();
                    water.ReCalculateBounds();
                }
                water.MeshNoise = EditorGUILayout.FloatField("Noise", water.MeshNoise);

                EditorGUI.BeginChangeCheck();
                water.TileSize = PEditorCommon.InlineVector2Field("Tile Size", water.TileSize);
                water.TilesFollowMainCamera = EditorGUILayout.Toggle("Follow Main Camera", water.TilesFollowMainCamera);
                SerializedObject so = new SerializedObject(water);
                SerializedProperty sp = so.FindProperty("tileIndices");

                if (sp != null)
                {
                    EditorGUI.BeginChangeCheck();
                    EditorGUILayout.PropertyField(sp, true);
                    if (EditorGUI.EndChangeCheck())
                    {
                        so.ApplyModifiedProperties();
                    }
                }

                sp.Dispose();
                so.Dispose();

                if (EditorGUI.EndChangeCheck())
                {
                    water.ReCalculateBounds();
                }
            }

            if (!isEditingTileIndices)
            {
                if (GUILayout.Button("Edit Tiles"))
                {
                    isEditingTileIndices = true;
                }
            }
            else
            {
                EditorGUILayout.LabelField("Edit water tiles in Scene View.", PEditorCommon.WordWrapItalicLabel);
                if (GUILayout.Button("End Editing Tiles"))
                {
                    isEditingTileIndices = false;
                }
            }
        }

        private void DrawRenderingSettingsGUI()
        {
            string label = "Rendering";
            string id = "water-profile-general";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                GUI.enabled = false;
                EditorGUILayout.ObjectField("Material", water.MaterialToRender, typeof(Material), false);
                if (water.MeshType == PWaterMeshType.TileablePlane && water.ShouldRenderBackface)
                {
                    EditorGUILayout.ObjectField("Material Back Face", water.MaterialBackFace, typeof(Material), false);
                }
                GUI.enabled = true;
                profile.RenderQueueIndex = EditorGUILayout.IntField("Queue Index", profile.RenderQueueIndex);

                profile.LightingModel = (PLightingModel)EditorGUILayout.EnumPopup("Light Model", profile.LightingModel);
                profile.UseFlatLighting = EditorGUILayout.Toggle("Flat Lighting", profile.UseFlatLighting);
                if (water.MeshType == PWaterMeshType.TileablePlane)
                {
                    water.ShouldRenderBackface = EditorGUILayout.Toggle("Render Back Face", water.ShouldRenderBackface);
                }

            });
        }

        private void DrawTimeSettingsGUI()
        {
            string label = "Time";
            string id = "water-time";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                EditorGUILayout.LabelField("Time", water.GetTimeParam().ToString());
            });
        }

        private void DrawColorsSettingsGUI()
        {
            string label = "Colors";
            string id = "water-profile-colors";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.Color = EditorGUILayout.ColorField("Color", profile.Color);
                if (profile.EnableLightAbsorption)
                {
                    profile.DepthColor = EditorGUILayout.ColorField("Depth Color", profile.DepthColor);
                }
                if (profile.LightingModel == PLightingModel.PhysicalBased || profile.LightingModel == PLightingModel.BlinnPhong)
                {
                    profile.SpecColor = EditorGUILayout.ColorField(new GUIContent("Specular Color"), profile.SpecColor, true, false, true);
                    profile.Smoothness = EditorGUILayout.Slider("Smoothness", profile.Smoothness, 0f, 1f);
                }
            });
        }

        private void DrawFresnelSettingsGUI()
        {
            string label = "Fresnel";
            string id = "water-profile-fresnel";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.FresnelStrength = EditorGUILayout.Slider("Strength", profile.FresnelStrength, 0f, 10f);
                profile.FresnelBias = EditorGUILayout.Slider("Bias", profile.FresnelBias, 0f, 1f);
            });
        }

        private void DrawLightAbsorbtionSettingsGUI()
        {
            string label = "Light Absorption";
            string id = "water-profile-absorption";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.EnableLightAbsorption = EditorGUILayout.Toggle("Enable", profile.EnableLightAbsorption);
                if (profile.EnableLightAbsorption)
                {
                    profile.DepthColor = EditorGUILayout.ColorField("Depth Color", profile.DepthColor);
                    profile.MaxDepth = EditorGUILayout.FloatField("Max Depth", profile.MaxDepth);
                }
            });
        }

        private void DrawFoamSettingsGUI()
        {
            string label = "Foam";
            string id = "water-profile-foam";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.EnableFoam = EditorGUILayout.Toggle("Enable", profile.EnableFoam);
                if (profile.EnableFoam)
                {
                    profile.EnableFoamHQ = EditorGUILayout.Toggle("High Quality", profile.EnableFoamHQ);
                    if (profile.EnableFoamHQ)
                    {
                        profile.FoamNoiseScaleHQ = EditorGUILayout.FloatField("Scale", profile.FoamNoiseScaleHQ);
                        profile.FoamNoiseSpeedHQ = EditorGUILayout.FloatField("Speed", profile.FoamNoiseSpeedHQ);
                    }
                    profile.FoamColor = EditorGUILayout.ColorField(new GUIContent("Color"), profile.FoamColor, true, true, true);

                    PEditorCommon.Header("Shoreline");
                    profile.FoamDistance = EditorGUILayout.FloatField("Distance", profile.FoamDistance);
                    profile.ShorelineFoamStrength = EditorGUILayout.Slider("Strength", profile.ShorelineFoamStrength, 0f, 1f);
                }
            });
        }

        private void DrawRippleSettingsGUI()
        {
            string label = "Ripple";
            string id = "water-profile-ripple";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.RippleHeight = EditorGUILayout.Slider("Height", profile.RippleHeight, 0f, 1f);
                profile.RippleNoiseScale = EditorGUILayout.FloatField("Scale", profile.RippleNoiseScale);
                profile.RippleSpeed = EditorGUILayout.FloatField("Speed", profile.RippleSpeed);
            });
        }

        private void DrawReflectionSettingsGUI()
        {
            bool stereoEnable = false;
            if (Camera.main != null)
            {
                stereoEnable = Camera.main.stereoEnabled;
            }

            string label = "Reflection" + (stereoEnable ? " (Not support for VR)" : "");
            string id = "water-profile-reflection";

            GUI.enabled = !stereoEnable;
            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.EnableReflection = EditorGUILayout.Toggle("Enable", profile.EnableReflection);
                if (profile.EnableReflection)
                {
                    profile.ReflectCustomSkybox = EditorGUILayout.Toggle("Custom Skybox", profile.ReflectCustomSkybox);
                    profile.EnableReflectionPixelLight = EditorGUILayout.Toggle("Pixel Light", profile.EnableReflectionPixelLight);
                    profile.ReflectionClipPlaneOffset = EditorGUILayout.FloatField("Clip Plane Offset", profile.ReflectionClipPlaneOffset);

                    if (reflectionLayersSO != null)
                    {
                        EditorGUILayout.PropertyField(reflectionLayersSO);
                    }
                    so.ApplyModifiedProperties();

                    profile.ReflectionTextureResolution = EditorGUILayout.IntPopup("Resolution", profile.ReflectionTextureResolution, renderTextureSizeLabels, renderTextureSizes);
                    profile.ReflectionDistortionStrength = EditorGUILayout.FloatField("Distortion", profile.ReflectionDistortionStrength);
                }
            });
            GUI.enabled = true;
        }

        private void DrawRefractionSettingsGUI()
        {
            string label = "Refraction";
            string id = "water-profile-refraction";

            PEditorCommon.Foldout(label, true, id, () =>
            {
                profile.EnableRefraction = EditorGUILayout.Toggle("Enable", profile.EnableRefraction);
                profile.RefractionDistortionStrength = EditorGUILayout.FloatField("Distortion", profile.RefractionDistortionStrength);

            });
        }

        private void DuringSceneGUI(SceneView sv)
        {
            Tools.hidden = isEditingTileIndices;
            if (water.MeshType == PWaterMeshType.TileablePlane && isEditingTileIndices)
            {
                DrawEditingTilesGUI();
            }

            if (isEditingTileIndices)
            {
                DrawBounds();
            }
        }

        private void DrawEditingTilesGUI()
        {
            tileEditingGUIDrawer.Draw();
        }

        private void DrawBounds()
        {
            if (Event.current == null)
                return;
            if (water.Profile == null)
                return;

            Vector3 center = water.transform.TransformPoint(water.Bounds.center);
            Vector3 size = water.transform.TransformVector(water.Bounds.size);
            Handles.color = Color.yellow;
            Handles.DrawWireCube(center, size);
        } 

        public void DrawDebugGUI()
        {
            string label = "Debug";
            string id = "debug" + water.GetInstanceID().ToString();

            PEditorCommon.Foldout(label, false, id, () =>
            {
                Camera[] cams = water.GetComponentsInChildren<Camera>();
                for (int i = 0; i < cams.Length; ++i)
                {
                    if (!cams[i].name.StartsWith("~"))
                        continue;
                    if (cams[i].targetTexture == null)
                        continue;
                    EditorGUILayout.LabelField(cams[i].name);
                    Rect r = GUILayoutUtility.GetAspectRect(1);
                    EditorGUI.DrawPreviewTexture(r, cams[i].targetTexture);
                    EditorGUILayout.Space();
                }
            });
        }

        public override bool RequiresConstantRepaint()
        {
            return willDrawDebugGUI;
        }

        private void OnRenderCamera(Camera cam)
        {
            
        }

        private void OnRenderCameraSRP(ScriptableRenderContext context, Camera cam)
        {
            OnRenderCamera(cam);
        }
    }
}
