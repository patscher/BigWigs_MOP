
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Tsulong", 886, 742)
if not mod then return end
mod:RegisterEnableMob(10000) -- unknown actualy


--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
-- Night Phase
	L.shadow_message = "Move to >>SUNBEAM<<"
	L.Nightmares_message_self = "Nightmare on YOU! Run!"
	L.breath = "Shadow Breath"
	L.breath_desc = "Tank alert only. Count the stacks of Shadow Breath and show a duration bar."
	L.breath_icon = 122752
	L.breath_message = "%2$dx Shadow Breath on %1$s"
	L.sunbeam_spawned = "Sunbeam Spawned"
	
	L.Day_power_message = "Night Phase soon!"	
	L.AnouncePhaseNight = "Night Phase"
	L.AnouncePhaseNight_desc = "Announce Night Phase"
	L.AnouncePhaseNight_icon = 122752
	
	
-- Day Phase
	L.embodied_spawned = "Embodied Terror spawned"
	L.Terrorize = "Terrorize on %1$s"
	L.TerrorizeMe = "Terrorize on me!"
	L.fright = ">>>Fright casting<<<"
	L.unstable_spawned = "Unstable Sha spawned! >> SWITCH TARGET <<"
	L.SunBreath_soon = "Sunbreath soon! >>Move in!<<"
	L.SunBreathTank_soon = "Sunbreath soon! >> Move Adds in! <<"
	L.breathHealer = "%2$dx Sunbreath on %1$s"
	
	L.HealerBreath = "Sun Breath"
	L.HealerBreath_desc = "Healer alert only. show a duration bar for Sun Breath"
	L.HealerBreath_icon = 122855
	L.breathHealer_message	= "Sun Breath Timer"
	L.Night_power_message = "Day Phase soon!"
	
	
	L.AnouncePhaseDay = "Day Phase"
	L.AnouncePhaseDay_desc = "Announce day Phase"
	L.AnouncePhaseDay_icon = 122855
	
end
L = mod:GetLocale()
L.breath = L.breath.." "..INLINE_TANK_ICON
L.HealerBreath = L.HealerBreath.." "..INLINE_HEALER_ICON
--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Night Phase
		"AnouncePhaseDay",
		{122768, "WHISPER", "FLASHSHAKE"}, {122777, "SAY", "WHISPER", "FLASHSHAKE"}, "breath", 122789, 
		"AnouncePhaseNight",
		-- Day Phase
		122995, {123011, "SAY", "FLASHSHAKE"},123036, 122954, {122881, "SAY", "FLASHSHAKE"}, "HealerBreath", 
		
		-- General
		"berserk", "bosskill",
	}, 
	{
		AnouncePhaseDay = "ej:6310",
		AnouncePhaseNight = "ej:6315",
		berserk = "general",
	}
end

function mod:OnBossEnable()
	-- Night Phase
	self:Log("SPELL_AURA_REMOVED_DOSE", "ShadowsDecrease", 125843, 123252)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ShadowsIncrease", 125843, 122768) -- Shadow Debuff Stacks 
	self:Log("SPELL_CAST_SUCCESS", "NightmaresCast", 122777, 122770) -- Nightmare get casted 
	self:Log("SPELL_AURA_APPLIED", "NightmaresHitted", 122777, 122770) -- Nightmare Debuff
	self:Log("SPELL_AURA_APPLIED", "ShadowBreath", 122752, 92173, 80213) -- Shadow Breath Debuff
	self:Log("SPELL_AURA_APPLIED_DOSE", "ShadowBreath", 122752, 92173, 80213) -- Shadow Breath Stacks
	self:Log("SPELL_CAST_SUCCESS", "Sunbeam", 122789) -- Sunbeam Cast
	
		
	
	-- Day Phase
	self:Log("SPELL_CAST_SUCCESS", "embodied", 122995, 122996) -- Spawn Embodied
	self:Log("SPELL_AURA_APPLIED", "TerrorizeApplied", 123018, 123012, 123011) -- Terrorize from Embodied Adds
	self:Log("SPELL_CAST_START", "fright", 123036) -- fright cast from Fright Mobs
	self:Log("SPELL_CAST_SUCCESS", "unstable_spawned", 122954, 122953, 122952, 122946) -- summon unstable sha
	self:Log("SPELL_CAST_START", "UnstableCast", 122881, 122907, 122938) -- Unstable Bolt Cast
	self:Log("SPELL_CAST_SUCCESS", "UnstableHitted", 122881, 122907, 122938) -- Unstable Bold casted and moving to player
	self:Log("SPELL_CAST_START", "SunBreathCast", 123185, 123105 , 122855) -- Warn to run into Breath for Healers
	
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:RegisterUnitEvent("UNIT_POWER", "boss1", "boss2", "boss3", "boss4")
	self:Death("Win", 10000)
end

function mod:OnEngage(diff)

	self:Berserk(360) -- assume

end

--------------------------------------------------------------------------------
-- Event Handlers
------ 


-- Night Phase
do
	local warned = {}
	function mod:ShadowsIncrease(player, _, _, _, _, stack)
		if not warned[player] then return end
		if stack > 5 then warned[player] = nil end
	end
	function mod:ShadowsDecrease(player, spellId, _, _, _, stack)
		if warned[player] then return end
		if UnitIsUnit(player, "player") then
			if stack > 2 then return end
			self:Message(122768, L["shadow_message"], "Personal", spellId)
			self:FlashShake(122768)
			warned[player] = true
		elseif stack < 5 then
			self:Whisper(122768, player, L["shadow_message"], true)
			warned[player] = true
		end
	end
end

do
	local function checkTarget(sGUID)
		for i = 1, 4 do
			local bossId = ("boss%d"):format(i)
			if UnitGUID(bossId) == sGUID and UnitIsUnit(bossId.."target", "player") then
				mod:FlashShake(122777)
				mod:Say(122777, CL["say"]:format((GetSpellInfo(122777))))
				self:LocalMessage(122777, L["Nightmares_message_self"], "Personal", spellId, "Info")
				self:Whisper(122777, player, spellName) -- Whisper Target with Defiled Ground	
				break
			end
		end
	end
	function mod:NightmaresCast(...)
		local sGUID = select(11, ...)
		self:ScheduleTimer(checkTarget, 0.1, sGUID)
	end
end

do
	local last = 0
	function mod:NightmaresHitted(player, spellId)
		local time = GetTime() 
		if (time - last) > 2 then
			last = time
			if UnitIsUnit(player, "player") then
				self:FlashShake(122777)
			end
		end
	end
end

function mod:ShadowBreath(player, spellId, _, _, _, buffStack)
	if self:Tank() then
		buffStack = buffStack or 1
		self:SendMessage("BigWigs_StopBar", self, L["breath_message"]:format(player, buffStack - 1))
		self:Bar("breath", L["breath_message"]:format(player, buffStack), 31, spellId)
		self:TargetMessage("breath", L["breath_message"], player, "Urgent", spellId, buffStack > 1 and "Info" or nil, buffStack)
	end
end

function mod:Sunbeam(_, spellId, _, _, spellName)
	self:Message(122789, L["sunbeam_spawned"], "Important", 122789, "Alarm")
end

-- Day Phase
function mod:embodied(_, spellId, _, _, spellName)
	self:Message(122995, L["embodied_spawned"], "Important", 122995, "Alarm")
end

function mod:TerrorizeApplied(player, spellId)
	if UnitIsUnit(player, "player") and not self:LFR() then
		self:LocalMessage(123011, CL["you"]:format(L["Terrorize"]), "Personal", spellId, "Alert")
		self:Say(123011, CL["say"]:format(L["TerrorizeMe"]))
		self:FlashShake(123011)
	end
end

function mod:fright(_, spellId)
	self:Message(123036, L["fright"], "Attention", spellId)
end

function mod:unstable_spawned(_, spellId, _, _, spellName)
	self:Message(122954, L["unstable_spawned"], "Important", 122954, "Alarm")
end



do
	local function checkTarget2(sGUID)
		for i = 1, 4 do
			local bossId = ("boss%d"):format(i)
			if UnitGUID(bossId) == sGUID and UnitIsUnit(bossId.."target", "player") then
				mod:FlashShake(122881)
				mod:Say(122881, CL["say"]:format((GetSpellInfo(122881))))
				self:LocalMessage(122881, spellName, "Personal", spellId, "Info")
				
				break
			end
		end
	end
	function mod:UnstableCast(...)
		local sGUID = select(11, ...)
		self:ScheduleTimer(checkTarget2, 0.1, sGUID)
	end
end

do
	local last = 0
	function mod:UnstableHitted(player, spellId)
		local time = GetTime() 
		if (time - last) > 2 then
			last = time
			if UnitIsUnit(player, "player") then
				self:FlashShake(122881)
			end
		end
	end
end

function mod:SunBreathCast(_, spellId)
	if self:Healer() then
		self:Message(122855, L["SunBreath_soon"], "Important", 122855, "Alarm")
	elseif self:Tank() then
		self:Message(122855, L["SunBreathTank_soon"], "Important", 122855, "Alarm")
	end
end

function mod:SunBreath(player, spellId, _, _, _, buffStack)
	if self:Healer() then
		buffStack = buffStack or 1
		self:SendMessage("BigWigs_StopBar", self, L["breathHealer_message"]:format(player, buffStack - 1))
		self:Bar("HealerBreath", L["breathHealer_message"]:format(player, buffStack), 16, spellId)
	end
end

do
	local Night = EJ_GetSectionInfo(6310)
	local Day = EJ_GetSectionInfo(6315)	
	function mod:UNIT_POWER()
		for i = 1, 4 do
			local bossID = ("boss%d"):format(i)
			if UnitIsUnit(bossID, Night) then
				local power = UnitPower(bossID) -- , SPELL_POWER_ENERGY)
				if power > 95 then
				self:Message("AnouncePhaseDay", L["Night_power_message"], "Attention")
				end
			elseif UnitIsUnit(bossID, Day) then
				local power = UnitPower(bossID) -- , SPELL_POWER_ENERGY)
				if power > 95 then
				self:Message("AnouncePhaseNight", L["Day_power_message"], "Attention")
				end
			end
		end
	end
end


function mod:Deaths(mobId)
	if mobID == 10000 then
		self:Win()
	end
end