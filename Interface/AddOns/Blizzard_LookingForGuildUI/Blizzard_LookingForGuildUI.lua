UIPanelWindows["LookingForGuildFrame"] = { area = "left", pushable = 1, whileDead = 1 };

local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;
local APP_BUTTON_HEIGHT = 30;
local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

function LookingForGuildFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 3);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self.Inset:SetPoint("TOPLEFT", 4, -64);

	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		LookingForGuildFrameTabardEmblem:SetTexture("Interface\\FriendsFrame\\PlusManz-Alliance");
	else
		LookingForGuildFrameTabardEmblem:SetTexture("Interface\\FriendsFrame\\PlusManz-Horde");
	end

	LookingForGuildFrameTitleText:SetText(LOOKINGFORGUILD);

	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("LF_GUILD_BROWSE_UPDATED");
	self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED");
	self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_CHANGED");
end

function LookingForGuild_UpdateRoleButton( button, canBeRole )
	if ( canBeRole ) then
		button:Enable();
		SetDesaturation(button:GetNormalTexture(), false);
		button.cover:Hide();
		button.checkButton:Enable();
		if ( button.background ) then
			button.background:Show();
		end
		if ( button.shortageBorder ) then
			button.shortageBorder:SetVertexColor(1, 1, 1);
			button.incentiveIcon.texture:SetVertexColor(1, 1, 1);
			button.incentiveIcon.border:SetVertexColor(1, 1, 1);
		end
		button.Text:SetFontObject("GameFontHighlightSmall");
	else
		button:Disable();
		SetDesaturation(button:GetNormalTexture(), true);
		button.cover:Show();
		button.cover:SetAlpha(0.7);
		button.checkButton:Hide();
		button.checkButton:Disable();
		if ( button.background ) then
			button.background:Hide();
		end
		if ( button.shortageBorder ) then
			button.shortageBorder:SetVertexColor(0.5, 0.5, 0.5);
			button.incentiveIcon.texture:SetVertexColor(0.5, 0.5, 0.5);
			button.incentiveIcon.border:SetVertexColor(0.5, 0.5, 0.5);
		end
		button.Text:SetFontObject("GameFontDisableSmall");
	end
end

function LookingForGuildFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player");

	LookingForGuild_UpdateRoleButton(LookingForGuildTankButton, canBeTank);
	LookingForGuild_UpdateRoleButton(LookingForGuildHealerButton, canBeHealer);
	LookingForGuild_UpdateRoleButton(LookingForGuildDamagerButton, canBeDPS);

	UpdateMicroButtons();
	RequestGuildMembershipList();
end

function LookingForGuildFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( IsInGuild() and self:IsShown() ) then
			HideUIPanel(self);
		end
	elseif ( event == "LF_GUILD_BROWSE_UPDATED" ) then
		LookingForGuild_Update();
	elseif ( event == "LF_GUILD_MEMBERSHIP_LIST_UPDATED" ) then
		local numAppsLeft = ...;
		LookingForGuildBrowseFrameRequestsLeft:SetFormattedText(GUILD_FINDER_REQUESTS_LEFT, numAppsLeft);
		LookingForGuildApps_Update();
	elseif ( event == "LF_GUILD_MEMBERSHIP_LIST_CHANGED" ) then
		RequestGuildMembershipList();
	end
end

function LookingForGuildFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
end

function LookingForGuildFrame_Toggle()
	if ( LookingForGuildFrame:IsShown() ) then
		HideUIPanel(LookingForGuildFrame);
	else
		ShowUIPanel(LookingForGuildFrame);
	end
end

function LookingForGuildFrame_Update()
	if ( LookingForGuildFrame.selectedTab == 1 ) then
		LookingForGuildStartFrame:Show();
		LookingForGuildBrowseFrame:Hide();
		LookingForGuildAppsFrame:Hide();
	elseif ( LookingForGuildFrame.selectedTab == 2 ) then
		LookingForGuildStartFrame:Hide();
		LookingForGuildBrowseFrame:Show();
		LookingForGuildAppsFrame:Hide();
	else
		LookingForGuildStartFrame:Hide();
		LookingForGuildBrowseFrame:Hide();
		LookingForGuildAppsFrame:Show();
	end
end

--*******************************************************************************
--   Settings frame
--*******************************************************************************

function LookingForGuildPlaystyleButton_OnClick(index, userClick)
	local param;
	if ( index == 1 ) then
		LookingForGuildCasualButton:SetChecked(true);
		LookingForGuildModerateButton:SetChecked(false);
		LookingForGuildHardcoreButton:SetChecked(false);
		param = LFGUILD_PARAM_CASUAL;
	elseif ( index == 2 ) then
		LookingForGuildCasualButton:SetChecked(false);
		LookingForGuildModerateButton:SetChecked(true);
		LookingForGuildHardcoreButton:SetChecked(false);
		param = LFGUILD_PARAM_MODERATE;
	else
		LookingForGuildCasualButton:SetChecked(false);
		LookingForGuildModerateButton:SetChecked(false);
		LookingForGuildHardcoreButton:SetChecked(true);
		param = LFGUILD_PARAM_HARDCORE;
	end
	if ( userClick ) then
		SetLookingForGuildSettings(param, true);
	end
end

function LookingForGuildRoleButton_OnClick(self)
	local checked = self:GetChecked();
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	SetLookingForGuildSettings(self:GetParent().param, checked);
	LookingForGuildBrowseButton_Update();
end

function LookingForGuildStartFrame_OnLoad(self)
	LookingForGuildInterestFrameText:SetText(GUILD_INTEREST);
	LookingForGuildInterestFrame:SetHeight(74);
	LookingForGuildAvailabilityFrameText:SetText(GUILD_AVAILABILITY);
	LookingForGuildAvailabilityFrame:SetHeight(51);
	LookingForGuildRolesFrameText:SetText(CLASS_ROLES);
	LookingForGuildRolesFrame:SetHeight(83);
	LookingForGuildCommentFrameText:SetText(COMMENT);
	LookingForGuildCommentFrame:SetHeight(98);

	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetLookingForGuildSettings();
	-- interests
	LookingForGuildQuestButton:SetChecked(bQuest);
	LookingForGuildDungeonButton:SetChecked(bDungeon);
	LookingForGuildRaidButton:SetChecked(bRaid);
	LookingForGuildPvPButton:SetChecked(bPvP);
	LookingForGuildRPButton:SetChecked(bRP);
	-- availability
	LookingForGuildWeekdaysButton:SetChecked(bWeekdays);
	LookingForGuildWeekendsButton:SetChecked(bWeekends);
	-- roles
	LookingForGuildTankButton.checkButton:SetChecked(bTank);
	LookingForGuildHealerButton.checkButton:SetChecked(bHealer);
	LookingForGuildDamagerButton.checkButton:SetChecked(bDamage);
	LookingForGuildBrowseButton_Update();
	-- comment
	LookingForGuildCommentEditBox:SetText(GetLookingForGuildComment());

	LookingForGuildBrowseButton:SetWidth(max(116, LookingForGuildBrowseButton:GetTextWidth() + 24));
end

function LookingForGuildBrowseButton_Update()
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetLookingForGuildSettings();
	-- need to have at least 1 interest, 1 time, and 1 role checked to be able to list
	if ( bQuest or bDungeon or bRaid or bPvP or bRP ) and ( bWeekdays or bWeekends ) and ( bTank or bHealer or bDamage ) then
		LookingForGuildBrowseButton:Enable();
		PanelTemplates_EnableTab(LookingForGuildFrame, 2)
	else
		LookingForGuildBrowseButton:Disable();
		PanelTemplates_DisableTab(LookingForGuildFrame, 2)
	end
end

function LookingForGuildComment_SaveText(self)
	self = self or LookingForGuildCommentEditBox;
	SetLookingForGuildComment(self:GetText());
	self:ClearFocus();
end

function LookingForGuildCheckButton_OnEnter(self)
	local interestType = INTEREST_TYPES[self:GetID()];
	if ( interestType ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(_G["GUILD_INTEREST_"..interestType]);
		GameTooltip:AddLine(_G["GUILD_INTEREST_"..interestType.."_TOOLTIP"], 1, 1, 1, true);
		GameTooltip:Show();
	end
end

--*******************************************************************************
--   Browse frame
--*******************************************************************************

function LookingForGuildBrowseFrame_OnLoad(self)
	LookingForGuildRequestButton:SetWidth(max(116, LookingForGuildRequestButton:GetTextWidth() + 24));
	LookingForGuildBrowseFrameContainer.update = LookingForGuild_Update;
	HybridScrollFrame_CreateButtons(LookingForGuildBrowseFrameContainer, "LookingForGuildGuildTemplate", 0, 0);

	LookingForGuildBrowseFrameContainerScrollBar.Show =
		function (self)
			LookingForGuildBrowseFrameContainer:SetWidth(304);
			for _, button in next, LookingForGuildBrowseFrameContainer.buttons do
				button:SetWidth(301);
				button.fullComment:SetWidth(223);
			end
			getmetatable(self).__index.Show(self);
		end
	LookingForGuildBrowseFrameContainerScrollBar.Hide =
		function (self)
			LookingForGuildBrowseFrameContainer:SetWidth(320);
			for _, button in next, LookingForGuildBrowseFrameContainer.buttons do
				button:SetWidth(320);
				button.fullComment:SetWidth(242);
			end
			getmetatable(self).__index.Hide(self);
		end

	LookingForGuild_Update();
end

function LookingForGuildBrowseFrame_OnShow(self)
	RequestRecruitingGuildsList();
end

function LookingForGuild_Update()
	local scrollFrame = LookingForGuildBrowseFrameContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numGuilds = GetNumRecruitingGuilds();
	local _, numAppsRemaining = GetNumGuildMembershipRequests();
	local selection = GetRecruitingGuildSelection();

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numGuilds ) then
			local name, level, numMembers, achPoints, comment, cached, requestPending = GetRecruitingGuildInfo(index);
			button.name:SetText(name);
			button.numMembers:SetFormattedText(BROWSE_GUILDS_NUM_MEMBERS, numMembers);
			button.achPoints:SetText(achPoints);
			button.comment:SetText(comment);
			button.fullComment:SetText(comment);
			-- tabard
			local tabardInfo = { C_LFGuildInfo.GetRecruitingGuildTabardInfo(index) };
			SetLargeGuildTabardTextures(nil, button.emblem, button.tabard, button.border, tabardInfo);
			-- selection
			local buttonHeight = GUILD_BUTTON_HEIGHT;
			if ( requestPending ) then
				button.selectedTex:Show();
				button.pendingFrame:Show();
			else
				button.pendingFrame:Hide();
				if ( index == selection ) then
					button.selectedTex:Show();
					local commentHeight = button.fullComment:GetHeight();
					if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
						buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
					end
				else
					button.selectedTex:Hide();
				end
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

	local totalHeight = numGuilds * GUILD_BUTTON_HEIGHT;
	if ( scrollFrame.largeButtonHeight ) then
		totalHeight = totalHeight + (scrollFrame.largeButtonHeight - GUILD_BUTTON_HEIGHT);
	end
	local displayedHeight = numButtons * GUILD_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	if ( selection and numAppsRemaining > 0 ) then
		LookingForGuildRequestButton:Enable();
	else
		LookingForGuildRequestButton:Disable();
	end
end

function LookingForGuildGuild_OnClick(self, button)
	if ( button == "LeftButton" ) then
		local name, level, numMembers, achPoints, comment, cached, requestPending = GetRecruitingGuildInfo(self.index);
		if ( not requestPending ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			SetRecruitingGuildSelection(self.index);
			local commentHeight = self.fullComment:GetHeight();
			if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
				local buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
				self:SetHeight(buttonHeight);
				HybridScrollFrame_ExpandButton(LookingForGuildBrowseFrameContainer, ((self.index - 1) * GUILD_BUTTON_HEIGHT), buttonHeight);
			else
				HybridScrollFrame_CollapseButton(LookingForGuildBrowseFrameContainer);
			end
			LookingForGuild_Update();
		end
	end
end

function LookingForGuildGuild_ShowTooltip(self)
	local name = GetRecruitingGuildInfo(self.index);
	if not name then
		-- We haven't loaded recruitment data yet, just skip the tooltip.
		-- This only happens if you open the guild finder, go to the browse frame, join a guild, quit the guild, and then
		-- open the guild finder frame again with your mouse over where a recruitment button is.
		return;
	end

	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetRecruitingGuildSettings(self.index);
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
	-- roles
	buf = "";
	if ( bTank ) then buf = buf.."\n"..QUEST_DASH..TANK; end
	if ( bHealer ) then buf = buf.."\n"..QUEST_DASH..HEALER; end
	if ( bDamage ) then buf = buf.."\n"..QUEST_DASH..DAMAGER; end
	GameTooltip:AddLine(CLASS_ROLES..HIGHLIGHT_FONT_COLOR_CODE..buf..FONT_COLOR_CODE_CLOSE);

	GameTooltip:Show();
end

function LookingForGuild_RequestMembership()
	StaticPopupSpecial_Show(GuildFinderRequestMembershipFrame);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	local name, level = GetRecruitingGuildInfo(GetRecruitingGuildSelection());
	GuildFinderRequestMembershipFrameGuildName:SetText(name);
	GuildFinderRequestMembershipEditBox:SetText(GetLookingForGuildComment());
end

function GuildFinderRequestMembershipFrame_SendRequest()
	StaticPopupSpecial_Hide(GuildFinderRequestMembershipFrame);
	RequestGuildMembership(GuildFinderRequestMembershipFrameGuildName:GetText(), GuildFinderRequestMembershipEditBox:GetText():gsub("\n",""));
	SetRecruitingGuildSelection(nil);
	LookingForGuild_Update();
end

--*******************************************************************************
--   Apps frame
--*******************************************************************************

function LookingForGuildAppsFrame_OnLoad(self)
	LookingForGuildAppsFrameContainer.update = LookingForGuildApps_Update;
	HybridScrollFrame_CreateButtons(LookingForGuildAppsFrameContainer, "LookingForGuildAppTemplate", 0, 0);

	LookingForGuildAppsFrameContainerScrollBar.Show =
		function (self)
			LookingForGuildAppsFrameContainer:SetWidth(304);
			for _, button in next, LookingForGuildAppsFrameContainer.buttons do
				button:SetWidth(301);
			end
			getmetatable(self).__index.Show(self);
		end
	LookingForGuildAppsFrameContainerScrollBar.Hide =
		function (self)
			LookingForGuildAppsFrameContainer:SetWidth(320);
			for _, button in next, LookingForGuildAppsFrameContainer.buttons do
				button:SetWidth(320);
			end
			getmetatable(self).__index.Hide(self);
		end

	LookingForGuildApps_Update();
end

function LookingForGuildApps_Update()
	local scrollFrame = LookingForGuildAppsFrameContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numApps = GetNumGuildMembershipRequests();

	if ( numApps == 0 ) then
		LookingForGuildFrameTab3:SetText(LFGUILD_TAB_REQUESTS_NONE);
	else
		LookingForGuildFrameTab3:SetFormattedText(LFGUILD_TAB_REQUESTS, numApps);
	end
	PanelTemplates_TabResize(LookingForGuildFrameTab3, 0);

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numApps ) then
			local name, timeSince, timeLeft, declined = GetGuildMembershipRequestInfo(index);
			button.name:SetText(name);
			-- time left
			local daysLeft = floor(timeLeft / 86400); -- seconds in a day
			if ( daysLeft < 1 ) then
				button.timeLeft:SetText(GUILD_FINDER_LAST_DAY_LEFT);
			else
				button.timeLeft:SetFormattedText(GUILD_FINDER_DAYS_LEFT, daysLeft);
			end
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end
	local totalHeight = numApps * APP_BUTTON_HEIGHT;
	local displayedHeight = numButtons * APP_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function LookingForGuildApp_ShowTooltip(self)
	local name = GetGuildMembershipRequestInfo(self.index);
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetGuildMembershipRequestSettings(self.index);
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
	-- roles
	buf = "";
	if ( bTank ) then buf = buf.."\n"..QUEST_DASH..TANK; end
	if ( bHealer ) then buf = buf.."\n"..QUEST_DASH..HEALER; end
	if ( bDamage ) then buf = buf.."\n"..QUEST_DASH..DAMAGER; end
	GameTooltip:AddLine(CLASS_ROLES..HIGHLIGHT_FONT_COLOR_CODE..buf..FONT_COLOR_CODE_CLOSE);

	GameTooltip:Show();
end

function LookingForGuildFrame_CreateUIElements()
	if LookingForGuildFrame then
		return;
	end

	CreateFrame("Frame", "LookingForGuildFrame", UIParent, "ButtonFrameTemplate, LookingForGuildFrameTemplate");
	LookingForGuildFrameTabardBorder:SetSize(60, 60);
	LookingForGuildFrameTabardBorder:SetPoint("CENTER", LookingForGuildFrameTabardBackground, "CENTER", 0, -3);

	CreateFrame("Frame", "LookingForGuildStartFrame", UIParent, "LookingForGuildStartFrameTemplate");
	CreateFrame("Frame", "LookingForGuildBrowseFrame", UIParent, "LookingForGuildBrowseFrameTemplate");
	CreateFrame("Frame", "LookingForGuildAppsFrame", UIParent, "LookingForGuildAppsFrameTemplate");
end

LookingForGuildLoaderMixin = {}

function LookingForGuildLoaderMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
end

function LookingForGuildLoaderMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...;
		if addonName and addonName == "Blizzard_LookingForGuildUI" then
			LookingForGuildFrame_CreateUIElements();
		end
	end
end