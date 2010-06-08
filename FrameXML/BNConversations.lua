BN_CONVERSATION_INVITE_HEIGHT = 22;
BN_CONVERSATION_INVITE_NUM_DISPLAYED = 7;
BN_CONVERSATION_MAX_CHANNEL_MEMBERS = BNGetMaxPlayersInConversation();

function BNConversationInviteDialog_OnLoad(self)
	self:RegisterEvent("BN_CHAT_CHANNEL_CREATE_SUCCEEDED");
	self:RegisterEvent("BN_CHAT_CHANNEL_CREATE_FAILED");
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
	-- special popup dialog settings
	self.hideOnEscape = true;
	self.exclusive = true;
	
	BNConversationInvite_Reset();
end

function BNConversationInviteDialog_OnEvent(self, event, ...)
	if ( event == "BN_CHAT_CHANNEL_CREATE_SUCCEEDED" ) then
		local conversationID = ...;
		BNConversationInvite_UnlockActions();
		if ( PENDING_BN_WHISPER_TO_CONVERSATION_FRAME and
			PENDING_BN_WHISPER_TO_CONVERSATION_FRAME.inUse ) then
			FCF_RestoreChatsToFrame(DEFAULT_CHAT_FRAME, PENDING_BN_WHISPER_TO_CONVERSATION_FRAME);
			FCF_SetTemporaryWindowType(PENDING_BN_WHISPER_TO_CONVERSATION_FRAME, "BN_CONVERSATION", conversationID);
		end
	elseif ( event == "BN_CHAT_CHANNEL_CREATE_FAILED" ) then
		BNConversationInvite_UnlockActions();
	elseif ( event == "BN_FRIEND_ACCOUNT_ONLINE" and self:IsShown() ) then
		BNConversationInvite_Update();
	elseif ( event == "BN_FRIEND_ACCOUNT_OFFLINE" and self:IsShown() ) then
		local presenceID = ...;
		BNConversationInvite_Unlock(presenceID);
		BNConversationInvite_Deselect(presenceID);
	end
end

function BNConversationInviteListCheckButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		BNConversationInvite_Select(parent.id);
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		BNConversationInvite_Deselect(parent.id);
	end
end

function BNConversationInvite_SelectPlayers(conversationID)
	BNConversationInvite_SetMode("invite", conversationID);
	
	BNConversationInvite_Reset();
	
	for i=1, BNGetNumConversationMembers(conversationID) do
		local accountID, toonID, name = BNGetConversationMemberInfo(conversationID, i);
		BNConversationInvite_Lock(accountID);
	end
	
	StaticPopupSpecial_Show(BNConversationInviteDialog);
end

function BNConversationInvite_NewConversation(selected1, selected2)
	BNConversationInvite_SetMode("create");
	
	BNConversationInvite_Reset();
	
	if ( selected1 ) then
		BNConversationInvite_Select(selected1);
		BNConversationInvite_Lock(selected1);
	end
	if ( selected2 ) then
		BNConversationInvite_Select(selected2);
		BNConversationInvite_Lock(selected2);
	end
	
	StaticPopupSpecial_Show(BNConversationInviteDialog);
end

function BNConversationInvite_Reset()
	BNConversationInviteDialog.inviteTargets = {};	--Probably better to eat the gc than table.wipe in this case.
	BNConversationInviteDialog.lockedTargets = {};
	BNConversationInviteDialog.triggeringChatFrame = nil;
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
		if ( BNCreateConversation(inviteTargets[1], inviteTargets[2]) ) then
			BNConversationInvite_LockActions();
			PENDING_BN_WHISPER_TO_CONVERSATION_FRAME = BNConversationInviteDialog.triggeringChatFrame;
		end
	elseif ( BNConversationInviteDialog.mode == "invite" ) then
		for _, player in pairs(inviteTargets) do
			BNInviteToConversation(BNConversationInviteDialog.target, player);
		end
	else
		error("Unhandled invite type: "..tostring(BNConversationInviteDialog.mode))
	end
	StaticPopupSpecial_Hide(BNConversationInviteDialog);
end

function BNConversationInvite_LockActions()
	BNConversationInviteDialog.actionsLocked = true;
	BNConversationInvite_UpdateInviteButtonState();
end

function BNConversationInvite_UnlockActions()
	BNConversationInviteDialog.actionsLocked = false;
	BNConversationInvite_UpdateInviteButtonState();
end

function BNConversationInvite_UpdateInviteButtonState()
	local dialog = BNConversationInviteDialog;
	local button = BNConversationInviteDialogInviteButton;
	
	if ( dialog.actionsLocked or #dialog.inviteTargets < dialog.minInvites ) then
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

function BNConversationInvite_Lock(player)
	local lockedTargets = BNConversationInviteDialog.lockedTargets;
	if ( not tContains(lockedTargets, player) ) then
		tinsert(lockedTargets, player);
	end
	BNConversationInvite_Update();
end

function BNConversationInvite_Unlock(player)
	local lockedTargets = BNConversationInviteDialog.lockedTargets;
	tDeleteItem(lockedTargets, player);
	BNConversationInvite_Update();
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
		
		if ( tContains(BNConversationInviteDialog.lockedTargets, frame.id) or
				(#BNConversationInviteDialog.inviteTargets >= BNConversationInviteDialog.maxInvites and --Disable everything if we've checked the max amount
				not frame.checkButton:GetChecked()  ) ) then	--Never disable a button that is already checked) then 
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
	self.chatFrame = _G["ChatFrame"..self:GetID()];
	self.chatFrame.conversationButton = self;
	
	BNConversationButton_UpdateAttachmentPoint(self);
	BNConversationButton_UpdateTarget(self);
	
	self:RegisterEvent("BN_CHAT_CHANNEL_LEFT");
	self:RegisterEvent("BN_CHAT_CHANNEL_JOINED");
end

function BNConversationButton_OnClick(self, button)
	if ( self.chatType == "BN_CONVERSATION" ) then
		local frame = BNConversationInviteDialog;
		if ( frame:IsShown() and frame.target == self.chatTarget ) then
			StaticPopupSpecial_Hide(frame)
		else
			BNConversationInvite_SelectPlayers(self.chatTarget);
		end
	else
		BNConversationInvite_NewConversation(BNet_GetPresenceID(self.chatTarget));
		BNConversationInviteDialog.triggeringChatFrame = self.chatFrame;
	end
end

function BNConversationButton_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "BN_CHAT_CHANNEL_LEFT" and arg1 == self.chatTarget ) then
		BNConversationButton_UpdateEnabledState(self);
	elseif ( event == "BN_CHAT_CHANNEL_JOINED" and arg1 == self.chatTarget ) then
		BNConversationButton_UpdateEnabledState(self);
	end
end

function BNConversationButton_UpdateEnabledState(self)
	if ( self.chatType ~= "BN_CONVERSATION" or BNGetConversationInfo(self.chatTarget) ) then
		self:Enable();
	else
		self:Disable();
	end
end

function BNConversationButton_OnEnter(self, motion)
	if ( self.chatType == "BN_CONVERSATION" ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		BNConversation_DisplayConversationTooltip(self.chatTarget);
		
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(CLICK_TO_INVITE_TO_CONVERSATION, nil, nil, nil, true);
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(CLICK_TO_START_CONVERSATION, nil, nil, nil, true);
		GameTooltip:Show();		
	end
end
	
function BNConversation_DisplayConversationTooltip(conversationID)
	local info = ChatTypeInfo["BN_CONVERSATION"];
	GameTooltip:SetText(format(CONVERSATION_NAME, conversationID + MAX_WOW_CHAT_CHANNELS), info.r, info.g, info.b);

	for i=1, BNGetNumConversationMembers(conversationID) do
		local accountID, toonID, name = BNGetConversationMemberInfo(conversationID, i);
		GameTooltip:AddLine(name, FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
	end
	
	GameTooltip:Show();
end

function BNConversationButton_OnLeave(self, motion)
	if ( GameTooltip:GetOwner() == self ) then
		GameTooltip:Hide();
	end
end

function BNConversationButton_UpdateAttachmentPoint(self)
	local chatFrame = self.chatFrame;
	
	if ( chatFrame.isDocked ) then
		self:SetPoint("BOTTOM", chatFrame.buttonFrame.upButton, "TOP", 0, 0);
	else
		self:SetPoint("BOTTOM", chatFrame.buttonFrame.minimizeButton, "TOP", 0, 0);
	end
end

function BNConversationButton_UpdateTarget(self)
	local chatFrame = self.chatFrame;
	local chatTarget = tonumber(chatFrame.chatTarget) or chatFrame.chatTarget;
	
	self.chatType = chatFrame.chatType;
	self.chatTarget = chatTarget;
	BNConversationButton_UpdateEnabledState(self);
end