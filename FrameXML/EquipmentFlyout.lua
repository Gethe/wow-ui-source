EQUIPMENTFLYOUT_MAXROWS = 4;

EQUIPMENTFLYOUT_ONESLOT_LEFT_COORDS = { 0, 0.09765625, 0.5546875, 0.77734375 }
EQUIPMENTFLYOUT_ONESLOT_RIGHT_COORDS = { 0.41796875, 0.51171875, 0.5546875, 0.77734375 }

EQUIPMENTFLYOUT_ONESLOT_LEFTWIDTH = 25;
EQUIPMENTFLYOUT_ONESLOT_RIGHTWIDTH = 24;

EQUIPMENTFLYOUT_ONESLOT_WIDTH = 49;
EQUIPMENTFLYOUT_ONESLOT_HEIGHT = 54;

EQUIPMENTFLYOUT_ONEROW_LEFT_COORDS = { 0, 0.16796875, 0.5546875, 0.77734375 }
EQUIPMENTFLYOUT_ONEROW_CENTER_COORDS = { 0.16796875, 0.328125, 0.5546875, 0.77734375 }
EQUIPMENTFLYOUT_ONEROW_RIGHT_COORDS = { 0.328125, 0.51171875, 0.5546875, 0.77734375 }

EQUIPMENTFLYOUT_MULTIROW_TOP_COORDS = { 0, 0.8359375, 0, 0.19140625 }
EQUIPMENTFLYOUT_MULTIROW_MIDDLE_COORDS = { 0, 0.8359375, 0.19140625, 0.35546875 }
EQUIPMENTFLYOUT_MULTIROW_BOTTOM_COORDS = { 0, 0.8359375, 0.35546875, 0.546875 }

EQUIPMENTFLYOUT_ONEROW_HEIGHT = 54;

EQUIPMENTFLYOUT_ONEROW_LEFT_WIDTH = 43;
EQUIPMENTFLYOUT_ONEROW_CENTER_WIDTH = 41;
EQUIPMENTFLYOUT_ONEROW_RIGHT_WIDTH = 47;

EQUIPMENTFLYOUT_MULTIROW_WIDTH = 214;

EQUIPMENTFLYOUT_MULTIROW_TOP_HEIGHT = 49;
EQUIPMENTFLYOUT_MULTIROW_MIDDLE_HEIGHT = 42;
EQUIPMENTFLYOUT_MULTIROW_BOTTOM_HEIGHT = 49;

EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION = 0xFFFFFFFF;
EQUIPMENTFLYOUT_IGNORESLOT_LOCATION = 0xFFFFFFFE;
EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION = 0xFFFFFFFD;
EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION

EQUIPMENTFLYOUT_ITEMS_PER_ROW = 5;
EQUIPMENTFLYOUT_ITEMS_PER_PAGE = EQUIPMENTFLYOUT_MAXROWS * EQUIPMENTFLYOUT_ITEMS_PER_ROW;
EQUIPMENTFLYOUT_BORDERWIDTH = 3;
EQUIPMENTFLYOUT_WIDTH = 43;
EQUIPMENTFLYOUT_HEIGHT = 43;

EFITEM_WIDTH = 37;
EFITEM_HEIGHT = 37;
EFITEM_XOFFSET = 4;
EFITEM_YOFFSET = -5;

VERTICAL_FLYOUTS = { [16] = true, [17] = true, [18] = true }

local itemTable = {}; -- Used for items and locations
local itemDisplayTable = {} -- Used for ordering items by location

function EquipmentFlyout_OnLoad(self)
	self.buttons = {};
end

function EquipmentFlyout_CreateButton()
	local buttons = EquipmentFlyoutFrame.buttons;
	local buttonAnchor = EquipmentFlyoutFrame.buttonFrame;
	local numButtons = #buttons;
	
	local button = CreateFrame("ItemButton", "EquipmentFlyoutFrameButton" .. numButtons + 1, buttonAnchor, "EquipmentFlyoutButtonTemplate");

	local pos = numButtons/EQUIPMENTFLYOUT_ITEMS_PER_ROW;
	if ( math.floor(pos) == pos ) then
		-- This is the first button in a row.
		button:SetPoint("TOPLEFT", buttonAnchor, "TOPLEFT", EQUIPMENTFLYOUT_BORDERWIDTH, -EQUIPMENTFLYOUT_BORDERWIDTH - (EFITEM_HEIGHT - EFITEM_YOFFSET)* pos);
	else
		button:SetPoint("TOPLEFT", buttons[numButtons], "TOPRIGHT", EFITEM_XOFFSET, 0);
	end

	tinsert(buttons, button);
	return button
end

function EquipmentFlyout_OnUpdate(self, elapsed)
	if ( not IsModifiedClick("SHOWITEMFLYOUT") ) then
		local button = self.button;

		if ( button and button.popoutButton and button.popoutButton.flyoutLocked ) then
			EquipmentFlyout_UpdateFlyout(button);
		elseif ( button and button:IsMouseOver() ) then
			local onEnterFunc = button:GetScript("OnEnter");
			if ( onEnterFunc ) then
				onEnterFunc(button);
			end
		else
			self:Hide();
		end
	end
end

function EquipmentFlyout_OnShow(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("VOID_STORAGE_UPDATE");
end

function EquipmentFlyout_OnHide(self)
	if ( self.button and self.button.popoutButton ) then
		local popoutButton = self.button.popoutButton;
		popoutButton.flyoutLocked = false;
		EquipmentFlyoutPopoutButton_SetReversed(popoutButton, false);
	end
	self.button = nil;
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("VOID_STORAGE_UPDATE");
end

function EquipmentFlyout_OnEvent (self, event, ...)
	if ( event == "BAG_UPDATE" ) then
		-- This spams a lot, four times when we equip an item, but we need to use it. EquipmentFlyout_Show needs to stay fast for this reason.
		EquipmentFlyout_Show(self.button);
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		local arg1 = ...;
		if ( arg1 == "player" ) then
			EquipmentFlyout_Show(self.button);
		end
	elseif ( event == "VOID_STORAGE_UPDATE" ) then
		EquipmentFlyout_Show(self.button);
	end
end

local function _createFlyoutBG(buttonAnchor)
	local numBGs = buttonAnchor["numBGs"];
	numBGs = numBGs + 1;
	local texture = buttonAnchor:CreateTexture(nil, nil, "EquipmentFlyoutTexture");
	buttonAnchor["bg" .. numBGs] = texture;
	buttonAnchor["numBGs"] = numBGs;
	return texture;
end

function EquipmentFlyout_Show(itemButton)
	local id = itemButton.id or itemButton:GetID();

	local flyout = EquipmentFlyoutFrame;
	local buttons = flyout.buttons;
	
	if ( flyout.button ~= itemButton ) then
		flyout.currentPage = nil;
	end

	if ( flyout.button and flyout.button ~= itemButton ) then
		local popoutButton = flyout.button.popoutButton;
		if ( popoutButton and popoutButton.flyoutLocked ) then
			popoutButton.flyoutLocked = false;
			EquipmentFlyoutPopoutButton_SetReversed(popoutButton, false);
		end
	end
	flyout.button = itemButton;
	
	wipe(itemDisplayTable);
	wipe(itemTable);

	local flyoutSettings = itemButton:GetParent().flyoutSettings;

	flyoutSettings.getItemsFunc(id, itemTable);
	for location, itemID in next, itemTable do
		if ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list
			itemTable[location] = nil;
		else
			tinsert(itemDisplayTable, location);
		end
	end

	table.sort(itemDisplayTable); -- Sort by location. This ends up as: inventory, backpack, bags, bank, and bank bags.
	
	local numTotalItems = #itemDisplayTable;

	if ( flyoutSettings.postGetItemsFunc ) then
		numTotalItems = flyoutSettings.postGetItemsFunc(itemButton, itemDisplayTable, numTotalItems);
	end

	local numPageItems = min(numTotalItems, EQUIPMENTFLYOUT_ITEMS_PER_PAGE);
	while #buttons < numPageItems do -- Create any buttons we need.
		EquipmentFlyout_CreateButton();
	end
	
	if ( numPageItems == 0 ) then
		flyout:Hide();
		return;
	end

	flyout.totalItems = numTotalItems;
	EquipmentFlyout_UpdateItems();
	flyout:Show();
end

function EquipmentFlyout_ChangePage(delta)
	EquipmentFlyoutFrame.currentPage = EquipmentFlyoutFrame.currentPage + delta;
	EquipmentFlyout_UpdateItems();
end

-- Displays the items on the current page using the items in itemDisplayTable
-- That table is updated in EquipmentFlyout_Show
function EquipmentFlyout_UpdateItems()
	local flyout = EquipmentFlyoutFrame;
	local buttons = flyout.buttons;
	local buttonAnchor = flyout.buttonFrame;
	local itemButton = flyout.button;
	local id = itemButton.id or itemButton:GetID();	
	local flyoutSettings = itemButton:GetParent().flyoutSettings;

	local totalItems = flyout.totalItems;
	local currentPage = flyout.currentPage or 1;
	local maxPage = ceil(totalItems / EQUIPMENTFLYOUT_ITEMS_PER_PAGE);
	-- bounds between 1 and maxPage
	currentPage = max(currentPage, 1);
	currentPage = min(currentPage, maxPage);
	flyout.currentPage = currentPage;

	local itemOffset = (currentPage - 1) * EQUIPMENTFLYOUT_ITEMS_PER_PAGE;
	local numPageItems;
	if ( currentPage == maxPage ) then
		numPageItems = totalItems - itemOffset;
	else
		numPageItems = EQUIPMENTFLYOUT_ITEMS_PER_PAGE;
	end

	-- navigation frame
	local navFrame = flyout.NavigationFrame;
	if ( maxPage == 1 ) then
		navFrame:Hide();
	else
		navFrame:Show();
		if ( currentPage <= 1 ) then
			navFrame.PrevButton:Disable();
		else
			navFrame.PrevButton:Enable();
		end
		if ( currentPage >= maxPage ) then
			navFrame.NextButton:Disable();
		else
			navFrame.NextButton:Enable();
		end
	end

	for i, button in ipairs(buttons) do
		if ( i <= numPageItems ) then
			button.id = id;
			button.location = itemDisplayTable[itemOffset + i];
			button:Show();
			
			EquipmentFlyout_DisplayButton(button, itemButton);
		else
			button:Hide();
		end
	end

	-- past the first page we want full pages because of the navigation bar
	local numItemButtons;
	if ( currentPage == 1 ) then
		numItemButtons = numPageItems;
	else
		numItemButtons = EQUIPMENTFLYOUT_ITEMS_PER_PAGE;
	end
	
	flyout:SetParent(flyoutSettings.parent);
	flyout:SetFrameStrata("HIGH");
	flyout:ClearAllPoints();
	flyout:SetFrameLevel(itemButton:GetFrameLevel() - 1);
	flyout:SetPoint("TOPLEFT", itemButton, "TOPLEFT", -EQUIPMENTFLYOUT_BORDERWIDTH, EQUIPMENTFLYOUT_BORDERWIDTH);
	local horizontalItems = min(numItemButtons, EQUIPMENTFLYOUT_ITEMS_PER_ROW);
	local relativeAnchor = itemButton.popoutButton or itemButton;
	if ( itemButton.verticalFlyout ) then
		buttonAnchor:SetPoint("TOPLEFT", relativeAnchor, "BOTTOMLEFT", flyoutSettings.verticalAnchorX, flyoutSettings.verticalAnchorY);
	else
		buttonAnchor:SetPoint("TOPLEFT", relativeAnchor, "TOPRIGHT", flyoutSettings.anchorX, flyoutSettings.anchorY);
	end
	buttonAnchor:SetWidth((horizontalItems * EFITEM_WIDTH) + ((horizontalItems - 1) * EFITEM_XOFFSET) + EQUIPMENTFLYOUT_BORDERWIDTH);
	buttonAnchor:SetHeight(EQUIPMENTFLYOUT_HEIGHT + (math.floor((numItemButtons - 1)/EQUIPMENTFLYOUT_ITEMS_PER_ROW) * (EFITEM_HEIGHT - EFITEM_YOFFSET)));

	if ( flyout.numItemButtons ~= numItemButtons ) then
		local texturesUsed = 0;
		if ( numItemButtons == 1 ) then
			local bgTex, lastBGTex;
			bgTex = buttonAnchor.bg1;
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_ONESLOT_LEFT_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_ONESLOT_LEFTWIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_ONEROW_HEIGHT);
			bgTex:SetPoint("TOPLEFT", -5, 4);
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
			lastBGTex = bgTex;

			bgTex = buttonAnchor.bg2 or _createFlyoutBG(buttonAnchor);
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_ONESLOT_RIGHT_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_ONESLOT_RIGHTWIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_ONEROW_HEIGHT);
			bgTex:SetPoint("TOPLEFT", lastBGTex, "TOPRIGHT");
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
			lastBGTex = bgTex;
		elseif ( numItemButtons <= EQUIPMENTFLYOUT_ITEMS_PER_ROW ) then
			local bgTex, lastBGTex;
			bgTex = buttonAnchor.bg1;
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_ONEROW_LEFT_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_ONEROW_LEFT_WIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_ONEROW_HEIGHT);
			bgTex:SetPoint("TOPLEFT", -5, 4);
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
			lastBGTex = bgTex;
			for i = texturesUsed + 1, numItemButtons - 1 do
				bgTex = buttonAnchor["bg"..i] or _createFlyoutBG(buttonAnchor);
				bgTex:ClearAllPoints();
				bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_ONEROW_CENTER_COORDS));
				bgTex:SetWidth(EQUIPMENTFLYOUT_ONEROW_CENTER_WIDTH);
				bgTex:SetHeight(EQUIPMENTFLYOUT_ONEROW_HEIGHT);
				bgTex:SetPoint("TOPLEFT", lastBGTex, "TOPRIGHT");
				bgTex:Show();
				texturesUsed = texturesUsed + 1;
				lastBGTex = bgTex;
			end

			bgTex = buttonAnchor["bg"..numItemButtons] or _createFlyoutBG(buttonAnchor);
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_ONEROW_RIGHT_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_ONEROW_RIGHT_WIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_ONEROW_HEIGHT);
			bgTex:SetPoint("TOPLEFT", lastBGTex, "TOPRIGHT");
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
		elseif ( numItemButtons > EQUIPMENTFLYOUT_ITEMS_PER_ROW ) then
			local numRows = math.ceil(numItemButtons/EQUIPMENTFLYOUT_ITEMS_PER_ROW);
			local bgTex, lastBGTex;
			bgTex = buttonAnchor.bg1;
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_MULTIROW_TOP_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_MULTIROW_WIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_MULTIROW_TOP_HEIGHT);
			bgTex:SetPoint("TOPLEFT", -5, 4);
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
			lastBGTex = bgTex;
			for i = 2, numRows - 1 do -- Middle rows
				bgTex = buttonAnchor["bg"..i] or _createFlyoutBG(buttonAnchor);
				bgTex:ClearAllPoints();
				bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_MULTIROW_MIDDLE_COORDS));
				bgTex:SetWidth(EQUIPMENTFLYOUT_MULTIROW_WIDTH);
				bgTex:SetHeight(EQUIPMENTFLYOUT_MULTIROW_MIDDLE_HEIGHT);
				bgTex:SetPoint("TOPLEFT", lastBGTex, "BOTTOMLEFT");
				bgTex:Show();
				texturesUsed = texturesUsed + 1;
				lastBGTex = bgTex;
			end

			bgTex = buttonAnchor["bg"..numRows] or _createFlyoutBG(buttonAnchor);
			bgTex:ClearAllPoints();
			bgTex:SetTexCoord(unpack(EQUIPMENTFLYOUT_MULTIROW_BOTTOM_COORDS));
			bgTex:SetWidth(EQUIPMENTFLYOUT_MULTIROW_WIDTH);
			bgTex:SetHeight(EQUIPMENTFLYOUT_MULTIROW_BOTTOM_HEIGHT);
			bgTex:SetPoint("TOPLEFT", lastBGTex, "BOTTOMLEFT");
			bgTex:Show();
			texturesUsed = texturesUsed + 1;
			lastBGTex = bgTex;
		end

		for i = texturesUsed + 1, buttonAnchor["numBGs"] do
			buttonAnchor["bg" .. i]:Hide();
		end
		flyout.numItemButtons = numItemButtons;
	end
end

function EquipmentFlyout_DisplayButton(button, paperDollItemSlot)
	local location = button.location;
	if ( not location ) then
		button.UpgradeIcon:Hide();
		return;
	end
	if ( location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION ) then
		EquipmentFlyout_DisplaySpecialButton(button, paperDollItemSlot);
		return;
	end

	local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade = EquipmentManager_GetItemInfoByLocation(location);
	button.UpgradeIcon:SetShown(isUpgrade);
	local broken = ( maxDurability and durability == 0 );
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, count);
		if ( broken ) then
			SetItemButtonTextureVertexColor(button, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(button, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);
		end

		SetItemButtonQuality(button, quality, itemID);

		CooldownFrame_Set(button.cooldown, start, duration, enable);
		
		button.UpdateTooltip = function() EquipmentFlyoutButton_UpdateTooltip(button, GameTooltip); end
		button.setTooltip = setTooltip;
		if ( button:IsMouseOver() ) then
			button.UpdateTooltip();
		end
	else
		textureName = paperDollItemSlot.backgroundTextureName;
		if ( paperDollItemSlot.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, 0);
		SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);
		button.cooldown:Hide();
		button.UpdateTooltip = nil;
	end
end

function EquipmentFlyout_DisplaySpecialButton(button, paperDollItemSlot)
	local location = button.location;
	button.UpgradeIcon:Hide();
	button.IconOverlay:Hide();
	
	local quality = nil;
	local itemID = nil;
	SetItemButtonQuality(button, quality, itemID);

	if ( location == EQUIPMENTFLYOUT_IGNORESLOT_LOCATION ) then
		SetItemButtonTexture(button, "Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Opaque");
		SetItemButtonCount(button, nil);
		button.UpdateTooltip = 
			function () 
				GameTooltip:SetOwner(EquipmentFlyoutFrame.buttonFrame, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6);
				GameTooltip:SetText(EQUIPMENT_MANAGER_IGNORE_SLOT, 1.0, 1.0, 1.0); 
				GameTooltip:Show();
			end;
		SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);
	elseif ( location == EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION ) then
		SetItemButtonTexture(button, "Interface\\PaperDollInfoFrame\\UI-GearManager-Undo");
		SetItemButtonCount(button, nil);
		button.UpdateTooltip = 
			function () 
				GameTooltip:SetOwner(EquipmentFlyoutFrame.buttonFrame, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6); 
				GameTooltip:SetText(EQUIPMENT_MANAGER_UNIGNORE_SLOT, 1.0, 1.0, 1.0); 
				GameTooltip:Show();
			end;
		SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);		
	elseif ( location == EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION ) then
		SetItemButtonTexture(button, "Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag");
		SetItemButtonCount(button, nil);
		button.UpdateTooltip = 
			function () 
				GameTooltip:SetOwner(EquipmentFlyoutFrame.buttonFrame, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6);
				GameTooltip:SetText(EQUIPMENT_MANAGER_PLACE_IN_BAGS, 1.0, 1.0, 1.0); 
				GameTooltip:Show();
			end;
		SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);	
	end
	if ( button:IsMouseOver() and button.UpdateTooltip ) then
		button.UpdateTooltip();
	end
end

function EquipmentFlyoutButton_OnEnter(self)
	if ( self.UpdateTooltip ) then
		self.UpdateTooltip(); -- This shows the tooltip, and gets called repeatedly thereafter by GameTooltip.
	end
end

function EquipmentFlyoutButton_OnClick(self)
	local flyoutSettings = EquipmentFlyoutFrame.button:GetParent().flyoutSettings;
	if ( flyoutSettings.onClickFunc ) then
		flyoutSettings.onClickFunc(self);
	end
	if ( EquipmentFlyoutFrame.button.popoutButton and EquipmentFlyoutFrame.button.popoutButton.flyoutLocked and not flyoutSettings.keepShownOnClick ) then
		EquipmentFlyoutFrame:Hide();
	end
end

function EquipmentFlyout_UpdateFlyout(button)
	local id = button.id or button:GetID();
	if ( id ~= INVSLOT_AMMO ) then
		local flyoutSettings = button:GetParent().flyoutSettings;
		local hasLock = button.popoutButton and button.popoutButton.flyoutLocked;
		if ( (IsModifiedClick("SHOWITEMFLYOUT") and not (EquipmentFlyoutFrame:IsVisible() and EquipmentFlyoutFrame.button == button)) or
			hasLock) then
			EquipmentFlyout_Show(button);
		elseif ( (EquipmentFlyoutFrame:IsVisible() and EquipmentFlyoutFrame.button == button) and
			not hasLock and not IsModifiedClick("SHOWITEMFLYOUT") ) then
			EquipmentFlyoutFrame:Hide();
		end
	end
end

function EquipmentFlyout_SetTooltipAnchor(button)
	if ( EquipmentFlyoutFrame:IsShown() ) then
		GameTooltip:SetOwner(EquipmentFlyoutFrame.buttonFrame, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6);
		return true;
	end
end

--
-- Popouts - can only have 1 set, needs more work to be a template
-- 

local popoutButtons = {}

function EquipmentFlyoutPopoutButton_OnLoad(self)
	tinsert(popoutButtons, self);
end

function EquipmentFlyoutPopoutButton_HideAll()
	local flyout = EquipmentFlyoutFrame;
	if ( flyout.button and flyout.button.popoutButton.flyoutLocked ) then
		flyout:Hide();
	end
	for _, button in pairs(popoutButtons) do
		if ( button.flyoutLocked ) then
			button.flyoutLocked = false;
			flyout:Hide();
			EquipmentFlyoutPopoutButton_SetReversed(button, false);
		end
		
		button:Hide();
	end
end

function EquipmentFlyoutPopoutButton_ShowAll()
	for _, button in pairs(popoutButtons) do
		button:Show();
	end
end

function EquipmentFlyoutPopoutButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( self.flyoutLocked ) then
		self.flyoutLocked = false;
		EquipmentFlyoutFrame:Hide();
		EquipmentFlyoutPopoutButton_SetReversed(self, false);
	else
		self.flyoutLocked = true;
		EquipmentFlyout_Show(self:GetParent());
		EquipmentFlyoutPopoutButton_SetReversed(self, true);
	end
end

function EquipmentFlyoutPopoutButton_SetReversed(self, isReversed)
	if ( self:GetParent().verticalFlyout ) then
		if ( isReversed ) then
			self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0, 0.5);
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 0.5, 1);
		else
			self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
		end
	else
		if ( isReversed ) then
			self:GetNormalTexture():SetTexCoord(0.15625, 0, 0.84375, 0, 0.15625, 0.5, 0.84375, 0.5);
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 1, 0.84375, 1);
		else
			self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
			self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
		end
	end
end

function EquipmentFlyoutButton_UpdateTooltipAnchors(self, tooltip)
	local x = self:GetRight();
	local anchorFromLeft = x < GetScreenWidth() / 2;

	if ( anchorFromLeft ) then
		tooltip:SetAnchorType("ANCHOR_RIGHT");
	else
		tooltip:SetAnchorType("ANCHOR_LEFT");
	end
end

function EquipmentFlyoutButton_UpdateTooltip(self, tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	EquipmentFlyoutButton_UpdateTooltipAnchors(self, tooltip);
	self.setTooltip();
	GameTooltip_ShowCompareItem(tooltip);
end