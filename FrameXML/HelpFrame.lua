-- Ugly, but needs to be up here so that the function is defined when you try to add it as a parameter for general frames
function HelpFrameUnstick_OnClick()
	Stuck();
	HideUIPanel(HelpFrame);
end


-- "name" is the name of the frame to open, the index is the trouble ticket category associated with that frame
-- if a tickettype is mapped to HelpFrameGeneral then it should have an entry in the GENERAL_HELPFRAME table so it can configure itself
HELPFRAME_FRAMES = {};
HELPFRAME_FRAMES[1] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[2] = { name = "HelpFrameHarassment"};
HELPFRAME_FRAMES[3] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[4] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[5] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[6] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[7] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[8] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[9] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES[10] = { name = "HelpFrameGeneral"};
HELPFRAME_FRAMES["Stuck"] = { name = "HelpFrameStuck"};
HELPFRAME_FRAMES["GMHome"] = { name = "HelpFrameGM"};
HELPFRAME_FRAMES["Home"] = { name = "HelpFrameHome"};
HELPFRAME_FRAMES["OpenTicket"] = { name = "HelpFrameOpenTicket"};

GENERAL_HELPFRAME = {};
GENERAL_HELPFRAME[1] = {
	title = STUCK_OPTION,
	titleText = HELPFRAME_STUCK_TEXT1,
	buttonText = STUCK_BUTTON_TEXT,
	buttonOnClickFunc = HelpFrameUnstick_OnClick,
	button2Text = STUCK_BUTTON2_TEXT
};
GENERAL_HELPFRAME[3] = {
	title = HELPFRAME_GUILD_TITLE,
	titleText = HELPFRAME_GUILD_TEXT,
	bulletTitle1 = HELPFRAME_GUILD_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_GUILD_BULLET1,
		HELPFRAME_GUILD_BULLET2,
		HELPFRAME_GUILD_BULLET3
	},
	buttonText = HELPFRAME_GUILD_BUTTON_TEXT
};
GENERAL_HELPFRAME[4] = {
	title = HELPFRAME_ITEM_TITLE,
	titleText = HELPFRAME_ITEM_TEXT,
	bulletTitle1 = HELPFRAME_ITEM_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_ITEM_BULLET1,
		HELPFRAME_ITEM_BULLET2,
		HELPFRAME_ITEM_BULLET3,
		HELPFRAME_ITEM_BULLET4,
		HELPFRAME_ITEM_BULLET5
	},
	bulletTitle2 = HELPFRAME_ITEM_BULLET_TITLE2,
	bullets2 = {
		HELPFRAME_ITEM_BULLET6,
		HELPFRAME_ITEM_BULLET7
	},
	buttonText = HELPFRAME_ITEM_BUTTON_TEXT
};
GENERAL_HELPFRAME[5] = {
	title = HELPFRAME_ENVIRONMENTAL_TITLE,
	titleText = HELPFRAME_ENVIRONMENTAL_TEXT,
	bulletTitle1 = HELPFRAME_ENVIRONMENTAL_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_ENVIRONMENTAL_BULLET1,
		HELPFRAME_ENVIRONMENTAL_BULLET2,
		HELPFRAME_ENVIRONMENTAL_BULLET3,
		HELPFRAME_ENVIRONMENTAL_BULLET4,
		
	},
	bulletTitle2 = HELPFRAME_ENVIRONMENTAL_BULLET_TITLE2,
	bullets2 = {
		HELPFRAME_ENVIRONMENTAL_BULLET5,
		HELPFRAME_ENVIRONMENTAL_BULLET6,
	},
	buttonText = HELPFRAME_ENVIRONMENTAL_BUTTON_TEXT
};
GENERAL_HELPFRAME[6] = {
	title = HELPFRAME_NONQUEST_TITLE,
	titleText = HELPFRAME_NONQUEST_TEXT,
	bulletTitle1 = HELPFRAME_NONQUEST_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_NONQUEST_BULLET1,
		HELPFRAME_NONQUEST_BULLET2,
		HELPFRAME_NONQUEST_BULLET3,
		HELPFRAME_NONQUEST_BULLET4,
		
	},
	bulletTitle2 = HELPFRAME_NONQUEST_BULLET_TITLE2,
	bullets2 = {
		HELPFRAME_NONQUEST_BULLET5,
		HELPFRAME_NONQUEST_BULLET6,
		HELPFRAME_NONQUEST_BULLET7
	},
	buttonText = HELPFRAME_NONQUEST_BUTTON_TEXT
};
GENERAL_HELPFRAME[7] = {
	title = HELPFRAME_QUEST_TITLE,
	titleText = HELPFRAME_QUEST_TEXT,
	bulletTitle1 = HELPFRAME_QUEST_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_QUEST_BULLET1,
		HELPFRAME_QUEST_BULLET2,
		HELPFRAME_QUEST_BULLET3,
	},
	bulletTitle2 = HELPFRAME_QUEST_BULLET_TITLE2,
	bullets2 = {
		HELPFRAME_QUEST_BULLET4,
		HELPFRAME_QUEST_BULLET5
	},
	buttonText = HELPFRAME_QUEST_BUTTON_TEXT
};
GENERAL_HELPFRAME[8] = {
	title = HELPFRAME_TECHNICAL_TITLE,
	titleText = HELPFRAME_TECHNICAL_TEXT,
	bulletTitle1 = HELPFRAME_TECHNICAL_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_TECHNICAL_BULLET1,
		HELPFRAME_TECHNICAL_BULLET2,
		HELPFRAME_TECHNICAL_BULLET3,
		HELPFRAME_TECHNICAL_BULLET4,
		HELPFRAME_TECHNICAL_BULLET5,
		HELPFRAME_TECHNICAL_BULLET6,
		HELPFRAME_TECHNICAL_BULLET7,
	},
	endText = HELPFRAME_TECHNICAL_BULLET_TITLE2,
};
GENERAL_HELPFRAME[9] = {
	title = HELPFRAME_ACCOUNT_TITLE,
	titleText = HELPFRAME_ACCOUNT_TEXT,
	bulletTitle1 = HELPFRAME_ACCOUNT_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_ACCOUNT_BULLET1,
		HELPFRAME_ACCOUNT_BULLET2,
		HELPFRAME_ACCOUNT_BULLET3
	},
	endText = HELPFRAME_ACCOUNT_ENDTEXT,
	buttonText = HELPFRAME_ACCOUNT_BUTTON_TEXT
};
GENERAL_HELPFRAME[10] = {
	title = HELPFRAME_CHARACTER_TITLE,
	titleText = HELPFRAME_CHARACTER_TEXT,
	bulletTitle1 = HELPFRAME_CHARACTER_BULLET_TITLE1,
	bullets1 = {
		HELPFRAME_CHARACTER_BULLET1,
		HELPFRAME_CHARACTER_BULLET2,
		HELPFRAME_CHARACTER_BULLET3,
		HELPFRAME_CHARACTER_BULLET4,
		HELPFRAME_CHARACTER_BULLET5
	},
	buttonText = HELPFRAME_CHARACTER_BUTTON_TEXT
};

MAX_GENERAL_BULLETS = 10;
NUM_GM_CATEGORIES_TO_DISPLAY = 10;
GMTICKET_CHECK_INTERVAL = 600;		-- 10 Minutes

elapsedTime = 0;

function HelpFrame_OnLoad()
	-- Tab Handling code
	--PanelTemplates_SetNumTabs(this, 5);
	--PanelTemplates_SetTab(this, 1);
	this:RegisterEvent("UPDATE_GM_STATUS");
end

function HelpFrame_OnShow()
	--HelpFrame_ShowFrame(PanelTemplates_GetSelectedTab(this));
	HelpFrame_ShowFrame("Home");
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	GetGMStatus();
end

function HelpFrame_OnEvent()
	--[[if ( event ==  "UPDATE_GM_STATUS" ) then
		if ( arg1 == 1 ) then
			HelpFrameHomeGMButton:Show();
		else
			HelpFrameHomeGMButton:Hide();
		end
	end
	]]
end

function HelpFrame_ShowFrame(key, ticketType)
	-- Close previously opened frame
	if ( HelpFrame.openFrame ) then
		HelpFrame.openFrame:Hide();
	end
	
	-- If key is in the HELPFRAME_FRAMES table, use its name otherwise set to OpenTicket and set the category
	local frame;
	local frameInfo = HELPFRAME_FRAMES[key];
	if ( frameInfo ) then
		local targetName = frameInfo.name;
		if ( targetName == "HelpFrameGeneral" ) then
			-- Setup the frame if its a general frame
			HelpFrame_SetupGeneralFrame(key);
		end
		frame = getglobal(targetName);
	else
		frame = getglobal(HELPFRAME_FRAMES["OpenTicket"].name);
	end
	frame:Show();
	HelpFrame.openFrame = frame;
	
	-- Set the ticketType if there is one
	if ( ticketType ) then
		HelpFrameOpenTicket.ticketType = ticketType;
	end
end

function HelpFrame_SetupGeneralFrame(key)
	local info = GENERAL_HELPFRAME[key];
	if ( not info ) then
		return;	
	end
	if ( info.title ) then
		HelpFrameGeneralTitle:SetText(info.title);
	end
	if ( info.titleText ) then
		HelpFrameGeneralTitleText:SetText(info.titleText);
	end
	if ( info.bulletTitle1 ) then
		HelpFrameBulletTitle1:SetText(info.bulletTitle1);
	else
		HelpFrameBulletTitle1:SetText("");
	end
	local bulletIndex = 1;
	local bullet;
	if ( info.bullets1 ) then
		for index, value in  info.bullets1 do
			bullet = getglobal("HelpFrameGeneralBullet"..bulletIndex);
			if ( bullet ) then
				getglobal("HelpFrameGeneralBullet"..bulletIndex.."Text"):SetText(value);
				bullet:Show();
				if ( index > 1 ) then
					bullet:SetPoint("TOPLEFT", "HelpFrameGeneralBullet"..(bulletIndex-1), "BOTTOMLEFT", 0, -3);
				end
				bulletIndex = bulletIndex + 1;
			else
				_ERRORMESSAGE("Not enough bullets!  Tell Derek");
			end
		end
	end
	if ( info.bulletTitle2 ) then
		HelpFrameBulletTitle2:Show();
		HelpFrameBulletTitle2:SetPoint("TOPLEFT", "HelpFrameGeneralBullet"..(bulletIndex-1), "BOTTOMLEFT", -5, -20);
		HelpFrameBulletTitle2:SetText(info.bulletTitle2);
	else
		HelpFrameBulletTitle2:Hide();
	end
	if ( info.bullets2 ) then
		for index, value in  info.bullets2 do
			bullet = getglobal("HelpFrameGeneralBullet"..bulletIndex);
			if ( bullet ) then
				getglobal("HelpFrameGeneralBullet"..bulletIndex.."Text"):SetText(value);
				bullet:Show();
				if ( index == 1 ) then
					bullet:SetPoint("TOPLEFT", "HelpFrameBulletTitle2", "BOTTOMLEFT", 5, -3);
				else
					bullet:SetPoint("TOPLEFT", "HelpFrameGeneralBullet"..(bulletIndex-1), "BOTTOMLEFT", 0, -3);
				end
				bulletIndex = bulletIndex + 1;
			else
				_ERRORMESSAGE("Not enough bullets!  Tell Derek");
			end
		end
	end
	-- Hide all remaining bullets
	for i=bulletIndex, MAX_GENERAL_BULLETS do
		getglobal("HelpFrameGeneralBullet"..i):Hide();
	end
	-- Set bullet index to at least one
	bulletIndex = max(bulletIndex, 2);
	
	-- Set end text
	if ( info.endText ) then
		HelpFrameEndText:SetText(info.endText);
		HelpFrameEndText:SetPoint("TOPLEFT", "HelpFrameGeneralBullet"..(bulletIndex-1), "BOTTOMLEFT", -5, -20);
		HelpFrameEndText:Show();
	else
		HelpFrameEndText:Hide();
	end
	
	-- Configure the button
	if ( info.buttonText ) then
		HelpFrameGeneralButton:SetText(info.buttonText);
		HelpFrameGeneralButton:SetWidth(HelpFrameGeneralButtonText:GetWidth()+40);
		if ( info.endText ) then
			HelpFrameGeneralButton:SetPoint("TOP", "HelpFrameEndText", "BOTTOM", 0, -20);
		else
			HelpFrameGeneralButton:SetPoint("TOP", "HelpFrameGeneralBullet"..(bulletIndex-1), "BOTTOM", 0, -20);
		end
		if ( info.buttonOnClickFunc ) then
			HelpFrameGeneralButton.onClick = info.buttonOnClickFunc;
		else
			HelpFrameGeneralButton.onClick = nil;
		end
		HelpFrameGeneralButton:Show();
	else
		HelpFrameGeneralButton:Hide();
	end
	-- Set second title text if applicable
	if ( info.titleText2 ) then
		HelpFrameGeneralTitleText2:SetText(info.titleText2);
		HelpFrameGeneralTitleText2:SetPoint("TOPLEFT", "HelpFrameGeneralButton", "BOTTOM", -300, -20);
		HelpFrameGeneralTitleText2:Show();
	else
		HelpFrameGeneralTitleText2:Hide();
	end
	
	-- Configure second button if necessary
	if ( info.button2Text ) then
		HelpFrameGeneralButton2:SetText(info.button2Text);
		HelpFrameGeneralButton2:SetWidth(HelpFrameGeneralButton2Text:GetWidth()+40);
		if ( info.titleText2 ) then
			HelpFrameGeneralButton2:SetPoint("TOP", "HelpFrameGeneralTitleText2", "BOTTOM", 0, -20);
		else
			HelpFrameGeneralButton2:SetPoint("TOP", "HelpFrameGeneralButton", "BOTTOM", 0, -20);
		end
		if ( info.button2OnClickFunc ) then
			HelpFrameGeneralButton2.onClick = info.button2OnClickFunc;
		else
			HelpFrameGeneralButton2.onClick = nil;
		end
		HelpFrameGeneralButton2:Show();
	else
		HelpFrameGeneralButton2:Hide();
	end
end

function ToggleHelpFrame()
	if ( HelpFrame:IsVisible() ) then
		HideUIPanel(HelpFrame);
	else
		ShowUIPanel(HelpFrame);
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
		StaticPopup_Hide("HELP_TICKET");
	end
end

function HelpFrameOpenTicketDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, HelpFrameOpenTicketDropDown_Initialize);
	UIDropDownMenu_SetWidth(335, HelpFrameOpenTicketDropDown);
end

function HelpFrameOpenTicketDropDown_Initialize()
	local index = 1;
	local ticketType = getglobal("TICKET_TYPE"..index);
	local info;
	while (ticketType) do
		info = {};
		info.text = ticketType;
		info.func = HelpFrameOpenTicketDropDown_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
		index = index + 1;
		ticketType = getglobal("TICKET_TYPE"..index);
	end
end

function HelpFrameOpenTicketDropDown_OnClick()
	UIDropDownMenu_SetSelectedID(HelpFrameOpenTicketDropDown, this:GetID());
end

function HelpFrameOpenTicketDropDown_OnShow()
	GetGMTicket();
end

function HelpFrameOpenTicket_OnEvent()
	-- If there are args then the player has a ticket
	if ( arg1 ~= 0 ) then
		-- Has an open ticket
		HelpFrameOpenTicket.ticketType = arg1;
		HelpFrameOpenTicketText:SetText(arg2);
		HelpFrameOpenTicket.hasTicket = 1;
		HelpFrameOpenTicketSubmit:SetText(EDIT_TICKET);
		HelpFrameOpenTicketCancel:SetText(EXIT);
		HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_EDITTEXT);
	else
		-- Doesn't have an open ticket
		HelpFrameOpenTicketText:SetText("");
		HelpFrameOpenTicket.hasTicket = nil;
		HelpFrameOpenTicketSubmit:SetText(SUBMIT);
		HelpFrameOpenTicketCancel:SetText(CANCEL);
		HelpFrameOpenTicketLabel:SetText(HELPFRAME_OPENTICKET_TEXT);
	end	
end

function HelpFrameOpenTicketSubmit_OnClick()
	if ( HelpFrameOpenTicket.hasTicket ) then
		UpdateGMTicket(HelpFrameOpenTicket.ticketType, HelpFrameOpenTicketText:GetText());
		HideUIPanel(HelpFrame);
	else
		NewGMTicket(HelpFrameOpenTicket.ticketType, HelpFrameOpenTicketText:GetText());
		HideUIPanel(HelpFrame);
	end
end

function TicketStatusFrame_OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		GetGMTicket();
	else
		if ( arg1 ~= 0 ) then		
			this:Show();
			BuffFrame:SetPoint("TOPRIGHT", this:GetParent():GetName(), "TOPRIGHT", -205, (-this:GetHeight()));
			refreshTime = GMTICKET_CHECK_INTERVAL;
		else
			this:Hide();
			BuffFrame:SetPoint("TOPRIGHT", this:GetParent():GetName(), "TOPRIGHT", -205, -13);
		end
	end	
end

function HelpFrameButton_OnClick()
	HelpFrame_ShowFrame(this.key, this.ticketType);
end

function HelpFrameGM_Update()
	HelpFrameGM_UpdateCategories(GetGMTicketCategories());
end

function HelpFrameGM_UpdateCategories(...)
	local offset = FauxScrollFrame_GetOffset(HelpFrameGMScrollFrame);
	local index, button, text;
	for i=1, NUM_GM_CATEGORIES_TO_DISPLAY do
		index = 2 * (offset + i) - 1;
		button = getglobal("HelpFrameButton"..i);
		text = getglobal("HelpFrameButton"..i.."Text");
		if ( index <= arg.n  ) then
			text:SetText(arg[index+1]);
			button.key = arg[index];
			button.ticketType = arg[index];
			button:Show();
		else
			button:Hide();
		end
	end

	FauxScrollFrame_Update(HelpFrameGMScrollFrame, arg.n/2, NUM_GM_CATEGORIES_TO_DISPLAY, 37);
end

function HelpFrameGeneralButton_OnClick()
	if ( this.onClick ) then
		this.onClick();
	else
		HelpFrame_ShowFrame("OpenTicket");
	end
end

-- Every so often, query the server for our ticket status
-- This only gets called if the UI is up for the ticket
function TicketStatus_OnUpdate(elapsed)
	if ( HelpFrameOpenTicket.hasTicket ) then
		if( refreshTime ) then
			refreshTime = refreshTime - elapsed;

			if ( refreshTime <= 0 ) then
				refreshTime = GMTICKET_CHECK_INTERVAL;
				GetGMTicket();
			end
		end	
	end
end
