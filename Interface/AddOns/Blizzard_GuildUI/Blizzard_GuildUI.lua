UIPanelWindows["GuildFrame"] = { area = "left", pushable = 1, whileDead = 1 };
local GUILDFRAME_PANELS = { };
local GUILDFRAME_POPUPS = { };
local BUTTON_WIDTH_WITH_SCROLLBAR = 298;
local BUTTON_WIDTH_NO_SCROLLBAR = 320;

function GuildFrame_OnLoad(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("GUILD_RENAME_REQUIRED");
	self:RegisterEvent("REQUIRED_GUILD_RENAME_RESULT");
	GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
	PanelTemplates_SetNumTabs(self, 5);
	RequestGuildRewards();
--	QueryGuildXP();
	QueryGuildNews();
	C_Calendar.OpenCalendar();		-- to get event data
	GuildFrame_UpdateTabard();
	GuildFrame_UpdateFaction();
	local guildName, _, _, realm = GetGuildInfo("player");
	local fullName;
	if (realm) then
		fullName = string.format(FULL_PLAYER_NAME, guildName, realm);
	else
		fullName = guildName
	end
	GuildFrameTitleText:SetText(fullName);
	local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumGuildMembers();
	GuildFrameMembersCount:SetText(onlineAndMobileMembers.." / "..totalMembers);
end

function GuildFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	GuildFrameTab1:Show();
	GuildFrameTab3:Show();
	GuildFrameTab4:Show();
	GuildFrameTab2:SetPoint("LEFT", GuildFrameTab1, "RIGHT", -15, 0);
	GuildFrameTab5:SetPoint("LEFT", GuildFrameTab4, "RIGHT", -15, 0);
	if ( not PanelTemplates_GetSelectedTab(self) ) then
		GuildFrame_TabClicked(GuildFrameTab1);
	end
	C_GuildInfo.GuildRoster();
	UpdateMicroButtons();
	GuildNameChangeAlertFrame.topAnchored = true;
	GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
	GuildFrame_CheckName();

	if (GuildFrameTitleText:IsTruncated()) then
		GuildFrame.TitleMouseover.tooltip = GuildFrameTitleText:GetText();
	else
		GuildFrame.TitleMouseover.tooltip = nil;
	end

	-- keep points frame centered
	local pointFrame = GuildPointFrame;
	pointFrame.SumText:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints(true)));
	local width = pointFrame.SumText:GetStringWidth() + pointFrame.LeftCap:GetWidth() + pointFrame.RightCap:GetWidth() + pointFrame.Icon:GetWidth();
	pointFrame:SetWidth(width);
end

function GuildFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
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
		local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumGuildMembers();
		GuildFrameMembersCount:SetText(onlineAndMobileMembers.." / "..totalMembers);
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
--		QueryGuildXP();
		QueryGuildNews();
	elseif ( event == "GUILD_RENAME_REQUIRED" ) then
		GuildFrame.hasForcedNameChange = ...;
		GuildFrame_CheckName();
	elseif ( event == "REQUIRED_GUILD_RENAME_RESULT" ) then
		local success = ...
		if ( success ) then
			GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
			GuildFrame_CheckName();
		else
			UIErrorsFrame:AddMessage(ERR_GUILD_NAME_INVALID, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

function GuildFrame_UpdateFaction()
	local factionBar = GuildFactionFrame;
	local gender = UnitSex("player");
	local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _ = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	GuildFactionBarLabel:SetText(barValue.." / "..barMax);
	GuildFactionFrameStanding:SetText(factionStandingtext);
	GuildBar_SetProgress(GuildFactionBar, barValue, barMax);
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

function GuildFrame_CheckName()
	if ( GuildFrame.hasForcedNameChange ) then
		local clickableHelp = false
		GuildNameChangeAlertFrame:Show();

		if ( IsGuildLeader() ) then
			GuildNameChangeFrame.gmText:Show();
			GuildNameChangeFrame.memberText:Hide();
			GuildNameChangeFrame.button:SetText(ACCEPT);
			GuildNameChangeFrame.button:SetPoint("TOP", GuildNameChangeFrame.editBox, "BOTTOM", 0, -10);
			GuildNameChangeFrame.renameText:Show();
			GuildNameChangeFrame.editBox:Show();
		else
			clickableHelp = GuildNameChangeAlertFrame.topAnchored;
			GuildNameChangeFrame.gmText:Hide();
			GuildNameChangeFrame.memberText:Show();
			GuildNameChangeFrame.button:SetText(OKAY);
			GuildNameChangeFrame.button:SetPoint("TOP", GuildNameChangeFrame.memberText, "BOTTOM", 0, -30);
			GuildNameChangeFrame.renameText:Hide();
			GuildNameChangeFrame.editBox:Hide();
		end


		if ( clickableHelp ) then
			GuildNameChangeAlertFrame.alert:SetFontObject(GameFontHighlight);
			GuildNameChangeAlertFrame.alert:ClearAllPoints();
			GuildNameChangeAlertFrame.alert:SetPoint("BOTTOM", GuildNameChangeAlertFrame, "CENTER", 0, 0);
			GuildNameChangeAlertFrame.alert:SetWidth(190);
			GuildNameChangeAlertFrame:SetPoint("TOP", 15, -4);
			GuildNameChangeAlertFrame:SetSize(256, 60);
			GuildNameChangeAlertFrame:Enable();
			GuildNameChangeAlertFrame.clickText:Show();
			GuildNameChangeFrame:Hide();
		else
			GuildNameChangeAlertFrame.alert:SetFontObject(GameFontHighlightMedium);
			GuildNameChangeAlertFrame.alert:ClearAllPoints();
			GuildNameChangeAlertFrame.alert:SetPoint("CENTER", GuildNameChangeAlertFrame, "CENTER", 0, 0);
			GuildNameChangeAlertFrame.alert:SetWidth(220);
			GuildNameChangeAlertFrame:SetPoint("TOP", 0, -82);
			GuildNameChangeAlertFrame:SetSize(300, 40);
			GuildNameChangeAlertFrame:Disable();
			GuildNameChangeAlertFrame.clickText:Hide();
			GuildNameChangeFrame:Show();
		end
	else
		GuildNameChangeAlertFrame:Hide();
		GuildNameChangeFrame:Hide();
	end
end

function GuildPointFrame_OnEnter(self)
	self.Highlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(GUILD_POINTS_TT, 1, 1, 1);
	GameTooltip:Show();
end

function GuildPointFrame_OnLeave(self)
	self.Highlight:Hide();
	GameTooltip:Hide();
end

function GuildPointFrame_OnMouseUp(self)
	if ( IsInGuild() and CanShowAchievementUI() ) then
		AchievementFrame_LoadUI();
		AchievementFrame_ToggleAchievementFrame(false, true);
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
	itemLink = itemLink or select(2, GetItemInfo(itemID));
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
	if ( tabIndex == 1 ) then -- News
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildNewsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildPointFrame:Show();
		GuildFactionFrame:Show();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 2 ) then -- Roster
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRosterFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -90);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildPointFrame:Hide();
		GuildFactionFrame:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
	elseif ( tabIndex == 3 ) then -- Perks
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildPerksFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildPointFrame:Show();
		GuildFactionFrame:Hide();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Show();
		GuildPerksFrameMembersCountLabel:Hide();
		GuildFrameBottomInset:Hide();
	elseif ( tabIndex == 4 ) then -- Rewards
		ButtonFrameTemplate_HideButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildRewardsFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44);
		GuildFrameBottomInset:Hide();
		GuildPointFrame:Hide();
		GuildFactionFrame:Show();
		updateRosterCount = true;
		GuildFrameMembersCountLabel:Hide();
	elseif ( tabIndex == 5 ) then -- Info
		ButtonFrameTemplate_ShowButtonBar(GuildFrame);
		GuildFrame_ShowPanel("GuildInfoFrame");
		GuildFrameInset:SetPoint("TOPLEFT", 4, -65);
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26);
		GuildFrameBottomInset:Hide();
		GuildPointFrame:Hide();
		GuildFactionFrame:Hide();
		GuildFrameMembersCountLabel:Hide();
	end
	if ( updateRosterCount ) then
		C_GuildInfo.GuildRoster();
		GuildFrameMembersCount:Show();
	else
		GuildFrameMembersCount:Hide();
	end
end

function GuildFactionBar_OnEnter(self)
	local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _ = GetGuildFactionInfo();
	local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID);
	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;

	if (barMax == 0) then
		barMax = 1;
	end

	GuildFactionBarLabel:Show();
	local name, description = GetGuildFactionInfo();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(GUILD_REPUTATION);
	GameTooltip:AddLine(description, 1, 1, 1, true);
	local percentTotal = tostring(math.ceil((barValue / barMax) * 100));
	GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax), percentTotal));
	GameTooltip:Show();
end

function GuildBar_SetProgress(bar, currentValue, maxValue)
	if (maxValue == 0) then
		maxValue = 1;
	end

	local MAX_BAR = bar:GetWidth() - 4;
	local progress = min(MAX_BAR * currentValue / maxValue, MAX_BAR);
	bar.progress:SetWidth(progress + 1);
	bar.cap:Hide();
	bar.capMarker:Hide();
	-- hide shadow on progress bar near the right edge
	if ( progress > MAX_BAR - 4 ) then
		bar.shadow:Hide();
	else
		bar.shadow:Show();
	end
	currentValue = BreakUpLargeNumbers(currentValue);
	maxValue = BreakUpLargeNumbers(maxValue);
end

--*******************************************************************************
--   Guild Panel
--*******************************************************************************

function GuildPerksFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildPerksContainer.update = GuildPerks_Update;
	HybridScrollFrame_CreateButtons(GuildPerksContainer, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	-- create buttons table for news update
	local buttons = { };
	for i = 1, 9 do
		tinsert(buttons, _G["GuildUpdatesButton"..i]);
	end
	GuildPerksFrame.buttons = buttons;
end

function GuildPerksFrame_OnShow(self)
	GuildPerks_Update();
end

function GuildPerksFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	if ( event == "GUILD_ROSTER_UPDATE" ) then
		local canRequestRosterUpdate = ...;
		if ( canRequestRosterUpdate ) then
			C_GuildInfo.GuildRoster();
		end
	end
end

--****** News/Events ************************************************************
function GuildEventButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( CalendarFrame ) then
			CalendarFrame_OpenToGuildEventIndex(self.index);
		else
			ToggleCalendar();
			CalendarFrame_OpenToGuildEventIndex(self.index);
		end
	end
end

--****** Perks ******************************************************************

function GuildPerksButton_OnEnter(self)
	GuildPerksContainer.activeButton = self;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 36, 0);
	local spellLink = GetSpellLink(self.spellID);
	GameTooltip:SetHyperlink(spellLink);
end

function GuildPerks_Update()
	local scrollFrame = GuildPerksContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numPerks = GetNumGuildPerks();
--	local guildLevel = GetGuildLevel();

	local totalHeight = numPerks * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	local buttonWidth = scrollFrame.buttonWidth;
	if( totalHeight > displayedHeight )then
		scrollFrame:SetPoint("TOPLEFT", GuildAllPerksFrame, "TOPLEFT", 0, scrollFrame.yOffset);
		scrollFrame:SetWidth( scrollFrame.width );
		scrollFrame:SetHeight( scrollFrame.height );
	else
		buttonWidth = scrollFrame.buttonWidthNoScroll;
		scrollFrame:SetPoint("TOPLEFT", GuildAllPerksFrame, "TOPLEFT", 0, scrollFrame.yOffsetNoScroll);
		scrollFrame:SetWidth( scrollFrame.widthNoScroll );
		scrollFrame:SetHeight( scrollFrame.heightNoScroll );
	end
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numPerks ) then
			local name, spellID, iconTexture = GetGuildPerkInfo(index);
			button.name:SetText(name);
			button.icon:SetTexture(iconTexture);
			button.spellID = spellID;
			button:Show();
			button:SetWidth(buttonWidth);
		else
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	-- update tooltip
	if ( scrollFrame.activeButton ) then
		GuildPerksButton_OnEnter(scrollFrame.activeButton);
	end
end