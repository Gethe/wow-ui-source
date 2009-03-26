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
BUFF_ROW_SPACING = 0;

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
	self:RegisterEvent("UNIT_AURA");
end

function BuffFrame_OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "UNIT_AURA" ) then
		if ( unit == PlayerFrame.unit ) then
			BuffFrame_Update();
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
	local name, rank, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter);

	local buffName = buttonName..index;
	local buff = _G[buffName];
	local buffDuration = _G[buffName.."Duration"];

	if ( not name ) then
		-- No buff so hide it if it exists
		if ( buff ) then
			buff:Hide();
			buffDuration:Hide();
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

			buffDuration = _G[buffName.."Duration"];
		end
		-- Setup Buff
		buff.namePrefix = buttonName;
		buff:SetID(index);
		buff.unit = unit;
		buff.filter = filter;
		buff:SetAlpha(1.0);
		buff:Show();

		-- Set filter-specific attributes
		if ( helpful ) then
			-- Anchor Buffs
			BuffButton_UpdateAnchors(buttonName, index);
		else
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
				buffDuration:Show();
			else
				buffDuration:Hide();
			end

			if ( not buff.timeLeft ) then
				buff.timeLeft = expirationTime - GetTime();
				buff:SetScript("OnUpdate", AuraButton_OnUpdate);
			else
				buff.timeLeft = expirationTime - GetTime();
			end
		else
			buffDuration:Hide();
			if ( buff.timeLeft ) then
				buff:SetScript("OnUpdate", nil);
			end
			buff.timeLeft = nil;
		end

		-- Set Texture
		local icon = _G[buffName.."Icon"];
		icon:SetTexture(texture);

		-- Set the number of applications of an aura
		local buffCount = _G[buffName.."Count"];
		if ( count > 1 ) then
			buffCount:SetText(count);
			buffCount:Show();
		else
			buffCount:Hide();
		end

		-- Refresh tooltip
		if ( GameTooltip:IsOwned(buff) ) then
			GameTooltip:SetUnitAura(PlayerFrame.unit, index, filter);
		end
	end
	return 1;
end

function AuraButton_OnUpdate(self, elapsed)
	local index = self:GetID();
	if ( self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	securecall("AuraButton_UpdateDuration", self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev 
	self.timeLeft = max(self.timeLeft - elapsed, 0);

	if ( BuffFrame.BuffFrameUpdateTime > 0 ) then
		return;
	end
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, self.filter);
	end
end

function AuraButton_UpdateDuration(auraButton, timeLeft)
	local duration = _G[auraButton:GetName().."Duration"];
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

function BuffButton_UpdateAnchors(buttonName, index)
	local buff = _G[buttonName..index];

	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		if ( index == BUFFS_PER_ROW+1 ) then
			buff:SetPoint("TOP", TempEnchant1, "BOTTOM", 0, -BUFF_ROW_SPACING);
		else
			buff:SetPoint("TOP", _G[buttonName..(index-BUFFS_PER_ROW)], "BOTTOM", 0, -BUFF_ROW_SPACING);
		end
	elseif ( index == 1 ) then
		buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
	else
		buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -5, 0);
	end
end

function DebuffButton_UpdateAnchors(buttonName, index)
	local rows = ceil(BUFF_ACTUAL_DISPLAY/BUFFS_PER_ROW);
	local buff = _G[buttonName..index];
	local buffHeight = TempEnchant1:GetHeight();

	-- Position debuffs
	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		buff:SetPoint("TOP", _G[buttonName..(index-BUFFS_PER_ROW)], "BOTTOM", 0, -BUFF_ROW_SPACING);
	elseif ( index == 1 ) then
		if ( rows < 2 ) then
			buff:SetPoint("TOPRIGHT", TempEnchant1, "BOTTOMRIGHT", 0, -1*((2*BUFF_ROW_SPACING)+buffHeight));
		else
			buff:SetPoint("TOPRIGHT", TempEnchant1, "BOTTOMRIGHT", 0, -rows*(BUFF_ROW_SPACING+buffHeight));
		end
	else
		buff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -5, 0);
	end
end


function TemporaryEnchantFrame_Hide()
	TempEnchant1:Hide();
	TempEnchant1Duration:Hide();
	TempEnchant2:Hide();
	TempEnchant2Duration:Hide();
	BuffFrame:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPRIGHT", 0, 0);
end

function TemporaryEnchantFrame_OnUpdate(self, elapsed)
	if ( not PlayerFrame.unit or PlayerFrame.unit ~= "player" ) then
		-- don't show temporary enchants when the player isn't controlling himself
		TemporaryEnchantFrame_Hide();
		return;
	end

	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
	if ( not hasMainHandEnchant and not hasOffHandEnchant ) then
		-- No enchants, kick out early
		TemporaryEnchantFrame_Hide();
		return;
	end

	-- Has enchants
	local enchantButton;
	local textureName;
	local buffAlphaValue;
	local enchantIndex = 0;
	if ( hasOffHandEnchant ) then
		enchantIndex = enchantIndex + 1;
		textureName = GetInventoryItemTexture("player", 17);
		TempEnchant1:SetID(17);
		TempEnchant1Icon:SetTexture(textureName);
		TempEnchant1:Show();

		-- Show buff durations if necessary
		if ( offHandExpiration ) then
			offHandExpiration = offHandExpiration/1000;
		end
		AuraButton_UpdateDuration(TempEnchant1, offHandExpiration);

		-- Handle flashing
		if ( offHandExpiration and offHandExpiration < BUFF_WARNING_TIME ) then
			TempEnchant1:SetAlpha(BuffFrame.BuffAlphaValue);
		else
			TempEnchant1:SetAlpha(1.0);
		end
	end
	if ( hasMainHandEnchant ) then
		enchantIndex = enchantIndex + 1;
		enchantButton = _G["TempEnchant"..enchantIndex];
		textureName = GetInventoryItemTexture("player", 16);
		enchantButton:SetID(16);
		_G[enchantButton:GetName().."Icon"]:SetTexture(textureName);
		enchantButton:Show();

		-- Show buff durations if necessary
		if ( mainHandExpiration ) then
			mainHandExpiration = mainHandExpiration/1000;
		end
		AuraButton_UpdateDuration(enchantButton, mainHandExpiration);

		-- Handle flashing
		if ( mainHandExpiration and mainHandExpiration < BUFF_WARNING_TIME ) then
			enchantButton:SetAlpha(BuffFrame.BuffAlphaValue);
		else
			enchantButton:SetAlpha(1.0);
		end
	end
	--Hide unused enchants
	for i=enchantIndex+1, 2 do
		_G["TempEnchant"..i]:Hide();
		_G["TempEnchant"..i.."Duration"]:Hide();
	end

	-- Position buff frame
	TemporaryEnchantFrame:SetWidth(enchantIndex * 32);
	BuffFrame:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPLEFT", -5, 0);
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
	end
end
