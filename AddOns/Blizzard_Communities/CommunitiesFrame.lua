
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
	"CLUB_REMOVED",
	"CLUB_SELF_MEMBER_ROLE_UPDATED",
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

	self:UpdateCommunitiesButtons();
end

function CommunitiesFrameMixin:OnShow()
	self.PortraitOverlay.Portrait:SetTexture(132621); -- TODO:: Replace this hardcoded icon.
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	self:UpdateClubSelection();
end

function CommunitiesFrameMixin:OnEvent(event, ...)
	if event == "CLUB_STREAMS_LOADED" then
		local clubId = ...;
		if clubId == self:GetSelectedClubId() then
			local streams = C_Club.GetStreams(clubId);
			if not self.selectedStreamForClub[clubId] then
				self:SelectStream(clubId, streams[1].streamId);
			end
			
			self:UpdateStreamDropDown();
		end
	elseif event == "CLUB_STREAM_ADDED" then
		local clubId, streamId = ...;
		if clubId == self:GetSelectedClubId() then
			self.streams = C_Club.GetStreams(clubId);
			if not self.selectedStreamForClub[clubId] then
				self:SelectStream(clubId, streamId);
			end
			
			self:UpdateStreamDropDown();
		end
	elseif event == "CLUB_STREAM_REMOVED" then
		local clubId, streamId = ...;
		local selectedStream = self.selectedStreamForClub[clubId];
		local isSelectedClub = clubId == self:GetSelectedClubId();
		local isSelectedStream = selectedStream and selectedStream.streamId == streamId;
		if isSelectedClub or isSelectedStream then
			local streams = C_Club.GetStreams(clubId);
			if isSelectedStream and #streams > 0 then
				self:SelectStream(clubId, streams[1].streamId);
			end
			
			if isSelectedClub then
				self.streams = streams;
				self:UpdateStreamDropDown();
			end
		end
	elseif event == "CLUB_STREAM_SUBSCRIBED" then
		local clubId, streamId = ...;
		if clubId == self:GetSelectedClubId() and streamId == self:GetSelectedStreamId() then
			RequestInitialMessages(clubId, streamId);
		end
	elseif event == "CLUB_REMOVED" then
		local clubId = ...;
		if clubId == self:GetSelectedClubId() then
			self:UpdateClubSelection();
		end
	elseif event == "CLUB_SELF_MEMBER_ROLE_UPDATED" then
		local clubId, roleId = ...;
		if clubId == self:GetSelectedClubId() then
			self.privilegesForClub[clubId] = C_Club.GetClubPrivileges(clubId);
		else
			self.privilegesForClub[clubId] = nil;
		end
		self:UpdateCommunitiesButtons();
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

function CommunitiesFrameMixin:UpdateClubSelection()
	-- TODO:: We should prioritize selecting guild communities once those exist.

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
	},
};

function CommunitiesFrameMixin:SetDisplayMode(displayMode)
	if self.displayMode == displayMode then
		return;
	end
	
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
	
	self:UpdateCommunitiesTabs();
	
	self:TriggerEvent(CommunitiesFrameMixin.Event.DisplayModeChanged, displayMode);
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
	end
	
	
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
	if StaticPopup_Visible("INVITE_COMMUNITY_MEMBER") then
		StaticPopup_Hide("INVITE_COMMUNITY_MEMBER");
	end
	
	self.ChatEditBox:SetEnabled(clubId ~= nil);
	if clubId then
		SetCVar("lastSelectedClubId", clubId)
	
		C_Club.SetClubPresenceSubscription(clubId);
		
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			self.streams = C_Club.GetStreams(clubId);
			if (not self.selectedStreamForClub[clubId]) then
				self.selectedStreamForClub[clubId] = {};
			end

			-- TODO:: Update a new club after it's been added and we've
			-- retrieved stream info and so forth for it.
			if self.streams[1] then
				self:SelectStream(clubId, self.streams[1].streamId);
			else
				self:SelectStream(clubId, nil);
			end
			
			if not self.privilegesForClub[clubId] then
				self.privilegesForClub[clubId] = C_Club.GetClubPrivileges(clubId);
			end
			
			if self:GetDisplayMode() ~= COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
				self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
			end
			
			C_Club.SetClubPresenceSubscription(clubId);
		else
			local invitationInfo = C_Club.GetInvitationInfo(clubId);
			if invitationInfo then
				self.streams = {};
				if (not self.selectedStreamForClub[clubId]) then
					self.selectedStreamForClub[clubId] = {};
				end
				if (not self.privilegesForClub[clubId]) then
					self.privilegesForClub[clubId] = {};
				end
				
				self.InvitationFrame:DisplayInvitation(invitationInfo);
				self:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
			end
		end
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
		local privileges = self.privilegesForClub[clubId];
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
		return;
	end
	
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
			end
		end
	end
end

function CommunitiesFrameMixin:GetSelectedStreamForClub(clubId)
	return self.selectedStreamForClub[clubId];
end

function CommunitiesFrameMixin:UpdateStreamDropDown()
	local clubId = self:GetSelectedClubId();
	local selectedStream = self.selectedStreamForClub[clubId];
	self.StreamDropDownMenu.streams = self.streams;
	self.StreamDropDownMenu.privileges = self.privilegesForClub[clubId];
	UIDropDownMenu_SetSelectedValue(self.StreamDropDownMenu, selectedStream and selectedStream.streamId or nil, true);

	UIDropDownMenu_SetText(self.StreamDropDownMenu, selectedStream and selectedStream.name or "");
end

function CommunitiesFrameMixin:OnHide()
	C_Club.ClearClubPresenceSubscription();
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
end

function CommunitiesFrameMixin:ShowCreateChannelDialog()
	self.EditStreamDialog:ShowCreateDialog(self:GetSelectedClubId());
end

function CommunitiesFrameMixin:ShowEditStreamDialog()
	local clubId = self:GetSelectedClubId();
	local stream = self.selectedStreamForClub[clubId];
	if stream then
		self.EditStreamDialog:ShowEditDialog(clubId, self.selectedStreamForClub[clubId]);
	end
end

function CommunitiesFrameMixin:ShowNotificationSettingsDialog()
	self.NotificationSettingsDialog:Show();
end

function CommunitiesFrameMaximizeMinimizeButton_OnLoad(self)
	local function OnMaximize(frame)
		local communitiesFrame = frame:GetParent();
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.CHAT);
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
			local privileges = C_Club.GetClubPrivileges(clubId);
			if privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast then
				self.CommunitiesSettingsButton:Show();
				self.CommunitiesSettingsButton:SetText(clubInfo.clubType == Enum.ClubType.BattleNet and COMMUNITIES_SETTINGS_BUTTON_LABEL or COMMUNITIES_SETTINGS_BUTTON_CHARACTER_LABEL);
			end
		
			if clubInfo.clubType == Enum.ClubType.Guild then
				-- TODO:: Check guild permissions
				self.GuildRecruitmentButton:Show();
				self.GuildRecruitmentButton:ClearAllPoints();
				if self.CommunitiesSettingsButton:IsShown() then
					self.GuildRecruitmentButton:SetPoint("RIGHT", self.CommunitiesSettingsButton, "LEFT", -2, 0);
				else
					self.GuildRecruitmentButton:SetPoint("BOTTOMRIGHT");
				end
				
				self.GuildControlButton:Show();
			end
		end
	end
end

function CommunitiesControlFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end
