local COMMUNITIES_LIST_EVENTS = {
	"CLUB_ADDED",
	"CLUB_REMOVED",
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
		self:Update();
	elseif event == "CLUB_REMOVED" then
		self:Update();
	elseif event == "CLUB_INVITATION_ADDED_FOR_SELF" then
		self:Update();
	elseif event == "CLUB_INVITATION_REMOVED_FOR_SELF" then
		local invitationId = ...;
		tDeleteItem(self.declinedInvitationIds, invitationId);
		self:Update();
	end
end

function CommunitiesListMixin:GetPotentialClubs()
	local potentialClubs = C_Club.GetInvitationsForSelf();
	
	-- Remove all invites that have been declined.
	for i, declinedInvitationId in ipairs(self.declinedInvitationIds) do
		for j, inviteInfo in ipairs(potentialClubs) do
			if declinedInvitationId == inviteInfo.invitationId then
				table.remove(potentialClubs, j);
				break;
			end
		end
	end
	
	return potentialClubs;
end

function CommunitiesListMixin:Update()
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
		
	local clubs = C_Club.GetSubscribedClubs();
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
		
	self:PredictFavorites(clubs);
	
	table.sort(clubs, function(lhsClub, rhsClub)
		if lhsClub.favoriteTimeStamp ~= nil and rhsClub.favoriteTimeStamp ~= nil then
			return lhsClub.favoriteTimeStamp < rhsClub.favoriteTimeStamp;
		elseif lhsClub.favoriteTimeStamp ~= nil or rhsClub.favoriteTimeStamp ~= nil then
			return lhsClub.favoriteTimeStamp ~= nil;
		elseif lhsClub.joinTime ~= nil and rhsClub.joinTime ~= nil then
			return lhsClub.joinTime > rhsClub.joinTime;
		else
			return lhsClub.joinTime ~= nil;
		end
	end);
	
	local isInGuild = IsInGuild();
	local potentialClubs = self:GetPotentialClubs();
	local totalNumClubs = #potentialClubs + #clubs;
	if not isInGuild then
		totalNumClubs = totalNumClubs + 1;
	end
	
	local height = buttons[1]:GetHeight();
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
			local isInvitation = displayIndex <= #potentialClubs;
			if isInvitation then
				clubInfo = potentialClubs[displayIndex].club;
			else
				displayIndex = displayIndex - #potentialClubs;
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
			else
				button:SetClubInfo(nil);
				button:Hide();
			end
		end
	end
	
	-- We need + 1 for the blank entry at the top of the list.
	local clubsHeight = height * (totalNumClubs + 1);
	local totalHeight = clubsHeight + COMMUNITIES_LIST_INITLAL_TOP_BORDER_OFFSET + COMMUNITIES_LIST_INITLAL_BOTTOM_BORDER_OFFSET;
	HybridScrollFrame_Update(scrollFrame, totalHeight, usedHeight);
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
	self:Update();
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

local function DoesCommunityHaveUnreadMessages(clubId)
	for i, stream in ipairs(C_Club.GetStreams(clubId)) do
		if C_Club.GetStreamViewMarker(clubId, stream.streamId) ~= nil then
			return true;
		end
	end
end

CommunitiesListEntryMixin = {};

function CommunitiesListEntryMixin:SetClubInfo(clubInfo, isInvitation)
	self.TabardBackground:Hide();
	if clubInfo then
		self.Name:SetText(clubInfo.name);
		self.clubId = clubInfo.clubId;
		self.Selection:SetShown(clubInfo.clubId == self:GetCommunitiesFrame():GetSelectedClubId());
		
		self.InvitationIcon:SetShown(isInvitation);
		self.Icon:SetShown(not isInvitation);
		self.CircleMask:SetShown(not isInvitation);
		self.IconRing:SetShown(not isInvitation);
		C_Club.SetAvatarTexture(self.Icon, clubInfo.avatarId, clubInfo.clubType);
		
		self.UnreadNotificationIcon:SetShown(not isInvitation and DoesCommunityHaveUnreadMessages(clubInfo.clubId));
	else
		self.Name:SetText(nil);
		self.clubId = nil;
		self.Selection:Hide();
		self.Icon:SetTexture(nil);
		self.UnreadNotificationIcon:Hide();
		self:Hide();
	end
end

function CommunitiesListEntryMixin:SetGuildFinder()
	self.clubId = nil;
	self.Name:SetText(COMMUNITIES_GUILD_FINDER);
	self.Selection:SetShown(self:GetCommunitiesFrame():GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
	
	self.InvitationIcon:Hide();
	self.Icon:Show();
	self.CircleMask:Show();
	self.IconRing:Hide();
	self.TabardBackground:Show();

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

function CommunitiesListEntryMixin:GetCommuntiesList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesListEntryMixin:GetCommunitiesFrame()
	return self:GetCommuntiesList():GetCommunitiesFrame();
end

function CommunitiesListEntryMixin:OnClick(button)
	if button == "LeftButton" then
		if self.clubId == nil then
			self:GetCommunitiesFrame():SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
			self:GetCommunitiesFrame():SelectClub(nil);
		else
			self:GetCommunitiesFrame():SelectClub(self.clubId);
		end
	elseif button == "RightButton" then
		local communitiesList = self:GetParent():GetParent():GetParent();
		communitiesList:SetSelectedEntryForDropDown(self);
		ToggleDropDownMenu(1, nil, communitiesList.EntryDropDown, self, 0, 0);
	end
end

function CommunitiesDropDown_GetLeaveCommunityButtonInfo(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		local info = UIDropDownMenu_CreateInfo();
		info.text = COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY;
		if clubInfo.clubType == Enum.ClubType.Character then
			info.text = COMMUNITIES_LIST_DROP_DOWN_LEAVE_CHARACTER_COMMUNITY;
		end
		
		local memberInfoForSelf = C_Club.GetMemberInfoForSelf(clubInfo.clubId);
		if #C_Club.GetClubMembers(clubInfo.clubId) == 1 then
			info.func = function()
				StaticPopup_Show("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", nil, nil, clubInfo);
			end
		elseif memberInfoForSelf and memberInfoForSelf.role == Enum.ClubRoleIdentifier.Owner then
			info.func = function()
				UIErrorsFrame:AddMessage(COMMUNITIES_LIST_TRANSFER_OWNERSHIP_FIRST, RED_FONT_COLOR:GetRGBA());
			end
		else
			info.func = function()
				C_Club.LeaveClub(clubInfo.clubId);
			end
		end
		
		info.isNotRadio = true;
		info.notCheckable = true;
		return info;
	end
	
	return nil;
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
		if clubInfo then
			local info = UIDropDownMenu_CreateInfo();
			info.text = COMMUNITIES_LIST_DROP_DOWN_FAVORITE;
			info.func = function()
				communitiesList:SetFavorite(clubInfo.clubId, true);
			end;
			
			if clubInfo.favoriteTimeStamp then
				info.text = COMMUNITIES_LIST_DROP_DOWN_UNFAVORITE;
				info.func = function()
					communitiesList:SetFavorite(clubInfo.clubId, false);
				end;
			end
			
			info.isNotRadio = true;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info, level);
			
			info = CommunitiesDropDown_GetLeaveCommunityButtonInfo(clubInfo.clubId);
			if info then
				UIDropDownMenu_AddButton(info, level);
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
end

CommunitiesListDropDownMenuMixin = {};

function CommunitiesListDropDownMenuMixin:OnShow()
	UIDropDownMenu_Initialize(self, CommunitiesListDropDownMenu_Initialize);
	local communitiesFrame = self:GetCommunitiesFrame();
	UIDropDownMenu_SetSelectedValue(self, communitiesFrame:GetSelectedClubId());
	
	local function CommunitiesClubSelectedCallback(event, clubId)
		if clubId and self:IsVisible() then
			UIDropDownMenu_SetSelectedValue(self, clubId);
		end
	end
	
	self.clubSelectedCallback = CommunitiesClubSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
end

function CommunitiesListDropDownMenuMixin:OnHide()
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.clubSelectedCallback);
end

function CommunitiesListDropDownMenuMixin:GetCommunitiesFrame()
	return self:GetParent();
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
		local communitiesFrame = self:GetCommunitiesFrame();
		for i, clubInfo in ipairs(clubs) do
			info.text = clubInfo.name;
			info.value = clubInfo.clubId;
			info.func = function(button)
				communitiesFrame:SelectClub(button.value);
			end
			UIDropDownMenu_AddButton(info);
		end
		
		UIDropDownMenu_SetSelectedValue(self, communitiesFrame:GetSelectedClubId());
	end
end