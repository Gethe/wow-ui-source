SOR_AVAILABLE_LIST = {};

function ScrollOfResurrectionButton_OnClick(self)
	StaticPopupSpecial_Show(ScrollOfResurrectionSelectionFrame);
end

function ScrollOfResurrection_Show(sendType, target, text)
	ScrollOfResurrectionFrame.type = sendType;
	ScrollOfResurrectionFrame.target = target;
	ScrollOfResurrectionFrame.text = text;
	ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:SetText(SOR_DEFAULT_MESSAGE);
	
	StaticPopupSpecial_Show(ScrollOfResurrectionFrame);
	
	if ( ScrollOfResurrectionFrame.type == "email" and not target ) then
		ScrollOfResurrectionFrame.targetEditBox:Show();
		ScrollOfResurrectionFrame.targetEditBox:SetText("");
		ScrollOfResurrectionFrame.targetEditBox:SetFocus();
		ScrollOfResurrectionFrame.name:Hide();
	else
		ScrollOfResurrectionFrame.targetEditBox:Hide();
		ScrollOfResurrectionFrame.name:Show();
		ScrollOfResurrectionFrame.name:SetText(text);
		ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:SetFocus();
	end
end

function ScrollOfResurrectionAcceptButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local comment = ScrollOfResurrectionFrame.noteFrame.scrollFrame.editBox:GetText();
	if ( ScrollOfResurrectionFrame.type == "bn" ) then
		BNSendSoR(ScrollOfResurrectionFrame.target, comment);
	elseif ( ScrollOfResurrectionFrame.type == "guild" ) then
		GuildRosterSendSoR(ScrollOfResurrectionFrame.target, comment);
	elseif ( ScrollOfResurrectionFrame.type == "email" ) then
		SendSoRByText(ScrollOfResurrectionFrame.target or ScrollOfResurrectionFrame.targetEditBox:GetText(), comment);
	end
	StaticPopupSpecial_Hide(ScrollOfResurrectionFrame);
	UIErrorsFrame:AddMessage(SOR_SUCCESSFULLY_SENT, 1.0, 1.0, 0.0, 1.0);
end

function ScrollOfResurrectionSelection_OnLoad(self)
	self.list.scrollFrame.scrollBar.trackBG:Hide();
	self.list.scrollFrame.scrollBar.doNotHide = true;
	self.list.scrollFrame.update = ScrollOfResurrectionSelectionList_Update;
	self.exclusive = true;
	self.hideOnEscape = true;
	HybridScrollFrame_CreateButtons(self.list.scrollFrame, "ScrollOfResurrectionSelectionButtonTemplate");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("SOR_COUNTS_UPDATED");
end

function ScrollOfResurrectionSelection_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" and self.awaitingRosterUpdate ) then
		self.awaitingRosterUpdate = false;
		ScrollOfResurrectionSelection_RebuildEligibleList();
	elseif ( event == "SOR_COUNTS_UPDATED" ) then
		ScrollOfResurrectionSelectionList_Update();
	end
end

function ScrollOfResurrectionSelection_OnShow(self)
	PlaySound("igSpellBookOpen");
	ScrollOfResurrectionSelectionFrame.sendType = nil;
	ScrollOfResurrectionSelectionFrame.target = nil;
	ScrollOfResurrectionSelectionFrame.text = nil;
	ScrollOfResurrectionSelectionFrame.targetEditBox:SetText("");
	ScrollOfResurrectionSelection_RebuildEligibleList();

	--Request the guild roster info in case we don't have it yet.
	if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
		GuildRoster();
		self.awaitingRosterUpdate = true;
	end
end

function ScrollOfResurrectionSelectionList_Update()
	local numRemaining = GetNumSoRRemaining();
	local scrollFrame = ScrollOfResurrectionSelectionFrame.list.scrollFrame;

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	local numEntries = #SOR_AVAILABLE_LIST / 3;

	local totalScrollHeight = numEntries * buttons[1]:GetHeight();
	local displayedHeight = 0;

	for i=1, numButtons do
		local button = buttons[i];
		local index = offset + i;

		local name = SOR_AVAILABLE_LIST[(index-1) * 3 + 1];
		local target = SOR_AVAILABLE_LIST[(index-1) * 3 + 2];
		local sendType = SOR_AVAILABLE_LIST[(index-1) * 3 + 3];

		if ( name ) then
			button:Show();
			button.name:SetText(name);

			button.text = name;
			button.target = target;
			button.sendType = sendType;

			if ( numRemaining == 0 ) then
				button.name:SetFontObject(GameFontDisable);
				button:Disable();
			elseif ( button.target == ScrollOfResurrectionSelectionFrame.target and
				 button.sendType == ScrollOfResurrectionSelectionFrame.sendType ) then
				--This button is selected
				button:Enable();
				button.name:SetFontObject(GameFontHighlight);
				button.highlight:SetVertexColor(1, 0.824, 0);
				button:LockHighlight();
			else
				button:Enable();
				button.name:SetFontObject(GameFontNormal);
				button.highlight:SetVertexColor(0.243, 0.570, 1);
				button:UnlockHighlight();
			end

			displayedHeight = displayedHeight + button:GetHeight();
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, totalScrollHeight, displayedHeight);	

	--Update the check marks.
	local sendType = ScrollOfResurrectionSelectionFrame.sendType;
	if ( sendType == "bn" or sendType == "guild" ) then
		ScrollOfResurrectionSelectionFrame.selectionCheck:Show();
		ScrollOfResurrectionSelectionFrame.instructionEmail:SetAlpha(0.5);
	else
		ScrollOfResurrectionSelectionFrame.selectionCheck:Hide();
		ScrollOfResurrectionSelectionFrame.instructionEmail:SetAlpha(1);
	end

	if ( sendType == "email" ) then
		ScrollOfResurrectionSelectionFrame.emailCheck:Show();
		ScrollOfResurrectionSelectionFrame.instructionSelect:SetAlpha(0.5);
	else
		ScrollOfResurrectionSelectionFrame.emailCheck:Hide();
		ScrollOfResurrectionSelectionFrame.instructionSelect:SetAlpha(1);
	end

	--Update the limit display.
	if ( numRemaining >= 0 ) then
		ScrollOfResurrectionSelectionFrame.limit:Show();
		ScrollOfResurrectionSelectionFrame.limit:SetFormattedText(SOR_NUM_REMAINING, numRemaining);
	else
		ScrollOfResurrectionSelectionFrame.limit:Hide();
	end

	if ( numRemaining == 0 ) then
		ScrollOfResurrectionSelectionFrame.limit:SetFontObject(GameFontRed);

		--Override what was set above to look disabled.
		ScrollOfResurrectionSelectionFrame.emailCheck:Hide();
		ScrollOfResurrectionSelectionFrame.selectionCheck:Hide();
		ScrollOfResurrectionSelectionFrame.instructionEmail:SetAlpha(0.5);
		ScrollOfResurrectionSelectionFrame.instructionSelect:SetAlpha(0.5);
		ScrollOfResurrectionSelectionFrame.targetEditBox:Disable();

		--Update the Accept button
		ScrollOfResurrectionSelectionFrame.acceptButton.disableText = SOR_DISABLE_NO_INVITES_LEFT;
		ScrollOfResurrectionSelectionFrame.acceptButton:Disable();
	else
		ScrollOfResurrectionSelectionFrame.limit:SetFontObject(GameFontNormal);
		ScrollOfResurrectionSelectionFrame.targetEditBox:Enable();

		--Update the Accept button
		if ( not sendType or not ScrollOfResurrectionSelectionFrame.target ) then
			ScrollOfResurrectionSelectionFrame.acceptButton.disableText = SOR_DISABLE_CHOOSE_A_TARGET;
			ScrollOfResurrectionSelectionFrame.acceptButton:Disable();
		else
			ScrollOfResurrectionSelectionFrame.acceptButton.disableText = nil;
			ScrollOfResurrectionSelectionFrame.acceptButton:Enable();
		end
	end
end

function ScrollOfResurrectionSelectionButton_OnClick(self)
	ScrollOfResurrectionSelectionFrame.sendType = self.sendType;
	ScrollOfResurrectionSelectionFrame.target = self.target;
	ScrollOfResurrectionSelectionFrame.text = self.text;
	ScrollOfResurrectionSelectionFrame.targetEditBox:ClearFocus();
	ScrollOfResurrectionSelectionFrame.targetEditBox:SetText("");
	ScrollOfResurrectionSelectionList_Update();
end

function ScrollOfResurrectionSelection_RebuildEligibleList()
	SOR_AVAILABLE_LIST = {};
	--First, add RID friends:
	for i=1, BNGetNumFriends() do
		local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(i);
		if ( canSoR ) then
			tinsert(SOR_AVAILABLE_LIST, presenceName);
			tinsert(SOR_AVAILABLE_LIST, presenceID);
			tinsert(SOR_AVAILABLE_LIST, "bn");
		end
	end

	--Now, add guild members:
	for i=1, GetNumGuildMembers() do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName, achievementPoints, achievementRank, isMobile, canSoR = GetGuildRosterInfo(i);
		if ( canSoR ) then
			tinsert(SOR_AVAILABLE_LIST, name);
			tinsert(SOR_AVAILABLE_LIST, i);
			tinsert(SOR_AVAILABLE_LIST, "guild");
		end
	end

	--Update the display.
	ScrollOfResurrectionSelectionList_Update();
end
