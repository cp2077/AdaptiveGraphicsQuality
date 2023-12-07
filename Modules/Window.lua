local Settings = require("Modules/Settings")
local Tweaks = require("Modules/Tweaks")
local Config = require("Modules/Config")
local GameSettings = require("Modules/GameSettings")
local Helpers = require("Modules/Helpers")
local GraphicsQuality = require("Modules/GraphicsQuality")
local R = require("Modules/Renderer")
local Changelog = require("Modules/Changelog")

local Window = {}

ImGui = ImGui
ImGuiCol = ImGuiCol
ImGuiStyleVar = ImGuiStyleVar
ImGuiTreeNodeFlags = ImGuiTreeNodeFlags
ImGuiWindowFlags = ImGuiWindowFlags

function GetTreeName(k)
  if k == "vehicle" then return "Vehicle" end
  if k == "normal" then return "Normal" end
  if k == "menu" then return "Inv & CC" end
  if k == "photo" then return "PhotoMode" end
  if k == "combat" then return "Combat" end
  if k == "scene" then return "Cutscene" end
  if k == "override" then return "Override" end
  return k
end

function GetVarName(settingsVar)
  local output = {}
  for word in (settingsVar):gmatch("([^/]+)") do
    table.insert(output, word)
  end
  return output[2], output[3]
end

local copiedPreset = nil

-- function GetSectionName(varBaseName)
--     if varBaseName == "basic" then
--         return "Basic"
--     end
--     if varBaseName == "advanced" then
--         return "Advanced"
--     end
--     if varBaseName == "dynamicresolution" or varBaseName == "resolution" or varBaseName == "display" then
--         return "Display"
--     end
--     if varBaseName == "raytarcing" then
--         return "Ray Tracing"
--     end
-- end

function GetSettingsOptions(settings)
  local current
  local options = {}
  if settings.kind == "string_list" or settings.kind == "int_list" then
    options, cur = GameSettings.Options(settings.var)
    current = options[cur]
  elseif settings.kind == "name_list" then
    _options, cur = GameSettings.Options(settings.var)
    for i,k in pairs(_options) do
      table.insert(options, k.value)
    end
    current = options[cur].value
  else
    options = {true, false}
    current = GameSettings.Get(settings.var)
  end

  return current, options
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

local sections = {
  ["basic"] = false,
  ["advanced"] = false,
  ["resolution"] = false,
  ["raytracing"] = false,
}

function ButtonDisabled()
  ImGui.PushStyleColor(ImGuiCol.Button, 0.25, 0.35, 0.45, 0.3)
  ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.3)
  ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.25, 0.35, 0.45, 0.3)
  return 3
end
function ButtonSelected()
  ImGui.PushStyleColor(ImGuiCol.Button, 0.25, 0.35, 0.45, 0.8)
  ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.8)
  ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.25, 0.35, 0.45, 0.8)
  return 3
end

function OnConfigChange()
  Config.SaveConfig()
  SetPresetIfNeeded()
end

function TooltipIfHovered(text)
  if ImGui.IsItemHovered() then
    ImGui.BeginTooltip()
    ImGui.SetTooltip(text)
    ImGui.EndTooltip()
  end
end
---

function IsAutoPreset(presetName)
  for i,k in pairs({ "normal", "photo", "combat", "vehicle", "scene", "menu" }) do
    if presetName == k then
      return true
    end
  end
  return false
end

local function renderPresetTab(presetName)

  local isActivePreset = App.currentPreset == presetName
  local isActiveTab = Config.inner.currPresetTab == presetName
  local treeName = GetTreeName(presetName)
  -- local buttonName = (isActivePreset and "> " or " ") .. (isActivePreset and treeName:upper() or treeName) .. (isActivePreset and " <" or " ")
  local buttonName = " " .. treeName .. " "

  if isActivePreset then
    buttonName = buttonName:upper()
  end

  local colors = {}
  local tooltip = nil
  if isActivePreset then
    tooltip = "Active"
  end
  if not Config.inner.enabled[presetName] and IsAutoPreset(presetName) then
    colors = {{ ImGuiCol.Text, 1,1,1, 0.35 }}
    tooltip = "Uncheck to deactivate auto switch for this preset"
  end

  if presetName == "menu" then
    tooltip = "[Inventory and Character Creator] " .. (tooltip or "")
  end
  if isActivePreset then
    if isActiveTab then
      table.insert(colors, {ImGuiCol.Button, 0.0, 0.6, 0.2, 0.45})
    else
      table.insert(colors, {ImGuiCol.Button, 0.0, 0.6, 0.2, 1.0})
    end
    table.insert(colors, {ImGuiCol.ButtonActive, 0.0, 0.6, 0.2, 0.5})
    table.insert(colors, {ImGuiCol.ButtonHovered, 0.0, 0.6, 0.2, 0.7})
  end
  
  if R.Button(buttonName, { id = buttonName, disabled = isActiveTab, colors = colors, tooltip = tooltip }) then
    Config.inner.currPresetTab = presetName
    Config.SaveConfig()
  end
  R.SameLine()


  
end

local function SetPresetSettingsValue(presetName, var, value)
  for i, settings in pairs(Config.inner.presets[presetName]) do
    if settings.var == var then
      Config.inner.presets[presetName][i].value = value
      return
    end
  end
end

local searchSettingsString = ""
local searchSettingsStringLast = ""
local lastPresetName = ""
local searchSettings = {}

local function findIndex(var)
  for i,k in pairs(Settings.list) do
    if k.var == var then
      return i
    end
  end
  return -1
end

local function sortSettings(settings)
  table.sort(settings, function (a, b)
    return findIndex(a.var) < findIndex(b.var)
  end)


  return settings
end

local function getCachedSettingsSearch(presetName)
  local tempSettings = {}

  if searchSettingsString == "" then
    return Config.inner.presets[presetName]
  end

  if searchSettingsString == searchSettingsStringLast and lastPresetName == presetName then
    lastPresetName = presetName
    return searchSettings
  end

  for i, settings in pairs(Config.inner.presets[presetName]) do
    if string.find(settings.var:lower(), searchSettingsString:lower()) then
      table.insert(tempSettings, settings)
    end
  end

  searchSettingsStringLast = searchSettingsString
  lastPresetName = presetName
  searchSettings = tempSettings
  return searchSettings
end

local function getSettingsInfo(var)
  for i,settings in pairs(Settings.list) do
    if settings.var == var then
      return settings
    end
  end
end

local function GetSettingValueIdx(setting, presetName)
  for i, s in pairs(sortSettings(getCachedSettingsSearch(presetName))) do
    if s.var == setting then
      return i
    end
  end
  return 1
end

local function padding()
  R.CheckBox("",false, {colors = {{ ImGuiCol.Text, 0,0,0, 0.0 },{ ImGuiCol.CheckMark, 0,0,0, 0.0 },{ ImGuiCol.FrameBg,        0,0,0, 0.0 },
  { ImGuiCol.FrameBgHovered,        0,0,0, 0.0 },{ ImGuiCol.FrameBgActive,        0,0,0, 0.0 },
  { ImGuiCol.Button,        0,0,0, 0.0 },{ ImGuiCol.ButtonActive,  0,0,0, 0.0 },{ ImGuiCol.ButtonHovered, 0,0,0, 0.0 },}})
  R.SameLine()
  R.SameLine()
end

local function renderPresetTabContent(presetName)
  if Config.inner.currPresetTab ~= presetName then
    return
  end

  local isOverride = presetName == "override"
  local isScene = presetName == "scene"
  
  padding()
  R.Text("Dynamic Resolution")

  for i, setting in pairs(sortSettings(getCachedSettingsSearch(presetName))) do
    -- this breaks photomode
    if setting.var ~= "/graphics/advanced/DistantShadowsResolution_________TESTIT" then
      local varNameBase, varNameDetailed = GetVarName(setting.var)

      local info = getSettingsInfo(setting.var)

      if varNameDetailed == "DLSS_D" then
        varNameDetailed = "RayReconstruction"
      end

      local show = true

      local resScalingIdx = GetSettingValueIdx("/graphics/presets/ResolutionScaling", presetName)
      if (varNameBase == "presets" and varNameDetailed ~= "ResolutionScaling") then
        if (Config.inner.presets[presetName][resScalingIdx].ignore or Config.inner.presets[presetName][resScalingIdx].value == "Off") then
          show = false
        else
          show = false
          local v = varNameDetailed
          if Config.inner.presets[presetName][resScalingIdx].value == "DLSS" then
            if v == "RayReconstruction" or v == "DLSS_NewSharpness"  or v == "DLSSFrameGen" or v == "DLSSFrameGen" or v == "DLSS" then
              show = true
            end
          end
  
          if Config.inner.presets[presetName][resScalingIdx].value == "FSR" then
            if v == "FSR2" or v == "FSR2_Sharpness" then
              show = true
            end
          end

          if Config.inner.presets[presetName][resScalingIdx].value == "XeSS" then
            if v == "XESS" or v == "XESS_Sharpness" then
              show = true
            end
          end
        end

      end

      if (varNameBase == "presets" and varNameDetailed ~= "ResolutionScaling")
          and (Config.inner.presets[presetName][resScalingIdx].ignore or Config.inner.presets[presetName][resScalingIdx].value == "Off") then
        show = false
      end

      if info and show then
        if info.group then
          R.NewLine(1)
          padding()
          R.Text(firstToUpper(varNameBase))
        end
        
        local isActivePreset = Config.inner.enabled[presetName] or not IsAutoPreset(presetName)
        local isIgnore = not not Config.inner.presets[presetName][i].ignore
        local function renderInfo()
          if info.repaint then
            R.SameLine()
            local tooltip = "This setting reloads reshade and causes slight stutter"
            local opacity = 0.7
            if not isActivePreset then
              opacity = 0.5
            end
            if isIgnore then
              opacity = 0.2
            end
            R.Button("R", {
              tooltip = tooltip,
              small = true,
              colors = {
                { ImGuiCol.Button,        0.9, 0.70, 0.45, opacity },
                { ImGuiCol.Text,          0.0, 0.0,  0.0,  1.0 },
                { ImGuiCol.ButtonActive,  0.9, 0.70, 0.45, opacity },
                { ImGuiCol.ButtonHovered, 0.9, 0.70, 0.45, opacity },
              }
            })
          end
        end
        local mainTextColors = {}

        local value, used = R.CheckBox(
          "",
          not isIgnore,
          { 
            tooltip = "Uncheck to ignore this option", 
            id = presetName .. tostring(i) .. varNameDetailed, 
            colors = mainTextColors
          }
        )
        R.SameLine()
        -- R.Text("")
        R.SameLine()
        if used then
          Config.inner.presets[presetName][i].ignore = not value
          OnConfigChange()
        end

        local function ignoredColors()
          return {
            { ImGuiCol.Text, 1, 1, 1, 0.2 },
            { ImGuiCol.CheckMark, 0.25, 0.35, 0.45, 0.6 },
            { ImGuiCol.FrameBg,        0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.FrameBgHovered,        0.25, 0.35, 0.45, 0.3 },
            { ImGuiCol.FrameBgActive,        0.25, 0.35, 0.45, 0.3 },
            { ImGuiCol.Button,        0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.ButtonActive,  0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.2 },
          }
        end

        mainTextColors = { { ImGuiCol.Text, 1, 1, 1, 1 } }
        if not isActivePreset then
          if info and info.repaint then
            mainTextColors = { { ImGuiCol.Text, 0.9, 0.70, 0.45, 0.65 } }
          else
            mainTextColors = { { ImGuiCol.Text, 1, 1, 1, 0.65 } }
          end
        elseif info and info.repaint then
          mainTextColors = { { ImGuiCol.Text, 0.9, 0.70, 0.45, 1 } }
        end
        if isIgnore then
          mainTextColors = {
            { ImGuiCol.Text, 1, 1, 1, 0.2 },
            { ImGuiCol.CheckMark, 0.25, 0.35, 0.45, 0.6 },
            { ImGuiCol.FrameBg,        0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.FrameBgHovered,        0.25, 0.35, 0.45, 0.3 },
            { ImGuiCol.FrameBgActive,        0.25, 0.35, 0.45, 0.3 },
            { ImGuiCol.Button,        0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.ButtonActive,  0.25, 0.35, 0.45, 0.2 },
            { ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.2 },
          }
        end

        -- handle ray traced group
        local colors = mainTextColors
        local v = varNameDetailed
        if v == "RayTracedPathTracing"
           or v == "RayReconstruction"
           or v == "RayTracedReflections"
           or v == "RayTracedSunShadows"
           or v == "RayTracedLocalShadows"
           or v == "RayTracedLighting"
        then
          local rtIdx = GetSettingValueIdx("/graphics/raytracing/RayTracing", presetName)
          local curr, _ = GetSettingsOptions(sortSettings(getCachedSettingsSearch(presetName))[rtIdx])

          if (
            not Config.inner.presets[presetName][rtIdx].value
            or (not not Config.inner.presets[presetName][rtIdx].ignore and App.currentPreset ~= "" and not Config.inner.presets[App.currentPreset][GetSettingValueIdx("/graphics/raytracing/RayTracing", presetName)].value)
            or (App.currentPreset == "" and not curr)
          ) then
              colors = ignoredColors()
          end
        end

        local displayName = firstToUpper(varNameDetailed)
        if displayName == "RayTracing" then
          displayName = "Ray Tracing"
        elseif displayName == "RayTracedPathTracing" then
          displayName = "Path Tracing"
        elseif displayName == "RayReconstruction" then
          displayName = "DLSS Ray Reconstruction"
        elseif displayName == "DLSS_NewSharpness" then
          displayName = "DLSS Sharpness"
        elseif displayName == "FSR2_Sharpness" then
          displayName = "AMD FSR 2.1 Sharpening"
        elseif displayName == "XESS_Sharpness" then
          displayName = "Intel XeSS 1.2 Sharpness"
        elseif displayName == "RayTracedReflections" then
          displayName = "Ray-Traced Reflections"
        elseif displayName == "RayTracedSunShadows" then
          displayName = "Ray-Traced Sun Shadows"
        elseif displayName == "RayTracedLocalShadows" then
          displayName = "Ray-Traced Local Shadows"
        elseif displayName == "RayTracedLighting" then
          displayName = "Ray-Traced Lighting"
        elseif displayName == "WindowMode" then
          displayName = "Windowed Mode"
        elseif displayName == "MaximumFPS_OnOff" then
          displayName = "FPS Limit"
        elseif displayName == "MaximumFPS_Value" then
          displayName = "FPS Limit Value"
        elseif displayName == "ReflexMode" then
          displayName = "NVIDIA Reflex"
        elseif displayName == "HDRModes" then
          displayName = "HDR Mode"
        elseif displayName == "DepthOfField" then
          displayName = "Depth of Field"
        elseif displayName == "LensFlares" then
          displayName = "Lens Flare"
        elseif displayName == "ChromaticAberration" then
          displayName = "Chromatic Aberration"
        elseif displayName == "FilmGrain" then
          displayName = "Film Grain"
        elseif displayName == "MotionBlur" then
          displayName = "Motion Blur"
        elseif displayName == "AmbientOcclusion" then
          displayName = "Ambient Occlusion"
        elseif displayName == "CascadedShadowsRange" then
          displayName = "Cascaded ShadowsRange"
        elseif displayName == "CascadedShadowsResolution" then
          displayName = "Cascaded Shadows Resolution"
        elseif displayName == "ContactShadows" then
          displayName = "Contact Shadows"
        elseif displayName == "DistantShadowsResolution" then
          displayName = "Distant Shadows Resolution"
        elseif displayName == "LODPreset" then
          displayName = "Level of Detail (LOD)"
        elseif displayName == "LocalShadowsQuality" then
          displayName = "Local Shadows Quality"
        elseif displayName == "MaxDynamicDecals" then
          displayName = "Max Dynamic Decals"
        elseif displayName == "ScreenSpaceReflectionsQuality" then
          displayName = "Screen Space Reflections Quality"
        elseif displayName == "ShadowMeshQuality" then
          displayName = "Local Shadow Mesh Quality"
        elseif displayName == "VolumetricCloudsQuality" then
          displayName = "Volumetric Cloud Quality"
        elseif displayName == "VolumetricFogResolution" then
          displayName = "Volumetric Fog Resolution"
        elseif displayName == "GlobaIlluminationRange" then
          displayName = "Global Illumination Rage"
        elseif displayName == "ColorPrecision" then
          displayName = "Color Precision"
        elseif displayName == "SubsurfaceScatteringQuality" then
          displayName = "Subsurface Scattering Quality"
        elseif displayName == "FacialTangentUpdates" then
          displayName = "Facial Tangent Updates"
        elseif displayName == "DLSSFrameGen" then
          displayName = "DLSS Frame Generation"
        elseif displayName == "DLSS" then
          displayName = "DLSS Super Resolution"
        elseif displayName == "FSR2" then
          displayName = "AMD FidelityFX Super Resolution 2.1"
        elseif displayName == "XESS" then
          displayName = "Intel Xe Super Sampling 1.2"
        elseif displayName == "DLAA" then
          displayName = "NVIDIA DLAA"
        end

      
        if setting.kind ~= "bool" then
          R.Text(displayName, { colors = colors })
          renderInfo()

          padding()
        end


        local currentValue = Config.inner.presets[presetName][i].value

        local current, options = GetSettingsOptions(setting)

        if isIgnore then
          if App.currentPreset ~= "" then
            currentValue = Config.inner.presets[App.currentPreset][i].value
          else
            currentValue = current
          end
        end

        local function get(obj, key)
          local ok, result = pcall(function ()
            return obj[key]
          end)
          if ok then
            return result
          else
            print(result)
          end

          return nil
        end


        if setting.kind == "int" or setting.kind == "float" then
          local value
          local used
          local step = (get(info.options, "step") ~= nil) and get(info.options, "step") or 5
          local max = (get(info.options, "max") ~= nil) and info.options["max"] or 100
          local min = (get(info.options, "min") ~= nil) and info.options["min"] or 0
          local default = (get(info.options, "default") ~= nil) and info.options["default"] or 100
          local settingsValue = (type(currentValue) == "number") and
            currentValue or GameSettings.Get(setting.var)
          if settingsValue == nil then
            settingsValue = default
          end
          if settingsValue > max then
            settingsValue = max
          end
          if settingsValue < min then
            settingsValue = min
          end
          local itemID = presetName .. tostring(i) .. tostring(settingsValue)

          R.ItemWidth(250, function()
            if setting.kind == "float" then
              value, used = R.InputFloat("", settingsValue, { id = itemID, step = step, stepFast = 10, colors = mainTextColors })
            else
              value, used = R.InputInt("", settingsValue, { id = itemID, step = step, stepFast = 10, colors = mainTextColors })
            end
          end)

          if used and not isIgnore then
            if varNameDetailed == "DRS_TargetFPS" or varNameDetailed == "DRS_MinimalResolution" or varNameDetailed == "DRS_MaximalResolution" then
              local min = 5
              local max = 200
              value = math.max(min, math.min(value, max))
            end

            if isOverride then
              GraphicsQuality.SetSettings(setting.var, value)
            else
              Config.inner.presets[presetName][i].value = value
              OnConfigChange()
            end
          end
        elseif setting.kind == "bool" then
          local isActiveOption = currentValue
          local v = varNameDetailed

          local value, used = R.CheckBox(displayName, isActiveOption, { colors = colors })
          renderInfo()

          if setting.var == "/graphics/basic/DepthOfField" and Config.inner.currPresetTab == "photo" then
            R.SameLine()
            R.Button(
              "?",
              {
                tooltip =
                "If set to false, Depth Of Field option will be disabled and removed from PhotoMode menu entirely. (Changing to true requires photomode restart)",
                small = true,
                colors = {
                  { ImGuiCol.Button,        unpack(R.Colors.Yellow) },
                  { ImGuiCol.ButtonActive,  unpack(R.Colors.Yellow) },
                  { ImGuiCol.ButtonHovered, unpack(R.Colors.Yellow) },
                }
              }
            )
          end
          if used and not isIgnore then
            -- if varNameDetailed == "RayTracing" then
            --   SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DynamicResolutionScaling", false)
            -- end

            Config.inner.presets[presetName][i].value = value
            OnConfigChange()
          end
        else
          if #options > 7 or info.combo then
            for iOpt, kOpt in pairs(options) do
              if currentValue == kOpt then
                local item
                local clicked
                R.ItemWidth(250, function()
                  item, clicked = R.ComboItem(displayName, iOpt - 1, options, #options, { colors = mainTextColors })
                end)
      
                if clicked and not isIgnore then
                  Config.inner.presets[presetName][i].value = options[item + 1]
                  OnConfigChange()
                end
              end
            end
          else
            for iOpt, kOpt in pairs(options) do
              local isActiveOption = currentValue == kOpt
              local buttonText = tostring(kOpt)
              local tooltip = nil
              if varNameDetailed == "DLSS" or varNameDetailed == "FSR2" or varNameDetailed == "XESS" then
                tooltip = tostring(kOpt)
                if buttonText == "Auto" then
                  buttonText = "A"
                elseif buttonText == "Ultra Quality" then
                  buttonText = "UQ"
                elseif buttonText == "Quality" then
                  buttonText = "Q"
                elseif buttonText == "Balanced" then
                  buttonText = "B"
                elseif buttonText == "Performance" then
                  buttonText = "P"
                elseif buttonText == "Ultra Performance" then
                  buttonText = "UP"
                end
              end

              local buttonID = presetName .. tostring(i) .. tostring(kOpt) .. "switch"
              if R.Button(buttonText, { tooltip = tooltip, disabled = isActiveOption, id = buttonID, colors = colors }) and not isActiveOption and not isIgnore then
                if isOverride then
                  GraphicsQuality.SetSettings(setting.var, kOpt)
                else
                  Config.inner.presets[presetName][i].value = kOpt
                  OnConfigChange()
                end
              end
              R.SameLine()
              if iOpt == #options then
                R.NewLine()
              end
            end
            -- if varNameDetailed == "DLSS" or varNameDetailed == "FSR" or varNameDetailed == "Resolution" then
            --   R.SameLine()
            --   R.Button("?", { tooltip = 'This option is disabled for now due to a game bug.', small = true,  colors = {
            --     { ImGuiCol.Button, unpack(R.Colors.Red) },
            --     { ImGuiCol.ButtonActive, unpack(R.Colors.Red) },
            --     { ImGuiCol.ButtonHovered, unpack(R.Colors.Red) },
            --   }})
            -- end

            if setting.var == "/graphics/advanced/DistantShadowsResolution" and Config.inner.currPresetTab == "photo" then
              R.SameLine()
              R.Button("?",
                {
                  tooltip = 'In order to work properly,\nthis option has to be kept in sync with previously used preset',
                  small = true,
                  colors = {
                    { ImGuiCol.Button,        unpack(R.Colors.Yellow) },
                    { ImGuiCol.ButtonActive,  unpack(R.Colors.Yellow) },
                    { ImGuiCol.ButtonHovered, unpack(R.Colors.Yellow) },
                  }
                })
            end
          end
        end
        ImGui.Dummy(0, 6)
        -- R.NewLine(1)
      end
    end
  end
  R.NewLine(3)
end

local function renderCopyPasteMenu()
  if IsAutoPreset(Config.inner.currPresetTab) then
    R.Text(firstToUpper(Config.inner.currPresetTab) .. " ")
  else
    R.Text("Custom #" .. firstToUpper(Config.inner.currPresetTab) .. " ")
  end
  R.SameLine()
  if R.Button(" Copy ", { tooltip = "Copy current preset", sameLine = true, small = true }) then
    copiedPreset = json.decode(json.encode(Config.inner.presets[Config.inner.currPresetTab]))
  end

  if R.Button(" Paste ", { disabled = copiedPreset == nil, tooltip = "Paste copied preset", small = true }) and copiedPreset ~= nil then
    Config.inner.presets[Config.inner.currPresetTab] = copiedPreset
    OnConfigChange()
  end
  R.SameLine()
  if R.Button(" Force ", { tooltip = "Force activate this preset", sameLine = true, small = true }) then
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets[Config.inner.currPresetTab], Config.inner.currPresetTab)
  end
  if App.shouldCloseOverlay then
    R.NewLine()
    R.Text("Close CET overlay to apply changes", { colors = { { ImGuiCol.Text, unpack(R.Colors.Red) } } })
  end
end

local function renderPresetsTabs()
  -- TABS
  for i, presetName in pairs({ "normal", "photo", "combat", "vehicle", "scene", "menu" }) do
    renderPresetTab(presetName)
  end
  R.NewLine()
  for i, presetName in pairs({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }) do
    renderPresetTab(presetName)
  end
  R.NewLine()

  R.Separator()

  --COPY PASTE CONTROLS
  renderCopyPasteMenu()

  R.SameLine()

  if IsAutoPreset(Config.inner.currPresetTab) then
    local value, pressed = R.CheckBox("Auto switch", Config.inner.enabled[Config.inner.currPresetTab],
      { tooltip = 'Uncheck to turn off auto switch for this preset' })
    if pressed then
      Config.inner.enabled[Config.inner.currPresetTab] = value
      OnConfigChange()
    end
  else
    R.Button("", {
      colors = {
        { ImGuiCol.Button,        0, 0, 0, 0.0 },
        { ImGuiCol.ButtonHovered, 0, 0, 0, 0.0 },
        { ImGuiCol.ButtonActive,  0, 0, 0, 0.0 }, }
    })
  end

  R.Separator()

  local presets = { 
    "normal", "combat", "vehicle", "menu", "photo", "scene", "override",
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
   }

  -- CONTENT
  R.Window(
    "preset_settings",
    function()
      for i, presetName in pairs(presets) do
        renderPresetTabContent(presetName)
      end
    end,
    { saveScroll = true, isChild = true, dontResize = true, vars = {} }
  )
  -- R.NewLine(1)
  -- R.Text("Search ")
  -- R.SameLine()
  -- searchSettingsString, _ = R.InputText("", searchSettingsString, 100)
  -- R.SameLine()
  -- if R.Button("clear") then searchSettingsString = "" end

  -- R.NewLine()
end

local function renderOverrideTab()
end

local function renderInfoPage()
end
local function renderChangelog()
  R.Window(
    "agq_changelog",
    function()
      for _, change in pairs(Changelog) do
        R.Text(change.version)
        for _, changeText in pairs(change.changes) do
          R.Text(changeText)
        end
        R.NewLine(2)
      end
    end,
    { isChild = true, dontResize = true, vars = {} }
  )
end

local function renderTweaksTab()
  local function render()
    local lastGroup = nil
    local lastVar = nil
    for i, tweakOption in pairs(Tweaks.list) do
      if tweakOption.group ~= lastGroup then
        R.NewLine()
        if i > 1 then
          R.NewLine()
        end
        R.Text(tweakOption.group)
      end
      if tweakOption.var ~= lastVar then
        if tweakOption.group == lastGroup then
          R.NewLine()
        end
        R.Text("[" .. tweakOption.var .. "]")
      end
      lastGroup = tweakOption.group
      lastVar = tweakOption.var

      -- [AdaptiveGraphicsQuality] ...engine_tweaks\mods\AdaptiveGraphics\Modules\Renderer.lua:339: sol: no matching function call takes this number of arguments and the specified types

      local tooltip = tweakOption.note

      if tweakOption.kind == "bool" then
        local curValue = GameOptions.GetBool(tweakOption.var, tweakOption.key)
        local value, pressed = R.CheckBox(tweakOption.alt_name or tweakOption.key, curValue)
        if pressed then
          GameOptions.SetBool(tweakOption.var, tweakOption.key, value)
          Config.inner.tweaks[tweakOption.var .. tweakOption.key] = { value = value }
          Config.SaveConfig()
        end
      end

      if tweakOption.kind == "int" then
        local curValue = GameOptions.GetInt(tweakOption.var, tweakOption.key)
        local value
        local used
        R.ItemWidth(300, function()
          value, used = R.InputInt(tweakOption.key, curValue)
        end)
        if used then
          GameOptions.SetInt(tweakOption.var, tweakOption.key, value)

          -- min/max will be applied
          value = GameOptions.GetInt(tweakOption.var, tweakOption.key)
          Config.inner.tweaks[tweakOption.var .. tweakOption.key] = { value = value }
          Config.SaveConfig()
        end
      end

      if tweakOption.kind == "float" then
        local curValue = GameOptions.GetFloat(tweakOption.var, tweakOption.key)
        local value
        local used
        R.ItemWidth(100, function()
          value, used = R.DragFloat(tweakOption.key, curValue)
        end)
        ImGui.PopItemWidth()
        if used then
          GameOptions.SetFloat(tweakOption.var, tweakOption.key, value)

          -- min/max will be applied
          value = GameOptions.GetFloat(tweakOption.var, tweakOption.key)
          Config.inner.tweaks[tweakOption.var .. tweakOption.key] = { value = value }
          Config.SaveConfig()
        end
      end

      if tooltip then
        R.SameLine()
        R.Button("?", {
          tooltip = tooltip,
          small = true,
          colors = {
            { ImGuiCol.Button,        unpack(R.Colors.Gray) },
            { ImGuiCol.ButtonActive,  unpack(R.Colors.Gray) },
            { ImGuiCol.ButtonHovered, unpack(R.Colors.Gray) },
          }
        })
      end
      R.SameLine()
      if R.Button("Reset", { small = true, id = tweakOption.var .. tweakOption.key, {
            { ImGuiCol.Button,        unpack(R.Colors.Redish) },
            { ImGuiCol.ButtonActive,  unpack(R.Colors.Redish) },
            { ImGuiCol.ButtonHovered, unpack(R.Colors.Redish) },
          } }) then
        if tweakOption.kind == "bool" then
          GameOptions.SetBool(tweakOption.var, tweakOption.key, tweakOption.default)
        elseif tweakOption.kind == "float" then
          GameOptions.SetFloat(tweakOption.var, tweakOption.key, tweakOption.default)
        elseif tweakOption.kind == "int" then
          GameOptions.SetInt(tweakOption.var, tweakOption.key, tweakOption.default)
        end
        Config.inner.tweaks[tweakOption.var .. tweakOption.key] = { value = tweakOption.default }
        Config.SaveConfig()
      end
    end
    R.NewLine(3)
  end
  return R.Window(
    "agq_tweaks",
    render,
    { saveScroll = true, isChild = true, dontResize = true, vars = {} }
  )
end

local function renderSettingsTab()
  local function render()
    -- Enabled
    local value, pressed = R.CheckBox("Global auto switch", App.isEnabled, { tooltip = 'Uncheck to disable auto switch functionality' })
    if pressed then
      App.isEnabled = value
      Config.SaveConfig()
    end

    -- enabled on start
    local value, pressed = R.CheckBox('Enable global auto switch on boot', Config.inner.enabledOnStart, { tooltip = 'Auto switch will be enabled upon game start' })
    if pressed then
      Config.inner.enabledOnStart = value
      Config.SaveConfig()
    end

    R.NewLine()

    -- Autoswitch to normal
    -- local value, pressed = R.CheckBox('Set to "Normal" preset when auto switch is disabled', Config.inner.switchToNormalWhenDisabled)
    -- if pressed then
    --   Config.inner.switchToNormalWhenDisabled = value
    --   OnConfigChange()
    -- end

    -- disable autoswitch on hotkey
    local value, pressed = R.CheckBox('Disable auto switch when hotkey switch is used', Config.inner.disableAutoswitchOnHotkey)
    if pressed then
      Config.inner.disableAutoswitchOnHotkey = value
      if value then
        Config.inner.switchToNormalWhenDisabled = false
      end

      Config.SaveConfig()
    end

    R.NewLine()

    -- Combat when unholstered
    local value, pressed = R.CheckBox('"Combat" when unholstered', Config.inner.combatUnholstered,
      { tooltip = '"Combat" preset will be activated every time you unholster' })
    if pressed then
      Config.inner.combatUnholstered = value
      OnConfigChange()
    end

    if Config.inner.combatUnholstered then
      -- Combat when unholstered in a vehicle
      local value, pressed = R.CheckBox('"Combat" when unholstered in a vehicle', Config.inner.combatUnholsteredVehicle,
        { tooltip = '"Combat" preset will be activated every time you unholster inside a vehicle' })
      if pressed then
        Config.inner.combatUnholsteredVehicle = value
        OnConfigChange()
      end
      
    end

    -- Combat in dangerous area
    local value, pressed = R.CheckBox('"Combat" in "Dangerous Area"', Config.inner.isDangerousAreaACombat,
      { tooltip = '"Combat" preset will be activated every time you enter a "Dangerous" area.' })
    if pressed then
      Config.inner.isDangerousAreaACombat = value
      OnConfigChange()
    end
    

    -- Combat in restricted area
    local value, pressed = R.CheckBox('"Combat" in "Restricted Area"', Config.inner.isRestrictedAreaACombat,
      { tooltip = '"Combat" preset will be enabled every time you enter a "Restricted" area (recommended)' })
    if pressed then
      Config.inner.isRestrictedAreaACombat = value
      OnConfigChange()
    end

    R.NewLine()

    -- debug mode
    local value, pressed = R.CheckBox('Debug mode', Config.inner.isDebug)
    if pressed then
      Config.inner.isDebug = value
      OnConfigChange()
    end
  end

  return R.Window(
    "agq_settings",
    render,
    { saveScroll = true, isChild = true, dontResize = true, vars = {} }
  )
end

local function onRenderTabs()
  R.TabBar("agq_tabbar_", function()
    R.Tab("Presets", renderPresetsTabs)
    R.Tab("Tweaks", renderTweaksTab)
    R.Tab("Settings", renderSettingsTab)
    R.Tab("Changelog", renderChangelog)
  end)
end

function Window.Draw(isConfigReady)
  local mainWindowColors = {
    { ImGuiCol.Border,        0,    0,    0,    0 },
    { ImGuiCol.ScrollbarBg,   0,    0,    0,    0 },
    { ImGuiCol.TitleBg,       0,    0,    0,    0.7 },
    { ImGuiCol.TitleBgActive, 0,    0,    0,    0.7 },
    { ImGuiCol.WindowBg,      0,    0,    0,    0.7 },
    { ImGuiCol.FrameBg,       0.25, 0.35, 0.45, 0.8 },
    { ImGuiCol.Separator,     0.25, 0.35, 0.45, 0.8 },
  }

  local winHeight = App.shouldCloseOverlay and 450 or 500
  local mainWindowVars = {
    { ImGuiStyleVar.WindowRounding, 7.0 },
    { ImGuiStyleVar.ScrollbarSize,  4 },
    -- { ImGuiStyleVar.WindowMinSize,  480, winHeight },
  }

  local function onConfigNotReady()
    R.Text("Config hasn't been initialized. Please check console output.",
      { colors = { { ImGuiCol.Text, unpack(R.Colors.Red) } } })
  end
  local function onSettingsApplyError()
    R.Text("Failed to apply config. Please check console output.")
    if R.Button("Reset window") then
      Errors.SETTINGS_APPLY = false
    end
  end

  local function renderMainWindow()
    if not isConfigReady then
      onConfigNotReady()
    elseif Errors.SETTINGS_APPLY then
      onSettingsApplyError()
    else
      if not App.isEnabled then
        R.Text(" Global auto switch is off ", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
      else
        R.Text(" Global auto switch is on ", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Green) }} })
      end
      onRenderTabs()
    end
  end
  
  local scale = ImGui.GetFontSize() / 18

  R.Window("Adaptive Graphics Quality", renderMainWindow, { minH = 480 * scale, minW = 350 * scale, maxH = 900 * scale, maxW = 500 * scale, colors = mainWindowColors, vars = mainWindowVars, dontResize = true,   })

  R.Asserts()
end

return Window
