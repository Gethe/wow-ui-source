-- C_TransmogCollection.GetItemInfo(itemID, [itemModID]/itemLink/itemName) = appearanceID, sourceID
-- C_TransmogCollection.GetAllAppearanceSources(appearanceID) = { sourceID } This is cross-class, but no guarantee a source is actually attainable
-- C_TransmogCollection.GetSourceInfo(sourceID) = { data }
-- 15th return of GetItemInfo is expansionID
-- new events: TRANSMOG_COLLECTION_SOURCE_ADDED and TRANSMOG_COLLECTION_SOURCE_REMOVED, parameter is sourceID, can be cross-class (wand unlocked from ensemble while on warrior)

local REMOVE_TRANSMOG_ID = 0;

-- ************************************************************************************************************************************************************
-- **** MAIN **********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeFrame_OnLoad(self)
	SetPortraitToTexture(WardrobeFramePortrait, "Interface\\Icons\\INV_Arcane_Orb");
	WardrobeFrameTitleText:SetText(TRANSMOGRIFY);
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
	self:RegisterEvent("TRANSMOGRIFY_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
end

function WardrobeTransmogFrame_OnEvent(self, event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_ITEM_UPDATE" ) then
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
		if ( event == "TRANSMOGRIFY_UPDATE" ) then
			StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
		elseif ( event == "TRANSMOGRIFY_ITEM_UPDATE" and self.redoApply ) then
			WardrobeTransmogFrame_ApplyPending(0);
		end
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
	HideUIPanel(CollectionsJournal);
	WardrobeCollectionFrame_SetContainer(WardrobeFrame);

	PlaySound("UI_Transmog_OpenWindow");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");
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
		if ( hasPending or hasUndo or canTransmogrify ) then
			slotButton.Icon:SetTexture(texture or ENCHANT_EMPTY_SLOT_FILEDATAID);
			slotButton.NoItemTexture:Hide();
		else
			slotButton.Icon:SetColorTexture(0, 0, 0);
			slotButton.NoItemTexture:Show();
		end
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
		if ( WardrobeUtils_IsCategoryRanged(categoryID) ) then
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
	WardrobeTransmogFrame.redoApply = nil;
	if ( WardrobeTransmogFrame.applyWarningsTable and lastAcceptedWarningIndex < #WardrobeTransmogFrame.applyWarningsTable ) then
		lastAcceptedWarningIndex = lastAcceptedWarningIndex + 1;
		local data = {
			["link"] = WardrobeTransmogFrame.applyWarningsTable[lastAcceptedWarningIndex].itemLink,
			["useLinkForItemInfo"] = true,
			["warningIndex"] = lastAcceptedWarningIndex;
		};
		StaticPopup_Show("TRANSMOG_APPLY_WARNING", WardrobeTransmogFrame.applyWarningsTable[lastAcceptedWarningIndex].text, nil, data);
		WardrobeTransmogFrame_UpdateApplyButton();
		-- return true to keep static popup open when chaining warnings
		return true;
	else
		local success = C_Transmog.ApplyAllPending(GetCVarBool("transmogCurrentSpecOnly"));
		if ( success ) then
			PlaySound("UI_Transmog_Apply");
			WardrobeTransmogFrame.applyWarningsTable = nil;
			-- outfit tutorial
			if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN) ) then
				local outfits = C_TransmogCollection.GetOutfits();
				if ( #outfits == 0 ) then
					WardrobeTransmogFrame.OutfitHelpBox:Show();
				end
			end
		else
			-- it's retrieving item info
			WardrobeTransmogFrame.redoApply = true;
		end
		return false;
	end
end

WardrobeOutfitMixin = { };

function WardrobeOutfitMixin:LoadOutfit(outfitID)
	if ( not outfitID ) then
		return;
	end
	C_Transmog.LoadOutfit(outfitID);
end

function WardrobeOutfitMixin:GetSlotSourceID(slot, transmogType)
	local slotID = GetInventorySlotInfo(slot);
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(slotID, transmogType);
	if ( not canTransmogrify and not hasUndo ) then
		return NO_TRANSMOG_SOURCE_ID;
	end

	local _, _, sourceID = WardrobeCollectionFrame_GetInfoForEquippedSlot(slot, transmogType);
	return sourceID;
end

function WardrobeOutfitMixin:OnSelectOutfit(outfitID)
	if ( outfitID ) then
		SetCVar("lastTransmogOutfitID", outfitID);
	else
		-- outfitID can be 0, so use empty string for none
		SetCVar("lastTransmogOutfitID", "");
	end
end

function WardrobeOutfitMixin:GetLastOutfitID()
	return tonumber(GetCVar("lastTransmogOutfitID"));
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
			WardrobeTransmogButton_Select(self);
		elseif ( isTransmogrified ) then
			PlaySound("UI_Transmog_RevertingGearSlot");
			C_Transmog.SetPending(slotID, self.transmogType, 0);
			WardrobeTransmogButton_Select(self);
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
		if ( hasPending or hasUndo or canTransmogrify ) then
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
		else
			local itemBaseSourceID = C_Transmog.GetSlotVisualInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
			if ( itemBaseSourceID == NO_TRANSMOG_SOURCE_ID ) then
				GameTooltip:AddLine(TRANSMOGRIFY_INVALID_NO_ITEM, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			else
				GameTooltip:AddLine(TRANSMOGRIFY_ILLUSION_INVALID_ITEM, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
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
		if (WardrobeCollectionFrame.activeFrame == WardrobeCollectionFrame.ItemsCollectionFrame) then
			local _, _, selectedSourceID = WardrobeCollectionFrame_GetInfoForEquippedSlot(button.slot, button.transmogType);
			local forceGo = (button.transmogType == LE_TRANSMOG_TYPE_ILLUSION);
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, button.slot, button.transmogType, forceGo);
		end
		WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(true);
	else
		WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(false);
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

local WARDROBE_NUM_ROWS = 3;
local WARDROBE_NUM_COLS = 6;
local WARDROBE_PAGE_SIZE = WARDROBE_NUM_ROWS * WARDROBE_NUM_COLS;
local MAIN_HAND_INV_TYPE = 21;
local OFF_HAND_INV_TYPE = 22;
local RANGED_INV_TYPE = 15;
local TAB_ITEMS = 1;
local TAB_SETS = 2;
local TABS_MAX_WIDTH = 185;

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
	if ( parent == CollectionsJournal ) then
		collectionFrame:SetPoint("TOPLEFT", CollectionsJournal);
		collectionFrame:SetPoint("BOTTOMRIGHT", CollectionsJournal);
		collectionFrame.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -238, -85);
		collectionFrame.ItemsCollectionFrame.SlotsFrame:Show();
		collectionFrame.ItemsCollectionFrame.BGCornerTopLeft:Hide();
		collectionFrame.ItemsCollectionFrame.BGCornerTopRight:Hide();
		collectionFrame.ItemsCollectionFrame.WeaponDropDown:SetPoint("TOPRIGHT", -6, -22);
		collectionFrame.ItemsCollectionFrame.NoValidItemsLabel:Hide();
		collectionFrame.FilterButton:SetText(FILTER);
		collectionFrame.ItemsTab:SetPoint("TOPLEFT", 58, -28);
		WardrobeCollectionFrame_SetTab(collectionFrame.selectedCollectionTab);
	elseif ( parent == WardrobeFrame ) then
		collectionFrame:SetPoint("TOPRIGHT", 0, 0);
		collectionFrame:SetSize(662, 606);
		collectionFrame.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -235, -71);
		collectionFrame.ItemsCollectionFrame.SlotsFrame:Hide();
		collectionFrame.ItemsCollectionFrame.BGCornerTopLeft:Show();
		collectionFrame.ItemsCollectionFrame.BGCornerTopRight:Show();
		collectionFrame.ItemsCollectionFrame.WeaponDropDown:SetPoint("TOPRIGHT", -32, -25);
		collectionFrame.FilterButton:SetText(SOURCES);
		collectionFrame.ItemsTab:SetPoint("TOPLEFT", 8, -28);
		WardrobeCollectionFrame_SetTab(collectionFrame.selectedTransmogTab);
	end
	collectionFrame:Show();
end

function WardrobeCollectionFrame_ClickTab(tab)
	WardrobeCollectionFrame_SetTab(tab:GetID());
	PanelTemplates_ResizeTabsToFit(WardrobeCollectionFrame, TABS_MAX_WIDTH);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function WardrobeCollectionFrame_SetTab(tabID)
	PanelTemplates_SetTab(WardrobeCollectionFrame, tabID);
	local atTransmogrifier = WardrobeFrame_IsAtTransmogrifier();
	if ( atTransmogrifier ) then
		WardrobeCollectionFrame.selectedTransmogTab = tabID;
	else
		WardrobeCollectionFrame.selectedCollectionTab = tabID;
	end
	if ( tabID == TAB_ITEMS ) then
		WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.ItemsCollectionFrame;
		WardrobeCollectionFrame.ItemsCollectionFrame:Show();
		WardrobeCollectionFrame.SetsCollectionFrame:Hide();
		WardrobeCollectionFrame.SetsTransmogFrame:Hide();
		WardrobeCollectionFrame.searchBox:ClearAllPoints();
		WardrobeCollectionFrame.searchBox:SetPoint("TOPRIGHT", -107, -35);
		WardrobeCollectionFrame.searchBox:SetWidth(115);
	elseif ( tabID == TAB_SETS ) then
		WardrobeCollectionFrame.ItemsCollectionFrame:Hide();
		WardrobeCollectionFrame.searchBox:ClearAllPoints();
		if ( atTransmogrifier )  then
			WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.SetsTransmogFrame;
			WardrobeCollectionFrame.searchBox:SetPoint("TOPRIGHT", -107, -35);
			WardrobeCollectionFrame.searchBox:SetWidth(115);
		else
			WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.SetsCollectionFrame;
			WardrobeCollectionFrame.searchBox:SetPoint("TOPLEFT", 19, -69);
			WardrobeCollectionFrame.searchBox:SetWidth(145);
		end
		WardrobeCollectionFrame.SetsCollectionFrame:SetShown(not atTransmogrifier);
		WardrobeCollectionFrame.SetsTransmogFrame:SetShown(atTransmogrifier);
	end
end

function WardrobeCollectionFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
	PanelTemplates_ResizeTabsToFit(self, TABS_MAX_WIDTH);
	self.selectedCollectionTab = TAB_ITEMS;
	self.selectedTransmogTab = TAB_ITEMS;

	self.needsUpdateUsable = true;
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("SPELLS_CHANGED");

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_misc_enggizmos_19");
end

WardrobeItemsCollectionMixin = { };

function WardrobeItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", 24, "hands", "waist", "legs", "feet", 24, "mainhand", 12, "secondaryhand" };
	local parentFrame = self.SlotsFrame;
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

function WardrobeItemsCollectionMixin:OnEvent(event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" or event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slotID = ...;
		if ( slotID and self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			if ( slotID == GetInventorySlotInfo(self.activeSlot) ) then
				self:UpdateItems();
			end
		else
			-- generic update
			self:UpdateItems();
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED") then
		self:CheckLatestAppearance(true);
		self:ValidateChosenVisualSources();
		if ( self:IsVisible() ) then
			self:RefreshVisualsList();
			self:UpdateItems();
		end
	elseif ( event == "TRANSMOG_COLLECTION_CAMERA_UPDATE" ) then
		for i = 1, #self.Models do
			self.Models[i].cameraID = nil;
		end
		self:UpdateItems();
	end
end

function WardrobeCollectionFrame_OnEvent(self, event, ...)
	if ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.tooltipAppearanceID ) then
			WardrobeCollectionFrame_RefreshAppearanceTooltip();
		end
		if ( self.ItemsCollectionFrame:IsShown() ) then
			self.ItemsCollectionFrame:ValidateChosenVisualSources();
		end
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local hasAlternateForm, inAlternateForm = HasAlternateForm();
		if ( (self.inAlternateForm ~= inAlternateForm or self.updateOnModelChanged) ) then
			if ( self.activeFrame:OnUnitModelChangedEvent() ) then
				self.inAlternateForm = inAlternateForm;
				self.updateOnModelChanged = nil;
			end
		end
	elseif ( event == "PLAYER_LEVEL_UP" or event == "SKILL_LINES_CHANGED" or event == "UPDATE_FACTION" or event == "SPELLS_CHANGED" ) then
		if ( self:IsVisible() ) then
			C_TransmogCollection.UpdateUsableAppearances();
		else
			self.needsUpdateUsable = true;
		end
	elseif ( event == "TRANSMOG_SEARCH_UPDATED" ) then
		local searchType, arg1 = ...;
		if ( searchType == self.activeFrame.searchType ) then
			self.activeFrame:OnSearchUpdate(arg1);
		end
	elseif ( event == "SEARCH_DB_LOADED" ) then
		WardrobeCollectionFrame_RestartSearchTracking();
	end
end

function WardrobeItemsCollectionMixin:CheckLatestAppearance(changeTab)
	local latestAppearanceID, latestAppearanceCategoryID = C_TransmogCollection.GetLatestAppearance();
	if ( self.latestAppearanceID ~= latestAppearanceID ) then
		self.latestAppearanceID = latestAppearanceID;
		self.jumpToLatestAppearanceID = latestAppearanceID;
		self.jumpToLatestCategoryID = latestAppearanceCategoryID;

		if ( changeTab and not CollectionsJournal:IsShown() ) then
			CollectionsJournal_SetTab(CollectionsJournal, 5);
		end
	end
end

function WardrobeItemsCollectionMixin:OnLoad()
	self:CreateSlotButtons();
	self.BGCornerTopLeft:Hide();
	self.BGCornerTopRight:Hide();

	self.chosenVisualSources = { };

	UIDropDownMenu_Initialize(self.RightClickDropDown, nil, "MENU");
	self.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;

	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	self:CheckLatestAppearance();
end

function WardrobeItemsCollectionMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");

	local needsUpdate = false;	-- we don't need to update if we call WardrobeCollectionFrame_SetActiveSlot as that will do an update
	if ( self.jumpToLatestCategoryID and self.jumpToLatestCategoryID ~= self.activeCategory ) then
		local slot = WardrobeCollectionFrame_GetSlotFromCategoryID(self.jumpToLatestCategoryID);
		self:SetActiveSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE, self.jumpToLatestCategoryID);
		self.jumpToLatestCategoryID = nil;
	elseif ( self.activeSlot ) then
		-- redo the model for the active slot
		self:ChangeModelsSlot(nil, self.activeSlot);
		needsUpdate = true;
	else
		self:SetActiveSlot("HEADSLOT", LE_TRANSMOG_TYPE_APPEARANCE);
	end

	if ( needsUpdate ) then
		self:RefreshVisualsList();
		self:UpdateItems();
		self:UpdateWeaponDropDown();
	end

	-- tab tutorial
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB, true);
end

function WardrobeItemsCollectionMixin:OnHide()
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");

	WardrobeCollectionFrame_ClearSearch(LE_TRANSMOG_SEARCH_TYPE_ITEMS);
	C_TransmogCollection.EndSearch();

	for i = 1, #self.Models do
		self.Models[i]:SetKeepModelOnHide(false);
	end

	self.visualsList = nil;
	self.filteredVisualsList = nil;
end

function WardrobeCollectionFrame_OnShow(self)
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_chest_cloth_17");

	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");
	self:RegisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self.inAlternateForm = inAlternateForm;
	end

	if ( self.needsUpdateUsable ) then
		self.needsUpdateUsable = nil;
		C_TransmogCollection.UpdateUsableAppearances();
	end

	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		WardrobeCollectionFrame_SetTab(self.selectedTransmogTab);
	else
		WardrobeCollectionFrame_SetTab(self.selectedCollectionTab);
	end
end

function WardrobeCollectionFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	self:UnregisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:UnregisterEvent("SEARCH_DB_LOADED");
end
	
function WardrobeItemsCollectionMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function WardrobeItemsCollectionMixin:HandleKey(key)
	local _, _, _, selectedVisualID = self:GetActiveSlotInfo();
	local visualIndex;
	local visualsList = self:GetFilteredVisualsList();
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

		local newIndex = visualIndex;
		newIndex = newIndex + WARDROBE_NUM_COLS * direction;
		if ( GetPage(newIndex) ~= self.PagingFrame:GetCurrentPage() or newIndex > #visualsList ) then
			newIndex = visualIndex + WARDROBE_PAGE_SIZE * -direction;	-- reset by a full page in opposite direction
			while ( GetPage(newIndex) ~= self.PagingFrame:GetCurrentPage() or newIndex > #visualsList ) do
				newIndex = newIndex + WARDROBE_NUM_COLS * direction;
			end
		end
		visualIndex = newIndex;
	end
	self:SelectVisual(visualsList[visualIndex].visualID);
	self.jumpToVisualID = visualsList[visualIndex].visualID;
	self:ResetPage();
end

function WardrobeCollectionFrame_OnKeyDown(self, key)
	if ( self.tooltipCycle and key == WARDROBE_CYCLE_KEY ) then
		self:SetPropagateKeyboardInput(false);
		if ( IsShiftKeyDown() ) then
			self.tooltipSourceIndex = self.tooltipSourceIndex - 1;
		else
			self.tooltipSourceIndex = self.tooltipSourceIndex + 1;
		end
		WardrobeCollectionFrame_RefreshAppearanceTooltip();
	elseif ( key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY ) then
		if ( WardrobeFrame_IsAtTransmogrifier() and self.ItemsCollectionFrame:IsShown() ) then
			self:SetPropagateKeyboardInput(false);
			self.ItemsCollectionFrame:HandleKey(key);
		else
			self:SetPropagateKeyboardInput(true);
		end
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function WardrobeItemsCollectionMixin:ChangeModelsSlot(oldSlot, newSlot)
	WardrobeCollectionFrame.updateOnModelChanged = nil;

	local undressSlot, reloadModel;
	local newSlotIsArmor = WardrobeUtils_GetArmorCategoryIDFromSlot(newSlot);
	if ( newSlotIsArmor ) then
		local oldSlotIsArmor = oldSlot and WardrobeUtils_GetArmorCategoryIDFromSlot(oldSlot);
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

	if ( reloadModel and not self.Models[1]:CanSetUnit("player") ) then
		WardrobeCollectionFrame.updateOnModelChanged = true;
		for i = 1, #self.Models do
			self.Models[i]:ClearModel();
		end
		return;
	end

	for i = 1, #self.Models do
		local model = self.Models[i];
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
			model:Reload(newSlot);
		end
		model.visualInfo = nil;
	end
	self.illusionWeaponVisualID = nil;
end

function WardrobeItemsCollectionMixin:OnUnitModelChangedEvent()
	if ( self.Models[1]:CanSetUnit("player") ) then
		self:ChangeModelsSlot(nil, self:GetActiveSlot());
		self:UpdateItems();
		return true;
	else
		return false;
	end
end

function WardrobeUtils_IsCategoryRanged(category)
	return (category == LE_TRANSMOG_COLLECTION_TYPE_BOW) or (category == LE_TRANSMOG_COLLECTION_TYPE_GUN) or (category == LE_TRANSMOG_COLLECTION_TYPE_CROSSBOW);
end

function WardrobeUtils_GetArmorCategoryIDFromSlot(slot)
	for i = 1, #TRANSMOG_SLOTS do
		if ( TRANSMOG_SLOTS[i].slot == slot ) then
			return TRANSMOG_SLOTS[i].armorCategoryID;
		end
	end
end

function WardrobeUtils_GetValidIndexForNumSources(index, numSources)
	index = index - 1;
	if ( index < 0 ) then
		index = numSources + index;
	end
	return mod(index, numSources) + 1;
end

function WardrobeItemsCollectionMixin:GetActiveSlot()
	return self.activeSlot;
end

function WardrobeItemsCollectionMixin:GetActiveCategory()
	return self.activeCategory;
end

function WardrobeItemsCollectionMixin:IsValidWeaponCategoryForSlot(categoryID, slot)
	local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
	if ( name and isWeapon ) then
		if ( (slot == "MAINHANDSLOT" and canMainHand) or (slot == "SECONDARYHANDSLOT" and canOffHand) ) then
			if ( WardrobeFrame_IsAtTransmogrifier() ) then
				local equippedItemID = GetInventoryItemID("player", GetInventorySlotInfo(slot));
				return C_TransmogCollection.IsCategoryValidForItem(self.lastWeaponCategory, equippedItemID);
			else
				return true;
			end
		end
	end
	return false;
end

function WardrobeItemsCollectionMixin:SetActiveSlot(slot, transmogType, category)
	local previousSlot = self.activeSlot;
	self.activeSlot = slot;
	self.transmogType = transmogType;

	-- figure out a category
	if ( not category ) then
		if ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			category = nil;
		elseif ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local useLastWeaponCategory = (slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT") and
											self.lastWeaponCategory and
											self:IsValidWeaponCategoryForSlot(self.lastWeaponCategory, slot);
			if ( useLastWeaponCategory ) then
				category = self.lastWeaponCategory;
			else
				local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = self:GetActiveSlotInfo();
				if ( selectedSourceID ~= NO_TRANSMOG_SOURCE_ID ) then
					category = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
				end
			end
			if ( not category ) then
				if ( slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT" ) then
					-- find the first valid weapon category
					for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
						if ( self:IsValidWeaponCategoryForSlot(categoryID, slot) ) then
							category = categoryID;
							break;
						end
					end
				else
					category = WardrobeUtils_GetArmorCategoryIDFromSlot(slot);
				end
			end
		end
	end

	if ( previousSlot ~= slot ) then
		self:ChangeModelsSlot(previousSlot, slot);
	end
	-- set only if category is different or slot is different
	if ( category ~= self.activeCategory or slot ~= previousSlot ) then
		self:SetActiveCategory(category);
	end
end

function WardrobeItemsCollectionMixin:SetTransmogrifierAppearancesShown(hasAnyValidSlots)
	self.NoValidItemsLabel:SetShown(not hasAnyValidSlots);
	C_TransmogCollection.SetCollectedShown(hasAnyValidSlots);
end

function WardrobeItemsCollectionMixin:UpdateWeaponDropDown()
	local dropdown = self.WeaponDropDown;
	local name, isWeapon;
	if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		name, isWeapon = C_TransmogCollection.GetCategoryInfo(self.activeCategory);
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
		UIDropDownMenu_SetSelectedValue(dropdown, self.activeCategory);
		UIDropDownMenu_SetText(dropdown, name);
		local validCategories = WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if ( validCategories > 1 ) then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	end
end

function WardrobeItemsCollectionMixin:SetActiveCategory(category)
	self.activeCategory = category;
	if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		C_TransmogCollection.SetSearchAndFilterCategory(category);
		local name, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
		if ( isWeapon ) then
			self.lastWeaponCategory = category;
		end
	end
	self:RefreshVisualsList();
	self:UpdateWeaponDropDown();

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.slot == self.activeSlot and button.transmogType == self.transmogType);
	end

	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		self.jumpToVisualID = select(4, self:GetActiveSlotInfo());
	else
		self.jumpToVisualID = nil;
	end
	self:ResetPage();
	WardrobeCollectionFrame_SwitchSearchCategory();
end

function WardrobeItemsCollectionMixin:ResetPage()
	local page = 1;
	local selectedVisualID = NO_TRANSMOG_VISUAL_ID;
	if ( C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame.activeFrame.searchType) ) then
		self.resetPageOnSearchUpdated = true;
	else
		if ( self.jumpToVisualID ) then
			selectedVisualID = self.jumpToVisualID;
			self.jumpToVisualID = nil;
		elseif ( self.jumpToLatestAppearanceID ) then
			selectedVisualID = self.jumpToLatestAppearanceID;
			self.jumpToLatestAppearanceID = nil;
		end
	end
	if ( selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == selectedVisualID ) then
				page = floor((i-1) / WARDROBE_PAGE_SIZE) + 1;
				break;
			end
		end
	end
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateItems();
end

function WardrobeItemsCollectionMixin:FilterVisuals()
	local isAtTransmogrifier = WardrobeFrame_IsAtTransmogrifier();
	local visualsList = self.visualsList;
	local filteredVisualsList = { };
	for i = 1, #visualsList do
		if ( isAtTransmogrifier ) then
			if ( visualsList[i].isUsable and visualsList[i].isCollected ) then
				tinsert(filteredVisualsList, visualsList[i]);
			end
		else
			if ( not visualsList[i].isHideVisual ) then
				tinsert(filteredVisualsList, visualsList[i]);
			end
		end
	end
	self.filteredVisualsList = filteredVisualsList;
end

function WardrobeItemsCollectionMixin:SortVisuals()
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

	table.sort(self.filteredVisualsList, comparison);
end

function WardrobeItemsCollectionMixin:GetActiveSlotInfo()
	return WardrobeCollectionFrame_GetInfoForEquippedSlot(self.activeSlot, self.transmogType);
end

function WardrobeCollectionFrame_GetInfoForEquippedSlot(slot, transmogType)
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

	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetInfoForEquippedSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
	local _, _, canEnchant = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
	if ( canEnchant ) then
		return selectedSourceID, selectedVisualID;
	else
		local appearanceSourceID = C_TransmogCollection.GetIllusionFallbackWeaponSource();
		local _, appearanceVisualID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID;
	end
end

function WardrobeItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;
	local appearanceVisualID;	-- for weapon when looking at enchants
	local changeModel = false;
	local isAtTransmogrifier = WardrobeFrame_IsAtTransmogrifier();

	if ( self.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		-- for enchants we need to get the visual of the item in that slot
		local appearanceSourceID;
		appearanceSourceID, appearanceVisualID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(self.activeSlot);
		cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(appearanceSourceID);
		if ( appearanceVisualID ~= self.illusionWeaponVisualID ) then
			self.illusionWeaponVisualID = appearanceVisualID;
			changeModel = true;
		end
	else
		local _, isWeapon = C_TransmogCollection.GetCategoryInfo(self.activeCategory);
		isArmor = not isWeapon;
	end

	local tutorialAnchorFrame;
	local checkTutorialFrame = (self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE) and not WardrobeFrame_IsAtTransmogrifier()
								and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK);

	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo;
	local showUndoIcon;
	if ( isAtTransmogrifier ) then
		baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(self.activeSlot), self.transmogType);
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
	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * WARDROBE_PAGE_SIZE;
	for i = 1, WARDROBE_PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local visualInfo = self.filteredVisualsList[index];
		if ( visualInfo ) then
			model:Show();

			-- camera
			if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
				cameraID = C_TransmogCollection.GetAppearanceCameraID(visualInfo.visualID);
			end
			if ( model.cameraID ~= cameraID ) then
				Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

			if ( visualInfo ~= model.visualInfo or changeModel ) then
				if ( isArmor ) then
					local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID);
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

			if ( C_TransmogCollection.IsNewAppearance(visualInfo.visualID) ) then
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
				model:OnEnter();
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
	-- progress bar
	self:UpdateProgressBar();
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
		self.HelpBox:SetPoint("TOP", tutorialAnchorFrame, "BOTTOM", 0, -22);
		self.HelpBox:Show();
	else
		self.HelpBox:Hide();
	end
end

function WardrobeItemsCollectionMixin:UpdateProgressBar()
	local collected, total;
	if ( self.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		total = #self.visualsList;
		collected = 0;
		for i, illusion in ipairs(self.visualsList) do
			if ( illusion.isCollected ) then
				collected = collected + 1;
			end
		end
	else
		collected = C_TransmogCollection.GetCategoryCollectedCount(self.activeCategory);
		total = C_TransmogCollection.GetCategoryTotal(self.activeCategory);
	end
	WardrobeCollectionFrame_UpdateProgressBar(collected, total);
end

function WardrobeCollectionFrame_UpdateProgressBar(value, max)
	WardrobeCollectionFrame.progressBar:SetMinMaxValues(0, max);
	WardrobeCollectionFrame.progressBar:SetValue(value);
	WardrobeCollectionFrame.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, value, max);
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

function WardrobeItemsCollectionMixin:RefreshVisualsList()
	if ( self.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		self.visualsList = C_TransmogCollection.GetIllusions();
	else
		self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory);
	end
	self:FilterVisuals();
	self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.filteredVisualsList / WARDROBE_PAGE_SIZE));
end

function WardrobeItemsCollectionMixin:GetFilteredVisualsList()
	return self.filteredVisualsList;
end

function WardrobeItemsCollectionMixin:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable)
	local sourceID = self:GetChosenVisualSource(visualID);
	if ( sourceID == NO_TRANSMOG_SOURCE_ID ) then
		local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID);
		for i = 1, #sources do
			-- first 1 if it doesn't have to be usable
			if ( not mustBeUsable or not sources[i].useError ) then
				sourceID = sources[i].sourceID;
				break;
			end
		end
	end
	return sourceID;
end

function WardrobeItemsCollectionMixin:SelectVisual(visualID)
	if ( not WardrobeFrame_IsAtTransmogrifier() ) then
		return;
	end

	local sourceID;
	if ( self.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		sourceID = self:GetAnAppearanceSourceFromVisual(visualID, true);
	else
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == visualID ) then
				sourceID = visualsList[i].sourceID;
				break;
			end
		end
	end
	local slotID = GetInventorySlotInfo(self.activeSlot);
	C_Transmog.SetPending(slotID, self.transmogType, sourceID);
	PlaySound("UI_Transmog_ItemClick");
end

function WardrobeCollectionFrame_OpenTransmogLink(link, transmogType)
	local linkType, id = strsplit(":", link);

	if ( linkType == "transmogappearance" ) then
		local sourceID = tonumber(id);
		if ( not WardrobeCollectionFrame:IsVisible() ) then
			ToggleCollectionsJournal(5);
		end
		WardrobeCollectionFrame_SetTab(TAB_ITEMS);
		WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(sourceID, nil, LE_TRANSMOG_TYPE_APPEARANCE);
	elseif ( linkType == "transmogset") then
		local setID = tonumber(id);
		if ( not WardrobeCollectionFrame:IsVisible() ) then
			ToggleCollectionsJournal(5);
		end
		WardrobeCollectionFrame_SetTab(TAB_SETS);
		WardrobeCollectionFrame.SetsCollectionFrame:SelectSet(setID);
	end
end

function WardrobeItemsCollectionMixin:GoToSourceID(sourceID, slot, transmogType, forceGo)
	local categoryID, visualID;
	if ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
		categoryID, visualID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		slot = slot or WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID);
	elseif ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		visualID = C_TransmogCollection.GetIllusionSourceInfo(sourceID);
		slot = slot or "MAINHANDSLOT";
	end
	if ( visualID or forceGo ) then
		self.jumpToVisualID = visualID;
		if ( self.activeCategory ~= categoryID or self.activeSlot ~= slot ) then
			self:SetActiveSlot(slot, transmogType, category);
		else
			self:ResetPage();
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

WardrobeItemsModelMixin = { };

function WardrobeItemsModelMixin:OnLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:SetAutoDress(false);

	local lightValues = { enabled=true, omni=false, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.05, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
	self:SetLight(lightValues.enabled, lightValues.omni, 
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
			lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);
end

function WardrobeItemsModelMixin:OnEvent()
	self:RefreshCamera();
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeItemsModelMixin:OnModelLoaded()
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeItemsModelMixin:OnMouseDown(button)
	local parent = self:GetParent();
	local transmogType = self:GetParent().transmogType;
	if ( IsModifiedClick("CHATLINK") ) then
		local link;
		if ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			link = select(3, C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID));
		else
			local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID);
			if ( WardrobeCollectionFrame.tooltipSourceIndex ) then
				local index = WardrobeUtils_GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources);
				link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
			end
		end
		if ( link ) then
			HandleModifiedItemClick(link);
		end
		return;
	elseif ( IsModifiedClick("DRESSUP") ) then
		local slot = self:GetParent():GetActiveSlot();
		if ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local sourceID = self:GetParent():GetAnAppearanceSourceFromVisual(self.visualInfo.visualID);
			-- don't specify a slot for ranged weapons
			if ( WardrobeUtils_IsCategoryRanged(self:GetParent():GetActiveCategory()) ) then
				slot = nil;
			end
			DressUpVisual(sourceID, slot);
		elseif ( transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			local weaponSourceID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(slot);
			DressUpVisual(weaponSourceID, slot, self.visualInfo.sourceID);
		end
		return;
	end

	if ( button == "LeftButton" ) then
		CloseDropDownMenus();
		self:GetParent():SelectVisual(self.visualInfo.visualID);
	elseif ( button == "RightButton" ) then
		local dropDown = self:GetParent().RightClickDropDown;
		if ( dropDown.activeFrame ~= self ) then
			CloseDropDownMenus();
		end
		if ( not self.visualInfo.isCollected or self.visualInfo.isHideVisual or transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
			return;
		end
		dropDown.activeFrame = self;
		ToggleDropDownMenu(1, nil, dropDown, self, -6, -3);
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function WardrobeItemsModelMixin:OnEnter()
	if ( not self.visualInfo ) then
		return;
	end
	self:SetScript("OnUpdate", self.OnUpdate);
	if ( C_TransmogCollection.IsNewAppearance(self.visualInfo.visualID) ) then
		C_TransmogCollection.ClearNewAppearance(self.visualInfo.visualID);
		self.NewString:Hide();
		self.NewGlow:Hide();
	end
	if ( self:GetParent().transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		local visualID, name = C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name);
		if ( self.visualInfo.sourceText ) then
			GameTooltip:AddLine(self.visualInfo.sourceText, 1, 1, 1, 1);
		end
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local chosenSourceID = self:GetParent():GetChosenVisualSource(self.visualInfo.visualID);
		WardrobeCollectionFrame_SetAppearanceTooltip(self.visualInfo.visualID, chosenSourceID);
	end
end

function WardrobeItemsModelMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

function WardrobeItemsModelMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function WardrobeItemsModelMixin:Reload(reloadSlot)
	if ( self:IsShown() ) then
		if ( WARDROBE_MODEL_SETUP[reloadSlot] ) then
			self:SetUseTransmogSkin(WARDROBE_MODEL_SETUP[reloadSlot].useTransmogSkin);
			self:SetUnit("player", false);
			self:SetDoBlend(false);
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

function WardrobeItemsModelMixin:OnShow()
	if ( self.needsReload ) then
		self:Reload(self, self:GetParent():GetActiveSlot());
	end
end

WardrobeSetsTransmogModelMixin = { };

function WardrobeSetsTransmogModelMixin:OnLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:SetAutoDress(false);
	self:SetUnit("player");
	self:FreezeAnimation(0, 0, 0);
	local x, y, z = self:TransformCameraSpaceToModelSpace(0, 0, -0.25);
	self:SetPosition(x, y, z);
end

function WardrobeSetsTransmogModelMixin:OnEvent()
	self:RefreshCamera();
	local x, y, z = self:TransformCameraSpaceToModelSpace(0, 0, -0.25);
	self:SetPosition(x, y, z);
end

function WardrobeSetsTransmogModelMixin:OnMouseDown(button)
	if ( button == "LeftButton" ) then
		self:GetParent():LoadSet(self.setID);
	end
end

function WardrobeSetsTransmogModelMixin:OnEnter()
	local setInfo = C_TransmogSets.GetSetInfo(self.setID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(setInfo.name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	if ( setInfo.label ) then
		GameTooltip:AddLine(setInfo.label);
		GameTooltip:Show();
	end
end

function WardrobeSetsTransmogModelMixin:OnLeave()
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

function WardrobeCollectionFrame_RefreshAppearanceTooltip()
	WardrobeCollectionFrame_SetAppearanceTooltip(WardrobeCollectionFrame.tooltipAppearanceID, WardrobeCollectionFrame.tooltipSourceID);
end

function WardrobeCollectionFrame_HideAppearanceTooltip()
	WardrobeCollectionFrame.tooltipAppearanceID = nil;
	WardrobeCollectionFrame.tooltipSourceID = nil;
	WardrobeCollectionFrame.tooltipCycle = nil;
	WardrobeCollectionFrame.tooltipSourceIndex = nil;
	GameTooltip:Hide();
end

function WardrobeCollectionFrame_GetDefaultSourceIndex(appearanceID, sourceID)
	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(appearanceID);
	local sourceIndex;
	-- default sourceIndex is, in order of preference:
	-- 1. sourceID parameter, if collected and usable
	-- 2. collected and usable
	-- 3. collected and unusable
	-- 4. uncollected sourceID
	-- 5. uncollected
	for i = 1, #sources do
		if ( not sources[i].isCollected ) then
			if ( sourceID == sources[i].sourceID and not sourceIndex ) then
				sourceIndex = i;
				break;
			end
		else
			appearanceCollected = true;
			if ( not sources[i].useError ) then
				if ( sourceID == sources[i].sourceID ) then
					-- found #1
					sourceIndex = i;
					break;
				elseif ( not sourceIndex ) then
					-- candidate for #2
					sourceIndex = i;
					if ( sourceID == NO_TRANSMOG_SOURCE_ID ) then
						-- done
						break;
					end
				end
			else
				if ( not sourceIndex ) then
					-- candidate for #3
					sourceIndex = i;
				end
			end
		end
	end
	return sourceIndex or 1;
end

function WardrobeCollectionFrame_SetAppearanceTooltip(appearanceID, sourceID)
	WardrobeCollectionFrame.tooltipAppearanceID = appearanceID;
	WardrobeCollectionFrame.tooltipSourceID = sourceID;

	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(appearanceID);

	for i = 1, #sources do
		if ( sources[i].isHideVisual ) then
			GameTooltip:SetText(sources[i].name);
			return;
		end
	end

	local headerIndex;
	if ( not WardrobeCollectionFrame.tooltipSourceIndex ) then
		headerIndex = WardrobeCollectionFrame_GetDefaultSourceIndex(appearanceID, sourceID);
	else
		headerIndex = WardrobeUtils_GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources);
	end
	WardrobeCollectionFrame.tooltipSourceIndex = headerIndex;
	headerSourceID = sources[headerIndex].sourceID;

	local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[headerIndex]);
	GameTooltip:SetText(name, nameColor.r, nameColor.g, nameColor.b);

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
	if ( not sources[headerIndex].isCollected ) then
		GameTooltip:AddLine(sourceText, sourceColor.r, sourceColor.g, sourceColor.b, 1, 1);
	end

	local useError;
	local appearanceCollected = sources[headerIndex].isCollected
	if ( #sources > 1 and not appearanceCollected ) then
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

	if ( appearanceCollected  ) then
		if ( useError ) then
			GameTooltip:AddLine(useError, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		elseif ( not WardrobeFrame_IsAtTransmogrifier() ) then
			GameTooltip:AddLine(WARDROBE_TOOLTIP_TRANSMOGRIFIER, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1, 1);
		end
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
		sourceText = TRANSMOG_COLLECTED;
		sourceColor = GREEN_FONT_COLOR;
	else
		sourceText = _G["TRANSMOG_SOURCE_"..source.sourceType];
		sourceColor = HIGHLIGHT_FONT_COLOR;
	end

	return name, nameColor, sourceText, sourceColor;
end

function WardrobeItemsCollectionMixin:GetChosenVisualSource(visualID)
	return self.chosenVisualSources[visualID] or NO_TRANSMOG_SOURCE_ID;
end

function WardrobeItemsCollectionMixin:SetChosenVisualSource(visualID, sourceID)
	self.chosenVisualSources[visualID] = sourceID;
end

function WardrobeItemsCollectionMixin:ValidateChosenVisualSources()
	for visualID, sourceID in pairs(self.chosenVisualSources) do
		if ( sourceID ~= NO_TRANSMOG_SOURCE_ID ) then
			local keep = false;
			local sources = C_TransmogCollection.GetAppearanceSources(visualID);
			if ( sources ) then
				for i = 1, #sources do
					if ( sources[i].sourceID == sourceID ) then
						if ( sources[i].isCollected and not sources[i].useError ) then
							keep = true;
						end
						break;
					end
				end
			end
			if ( not keep ) then
				self.chosenVisualSources[visualID] = NO_TRANSMOG_SOURCE_ID;
			end
		end
	end
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
		if ( not C_TransmogCollection.CanSetFavoriteInCategory(WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory()) ) then
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
	local chosenSourceID = WardrobeCollectionFrame.ItemsCollectionFrame:GetChosenVisualSource(appearanceID);
	info.func = WardrobeCollectionFrameModelDropDown_SetSource;
	for i = 1, #sources do
		if ( sources[i].isCollected and not sources[i].useError ) then
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
			-- choose the 1st valid source if one isn't explicitly chosen
			if ( chosenSourceID == NO_TRANSMOG_SOURCE_ID ) then
				chosenSourceID = sources[i].sourceID;
			end
			info.checked = (chosenSourceID == sources[i].sourceID);
			UIDropDownMenu_AddButton(info);
		end
	end
end

function WardrobeCollectionFrameModelDropDown_SetSource(self, visualID, sourceID)
	WardrobeCollectionFrame.ItemsCollectionFrame:SetChosenVisualSource(visualID, sourceID);
end

function WardrobeCollectionFrameModelDropDown_SetFavorite(self, visualID, value)
	local set = (value == 1);
	C_TransmogCollection.SetIsAppearanceFavorite(visualID, set);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true);
	WardrobeCollectionFrame.ItemsCollectionFrame.HelpBox:Hide();
end

-- ***** WEAPON DROPDOWN

function WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameWeaponDropDown_Init(self)
	local slot = WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveSlot();
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
	if ( category and WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory() ~= category ) then
		CloseDropDownMenus();
		WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveCategory(category);
	end	
end

-- ***** NAVIGATION

function WardrobeItemsCollectionMixin:OnPageChanged(userAction)
	PlaySound("UI_Transmog_PageTurn");
	CloseDropDownMenus();
	if ( userAction ) then
		self:UpdateItems();
	end
end

-- ***** SEARCHING

function WardrobeCollectionFrame_SwitchSearchCategory()
	if ( WardrobeCollectionFrame.ItemsCollectionFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		WardrobeCollectionFrame_ClearSearch();
		WardrobeCollectionFrame.searchBox:Disable();
		WardrobeCollectionFrame.FilterButton:Disable();
		return;
	end

	WardrobeCollectionFrame.searchBox:Enable();
	WardrobeCollectionFrame.FilterButton:Enable();
	if ( WardrobeCollectionFrame.searchBox:GetText() ~= "" )  then
		local finished = C_TransmogCollection.SetSearch(WardrobeCollectionFrame.activeFrame.searchType, WardrobeCollectionFrame.searchBox:GetText());
		if ( not finished ) then
			WardrobeCollectionFrame_RestartSearchTracking();
		end
	end
end

function WardrobeItemsCollectionMixin:OnSearchUpdate(category)
	if ( category ~= self.activeCategory ) then
		return;
	end

	self:RefreshVisualsList();
	if ( self.resetPageOnSearchUpdated ) then
		self.resetPageOnSearchUpdated = nil;
		self:ResetPage();
	elseif ( WardrobeFrame_IsAtTransmogrifier() and WardrobeCollectionFrameSearchBox:GetText() == "" ) then
		local _, _, selectedSourceID = WardrobeCollectionFrame_GetInfoForEquippedSlot(self.activeSlot, self.transmogType);
		WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, self.activeSlot, self.transmogType, true);
	else
		self:UpdateItems();
	end
end

function WardrobeCollectionFrame_RestartSearchTracking()
	if ( WardrobeCollectionFrame.activeFrame.transmogType == LE_TRANSMOG_TYPE_ILLUSION ) then
		return;
	end

	local searchSize = C_TransmogCollection.SearchSize(WardrobeCollectionFrame.activeFrame.searchType);
	local searchProgress = C_TransmogCollection.SearchProgress(WardrobeCollectionFrame.activeFrame.searchType);

	WardrobeCollectionFrame.searchProgressFrame:Hide();
	WardrobeCollectionFrame.searchBox.updateDelay = 0;
	if ( not C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame.activeFrame.searchType) ) then
		WardrobeCollectionFrame.activeFrame:OnSearchUpdate();
	else
		WardrobeCollectionFrame.searchBox:SetScript("OnUpdate", WardrobeCollectionFrameSearchBox_OnUpdate);
	end
end

function WardrobeCollectionFrame_ClearSearch(searchType)
	WardrobeCollectionFrame.searchBox:SetText("");
	WardrobeCollectionFrame.searchProgressFrame:Hide();
	C_TransmogCollection.ClearSearch(searchType or WardrobeCollectionFrame.activeFrame.searchType);
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
	local searchSize = C_TransmogCollection.SearchSize(WardrobeCollectionFrame.activeFrame.searchType);
	local searchProgress = C_TransmogCollection.SearchProgress(WardrobeCollectionFrame.activeFrame.searchType);
	self:SetValue((searchProgress * maxValue) / searchSize);
	
	if ( not C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame.activeFrame.searchType) ) then
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
	
	if ( not C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame.activeFrame.searchType) ) then
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
		C_TransmogCollection.ClearSearch(WardrobeCollectionFrame.activeFrame.searchType);
	else
		C_TransmogCollection.SetSearch(WardrobeCollectionFrame.activeFrame.searchType, text);
	end
	
	WardrobeCollectionFrame_RestartSearchTracking();
end

-- ***** FILTER

function WardrobeFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeFilterDropDown_Initialize, "MENU");
end

function WardrobeFilterDropDown_Initialize(self, level)
	if ( not WardrobeCollectionFrame.activeFrame ) then
		return;
	end

	if ( WardrobeCollectionFrame.activeFrame.searchType == LE_TRANSMOG_SEARCH_TYPE_ITEMS ) then
		WardrobeFilterDropDown_InitializeItems(self, level);
	elseif ( WardrobeCollectionFrame.activeFrame.searchType == LE_TRANSMOG_SEARCH_TYPE_BASE_SETS ) then
		WardrobeFilterDropDown_InitializeBaseSets(self, level);
	end
end

function WardrobeFilterDropDown_InitializeItems(self, level)
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

function WardrobeFilterDropDown_InitializeBaseSets(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	info.isNotRadio = true;

	info.text = COLLECTED;
	info.func = function(_, _, _, value)
					C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_COLLECTED, value);
				end 
	info.checked = C_TransmogSets.GetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_COLLECTED);
	UIDropDownMenu_AddButton(info, level);

	info.text = NOT_COLLECTED;
	info.func = function(_, _, _, value)
					C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_UNCOLLECTED, value);
				end 
	info.checked = C_TransmogSets.GetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_UNCOLLECTED);
	UIDropDownMenu_AddButton(info, level);

	info.text = TRANSMOG_SET_PVE;
	info.func = function(_, _, _, value)
					C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_PVE, value);
				end 
	info.checked = C_TransmogSets.GetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_PVE);
	UIDropDownMenu_AddButton(info, level);

	info.text = TRANSMOG_SET_PVP;
	info.func = function(_, _, _, value)
					C_TransmogSets.SetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_PVP, value);
				end 
	info.checked = C_TransmogSets.GetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_PVP);
	UIDropDownMenu_AddButton(info, level);
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

-- ************************************************************************************************************************************************************
-- **** SETS LIST *********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local BASE_SET_BUTTON_HEIGHT = 46;
local VARIANT_SET_BUTTON_HEIGHT = 20;
local SET_PROGRESS_BAR_MAX_WIDTH = 204;
local IN_PROGRESS_FONT_COLOR = CreateColor(0.251, 0.753, 0.251);
local IN_PROGRESS_FONT_COLOR_CODE = "|cff40c040";

WardrobeSetsDataProviderMixin = {};

function WardrobeSetsDataProviderMixin:SortSets(sets)
	local comparison = function(set1, set2)
		local groupFavorite1 = set1.favoriteSetID and true;
		local groupFavorite2 = set2.favoriteSetID and true;
		if ( groupFavorite1 ~= groupFavorite2 ) then
			return groupFavorite1;
		end
		if ( set1.uiOrder ~= set2.uiOrder ) then
			return set1.uiOrder > set2.uiOrder;
		end
		return set1.setID > set2.setID;
	end

	table.sort(sets, comparison);
end

function WardrobeSetsDataProviderMixin:GetBaseSets()
	if ( not self.baseSets ) then
		self.baseSets = C_TransmogSets.GetBaseSets();
		self:DetermineFavorites();
		self:SortSets(self.baseSets);
	end
	return self.baseSets;
end

function WardrobeSetsDataProviderMixin:GetBaseSetByID(baseSetID)
	local baseSets = self:GetBaseSets();
	for i = 1, #baseSets do
		if ( baseSets[i].setID == baseSetID ) then
			return baseSets[i], i;
		end
	end
	return nil, nil;
end

function WardrobeSetsDataProviderMixin:GetUsableSets()
	if ( not self.usableSets ) then
		self.usableSets = C_TransmogSets.GetUsableSets();
		self:SortSets(self.usableSets);
	end
	return self.usableSets;
end

function WardrobeSetsDataProviderMixin:GetVariantSets(baseSetID)
	if ( not self.variantSets ) then
		self.variantSets = { };
	end

	local variantSets = self.variantSets[baseSetID];
	if ( not variantSets ) then
		variantSets = C_TransmogSets.GetVariantSets(baseSetID);
		self.variantSets[baseSetID] = variantSets;
		if ( #variantSets > 0 ) then
			-- add base to variants and sort
			local baseSet = self:GetBaseSetByID(baseSetID);
			if ( baseSet ) then
				tinsert(variantSets, baseSet);
			end
			self:SortSets(variantSets);
		end
	end
	return variantSets;
end

function WardrobeSetsDataProviderMixin:GetSetSourceData(setID)
	if ( not self.sourceData ) then
		self.sourceData = { };
	end

	local sourceData = self.sourceData[setID];
	if ( not sourceData ) then
		local sources = C_TransmogSets.GetSetSources(setID);
		local numCollected = 0;
		local numTotal = 0;
		for sourceID, collected in pairs(sources) do
			if ( collected ) then
				numCollected = numCollected + 1;
			end
			numTotal = numTotal + 1;
		end
		sourceData = { numCollected = numCollected, numTotal = numTotal, sources = sources };
		self.sourceData[setID] = sourceData;
	end
	return sourceData;
end

function WardrobeSetsDataProviderMixin:GetSetSources(setID)
	return self:GetSetSourceData(setID).sources;
end

function WardrobeSetsDataProviderMixin:GetSetSourceCounts(setID)
	local sourceData = self:GetSetSourceData(setID);
	return sourceData.numCollected, sourceData.numTotal;
end

function WardrobeSetsDataProviderMixin:GetBaseSetData(setID)
	if ( not self.baseSetsData ) then
		self.baseSetsData = { };
	end
	if ( not self.baseSetsData[setID] ) then
		local baseSetID = C_TransmogSets.GetBaseSetID(setID);
		if ( baseSetID ~= setID ) then
			return;
		end
		local topCollected, topTotal = self:GetSetSourceCounts(setID);
		local variantSets = self:GetVariantSets(setID);
		for i = 1, #variantSets do
			local numCollected, numTotal = self:GetSetSourceCounts(variantSets[i].setID);
			if ( numCollected > topCollected ) then
				topCollected = numCollected;
				topTotal = numTotal;
			end
		end
		local setInfo = { topCollected = topCollected, topTotal = topTotal, completed = (topCollected == topTotal) };
		self.baseSetsData[setID] = setInfo;
	end
	return self.baseSetsData[setID];
end

function WardrobeSetsDataProviderMixin:GetSetSourceTopCounts(setID)
	local baseSetData = self:GetBaseSetData(setID);
	if ( baseSetData ) then
		return baseSetData.topCollected, baseSetData.topTotal;
	else
		return self:GetSetSourceCounts(setID);
	end
end

function WardrobeSetsDataProviderMixin:GetSetsCounts()
	local baseSets = self:GetBaseSets();
	local numTotalSets = 0;
	local numCollectedSets = 0;
	for i = 1, #baseSets do
		local baseSet = baseSets[i];
		numTotalSets = numTotalSets + 1;
		local numCollected, numTotal = self:GetSetSourceCounts(baseSet.setID);
		if ( numCollected == numTotal ) then
			numCollectedSets = numCollectedSets + 1;
		end
		local variantSets = self:GetVariantSets(baseSet.setID);
		for variantIndex = 1, #variantSets do
			local variantSet = variantSets[variantIndex];
			if ( variantSet.setID ~= baseSet.setID ) then
				numTotalSets = numTotalSets + 1;
				numCollected, numTotal = self:GetSetSourceCounts(variantSet.setID);
				if ( numCollected == numTotal ) then
					numCollectedSets = numCollectedSets + 1;
				end
			end
		end
	end
	return numCollectedSets, numTotalSets;
end

function WardrobeSetsDataProviderMixin:GetSortedSetSources(setID)
	local returnTable = { };
	local sourceData = self:GetSetSourceData(setID);
	for sourceID, collected in pairs(sourceData.sources) do
		local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
		if ( sourceInfo ) then
			local sortOrder = EJ_GetInvTypeSortOrder(sourceInfo.invType);
			tinsert(returnTable, { sourceID = sourceID, collected = collected, sortOrder = sortOrder, itemID = sourceInfo.itemID });
		end
	end

	local comparison = function(entry1, entry2)
		if ( entry1.sortOrder == entry2.sortOrder ) then
			return entry1.itemID < entry2.itemID;
		else
			return entry1.sortOrder < entry2.sortOrder;
		end
	end
	table.sort(returnTable, comparison);
	return returnTable;
end

function WardrobeSetsDataProviderMixin:ClearSets()
	self.baseSets = nil;
	self.baseSetsData = nil;
	self.variantSets = nil;
	self.usableSets = nil;
	self.sourceData = nil;
end

function WardrobeSetsDataProviderMixin:ClearBaseSets()
	self.baseSets = nil;
end

function WardrobeSetsDataProviderMixin:ClearVariantSets()
	self.variantSets = nil;
end

function WardrobeSetsDataProviderMixin:ClearUsableSets()
	self.usableSets = nil;
end

function WardrobeSetsDataProviderMixin:GetIconForSet(setID)
	local sourceData = self:GetSetSourceData(setID);
	if ( not sourceData.icon ) then
		local sortedSources = self:GetSortedSetSources(setID);
		if ( sortedSources[1] ) then
			local _, _, _, _, icon = GetItemInfoInstant(sortedSources[1].itemID);
			sourceData.icon = icon;
		else
			sourceData.icon = QUESTION_MARK_ICON;
		end
	end
	return sourceData.icon;
end

function WardrobeSetsDataProviderMixin:DetermineFavorites()
	-- if a variant is favorited, so is the base set
	-- keep track of which set is favorited
	local baseSets = self:GetBaseSets();
	for i = 1, #baseSets do
		local baseSet = baseSets[i];
		baseSet.favoriteSetID = nil;
		if ( baseSet.favorite ) then
			baseSet.favoriteSetID = baseSet.setID;
		else
			local variantSets = self:GetVariantSets(baseSet.setID);
			for j = 1, #variantSets do
				if ( variantSets[j].favorite ) then
					baseSet.favoriteSetID = variantSets[j].setID;
					break;
				end
			end
		end
	end
end

function WardrobeSetsDataProviderMixin:RefreshFavorites()
	self.baseSets = nil;
	self.variantSets = nil;
	self:DetermineFavorites();
end

local SetsDataProvider = CreateFromMixins(WardrobeSetsDataProviderMixin);

WardrobeSetsCollectionMixin = {};

function WardrobeSetsCollectionMixin:OnLoad()
	self.BackgroundTile:SetPoint("TOPLEFT", 282, -4);
	self.BGCornerTopLeft:Hide();
	self.BGCornerTopRight:Hide();

	self.DetailsFrame.Name:SetFontObjectsToTry(Fancy24Font, Fancy20Font, Fancy16Font);
	self.DetailsFrame.itemFramesPool = CreateFramePool("FRAME", self, "WardrobeSetsDetailsItemFrameTemplate");

	self.selectedVariantSets = { };
end

function WardrobeSetsCollectionMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	-- select the first set if not init
	local baseSets = SetsDataProvider:GetBaseSets();
	if ( not self.init and baseSets and baseSets[1] ) then
		self.init = true;
		self:SelectSet(self:GetDefaultSetIDForBaseSet(baseSets[1].setID));
	else
		self:Refresh();
	end
	WardrobeCollectionFrame_UpdateProgressBar(SetsDataProvider:GetSetsCounts());
end

function WardrobeSetsCollectionMixin:OnHide()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	self:UnregisterEvent("TRANSMOG_COLLECTION_UPDATED");
	SetsDataProvider:ClearSets();
	WardrobeCollectionFrame_ClearSearch(LE_TRANSMOG_SEARCH_TYPE_BASE_SETS);
end

function WardrobeSetsCollectionMixin:OnEvent(event, ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		for itemFrame in self.DetailsFrame.itemFramesPool:EnumerateActive() do
			if ( itemFrame.itemID == itemID ) then
				self:SetItemFrameQuality(itemFrame);
				break;
			end
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" ) then
		SetsDataProvider:ClearSets();
		self:Refresh();
		WardrobeCollectionFrame_UpdateProgressBar(SetsDataProvider:GetSetsCounts());
	end
end

function WardrobeSetsCollectionMixin:Refresh()
	self.ScrollFrame:Update();
	self:DisplaySet(self:GetSelectedSetID());
end

function WardrobeSetsCollectionMixin:DisplaySet(setID)
	local setInfo = C_TransmogSets.GetSetInfo(setID);
	self.DetailsFrame.Name:SetText(setInfo.name);
	self.DetailsFrame.Label:SetText(setInfo.label);

	self.DetailsFrame.itemFramesPool:ReleaseAll();
	self.DetailsFrame.Model:Undress();
	local BUTTON_SPACE = 37;	-- button width + spacing between 2 buttons
	local sortedSources = SetsDataProvider:GetSortedSetSources(setID);
	local xOffset = -floor((#sortedSources - 1) * BUTTON_SPACE / 2);
	for i = 1, #sortedSources do
		local itemFrame = self.DetailsFrame.itemFramesPool:Acquire();
		itemFrame.sourceID = sortedSources[i].sourceID;
		itemFrame.itemID = sortedSources[i].itemID;
		itemFrame.collected = sortedSources[i].collected;
		local _, _, _, _, texture = GetItemInfoInstant(sortedSources[i].itemID);
		itemFrame.Icon:SetTexture(texture);
		if ( sortedSources[i].collected ) then
			itemFrame.Icon:SetDesaturated(false);
			itemFrame.Icon:SetAlpha(1);
			itemFrame.IconBorder:SetDesaturation(0);
			itemFrame.IconBorder:SetAlpha(1);
		else
			itemFrame.Icon:SetDesaturated(true);
			itemFrame.Icon:SetAlpha(0.3);
			itemFrame.IconBorder:SetDesaturation(1);
			itemFrame.IconBorder:SetAlpha(0.3);
		end
		self:SetItemFrameQuality(itemFrame);
		itemFrame:SetPoint("TOP", self.DetailsFrame, "TOP", xOffset + (i - 1) * BUTTON_SPACE, -97);
		itemFrame:Show();
		self.DetailsFrame.Model:TryOn(sortedSources[i].sourceID);
	end

	-- variant sets
	local baseSetID = C_TransmogSets.GetBaseSetID(setID);
	local variantSets = SetsDataProvider:GetVariantSets(baseSetID);
	if ( #variantSets == 0 )  then
		self.DetailsFrame.VariantSetsButton:Hide();
	else
		self.DetailsFrame.VariantSetsButton:Show();
		self.DetailsFrame.VariantSetsButton:SetText(setInfo.description);
	end
end

function WardrobeSetsCollectionMixin:SetItemFrameQuality(itemFrame)
	local _, quality;
	if ( itemFrame.collected ) then
		_, _, quality = GetItemInfo(itemFrame.itemID);
	end
	if ( quality == LE_ITEM_QUALITY_UNCOMMON ) then
		itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-green", true);
	elseif ( quality == LE_ITEM_QUALITY_RARE ) then
		itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-blue", true);
	elseif ( quality == LE_ITEM_QUALITY_EPIC ) then
		itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-purple", true);
	end
end

function WardrobeSetsCollectionMixin:OnSearchUpdate()
	if ( self.init ) then
		SetsDataProvider:ClearBaseSets();
		self:Refresh();
	end
end

function WardrobeSetsCollectionMixin:OnUnitModelChangedEvent()
	if ( self.DetailsFrame.Model:CanSetUnit("player") ) then
		self.DetailsFrame.Model:RefreshUnit();
		self:Refresh();
		return true;
	else
		return false;
	end
end

function WardrobeSetsCollectionMixin:OpenVariantSetsDropDown()
	local selectedSetID = self:GetSelectedSetID();
	if ( not selectedSetID ) then
		return;
	end
	local info = UIDropDownMenu_CreateInfo();
	local baseSetID = C_TransmogSets.GetBaseSetID(selectedSetID);
	local variantSets = SetsDataProvider:GetVariantSets(baseSetID);
	for i = 1, #variantSets do
		local variantSet = variantSets[i];
		-- TODO: Remove this when all sets get descriptions entered
		if ( not variantSet.description ) then
			variantSet.description = "Set ID "..variantSet.setID;
		end
		local numSourcesCollected, numSourcesTotal = SetsDataProvider:GetSetSourceCounts(variantSet.setID);
		local colorCode = IN_PROGRESS_FONT_COLOR_CODE;
		if ( numSourcesCollected == numSourcesTotal ) then
			colorCode = NORMAL_FONT_COLOR_CODE;
		elseif ( numSourcesCollected == 0 ) then
			colorCode = GRAY_FONT_COLOR_CODE;
		end
		info.text = format(ITEM_SET_NAME, variantSet.description..colorCode, numSourcesCollected, numSourcesTotal);
		info.checked = (variantSet.setID == selectedSetID);
		info.func = function() self:SelectSet(variantSet.setID); end;
		UIDropDownMenu_AddButton(info);
	end
end

function WardrobeSetsCollectionMixin:GetDefaultSetIDForBaseSet(baseSetID)
	if ( self.selectedVariantSets[baseSetID] ) then
		return self.selectedVariantSets[baseSetID];
	end
	local baseSet = SetsDataProvider:GetBaseSetByID(baseSetID);
	if ( baseSet.favoriteSetID ) then
		return baseSet.favoriteSetID;
	end
	return baseSetID;
end

function WardrobeSetsCollectionMixin:SelectSetFromButton(setID)
	self:SelectSet(self:GetDefaultSetIDForBaseSet(setID));
end

function WardrobeSetsCollectionMixin:SelectSet(setID)
	self.selectedSetID = setID;

	local baseSetID = C_TransmogSets.GetBaseSetID(setID);
	local variantSets = SetsDataProvider:GetVariantSets(baseSetID);
	if ( #variantSets > 0 ) then
		self.selectedVariantSets[baseSetID] = setID;
	end

	self:Refresh();
end

function WardrobeSetsCollectionMixin:GetSelectedSetID()
	return self.selectedSetID;
end

do
	local function OpenVariantSetsDropDown(self)
		self:GetParent():GetParent():OpenVariantSetsDropDown();
	end
	function WardrobeSetsCollectionVariantSetsDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenVariantSetsDropDown, "MENU");
	end
end

WardrobeSetsCollectionScrollFrameMixin = { };

local function WardrobeSetsCollectionScrollFrame_FavoriteDropDownInit(self)
	if ( not self.baseSetID ) then
		return;
	end

	local baseSet = SetsDataProvider:GetBaseSetByID(self.baseSetID);
	local variantSets = SetsDataProvider:GetVariantSets(self.baseSetID);
	local useDescription = (#variantSets > 0);

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.disabled = nil;

	if ( baseSet.favoriteSetID ) then
		if ( useDescription ) then
			local setInfo = C_TransmogSets.GetSetInfo(baseSet.favoriteSetID);
			info.text = format(TRANSMOG_SETS_UNFAVORITE_WITH_DESCRIPTION, setInfo.description);
		else
			info.text = BATTLE_PET_UNFAVORITE;
		end
		info.func = function()
			C_TransmogSets.SetIsFavorite(baseSet.favoriteSetID, false);
		end
	else
		local targetSetID = WardrobeCollectionFrame.SetsCollectionFrame:GetDefaultSetIDForBaseSet(self.baseSetID);
		if ( useDescription ) then
			local setInfo = C_TransmogSets.GetSetInfo(targetSetID);
			info.text = format(TRANSMOG_SETS_FAVORITE_WITH_DESCRIPTION, setInfo.description);
		else
			info.text = BATTLE_PET_FAVORITE;
		end
		info.func = function()
			C_TransmogSets.SetIsFavorite(targetSetID, true);
		end
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	info.text = CANCEL;
	info.func = nil;
	UIDropDownMenu_AddButton(info, level);
end

function WardrobeSetsCollectionScrollFrameMixin:OnLoad()
	self.scrollBar.trackBG:Show();
	self.scrollBar.trackBG:SetVertexColor(0, 0, 0, 0.75);
	self.scrollBar.doNotHide = true;
	self.update = self.Update;
	HybridScrollFrame_CreateButtons(self, "WardrobeSetsScrollFrameButtonTemplate", 44, 0);
	UIDropDownMenu_Initialize(self.FavoriteDropDown, WardrobeSetsCollectionScrollFrame_FavoriteDropDownInit, "MENU");
end

function WardrobeSetsCollectionScrollFrameMixin:OnShow()
	self:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
end

function WardrobeSetsCollectionScrollFrameMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
end

function WardrobeSetsCollectionScrollFrameMixin:OnEvent(event, ...)
	if ( event == "TRANSMOG_SETS_UPDATE_FAVORITE" ) then
		SetsDataProvider:RefreshFavorites();
		self:Update();
	end
end

function WardrobeSetsCollectionScrollFrameMixin:Update()
	local offset = HybridScrollFrame_GetOffset(self);
	local buttons = self.buttons;
	local baseSets = SetsDataProvider:GetBaseSets();

	-- show the base set as selected
	local selectedBaseSetID = C_TransmogSets.GetBaseSetID(self:GetParent():GetSelectedSetID());

	for i = 1, #buttons do
		local button = buttons[i];
		local setIndex = i + offset;
		if ( setIndex <= #baseSets ) then
			local baseSet = baseSets[setIndex];
			button:Show();
			button.Name:SetText(baseSet.name);
			local numSourcesCollected, numSourcesTotal = SetsDataProvider:GetSetSourceTopCounts(baseSet.setID);
			local color = IN_PROGRESS_FONT_COLOR;
			if ( numSourcesCollected == numSourcesTotal ) then
				color = NORMAL_FONT_COLOR;
			elseif ( numSourcesCollected == 0 ) then
				color = GRAY_FONT_COLOR;
			end
			button.Name:SetTextColor(color.r, color.g, color.b);
			button.Label:SetText(baseSet.label);
			button.Icon:SetTexture(SetsDataProvider:GetIconForSet(baseSet.setID));
			button.Icon:SetDesaturation((numSourcesCollected == 0) and 1 or 0);
			button.SelectedTexture:SetShown(baseSet.setID == selectedBaseSetID);
			button.Favorite:SetShown(baseSet.favoriteSetID);
			button.setID = baseSet.setID;

			if ( numSourcesCollected == 0 or numSourcesCollected == numSourcesTotal ) then
				button.ProgressBar:Hide();
			else
				button.ProgressBar:Show();
				button.ProgressBar:SetWidth(SET_PROGRESS_BAR_MAX_WIDTH * numSourcesCollected / numSourcesTotal);
			end
			button.IconCover:SetShown(numSourcesCollected ~= numSourcesTotal);
		else
			button:Hide();
		end
	end
	
	local extraHeight = (self.largeButtonHeight and self.largeButtonHeight - BASE_SET_BUTTON_HEIGHT) or 0;
	local totalHeight = #baseSets * BASE_SET_BUTTON_HEIGHT + extraHeight;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

WardrobeSetsDetailsItemMixin = { };

function WardrobeSetsDetailsItemMixin:OnEnter()
	local sourceInfo = C_TransmogCollection.GetSourceInfo(self.sourceID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	WardrobeCollectionFrame_SetAppearanceTooltip(sourceInfo.appearanceID, self.sourceID);

	self:SetScript("OnUpdate", 
		function()
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end
	);
end

function WardrobeSetsDetailsItemMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

function WardrobeSetsDetailsItemMixin:OnMouseDown()
	if ( IsModifiedClick("CHATLINK") ) then
		local sourceInfo = C_TransmogCollection.GetSourceInfo(self.sourceID);
		local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(sourceInfo.appearanceID);
		if ( WardrobeCollectionFrame.tooltipSourceIndex ) then
			local index = WardrobeUtils_GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources);
			local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
			if ( link ) then
				HandleModifiedItemClick(link);
			end
		end
	elseif ( IsModifiedClick("DRESSUP") ) then
		DressUpVisual(self.sourceID);
	end
end

WardrobeSetsTransmogMixin = { };

function WardrobeSetsTransmogMixin:OnLoad()
	self.NUM_ROWS = 2;
	self.NUM_COLS = 4;
	self.PAGE_SIZE = self.NUM_ROWS * self.NUM_COLS;
end

function WardrobeSetsTransmogMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:UpdateSets();
	WardrobeCollectionFrame_UpdateProgressBar(SetsDataProvider:GetSetsCounts());
end

function WardrobeSetsTransmogMixin:OnHide()
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self.loadingSetID = nil;
	SetsDataProvider:ClearSets();
end

function WardrobeSetsTransmogMixin:OnEvent(event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" ) then
		self:UpdateSets();
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" ) then
		SetsDataProvider:ClearSets();
		self:UpdateSets();
		WardrobeCollectionFrame_UpdateProgressBar(SetsDataProvider:GetSetsCounts());
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.loadingSetID ) then
			local setID = self.loadingSetID;
			self.loadingSetID = nil;
			self:LoadSet(setID);
		end
	end
end

function WardrobeSetsTransmogMixin:OnMouseWheel(value)
	self.PagingFrame:OnMouseWheel(value);
end

function WardrobeSetsTransmogMixin:UpdateSets()
	local usableSets = SetsDataProvider:GetUsableSets();
	self.PagingFrame:SetMaxPages(ceil(#usableSets / self.PAGE_SIZE));

	local selectedVisuals = { };
	for i = 1, #TRANSMOG_SLOTS do
		if ( TRANSMOG_SLOTS[i].transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local _, _, _, selectedVisualID = WardrobeCollectionFrame_GetInfoForEquippedSlot(TRANSMOG_SLOTS[i].slot, LE_TRANSMOG_TYPE_APPEARANCE);
			selectedVisuals[selectedVisualID] = true;
		end
	end

	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		if ( usableSets[index] ) then
			model:Show();
			model:Undress();
			local setMatches = true;
			local sourceData = SetsDataProvider:GetSetSourceData(usableSets[index].setID);
			for sourceID  in pairs(sourceData.sources) do
				model:TryOn(sourceID);
				local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
				if ( not selectedVisuals[sourceInfo.appearanceID] ) then
					setMatches = false;
				end
			end
			model.TransmogStateTexture:SetShown(setMatches);
			model.setID = usableSets[index].setID;
		else
			model:Hide();
			model.setID = nil;
		end
	end
end

function WardrobeSetsTransmogMixin:OnPageChanged(userAction)
	PlaySound("UI_Transmog_PageTurn");
	CloseDropDownMenus();
	if ( userAction ) then
		self:UpdateSets();
	end
end

function WardrobeSetsTransmogMixin:LoadSet(setID)
	local waitingOnData = false;
	local transmogSources = { };
	local sources = C_TransmogSets.GetSetSources(setID);
	for sourceID in pairs(sources) do
		local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
		local appearanceSources = WardrobeCollectionFrame_GetSortedAppearanceSources(sourceInfo.appearanceID);
		-- if the source in the set is not collected/usable, go with the 1st one
		local transmogSourceID = appearanceSources[1].sourceID;
		for i = 1, #appearanceSources do
			if ( not appearanceSources[i].name ) then
				waitingOnData = true;
			end
			if ( appearanceSources[i].sourceID == sourceID and appearanceSources[i].collected and not appearanceSources[i].useError ) then
				transmogSourceID = sourceID;
				break;
			end
		end
		transmogSources[sourceInfo.invType - 1] = transmogSourceID;
	end
	if ( waitingOnData ) then
		self.loadingSetID = setID;
	else
		self.loadingSetID = nil;
		C_Transmog.LoadSources(transmogSources);
	end
end

function WardrobeSetsTransmogMixin:OnUnitModelChangedEvent()
	if ( self.Models[1]:CanSetUnit("player") ) then
		for i = 1, #self.Models do
			self.Models[i]:RefreshUnit();
		end
		self:UpdateSets();
		return true;
	else
		return false;
	end
end

function WardrobeSetsTransmogMixin:OnSearchUpdate()
	SetsDataProvider:ClearUsableSets();
	self:UpdateSets();
end