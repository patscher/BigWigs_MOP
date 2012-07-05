
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Blade Lord Ta'yak", 897, 744)
if not mod then return end
mod:RegisterEnableMob(744)



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
		{122994, "FLASHSHAKE", "WHISPER" }, {123175, "FLASHSHAKE", "WHISPER" } , "berserk", "bosskill",
	}, {
		berserk = "general",
		
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "UnseenStrike", 122994)
	self:Log("SPELL_AURA_APPLIED", "WindStep", 123175)

	
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	
	self:Death("Win", 0)
end


function mod:UnseenStrike(player, spellId, _, _, spellName)
	if not UnitIsPlayer(player) then return end --Affects the NPC and a player
	self:TargetMessage(122994, spellName, player, "Attention", spellId, "Alarm")
	if UnitIsUnit("player", player) then
		self:FlashShake(122994)
		self:Whisper(122994, player, CL["you"]:format(spellName))
	end
end
	
function mod:WindStep(player, spellId, _, _, spellName)
	if not UnitIsPlayer(player) then return end --Affects the NPC and a player
	self:TargetMessage(123175, spellName, player, "Attention", spellId, "Alarm")
	if UnitIsUnit("player", player) then
		self:FlashShake(123175)
		self:Whisper(123175, player, CL["you"]:format(spellName))
	end
end	
		
	

function mod:OnEngage(diff)

	self:Berserk(360) -- assume

end

--------------------------------------------------------------------------------
-- Event Handlers
--