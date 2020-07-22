
RuneforgeItemSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeItemSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	self.IconBorder:SetAlpha(0);

	self:SetEvents();
	self:SetTextureAndEffects();
end

function RuneforgeItemSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		self:SetItem(nil);
		return;
	end

	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem then
		if self:IsRuneforgeUpgrading() then
			if C_LegendaryCrafting.IsRuneforgeLegendary(cursorItem) then
				self:SetItem(cursorItem);
				ClearCursor();
			end
		else
			if C_LegendaryCrafting.IsValidRuneforgeBaseItem(cursorItem) then
				self:SetItem(cursorItem);
				ClearCursor();
			end
		end
	else
		if self:IsRuneforgeUpgrading() then
			EquipmentFlyout_Show(self);

			local skipBags = true;
			self:SetSelectingItem(true, skipBags);
		else
			self:SetSelectingItem(true);
		end
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
	if self.onEnterEvent then
		self:GetRuneforgeFrame():TriggerEvent(self.onEnterEvent);
	end
end

function RuneforgeItemSlotMixin:OnLeave()
	if self.onLeaveEvent then
		self:GetRuneforgeFrame():TriggerEvent(self.onLeaveEvent);
	end

	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnShow()
	self:UpdateEffectVisibility();

	if self:IsRuneforgeUpgrading() then
		self:SetNormalAtlas("runecarving-upgrade-icon-center-empty");
		self:SetPushedAtlas("runecarving-upgrade-icon-center-empty");
		self.SelectingTexture:SetAtlas("runecarving-upgrade-icon-center-pressed", true);
	else
		self:SetNormalAtlas("runecarving-icon-center-empty");
		self:SetPushedAtlas("runecarving-icon-center-empty");
		self.SelectingTexture:SetAtlas("runecarving-icon-center-pressed", true);
	end
end

function RuneforgeItemSlotMixin:OnHide()
	self:UpdateEffectVisibility();
	self:ResetItemSlot();
end

function RuneforgeItemSlotMixin:SetEvents()
	self.onEnterEvent = RuneforgeFrameMixin.Event.ItemSlotOnEnter;
	self.onLeaveEvent = RuneforgeFrameMixin.Event.ItemSlotOnLeave;
	self.onItemChangedEvent = RuneforgeFrameMixin.Event.BaseItemChanged;
end

function RuneforgeItemSlotMixin:SetTextureAndEffects()
	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAtlas("runecarving-icon-center-empty", true);
	normalTexture:SetPoint("CENTER"); -- Remove the standard -1 offset.

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:ClearAllPoints();
	pushedTexture:SetPoint("CENTER");
	pushedTexture:SetAtlas("runecarving-upgrade-icon-center-empty", true);

	self:AddEffectData("primary", RuneforgeUtil.Effect.CenterRune, RuneforgeUtil.EffectTarget.None, RuneforgeUtil.Level.Overlay);
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

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:SetAlpha(hasItem and 0 or 1);

	self:SetSelectingItem(nil);

	if self.onItemChangedEvent then
		self:GetRuneforgeFrame():TriggerEvent(self.onItemChangedEvent);
	end
end

function RuneforgeItemSlotMixin:ResetItemSlot()
	self:SetItem(nil);
end

function RuneforgeItemSlotMixin:GetItem()
	return self:GetItemLocation();
end

function RuneforgeItemSlotMixin:SetSelectingItem(isSelectingItem, skipBags)
	local hasItem = self:GetItemLocation() ~= nil;
	self.SelectingTexture:SetShown(isSelectingItem and not hasItem);

	if isSelectingItem and hasItem then
		self:LockHighlight();
	else
		self:UnlockHighlight();
	end

	if not skipBags then
		if isSelectingItem then
			OpenAllBagsMatchingContext(self:GetRuneforgeFrame());
		else
			local forceUpdate = true;
			CloseAllBags(self:GetRuneforgeFrame(), forceUpdate);
		end
	end

	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:UpdateEffectVisibility(forceHide)
	local hasItem = self:GetItem() ~= nil;
	self:SetEffectShown("primary", self:IsShown() and not hasItem and not self.SelectingTexture:IsShown());
end


RuneforgeUpgradeItemSlotMixin = CreateFromMixins(RuneforgeItemSlotMixin);

function RuneforgeUpgradeItemSlotMixin:SetEvents()
	self.onEnterEvent = RuneforgeFrameMixin.Event.UpgradeItemSlotOnEnter;
	self.onLeaveEvent = RuneforgeFrameMixin.Event.UpgradeItemSlotOnLeave;
	self.onItemChangedEvent = RuneforgeFrameMixin.Event.UpgradeItemChanged;
end

function RuneforgeUpgradeItemSlotMixin:SetTextureAndEffects()
	local normalTexture = self:GetNormalTexture();
	normalTexture:SetAtlas("runecarving-upgrade-icon-slot-empty", true);
	normalTexture:SetPoint("CENTER"); -- Remove the standard -1 offset.

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:SetAtlas("runecarving-upgrade-icon-slot-pressed", true);

	self.SelectingTexture:SetAtlas("runecarving-upgrade-icon-slot-pressed", true);
	self.SelectedTexture:SetSize(57, 57);

	self:AddEffectData("primary", RuneforgeUtil.Effect.UpgradeSubRune, RuneforgeUtil.EffectTarget.None, RuneforgeUtil.Level.Overlay);
end

function RuneforgeUpgradeItemSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		self:SetItem(nil);
		return;
	end

	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem and self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(cursorItem) then
		self:SetItem(cursorItem);
		ClearCursor();
	else
		self:SetSelectingItem(true);
	end
end

function RuneforgeUpgradeItemSlotMixin:OnReceiveDrag()
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem and self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(cursorItem) then
		self:SetItem(cursorItem);
		ClearCursor();
	end
end

function RuneforgeUpgradeItemSlotMixin:OnShow()
	self:UpdateEffectVisibility();
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.ResetItemSlot, self);
end

function RuneforgeUpgradeItemSlotMixin:OnHide()
	self:ResetItemSlot();
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end
