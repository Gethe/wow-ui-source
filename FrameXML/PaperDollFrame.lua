NUM_RESISTANCE_TYPES = 5;
NUM_STATS = 5;
NUM_SHOPPING_TOOLTIPS = 2;
ATTACK_POWER_MAGIC_NUMBER = 14;

function PaperDollFrame_OnLoad()
	CharacterAttackFrameLabel:SetText(TEXT(MELEE_ATTACK));
	CharacterDamageFrameLabel:SetText(TEXT(DAMAGE_COLON));
	CharacterAttackPowerFrameLabel:SetText(TEXT(ATTACK_POWER_COLON));
	CharacterRangedAttackFrameLabel:SetText(TEXT(RANGED_ATTACK));
	CharacterRangedDamageFrameLabel:SetText(TEXT(DAMAGE_COLON));
	CharacterRangedAttackPowerFrameLabel:SetText(TEXT(ATTACK_POWER_COLON));
	CharacterArmorFrameLabel:SetText(TEXT(ARMOR_COLON));
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_RESISTANCES");
	this:RegisterEvent("UNIT_STATS");
	this:RegisterEvent("UNIT_DAMAGE");
	this:RegisterEvent("UNIT_RANGEDDAMAGE");
	this:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
	this:RegisterEvent("UNIT_ATTACK_SPEED");
	this:RegisterEvent("UNIT_ATTACK_POWER");
	this:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	this:RegisterEvent("UNIT_ATTACK");
	this:RegisterEvent("PLAYER_GUILD_UPDATE");
	this:RegisterEvent("SKILL_LINES_CHANGED");
end

function CharacterModelFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		AutoEquipCursorItem();
	end
end

function PaperDollFrame_OnEvent(event, unit)
	if ( unit and unit == "player" ) then
		if ( event == "UNIT_MODEL_CHANGED" ) then
			CharacterModelFrame:SetUnit("player");
		elseif ( event == "UNIT_LEVEL" ) then
			PaperDollFrame_SetLevel();
		elseif ( event == "UNIT_DAMAGE" or event == "PLAYER_DAMAGE_DONE_MODS" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" ) then
			PaperDollFrame_SetDamage();
			PaperDollFrame_SetRangedDamage();
			PaperDollFrame_SetAttackBothHands();
		elseif ( event == "UNIT_ATTACK" ) then
			PaperDollFrame_SetAttackBothHands();
			--PaperDollframe_SetRangeAttack();
		elseif ( event == "UNIT_RESISTANCES" ) then
			PaperDollFrame_SetResistances();
			PaperDollFrame_SetArmor();
		elseif ( event == "UNIT_STATS" ) then
			PaperDollFrame_SetStats();
		elseif ( event == "UNIT_ATTACK_POWER" ) then
			PaperDollFrame_SetAttackPower();
		elseif ( event == "UNIT_RANGED_ATTACK_POWER" ) then
			PaperDollFrame_SetRangedAttackPower();
			PaperDollFrame_SetRangedAttack(); -- ranged attack skill
		end
	end
	if ( event == "SKILL_LINES_CHANGED" ) then
		PaperDollFrame_SetAttackBothHands();
	end
	if ( event == "PLAYER_GUILD_UPDATE" ) then
		PaperDollFrame_SetGuild();
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		CharacterModelFrame:SetUnit("player");
		return;
	end
end

function PaperDollItemSlotButton_OnLoad()
	this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("CURSOR_UPDATE");
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
	this:RegisterEvent("SHOW_COMPARE_TOOLTIP");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	this:RegisterForDrag("LeftButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	local slotName = this:GetName();
	local id;
	local textureName;
	id, textureName = GetInventorySlotInfo(strsub(slotName,10));
	this:SetID(id);
	local texture = getglobal(slotName.."IconTexture");
	texture:SetTexture(textureName);
	this.backgroundTextureName = textureName;
	PaperDollItemSlotButton_Update();
end

function PaperDollFrame_SetLevel()
	CharacterLevelText:SetText(format(TEXT(PLAYER_LEVEL),UnitLevel("player"), UnitRace("player"), UnitClass("player")));
end

--[[
Just in case they change their minds
function PaperDollFrame_SetCharacterPoints()
	local cp1 = UnitCharacterPoints("player");
	CharacterPointsText1:SetText(cp1);
end
]]

function PaperDollFrame_SetGuild()
	local guildName;
	local rank;
	guildName, title, rank = GetGuildInfo("player");
	if ( guildName ) then
		CharacterGuildText:Show();
		CharacterGuildText:SetText(format(TEXT(GUILD_TITLE_TEMPLATE), title, guildName));
	else
		CharacterGuildText:Hide();
	end
	
end

function PaperDollFrame_SetResistances()
	for i=1, NUM_RESISTANCE_TYPES, 1 do
		local resistance;
		local positive;
		local negative;
		local base;
		local text = getglobal("MagicResText"..i);
		local frame = getglobal("MagicResFrame"..i);
		
		base, resistance, positive, negative = UnitResistance("player", frame:GetID());

		local resistanceName = getglobal("RESISTANCE"..(frame:GetID()).."_NAME");
		frame.tooltip = resistanceName.." "..RESISTANCE_LABEL.." "..resistance;

		-- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
		if( negative > positive ) then
			text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		elseif( negative == positive ) then
			text:SetText(resistance);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		end

		if ( positive ~= 0 or negative ~= 0 ) then
			-- Otherwise build up the formula
			frame.tooltip = frame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
			if( positive > 0 ) then
				frame.tooltip = frame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
			end
			if( negative < 0 ) then
				frame.tooltip = frame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
			end
			frame.tooltip = frame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
		end
		local unitLevel = UnitLevel("player");
		unitLevel = max(unitLevel, 20);
		local magicResistanceNumber = resistance/unitLevel;
		if ( magicResistanceNumber > 5 ) then
			resistanceLevel = RESISTANCE_EXCELLENT;
		elseif ( magicResistanceNumber > 3.75 ) then
			resistanceLevel = RESISTANCE_VERYGOOD;
		elseif ( magicResistanceNumber > 2.5 ) then
			resistanceLevel = RESISTANCE_GOOD;
		elseif ( magicResistanceNumber > 1.25 ) then
			resistanceLevel = RESISTANCE_FAIR;
		elseif ( magicResistanceNumber > 0 ) then
			resistanceLevel = RESISTANCE_POOR;
		else
			resistanceLevel = RESISTANCE_NONE;
		end
		frame.tooltipSubtext = format(RESISTANCE_TOOLTIP_SUBTEXT, resistanceName, unitLevel, resistanceLevel);
	end
end

function PaperDollFrame_SetStats()
	for i=1, NUM_STATS, 1 do
		local label = getglobal("CharacterStatFrame"..i.."Label");
		local text = getglobal("CharacterStatFrame"..i.."StatText");
		local frame = getglobal("CharacterStatFrame"..i);
		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		label:SetText(TEXT(getglobal("SPELL_STAT"..(i-1).."_NAME"))..":");
		stat, effectiveStat, posBuff, negBuff = UnitStat("player", i);
		
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..(i-1).."_NAME").." ";

		if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
			text:SetText(effectiveStat);
			frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
		else 
			tooltipText = tooltipText..effectiveStat;
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 ) then
				tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( negBuff < 0 ) then
				tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
			end
			frame.tooltip = tooltipText;

			-- If there are any negative buffs then show the main number in red even if there are
			-- positive buffs. Otherwise show in green.
			if ( negBuff < 0 ) then
				text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			else
				text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			end
		end
	end
end

function PaperDollFrame_SetAttackBothHands(unit, prefix)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	-- FIXME: The offhand stats aren't displayed yet.
	local mainHandAttackBase, mainHandAttackMod,
	      offHandAttackBase, offHandAttackMod = UnitAttackBothHands(unit);

	local frame = getglobal(prefix.."AttackFrame"); 
	local text = getglobal(prefix.."AttackFrameStatText");

	if( mainHandAttackMod == 0 ) then
		text:SetText(mainHandAttackBase);
		frame.tooltip = nil;
	else
		local color = RED_FONT_COLOR_CODE;
		if( mainHandAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
			frame.tooltip = mainHandAttackBase..color.." +"..mainHandAttackMod..FONT_COLOR_CODE_CLOSE;
		else
			frame.tooltip = mainHandAttackBase..color.." "..mainHandAttackMod..FONT_COLOR_CODE_CLOSE;
		end
		text:SetText(color..(mainHandAttackBase + mainHandAttackMod)..FONT_COLOR_CODE_CLOSE);
	end
end

function PaperDollFrame_SetRangedDamage(unit, prefix)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	if ( not prefix ) then
		prefix = "Character";
	end

	local damageText = getglobal(prefix.."RangedDamageFrameStatText");
	local damageFrame = getglobal(prefix.."RangedDamageFrame");

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE);
		damageFrame.damage = nil;
		return;
	end

	local temp1, temp2, temp3, temp4, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit);
	local rangedAttackSpeed, minDamage, maxDamage = UnitRangedDamage(unit);
	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
	local totalBonus = (fullDamage - baseDamage);
	local displayMin = max(floor(minDamage + totalBonus),1);
	local displayMax = max(ceil(maxDamage + totalBonus),1);
	local tooltip = floor(minDamage).." - "..ceil(maxDamage);
	if ( totalBonus == 0 ) then
		damageText:SetText(displayMin.." - "..displayMax);
	else
		local colorPos = "|cff20ff20";
		local colorNeg = "|cffff2020";
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		damageText:SetText(color..displayMin.." - "..displayMax.."|r");
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond);
	end
	damageFrame.attackSpeed = rangedAttackSpeed;
	damageFrame.damage = tooltip;
	damageFrame.dps = damagePerSecond;
end

function PaperDollFrame_SetRangedAttack(unit, prefix)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	if ( not prefix ) then
		prefix = "Character";
	end

	local rangedAttackBase, rangedAttackMod = UnitRangedAttack(unit);
	local frame = getglobal(prefix.."RangedAttackFrame"); 
	local text = getglobal(prefix.."RangedAttackFrameStatText");

	-- If no ranged texture then set stats to n/a
	local rangedTexture = GetInventoryItemTexture("player", 18);
	local oldValue = PaperDollFrame.noRanged;
	if ( rangedTexture ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		frame.tooltip = nil;
	end
	-- See if value has changed set the attack damage and power
	if ( oldValue ~= PaperDollFrame.noRanged ) then
		PaperDollFrame_SetRangedAttackPower();
		PaperDollFrame_SetRangedDamage();
	end
	if ( not rangedTexture ) then
		return;
	end
	
	if( rangedAttackMod == 0 ) then
		text:SetText(rangedAttackBase);
		frame.tooltip = nil;
	else
		local color = RED_FONT_COLOR_CODE;
		if( rangedAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
			frame.tooltip = rangedAttackBase..color.." +"..rangedAttackMod..FONT_COLOR_CODE_CLOSE;
		else
			frame.tooltip = rangedAttackBase..color.." "..rangedAttackMod..FONT_COLOR_CODE_CLOSE;
		end
		text:SetText(color..(rangedAttackBase + rangedAttackMod)..FONT_COLOR_CODE_CLOSE);
	end
end

function PaperDollFrame_SetDamage(unit, prefix)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end

	local damageText = getglobal(prefix.."DamageFrameStatText");
	local damageFrame = getglobal(prefix.."DamageFrame");

	local speed, offhandSpeed = UnitAttackSpeed(unit);
	
	local minDamage;
	local maxDamage; 
	local minOffHandDamage;
	local maxOffHandDamage; 
	local physicalBonusPos;
	local physicalBonusNeg;
	local percent;
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit);

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local damagePerSecond = (max(fullDamage,1) / speed);
	local damageTooltip = floor(minDamage).." - "..ceil(maxDamage);
	
	local totalBonus = (fullDamage - baseDamage);
	local displayMin = max(floor(minDamage + totalBonus),1);
	local displayMax = max(ceil(maxDamage + totalBonus),1);
	
	local colorPos = "|cff20ff20";
	local colorNeg = "|cffff2020";
	if ( totalBonus == 0 ) then
		damageText:SetText(displayMin.." - "..displayMax);
	else
		
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		damageText:SetText(color..displayMin.." - "..displayMax.."|r");
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		
	end
	damageFrame.damage = damageTooltip;
	damageFrame.attackSpeed = speed;
	damageFrame.dps = damagePerSecond;
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = minOffHandDamage;
		maxOffHandDamage = maxOffHandDamage;
		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		local offhandDamageTooltip = floor(minOffHandDamage).." - "..ceil(maxOffHandDamage);
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		damageFrame.offhandDamage = offhandDamageTooltip;
		damageFrame.offhandAttackSpeed = offhandSpeed;
		damageFrame.offhandDps = offhandDamagePerSecond;
	end
	
end

function PaperDollFrame_SetRangedAttackPower(unit, prefix)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	local frame = getglobal(prefix.."RangedAttackPowerFrame"); 
	local text = getglobal(prefix.."RangedAttackPowerFrameStatText");
	
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text:SetText(NOT_APPLICABLE);
		frame.tooltip = nil;
		return;
	end

	local base, posBuff, negBuff = UnitRangedAttackPower(unit);
	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, frame, text);
	frame.tooltipSubtext = format(RANGED_ATTACK_POWER_TOOLTIP, base/ATTACK_POWER_MAGIC_NUMBER);
end

function PaperDollFrame_SetAttackPower(unit, prefix)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	
	local base, posBuff, negBuff = UnitAttackPower(unit);

	local frame = getglobal(prefix.."AttackPowerFrame"); 
	local text = getglobal(prefix.."AttackPowerFrameStatText");

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, frame, text);
	frame.tooltipSubtext = format(MELEE_ATTACK_POWER_TOOLTIP, base/ATTACK_POWER_MAGIC_NUMBER);
end

function PaperDollFrame_SetAttackSpeed()
	local leftSpeed;
	local rightSpeed;
	rightSpeed, leftSpeed = UnitAttackSpeed("player");
	CharacterAttackSpeedFrameStatText:SetText(format("%.1f", rightSpeed));
	--if ( leftSpeed ) then
	--	CharacterAttackSpeedFrameStatText:SetText(format("%.2f, %.2f", rightSpeed, leftSpeed));
	--else
	--	CharacterAttackSpeedFrameStatText:SetText(format("%.2f", rightSpeed));
	--end
end

function PaperDollFrame_SetArmor(unit, prefix)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end

	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	local totalBufs = posBuff + negBuff;

	local frame = getglobal(prefix.."ArmorFrame");
	local text = getglobal(prefix.."ArmorFrameStatText");

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, frame, text);
	local playerLevel = UnitLevel(unit);
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400);
	armorReduction = 100 * (armorReduction/(armorReduction + 1));
	
	frame.tooltipSubtext = format(ARMOR_TOOLTIP, playerLevel, armorReduction);
end

function PaperDollFrame_SetDefense(unit, prefix)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	local base, modifier = UnitDefense(unit);

	local frame = getglobal(prefix.."DefenseFrame");
	local text = getglobal(prefix.."DefenseFrameStatText");
	
	local posBuff = 0;
	local negBuff = 0;
	if ( modifier > 0 ) then
		posBuff = modifier;
	elseif ( modifier < 0 ) then
		negBuff = modifier;
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, frame, text);
end

function PaperDollFrame_OnShow()
	PaperDollFrame_SetGuild();
	PaperDollFrame_SetLevel();
	PaperDollFrame_SetResistances();
	PaperDollFrame_SetStats();
	PaperDollFrame_SetDamage();
	PaperDollFrame_SetRangedDamage();
	PaperDollFrame_SetAttackPower();
	PaperDollFrame_SetRangedAttackPower();
	PaperDollFrame_SetRangedAttack();
	PaperDollFrame_SetArmor();
	PaperDollFrame_SetAttackBothHands();
end
 
function PaperDollFrame_OnHide()
	--CharacterFrameCharacterTabButton:Enable();
--	for i=1, NUM_SHOPPING_TOOLTIPS, 1 do
--		getglobal("ShoppingTooltip"..i):Hide();
--	end
end

function PaperDollItemSlotButton_OnEvent(event)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			PaperDollItemSlotButton_Update();
		end
		return;
	end
	if ( event == "ITEM_LOCK_CHANGED" ) then
		PaperDollItemSlotButton_UpdateLock();
		return;
	end
	if ( event == "BAG_UPDATE_COOLDOWN" ) then
		PaperDollItemSlotButton_Update(1);
		return;
	end
	if ( event == "CURSOR_UPDATE" ) then
		if ( CursorCanGoInSlot(this:GetID()) ) then
			this:LockHighlight();
		else
			this:UnlockHighlight();
		end
		return;
	end
	if ( event == "BAG_UPDATE" ) then
		PaperDollItemSlotButton_Update();
		return;
	end
	if ( event == "SHOW_COMPARE_TOOLTIP" ) then
		if ( (arg1 ~= this:GetID()) or not this:IsVisible() or (arg2 > NUM_SHOPPING_TOOLTIPS) ) then
			return;
		end

		local tooltip = getglobal("ShoppingTooltip"..arg2);
		local anchor = "ANCHOR_RIGHT";
		if ( arg2 > 1 ) then
			anchor = "ANCHOR_BOTTOMRIGHT";
		end
		tooltip:SetOwner(this, anchor);
		local hasItem, hasCooldown = tooltip:SetInventoryItem("player", this:GetID());
		if ( not hasItem ) then
			tooltip:Hide();
		elseif ( hasCooldown ) then
			this.updateTooltip = TOOLTIP_UPDATE_TIME;
		else
			this.updateTooltip = nil;
		end
		return;
	end
	if ( event == "UPDATE_INVENTORY_ALERTS" ) then
		PaperDollItemSlotButton_Update();
	end
end

function PaperDollItemSlotButton_OnClick(button, ignoreShift)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() and not ignoreShift ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetInventoryItemLink("player", this:GetID()));
			end
		else
			PickupInventoryItem(this:GetID());
		end
	elseif ( button == "RightButton" ) then
		UseInventoryItem(this:GetID());
	end
	
end

function PaperDollItemSlotButton_Update(cooldownOnly)
	local textureName = GetInventoryItemTexture("player", this:GetID());
	local cooldown = getglobal(this:GetName().."Cooldown");
	if ( textureName ) then
		SetItemButtonTexture(this, textureName);
		SetItemButtonCount(this, GetInventoryItemCount("player", this:GetID()));
		if ( GetInventoryItemBroken("player", this:GetID()) ) then
			SetItemButtonTextureVertexColor(this, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(this, 0.9, 0, 0);
		elseif ( not IsInventoryItemLocked(this:GetID()) ) then 
			SetItemButtonTextureVertexColor(this, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(this, 1.0, 1.0, 1.0);
		end
	else
		SetItemButtonTexture(this, this.backgroundTextureName);
		SetItemButtonCount(this, 0);
		SetItemButtonTextureVertexColor(this, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(this, 1.0, 1.0, 1.0);
		cooldown:Hide();
	end

	local start, duration, enable = GetInventoryItemCooldown("player", this:GetID());
	CooldownFrame_SetTimer(cooldown, start, duration, enable);

	--local quality = GetInventoryItemQuality("player", this:GetID());
	--if ( quality and quality ~= -1 ) then
	--	local color = getglobal("ITEM_QUALITY".. quality .."_COLOR");
	--	SetItemButtonNormalTextureVertexColor(this, color.r, color.g, color.b);
	--else
	--	SetItemButtonNormalTextureVertexColor(this, 1.0, 1.0, 1.0);
	--end
	if ( GameTooltip:IsOwned(this) ) then
		if ( textureName or cooldownOnly ) then
			if ( this.isBag ) then
				BagSlotButton_OnEnter();
			else
				PaperDollItemSlotButton_OnEnter();
			end
		else
			this.updateTooltip = nil;
			GameTooltip:Hide();
			ResetCursor();
		end
	end
	PaperDollItemSlotButton_UpdateLock();

	-- Update repair all button status
	if ( MerchantRepairAllIcon ) then
		local repairAllCost, canRepair = GetRepairAllCost();
		if ( canRepair ) then
			SetDesaturation(MerchantRepairAllIcon, nil);
			MerchantRepairAllButton:Enable();
		else
			SetDesaturation(MerchantRepairAllIcon, 1);
			MerchantRepairAllButton:Disable();
		end	
	end
end

function PaperDollItemSlotButton_UpdateLock()
	if ( IsInventoryItemLocked(this:GetID()) ) then
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		SetItemButtonDesaturated(this, 1, 0.5, 0.5, 0.5);
	else 
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		SetItemButtonDesaturated(this, nil);
	end
end

function PaperDollItemSlotButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", this:GetID());
    if ( not hasItem ) then
		GameTooltip:SetText(TEXT(getglobal(strupper(strsub(this:GetName(), 10)))));
	end
	if ( hasCooldown ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end
--	if ( MerchantFrame:IsVisible() ) then
--		ShowInventorySellCursor(this:GetID());
--	end
	if ( InRepairMode() and repairCost and (repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	end
end

function PaperDollItemSlotButton_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		if ( this.isBag ) then
			BagSlotButton_OnEnter();
		else
			PaperDollItemSlotButton_OnEnter();
		end
	else
		this.updateTooltip = nil;
	end
end

function PaperDollStatTooltip(unit, stat)
	if ( not unit ) then
		unit = "player";
	end
	-- Get class specific tooltip for that stat
	local temp, classFileName = UnitClass(unit);
	local classStatText = getglobal(strupper(classFileName).."_"..stat.."_".."TOOLTIP");
	-- If can't find one use the default
	if ( not classStatText ) then
		classStatText = getglobal("DEFAULT".."_"..stat.."_".."TOOLTIP");
	end

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetText(this.tooltip);
	GameTooltip:AddLine(classStatText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	GameTooltip:Show();
end

function PaperDollFormatStat(name, base, posBuff, negBuff, frame, textString)
	local effective = max(0,base + posBuff + negBuff);
	local text = HIGHLIGHT_FONT_COLOR_CODE..name.." "..effective;
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text = text..FONT_COLOR_CODE_CLOSE;
		textString:SetText(effective);
	else 
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text.." ("..base..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			text = text..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			text = text..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end

		-- if there is a negative buff then show the main number in red, even if there are
		-- positive buffs. Otherwise show the number in green
		if ( negBuff < 0 ) then
			textString:SetText(RED_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE);
		else
			textString:SetText(GREEN_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE);
		end
	end
	frame.tooltip = text;
end

function CharacterDamageFrame_OnEnter()
	-- Main hand weapon
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", this.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_COLON, this.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", this.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( this.offhandAttackSpeed ) then
		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", this.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_COLON, this.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", this.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:Show();
end

function CharacterRangedDamageFrame_OnEnter()
	if ( not this.damage ) then
		return;
	end
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", this.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_COLON, this.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", this.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:Show();
end
