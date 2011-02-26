UIPanelWindows["LookingForGuildFrame"] = { area = "left", pushable = 1, whileDead = 1 };

local GUILD_BUTTON_HEIGHT = 84;

function LookingForGuildFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self.Inset:SetPoint("TOPLEFT", 4, -64);
	
	LookingForGuildRequestButton:SetWidth(max(116, LookingForGuildRequestButton:GetTextWidth() + 24));
	LookingForGuildBrowseButton:SetWidth(max(116, LookingForGuildBrowseButton:GetTextWidth() + 24));

	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		LookingForGuildFrameTabardEmblem:SetTexture("Interface\\FriendsFrame\\PlusManz-Alliance");
		LookingForGuildFrameTabardEmblem:SetPoint("TOPLEFT", 1, 0);
	else
		LookingForGuildFrameTabardEmblem:SetTexture("Interface\\FriendsFrame\\PlusManz-Horde");	
		LookingForGuildFrameTabardEmblem:SetPoint("TOPLEFT", 0, 0);
	end
	
	LookingForGuildFrameTitleText:SetText(LOOKINGFORGUILD);
	
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("LF_GUILD_BROWSE_UPDATED");
end

function LookingForGuildFrame_OnShow(self)
	local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player");
	
	if ( canBeTank ) then
		LFG_EnableRoleButton(LookingForGuildTankButton);
		LookingForGuildTankButtonText:SetFontObject("GameFontHighlightSmall");
	else
		LFG_PermanentlyDisableRoleButton(LookingForGuildTankButton);
		LookingForGuildTankButtonText:SetFontObject("GameFontDisableSmall");
	end
	
	if ( canBeHealer ) then
		LFG_EnableRoleButton(LookingForGuildHealerButton);
		LookingForGuildHealerButtonText:SetFontObject("GameFontHighlightSmall");
	else
		LFG_PermanentlyDisableRoleButton(LookingForGuildHealerButton);
		LookingForGuildHealerButtonText:SetFontObject("GameFontDisableSmall");
	end
	
	if ( canBeDPS ) then
		LFG_EnableRoleButton(LookingForGuildDamagerButton);
		LookingForGuildDamagerButtonText:SetFontObject("GameFontHighlightSmall");
	else
		LFG_PermanentlyDisableRoleButton(LookingForGuildDamagerButton);
		LookingForGuildDamagerButtonText:SetFontObject("GameFontDisableSmall");
	end

	UpdateMicroButtons();
end

function LookingForGuildFrame_OnEvent(self, event)
	if ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( IsInGuild() and self:IsShown() ) then
			HideUIPanel(self);
		end
	elseif ( event == "LF_GUILD_BROWSE_UPDATED" ) then
		LookingForGuild_Update();
	end
end

function LookingForGuildFrame_OnHide(self)
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
		LookingForGuildRequestButton:Hide();
		LookingForGuildBrowseButton:Show();
	else
		LookingForGuildStartFrame:Hide();
		LookingForGuildBrowseFrame:Show();
		LookingForGuildRequestButton:Show();
		LookingForGuildBrowseButton:Hide();
	end
end

function LookingForGuildPlaystyleButton_OnClick(index, userClick)
	local param;
	if ( index == 1 ) then
		LookingForGuildCasualButton:SetChecked(1);
		LookingForGuildModerateButton:SetChecked(nil);
		LookingForGuildHardcoreButton:SetChecked(nil);
		param = LFGUILD_PARAM_CASUAL;
	elseif ( index == 2 ) then
		LookingForGuildCasualButton:SetChecked(nil);
		LookingForGuildModerateButton:SetChecked(1);
		LookingForGuildHardcoreButton:SetChecked(nil);
		param = LFGUILD_PARAM_MODERATE;
	else
		LookingForGuildCasualButton:SetChecked(nil);
		LookingForGuildModerateButton:SetChecked(nil);
		LookingForGuildHardcoreButton:SetChecked(1);
		param = LFGUILD_PARAM_HARDCORE;
	end
	if ( userClick ) then
		SetLookingForGuildSettings(param, true);
	end
end

function LookingForGuildRoleButton_OnClick(self)
	local checked = self:GetChecked();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	local id = self:GetParent():GetID();
	if ( id == 1 ) then
		SetLookingForGuildSettings(LFGUILD_PARAM_TANK, checked);
	elseif ( id == 2 ) then
		SetLookingForGuildSettings(LFGUILD_PARAM_HEALER, checked);
	else
		SetLookingForGuildSettings(LFGUILD_PARAM_DAMAGE, checked);
	end
	LookingForGuildBrowseButton_Update();
end

function LookingForGuildStartFrame_OnLoad(self)
	LookingForGuildPlaystyleFrameText:SetText(GUILD_PLAYSTYLE);
	LookingForGuildPlaystyleFrame:SetHeight(56);
	LookingForGuildAvailabilityFrameText:SetText(GUILD_AVAILABILITY);
	LookingForGuildAvailabilityFrame:SetHeight(56);
	LookingForGuildRolesFrameText:SetText(CLASS_ROLES);
	LookingForGuildRolesFrame:SetHeight(80);
	LookingForGuildCommentFrameText:SetText(COMMENT);
	LookingForGuildCommentFrame:SetHeight(112);

	local bCasual, bModerate, bHardcore, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetLookingForGuildSettings();
	-- playstyle
	if ( bModerate ) then
		LookingForGuildPlaystyleButton_OnClick(2);
	elseif ( bHardcore ) then
		LookingForGuildPlaystyleButton_OnClick(3);
	else
		LookingForGuildPlaystyleButton_OnClick(1);
	end
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
end

function LookingForGuildBrowseButton_Update()
	local bCasual, bModerate, bHardcore, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetLookingForGuildSettings();
	-- need to have at least 1 time and at least 1 role checked to be able to browse
	if ( bWeekdays or bWeekends ) and ( bTank or bHealer or bDamage ) then
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

function LookingForGuildBrowseFrame_OnLoad(self)
	LookingForGuildBrowseFrameContainer.update = LookingForGuild_Update;
	HybridScrollFrame_CreateButtons(LookingForGuildBrowseFrameContainer, "LookingForGuildGuildTemplate", 0, 0);
	
	LookingForGuildBrowseFrameContainerScrollBar.Show = 
		function (self)
			LookingForGuildBrowseFrameContainer:SetWidth(304);
			for _, button in next, LookingForGuildBrowseFrameContainer.buttons do
				button:SetWidth(301);
			end
			getmetatable(self).__index.Show(self);
		end	
	LookingForGuildBrowseFrameContainerScrollBar.Hide = 
		function (self)
			LookingForGuildBrowseFrameContainer:SetWidth(320);
			for _, button in next, LookingForGuildBrowseFrameContainer.buttons do
				button:SetWidth(320);
			end
			getmetatable(self).__index.Hide(self);
		end
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
	local selection = GetRecruitingGuildSelection();

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		local name, level, numMembers, achPoints, comment, requestPending = GetRecruitingGuildInfo(index);
		if ( name ) then
			button.name:SetText(name);
			button.level:SetText(level);
			button.numMembers:SetFormattedText(BROWSE_GUILDS_NUM_MEMBERS, numMembers);
			button.achPoints:SetText(achPoints);
			button.comment:SetText(comment);
			-- tabard
			local tabardInfo = { GetRecruitingGuildTabardInfo(index) };
			SetLargeGuildTabardTextures(nil, button.emblem, button.tabard, nil, tabardInfo);
			-- selection
			if ( requestPending ) then
				button.selectedTex:Show();
				button.pendingFrame:Show();
			else
				button.pendingFrame:Hide();
				if ( index == selection ) then
					button.selectedTex:Show();
				else
					button.selectedTex:Hide();
				end
			end
			
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end
	local totalHeight = numGuilds * GUILD_BUTTON_HEIGHT;
	local displayedHeight = numButtons * GUILD_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	if ( selection ) then
		LookingForGuildRequestButton:Enable();
	else
		LookingForGuildRequestButton:Disable();
	end
end

function LookingForGuildGuild_OnClick(self, button)
	if ( button == "LeftButton" ) then
		local name, level, numMembers, achPoints, comment, requestPending = GetRecruitingGuildInfo(self.index);
		if ( not requestPending ) then
			SetRecruitingGuildSelection(self.index);
			LookingForGuild_Update();
		end
	end
end

function LookingForGuild_RequestMembership()
	RequestGuildMembership();
	SetRecruitingGuildSelection(nil);
	LookingForGuild_Update();
end