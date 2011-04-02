UIPanelWindows["GuildFrame"] = { area = "left", pushable = 1, whileDead = 1 };
local GUILDFRAME_PANELS = { };
local GUILDFRAME_POPUPS = { };
local BUTTON_WIDTH_WITH_SCROLLBAR = 298;
local BUTTON_WIDTH_NO_SCROLLBAR = 320;

function GuildFrame_OnLoad(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_XP_UPDATE");
	self:RegisterEvent("GUILD_PERK_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_FACTION");
	PanelTemplates_SetNumTabs(self, 5);
	RequestGuildRewards();
	QueryGuildXP();
	QueryGuildNews();
	OpenCalendar();		-- to get event data
	GuildFrame_UpdateTabard();
	GuildFrame_UpdateLevel();
	GuildFrame_UpdateXP();
	GuildFrame_UpdateFaction();
	local guildName = GetGuildInfo("player");
	GuildFrameTitleText:SetText(guildName);
	local totalMembers, onlineMembers = GetNumGuildMembers();
	GuildFrameMembersCount:SetText(onlineMembers.." / "..totalMembers);
end

function GuildFrame_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	if ( GetGuildLevelEnabled() ) then
		GuildFrameTab1:Show();
		GuildFrameTab3:Show();
		GuildFrameTab4:Show();
		GuildFrameTab2:SetPoint("LEFT", GuildFrameTab1, "RIGHT", -15, 0);
		GuildFrameTab5:SetPoint("LEFT", GuildFrameTab4, "RIGHT", -15, 0);
		GuildLevelFrame:Show();
		if ( not PanelTemplates_GetSelectedTab(self) ) then
			GuildFrame_TabClicked(GuildFrameTab1);
		end
	else
		GuildFrameTab1:Hide();
		GuildFrameTab3:Hide();
		GuildFrameTab4:Hide();
		GuildFrameTab2:SetPoint("LEFT", GuildFrameTab1);
		GuildFrameTab5:SetPoint("LEFT", GuildFrameTab2, "RIGHT", -15, 0);
		GuildLevelFrame:Hide();
		if ( not PanelTemplates_GetSelectedTab(self) ) then
			GuildFrame_TabClicked(GuildFrameTab2);
		end	
	end
	GuildRoster();
	UpdateMicroButtons();
end

function GuildFrame_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	CloseGuildMenus();
end

function GuildFrame_Toggle()
	if ( GuildFrame:IsShown() ) then
		HideUIPanel(GuildFrame);
	else
		ShowUIPanel(GuildFrame);
	end
end

function GuildFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		local totalMembers, onlineMembers = GetNumGuildMembers();
		GuildFrameMembersCount:SetText(onlineMembers.." / "..totalMembers);
	elseif ( event == "GUILD_XP_UPDATE" ) then
		GuildFrame_UpdateXP();
	elseif ( event == "UPDATE_FACTION" ) then
		GuildFrame_UpdateFaction();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( IsInGuild() ) then
			local guildName = GetGuildInfo("player");
			GuildFrameTitleText:SetText(guildName);
			GuildFrame_UpdateTabard();
		else
			if ( self:IsShown() ) then
				HideUIPanel(self);
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		QueryGuildXP();
		QueryGuildNews();
	elseif ( event == "GUILD_PERK_UPDATE" ) then
		GuildFrame_UpdateLevel();
	end
end

function GuildFrame_UpdateLevel()
	local guildLevel = GetGuildLevel();
	GuildLevelFrameText:SetText(guildLevel);
	if ( GetGuildFactionGroup() == 0 ) then
		GuildXPFrameLevelText:SetFormattedText(GUILD_LEVEL_AND_FACTION, guildLevel, FACTION_HORDE);
	else
		GuildXPFrameLevelText:SetFormattedText(GUILD_LEVEL_AND_FACTION, guildLevel, FACTION_ALLIANCE);
	end
	if ( guildLevel == MAX_GUILD_LEVEL ) then
		GuildXPBar:Hide();
		GuildXPFrameLevelText:SetPoint("BOTTOM", GuildXPFrame, "TOP", 0, -8);
	else
		GuildXPBar:Show();
		GuildXPFrameLevelText:SetPoint("BOTTOM", GuildXPFrame, "TOP", 0, 2);
		GuildFrame_UpdateXP();
	end
end

function GuildFrame_UpdateXP()
	local currentXP, nextLevelXP, dailyXP, maxDailyXP, _, _, isUncapped = UnitGetGuildXP("player");
	local capXP = maxDailyXP - dailyXP;
	if ( isUncapped ) then
		capXP = 0;
	end
	GuildBar_SetProgress(GuildXPBar, currentXP, nextLevelXP + currentXP, capXP);
end

function GuildFrame_UpdateFaction()
	local factionBar = GuildFactionFrame;
	local gender = UnitSex("player");
	local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _, repToCap, weeklyCap = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	GuildFactionBarLabel:SetText(barValue.." / "..barMax);
	GuildFactionFrameStanding:SetText(factionStandingtext);
	GuildBar_SetProgress(GuildFactionBar, barValue, barMax, repToCap or 0);
end

function GuildFrame_UpdateTabard()
	SetLargeGuildTabardTextures("player", GuildFrameTabardEmblem, GuildFrameTabardBackground, GuildFrameTabardBorder);
end

function GuildFrame_CheckPermissions()
	if ( IsGuildLeader() ) then
		GuildControlButton:Enable();
	else
		GuildControlButton:Disable();
	end
	if ( CanGuildInvite() ) then
		GuildAddMemberButton:Enable();
	else
		GuildAddMemberButton:Disable();
	end
end

--****** Common Functions *******************************************************

function GuildFrame_OpenAchievement(button, achievementID)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end	
	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame();
	end
	AchievementFrame_SelectAchievement(achievementID);
end

function GuildFrame_LinkItem(button, itemID, itemLink)
	local _;
	if ( not itemLink ) then
		_, itemLink = GetItemInfo(itemID);
	end
	if ( itemLink ) then
		if ( ChatEdit_GetActiveWindow() ) then
			ChatEdit_InsertLink(itemLink);
		else
			ChatFrame_OpenChat(itemLink);
		end
	end
end

function GuildFrame_UpdateScrollFrameWidth(scrollFrame)
	local newButtonWidth;
	local buttons = scrollFrame.buttons;

	if ( scrollFrame.scrollBar:IsShown() ) then
		if ( scrollFrame.wideButtons ) then
			newButtonWidth = BUTTON_WIDTH_WITH_SCROLLBAR;
		end
	else
		if ( not scrollFrame.wideButtons ) then
			newButtonWidth = BUTTON_WIDTH_NO_SCROLLBAR;
		end
	end
	if ( newButtonWidth ) then
		for i = 1, #buttons do
			buttons[i]:SetWidth(newButtonWidth);
		end
		scrollFrame.wideButtons = not scrollFrame.wideButtons;
		scrollFrame:SetWidth(newButtonWidth);
		scrollFrame.scrollChild:SetWidth(newButtonWidth);
	end	
end

--****** Panels/Popups **********************************************************

function GuildFrame_RegisterPanel(frame)
	tinsert(GUILDFRAME_PANELS, frame:GetName());
end

function GuildFrame_ShowPanel(frameName)
	local frame;
	for index, value in pairs(GUILDFRAME_PANELS) do
		if ( value == frameName ) then
			frame = _G[value];
		else
			_G[value]:Hide();
		end	
	end
	if ( frame ) then
		frame:Show();
	end
end

function GuildFrame_RegisterPopup(frame)
	tinsert(GUILDFRAME_POPUPS, frame:GetName());
end

function GuildFramePopup_Show(frame)
	local name = frame:GetName();
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		if ( name ~= value ) then
			_G[value]:Hide();
		end
	end
	frame:Show();
end

function GuildFramePopup_Toggle(frame)
	if ( frame:IsShown() ) then
		frame:Hide();
	else
		GuildFramePopup_Show(frame);
	end
end

function CloseGuildMenus()
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		local frame = _G[value];
		if ( frame:IsShown() ) then
			frame:Hide();
			return true;
		end
	end
end

--****** Tabs *******************************************************************

function GuildFrame_TabClicked(self)
	local updateRosterCount = false;
	local tabIndex = self:GetID();
	CloseGuildMenus();	
	PanelTemplates_SetTab(self:GetParent(), tabIndex);
	if ( tabIndex == 1 ) then -- Guild
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildMainFrame");
		-- inset changes are in GuildMainFrame_OnShow()
		GuildFrameBottomInset:Show();
		GuildXPFrame:Show();
		GuildFactionFrame:Show();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 2 ) then -- Roster 
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRosterFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -90);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPFrame:Hide();
		GuildFactionFrame:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
	elseif ( tabIndex == 3 ) then -- News
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildNewsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPFrame:Show();
		GuildFactionFrame:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
	elseif ( tabIndex == 4 ) then -- Rewards
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRewardsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildXPFrame:Hide();
		GuildFactionFrame:Show();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 5 ) then -- Info
		ButtonFrameTemplate_ShowButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildInfoFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPFrame:Hide();
		GuildFactionFrame:Hide();
		GuildFrameMembersCountLabel:Hide();
	end
	if ( updateRosterCount ) then
		GuildRoster();
		GuildFrameMembersCount:Show();
	else
		GuildFrameMembersCount:Hide();
	end
end

--****** Progress Bars **********************************************************

function GuildXPBar_OnLoad()
	local MAX_BAR = GuildXPBar:GetWidth();
	local space = MAX_BAR / 5;
	local offset = space - 3;
	GuildXPBarDivider1:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space;
	GuildXPBarDivider2:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space - 1;
	GuildXPBarDivider3:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);
	offset = offset + space - 1;
	GuildXPBarDivider4:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0);	
end

function GuildXPBar_OnEnter(self)
	local currentXP, remainingXP, dailyXP, maxDailyXP, _, _, isUncapped = UnitGetGuildXP("player");
	local nextLevelXP = currentXP + remainingXP;
	local percentTotal = tostring(math.ceil((currentXP / nextLevelXP) * 100));
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(GUILD_EXPERIENCE);
	GameTooltip:AddLine(GUILD_EXPERIENCE_TOOLTIP, 1, 1, 1, 1);
	GameTooltip:AddLine(" ");
	if ( isUncapped ) then
		GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_NO_CAP, UNCAPPED_GUILD_LEVEL), 1, 1, 1, 1);
		GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, TextStatusBar_CapDisplayOfNumericValue(currentXP), TextStatusBar_CapDisplayOfNumericValue(nextLevelXP), percentTotal));
	else
		GameTooltip:AddLine(GUILD_EXPERIENCE_CAP, 1, 1, 1, 1);
		GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, TextStatusBar_CapDisplayOfNumericValue(currentXP), TextStatusBar_CapDisplayOfNumericValue(nextLevelXP), percentTotal));
		local percentDaily = tostring(math.ceil((dailyXP / maxDailyXP) * 100));
		GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_DAILY, TextStatusBar_CapDisplayOfNumericValue(dailyXP), TextStatusBar_CapDisplayOfNumericValue(maxDailyXP), percentDaily));	
	end
	GameTooltip:Show();
end

function GuildFactionBar_OnEnter(self)
	local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _, repToCap, weeklyCap = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	
	GuildFactionBarLabel:Show();
	local name, description = GetGuildFactionInfo();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(GUILD_REPUTATION);
	GameTooltip:AddLine(description, 1, 1, 1, 1, 1);
	GameTooltip:AddLine("\n"..GUILD_REPUTATION_CAP, 1, 1, 1, 1, 1);
	local percentTotal = tostring(math.ceil((barValue / barMax) * 100));
	GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, TextStatusBar_CapDisplayOfNumericValue(barValue), TextStatusBar_CapDisplayOfNumericValue(barMax), percentTotal));
	local weeklyRep = weeklyCap - repToCap;
	local percentWeekly = tostring(math.ceil((weeklyRep / weeklyCap) * 100));
	GameTooltip:AddLine(string.format(GUILD_REPUTATION_WEEKLY, TextStatusBar_CapDisplayOfNumericValue(weeklyRep), TextStatusBar_CapDisplayOfNumericValue(weeklyCap), percentWeekly));	
	GameTooltip:Show();
end

function GuildBar_SetProgress(bar, currentValue, maxValue, capValue)
	local MAX_BAR = bar:GetWidth() - 4;
	local progress = min(MAX_BAR * currentValue / maxValue, MAX_BAR);
	local capAtEdge;
	bar.progress:SetWidth(progress + 1);
	if ( capValue + currentValue >= maxValue ) then
		capValue = maxValue - currentValue;
		capAtEdge = true;
	end
	local capWidth = MAX_BAR * capValue / maxValue;
	if ( capWidth > 0 ) then
		bar.cap:SetWidth(capWidth);
		bar.cap:Show();
		-- don't show cap marker if cap goes all the way to the end
		if ( capAtEdge ) then
			bar.capMarker:Hide();
		else
			bar.capMarker:Show();
		end
	else
		bar.cap:Hide();
		bar.capMarker:Hide();
	end
	-- hide shadow on progress bar near the right edge
	if ( progress > MAX_BAR - 4 ) then
		bar.shadow:Hide();
	else
		bar.shadow:Show();
	end
	currentValue = TextStatusBar_CapDisplayOfNumericValue(currentValue);
	maxValue = TextStatusBar_CapDisplayOfNumericValue(maxValue);
end

--*******************************************************************************
--   Guild Panel
--*******************************************************************************

function GuildMainFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildPerksContainer.update = GuildPerks_Update;
	HybridScrollFrame_CreateButtons(GuildPerksContainer, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");	
	self:RegisterEvent("GUILD_PERK_UPDATE");
	self:RegisterEvent("GUILD_NEWS_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_MOTD");
	-- faction icon
	if ( GetGuildFactionGroup() == 0 ) then  -- horde
		GuildNewPerksFrameFaction:SetTexCoord(0.42871094, 0.53808594, 0.60156250, 0.87890625);
	else  -- alliance
		GuildNewPerksFrameFaction:SetTexCoord(0.31640625, 0.42675781, 0.60156250, 0.88281250);
	end
	-- create buttons table for news update
	local buttons = { };
	for i = 1, 9 do
		tinsert(buttons, _G["GuildUpdatesButton"..i]);
	end
	GuildMainFrame.buttons = buttons;
end

function GuildMainFrame_OnShow(self)
	-- inset stuff
	GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
	if ( not GuildMainFrame.allPerks ) then
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 170);
		GuildFrameBottomInset:Show();
	else
		GuildFrameBottomInset:Hide();
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
	end
	GuildMainFrame_UpdatePerks();
	GuildNewsSort(1);	-- disregard filters and stickies
end

function GuildMainFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	if ( event == "GUILD_PERK_UPDATE" ) then
		GuildMainFrame_UpdatePerks();
	elseif ( event == "GUILD_NEWS_UPDATE" or event == "GUILD_ROSTER_UPDATE" or event == "GUILD_MOTD" ) then
		GuildMainFrame_UpdateNewsEvents();
	end
end

--****** News/Events ************************************************************

function GuildMainFrame_UpdateNewsEvents()
	local numNews = GetNumGuildNews();
	if ( GetGuildRosterMOTD() ~= "" ) then
		numNews = numNews + 1;
	end
	local numEvents = CalendarGetNumGuildEvents();

	-- figure out a place to divide news from events
	local divider;
	local maxNews = max(1, numNews);
	local maxEvents = max(1, numEvents);
	if ( maxNews + maxEvents <= 7 ) then
		if ( maxNews <= 4 and maxEvents <= 4 ) then
			divider = 5;
		else
			divider = maxNews + 1;
		end
	else
		if ( maxEvents <= 4 ) then
			divider = 9 - maxEvents;
		else
			divider = min(4, maxNews) + 1;
		end
	end
	
	local button;
	local buttons = GuildMainFrame.buttons;
	-- news
	if ( numNews == 0 ) then
		GuildUpdatesNoNews:Show();
		GuildUpdatesNoNews:SetPoint("TOP", GuildUpdatesButton1);
		GuildUpdatesNoNews:SetHeight((divider - 1) * 18);
	else
		GuildUpdatesNoNews:Hide();
	end
	for i = 1, divider - 1 do
		buttons[i]:SetHeight(18);
		buttons[i].isEvent = nil;
	end
	GuildNews_Update(true, divider - 1);
	
	-- divider
	button = _G["GuildUpdatesButton"..divider];
	GuildUpdatesDivider:SetPoint("CENTER", button);
	button:Hide();
	button:SetHeight(11);
	-- events
	if ( numEvents == 0 ) then
		GuildUpdatesNoEvents:Show();
		GuildUpdatesNoEvents:SetPoint("TOP", _G["GuildUpdatesButton"..(divider + 1)]);
		GuildUpdatesNoEvents:SetHeight((9 - divider) * 18);
	else
		GuildUpdatesNoEvents:Hide();
	end
	for i = 1, 9 - divider do
		button = buttons[divider + i];
		if ( i > numEvents ) then
			button:Hide();
		else
			button:SetHeight(18);
			-- check if this button used to show news
			if ( not button.isEvent ) then
				button.isEvent = true;
				button.icon:Show();
				button.dash:Hide();
			end
			GuildInfoEvents_SetButton(button, i);
			button:Show();
		end
	end
end

--****** Perks ******************************************************************

function GuildPerksButton_OnEnter(self)
	GuildPerksContainer.activeButton = self;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 36, 0);
	GameTooltip:SetHyperlink(GetSpellLink(self.spellID));
end

function GuildMainFrame_UpdatePerks()
	local guildLevel = GetGuildLevel();
	local perkIndex = guildLevel - 1;	-- no perk at first level
	if ( perkIndex < 1 ) then
		GuildLatestPerkButton:Hide();
	else
		GuildLatestPerkButton:Show();
		local name, spellID, iconTexture = GetGuildPerkInfo(perkIndex);
		GuildLatestPerkButtonIconTexture:SetTexture(iconTexture);
		GuildLatestPerkButtonName:SetText(name);
		GuildLatestPerkButton.spellID = spellID;
	end
	if ( guildLevel == MAX_GUILD_LEVEL ) then
		GuildNextPerkButton:Hide();
	else
		local name, spellID, iconTexture = GetGuildPerkInfo(perkIndex + 1);
		GuildNextPerkButtonIconTexture:SetTexture(iconTexture);
		GuildNextPerkButtonIconTexture:SetDesaturated(1);
		GuildNextPerkButtonName:SetText(name);
		GuildNextPerkButtonLabel:SetFormattedText(GUILD_NEXT_PERK_LEVEL, guildLevel + 1);
		GuildNextPerkButton.spellID = spellID;
		GuildNextPerkButton:Show();
	end
	GuildPerks_Update();
end

function GuildPerks_Update()
	local scrollFrame = GuildPerksContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numPerks = GetNumGuildPerks();
	local guildLevel = GetGuildLevel();
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numPerks ) then
			local name, spellID, iconTexture, level = GetGuildPerkInfo(index);
			button.name:SetText(name);
			button.level:SetFormattedText(PERK_LEVEL, level);
			button.icon:SetTexture(iconTexture);
			button.spellID = spellID;
			button:Show();
			if ( level > guildLevel ) then
				button:EnableDrawLayer("BORDER");
				button:DisableDrawLayer("BACKGROUND");
				button.icon:SetDesaturated(1);
				button.name:SetFontObject(GameFontNormalLeftGrey);
				button.lock:Show();
				button.level:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				button:EnableDrawLayer("BACKGROUND");
				button:DisableDrawLayer("BORDER");
				button.icon:SetDesaturated(0);
				button.name:SetFontObject(GameFontHighlight);
				button.lock:Hide();
				button.level:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
		else
			button:Hide();
		end
	end
	local totalHeight = numPerks * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
		
	-- update tooltip
	if ( scrollFrame.activeButton ) then
		GuildPerksButton_OnEnter(scrollFrame.activeButton);
	end
end

function GuildPerksToggleButton_OnClick(self)
	if ( GuildMainFrame.allPerks ) then
		GuildMainFrame.allPerks = nil;
		PlaySound("igSpellBookClose");
		GuildNewPerksFrame:Show();
		GuildAllPerksFrame:Hide();
		GuildPerksToggleButtonRightText:SetText(GUILD_VIEW_ALL_PERKS_LINK);
		GuildPerksToggleButtonArrow:SetTexCoord(0.45312500, 0.64062500, 0.01562500, 0.20312500);		
		-- inset stuff
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 170);
		GuildFrameBottomInset:Show();
		GuildPerksToggleButton:SetPoint("TOPLEFT", GuildFrameInset, 0, -192);
	else
		GuildMainFrame.allPerks = true;
		PlaySound("igSpellBookOpen");
		GuildAllPerksFrame:Show();
		GuildNewPerksFrame:Hide();
		GuildPerksToggleButtonRightText:SetText(GUILD_VIEW_NEW_PERKS_LINK);
		GuildPerksToggleButtonArrow:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500);		
		-- inset stuff
		GuildFrameBottomInset:Hide();
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildPerksToggleButton:SetPoint("TOPLEFT", GuildFrameInset);
	end
end