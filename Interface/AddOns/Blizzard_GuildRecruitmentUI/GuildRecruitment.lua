local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;

local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

function CommunitiesGuildRecruitmentFrame_OnLoad(self)
	SetLargeGuildTabardTextures("player", self.TabardEmblem, self.TabardBackground, self.TabardBorder);
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);

	self:RegisterEvent("LF_GUILD_POST_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUITS_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED");
	self:RegisterEvent("GUILD_CHALLENGE_UPDATED");
	
	RequestGuildRecruitmentSettings();
end

function CommunitiesGuildRecruitmentFrame_OnEvent(self, event, arg1)
	if ( event == "LF_GUILD_POST_UPDATED" ) then
		local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
		-- interest
		self.Recruitment.InterestFrame.QuestButton:SetChecked(bQuest);
		self.Recruitment.InterestFrame.DungeonButton:SetChecked(bDungeon);
		self.Recruitment.InterestFrame.RaidButton:SetChecked(bRaid);
		self.Recruitment.InterestFrame.PvPButton:SetChecked(bPvP);
		self.Recruitment.InterestFrame.RPButton:SetChecked(bRP);
		-- availability
		self.Recruitment.AvailabilityFrame.WeekdaysButton:SetChecked(bWeekdays);
		self.Recruitment.AvailabilityFrame.WeekendsButton:SetChecked(bWeekends);
		-- roles
		self.Recruitment.RolesFrame.TankButton.checkButton:SetChecked(bTank);
		self.Recruitment.RolesFrame.HealerButton.checkButton:SetChecked(bHealer);
		self.Recruitment.RolesFrame.DamagerButton.checkButton:SetChecked(bDamage);
		-- level
		if ( bMaxLevel ) then
			CommunitiesGuildRecruitmentLevelFrame_SelectLevelButton(self.Recruitment.LevelFrame, 2);
		else
			CommunitiesGuildRecruitmentLevelFrame_SelectLevelButton(self.Recruitment.LevelFrame, 1);
		end
		-- comment
		self.Recruitment.CommentFrame.CommentInputFrame.ScrollFrame.CommentEditBox:SetText(GetGuildRecruitmentComment());
		CommunitiesGuildRecruitmentFrameRecruitment_UpdateListGuildButton(self.Recruitment);
	elseif ( event == "LF_GUILD_RECRUITS_UPDATED" ) then
		CommunitiesGuildRecruitmentFrameApplicants_Update(self.Applicants);
	elseif ( event == "LF_GUILD_RECRUIT_LIST_CHANGED" ) then
		RequestGuildApplicantsList();
	end
end

function CommunitiesGuildRecruitmentFrame_OnShow(self)
	RequestGuildApplicantsList();
	if not IsGuildLeader() then
		self.Tab1:Hide();
		self.Tab2:SetPoint("LEFT", self.Tab1, "LEFT");
		PanelTemplates_SetTab(self, 2);
	else
		self.Tab1:Show();
		self.Tab2:SetPoint("LEFT", self.Tab1, "RIGHT");
	end
	
	CommunitiesGuildRecruitmentFrame_Update(self);
end

function CommunitiesGuildRecruitmentFrame_Update(self)
	local selectedTab = PanelTemplates_GetSelectedTab(self);
	if ( selectedTab == 1 ) then
		self.Recruitment:Show();
		self.Applicants:Hide();
	else
		self.Recruitment:Hide();
		self.Applicants:Show();
	end
end

--*******************************************************************************
--   Recruitment Tab
--*******************************************************************************

function CommunitiesGuildRecruitmentFrameRecruitment_OnLoad(self)
	self.InterestFrame.Text:SetText(GUILD_INTEREST);
	self.InterestFrame:SetHeight(63);
	self.AvailabilityFrame.Text:SetText(GUILD_AVAILABILITY);
	self.AvailabilityFrame:SetHeight(43);
	self.RolesFrame.Text:SetText(CLASS_ROLES);
	self.RolesFrame:SetHeight(80);
	self.LevelFrame.Text:SetText(GUILD_RECRUITMENT_LEVEL);
	self.LevelFrame:SetHeight(43);
	self.CommentFrame:SetHeight(72);
	
	-- defaults until data is retrieved
	self.LevelFrame.LevelAnyButton:SetChecked(true);
	self.ListGuildButton:Disable();
end

function CommunitiesGuildRecruitmentLevelFrame_SelectLevelButton(self, index, userClick)
	local guildRecruitmentFrame = self:GetParent();
	local param;
	if ( index == 1 ) then
		guildRecruitmentFrame.LevelFrame.LevelAnyButton:SetChecked(true);
		guildRecruitmentFrame.LevelFrame.LevelMaxButton:SetChecked(false);
		param = LFGUILD_PARAM_ANY_LEVEL;
	elseif ( index == 2 ) then
		guildRecruitmentFrame.LevelFrame.LevelAnyButton:SetChecked(false);
		guildRecruitmentFrame.LevelFrame.LevelMaxButton:SetChecked(true);
		param = LFGUILD_PARAM_MAX_LEVEL;
	end
	if ( userClick ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		SetGuildRecruitmentSettings(param, true);
	end	
end

function CommunitiesGuildRecruitmentRoleButton_OnClick(self)
	local guildRecruitmentFrame = self:GetParent():GetParent():GetParent();
	local checked = self:GetChecked();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	SetGuildRecruitmentSettings(self:GetParent().param, checked);
	CommunitiesGuildRecruitmentFrameRecruitment_UpdateListGuildButton(guildRecruitmentFrame);
end

function CommunitiesGuildRecruitmentFrameRecruitment_UpdateListGuildButton(self)
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	-- need to have at least 1 interest, 1 time, and 1 role checked to be able to list
	if ( bQuest or bDungeon or bRaid or bPvP or bRP ) and ( bWeekdays or bWeekends ) and ( bTank or bHealer or bDamage ) then
		self.ListGuildButton:Enable();
	else
		self.ListGuildButton:Disable();
		-- delist if already listed
		if ( bListed ) then
			bListed = false;
			SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, false);
		end
	end
	CommunitiesGuildRecruitmentListGuildButton_UpdateText(self.ListGuildButton, bListed);
end

function CommunitiesGuildRecruitmentListGuildButton_OnClick(self)
	local guildRecruitmentFrame = self:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	bListed = not bListed;
	if ( bListed and guildRecruitmentFrame.CommentFrame.CommentInputFrame.ScrollFrame.CommentEditBox:HasFocus() ) then
		CommunitiesGuildRecruitmentComment_SaveText(guildRecruitmentFrame.CommentFrame.CommentInputFrame.ScrollFrame.CommentEditBox);
	end
	SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, bListed);
	CommunitiesGuildRecruitmentListGuildButton_UpdateText(guildRecruitmentFrame.ListGuildButton, bListed);
end

function CommunitiesGuildRecruitmentListGuildButton_UpdateText(self, listed)
	if ( listed ) then
		self:SetText(GUILD_CLOSE_RECRUITMENT);
	else
		self:SetText(GUILD_OPEN_RECRUITMENT);
	end
end

function CommunitiesGuildRecruitmentComment_SaveText(self)
	SetGuildRecruitmentComment(self:GetText():gsub("\n",""));
	self:ClearFocus();
end

function CommunitiesGuildRecruitmentCheckButton_OnEnter(self)
	local interestType = INTEREST_TYPES[self:GetID()];
	if ( interestType ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(_G["GUILD_INTEREST_"..interestType]);
		GameTooltip:AddLine(_G["GUILD_INTEREST_"..interestType.."_TOOLTIP"], 1, 1, 1, true);
		GameTooltip:Show();
	end
end

--*******************************************************************************
--   Applicants Tab
--*******************************************************************************

function CommunitiesGuildRecruitmentFrameApplicants_OnLoad(self)
	local applicantsContainer = self.Container;
	applicantsContainer.update = function () CommunitiesGuildRecruitmentFrameApplicants_Update(self); end;
	HybridScrollFrame_CreateButtons(applicantsContainer, "CommunitiesGuildRecruitmentApplicantTemplate", 0, 0);
	
	applicantsContainer.scrollBar.Show = 
		function (self)
			applicantsContainer:SetWidth(304);
			for _, button in next, applicantsContainer.buttons do
				button:SetWidth(301);
				button.fullComment:SetWidth(223);
			end
			getmetatable(self).__index.Show(self);
		end
	applicantsContainer.scrollBar.Hide = 
		function (self)
			applicantsContainer:SetWidth(320);
			for _, button in next, applicantsContainer.buttons do
				button:SetWidth(320);
				button.fullComment:SetWidth(242);
			end
			getmetatable(self).__index.Hide(self);
		end
end

function CommunitiesGuildRecruitmentFrameApplicants_OnShow(self)
	CommunitiesGuildRecruitmentFrameApplicants_Update(self);
end

function CommunitiesGuildRecruitmentFrameApplicants_Update(self)
	local scrollFrame = self.Container;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numApplicants = GetNumGuildApplicants();
	local selection = GetGuildApplicantSelection();

	if ( numApplicants == 0 ) then
		self:GetParent().Tab2:SetText(GUILDINFOTAB_APPLICANTS_NONE);
	else
		self:GetParent().Tab2:SetFormattedText(GUILDINFOTAB_APPLICANTS, numApplicants);
	end
	PanelTemplates_TabResize(self:GetParent().Tab2, 0);
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		local name, level, class, _, _, _, _, _, _, _, isTank, isHealer, isDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(index);
		if ( name ) then
			button.name:SetText(name);
			button.level:SetText(level);
			button.comment:SetText(comment);
			button.fullComment:SetText(comment);
			button.class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
			-- time left
			local daysLeft = floor(timeLeft / 86400); -- seconds in a day
			if ( daysLeft < 1 ) then
				button.timeLeft:SetText(GUILD_FINDER_LAST_DAY_LEFT);
			else
				button.timeLeft:SetFormattedText(GUILD_FINDER_DAYS_LEFT, daysLeft);
			end
			-- roles
			if ( isTank ) then
				button.tankTex:SetAlpha(1);
			else
				button.tankTex:SetAlpha(0.2);
			end
			if ( isHealer ) then
				button.healerTex:SetAlpha(1);
			else
				button.healerTex:SetAlpha(0.2);
			end
			if ( isDamage ) then
				button.damageTex:SetAlpha(1);
			else
				button.damageTex:SetAlpha(0.2);
			end
			-- selection
			local buttonHeight = GUILD_BUTTON_HEIGHT;
			if ( index == selection ) then
				button.selectedTex:Show();
				local commentHeight = button.fullComment:GetHeight();
				if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
					buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
				end
			else
				button.selectedTex:Hide();
			end
			
			button:SetHeight(buttonHeight);
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end
	
	if ( not selection ) then
		HybridScrollFrame_CollapseButton(scrollFrame);
	end
	
	local totalHeight = numApplicants * GUILD_BUTTON_HEIGHT;
	if ( scrollFrame.largeButtonHeight ) then
		totalHeight = totalHeight + (scrollFrame.largeButtonHeight - GUILD_BUTTON_HEIGHT);
	end
	local displayedHeight = numButtons * GUILD_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	local applicantsFrame = self:GetParent().Applicants;
	if ( selection and selection > 0 ) then
		applicantsFrame.InviteButton:Enable();
		applicantsFrame.DeclineButton:Enable();
		applicantsFrame.MessageButton:Enable();
	else
		applicantsFrame.InviteButton:Disable();
		applicantsFrame.DeclineButton:Disable();
		applicantsFrame.MessageButton:Disable();
	end
end

function CommunitiesGuildRecruitmentApplicant_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		SetGuildApplicantSelection(self.index);
		local commentHeight = self.fullComment:GetHeight();
		if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
			local buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
			self:SetHeight(buttonHeight);
			HybridScrollFrame_ExpandButton(self:GetParent():GetParent(), ((self.index - 1) * GUILD_BUTTON_HEIGHT), buttonHeight);
		else
			HybridScrollFrame_CollapseButton(self:GetParent():GetParent());
		end
		CommunitiesGuildRecruitmentFrameApplicants_Update(self:GetParent():GetParent():GetParent());
	elseif ( button == "RightButton" ) then
		local guildRecruitmentFrame = self:GetParent():GetParent():GetParent();
		local dropDown = guildRecruitmentFrame.DropDown;
		if ( dropDown.index ~= self.index ) then
			CloseDropDownMenus();
		end
		dropDown.index = self.index;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 1, -1);
	end
end

function CommunitiesGuildRecruitmentApplicant_ShowTooltip(self)
	local name, level, class, bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name);
	local buf = "";
	-- interests
	if ( bQuest ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_QUEST; end
	if ( bDungeon ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_DUNGEON; end
	if ( bRaid ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RAID; end
	if ( bPvP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_PVP; end
	if ( bRP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RP; end	
	GameTooltip:AddLine(GUILD_INTEREST..HIGHLIGHT_FONT_COLOR_CODE..buf..FONT_COLOR_CODE_CLOSE);
	-- availability
	buf = "";
	if ( bWeekdays ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKDAYS; end
	if ( bWeekends ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKENDS; end
	GameTooltip:AddLine(GUILD_AVAILABILITY..HIGHLIGHT_FONT_COLOR_CODE..buf..FONT_COLOR_CODE_CLOSE);
	
	GameTooltip:Show();
end

function CommunitiesGuildRecruitmentDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRecruitmentDropDown_Initialize, "MENU");
end

function CommunitiesGuildRecruitmentDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local name = GetGuildApplicantInfo(self.index) or UNKNOWN;
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.func = function(...) CommunitiesGuildRecruitmentDropDown_OnClick(self, ...); end;
	
	info.text = INVITE;
	info.arg1 = "invite";
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	
	info.text = WHISPER;
	info.arg1 = "whisper";
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = ADD_FRIEND;
	info.arg1 = "addfriend";
	if ( C_FriendList.GetFriendInfo(name) ) then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	
	info.text = DECLINE;
	info.arg1 = "decline";
	info.disabled = nil;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function CommunitiesGuildRecruitmentDropDown_OnClick(self, button, action)
	local name = GetGuildApplicantInfo(self.index);
	if ( not name ) then
		return;
	end
	if ( action == "invite" ) then
		GuildInvite(name);
	elseif ( action == "whisper" ) then
		ChatFrame_SendTell(name);
	elseif ( action == "addfriend" ) then
		C_FriendList.AddOrRemoveFriend(name);
	elseif ( action == "decline" ) then
		DeclineGuildApplicant(self.index);
	end
end
