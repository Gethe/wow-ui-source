
function CommunitiesStreamDropDownMenu_Initialize(self)
	if self.streams ~= nil and self:GetCommunitiesFrame():GetSelectedClubId() ~= nil then
		local info = UIDropDownMenu_CreateInfo();
		info.minWidth = 170;
		for i, stream in ipairs(self.streams) do
			if stream.leadersAndModeratorsOnly then
				info.text = COMMUNITIES_STREAM_FORMAT_LEADERS_AND_MODERATORS_ONLY:format(stream.name);
			else
				info.text = stream.name;
			end
			
			info.value = stream.streamId;
			info.checked = stream.streamId == UIDropDownMenu_GetSelectedValue(self);
			info.func = function(button)
				local communitiesFrame = self:GetCommunitiesFrame();
				communitiesFrame:SelectStream(communitiesFrame:GetSelectedClubId(), button.value) 
			end
			UIDropDownMenu_AddButton(info);
		end
		if self.privileges.canCreateStream then
			info.text = COMMUNITIES_CREATE_CHANNEL;
			info.value = nil;
			info.notCheckable = 1;
			info.func = function(button)
				self:GetCommunitiesFrame():ShowCreateChannelDialog();
			end
			UIDropDownMenu_AddButton(info);
		end
	end
end

CommunitiesStreamDropDownMixin = {}

function CommunitiesStreamDropDownMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 115);
	self.Text:SetJustifyH("LEFT");
end

function CommunitiesStreamDropDownMixin:GetCommunitiesFrame()
	return self:GetParent();
end

CommunitiesEditStreamDialogMixin = {}

function CommunitiesEditStreamDialogMixin:OnLoad()
	self.Description.EditBox:SetScript("OnTabPressed", 
		function() 
			self.NameEdit:SetFocus() 
		end);
	self.Cancel:SetScript("OnClick", function() self:Hide(); end);
	self.NameEdit:SetScript("OnTextChanged", function() self:UpdateAcceptButton(); end);
end

function CommunitiesEditStreamDialogMixin:ShowCreateDialog(clubId)
	self.clubId = clubId;
	self.TitleLabel:SetText(COMMUNITIES_CREATE_CHANNEL);
	self.NameEdit:SetText("");
	self.Description.EditBox:SetText("");
	self.Accept:SetScript("OnClick", function(self)
		local editStreamDialog = self:GetParent();
		local moderatorsAndLeadersOnly = editStreamDialog.TypeCheckBox:GetChecked();
		C_Club.CreateStream(editStreamDialog.clubId, editStreamDialog.NameEdit:GetText(), editStreamDialog.Description.EditBox:GetText(), moderatorsAndLeadersOnly);
		editStreamDialog:Hide();
	end);
	self:Show();
end

function CommunitiesEditStreamDialogMixin:ShowEditDialog(clubId, stream)
	self.create = false;
	self.TitleLabel:SetText(COMMUNITIES_EDIT_CHANNEL);
	self.TitleEdit:SetText(stream.name);
	self.NameEdit:SetText(stream.name);
	self.NameEdit:SetFocus();
	self.Description.EditBox:SetText(stream.subject);
	self.Accept:SetScript("OnClick", function() 
		-- TODO: add an access drop down menu with options for "All Members", and "Moderators and Leaders Only";
		local moderatorsAndLeadersOnly = false;
		C_Club.EditStream(self.clubId, stream.streamId, self.NameEdit:GetText(), self.Description.EditBox:GetText())
		self:Hide();
	end);
	self:Show();
end

function CommunitiesEditStreamDialogMixin:UpdateAcceptButton()
	self.Accept:SetEnabled(self.NameEdit:GetText() ~= "");
end

CommunitiesAddToChatMixin = {};

function CommunitiesAddToChatMixin:OnLoad()
	self.highlightFramePool = CreateFramePool("BUTTON", self, "CommunitiesAddStreamHighlightFrameTemplate");
end

function CommunitiesAddToChatMixin:OnShow()
	self:RegisterEvent("COMMUNITIES_STREAM_CURSOR_CLEAR");
end

function CommunitiesAddToChatMixin:OnEvent(event)
	if event == "COMMUNITIES_STREAM_CURSOR_CLEAR" then
		self:Reset();
	end
end

function CommunitiesAddToChatMixin:OnClick()
	self:Reset();
	
	local communitiesFrame = self:GetCommunitiesFrame();
	local clubId = communitiesFrame:GetSelectedClubId();
	local streamId = communitiesFrame:GetSelectedStreamId();
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	
	for i = 1, NUM_CHAT_WINDOWS do
		local chatWindow = _G["ChatFrame"..i];
		if chatWindow:IsVisible() and chatWindow ~= COMBATLOG then
			-- TODO:: Check if this frame already has this stream attached to it.
			local highlightFrame = self.highlightFramePool:Acquire();
			highlightFrame:SetPoint("TOPLEFT", chatWindow, "TOPLEFT", -2, 3);
			highlightFrame:SetPoint("BOTTOMRIGHT", chatWindow, "BOTTOMRIGHT", 2, -7);
			highlightFrame:SetChatFrameIndex(i);
			highlightFrame:SetStyle(not ChatFrame_ContainsChannel(chatWindow, channelName));
			highlightFrame:Show();
		end
	end
	
	local canCreateChatWindow = FCF_GetNumActiveChatFrames() ~= NUM_CHAT_WINDOWS;
	self.CommunitiesAddStreamHighlightTab:SetShown(canCreateChatWindow);
	if canCreateChatWindow then
		local lastDockedFrame = FCFDock_GetNewTabAnchor(GENERAL_CHAT_DOCK);
		self.CommunitiesAddStreamHighlightTab:SetPoint("BOTTOMLEFT", lastDockedFrame, "BOTTOMRIGHT", -7, 0);
	end
	
	C_Cursor.SetCursorCommunitiesStream(clubId, streamId);
end

function CommunitiesAddToChatMixin:Reset()
	self.highlightFramePool:ReleaseAll();
	self.CommunitiesAddStreamHighlightTab:Hide();
	if C_Cursor.GetCursorCommunitiesStream() then
		C_Cursor.DropCursorCommunitiesStream();
	end
end

function CommunitiesAddToChatMixin:OnHide()
	self:UnregisterEvent("COMMUNITIES_STREAM_CURSOR_CLEAR");
	self:Reset();
end

CommunitiesAddStreamHighlightFrameMixin = {};

function CommunitiesAddStreamHighlightFrameMixin:SetChatFrameIndex(index)
	self.chatFrameIndex = index;
end

function CommunitiesAddStreamHighlightFrameMixin:GetStyle()
	return self.add;
end

function CommunitiesAddStreamHighlightFrameMixin:SetStyle(add)
	self.add = add;
	if add then
		self.Body:SetAtlas("communities-chat-body-add");
		self.Icon:SetAtlas("communities-chat-icon-plus");
	else
		self.Body:SetAtlas("communities-chat-body-remove");
		self.Icon:SetAtlas("communities-chat-icon-minus");
	end
end

function CommunitiesAddStreamHighlightFrameMixin:OnClick()
	local clubId, streamId = C_Cursor.GetCursorCommunitiesStream();
	if clubId then
		local chatFrame = Chat_GetChatFrame(self.chatFrameIndex);
		if chatFrame then
			local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
			local add = self:GetStyle();
			if add then
				C_Club.AddClubStreamToChatWindow(clubId, streamId, self.chatFrameIndex);
				ChatFrame_AddChannel(chatFrame, channelName);
				self:GetParent():Reset();
			else
				ChatFrame_RemoveChannel(chatFrame, channelName);
				self:GetParent():Reset();
			end
		end
	end
end

function CommunitiesAddToChatMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesAddStreamHighlightTab_OnClick(self)
	if FCF_GetNumActiveChatFrames() ~= NUM_CHAT_WINDOWS then
		local clubId, streamId = C_Cursor.GetCursorCommunitiesStream();
		if clubId and streamId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			local streamInfo = C_Club.GetStreamInfo(clubId, streamId);
			if clubInfo and streamInfo then
				local MAX_COMMUNITY_NAME_LENGTH = 12;
				local MAX_CHAT_TAB_STREAM_NAME_LENGTH = 50; -- Arbitrarily large, since for now we don't want to truncate the stream part.
				local communityPart = ChatFrame_TruncateToMaxLength(clubInfo.name, MAX_COMMUNITY_NAME_LENGTH);
				local streamPart = ChatFrame_TruncateToMaxLength(streamInfo.name, MAX_CHAT_TAB_STREAM_NAME_LENGTH);
				local chatFrameName = COMMUNITIES_NAME_AND_STREAM_NAME:format(communityPart, streamPart);
				local frame, chatFrameIndex = FCF_OpenNewWindow(chatFrameName);
				C_Club.AddClubStreamToChatWindow(clubId, streamId, chatFrameIndex);
				ChatFrame_AddChannel(frame, Chat_GetCommunitiesChannelName(clubId, streamId));
				self:GetParent():Reset();
			end
		end
	end
end