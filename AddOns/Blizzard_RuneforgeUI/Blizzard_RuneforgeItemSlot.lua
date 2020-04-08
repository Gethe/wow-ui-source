
RuneforgeItemSlotButtonMixin = {};

function RuneforgeItemSlotButtonMixin:OnLoad()
	self:SetNormalTexture(nil);
end

function RuneforgeItemSlotButtonMixin:OnEnter()
	local itemLocation = self:GetItemLocation();
	if itemLocation then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		self:GetParent():GetRuneforgeFrame():SetItemTooltip(GameTooltip);
		GameTooltip:Show();
	end
end

function RuneforgeItemSlotButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgeItemSlotButtonMixin:OnClick(...)
	self:GetParent():OnClick(...);
end

function RuneforgeItemSlotButtonMixin:OnReceiveDrag(...)
	self:GetParent():OnReceiveDrag(...);
end


RuneforgeItemSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeItemSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function RuneforgeItemSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		self:SetItem(nil);
		return;
	end

	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem then
		if C_LegendaryCrafting.IsValidRuneforgeBaseItem(cursorItem) then
			self:SetItem(cursorItem);
			ClearCursor();
		end
	else
		self:SetSelectingItem(true);
	end
end

function RuneforgeItemSlotMixin:OnReceiveDrag()
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem and C_LegendaryCrafting.IsValidRuneforgeBaseItem(cursorItem) then
		self:SetItem(cursorItem);
		ClearCursor();
	end
end

function RuneforgeItemSlotMixin:OnEnter()
	self.ItemButton:LockHighlight();
end

function RuneforgeItemSlotMixin:OnLeave()
	self.ItemButton:UnlockHighlight();
end

function RuneforgeItemSlotMixin:OnHide()
	self:Reset();
end

function RuneforgeItemSlotMixin:Reset()
	self:SetItem(nil);
end

function RuneforgeItemSlotMixin:SetItem(itemLocation)
	local currentItemLocation = self.ItemButton:GetItemLocation();
	if currentItemLocation then
		C_Item.UnlockItem(currentItemLocation);
	end

	self.ItemButton:SetItemLocation(itemLocation);

	if itemLocation then
		C_Item.LockItem(itemLocation);
	end

	self:SetSelectingItem(nil);
	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.BaseItemChanged);
end

function RuneforgeItemSlotMixin:GetItem()
	return self.ItemButton:GetItemLocation();
end

function RuneforgeItemSlotMixin:SetSelectingItem(isSelectingItem)
	if isSelectingItem then
		OpenAllBags(self:GetRuneforgeFrame());
	else
		local forceUpdate = true;
		CloseAllBags(self:GetRuneforgeFrame(), forceUpdate);
	end
end
