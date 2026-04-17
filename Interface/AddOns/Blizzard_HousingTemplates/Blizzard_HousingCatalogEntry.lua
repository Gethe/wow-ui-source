local ModelSceneID = 691;
local ActorTag = "decor";
local QuestionMarkIconFileDataID = 134400;
local ContentTrackingAtlasMarkup = CreateAtlasMarkup("waypoint-mappin-minimap-untracked", 16, 16, -3, 0);

-- This is decor-only for now but should be extended to support entry type and recordID generically
local function GetMarketInfoIfDecor(entryVariantID)
	if entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor then
		return C_HousingCatalog.GetMarketInfoForDecor(entryVariantID.recordID);
	end

	return nil;
end

HousingCatalogDyeDisplayMixin = {};

function HousingCatalogDyeDisplayMixin:OnLoad()
	if self.spacingAdjust then
		local spacingAdjust = self.spacingAdjust;
		for i = 2, #self.dyeIcons do
			local icon = self.dyeIcons[i];
			icon:AdjustPointsOffset(spacingAdjust, 0);
		end
	end
end

function HousingCatalogDyeDisplayMixin:GetDyeIcon(index)
	return self.dyeIcons[index];
end

function HousingCatalogDyeDisplayMixin:SetNumDyeIconsShown(numIcons)
	for i, icon in ipairs(self.dyeIcons) do
		icon:SetShown(i <= numIcons);
	end
end

function HousingCatalogDyeDisplayMixin:UpdateDyeSlots(dyeSlots)
	local anyDyes = false;
	for i, dyeSlotEntry in ipairs(dyeSlots) do
		local icon = self:GetDyeIcon(i);
		local dyeColorID = dyeSlotEntry.dyeColorID;
		local dyeColorInfo = dyeColorID and C_DyeColor.GetDyeColorInfo(dyeColorID) or nil;
		if dyeColorInfo then
			icon:SetVertexColor(dyeColorInfo.swatchColorStart:GetRGB());
			anyDyes = true;
		else
			icon:SetVertexColor(1, 1, 1);
		end

		icon:SetAlpha(dyeColorInfo and 1 or 0.2);
	end
	self:SetNumDyeIconsShown(#dyeSlots);
	return anyDyes;
end

HousingCatalogEntryMixin = {};

function HousingCatalogEntryMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(ModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	self:TypeSpecificOnLoad();
end

function HousingCatalogEntryMixin:Init(elementData)
	self.elementData = elementData;
	self.entryVariantID = elementData.entryVariantID;
	self.bundleItemInfo = elementData.bundleItemInfo;
	local forceUpdate = true;
	self:UpdateEntryData(forceUpdate);

	if self.whileInitializedEvents then
		FrameUtil.RegisterFrameForEvents(self, self.whileInitializedEvents);
	end

	self:TypeSpecificInit();
end

function HousingCatalogEntryMixin:IsBundleItem()
	return self.bundleItemInfo ~= nil;
end

function HousingCatalogEntryMixin:GetNumDecorPlaced()
	if not self:IsBundleItem() then
		return 0;
	end

	return HouseEditorFrame.MarketShoppingCartFrame:GetNumDecorPlaced(self.bundleItemInfo.bundleCatalogShopProductID, self.bundleItemInfo.decorID);
end

function HousingCatalogEntryMixin.Reset(framePool, self)
	if self.whileInitializedEvents then
		FrameUtil.UnregisterFrameForEvents(self, self.whileInitializedEvents);
	end

	Pool_HideAndClearAnchors(framePool, self);
	self.elementData = nil
	self.entryVariantID = nil;
	self:ClearEntryData();

	self:TypeSpecificReset();
end

function HousingCatalogEntryMixin:OnShow()
	if self.whileShownEvents then
		FrameUtil.RegisterFrameForEvents(self, self.whileShownEvents);
	end
	self:UpdateVisuals();
end

function HousingCatalogEntryMixin:OnHide()
	if self.whileShownEvents then
		FrameUtil.UnregisterFrameForEvents(self, self.whileShownEvents);
	end
end

function HousingCatalogEntryMixin:GetEntryData()
	return self.entryVariantID and C_HousingCatalog.GetCatalogEntryInfo(self.entryVariantID) or nil;
end

function HousingCatalogEntryMixin:GetVariantData()
	return self.entryVariantID and C_HousingCatalog.GetCatalogEntryVariantInfo(self.entryVariantID) or nil;
end

function HousingCatalogEntryMixin:UpdateEntryData(forceUpdate)
	local isValidBundleItem = self:IsBundleItem() and self.bundleItemInfo and self.bundleItemInfo.decorID;
	if not self.elementData or (not self.entryVariantID and not isValidBundleItem) then
		self:ClearEntryData();
		return;
	end

	local entryInfo = self:GetEntryData();
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
	self.variantInfo = self:GetVariantData();

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
	self.variantInfo = nil;
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
	if not self:HasValidData() then
		return;
	end
	
	local valid = self:GetIsValid();
	local displayContext = self:GetDisplayContext();

	if self.entryInfo.iconTexture or self.entryInfo.iconAtlas then
		self.ModelScene:Hide();
		if self.entryInfo.iconTexture then
			self.Icon:SetTexture(self.entryInfo.iconTexture);
		else
			self.Icon:SetAtlas(self.entryInfo.iconAtlas);
		end

		self:SetEnabled(valid);
		if valid then
			self.Icon:SetDesaturated(false);
			self.CustomizeIcon:SetDesaturated(false);
			self.Icon:SetAlpha(1);
			self.InfoText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			self.Background:SetDesaturated(false);
		else
			self.Icon:SetDesaturated(true);
			self.CustomizeIcon:SetDesaturated(true);
			self.Icon:SetAlpha(0.5);
			self.InfoText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			self.Background:SetDesaturated(true);
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
		self.ModelScene:Hide();
		self.Icon:SetTexture(QuestionMarkIconFileDataID);
		self.Icon:Show();
	end

	self.CustomizeIcon:SetShown(self.entryInfo.canCustomize);

	self.InfoIcon:Hide();

	if self:IsBundleItem() then
		self.InfoText:Show();

		local numPlaced = self:GetNumDecorPlaced();
		local quantity = self.bundleItemInfo.quantity - numPlaced;
		self.InfoText:SetText(quantity);
		if quantity <= 0 then
			self.InfoText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	elseif displayContext.showMarketInfo then
		local marketInfo = GetMarketInfoIfDecor(self.entryVariantID);
		local price = marketInfo and marketInfo.price or 0;
		self.InfoText:SetText(Blizzard_HousingCatalogUtil.FormatPrice(price));
		self.InfoText:SetShown(price > 0);
	elseif self.entryInfo.isUniqueTrophy then
		-- Right now info icon is only used for the unique trophy icon.
		self.InfoText:Hide();
		self.InfoIcon:Show();
	else
		-- We only use variant quantities if we're showing split up individual stacks
		local variantInfoForQuantity = displayContext.showVariantStacks and self.variantInfo or nil;
		local quantity = Blizzard_HousingCatalogUtil.GetEntryQuantity(self.entryInfo, variantInfoForQuantity);
		self.InfoText:SetText(quantity);
		local showQuantity = quantity > 0 and self.entryVariantID.entryType ~= Enum.HousingCatalogEntryType.Room;
		self.InfoText:SetShown(showQuantity);
	end

	self:UpdateTypeSpecificVisuals();

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
	return self.elementData and (self.entryVariantID or self.bundleItemInfo) and self.entryInfo;
end

function HousingCatalogEntryMixin:GetElementData()
	return self.elementData;
end

function HousingCatalogEntryMixin:GetDisplayContext()
	local displayContext = nil;
	if self.elementData then
		displayContext = self.elementData.displayContextGetter();
	end

	if not displayContext then
		-- Rather than nil, just use all-false values of each expected field
		-- This makes things easier than scattering nil checks everywhere, and majority of logic is already gated by HasValidData anyway
		displayContext = {
			isDefault = true, -- For debugging sources of context values if needed
			showMarketInfo = false,
			showVariantStacks = false,
			showDestroyOptions = false,
			showTrackingOptions = false,
		};
	end
	
	return displayContext;
end

function HousingCatalogEntryMixin:OnEnter()
	if not self:HasValidData() then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);

	self:AddTooltipTitle(GameTooltip);
	self:AddTooltipLines(GameTooltip);
	self:AddTooltipTrackingLines(GameTooltip);

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

	if IsModifiedClick("CHATLINK") then
		local decorLink = C_HousingDecor.GetDecorHyperlink(self.entryVariantID.recordID);
		ChatFrameUtil.InsertLink(decorLink);
	elseif button == "RightButton" then
		self:ShowContextMenu();
	else
		self:TypeSpecificOnInteract(button, isDrag);
	end
end

function HousingCatalogEntryMixin:TypeSpecificOnLoad()
	-- Optional override
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

function HousingCatalogEntryMixin:UpdateTypeSpecificVisuals()
	-- Optional override
end

function HousingCatalogEntryMixin:UpdateTypeSpecificData()
	-- Optional override
end

function HousingCatalogEntryMixin:ClearTypeSpecificData()
	-- Optional override
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

function HousingCatalogEntryMixin:AddTooltipTrackingLines(tooltip)
	-- Optional override
end

HousingCatalogDecorEntryMixin = CreateFromMixins(HousingCatalogEntryMixin);

function HousingCatalogDecorEntryMixin:GetEntryData()
	-- Overrides HousingCatalogEntryMixin.

	return self:IsBundleItem() and C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, self.bundleItemInfo.decorID) or HousingCatalogEntryMixin.GetEntryData(self);
end

function HousingCatalogDecorEntryMixin:AddTooltipTitle(tooltip)
	-- Overrides HousingCatalogEntryMixin.

	local dyeNames = self.entryInfo.customizations;
	local isDyed = dyeNames and #dyeNames > 0;
	local name = isDyed and HOUSING_DECOR_DYED_NAME_FORMAT:format(self.entryInfo.name) or self.entryInfo.name;
	local placementCost = HOUSING_DECOR_PLACEMENT_COST_FORMAT:format(self.entryInfo.placementCost);
	local itemQualityColor = ColorManager.GetColorDataForItemQuality(self.entryInfo.quality or Enum.ItemQuality.Common).color;
	local wrap = false;
	GameTooltip_AddColoredDoubleLine(tooltip, name, placementCost, itemQualityColor, HIGHLIGHT_FONT_COLOR, wrap);
end

function HousingCatalogDecorEntryMixin:AddTooltipLines(tooltip)
	-- Overrides HousingCatalogEntryMixin.

	local entryInfo = self.entryInfo;
	local displayContext = self:GetDisplayContext();

	if entryInfo.isUniqueTrophy then
		GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_UNIQUE_TROPHY_TOOLTIP);
	end

	local stored = Blizzard_HousingCatalogUtil.GetEntryNumStored(entryInfo);
	local total = Blizzard_HousingCatalogUtil.GetEntryTotalOwned(entryInfo);
	if total ~= 0 then
		local wrapTotal = false;
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_OWNED_COUNT_FORMAT:format(total, entryInfo.totalNumPlaced, stored), wrapTotal);
	end

	if entryInfo.firstAcquisitionBonus > 0 then
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_FIRST_ACQUISITION_FORMAT:format(entryInfo.firstAcquisitionBonus));
	end

	self:AddInvalidTooltipLine(tooltip);

	if self:IsBundleItem() then
		local numPlaced = self:GetNumDecorPlaced();
		if numPlaced >= self.bundleItemInfo.quantity then
			GameTooltip_AddErrorLine(tooltip, HOUSING_BUNDLE_BUNDLE_ITEM_PLACED);
		else
			GameTooltip_AddInstructionLine(tooltip, HOUSING_BUNDLE_CLICK_TO_PLACE_DECOR);
		end
	elseif displayContext.showMarketInfo then
		local marketInfo = GetMarketInfoIfDecor(self.entryVariantID);
		if marketInfo and marketInfo.price then
			local priceText = Blizzard_HousingCatalogUtil.FormatPrice(marketInfo.price);
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_PRICE_FORMAT:format(priceText));
		end

		if marketInfo and #marketInfo.bundleIDs > 0 then
			GameTooltip_AddColoredLine(tooltip, HOUSING_DECOR_BUNDLE_DISCLAIMER, DISCLAIMER_TOOLTIP_COLOR);
		end

		GameTooltip_AddInstructionLine(tooltip, HOUSING_BUNDLE_CLICK_TO_PLACE_DECOR);
	end

	local dyeNames = entryInfo.customizations;
	if dyeNames and #dyeNames > 0 then
		local dyeNamesString = table.concat(dyeNames, ", ");
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_DYE_LIST:format(dyeNamesString));
	end

	if not self:IsBundleItem() then
		local timeStamp = C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(Enum.HousingCatalogEntryType.Decor, self.entryVariantID.recordID);
		if timeStamp then
			GameTooltip_AddNormalLine(tooltip, Blizzard_HousingCatalogUtil.FormatRefundTime(timeStamp));
			GameTooltip_AddInstructionLine(tooltip, HOUSING_DECOR_REFUND_RIGHT_CLICK_INSTRUCTION);
		end
	end
end

function HousingCatalogDecorEntryMixin:AddTooltipTrackingLines(tooltip)
	if not self:GetDisplayContext().showTrackingOptions then
		return;
	end

	if not ContentTrackingUtil.IsContentTrackingEnabled() then
		GameTooltip_AddColoredLine(tooltip, CONTENT_TRACKING_DISABLED_TOOLTIP_PROMPT, GRAY_FONT_COLOR);
		return;
	end

	if C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, self.entryVariantID.recordID) then
		if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, self.entryVariantID.recordID) then
			GameTooltip_AddColoredLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT, GREEN_FONT_COLOR);
		else
			GameTooltip_AddInstructionLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_TRACKABLE_TOOLTIP_PROMPT, GREEN_FONT_COLOR);
		end
	else
		GameTooltip_AddDisabledLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_UNTRACKABLE_TOOLTIP_PROMPT, GRAY_FONT_COLOR);
	end
end

function HousingCatalogDecorEntryMixin:UpdateTypeSpecificVisuals()
	local displayContext = self:GetDisplayContext();

	local anyDyes = false;
	if not displayContext.showMarketInfo then
		local dyeSlots = self.variantInfo and self.variantInfo.dyeSlots or {};
		anyDyes = self.DyeDisplay:UpdateDyeSlots(dyeSlots);
	else
		self.DyeDisplay:SetNumDyeIconsShown(0);
	end

	-- Make sure to hide the customizable icon for already-dyed decor
	self.CustomizeIcon:SetShown(not anyDyes and self.entryInfo.canCustomize);
end


StaticPopupDialogs["HOUSING_MAX_DECOR_REACHED"] = {
	text = ERR_PLACED_DECOR_LIMIT_REACHED,
	button1 = OKAY,
	button2 = nil
};

function HousingCatalogDecorEntryMixin:TypeSpecificOnInteract(button, isDrag)
	if not C_HouseEditor.IsHouseEditorActive() then
		return;
	end

	if not self:HasValidData() or (not C_HousingDecor.IsPreviewState() and Blizzard_HousingCatalogUtil.GetEntryNumStored(self.entryInfo) <= 0) then
		return;
	end

	if self:IsBundleItem() then
		local numPlaced = self:GetNumDecorPlaced();
		if numPlaced >= self.bundleItemInfo.quantity then
			return;
		end
	end

	local decorPlaced = C_HousingDecor.GetSpentPlacementBudget();
	local maxDecor = C_HousingDecor.GetMaxPlacementBudget();
	local hasMaxDecor = C_HousingDecor.HasMaxPlacementBudget();

	if hasMaxDecor and decorPlaced >= maxDecor then
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

	local StartPlacing;
	if C_HousingDecor.IsPreviewState() then
		local bundleCatalogShopProductID = self.bundleItemInfo and self.bundleItemInfo.bundleCatalogShopProductID or nil;
		StartPlacing = function()
			local decorID = self:IsBundleItem() and self.bundleItemInfo.decorID or self.entryVariantID.recordID;
			C_HousingBasicMode.StartPlacingPreviewDecor(decorID, bundleCatalogShopProductID);
		end;
	else
		-- Bundle entries should all be in the market view and can't be previewed otherwise.
		if self:IsBundleItem() then
			return;
		end

		StartPlacing = function() C_HousingBasicMode.StartPlacingNewDecor(self.entryVariantID); end
	end

	-- Sound will be played by HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED event handler
	-- which properly handles preview vs non-preview sounds

	if not C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.BasicDecor) then
		C_HouseEditor.ActivateHouseEditorMode(Enum.HouseEditorMode.BasicDecor);

		RunNextFrame(function()
			StartPlacing();
		end);
		return;
	end

	local activeHouseEditorMode = C_HouseEditor.GetActiveHouseEditorMode();
	local activeEditorModeFrame = HouseEditorFrame and HouseEditorFrame:GetActiveModeFrame();
	if activeHouseEditorMode == Enum.HouseEditorMode.BasicDecor and activeEditorModeFrame then
		-- if user dragged icon from the house chest, then add decor on mouse up.
		-- otherwise, user clicked on house chest icon; don't add decor until next click.
		activeEditorModeFrame.commitNewDecorOnMouseUp = isDrag;
		--dragging functionality for placing preview Decor
		activeEditorModeFrame.draggingPreviewDecor = C_HousingDecor.IsPreviewState() and isDrag;
		-- HOUSING_TODO: We should add some kind of out error to these kinds of APIs so we can display any failure reasons
		StartPlacing();
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
	C_HousingCatalog.DestroyEntry(self.entryVariantID, destroyAll)
end

function HousingCatalogDecorEntryMixin:ShowContextMenu()
	-- If any other catalog entry type is added that needs a context menu we can move all this to be shared
	-- with some kind of conditional flag - for now, it's only for decor

	-- For now there's no context menu for bundle children
	if self:IsBundleItem() then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_CATALOG_ENTRY");
		local displayContext = self:GetDisplayContext();

		local timeStamp = C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(Enum.HousingCatalogEntryType.Decor, self.entryVariantID.recordID);
		if timeStamp then
			rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_REFUND, function()
				CatalogShopRefundFlowInboundInterface.SetShown(true);
			end);
		end

		if displayContext.showMarketInfo then
			local marketInfo = GetMarketInfoIfDecor(self.entryVariantID);
			if marketInfo then
				rootDescription:CreateButton(HOUSING_MARKET_ADD_TO_CART, function()
					local elementData = {
						isBundleParent = false,
						isBundleChild = false,

						id = self.entryInfo.itemID,
						name = self.entryInfo.name,
						decorID = self.entryVariantID.recordID,
						icon = self.entryInfo.iconTexture,
						productID = marketInfo.productID;
						price = marketInfo.originalPrice or marketInfo.price,
						salePrice = marketInfo.originalPrice and marketInfo.price or nil,
					};

					EventRegistry:TriggerEvent(string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartDataServices.AddToCart), elementData);
				end);

				if marketInfo.productID then
					rootDescription:CreateButton(HOUSING_MARKET_VIEW_IN_SHOP, function()
						Blizzard_HousingCatalogUtil.OpenCatalogShopForProduct(marketInfo.productID);
					end);
				end
			end
		elseif displayContext.showDestroyOptions then
			local destroySingleButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY, function()
				local popupData = {
					destroyAll = false,
					owner = self,
					confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
				};
				local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING);
				StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData);
			end);

			local showDisabledTooltip = function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY);
			end

			destroySingleButtonDesc:SetEnabled(self.entryInfo.destroyableInstanceCount > 0);

			if self.entryInfo.destroyableInstanceCount <= 0 then
				destroySingleButtonDesc:SetTooltip(showDisabledTooltip);
			end

			-- The bulk destroy amount should be driven from a PlayerHousingConstants.tag update in 12.0.7
			local bulkDestroyAmount = 5
			local canDestroyMultiple = self.entryInfo.destroyableInstanceCount >= bulkDestroyAmount
			if canDestroyMultiple then
				local destroyAllButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY .. " (" .. bulkDestroyAmount .. ")", function()
					local popupData = {
						destroyAll = true,
						owner = self,
						confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
					};
					local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY_ALL, bulkDestroyAmount, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING);
					StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData);
				end);
				destroyAllButtonDesc:SetEnabled(canDestroyMultiple);
				if not canDestroyMultiple then
					destroyAllButtonDesc:SetTooltip(showDisabledTooltip);
				end
			end
		end
	end);
end

HousingCatalogRoomEntryMixin = {};

local RoomEntryWhileInitializedEvents = {
	"HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
};

local RoomEntryWhileShownEvents = {
	"HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
	"HOUSING_LAYOUT_DOOR_SELECTED",
	"HOUSING_LAYOUT_DOOR_SELECTION_CHANGED",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSE_LEVEL_CHANGED"
};

function HousingCatalogRoomEntryMixin:TypeSpecificOnLoad()
	self.whileInitializedEvents = RoomEntryWhileInitializedEvents;
	self.whileShownEvents = RoomEntryWhileShownEvents;
end

function HousingCatalogRoomEntryMixin:OnEvent(event, ...)
	if event == "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED" then
		local anySelected, roomID = ...;
		self:SetSelected(anySelected and roomID == self.entryVariantID.recordID);
	elseif event == "HOUSING_LAYOUT_DOOR_SELECTED" or event == "HOUSING_LAYOUT_DOOR_SELECTION_CHANGED" 
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" or event == "HOUSING_LAYOUT_ROOM_REMOVED" or event == "HOUSE_LEVEL_CHANGED" then
		self:UpdateVisuals();
	end
end

function HousingCatalogRoomEntryMixin:GetTypeSpecificIsValid()
	local isValid, invalidTooltip, invalidError = true, nil, nil;

	local isAtBudgetMax = C_HousingLayout.HasRoomPlacementBudget() and C_HousingLayout.GetSpentPlacementBudget() >= C_HousingLayout.GetRoomPlacementBudget();
	if isAtBudgetMax then
		isValid = false;
		invalidTooltip = ERR_PLACED_ROOM_LIMIT_REACHED;
	end

	local doorComponentID, roomGUID = C_HousingLayout.GetSelectedDoor();
	if isValid and doorComponentID and roomGUID then
		isValid = C_HousingLayout.HasValidConnection(roomGUID, doorComponentID, self.entryVariantID.recordID);
		if not isValid then
			invalidTooltip = HOUSING_LAYOUT_CANT_PLACE_ROOM_TOOLTIP;
		end
	end

	return isValid, invalidTooltip, invalidError;
end

function HousingCatalogRoomEntryMixin:HasValidData()
	-- Overrides HousingCatalogEntryMixin.

	-- For now, we don't support bundleItemInfo-based room entries.
	return self.elementData and self.entryInfo;
end

function HousingCatalogRoomEntryMixin:UpdateTypeSpecificVisuals()
	self.SpecialRoomFrame:SetShown(self.entryInfo.isPrefab);
	self.SpecialRoomIcon:SetShown(self.entryInfo.isPrefab);
end

function HousingCatalogRoomEntryMixin:UpdateTypeSpecificData()
	if not self:HasValidData() then
		return;
	end
	local selectedFloorplan = C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.Layout) and C_HousingLayout.GetSelectedFloorplan() or nil;
	local isSelected = selectedFloorplan == self.entryVariantID.recordID;

	if isSelected ~= self.isSelected then
		self:SetSelected(isSelected);
	end
end

function HousingCatalogRoomEntryMixin:SetSelected(isSelected)
	self.isSelected = isSelected;
	local isPressed = false;
	self:UpdateBackground(isPressed);
end

function HousingCatalogRoomEntryMixin:AddTooltipTitle(tooltip)
	local placementCost = HOUSING_ROOM_PLACEMENT_COST_FORMAT:format(self.entryInfo.placementCost);
	local itemQualityColor = ColorManager.GetColorDataForItemQuality(self.entryInfo.quality or Enum.ItemQuality.Common).color;
	local wrap = false;
	GameTooltip_AddColoredDoubleLine(tooltip, self.entryInfo.name, placementCost, itemQualityColor, HIGHLIGHT_FONT_COLOR, wrap);
end

function HousingCatalogRoomEntryMixin:AddTooltipLines(tooltip)
	if self.entryInfo.isPrefab then
		GameTooltip_AddHighlightLine(tooltip, HOUSING_LAYOUT_PREFAB_ROOM_TOOLTIP);
	end

	self:AddInvalidTooltipLine(tooltip);
end

function HousingCatalogRoomEntryMixin:TypeSpecificOnInteract(button, isDrag)
	if not C_HouseEditor.IsHouseEditorActive() then
		return;
	end

	if isDrag then
		local isPressed = false;
		self:UpdateBackground(isPressed);
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

	local roomID = self.entryVariantID.recordID;

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
