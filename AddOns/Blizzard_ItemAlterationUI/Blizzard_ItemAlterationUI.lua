-- GetItemTransmogrifyInfo(item link/item id/item name)
--   returns: canBeChanged, noChangeReason, canBeSource, noSourceReason
-- CanTransmogrifyItemWithItem(target item link/target item id/target item name, source item link/source item id/source item name)
--   returns: canBeTransmogrified, failReason

UIPanelWindows["TransmogrifyFrame"] =	{ area = "left", pushable = 0 };

local BUTTONS = { };

function TransmogrifyFrame_Show()
	ShowUIPanel(TransmogrifyFrame);
	if ( not TransmogrifyFrame:IsShown() ) then
		CloseTransmogrifyFrame();
	end
end

function TransmogrifyFrame_Hide()
	HideUIPanel(TransmogrifyFrame);
end

function TransmogrifyFrame_OnLoad(self)
	TransmogrifyArtFrameTitleText:SetText(TRANSMOGRIFY);
	TransmogrifyArtFrameTitleBg:SetDrawLayer("BACKGROUND", -1);
	TransmogrifyArtFrameTopTileStreaks:Hide();
	TransmogrifyArtFrameBg:Hide();
	SetPortraitToTexture(TransmogrifyArtFramePortrait, "Interface\\Icons\\INV_Arcane_Orb");

	RaiseFrameLevel(TransmogrifyArtFrame);
	RaiseFrameLevelByTwo(TransmogrifyFrameButtonFrame);
	TransmogrifyArtFrameCloseButton:SetScript("OnClick", function() HideUIPanel(TransmogrifyFrame); end);
	
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOGRIFY_BIND_CONFIRM");

	-- flyout settings
	self.flyoutSettings = {
		onClickFunc = TransmogrifyItemFlyoutButton_OnClick,
		getItemsFunc =  TransmogrifyItemFlyout_GetItems,
		hasPopouts = false,
		parent = TransmogrifyFrame,
		anchorX = 7,
		anchorY = 3,
		verticalAnchorX = -2,
		verticalAnchorY = -6,
	};
end

function TransmogrifyFrame_OnEvent(self, event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" ) then
		local slot = ...;
		-- play sound?
		local button = BUTTONS[slot];
		if ( button ) then
			local isTransmogrified, canTransmogrify, cannotTransmogrifyReason, hasPending, hasUndo = GetTransmogrifySlotInfo(button.id);
			if ( hasUndo ) then
				PlaySound("UI_Transmogrify_Undo");
			elseif ( not hasPending ) then
				if ( button.hadUndo ) then
					PlaySound("UI_Transmogrify_Redo");
					button.hadUndo = nil;
				end
			end
		end
		if ( TransmogrifyConfirmationPopup:IsShown() and TransmogrifyConfirmationPopup.slot == slot ) then
			TransmogrifyConfirmationPopup.slot = nil;		-- to keep popup from clearing slot on hide
			StaticPopupSpecial_Hide(TransmogrifyConfirmationPopup);
		end
		TransmogrifyFrame_Update(self);
	elseif ( event == "BAG_UPDATE" ) then
		ValidateTransmogrifications();
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		ValidateTransmogrifications();
		local slot, hasItem = ...;
		if ( slot == INVSLOT_TABARD or slot == INVSLOT_BODY ) then
			if ( hasItem ) then
				local itemID = GetInventoryItemID("player", slot);
				TransmogrifyModelFrame:TryOn(itemID);
			else
				TransmogrifyModelFrame:UndressSlot(slot);
			end
		end
	elseif ( event == "TRANSMOGRIFY_CLOSE" ) then
		self:Hide();
	elseif ( event == "TRANSMOGRIFY_SUCCESS" ) then
		local slot = ...;
		local button = BUTTONS[slot];
		if ( button ) then
			TransmogrifyFrame_AnimateSlotButton(button);
			TransmogrifyFrame_UpdateSlotButton(button);
			TransmogrifyFrame_UpdateApplyButton();
		end
	elseif ( event == "TRANSMOGRIFY_BIND_CONFIRM" ) then
		TransmogrifyConfirmationPopup_Show(...);
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" ) then
			local hasAlternateForm, inAlternateForm = HasAlternateForm();
			if ( self.alternateForm ~= inAlternateForm ) then
				self.alternateForm = inAlternateForm;
				TransmogrifyModelFrame:SetUnit("player");
				TransmogrifyFrame_Update(self);
			end
		end
	end
end

function TransmogrifyFrame_OnShow(self)
	PlaySound("UI_EtherealWindow_Open");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("BAG_UPDATE");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterEvent("UNIT_MODEL_CHANGED");
		self.alternateForm = inAlternateForm;
	end
	TransmogrifyModelFrame:SetUnit("player");
	Model_Reset(TransmogrifyModelFrame);
	self.headSlot.displayHelm = ShowingHelm();
	self.backSlot.displayCloak = ShowingCloak();
	TransmogrifyFrame_Update(self);
end

function TransmogrifyFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	StaticPopupSpecial_Hide(TransmogrifyConfirmationPopup);
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	CloseTransmogrifyFrame();
end

function TransmogrifyFrame_GetAnimationFrame()
	local name, frame;
	local i = 1;
	while true do
		name = "TransmogrifyAnimation"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Frame", name, TransmogrifyFrame, "TransmogrifyAnimationFrameTemplate");
			return frame;
		end
		i = i + 1;
		assert(i < 20);
	end
end

function TransmogrifyFrame_GetPendingFrame()
	local name, frame;
	local i = 1;
	while true do
		name = "TransmogrifyPending"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Frame", name, TransmogrifyFrame, "TransmogrifyPendingFrameTemplate");
			return frame;
		end
		i = i + 1;
		assert(i < 20);
	end
end

function TransmogrifyFrame_AnimateSlotButton(button)
	-- don't do anything if this button already has an animation frame;
	if ( button.animationFrame ) then
		return;
	end
	local animationFrame = TransmogrifyFrame_GetAnimationFrame();
	animationFrame:SetParent(button);
	animationFrame:SetPoint("CENTER");
	button.animationFrame = animationFrame;
	local isTransmogrified = GetTransmogrifySlotInfo(button.id);
	if ( isTransmogrified ) then
		animationFrame.transition:Show();
	else
		animationFrame.transition:Hide();
	end
	animationFrame:Show();
	animationFrame.anim:Play();
end

function TransmogrifySlotButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	local slotName = strsub(self:GetName(), 18);
	local id, textureName = GetInventorySlotInfo(slotName);
	self.id = id;
	self.defaultTexture = textureName;
	self.icon:SetTexture(textureName);
	self.verticalFlyout = VERTICAL_FLYOUTS[id];
	BUTTONS[id] = self;
	RaiseFrameLevelByTwo(self);
end

function TransmogrifySlotButton_OnEvent(self, event, ...)
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWITEMFLYOUT") and self:IsMouseOver() ) then
			TransmogrifySlotButton_OnEnter(self);
		end
	end
end

function TransmogrifySlotButton_OnClick(self, button)
	local isTransmogrified, canTransmogrify, cannotTransmogrifyReason, hasPending, hasUndo = GetTransmogrifySlotInfo(self.id);
	-- save for sound to play on TRANSMOGRIFY_UPDATE event
	self.hadUndo = hasUndo;
	if ( button == "LeftButton" ) then
		ClickTransmogrifySlot(self.id);
	elseif ( button == "RightButton" ) then
		ClearTransmogrifySlot(self.id);
	end
	self.undoIcon:Hide();
	TransmogrifySlotButton_OnEnter(self);
end

function TransmogrifySlotButton_OnEnter(self)
	local isTransmogrified, canTransmogrify, cannotTransmogrifyReason, hasPending, hasUndo = GetTransmogrifySlotInfo(self.id);
	local cursorItem = GetCursorInfo();
	if ( cursorItem ~= "item" and isTransmogrified and not ( hasPending or hasUndo ) ) then
		self.undoIcon:Show();
	end

	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	EquipmentFlyout_UpdateFlyout(self);
	if ( not EquipmentFlyout_SetTooltipAnchor(self) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	if ( hasPending or hasUndo ) then
		GameTooltip:SetTransmogrifyItem(self.id);
	elseif ( not canTransmogrify ) then
		local slotName = _G[strupper(strsub(self:GetName(), 18))];
		GameTooltip:SetText(slotName);
		local errorMsg = _G["TRANSMOGRIFY_INVALID_REASON"..cannotTransmogrifyReason];
		if ( errorMsg ) then
			GameTooltip:AddLine(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, 1);
		end
		GameTooltip:Show();
	else
		local hasItem = GameTooltip:SetInventoryItem("player", self.id);
	end

	TransmogrifyModelFrame.controlFrame:Show();
end

function TransmogrifySlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	TransmogrifyModelFrame.controlFrame:Hide();
	self.undoIcon:Hide();
	GameTooltip:Hide();
end

function TransmogrifyFrame_Update(self)

	for _, button in pairs(BUTTONS) do
		TransmogrifyFrame_UpdateSlotButton(button);
	end
	TransmogrifyFrame_UpdateApplyButton();
end

function TransmogrifyFrame_UpdateApplyButton()
	local cost, numChanges = GetTransmogrifyCost();
	local canApply;
	if ( cost > GetMoney() ) then
		SetMoneyFrameColor("TransmogrifyMoneyFrame", "red");
	else
		SetMoneyFrameColor("TransmogrifyMoneyFrame");
		if (numChanges > 0 ) then
			canApply = true;
		end
	end
	if ( TransmogrifyConfirmationPopup:IsShown() ) then
		canApply = false;
	end
	MoneyFrame_Update("TransmogrifyMoneyFrame", cost);
	if ( canApply ) then
		TransmogrifyApplyButton:Enable();
	else
		TransmogrifyApplyButton:Disable();
	end
end

function TransmogrifyFrame_UpdateSlotButton(button)
	local isTransmogrified, canTransmogrify, cannotTransmogrifyReason, hasPending, hasUndo, visibleItemID, textureName = GetTransmogrifySlotInfo(button.id);
	local hasChange = hasPending or hasUndo;

	if ( canTransmogrify ) then
		button.icon:SetTexture(textureName);
		button.noItem:Hide();
	else
		button.icon:SetTexture(button.defaultTexture);
		button.noItem:Show();
	end

	-- desaturate icon if it's not transmogrified
	if ( isTransmogrified or hasPending ) then
		button.icon:SetDesaturated(false);
	else
		button.icon:SetDesaturated(true);
	end

	-- show altered texture if the item is transmogrified and doesn't have a pending transmogrification or is animating
	if ( isTransmogrified and not hasChange and not button.animationFrame ) then
		button.altTexture:Show();
	else
		button.altTexture:Hide();
	end

	-- show ants frame is the item has a pending transmogrification and is not animating
	if ( hasChange and not button.animationFrame ) then
		local pendingFrame = button.pendingFrame;
		if ( not pendingFrame ) then
			pendingFrame = TransmogrifyFrame_GetPendingFrame();
			pendingFrame:SetParent(button);
			pendingFrame:SetPoint("CENTER");
			button.pendingFrame = pendingFrame;
		end
		pendingFrame:Show();
		if ( hasUndo ) then
			pendingFrame.undo:Show();
		else
			pendingFrame.undo:Hide();
		end
	elseif ( button.pendingFrame ) then
		button.pendingFrame:Hide();
		button.pendingFrame = nil;
	end
	

	local showModel = true;
	if (button.id == INVSLOT_HEAD and not button.displayHelm) then
		if ( hasChange ) then
			button.displayHelm = true;
		else
			showModel = false;
		end
	end
	if (button.id == INVSLOT_BACK and not button.displayCloak) then
		if ( hasChange ) then
			button.displayCloak = true;
		else
			showModel = false;
		end
	end
	if ( showModel ) then
		if ( visibleItemID and visibleItemID > 0 ) then
			local slot;
			if ( button.id == INVSLOT_MAINHAND ) then
				slot = "mainhand";
			elseif ( button.id == INVSLOT_OFFHAND ) then
				slot = "offhand";
			end
			TransmogrifyModelFrame:TryOn(visibleItemID, slot);
		else
			if ( button.id == INVSLOT_RANGED ) then
				-- clear both hands
				TransmogrifyModelFrame:UndressSlot(INVSLOT_MAINHAND);
				TransmogrifyModelFrame:UndressSlot(INVSLOT_OFFHAND);
			else
				TransmogrifyModelFrame:UndressSlot(button.id);
			end
		end
	end
end

function TransmogrifyItemFlyoutButton_OnClick(self)
	if ( self.location ) then
		local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(self.location);
		if ( bag ) then
			UseItemForTransmogrify(bag, slot, EquipmentFlyoutFrame.button.id);
		else
			UseItemForTransmogrify(nil, slot, EquipmentFlyoutFrame.button.id);
		end
	end
end

function TransmogrifyItemFlyout_GetItems(slot, itemTable)
	GetInventoryItemsForSlot(slot, itemTable, "transmogrify");
end

function TransmogrifyConfirmationPopup_Show(slot, sourceItemLink, destinationItemLink)
	local popup = TransmogrifyConfirmationPopup;
	local baseHeight;
	if ( sourceItemLink and destinationItemLink ) then
		TransmogrifyConfirmationPopup_SetItem(popup.ItemFrame1, sourceItemLink);
		TransmogrifyConfirmationPopup_SetItem(popup.ItemFrame2, destinationItemLink);
		popup.Text:SetText(TRANSMOGRIFY_BIND_CONFIRMATION_BOTH.."\n"..CONFIRM_CONTINUE);
		baseHeight = 160;
	else
		popup.ItemFrame2:Hide();
		if ( sourceItemLink ) then
			TransmogrifyConfirmationPopup_SetItem(popup.ItemFrame1, sourceItemLink);
			popup.Text:SetText(TRANSMOGRIFY_BIND_CONFIRMATION_SOURCE.."\n"..CONFIRM_CONTINUE);
		else
			TransmogrifyConfirmationPopup_SetItem(popup.ItemFrame1, destinationItemLink);
			popup.Text:SetText(TRANSMOGRIFY_BIND_CONFIRMATION_DESTINATION.."\n"..CONFIRM_CONTINUE);
		end
		baseHeight = 115;
	end
	popup:SetHeight(baseHeight + popup.Text:GetHeight());
	StaticPopupSpecial_Show(popup);
	popup.slot = slot;
	TransmogrifyApplyButton:Disable();
end

function TransmogrifyConfirmationPopup_SetItem(itemFrame, itemLink)
	local itemName, _, itemQuality, _, _, _, _, _, _, texture = GetItemInfo(itemLink);
	local r, g, b = GetItemQualityColor(itemQuality or 1);
	itemFrame.Text:SetText(itemName);
	itemFrame.Text:SetTextColor(r, g, b);
	itemFrame.icon:SetTexture(texture);
	itemFrame:Show();
	itemFrame.link = itemLink;
end