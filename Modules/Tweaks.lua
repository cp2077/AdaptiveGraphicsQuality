local Tweaks = {
  list = {
    { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles",
      note = "Turning it off also turns off the lens flare effect", key = "Bloom", kind = "bool", default = true },
    -- { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles",
    --   note = "Turning it off may cause performance degradation", key = "Antialiasing", kind = "bool", default = true },
    -- i'm not sure what it does exactly
    -- { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles", alt_name = "ContrastAdaptiveSharpening", key = "ConstrastAdaptiveSharpening", kind = "bool", default = true },

    { variant = "gameOptions", group = "Graphics", var = "Developer/FeatureToggles", key = "CharacterSubsurfaceScattering", kind = "bool", default = true },

    -- Character
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Hair", key = "SpecularRandom_Max", kind = "float", default = 0.0 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Hair", key = "SpecularRandom_Min", kind = "float", default = -0.3 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Hair", key = "RoughnessFactor", kind = "float", default = 1.0 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Hair", key = "AlbedoMultiplier", kind = "float", default = 0.6 },
    { variant = "gameOptions", group = "Graphics", var = "Editor/Characters/Hair", key = "AdditionalAreaRoughness", kind = "float", default = 0.1 },

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
