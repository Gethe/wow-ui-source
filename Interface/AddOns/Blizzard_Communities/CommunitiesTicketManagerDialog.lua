
local COMMUNITIES_TICKET_MANAGER_DIALOG_EVENTS = {
	"CLUB_TICKETS_RECEIVED",
	"CLUB_TICKET_CREATED",
};

local INVITE_MANAGER_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_CREATOR,
		width = 96,
	},
	
	[2] = {
		title = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK,
		width = 284,
	},
	
	[3] = {
		title = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_EXPIRES,
		width = 75,
	},
	
	[4] = {
		title = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_USES,
		width = 0,
	},
};

function CommunitiesTicketManagerDialog_Open(clubId, streamId)
	CommunitiesTicketManagerDialog:SetClubId(clubId);
	CommunitiesTicketManagerDialog:SetStreamId(streamId);
	CommunitiesTicketManagerDialog:Show();
end

function CommunitiesTicketManagerDialog_OnStreamChanged(clubId, streamId)
	if clubId == CommunitiesTicketManagerDialog:GetClubId() then
		CommunitiesTicketManagerDialog:SetStreamId(streamId);
	end
end

ClubTicketUtil = {};

function ClubTicketUtil.GetSecondsRemaining(expirationTime)
	return (expirationTime / 1000000 - GetServerTime());
end

function ClubTicketUtil.FormatTimeRemaining(expirationTime)
	local seconds = ClubTicketUtil.GetSecondsRemaining(expirationTime);
	local hideSeconds = seconds >= 60;
	return SecondsToTime(seconds, hideSeconds);
end

function ClubTicketUtil.FormatTicket(clubInfo, ticketId)
	if clubInfo.clubType == Enum.ClubType.BattleNet then
		local currentRegionName = GetCurrentRegionName();
		local factionGroupTag, localizedFaction = UnitFactionGroup("player");
		if currentRegionName == "CN" then
			return COMMUNITIES_INVITE_MANAGER_TICKET_FORMAT_CN:format(ticketId, currentRegionName, factionGroupTag);
		else
			return COMMUNITIES_INVITE_MANAGER_TICKET_FORMAT:format(ticketId, currentRegionName, factionGroupTag);
		end
	elseif clubInfo.clubType == Enum.ClubType.Character then
		local currentRegionName = GetCurrentRegionName();
		local factionGroupTag, localizedFaction = UnitFactionGroup("player");
		if currentRegionName == "CN" then
			return COMMUNITIES_INVITE_MANAGER_TICKET_FORMAT_CHARACTER_CN:format(ticketId, currentRegionName, factionGroupTag);
		else
			return COMMUNITIES_INVITE_MANAGER_TICKET_FORMAT_CHARACTER:format(ticketId, currentRegionName, factionGroupTag);
		end
	-- else -- This is an error case. We don't support tickets for other club types right now.
	end
end

function ClubTicketUtil.IsTicketExpired(ticket)
	return ticket.expirationTime ~= 0 and ticket.expirationTime / 1000000 < GetServerTime()
end

local DEFAULT_USES_OPTION = 3;
local USES_OPTIONS = {
	1,
	10,
	50,
	100,
	0, -- unlimited
};

function CommunitiesTicketManagerDialogUsesDropDown_Initialize(self)
	for i, option in ipairs(USES_OPTIONS) do
		local info = UIDropDownMenu_CreateInfo();
		local text = nil;
		if option == 0 then
			text = COMMUNITIES_INVITE_MANAGER_USES_UNLIMITED;
		else
			text = COMMUNITIES_INVITE_MANAGER_USES:format(option);
		end
		
		info.text = text;
		info.value = i;
		info.func = function (button)
			CommunitiesTicketManagerDialog:SetUses(option);
			UIDropDownMenu_SetSelectedValue(self, button.value);
		end;
		
		info.checked = function()
			return CommunitiesTicketManagerDialog:GetUses() == option;
		end;
		
		UIDropDownMenu_AddButton(info);
	end
end

local DEFAULT_EXPIRES_OPTION = 2;
local EXPIRES_OPTIONS = {
	10 * 60, -- 10 minutes
	30 * 60, -- 30 minutes
	1 * 60 * 60, -- 1 hour
	24 * 60 * 60, -- 1 day
	0, -- never
};

function CommunitiesTicketManagerDialogExpiresDropDown_Initialize(self)
	for i, option in ipairs(EXPIRES_OPTIONS) do
		local info = UIDropDownMenu_CreateInfo();
		local text = nil;
		if option == 0 then
			text = COMMUNITIES_INVITE_MANAGER_EXPIRES_NEVER;
		else
			text = SecondsToTime(option, true, true);
		end
		
		info.text = text;
		info.value = i;
		info.func = function (button)
			CommunitiesTicketManagerDialog:SetExpirationTime(option);
			UIDropDownMenu_SetSelectedValue(self, button.value);
		end;
		
		info.checked = function()
			return CommunitiesTicketManagerDialog:GetExpirationTime() == option;
		end;
		
		UIDropDownMenu_AddButton(info);
	end
end

CommunitiesTicketEntryMixin = {};

function CommunitiesTicketEntryMixin:OnUpdate()
	if self.Creator:IsTruncated() and self.Creator:IsMouseOver() then
		GameTooltip:SetOwner(self);
		GameTooltip:AddLine(self.Creator:GetText(), HIGHLIGHT_FONT_COLOR);
		GameTooltip:Show();
	else
		GameTooltip:Hide();
	end
end

function CommunitiesTicketEntryMixin:OnEnter()
	self.CopyLinkButton:Show();
	
	if self.Creator:IsTruncated() then
		self:SetScript("OnUpdate", CommunitiesTicketEntryMixin.OnUpdate);
	end
end

function CommunitiesTicketEntryMixin:OnLeave()
	if GetMouseFocus() ~= self.CopyLinkButton then
		self.CopyLinkButton:Hide();
	end
	
	self:SetScript("OnUpdate", nil);
	GameTooltip:Hide();
end

function CommunitiesTicketEntryMixin:SetClubId(clubId)
	self.clubId = clubId;
end

function CommunitiesTicketEntryMixin:GetClubId()
	return self.clubId;
end

function CommunitiesTicketEntryMixin:SetTicket(ticketInfo)
	self.ticketInfo = ticketInfo;
	
	local clubId = self:GetClubId();
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return;
	end
	
	self.Creator:SetText(ticketInfo.creator.name or "");
	self.Creator:SetTextColor(CommunitiesUtil.GetMemberRGB(ticketInfo.creator));
		
	self.Link:SetText(ClubTicketUtil.FormatTicket(clubInfo, ticketInfo.ticketId));
	
	if ticketInfo.allowedRedeemCount == 0 then
		self.Uses:SetText(COMMUNITIES_INVITE_MANAGER_USES_UNLIMITED);
		self.Uses:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self.Uses:SetText(COMMUNITIES_INVITE_MANAGER_USES_FORMAT:format(ticketInfo.allowedRedeemCount - ticketInfo.currentRedeemCount, ticketInfo.allowedRedeemCount));
		self.Uses:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	
	if ticketInfo.expirationTime == 0 then
		self.Expires:SetText(COMMUNITIES_INVITE_MANAGER_EXPIRES_NEVER);
		self.Expires:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self.Expires:SetText(ClubTicketUtil.FormatTimeRemaining(ticketInfo.expirationTime));
		self.Expires:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
end

function CommunitiesTicketEntryMixin:GetTicketInfo()
	return self.ticketInfo;
end

function CommunitiesTicketEntryMixin:Refresh()
	local ticketInfo = self:GetTicketInfo();
	local timeRemaining = ClubTicketUtil.GetSecondsRemaining(self.ticketInfo.expirationTime);
	if timeRemaining > 0 then
		self.Expires:SetText(ClubTicketUtil.FormatTimeRemaining(ticketInfo.expirationTime));
	end
end

function CommunitiesTicketEntryMixin:RevokeTicket()
	C_Club.DestroyTicket(self:GetClubId(), self:GetTicketInfo().ticketId);
	self:GetCommunitiesIniteManagerDialog():OnTicketRevoked(self:GetTicketInfo().ticketId);
end

function CommunitiesTicketEntryMixin:GetCommunitiesIniteManagerDialog()
	return self:GetParent():GetParent():GetParent():GetParent();
end

CommunitiesTicketManagerScrollFrameMixin = {};

function CommunitiesTicketManagerScrollFrameMixin:OnLoad()
	self.ColumnDisplay:LayoutColumns(INVITE_MANAGER_COLUMN_INFO);
end

CommunitiesTicketManagerDialogMixin = {};

function CommunitiesTicketManagerDialogMixin:OnLoad()
	self.tickets = {};
	self.revokedTickets = {};
	self:SetUses(USES_OPTIONS[DEFAULT_USES_OPTION]);
	self:SetExpirationTime(EXPIRES_OPTIONS[DEFAULT_EXPIRES_OPTION]);
	
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CommunitiesTicketEntryTemplate", function(button, elementData)
		button:SetClubId(self:GetClubId());
		button:SetTicket(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.InviteManager.ScrollBox, self.InviteManager.ScrollBar, view);

	UIDropDownMenu_SetWidth(self.UsesDropDownMenu, 115);
	self.UsesDropDownMenu.Text:SetJustifyH("LEFT");
	UIDropDownMenu_Initialize(self.UsesDropDownMenu, CommunitiesTicketManagerDialogUsesDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self.UsesDropDownMenu, DEFAULT_USES_OPTION);
	
	UIDropDownMenu_SetWidth(self.ExpiresDropDownMenu, 115);
	self.ExpiresDropDownMenu.Text:SetJustifyH("LEFT");
	UIDropDownMenu_Initialize(self.ExpiresDropDownMenu, CommunitiesTicketManagerDialogExpiresDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self.ExpiresDropDownMenu, DEFAULT_EXPIRES_OPTION);
end

function CommunitiesTicketManagerDialogMixin:OnShow()
	self:SetExpanded(false);
	self.shouldGenerateDefaultLink = true;
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_TICKET_MANAGER_DIALOG_EVENTS);
	
	local clubId = self:GetClubId()
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		self.DialogLabel:SetFormattedText(COMMUNITIES_INVITE_MANAGER_LABEL, clubInfo.name);
		self.IconRing:SetAtlas(self.clubType == Enum.ClubType.BattleNet and "communities-ring-blue" or "communities-ring-gold");
		C_Club.SetAvatarTexture(self.Icon, clubInfo.avatarId, clubInfo.clubType);
	end
	
	self:Update();
	
	C_Club.RequestTickets(self:GetClubId());
	
	self.refreshTicker = C_Timer.NewTicker(1.0, function ()
		self:RemoveExpiredTickets();
		self:Refresh();
	end);
	
	CommunitiesFrame:RegisterDialogShown(self);
end

function CommunitiesTicketManagerDialogMixin:SortTickets()
	table.sort(self.tickets, function (lhsTicket, rhsTicket)
		return lhsTicket.creationTime > rhsTicket.creationTime;
	end);
end

function CommunitiesTicketManagerDialogMixin:UpdateTickets()
	local clubId = self:GetClubId();
	local tickets = C_Club.GetTickets(clubId);
	if #tickets <= 0 then
		if self.shouldGenerateDefaultLink then
			self:GenerateDefaultLink();
		end
	else
		self.tickets = tickets;
		self:SortTickets();
	end
	
	self.shouldGenerateDefaultLink = false;
	
	self:Update();
end

function CommunitiesTicketManagerDialogMixin:AddTicket(ticketInfo)
	table.insert(self.tickets, ticketInfo);
	self:SortTickets();
end

function CommunitiesTicketManagerDialogMixin:ClearTickets()
	table.wipe(self.tickets);
end

function CommunitiesTicketManagerDialogMixin:RemoveExpiredTickets()
	local ticketsChanged = false;
	for i, ticket in ipairs(self.tickets) do
		if ClubTicketUtil.IsTicketExpired(ticket) then
			ticketsChanged = true;
			break;
		end
	end
	
	if ticketsChanged then
		local remainingTickets = {};
		for i, ticket in ipairs(self.tickets) do
			if not ClubTicketUtil.IsTicketExpired(ticket) then
				table.insert(remainingTickets, ticket);
			end
		end
		
		self.tickets = remainingTickets;
		self:Update();
	end
end

function CommunitiesTicketManagerDialogMixin:GetTickets()
	return self.tickets;
end

function CommunitiesTicketManagerDialogMixin:Update()
	self:RefreshLink();
	
	local tickets = self:GetTickets();
	local hasTickets = #tickets >= 1;
	self.LinkToChat:SetEnabled(hasTickets);
	self.Copy:SetEnabled(hasTickets);
	
	local dataProvider = CreateDataProvider(tickets);
	self.InviteManager.ScrollBox:SetDataProvider(dataProvider);
end

function CommunitiesTicketManagerDialogMixin:Refresh()
	self:RefreshLink();
	
	self.InviteManager.ScrollBox:ForEachFrame(function(button, ticketInfo)
		button:SetTicket(ticketInfo);
	end);
end

function CommunitiesTicketManagerDialogMixin:OnTicketRevoked(ticketId)
	for i, ticket in ipairs(self.tickets) do
		if ticket.ticketId == ticketId then
			table.remove(self.tickets, i);
			break;
		end
	end
	
	self:Update();
end

function CommunitiesTicketManagerDialogMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_TICKET_MANAGER_DIALOG_EVENTS);
	self.refreshTicker:Cancel();
	self:ClearTickets();
end

function CommunitiesTicketManagerDialogMixin:OnEvent(event, ...)
	if event == "CLUB_TICKETS_RECEIVED" then
		self:UpdateTickets();
	elseif event == "CLUB_TICKET_CREATED" then
		local clubId, ticketInfo = ...;
		if clubId == self:GetClubId() then
			self:AddTicket(ticketInfo);
			self:Update();
		end
	end
end

local PIECES_SHOWN_IN_EXPANDED_VIEW = {
	MaximizeButton = false,
	ExpandLabel = false,
	Separator = true,
	InviteManager = true,
	NewLinkLabel = true,
	ExpiresDropDownLabel = true,
	ExpiresDropDownMenu = true,
	UsesDropDownLabel = true,
	UsesDropDownMenu = true,
	GenerateLinkButton = true,
};

function CommunitiesTicketManagerDialogMixin:SetExpanded(expanded)
	self:SetHeight(expanded and 584 or 282);
	for piece, shownInExpandedView in pairs(PIECES_SHOWN_IN_EXPANDED_VIEW) do
		self[piece]:SetShown(expanded == shownInExpandedView);
	end
end

function CommunitiesTicketManagerDialogMixin:SetUses(uses)
	self.uses = uses;
end

function CommunitiesTicketManagerDialogMixin:GetUses()
	return self.uses;
end

function CommunitiesTicketManagerDialogMixin:SetExpirationTime(expirationTime)
	self.expirationTime = expirationTime;
end

function CommunitiesTicketManagerDialogMixin:GetExpirationTime()
	return self.expirationTime;
end

function CommunitiesTicketManagerDialogMixin:GenerateDefaultLink()
	self:GenerateLink(USES_OPTIONS[DEFAULT_USES_OPTION], EXPIRES_OPTIONS[DEFAULT_EXPIRES_OPTION]);
end

function CommunitiesTicketManagerDialogMixin:GenerateLink(overrideUses, overrideExpiration, overrideStreamId)
	local uses = overrideUses or self:GetUses();
	if uses == 0 then
		uses = nil;
	end
	
	local expirationTime = overrideExpiration or self:GetExpirationTime();
	if expirationTime == 0 then
		expirationTime = nil;
	end
	
	local streamId = overrideStreamId or self:GetStreamId();
	local clubId = self:GetClubId();
	local clubInfo = C_Club.GetClubInfo(clubId);
	C_Club.CreateTicket(clubId, uses, expirationTime, streamId, clubInfo.crossFaction);
end

function CommunitiesTicketManagerDialogMixin:GetFirstTicketInfo()
	local tickets = self:GetTickets();
	if #tickets >= 1 then
		return tickets[1];
	end
	
	return nil;
end

function CommunitiesTicketManagerDialogMixin:SendLinkToChat()
	local ticketInfo = self:GetFirstTicketInfo();
	local clubInfo = C_Club.GetClubInfo(self:GetClubId());

	if ticketInfo and clubInfo then
		local link = GetClubTicketLink(ticketInfo.ticketId, clubInfo.name, clubInfo.clubType);
		if not ChatEdit_InsertLink(link) then
			ChatFrame_OpenChat(link);
		end
	end
end

function CommunitiesTicketManagerDialogMixin:RefreshLink()
	local tickets = self:GetTickets();
	if #tickets >= 1 then
		local ticketInfo = tickets[1];
		local clubInfo = C_Club.GetClubInfo(self:GetClubId());
		if not clubInfo then
			return;
		end
		
		self.LinkIDText:SetText(ticketInfo.ticketId);
		
		if ticketInfo.allowedRedeemCount == 0 then
			self.UsesText:SetText(COMMUNITIES_INVITE_MANAGER_USES_UNLIMITED); 
		else
			self.UsesText:SetText(ticketInfo.allowedRedeemCount - ticketInfo.currentRedeemCount);
		end
		
		if ticketInfo.expirationTime == 0 then
			self.ExpiresText:SetText(COMMUNITIES_INVITE_MANAGER_EXPIRES_NEVER);
		else
			self.ExpiresText:SetText(ClubTicketUtil.FormatTimeRemaining(ticketInfo.expirationTime));
		end
	else
		self.LinkIDText:SetText("");
		self.UsesText:SetText("");
		self.ExpiresText:SetText("");
	end
end

function CommunitiesTicketManagerDialogMixin:SetClubId(clubId)
	self.clubId = clubId;
end

function CommunitiesTicketManagerDialogMixin:GetClubId()
	return self.clubId;
end

function CommunitiesTicketManagerDialogMixin:SetStreamId(streamId)
	self.streamId = streamId;
end

function CommunitiesTicketManagerDialogMixin:GetStreamId()
	return self.streamId;
end
