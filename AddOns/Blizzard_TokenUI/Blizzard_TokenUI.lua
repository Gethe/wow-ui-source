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
	self.categoryLeft = _G[name.."CategoryLeft"];
	self.categoryRight = _G[name.."CategoryRight"];
	self.highlight = _G[name.."Highlight"];
	self.stripe = _G[name.."Stripe"];
end

function TokenFrame_OnLoad()
	TokenFrameContainerScrollBar.Show = 
		function (self)
			TokenFrameContainer:SetWidth(299);
			for _, button in next, _G["TokenFrameContainer"].buttons do
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

function TokenFrame_OnShow(self)
	SetButtonPulse(CharacterFrameTab5, 0, 1);	--Stop the button pulse
	TokenFrame_Update();
end

function TokenFrame_Update()

	-- Setup the buttons
	local scrollFrame = TokenFrameContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numTokenTypes = GetCurrencyListSize();
	local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID;
	local button, index;
	for i=1, numButtons do
		index = offset+i;
		name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(index);

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
				button.itemID = nil;
				button.LinkButton:Hide();
			else
				button.categoryLeft:Hide();
				button.categoryRight:Hide();
				button.expandIcon:Hide();
				button.count:SetText(count);
				button.extraCurrencyType = extraCurrencyType;
				if ( extraCurrencyType == 1 ) then	--Arena points
					button.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
					button.icon:SetTexCoord(0, 1, 0, 1);
				elseif ( extraCurrencyType == 2 ) then --Honor points
					local factionGroup = UnitFactionGroup("player");
					if ( factionGroup ) then
						button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
						button.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
					else
						button.icon:Hide() --We don't know their faction yet!
						button.icon:SetTexCoord(0, 1, 0, 1);
					end
				else
					button.icon:SetTexture(icon);
					button.icon:SetTexCoord(0, 1, 0, 1);
				end
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
				button.itemID = itemID;
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
	
	if ( numTokenTypes == 0 ) then
		CharacterFrameTab5:Hide();
	else
		CharacterFrameTab5:Show();
	end
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
	local watchButton;
	local name, count, extraCurrencyType, icon;
	for i=1, MAX_WATCHED_TOKENS do
		name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i);
		-- Update watched tokens
		if ( name ) then
			watchButton = _G["BackpackTokenFrameToken"..i];
			watchButton.extraCurrencyType = extraCurrencyType;
			if ( extraCurrencyType == 1 ) then	--Arena points
				watchButton.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
				watchButton.icon:SetTexCoord(0, 1, 0, 1);
			elseif ( extraCurrencyType == 2 ) then --Honor points
				local factionGroup = UnitFactionGroup("player");
				if ( factionGroup ) then
					watchButton.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
					watchButton.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
				else
					watchButton.icon:SetTexCoord(0, 1, 0, 1);
				end
			else
				watchButton.icon:SetTexture(icon);
				watchButton.icon:SetTexCoord(0, 1, 0, 1);
			end
			if ( count <= 99999 ) then
				watchButton.count:SetText(count);
			else
				watchButton.count:SetText("*");
			end
			watchButton:Show();
			BackpackTokenFrame.shouldShow = 1;
			BackpackTokenFrame.numWatchedTokens = i;
			watchButton.itemID = itemID;
		else
			_G["BackpackTokenFrameToken"..i]:Hide();
			if ( i == 1 ) then
				BackpackTokenFrame.shouldShow = nil;
			end
			_G["BackpackTokenFrameToken"..i].itemID = nil;
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
				self.isWatched = false;
			else
				-- Set an error message if trying to show too many quests
				if ( GetNumWatchedTokens() >= MAX_WATCHED_TOKENS ) then
					UIErrorsFrame:AddMessage(format(TOO_MANY_WATCHED_TOKENS, MAX_WATCHED_TOKENS), 1.0, 0.1, 0.1, 1.0);
					return;
				end
				SetCurrencyBackpack(TokenFrame.selectedID, 1);
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
	TokenFrame_Update();
	TokenFramePopup_CloseIfHidden();
end

function TokenFrame_UpdatePopup(button)
	TokenFramePopupInactiveCheckBox:SetChecked(button.isUnused);
	TokenFramePopupBackpackCheckBox:SetChecked(button.isWatched);
end

function TokenButtonLinkButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		ChatEdit_InsertLink(select(2, GetItemInfo(self:GetParent().itemID)));
	end
end

function BackpackTokenButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		ChatEdit_InsertLink(select(2, GetItemInfo(self.itemID)));
	end
end
