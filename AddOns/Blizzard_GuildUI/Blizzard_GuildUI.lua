UIPanelWindows["GuildFrame"] = { area = "left", pushable = 1};
local GUILDFRAME_PANELS = { };
local GUILDFRAME_POPUPS = { };

function GuildFrame_OnLoad(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("GUILD_XP_UPDATE");
	PanelTemplates_SetNumTabs(self, 5);
	PanelTemplates_DisableTab(self, 3);		-- no news for now
	PanelTemplates_DisableTab(self, 4);		-- no rewards for now
	QueryGuildXP();
	GuildRoster();
	GuildFrame_UpdateLevel();
	GuildFrame_UpdateXP();
	GuildFrame_UpdatePlayerRank();
	GuildFrame_CheckPermissions();
end

function GuildFrame_OnShow(self)
	UpdateMicroButtons();
end

function GuildFrame_OnHide(self)
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
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		GuildFrame_UpdatePlayerRank();
		GuildFrame_CheckPermissions();
		if ( not IsInGuild() and self:IsShown() ) then
			HideUIPanel(self);
		end
	end
end

function GuildFrame_UpdateLevel()
	local guildLevel = GetGuildLevel();
	GuildLevelFrameText:SetText(guildLevel);
	if ( GetGuildFactionGroup() == 0 ) then
		GuildXPBarLevelText:SetFormattedText(GUILD_LEVEL_AND_FACTION, guildLevel, FACTION_HORDE);
	else
		GuildXPBarLevelText:SetFormattedText(GUILD_LEVEL_AND_FACTION, guildLevel, FACTION_ALLIANCE);
	end	
end

function GuildFrame_UpdateXP()
	local currentXP, nextLevelXP, dailyXP, maxDailyXP = UnitGetGuildXP("player");
	GuildXPBar_SetProgress(currentXP, nextLevelXP, maxDailyXP - dailyXP);
end

function GuildFrame_UpdatePlayerRank()
	local guildName, title, rank = GetGuildInfo("player");
	if ( guildName ) then
		GuildFrameTitleText:SetFormattedText(GUILD_TITLE_TEMPLATE, title, guildName);
	else 
		GuildFrameTitleText:SetText("");
	end
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

--****** Panels/Popups **********************************************************

function GuildFrame_RegisterPanel(frame)
	tinsert(GUILDFRAME_PANELS, frame:GetName());
end

function GuildFrame_ShowPanel(frameName)
	for index, value in pairs(GUILDFRAME_PANELS) do
		if ( value == frameName ) then
			_G[value]:Show()
		else
			_G[value]:Hide();
		end	
	end 
end

function GuildFrame_RegisterPopup(frame)
	tinsert(GUILDFRAME_PANELS, frame:GetName());
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
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 170);
		GuildFrameBottomInset:Show();
		GuildXPBar:Show();
		GuildFactionBar:Show();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 2 ) then -- Roster 
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRosterFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -90);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildFactionBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
	elseif ( tabIndex == 3 ) then -- News
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildNewsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Show();
		GuildFactionBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
	elseif ( tabIndex == 4 ) then -- Rewards
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRewardsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildFactionBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 5 ) then -- Info
		ButtonFrameTemplate_ShowButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildInfoFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildFactionBar:Hide();
		GuildAddMemberButton:Show();
		GuildControlButton:Show();
		GuildViewLogButton:Show();
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 6 ) then -- old stuff
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 40);
		GuildFrameBottomInset:Hide();
		GuildXPBar:Hide();
		GuildFactionBar:Hide();
		GuildAddMemberButton:Hide();
		GuildControlButton:Hide();
		GuildViewLogButton:Hide();
		GuildFrameMembersCountLabel:Hide();
		GuildFrame_ShowPanel("GuildDisplayFrame");
	end
	if ( updateRosterCount ) then
		GuildRoster();
		GuildFrameMembersCount:Show();
	else
		GuildFrameMembersCount:Hide();
	end
end

--****** XP Bar *****************************************************************

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
	local currentXP, nextLevelXP, dailyXP, maxDailyXP, playerXP = UnitGetGuildXP("player");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText("Guild Experience");
	GameTooltip:AddDoubleLine("Current:", currentXP, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine("Next level:", nextLevelXP, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddLine("Today", NORMAL_FONT_COLOR_CODE.r, NORMAL_FONT_COLOR_CODE.g, NORMAL_FONT_COLOR_CODE.b);
	GameTooltip:AddDoubleLine("Earned:", currentXP, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine("Remaining (cap):", maxDailyXP - currentXP, 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine("Your contribution:", playerXP, 1, 1, 1, 1, 1, 1);
	GameTooltip:Show();
end

function GuildXPBar_SetProgress(currentValue, maxValue, capValue)
	local MAX_BAR = GuildXPBar:GetWidth() - 4;
	local progress = MAX_BAR * currentValue / maxValue;
	
	GuildXPBarProgress:SetWidth(progress + 1);
	if ( capValue + currentValue > maxValue ) then
		capValue = maxValue - currentValue;
	end
	local capWidth = MAX_BAR * capValue / maxValue;
	if ( capWidth > 0 ) then
		GuildXPBarCap:SetWidth(capWidth);
		GuildXPBarCap:Show();
		GuildXPBarCapMarker:Show();
	else
		GuildXPBarCap:Hide();
		GuildXPBarCapMarker:Hide();
	end
	currentValue = TextStatusBar_CapDisplayOfNumericValue(currentValue);
	maxValue = TextStatusBar_CapDisplayOfNumericValue(maxValue);
	--GuildXPBarText:SetText(currentValue.."/"..maxValue);
end

--*******************************************************************************
--   Guild Panel
--*******************************************************************************

function GuildMainFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildPerksContainer.update = GuildPerks_Update;
	HybridScrollFrame_CreateButtons(GuildPerksContainer, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");	
	self:RegisterEvent("GUILD_PERK_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	-- faction icon
	if ( GetGuildFactionGroup() == 0 ) then  -- horde
		GuildNewPerksFrameFaction:SetTexCoord(0.42871094, 0.53808594, 0.60156250, 0.87890625);
		SetPortraitToTexture("GuildFramePortrait", "Interface\\Icons\\Spell_Misc_HellifrePVPThrallmarFavor");
	else  -- alliance
		GuildNewPerksFrameFaction:SetTexCoord(0.31640625, 0.42675781, 0.60156250, 0.88281250);
		SetPortraitToTexture("GuildFramePortrait", "Interface\\Icons\\Spell_Misc_HellifrePVPHonorHoldFavor");
	end
	-- select its tab
	GuildFrame_TabClicked(GuildFrameTab1);
	-- display news and events
	GuildMainFrame_SetUpdates(0, 0);
end

function GuildMainFrame_OnShow(self)
	GuildMainFrame_UpdateFaction();
	GuildMainFrame_UpdatePerks();
end

function GuildMainFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	if ( event == "GUILD_PERK_UPDATE" ) then
		GuildMainFrame_UpdatePerks();
	elseif ( event == "UPDATE_FACTION" ) then
		GuildMainFrame_UpdateFaction();
	end
end

--****** News/Events ************************************************************

function GuildMainFrame_SetUpdates(numNews, numEvents)
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
	-- news
	if ( numNews == 0 ) then
		GuildUpdatesNoNews:Show();
		GuildUpdatesNoNews:SetPoint("TOP", GuildUpdatesButton1);
		GuildUpdatesNoNews:SetHeight((divider - 1) * 18);
	else
		GuildUpdatesNoNews:Hide();
	end
	for i = 1, divider - 1 do
		button = _G["GuildUpdatesButton"..i];
		button:SetHeight(18);
		if ( i > numNews ) then
			button:Hide();
		else
			button.text:SetText("Placeholder guild news #"..i);
			button:Show();
			button.icon:Hide();
		end
	end
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
		button = _G["GuildUpdatesButton"..(divider + i)];
		button:SetHeight(18);
		if ( i > numEvents ) then
			button:Hide();
		else
			button.text:SetText("Placeholder guild event #"..i);
			button.icon:SetTexture("Interface\\LFGFrame\\LFGIcon-NAXXRAMAS");
			button.icon:Show();
			button:Show();
		end
	end
end

--****** Perks ******************************************************************

function GuildMainFrame_UpdatePerks()
	local guildLevel = GetGuildLevel();
	local maxLevels = GetNumGuildPerks();
	if ( guildLevel == 0 ) then
		GuildLatestPerkButton:Hide();
	else
		GuildLatestPerkButton:Show();
		local name, spellID, iconTexture = GetGuildPerkInfo(guildLevel);
		GuildLatestPerkButtonIconTexture:SetTexture(iconTexture);
		GuildLatestPerkButtonName:SetText(name);
		GuildLatestPerkButton.spellID = spellID;
	end
	if ( guildLevel == maxLevels ) then
		GuildNextPerkButton:Hide();
	else
		local nextGuildLevel = guildLevel + 1;
		local name, spellID, iconTexture = GetGuildPerkInfo(nextGuildLevel);
		GuildNextPerkButtonIconTexture:SetTexture(iconTexture);
		GuildNextPerkButtonIconTexture:SetDesaturated(1);
		GuildNextPerkButtonName:SetText(name);
		GuildNextPerkButtonLabel:SetFormattedText(GUILD_NEXT_PERK_LEVEL, nextGuildLevel);
		GuildNextPerkButton.spellID = spellID;
	end
	GuildPerks_Update();
end

function GuildMainFrame_UpdateFaction()
	local factionBar = GuildFactionBar;
	local gender = UnitSex("player");
	local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	barMin = 0;
	GuildFactionBarLabel:SetText(barValue.." / "..barMax);
	GuildFactionBarStanding:SetText(factionStandingtext);
	factionBar:SetMinMaxValues(0, barMax);
	factionBar:SetValue(barValue);
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
			button.level:SetText("Level "..level);
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
end

function GuildPerksToggleButton_OnClick(self)
	if ( GuildMainFrame.allPerks ) then
		GuildMainFrame.allPerks = nil;
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