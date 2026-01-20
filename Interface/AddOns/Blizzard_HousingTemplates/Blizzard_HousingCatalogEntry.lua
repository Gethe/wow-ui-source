local ModelSceneID = 691;
local ActorTag = "decor";
local QuestionMarkIconFileDataID = 134400;
local ContentTrackingAtlasMarkup = CreateAtlasMarkup("waypoint-mappin-minimap-untracked", 16, 16, -3, 0);

HousingCatalogEntryMixin = {};

function HousingCatalogEntryMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(ModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	self:TypeSpecificOnLoad();
end

function HousingCatalogEntryMixin:Init(elementData)
	self.elementData = elementData;
	self.entryID = elementData.entryID;
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
	self.entryID = nil;
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
	return self.entryID and C_HousingCatalog.GetCatalogEntryInfo(self.entryID) or nil;
end

function HousingCatalogEntryMixin:UpdateEntryData(forceUpdate)
	local isValidBundleItem = self:IsBundleItem() and self.bundleItemInfo and self.bundleItemInfo.decorID;
	if not self.elementData or (not self.entryID and not isValidBundleItem) then
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

	local anyDyes = false;
	for i, dyeID in ipairs(self.entryInfo.dyeIDs) do
		local icon = self.dyeIcons[i];
		if dyeID > 0 then
			local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeID);
			if dyeColorInfo then
				icon:SetVertexColor(dyeColorInfo.swatchColorStart:GetRGB());
			end
			icon:SetAtlas("dye-drop_32");
			anyDyes = true;
		else
			icon:SetVertexColor(1,1,1);
			icon:SetAtlas("dye-drop-no-dye_32")
		end
	end

	self.CustomizeIcon:SetShown(not anyDyes and self.entryInfo.canCustomize);
	for i, icon in ipairs(self.dyeIcons) do
		icon:SetShown(anyDyes and i <= #self.entryInfo.dyeIDs);
	end

	self.InfoIcon:Hide();

	self.InfoText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	if self:IsBundleItem() then
		self.InfoText:Show();

		local numPlaced = self:GetNumDecorPlaced();
		local quantity = self.bundleItemInfo.quantity - numPlaced;
		self.InfoText:SetText(quantity);
		if quantity <= 0 then
			self.InfoText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	elseif self:IsInMarketView() then
		local marketInfo = self.entryInfo.marketInfo;
		local price = marketInfo and marketInfo.price or 0;
		self.InfoText:SetText(Blizzard_HousingCatalogUtil.FormatPrice(price));
		self.InfoText:SetShown(price > 0);
	elseif self.entryInfo.isUniqueTrophy then
		-- Right now info icon is only used for the unique trophy icon.
		self.InfoText:Hide();
		self.InfoIcon:Show();
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
	return self.elementData and (self.entryID or self.bundleItemInfo) and self.entryInfo;
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

	if button == "RightButton" then
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

function HousingCatalogEntryMixin:IsInMarketView()
	-- Optional override. Rooms do not have a market view.
	return false;
end

HousingCatalogDecorEntryMixin = CreateFromMixins(HousingCatalogEntryMixin);

function HousingCatalogDecorEntryMixin:GetEntryData()
	-- Overrides HousingCatalogEntryMixin.

	local tryGetOwnedInfo = false;
	return self:IsBundleItem() and C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, self.bundleItemInfo.decorID, tryGetOwnedInfo) or HousingCatalogEntryMixin.GetEntryData(self);
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
	local marketInfo = entryInfo.marketInfo;

	if entryInfo.isUniqueTrophy then
		GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_UNIQUE_TROPHY_TOOLTIP);
	end

	local stored = entryInfo.quantity + entryInfo.remainingRedeemable;
	local total = entryInfo.numPlaced + stored;
	if total ~= 0 then
		GameTooltip_AddNormalLine(tooltip, HOUSING_DECOR_OWNED_COUNT_FORMAT:format(total, entryInfo.numPlaced, stored));
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

	-- We only show market info in the market view.
	elseif self:IsInMarketView() then
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
		local timeStamp = C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(Enum.HousingCatalogEntryType.Decor, self.entryInfo.entryID.recordID);
		if timeStamp then
			GameTooltip_AddNormalLine(tooltip, Blizzard_HousingCatalogUtil.FormatRefundTime(timeStamp));
			GameTooltip_AddInstructionLine(tooltip, HOUSING_DECOR_REFUND_RIGHT_CLICK_INSTRUCTION);
		end
	end
end

function HousingCatalogDecorEntryMixin:AddTooltipTrackingLines(tooltip)
	if self:IsInStorageView() then
		-- No tracking in storage view
		return;
	end

	if not ContentTrackingUtil.IsContentTrackingEnabled() then
		GameTooltip_AddColoredLine(tooltip, CONTENT_TRACKING_DISABLED_TOOLTIP_PROMPT, GRAY_FONT_COLOR);
		return;
	end

	if C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, self.entryInfo.entryID.recordID) then
		if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, self.entryInfo.entryID.recordID) then
			GameTooltip_AddColoredLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT, GREEN_FONT_COLOR);
		else
			GameTooltip_AddInstructionLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_TRACKABLE_TOOLTIP_PROMPT, GREEN_FONT_COLOR);
		end
	else
		GameTooltip_AddDisabledLine(tooltip, ContentTrackingAtlasMarkup..CONTENT_TRACKING_UNTRACKABLE_TOOLTIP_PROMPT, GRAY_FONT_COLOR);
	end
end


StaticPopupDialogs["HOUSING_MAX_DECOR_REACHED"] = {
	text = ERR_PLACED_DECOR_LIMIT_REACHED,
	button1 = OKAY,
	button2 = nil
};

function HousingCatalogDecorEntryMixin:IsInStorageView()
	-- TODO:: Replace this global access hack.
	return HouseEditorFrame and HouseEditorFrame.StoragePanel and DoesAncestryInclude(HouseEditorFrame.StoragePanel, self);
end

function HousingCatalogDecorEntryMixin:IsInMarketView()
	-- Overrides HousingCatalogEntryMixin.

	-- TODO:: Replace this hack. For now I'm not sure how preview placement will work so I'm disabling it.
	local storagePanel = HouseEditorFrame and HouseEditorFrame.StoragePanel or nil;
	if storagePanel and storagePanel:IsVisible() and storagePanel:IsInMarketTab() then
		return true;
	end

	return false;
end

function HousingCatalogDecorEntryMixin:TypeSpecificOnInteract(button, isDrag)
	if not C_HouseEditor.IsHouseEditorActive() then
		return;
	end

	if not self:HasValidData() or (not C_HousingDecor.IsPreviewState() and self.entryInfo.quantity + self.entryInfo.remainingRedeemable <= 0) then
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
			local decorID = self:IsBundleItem() and self.bundleItemInfo.decorID or self.entryID.recordID;
			C_HousingBasicMode.StartPlacingPreviewDecor(decorID, bundleCatalogShopProductID);
		end;
	else
		-- Bundle entries should all be in the market view and can't be previewed otherwise.
		if self:IsBundleItem() then
			return;
		end

		StartPlacing = function() C_HousingBasicMode.StartPlacingNewDecor(self.entryID); end
	end

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
	C_HousingCatalog.DestroyEntry(self.entryID, destroyAll)
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

		local timeStamp = C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(Enum.HousingCatalogEntryType.Decor, self.entryInfo.entryID.recordID);
		if timeStamp then
			rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_REFUND, function()
				if IsPublicBuild() then
					CatalogShopRefundFlowInboundInterface.SetShown(true);

				-- TODO:: Remove this debug code once we're finished implementing the refund flow.
				else
					local debugInfo = C_HousingCatalog.GetCatalogEntryDebugInfoForID(self.entryID);
					local guidToRefund = debugInfo.instanceGUIDs[#debugInfo.instanceGUIDs];
					local guidString = (debugInfo.instanceGUIDs[#debugInfo.instanceGUIDs]):sub(9, #guidToRefund);
					ConsoleExec("refundDecorWithVC " .. guidString);
				end
			end);
		end

		if self:IsInMarketView() then
			if self.entryInfo.marketInfo then
				rootDescription:CreateButton(HOUSING_MARKET_ADD_TO_CART, function()
					local elementData = {
						isBundleParent = false,
						isBundleChild = false,

						id = self.entryInfo.itemID,
						name = self.entryInfo.name,
						decorID = self.entryID.recordID,
						icon = self.entryInfo.iconTexture,
						productID = self.entryInfo.marketInfo.productID;
						price = self.entryInfo.marketInfo.originalPrice or self.entryInfo.marketInfo.price,
						salePrice = self.entryInfo.marketInfo.originalPrice and self.entryInfo.marketInfo.price or nil,
					};

					EventRegistry:TriggerEvent(string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartDataServices.AddToCart), elementData);
				end);

				if self.entryInfo.marketInfo.productID then
					rootDescription:CreateButton(HOUSING_MARKET_VIEW_IN_SHOP, function()
						Blizzard_HousingCatalogUtil.OpenCatalogShopForProduct(self.entryInfo.marketInfo.productID);
					end);
				end
			end
		elseif self:IsInStorageView() then
			local destroySingleButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY, function()
				local popupData = {
					destroyAll = false,
					owner = self,
					confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
				};
				local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING);
				StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData);
			end);

			local canDestroyEntry = C_HousingCatalog.CanDestroyEntry(self.entryID);
			
			local showDisabledTooltip = function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY);
			end

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
		self:SetSelected(anySelected and roomID == self.entryID.recordID);
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
		isValid = C_HousingLayout.HasValidConnection(roomGUID, doorComponentID, self.entryID.recordID);
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
