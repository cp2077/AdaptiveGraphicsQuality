Cron = require("Modules/Cron")
local GameSession = require("Modules/GameSession")
Vars = require("Modules/Vars")
GraphicsQuality = require("Modules/GraphicsQuality")
Config = require("Modules/Config")
local GameUI = require("Modules/GameUI")
Helpers = require("Modules/Helpers")
Tweaks = require("Modules/Tweaks")
local Window = require("Modules/Window")

App = { ["version"] = "1.5.1" }
local isLoaded = false
App.inited = false
App.isOverlayOpen = false
App.isEnabled = true
App.currentPreset = ""
App.shouldCloseOverlay = false

App.menuState = nil

Errors = {
  SETTINGS_APPLY = false,
}
App.States = {
  isCombat = false,
  isVehicle = false
}

local API = {}

function API.Enable()
  App.isEnabled = true
end

function API.Disable()
  App.isEnabled = false
end

function API.DisableAndSetToNormal()
  App.isEnabled = false
  GraphicsQuality.RequestPreset(Config.inner.presets.normal, "normal")
end

function API.IsEnabled()
  return App.isEnabled
end

function IsCombat()
  return App.States.isCombat
end
function IsVehicle()
  return App.States.isVehicle
end
function IsPhotomode()
  return GameUI.IsPhoto()
end
function IsMenu()
  return GameUI.GetMenu() == "NewGame" or GameUI.GetMenu() == "Hub"
end
function IsScene()
  return GameUI.IsScene()
end

local function initTweaks()
  for _,tweakOption in pairs(Tweaks.list) do
    local curValue = GameOptions.Get(tweakOption.var, tweakOption.key)
    local savedValue = Config.inner.tweaks[tweakOption.var..tweakOption.key]
    if savedValue and savedValue.value ~= nil then
      if tweakOption.kind == "bool" then
        GameOptions.SetBool(tweakOption.var, tweakOption.key, savedValue.value)
      elseif tweakOption.kind == "float" then
        GameOptions.SetFloat(tweakOption.var, tweakOption.key, savedValue.value)
      elseif tweakOption.kind == "int" then
        GameOptions.SetInt(tweakOption.var, tweakOption.key, savedValue.value)
      end
    else
      -- Config.inner.tweaks[tweakOption.var..tweakOption.key] = { value = nil, _ = 0 }
    end
    --
  end
end

local function assertDefaultPresetsExist()
  local defaultPreset = GraphicsQuality.GetCurrentPreset()
  local changed = false
  for presetName, value in pairs(Config.inner.presets) do
    if value == 0 then
      changed = true
      -- clone the list

      Config.inner.presets[presetName] = json.decode(json.encode(defaultPreset))

      -- Default photomode's DOF option to true in order to not break it.
      if presetName == "photo" then
        for _, presetSettings in pairs(Config.inner.presets[presetName]) do
          if presetSettings.var == "/graphics/basic/DepthOfField" then
            presetSettings.value = true
            break
          end
        end
      end
    end
  end

  if changed then
    Config.SaveConfig()
  end
end

function IsCurrentPreset(preset)
  local currentPreset = GraphicsQuality.GetCurrentPreset()

  for _,currentPresetSettings in pairs(currentPreset) do
    for _,presetSettings in pairs(preset) do
      if not presetSettings.ignore then
        if presetSettings.var == currentPresetSettings.var and (presetSettings.value ~= currentPresetSettings.value) then
          return false
        end
      end
    end
  end

  return true
end
function HasMountedVehicle()
  return not not Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
end
function IsEnteringVehicle()
  return IsInVehicle() and Game.GetWorkspotSystem():GetExtendedInfo(Game.GetPlayer()).entering
end
function IsExitingVehicle()
  return IsInVehicle() and Game.GetWorkspotSystem():GetExtendedInfo(Game.GetPlayer()).exiting
end
function IsInVehicle()
  local ws = Game.GetWorkspotSystem()
  local player = Game.GetPlayer()
  if ws and player then
    local info = ws:GetExtendedInfo(player)
    if info then
      return ws:IsActorInWorkspot(player)
        and info.isActive
        and HasMountedVehicle()
    end
  end
end

function SetPresetIfNeeded()
  if not App.isEnabled then
    if Config.inner.switchToNormalWhenDisabled then
      GraphicsQuality.RequestPreset(Config.inner.presets.normal, "normal")
    end
    return
  end
  local delay = 0.1

  if IsPhotomode() and Config.inner.enabled.photo then
    delay = 0.8
    GraphicsQuality.RequestPreset(Config.inner.presets.photo, "photo", delay)
  elseif IsMenu() and Config.inner.enabled.menu then
    GraphicsQuality.RequestPreset(Config.inner.presets.menu, "menu", delay)
  elseif IsCombat() and Config.inner.enabled.combat then
    delay = 0
    GraphicsQuality.RequestPreset(Config.inner.presets.combat, "combat", delay)
  elseif IsVehicle() and Config.inner.enabled.vehicle then
    GraphicsQuality.RequestPreset(Config.inner.presets.vehicle, "vehicle", delay)
  elseif IsScene() and Config.inner.enabled.scene then
    GraphicsQuality.RequestPreset(Config.inner.presets.scene, "scene", delay)
  else
    if App.currentPreset == "combat" then
      delay = 0.8
    end

    GraphicsQuality.RequestPreset(Config.inner.presets.normal, "normal", delay)
  end
end


function App.new()
  -- registerForEvent('onTweak', function()
  --   print(123)
  --   TweakDB:SetFlat('PreventionSystem.setup.totalEntitiesLimit', 20)
  --   local lookAtPreset = TweakDB:GetFlat('PhotoModePoses.idle__katana.lookAtPreset')
  --   TweakDB:SetFlat('PhotoModePoses.idle_squat.lookAtPreset', lookAtPreset)
  --   print(TweakDB:GetFlat("PhotoModePoses.idle_squat.disableLookAtForGarmentTags")[1])
  -- end)


  local deltaAccum = 0
  registerForEvent("onDraw", function(delta)
    if not App.inited or not App.isOverlayOpen then
      return
    end

    Window.Draw(Config.isReady)
  end)

  local checkEvery = Vars.CHECK_COMBAR_EVERY_MS / 1000

  -- Cron.Every(0.2, GraphicsQuality.EnsurePreset, {})

  local hadWeapon = false

  registerForEvent("onUpdate", function(delta)
    if not App.inited or not Config.isReady then
      return
    end

    
    Cron.Update(delta)
    
    if not GameUI.IsMainMenu() and (GameUI.IsMenu() or GameUI.IsLoading()) then
      return
    end

    GraphicsQuality.EnsurePreset()

    if not isLoaded then
      return
    end

    deltaAccum = deltaAccum + delta
    -- do stuff every N seconds
    if deltaAccum > checkEvery then
      -- print(Helpers.highestHostileDetection())
      deltaAccum = 0

      CheckCombat()
      CheckVehicle()
    end
  end)

  local lastIsInCombat = false
  local lastInVehiceState = false
  local lastUnholstered = false
  local ignoreForThisLocomotion = false
  local lastLocomotion = 0

  local upperBodyState = 0

  function CheckCombat()
    local combatState = Helpers.CombatState()
    local securityZone = Helpers.SecurityZone()

    local unholstered = Config.inner.combatUnholstered and (Helpers.HasWeapon())

    local isInCombat =
      combatState == "InCombat" or
      (unholstered and (not IsInVehicle() or Config.inner.combatUnholsteredVehicle)) or
      (Config.inner.isDangerousAreaACombat and securityZone == "DangerousZone") or
      (Config.inner.isRestrictedAreaACombat and securityZone == "RestrictedZone")

      -- print(isInCombat)


    local hasCombatStateChanged = lastIsInCombat ~= isInCombat
    local unholsteredChanged = lastUnholstered ~= unholstered
    local locomotionState = Helpers.LocomotionState()


    -- print(Game.GetWorkspotSystem():IsActorInWorkspot(Game.GetPlayer()))

    -- if one of the potentially temporary locomotions
    -- 8     - Climb
    -- 10-13 - Ladder
    local isTempLocomotion = Config.inner.combatUnholstered 
      and (locomotionState == 8 
        or (locomotionState >= 10 and locomotionState <= 13)
        or locomotionState == 14
        or locomotionState == 17
        or locomotionState == 23
        or locomotionState == 24
        or locomotionState == 25
        or locomotionState == 26
        or locomotionState == 27
        or locomotionState == 28
        or locomotionState == 29
        or locomotionState == 31
        or upperBodyState == 4
        or (Helpers.IsInWorkspot() and not IsInVehicle() and not GameUI.IsVehicle())
        or Helpers.GrappleState() > 0
      )
    if not isTempLocomotion and ignoreForThisLocomotion then
      ignoreForThisLocomotion = false
    end

    if Config.inner.combatUnholstered then
      ignoreForThisLocomotion = false
    end
    
    if hasCombatStateChanged then
      if isInCombat then
        OnCombatEnter()
      else
        -- if holstered a gun
        if unholsteredChanged and not unholstered and Config.inner.combatUnholstered then
          -- if one of the temporary locomotions, then ignore the combat state change
          if isTempLocomotion then
            ignoreForThisLocomotion = true
          end
        end

        if not ignoreForThisLocomotion then
          OnCombatExit()
        end
      end
    end

    lastUnholstered = unholstered
    lastLocomotion = locomotionState

    lastIsInCombat = isInCombat
  end

  function CheckVehicle()
    local isInVehicle = IsInVehicle()
    local hasInVehicleChanged = lastInVehiceState ~= isInVehicle

    if hasInVehicleChanged then
      if isInVehicle then
        OnVehicleEnter()
      else
        OnVehicleExit()
      end
    end

    lastInVehiceState = isInVehicle
  end

  function OnPhotomodeEnter()
    isLoaded = true
    if Config.inner.enabled.photo then
      SetPresetIfNeeded()
    end
  end

  function OnPhotomodeExit()
    isLoaded = true
    if Config.inner.enabled.photo then
      SetPresetIfNeeded()
    end
  end

  function OnVehicleEnter()
    isLoaded = true
    App.States.isVehicle = true

    if Config.inner.enabled.vehicle then
      SetPresetIfNeeded()
    end
  end
  function OnVehicleExit()
    App.States.isVehicle = false
    if Config.inner.enabled.vehicle then
      SetPresetIfNeeded()
    end
  end

  function OnCombatEnter()
    isLoaded = true
    App.States.isCombat = true
    if Config.inner.enabled.combat then
      SetPresetIfNeeded()
    end
  end
  function OnCombatExit()
    App.States.isCombat = false
    if Config.inner.enabled.combat then
      SetPresetIfNeeded()
    end
  end

  function OnMenuEnter()
    if Config.inner.enabled.menu then
      SetPresetIfNeeded()
    end
  end
  function OnMenuExit()
    if Config.inner.enabled.menu then
      SetPresetIfNeeded()
    end
  end

  function OnSceneEnter()
    if Config.inner.enabled.scene then
      SetPresetIfNeeded()
    end
  end
  function OnSceneExit()
    if Config.inner.enabled.scene then
      SetPresetIfNeeded()
    end
  end
  registerForEvent("onShutdown", function()
    GraphicsQuality.RequestPreset(Config.inner.presets.normal, "normal")
  end)
  registerForEvent("onOverlayOpen", function ()
    App.isOverlayOpen = true
  end)
  registerForEvent("onOverlayClose", function ()
    App.isOverlayOpen = false
  end)
  registerForEvent("onInit", function ()
    Config.InitConfig()
    App.isEnabled = Config.inner.enabledOnStart
    if App.isEnabled then
      App.currentPreset = "normal"
    end
    assertDefaultPresetsExist()

    -- temp sorting fix
    Config.InitConfig()

    initTweaks()

    GameSession.OnStart(function()
      Helpers.PrintDebugMsg("Game session has been started")
      isLoaded = true
    end)

    GameSession.OnEnd(function()
      Helpers.PrintDebugMsg("Game session has been ended")
      isLoaded = false
    end)

    GameSession.OnResume(function()
      Helpers.PrintDebugMsg("Game has been unpaused")
      isLoaded = true
    end)

    GameSession.OnPause(function()
      Helpers.PrintDebugMsg("Game has been paused")
      isLoaded = false
    end)

    GameUI.Observe(GameUI.Event.MenuNav, SetPresetIfNeeded)

    GameUI.OnPhotoModeOpen(OnPhotomodeEnter)
    GameUI.OnPhotoModeClose(OnPhotomodeExit)

    GameUI.OnMenuOpen(OnMenuEnter)
    GameUI.OnMenuClose(OnMenuExit)

    GameUI.OnVehicleEnter(OnVehicleEnter)
    GameUI.OnVehicleExit(OnVehicleExit)

    GameUI.OnSceneEnter(OnSceneEnter)
    GameUI.OnSceneExit(OnSceneExit)


    -- Observe('RadialWheelController', 'RegisterBlackboards', function(_, loaded)
    --   isLoaded = loaded
    -- end)
    
    Observe('WeaponRosterGameController', 'OnWeaponDataChanged', function (_, state)
      if Config.inner.combatUnholstered then
        if ItemID.IsValid(FromVariant(state).weapon.weaponID) then
          OnCombatEnter()
        else
          CheckCombat()
        end
      end
    end)

    Observe('PlayerPuppet', 'OnGameAttached', function(self, b)
      self:RegisterInputListener(self, "OpenInventoryMenu")
    end)

    -- Observe('PlayerPuppet', 'OnCombatGadgetStateChanged', function(self, newState)
    --   print("combatStateChanged", newState)
    --   CheckCombat()
    -- end)

    Observe('PlayerPuppet', 'OnUpperBodyStateChange', function(self, newState)
      upperBodyState = newState
    end)

    Observe("PlayerPuppet", "OnAction", function(_, action)
      local ListenerAction = GetSingleton('gameinputScriptListenerAction')
      local actionName = Game.NameToString(ListenerAction:GetName(action))
      -- if you open inventory without going into HUB menu first, settings are not applied for some reason.
      if actionName == "OpenInventoryMenu" then
        if Config.inner.enabled.menu then
          GraphicsQuality.RequestPreset(Config.inner.presets.menu, "menu")
        end
      end
    end)
    -- Observe("PlayerPuppet", "OnEnterUndefinedZone", function() end)
    -- Observe("PlayerPuppet", "OnEnterPublicZone", function() end)
    -- Observe("PlayerPuppet", "OnExitPublicZone", function() end)
    -- Observe("PlayerPuppet", "OnEnterSafeZone", function() end)
    -- Observe("PlayerPuppet", "OnExitSafeZone", function() end)
    -- Observe("PlayerPuppet", "OnEnterRestrictedZone", function() end)
    -- Observe("PlayerPuppet", "OnEnterDangerousZone", function() end)
    App.inited = true
  end)

  registerHotkey("agq_toggle_enabled", "Toggle enabled", function()
    App.isEnabled = not App.isEnabled
  end)
  registerHotkey("agq_toggle_force_normal", 'Force "Normal" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.normal, "normal")
  end)
  registerHotkey("agq_toggle_force_photomode", 'Force "Photomode" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.photo, "photo", 0)
  end)
  registerHotkey("agq_toggle_force_menu", 'Force "Menu" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.menu, "menu")
  end)
  registerHotkey("agq_toggle_force_combat", 'Force "Combat" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.combat, "combat")
  end)
  registerHotkey("agq_toggle_force_vehicle", 'Force "Vehicle" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.vehicle, "vehicle")
  end)
  registerHotkey("agq_toggle_force_scene", 'Force "Scene" preset', function()
    if Config.inner.disableAutoswitchOnHotkey then
      App.isEnabled = false
    end
    GraphicsQuality.RequestPreset(Config.inner.presets.scene, "scene")
  end)
  
  for var=1,10 do
    registerHotkey("agq_force_custom_" .. var, "Force custom preset #" .. tostring(var), function()
      if Config.inner.disableAutoswitchOnHotkey then
        App.isEnabled = false
      end
      GraphicsQuality.RequestPreset(Config.inner.presets[tostring(var)], tostring(var))
    end)
  end

  return {
    version = App.version,
    api = API,
    GameSettings = GameSettings,
  }
end

return App.new()
