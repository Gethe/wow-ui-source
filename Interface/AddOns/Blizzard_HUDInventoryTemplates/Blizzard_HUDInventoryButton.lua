
HUDInventoryButtonMixin = {};

function HUDInventoryButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton", "RightButton");
end

function HUDInventoryButtonMixin:OnDragStart()
	C_Container.PickupContainerItem(self:GetBagID(), self:GetID());
end

function HUDInventoryButtonMixin:OnReceiveDrag()
	self:OnDragStart();
end

function HUDInventoryButtonMixin:OnEnter()
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnEnter(self);

	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 100);
	GameTooltip:SetBagItem(self:GetBagID(), self:GetID());
	GameTooltip:Show();
end

function HUDInventoryButtonMixin:OnLeave()
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnLeave(self);

	GameTooltip_Hide();
end

function HUDInventoryButtonMixin:OnClick(button, ...)
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnClick(self, button, ...);

	local modifiedClick = IsModifiedClick();

	-- If we can loot the item and autoloot toggle is active, then do a normal click
	if button ~= "LeftButton" and modifiedClick and IsModifiedClick("AUTOLOOTTOGGLE") then
		local info = C_Container.GetContainerItemInfo(self:GetBagID(), self:GetID());
		local lootable = info and info.hasLoot;
		if lootable then
			modifiedClick = false;
		end
	end

	if modifiedClick then
		self:HandleModifiedClick();
	else
		self:HandleClick();
	end
end

function HUDInventoryButtonMixin:HandleModifiedClick()
	local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
	HandleModifiedItemClick(C_Container.GetContainerItemLink(self:GetBagID(), self:GetID()), itemLocation);
end

function HUDInventoryButtonMixin:HandleClick()
	C_Container.UseContainerItem(self:GetBagID(), self:GetID());
end

function HUDInventoryButtonMixin:SetInfo(bagID, buttonID, commandName)
	self.bagID = bagID;
	self.buttonID = buttonID;
	self:SetCommandName(commandName);
	self:UpdateItem();
end

function HUDInventoryButtonMixin:SetCommandName(commandName)
	self.commandName = commandName;
	self:UpdateHotkey();
end

function HUDInventoryButtonMixin:GetBagID()
	return self.bagID;
end

function HUDInventoryButtonMixin:GetID()
	return self.buttonID;
end

function HUDInventoryButtonMixin:UpdateCooldown(hasItem)
	if hasItem then
		local start, duration, enable = C_Container.GetContainerItemCooldown(self:GetBagID(), self:GetID());
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(self, DARKGRAY_COLOR:GetRGB());
		else
			SetItemButtonTextureVertexColor(self, WHITE_FONT_COLOR:GetRGB());
		end
	else
		self.Cooldown:Hide();
	end
end

function HUDInventoryButtonMixin:UpdateItem()
	local itemInfo = C_Container.GetContainerItemInfo(self.bagID, self.buttonID);
	local hasItem = itemInfo ~= nil;
	local texture = hasItem and itemInfo.iconFileID;
	self:SetItemButtonTexture(texture);
	SetItemButtonCount(self, hasItem and itemInfo.stackCount);
	self:UpdateCooldown(hasItem);
	self:UpdateHotkey();
end

function HUDInventoryButtonMixin:UpdateHotkey()
	local hotkey = self.HotKey;
	hotkey:SetText(RANGE_INDICATOR);
	hotkey:Hide();

	if self.commandName then
		local key = GetBindingKey(self.commandName);
		local text = GetBindingText(key, 0);
		if text ~= "" then
			hotkey:SetText(text);
			hotkey:Show();
		end
	end
end
