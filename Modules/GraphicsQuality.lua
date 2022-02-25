local GraphicsQuality = {}

local Settings = require("Modules/Settings")
local GameSettings = require("Modules/GameSettings")
local Helpers = require("Modules/Helpers")
local Cron = require("Modules/Cron")

function ConfirmChanges()
  Cron.Every(0.1, function (timer)
    if App.isOverlayOpen then
      App.shouldCloseOverlay = true
    else
      App.shouldCloseOverlay = false
      timer:Halt()
      Cron.NextTick(function()
        GameSettings.Confirm()
        GameSettings.Save()
      end)
    end
  end)

  return true
end

function GraphicsQuality.SetSettings(var, val)
  GameSettings.Set(var, val)
  ConfirmChanges()
end

function GraphicsQuality.SetPreset(preset, presetName, delay)
  if delay == nil then
    delay = 0
  end

  Cron.After(delay, function()
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

    if IsCurrentPreset(preset) then
      Helpers.PrintDebugMsg("skipping the same preset")
      return
    end


    for _,k in pairs(preset) do
      -- if k.var ~=  "/graphics/dynamicresolution/DLSS"
      --    and k.var ~=  "/graphics/dynamicresolution/FSR"
      --    and k.var ~=  "/graphics/dynamicresolution/DynamicResolutionScaling"
      --    and k.var ~=  "/video/display/Resolution" then
      GameSettings.Set(k.var, k.value)
      -- end
    end

    -- -- DOF should always be enabled for the photomode otherwise it breaks
    -- if presetName == "photo" then
    --   GameSettings.Set("/graphics/basic/DepthOfField", true)
    -- end

    ConfirmChanges()
    -- if ConfirmChanges() then
    --   Helpers.PrintDebugMsg(tostring(presetName).. " preset has been applied")
    -- end

    App.currentPreset = presetName
  end)
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
