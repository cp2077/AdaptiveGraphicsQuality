local GraphicsQuality = {}

local Settings = require("Modules/Settings")
local GameSettings = require("Modules/GameSettings")
local Helpers = require("Modules/Helpers")
local Cron = require("Modules/Cron")
local GameHUD = require("Modules/GameHUD")

function ConfirmChanges(callback)
  GameSettings.Save()
  if GameSettings.NeedsConfirmation() then
    GameSettings.Confirm()
  end

  if callback then
    callback()
  end

  return true
end

function GraphicsQuality.SetSettings(var, val)
  GameSettings.Set(var, val)
  ConfirmChanges()
end

local isApplyingPreset = false

local presetQueue = {}
-- apply the last preset in the preset queue
function GraphicsQuality.EnsurePreset()
  if #presetQueue == 0 then
    return
  end

  local preset = presetQueue[#presetQueue]

  if App.isOverlayOpen then
    App.shouldCloseOverlay = true
    return
  end

  App.shouldCloseOverlay = false

  if isApplyingPreset then
    return
  end


  for k,v in pairs(presetQueue) do presetQueue[k]=nil end

  if preset then
    isApplyingPreset = true
    preset()
  end
end

-- add preset to the preset queue
function GraphicsQuality.RequestPreset(preset, presetName, delay)
  table.insert(presetQueue, function()
    local lastPreset = App.currentPreset
    GraphicsQuality.ApplyPreset(preset, presetName, delay, function ()
      isApplyingPreset = false
      App.currentPreset = presetName
      if lastPreset  ~= App.currentPreset then
        -- GameHUD.ShowMessage('AGQ: "' .. App.currentPreset .. '" preset activated', 1.5)
      end
    end)
  end)
end

function GraphicsQuality.ApplyPreset(preset, presetName, delay, cb)
  if delay == nil then
    delay = 0
  end

  local function setPreset()
    -- early quit if has new presets to apply - we always apply the last one
    -- we do this here because i'm an idiot and this code is garbage
    if #presetQueue > 0 then
      return cb()
    end

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

    local wasDlssdEnabled = GameSettings.Get("/graphics/presets/DLSS_D") == true

    -- When DLSS and PathTracing are on, the game will always activate DLSSD,
    -- so we have to reapply it several times.
    function EnsureDlssd()
      for _,k in pairs(preset) do
        if k.var ==  "/graphics/presets/DLSS_D" then
          if tostring(GameSettings.Get(k.var)) ~= tostring(k.value) then
            -- if not ignored value - set to whatever it is.
            -- otherwise - check if current value is false to reapply it.
            if not k.ignore then
              Helpers.PrintDebugMsg(k.var .. " was set to " .. tostring(k.value))
              GameSettings.Set(k.var, k.value)
            else
              if not wasDlssdEnabled then
                Helpers.PrintDebugMsg(k.var .. " was set to " .. tostring(k.value))
                GameSettings.Set(k.var, k.value)
              end
            end
          end
        end
      end
    end
    
    if IsCurrentPreset(preset) then
      Helpers.PrintDebugMsg("skipping the same preset")
      isApplyingPreset = false
      App.currentPreset = presetName
      return cb()
    end

    for _,k in pairs(preset) do
      if tostring(GameSettings.Get(k.var)) ~= tostring(k.value) then
        if not k.ignore then
          Helpers.PrintDebugMsg(k.var .. " was set to " .. tostring(k.value))
          GameSettings.Set(k.var, k.value)
        end
      end
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
      if not opt then
        print(k.var)
      end
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
