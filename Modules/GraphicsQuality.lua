local GraphicsQuality = {}

local Settings = require("Modules/Settings")
local GameSettings = require("Modules/GameSettings")
local Helpers = require("Modules/Helpers")
local Cron = require("Modules/Cron")

function ConfirmChanges(callback)
  GameSettings.Confirm()
  GameSettings.Save()

  if callback then
    callback()
  end

  return true
end

function GraphicsQuality.SetSettings(var, val)
  GameSettings.Set(var, val)
  ConfirmChanges()
end

local settingPreset = false

local presetQueue = {}

function GraphicsQuality.EnsurePreset()
  if #presetQueue == 0 then
    return
  end

  if App.isOverlayOpen then
    App.shouldCloseOverlay = true
    return
  end

  App.shouldCloseOverlay = false

  if settingPreset then
    return
  end

  local preset = presetQueue[#presetQueue]

  for k,v in pairs(presetQueue) do presetQueue[k]=nil end

  if preset then
    settingPreset = true
    preset()
  end
end
function GraphicsQuality.SetPreset(preset, presetName, delay)
  table.insert(presetQueue, function()
    GraphicsQuality._SetPreset(preset, presetName, 0, function ()
      settingPreset = false
    end)
  end)
end

function GraphicsQuality._SetPreset(preset, presetName, delay, cb)
  if delay == nil then
    delay = 0
  end

  local function setPreset()
    if preset == 0 then
      return Helpers.PrintMsg("Couldn't set preset since it doesn't exist. Was it initialized properly?")
    end

    if presetName == "photo" then
      for _ ,presetSettings in pairs(preset) do
        -- -- DOF should always be enabled for the photomode otherwise it breaks
        -- if presetSettings.var == "/graphics/basic/DepthOfField" then
        --   presetSettings.value = true
        -- end

        if presetSettings.var == "/graphics/advanced/DistantShadowsResolution" then
          presetSettings.value = GameSettings.Get("/graphics/advanced/DistantShadowsResolution")
        end
      end
    end

    function EnsureDlssd()
      for _,k in pairs(preset) do
        if k.var ==  "/graphics/dlss/DLSS_D" then
          GameSettings.Set(k.var, k.value)
        end
      end
    end
    
    if IsCurrentPreset(preset) then
      Helpers.PrintDebugMsg("skipping the same preset")
      settingPreset = false
      return
    end

    for _,k in pairs(preset) do
      GameSettings.Set(k.var, k.value)
      -- end
    end

    EnsureDlssd()

    ConfirmChanges(function()
      Cron.NextTick(function ()
        EnsureDlssd()
        Cron.NextTick(function ()
          EnsureDlssd()
          cb()
        end, {})
      end, {})
    end)

    App.currentPreset = presetName
  end

  if delay == 0 then
    setPreset()
  else
    Cron.After(delay, setPreset, {})
  end

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
      Helpers.PrintMsg("couldn't get value for " .. k.var)
    end
  end

  return list
end

return GraphicsQuality
