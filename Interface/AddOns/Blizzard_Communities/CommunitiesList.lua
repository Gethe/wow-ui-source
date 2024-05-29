local COMMUNITIES_LIST_EVENTS = {
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_UPDATED",
	"CLUB_INVITATION_ADDED_FOR_SELF",
	"CLUB_INVITATION_REMOVED_FOR_SELF",
	"CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED",
	"GUILD_ROSTER_UPDATE",
	"CLUB_FINDER_APPLICANT_INVITE_RECIEVED",
};
	
local NEW_COMMUNITY_FLASH_DURATION = 6.0;

function CreateCommunitiesIconNotificationMarkup(text, xoffset, yoffset)
	return string.format("%s %s", text, CreateAtlasMarkup("communities-icon-notification", 11, 11, xoffset, yoffset));
end

CommunitiesListMixin = {};

function CommunitiesListMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesListMixin:OnEvent(event, ...)
	if event == "CLUB_ADDED" then
		self:UpdateCommunitiesList();
		self:Update();
	elseif event == "CLUB_REMOVED" then
		self:UpdateCommunitiesList();
		self:Update();
	elseif event == "CLUB_UPDATED" then
		local clubId = ...;
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			self:UpdateClub(clubInfo);
		end
	elseif event == "CLUB_INVITATION_ADDED_FOR_SELF" then
		self:UpdateInvitations();
		self:Update();
	elseif event == "CLUB_INVITATION_REMOVED_FOR_SELF" then
		local invitationId = ...;
		tDeleteItem(self.declinedInvitationIds, invitationId);
		self:UpdateInvitations();
		self:Update();
	elseif event == "CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED" or event == "CLUB_FINDER_APPLICANT_INVITE_RECIEVED" then
		self:UpdateFinderInvitations(); 
		self:Update(); 
	elseif event == "GUILD_ROSTER_UPDATE" then 
		self:UpdateCommunitiesList();
		self:Update();
	end
end

function CommunitiesListMixin:UpdateInvitations()
	self.invitations = C_Club.GetInvitationsForSelf();
	
	-- Remove all invites that have been declined.
	for i, declinedInvitationId in ipairs(self.declinedInvitationIds) do
		for j, inviteInfo in ipairs(self.invitations) do
			if declinedInvitationId == inviteInfo.invitationId then
				table.remove(self.invitations, j);
				break;
			end
		end
	end
end

function CommunitiesListMixin:UpdateFinderInvitations()
	self.finderInvitations = C_ClubFinder.PlayerGetClubInvitationList();
end 

function CommunitiesListMixin:GetClubFinderInvitations()
	return self.finderInvitations;
end

function CommunitiesListMixin:GetInvitations()
	return self.invitations;
end

function CommunitiesListMixin:GetTickets()
	return self.tickets or {};
end

function CommunitiesListMixin:GetTicketInfoForClubId(clubId)
	for i, ticketInfo in ipairs(self:GetTickets()) do
		if ticketInfo.clubInfo.clubId == clubId then
			return ticketInfo;
		end
	end

	return nil;
end

function CommunitiesListMixin:AlreadyInClubOrHaveInvitation(clubId)
	local communities = self:GetCommunitiesList();
	local invitations = self:GetInvitations();

	for _, community in ipairs(communities) do
		if community.clubId == clubId then
			return true;
		end
	end
	for _, invitation in ipairs(invitations) do
		if invitation.club.clubId == clubId then
			return true;
		end
	end

	return false;
end

function CommunitiesListMixin:AlreadyHaveTicket(ticketId)
	local tickets = self:GetTickets();

	for _, ticketInfo in ipairs(tickets) do
		if ticketInfo.ticketId == ticketId then
			return true;
		end
	end

	return false;
end

function CommunitiesListMixin:ValidateTickets()
	-- Remove any tickets for clubs that we're already in or have an invite for
	local tickets = self:GetTickets();
	for i = #tickets, 1, -1 do
		local ticket = tickets[i];
		if self:AlreadyInClubOrHaveInvitation(ticket.clubInfo.clubId) then
			table.remove(tickets, i);
		end
	end
end

function CommunitiesListMixin:AddTicket(ticketId, clubInfo)
	ShowUIPanel(CommunitiesFrame);
	if self:AlreadyHaveTicket(ticketId) then
		return;
	end
	if not self:AlreadyInClubOrHaveInvitation(clubInfo.clubId) then
		local ticketInfo = {};
		ticketInfo.ticketId = ticketId;
		ticketInfo.clubInfo = clubInfo;

		if self.tickets == nil then
			self.tickets = {};
		end
		table.insert(self.tickets, ticketInfo);
	end

	local forceUpdate = true;
	local communitiesFrame = self:GetParent();
	communitiesFrame:SelectClub(clubInfo.clubId, forceUpdate)
end

function CommunitiesListMixin:RemoveTicket(ticketId)
	for i, ticketInfo in ipairs(self.tickets) do
		if ticketInfo.ticketId == ticketId then
			table.remove(self.tickets, i);
			self:Update();
			return;
		end
	end
end

function CommunitiesListMixin:ClearTickets(ticketId)
	self.ticket = nil;
end

function CommunitiesListMixin:SortCommunitiesList()
	CommunitiesUtil.SortClubs(self:GetCommunitiesList());
end

function CommunitiesListMixin:UpdateCommunitiesList()
	local clubs = C_Club.GetSubscribedClubs();
	self.communitiesList = clubs;
	self:PredictFavorites(clubs);
	self:SortCommunitiesList();
end

function CommunitiesListMixin:GetCommunitiesList()
	return self.communitiesList;
end

function CommunitiesListMixin:Update()
	local clubs = self:GetCommunitiesList();
	local playerIsInGuild = IsInGuild();
	self:ValidateTickets();
	
	-- TODO:: Determine if this player is at the maximum number of allowed clubs or not.
	-- We probably need to change the create flow as well, since it's possible you are
	-- allowed to create more bnet groups, but not more wow communities or vice versa.
	local dataProvider = CreateDataProvider();
	for index, clubInfo in ipairs(self:GetTickets()) do
		clubInfo.isTicket = true;
		dataProvider:Insert({clubInfo = clubInfo});
	end
	
	local invitations = self:GetInvitations();
	if invitations then
		for index, clubInfo in ipairs(invitations) do
			local club = clubInfo.club;
			club.isInvitation = true;
			dataProvider:Insert({clubInfo = club});
		end
	end
	
	local clubFinderInvitations = self:GetClubFinderInvitations(); 
	if clubFinderInvitations then
		for index, clubInfo in ipairs(clubFinderInvitations) do
			clubInfo.isClubFinderInvitation = true;
			dataProvider:Insert({clubInfo = clubInfo});
		end
	end

	for index, clubInfo in ipairs(clubs) do
		clubInfo.isClub = true;
		dataProvider:Insert({clubInfo = clubInfo});
	end

	local clubFinderEnabled = C_ClubFinder.IsEnabled();
	local communitiesFinderEnabled = C_ClubFinder.IsCommunityFinderEnabled();
	local guildFinderFrame = self:GetCommunitiesFrame().GuildFinderFrame;
	if clubFinderEnabled then
		guildFinderFrame.isGuildType = true;
		guildFinderFrame:UpdateType();
		
		if not playerIsInGuild then
			dataProvider:Insert({setGuildFinder = true});
		end

		if communitiesFinderEnabled then
			dataProvider:Insert({setFindCommunity = true});
		end
	end
	
	if C_Club.ShouldAllowClubType(Enum.ClubType.Character) or C_Club.ShouldAllowClubType(Enum.ClubType.BattleNet) then
		dataProvider:Insert({setJoinCommunity = true});
	end

	if clubFinderEnabled and playerIsInGuild then
		dataProvider:Insert({setGuildFinder = true});
	end 

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function CommunitiesListMixin:UpdateClub(clubInfo)
	local clubs = self:GetCommunitiesList();
	if clubs then
		local clubId = clubInfo.clubId;
		for i, club in ipairs(clubs) do
			if club.clubId == clubId then
				clubs[i] = clubInfo;
				break;
			end
		end
	end
	
	-- Notifying the button is complicated because its data resides in a different data provider. We can't simply
	-- replace that data without notifications to signal the ScrollBox to be reinitialized correctly.
	self:Update();
end

function CommunitiesListMixin:OnLoad()
	C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All);
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CommunitiesListEntryTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(40,0,0,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.declinedInvitationIds = {};
	self.pendingFavorites = {};
end

function CommunitiesListMixin:RegisterEventCallbacks()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:RegisterCallback(CommunitiesFrameMixin.Event.InviteDeclined, self.OnCommunityInviteDeclined, self);
	communitiesFrame:RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.OnCommunitiesFrameDisplayModeChanged, self);
end

function CommunitiesListMixin:OnCommunitiesFrameDisplayModeChanged()
	self:Update();
end

function CommunitiesListMixin:OnCommunityInviteDeclined(invitationId, clubId)
	local communitiesFrame = self:GetCommunitiesFrame(); 
	self.declinedInvitationIds[#self.declinedInvitationIds + 1] = invitationId;
	self:GetCommunitiesFrame():UpdateClubSelection();
	self:UpdateInvitations();
	self:Update();
end

function CommunitiesListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_LIST_EVENTS);

	self:UpdateCommunitiesList();
	self:UpdateInvitations();
	self:Update();
	
	self:RegisterEventCallbacks();
end

function CommunitiesListMixin:OnHide()
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.InviteDeclined, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self);
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_LIST_EVENTS);
end

function CommunitiesListMixin:ScrollToClub(clubId)
	self.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.clubInfo and elementData.clubInfo.clubId == clubId;
	end, ScrollBoxConstants.AlignCenter);
end

function CommunitiesListMixin:OnClubSelected(clubId)
	self:Update();
end

function CommunitiesListMixin:SetFavorite(clubId, isFavorite)
	C_Club.SetFavorite(clubId, isFavorite);
	if isFavorite then
		self.pendingFavorites[clubId] = GetServerTime();
	else
		self.pendingFavorites[clubId] = 0;
	end
	self:PredictFavorites(self.communitiesList);
	self:SortCommunitiesList();
	self:Update();
	ChannelFrame:OnCommunityFavoriteChanged(clubId);
end

function CommunitiesListMixin:IsClubFavorite(clubInfo)
	if self.pendingFavorites[clubInfo.clubId] then
		return self.pendingFavorites[clubInfo.clubId] ~= 0;
	else
		return clubInfo.favoriteTimeStamp ~= nil;
	end
end

function CommunitiesListMixin:PredictFavorites(clubs)
	local remainingPredictions = {};
	for clubId, predictedFavoriteEntry in pairs(self.pendingFavorites) do
		for i, clubInfo in ipairs(clubs) do
			if clubInfo.clubId == clubId then
				if clubInfo.favoriteTimeStamp ~= predictedFavoriteEntry then
					clubInfo.favoriteTimeStamp = predictedFavoriteEntry ~= 0 and predictedFavoriteEntry or nil;
					remainingPredictions[clubId] = predictedFavoriteEntry;
				end
			end
		end
	end
	
	self.pendingFavorites = remainingPredictions;
end

function CommunitiesListMixin:IsFinderVisible()
	local button = self.ScrollBox:FindFrameByPredicate(function(button, elementData)
		return button.Name:GetText() == COMMUNITY_FINDER_FIND_COMMUNITY;
	end);
	return button ~= nil;
end

function CommunitiesListMixin:OnNewCommunityFlashStarted()
	if not self.newCommunityFlashTime then
		self.newCommunityFlashTime = GetTime();
	end
end

function CommunitiesListMixin:ShouldShowNewCommunityFlash(clubId)
	if self.newCommunityFlashTime and (GetTime() - self.newCommunityFlashTime) > NEW_COMMUNITY_FLASH_DURATION then
		return false;
	end

	return clubId == GuildMicroButton:GetNewClubId();
end

local COMMUNITIES_LIST_ENTRY_EVENTS = {
	"STREAM_VIEW_MARKER_UPDATED",
	"PLAYER_GUILD_UPDATE",
	"CHAT_DISABLED_CHANGE_FAILED",
	"CHAT_DISABLED_CHANGED",
}

CommunitiesListEntryMixin = {};

local function GetFontColor(isBattleNet, isGuild, isInvitation)
	if isBattleNet then
		return BATTLENET_FONT_COLOR;
	elseif isGuild then
		return GREEN_FONT_COLOR;
	elseif isInvitation then
		return HIGHLIGHT_FONT_COLOR;
	end

	return NORMAL_FONT_COLOR;
end

function CommunitiesListEntryMixin:Init(elementData)
	self:SetEntryEnabled(true);

	local clubInfo = elementData.clubInfo;
	local isInvitation = clubInfo and clubInfo.isInvitation;
	local isClubFinderInvitation = clubInfo and clubInfo.isClubFinderInvitation;

	if (isInvitation) then
		self.overrideOnClick = function(self, button)
			if (button == "LeftButton") then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				local communitiesFrame = self:GetCommunitiesFrame();
				communitiesFrame:SelectClub(self.clubId);
				self:UpdateUnreadNotification();
			end
		end;
	else
		self.overrideOnClick = nil;
	end

	-- Club tickets have the real club info one layer down.
	local isTicket = clubInfo and clubInfo.isTicket;
	if (isTicket) then
		clubInfo = clubInfo.clubInfo;
	end

	local communitiesList = self:GetCommunitiesList();
	local shouldShowFlash = clubInfo and communitiesList:ShouldShowNewCommunityFlash(clubInfo.clubId);
	local isFlashing = UIFrameIsFlashing(self.NewCommunityFlash);
	if (shouldShowFlash and not isFlashing) then
		UIFrameFlash(self.NewCommunityFlash, 1.0, 1.0, NEW_COMMUNITY_FLASH_DURATION, false, 0, 0);
		communitiesList:OnNewCommunityFlashStarted();
	elseif (not shouldShowFlash and isFlashing) then
		UIFrameFlashStop(self.NewCommunityFlash);
	end

	if (clubInfo) then
		local isGuild = clubInfo.clubType == Enum.ClubType.Guild;

		if (isClubFinderInvitation) then
			self.Name:SetText(COMMUNITIES_LIST_INVITATION_DISPLAY:format(clubInfo.name));
			self.clubInfo = clubInfo;
			self.overrideOnClick = function(self, button)
				if (button == "LeftButton") then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
					local communitiesFrame = self:GetCommunitiesFrame();
					communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
					communitiesFrame.ClubFinderInvitationFrame:DisplayInvitation(self.clubInfo);
					communitiesFrame:SelectClub(nil);
				end
			end;

			if (isGuild) then
				self.Background:SetAtlas("communities-nav-button-green-normal");
				self.Background:SetTexCoord(0, 1, 0, 1);
				self.Selection:SetAtlas("communities-nav-button-green-pressed");
				self.Selection:SetTexCoord(0, 1, 0, 1);
			else
				self.Background:SetTexture("Interface\\Common\\bluemenu-main");
				self.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
				self.Selection:SetTexture("Interface\\Common\\bluemenu-main");
				self.Selection:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
			end

			local isBattleNet = false;
			self.Name:SetTextColor(GetFontColor(isBattleNet, isGuild, isInvitation):GetRGB());
			self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 11, 0);
			self.isInvitation = isInvitation;
			self.isTicket = isTicket;
			self.Selection:SetShown(true);
			self.FavoriteIcon:SetShown(false);
			self.InvitationIcon:SetShown(isClubFinderInvitation);
			SetLargeGuildTabardTextures("player", self.GuildTabardEmblem, self.GuildTabardBackground, self.GuildTabardBorder);
			self.GuildTabardEmblem:SetShown(false);
			self.GuildTabardBackground:SetShown(false);
			self.GuildTabardBorder:SetShown(false);
			self.Icon:SetShown(false);
			self.Icon:SetSize(38, 38);
			self.Icon:SetPoint("TOPLEFT", 11, -15);
			self.CircleMask:SetShown(false);
			self.IconRing:SetShown(false);
			return;
		end

		if (isInvitation) then
			self.Name:SetText(COMMUNITIES_LIST_INVITATION_DISPLAY:format(clubInfo.name));
		else
			self.Name:SetText(clubInfo.name);
		end

		if (isGuild) then
			self.Background:SetAtlas("communities-nav-button-green-normal");
			self.Background:SetTexCoord(0, 1, 0, 1);
			self.Selection:SetAtlas("communities-nav-button-green-pressed");
			self.Selection:SetTexCoord(0, 1, 0, 1);
		else
			self.Background:SetTexture("Interface\\Common\\bluemenu-main");
			self.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
			self.Selection:SetTexture("Interface\\Common\\bluemenu-main");
			self.Selection:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		end

		local isBattleNet = clubInfo.clubType == Enum.ClubType.BattleNet;
		self.Name:SetTextColor(GetFontColor(isBattleNet, isGuild, isInvitation):GetRGB());
		self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 11, 0);
		self.clubId = clubInfo.clubId;
		self.isInvitation = isInvitation;
		self.isTicket = isTicket;
		self.Selection:SetShown(clubInfo.clubId == self:GetCommunitiesFrame():GetSelectedClubId());
		self.FavoriteIcon:SetShown(self:GetCommunitiesFrame().CommunitiesList:IsClubFavorite(clubInfo));
		self.InvitationIcon:SetShown(isInvitation or isTicket);
		SetLargeGuildTabardTextures("player", self.GuildTabardEmblem, self.GuildTabardBackground, self.GuildTabardBorder);
		self.GuildTabardEmblem:SetShown(isGuild);
		self.GuildTabardBackground:SetShown(isGuild);
		self.GuildTabardBorder:SetShown(isGuild);
		self.Icon:SetShown(not isInvitation and not isGuild and not isTicket);
		self.Icon:SetSize(38, 38);
		self.Icon:SetPoint("TOPLEFT", 11, -15);
		self.CircleMask:SetShown(not isInvitation and not isGuild);
		self.IconRing:SetShown(not isInvitation and not isGuild and not isTicket);
		self.IconRing:SetAtlas(isBattleNet and "communities-ring-blue" or "communities-ring-gold");
		C_Club.SetAvatarTexture(self.Icon, clubInfo.avatarId, clubInfo.clubType);
		self:UpdateUnreadNotification();
	elseif (elementData.setGuildFinder) then
		self:SetGuildFinder();
	elseif (elementData.setFindCommunity) then
		self:SetFindCommunity();
	elseif (elementData.setJoinCommunity) then
		self:SetAddCommunity();
	end
end

function CommunitiesListEntryMixin:UpdateUnreadNotification()
	if C_SocialRestrictions.IsChatDisabled() then
		self.UnreadNotificationIcon:SetShown(false);
	else
		local isNewInvitation = self.isInvitation and not DISPLAYED_COMMUNITIES_INVITATIONS[self.clubId];
		local hasUnread = not self.isTicket and self.clubId and CommunitiesUtil.DoesCommunityHaveUnreadMessages(self.clubId);
		self.UnreadNotificationIcon:SetShown(isNewInvitation or hasUnread);
	end
end

function CommunitiesListEntryMixin:CheckForDisabledReason(clubType)
	local disabledReason = C_ClubFinder.GetClubFinderDisableReason();
	local disabled = disabledReason or not C_Club.ShouldAllowClubType(clubType);
	self:SetEntryEnabled(not disabled);

	if disabled then
		if disabledReason == Enum.ClubFinderDisableReason.Muted then
			self:SetDisabledTooltip(COMMUNITY_FEATURE_UNAVAILABLE_MUTED);
		elseif disabledReason == Enum.ClubFinderDisableReason.Silenced then
			self:SetDisabledTooltip(COMMUNITY_FEATURE_UNAVAILABLE_SILENCED);
		elseif disabledReason == Enum.ClubFinderDisableReason.VeteranTrial then 
			self:SetDisabledTooltip(CLUB_FINDER_DISABLE_REASON_VETERAN_TRIAL);
		else
			self:SetDisabledTooltip(COMMUNITY_TYPE_UNAVAILABLE);
		end
	else
		self:SetDisabledTooltip(nil);
	end

	return disabled;
end

function CommunitiesListEntryMixin:SetFindCommunity()
	local disabled = self:CheckForDisabledReason(Enum.ClubType.Character);

	self.overrideOnClick = function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local communitiesFrame = self:GetCommunitiesFrame();
		communitiesFrame:SelectClub(nil);
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER);

		communitiesFrame.CommunityFinderFrame.isGuildType = false;
		communitiesFrame.CommunityFinderFrame.selectedTab = 1; 
		communitiesFrame.CommunityFinderFrame:UpdateType(); 
	end;
	
	self.clubId = nil;
	self.Name:SetText(COMMUNITY_FINDER_FIND_COMMUNITY);

	if not disabled then
		self.Name:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	end

	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 13, 0);
	self.Selection:SetShown(self:GetCommunitiesFrame():GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER);

	self.Background:SetTexture("Interface\\Common\\bluemenu-main");
	self.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
	self.Selection:SetTexture("Interface\\Common\\bluemenu-main");
	self.Selection:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
	self.FavoriteIcon:Hide();
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.CircleMask:Hide();
	self.IconRing:Hide();
	self.GuildTabardEmblem:Hide();
	self.GuildTabardBackground:Hide();
	self.GuildTabardBorder:Hide();
	self.UnreadNotificationIcon:Hide();

	self.Icon:SetAtlas("communities-icon-searchmagnifyingglass");
	self.Icon:SetSize(30, 30);
	self.Icon:SetPoint("TOPLEFT", 17, -18);

	UIFrameFlashStop(self.NewCommunityFlash);
end

function CommunitiesListEntryMixin:SetAddCommunity()
	self:SetEntryEnabled(true);

	self.overrideOnClick = function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
		if not AddCommunitiesFlow_IsShown() then
			self:GetCommunitiesFrame():CloseActiveDialogs();
		end
		AddCommunitiesFlow_Toggle();
	end;
	
	self.clubId = nil;
	self.Name:SetText(COMMUNITIES_JOIN_COMMUNITY);
	self.Name:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 13, 0);
	self.Selection:Hide();
	
	self.Background:SetTexture("Interface\\Common\\bluemenu-main");
	self.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
	self.Selection:SetTexture("Interface\\Common\\bluemenu-main");
	self.Selection:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
	self.FavoriteIcon:Hide();
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.CircleMask:Hide();
	self.IconRing:Hide();
	self.GuildTabardEmblem:Hide();
	self.GuildTabardBackground:Hide();
	self.GuildTabardBorder:Hide();
	self.UnreadNotificationIcon:Hide();

	self.Icon:SetAtlas("communities-icon-addgroupplus");
	self.Icon:SetSize(30, 30);
	self.Icon:SetPoint("TOPLEFT", 17, -18);

	UIFrameFlashStop(self.NewCommunityFlash);
end

function CommunitiesListEntryMixin:SetGuildFinder()
	local disabled = self:CheckForDisabledReason(Enum.ClubType.Guild);

	self.overrideOnClick = function ()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		local communitiesFrame = self:GetCommunitiesFrame();
		communitiesFrame:SelectClub(nil);	
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);

		communitiesFrame.GuildFinderFrame.isGuildType = true;
		communitiesFrame.GuildFinderFrame.selectedTab = 1;
		communitiesFrame.GuildFinderFrame:UpdateType(); 

		communitiesFrame.Inset:Hide();
	end;
	
	self.clubId = nil;
	self.Name:SetText(COMMUNITIES_GUILD_FINDER);

	if not disabled then
		self.Name:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	end

	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 10, 0);
	self.Selection:SetShown(self:GetCommunitiesFrame():GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);

	self.Background:SetAtlas("communities-nav-button-green-normal");
	self.Background:SetTexCoord(0, 1, 0, 1);
	self.Selection:SetAtlas("communities-nav-button-green-pressed");
	self.Selection:SetTexCoord(0, 1, 0, 1);
	self.FavoriteIcon:Hide();
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.Icon:SetSize(35, 35);
	self.Icon:SetPoint("TOPLEFT", 15, -15);
	self.CircleMask:Show();
	self.IconRing:Hide();
	self.GuildTabardEmblem:Hide();
	self.GuildTabardBackground:Show();
	self.GuildTabardBackground:SetVertexColor(0.7, 0.7, 0.7);
	self.GuildTabardBorder:Show();
	self.GuildTabardBorder:SetVertexColor(0.7, 0.7, 0.7);
	self.UnreadNotificationIcon:Hide();

	local factionGroup = UnitFactionGroup("player");
	if factionGroup == "Alliance" then
		self.Icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Alliance");
	else
		self.Icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Horde");
	end

	UIFrameFlashStop(self.NewCommunityFlash);
end

function CommunitiesListEntryMixin:GetClubId()
	return self.clubId;
end

function CommunitiesListEntryMixin:IsInvitation()
	return self.isInvitation;
end

function CommunitiesListEntryMixin:IsTicket()
	return self.isTicket;
end

function CommunitiesListEntryMixin:GetCommunitiesList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesListEntryMixin:GetCommunitiesFrame()
	return self:GetCommunitiesList():GetCommunitiesFrame();
end

function CommunitiesListEntryMixin:SetEntryEnabled(enabled)
	local desaturated = not enabled;
	self.Background:SetDesaturated(desaturated);
	self.Icon:SetDesaturated(desaturated);
	self.GuildTabardBorder:SetDesaturated(desaturated);
	self.GuildTabardBackground:SetDesaturated(desaturated);
	self.Name:SetFontObject(GameFontDisable);
	self:SetEnabled(enabled);
end

function CommunitiesListEntryMixin:SetDisabledTooltip(disabledTooltip)
	self.disabledTooltip = disabledTooltip;
end

function CommunitiesListEntryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_LIST_ENTRY_EVENTS);
end

function CommunitiesListEntryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_LIST_ENTRY_EVENTS);
end

function CommunitiesListEntryMixin:OnEvent(event, ...)
	if event == "STREAM_VIEW_MARKER_UPDATED" then
		local clubId, streamId, lastUnreadTime = ...;
		if clubId == self.clubId then
			self:UpdateUnreadNotification();
		end
	elseif event == "PLAYER_GUILD_UPDATE" then
		SetLargeGuildTabardTextures("player", self.GuildTabardEmblem, self.GuildTabardBackground, self.GuildTabardBorder);
	elseif event == "CHAT_DISABLED_CHANGE_FAILED" or event == "CHAT_DISABLED_CHANGED" then
		self:UpdateUnreadNotification();
	end
end

function CommunitiesListEntryMixin:OnEnter()
	if not self:IsEnabled() and self.disabledTooltip then
		GameTooltip_ShowDisabledTooltip(GameTooltip, self, self.disabledTooltip);
	elseif self.Name:IsTruncated() then
		GameTooltip:SetOwner(self);
		GameTooltip_SetTitle(GameTooltip, self.Name:GetText());
		GameTooltip:Show();
	end
end

function CommunitiesListEntryMixin:OnClick(button)
	if self.overrideOnClick then
		self.overrideOnClick(self, button);
		return;
	end
	
	if button == "LeftButton" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self:GetCommunitiesFrame():SelectClub(self.clubId);
	elseif button == "RightButton" then
		local clubId = self:GetClubId();
		if not clubId then
			return;
		end

		local clubInfo = C_Club.GetClubInfo(clubId);
		if not clubInfo then
			return;
		end

		local memberInfo = C_Club.GetMemberInfoForSelf(clubId);
		if memberInfo then
			local contextData =
			{
				name = clubInfo.name,
				clubMemberInfo = memberInfo,
				clubInfo = clubInfo,
			};

			if clubInfo.clubType == Enum.ClubType.Guild then 
				UnitPopup_OpenMenu("GUILDS_GUILD", contextData);
			else 
				UnitPopup_OpenMenu("COMMUNITIES_COMMUNITY", contextData);
			end
		end
	end
end

CommunitiesListDropdownMixin = {};

function CommunitiesListDropdownMixin:OnLoad()
	WowStyle1DropdownMixin.OnLoad(self);

	self:SetSelectionTranslator(function(selection)
		return selection.data.dropdownText;
	end);
end

function CommunitiesListDropdownMixin:OnShow()
	self:SetupMenu();
	self:UpdateUnreadNotification();

	local parent = self:GetParent();
	if parent.RegisterCallback then
		parent:RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.OnCommunitiesClubSelected, self);
	end
end

function CommunitiesListDropdownMixin:OnHide()
	local parent = self:GetParent();
	if parent.RegisterCallback then
		parent:UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self);
	end
end

function CommunitiesListDropdownMixin:SetupMenu()
	WowStyle1DropdownMixin.SetupMenu(self, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMMUNITIES_LIST");

		local clubs = C_Club.GetSubscribedClubs();
		if not clubs then
			return;
		end

		CommunitiesUtil.SortClubs(clubs);
		
		local function IsChecked(clubInfo)
			return clubInfo.clubId == self:GetParent():GetSelectedClubId();
		end

		local function SetChecked(clubInfo)
			self:GetParent():SelectClub(clubInfo.clubId);
		end

		for i, clubInfo in ipairs(clubs) do
			local text = clubInfo.name;
			clubInfo.dropdownText = text;

			if CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubInfo.clubId) then
				text = CreateCommunitiesIconNotificationMarkup(text);
			end

			rootDescription:CreateRadio(text, IsChecked, SetChecked, clubInfo);
		end
	end);
end

function CommunitiesListDropdownMixin:OnCommunitiesClubSelected(clubId)
	if clubId and self:IsVisible() then
		self:OnClubSelected();
	end
end

function CommunitiesListDropdownMixin:OnClubSelected()
	self:SetupMenu();
	self:UpdateUnreadNotification();
end

function CommunitiesListDropdownMixin:UpdateUnreadNotification()
	local parent = self:GetParent();
	if parent.RegisterCallback then
		local clubId = parent:GetSelectedClubId();
		self.NotificationOverlay:SetShown(CommunitiesUtil.DoesOtherCommunityHaveUnreadMessages(clubId));
	else
		-- If our parent is not the communities frame we don't show unread notifications.
		self.NotificationOverlay:SetShown(false);
	end
end