
local REMOVE_TRANSMOG_ID = 0;

-- ************************************************************************************************************************************************************
-- **** MAIN **********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeFrame_OnLoad(self)
	SetPortraitToTexture(WardrobeFramePortrait, "Interface\\Icons\\INV_Arcane_Orb");
	WardrobeFrameTitleText:SetText(TRANSMOGRIFY);
end

function WardrobeFrame_OnShow(self)
	HideUIPanel(CollectionsJournal);
	WardrobeCollectionFrame_SetContainer(self);
end

function WardrobeFrame_IsAtTransmogrifier()
	return WardrobeFrame and WardrobeFrame:IsShown();
end

-- ************************************************************************************************************************************************************
-- **** TRANSMOG **********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeTransmogFrame_OnLoad(self)
	local race, fileName = UnitRace("player");
	local atlas = "transmog-background-race-"..fileName;
	self.Inset.BG:SetAtlas(atlas);

	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
end

function WardrobeTransmogFrame_OnEvent(self, event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" ) then
		local slotID, transmogType = ...;
		-- play sound?
		local slotButton = WardrobeTransmogFrame_GetSlotButton(slotID, transmogType);
		if ( slotButton ) then
			local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(slotID, slotButton.transmogType);
			if ( hasUndo ) then
				PlaySound("UI_Transmogrify_Undo");
			elseif ( not hasPending ) then
				if ( slotButton.hadUndo ) then
					PlaySound("UI_Transmogrify_Redo");
					slotButton.hadUndo = nil;
				end
			end
			-- specs button tutorial
			if ( hasPending and not hasUndo ) then
				if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON) ) then
					self.SpecHelpBox:Show();
				end
			end
		end
		StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
		self.dirty = true;
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		C_Transmog.ValidateAllPending();
	elseif ( event == "TRANSMOGRIFY_SUCCESS" ) then
		local slotID, transmogType = ...;
		local slotButton = WardrobeTransmogFrame_GetSlotButton(slotID, transmogType);
		if ( slotButton ) then
			WardrobeTransmogFrame_AnimateSlotButton(slotButton);
			WardrobeTransmogFrame_UpdateSlotButton(slotButton);
			-- transmogging a weapon might allow/disallow enchants
			if ( slotButton.slot == "MAINHANDSLOT" ) then
				WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.Model.MainHandEnchantButton);
			elseif ( slotButton.slot == "SECONDARYHANDSLOT" ) then
				WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.Model.SecondaryHandEnchantButton);
			end
			WardrobeTransmogFrame_UpdateApplyButton();
		end
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" and WardrobeTransmogFrame.Model:CanSetUnit("player") ) then
			local hasAlternateForm, inAlternateForm = HasAlternateForm();
			if ( self.inAlternateForm ~= inAlternateForm ) then
				self.inAlternateForm = inAlternateForm;
				WardrobeTransmogFrame.Model:SetUnit("player");
				WardrobeTransmogFrame_Update(self);
			end
		end
	end
end

function WardrobeTransmogFrame_OnShow(self)
	PlaySound("UI_Transmog_OpenWindow");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterEvent("UNIT_MODEL_CHANGED");
		self.inAlternateForm = inAlternateForm;
	end
	WardrobeTransmogFrame.Model:SetUnit("player");
	Model_Reset(WardrobeTransmogFrame.Model);

	WardrobeTransmogFrame_Update(self);
end

function WardrobeTransmogFrame_OnHide(self)
	PlaySound("UI_Transmog_CloseWindow");
	StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	C_Transmog.Close();
	self.OutfitHelpBox:Hide();
	self.SpecHelpBox:Hide();
end

function WardrobeTransmogFrame_OnUpdate(self)
	if ( self.dirty ) then
		self.dirty = nil;
		WardrobeTransmogFrame_Update(self);
	end
end

function WardrobeTransmogFrame_Update()
	for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
		WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.Model.SlotButtons[i]);
	end
	WardrobeTransmogFrame_UpdateWeaponModel("MAINHANDSLOT");
	WardrobeTransmogFrame_UpdateWeaponModel("SECONDARYHANDSLOT");
	WardrobeTransmogFrame_UpdateApplyButton();
	WardrobeTransmogFrame.OutfitDropDown:UpdateSaveButton();
	
	if ( not WardrobeTransmogFrame.selectedSlotButton or not WardrobeTransmogFrame.selectedSlotButton:IsEnabled() ) then
		-- select first valid slot or clear selection
		local validButton;
		for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
			local button = WardrobeTransmogFrame.Model.SlotButtons[i];
			if ( button:IsEnabled() and button.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
				validButton = WardrobeTransmogFrame.Model.SlotButtons[i];
				break;
			end
		end
		WardrobeTransmogButton_Select(validButton);
	else
		WardrobeTransmogButton_Select(WardrobeTransmogFrame.selectedSlotButton);
	end
end

function WardrobeTransmogFrame_UpdateSlotButton(slotButton)
	local slotID, defaultTexture = GetInventorySlotInfo(slotButton.slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(slotID, slotButton.transmogType);
	local hasChange = (hasPending and canTransmogrify) or hasUndo;

	-- hide enchant button?
	if ( slotButton.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		if ( hasPending or hasUndo or canTransmogrify ) then
			slotButton:Show();
		else
			slotButton:Hide();
			return;
		end
	end

	if ( slotButton.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		if ( canTransmogrify or hasChange ) then
			slotButton.Icon:SetTexture(texture);
			slotButton.NoItemTexture:Hide();
		else
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			if ( tag  == "NO_ITEM" ) then
				slotButton.Icon:SetTexture(defaultTexture);
			else
				slotButton.Icon:SetTexture(texture);
			end
			slotButton.NoItemTexture:Show();
		end
	else
		slotButton.Icon:SetTexture(texture or ENCHANT_EMPTY_SLOT_FILEDATAID);
	end
	slotButton:SetEnabled(canTransmogrify or hasUndo);

	-- show transmogged border if the item is transmogrified and doesn't have a pending transmogrification or is animating
	if ( hasPending ) then
		if ( hasUndo or (isPendingCollected and canTransmogrify) ) then
			WardrobeTransmogButton_SetStatusBorder(slotButton, "PINK");
		else
			WardrobeTransmogButton_SetStatusBorder(slotButton, "NONE");
		end
	else
		if ( isTransmogrified and not hasChange and not slotButton.AnimFrame:IsShown() ) then
			WardrobeTransmogButton_SetStatusBorder(slotButton, "PINK");
		else
			WardrobeTransmogButton_SetStatusBorder(slotButton, "NONE");
		end
	end

	-- show ants frame is the item has a pending transmogrification and is not animating
	if ( hasChange and (hasUndo or isPendingCollected) and not slotButton.AnimFrame:IsShown() ) then
		slotButton.PendingFrame:Show();
		if ( hasUndo ) then
			slotButton.PendingFrame.Undo:Show();
		else
			slotButton.PendingFrame.Undo:Hide();
		end
	else
		slotButton.PendingFrame:Hide();
	end

	if ( isHideVisual and not hasUndo ) then
		if ( slotButton.HiddenVisualIcon ) then
			slotButton.HiddenVisualCover:Show();
			slotButton.HiddenVisualIcon:Show();
		end
		local baseTexture = GetInventoryItemTexture("player", slotID);
		slotButton.Icon:SetTexture(baseTexture);
	else
		if ( slotButton.HiddenVisualIcon ) then
			slotButton.HiddenVisualCover:Hide();
			slotButton.HiddenVisualIcon:Hide();
		end
	end

	local showModel = (slotButton.transmogType == LE_TRANSMOG_TYPE_APPEARANCE);
	if ( slotButton.slot == "MAINHANDSLOT" or slotButton.slot == "SECONDARYHANDSLOT" ) then
		-- weapons get done in WardrobeTransmogFrame_UpdateWeaponModel to package item and enchant together
		showModel = false;
	end
	if ( showModel ) then
		local sourceID = WardrobeTransmogFrame_GetDisplayedSource(slotButton);
		if ( sourceID == NO_TRANSMOG_SOURCE_ID ) then
			WardrobeTransmogFrame.Model:UndressSlot(slotID);			
		else
			-- only update if different
			local existingAppearanceSourceID = WardrobeTransmogFrame.Model:GetSlotTransmogSources(slotID);
			if ( existingAppearanceSourceID ~= sourceID ) then
				WardrobeTransmogFrame.Model:TryOn(sourceID);
			end
		end
	end
end

function WardrobeTransmogFrame_UpdateWeaponModel(slot)
	local weaponSlotButton, enchantSlotButton;
	if ( slot == "MAINHANDSLOT" ) then
		weaponSlotButton = WardrobeTransmogFrame.Model.MainHandButton;
		enchantSlotButton = WardrobeTransmogFrame.Model.MainHandEnchantButton;
	else
		weaponSlotButton = WardrobeTransmogFrame.Model.SecondaryHandButton;
		enchantSlotButton = WardrobeTransmogFrame.Model.SecondaryHandEnchantButton;
	end
	local slotID = GetInventorySlotInfo(slot);
	local appearanceSourceID = WardrobeTransmogFrame_GetDisplayedSource(weaponSlotButton);
	if ( appearanceSourceID ~= NO_TRANSMOG_SOURCE_ID ) then
		local illusionSourceID = WardrobeTransmogFrame_GetDisplayedSource(enchantSlotButton);
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		-- don't specify a slot for ranged weapons
		if ( WardrobeCollectionFrame_IsCategoryRanged(categoryID) ) then
			slot = nil;
		end
		-- check existing equipped on model. we don't want to update it if the same because the hand will open/close.
		local existingAppearanceSourceID, existingIllustionSourceID = WardrobeTransmogFrame.Model:GetSlotTransmogSources(slotID);
		if ( existingAppearanceSourceID ~= appearanceSourceID or existingIllustionSourceID ~= illusionSourceID ) then
			WardrobeTransmogFrame.Model:TryOn(appearanceSourceID, slot, illusionSourceID);
		end
	end	
end

function WardrobeTransmogFrame_GetDisplayedSource(slotButton)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(slotButton.slot), slotButton.transmogType);
	if ( pendingSourceID ~= REMOVE_TRANSMOG_ID ) then
		return pendingSourceID;
	elseif ( hasPendingUndo or appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		return baseSourceID;
	else
		return appliedSourceID;
	end	
end

function WardrobeTransmogFrame_AnimateSlotButton(slotButton)
	-- don't do anything if this button is already animating;
	if ( slotButton.AnimFrame:IsShown() ) then
		return;
	end
	local isTransmogrified = C_Transmog.GetSlotInfo(slotButton.slotID, slotButton.transmogType);
	if ( isTransmogrified ) then
		slotButton.AnimFrame.Transition:Show();
	else
		slotButton.AnimFrame.Transition:Hide();
	end
	slotButton.AnimFrame:Show();
	slotButton.AnimFrame.Anim:Play();
end

function WardrobeTransmogFrame_UpdateApplyButton()
	local cost, numChanges = C_Transmog.GetCost();
	local canApply;
	if ( cost > GetMoney() ) then
		SetMoneyFrameColor("WardrobeTransmogMoneyFrame", "red");
	else
		SetMoneyFrameColor("WardrobeTransmogMoneyFrame");
		if (numChanges > 0 ) then
			canApply = true;
		end
	end
	if ( StaticPopup_FindVisible("TRANSMOG_APPLY_WARNING") ) then
		canApply = false;
	end
	MoneyFrame_Update("WardrobeTransmogMoneyFrame", cost, true);	-- always show 0 copper
	WardrobeTransmogFrame.ApplyButton:SetEnabled(canApply);
	WardrobeTransmogFrame.Model.ClearAllPendingButton:SetShown(canApply);
end

function WardrobeTransmogFrame_GetSlotButton(slotID, transmogType)
	for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
		local slotButton = WardrobeTransmogFrame.Model.SlotButtons[i];
		if ( slotButton.slotID == slotID and slotButton.transmogType == transmogType ) then
			return slotButton;
		end
	end
end

function WardrobeTransmogFrame_ApplyPending(lastAcceptedWarningIndex)
	if ( lastAcceptedWarningIndex == 0 or not WardrobeTransmogFrame.applyWarningsTable ) then
		WardrobeTransmogFrame.applyWarningsTable = C_Transmog.GetApplyWarnings();
	end
	if ( WardrobeTransmogFrame.applyWarningsTable and lastAcceptedWarningIndex < #WardrobeTransmogFrame.applyWarningsTable ) then
		lastAcceptedWarningIndex = lastAcceptedWarningIndex + 1;
		local itemLink = WardrobeTransmogFrame.applyWarningsTable[lastAcceptedWarningIndex].itemLink;
		local itemName, _, itemQuality, _, _, _, _, _, _, texture = GetItemInfo(itemLink);
		local r, g, b = GetItemQualityColor(itemQuality);
		local data = {
			["texture"] = texture,
			["name"] = itemName,
			["color"] = {r, g, b, 1},
			["link"] = itemLink,
			["warningIndex"] = lastAcceptedWarningIndex;
		};
		StaticPopup_Show("TRANSMOG_APPLY_WARNING", WardrobeTransmogFrame.applyWarningsTable[lastAcceptedWarningIndex].text, nil, data);
		WardrobeTransmogFrame_UpdateApplyButton();
		-- return true to keep static popup open when chaining warnings
		return true;
	else
		WardrobeTransmogFrame.applyWarningsTable = nil;
		C_Transmog.ApplyAllPending(GetCVarBool("transmogCurrentSpecOnly"));
		-- outfit tutorial
		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN) ) then
			local outfits = C_TransmogCollection.GetOutfits();
			if ( #outfits == 0 ) then
				WardrobeTransmogFrame.OutfitHelpBox:Show();
			end
		end
		return false;
	end
end

function WardrobeTransmogFrame_LoadOutfit(outfitID)
	C_Transmog.LoadOutfit(outfitID);
end

function WardrobeTransmogFrame_GetSourceIDForOutfit(slot, transmogType)
	local slotID = GetInventorySlotInfo(slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(slotID, transmogType);
	if ( not canTransmogrify and not hasUndo ) then
		return NO_TRANSMOG_SOURCE_ID;
	end

	local _, _, sourceID = WardrobeCollectionFrame_GetInfoForSlot(slot, transmogType);
	return sourceID;
end

-- ***** BUTTONS

function WardrobeTransmogButton_OnLoad(self)
	local slotID, textureName = GetInventorySlotInfo(self.slot);
	self.slotID = slotID;
	if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		self.Icon:SetTexture(textureName);
	else
		self.Icon:SetTexture(ENCHANT_EMPTY_SLOT_FILEDATAID);
	end
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function WardrobeTransmogButton_OnClick(self, button)
	local slotID = GetInventorySlotInfo(self.slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(slotID, self.transmogType);
	-- save for sound to play on TRANSMOGRIFY_UPDATE event
	self.hadUndo = hasUndo;
	if ( button == "RightButton" ) then
		if ( hasPending or hasUndo ) then
			PlaySound("UI_Transmog_RevertingGearSlot");
			C_Transmog.ClearPending(slotID, self.transmogType);
		elseif ( isTransmogrified ) then
			PlaySound("UI_Transmog_RevertingGearSlot");
			C_Transmog.SetPending(slotID, self.transmogType, 0);
		end
	else
		PlaySound("UI_Transmog_GearSlotClick");
		WardrobeTransmogButton_Select(self);
	end
	if ( self.UndoButton ) then
		self.UndoButton:Hide();
	end
	WardrobeTransmogButton_OnEnter(self);
end

function WardrobeTransmogButton_OnEnter(self)
	local slotID = GetInventorySlotInfo(self.slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(slotID, self.transmogType);

	if ( self.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		GameTooltip:SetText(WEAPON_ENCHANTMENT);
		local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slotID, LE_TRANSMOG_TYPE_ILLUSION);
		if ( baseSourceID > 0 ) then
			local _, name = C_TransmogCollection.GetIllusionSourceInfo(baseSourceID);
			GameTooltip:AddLine(name, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		end
		if ( hasUndo ) then
			GameTooltip:AddLine(TRANSMOGRIFY_TOOLTIP_REVERT, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b);
		elseif ( pendingSourceID > 0 ) then
			GameTooltip:AddLine(WILL_BE_TRANSMOGRIFIED_HEADER, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b);
			local _, name = C_TransmogCollection.GetIllusionSourceInfo(pendingSourceID);
			GameTooltip:AddLine(name, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b);
		elseif ( appliedSourceID > 0 ) then
			GameTooltip:AddLine(TRANSMOGRIFIED_HEADER, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b);
			local _, name = C_TransmogCollection.GetIllusionSourceInfo(appliedSourceID);
			GameTooltip:AddLine(name, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b);
		end
		GameTooltip:Show();
	else
		if ( self.UndoButton and isTransmogrified and not ( hasPending or hasUndo ) ) then
			self.UndoButton:Show();
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 14, 0);
		if ( hasPending and not hasUndo and not isPendingCollected ) then
			GameTooltip:SetText(_G[self.slot]);
			GameTooltip:AddLine(TRANSMOGRIFY_STYLE_UNCOLLECTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			GameTooltip:Show();
		elseif ( not canTransmogrify and not hasUndo ) then
			GameTooltip:SetText(_G[self.slot]);
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			local errorMsg;
			if ( tag == "CANNOT_USE" ) then
				local errorCode, errorString = C_Transmog.GetSlotUseError(slotID, self.transmogType);
				errorMsg = errorString;
			else
				errorMsg = tag and _G["TRANSMOGRIFY_INVALID_"..tag];
			end
			if ( errorMsg ) then
				GameTooltip:AddLine(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
		elseif ( hasPending or hasUndo ) then
			GameTooltip:SetTransmogrifyItem(slotID);
		else
			GameTooltip:SetInventoryItem("player", slotID);
		end
	end
	WardrobeTransmogFrame.Model.controlFrame:Show();
end

function WardrobeTransmogButton_OnLeave(self)
	if ( self.UndoButton and not self.UndoButton:IsMouseOver() ) then
		self.UndoButton:Hide();
	end
	WardrobeTransmogFrame.Model.controlFrame:Hide();
	GameTooltip:Hide();
end

function WardrobeTransmogButton_Select(button)
	if ( WardrobeTransmogFrame.selectedSlotButton ) then
		WardrobeTransmogFrame.selectedSlotButton.SelectedTexture:Hide();
	end
	WardrobeTransmogFrame.selectedSlotButton = button;
	if ( button ) then
		button.SelectedTexture:Show();
		WardrobeCollectionFrame_SetActiveSlot(button.slot, button.transmogType);
		WardrobeCollectionFrame_SetTransmogrifierAppearancesShown(true);
	else
		WardrobeCollectionFrame_SetTransmogrifierAppearancesShown(false);
	end
end

function WardrobeTransmogButton_SetStatusBorder(self, status)
	local atlas;
	if ( status == "RED" ) then
		if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			atlas = "transmog-frame-red";
		else
			atlas = "transmog-frame-small-red";
		end
	elseif ( status == "PINK" ) then
		if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			atlas = "transmog-frame-pink";
		else
			atlas = "transmog-frame-small-pink";
		end	
	end
	if ( atlas ) then
		self.StatusBorder:Show();
		self.StatusBorder:SetAtlas(atlas, true);
	else
		self.StatusBorder:Hide();
	end
end

-- ************************************************************************************************************************************************************
-- **** COLLECTION ********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local CURRENT_PAGE = 1;
local WARDROBE_NUM_ROWS = 3;
local WARDROBE_NUM_COLS = 6;
local WARDROBE_PAGE_SIZE = WARDROBE_NUM_ROWS * WARDROBE_NUM_COLS;
local MAIN_HAND_INV_TYPE = 21;
local OFF_HAND_INV_TYPE = 22;
local RANGED_INV_TYPE = 15;

local HIDE_VISUAL_STRINGS = {
	["HEADSLOT"] = TRANSMOG_HIDE_HELM,
	["SHOULDERSLOT"] = TRANSMOG_HIDE_SHOULDERS,
	["BACKSLOT"] = TRANSMOG_HIDE_CLOAK,
}

local WARDROBE_MODEL_SETUP = {
	["HEADSLOT"] 		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = false } },
	["SHOULDERSLOT"]	= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["BACKSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["CHESTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["TABARDSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["SHIRTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["WRISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["HANDSSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = true, HEADSLOT = true } },
	["WAISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["LEGSSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true } },
	["FEETSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true, HANDSSLOT = true, LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true } },	
}

local WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 78420,
	["LEGSSLOT"] = 78425,
	["FEETSLOT"] = 78427,
	["HANDSSLOT"] = 78426,
	["HEADSLOT"] = 78416,
}

function WardrobeCollectionFrame_SetContainer(parent)
	local collectionFrame = WardrobeCollectionFrame;
	collectionFrame:SetParent(parent);
	collectionFrame:ClearAllPoints();
	collectionFrame:Show();
	if ( parent == CollectionsJournal ) then
		collectionFrame:SetPoint("TOPLEFT", CollectionsJournal);
		collectionFrame:SetPoint("BOTTOMRIGHT", CollectionsJournal);
		collectionFrame.ModelsFrame.ModelR1C1:SetPoint("TOP", -238, -85);
		collectionFrame.ModelsFrame.SlotsFrame:Show();
		collectionFrame.ModelsFrame.BGCornerTopLeft:Hide();
		collectionFrame.ModelsFrame.BGCornerTopRight:Hide();
		collectionFrame.ModelsFrame.WeaponDropDown:SetPoint("TOPRIGHT", -6, -22);
		collectionFrame.progressBar:SetWidth(196);
		collectionFrame.ModelsFrame.NoValidItemsLabel:Hide();
		collectionFrame.FilterButton:SetText(FILTER);
	elseif ( parent == WardrobeFrame ) then
		collectionFrame:SetPoint("TOPRIGHT", 0, 0);
		collectionFrame:SetSize(662, 606);
		collectionFrame.ModelsFrame.ModelR1C1:SetPoint("TOP", -235, -71);
		collectionFrame.ModelsFrame.SlotsFrame:Hide();
		collectionFrame.ModelsFrame.BGCornerTopLeft:Show();
		collectionFrame.ModelsFrame.BGCornerTopRight:Show();
		collectionFrame.ModelsFrame.WeaponDropDown:SetPoint("TOPRIGHT", -32, -25);
		collectionFrame.progressBar:SetWidth(437);
		collectionFrame.FilterButton:SetText(SOURCES);
	end
end

function WardrobeCollectionFrame_OnLoad(self)
	WardrobeCollectionFrame_CreateSlotButtons();
	self.ModelsFrame.BGCornerTopLeft:Hide();
	self.ModelsFrame.BGCornerTopRight:Hide();
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_misc_enggizmos_19");
	
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	self.newTransmogs = UIParent.newTransmogs or {};
	self.mostRecentCollectedVisualID = UIParent.mostRecentCollectedVisualID;
	self.mostRecentCollectedCategoryID = UIParent.mostRecentCollectedCategoryID;
	UIParent.newTransmogs = nil;
	UIParent.mostRecentCollectedVisualID = nil;
	UIParent.mostRecentCollectedCategoryID = nil;

	UIDropDownMenu_Initialize(self.ModelsFrame.RightClickDropDown, nil, "MENU");
	self.ModelsFrame.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;

	self.needsUpdateUsable = true;
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("SPELLS_CHANGED");
end

function WardrobeCollectionFrame_CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", 24, "hands", "waist", "legs", "feet", 24, "mainhand", 12, "secondaryhand" };
	local parentFrame = WardrobeCollectionFrame.ModelsFrame.SlotsFrame;
	local lastButton;	
	local xOffset = 2;
	local mainHandButton, secondaryHandButton;
	for i = 1, #slots do
		local value = tonumber(slots[i]);
		if ( value ) then
			-- this is a spacer
			xOffset = value;
		else
			local button = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSlotButtonTemplate");
			button.NormalTexture:SetAtlas("transmog-nav-slot-"..slots[i], true);
			if ( lastButton ) then
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				button:SetPoint("TOPLEFT");
			end
			button.slot = string.upper(slots[i]).."SLOT";
			xOffset = 2;
			lastButton = button;
			if ( slots[i] == "mainhand" ) then
				mainHandButton = button;
			elseif ( slots[i] == "secondaryhand" ) then
				secondaryHandButton = button;
			end
		end
	end
	-- enchant buttons
	local mainHandEnchantButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeEnchantButtonTemplate");
	mainHandEnchantButton:SetPoint("BOTTOMRIGHT", mainHandButton, "TOPRIGHT", 16, -15);
	mainHandEnchantButton.slot = mainHandButton.slot;
	local secondaryHandEnchantButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeEnchantButtonTemplate");
	secondaryHandEnchantButton:SetPoint("BOTTOMRIGHT", secondaryHandButton, "TOPRIGHT", 16, -15);
	secondaryHandEnchantButton.slot = secondaryHandButton.slot;
	parentFrame.EnchantButtons = { mainHandEnchantButton, secondaryHandEnchantButton };
end

function WardrobeCollectionFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		-- TODO: fix weapon dropdown? force change category?
	elseif ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" or event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slotID = ...;
		if ( slotID and WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			if ( slotID == GetInventorySlotInfo(WardrobeCollectionFrame.activeSlot) ) then
				WardrobeCollectionFrame_Update();
			end
		else
			-- generic update
			WardrobeCollectionFrame_Update();
		end
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.tooltipAppearanceID ) then
			WardrobeCollectionFrameModel_SetTooltip();
		end
	elseif ( event == "TRANSMOG_COLLECTION_CAMERA_UPDATE" ) then
		for i = 1, #self.ModelsFrame.Models do
			self.ModelsFrame.Models[i].cameraID = nil;
		end
		WardrobeCollectionFrame_Update();
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED") then
		local categoryID, sourceID, visualID, action = ...;
		if ( action == "add" ) then
			self.newTransmogs[visualID] = true;
			self.mostRecentCollectedVisualID = visualID;
			self.mostRecentCollectedCategoryID = categoryID;
			if ( not CollectionsJournal:IsShown() ) then
				CollectionsJournal_SetTab(CollectionsJournal, 5);
			end
		elseif ( action == "remove" ) then
			self.newTransmogs[visualID] = nil;
			if ( self.mostRecentCollectedVisualID == visualID ) then
				self.mostRecentCollectedVisualID = nil;
				self.mostRecentCollectedCategoryID = nil;
			end
		end
		if ( self:IsVisible() and (not categoryID or categoryID == self.activeCategory) ) then
			WardrobeCollectionFrame_GetVisualsList();
			WardrobeCollectionFrame_FilterVisuals();
			WardrobeCollectionFrame_SortVisuals();
			WardrobeCollectionFrame_Update();
		end
	elseif ( event == "APPEARANCE_SEARCH_UPDATED" ) then
		local category = ...;
		if ( category == self.activeCategory ) then
			WardrobeCollectionFrame_UpdateSearch();
		end
	elseif ( event == "SEARCH_DB_LOADED" ) then
		WardrobeCollectionFrame_RestartSearchTracking();
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local hasAlternateForm, inAlternateForm = HasAlternateForm();
		if ( self.inAlternateForm ~= inAlternateForm and self.ModelsFrame.Models[1]:CanSetUnit("player") ) then
			self.inAlternateForm = inAlternateForm;
			WardrobeCollectionFrame_ChangeModelsSlot(nil, WardrobeCollectionFrame.activeSlot);
			WardrobeCollectionFrame_Update();
		end
	elseif ( event == "PLAYER_LEVEL_UP" or event == "SKILL_LINES_CHANGED" or event == "UPDATE_FACTION" or event == "SPELLS_CHANGED" ) then
		if ( self:IsVisible() ) then
			C_TransmogCollection.UpdateUsableAppearances();
		else
			self.needsUpdateUsable = true;
		end
	end
end

function WardrobeCollectionFrame_OnShow(self)
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_chest_cloth_17");

	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	self:RegisterEvent("APPEARANCE_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end

	local needsUpdate = false;	-- we don't need to update if we call WardrobeCollectionFrame_SetActiveSlot as that will do an update
	if ( self.mostRecentCollectedCategoryID and self.mostRecentCollectedCategoryID ~= self.activeCategory ) then
		local categoryID = self.mostRecentCollectedCategoryID;
		local slot = WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID);
		WardrobeCollectionFrame_SetActiveSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE, categoryID);
	elseif ( self.activeSlot ) then
		-- redo the model for the active slot
		WardrobeCollectionFrame_ChangeModelsSlot(nil, self.activeSlot);
		needsUpdate = true;
	else
		WardrobeCollectionFrame_SetActiveSlot("HEADSLOT", LE_TRANSMOG_TYPE_APPEARANCE);
	end

	if ( needsUpdate ) then
		WardrobeCollectionFrame_GetVisualsList();
		WardrobeCollectionFrame_FilterVisuals();
		WardrobeCollectionFrame_SortVisuals();
		WardrobeCollectionFrame_Update();
		WardrobeCollectionFrame_UpdateWeaponDropDown();
	end

	if ( self.needsUpdateUsable ) then
		self.needsUpdateUsable = nil;
		C_TransmogCollection.UpdateUsableAppearances();
	end

	-- tab tutorial
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB, true);
end

function WardrobeCollectionFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	self:UnregisterEvent("APPEARANCE_SEARCH_UPDATED");
	self:UnregisterEvent("SEARCH_DB_LOADED");
	WardrobeCollectionFrame_ClearSearch();
	C_TransmogCollection.EndSearch();

	for i = 1, #self.ModelsFrame.Models do
		self.ModelsFrame.Models[i]:SetKeepModelOnHide(false);
	end

	self.visualsList = nil;
	self.filteredVisualsList = nil;
end
	
function WardrobeCollectionFrame_OnMouseWheel(self, delta)
	if ( delta > 0 ) then
		WardrobeCollectionFrame_PrevPage();
	else
		WardrobeCollectionFrame_NextPage();
	end
end

function WardrobeCollectionFrame_OnKeyDown(self, key)
	if ( self.tooltipCycle and key == WARDROBE_CYCLE_KEY ) then
		self:SetPropagateKeyboardInput(false);
		if ( IsShiftKeyDown() ) then
			self.tooltipIndexOffset = self.tooltipIndexOffset - 1;
		else
			self.tooltipIndexOffset = self.tooltipIndexOffset + 1;
		end
		WardrobeCollectionFrameModel_SetTooltip();
	elseif ( key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY ) then
		if ( not WardrobeFrame_IsAtTransmogrifier() ) then
			self:SetPropagateKeyboardInput(true);
			return;
		end

		self:SetPropagateKeyboardInput(false);
		local _, _, _, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
		local visualIndex;
		local visualsList = WardrobeCollectionFrame.filteredVisualsList;
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == selectedVisualID ) then
				visualIndex = i;
				break;
			end
		end
		if ( not visualIndex ) then
			return;
		end
		if ( key == WARDROBE_PREV_VISUAL_KEY ) then
			visualIndex = visualIndex - 1;
			if ( visualIndex < 1 ) then
				visualIndex = #visualsList;
			end
		elseif ( key == WARDROBE_NEXT_VISUAL_KEY ) then
			visualIndex = visualIndex + 1;
			if ( visualIndex > #visualsList ) then
				visualIndex = 1;
			end
		elseif ( key == WARDROBE_DOWN_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY ) then
			local function GetPage(index)
				return floor((index-1) / WARDROBE_PAGE_SIZE) + 1;
			end

			local direction = 1;
			if ( key == WARDROBE_UP_VISUAL_KEY ) then
				direction = -1;
			end

			local currentPage = WardrobeCollectionFrame_GetCurrentPage();
			local newIndex = visualIndex;
			newIndex = newIndex + WARDROBE_NUM_COLS * direction;
			if ( GetPage(newIndex) ~= currentPage or newIndex > #visualsList ) then
				newIndex = visualIndex + WARDROBE_PAGE_SIZE * -direction;	-- reset by a full page in opposite direction
				while ( GetPage(newIndex) ~= currentPage or newIndex > #visualsList ) do
					newIndex = newIndex + WARDROBE_NUM_COLS * direction;
				end
			end
			visualIndex = newIndex;
		end
		WardrobeCollectionFrame_SelectVisual(visualsList[visualIndex].visualID);
		WardrobeCollectionFrame.jumpToVisualID = visualsList[visualIndex].visualID;
		WardrobeCollectionFrame_ResetPage();
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function WardrobeCollectionFrame_ChangeModelsSlot(oldSlot, newSlot)
	local undressSlot, reloadModel;
	local newSlotIsArmor = WardrobeCollectionFrame_GetArmorCategoryIDFromSlot(newSlot);
	if ( newSlotIsArmor ) then
		local oldSlotIsArmor = oldSlot and WardrobeCollectionFrame_GetArmorCategoryIDFromSlot(oldSlot);
		if ( oldSlotIsArmor ) then
			if ( WARDROBE_MODEL_SETUP[oldSlot].useTransmogSkin ~= WARDROBE_MODEL_SETUP[newSlot].useTransmogSkin ) then
				reloadModel = true;
			else
				undressSlot = true;
			end
		else
			reloadModel = true;
		end
	end
	for i = 1, #WardrobeCollectionFrame.ModelsFrame.Models do
		local model = WardrobeCollectionFrame.ModelsFrame.Models[i];
		if ( undressSlot ) then
			local changedOldSlot = false;
			-- dress/undress setup gear
			for slot, equip in pairs(WARDROBE_MODEL_SETUP[newSlot].slots) do
				if ( equip ~= WARDROBE_MODEL_SETUP[oldSlot].slots[slot] ) then
					if ( equip ) then
						model:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
					else
						model:UndressSlot(GetInventorySlotInfo(slot));
					end
					if ( slot == oldSlot ) then
						changedOldSlot = true;
					end
				end
			end
			-- undress old slot
			if ( not changedOldSlot ) then
				local slotID = GetInventorySlotInfo(oldSlot);
				model:UndressSlot(slotID);
			end
		elseif ( reloadModel ) then
			WardrobeCollectionFrameModel_Reload(model, newSlot);
		end
		model.visualInfo = nil;
	end
	WardrobeCollectionFrame.illusionWeaponVisualID = nil;
end

function WardrobeCollectionFrame_IsCategoryRanged(category)
	return (category == LE_TRANSMOG_COLLECTION_TYPE_BOW) or (category == LE_TRANSMOG_COLLECTION_TYPE_GUN) or (category == LE_TRANSMOG_COLLECTION_TYPE_CROSSBOW);
end

function WardrobeCollectionFrame_GetArmorCategoryIDFromSlot(slot)
	for i = 1, #TRANSMOG_SLOTS do
		if ( TRANSMOG_SLOTS[i].slot == slot ) then
			return TRANSMOG_SLOTS[i].armorCategoryID;
		end
	end
end

local function IsValidWeaponCategoryForSlot(categoryID, slot)
	local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
	if ( name and isWeapon ) then
		if ( (slot == "MAINHANDSLOT" and canMainHand) or (slot == "SECONDARYHANDSLOT" and canOffHand) ) then
			if ( WardrobeFrame_IsAtTransmogrifier() ) then
				local equippedItemID = GetInventoryItemID("player", GetInventorySlotInfo(slot));
				return C_TransmogCollection.IsCategoryValidForItem(WardrobeCollectionFrame.lastWeaponCategory, equippedItemID);
			else
				return true;
			end
		end
	end
	return false;
end

function WardrobeCollectionFrame_SetActiveSlot(slot, transmogType, category)
	local previousSlot = WardrobeCollectionFrame.activeSlot;
	WardrobeCollectionFrame.activeSlot = slot;
	WardrobeCollectionFrame.transmogType = transmogType;

	-- figure out a category
	if ( not category ) then
		if ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			category = nil;
		elseif ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local useLastWeaponCategory = (slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT") and
										 WardrobeCollectionFrame.lastWeaponCategory and
										 IsValidWeaponCategoryForSlot(WardrobeCollectionFrame.lastWeaponCategory, slot);
			if ( useLastWeaponCategory ) then
				category = WardrobeCollectionFrame.lastWeaponCategory;
			else
				local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
				if ( selectedSourceID ~= NO_TRANSMOG_SOURCE_ID ) then
					category = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
				end
			end
			if ( not category ) then
				if ( slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT" ) then
					-- find the first valid weapon category
					for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
						if ( IsValidWeaponCategoryForSlot(categoryID, slot) ) then
							category = categoryID;
							break;
						end
					end
				else
					category = WardrobeCollectionFrame_GetArmorCategoryIDFromSlot(slot);
				end
			end
		end
	end

	if ( previousSlot ~= slot ) then
		WardrobeCollectionFrame_ChangeModelsSlot(previousSlot, slot);
	end
	-- set only if category is different or slot is different
	if ( category ~= WardrobeCollectionFrame.activeCategory or slot ~= previousSlot ) then
		WardrobeCollectionFrame_SetActiveCategory(category);
	end
end

function WardrobeCollectionFrame_SetTransmogrifierAppearancesShown(hasAnyValidSlots)
	WardrobeCollectionFrame.ModelsFrame.NoValidItemsLabel:SetShown(not hasAnyValidSlots);
	C_TransmogCollection.SetCollectedShown(hasAnyValidSlots);
end

function WardrobeCollectionFrame_UpdateWeaponDropDown()
	local dropdown = WardrobeCollectionFrame.ModelsFrame.WeaponDropDown;
	local name, isWeapon;
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		name, isWeapon = C_TransmogCollection.GetCategoryInfo(WardrobeCollectionFrame.activeCategory);
	end
	if ( not isWeapon ) then
		if ( WardrobeFrame_IsAtTransmogrifier() ) then
			dropdown:Hide();
		else
			dropdown:Show();
			UIDropDownMenu_DisableDropDown(dropdown);
			UIDropDownMenu_SetText(dropdown, "");
		end
	else
		dropdown:Show();
		UIDropDownMenu_SetSelectedValue(dropdown, WardrobeCollectionFrame.activeCategory);
		UIDropDownMenu_SetText(dropdown, name);
		local validCategories = WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if ( validCategories > 1 ) then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	end
end

function WardrobeCollectionFrame_SetActiveCategory(category)
	WardrobeCollectionFrame.activeCategory = category;
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		C_TransmogCollection.SetFilterCategory(category);
		local name, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
		if ( isWeapon ) then
			WardrobeCollectionFrame.lastWeaponCategory = category;
		end
	end
	WardrobeCollectionFrame_GetVisualsList();
	WardrobeCollectionFrame_UpdateWeaponDropDown();

	local slotButtons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.slot == WardrobeCollectionFrame.activeSlot and button.transmogType == WardrobeCollectionFrame.transmogType);
	end

	WardrobeCollectionFrame_FilterVisuals();
	WardrobeCollectionFrame_SortVisuals();
	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		WardrobeCollectionFrame.jumpToVisualID = select(4, WardrobeCollectionFrame_GetActiveSlotInfo());
	else
		WardrobeCollectionFrame.jumpToVisualID = nil;
	end
	WardrobeCollectionFrame_ResetPage();
	WardrobeCollectionFrame_SwitchSearchCategory();
end

function WardrobeCollectionFrame_ResetPage()
	local page = 1;
	local selectedVisualID = NO_TRANSMOG_VISUAL_ID;
	if ( C_TransmogCollection.IsSearchInProgress() ) then
		WardrobeCollectionFrame.resetPageOnSearchUpdated = true;
	else
		if ( WardrobeCollectionFrame.jumpToVisualID ) then
			selectedVisualID = WardrobeCollectionFrame.jumpToVisualID;
			WardrobeCollectionFrame.jumpToVisualID = nil;
		elseif ( WardrobeCollectionFrame.mostRecentCollectedVisualID ) then
			selectedVisualID = WardrobeCollectionFrame.mostRecentCollectedVisualID;
			WardrobeCollectionFrame.mostRecentCollectedVisualID = nil;
			WardrobeCollectionFrame.mostRecentCollectedCategoryID = nil;
		end
	end
	if ( selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
		for i = 1, #WardrobeCollectionFrame.filteredVisualsList do
			if ( WardrobeCollectionFrame.filteredVisualsList[i].visualID == selectedVisualID ) then
				page = floor((i-1) / WARDROBE_PAGE_SIZE) + 1;
				break;
			end
		end
	end
	WardrobeCollectionFrame_SetCurrentPage(page);
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFrame_FilterVisuals()
	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		local visualsList = WardrobeCollectionFrame.visualsList;
		local filteredVisualsList = { };
		for i = 1, #visualsList do
			if ( visualsList[i].isUsable and visualsList[i].isCollected ) then
				tinsert(filteredVisualsList, visualsList[i]);
			end
		end
		WardrobeCollectionFrame.filteredVisualsList = filteredVisualsList;
	else
		WardrobeCollectionFrame.filteredVisualsList = WardrobeCollectionFrame.visualsList;
	end
end

function WardrobeCollectionFrame_SortVisuals()
	local comparison = function(source1, source2)
		if ( source1.isCollected ~= source2.isCollected ) then
			return source1.isCollected;
		end
		if ( source1.isUsable ~= source2.isUsable ) then
			return source1.isUsable;
		end
		if ( source1.isFavorite ~= source2.isFavorite ) then
			return source1.isFavorite;
		end
		if ( source1.isHideVisual ~= source2.isHideVisual ) then
			return source1.isHideVisual;
		end
		if ( source1.uiOrder and source2.uiOrder ) then
			return source1.uiOrder > source2.uiOrder;
		end
		return source1.sourceID > source2.sourceID;
	end

	table.sort(WardrobeCollectionFrame.filteredVisualsList, comparison);
end

function WardrobeCollectionFrame_GetActiveSlotInfo()
	return WardrobeCollectionFrame_GetInfoForSlot(WardrobeCollectionFrame.activeSlot, WardrobeCollectionFrame.transmogType);
end

function WardrobeCollectionFrame_GetInfoForSlot(slot, transmogType)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(slot), transmogType);
	if ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		appliedSourceID = baseSourceID;
		appliedVisualID = baseVisualID;
	end
	local selectedSourceID, selectedVisualID;
	if ( pendingSourceID ~= REMOVE_TRANSMOG_ID ) then
		selectedSourceID = pendingSourceID;
		selectedVisualID = pendingVisualID;
	elseif ( hasPendingUndo ) then
		selectedSourceID = baseSourceID;
		selectedVisualID = baseVisualID;
	else
		selectedSourceID = appliedSourceID;
		selectedVisualID = appliedVisualID;
	end
	return appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID;
end

function WardrobeCollectionFrame_GetWeaponInfoForEnchant(slot)
	if ( not WardrobeFrame_IsAtTransmogrifier() and DressUpFrame:IsShown() ) then
		local appearanceSourceID = DressUpModel:GetSlotTransmogSources(GetInventorySlotInfo(slot));
		local _, appearanceVisualID, canEnchant = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		if ( canEnchant ) then
			return appearanceSourceID, appearanceVisualID;
		end
	end

	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetInfoForSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
	local _, _, canEnchant = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
	if ( canEnchant ) then
		return selectedSourceID, selectedVisualID;
	else
		local appearanceSourceID = C_TransmogCollection.GetIllusionFallbackWeaponSource();
		local _, appearanceVisualID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID;
	end
end

function WardrobeCollectionFrame_Update()
	local isArmor;
	local cameraID;
	local appearanceVisualID;	-- for weapon when looking at enchants
	local changeModel = false;
	local isAtTransmogrifier = WardrobeFrame_IsAtTransmogrifier();

	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		-- for enchants we need to get the visual of the item in that slot
		local appearanceSourceID;
		appearanceSourceID, appearanceVisualID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(WardrobeCollectionFrame.activeSlot);
		cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(appearanceSourceID);
		if ( appearanceVisualID ~= WardrobeCollectionFrame.illusionWeaponVisualID ) then
			WardrobeCollectionFrame.illusionWeaponVisualID = appearanceVisualID;
			changeModel = true;
		end
	else
		local _, isWeapon = C_TransmogCollection.GetCategoryInfo(WardrobeCollectionFrame.activeCategory);
		isArmor = not isWeapon;
	end

	if ( WardrobeCollectionFrame_GetCurrentPage() > WardrobeCollectionFrame_GetMaxPages() ) then
		WardrobeCollectionFrame_SetCurrentPage(WardrobeCollectionFrame_GetMaxPages());
	elseif ( WardrobeCollectionFrame_GetCurrentPage() < 1 and WardrobeCollectionFrame_GetMaxPages() > 0 ) then
		WardrobeCollectionFrame_SetCurrentPage(1);
	end

	local tutorialAnchorFrame;
	local checkTutorialFrame = (WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE) and not WardrobeFrame_IsAtTransmogrifier()
								and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK);

	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo;
	local showUndoIcon;
	if ( isAtTransmogrifier ) then
		baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(WardrobeCollectionFrame.activeSlot), WardrobeCollectionFrame.transmogType);
		if ( appliedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
			if ( hasPendingUndo ) then
				pendingVisualID = baseVisualID;
				showUndoIcon = true;
			end
			-- current border (yellow) should only show on untransmogrified items
			baseVisualID = nil;
		end	
		-- hide current border (yellow) or current-transmogged border (purple) if there's something pending
		if ( pendingVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
			baseVisualID = nil;
			appliedVisualID = nil;
		end
	end

	local pendingTransmogModelFrame = nil;
	for i = 1, WARDROBE_PAGE_SIZE do
		local model = WardrobeCollectionFrame.ModelsFrame.Models[i];
		local index = i + (WardrobeCollectionFrame_GetCurrentPage() - 1) * WARDROBE_PAGE_SIZE;
		local visualInfo = WardrobeCollectionFrame.filteredVisualsList[index];
		if ( visualInfo ) then
			model:Show();

			-- camera
			if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
				cameraID = C_TransmogCollection.GetAppearanceCameraID(visualInfo.visualID);
			end
			if ( model.cameraID ~= cameraID ) then
				Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

			if ( visualInfo ~= model.visualInfo or changeModel ) then
				if ( isArmor ) then
					local sourceID = WardrobeCollectionFrame_GetAnAppearanceSourceFromVisual(visualInfo.visualID);
					model:TryOn(sourceID);
				elseif ( appearanceVisualID ) then
					-- appearanceVisualID is only set when looking at enchants
					model:SetItemAppearance(appearanceVisualID, visualInfo.visualID);
				else
					model:SetItemAppearance(visualInfo.visualID);
				end
			end
			model.visualInfo = visualInfo;

			-- state at the transmogrifier
			local transmogStateAtlas;
			if ( visualInfo.visualID == appliedVisualID ) then
				transmogStateAtlas = "transmog-wardrobe-border-current-transmogged";
			elseif ( visualInfo.visualID == baseVisualID ) then
				transmogStateAtlas = "transmog-wardrobe-border-current";
			elseif ( visualInfo.visualID == pendingVisualID ) then
				transmogStateAtlas = "transmog-wardrobe-border-selected";
				pendingTransmogModelFrame = model;
			end
			if ( transmogStateAtlas ) then
				model.TransmogStateTexture:SetAtlas(transmogStateAtlas, true);
				model.TransmogStateTexture:Show();
			else
				model.TransmogStateTexture:Hide();
			end

			-- border
			if ( not visualInfo.isCollected ) then
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			elseif ( not visualInfo.isUsable ) then
				model.Border:SetAtlas("transmog-wardrobe-border-unusable");
			else
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
			end

			if ( WardrobeCollectionFrame.newTransmogs[visualInfo.visualID] ) then
				model.NewString:Show();
				model.NewGlow:Show();
			else
				model.NewString:Hide();
				model.NewGlow:Hide();
			end
			-- favorite
			model.Favorite.Icon:SetShown(visualInfo.isFavorite);
			-- hide visual option
			model.HideVisual.Icon:SetShown(isAtTransmogrifier and visualInfo.isHideVisual);

			if ( GameTooltip:GetOwner() == model ) then
				WardrobeCollectionFrameModel_OnEnter(model);
			end
			
			-- find potential tutorial anchor in the 1st row
			if ( checkTutorialFrame ) then
				if ( i < WARDROBE_NUM_COLS and not WardrobeCollectionFrame.tutorialVisualID and visualInfo.isCollected and not visualInfo.isHideVisual ) then
					tutorialAnchorFrame = model;
				elseif ( WardrobeCollectionFrame.tutorialVisualID and WardrobeCollectionFrame.tutorialVisualID == visualInfo.visualID ) then
					tutorialAnchorFrame = model;
				end
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end
	if ( pendingTransmogModelFrame ) then
		WardrobeModelPendingTransmogFrame:SetParent(pendingTransmogModelFrame);
		WardrobeModelPendingTransmogFrame:SetPoint("CENTER");
		WardrobeModelPendingTransmogFrame:Show();
		if ( WardrobeModelPendingTransmogFrame.visualID ~= pendingVisualID ) then
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim:Stop();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim:Play();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim2:Stop();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim2:Play();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim3:Stop();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim3:Play();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim4:Stop();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim4:Play();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim5:Stop();
			WardrobeModelPendingTransmogFrame.TransmogSelectedAnim5:Play();
		end
		WardrobeModelPendingTransmogFrame.UndoIcon:SetShown(showUndoIcon);
		WardrobeModelPendingTransmogFrame.visualID = pendingVisualID;
	else
		WardrobeModelPendingTransmogFrame:Hide();
	end
	-- navigation buttons
	WardrobeCollectionFrame_UpdateNavigationButtons();
	-- progress bar
	WardrobeCollectionFrame_UpdateProgressBar(WardrobeCollectionFrame.filteredVisualsList);
	-- tutorial
	if ( checkTutorialFrame ) then
		if ( C_TransmogCollection.HasFavorites() ) then
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true);
			tutorialAnchorFrame = nil;
		elseif ( tutorialAnchorFrame ) then
			if ( not WardrobeCollectionFrame.tutorialVisualID ) then
				WardrobeCollectionFrame.tutorialVisualID = tutorialAnchorFrame.visualInfo.visualID;
			end
			if ( WardrobeCollectionFrame.tutorialVisualID ~= tutorialAnchorFrame.visualInfo.visualID ) then
				tutorialAnchorFrame = nil;
			end
		end
	end
	if ( tutorialAnchorFrame ) then
		WardrobeCollectionFrame.ModelsFrame.HelpBox:SetPoint("TOP", tutorialAnchorFrame, "BOTTOM", 0, -22);
		WardrobeCollectionFrame.ModelsFrame.HelpBox:Show();
	else
		WardrobeCollectionFrame.ModelsFrame.HelpBox:Hide();
	end
end

function WardrobeCollectionFrame_GetMaxPages()
	return ceil(#WardrobeCollectionFrame.filteredVisualsList / WARDROBE_PAGE_SIZE);
end

function WardrobeCollectionFrame_SetCurrentPage(page)
	CloseDropDownMenus();
	CURRENT_PAGE = page;
end

function WardrobeCollectionFrame_GetCurrentPage()
	return CURRENT_PAGE;
end

function WardrobeCollectionFrame_UpdateProgressBar(collection)
	local collected, total;
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		total = #WardrobeCollectionFrame.visualsList;
		collected = 0;
		for i, illusion in ipairs(WardrobeCollectionFrame.visualsList) do
			if ( illusion.isCollected ) then
				collected = collected + 1;
			end
		end
	else
		collected = C_TransmogCollection.GetCategoryCollectedCount(WardrobeCollectionFrame.activeCategory);
		total = C_TransmogCollection.GetCategoryTotal(WardrobeCollectionFrame.activeCategory);
	end
	WardrobeCollectionFrame.progressBar:SetMinMaxValues(0, total);
	WardrobeCollectionFrame.progressBar:SetValue(collected);
	WardrobeCollectionFrame.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, collected, total);
end

function WardrobeCollectionFrame_UpdateNavigationButtons()
	WardrobeCollectionFrame.NavigationFrame.PageText:SetFormattedText(COLLECTION_PAGE_NUMBER, WardrobeCollectionFrame_GetCurrentPage(), WardrobeCollectionFrame_GetMaxPages());
	if ( WardrobeCollectionFrame_GetCurrentPage() <= 1 ) then
		WardrobeCollectionFrame.NavigationFrame.PrevPageButton:Disable();
	else
		WardrobeCollectionFrame.NavigationFrame.PrevPageButton:Enable();
	end
	if ( WardrobeCollectionFrame_GetCurrentPage() == WardrobeCollectionFrame_GetMaxPages() ) then
		WardrobeCollectionFrame.NavigationFrame.NextPageButton:Disable();
	else
		WardrobeCollectionFrame.NavigationFrame.NextPageButton:Enable();
	end
end

function WardrobeCollectionFrame_GetSortedAppearanceSources(appearanceID)
	local comparison = function(source1, source2)
		if ( source1.isCollected ~= source2.isCollected ) then
			return source1.isCollected;
		end

		if ( source1.quality and source2.quality ) then
			if ( source1.quality ~= source2.quality ) then
				return source1.quality > source2.quality;
			end
		else
			return source1.quality;
		end

		return source1.sourceID > source2.sourceID;
	end

	local sources = C_TransmogCollection.GetAppearanceSources(appearanceID);
	table.sort(sources, comparison);
	return sources;
end

function WardrobeCollectionFrame_GetVisualsList()
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		WardrobeCollectionFrame.visualsList = C_TransmogCollection.GetIllusions();
	else
		WardrobeCollectionFrame.visualsList = C_TransmogCollection.GetCategoryAppearances(WardrobeCollectionFrame.activeCategory);
	end
end

function  WardrobeCollectionFrame_GetAnAppearanceSourceFromVisual(visualID)
	local sourceID = WardrobeCollectionFrameModel_GetChosenVisualSource(visualID);
	if ( not sourceID ) then
		local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID);
		sourceID = sources[1].sourceID;
	end
	return sourceID;
end

function WardrobeCollectionFrame_SelectVisual(visualID)
	if ( not WardrobeFrame_IsAtTransmogrifier() ) then
		return;
	end

	local sourceID;
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		sourceID = WardrobeCollectionFrame_GetAnAppearanceSourceFromVisual(visualID);
	else
		local visualsList = WardrobeCollectionFrame.filteredVisualsList;
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == visualID ) then
				sourceID = visualsList[i].sourceID;
				break;
			end
		end
	end
	local slotID = GetInventorySlotInfo(WardrobeCollectionFrame.activeSlot);
	C_Transmog.SetPending(slotID, WardrobeCollectionFrame.transmogType, sourceID);
	PlaySound("UI_Transmog_ItemClick");
end

function WardrobeCollectionFrame_OpenTransmogLink(link, transmogType)
	local linkType, sourceID = strsplit(":", link);
	if ( linkType ~= "transmogappearance" ) then
		return;
	end

	if ( not WardrobeCollectionFrame:IsVisible() ) then
		ToggleCollectionsJournal(5);
	end

	sourceID = tonumber(sourceID);
	local categoryID, visualID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	if ( categoryID ) then	
		local slot = WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID);
		WardrobeCollectionFrame.jumpToVisualID = visualID;
		if ( WardrobeCollectionFrame.activeCategory ~= categoryID or WardrobeCollectionFrame.activeSlot ~= slot ) then
			WardrobeCollectionFrame_SetActiveSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE, categoryID);
		else
			WardrobeCollectionFrame_ResetPage();
		end
	end
end

function WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID)
	local slot;
	for i = 1, #TRANSMOG_SLOTS do
		if ( TRANSMOG_SLOTS[i].armorCategoryID == categoryID ) then
			slot = TRANSMOG_SLOTS[i].slot;
			break;
		end
	end
	if ( not slot ) then
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
		if ( canMainHand ) then
			slot = "MAINHANDSLOT";
		elseif ( canOffHand ) then
			slot = "SECONDARYHANDSLOT";
		end
	end
	return slot;
end

-- ***** MODELS

function WardrobeCollectionFrameModel_OnLoad(self)
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	
	local lightValues = { enabled=true, omni=false, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.05, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
	self:SetLight(lightValues.enabled, lightValues.omni, 
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
			lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);
end

function WardrobeCollectionFrameModel_OnEvent(self)
	self:RefreshCamera();
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeCollectionFrameModel_OnModelLoaded(self)
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeCollectionFrameModel_OnMouseDown(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link;
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			link = select(3, C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID));
		else
			local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID);
			local offset = WardrobeCollectionFrame.tooltipIndexOffset;
			if ( offset ) then
				if ( offset < 0 ) then
					offset = #sources + offset;
				end
				local index = mod(offset, #sources) + 1;
				link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
			end
		end
		if ( link ) then
			HandleModifiedItemClick(link);
		end
		return;
	elseif ( IsModifiedClick("DRESSUP") ) then
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local sourceID = WardrobeCollectionFrame_GetAnAppearanceSourceFromVisual(self.visualInfo.visualID);
			local slot = WardrobeCollectionFrame.activeSlot;
			-- don't specify a slot for ranged weapons
			if ( WardrobeCollectionFrame_IsCategoryRanged(WardrobeCollectionFrame.activeCategory) ) then
				slot = nil;
			end
			DressUpVisual(sourceID, slot);
		elseif ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			local weaponSourceID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(WardrobeCollectionFrame.activeSlot);
			DressUpVisual(weaponSourceID, WardrobeCollectionFrame.activeSlot, self.visualInfo.sourceID);
		end
		return;
	end

	if ( button == "LeftButton" ) then
		CloseDropDownMenus();
		WardrobeCollectionFrame_SelectVisual(self.visualInfo.visualID);
	elseif ( button == "RightButton" ) then
		local dropDown = WardrobeCollectionFrame.ModelsFrame.RightClickDropDown;
		if ( dropDown.activeFrame ~= self ) then
			CloseDropDownMenus();
		end
		if ( not self.visualInfo.isCollected or self.visualInfo.isHideVisual or WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			return;
		end
		dropDown.activeFrame = self;
		ToggleDropDownMenu(1, nil, dropDown, self, -6, -3);
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function WardrobeCollectionFrameModel_OnEnter(self)
	if ( not self.visualInfo ) then
		return;
	end
	self:SetScript("OnUpdate", WardrobeCollectionFrameModel_OnUpdate);
	if ( WardrobeCollectionFrame.newTransmogs[self.visualInfo.visualID] ) then
		WardrobeCollectionFrame.newTransmogs[self.visualInfo.visualID] = nil;
		self.NewString:Hide();
		self.NewGlow:Hide();
	end
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		local visualID, name = C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name);
		if ( self.visualInfo.sourceText ) then
			GameTooltip:AddLine(self.visualInfo.sourceText, 1, 1, 1, 1);
		end
		GameTooltip:Show();
	else
		if ( self.visualInfo.isHideVisual ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(HIDE_VISUAL_STRINGS[WardrobeCollectionFrame.activeSlot]);
		else
			WardrobeCollectionFrame.tooltipAppearanceID = self.visualInfo.visualID;
			WardrobeCollectionFrame.tooltipIndexOffset = nil;
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			WardrobeCollectionFrameModel_SetTooltip();
		end
	end
end

function WardrobeCollectionFrameModel_OnLeave(self)
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	WardrobeCollectionFrame.tooltipAppearanceID = nil;
	WardrobeCollectionFrame.tooltipCycle = nil;
	WardrobeCollectionFrame.tooltipIndexOffset = nil;
	GameTooltip:Hide();
end

function WardrobeCollectionFrameModel_OnUpdate(self)
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function WardrobeCollectionFrameModel_Reload(self, reloadSlot)
	if ( self:IsShown() ) then
		if ( WARDROBE_MODEL_SETUP[reloadSlot] ) then
			self:SetUseTransmogSkin(WARDROBE_MODEL_SETUP[reloadSlot].useTransmogSkin);
			self:SetUnit("player");
			self:FreezeAnimation(0);
			self:Undress();
			for slot, equip in pairs(WARDROBE_MODEL_SETUP[reloadSlot].slots) do
				if ( equip ) then
					self:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
				end
			end
		end
		self:SetKeepModelOnHide(true);
		self.cameraID = nil;
		self.needsReload = nil;
	else
		self.needsReload = true;
	end
end

function WardrobeCollectionFrameModel_OnShow(self)
	if ( self.needsReload ) then
		WardrobeCollectionFrameModel_Reload(self, WardrobeCollectionFrame.activeSlot);
	end
end

local function GetDropDifficulties(drop)
	local text = drop.difficulties[1];
	if ( text ) then
		for i = 2, #drop.difficulties do
			text = text..", "..drop.difficulties[i];
		end
	end
	return text;
end

function WardrobeCollectionFrameModel_SetTooltip()
	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(WardrobeCollectionFrame.tooltipAppearanceID);

	if ( not WardrobeCollectionFrame.tooltipIndexOffset ) then
		WardrobeCollectionFrame.tooltipIndexOffset = 0;
		local lowestUseLevel = GetMaxPlayerLevel();
		for i = 1, #sources do
			if ( not sources[i].isCollected ) then
				break;
			end
			if ( not sources[i].useError ) then
				WardrobeCollectionFrame.tooltipIndexOffset = i - 1;
				break;
			end
			if ( sources[i].minLevel and sources[i].minLevel < lowestUseLevel ) then
				lowestUseLevel = sources[i].minLevel;
				WardrobeCollectionFrame.tooltipIndexOffset = i - 1;
			end
		end
	end
	if ( WardrobeCollectionFrame.tooltipIndexOffset < 0 ) then
		WardrobeCollectionFrame.tooltipIndexOffset = #sources + WardrobeCollectionFrame.tooltipIndexOffset;
	end
	local offset = WardrobeCollectionFrame.tooltipIndexOffset;
	-- header item
	local headerIndex;
	local headerSourceID = WardrobeCollectionFrameModel_GetChosenVisualSource(WardrobeCollectionFrame.tooltipAppearanceID);
	if ( headerSourceID ) then
		-- find the index
		for i = 1, #sources do
			if ( sources[i].sourceID == headerSourceID ) then
				headerIndex = mod(i + offset - 1, #sources) + 1;
				break;
			end
		end
	else
		headerIndex = mod(offset, #sources) + 1;
		headerSourceID = sources[headerIndex].sourceID;
	end

	local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[headerIndex]);
	GameTooltip:SetText(name, nameColor.r, nameColor.g, nameColor.b);

	-- at the transmogrify vendor or the appearance is collected we're done after the main item name
	if ( WardrobeFrame_IsAtTransmogrifier() or sources[headerIndex].isCollected ) then
		-- but extra tooltip text if not at transmogrifier
		if ( not WardrobeFrame_IsAtTransmogrifier() ) then
			GameTooltip:AddLine(WARDROBE_TOOLTIP_TRANSMOGRIFIER, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1, 1);
		end
		GameTooltip:Show();
		return;
	end

	if ( sources[headerIndex].sourceType == TRANSMOG_SOURCE_BOSS_DROP and not sources[headerIndex].isCollected ) then
		local drops = C_TransmogCollection.GetAppearanceSourceDrops(headerSourceID);
		if ( drops and #drops > 0 ) then
			local showDifficulty = false;
			if ( #drops == 1 ) then
				sourceText = _G["TRANSMOG_SOURCE_"..TRANSMOG_SOURCE_BOSS_DROP]..": "..string.format(WARDROBE_TOOLTIP_ENCOUNTER_SOURCE, drops[1].encounter, drops[1].instance);
				showDifficulty = true;
			else
				-- check if the drops are the same instance
				local sameInstance = true;
				local firstInstance = drops[1].instance;
				for i = 2, #drops do
					if ( drops[i].instance ~= firstInstance ) then
						sameInstance = false;
						break;
					end
				end
				-- ok, if multiple instances check if it's the same tier if the drops have a single tier
				local sameTier = true;
				local firstTier = drops[1].tiers[1];
				if ( not sameInstance and #drops[1].tiers == 1 ) then
					for i = 2, #drops do
						if ( #drops[i].tiers > 1 or drops[i].tiers[1] ~= firstTier ) then
							sameTier = false;
							break;
						end
					end
				end
				-- if same instance or tier, check if we have same difficulties and same instanceType
				local sameDifficulty = false;
				local sameInstanceType = false;
				if ( sameInstance or sameTier ) then
					sameDifficulty = true;
					sameInstanceType = true;
					for i = 2, #drops do
						if ( drops[1].instanceType ~= drops[i].instanceType ) then
							sameInstanceType = false;
						end
						if ( #drops[1].difficulties ~= #drops[i].difficulties ) then
							sameDifficulty = false;
						else
							for j = 1, #drops[1].difficulties do
								if ( drops[1].difficulties[j] ~= drops[i].difficulties[j] ) then
									sameDifficulty = false;
									break;
								end
							end
						end
					end
				end
				-- override sourceText if sameInstance or sameTier
				if ( sameInstance ) then
					sourceText = _G["TRANSMOG_SOURCE_"..TRANSMOG_SOURCE_BOSS_DROP]..": "..firstInstance;
					showDifficulty = sameDifficulty;
				elseif ( sameTier ) then
					local location = firstTier;
					if ( sameInstanceType ) then
						if ( drops[1].instanceType == INSTANCE_TYPE_DUNGEON ) then
							location = string.format(WARDROBE_TOOLTIP_DUNGEONS, location);
						elseif ( drops[1].instanceType == INSTANCE_TYPE_RAID ) then
							location = string.format(WARDROBE_TOOLTIP_RAIDS, location);
						end
					end
					sourceText = _G["TRANSMOG_SOURCE_"..TRANSMOG_SOURCE_BOSS_DROP]..": "..location;
				end
			end
			if ( showDifficulty ) then
				local diffText = GetDropDifficulties(drops[1]);
				if ( diffText ) then
					sourceText = sourceText.." "..string.format(PARENS_TEMPLATE, diffText);
				end
			end
		end
	end
	GameTooltip:AddLine(sourceText, sourceColor.r, sourceColor.g, sourceColor.b, 1, 1);

	local useError;
	if ( #sources > 1 ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(WARDROBE_OTHER_ITEMS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		for i = 1, #sources do
			local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[i]);
			if ( i == headerIndex ) then
				name = WARDROBE_TOOLTIP_CYCLE_ARROW_ICON..name;
				useError = sources[i].useError;
			else
				name = WARDROBE_TOOLTIP_CYCLE_SPACER_ICON..name;
			end
			GameTooltip:AddDoubleLine(name, sourceText, nameColor.r, nameColor.g, nameColor.b, sourceColor.r, sourceColor.g, sourceColor.b);
		end	
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(WARDROBE_TOOLTIP_CYCLE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		WardrobeCollectionFrame.tooltipCycle = true;
	else
		useError = sources[headerIndex].useError;
		WardrobeCollectionFrame.tooltipCycle = nil;
	end

	if ( useError ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(useError, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function WardrobeCollectionFrameModel_GetSourceTooltipInfo(source)
	local name, nameColor;
	if ( source.name ) then
		name = source.name;
		nameColor = ITEM_QUALITY_COLORS[source.quality];
	else
		name = RETRIEVING_ITEM_INFO;
		nameColor = RED_FONT_COLOR;
		sourceText = "";
	end

	local sourceText, sourceColor;
	if ( source.isCollected ) then
		sourceText = COLLECTED;
		sourceColor = GREEN_FONT_COLOR;
	else
		sourceText = _G["TRANSMOG_SOURCE_"..source.sourceType];
		sourceColor = HIGHLIGHT_FONT_COLOR;
	end

	return name, nameColor, sourceText, sourceColor;
end

local chosenVisualSources = { };

function WardrobeCollectionFrameModel_GetChosenVisualSource(visualID)
	return chosenVisualSources[visualID];
end

function WardrobeCollectionFrameModel_SetChosenVisualSource(visualID, sourceID)
	chosenVisualSources[visualID] = sourceID;
end

function WardrobeCollectionFrameRightClickDropDown_Init(self)
	local appearanceID = self.activeFrame.visualInfo.visualID;
	local info = UIDropDownMenu_CreateInfo();
	-- Set Favorite
	if ( C_TransmogCollection.GetIsAppearanceFavorite(appearanceID) ) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.arg1 = appearanceID;
		info.arg2 = 0;
	else
		info.text = BATTLE_PET_FAVORITE;
		info.arg1 = appearanceID;
		info.arg2 = 1;
		if ( not C_TransmogCollection.CanSetFavoriteInCategory(WardrobeCollectionFrame.activeCategory) ) then
			info.tooltipWhileDisabled = 1
			info.tooltipTitle = BATTLE_PET_FAVORITE;
			info.tooltipText = TRANSMOG_CATEGORY_FAVORITE_LIMIT;
			info.tooltipOnButton = 1;
			info.disabled = 1;
		end
	end
	info.notCheckable = true;
	info.func = WardrobeCollectionFrameModelDropDown_SetFavorite;
	UIDropDownMenu_AddButton(info);
	-- Cancel
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = CANCEL;
	UIDropDownMenu_AddButton(info);

	local headerInserted = false;
	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(appearanceID);
	info.func = WardrobeCollectionFrameModelDropDown_SetSource;
	for i = 1, #sources do
		if ( sources[i].isCollected ) then
			if ( not headerInserted ) then
				headerInserted = true;
				-- space
				info.text = " ";
				info.disabled = true;
				UIDropDownMenu_AddButton(info);
				info.disabled = nil;
				-- header
				info.text = WARDROBE_TRANSMOGRIFY_AS;
				info.isTitle = true;
				info.colorCode = NORMAL_FONT_COLOR_CODE;
				UIDropDownMenu_AddButton(info);
				info.isTitle = nil;
				-- turn off notCheckable
				info.notCheckable = nil;
			end
			if ( sources[i].name ) then
				info.text = sources[i].name;
				info.colorCode = ITEM_QUALITY_COLORS[sources[i].quality].hex;
			else
				info.text = RETRIEVING_ITEM_INFO;
				info.colorCode = RED_FONT_COLOR_CODE;
			end
			info.disabled = nil;
			info.arg1 = appearanceID;
			info.arg2 = sources[i].sourceID;
			local checked;
			local chosenSourceID = WardrobeCollectionFrameModel_GetChosenVisualSource(appearanceID);
			if ( chosenSourceID ) then
				if ( chosenSourceID == sources[i].sourceID ) then
					checked = true;
				end
			else
				checked = (i == 1);
			end
			info.checked = checked;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function WardrobeCollectionFrameModelDropDown_SetSource(self, visualID, sourceID)
	WardrobeCollectionFrameModel_SetChosenVisualSource(visualID, sourceID);
end

function WardrobeCollectionFrameModelDropDown_SetFavorite(self, visualID, value)
	local set = (value == 1);
	C_TransmogCollection.SetIsAppearanceFavorite(visualID, set);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true);
	WardrobeCollectionFrame.ModelsFrame.HelpBox:Hide();
end

-- ***** WEAPON DROPDOWN

function WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameWeaponDropDown_Init(self)
	local slot = WardrobeCollectionFrame.activeSlot;
	if ( not slot ) then
		return;
	end

	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = WardrobeCollectionFrameWeaponDropDown_OnClick;

	local equippedItemID = GetInventoryItemID("player", GetInventorySlotInfo(slot));
	local checkCategory = equippedItemID and WardrobeFrame_IsAtTransmogrifier();
	if ( checkCategory ) then
		-- if the equipped item cannot be transmogrified, relax restrictions
		local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(GetInventorySlotInfo(slot), LE_TRANSMOG_TYPE_APPEARANCE);
		if ( not canTransmogrify ) then
			checkCategory = false;
		end
	end
	local buttonsAdded = 0;
	
	for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
		if ( name and isWeapon ) then
			if ( (slot == "MAINHANDSLOT" and canMainHand) or (slot == "SECONDARYHANDSLOT" and canOffHand) ) then
				if ( not checkCategory or C_TransmogCollection.IsCategoryValidForItem(categoryID, equippedItemID) ) then
					info.text = name;
					info.arg1 = categoryID;
					info.value = categoryID;
					if ( info.value == selectedValue ) then
						info.checked = 1;
					else
						info.checked = nil;
					end
					UIDropDownMenu_AddButton(info);
					buttonsAdded = buttonsAdded + 1;
				end
			end
		end
	end
	return buttonsAdded;
end

function WardrobeCollectionFrameWeaponDropDown_OnClick(self, category)
	if ( category and WardrobeCollectionFrame.activeCategory ~= category ) then
		CloseDropDownMenus();
		WardrobeCollectionFrame_SetActiveCategory(category);
	end	
end

-- ***** NAVIGATION

function WardrobeCollectionFrame_PrevPage()
	WardrobeCollectionFrame_SetPage(WardrobeCollectionFrame_GetCurrentPage() - 1);
	PlaySound("UI_Transmog_PageTurn");
end

function WardrobeCollectionFrame_NextPage()
	WardrobeCollectionFrame_SetPage(WardrobeCollectionFrame_GetCurrentPage() + 1);
	PlaySound("UI_Transmog_PageTurn");
end

function WardrobeCollectionFrame_SetPage(page)
	page = math.min(WardrobeCollectionFrame_GetMaxPages(), math.max(page, 1));
	if ( WardrobeCollectionFrame_GetCurrentPage() ~= page ) then
		WardrobeCollectionFrame_SetCurrentPage(page);
		PlaySound("igAbiliityPageTurn");
		WardrobeCollectionFrame_Update();
	end	
end

-- ***** SEARCHING

function WardrobeCollectionFrame_SwitchSearchCategory()
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		WardrobeCollectionFrame_ClearSearch();
		WardrobeCollectionFrame.searchBox:Disable();
		WardrobeCollectionFrame.FilterButton:Disable();
		return;
	end

	WardrobeCollectionFrame.searchBox:Enable();
	WardrobeCollectionFrame.FilterButton:Enable();
	if ( WardrobeCollectionFrame.searchBox:GetText() ~= "" )  then
		local finished = C_TransmogCollection.SetSearch(WardrobeCollectionFrame.activeCategory, WardrobeCollectionFrame.searchBox:GetText());
		if ( not finished ) then
			WardrobeCollectionFrame_RestartSearchTracking();
		end
	end
end

function WardrobeCollectionFrame_UpdateSearch()
	WardrobeCollectionFrame_GetVisualsList();
	WardrobeCollectionFrame_FilterVisuals();
	WardrobeCollectionFrame_SortVisuals();
	if ( WardrobeCollectionFrame.resetPageOnSearchUpdated ) then
		WardrobeCollectionFrame.resetPageOnSearchUpdated = nil;
		WardrobeCollectionFrame_ResetPage();
	else
		WardrobeCollectionFrame_Update();
	end
end

function WardrobeCollectionFrame_RestartSearchTracking()
	if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		return;
	end

	local searchSize = C_TransmogCollection.SearchSize(WardrobeCollectionFrame.activeCategory);
	local searchProgress = C_TransmogCollection.SearchProgress(WardrobeCollectionFrame.activeCategory);
	
	WardrobeCollectionFrame.searchProgressFrame:Hide();
	WardrobeCollectionFrame.searchBox.updateDelay = 0;
	if ( not C_TransmogCollection.IsSearchInProgress() ) then
		WardrobeCollectionFrame_UpdateSearch();
	else
		WardrobeCollectionFrame.searchBox:SetScript("OnUpdate", WardrobeCollectionFrameSearchBox_OnUpdate);
	end
end

function WardrobeCollectionFrame_ClearSearch()
	WardrobeCollectionFrame.searchBox:SetText("");
	WardrobeCollectionFrame.searchProgressFrame:Hide();
	C_TransmogCollection.ClearSearch();
end

function WardrobeCollectionFrameSearchProgressBar_OnLoad(self)
	self:SetStatusBarColor(0, .6, 0, 1);
	self:SetMinMaxValues(0, 1000);
	self:SetValue(0);
	self:GetStatusBarTexture():SetDrawLayer("BORDER");
end

function WardrobeCollectionFrameSearchProgressBar_OnHide(self)
	self:SetValue(0);
	self:SetScript("OnUpdate", nil);
end

function WardrobeCollectionFrameSearchProgressBar_OnUpdate(self, elapsed)
	local _, maxValue = self:GetMinMaxValues();
	local searchSize = C_TransmogCollection.SearchSize(WardrobeCollectionFrame.activeCategory);
	local searchProgress = C_TransmogCollection.SearchProgress(WardrobeCollectionFrame.activeCategory);
	self:SetValue((searchProgress * maxValue) / searchSize);
	
	if ( not C_TransmogCollection.IsSearchInProgress() ) then
		WardrobeCollectionFrame.searchProgressFrame:Hide();
	end
end

function WardrobeCollectionFrameSearchBox_OnLoad(self)
	SearchBoxTemplate_OnLoad(self);
	self:SetScript("OnUpdate", nil);
	self.updateDelay = 0;
end

function WardrobeCollectionFrameSearchBox_OnHide(self)
	self:SetScript("OnUpdate", nil);
	self.updateDelay = 0;
	WardrobeCollectionFrame.searchProgressFrame:Hide();
end

function WardrobeCollectionFrameSearchBox_OnKeyDown(self, key, ...)
	if ( key == WARDROBE_CYCLE_KEY ) then
		WardrobeCollectionFrame_OnKeyDown(WardrobeCollectionFrame, key, ...);
	end
end

local WARDROBE_SEARCH_DELAY = 0.6;
function WardrobeCollectionFrameSearchBox_OnUpdate(self, elapsed)
	self.updateDelay = self.updateDelay + elapsed;
	
	if ( not C_TransmogCollection.IsSearchInProgress() ) then
		self:SetScript("OnUpdate", nil);
		self.updateDelay = 0;
	elseif ( self.updateDelay >= WARDROBE_SEARCH_DELAY ) then
		self:SetScript("OnUpdate", nil);
		self.updateDelay = 0;
		
		if ( not C_TransmogCollection.IsSearchDBLoading() ) then
			WardrobeCollectionFrame.searchProgressFrame.loading:Hide();
			WardrobeCollectionFrame.searchProgressFrame.searchProgressBar:Show();
			WardrobeCollectionFrame.searchProgressFrame.searchProgressBar:SetScript("OnUpdate", WardrobeCollectionFrameSearchProgressBar_OnUpdate);
		else
			WardrobeCollectionFrame.searchProgressFrame.loading:Show();
			WardrobeCollectionFrame.searchProgressFrame.searchProgressBar:Hide();
		end
		
		WardrobeCollectionFrame.searchProgressFrame:Show();
	end
end

function WardrobeCollectionFrameSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	
	local text = self:GetText();
	if ( text == "" ) then
		C_TransmogCollection.ClearSearch();
	else
		C_TransmogCollection.SetSearch(WardrobeCollectionFrame.activeCategory, text);
	end
	
	WardrobeCollectionFrame_RestartSearchTracking();
end

-- ***** FILTER

function WardrobeFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeFilterDropDown_Initialize, "MENU");
end

function WardrobeFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	local atTransmogrifier = WardrobeFrame_IsAtTransmogrifier();

	if level == 1 and not atTransmogrifier then
		info.text = COLLECTED
		info.func = function(_, _, _, value)
						C_TransmogCollection.SetCollectedShown(value);
					end 
		info.checked = C_TransmogCollection.GetCollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
						C_TransmogCollection.SetUncollectedShown(value);
					end 
		info.checked = C_TransmogCollection.GetUncollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = SOURCES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
	else
		if level == 2 or atTransmogrifier then
			local refreshLevel = atTransmogrifier and 1 or 2;
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL
			info.func = function()
							C_TransmogCollection.SetAllSourceTypeFilters(true);
							UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_TransmogCollection.SetAllSourceTypeFilters(false);
							UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
						end
			UIDropDownMenu_AddButton(info, level)
			info.notCheckable = false;

			local numSources = C_TransmogCollection.GetNumTransmogSources();
			for i = 1, numSources do
				info.text = _G["TRANSMOG_SOURCE_"..i];
				info.func = function(_, _, _, value)
							C_TransmogCollection.SetSourceTypeFilter(i, value);
						end
				info.checked = function() return not C_TransmogCollection.IsSourceTypeFilterChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

-- ***** SPEC DROPDOWN

function WardrobeTransmogFrameSpecDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeTransmogFrameSpecDropDown_Initialize, "MENU");
end

function WardrobeTransmogFrameSpecDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = TRANSMOG_APPLY_TO;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();

	local currentSpecOnly = GetCVarBool("transmogCurrentSpecOnly");

	info.text = TRANSMOG_ALL_SPECIALIZATIONS;
	info.func = WardrobeTransmogFrameSpecDropDown_OnClick;
	info.checked = not currentSpecOnly;
	info.value = 0;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	info.text = TRANSMOG_CURRENT_SPECIALIZATION;
	info.func = WardrobeTransmogFrameSpecDropDown_OnClick;
	info.checked = currentSpecOnly;
	info.value = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	local spec = GetSpecialization();
	local _, name = GetSpecializationInfo(spec);
	info.text = format(PARENS_TEMPLATE, name);
	info.leftPadding = 16;
	info.notCheckable = true;
	info.notClickable = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function WardrobeTransmogFrameSpecDropDown_OnClick(self)
	SetCVar("transmogCurrentSpecOnly", self.value == 1);
end