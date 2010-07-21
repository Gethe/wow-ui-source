-- global data
HELPFRAME_BULLET_SPACING = -3;
HELPFRAME_SECTION_SPACING = -20;
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes

HELPFRAME_START_PAGE = "KBase";


-- local data

-- helpFrames contains the names of all the frames that can go into the frameStack
local helpFrames = {
	["GMTalk"]			= "HelpFrameGMTalk",
	["Stuck"]			= "HelpFrameStuck",
	["ReportIssue"]		= "HelpFrameReportIssue",
	["OpenTicket"]		= "HelpFrameOpenTicket",
	["GMResponse"]		= "HelpFrameViewResponse",
	["NeedMoreHelp"]	= "HelpFrameOpenTicket",
	["Welcome"]			= "HelpFrameWelcome",
	["KBase"]			= "KnowledgeBaseFrame",
	["Lag"]				= "HelpFrameLag",
};
-- openFrame is the current help frame that a player has opened.
local openFrame;
-- frameStack is a stack of all the help frames that a player has opened.
-- For example, if I open the knowledge base, then open the stuck frame, then open the open ticket frame,
-- frameStack would look like this:
--
--  frameStack: bottom [ KnowledgeBaseFrame, HelpFrameStuck ] top
--  openFrame: HelpFrameOpenTicket
--
-- For usage, see:
--  HelpFrame_ShowFrame(key)
--  HelpFrame_PopFrame()
--  HelpFrame_PopAllFrames()
local frameStack = { };

local refreshTime;
local ticketQueueActive = true;

local haveTicket = false;		-- true if the server tells us we have an open ticket
local haveResponse = false;		-- true if we got a GM response to a previous ticket
local needResponse = true;		-- true if we want a GM to contact us when we open a new ticket


--
-- HelpFrame
--

function HelpFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_GM_STATUS");
	self:RegisterEvent("UPDATE_TICKET");
	self:RegisterEvent("GMSURVEY_DISPLAY");
	self:RegisterEvent("GMRESPONSE_RECEIVED");
end

function HelpFrame_OnShow(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	GetGMStatus();
end

function HelpFrame_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	if ( openFrame ) then
		openFrame:Hide();
		openFrame = nil;
	end
	HelpFrame_PopAllFrames();
end

function HelpFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		GetGMTicket();
	elseif ( event ==  "UPDATE_GM_STATUS" ) then
		local status = ...;
		if ( status == GMTICKET_QUEUE_STATUS_ENABLED ) then
			ticketQueueActive = true;
		else
			ticketQueueActive = false;
			HelpFrameStuckOpenTicket:Disable();
			if ( status == GMTICKET_QUEUE_STATUS_DISABLED ) then
				StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			end
		end
	elseif ( event == "GMSURVEY_DISPLAY" ) then
		-- If there's a survey to display then fill out info and return
		TicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
		TicketStatusTime:Hide();
		TicketStatusFrame:SetHeight(TicketStatusTitleText:GetHeight() + 20);
		TicketStatusFrame:Show();
		TicketStatusFrame.hasGMSurvey = true;
		haveResponse = false;
		haveTicket = false;
		UIFrameFlash(TicketStatusFrameIcon, 0.75, 0.75, 20);
	elseif ( event == "UPDATE_TICKET" ) then
		local category, ticketDescription, ticketAge, oldestTicketTime, updateTime, assignedToGM, openedByGM = ...;
		-- If there are args then the player has a ticket
		if ( category ) then
			-- Has an open ticket
			TicketStatusTitleText:SetText(TICKET_STATUS);
			TicketStatusFrame.hasGMSurvey = false;
			HelpFrameOpenTicketEditBox:SetText(ticketDescription);
			-- Setup estimated wait time
			--[[
			ticketAge - days
			oldestTicketTime - days
			updateTime - days
				How recent is the data for oldest ticket time, measured in days.  If this number 1 hour, we have bad data.
			assignedToGM - see GMTICKET_ASSIGNEDTOGM_STATUS_* constants
			openedByGM - see GMTICKET_OPENEDBYGM_STATUS_* constants
			]]
			local statusText;
			TicketStatusFrame.ticketTimer = nil;
			if ( openedByGM == GMTICKET_OPENEDBYGM_STATUS_OPENED ) then
				-- if ticket has been opened by a gm
				if ( assignedToGM == GMTICKET_ASSIGNEDTOGM_STATUS_ESCALATED ) then
					statusText = GM_TICKET_ESCALATED;
				else
					statusText = GM_TICKET_SERVICE_SOON;
				end
			else
				-- convert from days to seconds
				local estimatedWaitTime = (oldestTicketTime - ticketAge) * 24 * 60 * 60;
				if ( estimatedWaitTime < 0 ) then
					estimatedWaitTime = 0;
				end

				if ( oldestTicketTime < 0 or updateTime < 0 or updateTime > 0.042 ) then
					statusText = GM_TICKET_UNAVAILABLE;
				elseif ( estimatedWaitTime > 7200 ) then
					-- if wait is over 2 hrs
					statusText = GM_TICKET_HIGH_VOLUME;
				elseif ( estimatedWaitTime > 300 ) then
					-- if wait is over 5 mins
					statusText = format(GM_TICKET_WAIT_TIME, SecondsToTime(estimatedWaitTime, 1));
					TicketStatusFrame.ticketTimer = estimatedWaitTime;
				else
					statusText = GM_TICKET_SERVICE_SOON;
				end
			end
			if ( statusText ) then
				TicketStatusTime:Show();
				TicketStatusTime:SetText(statusText);
			end

			haveResponse = false;
			haveTicket = true;
			HelpFrameOpenTicketSubmit:SetText(EDIT_TICKET);
			HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_EDITTEXT);

			-- hide the buttons that open a ticket and show the buttons that edit a ticket
			KnowledgeBaseFrameGMTalk:Hide();
			KnowledgeBaseFrameReportIssue:Hide();
			HelpFrameStuckOpenTicket:Hide();
			KnowledgeBaseFrameEditTicket:Show();
			KnowledgeBaseFrameAbandonTicket:Show();
		else
			-- the player does not have a ticket
			HelpFrameOpenTicketEditBox:SetText("");
			haveResponse = false;
			haveTicket = false;
			HelpFrameOpenTicketSubmit:SetText(SUBMIT);
			HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_TEXT);

			-- hide the buttons that edit a ticket and show the buttons that open a ticket
			KnowledgeBaseFrameGMTalk:Show();
			KnowledgeBaseFrameReportIssue:Show();
			HelpFrameStuckOpenTicket:Show();
			KnowledgeBaseFrameEditTicket:Hide();
			KnowledgeBaseFrameAbandonTicket:Hide();
		end
	elseif ( event == "GMRESPONSE_RECEIVED" ) then
		local ticketDescription, response = ...;

		haveResponse = true;
		-- i know this is a little confusing since you can have a ticket while you have a response, but having a response
		-- basically implies that you can't make a *new* ticket until you deal with the response...maybe it should be
		-- called haveNewTicket but that would probably be even more confusing
		haveTicket = false;

		TicketStatusTitleText:SetText(GM_RESPONSE_ALERT);
		TicketStatusTime:SetText("");
		TicketStatusTime:Hide();
		TicketStatusFrame.hasGMSurvey = false;

		local descriptionSuffix = "\n";
		HelpFrameViewResponseIssueBody:SetText(ticketDescription..descriptionSuffix);
		local responseSuffix = "\n";
		HelpFrameViewResponseMessageBody:SetText(response..responseSuffix);

		-- clear out the open ticket edit box...the original design called for filling in the edit box with the ticketDescription in case
		-- the player wanted to create a follow-up ticket, but creating a new ticket with your old ticket's text felt strange so I opted
		-- to just clear out the text instead
		HelpFrameOpenTicketEditBox:SetText("");
		HelpFrameOpenTicketSubmit:SetText(SUBMIT);
		HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_FOLLOWUPTEXT);

		-- hide the buttons that edit a ticket and show the buttons that open a ticket
		-- the player shouldn't be able to edit or open a ticket while a response is up, but they will at least be able to view
		-- the information on the various help pages this way
		KnowledgeBaseFrameGMTalk:Show();
		KnowledgeBaseFrameReportIssue:Show();
		HelpFrameStuckOpenTicket:Show();
		KnowledgeBaseFrameEditTicket:Hide();
		KnowledgeBaseFrameAbandonTicket:Hide();
	end
end

function HelpFrame_ShowFrame(key)
	local frameName = helpFrames[key];
	local frame = _G[frameName];
	if ( not frame ) then
		return;
	end

	-- Close previously opened frame
	if ( openFrame ) then
		if ( frame == openFrame ) then
			-- the requested frame is the same as the open frame...do nothing
			return;
		end
		openFrame:Hide();
		tinsert(frameStack, openFrame);
	end

	if ( key == "OpenTicket" ) then
		if ( not HelpFrame_IsGMTicketQueueActive() ) then
			-- Petition queue is down and we're trying to go to the OpenTicket frame, show a dialog instead
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			return;
		end
		if ( haveResponse ) then
			-- if we have a response that hasn't been dealt with and the player is trying to open a new ticket,
			-- give them a warning dialog instead
			HideUIPanel(HelpFrame);
			StaticPopup_Show("GM_RESPONSE_MUST_RESOLVE_RESPONSE");
			return;
		end
	end

	ShowUIPanel(HelpFrame);
	frame:Show();
	openFrame = frame;
end

function HelpFrame_PopFrame()
	if ( not openFrame) then
		return;
	end
	openFrame:Hide();
	local top = tremove(frameStack);
	if ( not top ) then
		HideUIPanel(HelpFrame);
		return;
	end
	top:Show();
	openFrame = top;
end

function HelpFrame_PopAllFrames()
	while #frameStack > 0 do
		tremove(frameStack);
	end
end

function HelpFrame_IsGMTicketQueueActive()
	return ticketQueueActive;
end

function HelpFrame_HaveGMTicket()
	return haveTicket;
end

function HelpFrame_HaveGMResponse()
	return haveResponse;
end


--
-- HelpFrameGMTalk
--

function HelpFrameGMTalk_OnShow(self)
	needResponse = true;
end


--
-- HelpFrameReportIssue
--

function HelpFrameReportIssue_OnShow(self)
	needResponse = false;
end


--
-- HelpFrameStuck
--

function HelpFrameStuck_OnShow(self)
	needResponse = true;
end


--
-- HelpFrameOpenTicket
--

function HelpFrameOpenTicketCancel_OnClick()
	GetGMTicket();
	HelpFrame_PopFrame();
end

function HelpFrameOpenTicketSubmit_OnClick()
	if ( haveResponse ) then
		GMResponseNeedMoreHelp(HelpFrameOpenTicketEditBox:GetText());
	else
		if ( haveTicket ) then
			UpdateGMTicket(HelpFrameOpenTicketEditBox:GetText());
		else
			NewGMTicket(HelpFrameOpenTicketEditBox:GetText(), needResponse);
		end
	end
	HideUIPanel(HelpFrame);
end


--
-- HelpFrameViewResponseButton
--

function HelpFrameViewResponseButton_OnLoad(self)
	local width = self:GetWidth() - 20;
	local deltaWidth = self:GetTextWidth() - width;
	if ( deltaWidth > 0 ) then
		self:SetWidth(width + deltaWidth + 40);
	end
end


--
-- HelpFrameViewResponseMoreHelp
--

function HelpFrameViewResponseMoreHelp_OnClick(self)
	StaticPopup_Show("GM_RESPONSE_NEED_MORE_HELP");
end


--
-- HelpFrameViewResponseIssueResolved
--

function HelpFrameViewResponseIssueResolved_OnClick(self)
	StaticPopup_Show("GM_RESPONSE_RESOLVE_CONFIRM");
end


--
-- TicketStatusFrame
--

function TicketStatusFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_TICKET");
	self:RegisterEvent("GMRESPONSE_RECEIVED");
end

function TicketStatusFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_TICKET" ) then
		local category = ...;
		if ( (category or self.hasGMSurvey) and (not GMChatStatusFrame or not GMChatStatusFrame:IsShown()) ) then
			self:Show();
			refreshTime = GMTICKET_CHECK_INTERVAL;
		else
			self:Hide();
		end
	elseif ( event == "GMRESPONSE_RECEIVED" ) then
		if ( not GMChatStatusFrame or not GMChatStatusFrame:IsShown() ) then
			self:Show();
		else
			self:Hide();
		end
	end
end

function TicketStatusFrame_OnUpdate(self, elapsed)
	if ( haveTicket ) then
		-- Every so often, query the server for our ticket status
		if ( refreshTime ) then
			refreshTime = refreshTime - elapsed;
			if ( refreshTime <= 0 ) then
				refreshTime = GMTICKET_CHECK_INTERVAL;
				GetGMTicket();
			end
		end
		if ( self.ticketTimer ) then
			self.ticketTimer = self.ticketTimer - elapsed;
			TicketStatusTime:SetFormattedText(GM_TICKET_WAIT_TIME, SecondsToTime(self.ticketTimer, 1));
		end
	end
end

function TicketStatusFrame_OnShow(self)
	ConsolidatedBuffs:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", -205, (-self:GetHeight()));
end

function TicketStatusFrame_OnHide(self)
	if( not GMChatStatusFrame or not GMChatStatusFrame:IsShown() ) then
		ConsolidatedBuffs:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -180, -13);
	end
end


--
-- TicketStatusFrameButton
--

function TicketStatusFrameButton_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	-- make sure this frame doesn't cover up the content in the parent
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 1);
end

function TicketStatusFrameButton_OnClick(self)
	if ( TicketStatusFrame.hasGMSurvey ) then
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		TicketStatusFrame:Hide();
	elseif ( StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") ) then
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
	elseif ( StaticPopup_Visible("HELP_TICKET") ) then
		StaticPopup_Hide("HELP_TICKET");
	elseif ( StaticPopup_Visible("GM_RESPONSE_NEED_MORE_HELP") ) then
		StaticPopup_Hide("GM_RESPONSE_NEED_MORE_HELP");
	elseif ( StaticPopup_Visible("GM_RESPONSE_RESOLVE_CONFIRM") ) then
		StaticPopup_Hide("GM_RESPONSE_RESOLVE_CONFIRM");
	elseif ( StaticPopup_Visible("GM_RESPONSE_CANT_OPEN_TICKET") ) then
		StaticPopup_Hide("GM_RESPONSE_CANT_OPEN_TICKET");
	elseif ( not HelpFrame:IsShown() and not KnowledgeBaseFrame:IsShown() ) then
		if ( haveResponse ) then
			HelpFrame_ShowFrame("GMResponse");
		elseif ( haveTicket ) then
			StaticPopup_Show("HELP_TICKET");
		end
	end
end

function HelpReportLag(kind)
	HideUIPanel(HelpFrame);
	GMReportLag(STATIC_CONSTANTS[kind]);
	StaticPopup_Show("LAG_SUCCESS");
end

