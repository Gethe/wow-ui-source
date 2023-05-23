
local SERVER_TIMEOUT = 20;

PerksProgramMixin = {};
function PerksProgramMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_DATA_REFRESH");
	self:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_REFUND_SUCCESS");
	EventRegistry:RegisterCallback("PerksProgram.ServerPurchaseCountdownExpired", self.OnServerPurchaseCountdownExpired, self);
	EventRegistry:RegisterCallback("PerksProgram.ServerRefundCountdownExpired", self.OnServerRefundCountdownExpired, self);

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

function PerksProgramMixin:SetSortField(sortField)
	if self.sortField == sortField then
		self:SetSortAscending(not self:GetSortAscending());
	else
		self:SetSortAscending(true);
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
	return self.ProductsFrame:GetSelectedProducts();
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
	self.modelFadeInTimer = C_Timer.NewTimer(1.0, GenerateClosure(self.FadeInModelScene, self));
	self:SetHideArmorSetting(nil);
	C_PerksProgram.RequestPendingChestRewards();

	StaticPopup_SetFullScreenFrame(self);
	AlertFrame:SetFullScreenFrame(self, "HIGH");
	AlertFrame:SetBaseAnchorFrame(self.FooterFrame.RotateButtonContainer);
	ActionStatus:SetAlternateParentFrame(self);

	EventRegistry:TriggerEvent("PerksProgramFrame.OnShow");
	PlaySound(SOUNDKIT.TRADING_POST_UI_MENU_OPEN);
end

function PerksProgramMixin:OnHide()

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

	PlaySound(SOUNDKIT.TRADING_POST_UI_MENU_CLOSE);
end

function PerksProgramMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_DATA_REFRESH" then
		self.vendorItemIDs = C_PerksProgram.GetAvailableVendorItemIDs();
		EventRegistry:TriggerEvent("PerksProgram.AllDataRefresh");
	elseif event =="PERKS_PROGRAM_PURCHASE_SUCCESS" then
		PlaySound(SOUNDKIT.TRADING_POST_UI_PURCHASE_CELEBRATION);
		if self.purchaseStateTimer then
			self.purchaseStateTimer:Cancel();
		end
	elseif event == "PERKS_PROGRAM_REFUND_SUCCESS" then
		PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_REFUND);
		if self.purchaseStateTimer then
			self.purchaseStateTimer:Cancel();
		end
	elseif event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";
		if isRightButton and StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM") then
			StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM");
			PerksProgramFrame:ResetDragAndDrop();
		end
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
	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(product.itemID);
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

function PerksProgramMixin:OnServerPurchaseCountdownExpired()
	StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_PURCHASE");
	StaticPopup_Show("PERKS_PROGRAM_SERVER_ERROR");
end

function PerksProgramMixin:Purchase(data)
	C_PerksProgram.RequestPurchase(data.product.perksVendorItemID);
	if self.purchaseStateTimer then
		self.purchaseStateTimer:Cancel();
	end
	self.purchaseStateTimer = C_Timer.NewTimer(SERVER_TIMEOUT, function() EventRegistry:TriggerEvent("PerksProgram.ServerPurchaseCountdownExpired"); end);
end

function PerksProgramMixin:ConfirmRefund()
	local product = self:GetSelectedProduct();

	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(product.itemID);
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

function PerksProgramMixin:OnServerRefundCountdownExpired()
	StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_REFUND");
	StaticPopup_Show("PERKS_PROGRAM_SERVER_ERROR");
end

function PerksProgramMixin:Refund(data)
	C_PerksProgram.RequestRefund(data.product.perksVendorItemID);
	if self.purchaseStateTimer then
		self.purchaseStateTimer:Cancel();
	end
	self.purchaseStateTimer = C_Timer.NewTimer(SERVER_TIMEOUT, function() EventRegistry:TriggerEvent("PerksProgram.ServerRefundCountdownExpired"); end);
end

function PerksProgramMixin:GetFrozenItemData()
	local data;
	local frozenVendorItem = C_PerksProgram.GetFrozenPerksVendorItemInfo();
	if frozenVendorItem and frozenVendorItem.itemID then
		local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(frozenVendorItem.itemID);
		data = {};
		data.product = frozenVendorItem;
		data.link = itemLink;
		data.name = frozenVendorItem.name;
		data.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
		data.tooltip = PerksProgramTooltip;
		data.texture = itemTexture;
	end
	return data;
end

function PerksProgramMixin:ClearFrozenItem()
	C_PerksProgram.ClearFrozenPerksVendorItem();
	PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_UNLOCKING);
end

function PerksProgramMixin:ConfirmOverrideFrozenItem()
	local data = self:GetFrozenItemData();
	if data then
		StaticPopup_Show("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM", nil, nil, data);
		self:RegisterEvent("GLOBAL_MOUSE_DOWN");		
	else
		self:GetFrozenItemFrame():TriggerFreezeItem();
		C_PerksProgram.SetFrozenPerksVendorItem();
		PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_LOCKING);
	end
end

function PerksProgramMixin:OverrideFrozenItem()
	self:GetFrozenItemFrame():TriggerFreezeItem();
	C_PerksProgram.SetFrozenPerksVendorItem();
	PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_LOCKING);
end

function PerksProgramMixin:ResetDragAndDrop()
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
	local frozenItemFrame = self:GetFrozenItemFrame();
	frozenItemFrame.FrozenButton:TriggerCancelFrozenItem();

	local frozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();
	frozenItemFrame:SetupFrozenVendorItem(frozenVendorItemInfo);
	C_PerksProgram.ResetHeldItemDragAndDrop();
end

function PerksProgramMixin:GetFrozenItemFrame()
	return self.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenItemFrame;
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