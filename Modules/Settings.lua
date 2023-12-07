local Settings = {
  list = {

    -- DLSS
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/ResolutionScaling", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/DLSS", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/DLSS_NewSharpness", kind = "float", options = { default = 0, max = 1, step = 0.1, min = 0 } },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/DLSSFrameGen", kind = "bool", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/DLSS_D", kind = "bool", options = {} },

    { repaint = true, variant = "gameSettings", var = "/graphics/presets/DLAA_NewSharpness", kind = "float", options = { default = 0, max = 1, step = 0.1, min = 0 } },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/FSR2", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/FSR2_Sharpness", kind = "float", options = { default = 0, max = 1, step = 0.1, min = 0 } },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/XESS", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/presets/XESS_Sharpness", kind = "float", options = { default = 0, max = 1, step = 0.1, min = 0 } },
    
    -- RTX
    { group = true, variant = "gameSettings", var = "/graphics/raytracing/RayTracing", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedPathTracing", kind = "bool", options = {} },
  
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedReflections", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedSunShadows", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedLocalShadows", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedLighting", kind = "string_list", options = {} },

    -- Resolution
    { group = true, repaint = true, variant = "gameSettings", var = "/video/display/Resolution", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/video/display/WindowMode", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/video/display/VSync", kind = "string_list", options = {}, combo = true },

    { variant = "gameSettings", var = "/video/display/MaximumFPS_OnOff", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/video/display/MaximumFPS_Value", kind = "int", options = {} },

    { repaint = true, variant = "gameSettings", var = "/video/display/ReflexMode", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/video/display/HDRModes", kind = "string_list", options = {} },
    
    -- Basic
    { group = true, variant = "gameSettings", var = "/graphics/basic/DepthOfField", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/LensFlares", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/ChromaticAberration", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/FilmGrain", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/MotionBlur", kind = "string_list", options = {} },
    
    -- Advanced
    { group = true, variant = "gameSettings", var = "/graphics/advanced/AmbientOcclusion", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/CascadedShadowsRange", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/CascadedShadowsResolution", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/ContactShadows", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/DistantShadowsResolution", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/LODPreset", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/LocalShadowsQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/MaxDynamicDecals", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/MirrorQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/ScreenSpaceReflectionsQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/ShadowMeshQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/VolumetricCloudsQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/VolumetricFogResolution", kind = "string_list", options = {} },

    -- { variant = "gameSettings", var = "/graphics/TextureQuality", kind = "string_list", options = {} },
    -- { variant = "gameSettings", var = "/gameplay/performance/SlowHDD", kind = "bool", options = {} },
    -- { variant = "gameSettings", var = "/gameplay/performance/HDDMode", kind = "name_list", options = {} },
    -- { variant = "gameSettings", var = "/gameplay/performance/CrowdDensity", kind = "string_list", options = {} },
    
    -- { variant = "gameSettings", var = "/graphics/advanced/CrowdDensity", kind = "name_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/GlobaIlluminationRange", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/ColorPrecision", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/SubsurfaceScatteringQuality", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/advanced/FacialTangentUpdates", kind = "bool", options = {} },

    -- { variant = "gameSettings", var = "/interface/CrowdsOnMinimap", kind = "bool", options = {} },
    
  }
}

return Settings

