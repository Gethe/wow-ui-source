
RuneforgeItemSlotButtonMixin = {};

function RuneforgeItemSlotButtonMixin:OnLoad()
	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAtlas("runecarving-icon-center-empty", true);
	normalTexture:SetPoint("CENTER"); -- Remove the standard -1 offset.

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:ClearAllPoints();
	pushedTexture:SetPoint("CENTER");
	pushedTexture:SetAtlas("runecarving-icon-center-pressed", true);

	self.IconBorder:SetAlpha(0);
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

function RuneforgeItemSlotButtonMixin:SetItemLocation(itemLocation)
	local hasItem = itemLocation ~= nil;
	self.SelectedTexture:SetShown(hasItem);

	local alpha = hasItem and 0 or 1;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);

	ItemButtonMixin.SetItemLocation(self, itemLocation);
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
	if currentItemLocation and C_Item.DoesItemExist(currentItemLocation) then
		C_Item.UnlockItem(currentItemLocation);
	end

	self.ItemButton:SetItemLocation(itemLocation);

	if itemLocation ~= nil then
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
		OpenAllBagsMatchingContext(self:GetRuneforgeFrame());

		local isLocked = true;
		self.ItemButton:SetButtonState("PUSHED", isLocked);
	else
		local forceUpdate = true;
		CloseAllBags(self:GetRuneforgeFrame(), forceUpdate);

		self.ItemButton:SetButtonState("NORMAL");
	end	
end
