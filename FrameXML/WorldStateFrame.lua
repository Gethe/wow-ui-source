local MAX_SCORE_BUTTONS = 20;
local MAX_NUM_STAT_COLUMNS = 7;
local SCOREFRAME_BASE_COLUMNS = 6;
local SCOREFRAME_COLUMN_SPACING = 76;
local SCOREFRAME_BUTTON_TEXT_OFFSET = -28;

local SCORE_BUTTON_HEIGHT = 16;

function WorldStateScoreFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");
	self:RegisterEvent("LFG_ROLE_CHECK_DECLINED");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_READY_CHECK_DECLINED");
	self:RegisterEvent("LFG_READY_CHECK_SHOW");

	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);

	UIDropDownMenu_Initialize( WorldStateButtonDropDown, WorldStateButtonDropDown_Initialize, "MENU");
	
	ButtonFrameTemplate_HidePortrait(self);
	self.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, -124);
	self.Inset:SetPoint("BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, 40);
	_G[self:GetName() .. "BtnCornerLeft"]:Hide();
	_G[self:GetName() .. "BtnCornerRight"]:Hide();
	_G[self:GetName() .. "ButtonBottomBorder"]:Hide();
	
	local prevRowFrame = WorldStateScoreButton1;
	for i=2,MAX_SCORE_BUTTONS do
		local rowFrame = CreateFrame("FRAME", "WorldStateScoreButton"..i, WorldStateScoreFrame, "WorldStateScoreTemplate");
		rowFrame:SetPoint("TOPLEFT",  prevRowFrame, "BOTTOMLEFT", 0, 0);
		rowFrame:SetPoint("TOPRIGHT",  prevRowFrame, "BOTTOMRIGHT", 0, 0);
		prevRowFrame = rowFrame;
	end
	
	self.onCloseCallback = WorldStateScoreFrame_OnClose;
end

function WorldStateScoreFrame_OnEvent(self, event, ...)
	if	event == "UPDATE_BATTLEFIELD_SCORE" or event == "UPDATE_WORLD_STATES" then
		if InActiveBattlefield() and (self:IsVisible() or GetBattlefieldWinner()) then
			WorldStateScoreFrame_Resize();
			WorldStateScoreFrame_Update();
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		HideUIPanel(self);
		self.firstOpen = false;
		self.leaving = nil;
		BATTLEFIELD_SHUTDOWN_TIMER = 0;
	elseif ( event == "PLAYER_ENTERING_BATTLEGROUND" ) then
		WorldStateScoreFrameQueueButton:Enable();
	elseif ( event == "LFG_ROLE_CHECK_DECLINED" or event == "LFG_READY_CHECK_DECLINED" ) then
		WorldStateScoreFrameQueueButton:Enable();
	elseif ( event == "LFG_ROLE_CHECK_SHOW" or event == "LFG_READY_CHECK_SHOW" ) then	
		WorldStateScoreFrameQueueButton:Disable();
	end
end

function WorldStateScoreFrame_OnShow(self)
	WorldStateScoreFrame_Resize();
	WorldStateScoreFrame_Update();
	WorldStateScoreFrameTab_OnClick(WorldStateScoreFrameTab1);
end

function WorldStateButtonDropDown_Initialize()
	UnitPopup_ShowMenu(WorldStateButtonDropDown, "WORLD_STATE_SCORE", nil, WorldStateButtonDropDown.name);
end

function WorldStateScoreFrame_ShowWorldStateButtonDropDown(self, name, battlefieldScoreIndex)
	WorldStateButtonDropDown.name = name;
	WorldStateButtonDropDown.battlefieldScoreIndex = battlefieldScoreIndex;
	WorldStateButtonDropDown.initialize = WorldStateButtonDropDown_Initialize;
	ToggleDropDownMenu(1, nil, WorldStateButtonDropDown, self:GetName(), 0, 0);
end

function WorldStateScoreFrame_Update()
	local isArena, isRegistered = IsActiveBattlefieldArena();
	local isRatedBG = IsRatedBattleground();
	local isWargame = IsWargame();
	local isSkirmish = IsArenaSkirmish();
	local battlefieldWinner = GetBattlefieldWinner(); 
	local isLFDBattlefield = IsInLFDBattlefield();

	local firstFrameAfterCustomStats = WorldStateScoreFrameHonorGained;
	WorldStateScoreFramePrestige:SetShown(UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]);
	
	-- LFD Battlefield scoreboard has the same contents as arena skirmish
	if ( isArena or isLFDBattlefield ) then
		-- Hide unused tabs
		WorldStateScoreFrameTab1:Hide();
		WorldStateScoreFrameTab2:Hide();
		WorldStateScoreFrameTab3:Hide();
	
		-- Hide unused columns
		WorldStateScoreFrameDeaths:Hide();
		WorldStateScoreFrameHK:Hide();
		WorldStateScoreFrameHonorGained:Hide();
		WorldStateScoreFrameBgRating:Hide();

		if ( isWargame or isSkirmish or isLFDBattlefield ) then
			WorldStateScoreFrameRatingChange:Hide()
		end
		WorldStateScoreFrameName:SetWidth(325)
		
		-- Reanchor some columns.
		WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameKB, "RIGHT", -5, 0);
		WorldStateScoreFrameTeam:Hide();
		if ( not isWargame and not isSkirmish and not isLFDBattlefield ) then
			WorldStateScoreFrameRatingChange:Show();
			WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameHealingDone, "RIGHT", 0, 0);
			WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
		end
		WorldStateScoreFrameMatchmakingRating:Hide();
		WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);
	else
		-- Show Tabs
		WorldStateScoreFrameTab1:Show();
		WorldStateScoreFrameTab2:Show();
		WorldStateScoreFrameTab3:Show();
		
		WorldStateScoreFrameTeam:Hide();
		WorldStateScoreFrameDeaths:Show();

		WorldStateScoreFrameName:SetWidth(175)
		
		-- Reanchor some columns.
		WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);
		
		if isRatedBG then
			WorldStateScoreFrameHonorGained:Hide();
			WorldStateScoreFrameHK:Hide();
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);	
			
			WorldStateScoreFrameBgRating:Show();
			firstFrameAfterCustomStats = WorldStateScoreFrameBgRating;

			if battlefieldWinner then
				WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
				WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameBgRating, "RIGHT", -5, 0);
				WorldStateScoreFrameRatingChange:Show();
			else
				WorldStateScoreFrameRatingChange:Hide();
			end
		else 
			WorldStateScoreFrameHK:Show();
			WorldStateScoreFrameHK:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameHK, "RIGHT", -5, 0);
			
			WorldStateScoreFrameHonorGained:Show();

			WorldStateScoreFrameRatingChange:Hide();
			WorldStateScoreFrameBgRating:Hide();
		end
		WorldStateScoreFrameMatchmakingRating:Hide();
	end

	--Show the frame if its hidden and there is a victor
	if ( battlefieldWinner ) then
		-- Show the final score frame, set textures etc.
		
		if  not WorldStateScoreFrame.firstOpen then
			ShowUIPanel(WorldStateScoreFrame);
			WorldStateScoreFrame.firstOpen = true;
		end
		
		if ( isArena ) then
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_ARENA);
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT_ARENA);
		elseif ( isLFDBattlefield ) then
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_LFD_BATTLEFIELD);
			WorldStateScoreFrameTimerLabel:SetText("");
		else
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_BATTLEGROUND);
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT);
		end
		
		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();
		
		if(isSkirmish)then
			WorldStateScoreFrameQueueButton:Show();
			WorldStateScoreFrameLeaveButton:SetPoint("BOTTOM", WorldStateScoreFrameLeaveButton:GetParent(), "BOTTOM", 80, 3);
		else
			WorldStateScoreFrameQueueButton:Hide();
			WorldStateScoreFrameLeaveButton:SetPoint("BOTTOM", WorldStateScoreFrameLeaveButton:GetParent(), "BOTTOM", 0, 3);
		end

		-- Show winner
		if ( isArena ) then
			if ( isRegistered ) then
				if ( GetBattlefieldTeamInfo(battlefieldWinner) ) then
					local teamName
					if ( battlefieldWinner == 0) then
						teamName = ARENA_TEAM_NAME_GREEN
					else
						teamName = ARENA_TEAM_NAME_GOLD
					end
					WorldStateScoreWinnerFrameText:SetFormattedText(VICTORY_TEXT_ARENA_WINS, teamName);			
				else
					WorldStateScoreWinnerFrameText:SetText(VICTORY_TEXT_ARENA_DRAW);							
				end
			else
				WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT_ARENA"..battlefieldWinner]);
			end
			if ( battlefieldWinner == 0 ) then
				-- Green Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameText:SetVertexColor(0.1, 1.0, 0.1);	
			else		
				-- Gold Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.82, 0);	
			end
		elseif ( isLFDBattlefield ) then
			if ( GetBattlefieldTeamInfo(battlefieldWinner) ) then
				local teamName;
				if ( battlefieldWinner == 0) then
					teamName = ARENA_TEAM_NAME_PURPLE;
				else
					teamName = ARENA_TEAM_NAME_GOLD;
				end
				WorldStateScoreWinnerFrameText:SetFormattedText(VICTORY_TEXT_LFD_BATTLEFIELD_WINS, teamName);
			else
				WorldStateScoreWinnerFrameText:SetText(VICTORY_TEXT_LFD_BATTLEFIELD_DRAW);
			end
			if ( battlefieldWinner == 0 ) then
				-- Purple Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.57, 0.11, 0.57);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.57, 0.11, 0.57);
				WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.1, 1);
			else
				-- Gold Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.82, 0);
			end
		else
			WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT"..battlefieldWinner]);
			if ( battlefieldWinner == 0 ) then
				-- Horde won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.52, 0.075, 0.18);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.5, 0.075, 0.18);
				WorldStateScoreWinnerFrameText:SetVertexColor(1.0, 0.1, 0.1);
			else
				-- Alliance won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameText:SetVertexColor(0, 0.68, 0.94);	
			end
		end
		WorldStateScoreWinnerFrame:Show();
	else
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
		WorldStateScoreFrameQueueButton:Hide();
		WorldStateScoreFrameTimerLabel:Hide();
		WorldStateScoreFrameTimer:Hide();
	end
	
	-- Update buttons
	local numScores = GetNumBattlefieldScores();

	local scoreButton, columnButtonIcon;
	local name, kills, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec, honorLevel;
	local teamName, teamRating, newTeamRating, teamMMR;
	local index;
	local columnData;

        -- ScrollFrame update
	local hasScrollBar;
	if ( numScores > MAX_SCORE_BUTTONS ) then
		hasScrollBar = 1;
		WorldStateScoreScrollFrame:Show();
	else
		WorldStateScoreScrollFrame:Hide();
        end
	FauxScrollFrame_Update(WorldStateScoreScrollFrame, numScores, MAX_SCORE_BUTTONS, SCORE_BUTTON_HEIGHT );

	-- Setup Columns
	local text, icon, tooltip, columnButton;
	local numStatColumns = GetNumBattlefieldStats();
	local columnButton, columnButtonText, columnTextButton, columnIcon;
	local lastStatsFrame = "WorldStateScoreFrameHealingDone";
	for i=1, MAX_NUM_STAT_COLUMNS do
		if ( i <= numStatColumns ) then
			text, icon, tooltip = GetBattlefieldStatInfo(i);
			columnButton = _G["WorldStateScoreColumn"..i];
			columnButtonText = _G["WorldStateScoreColumn"..i.."Text"];
			columnButtonText:SetText(text);
			columnButton.icon = icon;
			columnButton.tooltip = tooltip;
			
			columnTextButton = _G["WorldStateScoreButton1Column"..i.."Text"];

			if ( icon ~= "" ) then
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, SCOREFRAME_BUTTON_TEXT_OFFSET);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, SCOREFRAME_BUTTON_TEXT_OFFSET);
			end

			
			if ( i == numStatColumns ) then
				lastStatsFrame = "WorldStateScoreColumn"..i;
			end
		
			_G["WorldStateScoreColumn"..i]:Show();
		else
			_G["WorldStateScoreColumn"..i]:Hide();
		end
	end
	
	-- Anchor the next frame to the last column shown
	firstFrameAfterCustomStats:SetPoint("LEFT", lastStatsFrame, "RIGHT", 5, 0);
	
	-- Last button shown is what the player count anchors to
	local lastButtonShown = "WorldStateScoreButton1";
	local teamDataFailed, coords;
	local scrollOffset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame);

	for i=1, MAX_SCORE_BUTTONS do
		-- Need to create an index adjusted by the scrollframe offset
		index = scrollOffset + i;
		scoreButton = _G["WorldStateScoreButton"..i];
		if ( hasScrollBar ) then
			scoreButton:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		else
			scoreButton:SetWidth(WorldStateScoreFrame.buttonWidth);
		end
		if ( index <= numScores ) then
			scoreButton.index = index;
			name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec, honorLevel = GetBattlefieldScore(index);
			
			if ( classToken ) then
				coords = CLASS_ICON_TCOORDS[classToken];
				scoreButton.class.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
				scoreButton.class.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
				scoreButton.class:Show();
			else
				scoreButton.class:Hide();
			end
			
			if ( honorLevel > 0 ) then
				local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
				if ( honorRewardInfo ) then
					scoreButton.prestige.icon:SetTexture(honorRewardInfo.badgeFileDataID or 0);
					scoreButton.prestige.tooltip = HONOR_LEVEL_TOOLTIP:format(honorLevel);
					scoreButton.prestige:Show();
				else
					scoreButton.prestige:Hide();
				end
			else
				scoreButton.prestige:Hide();
			end

			scoreButton.name.text:SetText(name);
			if ( not race ) then
				race = "";
			end
			if ( not class ) then
				class = "";
			end
			scoreButton.name.name = name;
			scoreButton.name.tooltip = race.." "..class;
			if ( talentSpec ) then
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = format(TALENT_SPEC_AND_CLASS, talentSpec, class);
			else
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = class;
			end
			scoreButton.killingBlows:SetText(killingBlows);
			scoreButton.damage:SetText(AbbreviateLargeNumbers(damageDone));
			scoreButton.healing:SetText(AbbreviateLargeNumbers(healingDone));
			teamDataFailed = 0;
			teamName, teamRating, newTeamRating, teamMMR = GetBattlefieldTeamInfo(faction);

			if ( not teamRating ) then
				teamDataFailed = 1;
			end
			
			if ( not newTeamRating ) then
				teamDataFailed = 1;
			end

			if ( isArena or isLFDBattlefield ) then
				scoreButton.name.text:SetWidth(350);
				if ( isRegistered ) then
					scoreButton.team:SetText(teamName);
					scoreButton.team:Show();
					if (not isSkirmish) then
						if ( teamDataFailed == 1 ) then
							scoreButton.ratingChange:SetText("-------");
						else
							if ratingChange > 0 then 
								scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
							else
								scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
							end
						end
						scoreButton.ratingChange:Show();
					else
						scoreButton.ratingChange:Hide();
					end
				else
					scoreButton.team:Hide();
					scoreButton.ratingChange:Hide();
				end
				scoreButton.honorableKills:Hide();
				scoreButton.honorGained:Hide();
				scoreButton.deaths:Hide();
				scoreButton.bgRating:Hide();
			else
				scoreButton.name.text:SetWidth(175);
				scoreButton.deaths:SetText(deaths);
				scoreButton.team:Hide();
				scoreButton.deaths:Show();
				if isRatedBG then
					if battlefieldWinner then
						if ratingChange > 0 then 
							scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
						else
							scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
						end
						scoreButton.ratingChange:Show();
					else
						scoreButton.ratingChange:Hide();
					end
					scoreButton.bgRating:SetText(bgRating);
					scoreButton.bgRating:Show();
					scoreButton.honorGained:Hide();
					scoreButton.honorableKills:Hide();
				else 
					scoreButton.honorGained:SetText(floor(honorGained));
					scoreButton.honorGained:Show();
					scoreButton.honorableKills:SetText(honorableKills);
					scoreButton.honorableKills:Show();
					scoreButton.ratingChange:Hide();
					scoreButton.bgRating:Hide();
				end
				scoreButton.matchmakingRating:Hide();
			end
			
			for j=1, MAX_NUM_STAT_COLUMNS do
				columnButtonText = _G["WorldStateScoreButton"..i.."Column"..j.."Text"];
				columnButtonIcon = _G["WorldStateScoreButton"..i.."Column"..j.."Icon"];
				if ( j <= numStatColumns ) then
					-- If there's an icon then move the icon left and format the text with an "x" in front
					columnData = GetBattlefieldStatData(index, j);
					if ( _G["WorldStateScoreColumn"..j].icon ~= "" ) then
						if ( columnData > 0 ) then
							columnButtonText:SetFormattedText(FLAG_COUNT_TEMPLATE, columnData);
							columnButtonIcon:SetTexture(_G["WorldStateScoreColumn"..j].icon..faction);
							columnButtonIcon:Show();
						else
							columnButtonText:SetText("");
							columnButtonIcon:Hide();
						end
						
					else
						columnButtonText:SetText(columnData);
						columnButtonIcon:Hide();
					end
					columnButtonText:Show();
				else
					columnButtonText:Hide();
					columnButtonIcon:Hide();
				end
			end
			if ( faction ) then
				if ( faction == 0 ) then
					if ( isArena ) then
						-- Green Team 
						scoreButton.factionLeft:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.factionRight:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.name.text:SetVertexColor(0.1, 1.0, 0.1);
					elseif ( isLFDBattlefield ) then
						-- Purple Team
						scoreButton.factionLeft:SetVertexColor(0.57, 0.11, 0.57);
						scoreButton.factionRight:SetVertexColor(0.57, 0.11, 0.57);
						scoreButton.name.text:SetVertexColor(1, 0.1, 1);
					else
						-- Horde
						scoreButton.factionLeft:SetVertexColor(0.52, 0.075, 0.18);
						scoreButton.factionRight:SetVertexColor(0.5, 0.075, 0.18);
						scoreButton.name.text:SetVertexColor(1.0, 0.1, 0.1);
					end
				else
					if ( isArena ) then
						-- Gold Team 
						scoreButton.factionLeft:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.factionRight:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.name.text:SetVertexColor(1, 0.82, 0);
					elseif ( isLFDBattlefield ) then
						-- Gold Team
						scoreButton.factionLeft:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.factionRight:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.name.text:SetVertexColor(1, 0.82, 0);
					else
						-- Alliance 
						scoreButton.factionLeft:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.factionRight:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.name.text:SetVertexColor(0, 0.68, 0.94);
					end
				end
				if ( ( not isArena and not isLFDBattlefield ) and ( name == UnitName("player") ) ) then
					scoreButton.name.text:SetVertexColor(1.0, 0.82, 0);
				end
				scoreButton.factionLeft:Show();
				scoreButton.factionRight:Show();
			else
				scoreButton.factionLeft:Hide();
				scoreButton.factionRight:Hide();
			end
			lastButtonShown = scoreButton:GetName();
			scoreButton:Show();
		else
			scoreButton:Hide();
		end
	end
	
	-- Show average matchmaking rating at the bottom	
	if isRatedBG or ((isArena and isRegistered) and not isSkirmish) then
		local _, ourAverageMMR, theirAverageMMR;
		local myFaction = GetBattlefieldArenaFaction();
		_, _, _, ourAverageMMR = GetBattlefieldTeamInfo(myFaction);
		_, _, _, theirAverageMMR = GetBattlefieldTeamInfo((myFaction+1)%2);
		WorldStateScoreFrame.teamAverageRating:Show();
		WorldStateScoreFrame.enemyTeamAverageRating:Show();
		WorldStateScoreFrame.teamAverageRating:SetFormattedText(BATTLEGROUND_YOUR_AVERAGE_RATING, ourAverageMMR);
		WorldStateScoreFrame.enemyTeamAverageRating:SetFormattedText(BATTLEGROUND_ENEMY_AVERAGE_RATING, theirAverageMMR);
	else
		WorldStateScoreFrame.teamAverageRating:Hide();
		WorldStateScoreFrame.enemyTeamAverageRating:Hide();
	end
	
	-- Count number of players on each side
	local _, _, _, _, numHorde = GetBattlefieldTeamInfo(0);
	local _, _, _, _, numAlliance = GetBattlefieldTeamInfo(1);
	
	-- Set count text and anchor team count to last button shown
	WorldStateScorePlayerCount:Show();
	if ( numHorde > 0 and numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetText(format(PLAYER_COUNT_ALLIANCE, numAlliance).." / "..format(PLAYER_COUNT_HORDE, numHorde));
	elseif ( numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_ALLIANCE, numAlliance);
	elseif ( numHorde > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_HORDE, numHorde);
	else
		WorldStateScorePlayerCount:Hide();
	end
	if ( isArena or isLFDBattlefield ) then
		WorldStateScorePlayerCount:Hide();
	end


	if GetBattlefieldInstanceRunTime() > 60000 then
		WorldStateScoreBattlegroundRunTime:Show();
		WorldStateScoreBattlegroundRunTime:SetText(TIME_ELAPSED.." "..SecondsToTime(GetBattlefieldInstanceRunTime()/1000, true));
	else
		WorldStateScoreBattlegroundRunTime:Hide();
	end
end

function WorldStateScoreFrame_Resize()
	local isArena, isRegistered = IsActiveBattlefieldArena();
	local isRatedBG = IsRatedBattleground();
	
	local columns = SCOREFRAME_BASE_COLUMNS;
	local scrollBar = 37;
	local name;
	
	local width = WorldStateScoreFrameName:GetWidth() + WorldStateScoreFrameClass:GetWidth() + WorldStateScoreFramePrestige:GetWidth();

	if ( isArena ) then
		columns = 4;
		if ( isRegistered ) then
			columns = 5;
			width = width + WorldStateScoreFrameTeam:GetWidth();
		else
			width = width + 43;
		end
	elseif ( isRatedBG ) then
		if not GetBattlefieldWinner() then
			columns = columns - 1;
		end
	end

	columns = columns + GetNumBattlefieldStats();

	width = width + (columns*SCOREFRAME_COLUMN_SPACING);

	if ( WorldStateScoreScrollFrame:IsShown() ) then
		width = width + scrollBar;
	end

	WorldStateScoreFrame:SetWidth(width);
	
	local height = 428;

	local yOffset = -64;
	local sectionHeight = 60;

	if ( UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]) then
		height = height + sectionHeight;
		yOffset = yOffset - sectionHeight;
		WorldStateScoreFrame.XPBar:Show();
		WorldStateScoreFrameSeparator:Show();
	else
		WorldStateScoreFrame.XPBar:Hide();
		WorldStateScoreFrameSeparator:Hide();
	end

	WorldStateScoreFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, yOffset);
	WorldStateScoreFrame:SetHeight(height);
		
	WorldStateScoreFrame.scrollBarButtonWidth = WorldStateScoreFrame:GetWidth() - 165;
	WorldStateScoreFrame.buttonWidth = WorldStateScoreFrame:GetWidth() - 137;
	WorldStateScoreScrollFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);

	-- Position Column data horizontally
	for i=1, MAX_SCORE_BUTTONS do
		local scoreButton = _G["WorldStateScoreButton"..i];
		
		if ( i == 1 ) then
			scoreButton.team:SetPoint("LEFT", "WorldStateScoreFrameTeam", "LEFT", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.matchmakingRating:SetPoint("CENTER", "WorldStateScoreFrameMatchmakingRating", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.bgRating:SetPoint("CENTER", "WorldStateScoreFrameBgRating", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.ratingChange:SetPoint("CENTER", "WorldStateScoreFrameRatingChange", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreFrameHK", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreFrameKB", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreFrameDeaths", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.damage:SetPoint("CENTER", "WorldStateScoreFrameDamageDone", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.healing:SetPoint("CENTER", "WorldStateScoreFrameHealingDone", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreFrameHonorGained", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			for j=1, MAX_NUM_STAT_COLUMNS do
				_G["WorldStateScoreButton"..i.."Column"..j.."Text"]:SetPoint("CENTER", _G["WorldStateScoreColumn"..j], "CENTER", 0,  SCOREFRAME_BUTTON_TEXT_OFFSET);
			end
		else
			scoreButton.team:SetPoint("LEFT", "WorldStateScoreButton"..(i-1).."Team", "LEFT", 0,  -SCORE_BUTTON_HEIGHT);
			scoreButton.matchmakingRating:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."MatchmakingRating", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.bgRating:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."BgRating", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.ratingChange:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."RatingChange", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorableKills", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."KillingBlows", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Deaths", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.damage:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Damage", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.healing:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Healing", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorGained", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			for j=1, MAX_NUM_STAT_COLUMNS do
				_G["WorldStateScoreButton"..i.."Column"..j.."Text"]:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Column"..j.."Text", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			end
		end
	end
	return width;
end

function WorldStateScoreFrame_OnClose(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	HideParentPanel(self);
end

function WorldStateScoreFrame_OnHide(self)
	CloseDropDownMenus();
end

function WorldStateScoreFrameTab_OnClick(tab)
	local faction = tab:GetID();
	PanelTemplates_SetTab(WorldStateScoreFrame, faction);
	if ( faction == 2 ) then
		faction = 1;
	elseif ( faction == 3 ) then
		faction = 0;
	else
		faction = nil;
	end
	WorldStateScoreFrameLabel:SetFormattedText(STAT_TEMPLATE, tab:GetText());
	SetBattlefieldScoreFaction(faction);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function ToggleWorldStateScoreFrame()
	if ( WorldStateScoreFrame:IsShown() ) then
		HideUIPanel(WorldStateScoreFrame);
	else
		--Make sure we're in an active BG
		local inBattlefield = false;
		for i=1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i);
			if ( status == "active" ) then
				inBattlefield = true;
				break;
			end
		end

		if ( ( not IsActiveBattlefieldArena() or GetBattlefieldWinner() or C_PvP.IsInBrawl() ) and inBattlefield ) then
			ShowUIPanel(WorldStateScoreFrame);
		end
	end
end

function ScorePlayer_OnClick(self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		if ( not UnitIsUnit(self.name,"player") ) then
			WorldStateScoreFrame_ShowWorldStateButtonDropDown(self, self.name, self:GetParent().index);
		end
	elseif ( mouseButton == "LeftButton" and IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		ChatEdit_InsertLink(self.text:GetText());
	end
end