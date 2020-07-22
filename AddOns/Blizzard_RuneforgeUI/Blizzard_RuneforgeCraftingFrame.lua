
RuneforgeCraftingFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeCraftingFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function RuneforgeCraftingFrameMixin:OnLoad()
	local function RuneforgeSelectUpgradeItemButtonCallback(flyoutButton)
		self:SetItem(flyoutButton:GetItemLocation());
	end

	-- itemSlot is required by the API, but unused in this context.
	local function GetRuneforgeLegendariesCallback(itemSlot, resultsTable)
		self:GetRuneforgeLegendariesCallback(resultsTable);
	end

	self.flyoutSettings = {
		onClickFunc = RuneforgeSelectUpgradeItemButtonCallback,
		getItemsFunc = GetRuneforgeLegendariesCallback,
		postGetItemsFunc = function (itemButton, itemDisplayTable, numTotalItems) return numTotalItems; end,
		customFlyoutOnUpdate = nop,
		hasPopouts = true,
		parent = self:GetParent(),
		anchorX = 20,
		anchorY = -8,
		useItemLocation = true,
		hideFlyoutHighlight = true,
		alwaysHideOnClick = true,
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

		if isRightButton or (not DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus)) then
			EquipmentFlyout_Hide();
		end
	end
end

function RuneforgeCraftingFrameMixin:SetItem(item, autoSelectSlot)
	if item == nil then
		self.BaseItemSlot:SetItem(item);
	elseif self:IsRuneforgeUpgrading() then
		if autoSelectSlot and (self:GetItem() ~= nil) then
			if self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(item) then
				self.UpgradeItemSlot:SetItem(item);
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

function RuneforgeCraftingFrameMixin:GetRuneforgeLegendariesCallback(resultsTable)
	local function ItemLocationCallback(itemLocation)
		if C_LegendaryCrafting.IsRuneforgeLegendary(itemLocation) then
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
