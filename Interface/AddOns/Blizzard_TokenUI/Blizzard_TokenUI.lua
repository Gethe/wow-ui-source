UIPanelWindows["TokenFrame"] = { area = "left", pushable = 1, whileDead = 1 };

TokenHeaderMixin = {};

function TokenHeaderMixin:OnLoad_TokenHeaderTemplate()
	self:SetClickHandler(function(_header, button)
		if button == "LeftButton" then
			self:ToggleCollapsed();
		end
	end);
end

function TokenHeaderMixin:Initialize(elementData)
	self.elementData = elementData;

	self:GetTitleRegion():SetText(self.elementData.name or "");
	self:UpdateCollapsedState(self:IsCollapsed());
end

function TokenHeaderMixin:IsCollapsed()
	return not self.elementData.isHeaderExpanded;
end

function TokenHeaderMixin:ToggleCollapsed()
	C_CurrencyInfo.ExpandCurrencyList(self.elementData.currencyIndex, self:IsCollapsed());
	TokenFrame:Update();
	TokenFramePopup:CloseIfHidden();
end

TokenEntryMixin = {};

function TokenEntryMixin:OnLoad()
	self.Content.BackgroundHighlight:SetFrameLevel(self:GetFrameLevel() - 1);

	self.Content.AccountWideIcon:SetScript("OnLeave", function()
		GameTooltip_Hide();
		self:OnLeave();
	end);
end

function TokenEntryMixin:Initialize(elementData)
	self.elementData = elementData;
	self.currencyIndex = elementData.currencyIndex;

	self.Content.Count:SetText(BreakUpLargeNumbers(elementData.quantity));
	self.Content.Name:SetText(elementData.name);
	self:RefreshTextColor();

	self.Content.CurrencyIcon:SetTexture(elementData.iconFileID);
	self.Content.WatchedCurrencyCheck:SetShown(elementData.isShowInBackpack);

	self:RefreshHighlightVisuals();
end

function TokenEntryMixin:IsSelected()
	return self.elementData.name == TokenFrame.selectedToken;
end

function TokenEntryMixin:RefreshBackgroundHighlight()
	self.Content.BackgroundHighlight:SetAlpha((self:IsSelected() and self.selectedHighlightAlpha) or (self:IsMouseOver() and self.mouseOverHighlightAlpha) or 0);
end

function TokenEntryMixin:RefreshAccountCurrencyIcon()
	if not (self:IsSelected() or self:IsMouseOver()) then
		self.Content.AccountWideIcon:Hide();
		return;
	end

	if self.elementData.isAccountWide then
		self.Content.AccountWideIcon.Icon:SetAtlas("warbands-icon", TextureKitConstants.UseAtlasSize);
		self.Content.AccountWideIcon.Icon:SetScale(0.9);
	elseif self.elementData.isAccountTransferable then
		self.Content.AccountWideIcon.Icon:SetAtlas("warbands-transferable-icon", TextureKitConstants.UseAtlasSize);
		self.Content.AccountWideIcon.Icon:SetScale(0.9);
	else
		self.Content.AccountWideIcon.Icon:SetAtlas(nil);
	end

	self.Content.AccountWideIcon:SetShown(self.Content.AccountWideIcon.Icon:GetAtlas() ~= nil);
end

function TokenEntryMixin:RefreshHighlightVisuals()
	self:RefreshBackgroundHighlight();
	self:RefreshAccountCurrencyIcon();
end

function TokenEntryMixin:RefreshTextColor()
	local hasCurrency = self.elementData.quantity > 0;
	local textColor = hasCurrency and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
	self.Content.Count:SetTextColor(textColor:GetRGBA());
	self.Content.Name:SetTextColor(textColor:GetRGBA());
end

function TokenEntryMixin:OnMouseDown()
	self.Content:AdjustPointsOffset(1, -1);
end

function TokenEntryMixin:OnMouseUp()
	self.Content:AdjustPointsOffset(-1, 1);
end

function TokenEntryMixin:OnClick()
	local linkedToChat = false;
	if IsModifiedClick("CHATLINK") then
		linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyListLink(self.currencyIndex));
	end
	if not linkedToChat then
		if IsModifiedClick("TOKENWATCHTOGGLE") then
			TokenFrame:SetTokenWatched(self.currencyIndex, not self.elementData.isShowInBackpack);
		else
			local showPopup = not TokenFramePopup:IsShown() or TokenFrame.selectedID ~= self.currencyIndex;
			TokenFramePopup:SetShown(showPopup);

			-- Toggle the selected state of this currency on a regular (non-modified) left click
			local alreadySelected = self:IsSelected();
			TokenFrame.selectedToken = (not alreadySelected and self.Content.Name:GetText()) or nil;
			-- Set the selectedID as well if we're going to show the options for this currency
			TokenFrame.selectedID = showPopup and self.currencyIndex or nil;
			if showPopup then
				TokenFrame:UpdatePopup(self);
			end
		end
	end

	-- Hide this currency's tooltip if we're showing the options for this currency
	local showingCurrencyOptions = self:IsSelected() and TokenFramePopup:IsShown();
	if showingCurrencyOptions then
		GameTooltip_Hide();
	else
		self:ShowCurrencyTooltip();
	end

	TokenFrame:Update();
	TokenFramePopup:CloseIfHidden();
end

function TokenEntryMixin:OnEnter()
	local showingCurrencyOptions = self:IsSelected() and TokenFramePopup:IsShown();
	if not self:IsSelected() or not showingCurrencyOptions then
		self:ShowCurrencyTooltip();
	end

	self:RefreshHighlightVisuals();
end

function TokenEntryMixin:ShowCurrencyTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCurrencyToken(self.elementData.currencyIndex);

	if self.elementData.isAccountTransferable then
		local transferPercentage = self.elementData.transferPercentage;
		local percentageLost = transferPercentage and (100 - transferPercentage) or 0;
		if percentageLost > 0 then
			GameTooltip_AddNormalLine(GameTooltip, CURRENCY_TRANSFER_LOSS:format(math.ceil(percentageLost)));
		end
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddInstructionLine(GameTooltip, CURRENCY_BUTTON_TOOLTIP_CLICK_INSTRUCTION);

	GameTooltip:Show();
end

function TokenEntryMixin:OnLeave()
	GameTooltip_Hide();

	self:RefreshHighlightVisuals();
end

TokenEntryAccountWideIconMixin = {};

function TokenEntryAccountWideIconMixin:OnEnter()
	if not self:IsShown() then
		return;
	end

	self:ShowTooltip();
end

function TokenEntryAccountWideIconMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local tooltipLine = self:GetCurrencyButton().elementData.isAccountTransferable and ACCOUNT_TRANSFERRABLE_CURRENCY or ACCOUNT_LEVEL_CURRENCY;
	GameTooltip_AddNormalLine(GameTooltip, tooltipLine);
	GameTooltip:Show();
end

function TokenEntryAccountWideIconMixin:GetCurrencyButton()
	return self:GetParent():GetParent();
end

TokenSubHeaderMixin = {};

function TokenSubHeaderMixin:Initialize(elementData)
	self.elementData = elementData;
	self.Text:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(elementData.name));

	self.ToggleCollapseButton:RefreshIcon();
end

function TokenSubHeaderMixin:IsCollapsed()
	return not self.elementData.isHeaderExpanded;
end

function TokenSubHeaderMixin:ToggleCollapsed()
	C_CurrencyInfo.ExpandCurrencyList(self.elementData.currencyIndex, self:IsCollapsed());
	TokenFrame:Update();
	TokenFramePopup:CloseIfHidden();
end

TokenSubHeaderToggleCollapseButtonMixin = {};

function TokenSubHeaderToggleCollapseButtonMixin:GetHeader()
	return self:GetParent();
end

function TokenSubHeaderToggleCollapseButtonMixin:RefreshIcon()
	local header = self:GetHeader();
	self:GetNormalTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open", TextureKitConstants.UseAtlasSize);
	self:GetPushedTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closedpressed" or "campaign_headericon_openpressed", TextureKitConstants.UseAtlasSize);
end

function TokenSubHeaderToggleCollapseButtonMixin:OnClick()
	self:GetHeader():ToggleCollapsed();
end

local TOKEN_FRAME_EVENTS = {
	"ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
};

TokenFrameMixin = {};

function TokenFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, elementData)
		button:Initialize(elementData);
	end

	view:SetElementIndentCalculator(function(elementData)
		local isTopLevelHeader = elementData.isHeader and elementData.currencyListDepth == 0;
		if isTopLevelHeader then
			return 0;
		end

		-- We only slightly indent elements that are immediately under top level headers
		if elementData.currencyListDepth == 1 then
			return 2;
		end

		return 50 * (elementData.currencyListDepth -1);
	end);

	view:SetElementFactory(function(factory, elementData)
		local isTopLevelHeader = elementData.isHeader and elementData.currencyListDepth == 0;
		if isTopLevelHeader then
			factory("TokenHeaderTemplate", Initializer);
			return;
		end

		local isSubHeader = elementData.isHeader and elementData.currencyListDepth > 0;
		if isSubHeader then
			factory("TokenSubHeaderTemplate", Initializer);
			return;
		end

		factory("TokenEntryTemplate", Initializer);
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 10, 10;
	local elementSpacing = 2;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.filterDropdown:SetWidth(130);
end

local function IsFilterTypeSelected(filterType)
	return C_CurrencyInfo.GetCurrencyFilter() == filterType;
end

local function SetFilterTypeSelected(filterType)
	-- Clear out whatever we currently have selected because we're changing the filter type
	TokenFrame.selectedToken = nil;
	TokenFrame.selectedID = nil;
	TokenFramePopup:Hide();
	HideUIPanel(CurrencyTransferMenu);

	C_CurrencyInfo.SetCurrencyFilter(filterType);
end

local CurrencyFilterFilterTypeOrder = {
	Enum.CurrencyFilterType.DiscoveredAndAllAccountTransferable,
	Enum.CurrencyFilterType.DiscoveredOnly,
};

local function GetCurrencyFilterTypeName(filterType)
	local CurrencyFilterTypeNames = {
		[Enum.CurrencyFilterType.DiscoveredAndAllAccountTransferable] = CURRENCY_FILTER_TYPE_TRANSFERABLE,
		-- [Enum.CurrencyFilterType.DiscoveredOnly] = CURRENCY_FILTER_TYPE_CHARACTER:format(UnitName("player")),
	};

	-- We don't store the player's name in case it is modified/updated during a play session
	if filterType == Enum.CurrencyFilterType.DiscoveredOnly then
		return CURRENCY_FILTER_TYPE_CHARACTER:format(UnitName("player"));
	end

	return CurrencyFilterTypeNames[filterType];
end

local function GetCurrencyFilterTypeTooltipDescription(filterType)
	local CurrencyFilterTypeTooltipDescriptions = {
		[Enum.CurrencyFilterType.DiscoveredAndAllAccountTransferable] = CURRENCY_FILTER_TYPE_TRANSFERABLE_TOOLTIP,
	};

	return CurrencyFilterTypeTooltipDescriptions[filterType];
end

function TokenFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TOKEN_FRAME_EVENTS);

	SetButtonPulse(CharacterFrameTab3, 0, 1); --Stop the button pulse

	self:Update();

	self.filterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CURRENCY_FRAME_FILTER");

		for index, filterType in ipairs(CurrencyFilterFilterTypeOrder) do
			local button = rootDescription:CreateRadio(GetCurrencyFilterTypeName(filterType), IsFilterTypeSelected, SetFilterTypeSelected, filterType);

			local tooltipDescription = GetCurrencyFilterTypeTooltipDescription(filterType);
			if tooltipDescription then
				button:SetTooltip(function(tooltip, elementDescription)
					GameTooltip_AddHighlightLine(tooltip, tooltipDescription);
				end);
			end
		end
	end);
end

function TokenFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TOKEN_FRAME_EVENTS);

	-- Reset the selected currency for the next time we open the window
	self.selectedToken = nil;
	self.selectedID = nil;

	TokenFramePopup:Hide();
	HideUIPanel(CurrencyTransferMenu);
	CurrencyTransferLog:Hide();
end

function TokenFrameMixin:OnEvent(event, ...)
	if event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED" then
		if C_CurrencyInfo.DoesCurrentFilterRequireAccountCurrencyData() then
			self:Update();
		end
	end
end

function TokenFrameMixin:Update()
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();
	CharacterFrameTab3:SetShown(numTokenTypes > 0);

	local currencyDataReady = not C_CurrencyInfo.DoesCurrentFilterRequireAccountCurrencyData() or C_CurrencyInfo.IsAccountCharacterCurrencyDataReady();
	self:SetLoadingSpinnerShown(not currencyDataReady);
	if not currencyDataReady then
		return;
	end

	local currencyList = {};
	for currencyIndex = 1, numTokenTypes do
		local currencyData = C_CurrencyInfo.GetCurrencyListInfo(currencyIndex);
		if currencyData then
			currencyData.currencyIndex = currencyIndex;
			tinsert(currencyList, currencyData);
		end
	end

	self.ScrollBox:SetDataProvider(CreateDataProvider(currencyList), ScrollBoxConstants.RetainScrollPosition);

	if self.selectedID then
		local function FindSelectedTokenButton(button, elementData)
			return elementData.currencyIndex == self.selectedID;
		end
		local selectedEntry = self.ScrollBox:FindFrameByPredicate(FindSelectedTokenButton);

		-- If we're updating the currency list while the "Options" popup is open then we should refresh it as well
		if selectedEntry and self.Popup:IsShown() then
			self:UpdatePopup(selectedEntry);
		end

		-- We want to hide the Currency Transfer Menu if we select a different currency than the one we currency have open for transferring
		local currencyTransferMismatch = selectedEntry and CurrencyTransferMenu:GetCurrencyID() ~= selectedEntry.elementData.currencyID;
		if currencyTransferMismatch then
			HideUIPanel(CurrencyTransferMenu);
		end
	else
		HideUIPanel(CurrencyTransferMenu);
	end

	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, GenerateClosure(self.RefreshAccountTransferableCurrenciesTutorial), self);
end

function TokenFrameMixin:RefreshAccountTransferableCurrenciesTutorial()
	HelpTip:Hide(self, ACCOUNT_TRANSFERABLE_CURRENCIES_TUTORIAL);

	local tutorialAcknowledged = GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_TRANSFERABLE_CURRENCIES);
	if tutorialAcknowledged then
		return;
	end

	local accountTransferableCurrency = self.ScrollBox:FindFrameByPredicate(function(button, elementData) return elementData.isAccountTransferable; end);
	if not accountTransferableCurrency then
		return;
	end

	local helpTipInfo = {
		text = ACCOUNT_TRANSFERABLE_CURRENCIES_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_TRANSFERABLE_CURRENCIES,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = 40,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
		checkCVars = true,
	};
	HelpTip:Show(self, helpTipInfo, accountTransferableCurrency);
end

function TokenFrameMixin:SetLoadingSpinnerShown(shown)
	self.ScrollBox:SetShown(not shown);
	self.ScrollBar:SetShown(not shown);

	self.LoadingSpinner:SetShown(shown);
end

function TokenFrameMixin:SetTokenWatched(id, watched)
	if watched then
		local maxWatched = BackpackTokenFrame:GetMaxTokensWatched();
		if GetNumWatchedTokens() >= maxWatched then
			UIErrorsFrame:AddMessage(TOO_MANY_WATCHED_TOKENS:format(maxWatched), 1.0, 0.1, 0.1, 1.0);
			return false;
		end
	end

	C_CurrencyInfo.SetCurrencyBackpack(id, watched);
	self:Update();
	BackpackTokenFrame:Update();
	return true;
end

TokenFramePopupMixin = {};

function TokenFramePopupMixin:CloseIfHidden()
	-- This handles the case where you close a category with the selected token popup shown
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();
	local selectedFound;
	for i=1, numTokenTypes do
		if ( TokenFrame.selectedToken == C_CurrencyInfo.GetCurrencyListInfo(i).name ) then
			selectedFound = 1;
		end
	end
	if ( not selectedFound ) then
		-- Clear out the selected currency if we can't find it anymore
		TokenFrame.selectedToken = nil;
		TokenFrame.selectedID = nil;

		TokenFramePopup:Hide();
	end
end

function TokenFramePopupMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	-- The this popup occupies the same space as the transfer log
	CurrencyTransferLog:Hide();
end

function TokenFramePopupMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function TokenFramePopupMixin:CalculateBestHeight()
	local showingCheckboxes = self.InactiveCheckbox:IsShown() or self.BackpackCheckbox:IsShown();
	local showingCurrencyTransferButton = self.CurrencyTransferToggleButton:IsShown();

	if showingCheckboxes and showingCurrencyTransferButton then
		return 135;
	elseif showingCurrencyTransferButton then
		return 90;
	end

	return 100;
end

function GetNumWatchedTokens()
	return BackpackTokenFrame:GetNumWatchedTokens();
end

function TokenFrameMixin:UpdatePopup(button)
	TokenFramePopup.InactiveCheckbox:SetShown(button.elementData.discovered);
	TokenFramePopup.InactiveCheckbox:SetChecked(button.elementData.isTypeUnused);

	TokenFramePopup.BackpackCheckbox:SetShown(button.elementData.discovered);
	TokenFramePopup.BackpackCheckbox:SetChecked(button.elementData.isShowInBackpack);

	TokenFramePopup.CurrencyTransferToggleButton:Refresh(button.elementData);

	TokenFramePopup:SetHeight(TokenFramePopup:CalculateBestHeight());
end

InactiveCurrencyCheckboxMixin = {};

function InactiveCurrencyCheckboxMixin:OnLoad()
	self.Text:SetText(UNUSED);
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function InactiveCurrencyCheckboxMixin:OnClick()
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		C_CurrencyInfo.SetCurrencyUnused(TokenFrame.selectedID, true);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		C_CurrencyInfo.SetCurrencyUnused(TokenFrame.selectedID, false);
	end

	local numTokens = C_CurrencyInfo.GetCurrencyListSize();
	for i=1, numTokens do
		if (  C_CurrencyInfo.GetCurrencyListInfo(i).name == TokenFrame.selectedToken ) then
			TokenFrame.selectedID = i;
			break;
		end
	end

	TokenFrame:Update();
	TokenFramePopup:CloseIfHidden();
end

function InactiveCurrencyCheckboxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, TOKEN_MOVE_TO_UNUSED);
	GameTooltip:Show();
end

BackpackCurrencyCheckboxMixin = {};

function BackpackCurrencyCheckboxMixin:OnLoad()
	self.Text:SetText(SHOW_ON_BACKPACK);
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function BackpackCurrencyCheckboxMixin:OnClick()
	local watched = self:GetChecked();
	local success = TokenFrame:SetTokenWatched(TokenFrame.selectedID, watched);

	if not success then
		self:SetChecked(false);
		return;
	end

	if watched then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function BackpackCurrencyCheckboxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, TOKEN_SHOW_ON_BACKPACK);
	GameTooltip:Show();
end

BackpackTokenFrameMixin = {};

function BackpackTokenFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("ContainerFrame.OnShowTokenWatcher", self.MarkDirty, self);

	self.tokenPool = CreateFramePool("BUTTON", self, "BackpackTokenTemplate");
end

function BackpackTokenFrameMixin:OnShow()
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function BackpackTokenFrameMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function BackpackTokenFrameMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		self:Update();
	end
end

function BackpackTokenFrameMixin:UpdateIfVisible()
	if self:IsVisible() then
		self:Update();
	end
end

function BackpackTokenFrameMixin:Update()
	local previousWatchedTokens = self.numWatchedTokens;
	self.numWatchedTokens = 0;
	self.Tokens = {};
	self.tokenPool:ReleaseAll();

	for i=1, self:GetMaxTokensWatched() do
		local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(i);

		if currencyInfo then
			local watchButton = self.tokenPool:Acquire();
			watchButton:SetID(i);
			self.Tokens[i] = watchButton;

			local count = currencyInfo.quantity;
			watchButton.Icon:SetTexture(currencyInfo.iconFileID);

			local currencyText = BreakUpLargeNumbers(count);
			if strlenutf8(currencyText) > 5 then
				currencyText = AbbreviateNumbers(count);
			end

			watchButton.Count:SetText(currencyText);
			watchButton.currencyID = currencyInfo.currencyTypesID;
			watchButton:Show();

			self.numWatchedTokens = i;
		end
	end

	self:UpdateTokenAnchoring();

	if previousWatchedTokens ~= self.numWatchedTokens then
		EventRegistry:TriggerEvent("TokenFrame.OnTokenWatchChanged", self);
	end
end

function BackpackTokenFrameMixin:MarkDirty()
	self.dirty = true;
end

function BackpackTokenFrameMixin:CleanDirty()
	if self.dirty then
		self:Update();
		self.dirty = nil;
	end
end

function BackpackTokenFrameMixin:ShouldShow()
	return self:GetNumWatchedTokens() > 0;
end

function BackpackTokenFrameMixin:GetNumWatchedTokens()
	if not self.numWatchedTokens then
		-- No count yet so get it
		self:Update();
	end

	return self.numWatchedTokens or 0;
end

function BackpackTokenFrameMixin:IsCombined()
	return self.isCombined;
end

function BackpackTokenFrameMixin:SetIsCombinedInventory(isCombined)
	self.isCombined = isCombined;
end

function BackpackTokenFrameMixin:UpdateTokenAnchoring()
	AnchorUtil.GridLayout(self.Tokens, self:GetInitialTokenAnchor(), self:GetTokenLayout());
end

function BackpackTokenFrameMixin:GetInitialTokenAnchor()
	return AnchorUtil.CreateAnchor("RIGHT", self, "RIGHT", -17, -1);
end

function BackpackTokenFrameMixin:GetTokenLayout()
	return AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, self:GetMaxTokensWatched(), 0, 0);
end

function BackpackTokenFrameMixin:GetMaxTokensWatched()
	if not self.tokenWidth then
		local info = C_XMLUtil.GetTemplateInfo("BackpackTokenTemplate");
		self.tokenWidth = info and info.width or 50;
	end

	-- If backpack has not been opened at least once since UI load, get approx width of container frame
	if (self:GetWidth() or 0) <= 1 then
		return math.max(math.floor(ContainerFrame_GetApproximateWidth() / self.tokenWidth), 1);
	end

	-- Otherwise, use own width to get max num tokens that can be watched (iow: max tokens that can fit in the frame)
	return math.max(math.floor(self:GetWidth() / self.tokenWidth), 1);
end

BackpackTokenMixin = {};

function BackpackTokenMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBackpackToken(self:GetID());
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddInstructionLine(GameTooltip, TOKEN_REMOVE_FROM_BACKPACK_INSTRUCTION);
	GameTooltip:Show();
end

function BackpackTokenMixin:OnLeave()
	GameTooltip:Hide();
end

function BackpackTokenMixin:OnClick()
	if IsModifiedClick("CHATLINK") then
		local linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyLink(self.currencyID));
		if linkedToChat then
			return;
		end
	end

	if IsModifiedClick("TOKENWATCHTOGGLE") then
		C_CurrencyInfo.SetCurrencyBackpackByID(self.currencyID, false);
		BackpackTokenFrame:Update();
		if TokenFrame and TokenFrame:IsShown() then
			TokenFrame:Update();
		end
	else
		CharacterFrame:ToggleTokenFrame();
	end
end
