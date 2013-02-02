
--[[
abilityInfo should be defined with the following functions:
{
	:GetAbilityID()		- returns the ID of the ability
	:GetCooldown()		- returns the current cooldown remaining on the ability (0 if this tooltip is not associated with a battle).
	:GetRemainingDuration() - returns the remaining duration of an aura (0 if this is not an aura).
	:IsInBattle()		- returns true if this tooltip is associated with a particular battle (and we can get the target's info)
	:GetHealth(target)	- returns the current health of the associated unit. If not in a battle, returns the max health for self and 0 any other tokens.
	:GetMaxHealth(target)- returns the max health of the associated unit. If not in a battle, returns 0 for all tokens but self.
	:GetAttackStat(target)	- returns the value of the attack stat of the pet
	:GetSpeedStat(target)	- returns the value of the speed stat of the pet
	:GetState(stateID, target) - returns the value of a state associated with a unit. If not associated with a battle, return 0.
	:GetWeatherState(stateID) - returns the value of the state associated with the weather. If not associated with a battle, return 0.
	:GetPadState(stateID, target) - returns the value of the state associated with the pad on target's side. If not associated with a battle, return 0.
	:GetPetOwner(target)	- returns either LE_BATTLE_PET_ALLY, LE_BATTLE_PET_ENEMY, or LE_BATTLE_PET_WEATHER while in combat.
	:HasAura(auraID, target) - returns true if the unit has the aura active, false if they don't or we aren't in combat.
	:GetPetType(target) - returns the pet type ID of the target. May return nil if the target doesn't exist (e.g. when clicking on the link in chat.)

	Values for target are:
	For abilities: self(default), enemy(affected)
	For auras: auracaster(default), aurawearer(affected), auraenemy(the enemy of aurawearer)
}
--]]
DEFAULT_PET_BATTLE_ABILITY_INFO = {};
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetAbilityID() error("UI: Unimplemented Function") end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetCooldown() return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetRemainingDuration() return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:IsInBattle() error("UI: Unimplemented Function") end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetHealth(target) return 100 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetMaxHealth(target) return 100 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetAttackStat(target) return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetSpeedStat(target) return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetState(stateID, target) return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetWeatherState(stateID) return 0 end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetPetOwner(taget) return LE_BATTLE_PET_ALLY end
function DEFAULT_PET_BATTLE_ABILITY_INFO:HasAura(auraID, target) return false end
function DEFAULT_PET_BATTLE_ABILITY_INFO:GetPetType(target) if ( self:IsInBattle() ) then error("UI: Unimplemented Function"); else return nil end end

function SharedPetBattleAbilityTooltip_GetInfoTable()
	local info = {};
	setmetatable(info, { __index = DEFAULT_PET_BATTLE_ABILITY_INFO; });
	return info;
end

function SharedPetBattleAbilityTooltip_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	self.strongAgainstTextures = { self.StrongAgainstType1 };
	self.weakAgainstTextures = { self.WeakAgainstType1 };
end

function SharedPetBattleAbilityTooltip_SetAbility(self, abilityInfo, additionalText)
	local abilityID = abilityInfo:GetAbilityID();
	if ( not abilityID ) then
		return;
	end

	local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID);

	local bottom = self.AbilityPetType;

	--Update name
	self.Name:SetText(name);
	
	if ( numTurns and numTurns > 1 ) then
		self.Duration:SetFormattedText(BATTLE_PET_ABILITY_MULTIROUND, numTurns);
		self.Duration:Show();
		bottom = self.Duration;
	else
		self.Duration:Hide();
	end
	
	--Update cooldown
	if ( maxCooldown > 0 ) then
		self.MaxCooldown:SetFormattedText(PET_BATTLE_TURN_COOLDOWN, maxCooldown);
		self.MaxCooldown:SetPoint("TOPLEFT", bottom, "BOTTOMLEFT", 0, -5);
		self.MaxCooldown:Show();
		bottom = self.MaxCooldown;
	else
		self.MaxCooldown:Hide();
	end

	--Current cooldown remaining
	local currentCooldown = abilityInfo:GetCooldown();
	if ( currentCooldown > 0 ) then
		self.CurrentCooldown:SetFormattedText(PET_BATTLE_TURN_CURRENT_COOLDOWN, currentCooldown);
		self.CurrentCooldown:Show();
		bottom = self.CurrentCooldown;
	else
		self.CurrentCooldown:Hide();
	end

	--Any additional text the callers wants us to display
	if ( additionalText ) then
		self.AdditionalText:SetText(additionalText);
		self.AdditionalText:SetPoint("TOPLEFT", bottom, "BOTTOMLEFT", 0, -5);
		self.AdditionalText:Show();
		bottom = self.AdditionalText;
	else
		self.AdditionalText:Hide();
	end

	--Update description
	local description = SharedPetAbilityTooltip_ParseText(abilityInfo, unparsedDescription);
	self.Description:SetText(description);
	self.Description:SetPoint("TOPLEFT", bottom, "BOTTOMLEFT", 0, -5);
	bottom = self.Description;

	--Update ability type
	if ( petType and petType > 0 ) then
		self.Name:SetSize(190, 32);
		self.Name:SetPoint("LEFT", self.AbilityPetType, "RIGHT", 5, 0);
		self.AbilityPetType:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);
		self.AbilityPetType:Show();
	else
		self.Name:SetSize(223, 32);
		self.Name:SetPoint("LEFT", self, "TOPLEFT", 11, -26);
		self.AbilityPetType:Hide();
	end

	--Update weaknesses/strengths
	if ( petType and not noStrongWeakHints ) then
		bottom = self.WeakAgainstIcon;
		self.StrongAgainstIcon:Show();
		self.StrongAgainstLabel:Show();
		self.Delimiter1:Show();
		self.WeakAgainstIcon:Show();
		self.WeakAgainstLabel:Show();
		self.Delimiter2:Show();

		local nextStrongIndex, nextWeakIndex = 1, 1;
		for i=1, C_PetJournal.GetNumPetTypes() do
			local modifier = C_PetBattles.GetAttackModifier(petType, i);
			if ( modifier > 1 ) then
				local icon = self.strongAgainstTextures[nextStrongIndex];
				if ( not icon ) then
					self.strongAgainstTextures[nextStrongIndex] = self:CreateTexture(nil, "ARTWORK", "SharedPetBattleStrengthPetTypeTemplate");
					icon = self.strongAgainstTextures[nextStrongIndex];
					icon:ClearAllPoints();
					icon:SetPoint("LEFT", self.strongAgainstTextures[nextStrongIndex - 1], "RIGHT", 2, 0);
				end
				if ( nextStrongIndex == 1 ) then
					self.StrongAgainstType1Label:SetText(_G["BATTLE_PET_NAME_"..i]);
					self.StrongAgainstType1Label:Show();
				else
					self.StrongAgainstType1Label:Hide(); --Don't show any text if there are multiple
				end
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextStrongIndex = nextStrongIndex + 1;
			elseif ( modifier < 1 ) then
				local icon = self.weakAgainstTextures[nextWeakIndex];
				if ( not icon ) then
					self.weakAgainstTextures[nextWeakIndex] = self:CreateTexture(nil, "ARTWORK", "SharedPetBattleStrengthPetTypeTemplate");
					icon = self.weakAgainstTextures[nextWeakIndex];
					icon:ClearAllPoints();
					icon:SetPoint("LEFT", self.weakAgainstTextures[nextWeakIndex - 1], "RIGHT", 2, 0);
				end
				if ( nextWeakIndex == 1 ) then
					self.WeakAgainstType1Label:SetText(_G["BATTLE_PET_NAME_"..i]);
					self.WeakAgainstType1Label:Show();
				else
					self.WeakAgainstType1Label:Hide(); --Don't show any text if there are multiple
				end
				icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]);
				icon:Show();
				nextWeakIndex = nextWeakIndex + 1;
			end
		end

		for i=nextStrongIndex, #self.strongAgainstTextures do
			self.strongAgainstTextures[i]:Hide();
		end
		for i=nextWeakIndex, #self.weakAgainstTextures do
			self.weakAgainstTextures[i]:Hide();
		end
	else
		self.StrongAgainstIcon:Hide();
		self.StrongAgainstLabel:Hide();
		self.StrongAgainstType1Label:Hide();
		self.Delimiter1:Hide();
		self.WeakAgainstIcon:Hide();
		self.WeakAgainstLabel:Hide();
		self.WeakAgainstType1Label:Hide();
		self.Delimiter2:Hide();
		for _, texture in pairs(self.strongAgainstTextures) do
			texture:Hide();
		end
		for _, texture in pairs(self.weakAgainstTextures) do
			texture:Hide();
		end
	end

	--We haven't updated frame rects yet, so we'll alpha out the frame and update the size (and show it) next frame.
	self.bottomFrame = bottom;
	self:SetAlpha(0);
	self:SetScript("OnUpdate", SharedPetBattleAbilityTooltip_UpdateSize);
end

function SharedPetBattleAbilityTooltip_UpdateSize(self)
	self:SetScript("OnUpdate", nil);
	self:SetHeight(self:GetTop() - self.bottomFrame:GetBottom() + 10);
	self:SetAlpha(1);
end

--Enclosure for parsing tooltips
--We use Lua to parse our tooltips instead of writing a custom parser to save development time.
--TODO: Look into caching returns to decrease garbage collection.
do
	local parsedAbilityInfo;
	function SharedPetAbilityTooltip_ParseText(abilityInfo, unparsed)
		parsedAbilityInfo = abilityInfo;
		local parsed = string.gsub(unparsed, "%b[]", SharedPetAbilityTooltip_ParseExpression);
		return parsed;
	end

	local parserEnv = {
		--Constants
		SELF = "self",
		ENEMY = "enemy",
		AURAWEARER = "aurawearer",
		AURACASTER = "auracaster",
		AURAENEMY = "auraenemy",
		AFFECTED = "affected",

		--Proc types (for use in getProcIndex)
		PROC_ON_APPLY = PET_BATTLE_EVENT_ON_APPLY,
		PROC_ON_DAMAGE_TAKEN = PET_BATTLE_EVENT_ON_DAMAGE_TAKEN,
		PROC_ON_DAMAGE_DEALT = PET_BATTLE_EVENT_ON_DAMAGE_DEALT,
		PROC_ON_HEAL_TAKEN = PET_BATTLE_EVENT_ON_HEAL_TAKEN,
		PROC_ON_HEAL_DEALT = PET_BATTLE_EVENT_ON_HEAL_DEALT,
		PROC_ON_AURA_REMOVED = PET_BATTLE_EVENT_ON_AURA_REMOVED,
		PROC_ON_ROUND_START = PET_BATTLE_EVENT_ON_ROUND_START,
		PROC_ON_ROUND_END = PET_BATTLE_EVENT_ON_ROUND_END,
		PROC_ON_TURN = PET_BATTLE_EVENT_ON_TURN,
		PROC_ON_ABILITY = PET_BATTLE_EVENT_ON_ABILITY,
		PROC_ON_SWAP_IN = PET_BATTLE_EVENT_ON_SWAP_IN,
		PROC_ON_SWAP_OUT = PET_BATTLE_EVENT_ON_SWAP_OUT,

		--We automatically populate with state constants as well in the form STATE_%s

		--Utility functions
		ceil = math.ceil,
		floor = math.floor,
		abs = math.abs,
		min = math.min,
		max = math.max,
		cond = function(conditional, onTrue, onFalse) if ( conditional ) then return onTrue; else return onFalse; end end,
		clamp = function(value, minClamp, maxClamp) return min(max(value, minClamp), maxClamp); end,

		--Data fetching functions
		unitState = function(stateID, target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetState(stateID, target);
				end,
		unitPower = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetAttackStat(target);
				end,
		unitSpeed = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetSpeedStat(target);
				end,
		unitMaxHealth = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetMaxHealth(target);
				end,
		unitHealth = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetHealth(target);
				end,
		unitIsAlly = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetPetOwner(target) == LE_BATTLE_PET_ALLY;
				end,
		unitHasAura = function(auraID, target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:HasAura(auraID, target);
				end,
		unitPetType = function(target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetPetType(target);
				end,
		isInBattle = function()
					return parsedAbilityInfo:IsInBattle();
				end,
		numTurns = function(abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local id, name, icon, maxCooldown, description, numTurns = C_PetBattles.GetAbilityInfoByID(abilityID);
					return numTurns;
				end,
		currentCooldown = function()
					return parsedAbilityInfo:GetCurrentCooldown();
				end,
		maxCooldown = function(abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local id, name, icon, maxCooldown, description, numTurns = C_PetBattles.GetAbilityInfoByID(abilityID);
					return maxCooldown;
				end,
		abilityPetType = function(abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local id, name, icon, maxCooldown, description, numTurns, petType = C_PetBattles.GetAbilityInfoByID(abilityID);
					return petType;
				end,
		petTypeName = function(petType)
					return _G["BATTLE_PET_DAMAGE_NAME_"..petType]
				end,
		remainingDuration = function()
					return parsedAbilityInfo:GetRemainingDuration();
				end,
		getProcIndex = function(procType, abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local turnIndex = C_PetBattles.GetAbilityProcTurnIndex(abilityID, procType);
					if ( not turnIndex ) then
						error("No such proc type: "..tostring(procType));
					end
					return turnIndex;
				end,
		abilityName = function(abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local id, name, icon, maxCooldown, description, numTurns, petType = C_PetBattles.GetAbilityInfoByID(abilityID);
					return name;
				end,
		abilityHasHints = function(abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityID);
					return petType and not noStrongWeakHints;
				end,
		padState = function(stateID, target)
					if ( not target ) then
						target = "default";
					end
					return parsedAbilityInfo:GetPadState(stateID, target);
				end,
		weatherState = function(stateID)
					return parsedAbilityInfo:GetWeatherState(stateID);
				end,
		abilityStateMod = function(stateID, abilityID)
					if ( not abilityID ) then
						abilityID = parsedAbilityInfo:GetAbilityID();
					end
					return C_PetBattles.GetAbilityStateModification(abilityID, stateID);
				end,
	};
	
	-- Dynamic fetching functions
	local effectParamStrings = {C_PetBattles.GetAllEffectNames()};
	for i = 1, #effectParamStrings do
		parserEnv[effectParamStrings[i]] = 
			function(turnIndex, effectIndex, abilityID)
				if ( not abilityID ) then
					abilityID = parsedAbilityInfo:GetAbilityID();
				end
				local value = C_PetBattles.GetAbilityEffectInfo(abilityID, turnIndex, effectIndex, effectParamStrings[i]);
				if ( not value ) then
					error("No such attribute: "..effectParamStrings[i]);
				end
				return value;
			end;
	end

	-- Fill out the environment with all states (format: STATE_%s)
	C_PetBattles.GetAllStates(parserEnv);
		
	
	--Alias helpers
	local function FormatDamageHelper(baseDamage, attackType, defenderType)
		local output = "";
		local multi = C_PetBattles.GetAttackModifier(attackType, defenderType);

		if ( multi > 1 ) then 
			output = GREEN_FONT_COLOR_CODE..math.floor(baseDamage * multi)..FONT_COLOR_CODE_CLOSE;
			if (ENABLE_COLORBLIND_MODE == "1") then
				output = output.."|Tinterface\\petbattles\\battlebar-abilitybadge-strong-small:0|t";
			end
			return output;
		elseif ( multi < 1 ) then 
			output = RED_FONT_COLOR_CODE..math.floor(baseDamage * multi)..FONT_COLOR_CODE_CLOSE;
			if (ENABLE_COLORBLIND_MODE == "1") then
				output = output.."|Tinterface\\petbattles\\battlebar-abilitybadge-weak-small:0|t";
			end
			return output;
		end
		
		return math.floor(baseDamage);
	end

	local function FormatHealingHelper(baseHeal, healingDone, healingTaken)
		local output = "";

		local doneMulti = (healingDone / 100)
		local takenMulti = (healingTaken / 100);
		
		local finalHeal = baseHeal + baseHeal * doneMulti;
		finalHeal = finalHeal + finalHeal * takenMulti;

		local finalMulti = finalHeal / baseHeal;

		if ( finalMulti > 1 ) then 
			output = GREEN_FONT_COLOR_CODE..math.floor(baseHeal * finalMulti)..FONT_COLOR_CODE_CLOSE;
			if (ENABLE_COLORBLIND_MODE == "1") then
				output = output.."|Tinterface\petbattles\battlebar-abilitybadge-strong-small:0|t";
			end
			return output;
		elseif( finalMulti < 1 ) then 
			output = RED_FONT_COLOR_CODE..math.floor(baseHeal * finalMulti)..FONT_COLOR_CODE_CLOSE;
			if (ENABLE_COLORBLIND_MODE == "1") then
				output = output.."|Tinterface\petbattles\battlebar-abilitybadge-weak-small:0|t";
			end
			return output;
		end

		return math.floor(baseHeal);
	end

	--Aliases
	parserEnv.OnlyInBattle = function(text) if ( parserEnv.isInBattle() ) then return text else return ""; end end;
	parserEnv.School = function(abilityID) return parserEnv.petTypeName(parserEnv.abilityPetType(abilityID)); end;
	parserEnv.SumStates = function(stateID, target)
		if ( parserEnv.unitPetType(target) == 7 ) then --Elementals aren't affected by weathers.
			return parserEnv.unitState(stateID, target) + parserEnv.padState(stateID, target);
		else
			return parserEnv.unitState(stateID, target) + parserEnv.padState(stateID, target) + parserEnv.weatherState(stateID);
		end
	end;


	--Attack aliases
	parserEnv.AttackBonus = function() return (1 + 0.05 * parserEnv.unitPower()); end;
	parserEnv.SimpleDamage = function(...) return parserEnv.points(...) * parserEnv.AttackBonus(); end;
	parserEnv.StandardDamage = function(...)
		local turnIndex, effectIndex, abilityID = ...;
		return parserEnv.FormatDamage(parserEnv.SimpleDamage(...), abilityID);
	end;
	parserEnv.FormatDamage = function(baseDamage, abilityID, affected)
		if ( not affected ) then
			affected = parserEnv.AFFECTED;
		end

		if ( parserEnv.isInBattle() and parserEnv.abilityHasHints(abilityID) ) then
			return FormatDamageHelper(baseDamage, parserEnv.abilityPetType(abilityID), parserEnv.unitPetType(affected));
		else
			return parserEnv.floor(baseDamage);
		end
	end;
	
	--Healing aliases
	parserEnv.HealingBonus = function() return (1 + 0.05 * parserEnv.unitPower()); end;
	parserEnv.SimpleHealing = function(...) return parserEnv.points(...) * parserEnv.HealingBonus(); end;
	parserEnv.StandardHealing = function(...)
		return parserEnv.FormatHealing(parserEnv.SimpleHealing(...));
	end;
	parserEnv.FormatHealing = function(baseHealing)
		if ( parserEnv.isInBattle() ) then
			return FormatHealingHelper(baseHealing, parserEnv.SumStates(65), parserEnv.SumStates(66));
		else
			return parserEnv.floor(baseHealing);
		end
	end;
	
	--Don't allow designers to accidentally change the environment
	local safeEnv = {};
	setmetatable(safeEnv, { __index = parserEnv, __newindex = function() end });

	function SharedPetAbilityTooltip_ParseExpression(expression)
		--Load the expression, chopping off the [] on the side.
		local expr = loadstring("return ("..string.sub(expression, 2, -2)..")");
		if ( expr ) then
			--Set the environment up to restrict functions
			setfenv(expr, safeEnv);

			--Don't let designer errors cause us to stop execution
			local success, repl = pcall(expr);
			if ( success ) then
				if ( type(repl) == "number" ) then
					return math.floor(repl);	--We don't want to display any decimals.
				else
					return repl or "";
				end
			elseif ( IsGMClient() ) then
				local err = string.match(repl, ":%d+: (.*)");
				return "[DATA ERROR: "..err.."]";
			else
				return "DATA ERROR";
			end
		else
			return "PARSING ERROR";
		end
	end
end

