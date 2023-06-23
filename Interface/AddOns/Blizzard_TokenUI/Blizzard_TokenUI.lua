UIPanelWindows["TokenFrame"] = { area = "left", pushable = 1, whileDead = 1 };
BACKPACK_TOKENFRAME_HEIGHT = 22;

function TokenFrame_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("TokenButtonTemplate", function(button, elementData)
		TokenFrame_InitTokenButton(self, button, elementData);
	end);
	view:SetPadding(2,2,2,3,3);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function TokenFrame_InitTokenButton(self, button, elementData)
	button.Check:Hide();

	local index = elementData.index;
	local currencyInfo = C_CurrencyInfo.GetCurrencyListInfo(index);
	local name = currencyInfo.name;
	local isHeader = currencyInfo.isHeader;
	local isExpanded = currencyInfo.isHeaderExpanded;
	local isUnused = currencyInfo.isTypeUnused;
	local isWatched = currencyInfo.isShowInBackpack;
	local count = currencyInfo.quantity;
	local icon = currencyInfo.iconFileID;
	if ( isHeader ) then
		button.CategoryLeft:Show();
		button.CategoryRight:Show();
		button.CategoryMiddle:Show();
		button.ExpandIcon:Show();
		button.Count:SetText("");
		button.Icon:SetTexture("");
		if ( isExpanded ) then
			button.ExpandIcon:SetTexCoord(0.5625, 1, 0, 0.4375);
		else
			button.ExpandIcon:SetTexCoord(0, 0.4375, 0, 0.4375);
		end
		button.Highlight:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton");
		button.Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -2);
		button.Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 2);
		button.Name:SetText(name);
		button.Name:SetFontObject("GameFontNormal");
		button.Name:SetPoint("LEFT", 22, 0);
		button.LinkButton:Hide();
	else
		button.CategoryLeft:Hide();
		button.CategoryRight:Hide();
		button.CategoryMiddle:Hide();
		button.ExpandIcon:Hide();
		button.Count:SetText(BreakUpLargeNumbers(count));
		button.Icon:SetTexture(icon);
		if ( isWatched ) then
			button.Check:Show();
		end
		button.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
		button.Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
		button.Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
		--Gray out the text if the count is 0
		if ( count == 0 ) then
			button.Count:SetFontObject("GameFontDisable");
			button.Name:SetFontObject("GameFontDisable");
		else
			button.Count:SetFontObject("GameFontHighlight");
			button.Name:SetFontObject("GameFontHighlight");
		end
		button.Name:SetText(name);
		button.Name:SetPoint("LEFT", 11, 0);
		button.LinkButton:Show();
	end

	--Manage highlight
	if ( name == TokenFrame.selectedToken ) then
		TokenFrame.selectedID = index;
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end

	button.index = index;
	button.isHeader = isHeader;
	button.isExpanded = isExpanded;
	button.isUnused = isUnused;
	button.isWatched = isWatched;
	button.Stripe:SetShown(elementData.index % 2 == 1);
end

function TokenFrame_OnShow(self)
	SetButtonPulse(CharacterFrameTab3, 0, 1); --Stop the button pulse
	CharacterFrame:SetTitle(UnitPVPName("player"));

	local resetScrollPosition = true;
	TokenFrame_Update(resetScrollPosition);
end

function TokenFrame_Update(resetScrollPosition)
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();
	CharacterFrameTab3:SetShown(numTokenTypes > 0);

	local newDataProvider = CreateDataProviderByIndexCount(numTokenTypes);
	CharacterFrame.TokenFrame.ScrollBox:SetDataProvider(newDataProvider, not resetScrollPosition and ScrollBoxConstants.RetainScrollPosition);
end

function TokenFramePopup_CloseIfHidden()
	-- This handles the case where you close a category with the selected token popup shown
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();
	local selectedFound;
	for i=1, numTokenTypes do
		if ( TokenFrame.selectedToken == C_CurrencyInfo.GetCurrencyListInfo(i).name ) then
			selectedFound = 1;
		end
	end
	if ( not selectedFound ) then
		TokenFramePopup:Hide();
	end
end

function GetNumWatchedTokens()
	return BackpackTokenFrame:GetNumWatchedTokens();
end

function TokenButton_OnClick(self)
	if ( self.isHeader ) then
		C_CurrencyInfo.ExpandCurrencyList(self.index, not self.isExpanded);
	else
		TokenFrame.selectedToken = self.Name:GetText();
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyListLink(self.index));
		end
		if ( not linkedToChat ) then
			if ( IsModifiedClick("TOKENWATCHTOGGLE") ) then
				TokenFrame.selectedID = self.index;
				local watched = not self.isWatched;
				local success = TokenFrame_SetTokenWatched(TokenFrame.selectedID, watched);
				if success then
					self.isWatched = watched;
				end

				if ( TokenFrame.selectedID == self.index ) then
					TokenFrame_UpdatePopup(self);
				end
			else
				local showPopup = not TokenFramePopup:IsShown() or TokenFrame.selectedID ~= self.index;
				TokenFramePopup:SetShown(showPopup);

				if showPopup then
					TokenFrame.selectedID = self.index;
					TokenFrame_UpdatePopup(self);
				end
			end
		end
	end
	TokenFrame_Update();
	TokenFramePopup_CloseIfHidden();
end

function TokenFrame_UpdatePopup(button)
	TokenFramePopup.InactiveCheckBox:SetChecked(button.isUnused);
	TokenFramePopup.BackpackCheckBox:SetChecked(button.isWatched);
end

InactiveCurrencyCheckBoxMixin = {};

function InactiveCurrencyCheckBoxMixin:OnLoad()
	self.Text:SetText(UNUSED);
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function InactiveCurrencyCheckBoxMixin:OnClick()
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

	TokenFrame_Update();
	TokenFramePopup_CloseIfHidden();
end

function InactiveCurrencyCheckBoxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, TOKEN_MOVE_TO_UNUSED);
	GameTooltip:Show();
end

BackpackCurrencyCheckBoxMixin = {};

function BackpackCurrencyCheckBoxMixin:OnLoad()
	self.Text:SetText(SHOW_ON_BACKPACK);
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function BackpackCurrencyCheckBoxMixin:OnClick()
	local watched = self:GetChecked();
	TokenFrame_SetTokenWatched(TokenFrame.selectedID, watched);

	if watched then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function BackpackCurrencyCheckBoxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, TOKEN_SHOW_ON_BACKPACK);
	GameTooltip:Show();
end

function TokenFrame_SetTokenWatched(id, watched)
	C_CurrencyInfo.SetCurrencyBackpack(id, watched);
	TokenFrame_Update();
	BackpackTokenFrame:Update();
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

			self.shouldShow = true;
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

	-- You can always track at least one token
	return math.max(math.floor(self:GetWidth() / self.tokenWidth), 1);
end

BackpackTokenMixin = {};

function BackpackTokenMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBackpackToken(self:GetID());
end

function BackpackTokenMixin:OnLeave()
	GameTooltip:Hide();
end

function BackpackTokenMixin:OnClick()
	if IsModifiedClick("CHATLINK") then
		HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyLink(self.currencyID));
	else
		CharacterFrame_ToggleTokenFrame();
	end
end