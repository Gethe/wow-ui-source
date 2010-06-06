BN_CONVERSATION_INVITE_HEIGHT = 22;
BN_CONVERSATION_INVITE_NUM_DISPLAYED = 7;
BN_CONVERSATION_MAX_CHANNEL_MEMBERS = 6;

function BNConversationInviteDialog_OnLoad(self)
	-- special popup dialog settings
	self.hideOnEscape = true;
	self.exclusive = true;
	
	BNConversationInvite_Reset();
end

function BNConversationInviteListCheckButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( self:GetChecked() ) then
		BNConversationInvite_Select(parent.id);
	else
		BNConversationInvite_Deselect(parent.id);
	end
end

function BNConversationInvite_SelectPlayers(conversationID)
	BNConversationInvite_SetMode("invite", conversationID);
	
	BNConversationInvite_Reset();
	StaticPopupSpecial_Show(BNConversationInviteDialog);
end

function BNConversationInvite_NewConversation(selected1, selected2)
	BNConversationInvite_SetMode("create");
	
	BNConversationInvite_Reset();
	
	if ( selected1 ) then
		BNConversationInvite_Select(selected1);
	end
	if ( selected2 ) then
		BNConversationInvite_Select(selected2);
	end
	
	StaticPopupSpecial_Show(BNConversationInviteDialog);
end

function BNConversationInvite_Reset()
	BNConversationInviteDialog.inviteTargets = {};	--Probably better to eat the gc than table.wipe in this case.
end

function BNConversationInvite_SetMode(mode, target)
	local frame = BNConversationInviteDialog;
	frame.mode = mode;
	frame.target = target;
	
	if ( mode == "create" ) then
		frame.instructionText:SetText(NEW_CONVERSATION_INSTRUCTIONS);
		BNConversationInvite_SetMinMaxInvites(2, 2);
	elseif ( mode == "invite" ) then
		local maxInvites = BN_CONVERSATION_MAX_CHANNEL_MEMBERS - BNGetNumConversationMembers(target);
		frame.instructionText:SetFormattedText(INVITE_CONVERSATION_INSTRUCTIONS, maxInvites);
		BNConversationInvite_SetMinMaxInvites(1, maxInvites);
	else
		error("Unhandled invite type: "..tostring(mode));
	end
end

function BNConversationInvite_SetMinMaxInvites(minInvites, maxInvites)
	local frame = BNConversationInviteDialog;
	frame.minInvites = minInvites;
	frame.maxInvites = maxInvites;
end

function BNConversationInviteDialogInviteButton_OnClick(self, button)
	local inviteTargets = BNConversationInviteDialog.inviteTargets;
	if ( BNConversationInviteDialog.mode == "create" ) then
		BNCreateConversation(inviteTargets[1], inviteTargets[2]);
	elseif ( BNConversationInviteDialog.mode == "invite" ) then
		for _, player in pairs(inviteTargets) do
			BNInviteToConversation(BNConversationInviteDialog.target, player);
		end
	else
		error("Unhandled invite type: "..tostring(BNConversationInviteDialog.mode))
	end
	StaticPopupSpecial_Hide(BNConversationInviteDialog);
end

function BNConversationInvite_UpdateInviteButtonState()
	local dialog = BNConversationInviteDialog;
	local button = BNConversationInviteDialogInviteButton;
	
	if ( #dialog.inviteTargets < dialog.minInvites ) then
		button:Disable();
	else
		button:Enable();
	end
end

function BNConversationInvite_Select(player)
	local inviteTargets = BNConversationInviteDialog.inviteTargets;
	if ( not tContains(inviteTargets, player) ) then
		tinsert(inviteTargets, player);
	end
	BNConversationInvite_Update();
end

function BNConversationInvite_Deselect(player)
	local inviteTargets = BNConversationInviteDialog.inviteTargets;
	tDeleteItem(inviteTargets, player);
	BNConversationInvite_Update();
end

function BNConversationInvite_IsUnitInConversation(conversationID, player)
	for i=1, BNGetNumConversationMembers(conversationID) do
		local accountID, toonID, name = BNGetConversationMemberInfo(conversationID, i);
		if ( player == accountID or player == toonID ) then	--DEBUG FIXME: Make sure that's the actual player and not just another with the same name?
			return true;
		end
	end
	return false;
end

function BNConversationInvite_Update()
	local _, numBNetOnline = BNGetNumFriends();
	
	local offset = FauxScrollFrame_GetOffset(BNConversationInviteDialogListScrollFrame);
	
	for i=1, BN_CONVERSATION_INVITE_NUM_DISPLAYED do
		local index = i + offset;
		local frame = _G["BNConversationInviteDialogListFriend"..i];
		if ( index <= numBNetOnline ) then
			local friendIndex = index;
			local presenceID, givenName, surname = BNGetFriendInfo(friendIndex);
			frame.name:SetFormattedText(BATTLENET_NAME_FORMAT, givenName, surname);
			frame.id = presenceID;
			frame:Show();
		else
			frame:Hide();
		end
		
		frame.checkButton:SetChecked(tContains(BNConversationInviteDialog.inviteTargets, frame.id));
		
		if ( not frame.checkButton:GetChecked() and (	--Never disable a button that is already checked
				#BNConversationInviteDialog.inviteTargets >= BNConversationInviteDialog.maxInvites or	--Disable everything if we've checked the max amount
				(BNConversationInviteDialog.target and BNConversationInvite_IsUnitInConversation(BNConversationInviteDialog.target, frame.id)) ) ) then	--Disable if the person is already in this conversation
			frame.checkButton:Disable();
			frame.name:SetFontObject("GameFontDisable");
		else
			frame.checkButton:Enable();
			frame.name:SetFontObject("GameFontHighlight");
		end
		
	end
	
	BNConversationInvite_UpdateInviteButtonState();
	FauxScrollFrame_Update(BNConversationInviteDialogListScrollFrame, numBNetOnline, BN_CONVERSATION_INVITE_NUM_DISPLAYED, BN_CONVERSATION_INVITE_HEIGHT);
end

----Member list functions.
function BNConversationButton_OnLoad(self)
	self:RegisterEvent("BN_CHAT_CHANNEL_MEMBER_JOINED");
	self:RegisterEvent("BN_CHAT_CHANNEL_MEMBER_LEFT");
	self:RegisterEvent("BN_CHAT_CHANNEL_MEMBER_UPDATED");
	
	self.chatFrame = _G["ChatFrame"..self:GetID()];
	self.chatFrame.conversationButton = self;
	
	_G[self.roster:GetName().."Background"]:SetVertexColor(0.0, 0.0, 0.0, 0.4);
	
	BNConversationButton_UpdateAttachmentPoint(self);
	BNConversationButton_UpdateTarget(self);
	BNConversationButton_Update(self)
end

function BNConversationButton_OnEvent(self, event, ...)
	local chanIndex, presenceID = ...;
	if ( chanIndex == self.conversationID ) then
		BNConversationButton_Update(self);
	end
end

function BNConversationButton_OnClick(self, button)
	if ( self.roster:IsShown() ) then
		BNConversationButton_RestoreChatFramePosition(self);
		self.roster:Hide();
	else
		BNConversationButton_EnsureChatFrameInBounds(self);
		self.roster:Show();
	end
end

function BNConversationButton_EnsureChatFrameInBounds(self)
	local chatFrame = self.chatFrame;
	local leftOverlap = self.roster:GetLeft();
	local rightOverlap = GetScreenWidth() - self.roster:GetRight()
	if ( leftOverlap < 0 ) then
		self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset, self.oldYOffset = chatFrame:GetPoint();
		chatFrame:SetPoint(self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset - leftOverlap, self.oldYOffset);
	elseif ( rightOverlap < 0 ) then
		self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset, self.oldYOffset = chatFrame:GetPoint();
		chatFrame:SetPoint(self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset + rightOverlap, self.oldYOffset);
	else
		BNConversationButton_RemoveSavedChatFramePosition(self);
	end
end

function BNConversationButton_RemoveSavedChatFramePosition(self)
	self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset, self.oldYOffset = nil;
end

function BNConversationButton_RestoreChatFramePosition(self)
	if ( self.oldPoint ) then
		self.chatFrame:SetPoint(self.oldPoint, self.oldRelativeTo, self.oldRelativePoint, self.oldXOffset, self.oldYOffset);
	end
end

function BNConversationButton_UpdateAttachmentPoint(self)
	local chatFrame = self.chatFrame;
	local onInside = false;
	local relativeFrame = chatFrame.buttonFrame;
	
	if ( chatFrame.isDocked ) then
		onInside = true;
		relativeFrame = chatFrame;
		self:SetPoint("BOTTOM", chatFrame.buttonFrame.upButton, "TOP", 0, 0);
	else
		self:SetPoint("BOTTOM", chatFrame.buttonFrame.minimizeButton, "TOP", 0, 0);
	end
	
	if ( (chatFrame.buttonSide == "left") ~= onInside ) then
		self.roster:ClearAllPoints();
		self.roster:SetPoint("TOPRIGHT", relativeFrame, "TOPLEFT", 0, 0);
		self.roster:SetPoint("BOTTOMRIGHT", relativeFrame, "BOTTOMLEFT", 0, 0);
	else
		self.roster:ClearAllPoints();
		self.roster:SetPoint("TOPLEFT", relativeFrame, "TOPRIGHT", 0, 0);
		self.roster:SetPoint("BOTTOMLEFT", relativeFrame, "BOTTOMRIGHT", 0, 0);
	end
end

function BNConversationButton_UpdateTarget(self)
	local chatFrame = self.chatFrame;
	assert(chatFrame.chatType == "BN_CONVERSATION");
	local chatTarget = tonumber(chatFrame.chatTarget);
	
	self.conversationID = chatTarget;
end

function BNConversationButton_Update(self)
	local roster = self.roster;
	
	local numMembers = BNGetNumConversationMembers(self.conversationID);
	for i =1, numMembers do
		local accountID, toonID, name = BNGetConversationMemberInfo(self.conversationID, i);
		local button = _G[roster:GetName().."Player"..i];
		button:SetText(name);
		button.name = name;
		if ( accountID ~= 0 ) then
			button.id = accountID;
		else
			button.id = toonID;
		end
		button:Show();
	end
	
	for i= numMembers + 1, BN_CONVERSATION_MAX_CHANNEL_MEMBERS do
		local button = _G[roster:GetName().."Player"..i];
		button:Hide();
	end
	
	if ( numMembers < BN_CONVERSATION_MAX_CHANNEL_MEMBERS ) then
		roster.inviteButton:SetPoint("TOP", _G[roster:GetName().."Player"..numMembers], "BOTTOM", 0, -5);
		roster.inviteButton:Show();
	else
		roster.inviteButton:Hide();
	end
end

function BNConversationMember_OnClick(self, button)
	if ( button == "LeftButton" ) then
		ChatFrame_SendTell(self.name);
	elseif ( button == "RightButton" ) then
		FriendsFrame_ShowBNDropdown(self.name, 1, nil, nil, nil, nil, self.id);
	end
end