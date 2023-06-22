local Settings = {
  list = {

    -- DLSS
    { repaint = true, variant = "gameSettings", var = "/graphics/dlss/DLSS", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/dynamicresolution/FSR2", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/dlss/DLAA", kind = "bool", options = {} },

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
    { group = true, variant = "gameSettings", var = "/video/display/MaximumFPS_OnOff", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/video/display/MaximumFPS_Value", kind = "int", options = {} },

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
    { variant = "gameSettings", var = "/gameplay/performance/CrowdDensity", kind = "name_list", options = {} },

  }
}

return Settings

