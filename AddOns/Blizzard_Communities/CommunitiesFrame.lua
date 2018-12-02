
CommunitiesFrameMixin = CreateFromMixins(CallbackRegistryBaseMixin);

CommunitiesFrameMixin:GenerateCallbackEvents(
{
    "InviteAccepted",
    "InviteDeclined",
	"TicketAccepted",
	"DisplayModeChanged",
	"ClubSelected",
	"StreamSelected",
	"SelectedClubInfoUpdated",
});

local COMMUNITIES_FRAME_EVENTS = {
	"CLUB_STREAMS_LOADED",
	"CLUB_STREAM_ADDED",
	"CLUB_STREAM_REMOVED",
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_UPDATED",
	"CLUB_SELF_MEMBER_ROLE_UPDATED",
	"STREAM_VIEW_MARKER_UPDATED",
	"BN_DISCONNECTED",
	"PLAYER_GUILD_UPDATE",
	"CHANNEL_UI_UPDATE",
	"UPDATE_CHAT_COLOR",
	"GUILD_RENAME_REQUIRED",
	"REQUIRED_GUILD_RENAME_RESULT",
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

	PortraitFrameTemplate_SetTitle(self, COMMUNITIES_FRAME_TITLE);

	UIDropDownMenu_Initialize(self.StreamDropDownMenu, CommunitiesStreamDropDownMenu_Initialize);

	self.selectedStreamForClub = {};
	self.privilegesForClub = {};
	self.newClubIds = {};

	self:UpdateCommunitiesButtons();
end

function CommunitiesFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	self:SetNeedsGuildNameChange(GetGuildRenameRequired());

	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, because they share one presence subscription
	if ChannelFrame and ChannelFrame:IsShown() then
		HideUIPanel(ChannelFrame);
	end

	local clubId = self:GetSelectedClubId();
	if clubId  then
		self:SelectClub(clubid, true);
	end

	self:UpdatePortrait();

	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	self:UpdateClubSelection();
	self:UpdateStreamDropDown();
	UpdateMicroButtons();

	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:ScrollToClub(self:GetSelectedClubId());
	end
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

		if self.CommunitiesList:IsShown() then
			self:SelectClub(clubId);
			self.CommunitiesList:ScrollToClub(clubId);
		elseif self:GetSelectedClubId() == nil then
			self:UpdateClubSelection();
		end
	elseif event == "CLUB_REMOVED" then
		local clubId = ...;
		self:SetPrivilegesForClub(clubId, nil);
		if clubId == self:GetSelectedClubId() then
			self:UpdateClubSelection();
		end
	elseif event == "CLUB_UPDATED" then
		self:ValidateDisplayMode();
		local clubId = ...;
		if self:GetSelectedClubId() == clubId then
			self:UpdateSelectedClubInfo(clubId);
			self:UpdatePortrait();
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
	elseif event == "PLAYER_GUILD_UPDATE" then
		local guildClubId = C_Club.GetGuildClubId();
		if guildClubId ~= nil and guildClubId == self:GetSelectedClubId() then
			SetLargeGuildTabardTextures("player", self.PortraitOverlay.TabardEmblem, self.PortraitOverlay.TabardBackground, self.PortraitOverlay.TabardBorder);
		end
	elseif event == "CHANNEL_UI_UPDATE" or event == "UPDATE_CHAT_COLOR" then
		self:UpdateStreamDropDown();
	elseif event == "GUILD_RENAME_REQUIRED" then
		self:SetNeedsGuildNameChange(...);
		self:ValidateDisplayMode();
	elseif event == "REQUIRED_GUILD_RENAME_RESULT" then
		local success = ...
		if success then
			self:SetNeedsGuildNameChange(GetGuildRenameRequired());
			self:ValidateDisplayMode();
		else
			UIErrorsFrame:AddExternalErrorMessage(ERR_GUILD_NAME_INVALID);
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
		self:CloseActiveDialogs();
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
	else
		self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
	end
end

function CommunitiesFrameMixin:SelectClub(clubId, forceUpdate)
	if forceUpdate or clubId ~= self.selectedClubId then
		self.ChatEditBox:SetEnabled(clubId ~= nil);
		self:UpdateSelectedClubInfo(clubId);
	end
end

function CommunitiesFrameMixin:UpdateSelectedClubInfo(clubId)
	local previousClubId = self.selectedClubId;
	self.selectedClubId = clubId;
	self.selectedClubInfo = clubId ~= nil and C_Club.GetClubInfo(clubId) or nil;
	if previousClubId ~= clubId then
		self:OnClubSelected(clubId);
	else
		self:TriggerEvent(CommunitiesFrameMixin.Event.SelectedClubInfoUpdated, clubId);
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
		"CommunitiesCalendarButton",
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

	TICKET = {
		"CommunitiesList",
		"TicketFrame",
	},

	GUILD_FINDER = {
		"CommunitiesList",
		"GuildFinderFrame",
	},

	GUILD_BENEFITS = {
		"CommunitiesList",
		"GuildBenefitsFrame",
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

	local subframesToUpdate = {};
	for i, mode in pairs(COMMUNITIES_FRAME_DISPLAY_MODES) do
		for j, subframe in ipairs(mode) do
			subframesToUpdate[subframe] = subframesToUpdate[subframe] or mode == displayMode;
		end
	end

	for subframe, shouldShow in pairs(subframesToUpdate) do
		self[subframe]:SetShown(shouldShow);
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
		if isGuildCommunitySelected then
			GuildRoster();
		end
		self.GuildMemberListDropDownMenu:SetShown(isGuildCommunitySelected);
	end

	self:UpdateMaximizeMinimizeButton();

	self:TriggerEvent(CommunitiesFrameMixin.Event.DisplayModeChanged, displayMode);

	self:UpdateCommunitiesButtons();
	self:UpdateCommunitiesTabs();
end

function CommunitiesFrameMixin:UpdateMaximizeMinimizeButton()
	self.MaximizeMinimizeFrame.MinimizeButton:SetEnabled(self.displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION and self.displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER and not self.chatDisabled);
end

function CommunitiesFrameMixin:GetNeedsGuildNameChange()
	return self.hasForcedNameChange;
end

function CommunitiesFrameMixin:SetNeedsGuildNameChange(needsNameChange)
	self.hasForcedNameChange = needsNameChange;
end

function CommunitiesFrameMixin:SetGuildNameAlertBannerMode(bannerMode)
	self.GuildNameAlertFrame.topAnchored = bannerMode;
	self:ValidateDisplayMode();
end

function CommunitiesFrameMixin:ValidateDisplayMode()
	local clubId = self:GetSelectedClubId();
	if clubId then
		local displayMode = self:GetDisplayMode();
		local guildDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO;
		local clubInfo = C_Club.GetClubInfo(clubId);
		self.chatDisabled = C_Club.IsAccountMuted(clubId);
		self.defaultMode = self.chatDisabled and COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or COMMUNITIES_FRAME_DISPLAY_MODES.CHAT;
		local isGuildCommunitySelected = clubInfo and clubInfo.clubType == Enum.ClubType.Guild;
		if not isGuildCommunitySelected and guildDisplay then
			self:SetDisplayMode(self.defaultMode);
		elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.TICKET then
			self:SetDisplayMode(self.defaultMode);
		elseif self.chatDisabled and displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT then
			self:SetDisplayMode(self.defaultMode);
		elseif self.chatDisabled and displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			--self:SetDisplayMode(self.defaultMode);
			self.MaximizeMinimizeFrame.MaximizeButton:Click();
		elseif displayMode == nil then
			self:SetDisplayMode(self.defaultMode);
		end

		if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER then
			self.GuildMemberListDropDownMenu:SetShown(isGuildCommunitySelected);
		end

		self.ChatTab:SetEnabled(not self.chatDisabled);
		self.ChatTab.IconOverlay:SetShown(self.chatDisabled);
		if self.chatDisabled then
			self.ChatTab.tooltip2 = ERR_PARENTAL_CONTROLS_CHAT_MUTED;
		else
			self.ChatTab.tooltip2 = nil;
		end
		self:UpdateMaximizeMinimizeButton();

		local needsGuildNameChange = isGuildCommunitySelected and self:GetNeedsGuildNameChange();
		if needsGuildNameChange then
			if self.GuildNameAlertFrame.topAnchored == nil then
				self.GuildNameAlertFrame.topAnchored = not IsGuildLeader();
			end

			if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
				self.GuildNameChangeFrame:SetPoint("TOPLEFT", self.Inset, "TOPLEFT", 3, -3);
				self.GuildNameChangeFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", 0, 5);
			else
				self.GuildNameChangeFrame:SetPoint("TOPLEFT", self.CommunitiesList, "TOPRIGHT", 24, -40);
				self.GuildNameChangeFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", 0, 0);
			end

			self.GuildNameAlertFrame:ClearAllPoints();
			if self.GuildNameAlertFrame.topAnchored then
				self.GuildNameAlertFrame:SetPoint("BOTTOM", self, "TOP");
			else
				self.GuildNameAlertFrame:SetPoint("TOP", self.GuildNameChangeFrame, "TOP", 0, -24)
			end

			if IsGuildLeader() then
				self.GuildNameChangeFrame.GMText:Show();
				self.GuildNameChangeFrame.MemberText:Hide();
				self.GuildNameChangeFrame.Button:SetText(ACCEPT);
				self.GuildNameChangeFrame.Button:SetPoint("TOP", self.GuildNameChangeFrame.EditBox, "BOTTOM", 0, -10);
				self.GuildNameChangeFrame.RenameText:Show();
				self.GuildNameChangeFrame.EditBox:Show();
			else
				self.GuildNameChangeFrame.GMText:Hide();
				self.GuildNameChangeFrame.MemberText:Show();
				self.GuildNameChangeFrame.Button:SetText(OKAY);
				self.GuildNameChangeFrame.Button:SetPoint("TOP", self.GuildNameChangeFrame.MemberText, "BOTTOM", 0, -30);
				self.GuildNameChangeFrame.RenameText:Hide();
				self.GuildNameChangeFrame.EditBox:Hide();
			end

			if self.GuildNameAlertFrame.topAnchored then
				self.GuildNameAlertFrame.Alert:SetFontObject(GameFontHighlight);
				self.GuildNameAlertFrame.Alert:ClearAllPoints();
				self.GuildNameAlertFrame.Alert:SetPoint("BOTTOM", self.GuildNameAlertFrame, "CENTER", 0, 0);
				self.GuildNameAlertFrame.Alert:SetWidth(190);
				self.GuildNameAlertFrame:SetSize(256, 60);
				self.GuildNameAlertFrame:Enable();
				self.GuildNameAlertFrame.ClickText:Show();
			else
				self.GuildNameAlertFrame.Alert:SetFontObject(GameFontHighlightMedium);
				self.GuildNameAlertFrame.Alert:ClearAllPoints();
				self.GuildNameAlertFrame.Alert:SetPoint("CENTER", self.GuildNameAlertFrame, "CENTER", 0, 0);
				self.GuildNameAlertFrame.Alert:SetWidth(220);
				self.GuildNameAlertFrame:SetSize(300, 40);
				self.GuildNameAlertFrame:Disable();
				self.GuildNameAlertFrame.ClickText:Hide();
			end
		end

		self.GuildNameAlertFrame:SetShown(needsGuildNameChange);
		self.GuildNameChangeFrame:SetShown(needsGuildNameChange and not self.GuildNameAlertFrame.topAnchored);
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

function CommunitiesFrameMixin:UpdatePortrait()
	local clubId = self:GetSelectedClubId();
	local clubInfo = clubId and C_Club.GetClubInfo(clubId) or nil;
	local isGuildCommunity = clubInfo and clubInfo.clubType == Enum.ClubType.Guild or nil;
	self.PortraitOverlay.Portrait:SetShown(not isGuildCommunity);
	self.PortraitOverlay.TabardEmblem:SetShown(isGuildCommunity);
	self.PortraitOverlay.TabardBackground:SetShown(isGuildCommunity);
	self.PortraitOverlay.TabardBorder:SetShown(isGuildCommunity);

	if clubInfo == nil then
		SetPortraitToTexture(self.PortraitOverlay.Portrait, "Interface\\Icons\\achievement_guildperk_havegroup willtravel");
	elseif isGuildCommunity then
		SetLargeGuildTabardTextures("player", self.PortraitOverlay.TabardEmblem, self.PortraitOverlay.TabardBackground, self.PortraitOverlay.TabardBorder);
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
				local forceUpdate = true;
				self:SelectStream(clubId, selectedStream.streamId, forceUpdate);
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

			if clubInfo.clubType == Enum.ClubType.Guild then
				GuildRoster();
			end
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

	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:OnClubSelected(clubId); -- TODO:: Convert this to use the registry system of callbacks.
	end
end

function CommunitiesFrameMixin:GetSelectedClubId()
	return self.selectedClubId;
end

function CommunitiesFrameMixin:GetSelectedClubInfo()
	return self.selectedClubInfo;
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
	addToChatButton:SetShown(false);

	if clubId ~= nil then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo and clubInfo.clubType == Enum.ClubType.Guild then
			inviteButton:SetEnabled(CanGuildInvite());
		else
			local privileges = self:GetPrivilegesForClub(clubId);
			if privileges.canSendInvitation then
				inviteButton:SetEnabled(true);
			-- There are currently no plans to allow suggesting members.
			-- elseif privileges.canSuggestMember then
			end
		end

		local selectedStreamId = self:GetSelectedStreamId();
		if selectedStreamId ~= nil and self:GetDisplayMode() ~= COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			local streamInfo = C_Club.GetStreamInfo(clubId, selectedStreamId);
			addToChatButton:SetShown(streamInfo and streamInfo.streamType ~= Enum.ClubStreamType.Guild and streamInfo.streamType ~= Enum.ClubStreamType.Officer);
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

function CommunitiesFrameMixin:SelectStream(clubId, streamId, forceUpdate)
	if not forceUpdate and self.selectedStreamForClub[clubId] and self.selectedStreamForClub[clubId].streamId == streamId then
		return;
	end
	
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

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

function CommunitiesFrameMixin:OpenGuildMemberDetailFrame(clubId, memberInfo)
	self.GuildMemberDetailFrame:DisplayMember(clubId, memberInfo);
end

function CommunitiesFrameMixin:CloseGuildMemberDetailFrame()
	self.GuildMemberDetailFrame:Hide();
end

function CommunitiesFrameMixin:ShowNotificationSettingsDialog(clubId)
	self.NotificationSettingsDialog:SelectClub(clubId);
	self.NotificationSettingsDialog:Show();
end

function CommunitiesFrameMaximizeMinimizeButton_OnLoad(self)
	local function OnMaximize(frame)
		local communitiesFrame = frame:GetParent();
		if communitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			communitiesFrame:SetDisplayMode(self:GetParent().defaultMode or COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
		end
		communitiesFrame:ValidateDisplayMode();
		communitiesFrame:SetSize(814, 426);
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
		ButtonFrameTemplateMinimizable_ShowPortrait(communitiesFrame);
		communitiesFrame.PortraitOverlay:Show();
		communitiesFrame.VoiceChatHeadset:SetPoint("TOPRIGHT", -8, -26);
		UpdateUIPanelPositions();
	end

	self:SetOnMaximizedCallback(OnMaximize);

	local function OnMinimize(frame)
		local communitiesFrame = frame:GetParent();
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED);
		communitiesFrame:ValidateDisplayMode();
		communitiesFrame:SetSize(322, 406);
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
		ButtonFrameTemplateMinimizable_HidePortrait(communitiesFrame);
		communitiesFrame.PortraitOverlay:Hide();
		communitiesFrame.VoiceChatHeadset:SetPoint("TOPRIGHT", -10, -26);
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
				self.GuildControlButton:SetShown(IsGuildLeader());

				local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
				if communitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER and myMemberInfo and myMemberInfo.guildRankOrder then
					local permissions = C_GuildInfo.GuildControlGetRankFlags(myMemberInfo.guildRankOrder);
					local hasInvitePermissions = permissions[GuildControlUIRankSettingsFrame.InviteCheckbox:GetID()];
					self.GuildRecruitmentButton:SetShown(hasInvitePermissions);
					self.GuildRecruitmentButton:ClearAllPoints();
					if self.GuildRecruitmentButton:IsShown() and self.GuildControlButton:IsShown() then
						self.GuildRecruitmentButton:SetPoint("RIGHT", self.GuildControlButton, "LEFT", -2, 0);
					else
						self.GuildRecruitmentButton:SetPoint("BOTTOMRIGHT");
					end
				end
			end
		end
	end
end

function CommunitiesControlFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end