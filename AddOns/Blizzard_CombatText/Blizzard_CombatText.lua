NUM_COMBAT_TEXT_LINES = 20;
COMBAT_TEXT_SCROLLSPEED = 1.9;
COMBAT_TEXT_FADEOUT_TIME = 1.3;
COMBAT_TEXT_HEIGHT = 25;
COMBAT_TEXT_CRIT_MAXHEIGHT = 60;
COMBAT_TEXT_CRIT_MINHEIGHT = 30;
COMBAT_TEXT_CRIT_SCALE_TIME = 0.05;
COMBAT_TEXT_CRIT_SHRINKTIME = 0.2;
COMBAT_TEXT_TO_ANIMATE = {};
COMBAT_TEXT_STAGGER_RANGE = 20;
COMBAT_TEXT_SPACING = 10;
COMBAT_TEXT_MAX_OFFSET = 130;
COMBAT_TEXT_LOW_HEALTH_THRESHOLD = 0.2;
COMBAT_TEXT_LOW_MANA_THRESHOLD = 0.2;
COMBAT_TEXT_LOCATIONS = {};
COMBAT_TEXT_X_ADJUSTMENT = 80;
COMBAT_TEXT_Y_SCALE = 1;
COMBAT_TEXT_X_SCALE = 1;

--[[
List of COMBAT_TEXT_TYPE_INFO attributes
======================================================
r, g, b = [floats]  --  The floating text color
show = [nil, 1]  --  Display this message type in the UI
isStaggered = [nil, 1]  --  Randomly stagger these messages from left to right
var = [nil, 1]  --  This messageType is shown if this variable resolves to "1"
]]

COMBAT_TEXT_TYPE_INFO = {};
COMBAT_TEXT_TYPE_INFO["INTERRUPT"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["DAMAGE_CRIT"] = {r = 1, g = 0.1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["DAMAGE"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, show = 1};
COMBAT_TEXT_TYPE_INFO["MISS"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["DODGE"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["PARRY"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["EVADE"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["IMMUNE"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["DEFLECT"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["REFLECT"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["RESIST"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["BLOCK"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["ABSORB"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE_CRIT"] = {r = 0.79, g = 0.3, b = 0.85, show = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE"] = {r = 0.79, g = 0.3, b = 0.85, show = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_MISS"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_DODGE"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_PARRY"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_EVADE"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_IMMUNE"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_DEFLECT"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_REFLECT"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_RESIST"] = {r = 0.79, g = 0.3, b = 0.85, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["SPELL_BLOCK"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["SPELL_ABSORB"] = {r = 0.79, g = 0.3, b = 0.85, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["ENERGIZE"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_ENERGIZE"};
COMBAT_TEXT_TYPE_INFO["PERIODIC_ENERGIZE"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE"};
COMBAT_TEXT_TYPE_INFO["SPELL_CAST"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_AURA_END"] = {r = 0.1, g = 1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["SPELL_AURA_END_HARMFUL"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["SPELL_AURA_START"] = {r = 0.1, g = 1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["SPELL_AURA_START_HARMFUL"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["SPELL_ACTIVE"] = {r = 1, g = 0.82, b = 0, var = "COMBAT_TEXT_SHOW_REACTIVES"};
COMBAT_TEXT_TYPE_INFO["FACTION"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_REPUTATION"};
COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["HEAL"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["DAMAGE_SHIELD"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_DISPELLED"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["EXTRA_ATTACKS"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["SPLIT_DAMAGE"] = {r = 1, g = 1, b = 1, show = 1};
COMBAT_TEXT_TYPE_INFO["HONOR_GAINED"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_HONOR_GAINED"};
COMBAT_TEXT_TYPE_INFO["HEALTH_LOW"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA"};
COMBAT_TEXT_TYPE_INFO["MANA_LOW"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA"};
COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_COMBAT_STATE"};
COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_COMBAT_STATE"};
COMBAT_TEXT_TYPE_INFO["COMBO_POINTS"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_COMBO_POINTS"};
COMBAT_TEXT_TYPE_INFO["RUNE"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_ENERGIZE"};
COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_ABSORB"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["HEAL_CRIT_ABSORB"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["HEAL_ABSORB"] = {r = 0.1, g = 1, b = 0.1, show = 1};

COMBAT_TEXT_RUNE = {};
COMBAT_TEXT_RUNE[1] = COMBAT_TEXT_RUNE_BLOOD;
COMBAT_TEXT_RUNE[2] = COMBAT_TEXT_RUNE_UNHOLY;
COMBAT_TEXT_RUNE[3] = COMBAT_TEXT_RUNE_FROST;

function CombatText_OnLoad(self)
	CombatText_UpdateDisplayedMessages();
	CombatText.previousMana = {};
	CombatText.xDir = 1;
end

function CombatText_OnEvent(self, event, ...)
	if ( not self:IsVisible() ) then
		CombatText_ClearAnimationList();
		return;
	end
	
	local arg1, data, arg3, arg4 = ...;

	-- Set up the messageType
	local messageType, message;
	-- Set the message data
	local displayType;

	if ( event == "UNIT_ENTERED_VEHICLE" ) then
		local unit, showVehicle = ...;
		if ( unit == "player" ) then
			if ( showVehicle ) then
				self.unit = "vehicle";
			else
				self.unit = "player";
			end
			CombatTextSetActiveUnit(self.unit);
		end
		return;
	elseif ( event == "UNIT_EXITING_VEHICLE" ) then
		if ( arg1 == "player" ) then
			self.unit = "player";
			CombatTextSetActiveUnit(self.unit);
		end
		return;
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == self.unit ) then
			if ( UnitHealth(self.unit)/UnitHealthMax(self.unit) <= COMBAT_TEXT_LOW_HEALTH_THRESHOLD ) then
				if ( not CombatText.lowHealth ) then
					messageType = "HEALTH_LOW";
					CombatText.lowHealth = 1;
				end
			else
				CombatText.lowHealth = nil;
			end
		end
		
		-- Didn't meet any of the criteria so just return
		if ( not messageType ) then
			return;
		end
	elseif ( event == "UNIT_POWER" ) then
		if ( arg1 == self.unit ) then
			local powerType, powerToken = UnitPowerType(self.unit);
			if ( powerToken == "MANA" and (UnitPower(self.unit) / UnitPowerMax(self.unit)) <= COMBAT_TEXT_LOW_MANA_THRESHOLD ) then
				if ( not CombatText.lowMana ) then
					messageType = "MANA_LOW";
					CombatText.lowMana = 1;
				end
			else
				CombatText.lowMana = nil;
			end
		end
		
		-- Didn't meet any of the criteria so just return
		if ( not messageType ) then
			return;
		end
	elseif ( event == "PLAYER_REGEN_DISABLED" ) then
		messageType = "ENTERING_COMBAT";
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		messageType = "LEAVING_COMBAT";
	elseif ( event == "UNIT_COMBO_POINTS" ) then
		local unit = ...;
		if ( unit == "player" ) then
			local comboPoints = GetComboPoints("player", "target");
			if ( comboPoints > 0 ) then
				messageType = "COMBO_POINTS";
				data = comboPoints;
				-- Show message as a crit if max combo points
				if ( comboPoints == MAX_COMBO_POINTS ) then
					displayType = "crit";
				end
			else
				return;
			end
		else
			return;
		end
	elseif ( event == "COMBAT_TEXT_UPDATE" ) then
		messageType = arg1;
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		messageType = "RUNE";
	else
		messageType = event;
	end

	-- Process the messageType and format the message
	--Check to see if there's a COMBAT_TEXT_TYPE_INFO associated with this combat message
	local info = COMBAT_TEXT_TYPE_INFO[messageType];
	if ( not info ) then
		info = {r = 1, g =1, b = 1};
	end
	-- See if we should display the message or not
	if ( not info.show ) then
		-- When Resists aren't being shown, partial resists should display as Damage
		if (info.var == "COMBAT_TEXT_SHOW_RESISTANCES" and arg3) then
			messageType = "DAMAGE";
		else
			return;
		end
	end

	local isStaggered = info.isStaggered;
	if ( messageType == "" ) then
	
	elseif ( messageType == "DAMAGE_CRIT" or messageType == "SPELL_DAMAGE_CRIT" ) then
		displayType = "crit";
		message = "-"..data;
	elseif ( messageType == "DAMAGE" or messageType == "SPELL_DAMAGE" ) then
		if (data == 0) then
			return
		end
		message = "-"..data;
	elseif ( messageType == "SPELL_CAST" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_START" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_START_HARMFUL" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_END" or messageType == "SPELL_AURA_END_HARMFUL" ) then
		message = format(AURA_END, data);
	elseif ( messageType == "HEAL" or messageType == "PERIODIC_HEAL") then
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and messageType == "HEAL" and UnitName(self.unit) ~= data ) then
			message = "+"..arg3.." ["..data.."]";
		else
			message = "+"..arg3;
		end
	elseif ( messageType == "HEAL_ABSORB" or messageType == "PERIODIC_HEAL_ABSORB") then
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and messageType == "HEAL_ABSORB" and UnitName(self.unit) ~= data ) then
			message = "+"..arg3.." ["..data.."] "..format(ABSORB_TRAILER, arg4);
		else
			message = "+"..arg3.." "..format(ABSORB_TRAILER, arg4);
		end
	elseif ( messageType == "HEAL_CRIT" ) then
		displayType = "crit";
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and UnitName(self.unit) ~= data ) then
			message = "+"..arg3.." ["..data.."]";
		else
			message = "+"..arg3;
		end
	elseif ( messageType == "HEAL_CRIT_ABSORB" ) then
		displayType = "crit";
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and UnitName(self.unit) ~= data ) then
			message = "+"..arg3.." ["..data.."] "..format(ABSORB_TRAILER, arg4);
		else
			message = "+"..arg3.." "..format(ABSORB_TRAILER, arg4);
		end
	elseif ( messageType == "ENERGIZE" or messageType == "PERIODIC_ENERGIZE") then
		local count =  tonumber(data) 
		if (count > 0 ) then
			data = "+"..data;
		end
		if( arg3 == "MANA"
			or arg3 == "RAGE"
			or arg3 == "FOCUS"
			or arg3 == "ENERGY"
			or arg3 == "RUNIC_POWER"
			or arg3 == "SOUL_SHARDS" 
			or (arg3 == "HOLY_POWER" and PaladinPowerBar:IsShown() and PaladinPowerBar:GetAlpha() > 0.5) ) then
			message = data.." ".._G[arg3];
			info = PowerBarColor[arg3];
		elseif ( arg3 == "ECLIPSE" ) then
			if ( count < 0 ) then
				message = "+"..abs(count).." "..BALANCE_NEGATIVE_ENERGY;
				info = PowerBarColor[arg3].negative;
			else
				message = data.." "..BALANCE_POSITIVE_ENERGY;
				info = PowerBarColor[arg3].positive;
			end
		end
	elseif ( messageType == "FACTION" ) then
		if ( tonumber(arg3) > 0 ) then
			arg3 = "+"..arg3;
		end
		message = "("..data.." "..arg3..")";
	elseif ( messageType == "SPELL_MISS" ) then
		message = COMBAT_TEXT_MISS;
	elseif ( messageType == "SPELL_DODGE" ) then
		message = COMBAT_TEXT_DODGE;
	elseif ( messageType == "SPELL_PARRY" ) then
		message = COMBAT_TEXT_PARRY;
	elseif ( messageType == "SPELL_EVADE" ) then
		message = COMBAT_TEXT_EVADE;
	elseif ( messageType == "SPELL_IMMUNE" ) then
		message = COMBAT_TEXT_IMMUNE;
	elseif ( messageType == "SPELL_DEFLECT" ) then
		message = COMBAT_TEXT_DEFLECT;
	elseif ( messageType == "SPELL_REFLECT" ) then
		message = COMBAT_TEXT_REFLECT;
	elseif ( messageType == "BLOCK" or messageType == "SPELL_BLOCK" ) then
		if ( arg3 ) then
			-- Partial block
			message = "-"..data.." "..format(BLOCK_TRAILER, arg3);
		else
			message = COMBAT_TEXT_BLOCK;
		end
	elseif ( messageType == "ABSORB" or messageType == "SPELL_ABSORB" ) then
		if ( arg3 and data > 0 ) then
			-- Partial absorb
			message = "-"..data.." "..format(ABSORB_TRAILER, arg3);
		else
			message = COMBAT_TEXT_ABSORB;
		end
	elseif ( messageType == "RESIST" or messageType == "SPELL_RESIST" ) then
		if ( arg3 ) then
			-- Partial resist
			message = "-"..data.." "..format(RESIST_TRAILER, arg3);
		else
			message = COMBAT_TEXT_RESIST;
		end
	elseif ( messageType == "HONOR_GAINED" ) then
		data = tonumber(data);
		if ( not data or abs(data) < 1 ) then
			return;
		end
		data = floor(data);
		if ( data > 0 ) then
			data = "+"..data;
		end
		message = format(COMBAT_TEXT_HONOR_GAINED, data);
	elseif ( messageType == "SPELL_ACTIVE" ) then
		displayType = "crit";
		message = "<"..data..">";
	elseif ( messageType == "COMBO_POINTS" ) then
		message = format(COMBAT_TEXT_COMBO_POINTS, data);
	elseif ( messageType == "RUNE" ) then
		if ( data == true ) then
			local runeType = GetRuneType(arg1);
			message = COMBAT_TEXT_RUNE[runeType];
			-- Alex Brazie had me use these values. Feel free to correct them
			if( runeType == 1 ) then 
				info.r = .75;
				info.g = 0;
				info.b = 0;
			elseif( runeType == 2 ) then
				info.r = .75;
				info.g = 1;
				info.b = 0;
			elseif (runeType == 3 ) then
				info.r = 0;
				info.g = 1;
				info.b = 1;
			end
		else
			message = nil;
		end
	else 
		message = _G["COMBAT_TEXT_"..messageType];
		if ( not message ) then
			message = _G[messageType];
		end
	end

	-- Add the message
	if ( message ) then
		CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, info.r, info.g, info.b, displayType, isStaggered);
	end	
end

function CombatText_OnUpdate(self, elapsed)
	local lowestMessage = COMBAT_TEXT_LOCATIONS.startY;
	local alpha, xPos, yPos;
	for index, value in pairs(COMBAT_TEXT_TO_ANIMATE) do
		if ( value.scrollTime >= COMBAT_TEXT_SCROLLSPEED ) then
			CombatText_RemoveMessage(value);
		else
			value.scrollTime = value.scrollTime + elapsed;
			-- Calculate x and y positions
			xPos, yPos = value.scrollFunction(value);

			-- Record Y position
			value.yPos = yPos;

			value:SetPoint("TOP", WorldFrame, "BOTTOM", xPos, yPos);
			if ( value.scrollTime >= COMBAT_TEXT_FADEOUT_TIME ) then
				alpha = 1-((value.scrollTime-COMBAT_TEXT_FADEOUT_TIME)/(COMBAT_TEXT_SCROLLSPEED-COMBAT_TEXT_FADEOUT_TIME));
				alpha = max(alpha, 0);
				value:SetAlpha(alpha);
			end

			-- Handle crit
			if ( value.isCrit ) then
				if ( value.scrollTime <= COMBAT_TEXT_CRIT_SCALE_TIME ) then
					value:SetTextHeight(floor(COMBAT_TEXT_CRIT_MINHEIGHT+((COMBAT_TEXT_CRIT_MAXHEIGHT-COMBAT_TEXT_CRIT_MINHEIGHT)*value.scrollTime/COMBAT_TEXT_CRIT_SCALE_TIME)));
				elseif ( value.scrollTime <= COMBAT_TEXT_CRIT_SHRINKTIME ) then
					value:SetTextHeight(floor(COMBAT_TEXT_CRIT_MAXHEIGHT - ((COMBAT_TEXT_CRIT_MAXHEIGHT-COMBAT_TEXT_CRIT_MINHEIGHT)*(value.scrollTime - COMBAT_TEXT_CRIT_SCALE_TIME)/(COMBAT_TEXT_CRIT_SHRINKTIME - COMBAT_TEXT_CRIT_SCALE_TIME))));
				else
					value.isCrit = nil;
				end
			end
		end
	end

	if ( (COMBAT_TEXT_Y_SCALE ~= WorldFrame:GetHeight() / 768) or (COMBAT_TEXT_X_SCALE ~= WorldFrame:GetWidth() / 1024) ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function CombatText_AddMessage(message, scrollFunction, r, g, b, displayType, isStaggered)
	local string, noStringsAvailable = CombatText_GetAvailableString();
	if ( noStringsAvailable ) then
		return;
	end
	
	string:SetText(message);
	string:SetTextColor(r, g, b);
	string.scrollTime = 0;
	if ( displayType == "crit" ) then
		string.scrollFunction = CombatText_StandardScroll;
	else
		string.scrollFunction = scrollFunction;
	end
	
	-- See which direction the message should flow
	local yDir;
	local lowestMessage;
	local useXadjustment = 0;
	if ( COMBAT_TEXT_LOCATIONS.startY < COMBAT_TEXT_LOCATIONS.endY ) then
		-- Flowing up
		lowestMessage = string:GetBottom();
		-- Find lowest message to anchor to
		for index, value in pairs(COMBAT_TEXT_TO_ANIMATE) do
			if ( lowestMessage >= value.yPos - 16 - COMBAT_TEXT_SPACING) then
				lowestMessage = value.yPos - 16 - COMBAT_TEXT_SPACING;
			end
		end
		if ( lowestMessage < (COMBAT_TEXT_LOCATIONS.startY - COMBAT_TEXT_MAX_OFFSET) ) then
			if ( displayType == "crit" ) then
				lowestMessage = string:GetBottom();
			else
				COMBAT_TEXT_X_ADJUSTMENT = COMBAT_TEXT_X_ADJUSTMENT * -1;
				useXadjustment = 1;
				lowestMessage = COMBAT_TEXT_LOCATIONS.startY - COMBAT_TEXT_MAX_OFFSET;
			end
		end
	else
		-- Flowing down
		lowestMessage = string:GetTop();
		-- Find lowest message to anchor to
		for index, value in pairs(COMBAT_TEXT_TO_ANIMATE) do
			if ( lowestMessage <= value.yPos + 16 + COMBAT_TEXT_SPACING) then
				lowestMessage = value.yPos + 16 + COMBAT_TEXT_SPACING;
			end
		end
		if ( lowestMessage > (COMBAT_TEXT_LOCATIONS.startY + COMBAT_TEXT_MAX_OFFSET) ) then
			if ( displayType == "crit" ) then
				lowestMessage = string:GetTop();
			else
				COMBAT_TEXT_X_ADJUSTMENT = COMBAT_TEXT_X_ADJUSTMENT * -1;
				useXadjustment = 1;
				lowestMessage = COMBAT_TEXT_LOCATIONS.startY + COMBAT_TEXT_MAX_OFFSET;
			end
		end
	end

	-- Handle crits
	if ( displayType == "crit" ) then
		string.endY = COMBAT_TEXT_LOCATIONS.startY;
		string.isCrit = 1;
		string:SetTextHeight(COMBAT_TEXT_CRIT_MINHEIGHT);
	elseif ( displayType == "sticky" ) then
		string.endY = COMBAT_TEXT_LOCATIONS.startY;
		string:SetTextHeight(COMBAT_TEXT_HEIGHT);
	else
		string.endY = COMBAT_TEXT_LOCATIONS.endY;
		string:SetTextHeight(COMBAT_TEXT_HEIGHT);
	end

	-- Stagger the text if flagged
	local staggerAmount = 0;
	if ( isStaggered ) then
		staggerAmount = random(0, COMBAT_TEXT_STAGGER_RANGE) - COMBAT_TEXT_STAGGER_RANGE/2;
	end

	-- Alternate x direction
	CombatText.xDir = CombatText.xDir * -1;
	if ( useXadjustment == 1 ) then
		if ( COMBAT_TEXT_X_ADJUSTMENT > 0 ) then
			CombatText.xDir = -1;
		else
			CombatText.xDir = 1;
		end
	end
	string.xDir = CombatText.xDir;
	string.startX = COMBAT_TEXT_LOCATIONS.startX + staggerAmount + (useXadjustment * COMBAT_TEXT_X_ADJUSTMENT);
	string.startY = lowestMessage;
	string.yPos = lowestMessage;
	string:ClearAllPoints();
	string:SetPoint("TOP", WorldFrame, "BOTTOM", string.startX, lowestMessage);
	string:SetAlpha(1);
	string:Show();
	tinsert(COMBAT_TEXT_TO_ANIMATE, string);
end

function CombatText_RemoveMessage(string)
	for index, value in pairs(COMBAT_TEXT_TO_ANIMATE) do
		if ( value == string ) then
			tremove(COMBAT_TEXT_TO_ANIMATE, index);
			string:SetAlpha(0);
			string:Hide();
			string:SetPoint("TOP", WorldFrame, "BOTTOM", COMBAT_TEXT_LOCATIONS.startX, COMBAT_TEXT_LOCATIONS.startY);
			break;
		end
	end
end

function CombatText_GetAvailableString()
	local string;
	for i=1, NUM_COMBAT_TEXT_LINES do
		string = _G["CombatText"..i];
		if ( not string:IsShown() ) then
			return string;
		end 
	end
	return CombatText_GetOldestString(), 1;
end

function CombatText_GetOldestString()
	local oldestString = COMBAT_TEXT_TO_ANIMATE[1];
	CombatText_RemoveMessage(oldestString);
	return oldestString;
end

function CombatText_ClearAnimationList()
	local string;
	for i=1, NUM_COMBAT_TEXT_LINES do
		string = _G["CombatText"..i];
		string:SetAlpha(0);
		string:Hide();
		string:SetPoint("TOP", WorldFrame, "BOTTOM", COMBAT_TEXT_LOCATIONS.startX, COMBAT_TEXT_LOCATIONS.startY);
	end
end

function CombatText_UpdateDisplayedMessages()
	-- Unregister events if combat text is disabled
	if ( SHOW_COMBAT_TEXT == "0" ) then
		CombatText:UnregisterEvent("COMBAT_TEXT_UPDATE");
		CombatText:UnregisterEvent("UNIT_HEALTH");
		CombatText:UnregisterEvent("UNIT_POWER");
		CombatText:UnregisterEvent("PLAYER_REGEN_DISABLED");
		CombatText:UnregisterEvent("PLAYER_REGEN_ENABLED");
		CombatText:UnregisterEvent("UNIT_COMBO_POINTS");
		CombatText:UnregisterEvent("RUNE_POWER_UPDATE");
		CombatText:UnregisterEvent("UNIT_ENTERED_VEHICLE");
		CombatText:UnregisterEvent("UNIT_EXITING_VEHICLE");
		return;
	end

	-- set the unit to track
	if ( UnitHasVehicleUI("player") ) then
		CombatText.unit = "vehicle";
	else
		CombatText.unit = "player";
	end
	CombatTextSetActiveUnit(CombatText.unit);

	-- register events
	CombatText:RegisterEvent("COMBAT_TEXT_UPDATE");
	CombatText:RegisterEvent("UNIT_HEALTH");
	CombatText:RegisterEvent("UNIT_POWER");
	CombatText:RegisterEvent("PLAYER_REGEN_DISABLED");
	CombatText:RegisterEvent("PLAYER_REGEN_ENABLED");
	CombatText:RegisterEvent("UNIT_COMBO_POINTS");
	CombatText:RegisterEvent("RUNE_POWER_UPDATE");
	CombatText:RegisterEvent("UNIT_ENTERED_VEHICLE");
	CombatText:RegisterEvent("UNIT_EXITING_VEHICLE");

	-- Get scale
	COMBAT_TEXT_Y_SCALE = WorldFrame:GetHeight() / 768;
	COMBAT_TEXT_X_SCALE = WorldFrame:GetWidth() / 1024;
	COMBAT_TEXT_SPACING = 10 * COMBAT_TEXT_Y_SCALE;
	COMBAT_TEXT_MAX_OFFSET = 130 * COMBAT_TEXT_Y_SCALE;
	COMBAT_TEXT_X_ADJUSTMENT = 80 * COMBAT_TEXT_X_SCALE;

	-- Update shown messages
	for index, value in pairs(COMBAT_TEXT_TYPE_INFO) do
		if ( value.var ) then
			if ( _G[value.var] == "1" ) then
				value.show = 1;
			else
				value.show = nil;
			end
		end
	end
	-- Update scrolldirection
	if ( COMBAT_TEXT_FLOAT_MODE == "1" ) then
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll;
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY = 609 * COMBAT_TEXT_Y_SCALE
		};
		
	elseif ( COMBAT_TEXT_FLOAT_MODE == "2" ) then	
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll;
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY =  159 * COMBAT_TEXT_Y_SCALE
		};
	else
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_FountainScroll;
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY = 609 * COMBAT_TEXT_Y_SCALE
		};
	end
	CombatText_ClearAnimationList();
end

function CombatText_StandardScroll(value)
	-- Calculate x and y positions
	local xPos = value.startX+((COMBAT_TEXT_LOCATIONS.endX - COMBAT_TEXT_LOCATIONS.startX)*value.scrollTime/COMBAT_TEXT_SCROLLSPEED);
	local yPos = value.startY+((value.endY - COMBAT_TEXT_LOCATIONS.startY)*value.scrollTime/COMBAT_TEXT_SCROLLSPEED);
	return xPos, yPos;
end

function CombatText_FountainScroll(value)
	-- Calculate x and y positions
	local radius = 150;
	local xPos = value.startX-value.xDir*(radius*(1-cos(90*value.scrollTime/COMBAT_TEXT_SCROLLSPEED)));
	local yPos = value.startY+radius*sin(90*value.scrollTime/COMBAT_TEXT_SCROLLSPEED);
	return xPos, yPos;
end
