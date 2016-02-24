
local NO_SOURCE_ID = 0;
local NO_VISUAL_ID = 0;
local REMOVE_TRANSMOG_ID = 0;

-- ************************************************************************************************************************************************************
-- **** MAIN **********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeFrame_OnLoad(self)
	SetPortraitToTexture(WardrobeFramePortrait, "Interface\\Icons\\INV_Arcane_Orb");
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
	self.Inset.TopDesatBG:SetDesaturated(true);
	self.Inset.BottomDesatBG:SetDesaturated(true);
	
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
		end
		StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
		WardrobeTransmogFrame_Update(self);
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		C_Transmog.ValidateAllPending();
	elseif ( event == "TRANSMOGRIFY_SUCCESS" ) then
		local slotID, transmogType = ...;
		local slotButton = WardrobeTransmogFrame_GetSlotButton(slotID, transmogType);
		if ( slotButton ) then
			WardrobeTransmogFrame_AnimateSlotButton(slotButton);
			WardrobeTransmogFrame_UpdateSlotButton(slotButton);
			WardrobeTransmogFrame_UpdateApplyButton();
		end
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" ) then
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
	PlaySound("UI_EtherealWindow_Open");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterEvent("UNIT_MODEL_CHANGED");
		self.inAlternateForm = inAlternateForm;
	end
	WardrobeTransmogFrame.Model:SetUnit("player");
	Model_Reset(WardrobeTransmogFrame.Model);
	
	-- select the same slot as in the collection frame
	for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
		if ( WardrobeTransmogFrame.Model.SlotButtons[i].slot == WardrobeCollectionFrame.activeSlot and WardrobeTransmogFrame.Model.SlotButtons[i].transmogType == WardrobeCollectionFrame.transmogType ) then
			WardrobeTransmogButton_Select(WardrobeTransmogFrame.Model.SlotButtons[i]);
			break;
		end
	end

	WardrobeTransmogFrame_Update(self);
end

function WardrobeTransmogFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	C_Transmog.Close();
end

function WardrobeTransmogFrame_Update()
	for i = 1, #WardrobeTransmogFrame.Model.SlotButtons do
		WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.Model.SlotButtons[i]);
	end
	WardrobeTransmogFrame_UpdateWeaponModel("MAINHANDSLOT");
	WardrobeTransmogFrame_UpdateWeaponModel("SECONDARYHANDSLOT");
	WardrobeTransmogFrame_UpdateApplyButton();
end

function WardrobeTransmogFrame_UpdateSlotButton(slotButton)
	local slotID, defaultTexture = GetInventorySlotInfo(slotButton.slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, texture = C_Transmog.GetSlotInfo(slotID, slotButton.transmogType);
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
		if ( canTransmogrify ) then
			slotButton.Icon:SetTexture(texture);
			slotButton.NoItemTexture:Hide();
		else
			slotButton.Icon:SetTexture(defaultTexture);
			if ( hasUndo ) then
				slotButton.NoItemTexture:Hide();
			else
				slotButton.NoItemTexture:Show();
			end
		end
	else
		slotButton.Icon:SetTexture(texture or ENCHANT_EMPTY_SLOT_FILEDATAID);
	end

	-- desaturate icon if it's not transmogrified
	if ( isTransmogrified or hasPending ) then
		slotButton.Icon:SetDesaturated(false);
	else
		slotButton.Icon:SetDesaturated(true);
	end

	-- show transmogged border if the item is transmogrified and doesn't have a pending transmogrification or is animating
	if ( hasPending ) then
		if ( isPendingCollected or hasUndo ) then
			WardrobeTransmogButton_SetStatusBorder(slotButton, "PINK");
		else
			WardrobeTransmogButton_SetStatusBorder(slotButton, "RED");
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

	local showModel = (slotButton.transmogType == LE_TRANSMOG_TYPE_APPEARANCE);
	if ( slotButton.slot == "MAINHANDSLOT" or slotButton.slot == "SECONDARYHANDSLOT" ) then
		-- weapons get done in WardrobeTransmogFrame_UpdateWeaponModel to package item and enchant together
		showModel = false;
	end
	if ( showModel ) then
		local sourceID = WardrobeTransmogFrame_GetDisplayedSource(slotButton);
		if ( sourceID == NO_SOURCE_ID ) then
			WardrobeTransmogFrame.Model:UndressSlot(slotID);			
		else
			WardrobeTransmogFrame.Model:TryOn(sourceID);
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
	if ( appearanceSourceID ~= NO_SOURCE_ID ) then
		local illusionSourceID = WardrobeTransmogFrame_GetDisplayedSource(enchantSlotButton);
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		-- don't specify a slot for ranged weapons
		if ( WardrobeCollectionFrame_IsCategoryRanged(categoryID) ) then
			slot = nil;
		end
		WardrobeTransmogFrame.Model:TryOn(appearanceSourceID, slot, illusionSourceID);
	end	
end

function WardrobeTransmogFrame_GetDisplayedSource(slotButton)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(slotButton.slot), slotButton.transmogType);
	if ( pendingSourceID ~= REMOVE_TRANSMOG_ID ) then
		return pendingSourceID;
	elseif ( hasPendingUndo or appliedSourceID == NO_SOURCE_ID ) then
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
	MoneyFrame_Update("WardrobeTransmogMoneyFrame", cost);
	if ( canApply ) then
		WardrobeTransmogFrame.ApplyButton:Enable();
	else
		WardrobeTransmogFrame.ApplyButton:Disable();
	end
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
		return false;
	end
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
			C_Transmog.ClearPending(slotID, self.transmogType);
		elseif ( isTransmogrified ) then
			C_Transmog.SetPending(slotID, self.transmogType, 0);
		end
	else
		WardrobeTransmogButton_Select(self);
	end
	self.UndoIcon:Hide();
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
		if ( isTransmogrified and not ( hasPending or hasUndo ) ) then
			self.UndoIcon:Show();
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 14, 0);
		if ( not canTransmogrify ) then
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
		elseif ( hasPending and not isPendingCollected ) then
			GameTooltip:SetText(_G[self.slot]);
			GameTooltip:AddLine(TRANSMOGRIFY_STYLE_UNCOLLECTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
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
	self.UndoIcon:Hide();
	WardrobeTransmogFrame.Model.controlFrame:Hide();
	GameTooltip:Hide();
end

function WardrobeTransmogButton_Select(button)
	if ( WardrobeTransmogFrame.selectedSlotButton ) then
		WardrobeTransmogFrame.selectedSlotButton.SelectedTexture:Hide();
	end
	button.SelectedTexture:Show();
	WardrobeTransmogFrame.selectedSlotButton = button;
	WardrobeCollectionFrame_SetActiveSlot(button.slot, button.transmogType);
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
local MODEL_ANIM_STOP = 3;

-- ************************************************************************************************************************************************************
-- **** START STUB/TEMP ***************************************************************************************************************************************
-- ************************************************************************************************************************************************************

COLLECTION_CAMERA = {
	[LE_TRANSMOG_COLLECTION_TYPE_HEAD] = { zoom = 1, rotation = 0.61, x = 2.9, y = 0, z = -0.75, cameraID = 98 },
	[LE_TRANSMOG_COLLECTION_TYPE_SHOULDER] = { zoom = 1, rotation = 0, x = 2.8, y = 0.35, z = -0.5, cameraID = 119 },
	[LE_TRANSMOG_COLLECTION_TYPE_BACK] = { zoom = 1, rotation = 3, x = 2.5, y = 0, z = -0.3, cameraID = 88 },
	[LE_TRANSMOG_COLLECTION_TYPE_CHEST] = { zoom = 1, rotation = 0, x = 2.5, y = 0, z = -0.3, cameraID = 88 },
	[LE_TRANSMOG_COLLECTION_TYPE_SHIRT] = { zoom = 1, rotation = 0, x = 2.5, y = 0, z = -0.3, cameraID = 88 },
	[LE_TRANSMOG_COLLECTION_TYPE_TABARD] = { zoom = 1, rotation = 0, x = 2.5, y = 0, z = -0.3, cameraID = 88 },
	[LE_TRANSMOG_COLLECTION_TYPE_WRIST] = { zoom = 1, rotation = 0.6, x = 2.7, y = 0.4, z = 0, cameraID = 90 },
	[LE_TRANSMOG_COLLECTION_TYPE_HANDS] = { zoom = 1, rotation = 0.6, x = 2.4, y = 0.4, z = 0.2, cameraID = 90 },
	[LE_TRANSMOG_COLLECTION_TYPE_WAIST] = { zoom = 1, rotation = 0, x = 2.7, y = 0, z = 0.05, cameraID = 90 },
	[LE_TRANSMOG_COLLECTION_TYPE_LEGS] = { zoom = 1, rotation = 0, x = 1.8, y = 0, z = 0.5, cameraID = 94 },	
	[LE_TRANSMOG_COLLECTION_TYPE_FEET] = { zoom = 1, rotation = 0, x = 2.2, y = 0, z = 0.9, cameraID = 94 },
	-- weapons
	[LE_TRANSMOG_COLLECTION_TYPE_FIST] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_WAND] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_1H_AXE] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_1H_SWORD] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_1H_MACE] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_DAGGER] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_SHIELD] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_HOLDABLE] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 161 },
	[LE_TRANSMOG_COLLECTION_TYPE_2H_AXE] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_2H_SWORD] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_2H_MACE] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_STAFF] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_POLEARM] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_BOW] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_GUN] = { zoom = 1, rotation = 1, x = 0.3, y = 0, z = -.4, cameraID = 185 },
	[LE_TRANSMOG_COLLECTION_TYPE_CROSSBOW] = { zoom = 1, rotation = 1, x = 1, y = -0.05, z = .5, cameraID = 185 },
	["BASE"] = { zoom = 1, rotation = 0, x = 0, y = 0, z = 0, cameraID = 98 },
}

local ARMOR_SLOTS = {
	[LE_TRANSMOG_COLLECTION_TYPE_HEAD] = "HEADSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_SHOULDER] = "SHOULDERSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_BACK] = "BACKSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_CHEST] = "CHESTSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_TABARD] = "TABARDSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_SHIRT] = "SHIRTSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_WRIST] = "WRISTSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_HANDS] = "HANDSSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_WAIST] = "WAISTSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_LEGS] = "LEGSSLOT",
	[LE_TRANSMOG_COLLECTION_TYPE_FEET] = "FEETSLOT",
};

local HIDE_VISUAL_STRINGS = {
	["HEADSLOT"] = TRANSMOG_HIDE_HELM,
	["SHOULDERSLOT"] = TRANSMOG_HIDE_SHOULDERS,
	["BACKSLOT"] = TRANSMOG_HIDE_CLOAK,
}

local WARDROBE_MODEL_SETUP = {
	[LE_TRANSMOG_COLLECTION_TYPE_HEAD] 		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_SHOULDER]	= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_BACK]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_CHEST]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_TABARD]	= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_SHIRT]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_WRIST]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_HANDS]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_WAIST]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_LEGS]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false } },
	[LE_TRANSMOG_COLLECTION_TYPE_FEET]		= { useTransmogSkin = false, slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = false } },
}

local WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 78420,
	["LEGSSLOT"] = 78425,
	["FEETSLOT"] = 78427,
	["HANDSSLOT"] = 78426,
}

local function TEMP_GetMaxPages()
	return ceil(#WardrobeCollectionFrame.filteredVisualsList / WARDROBE_PAGE_SIZE);
end

local function TEMP_SetCurrentPage(page)
	CloseDropDownMenus();
	CURRENT_PAGE = page;
end

local function TEMP_GetCurrentPage()
	return CURRENT_PAGE;
end

local function TEMP_UpdateProgressBar(collection)
	local collected, total;
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		collected = #WardrobeCollectionFrame.visualsList;
		total = collected;
	else
		collected = C_TransmogCollection.GetCategoryCollectedCount(WardrobeCollectionFrame.activeCategory);
		total = C_TransmogCollection.GetCategoryTotal(WardrobeCollectionFrame.activeCategory);
	end
	WardrobeCollectionFrame.progressBar:SetMinMaxValues(0, total);
	WardrobeCollectionFrame.progressBar:SetValue(collected);
	WardrobeCollectionFrame.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, collected, total);
end

local function TEMP_CanTitanGrip()
	local specIndex = GetSpecialization();
	if ( specIndex ) then
		local specID = GetSpecializationInfo(specIndex);
		if ( specID == 72 ) then
			return true;
		end
	end
	return false;
end

-- ************************************************************************************************************************************************************
-- ***** END STUB/TEMP ****************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeCollectionFrame_SetContainer(parent)
	local collectionFrame = WardrobeCollectionFrame;
	collectionFrame:SetParent(parent);
	collectionFrame:ClearAllPoints();
	collectionFrame:Show();
	if ( parent == CollectionsJournal ) then
		collectionFrame:SetPoint("TOPLEFT", CollectionsJournal);
		collectionFrame:SetPoint("BOTTOMRIGHT", CollectionsJournal);
		collectionFrame.ModelsFrame.ModelR1C1:SetPoint("TOP", -238, -84);
		collectionFrame.ModelsFrame.SlotsFrame:Show();
		collectionFrame.ModelsFrame.BGCornerTopLeft:Hide();
		collectionFrame.ModelsFrame.BGCornerTopRight:Hide();
		collectionFrame.ModelsFrame.WeaponDropDown:SetPoint("TOPRIGHT", -6, -22);
		collectionFrame.progressBar:SetWidth(196);
	elseif ( parent == WardrobeFrame ) then
		collectionFrame:SetPoint("TOPRIGHT", 0, 0);
		collectionFrame:SetSize(662, 606);
		collectionFrame.ModelsFrame.ModelR1C1:SetPoint("TOP", -238, -70);
		collectionFrame.ModelsFrame.SlotsFrame:Hide();
		collectionFrame.ModelsFrame.BGCornerTopLeft:Show();
		collectionFrame.ModelsFrame.BGCornerTopRight:Show();
		collectionFrame.ModelsFrame.WeaponDropDown:SetPoint("TOPRIGHT", -32, -25);
		collectionFrame.progressBar:SetWidth(437);
	end
end

function WardrobeCollectionFrame_OnLoad(self)
	WardrobeCollectionFrame_CreateSlotButtons();
	self.ModelsFrame.BGCornerTopLeft:Hide();
	self.ModelsFrame.BGCornerTopRight:Hide();
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_misc_enggizmos_19");
	
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("APPEARANCE_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");

	self.categoriesList = C_TransmogCollection.GetCategories();
	-- create an enchants category at the end
	FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT = NUM_LE_TRANSMOG_COLLECTION_TYPES + 1;
	local illusions = C_TransmogCollection.GetIllusions();
	self.categoriesList[FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT] = { count = #illusions, isEnchant = true };

	WardrobeCollectionFrame_UpdateCategoriesHandInfo();
	self.updateCameraIDs = true;

	self.newTransmogs = UIParent.newTransmogs or {};
	UIParent.newTransmogs = nil;

	UIDropDownMenu_Initialize(self.ModelsFrame.RightClickDropDown, nil, "MENU");
	self.ModelsFrame.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;
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
		WardrobeCollectionFrame_UpdateCategoriesHandInfo();
		WardrobeCollectionFrame_UpdateWeaponDropDown();
		WardrobeCollectionFrame_FilterVisuals();
		WardrobeCollectionFrame_SortVisuals();
		TEMP_SetCurrentPage(1);
		WardrobeCollectionFrame_Update();
	elseif ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" or event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slotID = ...;
		if ( slotID and WardrobeCollectionFrame.activeCategory ~= FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
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
		local cameraSettings = COLLECTION_CAMERA[self.activeCategory] or COLLECTION_CAMERA["BASE"];
		local cameraID = self.categoriesList[self.activeCategory].cameraID or cameraSettings.cameraID;
		for i = 1, #self.ModelsFrame.Models do
			Model_ApplyUICamera(self.ModelsFrame.Models[i], cameraID);
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED") then
		local categoryID, sourceID, visualID, new = ...;
		if ( new ) then
			self.newTransmogs[visualID] = true;
		end
		if ( self:IsVisible() and categoryID == self.activeCategory ) then
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
		self.updateCameraIDs = true;
		end
end

function WardrobeCollectionFrame_OnShow(self)
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");

	if ( self.updateCameraIDs ) then
		for i = 1, #self.categoriesList do
			self.categoriesList[i].cameraID = C_TransmogCollection.GetCategoryCamera(i);
		end
	end

	if ( WardrobeCollectionFrame.activeCategory ) then
		-- redo the model for the active category
		WardrobeCollectionFrame_ChangeModelsSlot(nil, WardrobeCollectionFrame.activeCategory);
	else
		WardrobeCollectionFrame_SetActiveSlot("HEADSLOT", LE_TRANSMOG_TYPE_APPEARANCE);
	end

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_chest_cloth_17");
	WardrobeCollectionFrame_UpdateWeaponDropDown();
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	WardrobeCollectionFrame_ClearSearch();
	C_TransmogCollection.EndSearch();
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

			local currentPage = TEMP_GetCurrentPage();
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
		WardrobeCollectionFrame_ResetPage();
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function WardrobeCollectionFrame_ChangeModelsSlot(oldCategory, newCategory)
	local undressSlot, reloadModel;
	if ( WardrobeCollectionFrame.categoriesList[newCategory].isArmor ) then
		if ( oldCategory and WardrobeCollectionFrame.categoriesList[oldCategory].isArmor ) then
			if ( WARDROBE_MODEL_SETUP[oldCategory].useTransmogSkin ~= WARDROBE_MODEL_SETUP[newCategory].useTransmogSkin ) then
				reloadModel = true;
			else
				undressSlot = true;
			end
		else
			reloadModel = true;
		end
	end
	local cameraSettings = COLLECTION_CAMERA[newCategory] or COLLECTION_CAMERA["BASE"];
	local cameraID = WardrobeCollectionFrame.categoriesList[newCategory].cameraID or cameraSettings.cameraID;
	for i = 1, #WardrobeCollectionFrame.ModelsFrame.Models do
		local model = WardrobeCollectionFrame.ModelsFrame.Models[i];
		if ( undressSlot ) then
			local changedOldSlot = false;
			-- dress/undress setup gear
			for slot, equip in pairs(WARDROBE_MODEL_SETUP[newCategory].slots) do
				if ( equip ~= WARDROBE_MODEL_SETUP[oldCategory].slots[slot] ) then
					if ( equip ) then
						model:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
					else
						model:UndressSlot(GetInventorySlotInfo(slot));
					end
					if ( slot == ARMOR_SLOTS[oldCategory] ) then
						changedOldSlot = true;
					end
				end
			end
			-- undress old slot
			if ( not changedOldSlot ) then
				local slotID = GetInventorySlotInfo(ARMOR_SLOTS[oldCategory]);
				model:UndressSlot(slotID);
			end
		elseif ( reloadModel ) then
			model:SetUseTransmogSkin(WARDROBE_MODEL_SETUP[newCategory].useTransmogSkin);
			model:SetUnit("player");
			model:SetAnimation(MODEL_ANIM_STOP);
			model:Undress();
			for slot, equip in pairs(WARDROBE_MODEL_SETUP[newCategory].slots) do
				if ( equip ) then
					model:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
				end
			end
		end
		model.visualInfo = nil;
		Model_ApplyUICamera(model, cameraID);
	end
	WardrobeCollectionFrame.illusionWeaponVisualID = nil;
end

function WardrobeCollectionFrame_UpdateCategoriesHandInfo()
	local categoriesList = WardrobeCollectionFrame.categoriesList;
	local canDualWield = CanDualWield() or HasIgnoreDualWieldWeapon();
	local canTitanGrip = TEMP_CanTitanGrip();

	for index = 1, #categoriesList do
		if ( categoriesList[index].count > 0 and categoriesList[index].isWeapon ) then
			if ( index == LE_TRANSMOG_COLLECTION_TYPE_HOLDABLE or index == LE_TRANSMOG_COLLECTION_TYPE_SHIELD ) then
				categoriesList[index].canMainHand = false;
				categoriesList[index].canOffHand = true;
				categoriesList[index].isTwoHanded = false;
			elseif ( index == LE_TRANSMOG_COLLECTION_TYPE_FIST or index == LE_TRANSMOG_COLLECTION_TYPE_1H_AXE or index == LE_TRANSMOG_COLLECTION_TYPE_1H_SWORD or
					 index == LE_TRANSMOG_COLLECTION_TYPE_1H_MACE or index == LE_TRANSMOG_COLLECTION_TYPE_DAGGER or index == LE_TRANSMOG_COLLECTION_TYPE_WARGLAIVES ) then
				categoriesList[index].canMainHand = true;
				categoriesList[index].canOffHand = canDualWield;
				categoriesList[index].isTwoHanded = false;
			else
				categoriesList[index].canMainHand = true;
				if ( WardrobeCollectionFrame_IsCategoryRanged(index) ) then
					categoriesList[index].canOffHand = false;
				else
					categoriesList[index].canOffHand = canTitanGrip;
				end
				categoriesList[index].isTwoHanded = true;
			end
		end
	end
end

function WardrobeCollectionFrame_IsCategoryForEitherHand(category)
	return WardrobeCollectionFrame.categoriesList[category].canMainHand and WardrobeCollectionFrame.categoriesList[category].canOffHand;
end

function WardrobeCollectionFrame_IsCategoryForOffHand(category)
	return WardrobeCollectionFrame.categoriesList[category].canOffHand;
end

function WardrobeCollectionFrame_IsCategoryForMainHand(category)
	return WardrobeCollectionFrame.categoriesList[category].canMainHand;
end

function WardrobeCollectionFrame_IsCategoryTwoHanded(category)
	return WardrobeCollectionFrame.categoriesList[category].isTwoHanded;
end

function WardrobeCollectionFrame_IsCategoryRanged(category)
	return (category == LE_TRANSMOG_COLLECTION_TYPE_BOW) or (category == LE_TRANSMOG_COLLECTION_TYPE_GUN) or (category == LE_TRANSMOG_COLLECTION_TYPE_CROSSBOW);
end

function WardrobeCollectionFrame_SetActiveSlot(slot, transmogType)
	local previousSlot = WardrobeCollectionFrame.activeSlot;
	WardrobeCollectionFrame.activeSlot = slot;
	WardrobeCollectionFrame.transmogType = transmogType;
	local category;
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
	if ( selectedSourceID ~= NO_SOURCE_ID ) then
		category = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
	end
	if ( slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT" ) then
		if ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			category = FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT;
		else
			-- if no valid selection, find the first valid weapon category
			if ( not category ) then
				for i = 1, #WardrobeCollectionFrame.categoriesList do
					if ( WardrobeCollectionFrame.categoriesList[i].isWeapon ) then
						if ( (slot == "MAINHANDSLOT" and WardrobeCollectionFrame_IsCategoryForMainHand(i))	or (slot == "SECONDARYHANDSLOT" and WardrobeCollectionFrame_IsCategoryForOffHand(i)) ) then
							category = i;
							break;
						end
					end
				end
			end
		end
	elseif ( not category ) then
		-- couldn't get category from appearance, find by slot
		for armorCategory, armorSlot in pairs(ARMOR_SLOTS) do
			if ( armorSlot == slot ) then
				category = armorCategory;
				break;
			end
		end
	end
	-- set only if category is different or slot is different
	if ( category ~= WardrobeCollectionFrame.activeCategory or slot ~= previousSlot ) then
		WardrobeCollectionFrame_SetActiveCategory(category);
	end
end

function WardrobeCollectionFrame_UpdateWeaponDropDown()
	local dropdown = WardrobeCollectionFrame.ModelsFrame.WeaponDropDown;
	if ( not WardrobeCollectionFrame.categoriesList[WardrobeCollectionFrame.activeCategory].isWeapon ) then
		if ( WardrobeFrame_IsAtTransmogrifier() ) then
			WardrobeCollectionFrame.ModelsFrame.WeaponDropDown:Hide();
		else
			WardrobeCollectionFrame.ModelsFrame.WeaponDropDown:Show();
			UIDropDownMenu_DisableDropDown(dropdown);
			UIDropDownMenu_SetText(dropdown, "");
		end
	else
		WardrobeCollectionFrame.ModelsFrame.WeaponDropDown:Show();
		UIDropDownMenu_SetSelectedValue(dropdown, WardrobeCollectionFrame.activeCategory);
		UIDropDownMenu_SetText(dropdown, WardrobeCollectionFrame.categoriesList[WardrobeCollectionFrame.activeCategory].name);
		local validCategories = WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if ( validCategories > 1 ) then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	end
end

function WardrobeCollectionFrame_SetActiveCategory(category)
	WardrobeCollectionFrame_ChangeModelsSlot(WardrobeCollectionFrame.activeCategory, category);
	WardrobeCollectionFrame.activeCategory = category;
	if ( WardrobeCollectionFrame.activeCategory ~= FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		C_TransmogCollection.SetFilterCategory(category);
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
	WardrobeCollectionFrame_ResetPage();
	WardrobeCollectionFrame_SwitchSearchCategory();
end

function WardrobeCollectionFrame_ResetPage()
	local page = 1;
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
	if ( WardrobeCollectionFrame.linkedVisualID ) then
		selectedVisualID = WardrobeCollectionFrame.linkedVisualID;
		WardrobeCollectionFrame.linkedVisualID = nil;
	end
	if ( selectedVisualID ~= NO_VISUAL_ID ) then
		for i = 1, #WardrobeCollectionFrame.filteredVisualsList do
			if ( WardrobeCollectionFrame.filteredVisualsList[i].visualID == selectedVisualID ) then
				page = floor((i-1) / WARDROBE_PAGE_SIZE) + 1;
				break;
			end
		end
	end
	TEMP_SetCurrentPage(page);
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFrame_FilterVisuals()
	local category = WardrobeCollectionFrame.categoriesList[WardrobeCollectionFrame.activeCategory];

	-- This only applies to 1h weapons
	local ignoreInvType;
	if ( category.isWeapon and not category.isTwoHanded and not TEMP_CanTitanGrip() ) then
		ignoreInvType = (WardrobeCollectionFrame.activeSlot == "MAINHANDSLOT") and OFF_HAND_INV_TYPE or MAIN_HAND_INV_TYPE;
	end

	local visualsList = WardrobeCollectionFrame.visualsList;
	local filteredVisualsList = { };
	for i = 1, #visualsList do
		if ( not visualsList[i].invType or visualsList[i].invType ~= ignoreInvType ) then
			tinsert(filteredVisualsList, visualsList[i]);
		end
	end
	WardrobeCollectionFrame.filteredVisualsList = filteredVisualsList;
end

function WardrobeCollectionFrame_SortVisuals()
	local comparison = function(source1, source2)
		if ( source1.isCollected ~= source2.isCollected ) then
			return source1.isCollected;
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
	if ( appliedSourceID == NO_SOURCE_ID ) then
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
		local _, appearanceVisualID, canEnchant, cameraID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		if ( canEnchant ) then
			return appearanceSourceID, appearanceVisualID, cameraID;
		end
	end

	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetInfoForSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
	local _, _, canEnchant, cameraID = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
	if ( canEnchant ) then
		return selectedSourceID, selectedVisualID, cameraID;
	else
		local appearanceSourceID = C_TransmogCollection.GetIllusionFallbackWeaponSource();
		local _, appearanceVisualID, _, cameraID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID, cameraID;
	end
end

function WardrobeCollectionFrame_Update()
	local isArmor = WardrobeCollectionFrame.categoriesList[WardrobeCollectionFrame.activeCategory].isArmor;
	local cameraID;
	local appearanceVisualID;	-- for weapon when looking at enchants
	local changeModel = false;
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		-- for enchants we need to get the visual of the item in that slot
		local appearanceSourceID;
		appearanceSourceID, appearanceVisualID, cameraID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(WardrobeCollectionFrame.activeSlot);
		if ( appearanceVisualID ~= WardrobeCollectionFrame.illusionWeaponVisualID ) then
			WardrobeCollectionFrame.illusionWeaponVisualID = appearanceVisualID;
			changeModel = true;
		end
	else
		local activeCategory = WardrobeCollectionFrame.activeCategory;
		local cameraSettings = COLLECTION_CAMERA[activeCategory] or COLLECTION_CAMERA["BASE"];
		cameraID = WardrobeCollectionFrame.categoriesList[activeCategory].cameraID or cameraSettings.cameraID;
	end

	if ( TEMP_GetCurrentPage() > TEMP_GetMaxPages() ) then
		TEMP_SetCurrentPage(TEMP_GetMaxPages());
	elseif ( TEMP_GetCurrentPage() < 1 and TEMP_GetMaxPages() > 0 ) then
		TEMP_SetCurrentPage(1);
	end

	local showOverlayTextures = WardrobeFrame_IsAtTransmogrifier();
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
	for i = 1, WARDROBE_PAGE_SIZE do
		local model = WardrobeCollectionFrame.ModelsFrame.Models[i];
		local index = i + (TEMP_GetCurrentPage() - 1) * WARDROBE_PAGE_SIZE;
		local visualInfo = WardrobeCollectionFrame.filteredVisualsList[index];
		if ( visualInfo ) then
			model:SetAlpha(1);
			model.cameraID = cameraID;
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
			if ( visualInfo.isCollected ) then
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
			else
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			end
			if ( showOverlayTextures ) then
				model.AppliedTexture:SetShown(visualInfo.visualID == appliedVisualID);
				model.SelectedTexture:SetShown(visualInfo.visualID == selectedVisualID);
			else
				model.AppliedTexture:Hide();
				model.SelectedTexture:Hide();
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
			-- If this mouse is over this model when it is alphaed out then we hide the tooltip.
			-- If the mouse is still over this model after we alpha in, it should be shown.
			if ( model:IsMouseOver() ) then
				WardrobeCollectionFrameModel_OnEnter(model);
			end
		else
			model:SetAlpha(0);
			model.visualInfo = nil;
			
			if ( GameTooltip:GetOwner() == model ) then
				GameTooltip:Hide();
			end
		end
	end
	-- navigation buttons
	WardrobeCollectionFrame_UpdateNavigationButtons();
	-- progress bar
	TEMP_UpdateProgressBar(WardrobeCollectionFrame.filteredVisualsList);
end

function WardrobeCollectionFrame_UpdateNavigationButtons()
	WardrobeCollectionFrame.NavigationFrame.PageText:SetFormattedText(COLLECTION_PAGE_NUMBER, TEMP_GetCurrentPage(), TEMP_GetMaxPages());
	if ( TEMP_GetCurrentPage() <= 1 ) then
		WardrobeCollectionFrame.NavigationFrame.PrevPageButton:Disable();
	else
		WardrobeCollectionFrame.NavigationFrame.PrevPageButton:Enable();
	end
	if ( TEMP_GetCurrentPage() == TEMP_GetMaxPages() ) then
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
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
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
		local slot = ARMOR_SLOTS[categoryID];
		if ( not slot ) then
			if ( WardrobeCollectionFrame.categoriesList[categoryID].canMainHand ) then
				slot = "MAINHANDSLOT";
			else
				slot = "SECONDARYHANDSLOT";
			end
		end
		WardrobeCollectionFrame.linkedVisualID = visualID;
		WardrobeCollectionFrame_SetActiveSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
		WardrobeCollectionFrame_SetActiveCategory(categoryID);
	end
end

-- ***** MODELS

function WardrobeCollectionFrameModel_OnLoad(self)
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	
	local lightValues = { enabled=1, omni=0, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.05, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
	self:SetLight(lightValues.enabled, lightValues.omni, 
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
			lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);
end

function WardrobeCollectionFrameModel_OnEvent(self)
	self:RefreshCamera();
	WardrobeCollectionFrameModel_ApplyCamera(self);
end

function WardrobeCollectionFrameModel_OnModelLoaded(self)
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeCollectionFrameModel_OnMouseDown(self, button)
	if ( self:GetAlpha() == 0 ) then
		return;
	end
	
	if ( IsModifiedClick("CHATLINK") ) then
		local link;
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			link = select(3, C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID));
		else
			local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID);
			local offset = WardrobeCollectionFrame.tooltipIndexOffset;
			if ( offset < 0 ) then
				offset = #sources + offset;
			end
			local index = mod(offset, #sources) + 1;
			link = select(7, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
		end
		HandleModifiedItemClick(link);
		return;
	elseif ( IsModifiedClick("DRESSUP") ) then
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local sourceID = WardrobeCollectionFrame_GetAnAppearanceSourceFromVisual(self.visualInfo.visualID);
			DressUpVisual(sourceID, WardrobeCollectionFrame.activeSlot);
		elseif ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			local weaponSourceID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(WardrobeCollectionFrame.activeSlot);
			DressUpVisual(weaponSourceID, WardrobeCollectionFrame.activeSlot, self.visualInfo.sourceID);
		end
		return;
	end

	if ( button == "LeftButton" ) then
		WardrobeCollectionFrame_SelectVisual(self.visualInfo.visualID);
	elseif ( button == "RightButton" and self.visualInfo.isCollected ) then
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			-- TODO: anything for enchants?
			return;
		end
		local dropDown = WardrobeCollectionFrame.ModelsFrame.RightClickDropDown;
		if ( dropDown.activeFrame ~= self ) then
			CloseDropDownMenus();
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
	if ( WardrobeCollectionFrame.newTransmogs[self.visualInfo.visualID] ) then
		WardrobeCollectionFrame.newTransmogs[self.visualInfo.visualID] = nil;
		self.NewString:Hide();
		self.NewGlow:Hide();
	end
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		local visualID, name = C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name);
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
	WardrobeCollectionFrame.tooltipAppearanceID = nil;
	WardrobeCollectionFrame.tooltipCycle = nil;
	WardrobeCollectionFrame.tooltipIndexOffset = nil;
	GameTooltip:Hide();
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
	if ( sources[headerIndex].sourceType == TRANSMOG_SOURCE_BOSS_DROP and not sources[headerIndex].isCollected ) then
		local drops = C_TransmogCollection.GetAppearanceSourceDrops(headerSourceID);
		if ( drops ) then
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
end

-- ***** WEAPON DROPDOWN

function WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameWeaponDropDown_Init(self)
	local categoriesList = WardrobeCollectionFrame.categoriesList;
	if ( not categoriesList ) then
		return;
	end

	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = WardrobeCollectionFrameWeaponDropDown_OnClick;

	local slot = WardrobeCollectionFrame.activeSlot;
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
	
	for categoryID = 1, #categoriesList do
		if ( categoriesList[categoryID].count > 0 and categoriesList[categoryID].isWeapon ) then
			if ( slot == "MAINHANDSLOT" and WardrobeCollectionFrame_IsCategoryForMainHand(categoryID) or
				 slot == "SECONDARYHANDSLOT" and WardrobeCollectionFrame_IsCategoryForOffHand(categoryID) ) then
				 if ( not checkCategory or C_TransmogCollection.IsCategoryValidForItem(categoryID, equippedItemID) ) then
					info.text = categoriesList[categoryID].name;
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
	WardrobeCollectionFrame_SetPage(TEMP_GetCurrentPage() - 1);
end

function WardrobeCollectionFrame_NextPage()
	WardrobeCollectionFrame_SetPage(TEMP_GetCurrentPage() + 1);
end

function WardrobeCollectionFrame_SetPage(page)
	page = math.min(TEMP_GetMaxPages(), math.max(page, 1));
	if ( TEMP_GetCurrentPage() ~= page ) then
		TEMP_SetCurrentPage(page);
		PlaySound("igAbiliityPageTurn");
		WardrobeCollectionFrame_Update();
	end	
end

-- ***** SEARCHING

function WardrobeCollectionFrame_SwitchSearchCategory()
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
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
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFrame_RestartSearchTracking()
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
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

	if level == 1 then
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
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL
			info.func = function()
							C_TransmogCollection.SetAllSourceTypeFilters(true);
							UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, 2);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_TransmogCollection.SetAllSourceTypeFilters(false);
							UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, 2);
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

-- ***** OUTFITS

function WardrobeOutfitDropDown_OnLoad(self)
	local button = _G[self:GetName().."Button"];
	button:SetScript("OnClick", WardrobeOutfitDropDown_OnClick);
	UIDropDownMenu_JustifyText(self, "LEFT");
	UIDropDownMenu_SetWidth(self, 188);
end

function WardrobeOutfitDropDown_OnShow(self)
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
	WardrobeOutfitDropDown_SelectOutfit(nil);
end

function WardrobeOutfitDropDown_OnHide(self)
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOG_OUTFITS_CHANGED");
	WardrobeOutfitFrame:Hide();
end

function WardrobeOutfitDropDown_OnEvent(self, event)
	if ( event == "TRANSMOG_OUTFITS_CHANGED" ) then
		-- try to reselect the same outfit to update the name
		-- if it changed or clear the name if it got deleted
		WardrobeOutfitDropDown_SelectOutfit(self.selectedOutfitID);
		if ( WardrobeOutfitFrame:IsShown() ) then
			WardrobeOutfitFrame_Update(WardrobeOutfitFrame);
		end
	end
	WardrobeOutfitDropDown_UpdateSaveButton();
end

function WardrobeOutfitDropDown_UpdateSaveButton()
	local self = WardrobeOutfitDropDown;
	if ( self.selectedOutfitID ) then
		self.SaveButton:SetEnabled(not WardrobeOutfitFrame_IsOutfitDressed(self.selectedOutfitID));
	else
		self.SaveButton:SetEnabled(false);
	end
end

function WardrobeOutfitDropDown_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	WardrobeOutfitDropDown_Toggle();
end

function WardrobeOutfitDropDown_Toggle()
	if ( WardrobeOutfitFrame:IsShown() ) then
		WardrobeOutfitFrame:Hide();
	else
		CloseDropDownMenus();
		WardrobeOutfitFrame:Show();
	end
end

function WardrobeOutfitDropDown_SelectOutfit(outfitID, loadOutfit)
	local self = WardrobeOutfitDropDown;
	self.selectedOutfitID = outfitID;
	local name;
	if ( outfitID ) then
		name = C_TransmogCollection.GetOutfitName(outfitID);
	end
	if ( name ) then	
		UIDropDownMenu_SetText(self, name);
	else
		UIDropDownMenu_SetText(self, GRAY_FONT_COLOR_CODE..TRANSMOG_OUTFIT_NONE..FONT_COLOR_CODE_CLOSE);
	end
	if ( loadOutfit and outfitID and WardrobeFrame_IsAtTransmogrifier() ) then
		C_Transmog.LoadOutfit(outfitID);
	end
	WardrobeOutfitDropDown_UpdateSaveButton();
end

local OUTFIT_FRAME_MIN_STRING_WIDTH = 88;
local OUTFIT_FRAME_MAX_STRING_WIDTH = 164;
local OUTFIT_FRAME_ADDED_PIXELS = 135;	-- pixels added to string width

function WardrobeOutfitFrame_OnShow(self)
	self:SetPoint("TOPLEFT", WardrobeOutfitDropDown, "BOTTOMLEFT", 8, -3);
	WardrobeOutfitFrame_Update(self);	
end

function WardrobeOutfitFrame_OnHide(self)
	self.timer = nil;
end

function WardrobeOutfitFrame_OnUpdate(self, elapsed)
	local mouseFocus = GetMouseFocus();
	for i = 1, #self.Buttons do
		local button = self.Buttons[i];
		if ( button == mouseFocus or button:IsMouseOver() ) then
			if ( button.outfitID ) then
				button.DeleteButton:Show();
				button.RenameButton:Show();
				button.SaveButton:Show();
			else	
				button.DeleteButton:Hide();
				button.RenameButton:Hide();
				button.SaveButton:Hide();
			end
			button.Highlight:Show();
		else
			button.DeleteButton:Hide();
			button.RenameButton:Hide();
			button.SaveButton:Hide();
			button.Highlight:Hide();
		end
	end
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		self:Hide();
	end
	if ( self.timer ) then
		self.timer = self.timer - elapsed;
		if ( self.timer < 0 ) then
			self:Hide();
		end
	end
end

function WardrobeOutfitFrame_StartCounting()
	WardrobeOutfitFrame.timer = UIDROPDOWNMENU_SHOW_TIME;
end

function WardrobeOutfitFrame_StopCounting()
	WardrobeOutfitFrame.timer = nil;
end

function WardrobeOutfitFrame_Update(self)
	local outfits = C_TransmogCollection.GetOutfits();
	local buttons = self.Buttons;
	local numButtons = 0;
	local stringWidth = 0;
	self:SetWidth(OUTFIT_FRAME_MAX_STRING_WIDTH + OUTFIT_FRAME_ADDED_PIXELS);
	for i = 1, MAX_TRANSMOG_OUTFITS do
		local newOutfitButton = (i == (#outfits + 1)) and (i ~= MAX_TRANSMOG_OUTFITS);
		if ( outfits[i] or newOutfitButton ) then
			local button = buttons[i];
			if ( not button ) then
				button = CreateFrame("BUTTON", nil, self, "WardrobeOutfitButtonTemplate");
				button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, 0);
				button:SetPoint("TOPRIGHT", buttons[i-1], "BOTTOMRIGHT", 0, 0);
			end
			button:Show();
			if ( newOutfitButton ) then
				button:SetText(GREEN_FONT_COLOR_CODE..TRANSMOG_OUTFIT_NEW..FONT_COLOR_CODE_CLOSE);
				button.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
				button.outfitID = nil;
				button.Check:Hide();
				button.Selection:Hide();
			else
				if ( outfits[i].outfitID == WardrobeOutfitDropDown.selectedOutfitID ) then
					button.Check:Show();
					button.Selection:Show();
				else
					button.Selection:Hide();
					button.Check:Hide();
				end
				local colorCode;
				if ( outfits[i].collected ) then
					colorCode = NORMAL_FONT_COLOR_CODE;
				else
					colorCode = RED_FONT_COLOR_CODE
				end
				button:SetText(colorCode..outfits[i].name..FONT_COLOR_CODE_CLOSE);
				button.Icon:SetTexture(outfits[i].icon);
				button.outfitID = outfits[i].outfitID;
			end
			stringWidth = max(stringWidth, button.Text:GetStringWidth());
			numButtons = numButtons + 1;
		else
			if ( buttons[i] ) then
				buttons[i]:Hide();
			end
		end
	end
	stringWidth = max(stringWidth, OUTFIT_FRAME_MIN_STRING_WIDTH);
	stringWidth = min(stringWidth, OUTFIT_FRAME_MAX_STRING_WIDTH);
	self:SetWidth(stringWidth + OUTFIT_FRAME_ADDED_PIXELS);
	self:SetHeight(30 + numButtons * 20);
end

function WardrobeOutfitFrame_IsOutfitDressed(outfitID)
	if ( not outfitID ) then
		return true;
	end
	local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(outfitID);
	if ( not appearanceSources ) then
		return true;
	end
	local slotButtons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		if ( button.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetInfoForSlot(button.slot, LE_TRANSMOG_TYPE_APPEARANCE);
			local slotID = GetInventorySlotInfo(button.slot);
			if ( selectedSourceID ~= appearanceSources[slotID] ) then
				return false;
			end
		end
	end
	local _, _, mainHandSourceID = WardrobeCollectionFrame_GetInfoForSlot("MAINHANDSLOT", LE_TRANSMOG_TYPE_ILLUSION);
	if ( mainHandSourceID ~= mainHandEnchant ) then
		return false;
	end
	local _, _, offHandSourceID = WardrobeCollectionFrame_GetInfoForSlot("SECONDARYHANDSLOT", LE_TRANSMOG_TYPE_ILLUSION);
	if ( offHandSourceID ~= offHandEnchant ) then
		return false;
	end
	return true;
end

function WardrobeOutfitFrame_SaveOutfit(name)
	local sources = { };
	local mainHandEnchant, offHandEnchant, icon;
	local slotButtons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetInfoForSlot(button.slot, button.transmogType);
		if ( selectedSourceID > 0 ) then
			if ( button.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
				local slotID = GetInventorySlotInfo(button.slot);
				sources[slotID] = selectedSourceID;
				-- outfit icon is that of the first item in slot order
				if ( not icon ) then
					icon = select(5, C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID));
				end
			elseif ( button.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
				if ( button.slot == "MAINHANDSLOT" ) then
					mainHandEnchant = selectedSourceID;
				else
					offHandEnchant = selectedSourceID;
				end
			end
		end
	end
	local outfitID = C_TransmogCollection.SaveOutfit(name, sources, mainHandEnchant, offHandEnchant, icon);
	WardrobeOutfitDropDown_SelectOutfit(outfitID);
end

function WardrobeOutfitFrame_DeleteOutfit(outfitID)
	C_TransmogCollection.DeleteOutfit(outfitID);
end

function WardrobeOutfitFrame_NameOutfit(newName, outfitID)
	local outfits = C_TransmogCollection.GetOutfits();
	for i = 1, #outfits do
		if ( outfits[i].name == newName ) then
			if ( outfitID ) then
				UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_ALREADY_EXISTS, 1.0, 0.1, 0.1, 1.0);
			else
				StaticPopup_Hide("NAME_TRANSMOG_OUTFIT");
				StaticPopup_Show("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", newName, nil, newName);
			end
			return;
		end
	end
	if ( outfitID ) then
		-- this is a rename
		C_TransmogCollection.ModifyOutfit(outfitID, newName);
	else
		-- this is a new outfit
		WardrobeOutfitFrame_SaveOutfit(newName);
	end
end

function WardrobeOutfitButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	WardrobeOutfitFrame:Hide();
	if ( self.outfitID ) then
		WardrobeOutfitDropDown_SelectOutfit(self.outfitID, true);
	else
		StaticPopup_Show("NAME_TRANSMOG_OUTFIT");
	end
end

function WardrobeOutfitRenameButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	WardrobeOutfitFrame:Hide();
	local outfitID = self:GetParent().outfitID;
	local name = C_TransmogCollection.GetOutfitName(outfitID);
	local dialog = StaticPopup_Show("NAME_TRANSMOG_OUTFIT", nil, nil, outfitID);
	if ( dialog ) then
		dialog.editBox:SetText(name);
	end
end

function WardrobeOutfitDeleteButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	WardrobeOutfitFrame:Hide();
	local outfitID = self:GetParent().outfitID;
	local name = C_TransmogCollection.GetOutfitName(outfitID);
	StaticPopup_Show("CONFIRM_DELETE_TRANSMOG_OUTFIT", name, nil, outfitID);
end

function WardrobeOutfitSaveButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	WardrobeOutfitFrame:Hide();
	local outfitID = self:GetParent().outfitID;
	local name = C_TransmogCollection.GetOutfitName(outfitID);
	StaticPopup_Show("CONFIRM_SAVE_TRANSMOG_OUTFIT", name, nil, name);
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