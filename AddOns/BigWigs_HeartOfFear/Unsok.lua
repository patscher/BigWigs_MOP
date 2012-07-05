
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Amber-Shaper Un'sok", 897, 737)
if not mod then return end
mod:RegisterEnableMob(0)


--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then

end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"berserk", "bosskill",
	}, {
		berserk = "general",
	}
end

function mod:OnBossEnable()

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 0)
end

function mod:OnEngage(diff)

	self:Berserk(360) -- assume

end

--------------------------------------------------------------------------------
-- Event Handlers
--


