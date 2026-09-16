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

EquipmentFlyoutMixin = {};

function EquipmentFlyoutMixin:SmartNavigationCloseHandler()
	self:Hide();
	return true;
end

function EquipmentFlyoutMixin:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function EquipmentFlyoutMixin:SetupGamepad()
	self.changeToPrevPage = GenerateFlatClosure(EquipmentFlyout_ChangePage, -1);
	self.changeToNextPage = GenerateFlatClosure(EquipmentFlyout_ChangePage, 1);

	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "EquipmentFlyoutFooter");
	self.gamepadFooter:SetCustomAnchor(
		CreateAnchor("TOPLEFT", self.NavigationFrame, "BOTTOMLEFT", 0, 0)
	);
	self.gamepadFooter:AddFunctionBinding(GAMEPAD_SHOULDER_LEFT, self.changeToPrevPage);
	self.gamepadFooter:AddFunctionBinding(GAMEPAD_SHOULDER_RIGHT, self.changeToNextPage);
	self.gamepadFooter:Finalize();
end

function EquipmentFlyoutMixin:InitializeGamepad()
	local navFrame = self.NavigationFrame;
	navFrame.PreviousPageText:Hide();
	navFrame.NextPageText:Hide();
	navFrame.PrevButton:Hide();
	navFrame.NextButton:Hide();

	navFrame.PrevPagePrompt:Show();
	navFrame.NextPagePrompt:Show();
	navFrame.PageTurnIndicatorLeft:Show();
	navFrame.PageTurnIndicatorRight:Show();
end

function EquipmentFlyoutMixin:UninitializeGamepad()
	local navFrame = self.NavigationFrame;
	navFrame.PreviousPageText:Show();
	navFrame.NextPageText:Show();
	navFrame.PrevButton:Show();
	navFrame.NextButton:Show();

	navFrame.PrevPagePrompt:Hide();
	navFrame.NextPagePrompt:Hide();
	navFrame.PageTurnIndicatorLeft:Hide();
	navFrame.PageTurnIndicatorRight:Hide();
end

function EquipmentFlyoutMixin:FocusGamepad()
	local navFrame = self.NavigationFrame;
	navFrame.PageTurnIndicatorLeft:SetScript("OnClick", self.changeToPrevPage);
	navFrame.PageTurnIndicatorRight:SetScript("OnClick", self.changeToNextPage);

	self.gamepadFooter:ShowAndActivateBindings();
end

function EquipmentFlyoutMixin:UnfocusGamepad()
	self.gamepadFooter:HideAndDeactivateBindings();
end

function EquipmentFlyout_OnLoad(self)
	self.buttons = {};
	self:RegisterForInterfaceTransitions();
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
	-- We can skip this for gamepad and avoid rebuilding and re-anchoring the flyout every frame which breaks navigation
	if InputUtil.IsGamepadUIEnabled() then
		return;
	end

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

	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:SuspendFrameWithFooter();
		GamepadMode.FrameControlsManager:DismissOnUnfocus(self);
		GamepadMode.FrameControlsManager:FrameShown(self);
		SmartNavigation:SetWrapping(self, true);
	end
end

function EquipmentFlyout_OnHide(self)
	if ( self.button and self.button.popoutButton ) then
		local popoutButton = self.button.popoutButton;
		popoutButton.flyoutLocked = false;
		EquipmentFlyoutPopoutButton_RefreshVisualState(popoutButton);
	end
	self.button = nil;
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");

	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:FrameHidden(self);
		GamepadMode.FrameControlsManager:UnsuspendFrame();
	end
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
	end
end

local function _createFlyoutBG(buttonAnchor)
	local numBGs = buttonAnchor["numBGs"];
	numBGs = numBGs + 1;
	local texture = buttonAnchor:CreateTexture(nil, nil, "EquipmentFlyoutTexture");

	local itemButton = buttonAnchor:GetParent().button;
	local flyoutSettings = itemButton:GetParent().flyoutSettings;
	local customBackground = flyoutSettings.customBackground;
	if customBackground then
		texture:SetTexture(customBackground);
	end

	buttonAnchor["bg" .. numBGs] = texture;
	buttonAnchor["numBGs"] = numBGs;
	return texture;
end

function EquipmentFlyout_GetFrame()
	return EquipmentFlyoutFrame;
end

function EquipmentFlyout_Hide()
	EquipmentFlyoutFrame:Hide();
end

function EquipmentFlyout_Show(itemButton)
	local id = itemButton.id or itemButton:GetID();

	local flyout = EquipmentFlyoutFrame;
	if flyout:IsShown() and (flyout.button ~= itemButton) then
		flyout:Hide();
	end

	local buttons = flyout.buttons;
	
	if ( flyout.button ~= itemButton ) then
		flyout.currentPage = nil;
	end

	if ( flyout.button and flyout.button ~= itemButton ) then
		local popoutButton = flyout.button.popoutButton;
		if ( popoutButton and popoutButton.flyoutLocked ) then
			popoutButton.flyoutLocked = false;
			EquipmentFlyoutPopoutButton_RefreshVisualState(popoutButton);
		end
	end
	flyout.button = itemButton;
	
	wipe(itemDisplayTable);
	wipe(itemTable);

	local flyoutSettings = itemButton:GetParent().flyoutSettings;
	local useItemLocation = flyoutSettings.useItemLocation;

	flyout:SetScript("OnUpdate", flyoutSettings.customFlyoutOnUpdate or EquipmentFlyout_OnUpdate);

	flyout.Highlight:SetShown(not flyoutSettings.hideFlyoutHighlight);
	if not flyoutSettings.hideFlyoutHighlight then
		flyout.Highlight:SetSize(flyoutSettings.highlightSizeX or 50, flyoutSettings.highlightSizeY or 50);
		flyout.Highlight:SetPoint("LEFT", flyout, "LEFT", flyoutSettings.highlightOfsX or -4, flyoutSettings.highlightOfsY or 0);
	end

	EquipmentFlyout_SetBackgroundTexture(flyoutSettings.customBackground or [[Interface\PaperDollInfoFrame\UI-GearManager-Flyout]]);

	flyoutSettings.getItemsFunc(id, itemTable);
	for location, itemID in next, itemTable do
		if ( not useItemLocation and ((location - id) == ITEM_INVENTORY_LOCATION_PLAYER) ) then -- Remove the currently equipped item from the list
			itemTable[location] = nil;
		else
			tinsert(itemDisplayTable, location);
		end
	end

	if useItemLocation then
		local locationToItemID = {};
		local function ItemLocationSort(lhsLocation, rhsLocation)
			locationToItemID[lhsLocation] = locationToItemID[lhsLocation] or C_Item.GetItemID(lhsLocation);
			locationToItemID[rhsLocation] = locationToItemID[rhsLocation] or C_Item.GetItemID(rhsLocation);
			
			local lhsItemID = locationToItemID[lhsLocation];
			local rhsItemID = locationToItemID[rhsLocation];
			return lhsItemID < rhsItemID;
		end

		table.sort(itemDisplayTable, ItemLocationSort);
	else
		table.sort(itemDisplayTable); -- Sort by location. This ends up as: inventory, backpack, bags, bank, and bank bags.
	end
	
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

	if (InputUtil.IsGamepadUIEnabled()) then
		-- Force a re-selection of the first button in case the button that is currently being focused on is the first button with different data.
		local forceReselect = true;
		SmartNavigation:SelectFirstButton(forceReselect);
	end
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

	local navFrame = flyout.NavigationFrame;
	if ( maxPage == 1 ) then
		navFrame:Hide();
	else
		navFrame:Show();
		local enablePrev = currentPage > 1;
		navFrame.PrevButton:SetEnabled(enablePrev);
		navFrame.PageTurnIndicatorLeft:SetEnabled(enablePrev);
		navFrame.PrevPagePrompt:SetEnabled(enablePrev);

		local enableNext = currentPage < maxPage;
		navFrame.NextButton:SetEnabled(enableNext);
		navFrame.PageTurnIndicatorRight:SetEnabled(enableNext);
		navFrame.NextPagePrompt:SetEnabled(enableNext);
	end

	for i, button in ipairs(buttons) do
		if ( i <= numPageItems ) then
			button.id = id;
			button:Show();
			
			local location = itemDisplayTable[itemOffset + i];
			button.location = location;

			if flyoutSettings.useItemLocation then
				button:SetItemLocation(location);

				local function SetButtonTooltip()
					local self = button;
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

					local itemLocation = self:GetItemLocation();

					if itemLocation:IsBagAndSlot() then
						local bag, slot = itemLocation:GetBagAndSlot();
						GameTooltip:SetBagItem(bag, slot);
					elseif itemLocation:IsEquipmentSlot() then
						local slot = itemLocation:GetEquipmentSlot();
						GameTooltip:SetInventoryItem("player", slot);
					end

					GameTooltip:Show(bag, slot);
				end

				button.setTooltip = SetButtonTooltip;
				button.UpdateTooltip = SetButtonTooltip;
			else
				EquipmentFlyout_DisplayButton(button, itemButton);
			end
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
	
	-- A Flyout without a parent won't scale correctly.
	assertsafe(flyoutSettings.parent, "Flyout must have a parent.");

	flyout:SetParent(flyoutSettings.parent);
	flyout:SetFrameStrata("HIGH");
	flyout:ClearAllPoints();
	flyout:SetFrameLevel(itemButton:GetFrameLevel() - 1);
	flyout:SetPoint("TOPLEFT", itemButton, "TOPLEFT", -EQUIPMENTFLYOUT_BORDERWIDTH, EQUIPMENTFLYOUT_BORDERWIDTH);
	local horizontalItems = min(numItemButtons, EQUIPMENTFLYOUT_ITEMS_PER_ROW);
	local flyoutDirection = itemButton.flyoutDirection;
	local relativeAnchor = itemButton.popoutButton or itemButton;
	buttonAnchor:ClearAllPoints();
	if ( flyoutDirection == "LEFT" ) then
		buttonAnchor:SetPoint("TOPRIGHT", relativeAnchor, "TOPLEFT", -flyoutSettings.anchorX, flyoutSettings.anchorY);
	elseif ( flyoutDirection == "UP" ) then
		buttonAnchor:SetPoint("BOTTOMLEFT", relativeAnchor, "TOPLEFT", flyoutSettings.verticalAnchorX, -flyoutSettings.verticalAnchorY);
	elseif ( flyoutDirection == "DOWN" ) then
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

	local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound = EquipmentManager_GetItemInfoByLocation(location);
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

		local doNotSuppressOverlays = false;
		SetItemButtonQuality(button, quality, itemID, doNotSuppressOverlays, isBound);

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
	if ( (flyoutSettings.alwaysHideOnClick) or (EquipmentFlyoutFrame.button.popoutButton and EquipmentFlyoutFrame.button.popoutButton.flyoutLocked and not flyoutSettings.keepShownOnClick) ) then
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

function EquipmentFlyout_SetBackgroundTexture(texture)
	local self = EquipmentFlyoutFrame;

	self.NavigationFrame.BottomBackground:SetTexture(texture);
	self.buttonFrame.bg1:SetTexture(texture);

	local buttonAnchor = self.buttonFrame;
	local numBGs = buttonAnchor["numBGs"];
	for i = 1, numBGs do
		buttonAnchor["bg" .. i]:SetTexture(texture);
	end
end

--
-- Popouts - can only have 1 set, needs more work to be a template
-- 

local popoutButtons = {}

local POP_OUT_DIRECTION_LEFT = "LEFT";
local POP_OUT_DIRECTION_RIGHT = "RIGHT";
local POP_OUT_DIRECTION_UP = "UP";
local POP_OUT_DIRECTION_DOWN = "DOWN";

local POP_OUT_SIDE_WIDTH = 20;
local POP_OUT_SIDE_HEIGHT = 43;
local POP_OUT_VERTICAL_WIDTH = 43;
local POP_OUT_VERTICAL_HEIGHT = 20;
local POP_OUT_BASELINE_ROTATION_RADIANS = math.pi * 0.5;

local POP_OUT_ATLAS_SET_SIDE = {
	normalAtlas = "UI-Character-Info-Button-PullSide",
	openAtlas = "UI-Character-Info-Button-PullSide-Open",
	pressedAtlas = "UI-Character-Info-Button-PullSide-Pressed",
};

local POP_OUT_ATLAS_SET_UP = {
	normalAtlas = "UI-Character-Info-Button-PullUp",
	openAtlas = "UI-Character-Info-Button-PullUp-Open",
	pressedAtlas = "UI-Character-Info-Button-PullUp-Pressed",
};

local POP_OUT_DIRECTION_DATA = {
	[POP_OUT_DIRECTION_LEFT] = { atlasSet = POP_OUT_ATLAS_SET_SIDE, rotationRadians = -math.pi * 0.5 + POP_OUT_BASELINE_ROTATION_RADIANS, width = POP_OUT_SIDE_WIDTH, height = POP_OUT_SIDE_HEIGHT },
	[POP_OUT_DIRECTION_RIGHT] = { atlasSet = POP_OUT_ATLAS_SET_SIDE, rotationRadians = math.pi * 0.5 + POP_OUT_BASELINE_ROTATION_RADIANS, width = POP_OUT_SIDE_WIDTH, height = POP_OUT_SIDE_HEIGHT },
	[POP_OUT_DIRECTION_UP] = { atlasSet = POP_OUT_ATLAS_SET_UP, rotationRadians = 0, width = POP_OUT_VERTICAL_WIDTH, height = POP_OUT_VERTICAL_HEIGHT },
	[POP_OUT_DIRECTION_DOWN] = { atlasSet = POP_OUT_ATLAS_SET_UP, rotationRadians = math.pi, width = POP_OUT_VERTICAL_WIDTH, height = POP_OUT_VERTICAL_HEIGHT },
};

local function EquipmentFlyoutPopoutButton_GetDirection(self)
	local parent = self:GetParent();
	local direction = (parent and parent.flyoutDirection) or self.flyoutDirection;
	if ( direction ) then
		return direction;
	end

	if ( parent and parent.verticalFlyout ) then
		return POP_OUT_DIRECTION_UP;
	end

	return POP_OUT_DIRECTION_RIGHT;
end

function EquipmentFlyoutPopoutButton_RefreshVisualState(self)
	local direction = EquipmentFlyoutPopoutButton_GetDirection(self);
	local directionData = POP_OUT_DIRECTION_DATA[direction] or POP_OUT_DIRECTION_DATA[POP_OUT_DIRECTION_RIGHT];
	local atlasSet = directionData.atlasSet;

	local normalAtlas = self.flyoutLocked and atlasSet.openAtlas or atlasSet.normalAtlas;
	self:SetNormalAtlas(normalAtlas, TextureKitConstants.UseAtlasSize);
	self:SetPushedAtlas(atlasSet.pressedAtlas, TextureKitConstants.UseAtlasSize);
	self:SetHighlightAtlas(normalAtlas, "ADD");
	self:SetSize(directionData.width, directionData.height);

	local normalTexture = self:GetNormalTexture();
	local pushedTexture = self:GetPushedTexture();
	local highlightTexture = self:GetHighlightTexture();

	if ( normalTexture and normalTexture.SetRotation ) then
		normalTexture:SetRotation(directionData.rotationRadians);
	end
	if ( pushedTexture and pushedTexture.SetRotation ) then
		pushedTexture:SetRotation(directionData.rotationRadians);
	end
	if ( highlightTexture and highlightTexture.SetRotation ) then
		highlightTexture:SetRotation(directionData.rotationRadians);
	end
end

function EquipmentFlyoutPopoutButton_OnLoad(self)
	tinsert(popoutButtons, self);

	EquipmentFlyoutPopoutButton_RefreshVisualState(self);
end

function EquipmentFlyoutPopoutButton_OnStateChanged(self)
	EquipmentFlyoutPopoutButton_RefreshVisualState(self);
end

function EquipmentFlyoutPopoutButton_HideAll()
	local flyout = EquipmentFlyoutFrame;
	if ( flyout.button and flyout.button.popoutButton and flyout.button.popoutButton.flyoutLocked ) then
		flyout:Hide();
	end
	for _, button in pairs(popoutButtons) do
		if ( button.flyoutLocked ) then
			button.flyoutLocked = false;
			flyout:Hide();
			EquipmentFlyoutPopoutButton_RefreshVisualState(button);
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
	else
		self.flyoutLocked = true;
		EquipmentFlyout_Show(self:GetParent());
	end
	EquipmentFlyoutPopoutButton_RefreshVisualState(self);
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
