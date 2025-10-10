local ModelSceneID = 691;
local ActorTag = "decor";
local QuestionMarkIconFileDataID = 134400;
local HearthsteelAtlasMarkup = CreateAtlasMarkup("hearthsteel-icon-32x32", 16, 16, 0, -1);

HousingCatalogEntryMixin = {};

function HousingCatalogEntryMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(ModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
end

function HousingCatalogEntryMixin:Init(elementData)
	self.elementData = elementData;
	self.entryID = elementData.entryID;
	local forceUpdate = true;
	self:UpdateEntryData(forceUpdate);

	self:TypeSpecificInit();
end

function HousingCatalogEntryMixin:UpdateEntryData(forceUpdate)
	if not self.elementData or not self.entryID then
		self:ClearEntryData();
		return;
	end

	local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(self.entryID);

	if not entryInfo then
		self:ClearEntryData();
		return;
	end

	-- Avoid updating all data and visuals if it's not necessary
	if not forceUpdate and self.entryInfo and tCompare(entryInfo, self.entryInfo) then
		return;
	end

	self:ClearEntryData();

	self.entryInfo = entryInfo;

	self:UpdateTypeSpecificData();

	self:UpdateVisuals();
end

function HousingCatalogEntryMixin:ClearEntryData()
	local actor = self.ModelScene:GetActorByTag(ActorTag);
	if actor then
		actor:ClearModel();
	end

	self:ClearTypeSpecificData();

	self.entryInfo = nil;
end

function HousingCatalogEntryMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.elementData = nil
	self.entryID = nil;
	self:ClearEntryData();

	self:TypeSpecificReset();
end

-- Returns bool isValid, invalidTooltip, invalidError
function HousingCatalogEntryMixin:GetIsValid()
	local isValid, invalidTooltip, invalidError = true, nil, nil;

	-- First check for invalid data
	if not self:HasValidData() then
		isValid = false;
		invalidTooltip = nil;
		invalidError = nil;
	end

	-- If valid so far, check for invalid house editor context
	if isValid and C_HouseEditor.IsHouseEditorActive() then
		local currentlyIndoors = C_Housing.IsInsideHouse();
		local invalidIndoors = currentlyIndoors and not self.entryInfo.isAllowedIndoors;
		local invalidOutdoors = not currentlyIndoors and not self.entryInfo.isAllowedOutdoors;

		isValid = not invalidIndoors and not invalidOutdoors;

		if invalidIndoors then
			invalidTooltip =  HOUSING_DECOR_ONLY_PLACEABLE_OUTSIDE;
			invalidError = HOUSING_DECOR_ONLY_PLACEABLE_OUTSIDE_ERROR;
		elseif invalidOutdoors then
			invalidTooltip = HOUSING_DECOR_ONLY_PLACEABLE_INSIDE;
			invalidError = HOUSING_DECOR_ONLY_PLACEABLE_INSIDE_ERROR
		end
	end

	-- If still valid so far, do type-specific valid check
	if isValid then
		isValid, invalidTooltip, invalidError = self:GetTypeSpecificIsValid();
	end

	return isValid, invalidTooltip, invalidError;
end

function HousingCatalogEntryMixin:AddInvalidTooltipLine(tooltip)
	local isValid, invalidTooltip = self:GetIsValid();
	if not isValid and invalidTooltip then
		GameTooltip_AddErrorLine(tooltip, invalidTooltip);
	end
end

function HousingCatalogEntryMixin:UpdateVisuals()
	local valid = self:GetIsValid();

	if self.entryInfo.iconTexture or self.entryInfo.iconAtlas then
		self.ModelScene:Hide();
		if self.entryInfo.iconTexture then
			self.Icon:SetTexture(self.entryInfo.iconTexture);
		else
			self.Icon:SetAtlas(self.entryInfo.iconAtlas);
		end

		if valid then
			self.Icon:SetDesaturated(false);
			self.Icon:SetAlpha(1);
		else
			self.Icon:SetDesaturated(true);
			self.Icon:SetAlpha(0.5);
		end

		self.Icon:Show();
	elseif self.entryInfo.asset then
		local actor = self.ModelScene:GetActorByTag(ActorTag);
		if actor then
			local modelID = self.entryInfo.asset;
			actor:SetModelByFileID(modelID);

			if valid then
				actor:SetDesaturation(0);
				actor:SetAlpha(1);
			else
				actor:SetDesaturation(1);
				actor:SetAlpha(0.5);
			end
		end

		self.ModelScene:Show();
		self.Icon:SetTexture(nil);
		self.Icon:Hide();
	else
		-- HOUSING_TODO: Remove or update placeholder replacement
		self.ModelScene:Hide();
		self.Icon:SetTexture(QuestionMarkIconFileDataID);
		self.Icon:Show();
	end

	if self:IsInMarketView() then
		local marketInfo = self.entryInfo.marketInfo;
		local price = marketInfo and marketInfo.price or 0;
		self.InfoText:SetText(price .. HearthsteelAtlasMarkup);
		self.InfoText:SetShown(price > 0);
	else
		self.InfoText:SetText(self.entryInfo.quantity + self.entryInfo.remainingRedeemable);
		self.InfoText:SetShown(self.entryInfo.showQuantity);
	end

	-- If already being hovered, make sure to refresh the tooltip
	if self:IsMouseMotionFocus() then
		self:OnEnter();
	end
end

function HousingCatalogEntryMixin:UpdateBackground(isPressed)
	local backgroundAtlas = self.backgroundDefault;
	if isPressed then
		backgroundAtlas = self.backgroundPressed;
	elseif self.isSelected then
		backgroundAtlas = self.backgroundActive;
	end

	self.Background:SetAtlas(backgroundAtlas);
	self.HoverBackground:SetAtlas(backgroundAtlas);
end

function HousingCatalogEntryMixin:HasValidData()
	return self.elementData and self.entryInfo;
end

function HousingCatalogEntryMixin:GetElementData()
	return self.elementData;
end

function HousingCatalogEntryMixin:OnEnter()
	if not self:HasValidData() then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);

	self:AddTooltipTitle(GameTooltip);
	self:AddTooltipLines(GameTooltip);

	EventRegistry:TriggerEvent("HousingCatalogEntry.TooltipCreated", self, GameTooltip);

	GameTooltip:Show();

	self.HoverBackground:Show();

	PlaySound(SOUNDKIT.HOUSING_ITEM_HOVER);
end

function HousingCatalogEntryMixin:OnLeave()
	if not self:HasValidData() then
		return;
	end

	GameTooltip:Hide();

	self.HoverBackground:Hide();
end

function HousingCatalogEntryMixin:OnMouseDown()
	if self:IsEnabled() then
		local isPressed = true;
		self:UpdateBackground(isPressed);
	end
end

function HousingCatalogEntryMixin:OnMouseUp()
	if self:IsEnabled() then
		local isPressed = false;
		self:UpdateBackground(isPressed);
	end
end

function HousingCatalogEntryMixin:OnClick(button)
	local isDrag = false;
	self:OnInteract(button, isDrag);
end

function HousingCatalogEntryMixin:OnDragStart()
	local button = nil;
	local isDrag = true;
	self:OnInteract(button, isDrag);
end

function HousingCatalogEntryMixin:OnInteract(button, isDrag)
	if not self:HasValidData() then
		return;
	end

	EventRegistry:TriggerEvent("HousingCatalogEntry.OnInteract", self, button, isDrag);

	if button == "RightButton" then
		self:ShowContextMenu();
	else
		self:TypeSpecificOnInteract(button, isDrag);
	end
end

function HousingCatalogEntryMixin:TypeSpecificInit()
	-- Optional override
end

function HousingCatalogEntryMixin:TypeSpecificReset()
	-- Optional override
end

function HousingCatalogEntryMixin:GetTypeSpecificIsValid()
	-- Optional override, should return isValid, invalidTooltip, invalidError
	return true, nil, nil;
end

function HousingCatalogEntryMixin:UpdateTypeSpecificData()
	-- Optional override
end

function HousingCatalogEntryMixin:ClearTypeSpecificData()
	-- Optional override
end

function HousingCatalogEntryMixin:IsInMarketView()
	-- Optional override
	return false;
end

function HousingCatalogEntryMixin:ShowContextMenu()
	-- Optional override
end

function HousingCatalogEntryMixin:TypeSpecificOnInteract(isDrag)
	-- Type-specific override required
	assert(false);
end

function HousingCatalogEntryMixin:AddTooltipTitle(tooltip)
	-- Optional override
	local wrap = false;
	GameTooltip_SetTitle(tooltip, self.entryInfo.name, nil, wrap);
end

function HousingCatalogEntryMixin:AddTooltipLines(tooltip)
	-- Type-specific override required
	assert(false);
end


HousingCatalogDecorEntryMixin = {};

function HousingCatalogDecorEntryMixin:AddTooltipTitle(tooltip)
	local dyeNames = self.entryInfo.customizations;
	local isDyed = dyeNames and #dyeNames > 0;
	local name = isDyed and HOUSING_DECOR_DYED_NAME_FORMAT:format(self.entryInfo.name) or self.entryInfo.name;
	local placementCost = HOUSING_DECOR_PLACEMENT_COST_FORMAT:format(self.entryInfo.placementCost);
	local wrap = false;
	GameTooltip_AddColoredDoubleLine(tooltip, name, placementCost, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, wrap);
end

function HousingCatalogDecorEntryMixin:AddTooltipLines(tooltip)
	local entryInfo = self.entryInfo;
	local marketInfo = entryInfo.marketInfo;

	local total = entryInfo.numPlaced + entryInfo.numStored;
	if total ~= 0 then
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_OWNED_COUNT_FORMAT:format(total, entryInfo.numPlaced, entryInfo.numStored));
	end

	if entryInfo.firstAcquisitionBonus > 0 then
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_FIRST_ACQUISITION_FORMAT:format(entryInfo.firstAcquisitionBonus));
	end

	self:AddInvalidTooltipLine(tooltip);

	if marketInfo and marketInfo.price then
		local priceText = marketInfo.price .. HearthsteelAtlasMarkup;
		GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_PRICE_FORMAT:format(priceText));
	end

	if marketInfo and #marketInfo.bundleIDs > 0 then
		GameTooltip_AddColoredLine(tooltip, HOUSING_DECOR_BUNDLE_DISCLAIMER, DISCLAIMER_TOOLTIP_COLOR);
	end

	local dyeNames = entryInfo.customizations;
	if dyeNames and #dyeNames > 0 then
		local dyeNamesString = table.concat(dyeNames, ", ");
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_DYE_LIST:format(dyeNamesString));
	end
end

StaticPopupDialogs["HOUSING_MAX_DECOR_REACHED"] = {
	text = ERR_PLACED_DECOR_LIMIT_REACHED,
	button1 = OKAY,
	button2 = nil
};

function HousingCatalogDecorEntryMixin:IsInMarketView()
	-- TODO:: Replace this hack. For now I'm not sure how preview placement will work so I'm disabling it.
	local storagePanel = HouseEditorFrame and HouseEditorFrame.StoragePanel or nil;
	if storagePanel and storagePanel:IsInMarketTab() then
		return true;
	end

	return false;
end

function HousingCatalogDecorEntryMixin:TypeSpecificOnInteract(button, isDrag)
	if not C_HouseEditor.IsHouseEditorActive() then
		return;
	end
	
	-- TODO:: Allow preview placement when quantity is 0.
	if self.entryInfo.quantity + self.entryInfo.remainingRedeemable <= 0 then
		return;
	end

	local decorPlaced = C_HousingDecor.GetNumDecorPlaced();
	local maxDecor = C_HousingDecor.GetMaxDecorPlaced();
	if decorPlaced >= maxDecor then
		StaticPopup_Show("HOUSING_MAX_DECOR_REACHED");
		return;
	end

	local isValid, invalidTooltip, invalidError = self:GetIsValid();
	if not isValid then
		local errorMessage = invalidError or invalidTooltip;
		if errorMessage then
			UIErrorsFrame:AddMessage(errorMessage, RED_FONT_COLOR:GetRGBA());
		end
		return;
	end

	if self:IsInMarketView() then
		-- TODO:: Implement preview placement for market tab
	else
		local sound;
		local size = self.entryInfo.size;
		if size == Enum.HousingCatalogEntrySize.Tiny or size == Enum.HousingCatalogEntrySize.Small then
			sound = SOUNDKIT.HOUSING_SELECT_ITEM_SMALL;
		elseif size == Enum.HousingCatalogEntrySize.Medium or size == Enum.HousingCatalogEntrySize.None then
			sound = SOUNDKIT.HOUSING_SELECT_ITEM_MEDIUM;
		else
			sound = SOUNDKIT.HOUSING_SELECT_ITEM_LARGE;
		end
		PlaySound(sound);

		if not C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.BasicDecor) then
			C_HouseEditor.ActivateHouseEditorMode(Enum.HouseEditorMode.BasicDecor);

			RunNextFrame(function()
				C_HousingBasicMode.StartPlacingNewDecor(self.entryID);
			end);
			return;
		end

		local activeHouseEditorMode = C_HouseEditor.GetActiveHouseEditorMode();
		local activeEditorModeFrame = HouseEditorFrame and HouseEditorFrame:GetActiveModeFrame();
		if activeHouseEditorMode == Enum.HouseEditorMode.BasicDecor and activeEditorModeFrame then
			-- if user dragged icon from the house chest, then add decor on mouse up.
			-- otherwise, user clicked on house chest icon; don't add decor until next click.
			activeEditorModeFrame.commitNewDecorOnMouseUp = isDrag;

			-- HOUSING_TODO: We should add some kind of out error to these kinds of APIs so we can display any failure reasons
			C_HousingBasicMode.StartPlacingNewDecor(self.entryID);
		end
	end
end

StaticPopupDialogs["CONFIRM_DESTROY_DECOR"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = DECLINE,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,

	OnAccept = function(dialog, data)
		data.owner:OnDestroyConfirmed(data.destroyAll);
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			data.owner:OnDestroyConfirmed(data.destroyAll);
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};

function HousingCatalogDecorEntryMixin:OnDestroyConfirmed(destroyAll)
	C_HousingCatalog.DestroyEntry(self.entryID, destroyAll)
end

function HousingCatalogDecorEntryMixin:ShowContextMenu()
	-- If any other catalog entry type is added that can also be destroyed, we can move all this to be shared
	-- with some kind of conditional flag - for now, it's only for decor
	local canDestroyEntry = C_HousingCatalog.CanDestroyEntry(self.entryID);

	local showDisabledTooltip = function(tooltip, elementDescription)
		GameTooltip_SetTitle(tooltip, HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY);
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_CATALOG_ENTRY");

		local destroySingleButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY, function()
			local popupData = {
				destroyAll = false,
				owner = self,
				confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
			};
			local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING);
			StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData);
		end);
		destroySingleButtonDesc:SetEnabled(canDestroyEntry);
		if not canDestroyEntry then
			destroySingleButtonDesc:SetTooltip(showDisabledTooltip);
		end

		if self.entryInfo.quantity > 1 then
			local destroyAllButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY_ALL, function()
				local popupData = {
					destroyAll = true,
					owner = self,
					confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
				};
				local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY_ALL, self.entryInfo.quantity, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING);
				StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData);
			end);
			destroyAllButtonDesc:SetEnabled(canDestroyEntry);
			if not canDestroyEntry then
				destroyAllButtonDesc:SetTooltip(showDisabledTooltip);
			end
		end
	end);
end

HousingCatalogRoomEntryMixin = {};

local RoomEntryEvents = {
	"HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
	"HOUSING_LAYOUT_DOOR_SELECTED",
	"HOUSING_LAYOUT_DOOR_SELECTION_CHANGED",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSE_LEVEL_CHANGED"
};

function HousingCatalogRoomEntryMixin:TypeSpecificInit()
	FrameUtil.RegisterFrameForEvents(self, RoomEntryEvents);
end

function HousingCatalogRoomEntryMixin:TypeSpecificReset()
	FrameUtil.UnregisterFrameForEvents(self, RoomEntryEvents);
end

function HousingCatalogRoomEntryMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED" then
		local anySelected, roomID = ...;
		self:SetSelected(anySelected and roomID == self.entryID.recordID);
	elseif event == "HOUSING_LAYOUT_DOOR_SELECTED" or event == "HOUSING_LAYOUT_DOOR_SELECTION_CHANGED" 
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" or event == "HOUSING_LAYOUT_ROOM_REMOVED" or event == "HOUSE_LEVEL_CHANGED" then
		self:UpdateVisuals();
	end
end

function HousingCatalogRoomEntryMixin:GetTypeSpecificIsValid()
	local isValid, invalidTooltip, invalidError = true, nil, nil;

	local isAtBudgetMax = C_HousingLayout.GetNumActiveRooms() >= C_HousingLayout.GetRoomPlacementBudget();
	if isAtBudgetMax then
		isValid = false;
		invalidTooltip = ERR_PLACED_ROOM_LIMIT_REACHED;
	end

	local doorComponentID, roomGUID = C_HousingLayout.GetSelectedDoor();
	if isValid and doorComponentID and roomGUID then
		isValid = C_HousingLayout.HasValidConnection(roomGUID, doorComponentID, self.entryID.recordID);
		if not isValid then
			invalidTooltip = HOUSING_LAYOUT_CANT_PLACE_ROOM_TOOLTIP;
		end
	end

	return isValid, invalidTooltip, invalidError;
end

function HousingCatalogRoomEntryMixin:UpdateTypeSpecificData()
	if not self:HasValidData() then
		return;
	end
	local selectedFloorplan = C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.Layout) and C_HousingLayout.GetSelectedFloorplan() or nil;
	local isSelected = selectedFloorplan == self.entryID.recordID;

	if isSelected ~= self.isSelected then
		self:SetSelected(isSelected);
	end
end

function HousingCatalogRoomEntryMixin:SetSelected(isSelected)
	self.isSelected = isSelected;
	local isPressed = false;
	self:UpdateBackground(isPressed);
end

function HousingCatalogRoomEntryMixin:AddTooltipLines(tooltip)
	self:AddInvalidTooltipLine(tooltip);
end

function HousingCatalogRoomEntryMixin:TypeSpecificOnInteract(button, isDrag)
	if not C_HouseEditor.IsHouseEditorActive() or isDrag then
		return;
	end

	local isValid, invalidTooltip, invalidError = self:GetIsValid();
	if not isValid then
		local errorMessage = invalidError or invalidTooltip;
		if errorMessage then
			UIErrorsFrame:AddMessage(errorMessage, RED_FONT_COLOR:GetRGBA());
		end
		return;
	end

	local roomID = self.entryID.recordID;

	PlaySound(SOUNDKIT.HOUSING_SELECT_ROOM_FROM_MENU);

	if not C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.Layout) then
		C_HouseEditor.ActivateHouseEditorMode(Enum.HouseEditorMode.Layout);

		RunNextFrame(function()
			C_HousingLayout.SelectFloorplan(roomID);
		end);
		return;
	end

	local selectedFloorplan = C_HousingLayout.GetSelectedFloorplan();
	if selectedFloorplan then
		C_HousingLayout.DeselectFloorplan();
	end

	if not selectedFloorplan or selectedFloorplan ~= roomID then
		C_HousingLayout.SelectFloorplan(roomID);
	end
end
