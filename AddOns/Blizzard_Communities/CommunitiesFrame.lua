
CommunitiesFrameMixin = CreateFromMixins(CallbackRegistryBaseMixin);

CommunitiesFrameMixin:GenerateCallbackEvents(
{
    "InviteAccepted",
    "InviteDeclined",
	"DisplayModeChanged",
	"ClubSelected",
	"StreamSelected",
});

local COMMUNITIES_FRAME_EVENTS = {
	"CLUB_STREAMS_LOADED",
	"CLUB_STREAM_ADDED",
	"CLUB_STREAM_REMOVED",
	"CLUB_STREAM_SUBSCRIBED",
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_SELF_MEMBER_ROLE_UPDATED",
	"STREAM_VIEW_MARKER_UPDATED",
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

local function RangeIsEmpty(range)
	return range.newestMessageId.epoch < range.oldestMessageId.epoch or (range.newestMessageId.epoch == range.oldestMessageId.epoch and range.newestMessageId.position < range.oldestMessageId.position);
end

local function RequestInitialMessages(clubId, streamId)
	local ranges = C_Club.GetMessageRanges(clubId, streamId);
	if (not ranges or #ranges == 0 or RangeIsEmpty(ranges[#ranges])) then
		C_Club.RequestMoreMessagesBefore(clubId, streamId, nil);
	end
end

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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	
	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, because they share one presence subscription
	if ChannelFrame and ChannelFrame:IsShown() then
		HideUIPanel(ChannelFrame);
	end

	local clubId = self:GetSelectedClubId();
	if clubId  then
		C_Club.SetClubPresenceSubscription(clubId);
	end

	SetPortraitToTexture(self.PortraitOverlay.Portrait, "Interface\\Icons\\Achievement_General_StayClassy");
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	self:UpdateClubSelection();
	UpdateMicroButtons();
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
	elseif event == "CLUB_STREAM_SUBSCRIBED" then
		local clubId, streamId = ...;
		if clubId == self:GetSelectedClubId() and streamId == self:GetSelectedStreamId() then
			RequestInitialMessages(clubId, streamId);
		end
	elseif event == "CLUB_ADDED" then
		local clubId = ...;
		self:AddNewClubId(clubId);
	elseif event == "CLUB_REMOVED" then
		local clubId = ...;
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
						C_Club.AddClubStreamToChatWindow(clubId, stream.streamId, 1);
						ChatFrame_AddCommunitiesChannel(DEFAULT_CHAT_FRAME, clubId, stream.streamId);
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
	
	if not IsInGuild() then
		self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
		self:SelectClub(nil);
	end
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
		"GuildMemberListDropDownMenu",
	},
	
	INVITATION = {
		"CommunitiesList",
		"InvitationFrame",
	},
	
	GUILD_FINDER = {
		"CommunitiesList",
		"GuildFinderFrame",
	},
	
	GUILD_BENEFITS = {
		"CommunitiesList",
		"GuildBenefitsFrame",
		"CommunitiesControlFrame",
	},
	
	GUILD_INFO = {
		"CommunitiesList",
		"GuildDetailsFrame",
		"GuildLogButton",
		"CommunitiesControlFrame",
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

	for i, mode in pairs(COMMUNITIES_FRAME_DISPLAY_MODES) do
		if mode ~= displayMode then
			for j, subframe in ipairs(mode) do
				self[subframe]:Hide();
			end
		end
	end
	
	for i, subframe in ipairs(displayMode) do
		self[subframe]:Show();
	end
	
	-- If we run into more cases where we need more specific controls on what
	-- is displayed in a displayMode then we should add support for conditional
	-- frames in displayMode based on clubType or perhaps a predicate function.
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER then
		local isGuildCommunitySelected = false;
		local clubId = self:GetSelectedClubId();
		if clubId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo then
				isGuildCommunitySelected = clubInfo.clubType == Enum.ClubType.Guild;
			end
		end
		
		self.GuildMemberListDropDownMenu:SetShown(isGuildCommunitySelected);
	end
	
	self.MaximizeMinimizeFrame.MinimizeButton:SetEnabled(displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION and displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
	
	self:TriggerEvent(CommunitiesFrameMixin.Event.DisplayModeChanged, displayMode);
	
	self:UpdateCommunitiesTabs();
end

function CommunitiesFrameMixin:ValidateDisplayMode()
	local clubId = self:GetSelectedClubId();
	if clubId then
		local displayMode = self:GetDisplayMode();
		local guildDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO;
		local clubInfo = C_Club.GetClubInfo(clubId);
		local isGuildCommunitySelected = clubInfo and clubInfo.clubType == Enum.ClubType.Guild;
		if not isGuildCommunitySelected and guildDisplay then
			self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION then
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
	self.GuildBenefitsTab:Hide();
	self.GuildInfoTab:Hide();
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or 
			displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or
			displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS or
			displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO then
		self.ChatTab:Show();
		self.RosterTab:Show();
		local clubId = self:GetSelectedClubId();
		if clubId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo then
				self.GuildBenefitsTab:SetShown(clubInfo.clubType == Enum.ClubType.Guild);
				self.GuildInfoTab:SetShown(clubInfo.clubType == Enum.ClubType.Guild);
			end
		end
		
		SetUIPanelAttribute(self, "extraWidth", 32);
	else
		SetUIPanelAttribute(self, "extraWidth", 0);
	end
	
	UpdateUIPanelPositions(self);
	
	self.ChatTab:SetChecked(false);
	self.RosterTab:SetChecked(false);
	self.GuildBenefitsTab:SetChecked(false);
	self.GuildInfoTab:SetChecked(false);
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT then
		self.ChatTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER then
		self.RosterTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS then
		self.GuildBenefitsTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO then
		self.GuildInfoTab:SetChecked(true);
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
			C_Club.SetAvatarTexture(self.PortraitOverlay.Portrait, clubInfo.avatarId, clubInfo.clubType);
			local selectedStream = self:GetSelectedStreamForClub(clubId);
			if selectedStream ~= nil then
				self:SelectStream(clubId, selectedStream.streamId);
			else
				local streams = C_Club.GetStreams(clubId);
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
			end
		end
	else
		SetPortraitToTexture(self.PortraitOverlay.Portrait, "Interface\\Icons\\Achievement_General_StayClassy");
	end
	
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
		local privileges = self:GetPrivilegesForClub(clubId);
		if privileges.canSendInvitation or privileges.canSendGuestInvitation then
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
						RequestInitialMessages(clubId, streamId);
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
	UIDropDownMenu_SetText(self.StreamDropDownMenu, selectedStream and selectedStream.name or "");
	self.StreamDropDownMenu:UpdateUnreadNotification();
end

function CommunitiesFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	
	self:CloseActiveDialogs();
	C_Club.ClearClubPresenceSubscription();
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

function CommunitiesFrameMixin:ShowNotificationSettingsDialog()
	self.NotificationSettingsDialog:Show();
end

function CommunitiesFrameMaximizeMinimizeButton_OnLoad(self)
	local function OnMaximize(frame)
		local communitiesFrame = frame:GetParent();
		if communitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		end
		
		communitiesFrame:SetSize(814, 426);
		communitiesFrame.Chat:SetPoint("TOPLEFT", communitiesFrame.CommunitiesList, "TOPRIGHT", 30, -46);
		communitiesFrame.Chat:SetPoint("BOTTOMRIGHT", communitiesFrame.MemberList, "BOTTOMLEFT", -22, 28);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("TOPLEFT", communitiesFrame.Chat.MessageFrame, "TOPRIGHT", 0, -9);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("BOTTOMLEFT", communitiesFrame.Chat.MessageFrame, "BOTTOMRIGHT", 0, -17);
		communitiesFrame.Chat.InsetFrame:Show();
		communitiesFrame.ChatEditBox:ClearAllPoints();
		communitiesFrame.ChatEditBox:SetPoint("TOPLEFT", communitiesFrame.Chat, "BOTTOMLEFT", -4, -3);
		communitiesFrame.ChatEditBox:SetPoint("TOPRIGHT", communitiesFrame.Chat, "BOTTOMRIGHT", -8, -3);
		communitiesFrame.StreamDropDownMenu:ClearAllPoints();
		communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", 188, -30);
		UIDropDownMenu_SetWidth(communitiesFrame.StreamDropDownMenu, 160);
		communitiesFrame.portrait:Show();
		communitiesFrame.TopLeftCorner:Hide();
		communitiesFrame.TopBorder:SetPoint("TOPLEFT", communitiesFrame.PortraitFrame, "TOPRIGHT",  0, -10);
		communitiesFrame.LeftBorder:SetPoint("TOPLEFT", communitiesFrame.PortraitFrame, "BOTTOMLEFT",  8, 0);
		communitiesFrame.PortraitOverlay:Show();
		UpdateUIPanelPositions();
	end
	
	self:SetOnMaximizedCallback(OnMaximize);
	
	local function OnMinimize(frame)
		local communitiesFrame = frame:GetParent();
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED);
		communitiesFrame:SetSize(322, 404);
		communitiesFrame.Chat:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 13, -64);
		communitiesFrame.Chat:SetPoint("BOTTOMRIGHT", communitiesFrame, "BOTTOMRIGHT", -32, 32);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("TOPLEFT", communitiesFrame.Chat.MessageFrame, "TOPRIGHT", 5, -13);
		communitiesFrame.Chat.MessageFrame.ScrollBar:SetPoint("BOTTOMLEFT", communitiesFrame.Chat.MessageFrame, "BOTTOMRIGHT", 5, 11);
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
		UpdateUIPanelPositions();
	end
	
	self:SetOnMinimizedCallback(OnMinimize);
	
	self:SetMinimizedCVar("miniCommunitiesFrame");
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
	self.GuildRecruitmentButton:Hide();
	self.GuildControlButton:Hide();
	
	local communitiesFrame = self:GetCommunitiesFrame();
	local clubId = communitiesFrame:GetSelectedClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			local privileges = communitiesFrame:GetPrivilegesForClub(clubId);
			local isGuild = clubInfo.clubType == Enum.ClubType.Guild;
			local hasCommunitySettingsPrivilege = privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast;
			if not isGuild and hasCommunitySettingsPrivilege then
				self.CommunitiesSettingsButton:Show();
				self.CommunitiesSettingsButton:SetText(clubInfo.clubType == Enum.ClubType.BattleNet and COMMUNITIES_SETTINGS_BUTTON_LABEL or COMMUNITIES_SETTINGS_BUTTON_CHARACTER_LABEL);
			end
		
			if isGuild then
				-- TODO:: Check guild permissions
				self.GuildRecruitmentButton:Show();
				self.GuildControlButton:Show();
			end
		end
	end
end

function CommunitiesControlFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end