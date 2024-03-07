
function CommunitiesStreamDropDownMenu_GetStreamName(clubId, stream)
	local streamName = "";
	local streamId = stream.streamId;
	if stream.leadersAndModeratorsOnly then
		streamName = COMMUNITIES_STREAM_FORMAT_LEADERS_AND_MODERATORS_ONLY:format(stream.name);
	else
		streamName = stream.name;
	end
	
	local r, g, b = Chat_GetCommunitiesChannelColor(clubId, streamId);
	local color = CreateColor(r, g, b);
	streamName = color:WrapTextInColorCode(streamName);
		
	local localID = ChatFrame_GetCommunitiesChannelLocalID(clubId, streamId);
	if localID and localID ~= 0 then
		streamName = streamName.." "..GRAY_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_STREAM0_CHAT_SHORTCUT_FORMAT:format(localID));
	end
	
	return streamName;
end

function CommunitiesStreamDropDownMenu_Initialize(self)
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	if not clubId then
		return;
	end
	
	local streams = C_Club.GetStreams(clubId);
	CommunitiesUtil.SortStreams(streams);
	
	local streamToNotificationSetting = CommunitiesUtil.GetStreamNotificationSettingsLookup(clubId);
	local canEditStream = self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canDestroyStream;
	local info = UIDropDownMenu_CreateInfo();
	info.minWidth = 170;
	info.iconXOffset = -3;
	for i, stream in ipairs(streams) do
		local streamId = stream.streamId;
		info.text = CommunitiesStreamDropDownMenu_GetStreamName(clubId, stream);
		
		-- TODO:: Support mention-based notifications once we have support for mentions.
		if streamToNotificationSetting[streamId] == Enum.ClubStreamNotificationFilter.All and
			CommunitiesUtil.DoesCommunityStreamHaveUnreadMessages(clubId, streamId) then
			info.text = info.text.." "..CreateAtlasMarkup("communities-icon-notification", 10, 10);
		end
				
		info.mouseOverIcon = canEditStream and stream.streamType == Enum.ClubStreamType.Other and "Interface\\WorldMap\\GEAR_64GREY" or nil;
		info.value = streamId;
		info.checked = streamId == UIDropDownMenu_GetSelectedValue(self);
		info.func = function(button)
			local gearIcon = button.Icon;
			if button.mouseOverIcon ~= nil and gearIcon:IsMouseOver() then
				self:GetCommunitiesFrame():ShowEditStreamDialog(clubId, streamId);
			else
				local communitiesFrame = self:GetCommunitiesFrame();
				communitiesFrame:SelectStream(communitiesFrame:GetSelectedClubId(), button.value) 
			end
		end
		UIDropDownMenu_AddButton(info);
	end
	
	info.mouseOverIcon = nil;
	
	local clubInfo = C_Club.GetClubInfo(clubId);
	local maximumNumberOfStreams = C_Club.GetClubLimits(clubInfo and clubInfo.clubType or Enum.ClubType.Character).maximumNumberOfStreams;
	if self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canCreateStream and #streams < maximumNumberOfStreams then
		info.text = GREEN_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CREATE_CHANNEL);
		info.value = nil;
		info.customCheckIconAtlas = "communities-icon-addchannelplus";
		info.func = function(button)
			self:GetCommunitiesFrame():ShowCreateChannelDialog();
		end
		UIDropDownMenu_AddButton(info);
	end
	
	info.customCheckIconAtlas = nil;
	
	info.text = COMMUNITIES_NOTIFICATION_SETTINGS;
	info.value = nil;
	info.customCheckIconTexture = "Interface\\WorldMap\\GEAR_64GREY";
	info.func = function(button)
		self:GetCommunitiesFrame():ShowNotificationSettingsDialog(clubId);
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
	self.Cancel:SetScript("OnClick", function() self:Hide(); PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON); end);
	self.NameEdit:SetScript("OnTextChanged", function() self:UpdateAcceptButton(); end);
end

function CommunitiesEditStreamDialogMixin:OnShow()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:RegisterDialogShown(self);
end

function CommunitiesEditStreamDialogMixin:ValidateText(clubId)
	local name = self.NameEdit:GetText();
	local description = self.Description.EditBox:GetText();
	local clubInfo = C_Club.GetClubInfo(clubId);
	local clubType = clubInfo and clubInfo.clubType or Enum.ClubType.Character;
	local nameError = C_Club.GetCommunityNameResultText(C_Club.ValidateText(clubType, name, Enum.ClubFieldType.ClubStreamName));
	local descriptionError = C_Club.GetCommunityNameResultText(C_Club.ValidateText(clubType, name, Enum.ClubFieldType.ClubStreamSubject));
	if nameError or descriptionError then
		UIErrorsFrame:AddExternalErrorMessage(nameError or descriptionError);
		return false;
	end
	return true;
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
		if editStreamDialog:ValidateText(clubId) then
			C_Club.CreateStream(clubId, editStreamDialog.NameEdit:GetText(), editStreamDialog.Description.EditBox:GetText(), leadersAndModeratorsOnly);
			editStreamDialog:Hide();
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
		if editStreamDialog:ValidateText(clubId) then
			C_Club.EditStream(clubId, stream.streamId, editStreamDialog.NameEdit:GetText(), editStreamDialog.Description.EditBox:GetText(), leadersAndModeratorsOnly)
			editStreamDialog:Hide();
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	self:GetCommunitiesFrame():RegisterDialogShown(self);
end

function CommunitiesNotificationSettingsDialogMixin:Refresh()
	self.buttonPool:ReleaseAll();
	
	local clubId = self:GetSelectedClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		self.ScrollFrame.Child.QuickJoinButton:SetChecked(clubInfo and clubInfo.socialQueueingEnabled);
		
		local notificationSettings = C_Club.GetClubStreamNotificationSettings(clubId);
		local notificationSettingsLookup = {};
		for i, setting in ipairs(notificationSettings) do
			notificationSettingsLookup[setting.streamId] = setting.filter;
		end
		
		local scrollHeight = 105;
		local streams = C_Club.GetStreams(clubId);
		CommunitiesUtil.SortStreams(streams);
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
		C_Club.SetSocialQueueingEnabled(clubId, self.ScrollFrame.Child.QuickJoinButton:GetChecked());
	
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
	
	local clubInfo = C_Club.GetClubInfo(clubId);
	local hasQuickJoin = clubInfo and clubInfo.clubType ~= Enum.ClubType.BattleNet;
	self.ScrollFrame.Child.QuickJoinButton:SetShown(hasQuickJoin);
	if hasQuickJoin then
		self.ScrollFrame.Child.SettingsLabel:SetPoint("TOP", 0, -79);
	else
		self.ScrollFrame.Child.SettingsLabel:SetPoint("TOP", 0, -19);
	end

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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():GetParent():GetParent():SetAll(self.filter);
end

function CommunitiesNotificationSettingsDialogOkayButton_OnClick(self)
	CommunitiesFrame.NotificationSettingsDialog:SaveSettings();
	CommunitiesFrame.NotificationSettingsDialog:Hide();
end

function CommunitiesNotificationSettingsDialogCancelButton_OnClick(self)
	CommunitiesFrame.NotificationSettingsDialog:Cancel();
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

function CommunitiesAddToChatMixin:OnMouseDown(button)
	UIMenuButtonStretchMixin.OnMouseDown(self, button);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	
	local streamInfo = C_Club.GetStreamInfo(clubId, streamId);
	if not streamInfo then
		return;
	end
	
	local isGuildStream = streamInfo.streamType == Enum.ClubStreamType.Guild or streamInfo.streamType == Enum.ClubStreamType.Officer;
	
	local info = UIDropDownMenu_CreateInfo();
	info.text = COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);
	
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	local function AddChatWindowToDropdown(chatWindow, chatWindowIndex)
		-- The only reserved chat window that allows communities channels is the general chat window.
		if FCF_IsChatWindowIndexReserved(chatWindowIndex) and (chatWindowIndex ~= 1) then
			return;
		end
	
		local info = UIDropDownMenu_CreateInfo();
		local chatTab = _G["ChatFrame"..chatWindowIndex.."Tab"];
		info.text = chatTab.Text:GetText();
		info.value = chatWindowIndex;
		
		if isGuildStream then
			local messageGroup = streamInfo.streamType == Enum.ClubStreamType.Guild and "GUILD" or "OFFICER";
			info.func = function(button)
				if button.checked then
					ChatFrame_RemoveMessageGroup(chatWindow, messageGroup);
				else
					ChatFrame_AddMessageGroup(chatWindow, messageGroup);
				end
				
				chatTab:Click();
			end;
			
			
			info.checked = ChatFrame_ContainsMessageGroup(chatWindow, messageGroup);
		else
			info.func = function(button)
				if button.checked then
					ChatFrame_RemoveCommunitiesChannel(chatWindow, clubId, streamId);
				else
					ChatFrame_AddNewCommunitiesChannel(chatWindowIndex, clubId, streamId);
				end
				
				chatTab:Click();
			end;
			
			info.checked = ChatFrame_ContainsChannel(chatWindow, channelName);
		end
		
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);
	end

	FCF_IterateActiveChatWindows(AddChatWindowToDropdown);

	local canCreateChatWindow = FCF_CanOpenNewWindow();
	if canCreateChatWindow then
		local info = UIDropDownMenu_CreateInfo();
		info.text = COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_NEW_CHAT_WINDOW;
		info.func = function(button)
			if isGuildStream then
				local noDefaultChannels = true;
				local chatFrameName = streamInfo.name;
				local frame = FCF_OpenNewWindow(chatFrameName, noDefaultChannels);
				local messageGroup = streamInfo.streamType == Enum.ClubStreamType.Guild and "GUILD" or "OFFICER";
				ChatFrame_AddMessageGroup(frame, messageGroup);
			else
				local clubInfo = C_Club.GetClubInfo(clubId);
				if clubInfo  then
					local MAX_COMMUNITY_NAME_LENGTH = 12;
					local MAX_CHAT_TAB_STREAM_NAME_LENGTH = 50; -- Arbitrarily large, since for now we don't want to truncate the stream part.
					local communityPart = ChatFrame_TruncateToMaxLength(clubInfo.name, MAX_COMMUNITY_NAME_LENGTH);
					local streamPart = ChatFrame_TruncateToMaxLength(streamInfo.name, MAX_CHAT_TAB_STREAM_NAME_LENGTH);
					local chatFrameName = COMMUNITIES_NAME_AND_STREAM_NAME:format(communityPart, streamPart);
					local noDefaultChannels = true;
					local frame, chatFrameIndex = FCF_OpenNewWindow(chatFrameName, noDefaultChannels);
					local setEditBoxToChannel = true;
					ChatFrame_AddNewCommunitiesChannel(chatFrameIndex, clubId, streamId, setEditBoxToChannel);
				end
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
		
		if not isGuildStream then
			ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton3);
		end
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
