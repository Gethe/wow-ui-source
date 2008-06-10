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
COMBAT_TEXT_TYPE_INFO["BLOCK"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["ABSORB"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["RESIST"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["EVADE"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["DODGE"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["PARRY"] = {r = 1, g = 0.1, b = 0.1, isStaggered = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["IMMUNE"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["DEFLECT"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["ENCHANTMENT_REMOVED"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["ENCHANTMENT_ADDED"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {r = 0.1, g = 1, b = 0.1, show = 1};
COMBAT_TEXT_TYPE_INFO["MANA"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_MANA"};
COMBAT_TEXT_TYPE_INFO["RAGE"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_MANA"};
COMBAT_TEXT_TYPE_INFO["FOCUS"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_MANA"};
COMBAT_TEXT_TYPE_INFO["ENERGY"] = {r = 0.1, g = 0.1, b = 1, var = "COMBAT_TEXT_SHOW_MANA"};
COMBAT_TEXT_TYPE_INFO["SPELL_ABSORBED"] = {r = 0.79, g = 0.3, b = 0.85, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["SPELL_RESISTED"] = {r = 0.79, g = 0.3, b = 0.85, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["PROC_RESISTED"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["DISPEL_FAILED"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_CAST"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_CAST_START"] = {r = 1, g = 1, b = 1};
COMBAT_TEXT_TYPE_INFO["AURA_END"] = {r = 0.1, g = 1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURA_FADE"};
COMBAT_TEXT_TYPE_INFO["AURA_END_HARMFUL"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURA_FADE"};
COMBAT_TEXT_TYPE_INFO["AURA_START"] = {r = 0.1, g = 1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["AURA_START_HARMFUL"] = {r = 1, g = 0.1, b = 0.1, var = "COMBAT_TEXT_SHOW_AURAS"};
COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE"] = {r = 0.79, g = 0.3, b = 0.85, show = 1};
COMBAT_TEXT_TYPE_INFO["SPELL_DODGED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_PARRIED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_BLOCKED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_RESISTANCES"};
COMBAT_TEXT_TYPE_INFO["SPELL_EVADED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_IMMUNE"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_DEFLECTED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_REFLECTED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
COMBAT_TEXT_TYPE_INFO["SPELL_MISSED"] = {r = 1, g = 1, b = 1, var = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS"};
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

function CombatText_OnLoad()
	CombatText_UpdateDisplayedMessages();
	CombatText.previousMana = {};
end

function CombatText_OnEvent(event)
	-- Set up the messageType
	local messageType, message;
	-- Set the message data
	local data = arg2;
	local displayType;
	if ( event == "UNIT_HEALTH" ) then
		if ( arg1 == "player" ) then
			if ( UnitHealth("player")/UnitHealthMax("player") <= COMBAT_TEXT_LOW_HEALTH_THRESHOLD ) then
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
	elseif ( event == "UNIT_MANA" ) then
		local mana = UnitMana("player");
		local powerType = UnitPowerType("player");
		if ( arg1 == "player" ) then
			if ( mana/UnitManaMax("player") <= COMBAT_TEXT_LOW_MANA_THRESHOLD and powerType == 0 ) then
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
	elseif ( event == "PLAYER_COMBO_POINTS" ) then
		local comboPoints = GetComboPoints();
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
	elseif ( event == "COMBAT_TEXT_UPDATE" ) then
		messageType = arg1;
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
		return;
	end

	local isStaggered = info.isStaggered;
	
	if ( messageType == "" ) then
	
	elseif ( messageType == "DAMAGE_CRIT" ) then
		displayType = "crit";
		message = "-"..data;
	elseif ( messageType == "DAMAGE" or messageType == "SPELL_DAMAGE" ) then
		message = "-"..data;
	elseif ( messageType == "AURA_START" ) then
		message = "<"..data..">";
	elseif ( messageType == "AURA_START_HARMFUL" ) then
		message = "<"..data..">";
	elseif ( messageType == "AURA_END" or messageType == "AURA_END_HARMFUL" ) then
		message = format(AURA_END, data);
	elseif ( messageType == "HEAL" or messageType == "PERIODIC_HEAL") then
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and messageType == "HEAL" and UnitName("player") ~= data ) then
			message = "+"..arg3.." ["..data.."]";
		else
			message = "+"..arg3;
		end
	elseif ( messageType == "HEAL_CRIT" ) then
		displayType = "crit";
		if ( COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" and UnitName("player") ~= data ) then
			message = "+"..arg3.." ["..data.."]";
		else
			message = "+"..arg3;
		end
	elseif ( messageType == "MANA" ) then
		if ( tonumber(data) > 0 ) then
			data = "+"..data;
		end
		message = data.." "..MANA;
	elseif ( messageType == "RAGE" ) then
		message = "+"..data.." "..RAGE;
	elseif ( messageType == "FOCUS" ) then
		message = "+"..data.." "..FOCUS;
	elseif ( messageType == "ENERGY" ) then
		message = "+"..data.." "..ENERGY;
	elseif ( messageType == "FACTION" ) then
		if ( tonumber(arg3) > 0 ) then
			arg3 = "+"..arg3;
		end
		message = "("..data.." "..arg3..")";
	elseif ( messageType == "BLOCK" ) then
		if ( arg3 ) then
			-- Partial block
			message = data.." "..format(BLOCK_TRAILER, arg3);
		else
			message = BLOCK;
		end
	elseif ( messageType == "ABSORB" ) then
		if ( arg3 ) then
			-- Partial block
			message = arg2.." "..format(ABSORB_TRAILER, arg3);
		else
			message = ABSORB;
		end
	elseif ( messageType == "RESIST" ) then
		if ( arg3 ) then
			-- Partial resist
			message = data.." "..format(RESIST_TRAILER, arg3);
		else
			message = RESIST;
		end
	elseif ( messageType == "SPELL_RESISTED" ) then
		if ( arg3 ) then
			-- Partial resist
			message = data.." "..format(RESIST_TRAILER, arg3);
		else
			message = RESIST;
		end
	elseif ( messageType == "HONOR_GAINED" ) then
		message = format(COMBAT_TEXT_HONOR_GAINED, data);
	elseif ( messageType == "SPELL_ACTIVE" ) then
		displayType = "crit";
		message = "<"..data..">";
	elseif ( messageType == "COMBO_POINTS" ) then
		message = format(GetText("COMBAT_TEXT_COMBO_POINTS", nil, data), data);
	else 
		message = getglobal(messageType);
		if ( not message ) then
			message = getglobal("COMBAT_TEXT_"..messageType);
		end
	end

	-- Add the message
	if ( message ) then
		CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, info.r, info.g, info.b, displayType, isStaggered);
	end	
end

function CombatText_OnUpdate(elapsed)
	local lowestMessage = COMBAT_TEXT_LOCATIONS.startY;
	local uiScale = 1;
	if ( GetCVar("useUiScale") == "1" ) then
		uiScale = GetCVar("uiscale") + 0;
		lowestMessage = lowestMessage / uiScale;
	end
	local alpha, xPos, yPos;
	for index, value in COMBAT_TEXT_TO_ANIMATE do
		if ( value.scrollTime >= COMBAT_TEXT_SCROLLSPEED ) then
			CombatText_RemoveMessage(value);
		else
			value.scrollTime = value.scrollTime + elapsed;
			-- Calculate x and y positions
			xPos, yPos = value.scrollFunction(value);

			-- Record Y position
			value.yPos = yPos;

			value:SetPoint("TOP", UIParent, "BOTTOM", xPos, yPos);
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
	if ( COMBAT_TEXT_LOCATIONS.startY < COMBAT_TEXT_LOCATIONS.endY ) then
		-- Flowing up
		lowestMessage = string:GetBottom();
		-- Find lowest message to anchor to
		for index, value in COMBAT_TEXT_TO_ANIMATE do
			if ( lowestMessage >= value.yPos - 16 - COMBAT_TEXT_SPACING) then
				lowestMessage = value.yPos - 16 - COMBAT_TEXT_SPACING;
			end
		end
		if ( lowestMessage < (COMBAT_TEXT_LOCATIONS.startY - COMBAT_TEXT_MAX_OFFSET) ) then
			lowestMessage = string:GetBottom();
		end
	else
		-- Flowing down
		lowestMessage = string:GetTop();
		-- Find lowest message to anchor to
		for index, value in COMBAT_TEXT_TO_ANIMATE do
			if ( lowestMessage <= value.yPos + 16 + COMBAT_TEXT_SPACING) then
				lowestMessage = value.yPos + 16 + COMBAT_TEXT_SPACING;
			end
		end
		if ( lowestMessage > (COMBAT_TEXT_LOCATIONS.startY + COMBAT_TEXT_MAX_OFFSET) ) then
			lowestMessage = string:GetTop();
		end
	end

	local uiScale = 1;

	-- Handle crits
	if ( displayType == "crit" ) then
		string.endY = COMBAT_TEXT_LOCATIONS.startY;
		string.isCrit = 1;
		string:SetTextHeight(COMBAT_TEXT_CRIT_MINHEIGHT);
	elseif ( displayType == "sticky" ) then
		string.endY = COMBAT_TEXT_LOCATIONS.startY;
		string:SetTextHeight(COMBAT_TEXT_HEIGHT);
	else
		if ( GetCVar("useUiScale") == "1" ) then
			uiScale = GetCVar("uiscale") + 0;
			string.endY = COMBAT_TEXT_LOCATIONS.endY / uiScale;
		else
			string.endY = COMBAT_TEXT_LOCATIONS.endY;
		end
		
		string:SetTextHeight(COMBAT_TEXT_HEIGHT);
	end

	-- Stagger the text if flagged
	local staggerAmount = 0;
	if ( isStaggered ) then
		staggerAmount = random(0, COMBAT_TEXT_STAGGER_RANGE) - COMBAT_TEXT_STAGGER_RANGE/2;
	end

	-- Alternate x direction
	if ( not CombatText.xDir or CombatText.xDir < 0 ) then
		CombatText.xDir = 1;
	else
		CombatText.xDir = -1;
	end
	string.xDir = CombatText.xDir;
	string.startX = COMBAT_TEXT_LOCATIONS.startX + staggerAmount;
	string.startY = lowestMessage;
	string.yPos = lowestMessage;
	string:SetPoint("TOP", UIParent, "BOTTOM", string.startX, lowestMessage);
	string:SetAlpha(1);
	string:Show();
	tinsert(COMBAT_TEXT_TO_ANIMATE, string);
end

function CombatText_RemoveMessage(string)
	for index, value in COMBAT_TEXT_TO_ANIMATE do
		if ( value == string ) then
			tremove(COMBAT_TEXT_TO_ANIMATE, index);
			string:SetAlpha(0);
			string:Hide();
			string:SetPoint("TOP", UIParent, "BOTTOM", COMBAT_TEXT_LOCATIONS.startX, COMBAT_TEXT_LOCATIONS.startY);
			break;
		end
	end
end

function CombatText_GetAvailableString()
	local string;
	for i=1, NUM_COMBAT_TEXT_LINES do
		string = getglobal("CombatText"..i);
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
		string = getglobal("CombatText"..i);
		string:SetAlpha(0);
		string:Hide();
		string:SetPoint("TOP", UIParent, "BOTTOM", COMBAT_TEXT_LOCATIONS.startX, COMBAT_TEXT_LOCATIONS.startY);
	end
end

function CombatText_UpdateDisplayedMessages()
	-- Unregister events if combat text is disabled
	if ( SHOW_COMBAT_TEXT == "0" ) then
		CombatText:UnregisterEvent("COMBAT_TEXT_UPDATE");
		CombatText:UnregisterEvent("UNIT_HEALTH");
		CombatText:UnregisterEvent("UNIT_MANA");
		CombatText:UnregisterEvent("PLAYER_REGEN_DISABLED");
		CombatText:UnregisterEvent("PLAYER_REGEN_ENABLED");
		CombatText:UnregisterEvent("PLAYER_COMBO_POINTS");
		return;
	else
		CombatText:RegisterEvent("COMBAT_TEXT_UPDATE");
		CombatText:RegisterEvent("UNIT_HEALTH");
		CombatText:RegisterEvent("UNIT_MANA");
		CombatText:RegisterEvent("PLAYER_REGEN_DISABLED");
		CombatText:RegisterEvent("PLAYER_REGEN_ENABLED");
		CombatText:RegisterEvent("PLAYER_COMBO_POINTS");
	end
	-- Update shown messages
	for index, value in COMBAT_TEXT_TYPE_INFO do
		if ( value.var ) then
			if ( getglobal(value.var) == "1" ) then
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
			startY = 384,
			endX = 0,
			endY = 609
		};
		
	elseif ( COMBAT_TEXT_FLOAT_MODE == "2" ) then	
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll;
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384,
			endX = 0,
			endY =  159
		};
	else
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_FountainScroll;
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384,
			endX = 0,
			endY = 609
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
	local xPos = value.xDir*(value.startX+radius*cos(90*value.scrollTime/COMBAT_TEXT_SCROLLSPEED))-value.xDir*radius;
	local yPos = value.startY+radius*sin(90*value.scrollTime/COMBAT_TEXT_SCROLLSPEED);
	return xPos, yPos;
end
