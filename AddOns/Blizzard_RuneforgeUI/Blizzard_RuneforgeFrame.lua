
UIPanelWindows["RuneforgeFrame"] = { area = "left", pushable = 3, showFailedFunc = C_LegendaryCrafting.CloseRuneforgeInteraction, };

-- Determined by hand using positioning macros.
local CircleRuneEffects = {
	{ effectID = 60, offsetX = 51, offsetY = 149 },
	{ effectID = 62, offsetX = 155, offsetY = 33 },
	{ effectID = 63, offsetX = 156, offsetY = -39 },
	{ effectID = 64, offsetX = 23, offsetY = -165 },
	{ effectID = 65, offsetX = -54, offsetY = -153 },
	{ effectID = 66, offsetX = -141, offsetY = -80 },
	{ effectID = 67, offsetX = -129, offsetY = 94 },
	{ effectID = 68, offsetX = -64, offsetY = 143 },
};


RuneforgeFrameMixin = CreateFromMixins(CallbackRegistryMixin);

RuneforgeFrameMixin:GenerateCallbackEvents(
{
	"BaseItemChanged",
	"PowerSelected",
	"ModifiersChanged",
	"ItemSlotOnEnter",
	"ItemSlotOnLeave",
});

local RuneforgeFrameEvents = {
	"CURRENCY_DISPLAY_UPDATE",
	"RUNEFORGE_LEGENDARY_CRAFTING_CLOSED",
};

local RuneforgeFrameUnitEvents = {
	"UNIT_SPELLCAST_SUCCEEDED",
};

function RuneforgeFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self.ResultTooltip:Init();
end

function RuneforgeFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, RuneforgeFrameUnitEvents, "player");

	self:RefreshCurrencyDisplay();
	self:SetStaticEffectsShown(true);

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFrameUnitEvents);

	C_LegendaryCrafting.CloseRuneforgeInteraction();

	self:SetStaticEffectsShown(false);

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		-- If this is a Runeforge currency, update.
		local updatedCurrencyID = ...;
		for i, currencyID in ipairs(C_LegendaryCrafting.GetRuneforgeLegendaryCurrencies()) do
			if currencyID == updatedCurrencyID then
				self:RefreshCurrencyDisplay();
				break;
			end
		end
	elseif event == "RUNEFORGE_LEGENDARY_CRAFTING_CLOSED" then
		HideUIPanel(self);
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, castGUID, spellID = ...;
		if spellID == C_LegendaryCrafting.GetRuneforgeLegendaryCraftSpellID() then
			self:SetItem(nil);
		end
	end
end

function RuneforgeFrameMixin:SetStaticEffectsShown(shown)
	if not self.centerPassiveEffect and shown then
		self.centerPassiveEffect = self:AddEffect(RuneforgeUtil.Level.Background, RuneforgeUtil.Effect.CenterPassive, self.CraftingFrame.BaseItemSlot);

		local bottomEffectDynamicDescription = { effectID = RuneforgeUtil.Effect.BottomPassive, offsetY = -204, };
		self.bottomEffect = self.BottomModelScene:AddDynamicEffect(bottomEffectDynamicDescription, self);

	elseif self.centerPassiveEffect and not shown then
		self.centerPassiveEffect:CancelEffect();
		self.centerPassiveEffect = nil;

		self.bottomEffect:CancelEffect();
		self.bottomEffect = nil;
	end
end

function RuneforgeFrameMixin:SetRunesShown(shown)
	if self.runeEffects and not shown then
		for i, effectController in ipairs(self.runeEffects) do
			effectController:CancelEffect();
		end

		self.runeEffects = nil;
	elseif not self.runeEffects and shown then
		self.runeEffects = {};

		for i, effect in ipairs(CircleRuneEffects) do
			local effectController = self.OverlayModelScene:AddDynamicEffect(effect, self.CraftingFrame.BaseItemSlot);
			table.insert(self.runeEffects, effectController);
		end
	end
end

function RuneforgeFrameMixin:RefreshCurrencyDisplay()
	local initFunction = nil;
	local initialAnchor = nil;
	local gridLayout = nil;
	local tooltipAnchor = "ANCHOR_RIGHT";
	return self.CurrencyDisplay:SetCurrencies(C_LegendaryCrafting.GetRuneforgeLegendaryCurrencies(), initFunction, initialAnchor, gridLayout, tooltipAnchor);
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

function RuneforgeFrameMixin:RefreshResultTooltip()
	local resultTooltip = self.ResultTooltip;
	local tooltipWasShown = resultTooltip:IsShown();
	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	local hasItem = baseItem ~= nil;
	if hasItem then
		resultTooltip:SetOwner(self, "ANCHOR_NONE");
		resultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -160);
		local itemID = C_Item.GetItemID(baseItem);
		resultTooltip:SetRuneforgeResultItem(itemID, powerID, modifiers);
	end
	
	resultTooltip:SetShown(hasItem);

	if tooltipWasShown ~= hasItem then
		local panelWidth = hasItem and (self:GetWidth() + resultTooltip:GetWidth()) or self:GetWidth();
		SetUIPanelAttribute(self, "width", panelWidth);
		UpdateUIPanelPositions(self);
	end
end

function RuneforgeFrameMixin:SetItem(itemLocation)
	if not itemLocation or C_LegendaryCrafting.IsValidRuneforgeBaseItem(itemLocation) then
		return self.CraftingFrame:SetItem(itemLocation);
	end

	return false;
end

function RuneforgeFrameMixin:GetItem()
	return self.CraftingFrame:GetItem();
end

function RuneforgeFrameMixin:HasItem()
	return self:GetItem() ~= nil;
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
	return C_LegendaryCrafting.GetRuneforgePowers(item);
end

function RuneforgeFrameMixin:GetCraftDescription()
	local craftDescription = {};

	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();
	if not baseItem or not powerID or #modifiers ~= 2 then
		return nil;
	end

	return C_LegendaryCrafting.MakeRuneforgeCraftDescription(baseItem, powerID, modifiers);
end

function RuneforgeFrameMixin:CanCraftRuneforgeLegendary()
	local baseItem, powerID, modifiers = self:GetLegendaryCraftInfo();

	if not baseItem then
		return false, nil;
	end

	for i, cost in ipairs(C_LegendaryCrafting.GetRuneforgeLegendaryCost(baseItem)) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(cost.currencyID);
		if cost.amount > currencyInfo.quantity then
			return false, RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_CURRENCY_FORMAT:format(currencyInfo.name);
		end
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

function RuneforgeFrameMixin:Close()
	HideUIPanel(self);
end
