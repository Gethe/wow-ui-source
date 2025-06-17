UIPanelWindows["CurrencyTransferMenu"] = { area = "left", pushable = 2, whileDead = 0, checkFit = 1, allowOtherPanels = 1, };

CurrencyTransferSystemMixin = {};

function CurrencyTransferSystemMixin:GetCurrencyTransferMenu()
	return CurrencyTransferMenu;
end

CurrencyTransferToggleButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

local CURRENCY_TRANSFER_TOGGLE_BUTTON_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
	"CURRENCY_TRANSFER_FAILED",
	"ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
	"CURRENCY_TRANSFER_INITIATED",
};

local DISABLED_ERROR_MESSAGE = {
	[Enum.AccountCurrencyTransferResult.MaxQuantity] = CURRENCY_TRANSFER_DISABLED_MAX_QUANTITY,
	[Enum.AccountCurrencyTransferResult.NoValidSourceCharacter] = CURRENCY_TRANSFER_DISABLED_NO_VALID_SOURCES,
	[Enum.AccountCurrencyTransferResult.CannotUseCurrency] = CURRENCY_TRANSFER_DISABLED_UNMET_REQUIREMENTS,
	[Enum.AccountCurrencyTransferResult.TransactionInProgress] = CURRENCY_TRANSFER_IN_PROGRESS,
	[Enum.AccountCurrencyTransferResult.CurrencyTransferDisabled] = ERR_CURRENCY_TRANSFER_DISABLED,
};

function CurrencyTransferToggleButtonMixin:GetDisabledErrorMessage(dataReady, failureReason)
	if not dataReady then
		return RETRIEVING_DATA;
	end

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
	if event == "CURRENCY_DISPLAY_UPDATE" or event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED" or event == "CURRENCY_TRANSFER_FAILED" or event == "CURRENCY_TRANSFER_INITIATED" then
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
	C_CurrencyInfo.RequestCurrencyDataForAccountCharacters();
	self:UpdateEnabledState();
end

function CurrencyTransferToggleButtonMixin:SetLoadingSpinnerShown(shown)
	-- We shouldn't show the spinner and the button text at the same time
	self.LoadingSpinner:SetShown(shown);
	self.Text:SetShown(not shown);
end

function CurrencyTransferToggleButtonMixin:UpdateEnabledState()
	if not self.currencyID then
		self:SetEnabled(false);
		return;
	end

	local dataReady = C_CurrencyInfo.IsAccountCharacterCurrencyDataReady();
	local transferInProgress = C_CurrencyInfo.IsCurrencyTransferInProgress();
	self:SetLoadingSpinnerShown(not dataReady or transferInProgress);

	local canTransfer, failureReason = C_CurrencyInfo.CanTransferCurrency(self.currencyID);
	self:SetEnabled(dataReady and canTransfer);
	self:SetDisabledTooltip(self:GetDisabledErrorMessage(dataReady, failureReason), "ANCHOR_RIGHT");
	
	local isValidCurrency = C_CurrencyInfo.IsAccountTransferableCurrency(self.currencyID);
	local hasDisabledTooltip = self:GetDisabledTooltip() ~= nil;
	self:SetShown(self:IsEnabled() or (isValidCurrency and hasDisabledTooltip));
end

CurrencyTransferMenuMixin = CreateFromMixins(CallbackRegistryMixin);

local CURRENCY_TRANSFER_MENU_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
	"CURRENCY_TRANSFER_FAILED",
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
	elseif event == "CURRENCY_TRANSFER_FAILED" then
		HideUIPanel(self);
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
	-- This should never happen, we should be validating account data before requesting a transfer
	if not C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
		return;
	end

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
	self.SourceBalancePreview:SetCharacterAndCurrencyBalance(sourceCharacterData.characterName, self:GetSourceCharacterCurrencyQuantity() - self:GetTotalCurrencyTransferCost());
end

function CurrencyTransferMenuMixin:OnCurrencyTransferAmountUpdated(amount)
	if not self.currencyInfo then 
		return;
	end

	self.ConfirmButton:SetEnabled(amount > 0);
	self:RefreshSourceCharacterBalancePreview();
	self:RefreshPlayerBalancePreview();
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

function CurrencyTransferMenuMixin:RefreshMenuTitle()
	self:SetTitle(CURRENCY_TRANSFER_MENU_TITLE:format(self.currencyInfo and self.currencyInfo.name or ""));
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
		return 0;
	end

	-- There are 3 currency limits that we care about:
	-- A currency can have a weekly limit set
	local hasWeeklyCurrencyLimit = self.currencyInfo.maxWeeklyQuantity > 0;
	-- A currency can have a general/overall limit set
	local hasGeneralCurrencyLimit = self.currencyInfo.maxQuantity > 0;
	-- And then ALL currencies have a hard limit of MAX_CURRENCY_QUANTITY, even if they don't have a manually set limit
	local remainingHardLimitEarnableQuantity = Constants.CurrencyConsts.MAX_CURRENCY_QUANTITY - self.currencyInfo.quantity;

	local noCurrencyLimitSet = not hasWeeklyCurrencyLimit and not hasGeneralCurrencyLimit;
	if noCurrencyLimitSet then
		return remainingHardLimitEarnableQuantity;
	end

	if hasWeeklyCurrencyLimit and hasGeneralCurrencyLimit then
		local remainingWeeklyEarnableQuantity = self.currencyInfo.maxWeeklyQuantity - self.currencyInfo.quantityEarnedThisWeek;
		local remainingGeneralEarnableQuantity = self.currencyInfo.maxQuantity - self.currencyInfo.quantity;
		return math.min(remainingWeeklyEarnableQuantity, remainingGeneralEarnableQuantity, remainingHardLimitEarnableQuantity);
	elseif hasWeeklyCurrencyLimit then
		local remainingWeeklyEarnableQuantity = self.currencyInfo.maxWeeklyQuantity - self.currencyInfo.quantityEarnedThisWeek;
		return math.min(remainingWeeklyEarnableQuantity, remainingHardLimitEarnableQuantity);
	elseif hasGeneralCurrencyLimit then
		local remainingGeneralEarnableQuantity = self.currencyInfo.maxQuantity - self.currencyInfo.quantity;
		return math.min(remainingGeneralEarnableQuantity, remainingHardLimitEarnableQuantity);
	end

	return remainingHardLimitEarnableQuantity;
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

function CurrencyTransferMenuMixin:GetRequestedCurrencyTransferAmount()
	return self.AmountSelector:GetRequestedCurrencyTransferAmount();
end

function CurrencyTransferMenuMixin:GetTotalCurrencyTransferCost()
	return self.AmountSelector:CalculateTotalCurrencyTransferCost(self.currencyInfo.currencyID);
end

function CurrencyTransferMenuMixin:GetCurrencyTransferLoss()
	return self.AmountSelector:CalculateCurrencyTransferLoss(self.currencyInfo.currencyID);
end

function CurrencyTransferMenuMixin:RefreshSourceCharacterBalancePreview()
	self.SourceBalancePreview:SetCurrencyBalance(self:GetSourceCharacterCurrencyQuantity() - self:GetTotalCurrencyTransferCost());
end

function CurrencyTransferMenuMixin:RefreshPlayerBalancePreview()
	local transferAmount = self:GetRequestedCurrencyTransferAmount();
	self.PlayerBalancePreview:SetCharacterAndCurrencyBalance(UnitName("player"), self:GetPlayerCurrencyQuantity() + transferAmount);
end

function CurrencyTransferMenuMixin:FullRefresh()
	if not self.currencyInfo then 
		return;
	end

	self:RefreshCurrencyInfo();
	self:RefreshMenuTitle();
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
	self:RefreshTransferCostDisplay();
end

function CurrencyTransferBalancePreviewMixin:RefreshTransferCostDisplay()
	if self.showTransferCost then
		-- Reanchor the transfer cost display so it always stays next to the amount, regardless of how many digits it has
		self.BalanceInfo.TransferCostDisplay:ClearAllPoints();
		local padding = 2;
		self.BalanceInfo.TransferCostDisplay:SetPoint("RIGHT", self.BalanceInfo.Amount, "RIGHT", -(self.BalanceInfo.Amount:GetStringWidth() + padding), 0);
	end
	self.BalanceInfo.TransferCostDisplay:SetShown(self.showTransferCost and self:GetCurrencyTransferMenu():GetCurrencyTransferLoss() ~= 0);
end

CurrencyTransferConfirmButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferConfirmButtonMixin:OnClick()
	local CurrencyTransferMenu = self:GetCurrencyTransferMenu();
	local sourceCharacterData = CurrencyTransferMenu:GetSourceCharacterData();
	C_CurrencyInfo.RequestCurrencyFromAccountCharacter(sourceCharacterData.characterGUID, CurrencyTransferMenu:GetCurrencyID(), CurrencyTransferMenu:GetRequestedCurrencyTransferAmount());
	HideUIPanel(CurrencyTransferMenu);
end

CurrencyTransferCancelButtonMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferCancelButtonMixin:OnClick()
	HideUIPanel(CurrencyTransferMenu);
end

CurrencyTransferAmountSelectorMixin = CreateFromMixins(CallbackRegistryMixin);

CurrencyTransferAmountSelectorMixin:GenerateCallbackEvents({
	"RequestSetSourceCharacterMaxQuantity",
});

function CurrencyTransferAmountSelectorMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(self, CurrencyTransferAmountSelectorMixin.Event.RequestSetSourceCharacterMaxQuantity, self.OnRequestSetSourceCharacterMaxQuantity);

	self.MaxQuantityButton:SetScript("OnClick", function() 
		self:TriggerEvent(CurrencyTransferAmountSelectorMixin.Event.RequestSetSourceCharacterMaxQuantity);
	end);

	self:Reset();
end

function CurrencyTransferAmountSelectorMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	self:Reset();
end

function CurrencyTransferAmountSelectorMixin:OnRequestSetSourceCharacterMaxQuantity()
	self.InputBox:TrySetFullSourceCharacterCurrencyQuantity();
end

function CurrencyTransferAmountSelectorMixin:GetRequestedCurrencyTransferAmount()
	return self.InputBox:GetNumber() or 0;
end

function CurrencyTransferAmountSelectorMixin:Reset()
	self.InputBox:Reset();
end

function CurrencyTransferAmountSelectorMixin:ValidateAndSetValue()
	self.InputBox:ValidateAndSetValue();
end

function CurrencyTransferAmountSelectorMixin:CalculateTotalCurrencyTransferCost(currencyID)
	return C_CurrencyInfo.GetCostToTransferCurrency(currencyID, self:GetRequestedCurrencyTransferAmount());
end

function CurrencyTransferAmountSelectorMixin:CalculateCurrencyTransferLoss(currencyID)
	local totalTransactionCost = self:CalculateTotalCurrencyTransferCost(currencyID);
	local requestedTransferAmount = self:GetRequestedCurrencyTransferAmount();
	return totalTransactionCost and (totalTransactionCost - requestedTransferAmount) or 0;
end

CurrencyTransferAmountInputBoxMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferAmountInputBoxMixin:OnEditFocusLost()
	EditBox_ClearHighlight(self);
	self:ValidateAndSetValue();
end

function CurrencyTransferAmountInputBoxMixin:ValidateAndSetValue()
	local inputValue = self:GetNumber();
	local clampedInputValue = self:GetClampedInputAmount(inputValue);
	self:SetNumber(clampedInputValue);

	-- We only need to update the transfer amount in the menu if it is going to change after being clamped
	if self.currentValue ~= clampedInputValue then
		self.currentValue = clampedInputValue;
		self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferAmountUpdated, self.currentValue);
	end
end

function CurrencyTransferAmountInputBoxMixin:TrySetFullSourceCharacterCurrencyQuantity()
	local sourceCharacterCurrencyQuantity = self:GetCurrencyTransferMenu():GetSourceCharacterCurrencyQuantity() or 0;
	local maxInputValue = math.min(sourceCharacterCurrencyQuantity, self:GetMaxTransferAmountPerTransaction());
	self:SetNumber(maxInputValue);
end

function CurrencyTransferAmountInputBoxMixin:GetClampedInputAmount(inputAmount)
	local CurrencyTransferMenu = self:GetCurrencyTransferMenu();
	local remainingEarnableQuantity = CurrencyTransferMenu:CalculateEarnableCurrencyLimit();
	local sourceCharacterMaxTransferQuantity = C_CurrencyInfo.GetMaxTransferableAmountFromQuantity(CurrencyTransferMenu:GetCurrencyID(), CurrencyTransferMenu:GetSourceCharacterCurrencyQuantity()) or 0;

	local maxTransferAmount = self:GetMaxTransferAmountPerTransaction();
	if sourceCharacterMaxTransferQuantity then
		maxTransferAmount = math.min(sourceCharacterMaxTransferQuantity, remainingEarnableQuantity, maxTransferAmount);
	else
		maxTransferAmount = math.min(remainingEarnableQuantity, maxTransferAmount);
	end

	return Clamp(inputAmount, 0, maxTransferAmount);
end

function CurrencyTransferAmountInputBoxMixin:Reset()
	self:SetNumber(0);
end

function CurrencyTransferAmountInputBoxMixin:OnTextChanged()
	self:ValidateAndSetValue();
end

function CurrencyTransferAmountInputBoxMixin:GetMaxTransferAmountPerTransaction()
	return 10^(self:GetMaxLetters()) - 1;
end

CurrencyTransferCostDisplayMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferCostDisplayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, CURRENCY_TRANSFER_COST_TOOLTIP:format(self:GetCurrencyTransferMenu():GetCurrencyTransferLoss()));
	GameTooltip:Show();
end

function CurrencyTransferCostDisplayMixin:OnLeave()
	GameTooltip_Hide();
end

CurrencyTransferSourceSelectorMixin = CreateFromMixins(CurrencyTransferSystemMixin);

function CurrencyTransferSourceSelectorMixin:OnLoad()
	self.Dropdown:SetWidth(135);
end

function CurrencyTransferSourceSelectorMixin:OnShow()
	self:RefreshPlayerName();
end

function CurrencyTransferSourceSelectorMixin:RefreshPlayerName()
	self.PlayerName:SetText(CURRENCY_TRANSFER_DESTINATION:format(UnitName("player")));
end

function CurrencyTransferSourceSelectorMixin:GetRosterCurrencyData()
	return self.rosterCurrencyData;
end

function CurrencyTransferSourceSelectorMixin:RefreshSelectedSource()
	self.Dropdown:GenerateMenu();
end

function CurrencyTransferSourceSelectorMixin:AutoSelectHighestQuantitySource()
	local rosterCurrencyData = self:GetRosterCurrencyData();
	if not rosterCurrencyData or #rosterCurrencyData == 0 then
		return;
	end

	-- C_CurrencyInfo.FetchRosterCurrencyData() is presorted by quantity
	self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferSourceSelected, rosterCurrencyData[1]);

	self:SetupCharacterDropdown();
end

function CurrencyTransferSourceSelectorMixin:SetupCharacterDropdown()
	local duplicateNameCount = {};
	for index, currencyData in ipairs(self.rosterCurrencyData) do
		if not duplicateNameCount[currencyData.characterName] then
			duplicateNameCount[currencyData.characterName] = 0;
		else
			duplicateNameCount[currencyData.characterName] = duplicateNameCount[currencyData.characterName] + 1;
		end
	end

	local function GetBestNameForRadioButton(currencyData)
		local isNameDuplicatedInList = duplicateNameCount[currencyData.characterName] and (duplicateNameCount[currencyData.characterName] > 0) or false;
		return isNameDuplicatedInList and currencyData.fullCharacterName or currencyData.characterName;
	end

	local function IsSelected(currencyData)
		local sourceCharacterData = self:GetCurrencyTransferMenu():GetSourceCharacterData();
		return sourceCharacterData and (sourceCharacterData.characterGUID == currencyData.characterGUID) or false;
	end

	local function SetSelected(currencyData)
		self:GetCurrencyTransferMenu():TriggerEvent(CurrencyTransferMenuMixin.Event.CurrencyTransferSourceSelected, currencyData);
	end
	
	local function CreateRadioWithIcon(rootDescription, currencyData, currencyInfo)
		local radio = rootDescription:CreateRadio(GetBestNameForRadioButton(currencyData), IsSelected, SetSelected, currencyData);
		radio:AddInitializer(function(button, description, menu)
			local rightTexture = button:AttachTexture();
			rightTexture:SetSize(18, 18);
			rightTexture:SetPoint("RIGHT");
			rightTexture:SetTexture(currencyInfo.icon);
		
			local fontString = button.fontString;
			fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			local maxCharacterNameWidth = 225;
			fontString:SetWidth(math.min(fontString:GetUnboundedStringWidth(), maxCharacterNameWidth));

			local fontString2 = button:AttachFontString();
			fontString2:SetHeight(20);
			fontString2:SetPoint("RIGHT", rightTexture, "LEFT", -5, 0);
			fontString2:SetJustifyH("RIGHT");
			fontString2:SetText(BreakUpLargeNumbers(currencyData.quantity));

			-- Manual calculation required to accomodate aligned text.
			local pad = 20;
			local width = pad + fontString:GetWidth() + 
				fontString2:GetUnboundedStringWidth() +
				rightTexture:GetWidth();

			local height = 20;
			return width, height;
		end);
	
		radio:SetOnEnter(function(button)
			if button.fontString:IsTruncated() then
				local tooltip = GetAppropriateTooltip();
				tooltip:SetOwner(self, "ANCHOR_NONE");
				tooltip:SetPoint("BOTTOMLEFT", button, "RIGHT", 0, 0);
				GameTooltip_AddHighlightLine(tooltip, button.fontString:GetText());
				tooltip:Show();
			end
		end);
		radio:SetOnLeave(function(button)
			GameTooltip_Hide();
		end);

		return radio;
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CURRENCY_TRANSFER");

		for index, currencyData in ipairs(self.rosterCurrencyData) do
			local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyData.currencyID);

			CreateRadioWithIcon(rootDescription, currencyData, currencyInfo);

			local extent = 20;
			local maxCharacters = 8;
			local maxScrollExtent = extent * maxCharacters;
			rootDescription:SetScrollMode(maxScrollExtent);
		end
	end);
end

function CurrencyTransferSourceSelectorMixin:RefreshRosterCurrencyData()
	local currencyID = self:GetCurrencyTransferMenu():GetCurrencyID();
	if not currencyID then
		return;
	end

	self.rosterCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID);
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
	local topPadding, bottomPadding, leftPadding, rightPadding = 2, 0, 4, 4;
	local elementSpacing = 2;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CurrencyTransferLogMixin:Refresh()
	local dataReady = C_CurrencyInfo.IsCurrencyTransferTransactionDataReady();
	self.LoadingSpinner:SetShown(not dataReady);
	if not dataReady then
		return;
	end

	local dataProvider = CreateDataProvider();
	for index, transaction in ipairs_reverse(C_CurrencyInfo.FetchCurrencyTransferTransactions()) do
		dataProvider:Insert(transaction);
	end

	local hasTransactionHistory = dataProvider:GetSize() > 0;
	self.EmptyLogMessage:SetShown(not hasTransactionHistory);
	self.ScrollBar:SetShown(hasTransactionHistory);
	self.ScrollBox:SetDataProvider(dataProvider);
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
	self.currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(elementData.currencyType);

	self.CurrencyQuantity:SetText(AbbreviateLargeNumbers(elementData.quantityTransferred));
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
	GameTooltip_AddNormalLine(GameTooltip, self.transactionData.fullSourceCharacterName .. " " .. arrowIcon .. " " .. self.transactionData.fullDestinationCharacterName, wrapText);
	GameTooltip_AddHighlightLine(GameTooltip, CURRENCY_TRANSFER_LOG_CURRENCY_FORMAT:format(BreakUpLargeNumbers(self.transactionData.quantityTransferred), self.currencyInfo and self.currencyInfo.name or ""), wrapText)
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