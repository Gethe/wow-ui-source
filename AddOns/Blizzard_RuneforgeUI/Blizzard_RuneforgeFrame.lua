
UIPanelWindows["RuneforgeFrame"] = { area = "left", pushable = 3, showFailedFunc = C_LegendaryCrafting.CloseRuneforgeInteraction, };


RuneforgeFrameMixin = CreateFromMixins(CallbackRegistryMixin);

RuneforgeFrameMixin:GenerateCallbackEvents(
{
	"BaseItemChanged",
	"ItemLevelTierChanged",
	"PowerSelected",
	"ModifiersChanged",
});

local RuneforgeFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
	"CURRENCY_DISPLAY_UPDATE",
	"RUNEFORGE_LEGENDARY_CRAFTING_CLOSED",
};

local RuneforgeFrameUnitEvents = {
	"UNIT_SPELLCAST_SUCCEEDED",
};

function RuneforgeFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
end

function RuneforgeFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, RuneforgeFrameUnitEvents, "player");

	self:RefreshCurrencyDisplay();

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeFrameUnitEvents);

	C_LegendaryCrafting.CloseRuneforgeInteraction();

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function RuneforgeFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local mouseFocus = GetMouseFocus();
		if not DoesAncestryInclude(self.PowerFrame, mouseFocus) and mouseFocus ~= self.PowerSlot then
			self.PowerFrame:Hide();
		end

		if not DoesAncestryInclude(self.ModifierFrame, mouseFocus) then
			self.ModifierFrame:CloseSelector();
		end
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		-- If this is a Runeforge currency, update.
		local updatedCurrencyID = ...;
		for i, currencyID in ipairs(RuneforgeUtil.GetRuneforgeCurrencies()) do
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

function RuneforgeFrameMixin:RefreshCurrencyDisplay()
	return self.CurrencyDisplay:SetCurrencies(RuneforgeUtil.GetRuneforgeCurrencies());
end

function RuneforgeFrameMixin:GetLegendaryCraftInfo()
	local itemLocation = self:GetItem();
	if itemLocation then
		local powerID = self.PowerSlot:GetPowerID();
		local modifiers = self.ModifierFrame:GetModifiers();
		local itemLevelTierIndex = self.ItemLevelSelector:GetItemLevelTierIndex();
		return itemLocation, powerID, modifiers, itemLevelTierIndex;
	end

	return nil;
end

function RuneforgeFrameMixin:SetItemTooltip(tooltip)
	local baseItem, powerID, modifiers, itemLevelTierIndex = self:GetLegendaryCraftInfo();
	if baseItem then
		local itemID = C_Item.GetItemID(baseItem);
		tooltip:SetRuneforgeResultItem(itemID, powerID, modifiers, itemLevelTierIndex);
	end
end

function RuneforgeFrameMixin:SetItem(itemLocation)
	if not itemLocation or C_LegendaryCrafting.IsValidRuneforgeBaseItem(itemLocation) then
		return self.BaseItemSlot:SetItem(itemLocation);
	end

	return false;
end

function RuneforgeFrameMixin:GetItem()
	return self.BaseItemSlot:GetItem();
end

function RuneforgeFrameMixin:HasItem()
	return self:GetItem() ~= nil;
end

function RuneforgeFrameMixin:TogglePowerList()
	if self.PowerFrame:IsShown() then
		self.PowerFrame:Hide();
	else
		self.PowerFrame:OpenPowerList(self:GetPowers());
		self.PowerFrame:Show();
	end
end

function RuneforgeFrameMixin:GetItemLevelTiers()
	local item = self.BaseItemSlot:GetItem();
	if not item then
		return nil;
	end

	return C_LegendaryCrafting.GetItemLevelTiers(item);
end

function RuneforgeFrameMixin:GetModifierSelections()
	local item = self.BaseItemSlot:GetItem();
	if not item then
		return {};
	end

	return C_LegendaryCrafting.GetRuneforgeModifiers(item);
end

function RuneforgeFrameMixin:GetPowers()
	local item = self.BaseItemSlot:GetItem();
	return C_LegendaryCrafting.GetRuneforgePowers(item);
end

function RuneforgeFrameMixin:GetItemLevelTier()
	return self.ItemLevelSelector:GetItemLevelTier();
end

function RuneforgeFrameMixin:GetCraftDescription()
	local craftDescription = {};

	local baseItem, powerID, modifiers, itemLevelTierIndex = self:GetLegendaryCraftInfo();
	if not baseItem or not powerID or #modifiers ~= 2 or not itemLevelTierIndex then
		return nil;
	end

	return C_LegendaryCrafting.MakeRuneforgeCraftDescription(baseItem, powerID, itemLevelTierIndex, modifiers);
end

function RuneforgeFrameMixin:Close()
	HideUIPanel(self);
end
