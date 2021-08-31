local Settings = {
  list = {
    -- Basic
    { variant = "gameSettings", var = "/graphics/basic/DepthOfField", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/LensFlares", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/MotionBlur", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/ChromaticAberration", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/basic/FilmGrain", kind = "bool", options = {} },

    -- Advanced
    { variant = "gameSettings", var = "/graphics/advanced/AmbientOcclusion", kind = "string_list", options = {} },
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

    -- Resolution
    { repaint = true, variant = "gameSettings", var = "/graphics/dynamicresolution/DLSS", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/dynamicresolution/StaticResolutionScaling", kind = "bool", options = {} },
    { repaint = true, variant = "gameSettings", var = "/graphics/dynamicresolution/SRS_Resolution", kind = "int", options = {} },
    { repaint = true, variant = "gameSettings", var = "/video/display/Resolution", kind = "string_list", options = {} },
    { repaint = true, variant = "gameSettings", var = "/video/display/WindowMode", kind = "string_list", options = {} },
    { variant = "gameSettings", var = "/video/display/VSync", kind = "string_list", options = {} },

    -- RTX
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracing", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedReflections", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedSunShadows", kind = "bool", options = {} },
    { variant = "gameSettings", var = "/graphics/raytracing/RayTracedLighting", kind = "string_list", options = {} },

    -- Tweaks
    -- { variant = "gameOptions", var = "/graphics/raytracing/RayTracedLighting", kind = "string_list", options = {} },
  }
}

return Settings
