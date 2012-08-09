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
CONSOLIDATED_BUFFS_PER_ROW = 4;
CONSOLIDATED_BUFF_ROW_HEIGHT = 23;
NUM_TEMP_ENCHANT_FRAMES = 3;
BUFF_BUTTON_HEIGHT = 30;
BUFF_FRAME_BASE_EXTENT = 13;	-- pixels from the top of the screen to the top edge of the buff frame, needed to calculate extent for UIParentManageFramePositions
BUFF_HORIZ_SPACING = -5;


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

local consolidatedBuffs = { };

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
		if ShouldShowConsolidatedBuffFrame() then
			ConsolidatedBuffs:Show();
		else
			ConsolidatedBuffs:Hide();
		end
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


function BuffFrame_Update()
	-- Handle Buffs
	BUFF_ACTUAL_DISPLAY = 0;
	for i=1, BUFF_MAX_DISPLAY do
		if ( AuraButton_Update("BuffButton", i, "HELPFUL") ) then
			BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY + 1;
		end
	end
	
	-- Handle debuffs
	DEBUFF_ACTUAL_DISPLAY = 0;
	for i=1, DEBUFF_MAX_DISPLAY do
		if ( AuraButton_Update("DebuffButton", i, "HARMFUL") ) then
			DEBUFF_ACTUAL_DISPLAY = DEBUFF_ACTUAL_DISPLAY + 1;
		end
	end
	
	BuffFrame_UpdateAllBuffAnchors();
	RaidBuffTray_Update();
end

function RaidBuffTray_Update()
	local numBufs = 0
	local buffmask, buffcount = GetRaidBuffInfo();
	if (buffmask == nil) then
		return;
	end

	local mask = 1;
	for i=1,NUM_LE_RAID_BUFF_TYPES do
		local name, rank, texture, duration, expiration, spellId, slot = GetRaidBuffTrayAuraInfo(i);
		local buff = ConsolidatedBuffsTooltip["Buff"..i];
		if name then  
			buff.index = slot;
			buff.name = name;
			buff.icon:SetTexture(texture);
			buff.label:SetFontObject(GameFontNormalSmall);
			numBufs = numBufs + 1;
		else
			buff.index = nil;
			buff.name = nil;
			buff.icon:SetTexture("Interface\\Common\\buff-bg");
			if (bit.band(buffmask, mask ) > 0) then
				buff.label:SetFontObject(GameFontHighlightSmall);			
			else
				buff.label:SetFontObject(GameFontDisableSmall);			
			end
			buff.label:SetText(buff.labelString);
		end
		mask = bit.lshift(mask, 1);
	end
	ConsolidatedBuffsCount:SetText(numBufs.."/"..max(numBufs,buffcount));
end

function RaidTray_Buff_OnUpdate(self)
	local index = self:GetID();
	if ( self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	RaidTray_Buff_UpdateDuration(self, self.timeLeft)
	self.timeLeft = max(self.expirationTime - GetTime(), 0);

	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitBuff(PlayerFrame.unit, self.index);
	end
end

function RaidTray_Buff_UpdateDuration(auraButton, timeLeft)
	local duration = auraButton.duration;
	if ( SHOW_BUFF_DURATIONS == "1" and timeLeft ) then
		local durationText = string.format(SecondsToTimeAbbrev(timeLeft));
		if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
			durationText = HIGHLIGHT_FONT_COLOR_CODE..durationText.."|r"
		end
		auraButton.label:SetText(durationText.."  "..auraButton.labelString);
	else
		auraButton.label:SetText(auraButton.labelString);
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

function AuraButton_Update(buttonName, index, filter)
	local unit = PlayerFrame.unit;
	local name, rank, texture, count, debuffType, duration, expirationTime, _, _, shouldConsolidate, spellId = UnitAura(unit, index, filter);
	local buffName = buttonName..index;
	local buff = _G[buffName];
	
	if ( not name ) then
		-- No buff so hide it if it exists
		if ( buff ) then
			buff:Hide();
			buff.duration:Hide();
		end
		return nil;
	else
		local helpful = (filter == "HELPFUL");

		-- If button doesn't exist make it
		if ( not buff ) then
			if ( helpful ) then
				buff = CreateFrame("Button", buffName, BuffFrame, "BuffButtonTemplate");
			else
				buff = CreateFrame("Button", buffName, BuffFrame, "DebuffButtonTemplate");
			end
			buff.parent = BuffFrame;
		end
		-- Setup Buff
		buff:SetID(index);
		buff.unit = unit;
		buff.filter = filter;
		buff:SetAlpha(1.0);
		buff.exitTime = nil;
		buff.consolidated = nil;
		buff:Show();
		-- Set filter-specific attributes
		if ( not helpful ) then
			-- Anchor Debuffs
			DebuffButton_UpdateAnchors(buttonName, index);

			-- Set color of debuff border based on dispel class.
			local debuffSlot = _G[buffName.."Border"];
			if ( debuffSlot ) then
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
				debuffSlot:SetVertexColor(color.r, color.g, color.b);
			end
		end

		if ( duration > 0 and expirationTime ) then
			if ( SHOW_BUFF_DURATIONS == "1" ) then
				buff.duration:Show();
			else
				buff.duration:Hide();
			end

			if ( not buff.timeLeft ) then
				buff.timeLeft = expirationTime - GetTime();
				buff:SetScript("OnUpdate", AuraButton_OnUpdate);
			else
				buff.timeLeft = expirationTime - GetTime();
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
		local icon = _G[buffName.."Icon"];
		icon:SetTexture(texture);

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

		if ( shouldConsolidate  and ShouldShowConsolidatedBuffFrame() ) then		
			buff.consolidated = true; --TODO: Consider ignoreing these alltogether.
			buff:Hide();
		end
	end
	return 1;
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
	self.timeLeft = max(self.expirationTime - GetTime(), 0);

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

function ConsolidatedBuffButton_OnClick(self)
	if ( self.name ) then
		CancelUnitBuff(PlayerFrame.unit, self.name);
	end
end

function BuffFrame_UpdateAllBuffAnchors()
	local buff, previousBuff, aboveBuff, index;
	local numBuffs = 0;
	local numAuraRows = 0;
	local slack = BuffFrame.numEnchants;
	
	if ShouldShowConsolidatedBuffFrame() then
		slack = slack + 1;	-- one icon for all consolidated buffs
	end
	
	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G["BuffButton"..i];
		if ( not buff.consolidated ) then
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
				if ( index == BUFFS_PER_ROW+1 ) then
					buff:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -BUFF_ROW_SPACING);
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -BUFF_ROW_SPACING);
				end
				aboveBuff = buff;
			elseif ( index == 1 ) then
				numAuraRows = 1;
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
			else
				if ( numBuffs == 1 ) then
					if ( BuffFrame.numEnchants > 0 ) then
						buff:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPLEFT", BUFF_HORIZ_SPACING, 0);
					else
						buff:SetPoint("TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", BUFF_HORIZ_SPACING, 0);
					end
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", BUFF_HORIZ_SPACING, 0);
				end
			end
			previousBuff = buff;
		end
	end

	-- check if we need to manage frames
	local bottomEdgeExtent = BUFF_FRAME_BASE_EXTENT;
	if ( DEBUFF_ACTUAL_DISPLAY > 0 ) then
		bottomEdgeExtent = bottomEdgeExtent + DebuffButton1.offsetY + BUFF_BUTTON_HEIGHT + ceil(DEBUFF_ACTUAL_DISPLAY / BUFFS_PER_ROW) * (BUFF_BUTTON_HEIGHT + BUFF_ROW_SPACING);
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
	if ShouldShowConsolidatedBuffFrame() then
		numBuffs = numBuffs + 1; -- consolidated buffs
	end
	
	local rows = ceil(numBuffs/BUFFS_PER_ROW);
	local buff = _G[buttonName..index];

	-- Position debuffs
	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		buff:SetPoint("TOP", _G[buttonName..(index-BUFFS_PER_ROW)], "BOTTOM", 0, -BUFF_ROW_SPACING);
	elseif ( index == 1 ) then
		if ( rows < 2 ) then
			DebuffButton1.offsetY = 1*((2*BUFF_ROW_SPACING)+BUFF_BUTTON_HEIGHT);
		else
			DebuffButton1.offsetY = rows*(BUFF_ROW_SPACING+BUFF_BUTTON_HEIGHT);
		end
		buff:SetPoint("TOPRIGHT", ConsolidatedBuffs, "BOTTOMRIGHT", 0, -DebuffButton1.offsetY);
	else
		buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -5, 0);
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
	local RETURNS_PER_ITEM = 3;
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
			local enchantButton = _G["TempEnchant"..enchantIndex];
			local textureName = GetInventoryItemTexture("player", textureMapping[itemIndex]);
			enchantButton:SetID(textureMapping[itemIndex]);
			_G[enchantButton:GetName().."Icon"]:SetTexture(textureName);
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
		_G["TempEnchant"..i]:Hide();
		_G["TempEnchant"..i.."Duration"]:Hide();
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

function ConsolidatedBuffs_OnUpdate(self)
	-- tooltip stuff
	-- need 1-pixel outer padding because otherwise at certain resolutions OnEnter will trigger with IsMouseOver returning false
	if ( self.mousedOver and not self:IsMouseOver(1, -1, -1, 1) ) then
		self.mousedOver = nil;
		if ( not ConsolidatedBuffsTooltip:IsMouseOver() ) then
			ConsolidatedBuffsTooltip:Hide();
		end
	end
end

function ConsolidatedBuffs_OnShow()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", -6, 0);
	BuffFrame_Update();
end

function ConsolidatedBuffs_OnEnter(self)			
	ConsolidatedBuffsTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 1);
	ConsolidatedBuffsTooltip:Show();
	ConsolidatedBuffs.mousedOver = true;
end

function ConsolidatedBuffs_OnHide(self)
	self.mousedOver = nil;	
	ConsolidatedBuffsTooltip:Hide();
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", ConsolidatedBuffs, "TOPRIGHT", 0, 0);
	BuffFrame_Update();
end


function ShouldShowConsolidatedBuffFrame()
	return IsInGroup() and GetCVarBool("consolidateBuffs");
end
