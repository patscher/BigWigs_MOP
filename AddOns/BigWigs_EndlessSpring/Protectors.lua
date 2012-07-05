
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Protectors of the Endless", 886, 683)
if not mod then return end
mod:RegisterEnableMob(60583, 60585, 60586)


--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then

L.shadows = "Touch of Sha on %1$s"
L.defiledground_message_self = "Defiled Ground under YOU!"
L.storm_him = "Storm 10 Yard!"
L.storm_20 = "Storm 20 Yard!"
L.storm_40 = "Storm 40 Yard!"
L.storm_60 = "Storm 60 Yard!"
L.storm_80 = "Storm 80 Yard!"
L.cooldown_Water = "Cleansing Water CD"
L.water_soon = "Cleansing Water Spawning"
L.water_spawned = "Globe spawned!"
L.cooldown_CorruptedWater = "Corrupted Water CD"
L.Corruptedwater_soon = "Corrupted Water Spawning"
L.Corruptedwater_spawned = "Corrupted Globe spawned! SWITCH TARGET!!!"

end
L = mod:GetLocale()

-----------------------------------------------------------------------------------------
-- Locals
local playerTbl = mod:NewTargetList()
local canEnable = true

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		 {117519, "FLASHSHAKE", "SAY"}, {117988, "WHISPER", "FLASHSHAKE", "SAY"} , 117975 , {117436, "SAY", "PROXIMITY"} , 118077, 117351, 117309, 117227,
		"berserk", "bosskill", 
	}, {
		[117519] = "ej:5789",
		[117436] = "ej:5793",
		[117309] = "ej:5794",
		berserk = "general",
	}
end

function mod:VerifyEnable()
	return canEnable
end

function mod:OnBossEnable()
	-- Protector Kaolan 
	self:Log("SPELL_AURA_APPLIED", "TouchApplied", 117519, 117510)				-- Touch of Sha warning for the Healers
	self:Log("SPELL_CAST_SUCCESS", "TouchCast",	 117519, 117510)				
	self:Log("SPELL_CAST_SUCCESS", "DefiledGroundCast", 117989, 117988, 118091, 117986)	
	self:Log("SPELL_AURA_APPLIED", "DefiledGround", 117989, 117988, 118091, 117986)		-- Defiled Ground under you!
	self:Log("SPELL_CAST_SUCCESS", "ExpelCorruption", 117975)						-- explosion from Boss
	
	-- Elder Regail 
	self:Log("SPELL_CAST_START", "LightningPrisonStart", 122874, 117398, 117436) -- Lightning Prison 2,5 Sec Cast
	self:Log("SPELL_AURA_APPLIED", "LightningPrisonApplied", 122874, 117398, 117436)
	self:Log("SPELL_AURA_REMOVED", "LightningPrisonRemoved", 122874, 117398, 117436)
	-- Storm
	self:Log("SPELL_CAST_START", "LightningStormStart", 118077) -- at himself
	self:Log("SPELL_CAST_SUCCESS", "LightningStorm20",	118003) -- 20 Yard
	self:Log("SPELL_CAST_SUCCESS", "LightningStorm40",	 118004) -- 40 Yard
	self:Log("SPELL_CAST_SUCCESS", "LightningStorm60",	118005) -- 60 Yard
	self:Log("SPELL_CAST_SUCCESS", "LightningStorm80",	118005) -- 80 Yard - Seems 100 Yard in BEta Bug?!
	self:Log("SPELL_CAST_SUCCESS", "Corruption",	117351) -- Overwhelming AOE
	-- Elder Asani
	self:Log("SPELL_CAST_START", "CleansingWater", 117309) -- Spawn Watter Bubble
	self:Log("SPELL_CAST_SUCCESS", "Water_spawned",	117309) -- the good one
	
	self:Log("SPELL_CAST_START", "CorruptedWater", 117227) -- Spawn Watter Bubble
	self:Log("SPELL_CAST_SUCCESS", "CorruptedWater_spawned",	117227) -- the Bad One
	
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:Death("Deaths", 60966, 60965, 60620, 60583, 60585, 60619, 60963, 60964, 60962, 60961, 60618, 60586)
end

function mod:OnEngage()
	bossDead = 0
	self:Berserk(360) -- assume

end

function mod:OnWin()
	canEnable = false
end

--------------------------------------------------------------------------------
-- Event Handlers
-- Protector Kaolan
function mod:TouchCast(_, spellId, _, _, spellName)
	self:Message(117519, spellName, "Attention", spellId)
	self:Bar(117519, "~"..spellName, 14, spellId)
end

function mod:TouchApplied(player, spellId)
	if UnitIsUnit(player, "player") and not self:LFR() then
		self:LocalMessage(117519, CL["you"]:format(L["shadows"]), "Personal", spellId, "Alert")
		self:Say(117519, CL["say"]:format(L["shadows"]))
		self:FlashShake(117519)
	end
end


do
	local function checkTarget(sGUID)
		for i = 1, 4 do
			local bossId = ("boss%d"):format(i)
			if UnitGUID(bossId) == sGUID and UnitIsUnit(bossId.."target", "player") then
				mod:FlashShake(117988)
				mod:Say(117988, CL["say"]:format((GetSpellInfo(117988))))
				break
			end
		end
	end
	function mod:DefiledGroundCast(...)
		local sGUID = select(11, ...)
		self:ScheduleTimer(checkTarget, 0.1, sGUID)
	end
end

do
	local last = 0
	function mod:DefiledGround(player, spellId)
		local time = GetTime() 
		if (time - last) > 2 then
			last = time
			if UnitIsUnit(player, "player") then
				self:LocalMessage(117988, L["defiledground_message_self"], "Personal", spellId, "Info")
				self:FlashShake(117988)
				self:Whisper(117988, player, spellName) -- Whisper Target with Defiled Ground
			end
		end
	end
end

function mod:ExpelCorruption(_, spellId, _, _, spellName)
	self:Message(117975, spellName, "Important")
end

-- Elder Regail
-- 
function mod:LightningPrisonStart(_, spellId, _, _, spellName)
	self:Message(117436, spellName, "Attention", spellId)
	self:FlashShake(117436)
end



do
	local scheduled = nil
	local function Prison(spellName)
		mod:TargetMessage(117436, spellName, playerTbl, "Important", 117436)
		scheduled = nil
	end
	function mod:LightningPrisonApplied(player, _, _, _, spellName)
		playerTbl[#playerTbl + 1] = player
		self:Bar(117436, spellName, 8, spellId)
		self:OpenProximity(7, 117436)
		mod:Say(117436, CL["say"]:format((GetSpellInfo(117436)))) -- HOpe This says -> "LIGHTNING PRSION ON ME"
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(Prison, 0.1, spellName)
		end
	end
end

function mod:LightningPrisonRemoved(player)
	if UnitIsUnit(player, "player") then
		self:CloseProximity(117436)
	end
end

-- Big AOE - he start the AOE at Himself, then a Circuit at 20 Yard (10 Yrd + 10 Trigger) then 40 Yard, then 60 Yard then 80 Yard (you get dmg if you 10 Yard near at this. First Spell Cast has Casttime rest is "instant" 

function mod:LightningStormStart(_, spellId)
	self:Message(118077, L["storm_him"], "Important", 118077, "Alarm")
end

function mod:LightningStorm20(_, spellId)
	self:Message(118077, L["storm_20"], "Important", 118003, "Alarm")
end
function mod:LightningStorm40(_, spellId)
	self:Message(118077, L["storm_40"], "Important", 118004, "Alarm")
end
function mod:LightningStorm60(_, spellId)
	self:Message(118077, L["storm_60"], "Important", 118005, "Alarm")
end
function mod:LightningStorm80(_, spellId)
	self:Message(118077, L["storm_80"], "Important", 118006, "Alarm")
end

-- AOE Aura at 2 Sha stacks
function mod:Corruption(_, spellId, _, _, spellName)
	self:Message(117351, spellName, "Important")
end

-- Elder Asani
--
-- Globe GOOD
function mod:CleansingWater(_, spellId)
	self:Message(117309, L["water_soon"], "Important")
	
end

function mod:Water_spawned(_, spellId, _, _, spellName)
	self:Message(117309, L["water_spawned"], "Important")
	self:Bar(117309, L["cooldown_Water"] , 10, spellId)
end

-- Globe BAD
function mod:CorruptedWater(_, spellId)
	self:Message(117227, L["Corruptedwater_soon"], "Important", 117227, "Alarm")
	
end

function mod:CorruptedWater_spawned(_, spellId, _, _, spellName)
	self:Message(117227, L["Corruptedwater_spawned"], "Important", 117227, "Alarm")
	self:Bar(117227, L["cooldown_CorruptedWater"] , 10, spellId)
end

-- WIN

	
	
function mod:Deaths(mobId)	
	if mobId == 60583 or mobId == 60585 or mobId == 60586 then
		bossDead = bossDead +1
		if bossDead > 2 then 
			self:Win() 
		end
	end
end




	

