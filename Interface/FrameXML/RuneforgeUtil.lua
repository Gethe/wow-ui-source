
RuneforgePowerBaseMixin = {};

function RuneforgePowerBaseMixin:OnHide()
	self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
end

function RuneforgePowerBaseMixin:OnEvent(event, ...)
	if event == "RUNEFORGE_POWER_INFO_UPDATED" then
		local powerID = ...;
		if powerID == self:GetPowerID() then
			self:SetPowerID(powerID);

			if self:IsMouseOver() then
				self:OnEnter();
			end
		end
	end
end

function RuneforgePowerBaseMixin:OnEnter()
	local powerInfo = self:GetPowerInfo();
	if powerInfo then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		GameTooltip_SetTitle(GameTooltip, powerInfo.name, LEGENDARY_ORANGE_COLOR);
	
		GameTooltip_AddColoredLine(GameTooltip, RUNEFORGE_LEGENDARY_POWER_LABEL, BRIGHTBLUE_FONT_COLOR);

		GameTooltip_AddColoredLine(GameTooltip, powerInfo.description, GREEN_FONT_COLOR);
	
		if not self.slotNames then
			self.slotNames = C_LegendaryCrafting.GetRuneforgePowerSlots(self:GetPowerID());
		end

		if #self.slotNames > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);

			local slotNames = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(table.concat(self.slotNames, LIST_DELIMITER));
			GameTooltip_AddNormalLine(GameTooltip, RUNEFORGE_LEGENDARY_POWER_TOOLTIP_SLOT_HEADER:format(slotNames));
		end

		if not self:ShouldHideSource() and powerInfo.source then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);

			local sourceText = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(powerInfo.source);
			GameTooltip_AddNormalLine(GameTooltip, RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT:format(sourceText));
		end

		if self:ShouldShowUnavailableError() and (powerInfo.state ~= Enum.RuneforgePowerState.Available) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, RUNEFORGE_LEGENDARY_POWER_TOOLTIP_NOT_COLLECTED);
		end

		local powerInfo = self:GetPowerInfo();
		local specName = powerInfo and powerInfo.specName or nil;
		if specName ~= nil then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);

			if powerInfo.matchesSpec then
				local requiresText = RUNEFORGE_LEGENDARY_POWER_REQUIRES_SPEC_FORMAT:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(specName));
				GameTooltip_AddNormalLine(GameTooltip, requiresText);
			else
				GameTooltip_AddErrorLine(GameTooltip, RUNEFORGE_LEGENDARY_POWER_REQUIRES_SPEC_FORMAT:format(specName));
			end
		end


		GameTooltip:Show();
	end
end

function RuneforgePowerBaseMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgePowerBaseMixin:OnSelected()
	if IsModifiedClick("CHATLINK") then
		local powerInfo = self:GetPowerInfo();
		if powerInfo == nil then
			return false;
		end

		ChatEdit_InsertLink(GetSpellLink(powerInfo.descriptionSpellID));
		return true;
	end

	return false;
end

function RuneforgePowerBaseMixin:SetPowerID(powerID)
	local oldPowerID = self.powerID;

	self.powerID = powerID;
	self.slotNames = nil;

	local hasPowerID = powerID ~= nil;
	self.powerInfo = hasPowerID and C_LegendaryCrafting.GetRuneforgePowerInfo(powerID) or nil;
	if hasPowerID then
		self:RegisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	else
		self:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED");
	end

	self:OnPowerSet(oldPowerID, powerID);
end

function RuneforgePowerBaseMixin:ShouldHideSource()
	local powerInfo = self:GetPowerInfo();
	return (powerInfo == nil) or (powerInfo.state == Enum.RuneforgePowerState.Available);
end

function RuneforgePowerBaseMixin:GetPowerID()
	return self.powerID;
end

function RuneforgePowerBaseMixin:GetPowerInfo()
	return self.powerInfo;
end

function RuneforgePowerBaseMixin:OnPowerSet(oldPowerID, newPowerID)
	-- override in your mixin.
end

function RuneforgePowerBaseMixin:ShouldShowUnavailableError()
	-- override in your mixin.
	return false;
end


RuneforgeEffectOwnerMixin = {};

function RuneforgeEffectOwnerMixin:GetRuneforgeFrame()
	return self;
end

function RuneforgeEffectOwnerMixin:AddEffectData(effectKey, effectID, effectTarget, effectLevel)
	self[effectKey] = { effectID = effectID, effectTarget = effectTarget, effectLevel = effectLevel };
end

function RuneforgeEffectOwnerMixin:GetFrameFromEffectTarget(effectTarget)
	if effectTarget == RuneforgeUtil.EffectTarget.ItemSlot then
		return self, self:GetRuneforgeFrame().CraftingFrame.BaseItemSlot;
	elseif effectTarget == RuneforgeUtil.EffectTarget.ReverseItemSlot then
		return self:GetRuneforgeFrame().CraftingFrame.BaseItemSlot, self;
	elseif effectTarget == RuneforgeUtil.EffectTarget.None then
		return self, nil;
	else
		error("Unknown effect target: "..effectTarget);
	end
end

function RuneforgeEffectOwnerMixin:SetEffectShown(effectKey, shown)
	local effectData = self[effectKey];
	local controller = effectData.controller;
	if shown and not controller then
		local source, target = self:GetFrameFromEffectTarget(effectData.effectTarget);
		effectData.controller = self:GetRuneforgeFrame():AddEffect(effectData.effectLevel, effectData.effectID, source, target);
	elseif not shown and controller then
		controller:CancelEffect();
		effectData.controller = nil;
	end
end


RuneforgeSystemMixin = CreateFromMixins(RuneforgeEffectOwnerMixin);

local RefreshEventNames = {
	"BaseItemChanged",
	"PowerSelected",
	"ModifiersChanged",
};

function RuneforgeSystemMixin:GetRuneforgeFrame()
	return self:GetParent():GetParent();
end

function RuneforgeSystemMixin:IsRuneforgeCrafting()
	return self:GetRuneforgeFrame():IsRuneforgeCrafting();
end

function RuneforgeSystemMixin:IsRuneforgeUpgrading()
	return self:GetRuneforgeFrame():IsRuneforgeUpgrading();
end

function RuneforgeSystemMixin:RegisterRefreshMethod(refreshMethod)
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event[eventName], GenerateClosure(refreshMethod, self, eventName), self);
	end
end

function RuneforgeSystemMixin:UnregisterRefreshMethod()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event[eventName], self);
	end
end


RuneforgeUtil = {};

RuneforgeUtil.EffectTarget = {
	None = 1,
	ItemSlot = 2,
	ReverseItemSlot = 3,
};

RuneforgeUtil.Effect = {
	CenterPassive = 52,
	BottomPassive = 53,
	CenterRune = 56,
	PowerSlotted = 55,
	PowerInChainsEffect = 58,
	PowerOutChainsEffect = 59,
	ModifierSlotted = 61,
	FirstModifierChainsEffect = 54,
	SecondModifierChainsEffect = 57,
	UpgradeCenterRune = 69,
	UpgradeSubRune = 70,
	CraftCast = 101,
};

RuneforgeUtil.Level = {
	Background = 1,
	Frame = 2,
	Overlay = 3,
};

RuneforgeUtil.RuneforgeState = {
	Craft = 1,
	Upgrade = 2,
};

RuneforgeUtil.FlyoutType = {
	BaseItem = 1,
	Legendary = 2,
	UpgradeItem = 3,
};

function RuneforgeUtil.GetCostsString(costs)
	local resultString = "";
	for i, cost in ipairs(costs) do
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(cost.currencyID);
		if currencyInfo then
			local currencyMarkup = CreateTextureMarkup(currencyInfo.icon, 64, 64, 14, 14, 0, 1, 0, 1);
			resultString = resultString.." "..cost.amount.." "..currencyMarkup;
		end
	end

	return resultString;
end

function RuneforgeUtil.IsUpgradeableRuneforgeLegendary(itemLocation)
	return C_LegendaryCrafting.IsRuneforgeLegendary(itemLocation) and not C_LegendaryCrafting.IsRuneforgeLegendaryMaxLevel(itemLocation);
end

function RuneforgeUtil.GetRuneforgeFilterText(filter)
	if filter == Enum.RuneforgePowerFilter.All then
		return RUNEFORGE_POWER_FILTER_ALL;
	elseif filter == Enum.RuneforgePowerFilter.Available then
		return RUNEFORGE_POWER_FILTER_AVAILABLE;
	elseif filter == Enum.RuneforgePowerFilter.Unavailable then
		return RUNEFORGE_POWER_FILTER_UNAVAILABLE;
	end

	return nil;
end

function RuneforgeUtil.GetPreviewClassAndSpec()
	local classID = select(3, UnitClass("player"));
	local spec = GetSpecialization();
	local specID = spec and GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")) or nil;
	return classID, specID;
end

Enum.RuneforgePowerState =
{
	Available = 0,
	Unavailable = 1,
	Invalid = 2,
};

Enum.RuneforgePowerFilter =
{
	All = 0,
	Available = 1,
	Unavailable = 2,
};
