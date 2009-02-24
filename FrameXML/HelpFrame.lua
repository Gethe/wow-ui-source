HELPFRAME_BULLET_SPACING = -3;
HELPFRAME_SECTION_SPACING = -20;
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes
HELPFRAME_START_PAGE = "KBase";

HELPFRAME_FRAMES = {};
HELPFRAME_FRAMES["GMTalk"] = { name = "HelpFrameGMTalk" };
HELPFRAME_FRAMES["Stuck"] = { name = "HelpFrameStuck" };
HELPFRAME_FRAMES["ReportIssue"] = { name = "HelpFrameReportIssue" };
HELPFRAME_FRAMES["OpenTicket"] = { name = "HelpFrameOpenTicket" };
HELPFRAME_FRAMES["Welcome"] = { name = "HelpFrameWelcome" };
HELPFRAME_FRAMES["KBase"] = { name = "KnowledgeBaseFrame" };

local refreshTime;

PETITION_QUEUE_ACTIVE = 1;

function HelpFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_GM_STATUS");
	self.back = HelpFrameGeneralCancel;

	HelpFrame.frameStack = {};
	HelpFrame.needResponse = true;

	HelpFrame.GMChatFrame = getglobal("ChatFrame"..NUM_CHAT_WINDOWS);
end

function HelpFrame_OnShow()
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	GetGMStatus();
end

function HelpFrame_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	self.back = nil;
	if ( self.openFrame ) then
		self.openFrame:Hide();
		self.openFrame = nil;
	end
	HelpFrame_PopAllFrames();
end

function HelpFrame_OnEvent(self, event, ...)
	if ( event ==  "UPDATE_GM_STATUS" ) then
		local status = ...;
		if ( status == 1 ) then
			PETITION_QUEUE_ACTIVE = 1;
		else
			PETITION_QUEUE_ACTIVE = nil;
			HelpFrameStuckOpenTicket:Disable();
			if ( status == -1 ) then
				StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			end
		end
	end
end

function HelpFrame_ShowFrame(key)
	-- Close previously opened frame
	if ( HelpFrame.openFrame ) then
		HelpFrame.openFrame:Hide();
		tinsert(HelpFrame.frameStack, HelpFrame.openFrame);
	end

	if ( key == "OpenTicket" and not PETITION_QUEUE_ACTIVE ) then
		-- Petition queue is down show a dialog
		HideUIPanel(HelpFrame);
		StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		return;
	end

	-- If key is in the HELPFRAME_FRAMES table, use its name otherwise set to OpenTicket and set the category
	local frame;
	local frameInfo = HELPFRAME_FRAMES[key];
	if ( frameInfo ) then
		frame = getglobal(frameInfo.name);
	else
		frame = getglobal(HELPFRAME_FRAMES["OpenTicket"].name);
	end
	frame:Show();
	HelpFrame.openFrame = frame;
end

function HelpFrame_PopFrame()
	if ( not HelpFrame.openFrame) then
		return;
	end
	HelpFrame.openFrame:Hide();
	local top = tremove(HelpFrame.frameStack);
	if ( not top ) then
		HideUIPanel(HelpFrame);
		return;
	end
	top:Show();
	HelpFrame.openFrame = top;
end

function HelpFrame_PopAllFrames()
	while #HelpFrame.frameStack > 0 do
		tremove(HelpFrame.frameStack);
	end
end

function HelpFrameOpenTicketDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, HelpFrameOpenTicketDropDown_Initialize);
	UIDropDownMenu_SetWidth(HelpFrameOpenTicketDropDown, 335);
end

function HelpFrameOpenTicketDropDown_Initialize()
	local index = 1;
	local ticketType = getglobal("TICKET_TYPE"..index);
	local info = UIDropDownMenu_CreateInfo();
	while (ticketType) do
		info.text = ticketType;
		info.func = HelpFrameOpenTicketDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
		index = index + 1;
		ticketType = getglobal("TICKET_TYPE"..index);
	end
end

function HelpFrameOpenTicketDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedID(HelpFrameOpenTicketDropDown, self:GetID());
end

function HelpFrameOpenTicketDropDown_OnShow()
	GetGMTicket();
end

function HelpFrameOpenTicket_OnEvent(self, event, ...)
	-- If there's a survey to display then fill out info and return
	if ( event == "GMSURVEY_DISPLAY" ) then
		TicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
		TicketStatusTime:Hide();
		TicketStatusFrame.hasGMSurvey = 1;
		TicketStatusFrame:SetHeight(TicketStatusTitleText:GetHeight() + 20);
		TicketStatusFrame:Show();
		HelpFrameOpenTicket.hasTicket = nil;
		UIFrameFlash(TicketStatusFrameButton, 0.75, 0.75, 20);
	elseif ( event == "UPDATE_TICKET" ) then
		local category, ticketDescription, ticketAge, oldestTicketTime, updateTime, assignedToGM, openedByGM = ...;
		-- If there are args then the player has a ticket
		if ( category ) then
			-- Has an open ticket
			TicketStatusTitleText:SetText(TICKET_STATUS1);
			HelpFrameOpenTicket.ticketType = category;
			HelpFrameOpenTicketText:SetText(ticketDescription);
			-- Setup estimated wait time
			--[[
			ticketAge - days
			oldestTicketTime - days
			updateTime - days
				How recent is the data for oldest ticket time, measured in days.  If this number 1 hour, we have bad data.
			assignedToGM
				0 - ticket is not currently assigned to a gm
				1 - ticket is assigned to a normal gm
				2 - ticket is in the escalation queue
			openedByGM
				0 - ticket has never been opened by a gm
				1 - ticket has been opened by a gm
			]]
			local statusText;
			HelpFrameOpenTicket.ticketTimer = nil;
			if ( openedByGM == 1 ) then
				-- if ticket has been opened by a gm
				if ( assignedToGM == 2 ) then
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
					HelpFrameOpenTicket.ticketTimer = estimatedWaitTime;
				else
					statusText = GM_TICKET_SERVICE_SOON;
				end
			end
			if ( statusText ) then
				TicketStatusTime:Show();
				TicketStatusTime:SetText(statusText);
			end

			HelpFrameOpenTicket.hasTicket = 1;
			HelpFrameOpenTicketSubmit:SetText(EDIT_TICKET);
			HelpFrameOpenTicketCancel:SetText(EXIT);
			HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_EDITTEXT);

			-- hide the buttons that open a ticket and show the buttons that edit a ticket
			KnowledgeBaseFrameGMTalk:Hide();
			KnowledgeBaseFrameReportIssue:Hide();
			HelpFrameStuckOpenTicket:Hide();
			KnowledgeBaseFrameOpenTicketEdit:Show();
			KnowledgeBaseFrameOpenTicketCancel:Show();
		else
			-- Doesn't have an open ticket
			HelpFrameOpenTicketText:SetText("");
			HelpFrameOpenTicket.hasTicket = nil;
			HelpFrameOpenTicketSubmit:SetText(SUBMIT);
			HelpFrameOpenTicketCancel:SetText(CANCEL);
			HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_TEXT);

			-- hide the buttons that edit a ticket and show the buttons that open a ticket
			KnowledgeBaseFrameGMTalk:Show();
			KnowledgeBaseFrameReportIssue:Show();
			HelpFrameStuckOpenTicket:Show();
			KnowledgeBaseFrameOpenTicketEdit:Hide();
			KnowledgeBaseFrameOpenTicketCancel:Hide();
		end
	end
end

function HelpFrameOpenTicketCancel_OnClick()
	GetGMTicket();
	HelpFrame_PopFrame();
end

function HelpFrameOpenTicketSubmit_OnClick()
	if ( HelpFrameOpenTicket.hasTicket ) then
		UpdateGMTicket(HelpFrameOpenTicketText:GetText());
		HideUIPanel(HelpFrame);
	else
		NewGMTicket(HelpFrameOpenTicketText:GetText(), HelpFrame.needResponse);

		HideUIPanel(HelpFrame);
	end
end

-- TicketStatusFrame

function TicketStatusFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_TICKET");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TicketStatusFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		GetGMTicket();
	elseif ( event == "UPDATE_TICKET" ) then
		local category = ...;
		if ( category and (not GMChatStatusFrame or not GMChatStatusFrame:IsShown()) ) then
			self:Show();
			refreshTime = GMTICKET_CHECK_INTERVAL;
		else
			self:Hide();
		end
	end
end

-- Every so often, query the server for our ticket status
-- This only gets called if the UI is up for the ticket
function TicketStatusFrame_OnUpdate(self, elapsed)
	if ( HelpFrameOpenTicket.hasTicket ) then
		if ( refreshTime ) then
			refreshTime = refreshTime - elapsed;

			if ( refreshTime <= 0 ) then
				refreshTime = GMTICKET_CHECK_INTERVAL;
				GetGMTicket();
			end
		end
		if ( HelpFrameOpenTicket.ticketTimer ) then
			HelpFrameOpenTicket.ticketTimer = HelpFrameOpenTicket.ticketTimer - elapsed;
			TicketStatusTime:SetFormattedText(GM_TICKET_WAIT_TIME, SecondsToTime(HelpFrameOpenTicket.ticketTimer, 1));
		end
	end
end

function TicketStatusFrameChildren_OnMouseUp()
	local frame = TicketStatusFrame;
	if ( frame.hasGMSurvey ) then
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		frame:Hide();
	elseif ( StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") or StaticPopup_Visible("HELP_TICKET") ) then
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
		StaticPopup_Hide("HELP_TICKET");
	elseif ( not HelpFrame:IsShown() and not KnowledgeBaseFrame:IsShown() ) then
		StaticPopup_Show("HELP_TICKET");
	end
end
