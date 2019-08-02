BUFF_FLASH_TIME_ON = 0.75;
BUFF_FLASH_TIME_OFF = 0.75;
BUFF_MIN_ALPHA = 0.3;
BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;
BUFFS_PER_ROW = 8;
BUFF_MAX_DISPLAY = 32;
BUFF_ACTUAL_DISPLAY = 0;
DEBUFF_MAX_DISPLAY = 16
DEBUFF_ACTUAL_DISPLAY = 0;
BUFF_ROW_SPACING = 15;
NUM_TEMP_ENCHANT_FRAMES = 3;
BUFF_BUTTON_HEIGHT = 30;
BUFF_FRAME_BASE_EXTENT = 13;	-- pixels from the top of the screen to the top edge of the buff frame, needed to calculate extent for UIParentManageFramePositions
BUFF_FRAME_HEIGHT = 50;
BUFF_HORIZ_SPACING = -5;
DEFAULT_AURA_DURATION_FONT = "GameFontNormalSmall";


DebuffTypeColor = { };
DebuffTypeColor["none"]	= { r = 0.80, g = 0, b = 0 };
DebuffTypeColor["Magic"]	= { r = 0.20, g = 0.60, b = 1.00 };
DebuffTypeColor["Curse"]	= { r = 0.60, g = 0.00, b = 1.00 };
DebuffTypeColor["Disease"]	= { r = 0.60, g = 0.40, b = 0 };
DebuffTypeColor["Poison"]	= { r = 0.00, g = 0.60, b = 0 };
DebuffTypeColor[""]	= DebuffTypeColor["none"];

DebuffTypeSymbol = { };
DebuffTypeSymbol["Magic"] = DEBUFF_SYMBOL_MAGIC;
DebuffTypeSymbol["Curse"] = DEBUFF_SYMBOL_CURSE;
DebuffTypeSymbol["Disease"] = DEBUFF_SYMBOL_DISEASE;
DebuffTypeSymbol["Poison"] = DEBUFF_SYMBOL_POISON;

function BuffFrame_OnLoad(self)
	self.BuffFrameUpdateTime = 0;
	self.BuffFrameFlashTime = 0;
	self.BuffFrameFlashState = 1;
	self.BuffAlphaValue = 1;
	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.numEnchants = 0;
	self.bottomEdgeExtent = 0;
end

function BuffFrame_OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "UNIT_AURA" ) then
		if ( unit == PlayerFrame.unit ) then
			BuffFrame_Update();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		BuffFrame_Update();
	end
end

function BuffFrame_OnUpdate(self, elapsed)
	if ( self.BuffFrameUpdateTime > 0 ) then
		self.BuffFrameUpdateTime = self.BuffFrameUpdateTime - elapsed;
	else
		self.BuffFrameUpdateTime = self.BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
	end

	self.BuffFrameFlashTime = self.BuffFrameFlashTime - elapsed;
	if ( self.BuffFrameFlashTime < 0 ) then
		local overtime = -self.BuffFrameFlashTime;
		if ( self.BuffFrameFlashState == 0 ) then
			self.BuffFrameFlashState = 1;
			self.BuffFrameFlashTime = BUFF_FLASH_TIME_ON;
		else
			self.BuffFrameFlashState = 0;
			self.BuffFrameFlashTime = BUFF_FLASH_TIME_OFF;
		end
		if ( overtime < self.BuffFrameFlashTime ) then
			self.BuffFrameFlashTime = self.BuffFrameFlashTime - overtime;
		end
	end

	if ( self.BuffFrameFlashState == 1 ) then
		self.BuffAlphaValue = (BUFF_FLASH_TIME_ON - self.BuffFrameFlashTime) / BUFF_FLASH_TIME_ON;
	else
		self.BuffAlphaValue = self.BuffFrameFlashTime / BUFF_FLASH_TIME_ON;
	end
	self.BuffAlphaValue = (self.BuffAlphaValue * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA;
end

do
	local function BuffFrame_UpdateWithSlots(buttonName, unit, filter, maxCount)
		local index = 1;
		AuraUtil.ForEachAura(unit, filter, maxCount, function(...)
			local _, texture, count, debuffType, duration, expirationTime, _, _, _, _, _, _, _, _, timeMod = ...;
			AuraButton_Update(buttonName, index, filter, texture, count, debuffType, duration, expirationTime, timeMod);
			index = index + 1;
			return index > maxCount;
		end);

		local count = index - 1;

		-- Hide remaining frames
		local buffArray = BuffFrame[buttonName];
		if buffArray then
			for i = index,#buffArray do
				buffArray[i]:Hide();
			end
		end

		return count;
	end

	function BuffFrame_Update()
		BUFF_ACTUAL_DISPLAY = BuffFrame_UpdateWithSlots("BuffButton", PlayerFrame.unit, "HELPFUL", BUFF_MAX_DISPLAY);
		DEBUFF_ACTUAL_DISPLAY = BuffFrame_UpdateWithSlots("DebuffButton", PlayerFrame.unit, "HARMFUL", DEBUFF_MAX_DISPLAY);
	
		BuffFrame_UpdateAllBuffAnchors();
	end
end

function BuffFrame_UpdatePositions()
	if ( SHOW_BUFF_DURATIONS == "1" ) then
		BUFF_ROW_SPACING = 15;
	else
		BUFF_ROW_SPACING = 5;
	end
	BuffFrame_Update();
end

function AuraButton_Update(buttonName, index, filter, texture, count, debuffType, duration, expirationTime, timeMod)
	local unit = PlayerFrame.unit;
	local buffArray = BuffFrame[buttonName];
	local buff = buffArray and BuffFrame[buttonName][index];

	if AuraButton_Update_BackwardsCompat then
		if not texture then
			texture, count, debuffType, duration, expirationTime, timeMod = AuraButton_Update_BackwardsCompat(buff, unit, index, filter);
			-- backwards compatibility -- will be removed in a future update
			if not texture then
				return;
			end
		end
	end

	local helpful = (filter == "HELPFUL");

	-- If button doesn't exist make it
	if ( not buff ) then
		local template = helpful and "BuffButtonTemplate" or "DebuffButtonTemplate";
		local buffName = buttonName..index;
		buff = CreateFrame("Button", buffName, BuffFrame, template);
		buff.parent = BuffFrame;
	end
	-- Setup Buff
	buff:SetID(index);
	buff.unit = unit;
	buff.filter = filter;
	buff:SetAlpha(1.0);
	buff.exitTime = nil;
	buff:Show();
	-- Set filter-specific attributes
	if ( not helpful ) then
		-- Anchor Debuffs
		DebuffButton_UpdateAnchors(buttonName, index);

		-- Set color of debuff border based on dispel class.
		if ( buff.Border ) then
			local color;
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					buff.symbol:Show();
					buff.symbol:SetText(DebuffTypeSymbol[debuffType] or "");
				else
					buff.symbol:Hide();
				end
			else
				buff.symbol:Hide();
				color = DebuffTypeColor["none"];
			end
			buff.Border:SetVertexColor(color.r, color.g, color.b);
		end
	end

	if ( duration > 0 and expirationTime ) then
		if ( SHOW_BUFF_DURATIONS == "1" ) then
			buff.duration:Show();
		else
			buff.duration:Hide();
		end
			
		local timeLeft = (expirationTime - GetTime());
		if(timeMod > 0) then
			buff.timeMod = timeMod;
			timeLeft = timeLeft / timeMod;
		end

		if ( not buff.timeLeft ) then
			buff.timeLeft = timeLeft;
			buff:SetScript("OnUpdate", AuraButton_OnUpdate);
		else
			buff.timeLeft = timeLeft;
		end

		buff.expirationTime = expirationTime;	
	else
		buff.duration:Hide();
		if ( buff.timeLeft ) then
			buff:SetScript("OnUpdate", nil);
		end
		buff.timeLeft = nil;
	end

	-- Set Texture
	buff.Icon:SetTexture(texture);

	-- Set the number of applications of an aura
	if ( count > 1 ) then
		buff.count:SetText(count);
		buff.count:Show();
	else
		buff.count:Hide();
	end

	-- Refresh tooltip
	if ( GameTooltip:IsOwned(buff) ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, filter);
	end
end

function AuraButton_OnUpdate(self)
	local index = self:GetID();
	if ( self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	securecall("AuraButton_UpdateDuration", self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev 
	
	-- Update our timeLeft
	local timeLeft = self.expirationTime - GetTime();
	if ( self.timeMod > 0 ) then
		timeLeft = timeLeft / self.timeMod;
	end
	self.timeLeft = max( timeLeft, 0 );
	
	if ( SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD ) then
		local aboveMinThreshold = self.timeLeft > SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD;
		local belowMaxThreshold = not SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD or self.timeLeft < SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD;
		if ( aboveMinThreshold and belowMaxThreshold ) then
			self.duration:SetFontObject(SMALLER_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM", 0, SMALLER_AURA_DURATION_OFFSET_Y);
		else
			self.duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM");
		end
	end

	if ( BuffFrame.BuffFrameUpdateTime > 0 ) then
		return;
	end
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, self.filter);
	end
end

function AuraButton_UpdateDuration(auraButton, timeLeft)
	local duration = auraButton.duration;
	if ( SHOW_BUFF_DURATIONS == "1" and timeLeft ) then
		duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));
		if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
			duration:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		duration:Show();
	else
		duration:Hide();
	end
end

function BuffButton_OnLoad(self)
	self:RegisterForClicks("RightButtonUp");
end

function BuffButton_OnClick(self)
	CancelUnitBuff(self.unit, self:GetID(), self.filter);
end

function BuffFrame_UpdateAllBuffAnchors()
	local buff, previousBuff, aboveBuff, index;
	local numBuffs = 0;
	local numAuraRows = 0;
	local slack = BuffFrame.numEnchants;
	
	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = BuffFrame.BuffButton[i];
		numBuffs = numBuffs + 1;
		index = numBuffs + slack;
		if ( buff.parent ~= BuffFrame ) then
			buff.count:SetFontObject(NumberFontNormal);
			buff:SetParent(BuffFrame);
			buff.parent = BuffFrame;
		end
		buff:ClearAllPoints();
		if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
			-- New row
			numAuraRows = numAuraRows + 1;
			buff:SetPoint("TOPRIGHT", aboveBuff, "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING);
			aboveBuff = buff;
		elseif ( index == 1 ) then
			numAuraRows = 1;
			buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
			aboveBuff = buff;
		else
			if ( numBuffs == 1 ) then
				if ( BuffFrame.numEnchants > 0 ) then
					buff:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPLEFT", BUFF_HORIZ_SPACING, 0);
					aboveBuff = TemporaryEnchantFrame;
				else
					buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
				end
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", BUFF_HORIZ_SPACING, 0);
			end
		end
		previousBuff = buff;
	end

	-- check if we need to manage frames
	local bottomEdgeExtent = BUFF_FRAME_BASE_EXTENT;
	if ( DEBUFF_ACTUAL_DISPLAY > 0 ) then
		bottomEdgeExtent = bottomEdgeExtent + DebuffButton1.offsetY + BUFF_FRAME_HEIGHT + ceil(DEBUFF_ACTUAL_DISPLAY / BUFFS_PER_ROW) * (BUFF_BUTTON_HEIGHT + BUFF_ROW_SPACING);
	else
		bottomEdgeExtent = bottomEdgeExtent + numAuraRows * (BUFF_BUTTON_HEIGHT + BUFF_ROW_SPACING);
	end
	if ( BuffFrame.bottomEdgeExtent ~= bottomEdgeExtent ) then
		BuffFrame.bottomEdgeExtent = bottomEdgeExtent;
		UIParent_ManageFramePositions();
	end
end


function DebuffButton_UpdateAnchors(buttonName, index)
	local numBuffs = BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants;
	
	local rows = ceil(numBuffs/BUFFS_PER_ROW);
	local buff = BuffFrame[buttonName][index];

	-- Position debuffs
	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		buff:SetPoint("TOP", BuffFrame[buttonName][index-BUFFS_PER_ROW], "BOTTOM", 0, -BUFF_ROW_SPACING);
	elseif ( index == 1 ) then
		if ( rows < 2 ) then
			DebuffButton1.offsetY = 1*((2*BUFF_ROW_SPACING)+BUFF_BUTTON_HEIGHT);
		else
			DebuffButton1.offsetY = rows*(BUFF_ROW_SPACING+BUFF_BUTTON_HEIGHT);
		end
		buff:SetPoint("TOPRIGHT", BuffFrame, "BOTTOMRIGHT", 0, -DebuffButton1.offsetY);
	else
		buff:SetPoint("RIGHT", BuffFrame[buttonName][index-1], "LEFT", -5, 0);
	end
end


function TemporaryEnchantFrame_Hide()
	if ( BuffFrame.numEnchants > 0 ) then
		BuffFrame.numEnchants = 0;
		BuffFrame_Update();		
	end
	TempEnchant1:Hide();
	TempEnchant1Duration:Hide();
	TempEnchant2:Hide();
	TempEnchant2Duration:Hide();
	TempEnchant3:Hide();
	TempEnchant3Duration:Hide();
end

function TemporaryEnchantFrame_OnUpdate(self, elapsed)
	if ( not PlayerFrame.unit or PlayerFrame.unit ~= "player" ) then
		-- don't show temporary enchants when the player isn't controlling himself
		TemporaryEnchantFrame_Hide();
		return;
	end

	TemporaryEnchantFrame_Update(GetWeaponEnchantInfo());
end

local textureMapping = {
	[1] = 16,	--Main hand
	[2] = 17,	--Off-hand
	[3] = 18,	--Ranged
};

function TemporaryEnchantFrame_Update(...)
	local RETURNS_PER_ITEM = 4;
	local numVals = select("#", ...);
	local numItems = numVals / RETURNS_PER_ITEM;

	if ( numItems == 0 ) then
		TemporaryEnchantFrame_Hide();
		return;
	end
	
	local enchantIndex = 0;
	for itemIndex = numItems, 1, -1 do	--Loop through the items from the back.
		local hasEnchant, enchantExpiration, enchantCharges = select(RETURNS_PER_ITEM * (itemIndex - 1) + 1, ...);
		if ( hasEnchant ) then
			enchantIndex = enchantIndex + 1;
			local enchantButton = TemporaryEnchantFrame.TempEnchant[enchantIndex];
			local textureName = GetInventoryItemTexture("player", textureMapping[itemIndex]);
			enchantButton:SetID(textureMapping[itemIndex]);
			enchantButton.Icon:SetTexture(textureName);
			enchantButton:Show();

			-- Show buff durations if necessary
			if ( enchantExpiration ) then
				enchantExpiration = enchantExpiration/1000;
			end
			AuraButton_UpdateDuration(enchantButton, enchantExpiration);

			-- Handle flashing
			if ( enchantExpiration and enchantExpiration < BUFF_WARNING_TIME ) then
				enchantButton:SetAlpha(BuffFrame.BuffAlphaValue);
			else
				enchantButton:SetAlpha(1.0);
			end
		end
	end
	
	--Hide unused enchants
	for i=enchantIndex+1, NUM_TEMP_ENCHANT_FRAMES do
		TemporaryEnchantFrame.TempEnchant[i]:Hide();
		TemporaryEnchantFrame.TempEnchant[i].duration:Hide();
	end

	-- Position buff frame
	TemporaryEnchantFrame:SetWidth(enchantIndex * 32);
	if ( BuffFrame.numEnchants ~= enchantIndex ) then
		BuffFrame.numEnchants = enchantIndex;
		BuffFrame_Update();
	end
end

function TempEnchantButton_OnLoad(self)
	self:RegisterForClicks("RightButtonUp");
end

function TempEnchantButton_OnUpdate(self, elapsed)
	-- Update duration
	if ( GameTooltip:IsOwned(self) ) then
		TempEnchantButton_OnEnter(self);
	end
end

function TempEnchantButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetInventoryItem("player", self:GetID());
end

function TempEnchantButton_OnClick(self, button)
	if ( self:GetID() == 16 ) then
		CancelItemTempEnchantment(1);
	elseif ( self:GetID() == 17 ) then
		CancelItemTempEnchantment(2);
	elseif ( self:GetID() == 18 ) then
		CancelItemTempEnchantment(3);
	end
end
