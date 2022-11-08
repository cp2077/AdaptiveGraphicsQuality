local Helpers = require("Modules/Helpers")
local Settings = require("Modules/Settings")
GameSettings = require("Modules/GameSettings")

local Config = {
  inner = {
    isStealthACombat = false,
    isRestrictedAreaACombat = false,
    isDangerousAreaACombat = true,
    isDebug = false,
    switchToNormalWhenDisabled = false,
    disableAutoswitchOnHotkey = false,
    presets = {
      normal = 0,
      menu = 0,
      photo = 0,
      combat = 0,
      vehicle = 0,
      scene = 0,
    },
    enabled = {
      normal = true,
      combat = true,
      photo = true,
      menu = false,
      vehicle = false,
      scene = false,
    },
    tweaks = { },
    notifications = {
      lastVersionNotice = nil
    }
  },
  isReady = false,
}

function Config.InitConfig()
  local config = ReadConfig()
  if config == nil then
    WriteConfig()
  else
    Config.inner = config
  end

  Migrate()
  Config.isReady = true
end

function Config.SaveConfig()
  WriteConfig()
end

function Config.Migrate()
  return Migrate()
end

function Migrate()
  if Config.inner.disableAutoswitchOnHotkey == nil then
    Config.inner.disableAutoswitchOnHotkey = false
  end

  for presetName, currPreset in pairs(Config.inner.presets) do
    local rm = {}
    if Config.inner.presets[presetName] == 0 then
      break
    end
    for i, currPresetSetting in pairs(Config.inner.presets[presetName]) do
      -- if "var" already exists in the config, skip it.
      if not GameSettings.Has(currPresetSetting.var)
          or currPresetSetting.var == "/graphics/dynamicresolution/StaticResolutionScaling"
          or currPresetSetting.var == "/graphics/dynamicresolution/DynamicResolutionScaling"
          or currPresetSetting.var == "/graphics/dynamicresolution/DRS_TargetFPS"
          or currPresetSetting.var == "/graphics/dynamicresolution/DRS_MinimalResolution"
          or currPresetSetting.var == "/graphics/dynamicresolution/DRS_MaximalResolution" then
        rm[i] = true
      end
    end

    for i=#Config.inner.presets[presetName],1,-1 do
      if rm[i] then
        table.remove(Config.inner.presets[presetName], i)
      end
    end

    -- for _, id in pairs(rm) do
    --   table.remove(Config.inner.presets[presetName], id)
    -- end
  end

  local defaultSettings = GraphicsQuality.GetCurrentPreset()
  for _, currSetting in pairs(Settings.list) do
    for presetName, currPreset in pairs(Config.inner.presets) do
      if currPreset == 0 then
        break
      end

      local exists = false
      for _, currPresetSetting in pairs(currPreset) do
        -- if "var" already exists in the config, skip it.
        if currPresetSetting.var == currSetting.var then
          exists = true
          break
        end
      end

      if not exists then
        local currValue = nil
        for _, currDefaultSetting in pairs(defaultSettings) do
          if currDefaultSetting.var == currSetting.var then
            currValue = currDefaultSetting.value
          end
        end

        if currValue == nil then
          break
        end


        table.insert(currPreset, {
          var = currSetting.var,
          kind = currSetting.kind,
          value = currValue
        })
      end

    end
  end

  -- sort presets
  for presetName, currPreset in pairs(Config.inner.presets) do
    if Config.inner.presets[presetName] == 0 then
      break
    end
    table.sort(Config.inner.presets[presetName], function (a, b)
      aDisplay = string.find(a.var, "display")
      bDisplay = string.find(b.var, "display")

      aDynamicres = string.find(a.var, "dynamicresolution")
      bDynamicres = string.find(b.var, "dynamicresolution")

      araytracing = string.find(a.var, "raytracing")
      braytracing = string.find(b.var, "raytracing")

      aperformance = string.find(a.var, "performance")
      bperformance = string.find(b.var, "performance")

      abasic = string.find(a.var, "basic")
      bbasic = string.find(b.var, "basic")

      if aDisplay or bDisplay then
        if aDisplay ~= bDisplay then
          return aDisplay and not bDisplay
        else
          if string.find(a.var, "VSync") then
            return false
          end
          if string.find(b.var, "VSync") then
            return true
          end
          if string.find(a.var, "FPS") then
            return false
          end
          if string.find(b.var, "FPS") then
            return true
          end
        end
      end

      if aDynamicres or bDynamicres then
        if aDynamicres ~= bDynamicres then
          return aDynamicres and not bDynamicres
        end
      end

      adlss = string.find(a.var, "DLSS")
      bdlss = string.find(b.var, "DLSS")

      afsr = string.find(a.var, "FSR2")
      bfsr = string.find(b.var, "FSR2")

      adrs = string.find(a.var, "DynamicResolutionScaling")
      bdrs = string.find(b.var, "DynamicResolutionScaling")

      if adlss or bdlss then
        if adlss ~= bdlss then
          return adlss and not bdlss
        end
      end

      if afsr or bfsr then
        if afsr ~= bfsr then
          return afsr and not bfsr
        end
      end

      if adrs or bdrs then
        if adrs ~= bdrs then
          return adrs and not bdrs
        end
      end

      if araytracing or braytracing then
        if araytracing ~= braytracing then
          return araytracing and not braytracing
        end
      end

      if aperformance or bperformance then
        if aperformance ~= bperformance then
          return not aperformance and bperformance
        end
      end

      -- if abasic or bbasic then
      --   if abasic ~= bbasic then
      --     return abasic and bbasic
      --   end
      -- end

      return a.var < b.var
    end)
  end

  -- ...
  WriteConfig()
end

function WriteConfig()
  local sessionPath = Vars.CONFIG_FILE_NAME
  local sessionFile = io.open(sessionPath, 'w')

  if not sessionFile then
    Helpers.RaiseError(('Cannot write config file %q.'):format(sessionPath))
  end

  sessionFile:write(json.encode(Config.inner))
  sessionFile:close()
end

local function readFile(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

function ReadConfig()
  local configPath = Vars.CONFIG_FILE_NAME

  local configStr = readFile(configPath)

  local ok, res = pcall(function() return json.decode(configStr) end)
  if not ok then
    return
  end

  return res
end


return Config
