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
		
	local clubs = self:GetCommunitiesList();
	if not self:GetCommunitiesFrame():GetSelectedClubId() and self.mostRecentAcceptedInvite then
		for i, clubInfo in ipairs(clubs) do
			if clubInfo.clubId == self.mostRecentAcceptedInvite then
				self:GetCommunitiesFrame():SelectClub(self.mostRecentAcceptedInvite);
				self.mostRecentAcceptedInvite = nil;

				-- Selecting a club already triggered a second update.
				return;
			end
		end
	end
		
	local isInGuild = IsInGuild();
	local invitations = self:GetInvitations();
	local totalNumClubs = #invitations + #clubs;
	if not isInGuild then
		totalNumClubs = totalNumClubs + 1;
	end

	local height = buttons[1]:GetHeight();
	
	-- TODO:: Determine if this player is at the maximum number of allowed clubs or not.
	-- We probably need to change the create flow as well, since it's possible you are
	-- allowed to create more bnet groups, but not more wow communities or vice versa.
	local shouldAddJoinCommunityEntry = true; 
	
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
			local isInvitation = displayIndex <= #invitations;
			if isInvitation then
				clubInfo = invitations[displayIndex].club;
			else
				displayIndex = displayIndex - #invitations;
				if not isInGuild then
					displayIndex = displayIndex - 1;
				end
				
				if displayIndex > 0 and displayIndex <= #clubs then
					clubInfo = clubs[displayIndex];
				end
			end
			
			if not isInGuild and displayIndex == 0 then
				button:SetGuildFinder();
				button:Show();
				usedHeight = usedHeight + height;
			elseif clubInfo then
				button:SetClubInfo(clubInfo, isInvitation);
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

function CommunitiesListMixin:UpdateClub(clubInfo)
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	for i, button in ipairs(buttons) do
		if button:GetClubId() == clubInfo.clubId then
			local isInvitation = false;
			button:SetClubInfo(clubInfo, isInvitation);
			return;
		end
	end
end

function CommunitiesListMixin:OnLoad()
	self.ListScrollFrame.update = function() 
		self:Update(); 
	end;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	self.ListScrollFrame.scrollBar:SetValue(0);
	
	self.declinedInvitationIds = {};
	self.pendingFavorites = {};
end

function CommunitiesListMixin:RegisterEventCallbacks()
	local function CommunityInviteAcceptedCallback(event, invitationId, clubId)
		self.mostRecentAcceptedInvite = clubId;
	end

	local function CommunityInviteDeclinedCallback(event, invitationId, clubId)
		self.declinedInvitationIds[#self.declinedInvitationIds + 1] = invitationId;
		self:UpdateInvitations();
		self:Update();
	end

	self.inviteAcceptedCallback = CommunityInviteAcceptedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.InviteAccepted, self.inviteAcceptedCallback);
	
	self.inviteDeclinedCallback = CommunityInviteDeclinedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.InviteDeclined, self.inviteDeclinedCallback);
end

function CommunitiesListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_LIST_EVENTS);
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CommunitiesListEntryTemplate", 0, -COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET);
	self.ListScrollFrame.ScrollBar:SetValueStep(1);
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
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_LIST_EVENTS);
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
	"STREAM_VIEW_MARKER_UPDATED"
}

CommunitiesListEntryMixin = {};

function CommunitiesListEntryMixin:SetClubInfo(clubInfo, isInvitation)
	self.overrideOnClick = nil;
	if clubInfo then
		local isGuild = clubInfo.clubType == Enum.ClubType.Guild;
		self.Name:SetText(clubInfo.name);
		local fontColor = NORMAL_FONT_COLOR;
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			fontColor = BATTLENET_FONT_COLOR;
		elseif isGuild then
			fontColor = GREEN_FONT_COLOR;
		end
		
		self.Name:SetTextColor(fontColor:GetRGB());
		self.clubId = clubInfo.clubId;
		self.isInvitation = isInvitation;
		self.Selection:SetShown(clubInfo.clubId == self:GetCommunitiesFrame():GetSelectedClubId());
		self.FavoriteIcon:SetShown(self:GetCommunitiesFrame().CommunitiesList:IsClubFavorite(clubInfo));
		self.InvitationIcon:SetShown(isInvitation);
		SetLargeGuildTabardTextures("player", self.GuildTabardEmblem, self.GuildTabardBackground, self.GuildTabardBorder);
		self.GuildTabardEmblem:SetShown(isGuild);
		self.GuildTabardBackground:SetShown(isGuild);
		self.GuildTabardBorder:SetShown(isGuild);
		self.Icon:SetShown(not isInvitation and not isGuild);
		self.Icon:SetSize(42, 42);
		self.Icon:SetPoint("TOPLEFT", 8, -15);
		self.CircleMask:SetShown(not isInvitation and not isGuild);
		self.IconRing:SetShown(not isInvitation and not isGuild);
		self.IconRing:SetAtlas(clubInfo.clubType == Enum.ClubType.BattleNet and "communities-ring-blue" or "communities-ring-gold");
		self.GuildFinderBackground:Hide();
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
	self.UnreadNotificationIcon:SetShown(not self.isInvitation and self.clubId and CommunitiesUtil.DoesCommunityHaveUnreadMessages(self.clubId));
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
	self.Selection:Hide();
	
	self.FavoriteIcon:Hide();
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.CircleMask:Hide();
	self.IconRing:Hide();
	self.GuildFinderBackground:Hide();
	self.GuildTabardEmblem:Hide();
	self.GuildTabardBackground:Hide();
	self.GuildTabardBorder:Hide();
	self.UnreadNotificationIcon:Hide();

	self.Icon:SetAtlas("communities-icon-addgroupplus");
	self.Icon:SetSize(32, 32);
	self.Icon:SetPoint("TOPLEFT", 11, -18);
end

function CommunitiesListEntryMixin:SetGuildFinder()
	self.overrideOnClick = function ()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self:GetCommunitiesFrame():SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
		self:GetCommunitiesFrame():SelectClub(nil);
	end;
	
	self.clubId = nil;
	self.Name:SetText(COMMUNITIES_GUILD_FINDER);
	self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	self.Selection:SetShown(self:GetCommunitiesFrame():GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
	
	self.FavoriteIcon:Hide();
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.Icon:SetSize(42, 42);
	self.Icon:SetPoint("TOPLEFT", 8, -15);
	self.CircleMask:Show();
	self.IconRing:Hide();
	self.GuildFinderBackground:Show();
	self.GuildTabardEmblem:Hide();
	self.GuildTabardBackground:Hide();
	self.GuildTabardBorder:Hide();
	self.UnreadNotificationIcon:Hide();

	local factionGroup = UnitFactionGroup("player");
	if factionGroup == "Alliance" then
		self.Icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Alliance");
	else
		self.Icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Horde");
	end
end

function CommunitiesListEntryMixin:GetClubId()
	return self.clubId;
end

function CommunitiesListEntryMixin:IsInvitation()
	return self.isInvitation;
end

function CommunitiesListEntryMixin:GetCommuntiesList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesListEntryMixin:GetCommunitiesFrame()
	return self:GetCommuntiesList():GetCommunitiesFrame();
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
		if not clubInfo or clubInfo.clubType == Enum.ClubType.Guild then
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
		local info = UIDropDownMenu_CreateInfo();
		local parent = self:GetParent();
		for i, clubInfo in ipairs(clubs) do
			info.text = clubInfo.name;
			if CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubInfo.clubId) then
				info.text = info.text.." "..CreateAtlasMarkup("communities-icon-notification", 11, 12);
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