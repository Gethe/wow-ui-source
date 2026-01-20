HousingBulletinBoardFrameMixin = {}

BULLETIN_BOARD_SHOWING_EVENTS = {
    "NEIGHBORHOOD_INFO_UPDATED",
};

function HousingBulletinBoardFrameMixin:OnEvent(event, ...)
    if event == "NEIGHBORHOOD_INFO_UPDATED" then
        local neighborhoodInfo = ...;
        self:OnNeighborhoodInfoUpdated(neighborhoodInfo);
    end
end

function HousingBulletinBoardFrameMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, BULLETIN_BOARD_SHOWING_EVENTS);
    self.GearDropdown:Hide(); --Wait to show settings until we have neighborhood info
    C_HousingNeighborhood.RequestNeighborhoodInfo();
    self.ResidentsTab:Show();
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_OPEN);
end

function HousingBulletinBoardFrameMixin:OnHide()
    C_HousingNeighborhood.OnBulletinBoardClosed();
    FrameUtil.UnregisterFrameForEvents(self, BULLETIN_BOARD_SHOWING_EVENTS);
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_CLOSE);
end

function HousingBulletinBoardFrameMixin:OnNeighborhoodInfoUpdated(neighborhoodInfo)
	self.GearDropdown:Show();
	self.neighborhoodName = neighborhoodInfo.neighborhoodName;
	self.neighborhoodOwnerType = neighborhoodInfo.neighborhoodOwnerType;
	self.ResidentsTab:OnNeighborhoodInfoUpdated(neighborhoodInfo);

	local bgAtlasPrefix = "housing-dashboard-bg-";
	local bgAtlasSuffix = C_HousingNeighborhood.GetCurrentNeighborhoodTextureSuffix();
	if bgAtlasSuffix then
		self.Background:SetAtlas(bgAtlasPrefix .. bgAtlasSuffix);
	end

	self.GearDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateButton(HOUSING_BULLETINBOARD_REPORT, GenerateClosure(self.ReportNeighborhood, self));
	end);
end

function HousingBulletinBoardFrameMixin:ReportNeighborhood()
	local reportInfo = ReportInfo:CreateNeighborhoodReportInfo(Enum.ReportType.Neighborhood);
	ReportFrame:InitiateReport(reportInfo, self.neighborhoodName); 
end

function HousingBulletinBoardFrameMixin:GetRosterFrame()
	return self.ResidentsTab;
end

--///////////////////////////////////////////////////////////////////////
BulletinBoardColumnDisplayMixin = CreateFromMixins(ColumnDisplayMixin);

--overridden from ColumnDisplayMixin
function BulletinBoardColumnDisplayMixin:OnLoad()
	self.columnHeaders = CreateFramePool("BUTTON", self, "BulletinBoardColumnDisplayButtonTemplate");
end

--//////////////////////////////////////////////////////////////////////
NeighborhoodRosterMixin = {};

local NEIGHBORHOOD_ROSTER_COLUMN_INFO = {
	[1] = {
		title = NEIGHBORHOOD_ROSTER_COLUMN_TITLE_NAME,
		width = 275,
		attribute = "name",
	},

	[2] = {
		title = NEIGHBORHOOD_ROSTER_COLUMN_TITLE_STATUS,
		width = 100,
		attribute = "status",
	},

	[3] = {
		title = NEIGHBORHOOD_ROSTER_COLUMN_TITLE_PLOT,
		width = 70,
		attribute = "plot",
	},
};

local EXTRA_GUILD_COLUMN_SUBDIVISION = {
    title = NEIGHBORHOOD_ROSTER_COLUMN_TITLE_SUBDIVISION,
    width = 100,
    attribute = "subdivision",
};

local BULLETIN_BOARD_ROSTER_SHOWING_EVENTS = {
	"UPDATE_BULLETIN_BOARD_ROSTER",
	"UPDATE_BULLETIN_BOARD_ROSTER_STATUSES",
	"UPDATE_BULLETIN_BOARD_MEMBER_TYPE"
};
function NeighborhoodRosterMixin:OnLoad()
    local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("NeighborhoodRosterEntryTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	self.InviteResidentButton:SetScript("OnClick", GenerateClosure(self.InviteResidentClicked, self));
	self.InviteResidentButton:SetText(HOUSING_BULLETINBOARD_INVITE_RESIDENT);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function NeighborhoodRosterMixin:OnEvent(event, ...)
	if event == "UPDATE_BULLETIN_BOARD_ROSTER" then
		local neighborhoodInfo, memberList = ...;
		self:OnNeighborhoodInfoUpdated(neighborhoodInfo);
		self:SetAlphabeticalSortedMemberList(memberList);
		self.LoadingSpinner:Hide();
	elseif event == "UPDATE_BULLETIN_BOARD_ROSTER_STATUSES" then
		local updatedMemberList = ...;
		self:UpdateRosterMembers(updatedMemberList);
	elseif event == "UPDATE_BULLETIN_BOARD_MEMBER_TYPE" then
		local member, type = ...;
		self:UpdateRosterMember(member, type);
	end
end

function NeighborhoodRosterMixin:UpdateRosterMembers(updatedMembers)
	if updatedMembers and #updatedMembers > 0 then
		for index, newMemberInfo in ipairs(updatedMembers) do
			--Iterate over cached member lists and update matches based on guid
			if self.alphabeticalMemberList then
				for alphaNumIndex, oldMemberInfo in ipairs(self.alphabeticalMemberList) do
					if newMemberInfo.playerGUID == oldMemberInfo.playerGUID then
						oldMemberInfo.residentType = newMemberInfo.residentType;
						oldMemberInfo.isOnline = newMemberInfo.isOnline;
					end
				end
			end
			if self.sortedMemberList then
				for sortedIndex, sortedMemberInfo in ipairs(self.sortedMemberList) do
					if newMemberInfo.playerGUID == sortedMemberInfo.playerGUID then
						sortedMemberInfo.residentType = newMemberInfo.residentType;
						sortedMemberInfo.isOnline = newMemberInfo.isOnline;
					end
				end
			end
		end
		self:UpdateRoster(self.sortedMemberList);
	end
end

function NeighborhoodRosterMixin:UpdateRosterMember(member, type)
	if self.alphabeticalMemberList then
		for _, memberInfo in ipairs(self.alphabeticalMemberList) do
			if memberInfo.playerGUID == member then
				memberInfo.residentType = type;
			end
		end
	end
	if self.sortedMemberList then
		for _, memberInfo in ipairs(self.sortedMemberList) do
			if memberInfo.playerGUID == member then
				memberInfo.residentType = type;
			end
		end
	end

	self.ScrollBox:ForEachFrame(function(frame, elementData)
		if frame.info.playerGUID == member then
			frame.info.residentType = type;
			frame:UpdateRank();
		end
	end);
end

function NeighborhoodRosterMixin:ShouldShowSubdivision()
    --Only private guild neighborhoods have subdivisions
    return self.neighborhoodOwnerType == Enum.NeighborhoodOwnerType.Guild;
end

function NeighborhoodRosterMixin:SetAlphabeticalSortedMemberList(memberList)
	if self:ShouldShowSubdivision() then
		--When an extra column is specified, the third argument can be used to set a custom x offset from the right side of the column display (default -28)
		self.ColumnDisplay:LayoutColumns(NEIGHBORHOOD_ROSTER_COLUMN_INFO, EXTRA_GUILD_COLUMN_SUBDIVISION, 0);
	else
		self.ColumnDisplay:LayoutColumns(NEIGHBORHOOD_ROSTER_COLUMN_INFO);
	end
	self.ColumnDisplay:Show();
	self.columnInfo = NEIGHBORHOOD_ROSTER_COLUMN_INFO;
	self.currentSortAttribute = self.columnInfo[1].attribute;
	self.reverseActiveColumnSort = false;

	self.alphabeticalMemberList = memberList;
	self:CopyAlphabeticalMemberList();
	
	self:UpdateRoster(self.alphabeticalMemberList);
end

function NeighborhoodRosterMixin:CopyAlphabeticalMemberList()
    self.sortedMemberList = {};
    for k,v in pairs(self.alphabeticalMemberList) do
        self.sortedMemberList[k] = v;
    end
end

function NeighborhoodRosterMixin:UpdateRoster(memberList)
    local dataProvider = CreateDataProvider();

	if memberList and #memberList > 0 then
		for index, memberInfo in ipairs(memberList) do
			dataProvider:Insert(memberInfo);
		end
	end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function HousingBulletinBoardRosterColumnDisplay_OnClick(self, columnIndex)
	HousingBulletinBoardFrame.ResidentsTab:SortByColumnIndex(columnIndex);
end

function NeighborhoodRosterMixin:SortByColumnIndex(columnIndex)
    local newSortAttribute = columnIndex <= #self.columnInfo and self.columnInfo[columnIndex].attribute or nil;
    if columnIndex > #self.columnInfo then
		newSortAttribute = EXTRA_GUILD_COLUMN_SUBDIVISION.attribute;
	end
    if self.currentSortAttribute == newSortAttribute then
        self.reverseActiveColumnSort = not self.reverseActiveColumnSort;
    else
        self.reverseActiveColumnSort = false;
    end
    self.currentSortAttribute = newSortAttribute;

    if self.currentSortAttribute == "name" then
        self:CopyAlphabeticalMemberList();
        if self.reverseActiveColumnSort then
			-- Reverse the member list.
			local memberListSize = #self.sortedMemberList;
			for i = 1, memberListSize / 2 do
				local reverseIndex = (memberListSize - i) + 1;
				local reverseEntry = self.sortedMemberList[reverseIndex];
				self.sortedMemberList[reverseIndex] = self.sortedMemberList[i];
				self.sortedMemberList[i] = reverseEntry;
			end
		end
        self:UpdateRoster(self.sortedMemberList);
    elseif self.currentSortAttribute == "status" then
        table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
            local lhsSortScore = lhsMemberInfo.isOnline and 1 or 0;
            local rhsSortScore = rhsMemberInfo.isOnline and 1 or 0;
			return lhsSortScore > rhsSortScore;
		end);
        self:UpdateRoster(self.sortedMemberList);
    elseif self.currentSortAttribute == "plot" then
        table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
			local lhsSortScore = lhsMemberInfo.plotID;
			local rhsSortScore = rhsMemberInfo.plotID; 
			return lhsSortScore < rhsSortScore;
		end);
        self:UpdateRoster(self.sortedMemberList);
    elseif self.currentSortAttribute == "subdivision" then
        table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
			local lhsSortScore = lhsMemberInfo.subdivision or 0;
			local rhsSortScore = rhsMemberInfo.subdivision or 0; 
			return lhsSortScore < rhsSortScore;
		end);
        self:UpdateRoster(self.sortedMemberList);
    end
end

function NeighborhoodRosterMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, BULLETIN_BOARD_ROSTER_SHOWING_EVENTS);
    self:UpdateRoster(nil);
    self.ColumnDisplay:LayoutColumns({});
    self.LoadingSpinner:Show();
    C_HousingNeighborhood.RequestNeighborhoodRoster();
end

function NeighborhoodRosterMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, BULLETIN_BOARD_ROSTER_SHOWING_EVENTS);
	HideUIPanel(HousingInviteResidentFrame);
end

function NeighborhoodRosterMixin:OnNeighborhoodInfoUpdated(neighborhoodInfo)
    self.neighborhoodName = neighborhoodInfo.neighborhoodName;
    self.neighborhoodOwnerType = neighborhoodInfo.neighborhoodOwnerType;
    self.NeighborhoodNameText:SetText(self.neighborhoodName);

	if self.neighborhoodOwnerType == Enum.NeighborhoodOwnerType.Charter and C_HousingNeighborhood.IsNeighborhoodManager() then
		self.InviteResidentButton:Show();
	else
		self.InviteResidentButton:Hide();
	end
end

function NeighborhoodRosterMixin:InviteResidentClicked()
    ShowUIPanel(HousingInviteResidentFrame);
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_BUTTONS);
end

StaticPopupDialogs["HOUSING_BULLETIN_EVICT_CONFIRMATION"] = {
	text = HOUSING_BULLETINBOARD_EVICT_CONFIRMATION_TEXT,
	button1 = HOUSING_BULLETINBOARD_EVICT_CONFIRMATION_CONFIRM,
	button2 = HOUSING_BULLETINBOARD_EVICT_CONFIRMATION_CANCEL,
	OnAccept = function(self)
		HousingBulletinBoardFrame:GetRosterFrame():ConfirmEviction();
	end,
	hideOnEscape = 1
};

function NeighborhoodRosterMixin:TryEvictResident(plotID)
	self.pendingEvictionPlotID = plotID;
	StaticPopup_Show("HOUSING_BULLETIN_EVICT_CONFIRMATION");
end

function NeighborhoodRosterMixin:ConfirmEviction()
	C_HousingNeighborhood.TryEvictPlayer(self.pendingEvictionPlotID);
end

StaticPopupDialogs["HOUSING_BULLETIN_ADD_MANAGER_CONFIRMATION"] = {
	text = HOUSING_ADD_NEIGHBORHOOD_MANAGER_CONFIRMATION,
	button1 = HOUSING_BULLETIN_CONTEXT_CONFIRM,
	button2 = HOUSING_BULLETIN_CONTEXT_CANCEL,
	OnAccept = function(self)
		HousingBulletinBoardFrame:GetRosterFrame():ConfirmAddManager();
	end,
	hideOnEscape = 1
};

function NeighborhoodRosterMixin:TryAddManager(playerGUID, playerName)
	self.pendingManagerGUID = playerGUID;
	StaticPopup_Show("HOUSING_BULLETIN_ADD_MANAGER_CONFIRMATION", playerName);
end

function NeighborhoodRosterMixin:ConfirmAddManager()
	C_HousingNeighborhood.PromoteToManager(self.pendingManagerGUID);
end

StaticPopupDialogs["HOUSING_BULLETIN_REMOVE_MANAGER_CONFIRMATION"] = {
	text = HOUSING_REMOVE_NEIGHBORHOOD_MANAGER_CONFIRMATION,
	button1 = HOUSING_BULLETIN_CONTEXT_CONFIRM,
	button2 = HOUSING_BULLETIN_CONTEXT_CANCEL,
	OnAccept = function(self)
		HousingBulletinBoardFrame:GetRosterFrame():ConfirmRemoveManager();
	end,
	hideOnEscape = 1
};

function NeighborhoodRosterMixin:TryRemoveManager(playerGUID, playerName)
	self.pendingManagerGUID = playerGUID;
	StaticPopup_Show("HOUSING_BULLETIN_REMOVE_MANAGER_CONFIRMATION", playerName);
end

function NeighborhoodRosterMixin:ConfirmRemoveManager()
	C_HousingNeighborhood.DemoteToResident(self.pendingManagerGUID);
end

StaticPopupDialogs["HOUSING_BULLETIN_TRANSFER_OWNER_CONFIRMATION"] = {
	text = HOUSING_BULLETIN_TRANSFER_OWNERSHIP_DIALOG,
	button1 = HOUSING_BULLETIN_CONTEXT_CONFIRM,
	button2 = HOUSING_BULLETIN_CONTEXT_CANCEL,
	OnAccept = function(self)
		HousingBulletinBoardFrame:GetRosterFrame():ConfirmTransferOwnership();
	end,
	hideOnEscape = 1
};

function NeighborhoodRosterMixin:TryTransferOwnership(playerGUID, playerName)
	self.pendingOwnerGUID = playerGUID;
	StaticPopup_Show("HOUSING_BULLETIN_TRANSFER_OWNER_CONFIRMATION", playerName);
end

function NeighborhoodRosterMixin:ConfirmTransferOwnership()
	C_HousingNeighborhood.TransferNeighborhoodOwnership(self.pendingOwnerGUID);
end

--//////////////////////////////////////////////////////////////////////
NeighborhoodRosterEntryMixin = {};

--TODO: set up events to update a single entry rather than the entire neighborhood roster for evicting / adding managers
NEIGHBORHOOD_ROSTER_ENTRY_EVENTS = {

};

function NeighborhoodRosterEntryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, NEIGHBORHOOD_ROSTER_ENTRY_EVENTS);
end

function NeighborhoodRosterEntryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, NEIGHBORHOOD_ROSTER_ENTRY_EVENTS);
end

function NeighborhoodRosterEntryMixin:OnEvent(event, ...)

end

function NeighborhoodRosterEntryMixin:OnClick(button)
	if button == "RightButton" then
		local isPrivateCharterNeighborhood = HousingBulletinBoardFrame:GetRosterFrame().neighborhoodOwnerType == Enum.NeighborhoodOwnerType.Charter;
		local contextData =
		{
			guid = self.info.playerGUID,
			name = self.info.residentName,
			plotID = self.info.plotID,
			subdivision = self.info.subdivision,
			targetResidentType = self.info.residentType,
			playerIsOwner = C_HousingNeighborhood.IsNeighborhoodOwner(),
			playerIsManager = C_HousingNeighborhood.IsNeighborhoodManager(),
			canBeManaged = isPrivateCharterNeighborhood,
		};
		UnitPopup_OpenMenu("NEIGHBORHOOD_ROSTER", contextData);
	end
end

function NeighborhoodRosterEntryMixin:Init(info)
    self.info = info;
    self.Plot:SetText(string.format(NEIGHBORHOOD_ROSTER_COLUMN_PLOT_FORMAT, info.plotID));
    self.NameFrame.Name:SetText(info.residentName);
    if HousingBulletinBoardFrame.ResidentsTab:ShouldShowSubdivision() then
        self.Subdivision:Show();
        self.Subdivision:SetText(string.format("%d", info.subdivision));
    else
        self.Subdivision:Hide();
    end
    if info.isOnline then
        self.Status:SetText(NEIGHBORHOOD_ROSTER_COLUMN_STATUS_ONLINE);
        self.Status:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.NameFrame.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Plot:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
    else
        self.Status:SetText(NEIGHBORHOOD_ROSTER_COLUMN_STATUS_OFFLINE);
        self.Status:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Plot:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
    end
	local index = self:GetOrderIndex();
	--alternate between light and dark button textures
	if index % 2 == 0 then
		self.NormalTexture:SetAtlas("housing-bulletinboard-list-item-bg-dark");
	else
		self.NormalTexture:SetAtlas("housing-bulletinboard-list-item-bg-light");
	end
    self:UpdateRank();
    self:UpdateNameFrame();
end

function NeighborhoodRosterEntryMixin:UpdateRank()
    self.NameFrame.RankIcon:Show();
    if self.info.residentType == Enum.ResidentType.Owner then
        self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
    elseif self.info.residentType == Enum.ResidentType.Manager then
        self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
    else
        self.NameFrame.RankIcon:Hide();
    end
end

function NeighborhoodRosterEntryMixin:UpdateNameFrame()
	local nameFrame = self.NameFrame;

	local frameWidth = 275;
	local iconsWidth = 0;
	local nameOffset = 0;

	local presenceShown = nameFrame.PresenceIcon:IsShown();

	nameFrame.Name:ClearAllPoints();
	if presenceShown then
		iconsWidth = iconsWidth + 20;

		nameFrame.Name:SetPoint("LEFT", nameFrame.PresenceIcon, "RIGHT");
		nameOffset = nameFrame.PresenceIcon:GetWidth();
	else
		nameFrame.Name:SetPoint("LEFT", nameFrame, "LEFT", 0, 0);
	end

	if nameFrame.RankIcon:IsShown() then
		iconsWidth = iconsWidth + 25;
	end

	local nameWidth = frameWidth - iconsWidth;
	nameFrame.Name:SetWidth(nameWidth);

	nameFrame:ClearAllPoints();
	nameFrame:SetPoint("LEFT", -1, 0);
	nameFrame:SetWidth(frameWidth);

	local nameStringWidth = nameFrame.Name:GetStringWidth();
	local rankOffset = (nameFrame.Name:IsTruncated() and nameWidth or nameStringWidth) + nameOffset;
	nameFrame.RankIcon:ClearAllPoints();
	nameFrame.RankIcon:SetPoint("LEFT", nameFrame, "LEFT", rankOffset, 0);
end

--//////////////////////////////////////////////////////////////////////
HousingInviteResidentFrameMixin = {}

local NeighborhoodInviteErrorTypeStrings = {
	[Enum.NeighborhoodInviteResult.DbError] = HOUSING_NEIGHBORHOOD_INVITE_ERR_GENERIC,
	[Enum.NeighborhoodInviteResult.RpcFailure] = HOUSING_NEIGHBORHOOD_INVITE_ERR_GENERIC,
	[Enum.NeighborhoodInviteResult.GenericFailure] = HOUSING_NEIGHBORHOOD_INVITE_ERR_GENERIC,
	[Enum.NeighborhoodInviteResult.Permission] = HOUSING_NEIGHBORHOOD_INVITE_ERR_DISABLED,
	[Enum.NeighborhoodInviteResult.Faction] = HOUSING_NEIGHBORHOOD_INVITE_ERR_FACTION,
	[Enum.NeighborhoodInviteResult.PendingInvitation] = HOUSING_NEIGHBORHOOD_INVITE_ERR_PENDING,
	[Enum.NeighborhoodInviteResult.InviteLimit] = HOUSING_NEIGHBORHOOD_INVITE_ERR_LIMIT,
	[Enum.NeighborhoodInviteResult.NotEnoughPlots] = HOUSING_NEIGHBORHOOD_INVITE_ERR_NO_PLOTS,
	[Enum.NeighborhoodInviteResult.NotFound] = HOUSING_NEIGHBORHOOD_INVITE_ERR_NOT_FOUND,
};

local INVITE_RESIDENT_SHOWING_EVENTS = {
	"NEIGHBORHOOD_INVITE_RESPONSE",
	"CANCEL_NEIGHBORHOOD_INVITE_RESPONSE",
	"PENDING_NEIGHBORHOOD_INVITES_RECIEVED",
};

function HousingInviteResidentFrameMixin:OnLoad()
	self.SendInviteButton:SetScript("OnClick", GenerateClosure(self.OnSendInviteClicked, self));

	self.pendingInvitesPool = CreateFramePool("Frame", self.ScrollFrame.InviteList, "PendingInviteTemplate");
	self.numPendingInvites = 0;
end

function HousingInviteResidentFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, INVITE_RESIDENT_SHOWING_EVENTS);
	C_HousingNeighborhood.RequestPendingNeighborhoodInvites();
	self.PendingListLoadingSpinner:Show();
	self.ErrorText:Hide();
end

function HousingInviteResidentFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, INVITE_RESIDENT_SHOWING_EVENTS);
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_BUTTONS);
end

function HousingInviteResidentFrameMixin:OnEvent(event, ...)
	if event == "NEIGHBORHOOD_INVITE_RESPONSE" then
        local neighborhoodInviteResult = ...;
		if neighborhoodInviteResult == Enum.NeighborhoodInviteResult.Success then
			self:AddPendingInvite(self.pendingInviteName);
			self.ScrollFrame.InviteList:Layout();
			self.ErrorText:Hide();
		else
			self.ErrorText:SetText(NeighborhoodInviteErrorTypeStrings[neighborhoodInviteResult]);
			self.ErrorText:Show();
		end
		self.pendingInvite = false;
		self.InviteButtonLoadingSpinner:Hide();
		self:SetInviteEnabled(true);
        
    elseif event == "CANCEL_NEIGHBORHOOD_INVITE_RESPONSE" then
		local neighborhoodInviteResult, playerName = ...;
		if neighborhoodInviteResult == Enum.NeighborhoodInviteResult.Success then
			self:RemovePendingInvite(playerName);
		else
			self:CancelRemovePendingInvite(playerName);
		end

	elseif event == "PENDING_NEIGHBORHOOD_INVITES_RECIEVED" then
		local neighborhoodInviteResult, playerNames = ...;
		if neighborhoodInviteResult == Enum.NeighborhoodInviteResult.Success then
			self:UpdatePendingInvitesList(playerNames);
		end
		self.PendingListLoadingSpinner:Hide();
	end
end

function HousingInviteResidentFrameMixin:UpdatePendingInvitesList(pendingInvites)
	self.pendingInvitesPool:ReleaseAll();
	self.numPendingInvites = 0;
	for i, playerName in ipairs(pendingInvites) do
		self:AddPendingInvite(playerName);
	end
	self.ScrollFrame.InviteList:Layout();
end

function HousingInviteResidentFrameMixin:AddPendingInvite(playerName)

	-- Check if the invited player is already in the list. If they are in the list, early out.
	-- Note: the invitation service responds with success for duplicate invites
	for inviteFrame in self.pendingInvitesPool:EnumerateActive() do
		if strcmputf8i(inviteFrame.RemoveButton.playerName, playerName) == 0 then
			inviteFrame.LoadingSpinner:Hide();
			return
		end
	end

	local pendingInviteFrame = self.pendingInvitesPool:Acquire();
		pendingInviteFrame.RemoveButton.playerName = playerName;
		pendingInviteFrame.RemoveButton.loadingSpinner = pendingInviteFrame.LoadingSpinner;
		self.numPendingInvites = self.numPendingInvites + 1;
		pendingInviteFrame.layoutIndex = self.numPendingInvites;
		pendingInviteFrame.RemoveButton:SetScript("OnClick", function(self)
			self.loadingSpinner:Show();
			self:Disable();
			HousingInviteResidentFrame:CancelInviteClicked(pendingInviteFrame);
		end);
		pendingInviteFrame.PlayerNameText:SetText(playerName);
		--alternate between light and dark button textures
		if pendingInviteFrame.layoutIndex % 2 == 0 then
			pendingInviteFrame.Background:SetAtlas("housing-bulletinboard-list-item-bg-dark");
		else
			pendingInviteFrame.Background:SetAtlas("housing-bulletinboard-list-item-bg-light");
		end
		pendingInviteFrame:Show();
end

function HousingInviteResidentFrameMixin:RemovePendingInvite(playerName)
	local toRemove;
	for inviteFrame in self.pendingInvitesPool:EnumerateActive() do
		if strcmputf8i(inviteFrame.RemoveButton.playerName, playerName) == 0 then
			inviteFrame.LoadingSpinner:Hide();
			inviteFrame.RemoveButton:Enable();
			toRemove = inviteFrame;
		end
	end
	if toRemove then
		self.pendingInvitesPool:Release(toRemove);
		self.ScrollFrame.InviteList:Layout();
	end
end

function HousingInviteResidentFrameMixin:CancelRemovePendingInvite(playerName)
	for inviteFrame in self.pendingInvitesPool:EnumerateActive() do
		if strcmputf8i(inviteFrame.RemoveButton.playerName, playerName) == 0 then
			inviteFrame.LoadingSpinner:Hide();
			inviteFrame.RemoveButton:Enable();
		end
	end
end

function HousingInviteResidentFrameMixin:SetInviteEnabled(enabled)
	if self.pendingInvite then

	else
		self.SendInviteButton:SetEnabled(enabled);
	end
end

function HousingInviteResidentFrameMixin:OnSendInviteClicked()
	self.SendInviteButton:Disable();
	self.InviteButtonLoadingSpinner:Show();
	self.pendingInvite = true;
	self.pendingInviteName = C_CharacterServices.CapitalizeCharName(self.PlayerSearchBox:GetText());
	C_HousingNeighborhood.InvitePlayerToNeighborhood(self.pendingInviteName);
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_INVITE_RESIDENTS_BUTTONS);
end

StaticPopupDialogs["HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE"] = {
	text = HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE_TEXT,
	button1 = HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE_CONFIRM,
	button2 = CANCEL,
	timeout = 0,
	exclusive = 1,
};

function HousingInviteResidentFrameMixin:CancelInviteClicked(pendingInviteFrame)
	self.pendingCancelInvite = pendingInviteFrame;
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_INVITE_RESIDENTS_BUTTONS);
	local dialog = StaticPopup_Show("HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE", self.pendingCancelInvite.RemoveButton.playerName);
	local acceptButton = dialog:GetButton1();
	acceptButton:SetScript("OnClick", GenerateClosure(self.CancelInviteConfirmed, self));
	local cancelButton = dialog:GetButton2();
	cancelButton:SetScript("OnClick", GenerateClosure(self.CancelInviteCancelled, self));
end

function HousingInviteResidentFrameMixin:CancelInviteConfirmed()
	C_HousingNeighborhood.CancelInviteToNeighborhood(self.pendingCancelInvite.RemoveButton.playerName);
	StaticPopup_Hide("HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE");
end

function HousingInviteResidentFrameMixin:CancelInviteCancelled()
	self.pendingCancelInvite.LoadingSpinner:Hide();
	self.pendingCancelInvite.RemoveButton:Enable();
	StaticPopup_Hide("HOUSING_BULLETIN_CONFIRM_CANCEL_NEIGHBORHOOD_INVITE");
end

--///////////////////////////////
HousingInviteSearchBoxMixin = {}

function HousingInviteSearchBoxMixin:OnLoad()
	AutoCompleteEditBox_SetAutoCompleteSource(self, GetAutoCompleteResults, AUTOCOMPLETE_LIST_TEMPLATES.ALL_CHARS.include, AUTOCOMPLETE_LIST_TEMPLATES.ALL_CHARS.exclude);
	self.addHighlightedText = true;
end

function HousingInviteSearchBoxMixin:OnEnterPressed()
	if ( not AutoCompleteEditBox_OnEnterPressed(self) and HousingInviteResidentFrame.SendInviteButton:IsEnabled() ) then
		HousingInviteResidentFrame:OnSendInviteClicked();
	end
end

function HousingInviteSearchBoxMixin:OnEscapePressed()
	self:ClearFocus();
end

function HousingInviteSearchBoxMixin:OnTextChanged(userInput)
	if ( not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local text = self:GetText();
		if ( text ~= "" ) then
			self.FillText:Hide();
			HousingInviteResidentFrame:SetInviteEnabled(true);
		else
			self.FillText:Show();
			HousingInviteResidentFrame:SetInviteEnabled(false);
		end
	end
end

--//////////////////////////////////////////////////////////////////////
NeighborhoodChangeNameDialogMixin = {}

local NAME_CHANGE_DIALOG_SHOWING_EVENTS = {
	"NEIGHBORHOOD_NAME_VALIDATED",
}

function NeighborhoodChangeNameDialogMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, NAME_CHANGE_DIALOG_SHOWING_EVENTS);
	PlaySound(SOUNDKIT.HOUSING_SETTINGS_OPEN_MENU);
end

function NeighborhoodChangeNameDialogMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, NAME_CHANGE_DIALOG_SHOWING_EVENTS);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.RenameNeighborhood);
	PlaySound(SOUNDKIT.HOUSING_SETTINGS_CLOSE_MENU);
end

function NeighborhoodChangeNameDialogMixin:OnEvent(event, ...)
	if event == "NEIGHBORHOOD_NAME_VALIDATED" then
		local approved = ...;
		if approved == false then
			NeighborhoodChangeNameDialog.NameError:Show();
		else
			C_Housing.TryRenameNeighborhood(NeighborhoodChangeNameDialog.NameEditBox:GetText());
			StaticPopupSpecial_Hide(NeighborhoodChangeNameDialog);
		end
    end
end

function NeighborhoodChangeNameDialogMixin:OnLoad()
    self.ConfirmButton:SetText(HOUSING_NEIGHBORHOOD_SETTINGS_CONFIRM);
    self.CancelButton:SetText(HOUSING_NEIGHBORHOOD_SETTINGS_CANCEL);
    self.ConfirmButton:SetScript("OnClick", self.OnConfirmClicked);
    self.CancelButton:SetScript("OnClick", function()
        StaticPopupSpecial_Hide(NeighborhoodChangeNameDialog);
		PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_BUTTONS);
    end);
end

function NeighborhoodChangeNameDialogMixin:OnConfirmClicked()
	PlaySound(SOUNDKIT.HOUSING_BULLETIN_BOARD_BUTTONS);
	C_Housing.ValidateNeighborhoodName(NeighborhoodChangeNameDialog.NameEditBox:GetText());
end

--//////////////////////////////////////////////////////////////////////
NeighborhoodChangeNameCostMixin = {}

local RENAME_TOKEN_ITEM_ID =  234128;

function NeighborhoodChangeNameCostMixin:OnLoad()
	local iconTexture = C_Item.GetItemIconByID(RENAME_TOKEN_ITEM_ID);
	self.Icon:SetTexture(iconTexture);
end

function NeighborhoodChangeNameCostMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetItemByID(RENAME_TOKEN_ITEM_ID);
	GameTooltip:Show();
end

function NeighborhoodChangeNameCostMixin:OnLeave()
	GameTooltip:Hide();
end
