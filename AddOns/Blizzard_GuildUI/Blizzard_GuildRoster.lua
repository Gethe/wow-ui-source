GUILD_DETAIL_NORM_HEIGHT = 195
GUILD_DETAIL_OFFICER_HEIGHT = 255
local GUILD_ROSTER_MAX_COLUMNS = 5;
local GUILD_ROSTER_MAX_STRINGS = 4;
local GUILD_ROSTER_BAR_MAX = 239;
local GUILD_ROSTER_BUTTON_OFFSET = 2;
local GUILD_ROSTER_BUTTON_HEIGHT = 20;
local currentGuildView;

local GUILD_ROSTER_COLUMNS = {
	playerStatus = { "level", "class", "wideName", "zone" },
	guildStatus = { "name", "rank", "note", "online" },
	contribution = { "level", "class", "wideName", "contribution" },
	pve = { "level", "class", "name", "valor", "hero" },
	pvp = { "level", "class", "name", "honor", "conquest" },
	achievement = { "level", "class", "wideName", "achievement" },
	tradeskill = { "wideName", "zone", "skill" },
};

local GUILD_ROSTER_COLUMN_DATA = {
	level = { width = 32, text = LEVEL_ABBR, stringJustify="CENTER" },
	class = { width = 32, text = CLASS_ABBR, hasIcon = true },
	name = { width = 81, text = NAME, stringJustify="LEFT" },
	wideName = { width = 101, text = NAME, sortType = "name", stringJustify="LEFT" },
	rank = { width = 76, text = RANK, stringJustify="LEFT" },
	note = { width = 76, text = LABEL_NOTE, stringJustify="LEFT" },
	online = { width = 76, text = LASTONLINE, stringJustify="LEFT" },
	zone = { width = 144, text = ZONE, stringJustify="LEFT" },	
	valor = { width = 83, text = "Valor", stringJustify="RIGHT" },
	hero = { width = 83, text = "Hero", stringJustify="RIGHT" },
	honor = { width = 83, text = "Honor", stringJustify="RIGHT" },
	conquest = { width = 83, text = "Conquest", stringJustify="RIGHT" },
	contribution = { width = 144, text = "Contribution", stringJustify="RIGHT", hasBar = true },
	achievement = { width = 144, text = "Achievement", stringJustify="RIGHT" },
	skill = { width = 63, text = "Skill", stringJustify="LEFT" },
};

function GuildRosterFrame_OnLoad(self)
	GuildFrame_RegisterPanel(self);
	GuildRosterContainer.update = GuildRoster_Update;
	HybridScrollFrame_CreateButtons(GuildRosterContainer, "GuildRosterButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -GUILD_ROSTER_BUTTON_OFFSET, "TOP", "BOTTOM");
	GuildRosterContainerScrollBar.doNotHide = true;
	GuildRosterShowOfflineButton:SetChecked(GetGuildRosterShowOffline());
	self:RegisterEvent("GUILD_TRADESKILL_UPDATE");
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GUILD_RECIPE_KNOWN_BY_MEMBERS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	GuildRoster_SetView("playerStatus");
	SetGuildRosterSelection(0);
	--GuildMemberDetailRankText:SetPoint("RIGHT", GuildFramePromoteButton, "LEFT");	
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
	self.doRecipeQuery = true;
end

function GuildRosterFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	if ( event == "GUILD_TRADESKILL_UPDATE" ) then
		if ( currentGuildView == "tradeskill" ) then
			QueryGuildRecipes();
			GuildRoster_Update();
		else
			GuildRosterFrame.doRecipeQuery = true;
		end
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( currentGuildView ~= "tradeskill" ) then
			local arg1 = ...;
			if ( arg1 ) then
				GuildRoster();
			end		
			GuildRoster_Update();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self.doRecipeQuery = true;
	end
end

function GuildRosterFrame_OnShow(self)
	GuildRoster_RecipeQueryCheck();
	GuildRoster_Update();
end

function GuildRoster_RecipeQueryCheck()
	if ( GuildRosterFrame.doRecipeQuery ) then
		QueryGuildRecipes();
		GuildRosterFrame.doRecipeQuery = nil;
	end
end

function GuildRoster_GetLastOnline(guildIndex)
	return RecentTimeDate( GetGuildRosterLastOnline(guildIndex) );
end

function GuildRoster_SortByColumn(column)
	if ( column.sortType ) then
		if ( currentGuildView == "tradeskill" ) then
			SortGuildTradeSkill(column.sortType);
		else
			SortGuildRoster(column.sortType);
		end
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

--****** Guild members **********************************************************

function GuildRosterButton_SetStringText(buttonString, text, isOnline, class)
	buttonString:SetText(text);
	if ( isOnline ) then
		if ( class ) then
			local classColor = RAID_CLASS_COLORS[class];
			buttonString:SetTextColor(classColor.r, classColor.g, classColor.b);
		else
			buttonString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		buttonString:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function GuildRoster_Update()
	local scrollFrame = GuildRosterContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index, class;
	local totalMembers, onlineMembers = GetNumGuildMembers();
	local selectedGuildMember = GetGuildRosterSelection();
	
	if ( currentGuildView == "tradeskill" ) then
		GuildRoster_UpdateTradeSkills();
		return;
	end

	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;	
	-- Get selected guild member info
	name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(selectedGuildMember);
	GuildFrame.selectedName = name;
	-- If there's a selected guildmember
	if ( selectedGuildMember > 0 ) then
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(GuildFrame.selectedName);
		GuildMemberDetailLevel:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
		GuildMemberDetailZoneText:SetText(zone);
		GuildMemberDetailRankText:SetText(rank);
		if ( online ) then
			GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL);
		else
			GuildMemberDetailOnlineText:SetText(GuildRoster_GetLastOnline(selectedGuildMember));
		end
		-- Update public note
		if ( CanEditPublicNote() ) then
			PersonalNoteText:SetTextColor(1.0, 1.0, 1.0);
			if ( (not note) or (note == "") ) then
				note = GUILD_NOTE_EDITLABEL;
			end
		else
			PersonalNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildMemberNoteBackground:EnableMouse(CanEditPublicNote());
		PersonalNoteText:SetText(note);
		-- Update officer note
		if ( CanViewOfficerNote() ) then
			if ( CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(CanEditOfficerNote());
			OfficerNoteText:SetText(officernote);

			-- Resize detail frame
			GuildMemberDetailOfficerNoteLabel:Show();
			GuildMemberOfficerNoteBackground:Show();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT);
		else
			GuildMemberDetailOfficerNoteLabel:Hide();
			GuildMemberOfficerNoteBackground:Hide();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT);
		end

		-- Manage guild member related buttons
		if ( CanGuildPromote() and ( rankIndex > 1 ) and ( rankIndex > (guildRankIndex + 1) ) ) then
			GuildFramePromoteButton:Enable();
		else 
			GuildFramePromoteButton:Disable();
		end
		if ( CanGuildDemote() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) and ( rankIndex ~= maxRankIndex ) ) then
			GuildFrameDemoteButton:Enable();
		else
			GuildFrameDemoteButton:Disable();
		end
		-- Hide promote/demote buttons if both disabled
		if ( not GuildFrameDemoteButton:IsEnabled() and not GuildFramePromoteButton:IsEnabled() ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildMemberGroupInviteButton:Disable();
		else
			GuildMemberGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildMemberDetailFrame:Hide();
	end
	
	-- placeholders
	local contribution = 0;
	local contributionRank = 0;
	local topContribution = 0;
	local honor = 0;
	local conquest = 0;
	local valor = 0;
	local hero = 0;
	local achievement = 0;
	
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName;
	-- numVisible
	local visibleMembers = onlineMembers;
	if ( GetGuildRosterShowOffline() ) then
		visibleMembers = totalMembers;
	end
	for i = 1, numButtons do
		button = buttons[i];		
		index = offset + i;		
		if ( index <= visibleMembers ) then
			button.guildIndex = index;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(index);
			if ( currentGuildView == "playerStatus" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
				GuildRosterButton_SetStringText(button.string2, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string3, zone, online)
			elseif ( currentGuildView == "guildStatus" ) then
				GuildRosterButton_SetStringText(button.string1, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string2, rank, online)
				GuildRosterButton_SetStringText(button.string3, note, online)
				GuildRosterButton_SetStringText(button.string4, GuildRoster_GetLastOnline(index), online)
			elseif ( currentGuildView == "contribution" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
				GuildRosterButton_SetStringText(button.string2, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string3, contribution, online)
				if ( contribution == 0 ) then
					button.barTexture:Hide();
				else
					button.barTexture:SetWidth(_GuildMembers[index].contribution / topContribution * GUILD_ROSTER_BAR_MAX);
					button.barTexture:Show();
				end
				GuildRosterButton_SetStringText(button.barLabel, "#"..contributionRank, online)
			elseif ( currentGuildView == "pve" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
				GuildRosterButton_SetStringText(button.string2, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string3, valor, online)
				GuildRosterButton_SetStringText(button.string4, hero, online)
			elseif ( currentGuildView == "pvp" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
				GuildRosterButton_SetStringText(button.string2, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string3, honor, online)
				GuildRosterButton_SetStringText(button.string4, conquest, online)
			elseif ( currentGuildView == "achievement" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));
				GuildRosterButton_SetStringText(button.string2, name, online, classFileName)
				GuildRosterButton_SetStringText(button.string3, achievement, online)
			end
			button:Show();
			if ( mod(index, 2) == 0 ) then
				button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688);
			else
				button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500);
			end
			if ( selectedGuildMember == index ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		else
			button:Hide();
		end
	end
	local totalHeight = visibleMembers * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildRosterButton_OnClick(self, button)
	if ( currentGuildView == "tradeskill" ) then
		return;
	end
	if ( button == "LeftButton" ) then
		if ( GuildMemberDetailFrame:IsShown() and self.guildIndex == GuildFrame.selectedGuildMember ) then
			SetGuildRosterSelection(0);
			GuildFrame.selectedGuildMember = 0;
			GuildMemberDetailFrame:Hide();
		else
			SetGuildRosterSelection(self.guildIndex);
			GuildFrame.selectedGuildMember = self.guildIndex;
			GuildFramePopup_Show(GuildMemberDetailFrame);
		end
		GuildRoster_Update();
	else
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(self.guildIndex);
		FriendsFrame_ShowDropdown(name, online);
	end
end

function GuildRoster_UpdateTradeSkills()
	local scrollFrame = GuildRosterContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index, class;
	local numTradeSkill = GetNumGuildTradeSkill();
	
	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		if ( index <= numTradeSkill ) then
			local skillID, isCollapsed, iconTexture, headerName, numOnline, numPlayers, playerName, class, isOnline, zone, skill = GetGuildTradeSkillInfo(index);
			if ( skillID ) then
				GuildRosterButton_SetStringText(button.string1, headerName, 1);
				GuildRosterButton_SetStringText(button.string2, "", 1);
				GuildRosterButton_SetStringText(button.string3, numOnline, 1);
				button.header:Show();
				button:UnlockHighlight();
				button.header.icon:SetTexture(iconTexture);
				button.header.name:SetText(headerName);
				button.header.collapsed = isCollapsed;
				if ( numPlayers == 0 ) then
					button.header.collapsedIcon:Hide();
					button.header.expandedIcon:Hide();
					button.header.allRecipes:Hide();
					button.header:Disable();
					button.header.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					button.header.leftEdge:SetVertexColor(0.75, 0.75, 0.75);
					button.header.rightEdge:SetVertexColor(0.75, 0.75, 0.75);
					button.header.middle:SetVertexColor(0.75, 0.75, 0.75);
				else
					button.header:Enable();
					button.header.allRecipes:Show();
					button.header.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
					button.header.leftEdge:SetVertexColor(1, 1, 1);
					button.header.rightEdge:SetVertexColor(1, 1, 1);
					button.header.middle:SetVertexColor(1, 1, 1);
					if ( isCollapsed ) then
						button.header.collapsedIcon:Show();
						button.header.expandedIcon:Hide();
					else
						button.header.expandedIcon:Show();
						button.header.collapsedIcon:Hide();
					end
				end
				button.header.skillID = skillID;
			else
				GuildRosterButton_SetStringText(button.string1, playerName, isOnline, string.upper(class));
				GuildRosterButton_SetStringText(button.string2, zone, isOnline);
				GuildRosterButton_SetStringText(button.string3, "["..skill.."]", isOnline);
				button.header:Hide();
			end
			button:Show();
			if ( mod(index, 2) == 0 ) then
				button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688);
			else
				button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500);
			end
		else
			button:Hide();
		end
	end
	
	local totalHeight = numTradeSkill * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GuildRosterTradeSkillHeader_OnClick(self)
	if ( self.collapsed ) then
		ExpandGuildTradeSkillHeader(self.skillID);
	else
		CollapseGuildTradeSkillHeader(self.skillID);
	end
end

--****** Dropdown ***************************************************************

function GuildRoster_SetView(view)
	local numColumns = #GUILD_ROSTER_COLUMNS[view];
	local stringsInfo = { };
	local stringOffset = 0;
	local haveIcon, haveBar;
	
	-- set up columns
	for columnIndex = 1, GUILD_ROSTER_MAX_COLUMNS do
		local columnButton = _G["GuildRosterColumnButton"..columnIndex];
		local columnType = GUILD_ROSTER_COLUMNS[view][columnIndex];
		if ( columnType ) then
			local columnData = GUILD_ROSTER_COLUMN_DATA[columnType];
			columnButton:SetText(columnData.text);
			WhoFrameColumn_SetWidth(columnButton, columnData.width);
			columnButton:Show();
			-- by default the sort type should be the same as the column type
			if ( columnData.sortType ) then
				columnButton.sortType = columnData.sortType;
			else
				columnButton.sortType = columnType;
			end
			if ( columnData.hasIcon ) then
				haveIcon = true;
			else	
				-- store string data for processing
				columnData["stringOffset"] = stringOffset;
				table.insert(stringsInfo, columnData);
			end
			stringOffset = stringOffset + columnData.width - 2;
			haveBar = haveBar or columnData.hasBar;
		else
			columnButton:Hide();
		end
	end	
	
	-- process the button strings
	local buttons = GuildRosterContainer.buttons;
	local button, fontString;
	for buttonIndex = 1, #buttons do
		button = buttons[buttonIndex];
		for stringIndex = 1, GUILD_ROSTER_MAX_STRINGS do
			fontString = button["string"..stringIndex];
			local stringData = stringsInfo[stringIndex];
			if ( stringData ) then
				-- want strings a little inside the columns, 6 pixels from the left and 8 from the right
				fontString:SetPoint("LEFT", stringData.stringOffset + 6, 0);
				fontString:SetWidth(stringData.width - 14);
				fontString:SetJustifyH(stringData.stringJustify);
				fontString:Show();
			else
				fontString:Hide();
			end
		end
		if ( haveIcon ) then
			button.icon:Show();
		else
			button.icon:Hide();
		end
		if ( haveBar ) then
			button.barLabel:Show();
			-- button.barTexture:Show(); -- shown status determined in GuildRoster_Update 
		else
			button.barLabel:Hide();
			button.barTexture:Hide();
		end
		button.header:Hide();
	end
	
	if ( view == "tradeskill" ) then
		GuildRoster_RecipeQueryCheck();
	end
	currentGuildView = view;
end

function GuildRosterViewDropdown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRosterViewDropdown_Initialize);
	UIDropDownMenu_SetWidth(GuildRosterViewDropdown, 150);
end

function GuildRosterViewDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = GuildRosterViewDropdown_OnClick;
	
	info.text = "Player Status";
	info.value = "playerStatus";
	UIDropDownMenu_AddButton(info);
	info.text = "Guild Status";
	info.value = "guildStatus";
	UIDropDownMenu_AddButton(info);	
	info.text = "Contribution (Lifetime)";
	info.value = "contribution";
	UIDropDownMenu_AddButton(info);
	info.text = "PvE Points (Lifetime)";
	info.value = "pve";
	UIDropDownMenu_AddButton(info);
	info.text = "PvP Points (Lifetime)";
	info.value = "pvp";
	UIDropDownMenu_AddButton(info);
	info.text = "Achievements";
	info.value = "achievement";
	UIDropDownMenu_AddButton(info);	
	info.text = "Professions";
	info.value = "tradeskill";
	UIDropDownMenu_AddButton(info);	
	
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
end

function GuildRosterViewDropdown_OnClick(self)
	GuildRoster_SetView(self.value);
	GuildRoster();
	GuildRoster_Update();
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView);
end
