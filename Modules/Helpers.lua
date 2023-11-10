local Helpers = {}
local Config = require("Modules/Config")

function Helpers.PrintMsg(msg)
  print('[AdaptiveGraphicsQuality]', msg)
end

function Helpers.PrintDebugMsg(msg)
  if Config.inner.isDebug then
    print('[AdaptiveGraphicsQuality:DEBUG]', msg)
  end
end

function Helpers.RaiseError(msg)
  print('[AdaptiveGraphicsQuality]', msg)
  error(msg, 2)
end

function Helpers.HasWeapon()
  local player = Game.GetPlayer()
  if player then
    local ts = Game.GetTransactionSystem()
    return ts and ts:GetItemInSlot(player, TweakDBID.new("AttachmentSlots.WeaponRight")) ~= nil
  end
  return false
end

function GetPlayerBlackboardDefsAndBlackboardSystemIfAll()
  local player = Game.GetPlayer()
  if player then
      local blackboardDefs = Game.GetAllBlackboardDefs()
      if blackboardDefs then
          local blackboardSystem = Game.GetBlackboardSystem()
          if blackboardSystem then
              return player, blackboardDefs, blackboardSystem
          end
      end
  end
end

function Helpers.IsInWorkspot()
  return Game.GetWorkspotSystem():IsActorInWorkspot(Game.GetPlayer())
end

function Helpers.GrappleState()
  local player, blackboardDefs, blackboardSystem = GetPlayerBlackboardDefsAndBlackboardSystemIfAll()
  if player then
      local blackboardPSM = blackboardSystem:GetLocalInstanced(player:GetEntityID(), blackboardDefs.PlayerStateMachine)
      return blackboardPSM:GetInt(blackboardDefs.PlayerStateMachine.Takedown)
  end
  return 0
end

function Helpers.highestHostileDetection()
  local player, blackboardDefs, blackboardSystem = GetPlayerBlackboardDefsAndBlackboardSystemIfAll()
  if player then
      local blackboardPSM = blackboardSystem:GetLocalInstanced(player:GetEntityID(), blackboardDefs.PlayerStateMachine)
      return blackboardPSM:GetFloat(Game.GetAllBlackboardDefs().UI_Stealth.highestHostileDetectionOnPlayer)
  end
  return 0
end

-- NotInBaseLocomotion = 0
-- Stand = 1
-- AimWalk = 2
-- Crouch = 3
-- Sprint = 4
-- Slide = 5
-- SlideFall = 6
-- Dodge = 7
-- Climb = 8
-- Vault = 9
-- Ladder = 10
-- LadderSprint = 11
-- LadderSlide = 12
-- LadderJump = 13
-- Fall = 14
-- AirThrusters = 15
-- AirHover = 16
-- SuperheroFall = 17
-- Jump = 18
-- DoubleJump = 19
-- ChargeJump = 20
-- HoverJump = 21
-- DodgeAir = 22
-- RegularLand = 23
-- HardLand = 24
-- VeryHardLand = 25
-- DeathLand = 26
-- SuperheroLand = 27
-- SuperheroLandRecovery = 28
-- Knockdown = 29
-- CrouchSprint = 30
-- Felled = 31
function Helpers.LocomotionState()
  local player, blackboardDefs, blackboardSystem = GetPlayerBlackboardDefsAndBlackboardSystemIfAll()
  if player then
      local blackboardPSM = blackboardSystem:GetLocalInstanced(player:GetEntityID(), blackboardDefs.PlayerStateMachine)
      return blackboardPSM:GetInt(blackboardDefs.PlayerStateMachine.LocomotionDetailed)
  end
  return 0
end

function Helpers.CombatGadgetState()
  local player, blackboardDefs, blackboardSystem = GetPlayerBlackboardDefsAndBlackboardSystemIfAll()
  if player then
      local blackboardPSM = blackboardSystem:GetLocalInstanced(player:GetEntityID(), blackboardDefs.PlayerStateMachine)
      return blackboardPSM:GetInt(blackboardDefs.PlayerStateMachine.CombatGadget)
  end
  return 0
end

-- Default = 0
-- InCombat = 1
-- OutOfCombat = 2
-- Stealth = 3
---@return "Default"|"InCombat"|"OutOfCombat"|"Stealth"
function Helpers.CombatState()
  local player = Game.GetPlayer()
  if player then
    return player:GetCurrentCombatState().value
  end
end

---@return "Undefined"|"PublicZone"|"SafeZone"|"RestrictedZone"|"DangerousZone"
function Helpers.SecurityZone()
  local player = Game.GetPlayer()
  if player then
    return player:GetCurrentSecurityZoneType(player).value
  end
end

return Helpers
