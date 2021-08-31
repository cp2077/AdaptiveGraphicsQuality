local Settings = require("Modules/Settings")
local GameSettings = require("Modules/GameSettings")
local Helpers = require("Modules/Helpers")

local GraphicsQuality = {}

function ConfirmChanges()
  if GameSettings.NeedsConfirmation() or GameSettings.NeedsReload() or GameSettings.NeedsRestart() then
    GameSettings.Confirm()
    GetSingleton("inkMenuScenario"):GetSystemRequestsHandler():RequestSaveUserSettings()
    return true
  end
end

function GraphicsQuality.SetSettings(var, val)
  GameSettings.Set(var, val)
  ConfirmChanges()
end

function GraphicsQuality.SetPreset(preset, presetName)
  -- DOF should always be enabled for the photomode otherwise it breaks
  if presetName == "photo" then
    for _,presetSettings in pairs(preset) do
      if presetSettings.var == "/graphics/basic/DepthOfField" then
        presetSettings.value = true
        break
      end
    end
  end

  if IsCurrentPreset(preset) then
    Helpers.PrintDebugMsg("skipping the same preset")
    return
  end

  for _,k in pairs(preset) do
    GameSettings.Set(k.var, k.value)
  end

  -- DOF should always be enabled for the photomode otherwise it breaks
  if presetName == "photo" then
    GameSettings.Set("/graphics/basic/DepthOfField", true)
  end

  if ConfirmChanges() then
    Helpers.PrintDebugMsg(tostring(presetName).. " preset has been applied")
  end

  App.currentPreset = presetName
end

function GraphicsQuality.GetCurrentPreset()
  local list = {}
  for i,k in pairs(Settings.list) do
    local value = nil
    if k.kind == "string_list" or k.kind == "int_list" then
      local opt, cur = GameSettings.Options(k.var)
      value = opt[cur]
    elseif k.kind == "name_list" then
      local opt, cur = GameSettings.Options(k.var)
      value = opt[cur].value
    else
      value = GameSettings.Get(k.var)
    end

    if value ~= nil then
      table.insert(list, { var = k.var, kind = k.kind, value = value })
    else
      Helpers.PrintMsg("couldn't get default preset")
    end
  end

  return list
end

return GraphicsQuality
