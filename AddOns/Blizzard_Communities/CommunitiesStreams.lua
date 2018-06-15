
function CommunitiesStreamDropDownMenu_Initialize(self)
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	if not clubId then
		return;
	end
	
	local streams = C_Club.GetStreams(clubId);
	if not streams then
		return;
	end
	
	local canEditStream = self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canDestroyStream;
	local info = UIDropDownMenu_CreateInfo();
	info.minWidth = 170;
	for i, stream in ipairs(streams) do
		if stream.leadersAndModeratorsOnly then
			info.text = COMMUNITIES_STREAM_FORMAT_LEADERS_AND_MODERATORS_ONLY:format(stream.name);
		else
			info.text = stream.name;
		end
		
		if CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, stream.streamId) then
			info.text = info.text.." "..CreateAtlasMarkup("communities-icon-notification", 11, 12);
		end
		
		info.mouseOverIcon = canEditStream and stream.streamType == Enum.ClubStreamType.Other and "Interface\\WorldMap\\GEAR_64GREY" or nil;
		info.value = stream.streamId;
		info.checked = stream.streamId == UIDropDownMenu_GetSelectedValue(self);
		info.func = function(button)
			local gearIcon = button.Icon;
			if button.mouseOverIcon ~= nil and gearIcon:IsMouseOver() then
				self:GetCommunitiesFrame():ShowEditStreamDialog(clubId, stream.streamId);
			else
				local communitiesFrame = self:GetCommunitiesFrame();
				communitiesFrame:SelectStream(communitiesFrame:GetSelectedClubId(), button.value) 
			end
		end
		UIDropDownMenu_AddButton(info);
	end
	
	info.mouseOverIcon = nil;
	
	if self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canCreateStream then
		info.text = COMMUNITIES_CREATE_CHANNEL;
		info.value = nil;
		info.notCheckable = 1;
		info.func = function(button)
			self:GetCommunitiesFrame():ShowCreateChannelDialog();
		end
		UIDropDownMenu_AddButton(info);
	end
	
	info.text = CreateTextureMarkup("Interface\\WorldMap\\GEAR_64GREY", 64, 64, 16, 16, 0, 1, 0, 1).." "..COMMUNITIES_NOTIFICATION_SETTINGS;
	info.value = nil;
	info.notCheckable = 1;
	info.func = function(button)
		self:GetCommunitiesFrame():ShowNotificationSettingsDialog();
	end
	UIDropDownMenu_AddButton(info);
end

CommunitiesStreamDropDownMixin = {}

function CommunitiesStreamDropDownMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 115);
	self.Text:SetJustifyH("LEFT");
end

function CommunitiesStreamDropDownMixin:UpdateUnreadNotification()
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	if clubId then
		local ignoreStreamId = self:GetCommunitiesFrame():GetSelectedStreamId();
		self.NotificationOverlay:SetShown(CommunitiesUtil.DoesCommunityHaveOtherUnreadMessages(clubId, ignoreStreamId));
	else
		self.NotificationOverlay:SetShown(false);
	end
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

function CommunitiesEditStreamDialogMixin:OnShow()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:RegisterDialogShown(self);
end

function CommunitiesEditStreamDialogMixin:ShowCreateDialog(clubId)
	self:SetWidth(350);
	self.Description.EditBox:SetWidth(283);
	self.Delete:Hide();
	self.Accept:SetPoint("BOTTOM", -56, 20);
	self.Cancel:SetPoint("BOTTOM", 56, 20);
	self.TitleLabel:SetText(COMMUNITIES_CREATE_CHANNEL);
	self.NameEdit:SetText("");
	self.Description.EditBox:SetText("");
	self.Accept:SetScript("OnClick", function(self)
		local editStreamDialog = self:GetParent();
		local leadersAndModeratorsOnly = editStreamDialog.TypeCheckBox:GetChecked();
		C_Club.CreateStream(clubId, editStreamDialog.NameEdit:GetText(), editStreamDialog.Description.EditBox:GetText(), leadersAndModeratorsOnly);
		editStreamDialog:Hide();
	end);
	self:Show();
	self.NameEdit:SetFocus();
end

function CommunitiesEditStreamDialogMixin:ShowEditDialog(clubId, stream)
	self:SetWidth(400);
	self.Description.EditBox:SetWidth(333);
	self.Delete:Show();
	self.Accept:SetPoint("BOTTOM", -111, 20);
	self.Cancel:SetPoint("BOTTOM", 111, 20);
	self.TitleLabel:SetText(COMMUNITIES_EDIT_CHANNEL);
	self.NameEdit:SetText(stream.name);
	self.Description.EditBox:SetText(stream.subject);
	self.TypeCheckBox:SetChecked(stream.leadersAndModeratorsOnly);
	self.Accept:SetScript("OnClick", function(self)
		local editStreamDialog = self:GetParent();
		local leadersAndModeratorsOnly = editStreamDialog.TypeCheckBox:GetChecked();
		C_Club.EditStream(clubId, stream.streamId, editStreamDialog.NameEdit:GetText(), editStreamDialog.Description.EditBox:GetText(), leadersAndModeratorsOnly)
		editStreamDialog:Hide();
	end);
	self.Delete:SetScript("OnClick", function(self)
		StaticPopup_Show("CONFIRM_DESTROY_COMMUNITY_STREAM", nil, nil, { clubId = clubId, streamId = stream.streamId, });
		self:GetParent():Hide();
	end);
	self:Show();
end

function CommunitiesEditStreamDialogMixin:UpdateAcceptButton()
	self.Accept:SetEnabled(self.NameEdit:GetText() ~= "");
end

function CommunitiesEditStreamDialogMixin:GetCommunitiesFrame()
	return self:GetParent();
end

CommunitiesNotificationSettingsStreamEntryMixin = {};

function CommunitiesNotificationSettingsStreamEntryMixin:SetStream(clubId, streamId)
	self.clubId = clubId;
	self.streamId = streamId;
end

function CommunitiesNotificationSettingsStreamEntryMixin:GetStreamId()
	return self.streamId;
end

function CommunitiesNotificationSettingsStreamEntryMixin:SetFilter(filter)
	if not self.clubId or not self.streamId then
		return;
	end
	
	self.filter = filter;
	self.ShowNotificationsButton:SetChecked(filter == Enum.ClubStreamNotificationFilter.All);
	self.HideNotificationsButton:SetChecked(filter == Enum.ClubStreamNotificationFilter.None);
end

function CommunitiesNotificationSettingsStreamEntryMixin:GetFilter()
	return self.filter;
end

CommunitiesNotificationSettingsDialogMixin = {};

function CommunitiesNotificationSettingsDialogMixin:OnLoad()
	self.buttonPool = CreateFramePool("BUTTON", self.ScrollFrame.Child, "CommunitiesNotificationSettingsStreamEntryTemplate");
end

function CommunitiesNotificationSettingsDialogMixin:OnShow()
	local communitiesFrame = self:GetCommunitiesFrame();
	self:SelectClub(communitiesFrame:GetSelectedClubId());
	communitiesFrame:RegisterDialogShown(self);
end

function CommunitiesNotificationSettingsDialogMixin:Refresh()
	self.buttonPool:ReleaseAll();
	
	local clubId = self:GetSelectedClubId();
	if clubId then
		local notificationSettings = C_Club.GetClubStreamNotificationSettings(clubId);
		local notificationSettingsLookup = {};
		for i, setting in ipairs(notificationSettings) do
			notificationSettingsLookup[setting.streamId] = setting.filter;
		end
		
		local scrollHeight = 105;
		local streams = C_Club.GetStreams(clubId);
		local previousEntry = nil;
		for i, stream in ipairs(streams) do
			local button = self.buttonPool:Acquire();
			button:SetStream(clubId, stream.streamId);
			button.StreamName:SetText(stream.name);
			if i == 1 then
				button:SetPoint("TOPLEFT", self.ScrollFrame.Child.Separator, "BOTTOMLEFT");
			else
				button:SetPoint("TOPLEFT", previousEntry, "BOTTOMLEFT");
			end
			
			button:SetFilter(notificationSettingsLookup[stream.streamId]);
			button:Show();
			scrollHeight = scrollHeight + button:GetHeight();
			previousEntry = button;
		end
		
		self.ScrollFrame.Child:SetHeight(scrollHeight);
	end
end

function CommunitiesNotificationSettingsDialogMixin:SaveSettings()
	local clubId = self:GetSelectedClubId();
	if clubId then
		local notificationSettings = {};
		for button in self.buttonPool:EnumerateActive() do
			table.insert(notificationSettings, { streamId = button:GetStreamId(), filter = button:GetFilter(), });
		end
		
		C_Club.SetClubStreamNotificationSettings(clubId, notificationSettings);
	end
end

function CommunitiesNotificationSettingsDialogMixin:SetAll(filter)
	for button in self.buttonPool:EnumerateActive() do
		button:SetFilter(filter);
	end
end

function CommunitiesNotificationSettingsDialogMixin:Cancel()
	self:Hide();
end

function CommunitiesNotificationSettingsDialogMixin:SelectClub(clubId)
	self.clubId = clubId;
	self.CommunitiesListDropDownMenu:OnClubSelected();
	self:Refresh();
end

function CommunitiesNotificationSettingsDialogMixin:GetSelectedClubId()
	return self.clubId;
end

function CommunitiesNotificationSettingsDialogMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesMassNotificationsSettingsButton_OnClick(self)
	self:GetParent():GetParent():GetParent():SetAll(self.filter);
end

function CommunitiesNotificationSettingsDialogOkayButton_OnClick(self)
	self:GetParent():SaveSettings();
	self:GetParent():Hide();
end

function CommunitiesNotificationSettingsDialogCancelButton_OnClick(self)
	self:GetParent():Cancel();
end

CommunitiesAddToChatMixin = {};

function CommunitiesAddToChatMixin:OnLoad()
	SquareButton_SetIcon(self, "DOWN");
end

function CommunitiesAddToChatMixin:SetClubId(clubId)
	self.clubId = clubId;
end

function CommunitiesAddToChatMixin:GetClubId()
	return self.clubId;
end

function CommunitiesAddToChatMixin:SetStreamId(streamId)
	self.streamId = streamId;
end

function CommunitiesAddToChatMixin:GetStreamId()
	return self.streamId;
end

function CommunitiesAddToChatMixin:OnClick()
	local clubId = self:GetParent():GetSelectedClubId();
	local streamId = self:GetParent():GetSelectedStreamId();
	if clubId and streamId then
		self:SetClubId(clubId);
		self:SetStreamId(streamId);
		ToggleDropDownMenu(nil, nil, self.DropDown, self, 0, 0);
	end
end

function CommunitiesAddToChatDropDown_Initialize(self, level)
	local clubId = self:GetParent():GetClubId();
	local streamId = self:GetParent():GetStreamId();
	if not clubId or not streamId then
		return;
	end
	
	local info = UIDropDownMenu_CreateInfo();
	info.text = COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);
	
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	for i = 1, FCF_GetNumActiveChatFrames() do
		local chatWindow = _G["ChatFrame"..i];
		if chatWindow ~= COMBATLOG then
			local info = UIDropDownMenu_CreateInfo();
			local chatTab = _G["ChatFrame"..i.."Tab"];
			info.text = chatTab.Text:GetText();
			info.value = i;
			info.func = function(button)
				if button.checked then
					ChatFrame_RemoveCommunitiesChannel(chatWindow, clubId, streamId);
				else
					C_Club.AddClubStreamToChatWindow(clubId, streamId, button.value);
					ChatFrame_AddCommunitiesChannel(chatWindow, clubId, streamId);
				end
				
				chatTab:Click();
			end;
			
			info.isNotRadio = true;
			info.checked = ChatFrame_ContainsChannel(chatWindow, channelName);
			UIDropDownMenu_AddButton(info, level);
		end
	end	

	local canCreateChatWindow = FCF_GetNumActiveChatFrames() ~= NUM_CHAT_WINDOWS;
	if canCreateChatWindow then
		local info = UIDropDownMenu_CreateInfo();
		info.text = COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_NEW_CHAT_WINDOW;
		info.func = function(button)
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
				ChatFrame_AddCommunitiesChannel(frame, clubId, streamId);
			end
		end;

		info.isNotRadio = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);
	end

	UIDropDownMenu_AddSeparator();
	
	local info = UIDropDownMenu_CreateInfo();
	info.text = COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_CHAT_SETTINGS;
	info.func = function()
		CURRENT_CHAT_FRAME_ID = SELECTED_CHAT_FRAME:GetID();
		ShowUIPanel(ChatConfigFrame);
		ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton3);
	end;
		
	info.isNotRadio = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);
end

function CommunitiesAddToChatDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CommunitiesAddToChatDropDown_Initialize, "MENU");
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