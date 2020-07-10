
RuneforgeItemSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeItemSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAtlas("runecarving-icon-center-empty", true);
	normalTexture:SetPoint("CENTER"); -- Remove the standard -1 offset.

	self:GetPushedTexture():SetAlpha(0);
	self.IconBorder:SetAlpha(0);

	self:AddEffectData("primary", RuneforgeUtil.Effect.CenterRune, RuneforgeUtil.EffectTarget.None, RuneforgeUtil.Level.Overlay);
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

function RuneforgeItemSlotMixin:OnMouseDown()
	self:SetEffectShown("primary", false);
end

function RuneforgeItemSlotMixin:OnMouseUp()
	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnReceiveDrag()
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem and C_LegendaryCrafting.IsValidRuneforgeBaseItem(cursorItem) then
		self:SetItem(cursorItem);
		ClearCursor();
	end
end

function RuneforgeItemSlotMixin:OnEnter()
	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.ItemSlotOnEnter);
end

function RuneforgeItemSlotMixin:OnLeave()
	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.ItemSlotOnLeave);
	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnShow()
	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnHide()
	self:SetItem(nil);
end

function RuneforgeItemSlotMixin:SetItemLocation(itemLocation)
	local hasItem = itemLocation ~= nil;
	self.SelectedTexture:SetShown(hasItem);

	local alpha = hasItem and 0 or 1;
	self:GetNormalTexture():SetAlpha(alpha);

	ItemButtonMixin.SetItemLocation(self, itemLocation);
end

function RuneforgeItemSlotMixin:SetItem(itemLocation)
	local currentItemLocation = self:GetItemLocation();
	if currentItemLocation and C_Item.DoesItemExist(currentItemLocation) then
		C_Item.UnlockItem(currentItemLocation);
	end

	self:SetItemLocation(itemLocation);

	local hasItem = itemLocation ~= nil;
	if hasItem then
		C_Item.LockItem(itemLocation);
	end

	self:SetSelectingItem(nil);

	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.BaseItemChanged);
end

function RuneforgeItemSlotMixin:GetItem()
	return self:GetItemLocation();
end

function RuneforgeItemSlotMixin:SetSelectingItem(isSelectingItem)
	self.SelectingTexture:SetShown(isSelectingItem);

	if isSelectingItem then
		OpenAllBagsMatchingContext(self:GetRuneforgeFrame());
	else
		local forceUpdate = true;
		CloseAllBags(self:GetRuneforgeFrame(), forceUpdate);
	end

	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:UpdateEffectVisibility(forceHide)
	local hasItem = self:GetItem() ~= nil;
	self:SetEffectShown("primary", not hasItem and not self.SelectingTexture:IsShown());
end
