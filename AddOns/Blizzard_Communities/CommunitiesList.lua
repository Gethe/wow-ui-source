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
	
local COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET = -28;
local COMMUNITIES_LIST_INITLAL_BOTTOM_BORDER_OFFSET = 40;
local COMMUNITIES_LIST_GUILD_FINDER_OFFSET = 28;

local NEW_COMMUNITY_FLASH_DURATION = 6.0;

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

function CommunitiesListMixin:GetFirstMatchingClubEntry(predicate)
	local buttons = self.ListScrollFrame.buttons;
	for i, button in ipairs(buttons) do
		if predicate(button) then
			return button;
		end
	end
	
	return nil;
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
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	
	local selectedClubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local clubs = self:GetCommunitiesList();
	self:ValidateTickets();
	local isInGuild = IsInGuild();
	local invitations = self:GetInvitations();
	local clubFinderInvitations = self:GetClubFinderInvitations(); 
	local clubFinderEnabled = C_ClubFinder.IsEnabled();
	local numFinderInvitations = 0; 
	
	if	(clubFinderInvitations and clubFinderEnabled) then 
		numFinderInvitations = #clubFinderInvitations
	end 

	local tickets = self:GetTickets();
	local totalNumClubs = numFinderInvitations + #invitations + #tickets + #clubs;

	if not isInGuild and clubFinderEnabled then
		totalNumClubs = totalNumClubs + 1;
	end

	local height = buttons[1]:GetHeight();
	-- TODO:: Determine if this player is at the maximum number of allowed clubs or not.
	-- We probably need to change the create flow as well, since it's possible you are
	-- allowed to create more bnet groups, but not more wow communities or vice versa.
	local shouldAddJoinCommunityEntry = C_Club.ShouldAllowClubType(Enum.ClubType.Character) or C_Club.ShouldAllowClubType(Enum.ClubType.BattleNet); 
	local shouldFindCommunityEntry = clubFinderEnabled;
	
	-- We need 1 for the blank entry at the top of the list.
	local clubsHeight = height * (totalNumClubs + 1);
	if shouldAddJoinCommunityEntry then
		clubsHeight = clubsHeight + height;
		if(shouldFindCommunityEntry) then 
			clubsHeight = clubsHeight + height; 
		end
	end
	
	local usedHeight = height;
	local shownGuildFinderButton = false; 
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;

		-- We leave a space at the top of the scroll frame. This is accomplished most easily with a blank entry.
		if displayIndex == 1 then
			buttons[displayIndex]:SetClubInfo(nil);
			buttons[displayIndex]:Hide();
		else
			displayIndex = displayIndex - 1;
			local clubInfo = nil;
			local isTicket = displayIndex <= #tickets;
			local isInvitation = displayIndex > #tickets and displayIndex <= #tickets + #invitations;
			local isClubFinderInvitation = displayIndex > #tickets + #invitations and displayIndex <= numFinderInvitations + #tickets + #invitations; 

			if isTicket then
				clubInfo = tickets[displayIndex].clubInfo;
			elseif isInvitation then
				displayIndex = displayIndex - #tickets;
				clubInfo = invitations[displayIndex].club;
			elseif isClubFinderInvitation then 
				displayIndex = displayIndex - #tickets - #invitations; 
				clubInfo = clubFinderInvitations[displayIndex];
			else
				displayIndex = displayIndex - #tickets - #invitations - numFinderInvitations;
				if not isInGuild and clubFinderEnabled then
					displayIndex = displayIndex - 1;
				end
				if displayIndex > 0 and displayIndex <= #clubs then
					clubInfo = clubs[displayIndex];
				end
			end
			if (not isInGuild and displayIndex == 0 and clubFinderEnabled) then
				button:SetGuildFinder();
				local communitiesFrame = self:GetCommunitiesFrame();
				communitiesFrame.GuildFinderFrame.isGuildType = true;
				communitiesFrame.GuildFinderFrame:UpdateType(); 
				button:Show();
				shownGuildFinderButton = true;
				usedHeight = usedHeight + height;
			elseif clubInfo then
				button:SetClubInfo(clubInfo, isInvitation, isTicket, isClubFinderInvitation);
				button:Show();
				usedHeight = usedHeight + height;
			elseif shouldFindCommunityEntry then
				button:SetFindCommunity(); 
				button:Show();
				usedHeight = usedHeight + height;
				shouldFindCommunityEntry = false;
			elseif shouldAddJoinCommunityEntry then 
				button:SetAddCommunity();
				button:Show(); 
				usedHeight = usedHeight + height; 
				shouldAddJoinCommunityEntry = false;
			elseif isInGuild and not shownGuildFinderButton  and clubFinderEnabled then 
				button:SetGuildFinder();
				button:Show();
				shownGuildFinderButton = true;
				usedHeight = usedHeight + height + COMMUNITIES_LIST_GUILD_FINDER_OFFSET;
			else
				button:SetClubInfo(nil);
				button:Hide();
			end
		end
	end
	local totalHeight = clubsHeight + COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET + COMMUNITIES_LIST_INITLAL_BOTTOM_BORDER_OFFSET;

	if (isInGuild and clubFinderEnabled) then 
		totalHeight = totalHeight + COMMUNITIES_LIST_GUILD_FINDER_OFFSET;
	end 

	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);
end

function CommunitiesListMixin:UpdateClubInfo(newClubInfo)
	local clubs = self:GetCommunitiesList();
	if clubs then
		for i, club in ipairs(clubs) do
			if club.clubId == newClubInfo.clubId then
				clubs[i] = newClubInfo;
				break;
			end
		end
	end
end

function CommunitiesListMixin:UpdateClub(clubInfo)
	self:UpdateClubInfo(clubInfo);
	
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	for i, button in ipairs(buttons) do
		if button:GetClubId() == clubInfo.clubId then
			local isInvitation = false;
			local isTicket = false;
			local isClubFinderInvitation = false;
			button:SetClubInfo(clubInfo, isInvitation, isTicket, isClubFinderInvitation);
			return;
		end
	end
end

function CommunitiesListMixin:OnLoad()
	self.ListScrollFrame.update = function() 
		self:Update(); 
	end;
	C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All);
	self.ListScrollFrame.ScrollBar.doNotHide = true;
	self.ListScrollFrame.ScrollBar:SetValue(0);
	
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

	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesListEntryTemplate", 0, -COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET);
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
	local hasScrollBar = self.ListScrollFrame.totalHeight > self.ListScrollFrame:GetHeight();
	if not hasScrollBar then
		return;
	end
	
	local clubs = self:GetCommunitiesList();
	if clubs ~= nil then
		local clubIndex = nil;
		for i, club in ipairs(clubs) do
			if club.clubId == clubId then
				clubIndex = i;
				break;
			end
		end
		
		if clubIndex ~= nil then
			local invitations = self:GetInvitations();
			local numInvitiations = invitations ~= nil and #invitations or 0;
			clubIndex = clubIndex + numInvitiations;
			
			-- Count the blank entry at the top of the scroll frame.
			clubIndex = clubIndex + 1;
			
			-- Count the guild finder.
			if not IsInGuild() then
				clubIndex = clubIndex + 1;
			end
			
			local buttons = self.ListScrollFrame.buttons;
			local buttonHeight = buttons[1]:GetHeight();
			
			local height = math.max(0, math.floor(buttonHeight * (clubIndex - (#buttons)/2.5)));
			HybridScrollFrame_SetOffset(self.ListScrollFrame, height);
			self.ListScrollFrame.ScrollBar:SetValue(height);
		end
	end
end

function CommunitiesListMixin:OnClubSelected(clubId)
	self:Update();
end

function CommunitiesListMixin:SetSelectedEntryForDropDown(entry)
	self.selectedEntryForDropDown = entry;
end

function CommunitiesListMixin:GetSelectedEntryForDropDown()
	return self.selectedEntryForDropDown;
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
	local buttons = self.ListScrollFrame.buttons;
	local numVisibleButtons = #buttons - 1;
	for i = 1, numVisibleButtons do
		local button = buttons[i];
		if button.Name:GetText() == COMMUNITY_FINDER_FIND_COMMUNITY then
			return true;
		end
	end

	return false;
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

function CommunitiesListEntryMixin:SetClubInfo(clubInfo, isInvitation, isTicket, isInviteFromFinder)
	self:SetEntryEnabled(true);

	if isInvitation then
		self.overrideOnClick = function(self, button)
			if button == "LeftButton" then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				local communitiesFrame = self:GetCommunitiesFrame(); 
				communitiesFrame:SelectClub(self.clubId);
				self:UpdateUnreadNotification();
			end
		end;
	else
		self.overrideOnClick = nil;
	end

	local communitiesList = self:GetCommunitiesList();
	local shouldShowFlash = clubInfo and communitiesList:ShouldShowNewCommunityFlash(clubInfo.clubId);
	local isFlashing = UIFrameIsFlashing(self.NewCommunityFlash);
	if shouldShowFlash and not isFlashing then
		UIFrameFlash(self.NewCommunityFlash, 1.0, 1.0, NEW_COMMUNITY_FLASH_DURATION, false, 0, 0);
		communitiesList:OnNewCommunityFlashStarted();
	elseif not shouldShowFlash and isFlashing then
		UIFrameFlashStop(self.NewCommunityFlash);
	end

	if clubInfo then
		if(isInviteFromFinder) then 
			self.Name:SetText(COMMUNITIES_LIST_INVITATION_DISPLAY:format(clubInfo.name));		
			self.clubInfo = clubInfo;
			self.overrideOnClick = function(self, button)
				if button == "LeftButton" then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
					local communitiesFrame = self:GetCommunitiesFrame();
					communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
					communitiesFrame.ClubFinderInvitationFrame:DisplayInvitation(self.clubInfo);
					communitiesFrame:SelectClub(nil);
				end
			end;

			if clubInfo.isGuild then
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
			self.Name:SetTextColor(GetFontColor(isBattleNet, clubInfo.isGuild, isInvitation):GetRGB());
			self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 11, 0);
			self.isInvitation = isInvitation;
			self.isTicket = isTicket;
			self.Selection:SetShown(true);
			self.FavoriteIcon:SetShown(false);
			self.InvitationIcon:SetShown(isInviteFromFinder);
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

		if isInvitation then
			self.Name:SetText(COMMUNITIES_LIST_INVITATION_DISPLAY:format(clubInfo.name));
		else
			self.Name:SetText(clubInfo.name);
		end
		
		local isGuild = clubInfo.clubType == Enum.ClubType.Guild;
		if isGuild then
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
	else
		self.Name:SetText(nil);
		self.clubId = nil;
		self.Selection:Hide();
		self.Icon:SetTexture(nil);
		self.UnreadNotificationIcon:Hide();
		self:Hide();
	end
end

function CommunitiesListEntryMixin:UpdateUnreadNotification()
	local isNewInvitation = self.isInvitation and not DISPLAYED_COMMUNITIES_INVITATIONS[self.clubId];
	local hasUnread = not self.isTicket and self.clubId and CommunitiesUtil.DoesCommunityHaveUnreadMessages(self.clubId);
	self.UnreadNotificationIcon:SetShown(isNewInvitation or hasUnread);
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
	local disabled = self:CheckForDisabledReason(Enum.ClubType.Character);

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
		local clubInfo = C_Club.GetClubInfo(self:GetClubId());
		if not clubInfo then
			return;
		end

		local communitiesList = self:GetParent():GetParent():GetParent();
		communitiesList:SetSelectedEntryForDropDown(self);
		ToggleDropDownMenu(1, nil, communitiesList.EntryDropDown, self, 0, 0);
	end
end

function CommunitiesListEntryDropDown_Initialize(self, level)
	local communitiesList = self:GetParent();
	local selectedCommunitiesListEntry = communitiesList:GetSelectedEntryForDropDown();
	if not selectedCommunitiesListEntry then
		return;
	end
	
	local clubId = selectedCommunitiesListEntry:GetClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		local memberInfo = C_Club.GetMemberInfoForSelf(clubId);
		if clubInfo and memberInfo then
			self.clubMemberInfo = memberInfo;
			self.clubInfo = clubInfo;
			if clubInfo.clubType == Enum.ClubType.Guild then 
				UnitPopup_ShowMenu(self, "GUILDS_GUILD", nil, clubInfo.name);
			else 
				UnitPopup_ShowMenu(self, "COMMUNITIES_COMMUNITY", nil, clubInfo.name);
			end
		end
	end
end

function CommunitiesListEntryDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CommunitiesListEntryDropDown_Initialize, "MENU");
end

function CommunitiesListEntryDropDown_OnHide(self)
	local communitiesList = self:GetParent();
	communitiesList:SetSelectedEntryForDropDown(nil);
	self.clubMemberInfo = nil;
	self.clubInfo = nil;
end

CommunitiesListDropDownMenuMixin = {};

function CommunitiesListDropDownMenuMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, self.width or 115);
	self.Text:SetJustifyH("LEFT");
end

function CommunitiesListDropDownMenuMixin:OnShow()
	UIDropDownMenu_Initialize(self, CommunitiesListDropDownMenu_Initialize);
	local parent = self:GetParent();
	UIDropDownMenu_SetSelectedValue(self, parent:GetSelectedClubId());
	self:UpdateUnreadNotification();

	if parent.RegisterCallback then
		parent:RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.OnCommunitiesClubSelected, self);
	end
end

function CommunitiesListDropDownMenuMixin:OnHide()
	local parent = self:GetParent();
	if parent.RegisterCallback then
		parent:UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self);
	end
end

function CommunitiesListDropDownMenuMixin:OnCommunitiesClubSelected(clubId)
	if clubId and self:IsVisible() then
		self:OnClubSelected();
	end
end

function CommunitiesListDropDownMenuMixin:OnClubSelected()
	local parent = self:GetParent();
	local clubId = parent:GetSelectedClubId();
	UIDropDownMenu_SetSelectedValue(self, clubId);
	
	local clubInfo = C_Club.GetClubInfo(clubId);
	UIDropDownMenu_SetText(self, clubInfo and clubInfo.name or "");
	
	self:UpdateUnreadNotification();
end

function CommunitiesListDropDownMenuMixin:UpdateUnreadNotification()
	local parent = self:GetParent();
	if parent.RegisterCallback then
		local clubId = parent:GetSelectedClubId();
		self.NotificationOverlay:SetShown(CommunitiesUtil.DoesOtherCommunityHaveUnreadMessages(clubId));
	else
		-- If our parent is not the communities frame we don't show unread notifications.
		self.NotificationOverlay:SetShown(false);
	end

end

function CommunitiesListScrollFrame_OnVerticalScroll(self)
	local communitiesList = self:GetParent();
	if communitiesList:GetSelectedEntryForDropDown() ~= nil then
		HideDropDownMenu(1);
	end
end

function CommunitiesListDropDownMenu_Initialize(self)
	local clubs = C_Club.GetSubscribedClubs();
	if clubs ~= nil then
		CommunitiesUtil.SortClubs(clubs);
		local info = UIDropDownMenu_CreateInfo();
		local parent = self:GetParent();
		for i, clubInfo in ipairs(clubs) do
			info.text = clubInfo.name;
			if CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubInfo.clubId) then
				info.text = info.text.." "..CreateAtlasMarkup("communities-icon-notification", 11, 11);
			end
			
			info.value = clubInfo.clubId;
			info.func = function(button)
				parent:SelectClub(button.value);
			end
			UIDropDownMenu_AddButton(info);
		end
		
		local clubId = parent:GetSelectedClubId();
		if clubId then
			UIDropDownMenu_SetSelectedValue(self, clubId);
			
			local clubInfo = C_Club.GetClubInfo(clubId);
			UIDropDownMenu_SetText(self, clubInfo and clubInfo.name or "");
		end
	end
end