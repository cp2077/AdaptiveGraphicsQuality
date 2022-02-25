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
  return ""
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

local currPresetTab = "normal"
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

local function renderPresetTab(presetName)

  local isActivePreset = App.currentPreset == presetName
  local isActiveTab = currPresetTab == presetName
  local treeName = GetTreeName(presetName)
  local buttonName = (isActivePreset and "> " or " ") .. (isActivePreset and treeName:upper() or treeName) .. (isActivePreset and " <" or " ")

  local colors = {}
  local tooltip = nil
  if isActivePreset then
    tooltip = "Active"
  end
  if not Config.inner.enabled[presetName] then
    colors = {{ ImGuiCol.Text, 1,1,1, 0.45 }}
    tooltip = "Disabled"
  end

  if presetName == "menu" then
    tooltip = "[Inventory and Character Creator] " .. (tooltip or "")
  end
  -- if isActivePreset then
  --   if isActiveTab then
  --     table.insert(colors, {ImGuiCol.Button, 0.0, 0.6, 0.2, 0.5})
  --   else
  --     table.insert(colors, {ImGuiCol.Button, 0.0, 0.6, 0.2, 1.0})
  --   end
  --   table.insert(colors, {ImGuiCol.ButtonActive, 0.0, 0.6, 0.2, 0.5})
  --   table.insert(colors, {ImGuiCol.ButtonHovered, 0.0, 0.6, 0.2, 0.7})
  -- end
  
  if R.Button(buttonName, { id = buttonName, disabled = isActiveTab, colors = colors, tooltip = tooltip }) then
    currPresetTab = presetName
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


local function renderPresetTabContent(presetName)
  if currPresetTab ~= presetName then
    return
  end

  local isOverride = presetName == "override"
  local isScene = presetName == "scene"

  R.NewLine(1)

  for i, setting in pairs(getCachedSettingsSearch(presetName)) do
    -- this breaks photomode
    if setting.var ~= "/graphics/advanced/DistantShadowsResolution_________TESTIT" then
      local varNameBase, varNameDetailed = GetVarName(setting.var)

      local info = getSettingsInfo(setting.var)
      -- if info == nil then
      --   print(setting.var)
      -- end

      local function renderInfo()
        if info.repaint then
          R.SameLine()
          local tooltip = "This option causes window redraw."
          R.Button("R", { tooltip = tooltip, small = true,  colors = {
            { ImGuiCol.Button, 0.9, 0.70, 0.45, 0.7  },
            { ImGuiCol.Text, 0.0, 0.0, 0.0,1.0  },
            { ImGuiCol.ButtonActive, 0.9, 0.70, 0.45, 0.7 },
            { ImGuiCol.ButtonHovered, 0.9, 0.70, 0.45, 0.7  },
          }  })
        end
      end
      local mainTextColors = {}

      if not info then
        print(setting.var)
      end

      if not Config.inner.enabled[presetName] then
        mainTextColors = {{ ImGuiCol.Text, 1,1,1, 0.45 }}
      elseif info.repaint then
        mainTextColors = {{ ImGuiCol.Text, 0.9, 0.70, 0.45, 1 }}
      end

      if setting.kind ~= "bool" then
        R.Text(firstToUpper(varNameDetailed), { colors = mainTextColors })
        renderInfo()
      end

      local current, options = GetSettingsOptions(setting)

      if setting.kind == "int" then
        local settingsValue = (type(Config.inner.presets[presetName][i].value) == "number") and Config.inner.presets[presetName][i].value or 100
        local itemID = presetName .. tostring(i) .. tostring(settingsValue)
        local value
        local used
        R.ItemWidth(150, function()
          value, used = R.InputInt("", settingsValue, { id = itemID, step = 5, stepFast = 10 })
        end)

        if used then
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
        local isActiveOption = Config.inner.presets[presetName][i].value
        local value, used = R.CheckBox(firstToUpper(varNameDetailed), isActiveOption, { colors = mainTextColors })
        renderInfo()

        if setting.var == "/graphics/basic/DepthOfField" and currPresetTab == "photo" then
          R.SameLine()
          R.Button(
            "?",
            {
              tooltip = "If set to false, Depth Of Field option will be disabled and removed from PhotoMode menu entirely. (Changing to true requires photomode restart)",
              small = true,
              colors = {
                { ImGuiCol.Button, unpack(R.Colors.Yellow) },
                { ImGuiCol.ButtonActive, unpack(R.Colors.Yellow) },
                { ImGuiCol.ButtonHovered, unpack(R.Colors.Yellow) },
              }
            }
          )
        end
        if used then
          -- if varNameDetailed == "RayTracing" then
          --   SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DynamicResolutionScaling", false)
          -- end

          if varNameDetailed == "DynamicResolutionScaling" then
            SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DLSS", "Off")
            SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/FSR", "Off")
            SetPresetSettingsValue(presetName, "/graphics/raytracing/RayTracing", false)
          end

          Config.inner.presets[presetName][i].value = value
          OnConfigChange()
        end
      else
        if #options > 7 then
          for iOpt, kOpt in pairs(options) do
            if Config.inner.presets[presetName][i].value == kOpt then
              local item
              local clicked
              R.ItemWidth(150, function()
                item, clicked = R.ComboItem("", iOpt-1, options, #options)
              end)
              if clicked then
                Config.inner.presets[presetName][i].value = options[item+1]
                OnConfigChange()
              end
            end
          end
        else
          for iOpt, kOpt in pairs(options) do
            local isActiveOption = Config.inner.presets[presetName][i].value == kOpt
            local buttonText = tostring(kOpt)
            local buttonID = presetName .. tostring(i) .. tostring(kOpt) .. "switch"
            if R.Button(buttonText, { disabled = isActiveOption, id = buttonID  }) and not isActiveOption then
              if varNameDetailed == "DLSS" then
                SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DynamicResolutionScaling", false)
                SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/FSR", "Off")
              end
              if varNameDetailed == "FSR" then
                SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DLSS", "Off")
                SetPresetSettingsValue(presetName, "/graphics/dynamicresolution/DynamicResolutionScaling", false)
              end

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

          if setting.var == "/graphics/advanced/DistantShadowsResolution" and currPresetTab == "photo" then
            R.SameLine()
            R.Button("?", { tooltip = 'In order to work properly,\nthis option has to be kept in sync with previously used preset', small = true,  colors = {
              { ImGuiCol.Button, unpack(R.Colors.Yellow) },
              { ImGuiCol.ButtonActive, unpack(R.Colors.Yellow) },
              { ImGuiCol.ButtonHovered, unpack(R.Colors.Yellow) },
            }})
          end
        end
      end
      ImGui.Dummy(0, 6)
      -- R.NewLine(1)
    end
  end
  R.NewLine(3)
end

local function renderCopyPasteMenu()
  if R.Button(" Copy ", { tooltip = "Copy current preset", sameLine = true }) then
    copiedPreset = json.decode(json.encode(Config.inner.presets[currPresetTab]))
  end

  if R.Button(" Paste ", { disabled = copiedPreset == nil, tooltip = "Paste copied preset" }) and copiedPreset ~= nil then
    Config.inner.presets[currPresetTab] = copiedPreset
    OnConfigChange()
  end
end

local function renderPresetsTabs()
  -- TABS
  for i,presetName in pairs({"normal", "photo", "combat", "vehicle", "scene", "menu"}) do
    renderPresetTab(presetName)
  end
  R.NewLine()

  R.Separator()
  R.NewLine(1)

  --COPY PASTE CONTROLS
  renderCopyPasteMenu()

  R.SameLine()

  if currPresetTab ~= "normal" and currPresetTab ~= "override" then
    local value, pressed = R.CheckBox("Enabled", Config.inner.enabled[currPresetTab], { tooltip = 'Turn off this preset' })
    if pressed then
      Config.inner.enabled[currPresetTab] = value
      OnConfigChange()
    end
  else
    R.Button("", { colors = {
    { ImGuiCol.Button, 0, 0, 0, 0.0 },
    { ImGuiCol.ButtonHovered, 0, 0, 0, 0.0},
    { ImGuiCol.ButtonActive, 0, 0, 0, 0.0}, }})
  end

  R.NewLine(1)
  R.Separator()

  -- CONTENT
  R.Window(
  "preset_settings",
  function()
    for i,presetName in pairs({"normal", "combat", "vehicle", "menu", "photo", "scene", "override" }) do
      renderPresetTabContent(presetName)
    end
  end,
  { saveScroll = true, isChild = true, minH = 393, minW = 560, maxH = 393, maxW = 560, vars = {}}
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
      for _,change in pairs(Changelog) do
        R.Text(change.version)
        for _,changeText in pairs(change.changes) do
          R.Text(changeText)
        end
        R.NewLine(2)
      end
    end,
    { isChild = true, minH = 480, minW = 560,  maxH = 480, maxW = 560, vars = {}}
  )
end

local function renderTweaksTab()
  local function render()
    local lastGroup = nil
    local lastVar = nil
    for i,tweakOption in pairs(Tweaks.list) do
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
          Config.inner.tweaks[tweakOption.var..tweakOption.key] = { value = value }
          Config.SaveConfig()
        end
      end

      if tweakOption.kind == "int" then
        local curValue = GameOptions.GetInt(tweakOption.var, tweakOption.key)
        local value
        local used
        R.ItemWidth(100, function()
          value, used = R.InputInt(tweakOption.key, curValue)
        end)
        if used then
          GameOptions.SetInt(tweakOption.var, tweakOption.key, value)

          -- min/max will be applied
          value = GameOptions.GetInt(tweakOption.var, tweakOption.key)
          Config.inner.tweaks[tweakOption.var..tweakOption.key] = { value = value }
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
          Config.inner.tweaks[tweakOption.var..tweakOption.key] = { value = value }
          Config.SaveConfig()
        end
      end

      if tooltip then
        R.SameLine()
        R.Button("?", { tooltip = tooltip, small = true,  colors = {
          { ImGuiCol.Button, unpack(R.Colors.Gray) },
          { ImGuiCol.ButtonActive, unpack(R.Colors.Gray) },
          { ImGuiCol.ButtonHovered, unpack(R.Colors.Gray) },
        }  })
      end
      R.SameLine()
      if R.Button("Reset", { small = true, id = tweakOption.var..tweakOption.key, {
        { ImGuiCol.Button, unpack(R.Colors.Redish) },
        { ImGuiCol.ButtonActive, unpack(R.Colors.Redish) },
        { ImGuiCol.ButtonHovered, unpack(R.Colors.Redish) },
      }}) then
        if tweakOption.kind == "bool" then
          GameOptions.SetBool(tweakOption.var, tweakOption.key, tweakOption.default)
        elseif tweakOption.kind == "float" then
          GameOptions.SetFloat(tweakOption.var, tweakOption.key, tweakOption.default)
        elseif tweakOption.kind == "int" then
          GameOptions.SetInt(tweakOption.var, tweakOption.key, tweakOption.default)
        end
        Config.inner.tweaks[tweakOption.var..tweakOption.key] = { value = tweakOption.default }
        Config.SaveConfig()
      end
    end
    R.NewLine(3)
  end
  return R.Window(
    "agq_tweaks",
    render,
    { saveScroll = true, isChild = true, minH = 480, minW = 560,  maxH = 480, maxW = 560, vars = {}}
  )
end

local function renderSettingsTab()
  local function render()
    -- Enabled
    local value, pressed = R.CheckBox("Enabled", App.isEnabled, { tooltip = 'Turn off auto auto switch completely' })
    if pressed then
      App.isEnabled = value
      OnConfigChange()
    end

    -- Autoswitch to normal
    local value, pressed = R.CheckBox('Auto switch to "Normal" preset when disabled', Config.inner.switchToNormalWhenDisabled)
    if pressed then
      Config.inner.switchToNormalWhenDisabled = value
      OnConfigChange()
    end

    -- disable autoswitch on hotkey
    local value, pressed = R.CheckBox('Disable auto switch when switched using hotkey', Config.inner.disableAutoswitchOnHotkey)
    if pressed then
      Config.inner.disableAutoswitchOnHotkey = value
      if value then
        Config.inner.switchToNormalWhenDisabled = false
      end

      OnConfigChange()
    end

    -- Combat in dangerous area
    local value, pressed = R.CheckBox('"Combat" in "Dangerous Area"', Config.inner.isDangerousAreaACombat, { tooltip = '"Combat" preset will be enabled every time you enter a "Dangerous" area.' })
    if pressed then
      Config.inner.isDangerousAreaACombat = value
      OnConfigChange()
    end

    -- Combat in restricted area
    local value, pressed = R.CheckBox('"Combat" in "Restricted Area"', Config.inner.isRestrictedAreaACombat, { tooltip = '"Combat" preset will be enabled every time you enter a "Restricted" area.' })
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
    { saveScroll = true, isChild = true, minH = 480, minW = 560,  maxH = 480, maxW = 560, vars = {}}
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
    { ImGuiCol.Border, 0, 0, 0, 0 },
    { ImGuiCol.ScrollbarBg, 0, 0, 0, 0 },
    { ImGuiCol.TitleBg, 0, 0, 0, 0.8 },
    { ImGuiCol.TitleBgActive, 0, 0, 0, 0.8 },
    { ImGuiCol.WindowBg, 0, 0, 0, 0.8 },
    { ImGuiCol.FrameBg, 0.25, 0.35, 0.45, 0.8 },
    { ImGuiCol.Separator, 0.25, 0.35, 0.45, 0.8 },
  }

  local winHeight = App.shouldCloseOverlay and 450 or 500
  local mainWindowVars = {
    { ImGuiStyleVar.WindowRounding, 7.0 },
    { ImGuiStyleVar.ScrollbarSize, 4 },
    { ImGuiStyleVar.WindowMinSize, 480, winHeight },
  }

  local function onConfigNotReady()
    R.Text("Config hasn't been initialized. Please check console output.", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
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
        R.NewLine()
        R.Text(" Autoswitch is turned off ")
        R.NewLine()
      end
      onRenderTabs()
        
      if App.shouldCloseOverlay then
        R.NewLine(1)
        R.Text("Close CET overlay to apply changes", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
      end
    end
  end

  R.Window("Adaptive Graphics Quality", renderMainWindow, { colors = mainWindowColors, vars = mainWindowVars })

  R.Asserts()
end


return Window

