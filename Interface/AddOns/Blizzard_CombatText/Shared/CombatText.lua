local PLUNDERSTORM_CURRENCY = 3011;

CombatTextMixin = {};

function CombatTextMixin:OnLoad()
	self.fontStringPool = CreateFontStringPool(self, "BACKGROUND", nil, nil, Pool_HideAndSetToDefaults, CombatTextConstants.NumCombatTextLines);
	self.activeFontStrings = {};
	self.textSpacing = 10;
	self.textOffsetMax = 130;
	self.textLocations = {};
	self.textOffsetAdjustment = 80;
	self.textScaleY = 1;
	self.textScaleX = 1;
	self.scrollFunction = CombatTextUtil.StandardScroll;
	self.xDir = 1;

	local function OnValueChanged(_, _, value)
		CombatTextUtil.UpdateEventRegistration(self, value);
		if value then
			self:UpdateDisplayedMessages();
		end
	end

	Settings.SetOnValueChangedCallback("enableFloatingCombatText", OnValueChanged);

	CombatTextUtil.RegisterCachableCVars();
	CombatTextUtil.UpdateEventRegistration(self, C_CVar.GetCVarBool("enableFloatingCombatText"));
	self:UpdateDisplayedMessages();
end

function CombatTextMixin:OnEvent(event, ...)
	if ( not self:IsVisible() ) then
		self:ClearAnimationList();
		return;
	end

	local arg1, data, arg3, arg4 = ...;

	-- Set up the messageType
	local messageType, message;
	-- Set the message data
	local displayType = nil;

	if ( event == "UNIT_ENTERED_VEHICLE" ) then
		local unit, showVehicle = ...;
		if ( unit == "player" ) then
			if ( showVehicle ) then
				self.unit = "vehicle";
			else
				self.unit = "player";
			end
			C_CombatText.SetActiveUnit(self.unit);
		end
		return;
	elseif ( event == "UNIT_EXITING_VEHICLE" ) then
		if ( arg1 == "player" ) then
			self.unit = "player";
			C_CombatText.SetActiveUnit(self.unit);
		end
		return;
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == self.unit ) then
			if ( UnitHealth(self.unit)/UnitHealthMax(self.unit) <= CombatTextConstants.LowHealthThreshold ) then
				if ( not self.lowHealth ) then
					messageType = "HEALTH_LOW";
					self.lowHealth = 1;
				end
			else
				self.lowHealth = nil;
			end
		end

		-- Didn't meet any of the criteria so just return
		if ( not messageType ) then
			return;
		end
	elseif ( event == "UNIT_POWER_UPDATE" ) then
		if ( arg1 == self.unit ) then
			local powerType, powerToken = UnitPowerType(self.unit);
			local maxPower = UnitPowerMax(self.unit);
			local currentPower = UnitPower(self.unit);
			if ( maxPower ~= 0 and powerToken == "MANA" and (currentPower / maxPower) <= CombatTextConstants.LowManaThreshold ) then
				if ( not self.lowMana ) then
					messageType = "MANA_LOW";
					self.lowMana = 1;
				end
			else
				self.lowMana = nil;
			end
			if ( data == "COMBO_POINTS" ) then
				messageType, data, displayType = CombatTextUtil.GetComboPointsMessageInfo(messageType, data, displayType);
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
	elseif ( event == "COMBAT_TEXT_UPDATE" ) then
		data, arg3, arg4 = C_CombatText.GetCurrentEventInfo();
		messageType = arg1;
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		messageType = "RUNE";
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		if arg1 == PLUNDERSTORM_CURRENCY then
			messageType = "PLUNDER_UPDATE";
		end
	else
		messageType = event;
	end

	-- Process the messageType and format the message
	--Check to see if there's a COMBAT_TEXT_TYPE_INFO associated with this combat message
	local info = CombatTextTypeInfo[messageType];
	if ( not info ) then
		info = {r = 1, g =1, b = 1};
	end
	-- See if we should display the message or not
	if ( not info.show ) then
		-- When Resists aren't being shown, partial resists should display as Damage
		if (info.cvar == "floatingCombatTextDamageReduction" and arg3) then
			if ( strsub(messageType, 1, 5) == "SPELL" ) then
				messageType = arg4 and "SPELL_DAMAGE_CRIT" or "SPELL_DAMAGE";
			else
				messageType = arg4 and "DAMAGE_CRIT" or "DAMAGE";
			end
		else
			return;
		end
	end

	local isStaggered = info.isStaggered;
	if ( messageType == "" ) then

	elseif ( messageType == "DAMAGE_CRIT" or messageType == "SPELL_DAMAGE_CRIT" ) then
		displayType = "crit";
		message = "-"..BreakUpLargeNumbers(data);
	elseif ( messageType == "DAMAGE" or messageType == "SPELL_DAMAGE" or messageType == "DAMAGE_SHIELD" ) then
		if (data == 0) then
			return
		end
		message = "-"..BreakUpLargeNumbers(data);
		if(arg1 and arg1 == "BLOCK" and arg3 and arg3 > 0) then
			message = CombatTextUtil.GetFormattedBlockMessage(message, arg3);
		end
	elseif ( messageType == "SPELL_CAST" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_START" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_START_HARMFUL" ) then
		message = "<"..data..">";
	elseif ( messageType == "SPELL_AURA_END" or messageType == "SPELL_AURA_END_HARMFUL" ) then
		message = format(AURA_END, data);
	elseif ( messageType == "HEAL" or messageType == "PERIODIC_HEAL") then
		if ( CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and messageType == "HEAL" and UnitName(self.unit) ~= data ) then
			message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."]";
		else
			message = "+"..BreakUpLargeNumbers(arg3);
		end
	elseif ( messageType == "HEAL_ABSORB" or messageType == "PERIODIC_HEAL_ABSORB") then
		if ( CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and messageType == "HEAL_ABSORB" and UnitName(self.unit) ~= data ) then
			message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."] "..format(ABSORB_TRAILER, arg4);
		else
			message = "+"..BreakUpLargeNumbers(arg3).." "..format(ABSORB_TRAILER, arg4);
		end
	elseif ( messageType == "HEAL_CRIT" or messageType == "PERIODIC_HEAL_CRIT" ) then
		displayType = "crit";
		if ( CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data ) then
			message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."]";
		else
			message = "+"..BreakUpLargeNumbers(arg3);
		end
	elseif ( messageType == "HEAL_CRIT_ABSORB" ) then
		displayType = "crit";
		if ( CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data ) then
			message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."] "..format(ABSORB_TRAILER, arg4);
		else
			message = "+"..BreakUpLargeNumbers(arg3).." "..format(ABSORB_TRAILER, arg4);
		end
	elseif ( messageType == "ENERGIZE" or messageType == "PERIODIC_ENERGIZE") then
		local count =  tonumber(data);
		if (count > 0 ) then
			data = "+"..BreakUpLargeNumbers(data);
		else
			return; --If we didnt actually gain anything, dont show it
		end
		if( arg3 == "MANA"
			or arg3 == "RAGE"
			or arg3 == "FOCUS"
			or arg3 == "ENERGY"
			or arg3 == "RUNIC_POWER"
			or arg3 == "DEMONIC_FURY") then
			message = data.." ".._G[arg3];
			info = CombatTextUtil.GetBasicPowerTypeColor(info, arg3);
		elseif ( arg3 == "HOLY_POWER"
				or arg3 == "SOUL_SHARDS"
				or arg3 == "CHI"
				or arg3 == "COMBO_POINTS"
				or arg3 == "ARCANE_CHARGES" ) then
			local numPower = UnitPower( "player" , CombatTextUtil.GetPowerEnumFromEnergizeString(arg3) );
			numPower = numPower + count;
			message = "<"..numPower.." ".._G[arg3]..">";
			info = PowerBarColor[arg3];
			--Display as crit if we're at max power
			if ( UnitPower( "player" , CombatTextUtil.GetPowerEnumFromEnergizeString(arg3)) == UnitPowerMax(self.unit, CombatTextUtil.GetPowerEnumFromEnergizeString(arg3))) then
				displayType = "crit";
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
	elseif ( messageType == "SPELL_MISFIRE" ) then
		message = COMBAT_TEXT_MISFIRE;
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
			message = CombatTextUtil.GetRunePowerUpdateMessage(arg1, info);
		else
			message = nil;
		end
	elseif (messageType == "ABSORB_ADDED") then
		if ( CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data ) then
			message = "+"..BreakUpLargeNumbers(arg3).."("..COMBAT_TEXT_ABSORB..")".." ["..data.."]";
		else
			message = "+"..BreakUpLargeNumbers(arg3).."("..COMBAT_TEXT_ABSORB..")";
		end
	elseif (messageType == "PLUNDER_UPDATE") then
		message = string.format(WOWLABS_CURRENCY_PICKUP, arg3);
	else
		message = _G["COMBAT_TEXT_"..messageType];
		if ( not message ) then
			message = _G[messageType];
		end
	end

	-- Add the message
	if ( message ) then
		self:AddMessage(message, self.scrollFunction, info.r, info.g, info.b, displayType, isStaggered);
	end
end

function CombatTextMixin:OnUpdate(elapsed)
	local alpha, xPos, yPos;
	for index, value in self:EnumerateActiveFontStrings() do
		if ( value.scrollTime >= CombatTextConstants.MessageScrollSpeed ) then
			self:ReleaseFontString(value);
		else
			value.scrollTime = value.scrollTime + elapsed;
			-- Calculate x and y positions
			xPos, yPos = value.scrollFunction(self, value);

			-- Record Y position
			value.yPos = yPos;

			value:SetPoint("TOP", WorldFrame, "BOTTOM", xPos, yPos);
			if ( value.scrollTime >= CombatTextConstants.MessageFadeOutTime ) then
				alpha = 1-((value.scrollTime-CombatTextConstants.MessageFadeOutTime)/(CombatTextConstants.MessageScrollSpeed-CombatTextConstants.MessageFadeOutTime));
				alpha = max(alpha, 0);
				value:SetAlpha(alpha);
			end

			-- Handle crit
			if ( value.isCrit ) then
				if ( value.scrollTime <= CombatTextConstants.CriticalHitScaleTime ) then
					value:SetTextHeight(floor(CombatTextConstants.CriticalHitMinHeight+((CombatTextConstants.CriticalHitMaxHeight-CombatTextConstants.CriticalHitMinHeight)*value.scrollTime/CombatTextConstants.CriticalHitScaleTime)));
				elseif ( value.scrollTime <= CombatTextConstants.CriticalHitShrinkTime ) then
					value:SetTextHeight(floor(CombatTextConstants.CriticalHitMaxHeight - ((CombatTextConstants.CriticalHitMaxHeight-CombatTextConstants.CriticalHitMinHeight)*(value.scrollTime - CombatTextConstants.CriticalHitScaleTime)/(CombatTextConstants.CriticalHitShrinkTime - CombatTextConstants.CriticalHitScaleTime))));
				else
					value.isCrit = nil;
				end
			end
		end
	end

	if ( (self.textScaleY ~= WorldFrame:GetHeight() / 768) or (self.textScaleX ~= WorldFrame:GetWidth() / 1024) ) then
		self:UpdateDisplayedMessages();
	end
end

function CombatTextMixin:AddMessage(message, scrollFunction, r, g, b, displayType, isStaggered)
	local fontString = self:AcquireFontString();

	if not fontString then
		return;
	end

	fontString:SetText(message);
	fontString:SetTextColor(r, g, b);
	fontString.scrollTime = 0;
	if ( displayType == "crit" ) then
		fontString.scrollFunction = CombatTextUtil.StandardScroll;
	else
		fontString.scrollFunction = scrollFunction;
	end

	-- See which direction the message should flow
	local yDir;
	local lowestMessage;
	local useXadjustment = 0;
	if ( self.textLocations.startY < self.textLocations.endY ) then
		-- Flowing up
		lowestMessage = fontString:GetBottom();
		-- Find lowest message to anchor to
		for index, value in self:EnumerateActiveFontStrings() do
			if ( lowestMessage >= value.yPos - 16 - self.textSpacing) then
				lowestMessage = value.yPos - 16 - self.textSpacing;
			end
		end
		if ( lowestMessage < (self.textLocations.startY - self.textOffsetMax) ) then
			if ( displayType == "crit" ) then
				lowestMessage = fontString:GetBottom();
			else
				self.textOffsetAdjustment = self.textOffsetAdjustment * -1;
				useXadjustment = 1;
				lowestMessage = self.textLocations.startY - self.textOffsetMax;
			end
		end
	else
		-- Flowing down
		lowestMessage = fontString:GetTop();
		-- Find lowest message to anchor to
		for index, value in self:EnumerateActiveFontStrings() do
			if ( lowestMessage <= value.yPos + 16 + self.textSpacing) then
				lowestMessage = value.yPos + 16 + self.textSpacing;
			end
		end
		if ( lowestMessage > (self.textLocations.startY + self.textOffsetMax) ) then
			if ( displayType == "crit" ) then
				lowestMessage = fontString:GetTop();
			else
				self.textOffsetAdjustment = self.textOffsetAdjustment * -1;
				useXadjustment = 1;
				lowestMessage = self.textLocations.startY + self.textOffsetMax;
			end
		end
	end

	-- Handle crits
	if ( displayType == "crit" ) then
		fontString.endY = self.textLocations.startY;
		fontString.isCrit = 1;
		fontString:SetTextHeight(CombatTextConstants.CriticalHitMinHeight);
	elseif ( displayType == "sticky" ) then
		fontString.endY = self.textLocations.startY;
		fontString:SetTextHeight(CombatTextConstants.MessageHeight);
	else
		fontString.endY = self.textLocations.endY;
		fontString:SetTextHeight(CombatTextConstants.MessageHeight);
	end

	-- Stagger the text if flagged
	local staggerAmount = 0;
	if ( isStaggered ) then
		staggerAmount = fastrandom(0, CombatTextConstants.StaggerRange) - CombatTextConstants.StaggerRange/2;
	end

	-- Alternate x direction
	self.xDir = self.xDir * -1;
	if ( useXadjustment == 1 ) then
		if ( self.textOffsetAdjustment > 0 ) then
			self.xDir = -1;
		else
			self.xDir = 1;
		end
	end
	fontString.xDir = self.xDir;
	fontString.startX = self.textLocations.startX + staggerAmount + (useXadjustment * self.textOffsetAdjustment);
	fontString.startY = lowestMessage;
	fontString.yPos = lowestMessage;
	fontString:ClearAllPoints();
	fontString:SetPoint("TOP", WorldFrame, "BOTTOM", fontString.startX, lowestMessage);
	fontString:SetAlpha(1);
	fontString:Show();
	table.insert(self.activeFontStrings, fontString);
end

function CombatTextMixin:EnumerateActiveFontStrings()
	return ipairs(self.activeFontStrings);
end

function CombatTextMixin:ReleaseFontString(fontString)
	local index = tIndexOf(self.activeFontStrings, fontString);

	if index then
		self.fontStringPool:Release(fontString);
		table.remove(self.activeFontStrings, index);
	end
end

function CombatTextMixin:AcquireFontString()
	local fontString = self.fontStringPool:Acquire();

	if fontString then
		self:InitializeFontString(fontString);
		return fontString;
	end
end

function CombatTextMixin:InitializeFontString(fontString)
	fontString:SetFontObject(CombatTextFont);
	fontString:SetAlpha(0);
	fontString:SetPoint("TOP", WorldFrame, "BOTTOM", self.textLocations.startX, self.textLocations.startY);
end

function CombatTextMixin:ClearAnimationList()
	for _, fontString in self:EnumerateActiveFontStrings() do
		fontString:SetAlpha(0);
		fontString:Hide();
		fontString:SetPoint("TOP", WorldFrame, "BOTTOM", self.textLocations.startX, self.textLocations.startY);
	end
end

function CombatTextMixin:UpdateDisplayedMessages()
	-- set the unit to track
	if ( UnitHasVehicleUI("player") ) then
		self.unit = "vehicle";
	else
		self.unit = "player";
	end
	C_CombatText.SetActiveUnit(self.unit);

	-- Get scale
	self.textScaleY = WorldFrame:GetHeight() / 768;
	self.textScaleX = WorldFrame:GetWidth() / 1024;
	self.textSpacing = 10 * self.textScaleY;
	self.textOffsetMax = 130 * self.textScaleY;
	self.textOffsetAdjustment = 80 * self.textScaleX;

	-- Update shown messages
	for index, value in pairs(CombatTextTypeInfo) do
		if ( value.cvar ) then
			if ( CVarCallbackRegistry:GetCVarValueBool(value.cvar) ) then
				value.show = 1;
			else
				value.show = nil;
			end
		end
	end
	-- Update scrolldirection
	local textFloatMode = CVarCallbackRegistry:GetCVarValue("floatingCombatTextFloatMode");
	if ( textFloatMode == "1" ) then
		self.scrollFunction = CombatTextUtil.StandardScroll;
		self.textLocations = {
			startX = 0,
			startY = 384 * self.textScaleY,
			endX = 0,
			endY = 609 * self.textScaleY
		};

	elseif ( textFloatMode == "2" ) then
		self.scrollFunction = CombatTextUtil.StandardScroll;
		self.textLocations = {
			startX = 0,
			startY = 384 * self.textScaleY,
			endX = 0,
			endY =  159 * self.textScaleY
		};
	else
		self.scrollFunction = CombatTextUtil.FountainScroll;
		self.textLocations = {
			startX = 0,
			startY = 384 * self.textScaleY,
			endX = 0,
			endY = 609 * self.textScaleY
		};
	end
	self:ClearAnimationList();
end
