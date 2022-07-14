
RuneforgeItemSlotMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeItemSlotEvents = {
	"UNIT_INVENTORY_CHANGED",
};

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
			if RuneforgeUtil.IsUpgradeableRuneforgeLegendary(cursorItem) then
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
		self:GetRuneforgeFrame().CraftingFrame:ShowFlyout(self);
		self:SetSelectingItem(true);
	end

	HelpTip:Hide(self, FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT_TEXT);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT, true);
end

function RuneforgeItemSlotMixin:OnMouseDown()
	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnMouseUp()
	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnReceiveDrag()
	if not self:IsEnabled() then
		return;
	end

	local cursorItem = C_Cursor.GetCursorItem();
	if self:IsRuneforgeUpgrading() then
		if RuneforgeUtil.IsUpgradeableRuneforgeLegendary(cursorItem) then
			self:SetItem(cursorItem);
			ClearCursor();
		end
	else
		if cursorItem and C_LegendaryCrafting.IsValidRuneforgeBaseItem(cursorItem) then
			self:SetItem(cursorItem);
			ClearCursor();
		end
	end
end

function RuneforgeItemSlotMixin:OnEnter()
	if self.onEnterEvent then
		self:GetRuneforgeFrame():TriggerEvent(self.onEnterEvent);
	end

	self:CheckErrorTooltip();
end

function RuneforgeItemSlotMixin:OnLeave()
	if self.onLeaveEvent then
		self:GetRuneforgeFrame():TriggerEvent(self.onLeaveEvent);
	end

	GameTooltip_Hide();

	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeItemSlotEvents);

	if self:IsRuneforgeUpgrading() then
		self:SetNormalAtlas("runecarving-upgrade-icon-center-empty");
		self:SetPushedAtlas("runecarving-upgrade-icon-center-empty");
		self.SelectingTexture:SetAtlas("runecarving-upgrade-icon-center-pressed", true);
	else
		self:SetNormalAtlas("runecarving-icon-center-empty");
		self:SetPushedAtlas("runecarving-icon-center-empty");
		self.SelectingTexture:SetAtlas("runecarving-icon-center-pressed", true);
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT) and self:GetRuneforgeFrame():HasValidItemForRuneforgeState() then
		local helpTipInfo = {
			text = FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT,
			alignment = HelpTip.Alignment.Left,
			targetPoint = HelpTip.Point.RightEdgeCenter,
		};

		HelpTip:Show(self, helpTipInfo, self);
	end

	self:Refresh();
end

function RuneforgeItemSlotMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeItemSlotEvents);

	self:UpdateEffectVisibility();
	self:ResetItemSlot();
	EquipmentFlyout_Hide();
end

function RuneforgeItemSlotMixin:OnEvent(event)
	if event == "UNIT_INVENTORY_CHANGED" then
		self:Refresh();
	end
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
	self:AddEffectData("primary-upgrade", RuneforgeUtil.Effect.UpgradeCenterRune, RuneforgeUtil.EffectTarget.None, RuneforgeUtil.Level.Overlay);

	self:SetErrorTexture("runecarving-icon-center-empty-error");
end

function RuneforgeItemSlotMixin:SetErrorTexture(atlas)
	self.ErrorTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

function RuneforgeItemSlotMixin:CheckErrorTooltip()
	if self:IsEnabled() then
		return;
	end

	local runeforgeFrame = self:GetRuneforgeFrame();
	local isUpgrading = runeforgeFrame:IsRuneforgeUpgrading();
	if isUpgrading then
		local hasValidItem, errorText = runeforgeFrame:HasRuneforgeLegendaryForUpgrade();
		if hasValidItem then
			return;
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, errorText, RED_FONT_COLOR);
		GameTooltip:Show();
	else
		local hasValidItem = runeforgeFrame:HasValidItemForRuneforgeState();
		if hasValidItem then
			return;
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, RUNEFORGE_LEGENDARY_ERROR_NO_BASE_ITEM_AVAILABLE, RED_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, RUNEFORGE_LEGENDARY_ERROR_NO_BASE_ITEM_AVAILABLE_DESCRIPTION);
		GameTooltip:Show();
	end
end

function RuneforgeItemSlotMixin:Refresh()
	local hasValidItem = self:GetRuneforgeFrame():HasValidItemForRuneforgeState();
	self:SetEnabled(hasValidItem);
	self.ErrorTexture:SetShown(not hasValidItem);
	self:UpdateEffectVisibility();
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

	if hasItem then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RUNEFORGE_LEGENDARY_CRAFT, true);
		HelpTip:HideAll(self);
		PlaySound(SOUNDKIT.UI_RUNECARVING_SELECT_ITEM);
	end
end

function RuneforgeItemSlotMixin:ResetItemSlot()
	self:SetItem(nil);
end

function RuneforgeItemSlotMixin:GetItem()
	return self:GetItemLocation();
end

function RuneforgeItemSlotMixin:SetSelectingItem(isSelectingItem)
	local hasItem = self:GetItemLocation() ~= nil;
	self.SelectingTexture:SetShown(isSelectingItem and not hasItem);

	if isSelectingItem and hasItem then
		self:LockHighlight();
	else
		self:UnlockHighlight();
	end

	self:UpdateEffectVisibility();
end

function RuneforgeItemSlotMixin:ShouldShowPrimaryEffect()
	local hasItem = self:GetItem() ~= nil;
	return self:IsShown() and not hasItem and not self.SelectingTexture:IsShown() and not self.ErrorTexture:IsShown();
end

function RuneforgeItemSlotMixin:GetEffectKeys()
	if self:GetRuneforgeFrame():IsRuneforgeUpgrading() then
		return "primary-upgrade", "primary";
	else
		return "primary", "primary-upgrade";
	end
end

function RuneforgeItemSlotMixin:UpdateEffectVisibility()
	local effectKey, alternateEffectKey = self:GetEffectKeys();
	self:SetEffectShown(effectKey, self:ShouldShowPrimaryEffect());

	if alternateEffectKey then
		self:SetEffectShown(alternateEffectKey, false);
	end
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
	pushedTexture:ClearAllPoints();
	pushedTexture:SetPoint("CENTER");
	pushedTexture:SetAtlas("runecarving-upgrade-icon-slot-empty", true);

	self.SelectingTexture:SetAtlas("runecarving-upgrade-icon-slot-pressed", true);
	self.SelectedTexture:SetSize(57, 57);

	self:AddEffectData("primary", RuneforgeUtil.Effect.UpgradeSubRune, RuneforgeUtil.EffectTarget.None, RuneforgeUtil.Level.Overlay);

	self:SetErrorTexture("runecarving-icon-reagent-empty-error");
end

function RuneforgeUpgradeItemSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		self:SetItem(nil);
		return;
	end

	local runeforgeFrame = self:GetRuneforgeFrame();
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem and runeforgeFrame:IsUpgradeItemValidForRuneforgeLegendary(cursorItem) then
		self:SetItem(cursorItem);
		ClearCursor();
	else
		runeforgeFrame.CraftingFrame:ShowFlyout(self, RuneforgeUtil.FlyoutType.UpgradeItem);
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
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.ResetItemSlot, self);
	self:Refresh();
end

function RuneforgeUpgradeItemSlotMixin:OnHide()
	self:ResetItemSlot();
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgeUpgradeItemSlotMixin:Refresh()
	local runeforgeFrame = self:GetRuneforgeFrame();
	self:SetEnabled(runeforgeFrame:HasValidUpgradeItem());

	local hasValidUpgradeItem = runeforgeFrame:HasValidUpgradeItem();
	self.ErrorTexture:SetShown(not hasValidUpgradeItem);
end

function RuneforgeUpgradeItemSlotMixin:GetEffectKeys()
	return "primary", nil;
end
