TRANSMOG_SHAPESHIFT_MIN_ZOOM = -0.3;

local EXCLUSION_CATEGORY_OFFHAND	= 1;
local EXCLUSION_CATEGORY_MAINHAND	= 2;

-- ************************************************************************************************************************************************************
-- **** MAIN **********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

function WardrobeFrame_OnLoad(self)
	self:SetPortraitToAsset("Interface\\Icons\\INV_Arcane_Orb");
	WardrobeFrameTitleText:SetText(TRANSMOGRIFY);
end

function WardrobeFrame_IsAtTransmogrifier()
	return WardrobeFrame and WardrobeFrame:IsShown();
end

local function GetSlotGlobalString(frame)
	if frame.transmogLocation:GetSlotName() == "SHOULDERSLOT" then
		if GetCVarBool("transmogShouldersSeparately") then
			if frame.transmogLocation:IsRightShoulderModification() then
				return RIGHTSHOULDERSLOT;
			else
				return LEFTSHOULDERSLOT;
			end
		end
	end
	return _G[frame.slot];
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
		local transmogLocation = ...;
		-- play sound?
		local slotButton = WardrobeTransmogFrame_GetSlotButton(transmogLocation);
		if ( slotButton ) then
			local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
			if ( hasUndo ) then
				PlaySound(SOUNDKIT.UI_TRANSMOGRIFY_UNDO);
			elseif ( not hasPending ) then
				if ( slotButton.hadUndo ) then
					PlaySound(SOUNDKIT.UI_TRANSMOGRIFY_REDO);
					slotButton.hadUndo = nil;
				end
			end
			-- specs button tutorial
			if ( hasPending and not hasUndo ) then
				if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON) ) then
					local helpTipInfo = {
						text = TRANSMOG_SPECS_BUTTON_TUTORIAL,
						buttonStyle = HelpTip.ButtonStyle.Close,
						cvarBitfield = "closedInfoFrames",
						bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON,
						targetPoint = HelpTip.Point.BottomEdgeCenter,
					};
					HelpTip:Show(self, helpTipInfo, self.SpecButton);
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
		local transmogLocation = ...;
		local slotButton = WardrobeTransmogFrame_GetSlotButton(transmogLocation);
		if ( slotButton ) then
			WardrobeTransmogFrame_AnimateSlotButton(slotButton);
			WardrobeTransmogFrame_UpdateSlotButton(slotButton);
			-- transmogging a weapon might allow/disallow enchants
			if ( slotButton.transmogLocation:IsMainHand() ) then
				WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.ModelScene.MainHandEnchantButton);
			elseif ( slotButton.transmogLocation:IsOffHand() ) then
				WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.ModelScene.SecondaryHandEnchantButton);
			end
			WardrobeTransmogFrame_UpdateApplyButton();
		end
	elseif ( event == "UNIT_MODEL_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" and IsUnitModelReadyForUI("player") ) then
			local hasAlternateForm, inAlternateForm = HasAlternateForm();
			if ( self.inAlternateForm ~= inAlternateForm ) then
				self.inAlternateForm = inAlternateForm;
				WardrobeTransmogFrame_UpdateModel();
			end
		end
	end
end

function WardrobeTransmogFrame_OnShow(self)
	HideUIPanel(CollectionsJournal);
	WardrobeCollectionFrame_SetContainer(WardrobeFrame);

	PlaySound(SOUNDKIT.UI_TRANSMOG_OPEN_WINDOW);
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( hasAlternateForm ) then
		self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end
	WardrobeTransmogFrame.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
	WardrobeTransmogFrame_UpdateModel();
end

function WardrobeTransmogFrame_OnHide(self)
	PlaySound(SOUNDKIT.UI_TRANSMOG_CLOSE_WINDOW);
	StaticPopup_Hide("TRANSMOG_APPLY_WARNING");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	C_Transmog.Close();
end

function WardrobeTransmogFrame_OnUpdate(self)
	if ( self.dirty ) then
		self.dirty = nil;
		WardrobeTransmogFrame_Update(self);
	end
end

function WardrobeTransmogFrame_UpdateModel()
	if WardrobeTransmogFrame.ModelScene.previousActor then
		WardrobeTransmogFrame.ModelScene.previousActor:ClearModel();
		WardrobeTransmogFrame.ModelScene.previousActor = nil;
	end

	local actor = WardrobeTransmogFrame.ModelScene:GetPlayerActor();
	if actor then
		local sheatheWeapons = false;
		local autoDress = true;
		actor:SetModelByUnit("player", sheatheWeapons, autoDress);
		WardrobeTransmogFrame.ModelScene.previousActor = actor;
	end
	WardrobeTransmogFrame_Update();
end

function WardrobeTransmogFrame_Update()
	for i = 1, #WardrobeTransmogFrame.ModelScene.SlotButtons do
		WardrobeTransmogFrame_UpdateSlotButton(WardrobeTransmogFrame.ModelScene.SlotButtons[i]);
	end
	WardrobeTransmogFrame_UpdateWeaponModel("SECONDARYHANDSLOT"); -- WOW8-56808: Should be updated before the main hand slot
	WardrobeTransmogFrame_UpdateWeaponModel("MAINHANDSLOT");
	WardrobeTransmogFrame_UpdateApplyButton();
	WardrobeTransmogFrame.OutfitDropDown:UpdateSaveButton();

	if ( not WardrobeTransmogFrame.selectedSlotButton or not WardrobeTransmogFrame.selectedSlotButton:IsEnabled() ) then
		-- select first valid slot or clear selection
		local validButton;
		for i = 1, #WardrobeTransmogFrame.ModelScene.SlotButtons do
			local button = WardrobeTransmogFrame.ModelScene.SlotButtons[i];
			if ( button:IsEnabled() and button.transmogLocation:IsAppearance() ) then
				validButton = button;
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
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(slotButton.transmogLocation);
	local hasChange = (hasPending and canTransmogrify) or hasUndo;

	if ( slotButton.transmogLocation:IsAppearance() ) then
		if ( canTransmogrify or hasChange ) then
			slotButton.Icon:SetTexture(texture);
			slotButton.NoItemTexture:Hide();
		else
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			if ( tag  == "NO_ITEM" or tag == "SLOT_FOR_RACE") then
				slotButton.Icon:SetTexture(defaultTexture);
			else
				slotButton.Icon:SetTexture(texture);
			end
			slotButton.NoItemTexture:Show();
		end
	else
		-- check for weapons lacking visual attachments
		local transmogLocation = TransmogUtil.GetCorrespondingHandTransmogLocation(slotButton.transmogLocation);
		local correspondingWeaponButton = WardrobeTransmogFrame_GetSlotButton(transmogLocation);
		local sourceID = WardrobeTransmogFrame_GetDisplayedSource(correspondingWeaponButton);
		if ( sourceID ~= NO_TRANSMOG_SOURCE_ID and not WardrobeCollectionFrame_CanEnchantSource(sourceID) ) then
			-- clear anything in the enchant slot, otherwise cost and Apply button state will still reflect anything pending
			C_Transmog.ClearPending(slotButton.transmogLocation);
			isTransmogrified = false;	-- handle legacy, this weapon could have had an illusion applied previously
			canTransmogrify = false;
			slotButton.invalidWeapon = true;
		else
			slotButton.invalidWeapon = false;
		end

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

	local showModel = slotButton.transmogLocation:IsAppearance();
	if ( slotButton.transmogLocation:IsEitherHand() ) then
		-- weapons get done in WardrobeTransmogFrame_UpdateWeaponModel to package item and enchant together
		showModel = false;
	end
	if ( showModel ) then
		local actor = WardrobeTransmogFrame.ModelScene:GetPlayerActor();
		if actor then
			local sourceID = WardrobeTransmogFrame_GetDisplayedSource(slotButton);
			if ( sourceID == NO_TRANSMOG_SOURCE_ID ) then
				actor:UndressSlot(slotID);
			else
				-- only update if different
				local existingAppearanceSourceID = actor:GetSlotTransmogSources(slotID);
				if ( existingAppearanceSourceID ~= sourceID ) then
					actor:TryOn(sourceID);
				end
			end
		end
	end
end

function WardrobeTransmogFrame_UpdateWeaponModel(slot)
	local actor = WardrobeTransmogFrame.ModelScene:GetPlayerActor();
	if not actor then
		return;
	end
	
	local weaponSlotButton, enchantSlotButton;
	if ( slot == "MAINHANDSLOT" ) then
		weaponSlotButton = WardrobeTransmogFrame.ModelScene.MainHandButton;
		enchantSlotButton = WardrobeTransmogFrame.ModelScene.MainHandEnchantButton;
	else
		weaponSlotButton = WardrobeTransmogFrame.ModelScene.SecondaryHandButton;
		enchantSlotButton = WardrobeTransmogFrame.ModelScene.SecondaryHandEnchantButton;
	end

	local slotID = GetInventorySlotInfo(slot);
	local appearanceSourceID = WardrobeTransmogFrame_GetDisplayedSource(weaponSlotButton);
	if ( appearanceSourceID ~= NO_TRANSMOG_SOURCE_ID ) then
		local illusionSourceID = WardrobeTransmogFrame_GetDisplayedSource(enchantSlotButton);
		-- check existing equipped on model. we don't want to update it if the same because the hand will open/close.
		local existingAppearanceSourceID, existingIllustionSourceID = actor:GetSlotTransmogSources(slotID);
		if ( existingAppearanceSourceID ~= appearanceSourceID or existingIllustionSourceID ~= illusionSourceID ) then
			if slot then
				-- don't specify a slot when applying or removing ranged weapons because of bows
				local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
				local existingCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(existingAppearanceSourceID);
				if ( WardrobeUtils_IsCategoryRanged(categoryID) or WardrobeUtils_IsCategoryRanged(existingCategoryID) ) then
					slot = nil;
				end
				actor:TryOn(appearanceSourceID, slot, illusionSourceID);
			end
		end
	else
		actor:UndressSlot(slotID);
	end
end

function WardrobeTransmogFrame_GetDisplayedSource(slotButton)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, appliedCategoryID, pendingSourceID, pendingVisualID, pendingCategoryID, hasPendingUndo, hideVisual = C_Transmog.GetSlotVisualInfo(slotButton.transmogLocation);
	if ( hideVisual ) then
		return 0;
	elseif ( pendingSourceID ~= REMOVE_TRANSMOG_ID ) then
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
	local isTransmogrified = C_Transmog.GetSlotInfo(slotButton.transmogLocation);
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
	WardrobeTransmogFrame.ModelScene.ClearAllPendingButton:SetShown(canApply);
end

function WardrobeTransmogFrame_GetSlotButton(transmogLocation)
	for i = 1, #WardrobeTransmogFrame.ModelScene.SlotButtons do
		local slotButton = WardrobeTransmogFrame.ModelScene.SlotButtons[i];
		if slotButton.transmogLocation:IsEqual(transmogLocation) then
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
			WardrobeTransmogFrame_OnTransmogApplied();
			PlaySound(SOUNDKIT.UI_TRANSMOG_APPLY);
			WardrobeTransmogFrame.applyWarningsTable = nil;
			-- outfit tutorial
			if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN) ) then
				local outfits = C_TransmogCollection.GetOutfits();
				if ( #outfits == 0 ) then
					local helpTipInfo = {
						text = TRANSMOG_OUTFIT_DROPDOWN_TUTORIAL,
						buttonStyle = HelpTip.ButtonStyle.Close,
						cvarBitfield = "closedInfoFrames",
						bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN,
						targetPoint = HelpTip.Point.RightEdgeCenter,
						offsetX = -18,
					};
					HelpTip:Show(WardrobeTransmogFrame, helpTipInfo, WardrobeTransmogFrame.OutfitDropDown);
				end
			end
		else
			-- it's retrieving item info
			WardrobeTransmogFrame.redoApply = true;
		end
		return false;
	end
end

function WardrobeTransmogFrame_OnTransmogApplied()
	if WardrobeOutfitDropDown.selectedOutfitID and WardrobeOutfitDropDown:IsOutfitDressed() then
		WardrobeTransmogFrame.OutfitDropDown:OnOutfitApplied(WardrobeOutfitDropDown.selectedOutfitID);
	end
end

function WardrobeTransmogFrame_ToggleRightShoulderDisplay(show)
	local headButton = WardrobeTransmogFrame.ModelScene.HeadButton;
	local rightShoulderButton = WardrobeTransmogFrame.ModelScene.RightShoulderButton;

	rightShoulderButton:SetShown(show);
	if show then
		headButton:SetPoint("TOP", -121, -15);
		rightShoulderButton:SetPoint("TOP", headButton, "BOTTOM", 0, -10);
	else
		headButton:SetPoint("TOP", -121, -41);
		rightShoulderButton:SetPoint("TOP", headButton, "TOP");
	end

	if WardrobeTransmogFrame.selectedSlotButton == rightShoulderButton then
		WardrobeTransmogButton_Select(WardrobeTransmogFrame.ModelScene.ShoulderButton);
	end
	C_Transmog.ClearPending(rightShoulderButton.transmogLocation);
end

WardrobeOutfitMixin = { };

function WardrobeOutfitMixin:OnOutfitApplied(outfitID)
	local value = outfitID or "";
	if GetCVarBool("transmogCurrentSpecOnly") then
		local specIndex = GetSpecialization();
		SetCVar("lastTransmogOutfitIDSpec"..specIndex, value);
	else
		for specIndex = 1, GetNumSpecializations() do
			SetCVar("lastTransmogOutfitIDSpec"..specIndex, value);
		end
	end
end

function WardrobeOutfitMixin:LoadOutfit(outfitID)
	if ( not outfitID ) then
		return;
	end
	C_Transmog.LoadOutfit(outfitID);
end

function WardrobeOutfitMixin:GetSlotSourceID(transmogLocation)
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
	if ( not canTransmogrify and not hasUndo ) then
		return NO_TRANSMOG_SOURCE_ID;
	end

	local _, _, sourceID = TransmogUtil.GetInfoForEquippedSlot(transmogLocation);
	return sourceID;
end

function WardrobeOutfitMixin:OnOutfitSaved(outfitID)
	local cost, numChanges = C_Transmog.GetCost();
	if numChanges == 0 then
		self:OnOutfitApplied(outfitID);
	end
end

function WardrobeOutfitMixin:OnSelectOutfit(outfitID)
	-- outfitID can be 0, so use empty string for none
	local value = outfitID or "";
	for specIndex = 1, GetNumSpecializations() do
		if GetCVar("lastTransmogOutfitIDSpec"..specIndex) == "" then
			SetCVar("lastTransmogOutfitIDSpec"..specIndex, value);
		end
	end
end

function WardrobeOutfitMixin:GetLastOutfitID()
	local specIndex = GetSpecialization();
	return tonumber(GetCVar("lastTransmogOutfitIDSpec"..specIndex));
end

-- ***** BUTTONS

function WardrobeTransmogButton_OnLoad(self)
	local slotID, textureName = GetInventorySlotInfo(self.slot);
	self.slotID = slotID;
	self.transmogLocation = TransmogUtil.GetTransmogLocation(slotID, self.transmogType, self.modification);
	if self.transmogLocation:IsAppearance() then
		self.Icon:SetTexture(textureName);
	else
		self.Icon:SetTexture(ENCHANT_EMPTY_SLOT_FILEDATAID);
	end
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function WardrobeTransmogButton_OnClick(self, button)
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(self.transmogLocation);
	-- save for sound to play on TRANSMOGRIFY_UPDATE event
	self.hadUndo = hasUndo;
	if ( button == "RightButton" ) then
		if ( hasPending or hasUndo ) then
			PlaySound(SOUNDKIT.UI_TRANSMOG_REVERTING_GEAR_SLOT);
			C_Transmog.ClearPending(self.transmogLocation);
			WardrobeTransmogButton_Select(self, true);
		elseif ( isTransmogrified ) then
			PlaySound(SOUNDKIT.UI_TRANSMOG_REVERTING_GEAR_SLOT);
			C_Transmog.SetPending(self.transmogLocation, 0);
			WardrobeTransmogButton_Select(self, true);
		end
	else
		PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
		WardrobeTransmogButton_Select(self, true);
	end
	if ( self.UndoButton ) then
		self.UndoButton:Hide();
	end
	WardrobeTransmogButton_OnEnter(self);
end

function WardrobeTransmogButton_OnEnter(self)
	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(self.transmogLocation);

	if ( self.transmogLocation:IsIllusion() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		GameTooltip:SetText(WEAPON_ENCHANTMENT);
		local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, appliedCategoryID, pendingSourceID, pendingVisualID, pendingCategoryID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(self.transmogLocation);
		if ( self.invalidWeapon ) then
			GameTooltip:AddLine(TRANSMOGRIFY_ILLUSION_INVALID_ITEM, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b, true);
		elseif ( hasPending or hasUndo or canTransmogrify ) then
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
			local transmogLocation = TransmogUtil.GetCorrespondingHandTransmogLocation(self.transmogLocation);
			local itemBaseSourceID = C_Transmog.GetSlotVisualInfo(transmogLocation);
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
			GameTooltip:SetText(GetSlotGlobalString(self));
			GameTooltip:AddLine(TRANSMOGRIFY_STYLE_UNCOLLECTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			GameTooltip:Show();
		elseif ( not canTransmogrify and not hasUndo ) then
			GameTooltip:SetText(GetSlotGlobalString(self));
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			local errorMsg;
			if ( tag == "CANNOT_USE" ) then
				local errorCode, errorString = C_Transmog.GetSlotUseError(self.transmogLocation);
				errorMsg = errorString;
			else
				errorMsg = tag and _G["TRANSMOGRIFY_INVALID_"..tag];
			end
			if ( errorMsg ) then
				GameTooltip:AddLine(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
		elseif ( hasPending or hasUndo ) then
			GameTooltip:SetTransmogrifyItem(self.transmogLocation);
		else
			GameTooltip:SetInventoryItem("player", self.transmogLocation:GetSlotID());
		end
	end
	WardrobeTransmogFrame.ModelScene.ControlFrame:Show();
	self.UpdateTooltip = WardrobeTransmogButton_OnEnter;
end

function WardrobeTransmogButton_OnLeave(self)
	if ( self.UndoButton and not self.UndoButton:IsMouseOver() ) then
		self.UndoButton:Hide();
	end
	WardrobeTransmogFrame.ModelScene.ControlFrame:Hide();
	GameTooltip:Hide();
	self.UpdateTooltip = nil;
end

function WardrobeTransmogButton_Select(button, fromOnClick)
	if ( WardrobeTransmogFrame.selectedSlotButton ) then
		WardrobeTransmogFrame.selectedSlotButton.SelectedTexture:Hide();
	end
	WardrobeTransmogFrame.selectedSlotButton = button;
	if ( button ) then
		button.SelectedTexture:Show();
		if (fromOnClick and WardrobeCollectionFrame.activeFrame ~= WardrobeCollectionFrame.ItemsCollectionFrame) then
			WardrobeCollectionFrame_ClickTab(WardrobeCollectionFrame.ItemsTab);
		end
		if ( WardrobeCollectionFrame.activeFrame == WardrobeCollectionFrame.ItemsCollectionFrame ) then
			local _, _, selectedSourceID = TransmogUtil.GetInfoForEquippedSlot(button.transmogLocation);
			local forceGo = button.transmogLocation:IsIllusion();
			local FOR_TRANSMOG = true;
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, button.transmogLocation, forceGo, FOR_TRANSMOG);
			WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(true);
		end
	else
		WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(false);
	end
end

function WardrobeTransmogButton_SetStatusBorder(self, status)
	local atlas;
	if ( status == "RED" ) then
		if ( self.transmogLocation:IsAppearance() ) then
			atlas = "transmog-frame-red";
		else
			atlas = "transmog-frame-small-red";
		end
	elseif ( status == "PINK" ) then
		if ( self.transmogLocation:IsAppearance() ) then
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

ClearAllPendingButtonMixin = {};

function ClearAllPendingButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_TRANSMOG_REVERTING_GEAR_SLOT);
	for index, button in ipairs(WardrobeTransmogFrame.ModelScene.SlotButtons) do
		C_Transmog.ClearPending(button.transmogLocation);
	end
end

function ClearAllPendingButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(TRANSMOGRIFY_CLEAR_ALL_PENDING);
end

function ClearAllPendingButtonMixin:OnLeave()
	GameTooltip:Hide();
end

-- ************************************************************************************************************************************************************
-- **** COLLECTION ********************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local MAIN_HAND_INV_TYPE = 21;
local OFF_HAND_INV_TYPE = 22;
local RANGED_INV_TYPE = 15;
local TAB_ITEMS = 1;
local TAB_SETS = 2;
local TABS_MAX_WIDTH = 185;

local WARDROBE_MODEL_SETUP = {
	["HEADSLOT"] 		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = false } },
	["SHOULDERSLOT"]	= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["BACKSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["CHESTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["TABARDSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["SHIRTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["WRISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["HANDSSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = true,  HEADSLOT = true  } },
	["WAISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["LEGSSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["FEETSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true  } },
}

local WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 78420,
	["LEGSSLOT"] = 78425,
	["FEETSLOT"] = 78427,
	["HANDSSLOT"] = 78426,
	["HEADSLOT"] = 78416,
}

local SET_MODEL_PAN_AND_ZOOM_LIMITS = {
	["Draenei2"] = { maxZoom = 2.2105259895325, panMaxLeft = -0.56983226537705, panMaxRight = 0.82581323385239, panMaxTop = -0.17342753708363, panMaxBottom = -2.6428601741791 },
	["Draenei3"] = { maxZoom = 3.0592098236084, panMaxLeft = -0.33429977297783, panMaxRight = 0.29183092713356, panMaxTop = -0.079871296882629, panMaxBottom = -2.4141833782196 },
	["Worgen2"] = { maxZoom = 1.9605259895325, panMaxLeft = -0.64045578241348, panMaxRight = 0.59410041570663, panMaxTop = -0.11050206422806, panMaxBottom = -2.2492413520813 },
	["Worgen3"] = { maxZoom = 2.9013152122498, panMaxLeft = -0.2526838183403, panMaxRight = 0.38198262453079, panMaxTop = -0.10407017171383, panMaxBottom = -2.4137926101685 },
	["Worgen3Alt"] = { maxZoom = 3.3618412017822, panMaxLeft = -0.19753229618072, panMaxRight = 0.26802557706833, panMaxTop = -0.073476828634739, panMaxBottom = -1.9255120754242 },
	["Worgen2Alt"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.33268970251083, panMaxRight = 0.36896070837975, panMaxTop = -0.14780110120773, panMaxBottom = -2.1662468910217 },
	["Scourge2"] = { maxZoom = 3.1710526943207, panMaxLeft = -0.3243542611599, panMaxRight = 0.5625838637352, panMaxTop = -0.054175414144993, panMaxBottom = -1.7261047363281 },
	["Scourge3"] = { maxZoom = 2.7105259895325, panMaxLeft = -0.35650563240051, panMaxRight = 0.41562974452972, panMaxTop = -0.07072202116251, panMaxBottom = -1.877711892128 },
	["Orc2"] = { maxZoom = 2.5526309013367, panMaxLeft = -0.64236557483673, panMaxRight = 0.77098786830902, panMaxTop = -0.075792260468006, panMaxBottom = -2.0818419456482 },
	["Orc3"] = { maxZoom = 3.2960524559021, panMaxLeft = -0.22763830423355, panMaxRight = 0.32022559642792, panMaxTop = -0.038521766662598, panMaxBottom = -2.0473554134369 },
	["Gnome3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.29900181293488, panMaxRight = 0.35779395699501, panMaxTop = -0.076380833983421, panMaxBottom = -0.99909907579422 },
	["Gnome2"] = { maxZoom = 2.8552639484406, panMaxLeft = -0.2777853012085, panMaxRight = 0.29651582241058, panMaxTop = -0.095201380550861, panMaxBottom = -1.0263166427612 },
	["Dwarf2"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.50352156162262, panMaxRight = 0.4159924685955, panMaxTop = -0.07211934030056, panMaxBottom = -1.4946432113648 },
	["Dwarf3"] = { maxZoom = 2.8947370052338, panMaxLeft = -0.37057432532311, panMaxRight = 0.43383255600929, panMaxTop = -0.084960877895355, panMaxBottom = -1.7173190116882 },
	["BloodElf3"] = { maxZoom = 3.1644730567932, panMaxLeft = -0.2654082775116, panMaxRight = 0.28886350989342, panMaxTop = -0.049619361758232, panMaxBottom = -1.9943760633469 },
	["BloodElf2"] = { maxZoom = 3.1710524559021, panMaxLeft = -0.25901651382446, panMaxRight = 0.45525884628296, panMaxTop = -0.085230752825737, panMaxBottom = -2.0548067092895 },
	["Troll2"] = { maxZoom = 2.2697355747223, panMaxLeft = -0.58214980363846, panMaxRight = 0.5104039311409, panMaxTop = -0.05494449660182, panMaxBottom = -2.3443803787231 },
	["Troll3"] = { maxZoom = 3.1249995231628, panMaxLeft = -0.35141581296921, panMaxRight = 0.50875341892242, panMaxTop = -0.063820324838161, panMaxBottom = -2.4224486351013 },
	["Tauren2"] = { maxZoom = 2.1118416786194, panMaxLeft = -0.82946360111237, panMaxRight = 0.83975899219513, panMaxTop = -0.061676319688559, panMaxBottom = -2.035267829895 },
	["Tauren3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.37433895468712, panMaxRight = 0.40420442819595, panMaxTop = -0.1868137717247, panMaxBottom = -2.2116675376892 },
	["NightElf3"] = { maxZoom = 2.9539475440979, panMaxLeft = -0.27334463596344, panMaxRight = 0.27148312330246, panMaxTop = -0.094710879027844, panMaxBottom = -2.3087983131409 },
	["NightElf2"] = { maxZoom = 2.9144732952118, panMaxLeft = -0.45042458176613, panMaxRight = 0.47114592790604, panMaxTop = -0.10513981431723, panMaxBottom = -2.4612309932709 },
	["Human3"] = { maxZoom = 3.3618412017822, panMaxLeft = -0.19753229618072, panMaxRight = 0.26802557706833, panMaxTop = -0.073476828634739, panMaxBottom = -1.9255120754242 },
	["Human2"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.33268970251083, panMaxRight = 0.36896070837975, panMaxTop = -0.14780110120773, panMaxBottom = -2.1662468910217 },
	["Pandaren3"] = { maxZoom = 2.5921046733856, panMaxLeft = -0.45187762379646, panMaxRight = 0.54132586717606, panMaxTop = -0.11439494043589, panMaxBottom = -2.2257535457611 },
	["Pandaren2"] = { maxZoom = 2.9342107772827, panMaxLeft = -0.36421552300453, panMaxRight = 0.50203305482864, panMaxTop = -0.11241528391838, panMaxBottom = -2.3707413673401 },
	["Goblin2"] = { maxZoom = 2.4605259895325, panMaxLeft = -0.31328883767128, panMaxRight = 0.39014467597008, panMaxTop = -0.089733943343162, panMaxBottom = -1.3402827978134 },
	["Goblin3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.26144406199455, panMaxRight = 0.30945864319801, panMaxTop = -0.07625275105238, panMaxBottom = -1.2928194999695 },
	["LightforgedDraenei2"] = { maxZoom = 2.2105259895325, panMaxLeft = -0.56983226537705, panMaxRight = 0.82581323385239, panMaxTop = -0.17342753708363, panMaxBottom = -2.6428601741791 },
	["LightforgedDraenei3"] = { maxZoom = 3.0592098236084, panMaxLeft = -0.33429977297783, panMaxRight = 0.29183092713356, panMaxTop = -0.079871296882629, panMaxBottom = -2.4141833782196 },
	["HighmountainTauren2"] = { maxZoom = 2.1118416786194, panMaxLeft = -0.82946360111237, panMaxRight = 0.83975899219513, panMaxTop = -0.061676319688559, panMaxBottom = -2.035267829895 },
	["HighmountainTauren3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.37433895468712, panMaxRight = 0.40420442819595, panMaxTop = -0.1868137717247, panMaxBottom = -2.2116675376892 },
	["Nightborne3"] = { maxZoom = 2.9539475440979, panMaxLeft = -0.27334463596344, panMaxRight = 0.27148312330246, panMaxTop = -0.094710879027844, panMaxBottom = -2.3087983131409 },
	["Nightborne2"] = { maxZoom = 2.9144732952118, panMaxLeft = -0.45042458176613, panMaxRight = 0.47114592790604, panMaxTop = -0.10513981431723, panMaxBottom = -2.4612309932709 },
	["VoidElf3"] = { maxZoom = 3.1644730567932, panMaxLeft = -0.2654082775116, panMaxRight = 0.28886350989342, panMaxTop = -0.049619361758232, panMaxBottom = -1.9943760633469 },
	["VoidElf2"] = { maxZoom = 3.1710524559021, panMaxLeft = -0.25901651382446, panMaxRight = 0.45525884628296, panMaxTop = -0.085230752825737, panMaxBottom = -2.0548067092895 },
	["MagharOrc2"] = { maxZoom = 2.5526309013367, panMaxLeft = -0.64236557483673, panMaxRight = 0.77098786830902, panMaxTop = -0.075792260468006, panMaxBottom = -2.0818419456482 },
	["MagharOrc3"] = { maxZoom = 3.2960524559021, panMaxLeft = -0.22763830423355, panMaxRight = 0.32022559642792, panMaxTop = -0.038521766662598, panMaxBottom = -2.0473554134369 },
	["DarkIronDwarf2"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.50352156162262, panMaxRight = 0.4159924685955, panMaxTop = -0.07211934030056, panMaxBottom = -1.4946432113648 },
	["DarkIronDwarf3"] = { maxZoom = 2.8947370052338, panMaxLeft = -0.37057432532311, panMaxRight = 0.43383255600929, panMaxTop = -0.084960877895355, panMaxBottom = -1.7173190116882 },
	["KulTiran2"] = { maxZoom =  1.71052598953247, panMaxLeft = -0.667941331863403, panMaxRight = 0.589463412761688, panMaxTop = -0.373320609331131, panMaxBottom = -2.7329957485199 },
	["KulTiran3"] = { maxZoom =  2.22368383407593, panMaxLeft = -0.43183308839798, panMaxRight = 0.445900857448578, panMaxTop = -0.303212702274323, panMaxBottom = -2.49550628662109 },
	["ZandalariTroll2"] = { maxZoom =  2.1710512638092, panMaxLeft = -0.487841755151749, panMaxRight = 0.561356604099274, panMaxTop = -0.385127544403076, panMaxBottom = -2.78562784194946 },
	["ZandalariTroll3"] = { maxZoom =  3.32894563674927, panMaxLeft = -0.376705944538116, panMaxRight = 0.488780438899994, panMaxTop = -0.20890490710735, panMaxBottom = -2.67064166069031 },
	["Mechagnome3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.29900181293488, panMaxRight = 0.35779395699501, panMaxTop = -0.076380833983421, panMaxBottom = -0.99909907579422 },
	["Mechagnome2"] = { maxZoom = 2.8552639484406, panMaxLeft = -0.2777853012085, panMaxRight = 0.29651582241058, panMaxTop = -0.095201380550861, panMaxBottom = -1.0263166427612 },
	["Vulpera2"] = { maxZoom = 2.4605259895325, panMaxLeft = -0.31328883767128, panMaxRight = 0.39014467597008, panMaxTop = -0.089733943343162, panMaxBottom = -1.3402827978134 },
	["Vulpera3"] = { maxZoom = 2.9605259895325, panMaxLeft = -0.26144406199455, panMaxRight = 0.30945864319801, panMaxTop = -0.07625275105238, panMaxBottom = -1.2928194999695 },
};

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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
		local enableSearchAndFilter = WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation and WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation:IsAppearance()
		WardrobeCollectionFrame.searchBox:SetEnabled(enableSearchAndFilter);
		WardrobeCollectionFrame.FilterButton:Show();
		WardrobeCollectionFrame.FilterButton:SetEnabled(enableSearchAndFilter);
	elseif ( tabID == TAB_SETS ) then
		WardrobeCollectionFrame.ItemsCollectionFrame:Hide();
		WardrobeCollectionFrame.searchBox:ClearAllPoints();
		if ( atTransmogrifier )  then
			WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.SetsTransmogFrame;
			WardrobeCollectionFrame.searchBox:SetPoint("TOPRIGHT", -107, -35);
			WardrobeCollectionFrame.searchBox:SetWidth(115);
			WardrobeCollectionFrame.FilterButton:Hide();
		else
			WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.SetsCollectionFrame;
			WardrobeCollectionFrame.searchBox:SetPoint("TOPLEFT", 19, -69);
			WardrobeCollectionFrame.searchBox:SetWidth(145);
			WardrobeCollectionFrame.FilterButton:Show();
			WardrobeCollectionFrame.FilterButton:SetEnabled(true);
		end
		WardrobeCollectionFrame.searchBox:SetEnabled(true);
		WardrobeCollectionFrame.SetsCollectionFrame:SetShown(not atTransmogrifier);
		WardrobeCollectionFrame.SetsTransmogFrame:SetShown(atTransmogrifier);
	end
end

function WardrobeCollectionFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, TAB_ITEMS);
	PanelTemplates_ResizeTabsToFit(self, TABS_MAX_WIDTH);
	self.selectedCollectionTab = TAB_ITEMS;
	self.selectedTransmogTab = TAB_ITEMS;

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\inv_misc_enggizmos_19");
end

function WardrobeCollectionFrame_OnSlotButtonEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	GameTooltip:SetText(GetSlotGlobalString(button));
end

WardrobeItemsCollectionMixin = { };

local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;

function WardrobeItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist", "legs", "feet", defaultSectionSpacing, "mainhand", spacingWithSmallButton, "secondaryhand" };
	local parentFrame = self.SlotsFrame;
	local lastButton;
	local xOffset = spacingNoSmallButton;
	for i = 1, #slots do
		local value = tonumber(slots[i]);
		if ( value ) then
			-- this is a spacer
			xOffset = value;
		else
			local slotString = slots[i];
			local button = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSlotButtonTemplate");
			button.NormalTexture:SetAtlas("transmog-nav-slot-"..slotString, true);
			if ( lastButton ) then
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				button:SetPoint("TOPLEFT");
			end
			button.slot = string.upper(slotString).."SLOT";
			xOffset = spacingNoSmallButton;
			lastButton = button;
			-- small buttons
			if ( slotString == "mainhand" or slotString == "secondaryhand" or slotString == "shoulder" ) then
				local smallButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSmallSlotButtonTemplate");
				smallButton:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 16, -15);
				smallButton.slot = button.slot;
				if ( slotString == "shoulder" ) then
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Appearance, Enum.TransmogModification.RightShoulder);

					smallButton.NormalTexture:SetAtlas("transmog-nav-slot-shoulder", false);
					smallButton:SetScript("OnEnter", WardrobeCollectionFrame_OnSlotButtonEnter);
					smallButton:Hide();
					parentFrame.rightShoulderButton = smallButton;
				else
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Illusion, Enum.TransmogModification.None);
				end
			end

			button.transmogLocation = TransmogUtil.GetTransmogLocation(button.slot, button.transmogType, button.modification);
		end
	end
end

function WardrobeItemsCollectionMixin:ToggleRightShoulderDisplay(show)
	local lastButton = nil;
	for i, button in ipairs(self.SlotsFrame.Buttons) do
		if not button.isSmallButton then
			local slotName =  button.transmogLocation:GetSlotName();
			if slotName == "BACKSLOT" then
				local xOffset = show and spacingWithSmallButton or spacingNoSmallButton;
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			elseif slotName == "HANDSSLOT" or slotName == "MAINHANDSLOT" then
				local xOffset = show and shorterSectionSpacing or defaultSectionSpacing;
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			end
			lastButton = button;
		end
	end
	self.SlotsFrame.rightShoulderButton:SetShown(show);

	if self.transmogLocation then
		-- if it was selected and got hidden, reset to left shoulder
		-- otherwise if left selected, update cameras
		local leftShoulderTransmogLocation = TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
		if not show and self.transmogLocation:IsEqual(self.SlotsFrame.rightShoulderButton.transmogLocation) then		
			self:SetActiveSlot(leftShoulderTransmogLocation);
		elseif self.transmogLocation:IsEqual(leftShoulderTransmogLocation) then
			self:UpdateItems();
		end
	end
end

function WardrobeItemsCollectionMixin:OnEvent(event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" or event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slotID = ...;
		if ( slotID and self.transmogLocation:IsAppearance() ) then
			if ( slotID == self.transmogLocation:GetSlotID() ) then
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
		WardrobeCollectionFrame_UpdateTabButtons();
	end
end

function WardrobeCollectionFrame_OnEvent(self, event, ...)
	if ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.tooltipContentFrame ) then
			self.tooltipContentFrame:RefreshAppearanceTooltip();
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
		WardrobeCollectionFrame_UpdateUsableAppearances();
	elseif ( event == "TRANSMOG_SEARCH_UPDATED" ) then
		local searchType, arg1 = ...;
		if ( searchType == self.activeFrame.searchType ) then
			self.activeFrame:OnSearchUpdate(arg1);
		end
	elseif ( event == "SEARCH_DB_LOADED" ) then
		WardrobeCollectionFrame_RestartSearchTracking();
	elseif ( event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" or event == "TRANSMOG_COLLECTION_CAMERA_UPDATE" ) then
		WardrobeCollectionFrame_RefreshCameras();
	end
end

function WardrobeCollectionFrame_UpdateUsableAppearances()
	if ( not WardrobeCollectionFrame.updateUsableAppearances ) then
		WardrobeCollectionFrame.updateUsableAppearances = true;
		C_Timer.After(0, function() WardrobeCollectionFrame.updateUsableAppearances = nil; C_TransmogCollection.UpdateUsableAppearances(); end);
	end
end

function WardrobeCollectionFrame_RefreshCameras()
	for i, frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		frame:RefreshCameras();
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
	self.HiddenModel:SetKeepModelOnHide(true);

	self.chosenVisualSources = { };

	self.NUM_ROWS = 3;
	self.NUM_COLS = 6;
	self.PAGE_SIZE = self.NUM_ROWS * self.NUM_COLS;

	UIDropDownMenu_Initialize(self.RightClickDropDown, nil, "MENU");
	self.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;

	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	self:CheckLatestAppearance();
end

function WardrobeItemsCollectionMixin:CheckHelpTip()
	if (WardrobeFrame_IsAtTransmogrifier()) then
		if (GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SETS_VENDOR_TAB)) then
			return;
		end

		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON)) then
			return;
		end

		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN)) then
			return;
		end

		local sets = C_TransmogSets.GetAllSets();
		local hasCollected = false;
		if (sets) then
			for i = 1, #sets do
				if (sets[i].collected) then
					hasCollected = true;
					break;
				end
			end
		end
		if (not hasCollected) then
			return;
		end

		local helpTipInfo = {
			text = TRANSMOG_SETS_VENDOR_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_SETS_VENDOR_TAB,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
		};
		HelpTip:Show(WardrobeCollectionFrame, helpTipInfo, WardrobeCollectionFrame.SetsTab);
	else
		if (GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SETS_TAB)) then
			return;
		end

		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK)) then
			return;
		end

		local helpTipInfo = {
			text = TRANSMOG_SETS_TAB_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_SETS_TAB,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
		};
		HelpTip:Show(WardrobeCollectionFrame, helpTipInfo, WardrobeCollectionFrame.SetsTab);
	end
end

function WardrobeItemsCollectionMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");

	local needsUpdate = false;	-- we don't need to update if we call :SetActiveSlot as that will do an update
	if ( self.jumpToLatestCategoryID and self.jumpToLatestCategoryID ~= self.activeCategory and not WardrobeFrame_IsAtTransmogrifier() ) then
		local slot = WardrobeCollectionFrame_GetSlotFromCategoryID(self.jumpToLatestCategoryID);
		-- The model got reset from OnShow, which restored all equipment.
		-- But ChangeModelsSlot tries to be smart and only change the difference from the previous slot to the current slot, so some equipment will remain left on.
		-- This is only set for new apperances, base transmogLocation is fine
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.None);
		local ignorePreviousSlot = true;
		self:SetActiveSlot(transmogLocation, self.jumpToLatestCategoryID, ignorePreviousSlot);
		self.jumpToLatestCategoryID = nil;
	elseif ( self.transmogLocation ) then
		-- redo the model for the active slot
		self:ChangeModelsSlot(self.transmogLocation);
		needsUpdate = true;
	else
		local transmogLocation = TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
		self:SetActiveSlot(transmogLocation);
	end

	WardrobeCollectionFrame.progressBar:SetShown(not WardrobeUtils_IsCategoryLegionArtifact(self:GetActiveCategory()));

	if ( needsUpdate ) then
		WardrobeCollectionFrame_UpdateUsableAppearances();
		self:RefreshVisualsList();
		self:UpdateItems();
		self:UpdateWeaponDropDown();
	end

	-- tab tutorial
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB, true);
	self:CheckHelpTip();
end

function WardrobeItemsCollectionMixin:OnHide()
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");

	StaticPopup_Hide("TRANSMOG_FAVORITE_WARNING");

	WardrobeCollectionFrame_ClearSearch(LE_TRANSMOG_SEARCH_TYPE_ITEMS);

	for i = 1, #self.Models do
		self.Models[i]:SetKeepModelOnHide(false);
	end

	self.visualsList = nil;
	self.filteredVisualsList = nil;
end

function WardrobeCollectionFrame_OnShow(self)
	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\inv_chest_cloth_17");

	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player");
	self:RegisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");

	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	self.inAlternateForm = inAlternateForm;

	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		WardrobeCollectionFrame_SetTab(self.selectedTransmogTab);
	else
		WardrobeCollectionFrame_SetTab(self.selectedCollectionTab);
	end
	WardrobeCollectionFrame_UpdateTabButtons();
end

function WardrobeCollectionFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	self:UnregisterEvent("TRANSMOG_SEARCH_UPDATED");
	self:UnregisterEvent("SEARCH_DB_LOADED");
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("SKILL_LINES_CHANGED");
	self:UnregisterEvent("UPDATE_FACTION");
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	C_TransmogCollection.EndSearch();
	self.jumpToVisualID = nil;
	for i, frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		frame:Hide();
	end
end

function WardrobeCollectionFrame_UpdateTabButtons()
	-- sets tab
	WardrobeCollectionFrame.SetsTab.FlashFrame:SetShown(C_TransmogSets.GetLatestSource() ~= NO_TRANSMOG_SOURCE_ID and not WardrobeFrame_IsAtTransmogrifier());
end

function WardrobeItemsCollectionMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function WardrobeItemsCollectionMixin:CanHandleKey(key)
	if ( WardrobeFrame_IsAtTransmogrifier() and (key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY) ) then
		return true;
	end
	return false;
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
	if ( visualIndex ) then
		visualIndex = WardrobeUtils_GetAdjustedDisplayIndexFromKeyPress(self, visualIndex, #visualsList, key);
		self:SelectVisual(visualsList[visualIndex].visualID);
		self.jumpToVisualID = visualsList[visualIndex].visualID;
		self:ResetPage();
	end
end

function WardrobeCollectionFrame_OnKeyDown(self, key)
	if ( self.tooltipCycle and key == WARDROBE_CYCLE_KEY ) then
		self:SetPropagateKeyboardInput(false);
		if ( IsShiftKeyDown() ) then
			self.tooltipSourceIndex = self.tooltipSourceIndex - 1;
		else
			self.tooltipSourceIndex = self.tooltipSourceIndex + 1;
		end
		self.tooltipContentFrame:RefreshAppearanceTooltip();
	elseif ( key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY ) then
		if ( self.activeFrame:CanHandleKey(key) ) then
			self:SetPropagateKeyboardInput(false);
			self.activeFrame:HandleKey(key);
		else
			self:SetPropagateKeyboardInput(true);
		end
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function WardrobeItemsCollectionMixin:ChangeModelsSlot(newTransmogLocation, oldTransmogLocation)
	WardrobeCollectionFrame.updateOnModelChanged = nil;
	local oldSlot = oldTransmogLocation and oldTransmogLocation:GetSlotName();
	local newSlot = newTransmogLocation:GetSlotName();

	local undressSlot, reloadModel;
	local newSlotIsArmor = newTransmogLocation:GetArmorCategoryID();
	if ( newSlotIsArmor ) then
		local oldSlotIsArmor = oldTransmogLocation and oldTransmogLocation:GetArmorCategoryID();
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

	if ( reloadModel and not IsUnitModelReadyForUI("player") ) then
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

function WardrobeItemsCollectionMixin:RefreshCameras()
	if ( self:IsShown() ) then
		for i, model in ipairs(self.Models) do
			model:RefreshCamera();
			if ( model.cameraID ) then
				Model_ApplyUICamera(model, model.cameraID);
			end
		end
	end
end

function WardrobeItemsCollectionMixin:OnUnitModelChangedEvent()
	if ( IsUnitModelReadyForUI("player") ) then
		self:ChangeModelsSlot(self.transmogLocation);
		self:UpdateItems();
		return true;
	else
		return false;
	end
end

function WardrobeUtils_IsCategoryRanged(category)
	return (category == Enum.TransmogCollectionType.Bow + 1) or (category == Enum.TransmogCollectionType.Gun + 1) or (category == Enum.TransmogCollectionType.Crossbow + 1);
end

function WardrobeUtils_IsCategoryLegionArtifact(category)
	return (category == Enum.TransmogCollectionType.Paired + 1);
end

function WardrobeUtils_GetValidIndexForNumSources(index, numSources)
	index = index - 1;
	if ( index < 0 ) then
		index = numSources + index;
	end
	return mod(index, numSources) + 1;
end

local function GetPage(entryIndex, pageSize)
	return floor((entryIndex-1) / pageSize) + 1;
end

function WardrobeUtils_GetAdjustedDisplayIndexFromKeyPress(contentFrame, index, numEntries, key)
	if ( key == WARDROBE_PREV_VISUAL_KEY ) then
		index = index - 1;
		if ( index < 1 ) then
			index = numEntries;
		end
	elseif ( key == WARDROBE_NEXT_VISUAL_KEY ) then
		index = index + 1;
		if ( index > numEntries ) then
			index = 1;
		end
	elseif ( key == WARDROBE_DOWN_VISUAL_KEY ) then
		local newIndex = index + contentFrame.NUM_COLS;
		if ( newIndex > numEntries ) then
			-- If you're at the last entry, wrap back around; otherwise go to the last entry.
			index = index == numEntries and 1 or numEntries;
		else
			index = newIndex;
		end
	elseif ( key == WARDROBE_UP_VISUAL_KEY ) then
		local newIndex = index - contentFrame.NUM_COLS;
		if ( newIndex < 1 ) then
			-- If you're at the first entry, wrap back around; otherwise go to the first entry.
			index = index == 1 and numEntries or 1;
		else
			index = newIndex;
		end
	end
	return index;
end

function WardrobeItemsCollectionMixin:GetActiveSlot()
	return self.transmogLocation and self.transmogLocation:GetSlotName();
end

function WardrobeItemsCollectionMixin:GetActiveCategory()
	return self.activeCategory;
end

function WardrobeItemsCollectionMixin:IsValidWeaponCategoryForSlot(categoryID)
	local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
	if ( name and isWeapon ) then
		if ( (self.transmogLocation:IsMainHand() and canMainHand) or (self.transmogLocation:IsOffHand() and canOffHand) ) then
			if ( WardrobeFrame_IsAtTransmogrifier() ) then
				local equippedItemID = GetInventoryItemID("player", self.transmogLocation:GetSlotID());
				return C_TransmogCollection.IsCategoryValidForItem(self.lastWeaponCategory, equippedItemID);
			else
				return true;
			end
		end
	end
	return false;
end

function WardrobeItemsCollectionMixin:SetActiveSlot(transmogLocation, category, ignorePreviousSlot)
	local previousTransmogLocation;
	if not ignorePreviousSlot then
		previousTransmogLocation = self.transmogLocation;
	end
	local slotChanged = not previousTransmogLocation or not previousTransmogLocation:IsEqual(transmogLocation);

	self.transmogLocation = transmogLocation;

	-- figure out a category
	if ( not category ) then
		if ( self.transmogLocation:IsIllusion() ) then
			category = nil;
		elseif ( self.transmogLocation:IsAppearance() ) then
			local useLastWeaponCategory = self.transmogLocation:IsEitherHand() and
											self.lastWeaponCategory and
											self:IsValidWeaponCategoryForSlot(self.lastWeaponCategory);
			if ( useLastWeaponCategory ) then
				category = self.lastWeaponCategory;
			else
				local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = self:GetActiveSlotInfo();
				if ( selectedSourceID ~= NO_TRANSMOG_SOURCE_ID ) then
					category = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
					if not self:IsValidWeaponCategoryForSlot(category) then
						category = nil;
					end
				end
			end
			if ( not category ) then
				if ( self.transmogLocation:IsEitherHand() ) then
					-- find the first valid weapon category
					for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
						if ( self:IsValidWeaponCategoryForSlot(categoryID) ) then
							category = categoryID;
							break;
						end
					end
				else
					category = self.transmogLocation:GetArmorCategoryID();
				end
			end
		end
	end

	if ( slotChanged ) then
		self:ChangeModelsSlot(transmogLocation, previousTransmogLocation);
	end
	-- set only if category is different or slot is different
	if ( category ~= self.activeCategory or slotChanged ) then
		CloseDropDownMenus();
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
	if ( self.transmogLocation:IsAppearance() ) then
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
	local previousCategory = self.activeCategory;
	self.activeCategory = category;
	if previousCategory ~= category then
		if ( self.transmogLocation:IsAppearance() ) then
			C_TransmogCollection.SetSearchAndFilterCategory(category);
			local name, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
			if ( isWeapon ) then
				self.lastWeaponCategory = category;
			end
		end

		self:RefreshVisualsList();
	else
		self:UpdateItems();
	end
	self:UpdateWeaponDropDown();

	WardrobeCollectionFrame.progressBar:SetShown(not WardrobeUtils_IsCategoryLegionArtifact(category));

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.transmogLocation:IsEqual(self.transmogLocation));
	end

	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		self.jumpToVisualID = select(4, self:GetActiveSlotInfo());
	end

	if previousCategory ~= category then
		self:ResetPage();
		WardrobeCollectionFrame_SwitchSearchCategory();
	end
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
		elseif ( self.jumpToLatestAppearanceID and not WardrobeFrame_IsAtTransmogrifier() ) then
			selectedVisualID = self.jumpToLatestAppearanceID;
			self.jumpToLatestAppearanceID = nil;
		end
	end
	if ( selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if ( visualsList[i].visualID == selectedVisualID ) then
				page = GetPage(i, self.PAGE_SIZE);
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
			if ( (visualsList[i].isUsable and visualsList[i].isCollected) or visualsList[i].alwaysShowItem ) then
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
		if ( source1.hasActiveRequiredHoliday ~= source2.hasActiveRequiredHoliday ) then
			return source1.hasActiveRequiredHoliday;
		end
		if ( source1.uiOrder and source2.uiOrder ) then
			return source1.uiOrder > source2.uiOrder;
		end
		return source1.sourceID > source2.sourceID;
	end

	table.sort(self.filteredVisualsList, comparison);
end

function WardrobeItemsCollectionMixin:GetActiveSlotInfo()
	return TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
end

function WardrobeCollectionFrame_GetWeaponInfoForEnchant(transmogLocation)
	if ( not WardrobeFrame_IsAtTransmogrifier() and DressUpFrame:IsShown() ) then
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor();
		if playerActor then
			local appearanceSourceID = playerActor:GetSlotTransmogSources(transmogLocation:GetSlotID());
			if ( WardrobeCollectionFrame_CanEnchantSource(appearanceSourceID) ) then
				local _, appearanceVisualID, _,_,_,_,_,_, appearanceSubclass = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
				return appearanceSourceID, appearanceVisualID, appearanceSubclass;
			end
		end
	end

	local correspondingTransmogLocation = TransmogUtil.GetCorrespondingHandTransmogLocation(transmogLocation);
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID, itemSubclass = TransmogUtil.GetInfoForEquippedSlot(correspondingTransmogLocation);
	if ( WardrobeCollectionFrame_CanEnchantSource(selectedSourceID) ) then
		return selectedSourceID, selectedVisualID, itemSubclass;
	else
		local appearanceSourceID = C_TransmogCollection.GetIllusionFallbackWeaponSource();
		local _, appearanceVisualID, _,_,_,_,_,_, appearanceSubclass= C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID, appearanceSubclass;
	end
end

function WardrobeCollectionFrame_CanEnchantSource(sourceID)
	local _, visualID, canEnchant,_,_,_,_,_, appearanceSubclass  = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	if ( canEnchant ) then
		WardrobeCollectionFrame.ItemsCollectionFrame.HiddenModel:SetItemAppearance(visualID, 0, appearanceSubclass);
		return WardrobeCollectionFrame.ItemsCollectionFrame.HiddenModel:HasAttachmentPoints();
	end
	return false;
end

function WardrobeItemsCollectionMixin:GetCameraVariation()
	if self.transmogLocation:GetSlotName() ~= "SHOULDERSLOT" or not GetCVarBool("transmogShouldersSeparately") then
		return nil;
	end
	if self.transmogLocation:IsRightShoulderModification() then
		return 1;
	else
		return 0;
	end
end

function WardrobeItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;
	local appearanceVisualID;	-- for weapon when looking at enchants
	local appearanceVisualSubclass;
	local changeModel = false;
	local isAtTransmogrifier = WardrobeFrame_IsAtTransmogrifier();

	if ( self.transmogLocation:IsIllusion() ) then
		-- for enchants we need to get the visual of the item in that slot
		local appearanceSourceID;
		appearanceSourceID, appearanceVisualID, appearanceVisualSubclass = WardrobeCollectionFrame_GetWeaponInfoForEnchant(self.transmogLocation);
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
	local checkTutorialFrame = self.transmogLocation:IsAppearance() and not WardrobeFrame_IsAtTransmogrifier()
								and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK);

	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, appliedCategoryID, pendingSourceID, pendingVisualID, pendingCategoryID, hasPendingUndo;
	local showUndoIcon;
	if ( isAtTransmogrifier ) then
		baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, appliedCategoryID, pendingSourceID, pendingVisualID, pendingCategoryID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(self.transmogLocation);
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

	local cameraVariation = self:GetCameraVariation();

	local pendingTransmogModelFrame = nil;
	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local visualInfo = self.filteredVisualsList[index];
		if ( visualInfo ) then
			model:Show();

			-- camera
			if ( self.transmogLocation:IsAppearance() ) then
				cameraID = C_TransmogCollection.GetAppearanceCameraID(visualInfo.visualID, cameraVariation);
			end
			if ( model.cameraID ~= cameraID ) then
				Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

			if ( visualInfo ~= model.visualInfo or changeModel ) then
				if ( isArmor ) then
					local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
					model:TryOn(sourceID);
				elseif ( appearanceVisualID ) then
					-- appearanceVisualID is only set when looking at enchants
					model:SetItemAppearance(appearanceVisualID, visualInfo.visualID, appearanceVisualSubclass);
				else
					model:SetItemAppearance(visualInfo.visualID);
				end
			end
			model.visualInfo = visualInfo;

			-- state at the transmogrifier
			local transmogStateAtlas;
			local matchesAppliedCategory = (appliedCategoryID == self.activeCategory) or self.transmogLocation:IsIllusion();
			local matchesPendingCategory = (pendingCategoryID == self.activeCategory) or self.transmogLocation:IsIllusion();
			if ( visualInfo.visualID == appliedVisualID and matchesAppliedCategory) then
				transmogStateAtlas = "transmog-wardrobe-border-current-transmogged";
			elseif ( visualInfo.visualID == baseVisualID ) then
				transmogStateAtlas = "transmog-wardrobe-border-current";
			elseif ( visualInfo.visualID == pendingVisualID and matchesPendingCategory) then
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
				if ( i < self.NUM_COLS and not WardrobeCollectionFrame.tutorialVisualID and visualInfo.isCollected and not visualInfo.isHideVisual ) then
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
		self.PendingTransmogFrame:SetParent(pendingTransmogModelFrame);
		self.PendingTransmogFrame:SetPoint("CENTER");
		self.PendingTransmogFrame:Show();
		if ( self.PendingTransmogFrame.visualID ~= pendingVisualID ) then
			self.PendingTransmogFrame.TransmogSelectedAnim:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim2:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim2:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim3:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim3:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim4:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim4:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim5:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim5:Play();
		end
		self.PendingTransmogFrame.UndoIcon:SetShown(showUndoIcon);
		self.PendingTransmogFrame.visualID = pendingVisualID;
	else
		self.PendingTransmogFrame:Hide();
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
		local helpTipInfo = {
			text = TRANSMOG_MOUSE_CLICK_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
		};
		HelpTip:Show(self, helpTipInfo, tutorialAnchorFrame);
	else
		HelpTip:Hide(self, TRANSMOG_MOUSE_CLICK_TUTORIAL);
	end
end

function WardrobeItemsCollectionMixin:UpdateProgressBar()
	local collected, total;
	if ( self.transmogLocation:IsIllusion() ) then
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

function WardrobeCollectionFrame_SortSources(sources, primaryVisualID, primarySourceID)
	local comparison = function(source1, source2)
		-- if a primary visual is given, sources for that are grouped by themselves above all others
		if ( primaryVisualID and source1.visualID ~= source2.visualID ) then
			return source1.visualID == primaryVisualID;
		end

		if ( source1.isCollected ~= source2.isCollected ) then
			return source1.isCollected;
		end

		if ( primarySourceID ) then
			local source1IsPrimary = (source1.sourceID == primarySourceID);
			local source2IsPrimary = (source2.sourceID == primarySourceID);
			if ( source1IsPrimary ~= source2IsPrimary ) then
				return source1IsPrimary;
			end
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
	table.sort(sources, comparison);
	return sources;
end

function WardrobeCollectionFrame_GetSortedAppearanceSources(visualID, categoryID)
	local sources = C_TransmogCollection.GetAppearanceSources(visualID, categoryID);
	return WardrobeCollectionFrame_SortSources(sources);
end

function WardrobeItemsCollectionMixin:RefreshVisualsList()
	if ( self.transmogLocation:IsIllusion() ) then
		self.visualsList = C_TransmogCollection.GetIllusions();
	else
		if( WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation:IsMainHand() ) then
			self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory, EXCLUSION_CATEGORY_MAINHAND);
		elseif (WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation:IsOffHand() ) then
			self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory, EXCLUSION_CATEGORY_OFFHAND);
		else
			self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory);
		end

	end
	self:FilterVisuals();
	self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.filteredVisualsList / self.PAGE_SIZE));
end

function WardrobeItemsCollectionMixin:GetFilteredVisualsList()
	return self.filteredVisualsList;
end

function WardrobeItemsCollectionMixin:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable)
	local sourceID = self:GetChosenVisualSource(visualID);
	if ( sourceID == NO_TRANSMOG_SOURCE_ID ) then
		local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID, self.activeCategory);
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
	if ( self.transmogLocation:IsAppearance() ) then
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
	C_Transmog.SetPending(self.transmogLocation, sourceID, self.activeCategory);
	PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);
end

function WardrobeCollectionFrame_OpenTransmogLink(link)
	if ( not CollectionsJournal:IsVisible() or not WardrobeCollectionFrame:IsVisible() ) then
		ToggleCollectionsJournal(5);
	end

	local linkType, id = strsplit(":", link);

	if ( linkType == "transmogappearance" ) then
		local sourceID = tonumber(id);
		WardrobeCollectionFrame_SetTab(TAB_ITEMS);
		-- For links a base appearance is fine
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		local slot = WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID);
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.None);
		WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
	elseif ( linkType == "transmogset") then
		local setID = tonumber(id);
		WardrobeCollectionFrame_SetTab(TAB_SETS);
		WardrobeCollectionFrame.SetsCollectionFrame:SelectSet(setID);
	end
end

function WardrobeItemsCollectionMixin:GoToSourceID(sourceID, transmogLocation, forceGo, forTransmog)
	local categoryID, visualID;
	if ( transmogLocation:IsAppearance() ) then
		categoryID, visualID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID, transmogLocation.slotID);
	elseif ( transmogLocation:IsIllusion() ) then
		visualID = C_TransmogCollection.GetIllusionSourceInfo(sourceID);
	end
	if ( visualID or forceGo ) then
		self.jumpToVisualID = visualID;
		if ( self.activeCategory ~= categoryID or not self.transmogLocation:IsEqual(transmogLocation) ) then
			self:SetActiveSlot(transmogLocation, categoryID);
		else
			if not self.filteredVisualsList then
				self:RefreshVisualsList();
			end
			self:ResetPage();
		end
	end
end

function WardrobeItemsCollectionMixin:SetAppearanceTooltip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	self.tooltipVisualID = frame.visualInfo.visualID;
	self:RefreshAppearanceTooltip();
end

function WardrobeItemsCollectionMixin:RefreshAppearanceTooltip()
	if ( not self.tooltipVisualID ) then
		return;
	end
	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.tooltipVisualID, self.activeCategory);
	local chosenSourceID = self:GetChosenVisualSource(self.tooltipVisualID);
	WardrobeCollectionFrame_SetAppearanceTooltip(self, sources, chosenSourceID);
end

function WardrobeItemsCollectionMixin:ClearAppearanceTooltip()
	self.tooltipVisualID = nil;
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

function WardrobeCollectionFrame_GetSlotFromCategoryID(categoryID)
	local slot;
	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		if categoryID == transmogSlot.armorCategoryID then
			slot = transmogSlot.location:GetSlotName();
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

RightShoulderCheckboxMixin = { }

function RightShoulderCheckboxMixin:OnShow()
	-- have to do it here rather than an OnLoad because it's part of the ItemsCollectionFrame which is loaded before WardrobeTransmogFrame
	-- and if the cvar is set it needs to interact with WardrobeTransmogFrame
	if not self.init then
		self.init = true;
		if not self:CheckCVar() then
			self:RegisterEvent("VARIABLES_LOADED");
		end
	end
end

function RightShoulderCheckboxMixin:OnEvent()
	self:CheckCVar();
end

function RightShoulderCheckboxMixin:CheckCVar()
	local isOn = GetCVarBool("transmogShouldersSeparately");
	if isOn then
		self:SetChecked(isOn);
		self:NotifyFrames(isOn);
	end
	return isOn;
end

function RightShoulderCheckboxMixin:OnClick()
	local isOn = self:GetChecked();
	if isOn then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	SetCVar("transmogShouldersSeparately", isOn);
	self:NotifyFrames(isOn);
end

function RightShoulderCheckboxMixin:NotifyFrames(isOn)
	WardrobeTransmogFrame_ToggleRightShoulderDisplay(isOn);
	WardrobeCollectionFrame.ItemsCollectionFrame:ToggleRightShoulderDisplay(isOn);
end

-- ***** MODELS

WardrobeItemsModelMixin = { };

function WardrobeItemsModelMixin:OnLoad()
	self:SetAutoDress(false);

	local lightValues = { enabled=true, omni=false, dirX=-1, dirY=1, dirZ=-1, ambIntensity=1.05, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
	self:SetLight(lightValues.enabled, lightValues.omni,
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
			lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);
end

function WardrobeItemsModelMixin:OnModelLoaded()
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function WardrobeItemsModelMixin:OnMouseDown(button)
	local itemsCollectionFrame = self:GetParent();
	if ( IsModifiedClick("CHATLINK") ) then
		local link;
		if ( itemsCollectionFrame.transmogLocation:IsIllusion() ) then
			link = select(3, C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID));
		else
			local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID, self.activeCategory);
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
		local slot = itemsCollectionFrame:GetActiveSlot();
		if ( itemsCollectionFrame.transmogLocation:IsAppearance() ) then
			local sourceID = itemsCollectionFrame:GetAnAppearanceSourceFromVisual(self.visualInfo.visualID, nil);
			-- don't specify a slot for ranged weapons
			if ( WardrobeUtils_IsCategoryRanged(itemsCollectionFrame:GetActiveCategory()) or  WardrobeUtils_IsCategoryLegionArtifact(itemsCollectionFrame:GetActiveCategory()) ) then
				slot = nil;
			end
			DressUpVisual(sourceID, slot);
		elseif ( itemsCollectionFrame.transmogLocation:IsIllusion() ) then
			local weaponSourceID = WardrobeCollectionFrame_GetWeaponInfoForEnchant(itemsCollectionFrame.transmogLocation);
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
		if ( not self.visualInfo.isCollected or self.visualInfo.isHideVisual or itemsCollectionFrame.transmogLocation:IsIllusion() ) then
			return;
		end
		dropDown.activeFrame = self;
		ToggleDropDownMenu(1, nil, dropDown, self, -6, -3);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function WardrobeItemsModelMixin:OnEnter()
	if ( not self.visualInfo ) then
		return;
	end
	self:SetScript("OnUpdate", self.OnUpdate);
	local itemsCollectionFrame = self:GetParent();
	if ( C_TransmogCollection.IsNewAppearance(self.visualInfo.visualID) ) then
		C_TransmogCollection.ClearNewAppearance(self.visualInfo.visualID);
		if itemsCollectionFrame.jumpToLatestAppearanceID == self.visualInfo.visualID then
			itemsCollectionFrame.jumpToLatestAppearanceID = nil;
			itemsCollectionFrame.jumpToLatestCategoryID  = nil;
		end
		self.NewString:Hide();
		self.NewGlow:Hide();
	end
	if ( itemsCollectionFrame.transmogLocation:IsIllusion() ) then
		local visualID, name = C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name);
		if ( self.visualInfo.sourceText ) then
			GameTooltip:AddLine(self.visualInfo.sourceText, 1, 1, 1, 1);
		end
		GameTooltip:Show();
	else
		itemsCollectionFrame:SetAppearanceTooltip(self);
	end
end

function WardrobeItemsModelMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	self:GetParent():ClearAppearanceTooltip();
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
		self:Reload(self:GetParent():GetActiveSlot());
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
	self:SetLight(true, false, -1, 1, -1, 1, 1, 1, 1, 0, 1, 1, 1);
end

function WardrobeSetsTransmogModelMixin:OnEvent()
	self:RefreshCamera();
	local x, y, z = self:TransformCameraSpaceToModelSpace(0, 0, -0.25);
	self:SetPosition(x, y, z);
end

function WardrobeSetsTransmogModelMixin:OnMouseDown(button)
	if ( button == "LeftButton" ) then
		self:GetParent():SelectSet(self.setID);
		PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);
	elseif ( button == "RightButton" ) then
		local dropDown = self:GetParent().RightClickDropDown;
		if ( dropDown.activeFrame ~= self ) then
			CloseDropDownMenus();
		end
		dropDown.activeFrame = self;
		ToggleDropDownMenu(1, nil, dropDown, self, -6, -3);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function WardrobeSetsTransmogModelMixin:OnEnter()
	self:GetParent().tooltipModel = self;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:RefreshTooltip();
end

function WardrobeSetsTransmogModelMixin:RefreshTooltip()
	local totalQuality = 0;
	local numTotalSlots = 0;
	local waitingOnQuality = false;
	local sourceQualityTable = self:GetParent().sourceQualityTable;
	local sources = C_TransmogSets.GetSetSources(self.setID);
	for sourceID in pairs(sources) do
		numTotalSlots = numTotalSlots + 1;
		if ( sourceQualityTable[sourceID] ) then
			totalQuality = totalQuality + sourceQualityTable[sourceID];
		else
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
			if ( sourceInfo and sourceInfo.quality ) then
				sourceQualityTable[sourceID] = sourceInfo.quality;
				totalQuality = totalQuality + sourceInfo.quality;
			else
				waitingOnQuality = true;
			end
		end
	end
	if ( waitingOnQuality ) then
		GameTooltip:SetText(RETRIEVING_ITEM_INFO, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		local setQuality = (numTotalSlots > 0 and totalQuality > 0) and Round(totalQuality / numTotalSlots) or Enum.ItemQuality.Common;
		local color = ITEM_QUALITY_COLORS[setQuality];
		local setInfo = C_TransmogSets.GetSetInfo(self.setID);
		GameTooltip:SetText(setInfo.name, color.r, color.g, color.b);
		if ( setInfo.label ) then
			GameTooltip:AddLine(setInfo.label);
			GameTooltip:Show();
		end
	end
end

function WardrobeSetsTransmogModelMixin:OnLeave()
	GameTooltip:Hide();
	self:GetParent().tooltipModel = nil;
end

function WardrobeSetsTransmogModelMixin:OnHide()
	self.setID = nil;
end

function WardrobeSetsTransmogModelMixin:OnModelLoaded()
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
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

function WardrobeCollectionFrame_HideAppearanceTooltip()
	WardrobeCollectionFrame.tooltipContentFrame = nil;
	WardrobeCollectionFrame.tooltipCycle = nil;
	WardrobeCollectionFrame.tooltipSourceIndex = nil;
	GameTooltip:Hide();
end

function WardrobeCollectionFrame_GetDefaultSourceIndex(sources, primarySourceID)
	local collectedSourceIndex;
	local unusableSourceIndex;
	local uncollectedSourceIndex;
	-- default sourceIndex is, in order of preference:
	-- 1. primarySourceID, if collected and usable
	-- 2. collected and usable
	-- 3. unusable primarySourceID
	-- 4. unusable
	-- 5. uncollected primarySourceID
	-- 6. uncollected
	for i, sourceInfo in ipairs(sources) do
		if ( sourceInfo.isCollected ) then
			if ( sourceInfo.useError ) then
				if ( not unusableSourceIndex or primarySourceID == sourceInfo.sourceID ) then
					unusableSourceIndex = i;
				end
			else
				if ( primarySourceID == sourceInfo.sourceID ) then
					-- found #1
					collectedSourceIndex = i;
					break;
				elseif ( not collectedSourceIndex ) then
					collectedSourceIndex = i;
					if ( primarySourceID == NO_TRANSMOG_SOURCE_ID ) then
						-- done
						break;
					end
				end
			end
		else
			if ( not uncollectedSourceIndex or primarySourceID == sourceInfo.sourceID ) then
				uncollectedSourceIndex = i;
			end
		end
	end
	return collectedSourceIndex or unusableSourceIndex or uncollectedSourceIndex or 1;
end

function WardrobeCollectionFrame_SetAppearanceTooltip(contentFrame, sources, primarySourceID)
	WardrobeCollectionFrame.tooltipContentFrame = contentFrame;

	for i = 1, #sources do
		if ( sources[i].isHideVisual ) then
			GameTooltip:SetText(sources[i].name);
			return;
		end
	end

	local firstVisualID = sources[1].visualID;
	local passedFirstVisualID = false;

	local headerIndex;
	if ( not WardrobeCollectionFrame.tooltipSourceIndex ) then
		headerIndex = WardrobeCollectionFrame_GetDefaultSourceIndex(sources, primarySourceID);
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
		-- only add "Other items using this appearance" if we're continuing to the same visualID
		if ( firstVisualID == sources[2].visualID ) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(WARDROBE_OTHER_ITEMS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		for i = 1, #sources do
			-- first time we transition to a different visualID, add "Other items that unlock this slot"
			if ( not passedFirstVisualID and firstVisualID ~= sources[i].visualID ) then
				passedFirstVisualID = true;
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine(WARDROBE_ALTERNATE_ITEMS);
			end

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
		if ( not useError ) then
			local holidayName = C_TransmogCollection.GetSourceRequiredHoliday(headerSourceID);
			if ( holidayName ) then
				GameTooltip:AddLine(TRANSMOG_APPEARANCE_USABLE_HOLIDAY:format(holidayName), LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b, true);
			end
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
		if ( source.sourceType ) then
			sourceText = _G["TRANSMOG_SOURCE_"..source.sourceType];
		end
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
	info.func = function(_, visualID, value) WardrobeCollectionFrameModelDropDown_SetFavorite(visualID, value); end;
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

	if WardrobeFrame_IsAtTransmogrifier() then
		WardrobeCollectionFrame.ItemsCollectionFrame:SelectVisual(visualID);
	end
end

function WardrobeCollectionFrameModelDropDown_SetFavorite(visualID, value, confirmed)
	local set = (value == 1);
	if ( set and not confirmed ) then
		local allSourcesConditional = true;
		local sources = C_TransmogCollection.GetAppearanceSources(visualID);
		for i, sourceInfo in ipairs(sources) do
			local info = C_TransmogCollection.GetAppearanceInfoBySource(sourceInfo.sourceID);
			if ( info.sourceIsCollectedPermanent ) then
				allSourcesConditional = false;
				break;
			end
		end
		if ( allSourcesConditional ) then
			StaticPopup_Show("TRANSMOG_FAVORITE_WARNING", nil, nil, visualID);
			return;
		end
	end
	C_TransmogCollection.SetIsAppearanceFavorite(visualID, set);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true);
	HelpTip:Hide(WardrobeCollectionFrame.ItemsCollectionFrame, TRANSMOG_MOUSE_CLICK_TUTORIAL);
end

-- ***** WEAPON DROPDOWN

function WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameWeaponDropDown_Init(self)
	local transmogLocation = WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation;
	if ( not transmogLocation ) then
		return;
	end

	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = WardrobeCollectionFrameWeaponDropDown_OnClick;

	local equippedItemID = GetInventoryItemID("player", transmogLocation:GetSlotID());
	local checkCategory = equippedItemID and WardrobeFrame_IsAtTransmogrifier();
	if ( checkCategory ) then
		-- if the equipped item cannot be transmogrified, relax restrictions
		local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
		if ( not canTransmogrify and not hasUndo ) then
			checkCategory = false;
		end
	end
	local buttonsAdded = 0;

	local isForMainHand = transmogLocation:IsMainHand();
	local isForOffHand = transmogLocation:IsOffHand();
	for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryID);
		if ( name and isWeapon ) then		
			if ( (isForMainHand and canMainHand) or (isForOffHand and canOffHand) ) then
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
	PlaySound(SOUNDKIT.UI_TRANSMOG_PAGE_TURN);
	CloseDropDownMenus();
	if ( userAction ) then
		self:UpdateItems();
	end
end

-- ***** SEARCHING

function WardrobeCollectionFrame_SwitchSearchCategory()
	if ( WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation:IsIllusion() ) then
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
		local _, _, selectedSourceID = TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
		if ( categoryID == self:GetActiveCategory() ) then
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, self.transmogLocation, true);
		else
			self:UpdateItems();
		end
	else
		self:UpdateItems();
	end
end

function WardrobeCollectionFrame_RestartSearchTracking()
	if ( WardrobeCollectionFrame.activeFrame.transmogLocation and WardrobeCollectionFrame.activeFrame.transmogLocation:IsIllusion() ) then
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

	UIDropDownMenu_AddSeparator();

	info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	info.isNotRadio = true;

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

function WardrobeSetsDataProviderMixin:SortSets(sets, reverseUIOrder, ignorePatchID)
	local comparison = function(set1, set2)
		local groupFavorite1 = set1.favoriteSetID and true;
		local groupFavorite2 = set2.favoriteSetID and true;
		if ( groupFavorite1 ~= groupFavorite2 ) then
			return groupFavorite1;
		end
		if ( set1.favorite ~= set2.favorite ) then
			return set1.favorite;
		end
		if ( set1.expansionID ~= set2.expansionID ) then
			return set1.expansionID > set2.expansionID;
		end
		if not ignorePatchID then
			if ( set1.patchID ~= set2.patchID ) then
				return set1.patchID > set2.patchID;
			end
		end
		if ( set1.uiOrder ~= set2.uiOrder ) then
			if ( reverseUIOrder ) then
				return set1.uiOrder < set2.uiOrder;
			else
				return set1.uiOrder > set2.uiOrder;
			end
		end
		if reverseUIOrder then
			return set1.setID < set2.setID;
		else
			return set1.setID > set2.setID;
		end
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
		-- group sets by baseSetID, except for favorited sets since those are to remain bucketed to the front
		for i, set in ipairs(self.usableSets) do
			if ( not set.favorite ) then
				local baseSetID = set.baseSetID or set.setID;
				local numRelatedSets = 0;
				for j = i + 1, #self.usableSets do
					if ( self.usableSets[j].baseSetID == baseSetID or self.usableSets[j].setID == baseSetID ) then
						numRelatedSets = numRelatedSets + 1;
						-- no need to do anything if already contiguous
						if ( j ~= i + numRelatedSets ) then
							local relatedSet = self.usableSets[j];
							tremove(self.usableSets, j);
							tinsert(self.usableSets, i + numRelatedSets, relatedSet);
						end
					end
				end
			end
		end
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
			local reverseUIOrder = true;
			local ignorePatchID = true;
			self:SortSets(variantSets, reverseUIOrder, ignorePatchID);
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

function WardrobeSetsDataProviderMixin:IsBaseSetNew(baseSetID)
	local baseSetData = self:GetBaseSetData(baseSetID)
	if ( not baseSetData.newStatus ) then
		local newStatus = C_TransmogSets.SetHasNewSources(baseSetID);
		if ( not newStatus ) then
			-- check variants
			local variantSets = self:GetVariantSets(baseSetID);
			for i, variantSet in ipairs(variantSets) do
				if ( C_TransmogSets.SetHasNewSources(variantSet.setID) ) then
					newStatus = true;
					break;
				end
			end
		end
		baseSetData.newStatus = newStatus;
	end
	return baseSetData.newStatus;
end

function WardrobeSetsDataProviderMixin:ResetBaseSetNewStatus(baseSetID)
	local baseSetData = self:GetBaseSetData(baseSetID)
	if ( baseSetData ) then
		baseSetData.newStatus = nil;
	end
end

function WardrobeSetsDataProviderMixin:GetSortedSetSources(setID)
	local returnTable = { };
	local sourceData = self:GetSetSourceData(setID);
	for sourceID, collected in pairs(sourceData.sources) do
		local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
		if ( sourceInfo ) then
			local sortOrder = EJ_GetInvTypeSortOrder(sourceInfo.invType);
			tinsert(returnTable, { sourceID = sourceID, collected = collected, sortOrder = sortOrder, itemID = sourceInfo.itemID, invType = sourceInfo.invType });
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
	self.RightInset.BGCornerTopLeft:Hide();
	self.RightInset.BGCornerTopRight:Hide();

	self.DetailsFrame.Name:SetFontObjectsToTry(Fancy24Font, Fancy20Font, Fancy16Font);
	self.DetailsFrame.itemFramesPool = CreateFramePool("FRAME", self.DetailsFrame, "WardrobeSetsDetailsItemFrameTemplate");

	self.selectedVariantSets = { };
end

function WardrobeSetsCollectionMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	-- select the first set if not init
	local baseSets = SetsDataProvider:GetBaseSets();
	if ( not self.init ) then
		self.init = true;
		if ( baseSets and baseSets[1] ) then
			self:SelectSet(self:GetDefaultSetIDForBaseSet(baseSets[1].setID));
		end
	else
		self:Refresh();
	end

	local latestSource = C_TransmogSets.GetLatestSource();
	if ( latestSource ~= NO_TRANSMOG_SOURCE_ID ) then
		local sets = C_TransmogSets.GetSetsContainingSourceID(latestSource);
		local setID = sets and sets[1];
		if ( setID ) then
			self:SelectSet(setID);
			local baseSetID = C_TransmogSets.GetBaseSetID(setID);
			self:ScrollToSet(baseSetID);
		end
		self:ClearLatestSource();
	end

	WardrobeCollectionFrame.progressBar:Show();
	self:UpdateProgressBar();
	self:RefreshCameras();

	if HelpTip:IsShowing(WardrobeCollectionFrame, TRANSMOG_SETS_TAB_TUTORIAL) then
		HelpTip:Hide(WardrobeCollectionFrame, TRANSMOG_SETS_TAB_TUTORIAL);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SETS_TAB, true);
	end
end

function WardrobeSetsCollectionMixin:OnHide()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
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
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		for itemFrame in self.DetailsFrame.itemFramesPool:EnumerateActive() do
			self:SetItemFrameQuality(itemFrame);
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" ) then
		SetsDataProvider:ClearSets();
		self:Refresh();
		self:UpdateProgressBar();
		self:ClearLatestSource();
	end
end

function WardrobeSetsCollectionMixin:UpdateProgressBar()
	WardrobeCollectionFrame_UpdateProgressBar(C_TransmogSets.GetBaseSetsCounts());
end

function WardrobeSetsCollectionMixin:ClearLatestSource()
	C_TransmogSets.ClearLatestSource();
	WardrobeCollectionFrame_UpdateTabButtons();
end

function WardrobeSetsCollectionMixin:Refresh()
	self.ScrollFrame:Update();
	self:DisplaySet(self:GetSelectedSetID());
end

function WardrobeSetsCollectionMixin:DisplaySet(setID)
	local setInfo = (setID and C_TransmogSets.GetSetInfo(setID)) or nil;
	if ( not setInfo ) then
		self.DetailsFrame:Hide();
		self.Model:Hide();
		return;
	else
		self.DetailsFrame:Show();
		self.Model:Show();
	end

	self.DetailsFrame.Name:SetText(setInfo.name);
	if ( self.DetailsFrame.Name:IsTruncated() ) then
		self.DetailsFrame.Name:Hide();
		self.DetailsFrame.LongName:SetText(setInfo.name);
		self.DetailsFrame.LongName:Show();
	else
		self.DetailsFrame.Name:Show();
		self.DetailsFrame.LongName:Hide();
	end
	self.DetailsFrame.Label:SetText(setInfo.label);
	self.DetailsFrame.LimitedSet:SetShown(setInfo.limitedTimeSet);

	local newSourceIDs = C_TransmogSets.GetSetNewSources(setID);

	self.DetailsFrame.itemFramesPool:ReleaseAll();
	self.Model:Undress();
	local BUTTON_SPACE = 37;	-- button width + spacing between 2 buttons
	local sortedSources = SetsDataProvider:GetSortedSetSources(setID);
	local xOffset = -floor((#sortedSources - 1) * BUTTON_SPACE / 2);
	for i = 1, #sortedSources do
		local itemFrame = self.DetailsFrame.itemFramesPool:Acquire();
		itemFrame.sourceID = sortedSources[i].sourceID;
		itemFrame.itemID = sortedSources[i].itemID;
		itemFrame.collected = sortedSources[i].collected;
		itemFrame.invType = sortedSources[i].invType;
		local texture = C_TransmogCollection.GetSourceIcon(sortedSources[i].sourceID);
		itemFrame.Icon:SetTexture(texture);
		if ( sortedSources[i].collected ) then
			itemFrame.Icon:SetDesaturated(false);
			itemFrame.Icon:SetAlpha(1);
			itemFrame.IconBorder:SetDesaturation(0);
			itemFrame.IconBorder:SetAlpha(1);

			local transmogSlot = C_Transmog.GetSlotForInventoryType(itemFrame.invType);
			if ( C_TransmogSets.SetHasNewSourcesForSlot(setID, transmogSlot) ) then
				itemFrame.New:Show();
				itemFrame.New.Anim:Play();
			else
				itemFrame.New:Hide();
				itemFrame.New.Anim:Stop();
			end
		else
			itemFrame.Icon:SetDesaturated(true);
			itemFrame.Icon:SetAlpha(0.3);
			itemFrame.IconBorder:SetDesaturation(1);
			itemFrame.IconBorder:SetAlpha(0.3);
			itemFrame.New:Hide();
		end
		self:SetItemFrameQuality(itemFrame);
		itemFrame:SetPoint("TOP", self.DetailsFrame, "TOP", xOffset + (i - 1) * BUTTON_SPACE, -94);
		itemFrame:Show();
		self.Model:TryOn(sortedSources[i].sourceID);
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
	if ( itemFrame.collected ) then
		local quality = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID).quality;
		if ( quality == Enum.ItemQuality.Uncommon ) then
			itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-green", true);
		elseif ( quality == Enum.ItemQuality.Rare ) then
			itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-blue", true);
		elseif ( quality == Enum.ItemQuality.Epic ) then
			itemFrame.IconBorder:SetAtlas("loottab-set-itemborder-purple", true);
		end
	end

end

function WardrobeSetsCollectionMixin:OnSearchUpdate()
	if ( self.init ) then
		SetsDataProvider:ClearBaseSets();
		SetsDataProvider:ClearVariantSets();
		SetsDataProvider:ClearUsableSets();
		self:Refresh();
	end
end

function WardrobeSetsCollectionMixin:OnUnitModelChangedEvent()
	if ( IsUnitModelReadyForUI("player") ) then
		self.Model:RefreshUnit();
		-- clearing cameraID so it resets zoom/pan
		self.Model.cameraID = nil;
		self.Model:UpdatePanAndZoomModelType();
		self:RefreshCameras();
		self:Refresh();
		return true;
	else
		return false;
	end
end

function WardrobeSetsCollectionMixin:RefreshCameras()
	if ( self:IsShown() ) then
		local detailsCameraID, transmogCameraID = C_TransmogSets.GetCameraIDs();
		local model = self.Model;
		self.Model:RefreshCamera();
		Model_ApplyUICamera(self.Model, detailsCameraID);
		if ( model.cameraID ~= detailsCameraID ) then
			model.cameraID = detailsCameraID;
			model.defaultPosX, model.defaultPosY, model.defaultPosZ, model.yaw = GetUICameraInfo(detailsCameraID);
		end
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
	if ( SetsDataProvider:IsBaseSetNew(baseSetID) ) then
		if ( C_TransmogSets.SetHasNewSources(baseSetID) ) then
			return baseSetID;
		else
			local variantSets = SetsDataProvider:GetVariantSets(baseSetID);
			for i, variantSet in ipairs(variantSets) do
				if ( C_TransmogSets.SetHasNewSources(variantSet.setID) ) then
					return variantSet.setID;
				end
			end
		end
	end

	if ( self.selectedVariantSets[baseSetID] ) then
		return self.selectedVariantSets[baseSetID];
	end

	local baseSet = SetsDataProvider:GetBaseSetByID(baseSetID);
	if ( baseSet.favoriteSetID ) then
		return baseSet.favoriteSetID;
	end
	-- pick the one with most collected, higher difficulty wins ties
	local highestCount = 0;
	local highestCountSetID;
	local variantSets = SetsDataProvider:GetVariantSets(baseSetID);
	for i = 1, #variantSets do
		local variantSetID = variantSets[i].setID;
		local numCollected = SetsDataProvider:GetSetSourceCounts(variantSetID);
		if ( numCollected > 0 and numCollected >= highestCount ) then
			highestCount = numCollected;
			highestCountSetID = variantSetID;
		end
	end
	return highestCountSetID or baseSetID;
end

function WardrobeSetsCollectionMixin:SelectSetFromButton(setID)
	CloseDropDownMenus();
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

function WardrobeSetsCollectionMixin:SetAppearanceTooltip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	self.tooltipTransmogSlot = C_Transmog.GetSlotForInventoryType(frame.invType);
	self.tooltipPrimarySourceID = frame.sourceID;
	self:RefreshAppearanceTooltip();
end

function WardrobeSetsCollectionMixin:RefreshAppearanceTooltip()
	if ( not self.tooltipTransmogSlot ) then
		return;
	end

	local sources = C_TransmogSets.GetSourcesForSlot(self:GetSelectedSetID(), self.tooltipTransmogSlot);
	if ( #sources == 0 ) then
		-- can happen if a slot only has HiddenUntilCollected sources
		local sourceInfo = C_TransmogCollection.GetSourceInfo(self.tooltipPrimarySourceID);
		tinsert(sources, sourceInfo);
	end
	WardrobeCollectionFrame_SortSources(sources, sources[1].visualID, self.tooltipPrimarySourceID);
	WardrobeCollectionFrame_SetAppearanceTooltip(self, sources, self.tooltipPrimarySourceID);
end

function WardrobeSetsCollectionMixin:ClearAppearanceTooltip()
	self.tooltipTransmogSlot = nil;
	self.tooltipPrimarySourceID = nil;
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

function WardrobeSetsCollectionMixin:CanHandleKey(key)
	if ( key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY ) then
		return true;
	end
	return false;
end

function WardrobeSetsCollectionMixin:HandleKey(key)
	if ( not self:GetSelectedSetID() ) then
		return false;
	end
	local selectedSetID = C_TransmogSets.GetBaseSetID(self:GetSelectedSetID());
	local _, index = SetsDataProvider:GetBaseSetByID(selectedSetID);
	if ( not index ) then
		return;
	end
	if ( key == WARDROBE_DOWN_VISUAL_KEY ) then
		index = index + 1;
	elseif ( key == WARDROBE_UP_VISUAL_KEY ) then
		index = index - 1;
	end
	local sets = SetsDataProvider:GetBaseSets();
	index = Clamp(index, 1, #sets);
	self:SelectSet(self:GetDefaultSetIDForBaseSet(sets[index].setID));
	self:ScrollToSet(sets[index].setID);
end

function WardrobeSetsCollectionMixin:ScrollToSet(setID)
	local totalHeight = 0;
	local scrollFrameHeight = self.ScrollFrame:GetHeight();
	local buttonHeight = self.ScrollFrame.buttonHeight;
	for i, set in ipairs(SetsDataProvider:GetBaseSets()) do
		if ( set.setID == setID ) then
			local offset = self.ScrollFrame.scrollBar:GetValue();
			if ( totalHeight + buttonHeight > offset + scrollFrameHeight ) then
				offset = totalHeight + buttonHeight - scrollFrameHeight;
			elseif ( totalHeight < offset ) then
				offset = totalHeight;
			end
			self.ScrollFrame.scrollBar:SetValue(offset, true);
			break;
		end
		totalHeight = totalHeight + buttonHeight;
	end
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
	local selectedSetID = self:GetParent():GetSelectedSetID();
	local selectedBaseSetID = selectedSetID and C_TransmogSets.GetBaseSetID(selectedSetID);

	for i = 1, #buttons do
		local button = buttons[i];
		local setIndex = i + offset;
		if ( setIndex <= #baseSets ) then
			local baseSet = baseSets[setIndex];
			button:Show();
			button.Name:SetText(baseSet.name);
			local topSourcesCollected, topSourcesTotal = SetsDataProvider:GetSetSourceTopCounts(baseSet.setID);
			local setCollected = C_TransmogSets.IsBaseSetCollected(baseSet.setID);
			local color = IN_PROGRESS_FONT_COLOR;
			if ( setCollected ) then
				color = NORMAL_FONT_COLOR;
			elseif ( topSourcesCollected == 0 ) then
				color = GRAY_FONT_COLOR;
			end
			button.Name:SetTextColor(color.r, color.g, color.b);
			button.Label:SetText(baseSet.label);
			button.Icon:SetTexture(SetsDataProvider:GetIconForSet(baseSet.setID));
			button.Icon:SetDesaturation((topSourcesCollected == 0) and 1 or 0);
			button.SelectedTexture:SetShown(baseSet.setID == selectedBaseSetID);
			button.Favorite:SetShown(baseSet.favoriteSetID);
			button.New:SetShown(SetsDataProvider:IsBaseSetNew(baseSet.setID));
			button.setID = baseSet.setID;

			if ( topSourcesCollected == 0 or setCollected ) then
				button.ProgressBar:Hide();
			else
				button.ProgressBar:Show();
				button.ProgressBar:SetWidth(SET_PROGRESS_BAR_MAX_WIDTH * topSourcesCollected / topSourcesTotal);
			end
			button.IconCover:SetShown(not setCollected);
		else
			button:Hide();
		end
	end

	local extraHeight = (self.largeButtonHeight and self.largeButtonHeight - BASE_SET_BUTTON_HEIGHT) or 0;
	local totalHeight = #baseSets * BASE_SET_BUTTON_HEIGHT + extraHeight;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

WardrobeSetsDetailsModelMixin = { };

function WardrobeSetsDetailsModelMixin:OnLoad()
	self:SetAutoDress(false);
	self:SetUnit("player");
	self:UpdatePanAndZoomModelType();
	self:SetLight(true, false, -1, 0, 0, .7, .7, .7, .7, .6, 1, 1, 1);
end

function WardrobeSetsDetailsModelMixin:UpdatePanAndZoomModelType()
	local hasAlternateForm, inAlternateForm = HasAlternateForm();
	if ( not self.panAndZoomModelType or self.inAlternateForm ~= inAlternateForm ) then
		local _, race = UnitRace("player");
		local sex = UnitSex("player");
		if ( inAlternateForm ) then
			self.panAndZoomModelType = race..sex.."Alt";
		else
			self.panAndZoomModelType = race..sex;
		end
		self.inAlternateForm = inAlternateForm;
	end
end

function WardrobeSetsDetailsModelMixin:GetPanAndZoomLimits()
	return SET_MODEL_PAN_AND_ZOOM_LIMITS[self.panAndZoomModelType];
end

function WardrobeSetsDetailsModelMixin:OnUpdate(elapsed)
	if ( self.rotating ) then
		local x = GetCursorPosition();
		local diff = (x - self.rotateStartCursorX) * MODELFRAME_DRAG_ROTATION_CONSTANT;
		self.rotateStartCursorX = GetCursorPosition();
		self.yaw = self.yaw + diff;
		if ( self.yaw < 0 ) then
			self.yaw = self.yaw + (2 * PI);
		end
		if ( self.yaw > (2 * PI) ) then
			self.yaw = self.yaw - (2 * PI);
		end
		self:SetRotation(self.yaw, false);
	elseif ( self.panning ) then
		local cursorX, cursorY = GetCursorPosition();
		local modelX = self:GetPosition();
		local panSpeedModifier = 100 * sqrt(1 + modelX - self.defaultPosX);
		local modelY = self.panStartModelY + (cursorX - self.panStartCursorX) / panSpeedModifier;
		local modelZ = self.panStartModelZ + (cursorY - self.panStartCursorY) / panSpeedModifier;
		local limits = self:GetPanAndZoomLimits();
		modelY = Clamp(modelY, limits.panMaxLeft, limits.panMaxRight);
		modelZ = Clamp(modelZ, limits.panMaxBottom, limits.panMaxTop);
		self:SetPosition(modelX, modelY, modelZ);
	end
end

function WardrobeSetsDetailsModelMixin:OnMouseDown(button)
	if ( button == "LeftButton" ) then
		self.rotating = true;
		self.rotateStartCursorX = GetCursorPosition();
	elseif ( button == "RightButton" ) then
		self.panning = true;
		self.panStartCursorX, self.panStartCursorY = GetCursorPosition();
		local modelX, modelY, modelZ = self:GetPosition();
		self.panStartModelY = modelY;
		self.panStartModelZ = modelZ;
	end
end

function WardrobeSetsDetailsModelMixin:OnMouseUp(button)
	if ( button == "LeftButton" ) then
		self.rotating = false;
	elseif ( button == "RightButton" ) then
		self.panning = false;
	end
end

function WardrobeSetsDetailsModelMixin:OnMouseWheel(delta)
	local posX, posY, posZ = self:GetPosition();
	posX = posX + delta * 0.5;
	local limits = self:GetPanAndZoomLimits();
	posX = Clamp(posX, self.defaultPosX, limits.maxZoom);
	self:SetPosition(posX, posY, posZ);
end

function WardrobeSetsDetailsModelMixin:OnModelLoaded()
	if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

WardrobeSetsDetailsItemMixin = { };

function WardrobeSetsDetailsItemMixin:OnEnter()
	self:GetParent():GetParent():SetAppearanceTooltip(self)

	self:SetScript("OnUpdate",
		function()
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end
	);

	if ( self.New:IsShown() ) then
		local transmogSlot = C_Transmog.GetSlotForInventoryType(self.invType);
		local setID = WardrobeCollectionFrame.SetsCollectionFrame:GetSelectedSetID();
		C_TransmogSets.ClearSetNewSourcesForSlot(setID, transmogSlot);
		local baseSetID = C_TransmogSets.GetBaseSetID(setID);
		SetsDataProvider:ResetBaseSetNewStatus(baseSetID);
		WardrobeCollectionFrame.SetsCollectionFrame:Refresh();
	end
end

function WardrobeSetsDetailsItemMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

function WardrobeSetsDetailsItemMixin:OnMouseDown()
	if ( IsModifiedClick("CHATLINK") ) then
		local sourceInfo = C_TransmogCollection.GetSourceInfo(self.sourceID);
		local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType);
		local sources = C_TransmogSets.GetSourcesForSlot(self:GetParent():GetParent():GetSelectedSetID(), slot);
		if ( #sources == 0 ) then
			-- can happen if a slot only has HiddenUntilCollected sources
			tinsert(sources, sourceInfo);
		end
		WardrobeCollectionFrame_SortSources(sources, sourceInfo.visualID, self.sourceID);
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
	self.APPLIED_SOURCE_INDEX = 1;
	self.SELECTED_SOURCE_INDEX = 3;
end

function WardrobeSetsTransmogMixin:OnShow()
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
	self:RefreshCameras();
	local RESET_SELECTION = true;
	self:Refresh(RESET_SELECTION);
	WardrobeCollectionFrame.progressBar:Show();
	self:UpdateProgressBar();
	self.sourceQualityTable = { };

	if HelpTip:IsShowing(WardrobeCollectionFrame, TRANSMOG_SETS_VENDOR_TUTORIAL) then
		HelpTip:Hide(WardrobeCollectionFrame, TRANSMOG_SETS_VENDOR_TUTORIAL);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SETS_VENDOR_TAB, true);
	end
end

function WardrobeSetsTransmogMixin:OnHide()
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
	self.loadingSetID = nil;
	SetsDataProvider:ClearSets();
	WardrobeCollectionFrame_ClearSearch(LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS);
	self.sourceQualityTable = nil;
end

function WardrobeSetsTransmogMixin:OnEvent(event, ...)
	if ( event == "TRANSMOGRIFY_UPDATE" and not self.ignoreTransmogrifyUpdateEvent ) then
		self:Refresh();
	elseif ( event == "TRANSMOGRIFY_SUCCESS" )  then
		-- this event fires once per slot so in the case of a set there would be up to 9 of them
		if ( not self.transmogrifySuccessUpdate ) then
			self.transmogrifySuccessUpdate = true;
			C_Timer.After(0, function() self.transmogrifySuccessUpdate = nil; self:Refresh(); end);
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" or event == "TRANSMOG_SETS_UPDATE_FAVORITE" ) then
		SetsDataProvider:ClearSets();
		self:Refresh();
		self:UpdateProgressBar();
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		if ( self.loadingSetID ) then
			local setID = self.loadingSetID;
			self.loadingSetID = nil;
			self:LoadSet(setID);
		end
		if ( self.tooltipModel ) then
			self.tooltipModel:RefreshTooltip();
		end
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( self.selectedSetID ) then
			self:LoadSet(self.selectedSetID);
		end
		self:Refresh();
	end
end

function WardrobeSetsTransmogMixin:OnMouseWheel(value)
	self.PagingFrame:OnMouseWheel(value);
end

function WardrobeSetsTransmogMixin:UpdateProgressBar()
	WardrobeCollectionFrame_UpdateProgressBar(C_TransmogSets.GetBaseSetsCounts());
end

function WardrobeSetsTransmogMixin:Refresh(resetSelection)
	self.appliedSetID = self:GetFirstMatchingSetID(self.APPLIED_SOURCE_INDEX);
	if ( resetSelection ) then
		self.selectedSetID = self:GetFirstMatchingSetID(self.SELECTED_SOURCE_INDEX);
		self:ResetPage();
	else
		self:UpdateSets();
	end
end

function WardrobeSetsTransmogMixin:UpdateSets()
	local usableSets = SetsDataProvider:GetUsableSets();
	self.PagingFrame:SetMaxPages(ceil(#usableSets / self.PAGE_SIZE));
	local pendingTransmogModelFrame = nil;
	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local set = usableSets[index];
		if ( set ) then
			model:Show();
			if ( model.setID ~= set.setID ) then
				model:Undress();
				local sourceData = SetsDataProvider:GetSetSourceData(set.setID);
				for sourceID  in pairs(sourceData.sources) do
					model:TryOn(sourceID);
				end
			end
			local transmogStateAtlas;
			if ( set.setID == self.appliedSetID and set.setID == self.selectedSetID ) then
				transmogStateAtlas = "transmog-set-border-current-transmogged";
			elseif ( set.setID == self.selectedSetID ) then
				transmogStateAtlas = "transmog-set-border-selected";
				pendingTransmogModelFrame = model;
			end
			if ( transmogStateAtlas ) then
				model.TransmogStateTexture:SetAtlas(transmogStateAtlas, true);
				model.TransmogStateTexture:Show();
			else
				model.TransmogStateTexture:Hide();
			end
			model.Favorite.Icon:SetShown(set.favorite);
			model.setID = set.setID;
		else
			model:Hide();
		end
	end

	if ( pendingTransmogModelFrame ) then
		self.PendingTransmogFrame:SetParent(pendingTransmogModelFrame);
		self.PendingTransmogFrame:SetPoint("CENTER");
		self.PendingTransmogFrame:Show();
		if ( self.PendingTransmogFrame.setID ~= pendingTransmogModelFrame.setID ) then
			self.PendingTransmogFrame.TransmogSelectedAnim:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim2:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim2:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim3:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim3:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim4:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim4:Play();
			self.PendingTransmogFrame.TransmogSelectedAnim5:Stop();
			self.PendingTransmogFrame.TransmogSelectedAnim5:Play();
		end
		self.PendingTransmogFrame.setID = pendingTransmogModelFrame.setID;
	else
		self.PendingTransmogFrame:Hide();
	end

	self.NoValidSetsLabel:SetShown(not C_TransmogSets.HasUsableSets());
end

function WardrobeSetsTransmogMixin:OnPageChanged(userAction)
	PlaySound(SOUNDKIT.UI_TRANSMOG_PAGE_TURN);
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
		local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType);
		local slotSources = C_TransmogSets.GetSourcesForSlot(setID, slot);
		WardrobeCollectionFrame_SortSources(slotSources, sourceInfo.visualID);
		local index = WardrobeCollectionFrame_GetDefaultSourceIndex(slotSources, sourceID);
		transmogSources[slot] = slotSources[index].sourceID;

		for i, slotSourceInfo in ipairs(slotSources) do
			if ( not slotSourceInfo.name ) then
				waitingOnData = true;
			end
		end
	end
	if ( waitingOnData ) then
		self.loadingSetID = setID;
	else
		self.loadingSetID = nil;
		-- if we don't ignore the event, clearing will momentarily set the page to the one with the set the user currently has transmogged
		-- if that's a different page from the current one then the models will flicker as we swap the gear to different sets and back
		self.ignoreTransmogrifyUpdateEvent = true;
		C_Transmog.ClearAllPending();
		self.ignoreTransmogrifyUpdateEvent = false;
		C_Transmog.LoadSources(transmogSources, -1, -1);
	end
end

function WardrobeSetsTransmogMixin:GetFirstMatchingSetID(sourceIndex)
	local transmogSourceIDs = { };
	for _, button in ipairs(WardrobeTransmogFrame.ModelScene.SlotButtons) do
		local sourceID = select(sourceIndex, TransmogUtil.GetInfoForEquippedSlot(button.transmogLocation));
		if ( sourceID ~= NO_TRANSMOG_SOURCE_ID ) then
			transmogSourceIDs[button.transmogLocation:GetSlotID()] = sourceID;
		end
	end

	local usableSets = SetsDataProvider:GetUsableSets();
	for _, set in ipairs(usableSets) do
		local setMatched = false;
		for slotID, transmogSourceID in pairs(transmogSourceIDs) do
			local sourceIDs = C_TransmogSets.GetSourceIDsForSlot(set.setID, slotID);
			-- if there are no sources for a slot, that slot is considered matched
			local slotMatched = (#sourceIDs == 0);
			for _, sourceID in ipairs(sourceIDs) do
				if ( transmogSourceID == sourceID ) then
					slotMatched = true;
					break;
				end
			end
			setMatched = slotMatched;
			if ( not setMatched ) then
				break;
			end
		end
		if ( setMatched ) then
			return set.setID;
		end
	end
	return nil;
end

function WardrobeSetsTransmogMixin:OnUnitModelChangedEvent()
	if ( IsUnitModelReadyForUI("player") ) then
		for i, model in ipairs(self.Models) do
			model:RefreshUnit();
			model.setID = nil;
		end
		self:RefreshCameras();
		self:UpdateSets();
		return true;
	else
		return false;
	end
end

function WardrobeSetsTransmogMixin:RefreshCameras()
	if ( self:IsShown() ) then
		local detailsCameraID, transmogCameraID = C_TransmogSets.GetCameraIDs();
		for i, model in ipairs(self.Models) do
			model.cameraID = transmogCameraID;
			model:RefreshCamera();
			Model_ApplyUICamera(model, transmogCameraID);
		end
	end
end

function WardrobeSetsTransmogMixin:OnSearchUpdate()
	SetsDataProvider:ClearUsableSets();
	self:UpdateSets();
end

function WardrobeSetsTransmogMixin:SelectSet(setID)
	self.selectedSetID = setID;
	self:LoadSet(setID);
	self:ResetPage();
end

function WardrobeSetsTransmogMixin:CanHandleKey(key)
	if ( key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY ) then
		return true;
	end
	return false;
end

function WardrobeSetsTransmogMixin:HandleKey(key)
	if ( not self.selectedSetID ) then
		return;
	end

	local setIndex;
	local usableSets = SetsDataProvider:GetUsableSets();
	for i = 1, #usableSets do
		if ( usableSets[i].setID == self.selectedSetID ) then
			setIndex = i;
			break;
		end
	end

	if ( setIndex ) then
		setIndex = WardrobeUtils_GetAdjustedDisplayIndexFromKeyPress(self, setIndex, #usableSets, key);
		self:SelectSet(usableSets[setIndex].setID);
	end
end

function WardrobeSetsTransmogMixin:ResetPage()
	local page = 1;
	if ( self.selectedSetID ) then
		local usableSets = SetsDataProvider:GetUsableSets();
		self.PagingFrame:SetMaxPages(ceil(#usableSets / self.PAGE_SIZE));
		for i, set in ipairs(usableSets) do
			if ( set.setID == self.selectedSetID ) then
				page = GetPage(i, self.PAGE_SIZE);
				break;
			end
		end
	end
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateSets();
end

function WardrobeSetsTransmogMixin:OpenRightClickDropDown()
	if ( not self.RightClickDropDown.activeFrame ) then
		return;
	end
	local setID = self.RightClickDropDown.activeFrame.setID;
	local info = UIDropDownMenu_CreateInfo();
	if ( C_TransmogSets.GetIsFavorite(setID) ) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.func = function() self:SetFavorite(setID, false); end
	else
		info.text = BATTLE_PET_FAVORITE;
		info.func = function() self:SetFavorite(setID, true); end
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	-- Cancel
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = CANCEL;
	UIDropDownMenu_AddButton(info);
end

function WardrobeSetsTransmogMixin:SetFavorite(setID, favorite)
	if ( favorite ) then
		-- remove any existing favorite in this group
		local isFavorite, isGroupFavorite = C_TransmogSets.GetIsFavorite(setID);
		if ( isGroupFavorite ) then
			local baseSetID = C_TransmogSets.GetBaseSetID(setID);
			C_TransmogSets.SetIsFavorite(baseSetID, false);
			local variantSets = C_TransmogSets.GetVariantSets(baseSetID);
			for i, variantSet in ipairs(variantSets) do
				C_TransmogSets.SetIsFavorite(variantSet.setID, false);
			end
		end
		C_TransmogSets.SetIsFavorite(setID, true);
	else
		C_TransmogSets.SetIsFavorite(setID, false);
	end
end

do
	local function OpenRightClickDropDown(self)
		self:GetParent():OpenRightClickDropDown();
	end
	function WardrobeSetsTransmogModelRightClickDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenRightClickDropDown, "MENU");
	end
end