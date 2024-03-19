
PerksProgramMixin = {};
function PerksProgramMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_DATA_REFRESH");
	self:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_REFUND_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_RESULT_ERROR");
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationShown", self.OnFrozenItemConfirmationShown, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationHidden", self.OnFrozenItemConfirmationHidden, self);

	self.activeFilters = {};
	self.vendorItemIDs = C_PerksProgram.GetAvailableVendorItemIDs();
	self.categoryIDs = C_PerksProgram.GetAvailableCategoryIDs();
	self.categories = {};
	for i, categoryID in ipairs(self.categoryIDs) do
		self.categories[i] = C_PerksProgram.GetCategoryInfo(categoryID);
		self.activeFilters[categoryID] = true;
	end
	self.activeFilters["collected"] = true;
	self.activeFilters["uncollected"] = true;
	self.activeFilters["useable"] = false;
	self:SetLabelFont(GameFontNormalMed3);

	local useNativeForm = true;
	self:SetUseNativeForm(useNativeForm);

	local hidePlayerForPreview = false;
	self.hidePlayerForPreview = hidePlayerForPreview;

	self:SetHideArmorSetting(nil);

	self.sortAscending = false;
	self.sortField = "price";

	self.ProductsFrame:Init();
	self.ModelSceneContainerFrame:Init();
	self.FooterFrame:Init();
end

function PerksProgramMixin:GetLabelFont()
	return self.labelFont or GameFontNormalMed3;
end

function PerksProgramMixin:SetLabelFont(font)
	self.labelFont = font;
end

function PerksProgramMixin:GetDefaultSortAscending(sortField)
	if sortField == "timeRemaining" then
		return true;
	elseif sortField == "price" then
		return false;
	elseif sortField == "name" then
		return true;
	end
	return false;
end

function PerksProgramMixin:SetSortField(sortField)
	if self.sortField == sortField then
		self:SetSortAscending(not self:GetSortAscending());
	else
		-- If we are setting the sort field to something new, then default SortAscending to whatever that field prefers
		local sortAscending = self:GetDefaultSortAscending(sortField);
		self:SetSortAscending(sortAscending);
	end
	self.sortField = sortField;
	EventRegistry:TriggerEvent("PerksProgram.SortFieldSet");
end

function PerksProgramMixin:GetSortField()
	return self.sortField or "name";
end

function PerksProgramMixin:SetSortAscending(ascending)
	self.sortAscending = ascending;
end

function PerksProgramMixin:GetSortAscending()
	return self.sortAscending;
end

function PerksProgramMixin:GetTogglePlayerSetting()
	return self.hidePlayerForPreview;
end

function PerksProgramMixin:TogglePlayerPreviewOnClick(hidePlayerForPreview)
	self.hidePlayerForPreview = hidePlayerForPreview;
	EventRegistry:TriggerEvent("PerksProgram.OnPlayerPreviewToggled");
end

function PerksProgramMixin:SetHideArmorSetting(playerArmorSetting)
	self.hidePlayerArmorSetting = playerArmorSetting;
end

function PerksProgramMixin:GetHideArmorSetting()
	return self.hidePlayerArmorSetting;
end

-- Function when actually clicking the button, which should have sound.
function PerksProgramMixin:PlayerToggledHideArmorOnClick(hidePlayerArmor)
	if self:GetHideArmorSetting() ~= hidePlayerArmor then
		if hidePlayerArmor then
			PlaySound(SOUNDKIT.TRADING_POST_UI_HIDE_ARMOR);
		else
			PlaySound(SOUNDKIT.TRADING_POST_UI_SHOW_ARMOR);
		end
		self:ToggleHideArmorSetting(hidePlayerArmor);
	end
end

function PerksProgramMixin:ToggleHideArmorSetting(playerArmorSetting)
	if self:GetHideArmorSetting() ~= playerArmorSetting then
		self:SetHideArmorSetting(playerArmorSetting);
		EventRegistry:TriggerEvent("PerksProgram.OnPlayerHideArmorToggled");
	end
end

function PerksProgramMixin:GetUseNativeForm()
	return self.UseNativeForm;
end

function PerksProgramMixin:SetUseNativeForm(useNativeForm)
	self.UseNativeForm = useNativeForm;
end

function PerksProgramMixin:SetFilterState(categoryID, value)
	self.activeFilters[categoryID] = value;
	EventRegistry:TriggerEvent("PerksProgram.OnFilterChanged");
end

function PerksProgramMixin:GetFilterState(categoryID)
	return self.activeFilters[categoryID];
end

function PerksProgramMixin:GetCategories()
	return self.categories;
end

function PerksProgramMixin:GetSelectedProduct()
	return self.ProductsFrame:GetSelectedProduct();
end

function PerksProgramMixin:SelectNextProduct()
	return self.ProductsFrame:SelectNextProduct();
end

function PerksProgramMixin:SelectPreviousProduct()
	return self.ProductsFrame:SelectPreviousProduct();
end

function PerksProgramMixin:GetDefaultModelSceneID(categoryID)
	for i, category in ipairs(self.categories) do
		if category.ID == categoryID then
			return category.defaultUIModelSceneID;
		end
	end
	return nil;
end

function PerksProgramMixin:FadeInModelScene()
	if self.fadeInModelUpdater then
		self.fadeInModelUpdater:Cancel();
	end

	local data = {object = PerksProgramFrame.ModelSceneContainerFrame, alphaStart = 0.0, alphaEnd = 1.0};
	local function Update(data)
		local alphaGain = Lerp(data.alphaStart, data.alphaEnd, 0.1);
		data.object:SetAlpha(Clamp(data.object:GetAlpha() + alphaGain, 0, 1));
	end
	local function IsComplete(data)
		if math.abs(data.object:GetAlpha() - data.alphaEnd) < 0.01 then
			data.object:SetAlpha(data.alphaEnd);
			return true;
		end
		return false;
	end
	local function Finish(data)
		self.fadeInModelUpdater = nil; 
	end
	self.fadeInModelUpdater = CreateObjectUpdater(data, Update, IsComplete, Finish);
end

function PerksProgramMixin:OnShow()
	self:RegisterEvent("Perks_Program_CLOSE");

	local hasErrorOccurred = false;
	self:SetServerErrorState(hasErrorOccurred);

	self.modelFadeInTimer = C_Timer.NewTimer(1.0, GenerateClosure(self.FadeInModelScene, self));
	self:SetHideArmorSetting(nil);
	C_PerksProgram.RequestPendingChestRewards();

	StaticPopup_SetFullScreenFrame(self);
	AlertFrame:SetFullScreenFrame(self, "HIGH");
	AlertFrame:SetBaseAnchorFrame(self.FooterFrame.RotateButtonContainer);
	ActionStatus:SetAlternateParentFrame(self);

	self:RegisterEvent("CURSOR_CHANGED");
	EventRegistry:TriggerEvent("PerksProgramFrame.OnShow");
	PlaySound(SOUNDKIT.TRADING_POST_UI_MENU_OPEN);

	AlertFrame:BlockLeftClickingAlerts(self);
end

function PerksProgramMixin:OnHide()
	self:UnregisterEvent("Perks_Program_CLOSE");

	StaticPopup_ClearFullScreenFrame();
	AlertFrame:ClearFullScreenFrame();
	AlertFrame:ResetBaseAnchorFrame();
	ActionStatus:ClearAlternateParentFrame();

	if self.modelFadeInTimer then
		self.modelFadeInTimer:Cancel();
		self.modelFadeInTimer = nil;
	end
	self.ModelSceneContainerFrame:SetAlpha(0);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.PerksProgramVendor);
	EventRegistry:TriggerEvent("PerksProgramFrame.OnHide");

	local scrollContainer = self.ProductsFrame.ProductsScrollBoxContainer;
	scrollContainer.selectionBehavior:ClearSelections();

	self:UnregisterEvent("CURSOR_CHANGED");
	PlaySound(SOUNDKIT.TRADING_POST_UI_MENU_CLOSE);

	AlertFrame:UnblockLeftClickingAlerts(self);

	self:CancelPurchaseTimer();
	self:CancelRefundTimer();
end

function PerksProgramMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_DATA_REFRESH" then
		self.vendorItemIDs = C_PerksProgram.GetAvailableVendorItemIDs();
		EventRegistry:TriggerEvent("PerksProgram.AllDataRefresh");
	elseif event =="PERKS_PROGRAM_PURCHASE_SUCCESS" then
		PlaySound(SOUNDKIT.TRADING_POST_UI_PURCHASE_CELEBRATION);
		self:CancelPurchaseTimer();
	elseif event == "PERKS_PROGRAM_REFUND_SUCCESS" then
		PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_REFUND);
		self:CancelRefundTimer();
	elseif event == "PERKS_PROGRAM_RESULT_ERROR" then
		local hasErrorOccurred = true;
		self:SetServerErrorState(hasErrorOccurred);
	elseif event == "GLOBAL_MOUSE_DOWN" then		
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";
		if isRightButton and StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM") then
			EventRegistry:TriggerEvent("PerksProgram.CancelFrozenItemConfirmation");
		end
	elseif event == "CURSOR_CHANGED" then
		local isDefault = ...;
		if isDefault and not StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM") then
			C_PerksProgram.ResetHeldItemDragAndDrop();
		end
	elseif event == "PERKS_PROGRAM_CLOSE" then
		self:Leave();
	end
end

function PerksProgramMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Leave();
	elseif key == "DOWN" then
		self:SelectNextProduct();
	elseif key == "UP" then
		self:SelectPreviousProduct();
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end
end

function PerksProgramMixin:Leave()
	C_PerksProgram.ResetHeldItemDragAndDrop();
	HideUIPanel(self);
end

function PerksProgramMixin:ConfirmPurchase()
	local product = self:GetSelectedProduct();
	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(product.itemID);
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	local markup = CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 16, 16, 0, 1, 0, 1);

	local data = {};
	data.product = product;
	data.link = itemLink;
	data.name = product.name;
	data.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
	data.texture = itemTexture;
	StaticPopup_Show("PERKS_PROGRAM_CONFIRM_PURCHASE", product.price, markup, data);
end

function PerksProgramMixin:CancelPurchaseTimer()
	StaticPopup_Hide("PERKS_PROGRAM_SLOW_PURCHASE");

	if self.purchaseStateTimer then
		self.purchaseStateTimer:Cancel();
	end
end

function PerksProgramMixin:Purchase(data)
	C_PerksProgram.RequestPurchase(data.product.perksVendorItemID);
	self:CancelPurchaseTimer();
	self.purchaseStateTimer = C_Timer.NewTimer(10, function()
		StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_PURCHASE");
		StaticPopup_Show("PERKS_PROGRAM_SLOW_PURCHASE");
	 end);
end

function PerksProgramMixin:ConfirmRefund()
	local product = self:GetSelectedProduct();

	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(product.itemID);
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	local markup = CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 16, 16, 0, 1, 0, 1);
	
	local data = {};
	data.product = product;
	data.link = itemLink;
	data.name = product.name;
	data.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
	data.texture = itemTexture;
	StaticPopup_Show("PERKS_PROGRAM_CONFIRM_REFUND", product.price, markup, data);
end

function PerksProgramMixin:CancelRefundTimer()
	if self.refundStateTimer then
		self.refundStateTimer:Cancel();
	end
end

function PerksProgramMixin:Refund(data)
	C_PerksProgram.RequestRefund(data.product.perksVendorItemID);
	self:CancelRefundTimer();
	self.refundStateTimer = C_Timer.NewTimer(45, function()
		-- If refund takes an excessively long time then just act like a server error happened so we don't lock up the UI
		self:SetServerErrorState(true);
	 end);
end

function PerksProgramMixin:OnFrozenItemConfirmationShown()
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
end

function PerksProgramMixin:OnFrozenItemConfirmationHidden()
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
end

local RED_TEXT_SECONDS_THRESHOLD = 3600;
function PerksProgramMixin:FormatTimeLeft(secondsRemaining, formatter)
	local color = (secondsRemaining > RED_TEXT_SECONDS_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = formatter:Format(secondsRemaining);
	return color:WrapTextInColorCode(text);
end

function PerksProgramMixin:GetCategoryText(categoryID)
	if categoryID == Enum.PerksVendorCategoryType.Transmog then
		return PERKS_VENDOR_CATEGORY_TRANSMOG;
	elseif categoryID == Enum.PerksVendorCategoryType.Mount then
		return PERKS_VENDOR_CATEGORY_MOUNT;
	elseif categoryID == Enum.PerksVendorCategoryType.Pet then
		return PERKS_VENDOR_CATEGORY_PET;
	elseif categoryID == Enum.PerksVendorCategoryType.Toy then
		return PERKS_VENDOR_CATEGORY_TOY;
	elseif categoryID == Enum.PerksVendorCategoryType.Illusion then
		return PERKS_VENDOR_CATEGORY_ILLUSION;
	elseif categoryID == Enum.PerksVendorCategoryType.Transmogset then
		return PERKS_VENDOR_CATEGORY_TRANSMOG_SET;
	end
	return "";
end

function PerksProgramMixin:GetCurrencyIconMarkup()
	if not self.currencyIconMarkup then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
		self.currencyIconMarkup = CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 20, 20, 0, 1, 0, 1, 0, 0);
	end

	return self.currencyIconMarkup;
end

local function BuildPerksVendorItemInfo(itemInfo)
	if itemInfo then
		itemInfo.isItemInfo = true;
		local perksVendorCategoryID = itemInfo.perksVendorCategoryID;
		local displayInfo = C_PerksProgram.GetPerksProgramItemDisplayInfo(itemInfo.perksVendorItemID);
		displayInfo.defaultModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(perksVendorCategoryID);
		itemInfo.displayData = PerksProgram_TranslateDisplayInfo(perksVendorCategoryID, displayInfo);
		if perksVendorCategoryID == Enum.PerksVendorCategoryType.Mount then
			itemInfo.creatureDisplays = C_MountJournal.GetAllCreatureDisplayIDsForMountID(itemInfo.mountID);
		end
	end

	return itemInfo
end

-- Use this instead of getting item info directly from C_PerksProgram since it adds extra data to the ItemInfo
function PerksProgramMixin:GetVendorItemInfo(perksVendorItemID)
	if C_PerksProgram.IsFrozenPerksVendorItem(perksVendorItemID) then
		return self:GetFrozenPerksVendorItemInfo();
	end

	local itemInfo = C_PerksProgram.GetVendorItemInfo(perksVendorItemID)
	return BuildPerksVendorItemInfo(itemInfo);
end

-- Use this instead of getting item info directly from C_PerksProgram since it adds extra data to the ItemInfo
function PerksProgramMixin:GetFrozenPerksVendorItemInfo()
	local itemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo()
	if itemInfo then
		itemInfo.isFrozen = true;
	end
	return BuildPerksVendorItemInfo(itemInfo);
end

function PerksProgramMixin:HasFrozenItem()
	return C_PerksProgram.GetFrozenPerksVendorItemInfo() ~= nil;
end

function PerksProgramMixin:SetServerErrorState(hasErrorOccurred)
	self.hasServerErrorOccurred = hasErrorOccurred;
	EventRegistry:TriggerEvent("PerksProgram.OnServerErrorStateChanged");

	-- If we had any confirmation static popup open then close the popup and show the error dialog
	if self.hasServerErrorOccurred then
		if StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_PURCHASE") then
			StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_PURCHASE");
			self:ShowServerErrorDialog();
		elseif StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_REFUND") then
			StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_REFUND");
			self:ShowServerErrorDialog();
		elseif StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM") then
			EventRegistry:TriggerEvent("PerksProgram.CancelFrozenItemConfirmation");
			self:ShowServerErrorDialog();
		end
	end
end

function PerksProgramMixin:GetServerErrorState()
	return self.hasServerErrorOccurred;
end

function PerksProgramMixin:ShowServerErrorDialog()
	StaticPopup_Show("PERKS_PROGRAM_SERVER_ERROR");
end

----------------------------------------------------------------------------------
-- TimeLeftListFormatter
----------------------------------------------------------------------------------
PerksProgramMixin.TimeLeftListFormatter = CreateFromMixins(SecondsFormatterMixin);
PerksProgramMixin.TimeLeftListFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, true);
PerksProgramMixin.TimeLeftListFormatter:SetStripIntervalWhitespace(true);
function PerksProgramMixin.TimeLeftListFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

function PerksProgramMixin.TimeLeftListFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

----------------------------------------------------------------------------------
-- TimeLeftDetailsFormatter
----------------------------------------------------------------------------------
PerksProgramMixin.TimeLeftDetailsFormatter = CreateFromMixins(SecondsFormatterMixin);
PerksProgramMixin.TimeLeftDetailsFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, false, true);
function PerksProgramMixin.TimeLeftDetailsFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

----------------------------------------------------------------------------------
-- TimeLeftFooterFormatter
----------------------------------------------------------------------------------
PerksProgramMixin.TimeLeftFooterFormatter = CreateFromMixins(SecondsFormatterMixin);
PerksProgramMixin.TimeLeftFooterFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, true);
PerksProgramMixin.TimeLeftFooterFormatter:SetStripIntervalWhitespace(true);
function PerksProgramMixin.TimeLeftFooterFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

function PerksProgramMixin.TimeLeftFooterFormatter:GetDesiredUnitCount(seconds)
	return 2;
end

----------------------------------------------------------------------------------
-- Theme Container
----------------------------------------------------------------------------------
PerksProgramThemeContainerMixin = {};

function PerksProgramThemeContainerMixin:OnLoad()
	local function PositionFrame(frame, point, relativeTo, relativePoint, offsetX, offsetY)
		frame:ClearAllPoints();
		frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
	end

	local productListBorder = PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.Border;
	PositionFrame(self.ProductList.Top, "BOTTOM", productListBorder, "TOP", 0, -51);
	PositionFrame(self.ProductList.Bottom, "TOP", productListBorder, "BOTTOM", 0, 118);
	PositionFrame(self.ProductList.Left, "RIGHT", productListBorder, "LEFT", 10, 2);
	PositionFrame(self.ProductList.Right, "LEFT", productListBorder, "RIGHT", -10, 2);

	local productDetailsBorder = PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.Border;
	PositionFrame(self.ProductDetails.Top, "BOTTOM", productDetailsBorder, "TOP", 0, -43);
	PositionFrame(self.ProductDetails.Bottom, "TOP", productDetailsBorder, "BOTTOM", 0, 33);
	PositionFrame(self.ProductDetails.Left, "TOPRIGHT", productDetailsBorder, "TOPLEFT", 10, 90);
	PositionFrame(self.ProductDetails.Right, "TOPLEFT", productDetailsBorder, "TOPRIGHT", -10, 90);
end

function PerksProgramThemeContainerMixin:OnShow()
	local theme = C_PerksActivities.GetPerksUIThemePrefix();
	local atlasPrefix = "perks-theme-"..theme.."-tp-";

	local function SetAtlas(texture, atlasSuffix)
		local atlasName = atlasPrefix..atlasSuffix;
		if not C_Texture.GetAtlasInfo(atlasName) then
			texture:SetTexture(nil);
			return;
		end

		texture:SetAtlas(atlasName, true);
	end

	SetAtlas(self.ProductList.Top, "topbig");
	SetAtlas(self.ProductList.Bottom, "bottombig");
	SetAtlas(self.ProductList.Left, "leftbig");
	SetAtlas(self.ProductList.Right, "rightbig");

	SetAtlas(self.ProductDetails.Top, "topsmall");
	SetAtlas(self.ProductDetails.Bottom, "bottomsmall");
	SetAtlas(self.ProductDetails.Left, "leftsmall");
	SetAtlas(self.ProductDetails.Right, "rightsmall");
end
