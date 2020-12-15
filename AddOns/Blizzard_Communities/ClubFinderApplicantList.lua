local APPLICANT_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
		attribute = "level",
	},

	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 45,
		attribute = "classID",
	},

	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
		attribute = "name",
	},

	[4] = {
		title = CLUB_FINDER_SPEC,
		width = 85,
		attribute = "spec",
	},

	[5] = {
		title = ITEM_LEVEL_ABBR,
		width = 45,
		attribute = "ilvl",
	},

	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 290,
		attribute = "memberNote",
	},
};

local TANK_SORT_VALUE = 4; 
local HEALER_SORT_VALUE = 2; 
local DPS_SORT_VALUE = 1; 

ClubFinderApplicantEntryMixin = { };

function ClubFinderApplicantEntryMixin:OnLoad()
	UIDropDownMenu_Initialize(self.RightClickDropdown, ApplicantRightClickOptionsMenuInitialize, "MENU");
end 

function ClubFinderApplicantEntryMixin:GetApplicantName()
	return self.Info.name;
end 

function ClubFinderApplicantEntryMixin:GetApplicantStatus()
	return self.Info.requestStatus;
end

function ClubFinderApplicantEntryMixin:GetPlayerGUID()
	return self.Info.playerGUID;
end 

function ClubFinderApplicantEntryMixin:GetClubGUID()
	return self.Info.clubFinderGUID;
end

function ClubFinderApplicantEntryMixin:GetServerName()
	local normalizedRealmName = select(7, GetPlayerInfoByGUID(self.Info.playerGUID));
	return normalizedRealmName;
end

function ClubFinderApplicantEntryMixin:GetFullName()
	local serverName = self:GetServerName();
	if (serverName ~= "") then
		serverName = "-"..serverName
	end
	return self:GetApplicantName()..serverName;
end

function ClubFinderApplicantEntryMixin:OnMouseDown(button)
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 100, 0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end 

function ClubFinderApplicantEntryMixin:UpdateMemberInfo(info)
	self.Info = info;
	if	(not info) then
		return;
	end

	local className, classTag = GetClassInfo(info.classID);
	self.ClassName = className; 
	self.ClassColor = CreateColor(GetClassColor(classTag));
	self.Name:SetText(info.name);
	self.Name:SetTextColor(self.ClassColor.r, self.ClassColor.g, self.ClassColor.b);

	self.Level:SetText(info.level);
	self.ItemLevel:SetText(info.ilvl); 
	self.Note:SetText(info.message);

	local isHealer = false; 
	local isDps = false; 
	local isTank = false; 

	self.RoleIcon1:Hide();
	self.RoleIcon2:Hide();
	self.RoleIcon3:Hide(); 

	for _, specID in ipairs(info.specIds) do 
		local role = GetSpecializationRoleByID(specID);
		if(role == "DAMAGER") then
			isDps = true; 
		elseif (role == "HEALER") then 
			isHealer = true; 
		elseif (role == "TANK") then 
			isTank = true; 
		end
	end 
	if(not isHealer and not isDps and not isTank) then 
		self.RoleIcon2:Hide();
		self.RoleIcon1:Hide();
		self.RoleIcon3:Hide();
		self.AllSpec:SetText(NONE);
		self.AllSpec:Show();
	elseif (isHealer and isTank and isDps) then 
		self.RoleIcon1:SetTexCoord(GetTexCoordsForRoleSmallCircle("TANK"));
		self.RoleIcon2:SetTexCoord(GetTexCoordsForRoleSmallCircle("HEALER"));
		self.RoleIcon3:SetTexCoord(GetTexCoordsForRoleSmallCircle("DAMAGER"));

		self.RoleIcon2:Show();
		self.RoleIcon1:Show();
		self.RoleIcon3:Show(); 

		self.AllSpec:Hide();
	else 
		self.AllSpec:Hide();

		local icon1Role;
		if isTank then
		  icon1Role = "TANK";
		elseif isHealer then
		  icon1Role = "HEALER";
		elseif isDps then  
		  icon1Role = "DAMAGER";
		end

		local icon2Role;
		if isHealer and isTank then
		  icon2Role= "HEALER";
		elseif isDps and (isTank or isHealer) then
		  icon2Role= "DAMAGER";
		end

		if (icon1Role) then
			self.RoleIcon1:SetTexCoord(GetTexCoordsForRoleSmallCircle(icon1Role));
			self.RoleIcon1:Show();
		end

		if (icon2Role) then
			self.RoleIcon2:SetTexCoord(GetTexCoordsForRoleSmallCircle(icon2Role));
			self.RoleIcon2:Show();
		end
	end
	if (classTag) then 
		self.Class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classTag]));
	end
	local isPendingList = self:GetParent():GetParent():GetParent().isPendingList;
	if (isPendingList) then 
		self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());

		if (info.requestStatus == Enum.PlayerClubRequestStatus.Pending) then 
			self.RequestStatus:SetText(CLUB_FINDER_PENDING);
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.Approved) then
			self.RequestStatus:SetText(CLUB_FINDER_APPROVED);
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.AutoApproved) then 
			self.RequestStatus:SetText(CLUB_FINDER_APPROVED);
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.Joined) then 
			self.RequestStatus:SetText(CLUB_FINDER_JOINED);
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.JoinedAnother) then 
			self.RequestStatus:SetText(CLUB_FINDER_JOINED_ANOTHER);
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.Canceled) then 
			self.RequestStatus:SetText(CLUB_FINDER_CANCELED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		elseif (info.requestStatus == Enum.PlayerClubRequestStatus.Declined) then 
			self.RequestStatus:SetText(CLUB_FINDER_DECLINED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		end
	end 
	self.CancelInvitationButton:SetShown(not isPendingList); 
	self.InviteButton:SetShown(not isPendingList);
	self.RequestStatus:SetShown(isPendingList); 

	if (self.InviteButton:IsShown() and self:GetParent():GetParent():GetParent().clubSizeMaxHit) then 
		self.InviteButton:Disable(); 
		self.InviteButton.Text:SetFontObject(GameFontDisableSmall);
	else 
		self.InviteButton:Enable(); 
		self.InviteButton.Text:SetFontObject(GameFontHighlightSmall);
	end 

end 

function ClubFinderApplicantEntryMixin:OnEnter()
	if (not self.ClassName) then
		return; 
	end 

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddColoredLine(GameTooltip, self.Info.name, self.ClassColor);
	GameTooltip_AddColoredLine(GameTooltip, UNIT_TYPE_LEVEL_TEMPLATE:format(self.Info.level, self.ClassName), HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT:format(self.Info.ilvl));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_SPECIALIZATIONS);

	if(#self.Info.specIds == 0) then 
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS, RED_FONT_COLOR);
	else 
		for _, specID in ipairs(self.Info.specIds) do 
			GameTooltip_AddNormalLine(GameTooltip, CommunitiesUtil.GetRoleSpecClassLine(self.Info.classID, specID));
		end
	end
	if(self.Info.message ~= "") then 
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip,	CLUB_FINDER_CLUB_DESCRIPTION:format(self.Info.message), GRAY_FONT_COLOR, true);
	end 
	GameTooltip:Show();

end

function ClubFinderApplicantEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function ApplicantRightClickOptionsMenuInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		info.text = CLUB_FINDER_REPORT_NAME;
		info.notCheckable = true;
		info.func = function()  ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.ApplicantsName, self:GetParent():GetClubGUID(), self:GetParent():GetPlayerGUID(), self:GetParent().Info); end
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_REPORT_JOIN_NOTE;
		info.notCheckable = true;
		info.func = function() ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.JoinNote, self:GetParent():GetClubGUID(), self:GetParent():GetPlayerGUID(), self:GetParent().Info); end
		UIDropDownMenu_AddButton(info, level);
	end
	
	if (level == 1) then 
		info.text = self:GetParent():GetApplicantName();
		info.isTitle = true; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level);
	
		if(self:GetParent():GetApplicantStatus() == Enum.PlayerClubRequestStatus.Declined) then 
			info.text = CLUB_FINDER_INVITE_APPLICANT_REDO; 
			info.colorCode = GREEN_FONT_COLOR_CODE; 
			info.isTitle = false; 
			info.notCheckable = true; 
			info.disabled = nil; 
			info.func = function() ClubFinderCancelOrAcceptApplicant(self, true, true); end
			UIDropDownMenu_AddButton(info, level);
		end	

		info.text = WHISPER;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.isTitle = false; 
		info.notCheckable = true; 
		info.disabled = nil;
		info.func = function () ChatFrame_SendTell(self:GetParent():GetFullName()); end
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_REPORT_FOR; 
		info.isTitle = false; 
		info.disabled = nil;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.notCheckable = true; 
		info.hasArrow = true
		info.value = 1; 
		UIDropDownMenu_AddButton(info, level);
	end
end

ClubFinderApplicantListMixin = { };

function ClubFinderApplicantListMixin:OnLoad()
	self.ColumnDisplay:LayoutColumns(APPLICANT_COLUMN_INFO);
	self.ColumnDisplay:Show();

	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "ClubFinderApplicantEntryTemplate", 0, 0);
	HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, true);
	self.ListScrollFrame.update = function() self:RefreshLayout() end;
end

function ClubFinderApplicantListMixin:OnShow()
	self:ResetColumnSort();
	CommunitiesFrameInset:Show(); 
end 

function ClubFinderApplicantListMixin:OnHide()
end 

function ClubFinderApplicantListMixin:ResetColumnSort()
	self.reverseActiveColumnSort = nil;
	self.activeColumnSortIndex = nil; 
end

function ClubFinderApplicantListColumnDisplay_OnClick(self, columnIndex)
	self:GetParent():SortByColumnIndex(columnIndex);
end

function ClubFinderApplicantSortFunction(shouldReverse, firstValue, secondValue)
	if (shouldReverse) then 
		return firstValue < secondValue
	else 
		return firstValue > secondValue
	end
end 

function ClubFinderApplicantSpecSortReturnSpecValue(specIds)
	local isDps, isHealer, isTank = false; 
	local specReturnValue = 0; 
	for _, specID in ipairs(specIds) do 
		local role = GetSpecializationRoleByID(specID);
		if(role == "DAMAGER") then
			isDps = true; 
		elseif (role == "HEALER") then 
			isHealer = true; 
		elseif (role == "TANK") then 
			isTank = true; 
		end
	end 

	if (isTank) then 
		specReturnValue = specReturnValue + TANK_SORT_VALUE; 
	end 
	if (isHealer) then 
		specReturnValue = specReturnValue + HEALER_SORT_VALUE; 
	end 
	if (isDps) then 
		specReturnValue = specReturnValue + DPS_SORT_VALUE; 
	end 

	return specReturnValue; 
end 

function ClubFinderApplicantSortFunctionBySpecIds(shouldReverse, firstSpecIds, secondSpecIds)
	local firstValue = ClubFinderApplicantSpecSortReturnSpecValue(firstSpecIds);
	local secondValue = ClubFinderApplicantSpecSortReturnSpecValue(secondSpecIds);

	if (shouldReverse) then 
		return firstValue < secondValue
	else 
		return firstValue > secondValue
	end
end 

function ClubFinderApplicantListMixin:SortByColumnIndex(columnIndex)
	local sortAttribute = APPLICANT_COLUMN_INFO[columnIndex] and APPLICANT_COLUMN_INFO[columnIndex].attribute or nil;
	if sortAttribute == nil or not self.ApplicantInfoList then
		return;
	end

	self.reverseActiveColumnSort = columnIndex ~= self.activeColumnSortIndex and false or not self.reverseActiveColumnSort;

	self.activeColumnSortIndex = columnIndex;

	if sortAttribute == "name" then
		table.sort(self.ApplicantInfoList, function(a, b) 
			ClubFinderApplicantSortFunction(self.reverseActiveColumnSort, a.name:upper(), b.name:upper()); 
		end);
	elseif sortAttribute == "level" then
		table.sort(self.ApplicantInfoList, function(a, b) 
			return ClubFinderApplicantSortFunction(self.reverseActiveColumnSort, a.level, b.level); 
		end);
	elseif sortAttribute == "memberNote" then
		table.sort(self.ApplicantInfoList, function(a, b) 
			return ClubFinderApplicantSortFunction(self.reverseActiveColumnSort, a.message:upper(), b.message:upper()); 
		end);
	elseif sortAttribute == "classID" then 
		table.sort(self.ApplicantInfoList, function(a, b) 
			return ClubFinderApplicantSortFunction(self.reverseActiveColumnSort, a.classID, b.classID); 
		end);
	elseif sortAttribute == "ilvl" then
		table.sort(self.ApplicantInfoList, function(a, b) 
			return ClubFinderApplicantSortFunction(self.reverseActiveColumnSort, a.ilvl, b.ilvl); 
		end);
	elseif sortAttribute == "spec" then 
		table.sort(self.ApplicantInfoList, function(a, b) 
			return ClubFinderApplicantSortFunctionBySpecIds(self.reverseActiveColumnSort, a.specIds, b.specIds);
		end);
	end
	self:RefreshLayout();
end

function ClubFinderApplicantListMixin:GuildMemberUpdate()
	local communitiesFrame = self:GetParent();
	local clubId = communitiesFrame:GetSelectedClubId();
	if (not clubId) then 
		return;
	end

	local clubInfo = C_Club.GetClubInfo(clubId);

	if clubInfo and clubInfo.clubType == Enum.ClubType.Guild and (IsGuildLeader() or C_GuildInfo.IsGuildOfficer()) then
		if not communitiesFrame:IsShowingApplicantList() then 
			C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Guild); 
			if (not self.newApplicantListRequest) then 
				self:SetApplicantRefreshTicker(Enum.ClubFinderRequestType.Guild);
			end	
		end
	end
end 

function ClubFinderApplicantListMixin:CommunitiesMemberUpdate()
	local communitiesFrame = self:GetParent();

	local clubId = communitiesFrame:GetSelectedClubId();
	if (not clubId) then 
		return;
	end

	local clubInfo = C_Club.GetClubInfo(clubId);


	if clubInfo and clubInfo.clubType == Enum.ClubType.Character then
		local selectedClubId = clubInfo.clubId;
		local myMemberInfo = C_Club.GetMemberInfoForSelf(selectedClubId);
		local hasFinderPermissions = myMemberInfo.role and myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader;
		if ( not communitiesFrame:IsShowingApplicantList() and hasFinderPermissions) then 
			C_ClubFinder.RequestApplicantList(Enum.ClubFinderRequestType.Community); 
			if (not self.newApplicantListRequest) then 
				self:SetApplicantRefreshTicker(Enum.ClubFinderRequestType.Community);
			end
		elseif communitiesFrame:IsShowingApplicantList() and not hasFinderPermissions then --When we were demoted and we are viewing the applicant list. 
			communitiesFrame.CommunityMemberListDropDownMenu:ResetDisplayMode();
			self:CancelRefreshTicker();
		end	
	end 
end 

function ClubFinderApplicantListMixin:SetApplicantRefreshTicker(clubType) 
	if (self.newApplicantListRequest) then 
		self.newApplicantListRequest:Cancel();
	end

	self.newApplicantListRequest = C_Timer.NewTicker(20, function() 
		C_ClubFinder.RequestApplicantList(clubType); 
	end);
end 

function ClubFinderApplicantListMixin:CancelRefreshTicker() 
	if (self.newApplicantListRequest) then 
		self.newApplicantListRequest:Cancel();
	end
end 

function ClubFinderApplicantListMixin:BuildList()
	local communityFrame = self:GetParent();
	local clubId = communityFrame:GetSelectedClubId();
	if (not clubId) then 
		return;
	end
	local isAppliantListDisplayMode = communityFrame:IsShowingApplicantList();

	local clubInfo = C_Club.GetClubInfo(clubId);

	if (not clubInfo) then 
		return; 
	end 

	-- Worst case we want to not allow them to invite, cause something might be broken.
	self.clubSizeMaxHit = not clubInfo.memberCount or clubInfo.memberCount >= C_Club.GetClubCapacity();

	local pendingList =  C_ClubFinder.ReturnPendingClubApplicantList(clubId);
	local applicantList = C_ClubFinder.ReturnClubApplicantList(clubId);

	if (self.isPendingList) then 
		self.ApplicantInfoList = pendingList;
	else 
		self.ApplicantInfoList = applicantList;
	end 


	if(clubInfo.clubType == Enum.ClubType.Guild) then 
		local guildMemberDropdown = communityFrame.GuildMemberListDropDownMenu; 
		guildMemberDropdown.hasPendingApplicants = false;
		guildMemberDropdown.hasApplicants = false; 
		guildMemberDropdown.shouldResetDropdown = false;

		if(pendingList and #pendingList > 0) then 
			guildMemberDropdown.hasPendingApplicants = true; 
		end 
		if(applicantList and #applicantList > 0) then 
			guildMemberDropdown.hasApplicants = true; 
		else 
			guildMemberDropdown.shouldResetDropdown = true; 
			if(isAppliantListDisplayMode and not self.isPendingList) then 
				guildMemberDropdown:ResetDisplayMode();
			end 
		end 
	elseif(clubInfo.clubType == Enum.ClubType.Character) then 
		local communityMemberDropdown = communityFrame.CommunityMemberListDropDownMenu; 
		communityMemberDropdown.hasPendingApplicants = false;
		communityMemberDropdown.hasApplicants = false; 
		communityMemberDropdown.shouldResetDropdown = false;

		if(pendingList and #pendingList > 0) then 
			communityMemberDropdown.hasPendingApplicants = true; 
		end 
		if(applicantList and #applicantList > 0) then 
			communityMemberDropdown.hasApplicants = true; 
		else 
			communityMemberDropdown.shouldResetDropdown = true; 
			if(isAppliantListDisplayMode and not self.isPendingList) then 
				communityMemberDropdown:ResetDisplayMode();
			end 
		end 
	end 

	if (not self.ApplicantInfoList or #self.ApplicantInfoList == 0 and isAppliantListDisplayMode) then 
		communityFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER);
	else 
		self:RefreshLayout();
	end
end 

function ClubFinderApplicantListMixin:RefreshLayout()
	local scrollFrame = self.ListScrollFrame;
	if (not self.ApplicantInfoList or #self.ApplicantInfoList == 0) then 
		return; 
	end 

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local showingCards = 0; 
	local index; 

	scrollFrame.scrollBar:Show();
	scrollFrame:Show();

	for i = 1, #scrollFrame.buttons do 
		index = offset + i; 
		local applicantInfo = self.ApplicantInfoList[index];
		if (applicantInfo) then 
			scrollFrame.buttons[i]:UpdateMemberInfo(applicantInfo); 
			scrollFrame.buttons[i]:Show(); 
			if (scrollFrame.buttons[i]:IsVisible() and scrollFrame.buttons[i]:IsMouseOver()) then 
				scrollFrame.buttons[i]:OnEnter(); 
			else 
				scrollFrame.buttons[i]:OnLeave();
			end 
			showingCards = showingCards + 1;
		else 
			scrollFrame.buttons[i]:Hide();
		end 
	end 

	local displayedHeight = showingCards * 20; 
	local totalHeight = #self.ApplicantInfoList * 20; 

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end 

ClubFinderApplicantInviteButtonMixin = { }; 
function ClubFinderApplicantInviteButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	if (self:IsEnabled()) then 
		GameTooltip:SetText(INVITE);
	else 
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_MAX_MEMBER_COUNT_HIT, RED_FONT_COLOR, true);
	end
	GameTooltip:Show();
end 

function ClubFinderApplicantInviteButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function ClubFinderCancelOrAcceptApplicant(self, shouldInvite, forceAccept)
	local communityFrame = self:GetParent():GetParent():GetParent():GetParent():GetParent();
	local clubId = communityFrame:GetSelectedClubId();
	if (clubId) then 
		local clubInfo = C_Club.GetClubInfo(clubId);
		if (clubInfo)  then 
			local applicantType;

			if(clubInfo.clubType == Enum.ClubType.Guild) then
				applicantType = Enum.ClubFinderRequestType.Guild
			elseif(clubInfo.clubType == Enum.ClubType.Character) then
				applicantType = Enum.ClubFinderRequestType.Community
			end

			if(applicantType) then 
				C_ClubFinder.RespondToApplicant(self:GetParent().Info.clubFinderGUID, self:GetParent().Info.playerGUID, shouldInvite, applicantType, self:GetParent().Info.name, forceAccept);
			end
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end 

function ClubFinderApplicantInviteButtonMixin:OnClick() 
	ClubFinderCancelOrAcceptApplicant(self, true, false);
end 

ClubFinderApplicantCancelButtonMixin = { }; 
function ClubFinderApplicantCancelButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(DECLINE);
	GameTooltip:Show();
end 

function ClubFinderApplicantCancelButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function ClubFinderApplicantCancelButtonMixin:OnClick() 
	ClubFinderCancelOrAcceptApplicant(self, false, false);
end 