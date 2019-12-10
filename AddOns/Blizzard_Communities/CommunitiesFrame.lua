
CommunitiesFrameMixin = CreateFromMixins(CallbackRegistryBaseMixin);

CommunitiesFrameMixin:GenerateCallbackEvents(
{
    "InviteAccepted",
    "InviteDeclined",
	"TicketAccepted",
	"DisplayModeChanged",
	"ClubSelected",
	"StreamSelected",
});

local COMMUNITIES_FRAME_EVENTS = {
	"CLUB_STREAMS_LOADED",
	"CLUB_STREAM_ADDED",
	"CLUB_STREAM_REMOVED",
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_SELF_MEMBER_ROLE_UPDATED",
	"STREAM_VIEW_MARKER_UPDATED",
	"BN_DISCONNECTED",
	"CHANNEL_UI_UPDATE",
	"UPDATE_CHAT_COLOR",
};

local COMMUNITIES_STATIC_POPUPS = {
	"INVITE_COMMUNITY_MEMBER",
	"INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK",
	"CONFIRM_DESTROY_COMMUNITY",
	"CONFIRM_REMOVE_COMMUNITY_MEMBER",
	"SET_COMMUNITY_MEMBER_NOTE",
	"CONFIRM_DESTROY_COMMUNITY_STREAM",
	"CONFIRM_LEAVE_AND_DESTROY_COMMUNITY",
	"CONFIRM_LEAVE_COMMUNITY",
};

function CommunitiesFrameMixin:OnLoad()
	CallbackRegistryBaseMixin.OnLoad(self);
	
	self.PortraitFrame:Hide();
	
	self.TitleText:SetText(COMMUNITIES_FRAME_TITLE);
	
	UIDropDownMenu_Initialize(self.StreamDropDownMenu, CommunitiesStreamDropDownMenu_Initialize);
		
	self.selectedStreamForClub = {};
	self.privilegesForClub = {};
	self.newClubIds = {};

	self:UpdateCommunitiesButtons();
end

function CommunitiesFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	
	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, because they share one presence subscription
	if ChannelFrame and ChannelFrame:IsShown() then
		HideUIPanel(ChannelFrame);
	end
	
	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, since we're pretending that they're one frame for Classic.
	if FriendsFrame and FriendsFrame:IsShown() then
		HideUIPanel(FriendsFrame);
	end

	local clubId = self:GetSelectedClubId();
	if clubId  then
		C_Club.SetClubPresenceSubscription(clubId);
	end

	self:UpdatePortrait();
	
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	self:UpdateClubSelection();
	self:UpdateStreamDropDown();
	UpdateMicroButtons();
	
	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:ScrollToClub(self:GetSelectedClubId());
	end

	-- Friend Frame tab hack.
	PanelTemplates_SetNumTabs(self, FRIEND_TAB_COUNT_WITH_GROUPS);
	self.selectedTab = FRIEND_TAB_BLIZZARDGROUPS;
	PanelTemplates_UpdateTabs(self);
	FriendsFrame.selectedTab = FRIEND_TAB_BLIZZARDGROUPS; -- Set on FriendsFrame as well.
	InGuildCheck(self);

	-- Update micromenu notifications.
	BlizzardGroups_UpdateNotifications();

	-- Flag for FriendsFrame.
	COMMUNITY_FRAME_HAS_BEEN_SHOWN = true;
end

function CommunitiesFrameMixin:OnEvent(event, ...)
	if event == "CLUB_STREAMS_LOADED" then
		local clubId = ...;
		self:StreamsLoadedForClub(clubId);
		if clubId == self:GetSelectedClubId() then
			local streams = C_Club.GetStreams(clubId);
			if not self:GetSelectedStreamForClub(clubId) then
				self:SelectStream(clubId, streams[1].streamId);
			end
			
			self:UpdateStreamDropDown();
		end
	elseif event == "CLUB_STREAM_ADDED" then
		local clubId, streamId = ...;
		if clubId == self:GetSelectedClubId() then
			if not self:GetSelectedStreamForClub(clubId) then
				self:SelectStream(clubId, streamId);
			end
			
			self:UpdateStreamDropDown();
		end
	elseif event == "CLUB_STREAM_REMOVED" then
		local clubId, streamId = ...;
		local selectedStream = self:GetSelectedStreamForClub(clubId);
		local isSelectedClub = clubId == self:GetSelectedClubId();
		local isSelectedStream = selectedStream and selectedStream.streamId == streamId;
		if isSelectedClub or isSelectedStream then
			local streams = C_Club.GetStreams(clubId);
			if isSelectedStream and #streams > 0 then
				self:SelectStream(clubId, streams[1].streamId);
			end
			
			if isSelectedClub then
				self:UpdateStreamDropDown();
			end
		end
	elseif event == "CLUB_ADDED" then
		local clubId = ...;
		self:AddNewClubId(clubId);
		
		if self:GetSelectedClubId() == nil then
			self:UpdateClubSelection();
		end
	elseif event == "CLUB_REMOVED" then
		local clubId = ...;
		self:SetPrivilegesForClub(clubId, nil);
		if clubId == self:GetSelectedClubId() then
			self:UpdateClubSelection();
		end
	elseif event == "CLUB_SELF_MEMBER_ROLE_UPDATED" then
		local clubId, roleId = ...;
		if clubId == self:GetSelectedClubId() then
			self:SetPrivilegesForClub(clubId, C_Club.GetClubPrivileges(clubId));
		else
			self:SetPrivilegesForClub(clubId, nil);
		end
		self:UpdateCommunitiesButtons();
	elseif event == "STREAM_VIEW_MARKER_UPDATED" then
		if self.StreamDropDownMenu:IsShown() then
			self.StreamDropDownMenu:UpdateUnreadNotification();
		end
		
		if self.CommunitiesListDropDownMenu:IsShown() then
			self.CommunitiesListDropDownMenu:UpdateUnreadNotification();
		end
	elseif event == "BN_DISCONNECTED" then
		HideUIPanel(self);
	elseif event == "CHANNEL_UI_UPDATE" or event == "UPDATE_CHAT_COLOR" then
		self:UpdateStreamDropDown();
	end
end

function CommunitiesFrameMixin:AddNewClubId(clubId)
	self.newClubIds[#self.newClubIds + 1] = clubId;
end

function CommunitiesFrameMixin:StreamsLoadedForClub(clubId)
	-- When you add a new club we want to add the general stream to your chat window.
	if not ChatFrame_CanAddChannel() then
		return;
	end
	
	for i, newClubId in ipairs(self.newClubIds) do
		if newClubId == clubId then
			local streams = C_Club.GetStreams(clubId);
			if streams then
				for i, stream in ipairs(streams) do
					if stream.streamType == Enum.ClubStreamType.General then
						local DEFAULT_CHAT_FRAME_INDEX = 1;
						ChatFrame_AddNewCommunitiesChannel(DEFAULT_CHAT_FRAME_INDEX, clubId, stream.streamId);
						table.remove(self.newClubIds, i);
						break;
					end
				end
			end
		end
	end
end

function CommunitiesFrameMixin:ToggleSubPanel(subPanel)
	if subPanel:IsShown() then
		self.activeSubPanel = nil;
		HideUIPanel(subPanel);
	else
		if self.activeSubPanel and self.activeSubPanel:IsShown() then
			HideUIPanel(self.activeSubPanel);
		end
		
		self.activeSubPanel = subPanel;
		ShowUIPanel(subPanel);
	end
end

function CommunitiesFrameMixin:CloseActiveSubPanel()
	if self.activeSubPanel then
		HideUIPanel(self.activeSubPanel);
		self.activeSubPanel = nil;
	end
end

function CommunitiesFrameMixin:RegisterDialogShown(dialog)
	self:CloseActiveDialogs(dialog);
	self.lastActiveDialog = dialog;
end

function CommunitiesFrameMixin:CloseStaticPopups()
	for i, popup in ipairs(COMMUNITIES_STATIC_POPUPS) do
		if StaticPopup_Visible(popup) then
			StaticPopup_Hide(popup);
		end
	end
end

function CommunitiesFrameMixin:CloseActiveDialogs(dialogBeingShown)
	CloseDropDownMenus();

	self:CloseStaticPopups();
	
	self:CloseActiveSubPanel();
	
	if AddCommunitiesFlow_IsShown() then
		AddCommunitiesFlow_Hide();
	end
	
	if CommunitiesAvatarPicker_IsShown() then
		CommunitiesAvatarPicker_Hide();
	end
	
	if self.lastActiveDialog ~= nil and self.lastActiveDialog ~= dialogBeingShown then
		self.lastActiveDialog:Hide();
		self.lastActiveDialog = nil;
	end
end

function CommunitiesFrameMixin:UpdateClubSelection()
	local lastSelectedClubId = tonumber(GetCVar("lastSelectedClubId")) or 0;
	local clubs = C_Club.GetSubscribedClubs();
	for i, club in ipairs(clubs) do
		if club.clubId == lastSelectedClubId then
			self:SelectClub(club.clubId);
			return;
		end
	end
	
	CommunitiesUtil.SortClubs(clubs);
	if #clubs > 0 then
		self:SelectClub(clubs[1].clubId);
		return;
	end

	self:SelectClub(nil);
end

function CommunitiesFrameMixin:SelectClub(clubId, forceUpdate)
	if forceUpdate or clubId ~= self.selectedClubId then
		self.ChatEditBox:SetEnabled(clubId ~= nil);
		self.selectedClubId = clubId;
		self:OnClubSelected(clubId);
	end
end

COMMUNITIES_FRAME_DISPLAY_MODES = {
	CHAT = {
		"CommunitiesList",
		"MemberList",
		"StreamDropDownMenu",
		"Chat",
		"ChatEditBox",
		"AddToChatButton",
		"InviteButton",
		"VoiceChatHeadset",
	},
	
	ROSTER = {
		"CommunitiesList",
		"MemberList",
		"CommunitiesControlFrame",
	},
	
	INVITATION = {
		"CommunitiesList",
		"InvitationFrame",
	},
	
	TICKET = {
		"CommunitiesList",
		"TicketFrame",
	},

	MINIMIZED = {
		"CommunitiesListDropDownMenu",
		"Chat",
		"ChatEditBox",
		"StreamDropDownMenu",
		"VoiceChatHeadset",
	},
};

function CommunitiesFrameMixin:SetDisplayMode(displayMode)
	if self.displayMode == displayMode then
		return;
	end
	
	self:CloseActiveDialogs();
	
	self.displayMode = displayMode;
	
	local subframesToUpdate = {};
	for i, mode in pairs(COMMUNITIES_FRAME_DISPLAY_MODES) do
		for j, subframe in ipairs(mode) do
			subframesToUpdate[subframe] = subframesToUpdate[subframe] or mode == displayMode;
		end
	end
	
	for subframe, shouldShow in pairs(subframesToUpdate) do
		self[subframe]:SetShown(shouldShow);
	end
	
	self.MaximizeMinimizeFrame.MinimizeButton:SetEnabled(displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
	
	self:TriggerEvent(CommunitiesFrameMixin.Event.DisplayModeChanged, displayMode);
	
	self:UpdateCommunitiesButtons();
	self:UpdateCommunitiesTabs();
end

function CommunitiesFrameMixin:ValidateDisplayMode()
	local clubId = self:GetSelectedClubId();
	if clubId then
		local displayMode = self:GetDisplayMode();
		local clubInfo = C_Club.GetClubInfo(clubId);
		if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.TICKET then
			self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		elseif displayMode == nil then
			self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		end
	end	
end

function CommunitiesFrameMixin:GetDisplayMode()
	return self.displayMode;
end

function CommunitiesFrameMixin:UpdateCommunitiesTabs()
	local displayMode = self:GetDisplayMode();
	
	self.ChatTab:Hide();
	self.RosterTab:Hide();
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER then
		self.ChatTab:Show();
		self.RosterTab:Show();
		SetUIPanelAttribute(self, "extraWidth", 32);
	else
		SetUIPanelAttribute(self, "extraWidth", 0);
	end
	
	UpdateUIPanelPositions(self);
	
	self.ChatTab:SetChecked(false);
	self.RosterTab:SetChecked(false);
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT then
		self.ChatTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER then
		self.RosterTab:SetChecked(true);
	end
end

function CommunitiesFrameMixin:UpdatePortrait()
	local clubId = self:GetSelectedClubId();
	local clubInfo = clubId and C_Club.GetClubInfo(clubId) or nil;
	self.PortraitOverlay.Portrait:SetShown(true);
	
	if clubInfo == nil then
		SetPortraitToTexture(self.PortraitOverlay.Portrait, "Interface\\Icons\\achievement_guildperk_havegroup willtravel");
	else
		C_Club.SetAvatarTexture(self.PortraitOverlay.Portrait, clubInfo.avatarId, clubInfo.clubType);
	end
end

function CommunitiesFrameMixin:OnClubSelected(clubId)
	local clubSelected = clubId ~= nil;
	self:CloseActiveDialogs();
	self.ChatEditBox:SetEnabled(clubSelected);
	if clubSelected then
		SetCVar("lastSelectedClubId", clubId)
	
		C_Club.SetClubPresenceSubscription(clubId);
		
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			local selectedStream = self:GetSelectedStreamForClub(clubId);
			if selectedStream ~= nil then
				self:SelectStream(clubId, selectedStream.streamId);
			else
				local streams = C_Club.GetStreams(clubId);
				CommunitiesUtil.SortStreams(streams);
				if #streams >= 1 then
					self:SelectStream(clubId, streams[1].streamId);
				else
					self:SelectStream(clubId, nil);
				end
			end
			
			if not self:HasPrivilegesForClub(clubId) then
				self:SetPrivilegesForClub(clubId, C_Club.GetClubPrivileges(clubId));
			end
			
			self:ValidateDisplayMode();
		else
			SetPortraitToTexture(self.PortraitOverlay.Portrait, "Interface\\Icons\\Achievement_General_StayClassy");
			local invitationInfo = C_Club.GetInvitationInfo(clubId);
			if invitationInfo then
				self.InvitationFrame:DisplayInvitation(invitationInfo);
				self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
			else
				local ticketInfo = self.CommunitiesList:GetTicketInfoForClubId(clubId);
				if ticketInfo then
					self.TicketFrame:DisplayTicket(ticketInfo);
					self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.TICKET);
				end
			end
		end
	end
	
	self:UpdatePortrait();
	self:UpdateCommunitiesButtons();
	self:UpdateCommunitiesTabs();
	self:TriggerEvent(CommunitiesFrameMixin.Event.ClubSelected, clubId);
	
	self:UpdateStreamDropDown(); -- TODO:: Convert this to use the registry system of callbacks.
	
	if self.MemberList:IsShown() then
		self.MemberList:OnClubSelected(clubId); -- TODO:: Convert this to use the registry system of callbacks.
	end
	
	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:OnClubSelected(clubId); -- TODO:: Convert this to use the registry system of callbacks.
	end
end

function CommunitiesFrameMixin:GetSelectedClubId()
	return self.selectedClubId;
end

function CommunitiesFrameMixin:GetSelectedStreamId()
	if not self.selectedClubId then
		return nil;
	end
	
	local stream = self:GetSelectedStreamForClub(self.selectedClubId);
	if not stream then
		return nil;
	end
	
	return stream.streamId;
end

function CommunitiesFrameMixin:UpdateCommunitiesButtons()
	local clubId = self:GetSelectedClubId();
	local inviteButton = self.InviteButton;
	inviteButton:SetEnabled(false);
	
	local addToChatButton = self.AddToChatButton;
	addToChatButton:SetEnabled(false);
	
	if clubId ~= nil then
		local clubInfo = C_Club.GetClubInfo(clubId);

		local privileges = self:GetPrivilegesForClub(clubId);
		if privileges.canSendInvitation then
			inviteButton:SetEnabled(true);
		-- There are currently no plans to allow suggesting members.
		-- elseif privileges.canSuggestMember then
		end
		
		if self:GetSelectedStreamId() ~= nil then
			addToChatButton:SetEnabled(true);
		end
	end
	
	self.CommunitiesControlFrame:Update();
end

function CommunitiesFrameMixin:SetFocusedStream(clubId, streamId)
	if self.focusedClubId and self.focusedStreamId then
		C_Club.UnfocusStream(self.focusedClubId, self.focusedStreamId);
	end
	
	self.focusedClubId = clubId;
	self.focusedStreamId = streamId;
	
	if clubId and streamId and not C_Club.FocusStream(clubId, streamId) then
		-- TODO:: Emit an error that we couldn't focus the stream.
	end
end

function CommunitiesFrameMixin:SelectStream(clubId, streamId)
	if streamId == nil then
		self.selectedStreamForClub[clubId] = nil;
		self:TriggerEvent(CommunitiesFrameMixin.Event.StreamSelected, streamId);
	else
		CommunitiesTicketManagerDialog_OnStreamChanged(clubId, streamId);
		
		local streams = C_Club.GetStreams(clubId);
		for i, stream in ipairs(streams) do
			if stream.streamId == streamId then
				self.selectedStreamForClub[clubId] = stream;
				
				if clubId == self:GetSelectedClubId() then
					self:SetFocusedStream(clubId, streamId);
					C_Club.SetAutoAdvanceStreamViewMarker(clubId, streamId);
					if C_Club.IsSubscribedToStream(clubId, streamId) then
						self.Chat:RequestInitialMessages(clubId, streamId);
					end
					
					self:TriggerEvent(CommunitiesFrameMixin.Event.StreamSelected, streamId);
					self:UpdateStreamDropDown();

					self.VoiceChatHeadset.Button:SetCommunityInfo(clubId, stream);
				end
			end
		end
	end
	
	self:UpdateCommunitiesButtons();
end

function CommunitiesFrameMixin:GetSelectedStreamForClub(clubId)
	return self.selectedStreamForClub[clubId];
end

function CommunitiesFrameMixin:SetPrivilegesForClub(clubId, privileges)
	self.privilegesForClub[clubId] = privileges;
end

function CommunitiesFrameMixin:GetPrivilegesForClub(clubId)
	return self.privilegesForClub[clubId] or {};
end

function CommunitiesFrameMixin:HasPrivilegesForClub(clubId)
	return self.privilegesForClub[clubId] ~= nil;
end

function CommunitiesFrameMixin:UpdateStreamDropDown()
	local clubId = self:GetSelectedClubId();
	local selectedStream = self:GetSelectedStreamForClub(clubId);
	UIDropDownMenu_SetSelectedValue(self.StreamDropDownMenu, selectedStream and selectedStream.streamId or nil, true);
	local streamName = selectedStream and CommunitiesStreamDropDownMenu_GetStreamName(clubId, selectedStream) or "";
	UIDropDownMenu_SetText(self.StreamDropDownMenu, streamName);
	self.StreamDropDownMenu:UpdateUnreadNotification();
end

function CommunitiesFrameMixin:OnHide()
	if (not FRIENDS_COMMUNITY_SWAP_IN_PROGRESS) then
		PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	end
	
	self:CloseActiveDialogs();
	C_Club.ClearClubPresenceSubscription();
	C_Club.ClearAutoAdvanceStreamViewMarker();
	C_Club.Flush();
	self:SetFocusedStream(nil, nil);
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	UpdateMicroButtons();
end

function CommunitiesFrameMixin:ShowCreateChannelDialog()
	self.EditStreamDialog:ShowCreateDialog(self:GetSelectedClubId());
end

function CommunitiesFrameMixin:ShowEditStreamDialog(clubId, streamId)
	local stream = C_Club.GetStreamInfo(clubId, streamId);
	if stream then
		self.EditStreamDialog:ShowEditDialog(clubId, stream);
	end
end

function CommunitiesFrameMixin:ShowNotificationSettingsDialog(clubId)
	self.NotificationSettingsDialog:SelectClub(clubId);
	self.NotificationSettingsDialog:Show();
end

function CommunitiesFrameMaximizeMinimizeButton_OnLoad(self)
	local function OnMaximize(frame)
		local communitiesFrame = frame:GetParent();
		local displayMode = communitiesFrame:GetDisplayMode();
		if not displayMode or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		end
		communitiesFrame:ValidateDisplayMode();
		communitiesFrame:SetSize(814, 424);
		communitiesFrame.Chat:SetPoint("TOPLEFT", communitiesFrame.CommunitiesList, "TOPRIGHT", 31, -44);
		communitiesFrame.Chat:SetPoint("BOTTOMRIGHT", communitiesFrame.MemberList, "BOTTOMLEFT", -32, 28);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("TOPLEFT", communitiesFrame.Chat.MessageFrame, "TOPRIGHT", 10, -11);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("BOTTOMLEFT", communitiesFrame.Chat.MessageFrame, "BOTTOMRIGHT", 10, -17);
		communitiesFrame.Chat.InsetFrame:Show();
		communitiesFrame.ChatEditBox:ClearAllPoints();
		communitiesFrame.ChatEditBox:SetPoint("TOPLEFT", communitiesFrame.Chat, "BOTTOMLEFT", -4, -4);
		communitiesFrame.ChatEditBox:SetPoint("TOPRIGHT", communitiesFrame.Chat, "BOTTOMRIGHT", 3, -4);
		communitiesFrame.StreamDropDownMenu:ClearAllPoints();
		communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", 188, -28);
		UIDropDownMenu_SetWidth(communitiesFrame.StreamDropDownMenu, 160);
		communitiesFrame.portrait:Show();
		communitiesFrame.TopLeftCorner:Hide();
		communitiesFrame.TopBorder:SetPoint("TOPLEFT", communitiesFrame.PortraitFrame, "TOPRIGHT",  0, -10);
		communitiesFrame.LeftBorder:SetPoint("TOPLEFT", communitiesFrame.PortraitFrame, "BOTTOMLEFT",  8, 0);
		communitiesFrame.PortraitOverlay:Show();
		communitiesFrame.VoiceChatHeadset:SetPoint("TOPRIGHT", -15, -26);
		UpdateUIPanelPositions();
	end
	
	self:SetOnMaximizedCallback(OnMaximize);
	
	local function OnMinimize(frame)
		local communitiesFrame = frame:GetParent();
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED);
		communitiesFrame:ValidateDisplayMode();
		communitiesFrame:SetSize(338, 424);
		communitiesFrame.Chat:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 13, -67);
		communitiesFrame.Chat:SetPoint("BOTTOMRIGHT", communitiesFrame, "BOTTOMRIGHT", -35, 36);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("TOPLEFT", communitiesFrame.Chat.MessageFrame, "TOPRIGHT", 8, -10);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("BOTTOMLEFT", communitiesFrame.Chat.MessageFrame, "BOTTOMRIGHT", 8, 7);
		communitiesFrame.Chat.InsetFrame:Hide();
		communitiesFrame.ChatEditBox:ClearAllPoints();
		communitiesFrame.ChatEditBox:SetPoint("BOTTOMLEFT", communitiesFrame, "BOTTOMLEFT", 10, 0);
		communitiesFrame.ChatEditBox:SetPoint("BOTTOMRIGHT", communitiesFrame, "BOTTOMRIGHT", -12, 0);
		communitiesFrame.StreamDropDownMenu:ClearAllPoints();
		communitiesFrame.StreamDropDownMenu:SetPoint("LEFT", communitiesFrame.CommunitiesListDropDownMenu, "RIGHT", -25, 0);
		UIDropDownMenu_SetWidth(communitiesFrame.StreamDropDownMenu, 115);
		communitiesFrame.portrait:Hide();
		communitiesFrame.TopLeftCorner:Show();
		communitiesFrame.TopBorder:SetPoint("TOPLEFT", communitiesFrame.TopLeftCorner, "TOPRIGHT",  0, 0);
		communitiesFrame.LeftBorder:SetPoint("TOPLEFT", communitiesFrame.TopLeftCorner, "BOTTOMLEFT",  0, 0);
		communitiesFrame.PortraitOverlay:Hide();
		communitiesFrame.VoiceChatHeadset:SetPoint("TOPRIGHT", -10, -26);
		UpdateUIPanelPositions();
	end
	
	self:SetOnMinimizedCallback(OnMinimize);
	
	self:SetMinimizedCVar("miniCommunitiesFrame");
end

function CommunitiesFrameToggleToFriends(selectedTab)
	FRIENDS_COMMUNITY_SWAP_IN_PROGRESS = true;
	ToggleCommunitiesFrame();
	ToggleFriendsFrame(selectedTab, true);
	FRIENDS_COMMUNITY_SWAP_IN_PROGRESS = false;
end

CommunitiesControlFrameMixin = {};

function CommunitiesControlFrameMixin:OnShow()
	self:Update();
end

function CommunitiesControlFrameMixin:Update()
	if not self:IsShown() then
		return;
	end
	
	self.CommunitiesSettingsButton:Hide();
	
	local communitiesFrame = self:GetCommunitiesFrame();
	local clubId = communitiesFrame:GetSelectedClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			local privileges = communitiesFrame:GetPrivilegesForClub(clubId);
			local hasCommunitySettingsPrivilege = privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast;
			if hasCommunitySettingsPrivilege then
				self.CommunitiesSettingsButton:Show();
				self.CommunitiesSettingsButton:SetText(COMMUNITIES_SETTINGS_BUTTON_LABEL);
			end
		end
	end
end

function CommunitiesControlFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end