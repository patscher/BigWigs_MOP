
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Imperial Vizier Zor'lok", 897, 745)
if not mod then return end
mod:RegisterEnableMob(0)


-- Locals
--
local playerTbl = mod:NewTargetList()

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
		{122994, "FLASHSHAKE"}, "berserk", "bosskill",
	}, {
		berserk = "general",
		
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "UnseenStrike", 122994)	

	
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	
	self:Death("Win", 0)
end

do
	local scheduled = nil
	local function Unseen(spellName)
		mod:TargetMessage(1122994, spellName, playerTbl, "Important", 122994)
		scheduled = nil
	end
end

function mod:OnEngage(diff)

	self:Berserk(360) -- assume

end

--------------------------------------------------------------------------------
-- Event Handlers
--


