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


function BuffFrame_OnLoad (self)
	BuffFrame.BuffFrameUpdateTime = 0;
	BuffFrame.BuffFrameFlashTime = 0;
	BuffFrame.BuffFrameFlashState = 1;
	BuffFrame.BuffAlphaValue = 1;
	self:RegisterEvent("UNIT_AURA");
end

function BuffFrame_OnEvent (self, event, ...)
	local unit = ...;
	if ( event == "UNIT_AURA" ) then
		if ( unit == PlayerFrame.unit ) then
			BuffFrame_Update();
		end
	end
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

function AuraButton_Update(buttonName, index, filter)
	local unit = PlayerFrame.unit;
	local name, rank, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter);

	local buffName = buttonName..index;
	local buff = getglobal(buffName);
	local buffDuration = getglobal(buffName.."Duration");

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

			buffDuration = getglobal(buffName.."Duration");
		end
		-- Setup Buff
		buff.namePrefix = buttonName;
		buff:SetID(index);
		buff.filter = filter;
		buff:SetAlpha(1.0);
		buff:Show();

		-- Set filter-specific attributes
		if ( helpful ) then
			-- Set secure attributes before we do any positioning or set scripts
			-- These will let us cancel our buffs
			buff:SetAttribute("unit", unit);
			buff:SetAttribute("index", index);
			-- Anchor Buffs
			BuffButton_UpdateAnchors(buttonName, index);
		else
			buff.unit = nil;
			-- Anchor Debuffs
			DebuffButton_UpdateAnchors(buttonName, index);
			-- Set color of debuff border based on dispel class.
			local debuffSlot = getglobal(buffName.."Border");
			if ( debuffSlot ) then
				local color;
				if ( debuffType ) then
					color = DebuffTypeColor[debuffType];
				else
					color = DebuffTypeColor["none"];
				end
				debuffSlot:SetVertexColor(color.r, color.g, color.b);
			end
		end

		if ( SHOW_BUFF_DURATIONS == "1" and duration > 0 and expirationTime ) then
			buffDuration:Show();
			if ( not buff.timeLeft ) then
				buff.timeLeft = expirationTime - GetTime();
				buff:SetScript("OnUpdate", BuffButton_OnUpdate);
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
		local icon = getglobal(buffName.."Icon");
		icon:SetTexture(texture);

		-- Set the number of applications of an aura
		local buffCount = getglobal(buffName.."Count");
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

function BuffFrame_OnUpdate (self, elapsed)
	if ( BuffFrame.BuffFrameUpdateTime > 0 ) then
		BuffFrame.BuffFrameUpdateTime = BuffFrame.BuffFrameUpdateTime - elapsed;
	else
		BuffFrame.BuffFrameUpdateTime = BuffFrame.BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
	end

	BuffFrame.BuffFrameFlashTime = BuffFrame.BuffFrameFlashTime - elapsed;
	if ( BuffFrame.BuffFrameFlashTime < 0 ) then
		local overtime = -BuffFrame.BuffFrameFlashTime;
		if ( BuffFrame.BuffFrameFlashState == 0 ) then
			BuffFrame.BuffFrameFlashState = 1;
			BuffFrame.BuffFrameFlashTime = BUFF_FLASH_TIME_ON;
		else
			BuffFrame.BuffFrameFlashState = 0;
			BuffFrame.BuffFrameFlashTime = BUFF_FLASH_TIME_OFF;
		end
		if ( overtime < BuffFrame.BuffFrameFlashTime ) then
			BuffFrame.BuffFrameFlashTime = BuffFrame.BuffFrameFlashTime - overtime;
		end
	end

	if ( BuffFrame.BuffFrameFlashState == 1 ) then
		BuffFrame.BuffAlphaValue = (BUFF_FLASH_TIME_ON - BuffFrame.BuffFrameFlashTime) / BUFF_FLASH_TIME_ON;
	else
		BuffFrame.BuffAlphaValue = BuffFrame.BuffFrameFlashTime / BUFF_FLASH_TIME_ON;
	end
	BuffFrame.BuffAlphaValue = (BuffFrame.BuffAlphaValue * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA;
end

function BuffButton_OnLoad (self)
	self:RegisterForClicks("RightButtonUp");
end

function BuffButton_OnUpdate (self, elapsed)
	local index = self:GetID();
	if ( self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	BuffFrame_UpdateDuration(self, self.timeLeft);
	self.timeLeft = max(self.timeLeft - elapsed, 0);

	if ( BuffFrame.BuffFrameUpdateTime > 0 ) then
		return;
	end
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, self.filter);
	end
end

function BuffButtons_UpdatePositions()
	if ( SHOW_BUFF_DURATIONS == "1" ) then
		BUFF_ROW_SPACING = 15;
	else
		BUFF_ROW_SPACING = 5;
	end
	BuffFrame_Update();
end

function BuffButton_UpdateAnchors(buttonName, index)
	local buff = getglobal(buttonName..index);

	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		if ( index == BUFFS_PER_ROW+1 ) then
			buff:SetPoint("TOP", TempEnchant1, "BOTTOM", 0, -BUFF_ROW_SPACING);
		else
			buff:SetPoint("TOP", getglobal(buttonName..(index-BUFFS_PER_ROW)), "BOTTOM", 0, -BUFF_ROW_SPACING);
		end
	elseif ( index == 1 ) then
		buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
	else
		buff:SetPoint("RIGHT", getglobal(buttonName..(index-1)), "LEFT", -5, 0);
	end
end

function DebuffButton_UpdateAnchors(buttonName, index)
	local rows = ceil(BUFF_ACTUAL_DISPLAY/BUFFS_PER_ROW);
	local buff = getglobal(buttonName..index);
	local buffHeight = TempEnchant1:GetHeight();

	-- Position debuffs
	if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
		-- New row
		buff:SetPoint("TOP", getglobal(buttonName..(index-BUFFS_PER_ROW)), "BOTTOM", 0, -BUFF_ROW_SPACING);
	elseif ( index == 1 ) then
		if ( rows < 2 ) then
			buff:SetPoint("TOPRIGHT", TempEnchant1, "BOTTOMRIGHT", 0, -1*((2*BUFF_ROW_SPACING)+buffHeight));
		else
			buff:SetPoint("TOPRIGHT", TempEnchant1, "BOTTOMRIGHT", 0, -rows*(BUFF_ROW_SPACING+buffHeight));
		end
	else
		buff:SetPoint("RIGHT", getglobal(buttonName..(index-1)), "LEFT", -5, 0);
	end
end


function BuffFrame_Enchant_OnUpdate(self, elapsed)
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
	
	-- No enchants, kick out early
	if ( not hasMainHandEnchant and not hasOffHandEnchant ) then
		TempEnchant1:Hide();
		TempEnchant1Duration:Hide();
		TempEnchant2:Hide();
		TempEnchant2Duration:Hide();
		BuffFrame:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPRIGHT", 0, 0);
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
		BuffFrame_UpdateDuration(TempEnchant1, offHandExpiration);

		-- Handle flashing
		if ( offHandExpiration and offHandExpiration < BUFF_WARNING_TIME ) then
			TempEnchant1:SetAlpha(BuffFrame.BuffAlphaValue);
		else
			TempEnchant1:SetAlpha(1.0);
		end
		
	end
	if ( hasMainHandEnchant ) then
		enchantIndex = enchantIndex + 1;
		enchantButton = getglobal("TempEnchant"..enchantIndex);
		textureName = GetInventoryItemTexture("player", 16);
		enchantButton:SetID(16);
		getglobal(enchantButton:GetName().."Icon"):SetTexture(textureName);
		enchantButton:Show();

		-- Show buff durations if necessary
		if ( mainHandExpiration ) then
			mainHandExpiration = mainHandExpiration/1000;
		end
		
		BuffFrame_UpdateDuration(enchantButton, mainHandExpiration);

		-- Handle flashing
		if ( mainHandExpiration and mainHandExpiration < BUFF_WARNING_TIME ) then
			enchantButton:SetAlpha(BuffFrame.BuffAlphaValue);
		else
			enchantButton:SetAlpha(1.0);
		end
	end
	--Hide unused enchants
	for i=enchantIndex+1, 2 do
		getglobal("TempEnchant"..i):Hide();
		getglobal("TempEnchant"..i.."Duration"):Hide();
	end

	-- Position buff frame
	TemporaryEnchantFrame:SetWidth(enchantIndex * 32);
	BuffFrame:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPLEFT", -5, 0);
end

function BuffFrame_EnchantButton_OnLoad (self)
	self:RegisterForClicks("RightButtonUp");
end

function BuffFrame_EnchantButton_OnUpdate (self, elapsed)
	-- Update duration
	if ( GameTooltip:IsOwned(self) ) then
		BuffFrame_EnchantButton_OnEnter(self);
	end
end

function BuffFrame_EnchantButton_OnEnter (self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetInventoryItem("player", self:GetID());
end

function BuffFrame_EnchantButton_OnClick (self, button)
	if ( self:GetID() == 16 ) then
		CancelItemTempEnchantment(1);
	elseif ( self:GetID() == 17 ) then
		CancelItemTempEnchantment(2);
	end;
end

function BuffFrame_UpdateDuration(buffButton, timeLeft)
	local duration = getglobal(buffButton:GetName().."Duration");
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

function RefreshBuffs(button, showBuffs, unit, numbuffs)
	local buttonName = button:GetName();
	local name, rank, icon, debuffType, debuffStack, debuffColor, unitStatus, statusColor;
	local debuffTotal = 0;
	button.hasDispellable = nil;
	if ( not numbuffs ) then
		numbuffs = MAX_PARTY_DEBUFFS;
	end

	for i=1, numbuffs do

		local debuffBorder = getglobal(buttonName.."Debuff"..i.."Border");
		local debuffIcon = getglobal(buttonName.."Debuff"..i.."Icon");

		if ( unit == "party"..i ) then
			unitStatus = getglobal(buttonName.."Status");
		end
		-- Show all buffs and debuffs
		if ( showBuffs == 1 ) then
			local filter;
			if ( GetCVarBool("showCastableBuffs") ) then
				filter = "RAID";
			end
			name, rank, icon = UnitBuff(unit, i, filter);
			debuffBorder:Show();
		-- Show all debuffs
		elseif ( showBuffs == 0 ) then
			name, rank, icon, debuffStack, debuffType = UnitDebuff(unit, i);
			debuffBorder:Show();
		-- Show dispellable debuffs (value nil or anything ~= 0 or 1)
		else
			local filter;
			if ( GetCVarBool("showDispelDebuffs") ) then
				filter = "RAID";
			end
			name, rank, icon, debuffStack, debuffType = UnitDebuff(unit, i, filter);
			debuffBorder:Show();
		end
		
		if ( icon ) then
			debuffIcon:SetTexture(icon);
			if ( debuffType ) then
				debuffColor = DebuffTypeColor[debuffType];
				statusColor = DebuffTypeColor[debuffType];
				button.hasDispellable = 1;
				debuffTotal = debuffTotal + 1;
			else
				debuffColor = DebuffTypeColor["none"];
			end
			debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);
			getglobal(buttonName.."Debuff"..i):Show();
		else
			getglobal(buttonName.."Debuff"..i):Hide();
		end
	end
	button.debuffTotal = debuffTotal;
	-- Reset unitStatus overlay graphic timer
	if ( button.numDebuffs ) then
		if ( debuffTotal >= button.numDebuffs ) then
			button.debuffCountdown = 30;
		end
	end
	if ( unitStatus and statusColor ) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	end
end
