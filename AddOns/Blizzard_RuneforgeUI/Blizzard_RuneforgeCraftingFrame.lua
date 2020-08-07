
RuneforgeCraftingFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeCraftingFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function RuneforgeCraftingFrameMixin:OnLoad()

	self.flyoutSettings = {
		customFlyoutOnUpdate = nop,
		hasPopouts = true,
		parent = self:GetParent(),
		anchorX = 20,
		anchorY = -8,
		useItemLocation = true,
		hideFlyoutHighlight = true,
		alwaysHideOnClick = true,
	};

	local function SelectFlyoutItemButtonCallback(flyoutButton)
		self:SetItem(flyoutButton:GetItemLocation());
	end

	local function UpgradeItemValidation(itemLocation)
		return self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(itemLocation);
	end

	local function UpgradeItemSelectFlyoutItemButtonCallback(flyoutButton)
		self:SetUpgradeItem(flyoutButton:GetItemLocation());
	end

	self.flyoutTypeToCallbacks = {
		[RuneforgeUtil.FlyoutType.BaseItem] = { C_LegendaryCrafting.IsValidRuneforgeBaseItem, SelectFlyoutItemButtonCallback },
		[RuneforgeUtil.FlyoutType.Legendary] = { C_LegendaryCrafting.IsRuneforgeLegendary, SelectFlyoutItemButtonCallback },
		[RuneforgeUtil.FlyoutType.UpgradeItem] = { UpgradeItemValidation, UpgradeItemSelectFlyoutItemButtonCallback },
	};
end

function RuneforgeCraftingFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self:RegisterRefreshMethod(self.Refresh);
end

function RuneforgeCraftingFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self.PowerFrame:Hide();
	
	self:UnregisterRefreshMethod();
end

function RuneforgeCraftingFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		if isRightButton or (not DoesAncestryInclude(self.PowerFrame, mouseFocus) and mouseFocus ~= self.PowerSlot) then
			self.PowerFrame:Hide();
		end

		if isRightButton or (not DoesAncestryInclude(self.ModifierFrame, mouseFocus)) then
			self.ModifierFrame:CloseSelector();
		end

		local flyoutSelected = not isRightButton and DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus);
		if not flyoutSelected then
			EquipmentFlyout_Hide();
		end

		if not flyoutSelected and (not DoesAncestryInclude(self.BaseItemSlot, mouseFocus)) then
			self.BaseItemSlot:SetSelectingItem(nil);
		end
	end
end

function RuneforgeCraftingFrameMixin:ShowFlyout(button, flyoutType)
	if flyoutType == nil then
		flyoutType = self:IsRuneforgeUpgrading() and RuneforgeUtil.FlyoutType.Legendary or RuneforgeUtil.FlyoutType.BaseItem;
	end

	self:SetDynamicFlyoutSettings(flyoutType);
	EquipmentFlyout_Show(button);
	PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_SELECTION_SUB_WINDOW);
end

function RuneforgeCraftingFrameMixin:SetDynamicFlyoutSettings(flyoutType)
	local callbacks = self.flyoutTypeToCallbacks[flyoutType];
	local filterFunction = callbacks[1];

	-- itemSlot is required by the API, but unused in this context.
	local function GetRuneforgeLegendariesCallback(itemSlot, resultsTable)
		self:GetRuneforgeFlyoutItemsCallback(filterFunction, resultsTable);
	end

	self.flyoutSettings.getItemsFunc = GetRuneforgeLegendariesCallback;
	self.flyoutSettings.onClickFunc = callbacks[2];
end

function RuneforgeCraftingFrameMixin:SetUpgradeItem(item)
	self.UpgradeItemSlot:SetItem(item);
end

function RuneforgeCraftingFrameMixin:SetItem(item, autoSelectSlot)
	if item == nil then
		self.BaseItemSlot:SetItem(item);
	elseif self:IsRuneforgeUpgrading() then
		if autoSelectSlot and (self:GetItem() ~= nil) then
			if self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(item) then
				self:SetUpgradeItem(item);
			end
		elseif C_LegendaryCrafting.IsRuneforgeLegendary(item) then
			self.BaseItemSlot:SetItem(item);
		end
	else
		if C_LegendaryCrafting.IsValidRuneforgeBaseItem(item) then
			self.BaseItemSlot:SetItem(item);
		end
	end

	return false;
end

function RuneforgeCraftingFrameMixin:GetItem()
	return self.BaseItemSlot:GetItem();
end

function RuneforgeCraftingFrameMixin:GetUpgradeItem()
	return self.UpgradeItemSlot:GetItem();
end

function RuneforgeCraftingFrameMixin:SetPowerID(powerID)
	return self.PowerSlot:SetPowerID(powerID);
end

function RuneforgeCraftingFrameMixin:GetPowerID()
	return self.PowerSlot:GetPowerID();
end

function RuneforgeCraftingFrameMixin:GetModifiers()
	return self.ModifierFrame:GetModifiers();
end

function RuneforgeCraftingFrameMixin:TogglePowerList()
	if self.PowerFrame:IsShown() then
		self.PowerFrame:Hide();
	else
		PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_SELECTION_SUB_WINDOW);
		self.PowerFrame:OpenPowerList(self:GetRuneforgeFrame():GetPowers());
		self.PowerFrame:Show();
	end
end

function RuneforgeCraftingFrameMixin:Refresh()
	local hasItem = self:GetItem() ~= nil;
	if self.RunesGlow:IsShown() == hasItem then
		return;
	end

	self:GetRuneforgeFrame():SetRunesShown(hasItem);
	self.RunesGlow:SetShown(hasItem);

	if hasItem then
		self.RunesGlow.FadeIn:Play();
	end

	self.UpgradeItemSlot:SetShown(hasItem and self:IsRuneforgeUpgrading());
end

function RuneforgeCraftingFrameMixin:GetRuneforgeFlyoutItemsCallback(filterFunction, resultsTable)
	local function ItemLocationCallback(itemLocation)
		if filterFunction(itemLocation) then
			resultsTable[itemLocation] = C_Item.GetItemID(itemLocation);
		end
	end

	ContainerFrameUtil_IteratePlayerInventory(ItemLocationCallback);

	for i = EQUIPPED_FIRST, EQUIPPED_LAST do
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(i);
		if C_Item.DoesItemExist(itemLocation) then
			ItemLocationCallback(itemLocation);
		end
	end
end

function RuneforgeCraftingFrameMixin:GetRuneforgeFrame()
	return self:GetParent();
end
