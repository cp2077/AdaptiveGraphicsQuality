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
