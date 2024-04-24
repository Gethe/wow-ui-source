
local DEFAULT_NUM_DAYS_TO_PREVIEW = 4;
local TOOLTIP_MAX_NUM_OF_CALENDER_EVENTS = 5;

CommunitiesCalendarButtonMixin = {};

function CommunitiesCalendarButtonMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesCalendarButtonMixin:OnEnter()
	local selectedClubInfo = self:GetCommunitiesFrame():GetSelectedClubInfo();
	if selectedClubInfo == nil then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0);
	GameTooltip_SetTitle(GameTooltip, COMMUNITIES_CALENDAR_TOOLTIP_TITLE);
	
	if selectedClubInfo.broadcast ~= "" then
		GameTooltip_AddNormalLine(GameTooltip, COMMUNITIES_CALENDAR_MOTD_FORMAT:format(selectedClubInfo.broadcast), true);
	end
	
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	local events = C_Calendar.GetClubCalendarEvents(selectedClubInfo.clubId, currentCalendarTime, C_DateAndTime.AdjustTimeByDays(currentCalendarTime, DEFAULT_NUM_DAYS_TO_PREVIEW));
	for i, event in ipairs(events) do
		if i > TOOLTIP_MAX_NUM_OF_CALENDER_EVENTS then
			break;
		end
		
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		
		local weekDay = currentCalendarTime.weekday == event.startTime.weekday and COMMUNITIES_CALENDAR_TODAY or CALENDAR_WEEKDAY_NAMES[event.startTime.weekday];
		local startTime = GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true);
		GameTooltip_AddColoredLine(GameTooltip, COMMUNITIES_CALENDAR_EVENT_FORMAT:format(weekDay, startTime), HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddNormalLine(GameTooltip, event.title);
		
		local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
		GameTooltip_AddColoredLine(GameTooltip, inviteStatusInfo.name, inviteStatusInfo.color);
	end
	
	if #events >= 1 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end
	
	GameTooltip_AddInstructionLine(GameTooltip, COMMUNITIES_CALENDAR_CLICK_TO_ADD_INSTRUCTIONS);
	GameTooltip:Show();
end

function CommunitiesCalendarButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function CommunitiesCalendarButtonMixin:OnClick()
	local selectedClubInfo = self:GetCommunitiesFrame():GetSelectedClubInfo();
	if selectedClubInfo ~= nil and (selectedClubInfo.clubType == Enum.ClubType.Guild or selectedClubInfo.clubType == Enum.ClubType.Character) then
		C_Calendar.SetNextClubId(selectedClubInfo.clubId);
	else
		C_Calendar.SetNextClubId(nil);
	end
	
	ToggleCalendar();
end
