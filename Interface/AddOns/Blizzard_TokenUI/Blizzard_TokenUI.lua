UIPanelWindows["TokenFrame"] = { area = "left", pushable = 1, whileDead = 1 };
TOKEN_BUTTON_OFFSET = 3;
MAX_WATCHED_TOKENS = 3;
BACKPACK_TOKENFRAME_HEIGHT = 22;

-- REMOVE ME!!!
SlashCmdList["TOKENUI"] = function() ToggleCharacter("TokenFrame"); end;

function TokenButton_OnLoad(self)
	local name = self:GetName();
	self.count = _G[name.."Count"];
	self.name = _G[name.."Name"];
	self.icon = _G[name.."Icon"];
	self.check = _G[name.."Check"];
	self.expandIcon = _G[name.."ExpandIcon"];
	self.highlight = _G[name.."Highlight"];
	self.stripe = _G[name.."Stripe"];
end

function TokenFrame_OnLoad(self)
	self.Container.scrollBar.Show =
		function (self)
			TokenFrameContainer:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -23, 4);
			for _, button in next, _G["TokenFrameContainer"].buttons do
				button:SetWidth(295);
			end
			TokenFrameContainer.scrollChild:SetWidth(295);
			getmetatable(self).__index.Show(self);
		end

	self.Container.scrollBar.Hide =
		function (self)
			TokenFrameContainer:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -4, 4);
			for _, button in next, TokenFrameContainer.buttons do
				button:SetWidth(317);
			end
			TokenFrameContainer.scrollChild:SetWidth(317);
			getmetatable(self).__index.Hide(self);
		end
	TokenFrameContainer.update = TokenFrame_Update;
end

function TokenFrame_OnShow(self)

	-- Create buttons if not created yet
	if (not self.Container.buttons) then
		-- if the currency frame was opened via a keybind before the character frame was opened, CharacterFrame.Inset would not exist during the TokenUI addon load
		self.Container:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 4, -4);
		self.Container:SetWidth(328);
		self.Container:SetHeight(360);
		HybridScrollFrame_CreateButtons(self.Container, "TokenButtonTemplate", 1, -2, "TOPLEFT", "TOPLEFT", 0, -TOKEN_BUTTON_OFFSET);
		local buttons = self.Container.buttons;
		local numButtons = #buttons;
		for i=1, numButtons do
			if ( mod(i, 2) == 1 ) then
				buttons[i].stripe:Hide();
			end
		end
	end

	SetButtonPulse(CharacterFrameTab3, 0, 1);	--Stop the button pulse
	CharacterFrame:SetTitle(UnitPVPName("player"));
	TokenFrame_Update();
end

function TokenFrame_Update()
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();

	if ( numTokenTypes == 0 ) then
		CharacterFrameTab3:Hide();
	else
		CharacterFrameTab3:Show();
	end

	if (not TokenFrameContainer.buttons) then
		return;
	end

	-- Setup the buttons
	local scrollFrame = TokenFrameContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local name, isHeader, isExpanded, isUnused, isWatched, count, icon;
	local button, index;
	for i=1, numButtons do
		index = offset+i;
		local currencyInfo = C_CurrencyInfo.GetCurrencyListInfo(index);
		button = buttons[i];
		button.check:Hide();
		if ( not currencyInfo or not currencyInfo.name or currencyInfo.name == "" ) then
			button:Hide();
		else
			name = currencyInfo.name;
			isHeader = currencyInfo.isHeader;
			isExpanded = currencyInfo.isHeaderExpanded;
			isUnused = currencyInfo.isTypeUnused;
			isWatched = currencyInfo.isShowInBackpack;
			count = currencyInfo.quantity;
			icon = currencyInfo.iconFileID;
			if ( isHeader ) then
				button.categoryLeft:Show();
				button.categoryRight:Show();
				button.categoryMiddle:Show();
				button.expandIcon:Show();
				button.count:SetText("");
				button.icon:SetTexture("");
				if ( isExpanded ) then
					button.expandIcon:SetTexCoord(0.5625, 1, 0, 0.4375);
				else
					button.expandIcon:SetTexCoord(0, 0.4375, 0, 0.4375);
				end
				button.highlight:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton");
				button.highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -2);
				button.highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 2);
				button.name:SetText(name);
				button.name:SetFontObject("GameFontNormal");
				button.name:SetPoint("LEFT", 22, 0);
				button.LinkButton:Hide();
			else
				button.categoryLeft:Hide();
				button.categoryRight:Hide();
				button.categoryMiddle:Hide();
				button.expandIcon:Hide();
				button.count:SetText(BreakUpLargeNumbers(count));
				button.icon:SetTexture(icon);
				if ( isWatched ) then
					button.check:Show();
				end
				button.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
				button.highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
				button.highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
				--Gray out the text if the count is 0
				if ( count == 0 ) then
					button.count:SetFontObject("GameFontDisable");
					button.name:SetFontObject("GameFontDisable");
				else
					button.count:SetFontObject("GameFontHighlight");
					button.name:SetFontObject("GameFontHighlight");
				end
				button.name:SetText(name);
				button.name:SetPoint("LEFT", 11, 0);
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
			button:Show();
		end
	end
	local totalHeight = numTokenTypes * (button:GetHeight()+TOKEN_BUTTON_OFFSET);
	local displayedHeight = #buttons * (button:GetHeight()+TOKEN_BUTTON_OFFSET);

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
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

function BackpackTokenFrame_Update()
	for i=1, MAX_WATCHED_TOKENS do
		local watchButton = BackpackTokenFrame.Tokens[i];
		local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(i);

		if currencyInfo then
			local count = currencyInfo.quantity;
			watchButton.icon:SetTexture(currencyInfo.iconFileID);

			local currencyText = BreakUpLargeNumbers(count);
			if strlenutf8(currencyText) > 5 then
				currencyText = AbbreviateNumbers(count);
			end

			watchButton.count:SetText(currencyText);
			watchButton.currencyID = currencyInfo.currencyTypesID;
			watchButton:Show();

			BackpackTokenFrame.shouldShow = true;
			BackpackTokenFrame.numWatchedTokens = i;
		else
			watchButton:Hide();
			if i == 1 then
				BackpackTokenFrame.shouldShow = nil;
			end
		end
	end
end

function GetNumWatchedTokens()
	if ( not BackpackTokenFrame.numWatchedTokens ) then
		-- No count yet so get it
		BackpackTokenFrame_Update();
	end
	return BackpackTokenFrame.numWatchedTokens or 0;
end

function BackpackTokenFrame_IsShown()
	return BackpackTokenFrame.shouldShow;
end

function ManageBackpackTokenFrame(backpack)
	if ( not backpack ) then
		backpack = GetBackpackFrame();
	end
	if ( not backpack ) then
		-- If still no backpack then we don't show the frame
		BackpackTokenFrame:Hide();
		return;
	end
	if ( BackpackTokenFrame_IsShown() ) then
		BackpackTokenFrame:SetParent(backpack);
		BackpackTokenFrame:SetPoint("BOTTOMLEFT", backpack, "BOTTOMLEFT", 9, 0);
		backpack:SetHeight(BACKPACK_HEIGHT+BACKPACK_TOKENFRAME_HEIGHT);
		BackpackTokenFrame:Show();
	else
		backpack:SetHeight(BACKPACK_HEIGHT);
		BackpackTokenFrame:Hide();
	end
end

function TokenButton_OnClick(self)
	if ( self.isHeader ) then
		if ( self.isExpanded ) then
			C_CurrencyInfo.ExpandCurrencyList(self.index, false);
		else
			C_CurrencyInfo.ExpandCurrencyList(self.index, true);
		end
	else
		TokenFrame.selectedToken = self.name:GetText();
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_CurrencyInfo.GetCurrencyListLink(self.index));
		end
		if ( not linkedToChat ) then
			if ( IsModifiedClick("TOKENWATCHTOGGLE") ) then
				TokenFrame.selectedID = self.index;
				if ( self.isWatched ) then
					C_CurrencyInfo.SetCurrencyBackpack(TokenFrame.selectedID, false);
					self.isWatched = false;
				else
					-- Set an error message if trying to show too many quests
					if ( GetNumWatchedTokens() >= MAX_WATCHED_TOKENS ) then
						UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0);
						return;
					end
					C_CurrencyInfo.SetCurrencyBackpack(TokenFrame.selectedID, true);
					self.isWatched = true;
				end
				if ( TokenFrame.selectedID == self.index ) then
					TokenFrame_UpdatePopup(self);
				end
				BackpackTokenFrame_Update();
				ManageBackpackTokenFrame();
			else

				if ( TokenFramePopup:IsShown() ) then
					if ( TokenFrame.selectedID == self.index ) then
						TokenFramePopup:Hide();
					else
						TokenFramePopup:Show();
					end
				else
					TokenFramePopup:Show();
				end
				TokenFrame.selectedID = self.index;
				TokenFrame_UpdatePopup(self);
			end
		end
	end
	TokenFrame_Update();
	TokenFramePopup_CloseIfHidden();
end

function TokenFrame_UpdatePopup(button)
	TokenFramePopupInactiveCheckBox:SetChecked(button.isUnused);
	TokenFramePopupBackpackCheckBox:SetChecked(button.isWatched);
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
	BackpackTokenFrame_Update();
	ManageBackpackTokenFrame();
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
	if ( self:GetChecked() ) then
		if ( GetNumWatchedTokens() >= MAX_WATCHED_TOKENS ) then
			UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0);
			self:SetChecked(false);
			return;
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		C_CurrencyInfo.SetCurrencyBackpack(TokenFrame.selectedID, true);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		C_CurrencyInfo.SetCurrencyBackpack(TokenFrame.selectedID, false);
	end
	TokenFrame_Update();
	BackpackTokenFrame_Update();
	ManageBackpackTokenFrame();
end

function BackpackCurrencyCheckBoxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, TOKEN_SHOW_ON_BACKPACK);
	GameTooltip:Show();
end
