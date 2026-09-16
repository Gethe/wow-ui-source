
HUDInventoryMixin = {};

local HUD_INVENTORY_BAR_EVENTS = {
	"UPDATE_BINDINGS",
	"GAME_PAD_ACTIVE_CHANGED",
	"BAG_NEW_ITEMS_UPDATED",
	"UNIT_INVENTORY_CHANGED",
	"ITEM_LOCK_CHANGED",
	"BAG_UPDATE",
};

function HUDInventoryMixin:OnLoad()
	HUDInventoryUtil.RegisterHUDElement(self);
	self.itemButtonPool = CreateFramePool("ItemButton", self, self.buttonTemplate);
	self:SetNumItemButtons(self.baseNumItemButtons);
end

function HUDInventoryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HUD_INVENTORY_BAR_EVENTS);
	self:UpdateItems();
end

function HUDInventoryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HUD_INVENTORY_BAR_EVENTS);
end

function HUDInventoryMixin:OnEvent(event)
	if event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" or
		event == "BAG_NEW_ITEMS_UPDATED" or event == "UNIT_INVENTORY_CHANGED" or
		event == "BAG_UPDATE" or event == "ITEM_LOCK_CHANGED" then
		self:UpdateItems();
	end
end

function HUDInventoryMixin:SetNumItemButtons(numItemButton)
	self.numItemButtons = numItemButton;
	self:SetupItems();
end

function HUDInventoryMixin:GetNumItemButtons()
	return self.numItemButtons;
end

function HUDInventoryMixin:UseItemButton(index)
	for itemButton in self.itemButtonPool:EnumerateActive() do
		if itemButton.layoutIndex == index then
			itemButton:HandleClick();
			return;
		end
	end
end

function HUDInventoryMixin:SetupItems()
	self.itemButtonPool:ReleaseAll();

	local itemContinuable = ContinuableContainer:Create();
	self.itemContinuable = itemContinuable;

	self:LayoutItemButtons(itemContinuable);

	itemContinuable:ContinueOnLoad(function()
		self.itemContinuable = nil;
		self:UpdateItems();
	end);
end

function HUDInventoryMixin:UpdateItems()
	for itemButton in self.itemButtonPool:EnumerateActive() do
		itemButton:UpdateItem();
	end
end

function HUDInventoryMixin:SetCommandPrefix(commandPrefix)
	self.commandPrefix = commandPrefix;
	for itemButton in self.itemButtonPool:EnumerateActive() do
		local commandName = self:GetCommandForIndex(itemButton.layoutIndex);
		itemButton:SetCommandName(commandName);
	end
end

function HUDInventoryMixin:GetCommandForIndex(layoutIndex)
	local buttonID = (self.startID - 1) + layoutIndex;
	local commandName = self.commandPrefix and (self.commandPrefix .. buttonID) or nil;
	return commandName;
end

function HUDInventoryMixin:DoQuickKeybindModeChange(showQuickKeybindMode)
	for itemButton in self.itemButtonPool:EnumerateActive() do
		itemButton:DoModeChange(showQuickKeybindMode);
	end
end

function HUDInventoryMixin:LayoutItemButtons()
	-- Override in your derived mixin.
end

-- Used for both these horizontal and grid layout frame versions of HUD inventory.
HUDInventoryLayoutFrameMixin = {};

function HUDInventoryLayoutFrameMixin:OnShow()
	HUDInventoryMixin.OnShow(self);
	BaseLayoutMixin.OnShow(self);
end

function HUDInventoryLayoutFrameMixin:SetupItems()
	HUDInventoryMixin.SetupItems(self);

	self:MarkDirty();
end

function HUDInventoryLayoutFrameMixin:LayoutItemButtons(itemContinuable)
	-- Overrides HUDInventoryMixin.

	for i = 1, self.numItemButtons do
		local itemButton = self.itemButtonPool:Acquire();
		itemButton.layoutIndex = i;

		local buttonID = (self.startID - 1) + i;
		local commandName = self:GetCommandForIndex(i);
		itemButton:SetInfo(self.bagID, buttonID, commandName);
		itemButton:Show();

		local item = Item:CreateFromBagAndSlot(self.bagID, buttonID);
		if not item:IsItemEmpty() then
			itemContinuable:AddContinuable(item);
		end
	end

	self:MarkDirty();
end

HUDInventoryBarMixin = CreateFromMixins(HUDInventoryMixin, HUDInventoryLayoutFrameMixin);

-- This is no longer used but this should work if needed. Be sure to uncomment the associated XML template.
-- HUDInventoryGridMixin = CreateFromMixins(HUDInventoryMixin, HUDInventoryLayoutFrameMixin);