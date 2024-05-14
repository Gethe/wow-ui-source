UIPanelWindows["CurrencyTransferMenu"] = { area = "left", pushable = 2, whileDead = 0, checkFit = 1, allowOtherPanels = 1, };

CurrencyTransferSystemMixin = {};

function CurrencyTransferSystemMixin:GetCurrencyTransferMenu()
	return CurrencyTransferMenu;
end

CurrencyTransferToggleButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

local CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
};

local DISABLED_ERROR_MESSAGE = {
	[Enum.AccountCurrencyTransferResult.MaxQuantity] = CURRENCY_TRANSFER_DISABLED_MAX_QUANTITY,
	[Enum.AccountCurrencyTransferResult.NoValidSourceCharacter] = CURRENCY_TRANSFER_DISABLED_NO_VALID_SOURCES,
};

function CurrencyTransferToggleButtonMixin:GetDisabledErrorMessage(failureReason)
	return DISABLED_ERROR_MESSAGE[failureReason];
end

function CurrencyTransferToggleButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS);
	C_CurrencyInfo.RequestCurrencyDataForAccountCharacters();
end

function CurrencyTransferToggleButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS);
end

function CurrencyTransferToggleButtonMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdateEnabledState();
	end
end

function CurrencyTransferToggleButtonMixin:OnClick()
	if not self.currencyID then
		return;
	end

	self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferRequested, self.currencyID);
end

function CurrencyTransferToggleButtonMixin:SetCurrencyID(currencyID)
	self.currencyID = currencyID;
end

function CurrencyTransferToggleButtonMixin:Refresh(currencyData)
	if not currencyData then
		self.currencyID = nil;
		self:SetEnabled(false);
		self:Hide();
		return;
	end

	self:SetCurrencyID(currencyData.currencyID);
	self:UpdateEnabledState();
end

function CurrencyTransferToggleButtonMixin:UpdateEnabledState()
	if not self.currencyID then
		self:SetEnabled(false);
		return;
	end

	local dataReady = C_CurrencyInfo.IsAccountCharacterCurrencyDataReady();

	local canTransfer, failureReason = C_CurrencyInfo.CanTransferCurrency(self.currencyID);
	self:SetEnabled(dataReady and canTransfer);
	self:SetDisabledTooltip(not dataReady and "Data not ready [PH]" or self:GetDisabledErrorMessage(failureReason), "ANCHOR_RIGHT");
	self:SetShown(self:IsEnabled() or self:GetDisabledTooltip() ~= nil);
end

CurrencyTransferMenuMixin = CreateFromMixins(CallbackRegistryMixin);

local CURRENCY_TRANSFER_MENU_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
	"ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
};

CurrencyTransferMenuMixin:GenerateCallbackEvents({
	"CurrencyTransferRequested",
	"CurrencyTransferSourceSelected",
	"CurrencyTransferAmountUpdated",
});

function CurrencyTransferMenuMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddStaticEventMethod(self, CurrencyTransferMenuMixin.Event.CurrencyTransferRequested, self.OnCurrencyTransferRequested);
	self:AddDynamicEventMethod(self, CurrencyTransferMenuMixin.Event.CurrencyTransferSourceSelected, self.OnCurrencyTransferSourceSelected);
	self:AddDynamicEventMethod(self, CurrencyTransferMenuMixin.Event.CurrencyTransferAmountUpdated, self.OnCurrencyTransferAmountUpdated);

	self:InitializeFrameVisuals();
end

function CurrencyTransferMenuMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		local currencyID, quantity, quantityChange, quantityGainSource, quantityLostSource = ...;
		if currencyID and currencyID == self:GetCurrencyID() then
			self:FullRefresh();
		end
	elseif event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED" then
		self:FullRefresh();
	end
end

function CurrencyTransferMenuMixin:InitializeFrameVisuals()
	ButtonFrameTemplate_HidePortrait(self);
	self:SetTitle(CURRENCY_TRANSFER_MENU_TITLE);

	self.TopTileStreaks:Hide();
	self.Inset:ClearAllPoints();
	self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", 11, -28);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 35);
	self.SourceSelector:ClearAllPoints();
	self.SourceSelector:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 20, -30);
	self.SourceSelector:SetPoint("TOPRIGHT", self.Inset, "TOPRIGHT", -20, -30);
end

function CurrencyTransferMenuMixin:OnCurrencyTransferRequested(requestedCurrencyID)
	local currencyAlreadyOpened = self.currencyInfo and self.currencyInfo.currencyID == requestedCurrencyID;
	if currencyAlreadyOpened then
		HideUIPanel(self);
		return;
	end

	self:SetCurrency(requestedCurrencyID);
	if self:IsShown() then
		self:FullRefresh();
	else
		ShowUIPanel(self);
	end
end

function CurrencyTransferMenuMixin:OnCurrencyTransferSourceSelected(sourceCharacterData)
	self.sourceCharacterData = sourceCharacterData;
	if not sourceCharacterData then
		return;
	end

	self.SourceSelector:RefreshSelectedSource();
	self.AmountSelector:ValidateAndSetValue();
	self.SourceBalancePreview:SetCharacterAndCurrencyBalance(sourceCharacterData.characterName, self:GetSourceCharacterCurrencyQuantity() - self:GetCurrencyTransferAmount());
end

function CurrencyTransferMenuMixin:OnCurrencyTransferAmountUpdated(amount)
	if not self.currencyInfo then 
		return;
	end

	self.ConfirmButton:SetEnabled(amount > 0);
	self.SourceBalancePreview:SetCurrencyBalance(self:GetSourceCharacterCurrencyQuantity() - amount);

	local transferCost = self:GetCurrencyTransferCost();
	amount = transferCost and (amount - transferCost) or amount;
	self.PlayerBalancePreview:SetCurrencyBalance(self:GetPlayerCurrencyQuantity() + amount);
end

function CurrencyTransferMenuMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, CURRENCY_TRANSFER_MENU_EVENTS);
	self:FullRefresh();
end

function CurrencyTransferMenuMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, CURRENCY_TRANSFER_MENU_EVENTS);
	self:ClearTransferData();
end

function CurrencyTransferMenuMixin:ClearTransferData()
	self.currencyInfo = nil;
	self.sourceCharacterData = nil;
end

function CurrencyTransferMenuMixin:SetCurrency(currencyID)
	if not currencyID then
		return;
	end

	self.currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
end

function CurrencyTransferMenuMixin:RefreshCurrencyInfo()
	if not self.currencyInfo then
		return;
	end

	self.currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyInfo.currencyID);
end

function CurrencyTransferMenuMixin:GetCurrencyInfo()
	return self.currencyInfo;
end

function CurrencyTransferMenuMixin:CalculateEarnableCurrencyLimit()
	if not self.currencyInfo then
		return nil;
	end

	local hasWeeklyCurrencyCap = self.currencyInfo.maxWeeklyQuantity > 0;
	local hasGeneralCurrencyCap = self.currencyInfo.maxQuantity > 0;
	local noCurrencyCap = not hasWeeklyCurrencyCap and not hasGeneralCurrencyCap; 
	if noCurrencyCap then
		return nil;
	end

	if hasWeeklyCap and hasGeneralCurrencyCap then
		local remainingWeeklyEarnableQuantity = self.currencyInfo.maxWeeklyQuantity - self.currencyInfo.quantityEarnedThisWeek;
		local remainingGeneralEarnableQuantity = self.currencyInfo.maxQuantity - self.currencyInfo.quantity;
		return math.min(remainingWeeklyEarnableQuantity, remainingGeneralEarnableQuantity);
	elseif hasWeeklyCap then
		return self.currencyInfo.maxWeeklyQuantity - self.currencyInfo.quantityEarnedThisWeek;
	elseif hasGeneralCurrencyCap then
		return self.currencyInfo.maxQuantity - self.currencyInfo.quantity;
	end

	return nil;
end

function CurrencyTransferMenuMixin:GetCurrencyID()
	return self.currencyInfo and self.currencyInfo.currencyID;
end

function CurrencyTransferMenuMixin:GetCurrencyIcon()
	return self.currencyInfo and self.currencyInfo.iconFileID;
end

function CurrencyTransferMenuMixin:GetPlayerCurrencyQuantity()
	return self.currencyInfo and self.currencyInfo.quantity;
end

function CurrencyTransferMenuMixin:GetSourceCharacterData()
	return self.sourceCharacterData;
end

function CurrencyTransferMenuMixin:GetSourceCharacterCurrencyQuantity()
	return self.sourceCharacterData and self.sourceCharacterData.quantity or 0;
end

function CurrencyTransferMenuMixin:GetSourceCharacterName()
	return self.sourceCharacterData and self.sourceCharacterData.characterName or "";
end

function CurrencyTransferMenuMixin:GetCurrencyTransferAmount()
	return self.AmountSelector:GetCurrencyTransferAmount();
end

function CurrencyTransferMenuMixin:GetCurrencyTransferCost()
	return self.AmountSelector:CalculateCurrencyTransferCost(self.currencyInfo.currencyID);
end

function CurrencyTransferMenuMixin:RefreshPlayerBalancePreview()
	local transferCost = self:GetCurrencyTransferCost();
	local transferAmount = transferCost and (self:GetCurrencyTransferAmount() - transferCost) or self:GetCurrencyTransferAmount();
	self.PlayerBalancePreview:SetCharacterAndCurrencyBalance(UnitName("player"), self:GetPlayerCurrencyQuantity() + transferAmount);
end

function CurrencyTransferMenuMixin:FullRefresh()
	if not self.currencyInfo then 
		return;
	end

	self:RefreshCurrencyInfo();
	self:RefreshPlayerBalancePreview();
	self.SourceSelector:RefreshRosterCurrencyData();
	self.SourceSelector:AutoSelectHighestQuantitySource();
end

CurrencyTransferBalancePreviewMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferBalancePreviewMixin:SetCharacterAndCurrencyBalance(characterName, balance)
	self:SetCharacterName(characterName);
	self:SetCurrencyBalance(balance);
	self:SetCurrencyIcon(self:GetCurrencyTransferMenu():GetCurrencyIcon());
end

function CurrencyTransferBalancePreviewMixin:SetCurrencyIcon(icon)
	self.BalanceInfo.CurrencyIcon:SetTexture(icon);
end

function CurrencyTransferBalancePreviewMixin:SetCharacterName(characterName)
	self.Label:SetFormattedText(CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW:format(characterName or ""));
end

function CurrencyTransferBalancePreviewMixin:SetCurrencyBalance(amount)
	self.BalanceInfo.Amount:SetText(amount and BreakUpLargeNumbers(amount) or 0);
	self.BalanceInfo.TransferCostDisplay:SetShown(self.showTransferCost and self:GetCurrencyTransferMenu():GetCurrencyTransferCost() ~= nil);
end

CurrencyTransferConfirmButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferConfirmButtonMixin:OnClick()
	local CurrencyTransferMenu = self:GetCurrencyTransferMenu();
	local sourceCharacterData = CurrencyTransferMenu:GetSourceCharacterData();
	C_CurrencyInfo.RequestCurrencyFromRoster(sourceCharacterData.characterGUID, CurrencyTransferMenu:GetCurrencyID(), CurrencyTransferMenu:GetCurrencyTransferAmount());
	HideUIPanel(CurrencyTransferMenu);
end

CurrencyTransferCancelButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferCancelButtonMixin:OnClick()
	HideUIPanel(CurrencyTransferMenu);
end

CurrencyTransferEntryMixin = CreateFromMixins(CurrencyTransferSystemMixin, CallbackRegistryMixin);

function CurrencyTransferEntryMixin:Initialize(elementData)
	self.elementData = elementData;
	local currencyInfo = elementData and C_CurrencyInfo.GetBasicCurrencyInfo(elementData.currencyID);
	self.CharacterName:SetText(elementData.characterName or "");
	self.CurrencyIcon:SetTexture(currencyInfo.icon);
	self.CurrencyBalance:SetText(elementData.quantity);
end

function CurrencyTransferEntryMixin:OnClick()
	self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferSourceSelected, self.elementData);
	CloseDropDownMenus();
end

CurrencyTransferAmountSelectorMixin = {};

function CurrencyTransferAmountSelectorMixin:OnHide()
	self:Reset();
end

function CurrencyTransferAmountSelectorMixin:GetCurrencyTransferAmount()
	return self.InputBox:GetNumber() or 0;
end

function CurrencyTransferAmountSelectorMixin:Reset()
	self.InputBox:Reset();
end

function CurrencyTransferAmountSelectorMixin:ValidateAndSetValue()
	self.InputBox:ValidateAndSetValue();
end

function CurrencyTransferAmountSelectorMixin:CalculateCurrencyTransferCost(currencyID)
	local transferAmountRequested = self:GetCurrencyTransferAmount();
	if not transferAmountRequested then
		return nil;
	end

	local transferPercentage = C_CurrencyInfo.GetCurrencyTransferPercentage(currencyID);
	local noTransferCost = not transferPercentage or transferPercentage == 100;
	if noTransferCost then
		return nil;
	end

	local transferPercentageLost = (100 - transferPercentage);
	local transferCost = transferAmountRequested * (transferPercentageLost / 100);
	return math.floor(transferCost);
end

CurrencyTransferAmountInputBoxMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferAmountInputBoxMixin:OnShow()
	self:SetNumber(0);
end

function CurrencyTransferAmountInputBoxMixin:OnEditFocusLost()
	EditBox_ClearHighlight(self);
	self:ValidateAndSetValue();
end

function CurrencyTransferAmountInputBoxMixin:ValidateAndSetValue()
	self:SetNumber(self:GetClampedInputAmount(self:GetNumber()));
	self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferAmountUpdated, self:GetNumber());
end

function CurrencyTransferAmountInputBoxMixin:GetClampedInputAmount(inputAmount)
	local CurrencyTransferMenu = self:GetCurrencyTransferMenu();
	local sourceCharacterQuantity = CurrencyTransferMenu:GetSourceCharacterCurrencyQuantity();
	local remainingEarnableQuantity = CurrencyTransferMenu:CalculateEarnableCurrencyLimit();

	local maxTransferAmount = nil;
	if sourceCharacterQuantity and remainingEarnableQuantity then
		maxTransferAmount = math.min(sourceCharacterQuantity, remainingEarnableQuantity);
	elseif sourceCharacterQuantity then
		maxTransferAmount = sourceCharacterQuantity;
	elseif remainingEarnableQuantity then
		maxTransferAmount = remainingEarnableQuantity;
	end

	if maxTransferAmount then
		return Clamp(inputAmount, 0, maxTransferAmount);
	else
		return (inputAmount >= 0) and inputAmount or 0;
	end
end

function CurrencyTransferAmountInputBoxMixin:Reset()
	self:SetText("");
end

CurrencyTransferCostDisplayMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferCostDisplayMixin:OnEnter()
	local transferCost = self:GetCurrencyTransferMenu():GetCurrencyTransferCost();
	if not transferCost then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, CURRENCY_TRANSFER_COST_TOOLTIP:format(transferCost));
	GameTooltip:Show();
end

function CurrencyTransferCostDisplayMixin:OnLeave()
	GameTooltip_Hide();
end

CurrencyTransferSourceSelectorMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferSourceSelectorMixin:OnShow()
	self:RefreshPlayerName();
end

function CurrencyTransferSourceSelectorMixin:RefreshPlayerName()
	self.PlayerName:SetText(CURRENCY_TRANSFER_DESTINATION:format(UnitName("player")));
end

function CurrencyTransferSourceSelectorMixin:RefreshSelectedSource()
	self.DropDown:RefreshSelectedSource();
end

function CurrencyTransferSourceSelectorMixin:RefreshRosterCurrencyData()
	self.Roster:RefreshRosterCurrencyData();
end

function CurrencyTransferSourceSelectorMixin:AutoSelectHighestQuantitySource()
	local rosterCurrencyData = self.Roster:GetRosterCurrencyData();
	if not rosterCurrencyData or #rosterCurrencyData == 0 then
		return;
	end

	-- C_CurrencyInfo.FetchRosterCurrencyData() is presorted by quantity
	self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferSourceSelected, rosterCurrencyData[1]);
end

CurrencyTransferSourceSelectorDropDownMixin = CreateFromMixins(CurrencyTransferSystemMixin);

local function CurrencyTransferSourceSelectorDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = CurrencyTransferMenu.SourceSelector.Roster;
	UIDropDownMenu_AddButton(info);
end

function CurrencyTransferSourceSelectorDropDownMixin:SetUpDropDownText()
	self.Text:ClearAllPoints();
	self.Text:SetPoint("RIGHT", self.Right, "RIGHT", -43, 2);
	self.Text:SetPoint("LEFT", self.Left, "RIGHT", 5, 2);
	self.Text:SetJustifyH("LEFT");
end

function CurrencyTransferSourceSelectorDropDownMixin:OnLoad()
	UIDropDownMenu_SetInitializeFunction(self, CurrencyTransferSourceSelectorDropdown_Initialize);
	local width = 120;
	UIDropDownMenu_SetWidth(self, width);
	UIDropDownMenu_SetAnchor(self, 5, 8, "TOPRIGHT", self, "BOTTOMRIGHT");
	self:SetUpDropDownText();
end

function CurrencyTransferSourceSelectorDropDownMixin:RefreshSelectedSource()
	local sourceCharacterName = self:GetCurrencyTransferMenu():GetSourceCharacterData().characterName;
	UIDropDownMenu_SetText(self, sourceCharacterName or "");
end

CurrencyTransferRosterMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferRosterMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CurrencyTransferEntryTemplate", function(button, elementData)
		button:Initialize(elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CurrencyTransferRosterMixin:OnShow()
	self:UpdateFrameDimensions();
	self:InitializeScrollBox();
	self.ScrollBox:SetDataProvider(CreateDataProvider(self.rosterCurrencyData));
end

local ROSTER_DATA_MAX_VISIBLE_LINES = 8;

function CurrencyTransferRosterMixin:UpdateFrameDimensions()
	self:SetHeight(self:CalculateBestFrameHeight());

	local scrollBarShown = #self.rosterCurrencyData > ROSTER_DATA_MAX_VISIBLE_LINES;
	self.ScrollBox:SetPoint("BOTTOMRIGHT", (scrollBarShown and -20 or -10), 0);
	self.ScrollBar:SetShown(scrollBarShown);
end

function CurrencyTransferRosterMixin:RefreshRosterCurrencyData()
	local currencyID = self:GetCurrencyTransferMenu():GetCurrencyID();
	if not currencyID then
		return;
	end

	self.rosterCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID);
end

function CurrencyTransferRosterMixin:GetRosterCurrencyData()
	return self.rosterCurrencyData;
end

function CurrencyTransferRosterMixin:CalculateBestFrameHeight()
	if not self.rosterCurrencyData then
		return;
	end

	local elementHeight = C_XMLUtil.GetTemplateInfo("CurrencyTransferEntryTemplate").height;
	local maxHeight = elementHeight * ROSTER_DATA_MAX_VISIBLE_LINES;
	local utilizedHeight = elementHeight * #self.rosterCurrencyData;

	return math.min(utilizedHeight, maxHeight);
end

-- This overrides UIDropDownCustomMenuEntryMixin:GetPreferredEntryHeight()
-- Our frame size changes based on the size of rosterCurrencyData,
-- So we need to calculate our new frame height when the UIDropDown system needs it.
function CurrencyTransferRosterMixin:GetPreferredEntryHeight()
	return self:CalculateBestFrameHeight();
end

CurrencyTransferLogMixin = {};

local CURRENCY_TRANSFER_LOG_EVENTS = {
	"CURRENCY_TRANSFER_LOG_UPDATE",
}

function CurrencyTransferLogMixin:OnLoad()
	self:InitializeFrameVisuals();
	self:InitializeScrollBox();
end

function CurrencyTransferLogMixin:OnShow()
	-- This popup occupies the same space as the transfer log
	TokenFramePopup:Hide();

	FrameUtil.RegisterFrameForEvents(self, CURRENCY_TRANSFER_LOG_EVENTS);
	self:Refresh();
end

function CurrencyTransferLogMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CURRENCY_TRANSFER_LOG_EVENTS);
end

function CurrencyTransferLogMixin:OnEvent(event, ...)
	if event == "CURRENCY_TRANSFER_LOG_UPDATE" then
		self:Refresh();
	end
end

function CurrencyTransferLogMixin:InitializeFrameVisuals()
	ButtonFrameTemplate_HidePortrait(self);
	self:SetTitle(CURRENCY_TRANSFER_LOG_TITLE);

	self.TopTileStreaks:Hide();
	self.Inset:ClearAllPoints();
	self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", 11, -28);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 10);

	self.ScrollBox:ClearAllPoints();
	self.ScrollBox:SetPoint("TOPLEFT", self.Inset, 5, -5);
	self.ScrollBox:SetPoint("BOTTOMRIGHT", self.Inset, -22, 2);
end

function CurrencyTransferLogMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CurrencyTransferLogEntryTemplate", function(button, elementData)
		button:Initialize(elementData);
	end);
	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 2;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CurrencyTransferLogMixin:Refresh()
	self.ScrollBox:SetDataProvider(CreateDataProvider(C_CurrencyInfo.FetchCurrencyTransferTransactions()));
end

function CurrencyTransferLogMixin:Toggle()
	self:SetShown(not self:IsShown())
end

local transactionAgeFormatter = CreateFromMixins(SecondsFormatterMixin);
transactionAgeFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold, 
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower
);

CurrencyTransferLogEntryMixin = {};

function CurrencyTransferLogEntryMixin:OnLoad()
	self.BackgroundHighlight:SetFrameLevel(self:GetFrameLevel() - 1);
end

function CurrencyTransferLogEntryMixin:Initialize(elementData)
	self.transactionData = elementData;
	self.currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(elementData.currencyID);

	self.CurrencyQuantity:SetText(AbbreviateLargeNumbers(elementData.quantity));
	self.SourceName:SetText(elementData.sourceCharacterName);
	self.DestinationName:SetText(elementData.destinationCharacterName);
	self.CurrencyIcon:SetTexture(self.currencyInfo and self.currencyInfo.icon or nil);

	self:RefreshHighlightVisuals();
end

function CurrencyTransferLogEntryMixin:RefreshBackgroundHighlight()
	local entryNeedsHighlight = self:IsMouseOver();
	self.BackgroundHighlight:SetAlpha(entryNeedsHighlight and 0.10 or 0);
end

function CurrencyTransferLogEntryMixin:RefreshHighlightVisuals()
	self:RefreshBackgroundHighlight();
end

function CurrencyTransferLogEntryMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local arrowIcon = CreateAtlasMarkup("arrow-short", 16, 16);
	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, self.transactionData.sourceCharacterName .. " " .. arrowIcon .. " " .. self.transactionData.destinationCharacterName, wrapText);
	GameTooltip_AddHighlightLine(GameTooltip, CURRENCY_TRANSFER_LOG_CURRENCY_FORMAT:format(BreakUpLargeNumbers(self.transactionData.quantity), self.currencyInfo and self.currencyInfo.name or ""), wrapText)
	GameTooltip_AddHighlightLine(GameTooltip, CURRENCY_TRANSFER_LOG_TIME_FORMAT:format(transactionAgeFormatter:Format(GetServerTime() - self.transactionData.timestamp)), wrapText);
	GameTooltip:Show();

	self:RefreshHighlightVisuals();
end

function CurrencyTransferLogEntryMixin:OnLeave()
	GameTooltip_Hide();

	self:RefreshHighlightVisuals();
end

CurrencyTransferLogToggleButtonMixin = {};

function CurrencyTransferLogToggleButtonMixin:OnClick()
	CurrencyTransferLog:Toggle();
end

function CurrencyTransferLogToggleButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, CURRENCY_TRANSFER_LOG_TITLE);
	GameTooltip:Show();
end

function CurrencyTransferLogToggleButtonMixin:OnLeave()
	GameTooltip_Hide();
end