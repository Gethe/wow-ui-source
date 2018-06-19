
CommunitiesHyperlink = {};

local pendingTicketIds = {};

local ticketListener;
local function CommunitiesHyperlink_OnEvent(self, event, ...)
	if event == "CLUB_TICKET_RECEIVED" then
		local error, ticketId, clubInfo = ...;
		if pendingTicketIds[ticketId] then
			if error == Enum.ClubErrorType.ErrorCommunitiesNone then
				CommunitiesFrame.CommunitiesList:AddTicket(ticketId, clubInfo);
			else
				local errorString = GetCommunitiesErrorString(ERROR_CLUB_ACTION_REDEEM_TICKET, error, Enum.ClubType.BattleNet);
				UIErrorsFrame:AddMessage(ERROR_CLUB_ACTION_REDEEM_TICKET:format(""), RED_FONT_COLOR:GetRGB());
			end

			pendingTicketIds[ticketId] = nil;
			if next(pendingTicketIds) == nil then
				ticketListener:UnregisterEvent("CLUB_TICKET_RECEIVED");
			end
		end
	end
end

function CommunitiesHyperlink.OnClickLink(ticketId)
	if not ticketListener then
		ticketListener = CreateFrame("FRAME");
		ticketListener:SetScript("OnEvent", CommunitiesHyperlink_OnEvent);
	end
	if not pendingTicketIds[ticketId] then
		ticketListener:RegisterEvent("CLUB_TICKET_RECEIVED");
		pendingTicketIds[ticketId] = true;
		C_Club.RequestTicket(ticketId);
	end
end