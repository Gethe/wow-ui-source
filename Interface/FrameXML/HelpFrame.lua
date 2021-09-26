
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

--Store all possible windows the HelpFrame will open.
HelpFrameWindows = {}

-- Side Navigation Table
HelpFrameNavTbl = {}
HelpFrameNavTbl[1] = {	text = KNOWLEDGE_BASE,
						icon ="Interface\\HelpFrame\\HelpIcon-KnowledgeBase",
						frame = "kbase"
					};
HelpFrameNavTbl[2] = {	text = HELPFRAME_ACCOUNTSECURITY_TITLE,
						icon ="Interface\\HelpFrame\\HelpIcon-AccountSecurity",
						frame = "asec"
					};
HelpFrameNavTbl[3] = {	text = HELPFRAME_STUCK_TITLE,
						icon ="Interface\\HelpFrame\\HelpIcon-CharacterStuck",
						frame = "stuck"
					};
HelpFrameNavTbl[4] = {	text = HELPFRAME_REPORT_BUG_TITLE,
						icon="Interface\\HelpFrame\\HelpIcon-Bug",
						frame = "bug"
					};
HelpFrameNavTbl[5] = {	text = HELPFRAME_REPORT_PLAYER_TITLE,
						icon="Interface\\HelpFrame\\HelpIcon-ReportAbuse",
						frame = "report"
					};
HelpFrameNavTbl[6] = {	text = HELP_TICKET_OPEN,
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "ticketHelp"
					};

--LAG REPORITNG BUTTONS
HelpFrameNavTbl[7] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Loot",
						tooltipTex = BUTTON_LAG_LOOT_TOOLTIP,
						newbieText = BUTTON_LAG_LOOT_NEWBIE
					};
HelpFrameNavTbl[8] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-AuctionHouse",
						tooltipTex = BUTTON_LAG_AUCTIONHOUSE_TOOLTIP,
						newbieText = BUTTON_LAG_AUCTIONHOUSE_NEWBIE
					};
HelpFrameNavTbl[9] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Mail",
						tooltipTex = BUTTON_LAG_MAIL_TOOLTIP,
						newbieText = BUTTON_LAG_MAIL_NEWBIE
					};
HelpFrameNavTbl[10] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Chat",
						tooltipTex = BUTTON_LAG_CHAT_TOOLTIP,
						newbieText = BUTTON_LAG_CHAT_NEWBIE
					};
HelpFrameNavTbl[11] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Movement",
						tooltipTex = BUTTON_LAG_MOVEMENT_TOOLTIP,
						newbieText = BUTTON_LAG_MOVEMENT_NEWBIE
					};
HelpFrameNavTbl[12] = {	icon ="Interface\\HelpFrame\\ReportLagIcon-Spells",
						tooltipTex = BUTTON_LAG_SPELL_TOOLTIP,
						newbieText = BUTTON_LAG_SPELL_NEWBIE
					};
-- Open Ticket Buttons
HelpFrameNavTbl[13] = {	text = KBASE_TOP_ISSUES,
						icon ="Interface\\HelpFrame\\HelpIcon-HotIssues",
						frame = "kbase",
						func = "KnowledgeBase_GotoTopIssues",
					};
HelpFrameNavTbl[14] = {	text = HELP_TICKET_OPEN, -- HELP_TICKET_EDIT
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "ticketHelp"
					};

--THis needs implementing - CHaz
HelpFrameNavTbl[15] = {	text = HELP_TICKET_OPEN,
						icon ="Interface\\HelpFrame\\HelpIcon-OpenTicket",
						frame = "GM_response"
					};

HelpFrameNavTbl[16] = {	text = HELPFRAME_SUBMIT_SUGGESTION_TITLE,
						icon ="Interface\\HelpFrame\\HelpIcon-Suggestion",
						frame = "suggestion"
					};
HelpFrameNavTbl[17]	= { text = HELPFRAME_ITEM_RESTORATION,
						icon ="Interface\\HelpFrame\\HelpIcon-ItemRestoration",
						func = function() StaticPopup_Show("CONFIRM_LAUNCH_URL", nil, nil, {index=3}) end,
						noSelection = true,
					};


KBASE_BUTTON_HEIGHT = 28; -- This is button height plus the offset
KBASE_NUM_ARTICLES_PER_PAGE = 100; -- Obsolete


-- global data
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes

HELPFRAME_START_PAGE			= 1; -- KNOWLEDGE_BASE;
HELPFRAME_KNOWLEDGE_BASE		= 1;
HELPFRAME_ACCOUNT_SECURITY		= 2;
HELPFRAME_CARACTER_STUCK		= 3;
HELPFRAME_SUBMIT_BUG			= 4;
HELPFRAME_REPORT_ABUSE			= 5;
HELPFRAME_OPEN_TICKET			= 6;
HELPFRAME_SUBMIT_SUGGESTION		= 16;

HELPFRAME_SUBMIT_TICKET			= 14;
HELPFRAME_GM_RESPONSE			= 15;


-- local data
local refreshTime;
local ticketQueueActive = true;

local haveTicket = false;		-- true if the server tells us we have an open ticket
local haveResponse = false;		-- true if we got a GM response to a previous ticket
local needResponse = true;		-- true if we want a GM to contact us when we open a new ticket (Note:  This flag is always true right now)
local needMoreHelp = false;

local kbsetupLoaded = false;


-- Browser data
local BROWSER_TOOLTIP_BUTTON_WIDTH = 150;

--
-- HelpFrame
--


function HelpFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_GM_STATUS");
	self:RegisterEvent("QUICK_TICKET_SYSTEM_STATUS");
	self:RegisterEvent("QUICK_TICKET_THROTTLE_CHANGED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_PROXY_FAILED");
	self:RegisterEvent("SIMPLE_BROWSER_WEB_ERROR");


	self.leftInset.Bg:SetTexture("Interface\\HelpFrame\\Tileable-Parchment", true, true);

	self.header.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true);
	self.header.Bg:SetHorizTile(true);
	self.header.Bg:SetVertTile(true);

	self.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true);
	self.Bg:SetHorizTile(true);
	self.Bg:SetVertTile(true);

	HelpFrame_UpdateQuickTicketSystemStatus();
end

function HelpFrame_OnShow(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	GetGMStatus();
	-- hearthstone button events
	local button = HelpFrameCharacterStuckHearthstone;
	button:RegisterEvent("BAG_UPDATE_COOLDOWN");
	button:RegisterEvent("BAG_UPDATE");
	button:RegisterEvent("SPELL_UPDATE_USABLE");
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	HelpFrame_UpdateQuickTicketSystemStatus();
end

function HelpFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
	-- hearthstone button events
	local button = HelpFrameCharacterStuckHearthstone;
	button:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	button:UnregisterEvent("BAG_UPDATE");
	button:UnregisterEvent("SPELL_UPDATE_USABLE");
	button:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	button:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
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
			if ( status == GMTICKET_QUEUE_STATUS_DISABLED ) then
				StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			end
		end
	elseif ( event == "QUICK_TICKET_SYSTEM_STATUS" or event == "QUICK_TICKET_THROTTLE_CHANGED" ) then
		HelpFrame_UpdateQuickTicketSystemStatus();
	elseif ( event == "SIMPLE_BROWSER_WEB_PROXY_FAILED" ) then
		StaticPopup_Show("WEB_PROXY_FAILED");
	elseif ( event == "SIMPLE_BROWSER_WEB_ERROR" ) then
		local errorNumber = tonumber(...);
		StaticPopup_Show("WEB_ERROR", errorNumber);
	end
end

function HelpFrame_UpdateSubsystemStatus(key, enabled)
	if ( enabled ) then
		HelpFrame_SetButtonEnabled(HelpFrame["button"..key], true);
	else
		if ( HelpFrame.selectedId == key ) then
			HelpFrame.button1:Click();
		end
		HelpFrame_SetButtonEnabled(HelpFrame["button"..key], false);
	end
end

function HelpFrame_UpdateQuickTicketSystemStatus()
	HelpFrame_UpdateSubsystemStatus(HELPFRAME_SUBMIT_BUG, GMEuropaBugsEnabled() and not GMQuickTicketSystemThrottled());
	HelpFrame_UpdateSubsystemStatus(HELPFRAME_SUBMIT_SUGGESTION, GMEuropaSuggestionsEnabled() and not GMQuickTicketSystemThrottled());
	HelpFrame_UpdateSubsystemStatus(HELPFRAME_REPORT_ABUSE, GMEuropaComplaintsEnabled() and not GMQuickTicketSystemThrottled());
	HelpFrame_UpdateSubsystemStatus(HELPFRAME_OPEN_TICKET, GMEuropaTicketsEnabled() and not GMQuickTicketSystemThrottled());
	HelpFrame_UpdateSubsystemStatus(HELPFRAME_ACCOUNT_SECURITY, GMEuropaTicketsEnabled() and not GMQuickTicketSystemThrottled());
end

function HelpFrame_ShowFrame(key)
	local testEnabled = IsTestBuild() and GMEuropaBugsEnabled() and not GMQuickTicketSystemThrottled();
	if ( testEnabled ) then
		key = key or HelpFrame.selectedId or HELPFRAME_SUBMIT_BUG;
	else
		key = key or HelpFrame.selectedId or HELPFRAME_START_PAGE;
	end
	if HelpFrameNavTbl[key].button and HelpFrameNavTbl[key].button:IsEnabled() then
		HelpFrameNavTbl[key].button:Click();
	else
		-- if the button was not enabled then it's not a user click so force the frame
		HelpFrame_SetFrameByKey(key);
	end

	if ( key == HELPFRAME_SUBMIT_TICKET ) then
		if ( not HelpFrame_IsGMTicketQueueActive() ) then
			-- Petition queue is down and we're trying to go to the OpenTicket frame, show a dialog instead
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
			return;
		end
	end

	ShowUIPanel(HelpFrame);
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

function HelpFrame_GMResponse_Acknowledge(markRead)
	haveResponse = false;
	if ( markRead ) then
		needMoreHelp = false;
		GMResponseResolve();
		HelpFrame_ShowFrame(HELPFRAME_OPEN_TICKET);
	else
		needMoreHelp = true;
		HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET);
	end
	if ( not TicketStatusFrame.hasGMSurvey and TicketStatusFrame:IsShown() ) then
		TicketStatusFrame:Hide();
	end
end

function HelpFrame_SetFrameByKey(key)
	HelpBrowser:Hide();
	local data = HelpFrameNavTbl[key];
	if data.frame then
		local showFrame = HelpFrame[data.frame];
		for a,frame in pairs(HelpFrameWindows) do
			if showFrame ~= frame then
				frame:Hide();
			end
		end
		showFrame:Show();
	end
	if data.func then
		if ( type(data.func) == "function" ) then
			data.func();
		else
			_G[data.func]();
		end
	end
end

function HelpFrame_SetSelectedButton(button)
	button.selected:Show();
	if HelpFrame.disabledButton and HelpFrame.disabledButton ~= button then
		HelpFrame.disabledButton.selected:Hide();
		HelpFrame.disabledButton:Enable();
	end
	button:Disable();
	HelpFrame.disabledButton = button;
	HelpFrame.selectedId = button:GetID();
end

function HelpFrame_SetTicketButtonText(text)
	HelpFrame.button6:SetText(text);
	HelpFrame.asec.ticketButton:SetText(text);
	HelpFrame.ticketHelp.ticketButton:SetText(text);
end

function HelpFrame_SetButtonEnabled(button, enabled)
	if ( enabled ) then
		button:Enable();
		button:GetNormalTexture():SetDesaturated(false);
		button.icon:SetDesaturated(false);
		button.icon:SetVertexColor(1, 1, 1);
		button.text:SetFontObject(GameFontNormalMed3);
	else
		button:Disable();
		button:GetNormalTexture():SetDesaturated(true);
		button.icon:SetDesaturated(true);
		button.icon:SetVertexColor(0.5, 0.5, 0.5);
		button.text:SetFontObject(GameFontDisableMed3);
	end
end

function HelpFrame_ShowReportCheatingDialog(playerLocation)
	local frame = ReportCheatingDialog;
	frame.target = playerLocation;
	frame.CommentFrame.EditBox:SetText("");
	frame.CommentFrame.EditBox.InformationText:Show();
	StaticPopupSpecial_Show(frame);
end

--
-- HelpFrameStuck
--

function HelpFrameStuckHearthstone_UpdateTooltip(self)
	self:GetScript("OnEnter")(self);
end

function HelpFrameStuckHearthstone_Update(self)
	local hearthstoneID = PlayerHasHearthstone();
	local cooldown = self.Cooldown;
	local start, duration, enable = GetItemCooldown(hearthstoneID or 0);
	CooldownFrame_Set(cooldown, start, duration, enable);
	if (not hearthstoneID or duration > 0 and enable == 0) then
		self.IconTexture:SetVertexColor(0.4, 0.4, 0.4);
	else
		self.IconTexture:SetVertexColor(1, 1, 1);
	end

	if (hearthstoneID) then
		self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
		self.IconTexture:SetDesaturated(false);
		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(hearthstoneID);
		self.IconTexture:SetTexture(texture);
	else
		self:SetHighlightTexture(nil);
		self.IconTexture:SetDesaturated(true);
		self.IconTexture:SetTexture("Interface\\Icons\\inv_misc_rune_01");
	end

	if (GameTooltip:GetOwner() == self) then
		self:UpdateTooltip();
	end
end

--
-- AccountSecurity
--

function AccountSecurityOpenTicket_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local data = HelpFrameNavTbl[self:GetID()];
	if ( not data.noSelection ) then
		HelpFrame_SetSelectedButton(self);
	end
	HelpFrame_SetFrameByKey(self:GetID());
end

--
-- HelpFrameSubmitBug
--

function HelpFrameReportBugSubmit_OnClick()
	local bugText = HelpFrameReportBugEditBox:GetText();
	GMSubmitBug(bugText);
	HelpFrameReportBugEditBox:SetText("");
	HideUIPanel(HelpFrame);
end

--
-- HelpFrameSubmitSuggestion
--
function HelpFrameSubmitSuggestionSubmit_OnClick()
	local suggestionText = HelpFrameSubmitSuggestionEditBox:GetText();
	GMSubmitSuggestion(suggestionText);
	HelpFrameSubmitSuggestionEditBox:SetText("");
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
-- HelpOpenTicketButton
--
function HelpOpenTicketButton_OnUpdate(self, elapsed)
	if ( haveTicket ) then
		-- Every so often, query the server for our ticket status
		if ( self.refreshTime ) then
			self.refreshTime = self.refreshTime - elapsed;
			if ( self.refreshTime <= 0 ) then
				self.refreshTime = GMTICKET_CHECK_INTERVAL;
				GetGMTicket();
			end
		end

		local timeText;
		if ( self.ticketTimer ) then
			self.ticketTimer = self.ticketTimer - elapsed;
			timeText.format(GM_TICKET_WAIT_TIME, SecondsToTime(self.ticketTimer, 1));
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine(self.titleText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		GameTooltip:AddLine(self.statusText);
		if (timeText) then
			GameTooltip:AddLine(timeText);
		end

		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		GameTooltip:Show();
	elseif ( haveResponse ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(GM_RESPONSE_ALERT, nil, nil, nil, nil, true);
	elseif ( TicketStatusFrame.hasGMSurvey ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(CHOSEN_FOR_GMSURVEY, nil, nil, nil, nil, true);
	end
end

function HelpOpenTicketButton_Update()
	local self = HelpOpenTicketButton;
	if ( self.haveTicket or TicketStatusFrame.hasGMSurvey ) then
		self:Show();
	else
		self:Hide();
	end
end

--
-- HelpOpenWebTicketButton
--

function HelpOpenWebTicketButton_OnEnter(self, elapsed)
	if ( self.haveTicket ) then
		if ( self.haveResponse ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:SetText(GM_RESPONSE_ALERT, nil, nil, nil, nil, true);
		elseif ( self.hasGMSurvey ) then
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:SetText(CHOSEN_FOR_GMSURVEY, nil, nil, nil, nil, true);
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
		self.hasGMSurvey = false;
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
		TicketStatusTime:SetText("");
		TicketStatusTime:Hide();
		if (hasTicket and ticketStatus ~= LE_TICKET_STATUS_OPEN) then
			self.hasWebTicket = true;
			if (ticketStatus == LE_TICKET_STATUS_NMI) then --need more info
				TicketStatusTitleText:SetText(TICKET_STATUS_NMI);
			elseif (ticketStatus == LE_TICKET_STATUS_SURVEY) then --survey is ready
				TicketStatusTitleText:SetText(CHOSEN_FOR_GMSURVEY);
				self:SetHeight(TicketStatusTitleText:GetHeight() + 20);
				self.haveWebSurvey = true;
			elseif (ticketStatus == LE_TICKET_STATUS_RESPONSE) then --ticket has been responded to
				TicketStatusTitleText:SetText(GM_RESPONSE_ALERT);
				self.haveResponse = true;
			end
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
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	-- make sure this frame doesn't cover up the content in the parent
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 1);
end

function TicketStatusFrameButton_OnClick(self)
	if (TicketStatusFrame.hasWebTicket and TicketStatusFrame.caseIndex) then
		HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET)
		HelpBrowser:OpenTicket(TicketStatusFrame.caseIndex)
		TicketStatusFrame.haveWebSurveyClicked = TicketStatusFrame.haveWebSurvey
		TicketStatusFrame:Hide()
		return;
	end
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
	elseif ( haveResponse ) then
		HelpFrame_SetFrameByKey(HELPFRAME_OPEN_TICKET);
		if ( not HelpFrame:IsShown() ) then
			ShowUIPanel(HelpFrame);
		end
	end
end

function HelpReportLag(kind)
	HideUIPanel(HelpFrame);
	GMReportLag(STATIC_CONSTANTS[kind]);
	StaticPopup_Show("LAG_SUCCESS");
end

-------------- Knowledgebase Functions ------------------
-------------- Knowledgebase Functions ------------------
-------------- Knowledgebase Functions ------------------

function KnowledgeBase_OnLoad(self)
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE");


	local homeData = {
		name = HOME,
		OnClick = KnowledgeBase_DisplayCategories,
		listFunc = KnowledgeBase_GetCategoryList,
	}
	self.navBar.textMaxWidth = 117;
	self.navBar.oldStyle = true;
	NavBar_Initialize(self.navBar, "HelpFrameNavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	--Scroll Frame
	self.scrollFrame.update = KnowledgeBase_UpdateArticles;
	self.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "KnowledgeBaseArticleTemplate", 8, -3, "TOPLEFT", "TOPLEFT", 0, -3);

	--Scroll Frame 2
	self.scrollFrame2.child:SetWidth(self.scrollFrame2:GetWidth());
	local childWidth = self.scrollFrame2.child:GetWidth();
	self.articleTitle:SetWidth(childWidth - 40);
	self.articleText:SetWidth(childWidth - 30);
end


function KnowledgeBase_OnShow(self)
	HelpBrowser:Show();
	if ( not kbsetupLoaded ) then
		KnowledgeBase_GotoTopIssues();
	else
		HelpBrowser:NavigateHome("KnowledgeBase");
	end

	HelpBrowser.homepage = "KnowledgeBase"
	HideKnowledgeBase();
end

function HideKnowledgeBase()
	HelpFrameKnowledgebaseStoneTex:Hide();
	HelpFrameKnowledgebaseTopTileStreaks:Hide();
	HelpFrameKnowledgebaseSearchBox:Hide();
	HelpFrameKnowledgebaseSearchButton:Hide();
	HelpFrameKnowledgebaseNavBar:Hide();
	HelpFrameKnowledgebaseScrollFrame:Hide();
	HelpFrameKnowledgebaseScrollFrame2:Hide();
end

function ShowKnowledgeBase()
	HelpFrameKnowledgebaseStoneTex:Show();
	HelpFrameKnowledgebaseTopTileStreaks:Show();
	HelpFrameKnowledgebaseSearchBox:Show();
	HelpFrameKnowledgebaseSearchButton:Show();
	HelpFrameKnowledgebaseNavBar:Show();
	HelpFrameKnowledgebaseScrollFrame:Show();
	HelpFrameKnowledgebaseScrollFrame2:Show();
end

function KnowledgeBase_OnEvent(self, event, ...)
	if ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS") then
		kbsetupLoaded = true;
		KnowledgeBase_SnapToTopIssues();
	elseif ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
		kbsetupLoaded = false;
	elseif ( event == "KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS" ) then
		local totalArticleHeaderCount = KBQuery_GetTotalArticleCount();

		if ( totalArticleHeaderCount > 0 ) then
			self.scrollFrame.ScrollBar:SetValue(0);
			self.totalArticleCount = totalArticleHeaderCount;
			self.dataFunc = KBQuery_GetArticleHeaderData;
			KnowledgeBase_UpdateArticles();
			KnowledgeBase_HideErrorFrame(self, KBASE_ERROR_NO_RESULTS);
		else
			KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_NO_RESULTS);
		end
	elseif ( event == "KNOWLEDGE_BASE_QUERY_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
	elseif ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS" ) then
		local id, subject, subjectAlt, text, keywords, languageId, isHot = KBArticle_GetData();
		self.articleTitle:SetText(subject);
		self.articleText:SetText(text);
		self.articleId:SetFormattedText(KBASE_ARTICLE_ID, id);
		self.scrollFrame2.ScrollBar:SetValue(0);

		self.scrollFrame:Hide();
		self.scrollFrame2:Show();
	elseif ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE" ) then
		KnowledgeBase_ShowErrorFrame(self, KBASE_ERROR_LOAD_FAILURE);
	end
end


function KnowledgeBase_Clearlist()
	local self = HelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		button:Hide();
		button:SetScript("OnClick", nil);
	end

	scrollFrame.ScrollBar:SetValue(0);
	scrollFrame.update = KnowledgeBase_Clearlist;
end


function KnowledgeBase_UpdateArticles()
	local self = HelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	self.scrollFrame2:Hide();
	self.scrollFrame:Show();

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if index <= self.totalArticleCount  then
			local articleId, articleHeader, isArticleHot, isArticleUpdated = self.dataFunc(index);
			button.number:SetText(index .. ".");
			button.title:SetPoint("LEFT", button.number, "RIGHT", 5, 0);

			button.articleId = articleId;
			button.articleHeader = articleHeader;

			local titleText = articleHeader
			if ( isArticleUpdated ) then
				titleText = "|TInterface\\GossipFrame\\AvailableQuestIcon:0:0:0:0|t "..titleText
			end
			if ( isArticleHot ) then
				titleText = "|TInterface\\HelpFrame\\HotIssueIcon:0:0:0:0|t "..titleText
			end
			button.title:SetText(titleText);
			button:SetScript("OnClick", KnowledgeBase_ArticleOnClick);

			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick", nil);
		end
	end

	scrollFrame.update = KnowledgeBase_UpdateArticles;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*self.totalArticleCount, scrollFrame:GetHeight());
end


function KnowledgeBase_ResendArticleRequest(self)
	KnowledgeBase_Clearlist();

	KBQuery_BeginLoading("",
		self.data.category,
		self.data.subcategory,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);

	HelpFrame.kbase.category = self.data.category;
	HelpFrame.kbase.subcategory = self.data.subcategory;

	KnowledgeBase_ClearSearch(HelpFrame.kbase.searchBox);
end


function KnowledgeBase_SendArticleRequest(categoryIndex, subcategoryIndex)
	KnowledgeBase_Clearlist();
	local buttonText = ALL;
	if subcategoryIndex ~= 0 then
		local list = KnowledgeBase_GetSubCategoryList(nil, categoryIndex);
		local entry = list and list[subcategoryIndex+1];
		buttonText = entry and entry.text;
	end

	local buttonData = {
		name = buttonText,
		OnClick = KnowledgeBase_ResendArticleRequest,
		category = categoryIndex,
		subcategory = subcategoryIndex,
	}
	NavBar_AddButton(HelpFrame.kbase.navBar, buttonData);

	KBQuery_BeginLoading("",
		categoryIndex,
		subcategoryIndex,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);

	HelpFrame.kbase.category = categoryIndex;
	HelpFrame.kbase.subcategory = subcategoryIndex;

	KnowledgeBase_ClearSearch(HelpFrame.kbase.searchBox);
end


function KnowledgeBase_SelectCategory(self, index, navBar) -- Index could also be the button used
	if type(index) ~= "number" then
		index = self.index;
	end
	HelpFrame.kbase.category = nil;

	if index == 1  then
		KnowledgeBase_SendArticleRequest(0,0);
		HelpFrame.kbase.category = 0
	elseif index == 2  then
		KnowledgeBase_GotoTopIssues();
	else
		KnowledgeBase_DisplaySubCategories(index-2);
		HelpFrame.kbase.category = index-2;
	end

	KnowledgeBase_ClearSearch(HelpFrame.kbase.searchBox);
end


function KnowledgeBase_SelectSubCategory(self, index, navBar) -- Index could also be the button used
	if type(index) ~= "number" then
		index = self.index;
	end
	HelpFrame.kbase.subcategory = index-1;
	KnowledgeBase_SendArticleRequest(HelpFrame.kbase.category, index-1);

	KnowledgeBase_ClearSearch(HelpFrame.kbase.searchBox);
end


function KnowledgeBase_GetCategoryList(self)
	local list = { };
	local numCata = KBSetup_GetCategoryCount()+2;
	for index = 1, numCata do
		local _, text;
		if ( index == 1 ) then
			text = ALL;
		elseif index == 2  then
			text = KBASE_TOP_ISSUES;
		else
			_, text = KBSetup_GetCategoryData(index-2);
		end
		local entry = { text = text, id = index, func = KnowledgeBase_SelectCategory };
		tinsert(list, entry);
	end
	return list;
end


function KnowledgeBase_DisplayCategories()
	if( not kbsetupLoaded ) then
		--never loaded the setup so load setup and go to top issues.
		KnowledgeBase_GotoTopIssues();
		return;
	end

	local self = HelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numCata = KBSetup_GetCategoryCount()+2;
	KnowledgeBase_ClearSearch(HelpFrame.kbase.searchBox);


	HelpFrame.kbase.category = nil;
	HelpFrame.kbase.subcategory = nil;

	self.scrollFrame2:Hide();
	self.scrollFrame:Show();

	local showButton = false;
	for i = 1, numButtons do
		showButton = false;
		local button = buttons[i];
		local index = offset + i;
		local list = KnowledgeBase_GetCategoryList(self);
		local entry = list and list[index];
		if entry then
			button.number:SetText("");
			button.title:SetPoint("LEFT", 10, 0);
			button.title:SetText(entry.text);
			button:SetScript("OnClick",	entry.func);
			button.index = index;
			showButton = true;
		end

		if showButton then
			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick",	nil);
		end
	end

	scrollFrame.update = KnowledgeBase_DisplayCategories;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*(numCata), scrollFrame:GetHeight());
end


function KnowledgeBase_GetSubCategoryList(self, category)
	category = category or self.data.category;
	local list = { };
	local numSubCata = KBSetup_GetSubCategoryCount(category)+1;
	for index = 1, numSubCata do
		local _, text;
		if ( index == 1 ) then
			text = ALL;
		else
			_, text = KBSetup_GetSubCategoryData(category, index-1);
		end
		local entry = { text = text, id = index, func = KnowledgeBase_SelectSubCategory };
		tinsert(list, entry);
	end
	return list;
end


function KnowledgeBase_DisplaySubCategories(category)
	HelpFrame.kbase.subcategory = nil;

	if category and type(category) == "number" then
		local _, cat_name = KBSetup_GetCategoryData(category);
		local buttonData = {
			name = cat_name,
			OnClick = KnowledgeBase_DisplaySubCategories,
			listFunc = KnowledgeBase_GetSubCategoryList,
			category = category,
		}
		NavBar_AddButton(HelpFrame.kbase.navBar, buttonData);
		HelpFrame.kbase.category = category;
	else
		--Updating because of Scrolling
		category = HelpFrame.kbase.category;
	end

	local self = HelpFrame.kbase;
	local scrollFrame = self.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numSubCata = KBSetup_GetSubCategoryCount(category)+1;

	self.scrollFrame2:Hide();
	self.scrollFrame:Show();

	local showButton = false;
	for i = 1, numButtons do
		showButton = false;
		local button = buttons[i];
		local index = offset + i;
		local list = KnowledgeBase_GetSubCategoryList(self, category);
		local entry = list and list[index];
		if entry then
			button.number:SetText("");
			button.title:SetPoint("LEFT", 10, 0);
			button.title:SetText(entry.text);
			button:SetScript("OnClick",	entry.func);
			button.index = index;
			showButton = true;
		end

		if showButton then
			button:Show();
		else
			button:Hide();
			button:SetScript("OnClick",	nil);
		end
	end

	scrollFrame.update = KnowledgeBase_DisplaySubCategories;
	HybridScrollFrame_Update(scrollFrame, KBASE_BUTTON_HEIGHT*(numSubCata), scrollFrame:GetHeight());
end


function KnowledgeBase_ShowErrorFrame(self, message)
	self.errorFrame.text:SetText(message);
	self.errorFrame:Show();
end

function KnowledgeBase_HideErrorFrame(self, message)
	if ( self.errorFrame.text:GetText() == message ) then
		self.errorFrame:Hide();
	end
end

---------------Kbase button functions--------------
---------------Kbase button functions--------------
---------------Kbase button functions--------------
function KnowledgeBase_SnapToTopIssues()
	KnowledgeBase_Clearlist();
	if( kbsetupLoaded ) then
		local totalArticleHeaderCount = KBSetup_GetTotalArticleCount();

		if ( totalArticleHeaderCount > 0 ) then
			HelpFrame.kbase.totalArticleCount = totalArticleHeaderCount;
			HelpFrame.kbase.dataFunc = KBSetup_GetArticleHeaderData;
			KnowledgeBase_UpdateArticles();
			KnowledgeBase_HideErrorFrame(HelpFrame.kbase, KBASE_ERROR_NO_RESULTS);
		else
			KnowledgeBase_ShowErrorFrame(HelpFrame.kbase, KBASE_ERROR_NO_RESULTS);
		end
	else
		--KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, 0);
	end
end

function KnowledgeBase_GotoTopIssues()
	HelpBrowser:NavigateHome("KnowledgeBase");
	NavBar_Reset(HelpFrame.kbase.navBar);
	KnowledgeBase_Clearlist();
	local buttonData = {
		name = KBASE_TOP_ISSUES,
		OnClick = KnowledgeBase_SnapToTopIssues,
	}
	NavBar_AddButton(HelpFrame.kbase.navBar, buttonData);
	KnowledgeBase_SnapToTopIssues();
end


function KnowledgeBase_ArticleOnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local buttonData = {
		name = self.articleHeader,
	}
	NavBar_AddButton(HelpFrame.kbase.navBar, buttonData);

	local searchType = 1;
	KBArticle_BeginLoading(self.articleId, searchType);
	KnowledgeBase_Clearlist();
end


function KnowledgeBase_Search()
	KnowledgeBase_Clearlist();
	if ( not KBSetup_IsLoaded() ) then
		return;
	end

	HelpFrame.kbase.category = 0;
	HelpFrame.kbase.subcategory = 0;

	local searchText = HelpFrame.kbase.searchBox:GetText();
	if HelpFrame.kbase.searchBox.inactive then
		searchText = "";
	end

	NavBar_Reset(HelpFrame.kbase.navBar);
	local buttonData = {
		name = KBASE_SEARCH_RESULTS,
		OnClick = KnowledgeBase_Search,
	}
	NavBar_AddButton(HelpFrame.kbase.navBar, buttonData);

	KBQuery_BeginLoading(searchText,
		0,
		0,
		KBASE_NUM_ARTICLES_PER_PAGE,
		0);

	HelpFrame.kbase.hasSearch = true;
end

function KnowledgeBase_ClearSearch(self)
	EditBox_ClearFocus(self);
	self:SetText(SEARCH);
	self:SetFontObject("GameFontDisable");
	self.icon:SetVertexColor(0.6, 0.6, 0.6);
	self.inactive = true;
	self.clearButton:Hide();
	self:GetParent().searchButton:Disable();
	HelpFrame.kbase.hasSearch = false;
end


local hasResized = false;
function HelpBrowser_ToggleTooltip(button, browser)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (BrowserSettingsTooltip:IsShown()) then
		BrowserSettingsTooltip:Hide();
		BrowserSettingsTooltip.browser = nil;
	else
		BrowserSettingsTooltip:SetParent(button)
		BrowserSettingsTooltip:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, 0);
		BrowserSettingsTooltip:Show();
		BrowserSettingsTooltip.browser = browser;
	end

	--resize the tooltip for different languages. Make sure buttons are the same width so they don't look weird
	if (not hasResized) then
		local tooltip = BrowserSettingsTooltip;
		local maxWidth = tooltip.Title:GetWidth()
		local buttonWidth = tooltip.CookiesButton:GetTextWidth();
		buttonWidth = buttonWidth + 20; --add button padding
		buttonWidth = max(buttonWidth, BROWSER_TOOLTIP_BUTTON_WIDTH);
		maxWidth = max(buttonWidth, maxWidth);
		maxWidth = maxWidth + 20; --add tooltip padding
		tooltip.CookiesButton:SetWidth(buttonWidth);
		tooltip:SetWidth(maxWidth);
		hasResized = true;
	end
end

--for race conditions with the spinner
local loading = nil;
local logging = nil;
function Browser_UpdateButtons(self, action)
	if (action == "enableback") then
		self.back:Enable();
	elseif (action == "disableback") then
		self.back:Disable();
	elseif (action == "enableforward") then
		self.forward:Enable();
	elseif (action == "disableforward") then
		self.forward:Disable();
	elseif (action == "startloading") then
		self.stop:Show();
		self.reload:Hide();
		loading = true;
	elseif (action == "doneloading") then
		self.stop:Hide();
		self.reload:Show();
		loading = nil;
	elseif (action == "loggingin") then
		logging = true;
	elseif (action == "notloggingin") then
		logging = nil;
	end

	if (loading or logging) then
		self.loading:Show();
		self.loading.Loop:Play();
	else
		self.loading.Loop:Stop();
		self.loading:Hide();
	end
end
