
StaticPopupDialogs["EXTERNAL_LINK"] = {
	text = BROWSER_EXTERNAL_LINK_DIALOG,
	button1 = OKAY,
	button3 = BROWSER_COPY_LINK,
	button2 = CANCEL,
	OnAccept = function(self, data)
		data.browser:OpenExternalLink();
	end,
	OnAlt = function(self, data)
		data.browser:CopyExternalLink();
	end,
	OnShow = function(self)

	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

-- global data
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes

HELPFRAME_KNOWLEDGE_BASE		= 1;
HELPFRAME_SUBMIT_TICKET			= 14;

-- local data
local refreshTime;
local ticketQueueActive = true;
local navigateHomeOnShow = true;

--
-- HelpFrameMixin
--

HelpFrameMixin = {};

function HelpFrameMixin:SetInitialLoading(initialLoading)
	self.initialLoading = initialLoading;
	self.SpinnerOverlay:SetShown(initialLoading);
end

function HelpFrameMixin:GetInitialLoading()
	return self.initialLoading;
end

function HelpFrameMixin:ShowUnavailable()
    -- TODO
end

function HelpFrameMixin:OnLoad()
	self:SetTitle(HELP_FRAME_TITLE);

	self:RegisterEvent("UPDATE_GM_STATUS");
	self:RegisterEvent("QUICK_TICKET_SYSTEM_STATUS");
	self:RegisterEvent("QUICK_TICKET_THROTTLE_CHANGED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_PROXY_FAILED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_ERROR");
end

function HelpFrameMixin:OnShow()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	GetGMStatus();
	if ( navigateHomeOnShow ) then
		HelpBrowser:NavigateHome("KnowledgeBase");
	end
	self:SetInitialLoading(true);
end

function HelpFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
end

function HelpFrameMixin:OnEvent(event, ...)
	if ( event ==  "UPDATE_GM_STATUS" ) then
		local status = ...;
		if ( status == GMTICKET_QUEUE_STATUS_ENABLED ) then
			ticketQueueActive = true;
		else
			ticketQueueActive = false;
			if ( status == GMTICKET_QUEUE_STATUS_DISABLED ) then
				StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			end
		end
	elseif ( event == "SIMPLE_BROWSER_WEB_PROXY_FAILED" ) then
		StaticPopup_Show("WEB_PROXY_FAILED");
	elseif ( event == "SIMPLE_BROWSER_WEB_ERROR" ) then
		local errorNumber = tonumber(...);
		StaticPopup_Show("WEB_ERROR", errorNumber);
	end
end

function HelpFrameMixin:OnError(msg)
	if (self:GetInitialLoading()) then
		self:ShowUnavailable();
	else
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(msg, info.r, info.g, info.b, info.id);
	end

end
function HelpFrameMixin:ShowFrame(key)
	if key == HELPFRAME_SUBMIT_TICKET then
		navigateHomeOnShow = false;
	else
		navigateHomeOnShow = true;
	end

	ShowUIPanel(HelpFrame);
end

function HelpFrame_IsGMTicketQueueActive()
	return ticketQueueActive;
end

function HelpFrame_ShowReportCheatingDialog(playerLocation)
	local frame = ReportCheatingDialog;
	frame.CommentFrame.EditBox:SetText("");
	frame.CommentFrame.EditBox.InformationText:Show();
	frame.reportToken = C_ReportSystem.InitiateReportPlayer(PLAYER_REPORT_TYPE_CHEATING, playerLocation);
	StaticPopupSpecial_Show(frame);
end

--
-- HelpOpenWebTicketButton
--

function HelpOpenWebTicketButton_OnEnter(self, elapsed)
	if ( self.haveTicket ) then
		if ( self.haveResponse ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:SetText(GM_RESPONSE_ALERT, nil, nil, nil, nil, true);
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:AddLine(self.titleText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			if (self.statusText) then
				GameTooltip:AddLine(self.statusText);
			end
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function HelpOpenWebTicketButton_OnUpdate(self, elapsed)
	-- Every so often, query the server for our ticket status
	if ( self.refreshTime ) then
		self.refreshTime = self.refreshTime - elapsed;
		if ( self.refreshTime <= 0 ) then
			self.refreshTime = GMTICKET_CHECK_INTERVAL;
			GetWebTicket();
		end
	end
end

function HelpOpenWebTicketButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_WEB_TICKET" ) then
		local hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg = ...;
		self.titleText = nil;
		self.statusText = nil;
		self.caseIndex = nil;
		if (hasTicket) then
			self.haveTicket = true;
			self.haveResponse = false;
			self.titleText = TICKET_STATUS;
			if (ticketStatus == LE_TICKET_STATUS_NMI) then --need more info
				self.statusText = TICKET_STATUS_NMI;
				self.caseIndex = caseIndex;
			elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then --ticket has been responded to
				self.haveResponse = true;
				self.caseIndex = caseIndex;
			elseif (ticketStatus == LE_TICKET_STATUS_OPEN) then
				if (waitMsg and waitTime > 0) then
					self.statusText = format(waitMsg, SecondsToTime(waitTime*60))
				elseif (waitMsg) then
					self.statusText = waitMsg;
				elseif (waitTime > 120) then
					self.statusText = GM_TICKET_HIGH_VOLUME;
				elseif (waitTime > 0) then
					self.statusText = format(GM_TICKET_WAIT_TIME, SecondsToTime(waitTime*60));
				else
					self.statusText = GM_TICKET_UNAVAILABLE;
				end
			elseif (ticketStatus == LE_TICKET_STATUS_SURVEY and numTickets == 1) then
				-- the player just has a survey, don't show this icon
				self:Hide();
				return;
			end
			self:Show();
		else
			-- the player does not have a ticket
			self.haveResponse = false;
			self.haveTicket = false;
			self:Hide();
		end
	end
end

--
-- TicketStatusFrame
--


function TicketStatusFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_WEB_TICKET");
end

function TicketStatusFrame_OnEvent(self, event, ...)
	if (event == "UPDATE_WEB_TICKET") then
		local hasTicket, numTickets, ticketStatus, caseIndex = ...;
		self.haveWebSurvey = false;
		if (hasTicket and ticketStatus ~= LE_TICKET_STATUS_OPEN) then
			self.hasWebTicket = true;
			if (ticketStatus == LE_TICKET_STATUS_NMI) then --need more info
				TicketStatusTitleText:SetText(TICKET_STATUS_NMI);
			elseif (ticketStatus == LE_TICKET_STATUS_SURVEY) then --survey is ready
				TicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
				self.haveWebSurvey = true;
			elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then --ticket has been responded to
				TicketStatusTitleText:SetText(GM_RESPONSE_ALERT);
				self.haveResponse = true;
			end
			self:SetHeight(TicketStatusTitleText:GetHeight() + 20);

			self.caseIndex = caseIndex;
			self:Show();
		else
			self.hasWebTicket = false;
			self:Hide();
		end
	end
end


function TicketStatusFrame_OnShow(self)
	UIParent_UpdateTopFramePositions();
end

function TicketStatusFrame_OnHide(self)
	UIParent_UpdateTopFramePositions();
end


--
-- TicketStatusFrameButton
--

function TicketStatusFrameButton_OnLoad(self)
	-- make sure this frame doesn't cover up the content in the parent
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 1);
end

function TicketStatusFrameButton_OnClick(self)
	if (TicketStatusFrame.hasWebTicket and TicketStatusFrame.caseIndex) then
		HelpFrame:ShowFrame(HELPFRAME_SUBMIT_TICKET);
		HelpBrowser:OpenTicket(TicketStatusFrame.caseIndex);
		TicketStatusFrame.haveWebSurveyClicked = TicketStatusFrame.haveWebSurvey;
		TicketStatusFrame:Hide();
	end
end
