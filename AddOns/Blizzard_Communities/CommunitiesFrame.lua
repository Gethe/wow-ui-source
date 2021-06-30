
CommunitiesFrameMixin = CreateFromMixins(CallbackRegistryMixin);

CommunitiesFrameMixin:GenerateCallbackEvents(
{
    "InviteAccepted",
    "InviteDeclined",
	"TicketAccepted",
	"DisplayModeChanged",
	"ClubSelected",
	"StreamSelected",
	"SelectedClubInfoUpdated",
	"MemberListDropDownShown",
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
	"CLUB_FINDER_RECRUITMENT_POST_RETURNED",
	"CLUB_FINDER_ENABLED_OR_DISABLED",
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
	"ADD_GUILDMEMBER",
	"ADD_GUILDMEMBER_WITH_FINDER_LINK",
};

local CLUB_FINDER_APPLICANT_LIST_EVENTS = {
	"GUILD_ROSTER_UPDATE",
	"CLUB_FINDER_RECRUITS_UPDATED",
	"CLUB_FINDER_APPLICATIONS_UPDATED",
};


local function InitSeenApplicants()
	g_clubIdToSeenApplicants = g_clubIdToSeenApplicants or {};
end

local function UpdateSeenApplicants(clubId, seenApplicants)
	g_clubIdToSeenApplicants[clubId] = {};
	for i = 1, #seenApplicants do
		local applicant = seenApplicants[i];
		g_clubIdToSeenApplicants[clubId][applicant.playerGUID] = true;
	end
end

local function HasNewClubApplications(clubId)
	if not clubId then
		return false;
	end

	local applicantList = C_ClubFinder.ReturnClubApplicantList(clubId);

	local seenApplicants = g_clubIdToSeenApplicants[clubId] or {};

	for i = 1, #applicantList do
		local applicant = applicantList[i];
		if not seenApplicants[applicant.playerGUID] then
			return true;
		end
	end

	return false;
end

function CommunitiesFrameMixin:RequestSubscribedClubFinderPostingInfo()
	if(C_ClubFinder.IsEnabled()) then 
		C_ClubFinder.RequestSubscribedClubPostingIDs();
	end
end 

function CommunitiesFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:SetTitle(COMMUNITIES_FRAME_TITLE);

	UIDropDownMenu_Initialize(self.StreamDropDownMenu, CommunitiesStreamDropDownMenu_Initialize);

	self.selectedStreamForClub = {};
	self.privilegesForClub = {};
	self.newClubIds = {};

	self:UpdateCommunitiesButtons();

	self:RequestSubscribedClubFinderPostingInfo();

	self:RegisterEvent("ADDON_LOADED");

	self.ReportFrames = {};
	table.insert(self.ReportFrames, self.GuildNameChangeFrame);
	table.insert(self.ReportFrames, self.CommunityNameChangeFrame);
	table.insert(self.ReportFrames, self.GuildPostingChangeFrame);
	table.insert(self.ReportFrames, self.CommunityPostingChangeFrame);
	table.insert(self.ReportFrames, self.GuildNameAlertFrame);

	self.GuildNameAlertFrame:SetScript("OnClick", GenerateClosure(self.OnGuildNameAlertFrameClicked, self));
end

function CommunitiesFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	self:SetNeedsGuildNameChange(GetGuildRenameRequired());

	-- Don't allow ChannelFrame and CommunitiesFrame to show at the same time, because they share one presence subscription
	if ChannelFrame and ChannelFrame:IsShown() then
		HideUIPanel(ChannelFrame);
	end

	self.PostingExpirationText:Hide();

	local clubId = GuildMicroButton:GetNewClubId() or self:GetSelectedClubId();
	if clubId then
		self:SelectClub(clubId, true);

		if C_ClubFinder.IsEnabled() then
			C_ClubFinder.RequestPostingInformationFromClubId(clubId);
		end
	end

	self:UpdatePortrait();
	
	self:RequestSubscribedClubFinderPostingInfo(); -- In case something has changed in the status of our posting since loading in. 

	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	FrameUtil.RegisterFrameForEvents(self, CLUB_FINDER_APPLICANT_LIST_EVENTS);

	self:UpdateClubSelection();
	self:UpdateStreamDropDown();
	MainMenuMicroButton_HideAlert(GuildMicroButton);
	UpdateMicroButtons();
	self:UpdateCommunitiesTabs();

	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:ScrollToClub(self:GetSelectedClubId());
	end

	self:RegisterCallback(CommunitiesFrameMixin.Event.MemberListDropDownShown, self.OnMemberListDropDownShown, self);
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
			if not self.ChatEditBox:HasFocus() then
				self:SelectClub(clubId);
				self.CommunitiesList:ScrollToClub(clubId);
			end
		elseif self:GetSelectedClubId() == nil then
			self:UpdateClubSelection();
		end
		C_ClubFinder.ResetClubPostingMapCache();
	elseif event == "CLUB_REMOVED" then
		local clubId = ...;
		self:SetPrivilegesForClub(clubId, nil);
		if clubId == self:GetSelectedClubId() then
			self:UpdateClubSelection();
		end
		self:ClearSelectedStreamForClub(clubId);
		C_ClubFinder.ResetClubPostingMapCache();
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
		self:ValidateDisplayMode();
		self.ApplicantList:CommunitiesMemberUpdate();
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
		C_ClubFinder.ResetClubPostingMapCache();
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
	elseif event == "CLUB_FINDER_RECRUITS_UPDATED" or event == "CLUB_FINDER_APPLICATIONS_UPDATED" then
		if(C_ClubFinder.IsEnabled()) then
			local clubId = self:GetSelectedClubId();
			if (clubId) then
				self.ApplicantList:BuildList();
				self:HideOrShowNotificationOverlay(clubId);
				self:CheckForTutorials();
			end
		else
			self.RosterTab.NotificationOverlay:SetShown(false);
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		local canRequestGuildRosterUpdate = ...;
		if canRequestGuildRosterUpdate then
			C_GuildInfo.GuildRoster();
		end
		self.ApplicantList:GuildMemberUpdate();
		self:UpdateCommunitiesButtons();
	elseif event == "CLUB_FINDER_RECRUITMENT_POST_RETURNED" then
		local displayMode = self:GetDisplayMode();
		if(displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or self:IsShowingApplicantList()) then
			local clubId = self:GetSelectedClubId();
			local clubInfo;
			if clubId then
				clubInfo = C_Club.GetClubInfo(clubId);
				if clubInfo then
					local isGuildCommunitySelected = clubInfo.clubType == Enum.ClubType.Guild;
					self:SetClubFinderPostingExpirationText(clubId, isGuildCommunitySelected);
				end
			end
		end
	elseif event == "CLUB_FINDER_ENABLED_OR_DISABLED" then
		StaticPopup_Show("CLUB_FINDER_ENABLED_DISABLED");
		HideUIPanel(self);
	elseif event == "ADDON_LOADED" then
		local addonName = ...;
		if not addonName or addonName ~= "Blizzard_Communities" then
			return;
		end

		self:UnregisterEvent("ADDON_LOADED");

		InitSeenApplicants();
	end
end

function CommunitiesFrameMixin:OnMemberListDropDownShown()
	HelpTip:Acknowledge(self, CLUB_FINDER_TUTORIAL_APPLICANT_LIST);
end

function CommunitiesFrameMixin:HasNewClubApplications(clubId)
	return HasNewClubApplications(clubId);
end

function CommunitiesFrameMixin:UpdateSeenApplicants()
	local selectedClubId = self:GetSelectedClubId();
	local applicantList = C_ClubFinder.ReturnClubApplicantList(selectedClubId);
	UpdateSeenApplicants(selectedClubId, applicantList);

	if self.GuildMemberListDropDownMenu:IsShown() then
		self.GuildMemberListDropDownMenu:UpdateNotificationFlash(false);
	end

	if self.CommunityMemberListDropDownMenu:IsShown() then
		self.CommunityMemberListDropDownMenu:UpdateNotificationFlash(false);
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

function CommunitiesFrameMixin:ClubFinderHyperLinkClicked(clubFinderId)
	if IsCommunitiesUIDisabledByTrialAccount() then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, RED_FONT_COLOR:GetRGBA());
		return;
	end

	if not C_ClubFinder.IsEnabled() then
		return;
	end

	if not self:IsShown() then
		ShowUIPanel(self);
	end

	self.CommunityFinderFrame:ClubFinderOnClickHyperLink(clubFinderId);
end

COMMUNITIES_FRAME_DISPLAY_MODES = {
	CHAT = {
		"CommunitiesList",
		"MemberList",
		"StreamDropDownMenu",
		"Chat",
		"ChatEditBox",
		"InviteButton",
		"VoiceChatHeadset",
		"CommunitiesCalendarButton",
		"CommunitiesControlFrame",
	},

	ROSTER = {
		"CommunitiesList",
		"MemberList",
		"CommunitiesControlFrame",
		"GuildMemberListDropDownMenu",
		"CommunityMemberListDropDownMenu",
	},

	COMMUNITY_APPLICANT_LIST = {
		"CommunitiesList",
		"ApplicantList",
		"CommunitiesControlFrame",
		"CommunityMemberListDropDownMenu",
	},

	GUILD_APPLICANT_LIST = {
		"CommunitiesList",
		"ApplicantList",
		"CommunitiesControlFrame",
		"GuildMemberListDropDownMenu",
	},

	INVITATION = {
		"CommunitiesList",
		"InvitationFrame",
		"ClubFinderInvitationFrame",
	},

	TICKET = {
		"CommunitiesList",
		"TicketFrame",
	},

	GUILD_FINDER = {
		"CommunitiesList",
		"GuildFinderFrame",
	},

	COMMUNITY_FINDER = {
		"CommunitiesList",
		"CommunityFinderFrame"
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

function CommunitiesFrameMixin:HasCommunityFinderPermissions(clubId, clubInfo)
	local privileges = C_Club.GetClubPrivileges(clubId);
	local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);

	if (not privileges or not myMemberInfo or not clubInfo) then
		return false; 
	end 

	local hasCommunityFinderPermissions = myMemberInfo.role and (myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader);
	return C_ClubFinder.IsEnabled() and hasCommunityFinderPermissions and privileges.canSendInvitation and clubInfo.clubType == Enum.ClubType.Character;
end 

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

	if self:IsShowingApplicantList() then
		self:UpdateSeenApplicants();
	end

	for subframe, shouldShow in pairs(subframesToUpdate) do
		self[subframe]:SetShown(shouldShow);
	end

	self.PostingExpirationText:Hide();

	local clubId = self:GetSelectedClubId();
	local clubInfo;
	if clubId then
		clubInfo = C_Club.GetClubInfo(clubId);
	end
	local isGuildCommunitySelected = false;
	if (clubInfo) then
		isGuildCommunitySelected = clubInfo.clubType == Enum.ClubType.Guild;
	end
	-- If we run into more cases where we need more specific controls on what
	-- is displayed in a displayMode then we should add support for conditional
	-- frames in displayMode based on clubType or perhaps a predicate function.
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or self:IsShowingApplicantList() then
		if isGuildCommunitySelected then
			C_GuildInfo.GuildRoster();
		end
		self.GuildMemberListDropDownMenu:SetShown(isGuildCommunitySelected);
		self.CommunityMemberListDropDownMenu:SetShown(self:HasCommunityFinderPermissions(clubId, clubInfo));
	end

	if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT and C_ClubFinder.IsEnabled()) then
		if clubInfo then
			self:SetClubFinderPostingExpirationText(clubId, isGuildCommunitySelected);
		end
	end

	if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER) then
		CommunitiesFrameInset:Hide();
	else
		CommunitiesFrameInset:Show();
	end

	self:UpdateMaximizeMinimizeButton();

	local displayMode = self:GetDisplayMode();
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER then
		HelpTip:Acknowledge(self, CLUB_FINDER_TUTORIAL_FINDER_BUTTONS_NO_SCROLL);
		HelpTip:Acknowledge(self, CLUB_FINDER_TUTORIAL_FINDER_BUTTONS_SCROLL);
	end

	self:TriggerEvent(CommunitiesFrameMixin.Event.DisplayModeChanged, displayMode);

	self:DisplayReportedAlerts(clubId);
	self:UpdateCommunitiesButtons();
	self:UpdateCommunitiesTabs();
	self:CheckForTutorials();
end

function CommunitiesFrameMixin:UpdateMaximizeMinimizeButton()
	self.MaximizeMinimizeFrame.MinimizeButton:SetEnabled(self.displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION and self.displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER and self.displayMode ~= COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER and not self.chatDisabled);
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

function CommunitiesFrameMixin:OnGuildNameAlertFrameClicked()
	self.GuildNameAlertFrame.topAnchored = false;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:ValidateDisplayMode();
end

function CommunitiesFrameMixin:HideClubFinderPostingExpirationStrings()
	self.PostingExpirationText.ExpirationTimeText:Hide();
	self.PostingExpirationText.DaysUntilExpire:Hide();
	self.PostingExpirationText.ExpiredText:Hide();
	self.PostingExpirationText.InfoButton:Hide();
end

function CommunitiesFrameMixin:SetClubFinderPostingExpirationText(clubId, isGuildCommunitySelected)
	local failure = false;

	self:HideClubFinderPostingExpirationStrings();

	if (not C_ClubFinder.IsEnabled()) then
		failure = true;
	elseif(isGuildCommunitySelected) then
		if(not IsGuildLeader() and not C_GuildInfo.IsGuildOfficer()) then
			failure = true;
		end
	else
		local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);

		if(not myMemberInfo or not myMemberInfo.role) then
			failure = true;
		end

		if (myMemberInfo.role ~= Enum.ClubRoleIdentifier.Owner and myMemberInfo.role ~= Enum.ClubRoleIdentifier.Leader) then
			failure = true;
		end
	end

	if failure then
		self.PostingExpirationText:Hide();
		return;
	end
	self.PostingExpirationText:Show();

	local expirationTime = ClubFinderGetClubPostingExpirationTime(clubId);
	if(C_ClubFinder.HasPostingBeenDelisted(clubId)) then
		if (isGuildCommunitySelected) then
			self.PostingExpirationText.ExpiredText:SetText(CLUB_FINDER_GUILD_POSTING_REMOVED_TEXT_SRRS);
		else
			self.PostingExpirationText.ExpiredText:SetText(CLUB_FINDER_COMMUNITY_POSTING_REMOVED_TEXT_SRRS);
		end
		local clubInfo = C_Club.GetClubInfo(clubId);
		local isGuildType = clubInfo and clubInfo.clubType == Enum.ClubType.Guild; 
		local isCommunityType = clubInfo and clubInfo.clubType == Enum.ClubType.Character;

		local isPostingBanned = C_ClubFinder.IsPostingBanned(clubId);
		local hasForceDescriptionChange = clubInfo and self:ClubFinderPostingHasActiveFlag(clubId, Enum.ClubFinderClubPostingStatusFlags.ForceDescriptionChange);
		local hasForceNameChange = clubInfo and ((clubInfo.clubType == Enum.ClubType.Guild and self:GetNeedsGuildNameChange()) or self:ClubFinderPostingHasActiveFlag(clubId, Enum.ClubFinderClubPostingStatusFlags.ForceNameChange));
		if (isPostingBanned) then 
			if (isGuildType) then
				self.PostingExpirationText.InfoButton.tooltipText = CLUB_FINDER_BANNED_POSTING_WARNING:format(CLUB_FINDER_TYPE_GUILD);
			elseif(isCommunityType) then
				self.PostingExpirationText.InfoButton.tooltipText = CLUB_FINDER_BANNED_POSTING_WARNING:format(CLUB_FINDER_COMMUNITY_TYPE);
			end
		elseif(hasForceNameChange) then 
			if (isGuildType) then
				self.PostingExpirationText.InfoButton.tooltipText = ERR_CLUB_FINDER_ERROR_TYPE_FLAGGED_RENAME:format(CLUB_FINDER_TYPE_GUILD);
			elseif(isCommunityType) then
				self.PostingExpirationText.InfoButton.tooltipText = ERR_CLUB_FINDER_ERROR_TYPE_FLAGGED_RENAME:format(CLUB_FINDER_COMMUNITY_TYPE);
			end
		elseif (hasForceDescriptionChange) then 
			self.PostingExpirationText.InfoButton.tooltipText = CLUB_FINDER_GUILD_POSTING_ALERT_REMOVED_DESC; 
		end
		self.PostingExpirationText.ExpiredText:Show();
		self.PostingExpirationText.InfoButton:SetShown(hasForceNameChange or isPostingBanned or hasForceDescriptionChange);
	elseif (expirationTime) then
		if (expirationTime > 0) then
			if (isGuildCommunitySelected) then
				self.PostingExpirationText.ExpirationTimeText:SetText(GUILD_FINDER_POSTING_GOING_TO_EXPIRE);
			else
				self.PostingExpirationText.ExpirationTimeText:SetText(COMMUNITY_FINDER_POSTING_EXPIRE_SOON);
			end
			self.PostingExpirationText.DaysUntilExpire:SetText(CLUB_FINDER_DAYS_UNTIL_EXPIRE:format(expirationTime));

			if (expirationTime > 5) then
				self.PostingExpirationText.DaysUntilExpire:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			elseif(expirationTime <= 5 and expirationTime > 0) then
				self.PostingExpirationText.DaysUntilExpire:SetTextColor(RED_FONT_COLOR:GetRGB());
			end

			self.PostingExpirationText.ExpirationTimeText:Show();
			self.PostingExpirationText.DaysUntilExpire:Show();
		else
			if (isGuildCommunitySelected) then
				self.PostingExpirationText.ExpiredText:SetText(GUILD_FINDER_POSTING_EXPIRED);
			else
				self.PostingExpirationText.ExpiredText:SetText(COMMUNITY_FINDER_POSTING_EXPIRED);
			end
			self.PostingExpirationText.ExpiredText:Show();
		end
	end
end

function CommunitiesFrameMixin:ClubFinderPostingHasActiveFlag(clubId, flag)
	local postingStatusFlags = C_ClubFinder.GetStatusOfPostingFromClubId(clubId);
	for _, statusFlag in ipairs(postingStatusFlags) do
		if (flag == statusFlag) then
			return true;
		end
	end
	return false;
end 

function CommunitiesFrameMixin:HideAllReportFramesExcept(exceptedFrame)
	for index, frame in ipairs(self.ReportFrames) do
		if frame ~= exceptedFrame then
			frame:Hide();
		end
	end 
end

function CommunitiesFrameMixin:GetDisplayableReportFrame(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return;
	end

	local hasForceNameChange = self:ClubFinderPostingHasActiveFlag(clubId, Enum.ClubFinderClubPostingStatusFlags.ForceNameChange);
	local hasGuildManagementPrivlileges = C_GuildInfo.IsGuildOfficer() or IsGuildLeader();
	local needsGuildNameChange = clubInfo.clubType == Enum.ClubType.Guild and (hasForceNameChange or self:GetNeedsGuildNameChange()) and hasGuildManagementPrivlileges;
	if needsGuildNameChange then
		return self.GuildNameChangeFrame;
	end

	if C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId) and C_ClubFinder.IsEnabled() and not C_ClubFinder.IsPostingBanned(clubId) then
		local hasForceDescriptionChange = self:ClubFinderPostingHasActiveFlag(clubId, Enum.ClubFinderClubPostingStatusFlags.ForceDescriptionChange);

		local needsGuildPostingMessageChange = clubInfo.clubType == Enum.ClubType.Guild and hasGuildManagementPrivlileges and hasForceDescriptionChange and not isPostingBanned;
		if needsGuildPostingMessageChange then
			return self.GuildPostingChangeFrame;
		end
		
	local hasCommunityFinderPermissions = self:HasCommunityFinderPermissions(clubId, clubInfo);
		local needsCommunityPostingMessageChange = clubInfo.clubType == Enum.ClubType.Character and hasCommunityFinderPermissions and hasForceDescriptionChange and not isPostingBanned;
		if needsCommunityPostingMessageChange then
			return self.CommunityPostingChangeFrame;
		end

		local needsCommunityNameChange = clubInfo.clubType == Enum.ClubType.Character and hasCommunityFinderPermissions and hasForceNameChange and not isPostingBanned; 
		if needsCommunityNameChange then
			return self.CommunityNameChangeFrame;
		end
	end
end

function CommunitiesFrameMixin:ShowGuildNameAlertFrame(alertText)
	self.GuildNameAlertFrame.Alert:SetText(alertText);
	self.GuildNameAlertFrame:SetShown(true);
end

function CommunitiesFrameMixin:DisplayReportedAlerts(clubId)
	if not clubId then
		return; 
	end 

	local reportFrame = self:GetDisplayableReportFrame(clubId);
	self:HideAllReportFramesExcept(reportFrame);

	if not reportFrame then
		return;
	end

	local isGuildLeader = IsGuildLeader();
	if self.GuildNameAlertFrame.topAnchored == nil then
		self.GuildNameAlertFrame.topAnchored = not isGuildLeader;
	end

	--We only want to show one alert at a time. Once the other alert is cleared, it will show the next in the case of numerous.
	if reportFrame == self.GuildNameChangeFrame then
		if not isGuildLeader then 
			reportFrame.GMText:SetText(GUILD_NAME_ALERT_MEMBER_HELP); 
		else 
			reportFrame.GMText:SetText(GUILD_NAME_ALERT_GM_HELP); 
		end
		reportFrame.EditBox:SetShown(isGuildLeader);
		reportFrame.Button:SetShown(isGuildLeader);
		reportFrame.RenameText:SetShown(isGuildLeader);

		self:ShowGuildNameAlertFrame(GUILD_NAME_ALERT);
	elseif reportFrame == self.CommunityNameChangeFrame then
		self:ShowGuildNameAlertFrame(CLUB_FINDER_COMMUNITY_NAME_CHANGE_ALERT);
	elseif reportFrame == self.GuildPostingChangeFrame then
		self:ShowGuildNameAlertFrame(CLUB_FINDER_GUILD_POSTING_ALERT);
	elseif reportFrame == self.CommunityPostingChangeFrame then
		self:ShowGuildNameAlertFrame(CLUB_FINDER_COMMUNITY_POSTING_ALERT);
	end

	reportFrame:ClearAllPoints();
	local displayMode = self:GetDisplayMode();
		if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
		reportFrame:SetPoint("TOPLEFT", self.Inset, "TOPRIGHT", 3, -3);
		reportFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMLEFT", 0, 5);
		else
		reportFrame:SetPoint("TOPLEFT", self.CommunitiesList, "TOPRIGHT", 24, -40);
		reportFrame:SetPoint("BOTTOMRIGHT", self.Inset, "BOTTOMRIGHT", 0, 0);
		end

		self.GuildNameAlertFrame:ClearAllPoints();
		if self.GuildNameAlertFrame.topAnchored then
			self.GuildNameAlertFrame:SetPoint("BOTTOM", self, "TOP");
		else
		self.GuildNameAlertFrame:SetPoint("TOP", reportFrame, "TOP", 0, -24)
		end

	reportFrame:SetShown(not self.GuildNameAlertFrame.topAnchored);

	self.GuildNameAlertFrame.Alert:ClearAllPoints();
	if self.GuildNameAlertFrame.topAnchored then
		self.GuildNameAlertFrame.Alert:SetFontObject(GameFontHighlight);
		self.GuildNameAlertFrame.Alert:SetPoint("BOTTOM", self.GuildNameAlertFrame, "CENTER", 0, 0);
		self.GuildNameAlertFrame.Alert:SetWidth(190);
		self.GuildNameAlertFrame:SetSize(256, 60);
		self.GuildNameAlertFrame:Enable();
		self.GuildNameAlertFrame.ClickText:Show();
	else
		self.GuildNameAlertFrame.Alert:SetFontObject(GameFontHighlightMedium);
		self.GuildNameAlertFrame.Alert:SetPoint("CENTER", self.GuildNameAlertFrame, "CENTER", 0, 0);
		self.GuildNameAlertFrame.Alert:SetWidth(220);
		self.GuildNameAlertFrame:SetSize(300, 40);
		self.GuildNameAlertFrame:Disable();
		self.GuildNameAlertFrame.ClickText:Hide();
	end
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
		elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.TICKET or self:IsShowingApplicantList() then
			self:SetDisplayMode(self.defaultMode);
		elseif self.chatDisabled and displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT then
			self:SetDisplayMode(self.defaultMode);
		elseif self.chatDisabled and displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
			--self:SetDisplayMode(self.defaultMode);
			self.MaximizeMinimizeFrame.MaximizeButton:Click();
		elseif displayMode == nil then
			self:SetDisplayMode(self.defaultMode);
		end

		local newDisplayMode = self:GetDisplayMode();
		local isRosterOrApplicantList = newDisplayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or self:IsShowingApplicantList();

		local shouldShowGuildMemberList = isRosterOrApplicantList and isGuildCommunitySelected;
		self.GuildMemberListDropDownMenu:SetShown(shouldShowGuildMemberList);
	
		local shouldShowCommunityMemberList = isRosterOrApplicantList and self:HasCommunityFinderPermissions(clubId, clubInfo);
		self.CommunityMemberListDropDownMenu:SetShown(shouldShowCommunityMemberList);
		self:DisplayReportedAlerts(clubId);
		self.ChatTab:SetEnabled(not self.chatDisabled);
		self.ChatTab.IconOverlay:SetShown(self.chatDisabled);
		if self.chatDisabled then
			self.ChatTab.tooltip2 = ERR_PARENTAL_CONTROLS_CHAT_MUTED;
		else
			self.ChatTab.tooltip2 = nil;
		end
		self:UpdateMaximizeMinimizeButton();
		self:CheckForTutorials();
	end
end

function CommunitiesFrameMixin:GetDisplayMode()
	return self.displayMode;
end

function CommunitiesFrameMixin:IsShowingApplicantList()
	return self.displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_APPLICANT_LIST or self.displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_APPLICANT_LIST;
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
			displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO or
			self:IsShowingApplicantList() then
		self.ChatTab:Show();
		self.RosterTab:Show();
		local clubId = self:GetSelectedClubId();
		if clubId then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if clubInfo then
				self.GuildBenefitsTab:SetShown(clubInfo.clubType == Enum.ClubType.Guild);
				self.GuildInfoTab:SetShown(clubInfo.clubType == Enum.ClubType.Guild);
			end
			self:HideOrShowNotificationOverlay(clubId);
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
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or self:IsShowingApplicantList() then
		self.RosterTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS then
		self.GuildBenefitsTab:SetChecked(true);
	elseif displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO then
		self.GuildInfoTab:SetChecked(true);
	end
end

function CommunitiesFrameMixin:SelectedClubHasApplicants()
	local clubId = self:GetSelectedClubId();
	if not clubId then
		return false;
	end

	local applicantList = C_ClubFinder.ReturnClubApplicantList(clubId);
	return applicantList and #applicantList > 0;
end

function CommunitiesFrameMixin:CheckForTutorials()
	if not C_ClubFinder.IsEnabled() then
		return;
	end

	if self.CommunitiesList:IsShown() and not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCCOUNT_CLUB_FINDER_NEW_FEATURE) then
		self:ShowClubFinderTutorial();
		return;
	end

	-- All tutorials below require invitation privleges and only apply to guilds and character communities.
	local isGuild = self:IsGuildSelected();
	local isGuildOrCommunity = isGuild or self:IsCharacterCommunitySelected();
	if isGuildOrCommunity and not self:HasInvitationPrivilegesForSelectedClub() then
		return;
	end

	local clubId = self:GetSelectedClubId();
	local displayMode = self:GetDisplayMode();
	if displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_BENEFITS or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_INFO then
		if self:SelectedClubHasApplicants() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_APPLICANTS_GUILD_LEADER) then
			self:ShowClubFinderApplicantListBreadcrumbForLeader();
			return;
		end
	end

	if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER) and self:SelectedClubHasApplicants() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_APPLICANTS_GUILD_LEADER) then
		self:ShowClubFinderApplicantListTutorialForLeader();
		return;
	end

	if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT) and (self.CommunitiesControlFrame.CommunitiesSettingsButton:IsShown() or self.CommunitiesControlFrame.GuildRecruitmentButton:IsShown()) then
		local clubPostingInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId);
		if clubPostingInfo then
			if not clubPostingInfo.localeSet and self:TryShowClubFinderLanguageFilterTutorialForLeader(isGuild) then
				return;
			end
		else
			if self:TryShowClubFinderRecruitmentTutorialForLeader(isGuild) then
				return;
			end
		end
	end


	if self.InviteButton:IsShown() and isGuild and clubId and C_ClubFinder.RequestPostingInformationFromClubId(clubId)then
		if self:TryShowClubFinderLinkTutorialForLeader() then
			return;
		end
	end
end

function CommunitiesFrameMixin:ShowClubFinderTutorial()
	local tutorialText = self.CommunitiesList:IsFinderVisible() and CLUB_FINDER_TUTORIAL_FINDER_BUTTONS_NO_SCROLL or CLUB_FINDER_TUTORIAL_FINDER_BUTTONS_SCROLL;
	local helpTipInfo = {
		text = tutorialText,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = LE_FRAME_TUTORIAL_ACCCOUNT_CLUB_FINDER_NEW_FEATURE,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		alignment = HelpTip.Alignment.Left,
		onHideCallback = function(acknowledged, closeFlag) self:CheckForTutorials(); end;
		offsetX = -4,
	};

	HelpTip:Show(self, helpTipInfo, self.CommunitiesList);
end

function CommunitiesFrameMixin:ShowClubFinderApplicantListBreadcrumbForLeader()
	local helpTipInfo = {
		text = CLUB_FINDER_TUTORIAL_ROSTER,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_APPLICANTS_GUILD_LEADER,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = -4,
	};

	HelpTip:Show(self, helpTipInfo, self.RosterTab);
end

function CommunitiesFrameMixin:ShowClubFinderApplicantListTutorialForLeader()
	local helpTipInfo = {
		text = CLUB_FINDER_TUTORIAL_APPLICANT_LIST,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_APPLICANTS_GUILD_LEADER,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		offsetX = -4,
	};

	if self:IsGuildSelected() then
		HelpTip:Show(self, helpTipInfo, self.GuildMemberListDropDownMenu);
	else
		HelpTip:Show(self, helpTipInfo, self.CommunityMemberListDropDownMenu);
	end
end

function CommunitiesFrameMixin:TryShowClubFinderRecruitmentTutorialForLeader(isGuildSelected)
	if not isGuildSelected and not self:IsCharacterCommunitySelected() then
		return false;
	end

	local flag = isGuildSelected and LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_GUILD_LEADER or LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_COMMUNITY_LEADER;
	local button = isGuildSelected and self.CommunitiesControlFrame.GuildRecruitmentButton or self.CommunitiesControlFrame.CommunitiesSettingsButton;
	local helpTipInfo = {
		text = CLUB_FINDER_TUTORIAL_POSTING,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = flag,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		offsetX = -4,
		useParentStrata = true,
		checkCVars = true,
	};

	return HelpTip:Show(self, helpTipInfo, button);
end

function CommunitiesFrameMixin:TryShowClubFinderLanguageFilterTutorialForLeader(isGuildSelected)
	if not isGuildSelected and not self:IsCharacterCommunitySelected() then
		return false;
	end

	local button = isGuildSelected and self.CommunitiesControlFrame.GuildRecruitmentButton or self.CommunitiesControlFrame.CommunitiesSettingsButton;
	local helpTipInfo = {
		text = CLUB_FINDER_TUTORIAL_LANGUAGE_FILTER,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CLUB_FINDER_NEW_LANGUAGE_FILTER,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		offsetX = -4,
		useParentStrata = true,
		checkCVars = true,
	};

	return HelpTip:Show(self, helpTipInfo, button);
end

function CommunitiesFrameMixin:TryShowClubFinderLinkTutorialForLeader()
	local helpTipInfo = {
		text = CLUB_FINDER_TUTORIAL_GUILD_LINK,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CLUB_FINDER_LINKING,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		offsetX = -4,
		useParentStrata = true,
		checkCVars = true,
	};

	return HelpTip:Show(self, helpTipInfo, self.InviteButton);
end

function CommunitiesFrameMixin:IsClubTypeSelected(clubType)
	local clubId = self:GetSelectedClubId();
	local clubInfo = clubId and C_Club.GetClubInfo(clubId) or nil;
	return clubInfo and (clubInfo.clubType == clubType) or false;
end

function CommunitiesFrameMixin:IsGuildSelected()
	return self:IsClubTypeSelected(Enum.ClubType.Guild);
end

function CommunitiesFrameMixin:IsCharacterCommunitySelected()
	return self:IsClubTypeSelected(Enum.ClubType.Character);
end

function CommunitiesFrameMixin:UpdatePortrait()
	local clubId = self:GetSelectedClubId();
	local clubInfo = clubId and C_Club.GetClubInfo(clubId) or nil;
	local isGuildCommunity = self:IsGuildSelected();
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
	self.PostingExpirationText:Hide();
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

			self:DisplayReportedAlerts(clubId);

			self:ValidateDisplayMode();
			local displayMode = self:GetDisplayMode();
			if clubInfo.clubType == Enum.ClubType.Guild then
				C_GuildInfo.GuildRoster();
				QueryGuildRecipes();
				if (C_GuildInfo.IsGuildOfficer() or IsGuildLeader()) then
					if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or self:IsShowingApplicantList()) then
						self:SetClubFinderPostingExpirationText(clubId, true);
					end
					C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Guild);
					self.ApplicantList:SetApplicantRefreshTicker(Enum.ClubFinderRequestType.Guild);
				else
					self.ApplicantList:CancelRefreshTicker();
				end
			elseif(clubInfo.clubType == Enum.ClubType.Character) then
				local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
				if (myMemberInfo and myMemberInfo.role and (myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader)) then
					if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or self:IsShowingApplicantList()) then
						self:SetClubFinderPostingExpirationText(clubId, false);
					end
					C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Community);
					self.ApplicantList:SetApplicantRefreshTicker(Enum.ClubFinderRequestType.Community);
				else
					self.ApplicantList:CancelRefreshTicker();
				end
			else
				self.ApplicantList:CancelRefreshTicker();
			end
			self.CommunitiesControlFrame:SetShown(displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT or displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER);
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
	else
		self.ApplicantList:CancelRefreshTicker();
	end

	self:UpdatePortrait();
	self:UpdateCommunitiesButtons();
	self:UpdateCommunitiesTabs();
	self:TriggerEvent(CommunitiesFrameMixin.Event.ClubSelected, clubId);

	self:UpdateStreamDropDown(); -- TODO:: Convert this to use the registry system of callbacks.

	if self.CommunitiesList:IsShown() then
		self.CommunitiesList:OnClubSelected(clubId); -- TODO:: Convert this to use the registry system of callbacks.
	end

	self:CheckForTutorials();
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

function CommunitiesFrameMixin:HideOrShowNotificationOverlay(clubId)
	if clubId ~= nil then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo and self:HasNewClubApplications(clubId) and C_ClubFinder.IsEnabled() then
			if (clubInfo.clubType == Enum.ClubType.Guild) then
				local canApproveApplications = IsGuildLeader() or C_GuildInfo.IsGuildOfficer();
				self.RosterTab.NotificationOverlay:SetShown(canApproveApplications);
				self.GuildMemberListDropDownMenu:UpdateNotificationFlash(canApproveApplications);
			elseif (clubInfo.clubType == Enum.ClubType.Character) then
				local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
				local role = myMemberInfo and myMemberInfo.role;
				local isOwnerOrLeader = role and (role == Enum.ClubRoleIdentifier.Owner or role == Enum.ClubRoleIdentifier.Leader);
				self.RosterTab.NotificationOverlay:SetShown(isOwnerOrLeader);
				self.CommunityMemberListDropDownMenu:UpdateNotificationFlash(isOwnerOrLeader);
			else
				self.RosterTab.NotificationOverlay:SetShown(false);
				self.CommunityMemberListDropDownMenu:UpdateNotificationFlash(false);
				self.GuildMemberListDropDownMenu:UpdateNotificationFlash(false);
			end
		else
			self.RosterTab.NotificationOverlay:SetShown(false);
			self.CommunityMemberListDropDownMenu:UpdateNotificationFlash(false);
			self.GuildMemberListDropDownMenu:UpdateNotificationFlash(false);
		end
	end
end

function CommunitiesFrameMixin:UpdateCommunitiesButtons()
	local clubId = self:GetSelectedClubId();
	local inviteButton = self.InviteButton;
	inviteButton:SetEnabled(false);
	inviteButton.disabledTooltip = nil;

	local addToChatButton = self.AddToChatButton;
	addToChatButton:Hide();

	if clubId ~= nil then
		local clubInfo = C_Club.GetClubInfo(clubId);
		self:HideOrShowNotificationOverlay(clubId);

		local isClubAtCapacity = clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity();
		if clubInfo and clubInfo.clubType == Enum.ClubType.Guild then
			local hasGuildPermissions = CanGuildInvite();
			inviteButton:SetEnabled(hasGuildPermissions and not isClubAtCapacity);
			local isButtonEnabled = inviteButton:IsEnabled();
			if(hasGuildPermissions and not isButtonEnabled) then
				if(isClubAtCapacity) then
					inviteButton.disabledTooltip = CLUB_INVITER_FAIL_GUILD_CAPACITY;
				end
			elseif(not isButtonEnabled) then
				inviteButton.disabledTooltip = ERR_CLUB_FINDER_ERROR_TYPE_NO_INVITE_PERMISSIONS;
			end
		elseif clubInfo and (clubInfo.clubType == Enum.ClubType.Character or clubInfo.clubType == Enum.ClubType.BattleNet) then
			local privileges = self:GetPrivilegesForClub(clubId);
			inviteButton:SetEnabled(not isClubAtCapacity and privileges.canSendInvitation);
			local isButtonEnabled = inviteButton:IsEnabled();
			if(privileges.canSendInvitation and not isButtonEnabled) then
				if(isClubAtCapacity) then
					inviteButton.disabledTooltip = CLUB_INVITER_FAIL_COMMUNITY_CAPACITY;
				end
			elseif(not isButtonEnabled) then
				inviteButton.disabledTooltip = ERR_CLUB_FINDER_ERROR_TYPE_NO_INVITE_PERMISSIONS;
			end
		end
		if self:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT then
			local selectedStreamId = self:GetSelectedStreamId();
			if selectedStreamId ~= nil and self:GetDisplayMode() ~= COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
				local streamInfo = C_Club.GetStreamInfo(clubId, selectedStreamId);
				addToChatButton:SetShown(streamInfo and streamInfo.streamType ~= Enum.ClubStreamType.Guild and streamInfo.streamType ~= Enum.ClubStreamType.Officer);
			end
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

function CommunitiesFrameMixin:ClearSelectedStreamForClub(clubId)
	self.selectedStreamForClub[clubId] = nil;
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
	UIDropDownMenu_Initialize(self.StreamDropDownMenu, CommunitiesStreamDropDownMenu_Initialize);
	UIDropDownMenu_SetSelectedValue(self.StreamDropDownMenu, selectedStream and selectedStream.streamId or nil, true);
	local streamName = selectedStream and CommunitiesStreamDropDownMenu_GetStreamName(clubId, selectedStream) or "";
	UIDropDownMenu_SetText(self.StreamDropDownMenu, streamName);
	self.StreamDropDownMenu:UpdateUnreadNotification();
end

function CommunitiesFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	self:CloseActiveDialogs();
	if(self.CommunityFinderFrame:IsShown()) then
		self.CommunityFinderFrame:Hide();
	end

	if self.RecruitmentDialog:IsShown() then
		HideUIPanel(self.RecruitmentDialog);
	end

	self.ApplicantList:CancelRefreshTicker();

	C_Club.ClearClubPresenceSubscription();
	C_Club.ClearAutoAdvanceStreamViewMarker();
	C_Club.Flush();
	self:SetFocusedStream(nil, nil);
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_FRAME_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, CLUB_FINDER_APPLICANT_LIST_EVENTS);
	UpdateMicroButtons();

	self.GuildFinderFrame:ClearAllCardLists();
	self.CommunityFinderFrame:ClearAllCardLists();

	self:UnregisterCallback(CommunitiesFrameMixin.Event.MemberListDropDownShown, self);
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

function CommunitiesFrameMixin:HasInvitationPrivilegesForSelectedClub()
	local clubId = self:GetSelectedClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			local privileges = self:GetPrivilegesForClub(clubId);
			return privileges.canSendInvitation;
		end
	end

	return false;
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
		communitiesFrame.VoiceChatHeadset:SetPoint("TOPRIGHT", -180, -26);
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
		UIDropDownMenu_SetWidth(communitiesFrame.StreamDropDownMenu, 90);
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
		local displayMode = communitiesFrame:GetDisplayMode();
		if clubInfo then
			local privileges = communitiesFrame:GetPrivilegesForClub(clubId);
			local isGuild = clubInfo.clubType == Enum.ClubType.Guild;
			local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
			local hasCommunitySettingsPrivilege = privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast
			and myMemberInfo and myMemberInfo.role and myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader or myMemberInfo.role == Enum.ClubRoleIdentifier.Moderator
			if (not isGuild) then
				if(displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT) then
					self.CommunitiesSettingsButton:Show();
					self.CommunitiesSettingsButton:SetText(clubInfo.clubType == Enum.ClubType.BattleNet and COMMUNITIES_SETTINGS_BUTTON_LABEL or COMMUNITIES_SETTINGS_BUTTON_CHARACTER_LABEL);
					self.CommunitiesSettingsButton:ClearAllPoints();
					self.CommunitiesSettingsButton:SetPoint("RIGHT", communitiesFrame.InviteButton, "LEFT", -2, 0);
					self.CommunitiesSettingsButton:SetEnabled(hasCommunitySettingsPrivilege);
					if not hasCommunitySettingsPrivilege then
						self.CommunitiesSettingsButton.disabledTooltip = CLUB_FINDER_NO_RECRUITING_PERMISSIONS;
					else
						self.CommunitiesSettingsButton.disabledTooltip = nil;
					end
				else
					self.CommunitiesSettingsButton:Hide();
				end
			end

			if isGuild then
				local shouldShowGuildControl = IsGuildLeader() and (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER or communitiesFrame:IsShowingApplicantList());
				self.GuildControlButton:SetShown(shouldShowGuildControl);

				local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
				if (displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT and myMemberInfo and myMemberInfo.guildRankOrder and C_ClubFinder.IsEnabled()) then
					self.GuildRecruitmentButton:Show();

					local canViewClubFinderSettings = IsGuildLeader() or C_GuildInfo.IsGuildOfficer() and C_ClubFinder.IsEnabled();
					local isPostingBanned = C_ClubFinder.IsPostingBanned(clubId); 
					local disabledReason = C_ClubFinder.GetClubFinderDisableReason();

					self.GuildRecruitmentButton:SetEnabled(disabledReason == nil and canViewClubFinderSettings and not isPostingBanned);

					if disabledReason == Enum.ClubFinderDisableReason.Muted then
						self.GuildRecruitmentButton.disabledTooltip = COMMUNITY_FEATURE_UNAVAILABLE_MUTED;
					elseif disabledReason == Enum.ClubFinderDisableReason.Silenced then
						self.GuildRecruitmentButton.disabledTooltip = COMMUNITY_FEATURE_UNAVAILABLE_SILENCED;
					elseif disableReason == Enum.ClubFinderDisableReason.VeteranTrial then 
						self.GuildRecruitmentButton.disabledTooltip = CLUB_FINDER_DISABLE_REASON_VETERAN_TRIAL;
					elseif (C_ClubFinder.IsEnabled() and not canViewClubFinderSettings) then
						self.GuildRecruitmentButton.disabledTooltip = CLUB_FINDER_NO_RECRUITING_PERMISSIONS;
					elseif (isPostingBanned) then 
						self.GuildRecruitmentButton.disabledTooltip = CLUB_FINDER_BANNED_POSTING_WARNING:format(CLUB_FINDER_TYPE_GUILD);
					else
						self.GuildRecruitmentButton.disabledTooltip = nil;
					end

					self.GuildRecruitmentButton:ClearAllPoints();

					if self.GuildRecruitmentButton:IsShown() and self:GetParent().InviteButton:IsShown() then
						self.GuildRecruitmentButton:SetPoint("RIGHT", self:GetParent().InviteButton, "LEFT", -2, 0);
					else
						self.GuildRecruitmentButton:SetPoint("BOTTOMRIGHT");
					end
				else
					self.GuildRecruitmentButton:Hide();
				end
			end
		end
	end
end

function CommunitiesControlFrameMixin:GetCommunitiesFrame()
	return self:GetParent();
end