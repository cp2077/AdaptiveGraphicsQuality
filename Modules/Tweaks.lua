local Tweaks = {
  list = {
    { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles", note = "Turning it off also turns off the lens flare effect", key = "Bloom", kind = "bool", default = true },
    -- { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles", note = "Ray Reconstruction toggle", key = "DLSSD", kind = "bool", default = true },
    { variant = "gameOptions", group = "Graphics", var = "RayTracing/Reference", key = "BounceNumber", kind = "int", default = -559038737 },
    { variant = "gameOptions", group = "Graphics", var = "RayTracing/Reference", key = "RayNumber", kind = "int", default = -559038737 },
    { variant = "gameOptions", group = "Graphics",
      note = "Number of raytracing samples for photomode screenshots", var = "RayTracing/ReferenceScreenshot", key = "SampleNumber", kind = "int", default = 5 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/PathTracing", key = "UseSSRFallback", kind = "bool", default = true },
    { variant = "gameOptions", group = "Graphics", var = "Rendering", key = "FakeGPUVRAM", kind = "float", default = 9 },
    { variant = "gameOptions", group = "Graphics", var = "Rendering", key = "FakeOverrideGPUVRAM", kind = "bool", default = false },
    
    { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles", key = "CharacterSubsurfaceScattering", kind = "bool", default = true },
    
    -- Character
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Skin", key = "SubsurfaceSpecularTintWeight", kind = "float", default = 0.3 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Skin", key = "SubsurfaceSpecularTint_B", kind = "float", default = 0.29 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Skin", key = "SubsurfaceSpecularTint_G", kind = "float", default = 0.26 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Skin", key = "SubsurfaceSpecularTint_R", kind = "float", default = 0.125 },

    { variant = "gameOptions", group = "Gameplay", var = "Developer/SaveSlotsConfig", key = "NumAutoSaveSlots", kind = "int", default = 10, min=0, max=200 },
    { variant = "gameOptions", group = "Gameplay", var = "Developer/SaveSlotsConfig", key = "NumQuickSaveSlots", kind = "int", default = 3, min=0, max=200 },
    { variant = "gameOptions", group = "Gameplay", var = "SaveConfig", key = "AutoSavePeriod", kind = "int", default = 300, unit = "sec", min=10, max=100000 },
  }
}

return Tweaks
