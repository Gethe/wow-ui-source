UIPanelWindows["TokenFrame"] = { area = "left", pushable = 1, whileDead = 1 };
TOKEN_BUTTON_OFFSET = 3;
MAX_WATCHED_TOKENS = 4;
BACKPACK_TOKENFRAME_HEIGHT = 22;

-- REMOVE ME!!!
SlashCmdList["TOKENUI"] = function() ToggleFrame(TokenFrame) end;

function TokenButton_OnLoad(self)
	local name = self:GetName();
	self.count = getglobal(name.."Count");
	self.name = getglobal(name.."Name");
	self.icon = getglobal(name.."Icon");
	self.check = getglobal(name.."Check");
	self.expandIcon = getglobal(name.."ExpandIcon");
	self.categoryLeft = getglobal(name.."CategoryLeft");
	self.categoryRight = getglobal(name.."CategoryRight");
	self.highlight = getglobal(name.."Highlight");
	self.stripe = getglobal(name.."Stripe");
end

function TokenFrame_OnLoad()
	TokenFrameContainerScrollBar.Show = 
		function (self)
			TokenFrameContainer:SetWidth(299);
			for _, button in next, getglobal("TokenFrameContainer").buttons do
				button:SetWidth(295);
			end
			getmetatable(self).__index.Show(self);
		end
		
	TokenFrameContainerScrollBar.Hide = 
		function (self)
			TokenFrameContainer:SetWidth(313);
			for _, button in next, TokenFrameContainer.buttons do
				button:SetWidth(313);
			end
			getmetatable(self).__index.Hide(self);
		end
	TokenFrameContainer.update = TokenFrame_Update;
	HybridScrollFrame_CreateButtons(TokenFrameContainer, "TokenButtonTemplate", 0, -2, "TOPLEFT", "TOPLEFT", 0, -TOKEN_BUTTON_OFFSET);
	local buttons = TokenFrameContainer.buttons;
	local numButtons = #buttons;
	for i=1, numButtons do
		if ( mod(i, 2) == 1 ) then
			buttons[i].stripe:Hide();
		end
	end
end

function TokenFrame_Update()
	if ( not GetCVarBool("showTokenFrame") ) then
		return;
	end
	
	-- Setup honor and arena points
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		TokenFrameHonorFrameHonorIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
	end
	TokenFrameHonorFrameHonor:SetText(GetHonorCurrency());
	TokenFrameHonorFrameArena:SetText(GetArenaCurrency());

	-- Setup the buttons
	local scrollFrame = TokenFrameContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numTokenTypes = GetCurrencyListSize();
	local name, isHeader, isExpanded, isUnused, isWatched, count, icon;
	local button, index;
	for i=1, numButtons do
		index = offset+i;
		name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(index);
		--[[ TEST STUFF
		name = "test"
		isHeader = nil;
		isExpanded = nil;
		isUnused = nil;
		isWatched = nil;
		count = 23
		icon = "";
		]]

		button = buttons[i];
		button.check:Hide();
		if ( not name or name == "" ) then
			button:Hide();
		else
			if ( isHeader ) then
				button.categoryLeft:Show();
				button.categoryRight:Show();
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
				button:SetText(name);
				button.name:SetText("");
			else
				button.categoryLeft:Hide();
				button.categoryRight:Hide();
				button.expandIcon:Hide();
				button.count:SetText(count);
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
				button:SetText("");
				button.name:SetText(name);
			end
			--Manage highlight
			if ( name == TokenFrame.selectedToken ) then
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

	HybridScrollFrame_Update(scrollFrame, numTokenTypes, totalHeight, displayedHeight);
end

function TokenFramePopup_CloseIfHidden()
	-- This handles the case where you close a category with the selected token popup shown
	local numTokenTypes = GetCurrencyListSize();
	local selectedFound;
	for i=1, numTokenTypes do
		if ( TokenFrame.selectedToken == GetCurrencyListInfo(i) ) then
			selectedFound = 1;
		end
	end
	if ( not selectedFound ) then
		TokenFramePopup:Hide();
	end
end

function BackpackTokenFrame_Update()
	local watchIndex = 1;
	local watchButton;
	local numTokenTypes = GetCurrencyListSize();
	for i=1, numTokenTypes do
		name, isHeader, _, _, isWatched, count, icon = GetCurrencyListInfo(i);
		-- Update watched tokens
		if ( isWatched and watchIndex <= MAX_WATCHED_TOKENS ) then
			watchButton = getglobal("BackpackTokenFrameToken"..watchIndex);
			watchButton.icon:SetTexture(icon);
			watchButton.count:SetText("x"..count);
			watchButton.index = i;
			watchButton:Show();
			watchIndex = watchIndex+1;
		end
	end
	-- Hide unhidden token buttons
	for i=watchIndex, MAX_WATCHED_TOKENS do
		getglobal("BackpackTokenFrameToken"..i):Hide();
	end
	if ( watchIndex == 1 ) then
		-- No tokens are being watched so hide the backpack bar
		BackpackTokenFrame.shouldShow = nil;
	else
		-- Tokens are shown so show the backpack bar
		BackpackTokenFrame.shouldShow = 1;
	end
	BackpackTokenFrame.numWatchedTokens = watchIndex-1;
end

function GetNumWatchedTokens()
	if ( not BackpackTokenFrame.numWatchedTokens ) then
		-- No count yet so get it
		BackpackTokenFrame_Update();
	end
	return BackpackTokenFrame.numWatchedTokens;
end

function BackpackTokenFrame_IsShown()
	return BackpackTokenFrame.shouldShow;
end

function ManageBackpackTokenFrame(backpack)
	if ( not backpack ) then
		backpack = GetBackpackFrame();
	end
	if ( not backpack ) then
		-- If still no backpack then don't worry about it
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
			ExpandCurrencyList(self.index, 0);
		else
			ExpandCurrencyList(self.index, 1);
		end
	else
		TokenFrame.selectedToken = self.name:GetText();
		if ( IsModifiedClick("TOKENWATCHTOGGLE") ) then
			TokenFrame.selectedID = self.index;
			if ( self.isWatched ) then
				SetCurrencyBackpack(TokenFrame.selectedID, 0);
			else
				-- Set an error message if trying to show too many quests
				if ( GetNumWatchedTokens() >= MAX_WATCHED_TOKENS ) then
					UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0);
					return;
				end
				SetCurrencyBackpack(TokenFrame.selectedID, 1);
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
	TokenFrame_Update();
	TokenFramePopup_CloseIfHidden();
end

function TokenFrame_UpdatePopup(button)
	TokenFramePopupInactiveCheckBox:SetChecked(button.isUnused);
	TokenFramePopupBackpackCheckBox:SetChecked(button.isWatched);
end
