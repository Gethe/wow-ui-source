
local NO_SOURCE_ID = 0;
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
	self.Model.HeadButton.displayHelm = ShowingHelm();
	self.Model.BackButton.displayCloak = ShowingCloak();
	
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
	if ( hasChange and not slotButton.AnimFrame:IsShown() ) then
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
	if ( slotButton.slot == "HEADSLOT" and not slotButton.displayHelm ) then
		if ( hasChange ) then
			slotButton.displayHelm = true;
		else
			showModel = false;
		end
	end
	if ( slotButton.slot == "BACKSLOT" and not slotButton.displayCloak ) then
		if ( hasChange ) then
			slotButton.displayCloak = true;
		else
			showModel = false;
		end
	end
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
		if ( hasPending or hasUndo ) then
			GameTooltip:SetTransmogrifyItem(slotID);
		elseif ( not canTransmogrify ) then
			GameTooltip:SetText(_G[self.slot]);
			local errorMsg = _G["TRANSMOGRIFY_INVALID_REASON"..cannotTransmogrifyReason];
			if ( errorMsg ) then
				GameTooltip:AddLine(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			GameTooltip:Show();
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

local CURRENT_PAGE;
local WARDROBE_PAGE_SIZE = 18;
local MAIN_HAND_INV_TYPE = 21;
local OFF_HAND_INV_TYPE = 22;
local RANGED_INV_TYPE = 15;
local MODEL_ANIM_STOP = 3;

-- global strings
WARDROBE_WEAPONS = "Weapons";
WARDROBE_COLLECTED = "Collected";
WARDROBE_OTHER_ITEMS = "Other items using this style:";
WARDROBE_TRANSMOGRIFY_AS = "Transmogrify as:"

-- ************************************************************************************************************************************************************
-- **** START STUB/TEMP ***************************************************************************************************************************************
-- ************************************************************************************************************************************************************

local TEMP_SOURCES = {
  [1] = { t = 'Vendor', n = 'Armorer Moki', l = 'The Jade Forest' },
  [2] = { t = 'Vendor', n = 'Arnold Raygun', l = 'Isle of Giants' },
  [3] = { t = 'Vendor', n = 'Arsenio Zerep', l = 'Lunarfall' },
  [4] = { t = 'Vendor', n = 'Artificer Baleera', l = 'Shadowmoon Valley' },
  [5] = { t = 'Vendor', n = 'Ashley Zerep', l = 'Lunarfall' },
  [6] = { t = 'Vendor', n = 'Aster', l = 'Vale of Eternal Blossoms' },
  [7] = { t = 'Vendor', n = 'Auria Irondreamer', l = 'Lunarfall' },
  [8] = { t = 'Vendor', n = 'Ayada the White', l = 'Lunarfall' },
  [9] = { t = 'Vendor', n = 'Bai Hua', l = 'The Wandering Isle' },
  [10] = { t = 'Vendor', n = 'Barleyflower', l = 'Shrine of Two Moons' },
  [11] = { t = 'Vendor', n = 'Barnaby Fletcher', l = 'Valley of the Four Winds' },
  [12] = { t = 'Vendor', n = 'Ben of the Booming Voice', l = 'Valley of the Four Winds' },
  [13] = { t = 'Vendor', n = 'Bero', l = 'Shrine of Seven Stars' },
  [14] = { t = 'Vendor', n = 'Big Dan Stormstout', l = 'Timeless Isle' },
  [15] = { t = 'Vendor', n = 'Big Keech', l = 'Vale of Eternal Blossoms' },
  [16] = { t = 'Vendor', n = 'Black Arrow', l = 'Kun-Lai Summit' },
  [17] = { t = 'Vendor', n = 'Bonni Chang', l = 'Shrine of Seven Stars' },
  [18] = { t = 'Vendor', n = 'Borus', l = 'Shadowmoon Valley' },
  [19] = { t = 'Vendor', n = 'Bowfitter Suyin', l = 'Krasarang Wilds' },
  [20] = { t = 'Vendor', n = 'Brewmaster Chani', l = 'Kun-Lai Summit' },
  [21] = { t = 'Vendor', n = 'Brewmaster Chani', l = 'Timeless Isle' },
  [22] = { t = 'Vendor', n = 'Brewmaster Roland', l = 'Shrine of Two Moons' },
  [23] = { t = 'Vendor', n = 'Brewmaster Skye', l = 'Shrine of Two Moons' },
  [24] = { t = 'Vendor', n = 'Brewmaster Vudia', l = 'Shrine of Two Moons' },
  [25] = { t = 'Vendor', n = 'Brother Noodle', l = 'Timeless Isle' },
  [26] = { t = 'Vendor', n = 'Bry Lang', l = 'The Jade Forest' },
  [27] = { t = 'Vendor', n = 'Card Trader Ami', l = 'Brawl\'gar Arena' },
  [28] = { t = 'Vendor', n = 'Card Trader Leila', l = 'Deeprun Tram' },
  [29] = { t = 'Vendor', n = 'Challenger Soong', l = 'Vale of Eternal Blossoms' },
  [30] = { t = 'Vendor', n = 'Challenger Wuli', l = 'Vale of Eternal Blossoms' },
  [31] = { t = 'Vendor', n = 'Chao of the Hundred Crabs', l = 'Dread Wastes' },
  [32] = { t = 'Vendor', n = 'Christopher Macdonald', l = 'Lunarfall' },
  [33] = { t = 'Vendor', n = 'Clara Henry', l = 'Shrine of Seven Stars' },
  [34] = { t = 'Vendor', n = 'Collin Gooddreg', l = 'Shrine of Seven Stars' },
  [35] = { t = 'Vendor', n = 'Commander Lo Ping', l = 'Townlong Steppes' },
  [36] = { t = 'Vendor', n = 'Commander Oxheart', l = 'Townlong Steppes' },
  [37] = { t = 'Vendor', n = 'Cook Jun', l = 'Dread Wastes' },
  [38] = { t = 'Vendor', n = 'Costan Highwall', l = 'Lunarfall' },
  [39] = { t = 'Vendor', n = 'Cousin Slowhands', l = '' },
  [40] = { t = 'Vendor', n = 'Crafter Kwon', l = 'Timeless Isle' },
  [41] = { t = 'Vendor', n = 'Cranfur the Noodler', l = 'Krasarang Wilds' },
  [42] = { t = 'Vendor', n = 'Cullen Hammerbrow', l = 'Shrine of Seven Stars' },
  [43] = { t = 'Vendor', n = 'Dame Jesepha', l = 'Deeprun Tram' },
  [44] = { t = 'Vendor', n = 'Danky', l = 'Vale of Eternal Blossoms' },
  [45] = { t = 'Vendor', n = 'Dean\'na', l = 'Frostfire Ridge' },
  [46] = { t = 'Vendor', n = 'Deckmender Lu', l = 'Dread Wastes' },
  [47] = { t = 'Vendor', n = 'Deedree', l = 'Lunarfall' },
  [48] = { t = 'Vendor', n = 'Deluwin Whisperfield', l = 'Lunarfall' },
  [49] = { t = 'Vendor', n = 'Den Den', l = 'Valley of the Four Winds' },
  [50] = { t = 'Vendor', n = 'Derenda Enkleshin', l = 'Shrine of Two Moons' },
  [51] = { t = 'Vendor', n = 'Disciple Jusi', l = 'Orgrimmar' },
  [52] = { t = 'Vendor', n = 'Dorogarr', l = 'Frostwall' },
  [53] = { t = 'Vendor', n = 'Elisa Vanning', l = 'Lunarfall' },
  [54] = { t = 'Vendor', n = 'Emdal', l = 'Shadowmoon Valley' },
  [55] = { t = 'Vendor', n = 'Emma Strikken', l = 'Lunarfall' },
  [56] = { t = 'Vendor', n = 'Enohar Thunderbrew', l = 'Blasted Lands' },
  [57] = { t = 'Vendor', n = 'Er', l = 'The Wandering Isle' },
  [58] = { t = 'Vendor', n = 'Eric Broadoak', l = 'Lunarfall' },
  [59] = { t = 'Vendor', n = 'Esha the Loommaiden', l = 'Shrine of Two Moons' },
  [60] = { t = 'Vendor', n = 'Fanara', l = 'Shadowmoon Valley' },
  [61] = { t = 'Vendor', n = 'Fang Whitescroll', l = 'Shrine of Two Moons' },
  [62] = { t = 'Vendor', n = 'Faraan', l = 'Shadowmoon Valley' },
  [63] = { t = 'Vendor', n = 'Field Merchant Skevin', l = 'Krasarang Wilds' },
  [64] = { t = 'Vendor', n = 'Fei Li', l = 'Timeless Isle' },
  [65] = { t = 'Vendor', n = '<The Firecracker>', l = '' },
  [66] = { t = 'Vendor', n = 'Auntie Stormstout', l = 'Stormstout Brewery' },
  [67] = { t = 'Vendor', n = 'Alchemist Yuan', l = 'Kun-Lai Summit' },
  [68] = { t = 'Vendor', n = 'Big Sal', l = 'Kun-Lai Summit' },
  [69] = { t = 'Vendor', n = 'Brother Rabbitsfoot', l = 'Timeless Isle' },
  [70] = { t = 'Vendor', n = 'Brother Yakshoe', l = 'Kun-Lai Summit' },
  [71] = { t = 'Vendor', n = 'Brother Yakshoe', l = 'Valley of the Four Winds' },
  [72] = { t = 'Vendor', n = 'Brother Yakshoe', l = 'Timeless Isle' },
  [73] = { t = 'Vendor', n = 'Clover Keeper', l = 'Kun-Lai Summit' },
  [74] = { t = 'Vendor', n = 'Cousin Copperfinder', l = 'Kun-Lai Summit' },
  [75] = { t = 'Vendor', n = 'Cousin Mountainmusk', l = 'Kun-Lai Summit' },
  [76] = { t = 'Vendor', n = 'Fixxit Redhammer', l = 'Kun-Lai Summit' },
  [77] = { t = 'Vendor', n = 'Christofen Moonfeather', l = 'Krasarang Wilds' },
  [78] = { t = 'Vendor', n = 'Armorer Gang', l = 'Kun-Lai Summit' },
  [79] = { t = 'Vendor', n = 'Brewmaster Boof', l = 'Kun-Lai Summit, The Veiled Stair' },
  [80] = { t = 'Vendor', n = 'Brewmaster Boof', l = 'Timeless Isle' },
  [81] = { t = 'Vendor', n = 'Claretta', l = 'Valley of the Four Winds' },
  [82] = { t = 'Vendor', n = 'Elyssa Nightquiver', l = 'Krasarang Wilds' },
  [83] = { t = 'Vendor', n = 'Damek Bloombeard', l = 'Molten Front' },
  [84] = { t = 'Vendor', n = 'Alin the Finder', l = 'Townlong Steppes' },
  [85] = { t = 'Vendor', n = 'Ayla Shadowstorm', l = 'Molten Front' },
  [86] = { t = 'Vendor', n = 'Baird Darkfeather', l = 'Twilight Highlands' },
  [87] = { t = 'Vendor', n = 'Bario Matalli', l = 'Stormwind City' },
  [88] = { t = 'Vendor', n = 'Ben Mora', l = 'Twilight Highlands' },
  [89] = { t = 'Vendor', n = 'Bolo the Elder', l = 'The Jade Forest' },
  [90] = { t = 'Vendor', n = 'Bren Stoneforge', l = 'Twilight Highlands' },
  [91] = { t = 'Vendor', n = 'Brewmaster Lei Kanglei', l = 'The Jade Forest' },
  [92] = { t = 'Vendor', n = 'Brewmother Kiki', l = 'The Jade Forest' },
  [93] = { t = 'Vendor', n = 'Brian Terrel', l = 'Twilight Highlands' },
  [94] = { t = 'Vendor', n = 'Carrick Irongrin', l = 'Twilight Highlands' },
  [95] = { t = 'Vendor', n = 'Cerie Bowden', l = 'Twilight Highlands' },
  [96] = { t = 'Vendor', n = 'Chef Kyel', l = 'The Jade Forest' },
  [97] = { t = 'Vendor', n = 'Cheung', l = 'The Jade Forest' },
  [98] = { t = 'Vendor', n = 'Chin', l = 'The Jade Forest' },
  [99] = { t = 'Vendor', n = 'Craftsman Hui', l = 'The Jade Forest' },
  [100] = { t = 'Vendor', n = 'Craw MacGraw', l = 'Twilight Highlands' },
  [101] = { t = 'Vendor', n = 'Daniel Lanchester', l = 'Twilight Highlands' },
  [102] = { t = 'Drop', n = 'Beryl Mage Hunter', l = 'Borean Tundra' },
  [103] = { t = 'Drop', n = 'Dreadwing', l = 'Blade\'s Edge Mountains' },
  [104] = { t = 'Drop', n = 'Beryl Sorcerer', l = 'Borean Tundra' },
  [105] = { t = 'Drop', n = 'Dreghood Drudge', l = 'Zangarmarsh' },
  [106] = { t = 'Drop', n = 'Maaka', l = 'Valley of the Four Winds' },
  [107] = { t = 'Drop', n = 'Drek\'Maz', l = 'Zul\'Drak' },
  [108] = { t = 'Drop', n = 'Luthion the Vile', l = 'Borean Tundra' },
  [109] = { t = 'Drop', n = 'Drillmaster Zurok', l = 'Hellfire Peninsula' },
  [110] = { t = 'Drop', n = 'Bimba', l = 'Valley of the Four Winds' },
  [111] = { t = 'Drop', n = 'Droggam', l = 'Blade\'s Edge Mountains' },
  [112] = { t = 'Drop', n = 'Bishop Street', l = 'Dragonblight' },
  [113] = { t = 'Drop', n = 'Drowned Gilnean Merchant', l = 'Blasted Lands' },
  [114] = { t = 'Drop', n = 'Blackmane Brigand', l = 'Kun-Lai Summit' },
  [115] = { t = 'Drop', n = 'Drowned Gilnean Sailor', l = 'Blasted Lands' },
  [116] = { t = 'Drop', n = 'Blackrock Forgeworker', l = 'Tanaan Jungle' },
  [117] = { t = 'Drop', n = 'Druid of the Flame', l = 'Molten Front' },
  [118] = { t = 'Drop', n = 'Blackrock Slaghauler', l = 'Tanaan Jungle' },
  [119] = { t = 'Drop', n = 'Druid of the Flame', l = 'Molten Front' },
  [120] = { t = 'Drop', n = 'Blackscale Myrmidon', l = 'Twilight Highlands' },
  [121] = { t = 'Drop', n = 'Druid of the Flame', l = 'Molten Front' },
  [122] = { t = 'Drop', n = 'Blacksmith Goodman', l = 'Dragonblight' },
  [123] = { t = 'Drop', n = 'Druid of the Flame', l = 'Molten Front' },
  [124] = { t = 'Drop', n = 'Blacktalon the Savage', l = 'Hellfire Peninsula' },
  [125] = { t = 'Drop', n = 'Druid of the Flame', l = 'Firelands' },
  [126] = { t = 'Drop', n = 'Bladespire Battlemage', l = 'Blade\'s Edge Mountains' },
  [127] = { t = 'Drop', n = 'Master Daellis Dawnstrike', l = 'Netherstorm' },
  [128] = { t = 'Drop', n = 'Bladespire Champion', l = 'Blade\'s Edge Mountains' },
  [129] = { t = 'Drop', n = 'Duke Vallenhal', l = 'Dragonblight' },
  [130] = { t = 'Drop', n = 'Bladespire Crusher', l = 'Blade\'s Edge Mountains' },
  [131] = { t = 'Drop', n = 'Dullgrom Dredger', l = 'Blade\'s Edge Mountains' },
  [132] = { t = 'Drop', n = 'Bladespire Mystic', l = 'Blade\'s Edge Mountains' },
  [133] = { t = 'Drop', n = 'Lunchbox', l = 'Borean Tundra' },
  [134] = { t = 'Drop', n = 'Bladespire Ravager', l = 'Blade\'s Edge Mountains' },
  [135] = { t = 'Drop', n = 'Duskhowl Prowler', l = 'Grizzly Hills' },
  [136] = { t = 'Drop', n = 'Bleeding Hollow Berserker', l = 'Tanaan Jungle' },
  [137] = { t = 'Drop', n = 'Master Caller', l = 'Isle of Thunder' },
  [138] = { t = 'Drop', n = 'Bleeding Hollow Grunt', l = 'Hellfire Peninsula' },
  [139] = { t = 'Drop', n = 'Kz\'Kzik', l = 'Dread Wastes' },
  [140] = { t = 'Drop', n = 'Bleeding Hollow Necrolyte', l = 'Hellfire Peninsula' },
  [141] = { t = 'Drop', n = 'Earthen Sculptor', l = 'Uldaman' },
  [142] = { t = 'Drop', n = 'Bleeding Hollow Ritualist', l = 'Tanaan Jungle' },
  [143] = { t = 'Drop', n = 'Anub\'ar Cultist', l = 'Dragonblight' },
  [144] = { t = 'Drop', n = 'Bleeding Hollow Savage', l = 'Tanaan Jungle' },
  [145] = { t = 'Drop', n = 'Anub\'ar Slayer', l = 'Dragonblight' },
  [146] = { t = 'Drop', n = 'Bleeding Hollow Worg', l = 'Hellfire Peninsula' },
  [147] = { t = 'Drop', n = 'Apexis Flayer', l = 'Blade\'s Edge Mountains' },
  [148] = { t = 'Drop', n = 'Merciless One', l = 'Abyssal Depths' },
  [149] = { t = 'Drop', n = 'Apprehensive Worker', l = 'Tol Barad Peninsula' },
  [150] = { t = 'Drop', n = 'Blighted Corpse', l = 'Sholazar Basin' },
  [151] = { t = 'Drop', n = 'Arazzius the Cruel', l = 'Hellfire Peninsula' },
  [152] = { t = 'Drop', n = 'Blightguard', l = 'Zul\'Drak' },
  [153] = { t = 'Drop', n = 'Kyparite Pulverizer', l = 'Dread Wastes' },
  [154] = { t = 'Drop', n = 'Bloated Abomination', l = 'Zul\'Drak' },
  [155] = { t = 'Drop', n = 'Arcanital Ra\'kul', l = 'Isle of Thunder' },
  [156] = { t = 'Drop', n = 'Blood Shade', l = 'Howling Fjord' },
  [157] = { t = 'Drop', n = 'Arch Mage Xintor', l = 'Hellfire Peninsula' },
  [158] = { t = 'Drop', n = 'Bloodeye Brute', l = 'Twilight Highlands' },
  [159] = { t = 'Drop', n = 'Anger Guard', l = 'Blade\'s Edge Mountains' },
  [160] = { t = 'Drop', n = 'Bloodfeast', l = 'Dragonblight' },
  [161] = { t = 'Drop', n = 'Emissary of Flame', l = 'Mount Hyjal' },
  [162] = { t = 'Drop', n = 'Bloodhound', l = 'Blackrock Depths' },
  [163] = { t = 'Drop', n = 'En\'kilah Abomination', l = 'Borean Tundra' },
  [164] = { t = 'Drop', n = 'Bloodmaul Battle Worg', l = 'Blade\'s Edge Mountains' },
  [165] = { t = 'Drop', n = 'En\'kilah Ghoul', l = 'Borean Tundra' },
  [166] = { t = 'Drop', n = 'Bloodmaul Dire Wolf', l = 'Blade\'s Edge Mountains' },
  [167] = { t = 'Drop', n = 'En\'kilah Necrolord', l = 'Borean Tundra' },
  [168] = { t = 'Drop', n = 'Bloodmaul Geomancer', l = 'Blade\'s Edge Mountains' },
  [169] = { t = 'Drop', n = 'Ango\'rosh Shaman', l = 'Zangarmarsh' },
  [170] = { t = 'Drop', n = 'Bloodmaul Shaman', l = 'Blade\'s Edge Mountains' },
  [171] = { t = 'Drop', n = 'Animated Warrior', l = 'Isle of Thunder' },
  [172] = { t = 'Drop', n = 'Bloodmaul Soothsayer', l = 'Blade\'s Edge Mountains' },
  [173] = { t = 'Drop', n = 'Anok\'ra the Manipulator', l = 'Dragonblight' },
  [174] = { t = 'Drop', n = 'Bloodmoon Cultist', l = 'Grizzly Hills' },
  [175] = { t = 'Drop', n = 'Anub\'ar Ambusher', l = 'Dragonblight' },
  [176] = { t = 'Drop', n = 'Bloodpaw Shaman', l = 'Dragonblight' },
  [177] = { t = 'Drop', n = 'Enslaved Bandit', l = 'Lost City of the Tol\'vir' },
  [178] = { t = 'Drop', n = 'Bloodscale Overseer', l = 'Zangarmarsh' },
  [179] = { t = 'Drop', n = 'Kypari Crawler', l = 'Dread Wastes' },
  [180] = { t = 'Drop', n = 'Bloodscale Wavecaller', l = 'Zangarmarsh' },
  [181] = { t = 'Drop', n = 'Kvaldir Seahorror', l = 'Shimmering Expanse' },
  [182] = { t = 'Drop', n = 'Bloodspore Harvester', l = 'Borean Tundra' },
  [183] = { t = 'Drop', n = 'Enslaved Inferno', l = 'Twilight Highlands' },
  [184] = { t = 'Drop', n = 'Bloodspore Roaster', l = 'Borean Tundra' },
  [185] = { t = 'Drop', n = 'Enslaved Tempest', l = 'Twilight Highlands' },
  [186] = { t = 'Drop', n = 'Bloodthirsty Worg', l = 'Howling Fjord' },
  [187] = { t = 'Drop', n = 'Enthralled Atal\'ai', l = 'Sunken Temple' },
  [188] = { t = 'Drop', n = 'Lost Shandaral Spirit', l = 'Crystalsong Forest' },
  [189] = { t = 'Drop', n = 'Enthralled Cultist', l = 'Blasted Lands' },
  [190] = { t = 'Drop', n = 'Bloodwash Idolater', l = 'Blasted Lands' },
  [191] = { t = 'Drop', n = 'Envoy Icarius', l = 'Shadowmoon Valley' },
  [192] = { t = 'Drop', n = 'Blue Drakonid Supplicant', l = 'Borean Tundra' },
  [193] = { t = 'Drop', n = 'Kvaldir Reaver', l = 'Hrothgar\'s Landing' },
  [194] = { t = 'Drop', n = 'Lord Klaq', l = 'Zangarmarsh' },
  [195] = { t = 'Drop', n = 'Et\'kil', l = 'Townlong Steppes' },
  [196] = { t = 'Drop', n = 'Boldrich Stonerender', l = 'Deepholm' },
  [197] = { t = 'Drop', n = 'Eternal Protector', l = 'Uldum' },
  [198] = { t = 'Drop', n = 'Bonechewer Backbreaker', l = 'Terokkar Forest' },
  [199] = { t = 'Drop', n = 'Ethereal Arcanist', l = 'Terokkar Forest' },
  [200] = { t = 'Drop', n = 'Bonechewer Evoker', l = 'Hellfire Peninsula' },
  [201] = { t = 'Drop', n = 'Ethereal Plunderer', l = 'Terokkar Forest' },  
  [202] = { t = 'Quest', n = 'Breaking Off A Piece' },
  [203] = { t = 'Quest', n = 'Chasing Icestorm: Thel\'zan\'s Phylactery' },
  [204] = { t = 'Quest', n = 'Frostmourne Cavern' },
  [205] = { t = 'Quest', n = 'Imprints on the Past' },
  [206] = { t = 'Quest', n = 'Leave Nothing to Chance' },
  [207] = { t = 'Quest', n = 'My Old Enemy' },
  [208] = { t = 'Quest', n = 'Parting Thoughts' },
  [209] = { t = 'Quest', n = 'Prevent the Accord' },
  [210] = { t = 'Quest', n = 'Return to the High Commander' },
  [211] = { t = 'Quest', n = 'Steamtank Surprise' },
  [212] = { t = 'Quest', n = 'Strengthen the Ancients' },
  [213] = { t = 'Quest', n = 'The End of the Line' },
  [214] = { t = 'Quest', n = 'The Fate of the Dead' },
  [215] = { t = 'Quest', n = 'The High Cultist' },
  [216] = { t = 'Quest', n = 'The Noble\'s Crypt' },
  [217] = { t = 'Quest', n = 'Through Fields of Flame' },
  [218] = { t = 'Quest', n = 'To Fordragon Hold!' },
  [219] = { t = 'Quest', n = 'Wanted: High Shaman Bloodpaw' },
  [220] = { t = 'Quest', n = 'Wanted: Kreug Oathbreaker' },
  [221] = { t = 'Quest', n = 'Wanted: Onslaught Commander Iustus' },
  [222] = { t = 'Quest', n = 'The Fall of Magtheridon' },
  [223] = { t = 'Quest', n = 'Alpha Worg' },
  [224] = { t = 'Quest', n = 'Bring Down Those Shields' },
  [225] = { t = 'Quest', n = 'Down to the Wire' },
  [226] = { t = 'Quest', n = 'Get Me Outa Here!' },
  [227] = { t = 'Quest', n = 'Hah... You\'re Not So Big Now!' },
  [228] = { t = 'Quest', n = 'I\'ve Got a Flying Machine!' },
  [229] = { t = 'Quest', n = 'It Was The Orcs, Honest!' },
  [230] = { t = 'Quest', n = 'Preying Upon the Weak' },
  [231] = { t = 'Quest', n = 'Scare the Guano Out of Them!' },
  [232] = { t = 'Quest', n = 'All Hail the Conqueror of Skorn!' },
  [233] = { t = 'Quest', n = 'Anguish of Nifflevar' },
  [234] = { t = 'Quest', n = 'Back to the Airstrip' },
  [235] = { t = 'Quest', n = 'Buying Some Time' },
  [236] = { t = 'Quest', n = 'Call to Arms!' },
  [237] = { t = 'Quest', n = 'Deploy the Shake-n-Quake!' },
  [238] = { t = 'Quest', n = 'Dragonflayer Battle Plans' },
  [239] = { t = 'Quest', n = 'Enemies of the Light' },
  [240] = { t = 'Quest', n = 'Give Fizzcrank the News' },
  [241] = { t = 'Quest', n = 'In Service to the Light' },
  [242] = { t = 'Quest', n = 'It Goes to 11...' },
  [243] = { t = 'Quest', n = 'It\'s Time for Action' },
  [244] = { t = 'Quest', n = 'Last Rites' },
  [245] = { t = 'Quest', n = 'Leader of the Deranged' },
  [246] = { t = 'Quest', n = 'Lightning Infused Relics' },
  [247] = { t = 'Quest', n = 'Master and Servant' },
  [248] = { t = 'Quest', n = 'Might As Well Wipe Out the Scourge' },
  [249] = { t = 'Quest', n = 'Mission: Eternal Flame' },
  [250] = { t = 'Quest', n = 'Mission: Plague This!' },
  [251] = { t = 'Quest', n = 'Necro Overlord Mezhen' },
  [252] = { t = 'Quest', n = 'News From the East' },
  [253] = { t = 'Quest', n = 'Plug the Sinkholes' },
  [254] = { t = 'Quest', n = 'Re-Cursive' },
  [255] = { t = 'Quest', n = 'Repurposed Technology' },
  [256] = { t = 'Quest', n = 'Rescuing the Rescuers' },
  [257] = { t = 'Quest', n = 'Return to Valgarde' },
  [258] = { t = 'Quest', n = 'Stop the Ascension!' },
  [259] = { t = 'Quest', n = 'Surrounded!' },
  [260] = { t = 'Quest', n = 'Take No Chances' },
  [261] = { t = 'Quest', n = 'The Delicate Sound of Thunder' },
  [262] = { t = 'Quest', n = 'The Frost Wyrm and its Master' },
  [263] = { t = 'Quest', n = 'The Gearmaster' },
  [264] = { t = 'Quest', n = 'The Hunt is On' },
  [265] = { t = 'Quest', n = 'The Late William Allerton' },
  [266] = { t = 'Quest', n = 'The Shining Light' },
  [267] = { t = 'Quest', n = 'The Siege' },
  [268] = { t = 'Quest', n = 'The Yeti Next Door' },
  [269] = { t = 'Quest', n = 'There Exists No Honor Among Birds' },
  [270] = { t = 'Quest', n = 'There\'s Something Going On In Those Caves' },
  [271] = { t = 'Quest', n = 'Two Wrongs...' },
  [272] = { t = 'Quest', n = 'Blast the Infernals!' },
  [273] = { t = 'Quest', n = 'News of Victory' },
  [274] = { t = 'Quest', n = 'Teron Gorefiend, I am...' },
  [275] = { t = 'Quest', n = 'Wanted: Durn the Hungerer' },
  [276] = { t = 'Quest', n = 'Cho\'war the Pillager' },
  [277] = { t = 'Quest', n = 'Crush the Bloodmaul Camp!' },
  [278] = { t = 'Quest', n = 'Cutting Your Teeth' },
  [279] = { t = 'Quest', n = 'Gauging the Resonant Frequency' },
  [280] = { t = 'Quest', n = 'Gorgrom the Dragon-Eater' },
  [281] = { t = 'Quest', n = 'Into the Draenethyst Mine' },
  [282] = { t = 'Quest', n = 'Planting the Banner' },
  [283] = { t = 'Quest', n = 'Protecting Our Own' },
  [284] = { t = 'Quest', n = 'Ride the Lightning' },
  [285] = { t = 'Quest', n = 'Ridgespine Menace' },
  [286] = { t = 'Quest', n = 'Show Them Gnome Mercy!' },
  [287] = { t = 'Quest', n = 'Showdown' },
  [288] = { t = 'Quest', n = 'The Bladespire Ogres' },
  [289] = { t = 'Quest', n = 'The Den Mother' },
  [290] = { t = 'Quest', n = 'The Ravaged Caravan' },
  [291] = { t = 'Quest', n = 'What Came First, the Drake or the Egg?' },
  [292] = { t = 'Quest', n = 'Corki\'s Gone Missing Again!' },
  [293] = { t = 'Quest', n = 'Message to Telaar' },
  [294] = { t = 'Quest', n = 'Ortor My Old Friend...' },
  [295] = { t = 'Quest', n = 'Solving the Problem' },
  [296] = { t = 'Quest', n = 'Stopping the Spread' },
  [297] = { t = 'Quest', n = 'The Twin Clefts of Nagrand' },
  [298] = { t = 'Quest', n = 'Torgos!' },
  [299] = { t = 'Quest', n = 'Escape from Firewing Point!' },
  [300] = { t = 'Quest', n = 'Kill the Shadow Council!' },
  [301] = { t = 'Quest', n = 'Letting Earthbinder Tavgren Know' },  
}

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

local TEMP_GEAR = {
	["CHESTSLOT"] = 3951,
	["LEGSSLOT"] = 3952,
	["FEETSLOT"] = 3954,
	["HANDSSLOT"] = 3953,
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
		-- outfit dropdown
		local outfitDropdown = WardrobeOutfitDropDown;
		outfitDropdown:SetParent(collectionFrame.PreviewFrame);
		outfitDropdown:ClearAllPoints();
		outfitDropdown:SetPoint("TOPLEFT", -10, 30);
		WardrobeOutfitDropDown_Resize();
	elseif ( parent == WardrobeFrame ) then
		collectionFrame:SetPoint("TOPRIGHT", 0, 0);
		collectionFrame:SetSize(662, 606);
		collectionFrame.ModelsFrame.ModelR1C1:SetPoint("TOP", -238, -70);
		collectionFrame.ModelsFrame.SlotsFrame:Hide();
		collectionFrame.ModelsFrame.BGCornerTopLeft:Show();
		collectionFrame.ModelsFrame.BGCornerTopRight:Show();
		collectionFrame.ModelsFrame.WeaponDropDown:SetPoint("TOPRIGHT", -32, -25);
		collectionFrame.progressBar:SetWidth(437);
		-- outfit dropdown
		local outfitDropdown = WardrobeOutfitDropDown;
		outfitDropdown:SetParent(parent);
		outfitDropdown:ClearAllPoints();
		outfitDropdown:SetPoint("TOPLEFT", -10, -58);
		WardrobeOutfitDropDown_Resize();
	end
end

function WardrobeCollectionFrame_OnLoad(self)
	WardrobeCollectionFrame_CreateSlotButtons();
	self.PreviewFrame.BottomDesatBG:SetDesaturated(true);
	self.PreviewFrame.TopDesatBG:SetDesaturated(true);
	self.ModelsFrame.BGCornerTopLeft:Hide();
	self.ModelsFrame.BGCornerTopRight:Hide();
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_misc_enggizmos_19");
	
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("APPEARANCE_SEARCH_UPDATED");
	self:RegisterEvent("SEARCH_DB_LOADED");

	self.categoriesList = C_TransmogCollection.GetCategories();
	-- create an enchants category at the end
	FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT = NUM_LE_TRANSMOG_COLLECTION_TYPES + 1;
	local illusions = C_TransmogCollection.GetIllusions();
	self.categoriesList[FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT] = { count = #illusions, isEnchant = true };

	WardrobeCollectionFrame_UpdateCategoriesHandInfo();
	WardrobeCollectionFrame_SetActiveSlot("HEADSLOT", LE_TRANSMOG_TYPE_APPEARANCE);
	
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
		local categoryID = ...;
		if ( categoryID == self.activeCategory ) then
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
	end
end

function WardrobeCollectionFrame_OnShow(self)
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	if ( WardrobeCollectionFrame.activeCategory ) then
		-- redo the model for the active category
		WardrobeCollectionFrame_ChangeModelsSlot(nil, WardrobeCollectionFrame.activeCategory);
	else 
		WardrobeCollectionFrame_SetActiveCategory(LE_TRANSMOG_COLLECTION_TYPE_HEAD);
	end

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_chest_cloth_17");
	WardrobeCollectionFrame_UpdateWeaponDropDown();
	if ( WardrobeFrame_IsAtTransmogrifier() ) then
		WardrobeCollectionFrame.PreviewFrame:Hide();
	else
		WardrobeCollectionFrame.PreviewFrame:Show();
		WardrobeCollectionFramePreview_Reset();
	end
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_SUCCESS");
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_CAMERA_UPDATE");
	self:UnregisterEvent("TRANSMOG_COLLECTION_UPDATED");
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
	elseif ( key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY ) then
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
			undressSlot = true;
		else
			reloadModel = true;
		end
	end
	local cameraSettings = COLLECTION_CAMERA[newCategory] or COLLECTION_CAMERA["BASE"];
	local cameraID = WardrobeCollectionFrame.categoriesList[newCategory].cameraID or cameraSettings.cameraID;
	for i = 1, #WardrobeCollectionFrame.ModelsFrame.Models do
		local model = WardrobeCollectionFrame.ModelsFrame.Models[i];
		if ( undressSlot ) then
			local slotID = GetInventorySlotInfo(ARMOR_SLOTS[oldCategory]);
			model:UndressSlot(slotID);
			-- if going to shirt, always remove chest temp gear
			if ( newCategory == LE_TRANSMOG_COLLECTION_TYPE_SHIRT ) then
				model:UndressSlot(GetInventorySlotInfo("CHESTSLOT"));
			else
				-- replace temp gear
				local gearAppearanceID = TEMP_GEAR[ARMOR_SLOTS[oldCategory]];
				if ( gearAppearanceID ) then
					model:TryOn(gearAppearanceID);
				elseif ( oldCategory == LE_TRANSMOG_COLLECTION_TYPE_SHIRT and newCategory ~= LE_TRANSMOG_COLLECTION_TYPE_CHEST ) then
					-- leaving shirt, put chest back
					model:TryOn(TEMP_GEAR["CHESTSLOT"]);
				end
			end
		elseif ( reloadModel ) then
			model:SetUnit("player");
			model:SetAnimation(MODEL_ANIM_STOP);
			model:Undress();
			-- put all the temp gear back
			for slot, gearAppearanceID in pairs(TEMP_GEAR) do
				model:TryOn(gearAppearanceID);
			end
		end
		model.visualInfo = nil;
		Model_ApplyUICamera(model, cameraID);
	end
	WardrobeCollectionFrame.illusionWeaponAppearanceID = nil;
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

function WardrobeCollectionFrame_UpdateEnchantButtons()
	local resetSlot;
	local buttons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.EnchantButtons;
	for i = 1, #buttons do
		local slot = buttons[i].slot;
		local sourceID = WardrobeCollectionFramePreview_GetInfoForSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
		if ( sourceID ) then
			local _, _, canEnchant = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
			showButton = canEnchant;
		end
		if ( showButton ) then
			buttons[i]:Show();
		else
			buttons[i]:Hide();
			-- if selected and hidden, reset to weapon
			if ( slot == WardrobeCollectionFrame.activeSlot and WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
				resetSlot = slot;
			end
		end
	end
	if ( resetSlot ) then
		WardrobeCollectionFrame_SetActiveSlot(resetSlot, LE_TRANSMOG_TYPE_APPEARANCE);
	end
end

function WardrobeCollectionFrame_ResetPage()
	local page = 1;
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = WardrobeCollectionFrame_GetActiveSlotInfo();
	if ( selectedSourceID ~= NO_SOURCE_ID ) then
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
		return source1.visualID > source2.visualID;
	end

	table.sort(WardrobeCollectionFrame.filteredVisualsList, comparison);
end

function WardrobeCollectionFrame_GetActiveSlotInfo()
	return WardrobeCollectionFrame_GetInfoForSlot(WardrobeCollectionFrame.activeSlot, WardrobeCollectionFrame.transmogType);
end

function WardrobeCollectionFrame_GetInfoForSlot(slot, transmogType)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(slot), transmogType);
	local previewSourceID, previewVisualID = WardrobeCollectionFramePreview_GetInfoForSlot(slot, transmogType);
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
	elseif ( previewSourceID ) then
		selectedSourceID = previewSourceID;
		selectedVisualID = previewVisualID;
	else
		selectedSourceID = appliedSourceID;
		selectedVisualID = appliedVisualID;
	end
	return appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID;
end

function WardrobeCollectionFrame_Update()
	local isArmor = WardrobeCollectionFrame.categoriesList[WardrobeCollectionFrame.activeCategory].isArmor;
	local _, appearanceSourceID, appearanceVisualID, cameraID;
	local changeModel = false;
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		-- for enchants we need to get the visual of the item in that slot
		_, _, appearanceSourceID, appearanceVisualID = WardrobeCollectionFrame_GetInfoForSlot(WardrobeCollectionFrame.activeSlot, LE_TRANSMOG_TYPE_APPEARANCE);
		_, _, _, cameraID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		if ( appearanceSourceID ~= WardrobeCollectionFrame.illusionWeaponAppearanceID ) then
			WardrobeCollectionFrame.illusionWeaponAppearanceID = appearanceSourceID;
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
					model:TryOn(visualInfo.sourceID);
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
			model.AppliedTexture:SetShown(visualInfo.visualID == appliedVisualID);
			model.SelectedTexture:SetShown(visualInfo.visualID == selectedVisualID);
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

function WardrobeCollectionFrame_SelectVisual(visualID)
	local sourceID;
	local visualsList = WardrobeCollectionFrame.filteredVisualsList;
	for i = 1, #visualsList do
		if ( visualsList[i].visualID == visualID ) then
			sourceID = visualsList[i].sourceID;
			break;
		end
	end
	if ( WardrobeCollectionFrame.PreviewFrame:IsShown() ) then
		WardrobeCollectionFramePreview_SetSource(sourceID, WardrobeCollectionFrame.transmogType, WardrobeCollectionFrame.activeSlot);
	else
		local chosenSourceID;
		if ( WardrobeCollectionFrame.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			chosenSourceID = WardrobeCollectionFrameModel_GetChosenVisualSource(visualID);
			-- if the user hasn't chosen a source for this visual, go with the 1st one
			if ( not chosenSourceID ) then
				local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(visualID);
				chosenSourceID = sources[1].sourceID;
			end
		else
			chosenSourceID = sourceID;
		end
		local slotID = GetInventorySlotInfo(WardrobeCollectionFrame.activeSlot);
		C_Transmog.SetPending(slotID, WardrobeCollectionFrame.transmogType, chosenSourceID);
	end
end

-- ***** MODELS

function WardrobeCollectionFrameModel_OnLoad(self)
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	
	local lightValues = { enabled=1, omni=0, dirX=-1, dirY=0, dirZ=0, ambIntensity=0.8, ambR=1, ambG=1, ambB=1, dirIntensity=0, dirR=1, dirG=1, dirB=1 };
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
		Model_ApplyUICamera(self, self.cameraID);
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
	if ( WardrobeCollectionFrame.activeCategory == FAKE_LE_TRANSMOG_COLLECTION_TYPE_ENCHANT ) then
		local visualID, name = C_TransmogCollection.GetIllusionSourceInfo(self.visualInfo.sourceID);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name);
	else
		WardrobeCollectionFrame.tooltipAppearanceID = self.visualInfo.visualID;
		WardrobeCollectionFrame.tooltipIndexOffset = 0;
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WardrobeCollectionFrameModel_SetTooltip();
	end
end

function WardrobeCollectionFrameModel_OnLeave(self)
	WardrobeCollectionFrame.tooltipAppearanceID = nil;
	WardrobeCollectionFrame.tooltipCycle = nil;
	WardrobeCollectionFrame.tooltipIndexOffset = 0;
	GameTooltip:Hide();
end

function WardrobeCollectionFrameModel_SetTooltip()
	local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(WardrobeCollectionFrame.tooltipAppearanceID);
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
	GameTooltip:AddLine(sourceText, sourceColor.r, sourceColor.g, sourceColor.b, 1, 1);

	if ( #sources > 1 ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(WARDROBE_OTHER_ITEMS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		for i = 1, #sources do
			local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[i]);
			if ( i == headerIndex ) then
				name = WARDROBE_TOOLTIP_CYCLE_ARROW_ICON..name;
			else
				name = WARDROBE_TOOLTIP_CYCLE_SPACER_ICON..name;
			end
			GameTooltip:AddDoubleLine(name, sourceText, nameColor.r, nameColor.g, nameColor.b, sourceColor.r, sourceColor.g, sourceColor.b);
		end	
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(WARDROBE_TOOLTIP_CYCLE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		WardrobeCollectionFrame.tooltipCycle = true;
	else
		WardrobeCollectionFrame.tooltipCycle = nil;
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
		sourceText = WARDROBE_COLLECTED;
		sourceColor = GREEN_FONT_COLOR;
	else
		local sourceData = TEMP_SOURCES[mod(source.sourceID - 1, #TEMP_SOURCES) + 1];
		sourceText = sourceData.t;
		if ( i == 1 ) then
			sourceText = sourceData.t..": "..sourceData.n;
			if ( sourceData.l ) then
				sourceText = sourceText.." in "..sourceData.l;
			end
		end
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

-- ***** PREVIEW

local PREVIEW_MIN_WIDTH, PREVIEW_MIN_HEIGHT;
local PREVIEW_MAX_WIDTH = 308;
local PREVIEW_MAX_HEIGHT = 458;
local PREVIEW_BOTTOMBG_RATIO;

function WardrobeCollectionFramePreview_OnLoad(self)
	PREVIEW_MIN_WIDTH, PREVIEW_MIN_HEIGHT = self:GetSize();
	PREVIEW_BOTTOMBG_RATIO = PREVIEW_MIN_HEIGHT / self.BottomBG:GetHeight();
	Model_OnLoad(self, MODELFRAME_MAX_PLAYER_ZOOM);
	self:SetUnit("player");
	self:SetResizable(true);
	self:SetMinResize(PREVIEW_MIN_WIDTH, PREVIEW_MIN_HEIGHT);
	self:SetMaxResize(PREVIEW_MAX_WIDTH, PREVIEW_MAX_HEIGHT);
end

function WardrobeCollectionFramePreview_StartResizing(self)
	self:StartSizing("BOTTOM");
	self.resizing = true;
end

function WardrobeCollectionFramePreview_StopResizing(self)
	self:StopMovingOrSizing();
	self.resizing = nil;
	if ( not self.ResizeButton:IsMouseOver() ) then
		ResetCursor();
	end
end

function WardrobeCollectionFramePreview_OnUpdate(self)
	Model_OnUpdate(self);
	if ( self.resizing ) then
		local width, height = self:GetSize();
		local newWidth = ceil(height * PREVIEW_MIN_WIDTH / PREVIEW_MIN_HEIGHT);
		self:SetWidth(newWidth);
		self.BottomBG:SetHeight(height / PREVIEW_BOTTOMBG_RATIO);
	end
end

function WardrobeCollectionFramePreview_SetSource(sourceID, transmogType, slot, skipUpdates)
	-- for hand slots retain the visual type we're not setting
	local appearanceSourceID, illusionSourceID, _;
	if ( slot == "MAINHANDSLOT" or slot == "SECONDARYHANDSLOT" ) then
		if ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			appearanceSourceID = sourceID;
			_, illusionSourceID = WardrobeCollectionFrame.PreviewFrame:GetSlotTransmogSources(GetInventorySlotInfo(slot));
			-- don't specify a slot for ranged weapons (bows will go to offhand)
			local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
			if ( WardrobeCollectionFrame_IsCategoryRanged(categoryID) ) then
				slot = nil;
			end
		else
			appearanceSourceID = WardrobeCollectionFrame.PreviewFrame:GetSlotTransmogSources(GetInventorySlotInfo(slot));
			illusionSourceID = sourceID;
		end
	else
		appearanceSourceID = sourceID;
	end
	WardrobeCollectionFrame.PreviewFrame:TryOn(appearanceSourceID, slot, illusionSourceID);
	if ( not skipUpdates ) then
		WardrobeCollectionFrame_UpdateEnchantButtons();
		WardrobeOutfitDropDown_UpdateSaveButton();
		WardrobeCollectionFrame_Update();
	end
end

function WardrobeCollectionFramePreview_SetSources(appearanceSources, mainHandIllusionSourceID, offHandIllusionSourceID)
	if ( not appearanceSources ) then
		return;
	end

	local slotButtons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		if ( button.transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local slotID = GetInventorySlotInfo(button.slot);
			if ( appearanceSources[slotID] ~= 0 ) then
				WardrobeCollectionFramePreview_SetSource(appearanceSources[slotID], LE_TRANSMOG_TYPE_APPEARANCE, button.slot, true);
			end
		end
	end
	if ( mainHandIllusionSourceID ~= 0 ) then
		WardrobeCollectionFramePreview_SetSource(mainHandIllusionSourceID, LE_TRANSMOG_TYPE_ILLUSION, "MAINHANDSLOT", true);
	end
	if ( offHandIllusionSourceID ~= 0 ) then
		WardrobeCollectionFramePreview_SetSource(offHandIllusionSourceID, LE_TRANSMOG_TYPE_ILLUSION, "SECONDARYHANDSLOT", true);
	end
	WardrobeCollectionFrame_UpdateEnchantButtons();
	WardrobeOutfitDropDown_UpdateSaveButton();
	WardrobeCollectionFrame_Update();
end

function WardrobeCollectionFramePreview_Reset()
	WardrobeCollectionFrame.PreviewFrame:Dress();
	WardrobeCollectionFrame_UpdateEnchantButtons();
	WardrobeOutfitDropDown_UpdateSaveButton();
end

function WardrobeCollectionFramePreview_TryOn(link)
	WardrobeCollectionFrame.PreviewFrame:TryOn(link);
	WardrobeCollectionFrame_Update();
	WardrobeCollectionFrame_UpdateEnchantButtons();
	WardrobeOutfitDropDown_UpdateSaveButton();
end

function WardrobeCollectionFramePreview_GetInfoForSlot(slot, transmogType)
	if ( WardrobeCollectionFrame.PreviewFrame:IsShown() ) then
		-- RANGED_INV_TYPE are displayed in the secondary hand and the model frame uses visual slots, not physical
		-- Have to reverse slots in that case
		local appearanceSourceID, illusionSourceID = WardrobeCollectionFrame.PreviewFrame:GetSlotTransmogSources(GetInventorySlotInfo(slot));
		if ( appearanceSourceID ~= NO_SOURCE_ID )  then
			local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
			if ( categoryID and WardrobeCollectionFrame.categoriesList[categoryID].invType == RANGED_INV_TYPE ) then
				if ( slot == "MAINHANDSLOT" ) then
					slot = "SECONDARYHANDSLOT";
				else
					slot = "MAINHANDSLOT";
				end
			end
		end
		if ( transmogType == LE_TRANSMOG_TYPE_APPEARANCE ) then
			local _, appearanceVisualID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
			return appearanceSourceID, appearanceVisualID;
		else
			local illusionVisualID = C_TransmogCollection.GetIllusionSourceInfo(illusionSourceID);
			return illusionSourceID, illusionVisualID or 0;
		end
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

-- ***** OUTFITS

function WardrobeOutfitDropDown_OnLoad(self)
	local button = _G[self:GetName().."Button"];
	button:SetScript("OnClick", WardrobeOutfitDropDown_OnClick);
	UIDropDownMenu_JustifyText(self, "LEFT");
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
	if ( loadOutfit and outfitID ) then
		local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(outfitID);
		if ( WardrobeFrame_IsAtTransmogrifier() ) then
			C_Transmog.LoadOutfit(outfitID);
		else
			WardrobeCollectionFramePreview_SetSources(C_TransmogCollection.GetOutfitSources(outfitID));
		end
	end
	WardrobeOutfitDropDown_UpdateSaveButton();
end

function WardrobeOutfitDropDown_Resize()
	if ( WardrobeOutfitDropDown:GetParent() == WardrobeFrame ) then
		UIDropDownMenu_SetWidth(WardrobeOutfitDropDown, 188);	
	else
		UIDropDownMenu_SetWidth(WardrobeOutfitDropDown, WardrobeCollectionFrame.PreviewFrame:GetWidth() - 119);
	end
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