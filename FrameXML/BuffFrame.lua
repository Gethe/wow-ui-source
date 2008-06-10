BUFF_FLASH_TIME_ON = 0.75;
BUFF_FLASH_TIME_OFF = 0.75;
BUFF_MIN_ALPHA = 0.3;
BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;

DEBUFF_MAX_DISPLAY = 7;

DebuffTypeColor = { };
DebuffTypeColor["none"]	= { r = 0.80, g = 0, b = 0 };
DebuffTypeColor["Magic"]	= { r = 0.20, g = 0.60, b = 1.00 };
DebuffTypeColor["Curse"]	= { r = 0.60, g = 0.00, b = 1.00 };
DebuffTypeColor["Disease"]	= { r = 0.60, g = 0.40, b = 0 };
DebuffTypeColor["Poison"]	= { r = 0.00, g = 0.60, b = 0 };


function BuffFrame_OnLoad()
	BuffFrameUpdateTime = 0;
	BuffFrameFlashTime = 0;
	BuffFrameFlashState = 1;
	BUFF_ALPHA_VALUE = 1;

	for i=1, 24 do
		getglobal("BuffButton"..(i-1).."Duration"):SetPoint("TOP", "BuffButton"..(i-1), "BOTTOM", 0, 0);
	end
end

function BuffFrame_OnUpdate(elapsed)
	if ( BuffFrameUpdateTime > 0 ) then
		BuffFrameUpdateTime = BuffFrameUpdateTime - elapsed;
	else
		BuffFrameUpdateTime = BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
	end

	BuffFrameFlashTime = BuffFrameFlashTime - elapsed;
	if ( BuffFrameFlashTime < 0 ) then
		local overtime = -BuffFrameFlashTime;
		if ( BuffFrameFlashState == 0 ) then
			BuffFrameFlashState = 1;
			BuffFrameFlashTime = BUFF_FLASH_TIME_ON;
		else
			BuffFrameFlashState = 0;
			BuffFrameFlashTime = BUFF_FLASH_TIME_OFF;
		end
		if ( overtime < BuffFrameFlashTime ) then
			BuffFrameFlashTime = BuffFrameFlashTime - overtime;
		end
	end

	if ( BuffFrameFlashState == 1 ) then
		BUFF_ALPHA_VALUE = (BUFF_FLASH_TIME_ON - BuffFrameFlashTime) / BUFF_FLASH_TIME_ON;
	else
		BUFF_ALPHA_VALUE = BuffFrameFlashTime / BUFF_FLASH_TIME_ON;
	end
	BUFF_ALPHA_VALUE = (BUFF_ALPHA_VALUE * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA;
end

function BuffButton_Update()
	local buffIndex, untilCancelled = GetPlayerBuff(this:GetID(), this.buffFilter);
	this.buffIndex = buffIndex;
	this.untilCancelled = untilCancelled;
	local buffDuration = getglobal(this:GetName().."Duration");

	if ( buffIndex < 0 ) then
		this:Hide();
		buffDuration:Hide();
		return;
	else
		this:SetAlpha(1.0);
		this:Show();
		if ( SHOW_BUFF_DURATIONS == "1" ) then
			buffDuration:Show();
		else
			buffDuration:Hide();
		end
	end

	local icon = getglobal(this:GetName().."Icon");
	icon:SetTexture(GetPlayerBuffTexture(buffIndex));

	-- Set color of debuff border based on dispel class.
	local color;
	local debuffType = GetPlayerBuffDispelType(GetPlayerBuff(this:GetID(), "HARMFUL"));
	local debuffSlot = getglobal(this:GetName().."Border");
	if ( debuffType ) then
		color = DebuffTypeColor[debuffType];
	else
		color = DebuffTypeColor["none"];
	end
	if ( debuffSlot ) then
		debuffSlot:SetVertexColor(color.r, color.g, color.b);
	end

	-- Set the number of applications of an aura if its a debuff
	local buffCount = getglobal(this:GetName().."Count");
	local count = GetPlayerBuffApplications(buffIndex);
	if ( count > 1 ) then
		buffCount:SetText(count);
		buffCount:Show();
	else
		buffCount:Hide();
	end

	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip:SetPlayerBuff(buffIndex);
	end
end

function BuffButton_OnLoad()
	-- Valid tokens for "buffFilter" include: HELPFUL, HARMFUL, CANCELABLE, NOT_CANCELABLE
	BuffButton_Update();
	this:RegisterForClicks("RightButtonUp");
	this:RegisterEvent("PLAYER_AURAS_CHANGED");
end

function BuffButton_OnEvent(event)
	if ( event == "PLAYER_AURAS_CHANGED" ) then
		BuffButton_Update();
	end
end

function BuffButton_OnUpdate()
	local buffDuration = getglobal(this:GetName().."Duration");
	if ( this.untilCancelled == 1 ) then
		buffDuration:Hide();
		return;
	end

	local buffIndex = this.buffIndex;
	local timeLeft = GetPlayerBuffTimeLeft(buffIndex);
	if ( timeLeft < BUFF_WARNING_TIME ) then
		this:SetAlpha(BUFF_ALPHA_VALUE);
	else
		this:SetAlpha(1.0);
	end

	-- Update duration
	BuffFrame_UpdateDuration(this, timeLeft);

	if ( BuffFrameUpdateTime > 0 ) then
		return;
	end
	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip:SetPlayerBuff(buffIndex);
	end
end

function BuffButton_OnClick()
	CancelPlayerBuff(this.buffIndex);
end

function BuffButtons_UpdatePositions()
	if ( SHOW_BUFF_DURATIONS == "1" ) then
		BuffButton8:SetPoint("TOP", "TempEnchant1", "BOTTOM", 0, -15);
		BuffButton16:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPRIGHT", 0, -90);
	else
		BuffButton8:SetPoint("TOP", "TempEnchant1", "BOTTOM", 0, -5);
		BuffButton16:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPRIGHT", 0, -70);
	end
end

function BuffFrame_Enchant_OnUpdate(elapsed)
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
		hasEnchant = 1;

		-- Show buff durations if necessary
		if ( offHandExpiration ) then
			offHandExpiration = offHandExpiration/1000;
		end
		BuffFrame_UpdateDuration(TempEnchant1, offHandExpiration);

		-- Handle flashing
		if ( offHandExpiration and offHandExpiration < BUFF_WARNING_TIME ) then
			TempEnchant1:SetAlpha(BUFF_ALPHA_VALUE);
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
		hasEnchant = 1;

		-- Show buff durations if necessary
		if ( mainHandExpiration ) then
			mainHandExpiration = mainHandExpiration/1000;
		end
		
		BuffFrame_UpdateDuration(enchantButton, mainHandExpiration);

		-- Handle flashing
		if ( mainHandExpiration and mainHandExpiration < BUFF_WARNING_TIME ) then
			enchantButton:SetAlpha(BUFF_ALPHA_VALUE);
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

function BuffFrame_EnchantButton_OnUpdate()
	-- Update duration
	if ( GameTooltip:IsOwned(this) ) then
		BuffFrame_EnchantButton_OnEnter();
	end
end

function BuffFrame_EnchantButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetInventoryItem("player", this:GetID());
end

function BuffFrame_UpdateDuration(buffButton, timeLeft)
	local duration = getglobal(buffButton:GetName().."Duration");
	if ( SHOW_BUFF_DURATIONS == "1" and timeLeft ) then
		duration:SetText(SecondsToTimeAbbrev(timeLeft));
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

function RefreshBuffs(button, showBuffs, unit)
	button = button:GetName();
	local debuff,  debuffType, debuffStack, debuffColor, unitStatus, statusColor;
	local debuffTotal = 0;
	this.hasDispellable = nil;

	for i=1, MAX_PARTY_DEBUFFS do

		local debuffBorder = getglobal(button.."Debuff"..i.."Border");
		local debuffIcon = getglobal(button.."Debuff"..i.."Icon");

		if ( unit == "party"..i ) then
			unitStatus = getglobal(button.."Status");
		end
		if ( showBuffs == 1 ) then
			debuff = UnitBuff(unit, i, SHOW_CASTABLE_BUFFS);
			debuffBorder:Show();
		elseif ( showBuffs == 0 ) then
			debuff, debuffStack, debuffType = UnitDebuff(unit, i);
			debuffBorder:Show();
		else
			debuff, debuffStack, debuffType = UnitDebuff(unit, i, SHOW_DISPELLABLE_DEBUFFS);
			debuffBorder:Show();
		end
		
		if ( debuff ) then
			debuffIcon:SetTexture(debuff);
			if ( debuffType ) then
				debuffColor = DebuffTypeColor[debuffType];
				statusColor = DebuffTypeColor[debuffType];
				this.hasDispellable = 1;
				debuffTotal = debuffTotal + 1;
			else
				debuffColor = DebuffTypeColor["none"];
			end
			debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);
			getglobal(button.."Debuff"..i):Show();
		else
			getglobal(button.."Debuff"..i):Hide();
		end
	end
	-- Reset unitStatus overlay graphic timer
	if ( this.numDebuffs ) then
		if ( debuffTotal >= this.numDebuffs ) then
			this.debuffCountdown = 30;
		end
	end
	if ( unitStatus and statusColor ) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	end

end

