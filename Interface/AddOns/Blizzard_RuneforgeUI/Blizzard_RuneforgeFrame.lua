
UIPanelWindows["RuneforgeFrame"] = { area = "left", pushable = 3, showFailedFunc = C_LegendaryCrafting.CloseRuneforgeInteraction, };

-- Determined by hand using positioning macros.
local CircleRuneEffects = {
	{ birthEffectID = 73, flashEffectID = 81, offsetX = 51, offsetY = 149 },
	{ birthEffectID = 74, flashEffectID = 82, offsetX = 155, offsetY = 33 },
	{ birthEffectID = 75, flashEffectID = 83, offsetX = 156, offsetY = -39 },
	{ birthEffectID = 76, flashEffectID = 84, offsetX = 23, offsetY = -165 },
	{ birthEffectID = 77, flashEffectID = 85, offsetX = -54, offsetY = -153 },
	{ birthEffectID = 78, flashEffectID = 86, offsetX = -141, offsetY = -80 },
	{ birthEffectID = 79, flashEffectID = 87, offsetX = -129, offsetY = 94 },
	{ birthEffectID = 80, flashEffectID = 88, offsetX = -64, offsetY = 143 },
};

local CircleRuneFlashEffects = {};
local CircleRuneBirthEffects = {};

local function InitializeRuneEffects()
	for i, effect in ipairs(CircleRuneEffects) do
		local flashEffect = CopyTable(effect);
		flashEffect.effectID = flashEffect.flashEffectID;
		table.insert(CircleRuneFlashEffects, flashEffect);

		local birthEffect = CopyTable(effect);
		birthEffect.effectID = birthEffect.birthEffectID;
		table.insert(CircleRuneBirthEffects, birthEffect);
	end
end


RuneforgeFrameMixin = CreateFromMixins(CallbackRegistryMixin);

RuneforgeFrameMixin:GenerateCallbackEvents(
{
	"BaseItemChanged",
	"PowerSelected",
	"ModifiersChanged",
	"ItemSlotOnEnter",
	"ItemSlotOnLeave",
	"UpgradeItemChanged",
	"UpgradeItemSlotOnEnter",
	"UpgradeItemSlotOnLeave",
});

local RuneforgeFrameEvents = {
	"RUNEFORGE_LEGENDARY_CRAFTING_CLOSED",
	"ITEM_CHANGED",
	"CURRENCY_DISPLAY_UPDATE",
};

local RuneforgeFramePlayerEvents = {
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_STOP",
	"UNIT_SPELLCAST_SUCCEEDED",
};

function RuneforgeFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.ResultTooltip:Init();
	self.runeforgeState = RuneforgeUtil.RuneforgeState.Craft;

	InitializeRuneEffects();
end

function RuneforgeFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, RuneforgeFramePlayerEvents, "player");
	EventRegistry:RegisterCallback("CinematicFrame.CinematicStarting", self.OnCinematicStarting, self);
	EventRegistry:RegisterCallback("CinematicFrame.CinematicStopped", self.OnCinematicStopped, self);
	self:RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
	self:RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self.OnUpgradeItemChanged, self);

	self:SetStaticEffectsShown(true);

	self:RefreshCurrencyDisplay();

	self.Title:SetText(self:IsRuneforgeUpgrading() and RUNEFORGE_LEGENDARY_CRAFTING_FRAME_UPGRADE_TITLE or RUNEFORGE_LEGENDARY_CRAFTING_FRAME_TITLE);

	PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_MAIN_WINDOW);

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnHide()
	if self.cinematicShowing then
		-- Defer this OnHide until after the cinematic is finished to avoid problems moving the camera.
		return;
	end

	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFramePlayerEvents, "player");
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStarting", self);
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStopped", self);
	self:UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
	self:UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self.OnUpgradeItemChanged, self);

	C_LegendaryCrafting.CloseRuneforgeInteraction();

	self:SetStaticEffectsShown(false);

	if not self.skipCloseSound then
		PlaySound(SOUNDKIT.UI_RUNECARVING_CLOSE_MAIN_WINDOW);
	end
	
	self.skipCloseSound = nil;

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnEvent(event, ...)
	if event == "RUNEFORGE_LEGENDARY_CRAFTING_CLOSED" then
		HideUIPanel(self);
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		self:RefreshCurrencyDisplay();
	elseif event == "ITEM_CHANGED" then
		local item = self:GetItem();
		if item then
			-- It's a bit odd to compare by item link, but we may not get the full inventory update until many frames later.
			local previousItemLink, newItemLink = ...;
			if previousItemLink == C_Item.GetItemLink(item) then
				LegendaryItemAlertSystem:AddAlert(newItemLink);
				PlaySound(SOUNDKIT.UI_RUNECARVING_CREATE_COMPLETE);
			end
		end

		if self:IsRuneforgeUpgrading() then
			HideUIPanel(self);
		end
	elseif event == "UNIT_SPELLCAST_START" then
		local unitTag, lineID, spellID = ...;
		if spellID == C_LegendaryCrafting.GetRuneforgeLegendaryCraftSpellID() then
			self:SetCastEffectShown(true);
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unitTag, lineID, spellID = ...;
		if spellID == C_LegendaryCrafting.GetRuneforgeLegendaryCraftSpellID() then
			if self.spellSucceeded then
				self.spellSucceeded = nil;
			else
				self:SetCastEffectShown(false);
			end
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unitTag, lineID, spellID = ...;
		if spellID == C_LegendaryCrafting.GetRuneforgeLegendaryCraftSpellID() then
			AlertFrame:SetAlertsEnabled(false, "runeforgeLegendaryCraft");
			self.spellSucceeded = true;
		end
	end
end

function RuneforgeFrameMixin:OnBaseItemChanged()
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnUpgradeItemChanged()
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnCinematicStarting()
	self.cinematicShowing = true;
	self:SetCastEffectShown(false);
end

function RuneforgeFrameMixin:OnCinematicStopped()
	self:SetCastEffectShown(false);
	AlertFrame:SetAlertsEnabled(true, "runeforgeLegendaryCraft");
	self.cinematicShowing = nil;
	self.skipCloseSound = true;
	self:OnHide();
end

function RuneforgeFrameMixin:RefreshCurrencyDisplay()
	local currencies = C_LegendaryCrafting.GetRuneforgeLegendaryCurrencies();

	local initialAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", self.CurrencyDisplay, "TOPRIGHT");
	local direction = GridLayoutMixin.Direction.TopRightToBottomLeftVertical;
	local stride = #currencies;
	local paddingX = 2;
	local paddingY = 2;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	local tooltipAnchor = "ANCHOR_TOP";
	self.CurrencyDisplay:SetCurrencies(currencies, initFunction, initialAnchor, layout, tooltipAnchor);
end

function RuneforgeFrameMixin:SetStaticEffectsShown(shown)
	if not self.centerPassiveEffect and shown then
		self.centerPassiveEffect = self:AddEffect(RuneforgeUtil.Level.Background, RuneforgeUtil.Effect.CenterPassive, self.CraftingFrame.BaseItemSlot);

		local bottomEffectDynamicDescription = { effectID = RuneforgeUtil.Effect.BottomPassive, offsetY = -214, };
		self.bottomEffect = self.BackgroundModelScene:AddDynamicEffect(bottomEffectDynamicDescription, self);

	elseif self.centerPassiveEffect and not shown then
		self.centerPassiveEffect:CancelEffect();
		self.centerPassiveEffect = nil;

		self.bottomEffect:CancelEffect();
		self.bottomEffect = nil;
	end
end

function RuneforgeFrameMixin:SetCastEffectShown(shown)
	if shown and not self.castEffect then
		self.castEffect = self:AddEffect(RuneforgeUtil.Level.Frame, RuneforgeUtil.Effect.CraftCast, self.CraftingFrame.BaseItemSlot);
	elseif not shown and self.castEffect then
		self.castEffect:CancelEffect();
		self.castEffect = nil;
	end
end

function RuneforgeFrameMixin:SetRunesShown(shown)
	self.runesShown = shown;

	if self.runeEffects and not shown then
		for i, effectController in ipairs(self.runeEffects) do
			effectController:CancelEffect();
		end

		self.runeEffects = nil;

		self:ClearRuneFlashes();
	elseif not self.runeEffects and shown then
		self.runeEffects = {};

		for i, effect in ipairs(CircleRuneBirthEffects) do
			local effectController = self.CraftingFrame.ModelScene:AddDynamicEffect(effect, self.CraftingFrame.BaseItemSlot);
			self.runeEffects[i] = effectController;
		end

		self:FlashRunes();
	end
end

function RuneforgeFrameMixin:ClearRuneFlashes()
	if self.runeFlashes then
		self.runeFlashesCanceled = true;

		for index, runeFlash in pairs(self.runeFlashes) do
			runeFlash:CancelEffect();
		end

		self.runeFlashes = nil;
		self.runeFlashesCanceled = nil;
	end
end

function RuneforgeFrameMixin:FlashRunes()
	self:ClearRuneFlashes();

	self.runeFlashes = {};

	for i, effect in ipairs(CircleRuneFlashEffects) do
		local function OnRuneforgeRuneFlashEffectResolution()
			if not self.runeFlashesCanceled then
				self.runeFlashes[i] = nil;
			end

			if not next(self.runeFlashes) then
				self.runeFlashes = nil;
			end
		end

		local target = nil;
		local onEffectFinish = nil;
		self.runeFlashes[i] = self.CraftingFrame.ModelScene:AddDynamicEffect(effect, self.CraftingFrame.BaseItemSlot, target, onEffectFinish, OnRuneforgeRuneFlashEffectResolution);
	end
end

function RuneforgeFrameMixin:GetLegendaryCraftInfo()
	local itemLocation = self:GetItem();
	if itemLocation then
		local powerID = self.CraftingFrame:GetPowerID();
		local modifiers = self.CraftingFrame:GetModifiers();
		return itemLocation, powerID, modifiers;
	end

	return nil;
end

function RuneforgeFrameMixin:GetItemPreviewInfo(baseItem, powerID, modifiers)
	if not baseItem then
		baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	end
	
	return self:IsRuneforgeUpgrading() and C_LegendaryCrafting.GetRuneforgeItemPreviewInfo(baseItem) or C_LegendaryCrafting.GetRuneforgeItemPreviewInfo(baseItem, powerID, modifiers);
end

function RuneforgeFrameMixin:RefreshResultTooltip()
	local resultTooltip = self.ResultTooltip;
	local tooltipWasShown = resultTooltip:IsShown();
	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	local hasItem = baseItem ~= nil;
	if hasItem then
		resultTooltip:SetOwner(self, "ANCHOR_NONE");
		resultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -162);

		local itemPreviewInfo = self:GetItemPreviewInfo(baseItem, powerID, modifiers);
		local upgradeItem = self:GetUpgradeItem();
		local hasUpgradeItem = upgradeItem ~= nil;
		local itemLevel = hasUpgradeItem and C_Item.GetCurrentItemLevel(upgradeItem) or itemPreviewInfo.itemLevel;

		if self:IsRuneforgeUpgrading() then
			resultTooltip:SetRuneforgeResultItem(itemPreviewInfo.itemGUID, itemLevel);
		else
			resultTooltip:SetRuneforgeResultItem(itemPreviewInfo.itemGUID, itemLevel, powerID, modifiers);
		end
	end
	
	resultTooltip:SetShown(hasItem);

	if tooltipWasShown ~= hasItem then
		local panelWidth = hasItem and (self:GetWidth() + resultTooltip:GetWidth()) or self:GetWidth();
		SetUIPanelAttribute(self, "width", panelWidth);
		UpdateUIPanelPositions(self);
	end
end

function RuneforgeFrameMixin:ShowComparisonTooltip()
	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	local upgradeItem = self:GetUpgradeItem();
	if baseItem == nil or upgradeItem == nil then
		return;
	end

	local itemPreviewInfo = self:GetItemPreviewInfo(baseItem, powerID, modifiers);

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("LEFT", self.CraftingFrame.BaseItemSlot, "RIGHT", 10, -6);
	GameTooltip:SetRuneforgeResultItem(itemPreviewInfo.itemGUID, itemPreviewInfo.itemLevel);

	SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
	GameTooltip:Show();

	local resultTooltip = self.ResultTooltip;
	resultTooltip:SetOwner(self, "ANCHOR_NONE");
	resultTooltip:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 4, 0);
	local upgradeItemLevel = C_Item.GetCurrentItemLevel(upgradeItem);
	resultTooltip:SetRuneforgeResultItem(itemPreviewInfo.itemGUID, upgradeItemLevel);
	resultTooltip:Show();

	SetUIPanelAttribute(self, "width", self:GetWidth());
	UpdateUIPanelPositions(self);
end

function RuneforgeFrameMixin:SetItem(itemLocation, autoSelectSlot)
	return self.CraftingFrame:SetItem(itemLocation, autoSelectSlot);
end

function RuneforgeFrameMixin:SetItemAutomatic(itemLocation)
	local autoSelectSlot = true;
	return self.CraftingFrame:SetItem(itemLocation, autoSelectSlot);
end

function RuneforgeFrameMixin:GetItem()
	return self.CraftingFrame:GetItem();
end

function RuneforgeFrameMixin:HasItem()
	return self:GetItem() ~= nil;
end

function RuneforgeFrameMixin:GetUpgradeItem()
	return self.CraftingFrame:GetUpgradeItem();
end

function RuneforgeFrameMixin:HasUpgradeItem()
	return self.CraftingFrame:GetUpgradeItem() ~= nil;
end

function RuneforgeFrameMixin:SetPowerID(powerID)
	return self.CraftingFrame:SetPowerID(powerID);
end

function RuneforgeFrameMixin:GetPowerID()
	return self.CraftingFrame:GetPowerID();
end

function RuneforgeFrameMixin:TogglePowerList()
	self.CraftingFrame:TogglePowerList();
end

function RuneforgeFrameMixin:GetPowers()
	local item = self.CraftingFrame:GetItem();
	if item then
		return C_LegendaryCrafting.GetRuneforgePowers(item, Enum.RuneforgePowerFilter.Relevant);
	else
		local classID, specID = RuneforgeUtil.GetPreviewClassAndSpec();
		local primaryPowers = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(classID, specID, C_Covenants.GetActiveCovenantID(), Enum.RuneforgePowerFilter.Relevant);
		local otherPowers = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(classID, nil, nil, Enum.RuneforgePowerFilter.Relevant);

		local invertedPrimaryPowers = tInvert(primaryPowers);
		local function FilterPredicate(powerID)
			return invertedPrimaryPowers[powerID] == nil;
		end

		local isIndexTable = true;
		otherPowers = tFilter(otherPowers, FilterPredicate, isIndexTable);

		return primaryPowers, otherPowers;
	end
end

function RuneforgeFrameMixin:GetCraftDescription()
	local craftDescription = {};

	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	if not baseItem or not powerID or #modifiers ~= 2 then
		return nil;
	end

	return C_LegendaryCrafting.MakeRuneforgeCraftDescription(baseItem, powerID, modifiers);
end

function RuneforgeFrameMixin:HasValidItemForRuneforgeState()
	if self:IsRuneforgeUpgrading() then
		if not self:HasAnyItem(RuneforgeUtil.IsUpgradeableRuneforgeLegendary) then
			return false;
		end
	else
		if not self:HasAnyItem(C_LegendaryCrafting.IsValidRuneforgeBaseItem) then
			return false;
		end
	end

	return true;
end

function RuneforgeFrameMixin:HasOnlyMaxLevelRuneforgeLegendaries()
	if not self:HasAnyItem(C_LegendaryCrafting.IsRuneforgeLegendary) then
		return false;
	end

	local function IsRuneforgeLegendaryNonMaxLevel(...)
		return C_LegendaryCrafting.IsRuneforgeLegendary(...) and not C_LegendaryCrafting.IsRuneforgeLegendaryMaxLevel(...);
	end

	if self:HasAnyItem(IsRuneforgeLegendaryNonMaxLevel) then
		return false;
	end

	return true;
end

function RuneforgeFrameMixin:HasValidUpgradeItem()
	return self:IsRuneforgeUpgrading() and self:HasAnyItem(GenerateClosure(self.IsUpgradeItemValidForRuneforgeLegendary, self));
end

function RuneforgeFrameMixin:HasAnyItem(filterFunction)
	local results = {};
	self.CraftingFrame:GetRuneforgeFlyoutItemsCallback(filterFunction, results);
	return next(results) ~= nil;
end

local function IsAnyPowerAvailable(powerList)
	for i, powerID in ipairs(powerList) do
		local powerInfo = C_LegendaryCrafting.GetRuneforgePowerInfo(powerID);
		if powerInfo.state == Enum.RuneforgePowerState.Available then
			return true;
		end
	end
end

function RuneforgeFrameMixin:IsAnyPowerAvailable()
	local specPowers, otherSpecPowers = self:GetPowers();
	return IsAnyPowerAvailable(specPowers) or (otherSpecPowers and IsAnyPowerAvailable(otherSpecPowers));
end

function RuneforgeFrameMixin:GetNumAvailableModifierTypes()
	local count = 0;
	local modifierItemIDs = C_LegendaryCrafting.GetRuneforgeModifiers();
	for i, modifierItemID in ipairs(modifierItemIDs) do
		if ItemUtil.GetCraftingReagentCount(modifierItemID) > 0 then
			count = count + 1;
		end
	end

	return count;
end

function RuneforgeFrameMixin:CanAffordRuneforgeLegendary()
	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	if baseItem == nil then
		return false, nil;
	end

	local isUpgrading = self:IsRuneforgeUpgrading();

	local upgradeItem = self:GetUpgradeItem();
	if isUpgrading and (upgradeItem == nil) then
		return false, nil;
	end

	local costs = isUpgrading and C_LegendaryCrafting.GetRuneforgeLegendaryUpgradeCost(baseItem, upgradeItem) or C_LegendaryCrafting.GetRuneforgeLegendaryCost(baseItem);
	for i, cost in ipairs(costs) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(cost.currencyID);
		if cost.amount > currencyInfo.quantity then
			local formatString = isUpgrading and RUNEFORGE_LEGENDARY_ERROR_UPGRADE_INSUFFICIENT_CURRENCY_FORMAT or RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_CURRENCY_FORMAT;
			return false, formatString:format(currencyInfo.name);
		end
	end

	return true, nil;
end

function RuneforgeFrameMixin:HasRuneforgeLegendaryForUpgrade()
	if self:HasOnlyMaxLevelRuneforgeLegendaries() then
		return false, RUNEFORGE_LEGENDARY_ERROR_ALL_MAX_LEVEL;
	end

	if not self:HasValidItemForRuneforgeState() then
		return false, RUNEFORGE_LEGENDARY_ERROR_NO_LEGENDARY_AVAILABLE;
	end

	return true, nil;
end

function RuneforgeFrameMixin:CanCraftRuneforgeLegendary()
	local isUpgrading = self:IsRuneforgeUpgrading();
	if isUpgrading then
		local hasRuneforgeLegendaryForUpgrade, errorText = self:HasRuneforgeLegendaryForUpgrade();
		if not hasRuneforgeLegendaryForUpgrade then
			return false, errorText;
		end
	else
		if not self:HasValidItemForRuneforgeState() then
			return false, RUNEFORGE_LEGENDARY_ERROR_NO_BASE_ITEM_AVAILABLE;
		end

		if not self:IsAnyPowerAvailable() then
			return false, RUNEFORGE_LEGENDARY_ERROR_NO_POWER;
		end

		local availableModifierTypes = self:GetNumAvailableModifierTypes();
		if availableModifierTypes <= 1 then
			return false, RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_MODIFIERS;
		end
	end

	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();

	if baseItem == nil then
		return false, nil;
	end

	if isUpgrading and not self:HasValidUpgradeItem() then
		return false, RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_NO_UPGRADE_ITEM_AVAILABLE;
	end
	
	local upgradeItem = self:GetUpgradeItem();
	if isUpgrading and (upgradeItem == nil) then
		return false, nil;
	end

	local canAfford, costError = self:CanAffordRuneforgeLegendary();
	if not canAfford then
		return false, costError;
	end

	-- We need exactly 2 modifiers, one for each secondary stat.
	if not powerID or #modifiers ~= 2 then
		return false, nil;
	end

	return true, nil;
end

function RuneforgeFrameMixin:GetModelSceneFromLevel(level)
	if level == RuneforgeUtil.Level.Background then
		return self.BackgroundModelScene;
	elseif level == RuneforgeUtil.Level.Overlay then
		return self.OverlayModelScene;
	else -- RuneforgeUtil.Level.Frame is omitted as that is the default level.
		return self.CraftingFrame.ModelScene;
	end
end

function RuneforgeFrameMixin:AddEffect(level, ...)
	local modelScene = self:GetModelSceneFromLevel(level);
	return modelScene:AddEffect(...);
end

function RuneforgeFrameMixin:SetRuneforgeState(state)
	self:SetItem(nil);
	self.runeforgeState = state;

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:GetRuneforgeState()
	return self.runeforgeState;
end

function RuneforgeFrameMixin:GetItemContext()
	local hasItem = self:HasItem();
	if self:GetRuneforgeState() == RuneforgeUtil.RuneforgeState.Upgrade then
		if not self:HasItem() then
			return ItemButtonUtil.ItemContextEnum.SelectRuneforgeItem;
		end

		if not self:HasUpgradeItem() then
			return ItemButtonUtil.ItemContextEnum.SelectRuneforgeUpgradeItem;
		end
	else
		if not self:HasItem() then
			return ItemButtonUtil.ItemContextEnum.PickRuneforgeBaseItem;
		end
	end

	return nil;
end

function RuneforgeFrameMixin:GetCost()
	local baseItem = self:GetItem();
	if self:IsRuneforgeUpgrading() then
		local upgradeItem = self:GetUpgradeItem();
		return (baseItem and upgradeItem) and C_LegendaryCrafting.GetRuneforgeLegendaryUpgradeCost(baseItem, upgradeItem) or nil;
	else
		return baseItem and C_LegendaryCrafting.GetRuneforgeLegendaryCost(baseItem) or nil;
	end
end

function RuneforgeFrameMixin:IsUpgradeItemValidForRuneforgeLegendary(itemLocation)
	local baseItem = self:GetItem();
	if not baseItem then
		return false;
	end

	return C_LegendaryCrafting.IsUpgradeItemValidForRuneforgeLegendary(baseItem, itemLocation);
end

function RuneforgeFrameMixin:IsRuneforgeCrafting()
	return self:GetRuneforgeState() == RuneforgeUtil.RuneforgeState.Craft;
end

function RuneforgeFrameMixin:IsRuneforgeUpgrading()
	return self:GetRuneforgeState() == RuneforgeUtil.RuneforgeState.Upgrade;
end

function RuneforgeFrameMixin:GetRuneforgeComponentInfo()
	if not self:IsRuneforgeUpgrading() then
		return nil;
	end

	local baseItem = self:GetItem();
	if baseItem == nil then
		return nil;
	end

	return C_LegendaryCrafting.GetRuneforgeLegendaryComponentInfo(baseItem);
end

function RuneforgeFrameMixin:CraftItem()
	self.CreateFrame:CraftItem();
end
