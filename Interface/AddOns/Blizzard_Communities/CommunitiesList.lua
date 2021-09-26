local COMMUNITIES_LIST_EVENTS = {
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_UPDATED",
	"CLUB_INVITATION_ADDED_FOR_SELF",
	"CLUB_INVITATION_REMOVED_FOR_SELF",
};
	
local COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET = -28;
local COMMUNITIES_LIST_INITLAL_BOTTOM_BORDER_OFFSET = 40;

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
	if selectedClubId == nil and self.mostRecentAcceptedInviteOrTicket then
		for i, clubInfo in ipairs(clubs) do
			if clubInfo.clubId == self.mostRecentAcceptedInviteOrTicket then
				self:GetCommunitiesFrame():SelectClub(self.mostRecentAcceptedInviteOrTicket);
				self.mostRecentAcceptedInviteOrTicket = nil;
				self:ScrollToClub(self:GetCommunitiesFrame():GetSelectedClubId());

				-- Selecting a club already triggered a second update.
				return;
			end
		end
	end
	
	self:ValidateTickets();

	local invitations = self:GetInvitations();
	local tickets = self:GetTickets();
	local totalNumClubs = #invitations + #tickets + #clubs;

	local height = buttons[1]:GetHeight();
	
	-- TODO:: Determine if this player is at the maximum number of allowed clubs or not.
	-- We probably need to change the create flow as well, since it's possible you are
	-- allowed to create more bnet groups, but not more wow communities or vice versa.
	local shouldAddJoinCommunityEntry = C_Club.ShouldAllowClubType(Enum.ClubType.BattleNet); 
	
	-- We need 1 for the blank entry at the top of the list.
	local clubsHeight = height * (totalNumClubs + 1);
	if shouldAddJoinCommunityEntry then
		clubsHeight = clubsHeight + height;
	end
	
	local usedHeight = height;
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

			if isTicket then
				clubInfo = tickets[displayIndex].clubInfo;
			elseif isInvitation then
				displayIndex = displayIndex - #tickets;
				clubInfo = invitations[displayIndex].club;
			else
				displayIndex = displayIndex - #tickets - #invitations;
				
				if displayIndex > 0 and displayIndex <= #clubs then
					clubInfo = clubs[displayIndex];
				end
			end
			
			if clubInfo then
				button:SetClubInfo(clubInfo, isInvitation, isTicket);
				button:SetFocused(isInvitation or clubInfo.clubId == selectedClubId);
				button:Show();
				usedHeight = usedHeight + height;
			elseif shouldAddJoinCommunityEntry then
				button:SetAddCommunity();
				button:Show();
				usedHeight = usedHeight + height;
				shouldAddJoinCommunityEntry = false;
			else
				button:SetClubInfo(nil);
				button:Hide();
			end
		end
	end
	
	local totalHeight = clubsHeight + COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET + COMMUNITIES_LIST_INITLAL_BOTTOM_BORDER_OFFSET;
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
			button:SetClubInfo(clubInfo, isInvitation, isTicket);
			return;
		end
	end
end

function CommunitiesListMixin:OnLoad()
	self.ListScrollFrame.update = function() 
		self:Update(); 
	end;
	self.ListScrollFrame.ScrollBar.doNotHide = true;
	self.ListScrollFrame.ScrollBar:SetValue(0);
	
	self.declinedInvitationIds = {};
	self.pendingFavorites = {};
end

function CommunitiesListMixin:RegisterEventCallbacks()
	local function CommunityInviteAcceptedCallback(event, invitationId, clubId)
		self.mostRecentAcceptedInviteOrTicket = clubId;
	end

	local function CommunityInviteDeclinedCallback(event, invitationId, clubId)
		self.declinedInvitationIds[#self.declinedInvitationIds + 1] = invitationId;
		self:GetCommunitiesFrame():UpdateClubSelection();
		self:UpdateInvitations();
		self:Update();
	end

	local function CommunityTicketAcceptedCallback(event, ticketId, clubId)
		self.mostRecentAcceptedInviteOrTicket = clubId;
	end

	self.inviteAcceptedCallback = CommunityInviteAcceptedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.InviteAccepted, self.inviteAcceptedCallback);
	
	self.inviteDeclinedCallback = CommunityInviteDeclinedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.InviteDeclined, self.inviteDeclinedCallback);

	self.ticketAcceptedCallback = CommunityTicketAcceptedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.TicketAccepted, self.ticketAcceptedCallback);
end

function CommunitiesListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_LIST_EVENTS);
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesListEntryTemplate", 0, -COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET);
	self:UpdateCommunitiesList();
	self:UpdateInvitations();
	self:Update();
	
	if not self.hasRegisteredEventCallbacks then
		self:RegisterEventCallbacks();
	end
end

function CommunitiesListMixin:OnHide()
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.InviteAccepted, self.inviteAcceptedCallback);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.InviteDeclined, self.inviteDeclinedCallback);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.TicketAccpted, self.ticketAcceptedCallback);
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
			
			local buttons = self.ListScrollFrame.buttons;
			local buttonHeight = buttons[1]:GetHeight();
			
			local height = math.max(0, math.floor(buttonHeight * (clubIndex - (#buttons)/2)));
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

local COMMUNITIES_LIST_ENTRY_EVENTS = {
	"STREAM_VIEW_MARKER_UPDATED",
}

CommunitiesListEntryMixin = {};

function CommunitiesListEntryMixin:SetClubInfo(clubInfo, isInvitation, isTicket)
	if isInvitation then
		self.overrideOnClick = function(self, button)
			if button == "LeftButton" then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				self:GetCommunitiesFrame():SelectClub(self.clubId);
				self:UpdateUnreadNotification();
			end
		end;
	else
		self.overrideOnClick = nil;
	end
	
	if clubInfo then
		if isInvitation then
			self.Name:SetText(COMMUNITIES_LIST_INVITATION_DISPLAY:format(clubInfo.name));
		else
			self.Name:SetText(clubInfo.name);
		end
		
		local fontColor = NORMAL_FONT_COLOR;
		fontColor = BATTLENET_FONT_COLOR;
		
		self.Background:SetTexture("Interface\\Common\\bluemenu-main");
		self.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		self.Selection:SetTexture("Interface\\Common\\bluemenu-main");
		self.Selection:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		
		self.Name:SetTextColor(fontColor:GetRGB());
		self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 11, 0);
		self.clubId = clubInfo.clubId;
		self.isInvitation = isInvitation;
		self.isTicket = isTicket;
		self.Selection:SetShown(clubInfo.clubId == self:GetCommunitiesFrame():GetSelectedClubId());
		self.FavoriteIcon:SetShown(self:GetCommunitiesFrame().CommunitiesList:IsClubFavorite(clubInfo));
		self.InvitationIcon:SetShown(isInvitation or isTicket);
		self.Icon:SetShown(not isInvitation and not isTicket);
		self.Icon:SetSize(38, 38);
		self.Icon:SetPoint("TOPLEFT", 11, -15);
		self.CircleMask:SetShown(not isInvitation);
		self.IconRing:SetShown(not isInvitation and not isTicket);
		self.IconRing:SetAtlas("communities-ring-blue");
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

function CommunitiesListEntryMixin:SetAddCommunity()
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
	self.UnreadNotificationIcon:Hide();

	self.Icon:SetAtlas("communities-icon-addgroupplus");
	self.Icon:SetSize(30, 30);
	self.Icon:SetPoint("TOPLEFT", 17, -18);
	
	self:SetFocused(true);
end

function CommunitiesListEntryMixin:SetFocused(isFocused)
	local a = isFocused and 1.0 or 0.4;
	local r, g, b = self.Name:GetTextColor();
	self.Name:SetTextColor(r, g, b, a);
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
	end
end

function CommunitiesListEntryMixin:OnEnter()
	if self.Name:IsTruncated() then
		GameTooltip:SetOwner(self);
		GameTooltip:AddLine(self.Name:GetText());
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
			UnitPopup_ShowMenu(self, "COMMUNITIES_COMMUNITY", nil, clubInfo.name);
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
		local function CommunitiesClubSelectedCallback(event, clubId)
			if clubId and self:IsVisible() then
				self:OnClubSelected();
			end
		end
		
		self.clubSelectedCallback = CommunitiesClubSelectedCallback;
		parent:RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
	end
end

function CommunitiesListDropDownMenuMixin:OnHide()
	local parent = self:GetParent();
	if parent.RegisterCallback then
		parent:UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
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