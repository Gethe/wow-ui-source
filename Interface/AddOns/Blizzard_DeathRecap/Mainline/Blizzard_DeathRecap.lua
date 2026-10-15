DeathRecapEntryMixin = {};

function DeathRecapEntryMixin:GetDamageInfo()
	return self.DamageInfo;
end

function DeathRecapEntryMixin:GetSpellInfo()
	return self.SpellInfo;
end

function DeathRecapEntryMixin:GetTombstoneIcon()
	return self:GetDamageInfo().TombstoneIcon;
end

function DeathRecapEntryMixin:GetAvoidableIcon()
	return self:GetDamageInfo().AvoidableIcon;
end

function DeathRecapEntryMixin:GetDeadlyIcon()
	return self:GetDamageInfo().DeadlyIcon;
end

function DeathRecapEntryMixin:GetDamageInfoAmount()
	return self:GetDamageInfo().Amount;
end

function DeathRecapEntryMixin:GetDamageInfoAmountLarge()
	return self:GetDamageInfo().AmountLarge;
end

function DeathRecapEntryMixin:GetSpellInfoCaster()
	return self:GetSpellInfo().Caster;
end

function DeathRecapEntryMixin:GetSpellInfoIcon()
	return self:GetSpellInfo().Icon;
end

function DeathRecapEntryMixin:GetSpellInfoName()
	return self:GetSpellInfo().Name;
end

function DeathRecapEntryMixin:OnLoad()
	self:GetDamageInfo():SetScript("OnEnter", function(damageInfoFrame)
		GameTooltip:SetOwner(damageInfoFrame, "ANCHOR_LEFT");
		GameTooltip:ClearLines();

		if self.amount then
			local valueStr = self.school and format(TEXT_MODE_A_STRING_VALUE_SCHOOL, self.amount, CombatLogUtil.GetSpellSchoolString(self.school)) or
							 self.amount;
			GameTooltip:AddLine(format(DEATH_RECAP_DAMAGE_TT, valueStr, self.dmgExtraStr), 1, 0, 0, false);
		end
	
		if self.spellName then
			if self.caster and #self.caster > 0 then
				GameTooltip:AddLine(format(DEATH_RECAP_CAST_BY_TT, self.spellName, self.caster), 1, 1, 1, true );
			else
				GameTooltip:AddLine(self.spellName, 1, 1, 1, true );
			end
		end

		if self.avoidable then
			GameTooltip:AddLine(CreateAtlasMarkup("damagemeters-avoidabledamage-icon", 16, 16) .. DEATH_RECAP_AVOIDABLE_SPELL, 1, 1, 1, true );
		end

		if self.deadly then
			GameTooltip:AddLine(CreateAtlasMarkup("icons_16x16_deadly", 16, 16) .. DEATH_RECAP_DEADLY_SPELL, 1, 1, 1, true );
		end

		local healthPercent = self:GetHealthPercent();
		if healthPercent then
			local seconds = self:GetTimeBeforeDeath();
			if seconds > 0 then
				GameTooltip:AddLine( format(DEATH_RECAP_CURR_HP_TT, format("%.1F", seconds), healthPercent), 1, 0.824, 0, true );
			else
				GameTooltip:AddLine( format(DEATH_RECAP_DEATH_TT, healthPercent), 1, 0.824, 0, true );
			end
		end

		GameTooltip:Show();
	end);

	self:GetDamageInfo():SetScript("OnLeave", function()
		GameTooltip_Hide();
	end);

	self:GetSpellInfo():SetScript("OnEnter", function(spellInfoFrame)
		if self.spellId then
			GameTooltip:SetOwner(spellInfoFrame, "ANCHOR_RIGHT");
			GameTooltip:SetSpellByID(self.spellId, false, false, false, -1, true);
			GameTooltip:Show();
		end
	end);

	self:GetSpellInfo():SetScript("OnLeave", function()
		GameTooltip_Hide();
	end);
end

function DeathRecapEntryMixin:GetEventInfo(eventData)
	local spellName = eventData.spellName;
	local nameIsNotSpell = false;
	
	local event = eventData.event;
	local spellId = eventData.spellId;
	local texture;
	if event == "SWING_DAMAGE" then
		spellId = 88163;
		spellName = ACTION_SWING;
		
		nameIsNotSpell = true;
	elseif event == "RANGE_DAMAGE" then
		nameIsNotSpell = true;
	elseif strsub(event, 1, 5) == "SPELL" then
		-- Spell standard arguments
	elseif event == "ENVIRONMENTAL_DAMAGE" then
		local environmentalType = eventData.environmentalType;
		environmentalType = string.upper(environmentalType);
		spellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_"..environmentalType];
		nameIsNotSpell = true;

		if environmentalType == "DROWNING" then
			texture = "spell_shadow_demonbreath";
		elseif environmentalType == "FALLING" then
			texture = "ability_rogue_quickrecovery";
		elseif environmentalType == "FIRE" or environmentalType == "LAVA" then
			texture = "spell_fire_fire";
		elseif environmentalType == "SLIME" then
			texture = "inv_misc_slime_01";
		elseif environmentalType == "FATIGUE" then
			texture = "ability_creature_cursed_05";
		else
			texture = "ability_creature_cursed_05"; -- default
		end

		texture = "Interface\\Icons\\"..texture;
	end
	
	local spellNameStr = spellName;
	local spellString;
	if spellName then
		if nameIsNotSpell then
			spellString = format(TEXT_MODE_A_STRING_ACTION, event, spellNameStr);
		else
			spellString = spellName;
		end
	end
	
	if spellId and not texture then
		texture = C_Spell.GetSpellTexture(spellId);
	end

	return spellId, spellString, texture;
end

function DeathRecapEntryMixin:Init(elementData)
	self.spellId, self.spellName, self.texture = self:GetEventInfo(elementData);

	local damageInfo = self:GetDamageInfo();

	if elementData.amount then
		local amountStr = BreakUpLargeNumbers(-elementData.amount);
		damageInfo.Amount:SetText(amountStr);
		damageInfo.AmountLarge:SetText(amountStr);
		self.amount = BreakUpLargeNumbers(elementData.amount);
		
		self.dmgExtraStr = "";

		if elementData.overkill and elementData.overkill > 0 then
			self.dmgExtraStr = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, elementData.overkill);
			self.amount = BreakUpLargeNumbers(elementData.amount - elementData.overkill)
		end

		if elementData.absorbed and elementData.absorbed > 0 then
			self.dmgExtraStr = self.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_ABSORB, elementData.absorbed);
			self.amount = BreakUpLargeNumbers(elementData.amount - elementData.absorbed)
		end

		if elementData.resisted and elementData.resisted > 0 then
			self.dmgExtraStr = self.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_RESIST, elementData.resisted);
			self.amount = BreakUpLargeNumbers(elementData.amount - elementData.resisted)
		end

		if elementData.blocked and elementData.blocked > 0 then
			self.dmgExtraStr = self.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_BLOCK, elementData.blocked);
			self.amount = BreakUpLargeNumbers(elementData.amount - elementData.blocked)
		end
	else
		self.amount = nil;
		self.dmgExtraStr = nil;
	end

	self.timeBeforeDeath = elementData.timeBeforeDeath;

	if elementData.maxHealth and elementData.maxHealth > 0 then
		self.healthPercent = floor(elementData.currentHP / elementData.maxHealth * 100);
	else
		self.healthPercent = nil;
	end

	if not elementData.hideCaster then
		self.caster = elementData.sourceName or COMBATLOG_UNKNOWN_UNIT
	else
		self.caster = nil;
	end

	self.school = elementData.school;
	self.deadly = elementData.deadly;
	self.avoidable = elementData.avoidable;

	local spellInfo = self:GetSpellInfo();

	spellInfo.Caster:SetText(self.caster);
	spellInfo.Name:SetText(self.spellName);
	spellInfo.Icon:SetTexture(self.texture);

	damageInfo.Amount:SetShown(not elementData.highestDamage);
	damageInfo.AmountLarge:SetShown(elementData.highestDamage);

	self:GetTombstoneIcon():SetShown(elementData.causedDeath);
	self:GetAvoidableIcon():SetShown(elementData.avoidable);
	self:GetDeadlyIcon():SetShown(elementData.deadly);
end

function DeathRecapEntryMixin:GetHealthPercent()
	return self.healthPercent;
end

function DeathRecapEntryMixin:GetTimeBeforeDeath()
	return self.timeBeforeDeath;
end

DeathRecapMixin = {};

function DeathRecapMixin:GetCloseButton()
	return self.CloseButton;
end

function DeathRecapMixin:GetDragButton()
	return self.DragButton;
end

function DeathRecapMixin:GetDivider()
	return self.Divider;
end

function DeathRecapMixin:GetScrollBox()
	return self.ScrollBox;
end

function DeathRecapMixin:GetScrollBar()
	return self.ScrollBar;
end

function DeathRecapMixin:GetUnavailableFontString()
	return self.Unavailable;
end

function DeathRecapMixin:OnLoad()
	self:GetCloseButton():SetScript("OnClick", function(button, mouseButtonName)
		HideUIPanel(self);
	end);

	self:GetDragButton():RegisterForDrag("LeftButton");

	self:GetDragButton():SetScript("OnDragStart", function()
		self:StartMoving();
	end);

	self:GetDragButton():SetScript("OnDragStop", function()
		self:StopMovingOrSizing();
	end);

	self:InitializeScrollBox();
end

function DeathRecapMixin:OnHide()
	self.recapID = nil;
end

function DeathRecapMixin:GetRecapID()
	return self.recapID;
end

function DeathRecapMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DeathRecapEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 2;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self:GetScrollBox(), self:GetScrollBar(), view);

	local topLeftX, topLeftY = 20, -5;
	local bottomRightX, bottomRightY = -22, 40;
	local withBarXOffset = 20;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self:GetDivider(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX - withBarXOffset, bottomRightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self:GetDivider(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX, bottomRightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self:GetScrollBox(), self:GetScrollBar(), scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function DeathRecapMixin:GetEntryFrameCount()
	return self:GetScrollBox():GetFrameCount();
end

function DeathRecapMixin:BuildDataProvider()
	local dataProvider = CreateDataProvider();
	local events = C_DeathRecap.GetRecapEvents(self:GetRecapID()) or {};
	local maxHealth = C_DeathRecap.GetRecapMaxHealth(self:GetRecapID());

	local highestDamageIndex, highestDamageAmount = 1, 0;
	local deathTimestamp = 0;

	for i, event in ipairs(events) do
		if event.amount and event.amount > highestDamageAmount then
			highestDamageIndex = i;
			highestDamageAmount = event.amount;
		end

		if event.timestamp and event.timestamp > deathTimestamp then
			deathTimestamp = event.timestamp;
		end
	end

	for i, event in ipairs(events) do
		local elementData = event;

		elementData.highestDamage = i == highestDamageIndex;
		elementData.maxHealth = maxHealth;
		elementData.timeBeforeDeath = deathTimestamp - elementData.timestamp;
		elementData.causedDeath = i == 1;

		dataProvider:Insert(elementData);
	end

	return dataProvider;
end

function DeathRecapMixin:OpenRecap(recapID)
	if recapID == self:GetRecapID() and self:IsShown() then
		self.recapID = nil;
		HideUIPanel(self);
		return;
	end
	
	self.recapID = recapID;

	ShowUIPanel(self);

	self:GetScrollBox():SetDataProvider(self:BuildDataProvider(), ScrollBoxConstants.DiscardScrollPosition);

	self:GetUnavailableFontString():SetShown(self:GetEntryFrameCount() == 0);
end
