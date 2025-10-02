local ModelSceneID = 691;
local ActorTag = "decor";
local QuestionMarkIconFileDataID = 134400;

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

function HousingCatalogEntryMixin:IsInvalidArea()
	local indoors = C_Housing.IsInsideHouse();
	local invalidIndoors = indoors and not self.entryInfo.isAllowedIndoors;
	local invalidOutdoors = not indoors and not self.entryInfo.isAllowedOutdoors;
	return invalidIndoors, invalidOutdoors;
end

function HousingCatalogEntryMixin:UpdateVisuals()

	local invalidIndoors, invalidOutdoors = self:IsInvalidArea();
	local valid = not invalidIndoors and not invalidOutdoors;

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
		self.InfoText:SetText(price .. CreateAtlasMarkup("hearthsteel-icon-32x32", 16, 16));
		self.InfoText:SetShown(price > 0);
	else
		self.InfoText:SetText(self.entryInfo.quantity + self.entryInfo.remainingRedeemable);
		self.InfoText:SetShown(self.entryInfo.showQuantity);
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

	local invalidIndoors, invalidOutdoors = self:IsInvalidArea();
	if invalidIndoors then
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_DECOR_ONLY_PLACEABLE_OUTSIDE);
	elseif invalidOutdoors then
		GameTooltip_AddErrorLine(GameTooltip, HOUSING_DECOR_ONLY_PLACEABLE_INSIDE);
	end

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
	if button == "RightButton" then
		self:ShowContextMenu();
	else
		local isDrag = false;
		self:OnInteract(isDrag);
	end
end

function HousingCatalogEntryMixin:OnDragStart()
	local isDrag = true;
	self:OnInteract(isDrag);
end

function HousingCatalogEntryMixin:TypeSpecificInit()
	-- Optional override
end

function HousingCatalogEntryMixin:TypeSpecificReset()
	-- Optional override
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

function HousingCatalogEntryMixin:OnInteract(isDrag)
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
	local total = entryInfo.numPlaced + entryInfo.numStored;
	GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_OWNED_COUNT_FORMAT:format(total, entryInfo.numPlaced, entryInfo.numStored));

	local dyeNames = entryInfo.customizations;
	if dyeNames and #dyeNames > 0 then
		local dyeNamesString = table.concat(dyeNames, ", ");
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_DYE_LIST:format(dyeNamesString));
	end
end

StaticPopupDialogs["HOUSING_LAYOUT_MAX_DECOR_REACHED"] = {
	text = HOUSING_LAYOUT_DECOR_LIMIT_REACHED,
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

function HousingCatalogDecorEntryMixin:OnInteract(isDrag)
	-- TODO:: Allow preview placement when quantity is 0.
	if not self:HasValidData() or self.entryInfo.quantity + self.entryInfo.remainingRedeemable <= 0 then
		return;
	end

	local decorPlaced = C_HousingDecor.GetNumDecorPlaced();
	local maxDecor = C_HousingDecor.GetMaxDecorPlaced();
	if decorPlaced >= maxDecor then
		StaticPopup_Show("HOUSING_LAYOUT_MAX_DECOR_REACHED");
		return;
	end

	local invalidIndoors, invalidOutdoors = self:IsInvalidArea();
	if invalidIndoors then
		UIErrorsFrame:AddMessage(HOUSING_DECOR_ONLY_PLACEABLE_OUTSIDE_ERROR, RED_FONT_COLOR:GetRGBA());
		return;
	elseif invalidOutdoors then
		UIErrorsFrame:AddMessage(HOUSING_DECOR_ONLY_PLACEABLE_INSIDE_ERROR, RED_FONT_COLOR:GetRGBA());
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
};

function HousingCatalogRoomEntryMixin:TypeSpecificInit()
	FrameUtil.RegisterFrameForEvents(self, RoomEntryEvents);
	self.isValid = true;
end

function HousingCatalogRoomEntryMixin:TypeSpecificReset()
	FrameUtil.UnregisterFrameForEvents(self, RoomEntryEvents);
end

function HousingCatalogRoomEntryMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED" then
		local anySelected, roomID = ...;

		self:SetSelected(anySelected and roomID == self.entryID.recordID);
	elseif event == "HOUSING_LAYOUT_DOOR_SELECTED" then
		local roomGUID, doorComponentId = ...;
		self:SetValid(C_HousingLayout.HasValidConnection(roomGUID, doorComponentId, self.entryID.recordID));
	elseif event == "HOUSING_LAYOUT_DOOR_SELECTION_CHANGED" then
		local hasSelectedDoor = ...;
		if not hasSelectedDoor then
			self:SetValid(true);
		end
	end
end

function HousingCatalogRoomEntryMixin:SetValid(isValid)
	self.isValid = isValid;
	self.Icon:SetDesaturation(isValid and 0.0 or 1.0);
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
	if not self.isValid then
		GameTooltip_AddColoredLine(tooltip, HOUSING_LAYOUT_CANT_PLACE_ROOM_TOOLTIP, RED_FONT_COLOR);
	end
end

function HousingCatalogRoomEntryMixin:OnInteract(isDrag)
	if not self:HasValidData() or not self.isValid or isDrag then
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

	if C_HousingLayout.HasSelectedDoor() then
		C_HousingLayout.CreateNewRoom(roomID);
	else
		local selectedFloorplan = C_HousingLayout.GetSelectedFloorplan();
		if selectedFloorplan then
			C_HousingLayout.DeselectFloorplan();
		end

		if not selectedFloorplan or selectedFloorplan ~= roomID then
			C_HousingLayout.SelectFloorplan(roomID);
		end
	end
end
