local Helpers = require("Modules/Helpers")
local Vars = require("Modules/Vars")

local Config = {
  inner = {
    isStealthACombat = true,
    isRestrictedAreaACombat = true,
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

function Migrate()

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
