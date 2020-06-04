local MAX_SCORE_BUTTONS = 22;
local MAX_NUM_STAT_COLUMNS = 7;
local SCOREFRAME_BASE_COLUMNS = 4;
local SCOREFRAME_COLUMN_SPACING = 77;
local SCOREFRAME_BUTTON_TEXT_OFFSET = -31;
local SCOREFRAME_BASE_WIDTH = 530;
local SCOREFRAME_COMMENTATOR_BONUS_WIDTH = 130;

local SCORE_BUTTON_HEIGHT = 15;

function WorldStateScoreFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND");

	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);

	UIDropDownMenu_Initialize( WorldStateButtonDropDown, WorldStateButtonDropDown_Initialize, "MENU");
	
	local prevRowFrame = WorldStateScoreButton1;
	for i=2,MAX_SCORE_BUTTONS do
		local rowFrame = CreateFrame("FRAME", "WorldStateScoreButton"..i, WorldStateScoreFrame, "WorldStateScoreTemplate");
		rowFrame:SetPoint("TOPLEFT",  prevRowFrame, "BOTTOMLEFT", 0, 1);
		rowFrame:SetPoint("TOPRIGHT",  prevRowFrame, "BOTTOMRIGHT", 0, 1);
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
	local battlefieldWinner = GetBattlefieldWinner(); 

	local firstFrameAfterCustomStats = WorldStateScoreFrameHonorGained;
	
	-- Show Tabs
	WorldStateScoreFrameTab1:Show();
	WorldStateScoreFrameTab2:Show();
	WorldStateScoreFrameTab3:Show();

	WorldStateScoreFrameDeaths:Show();

	--Show the frame if its hidden and there is a victor
	if ( battlefieldWinner ) then
		-- Show the final score frame, set textures etc.
		
		if  not WorldStateScoreFrame.firstOpen then
			ShowUIPanel(WorldStateScoreFrame);
			WorldStateScoreFrame.firstOpen = true;
		end
		
		WorldStateScoreFrameLeaveButton:SetText(LEAVE_BATTLEGROUND);
		WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT);
		
		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();

		-- Show winner
		WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT"..battlefieldWinner]);
		if ( battlefieldWinner == 0 ) then
			-- Horde won
			WorldStateScoreWinnerFrameLeft:SetTexCoord(0, 1, 0.5, 0.75);
			WorldStateScoreWinnerFrameRight:SetTexCoord(0, 0.97265625, 0.75, 1.0);
			WorldStateScoreWinnerFrameLeft:SetVertexColor(1.0, 0.1, 0.1);
			WorldStateScoreWinnerFrameRight:SetVertexColor(1.0, 0.1, 0.1);
			WorldStateScoreWinnerFrameText:SetTextColor(1.0, 0.1, 0.1);
		else
			-- Alliance won
			WorldStateScoreWinnerFrameLeft:SetTexCoord(0, 1, 0, 0.25);
			WorldStateScoreWinnerFrameRight:SetTexCoord(0, 0.97265625, 0.25, 0.5);
			WorldStateScoreWinnerFrameLeft:SetVertexColor(0, 0.68, 0.94);
			WorldStateScoreWinnerFrameRight:SetVertexColor(0, 0.68, 0.94);
			WorldStateScoreWinnerFrameText:SetTextColor(0, 0.68, 0.94);
		end
		WorldStateScoreWinnerFrame:Show();
	else
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
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
	local lastStatsFrame = "WorldStateScoreColumn1";
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
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, -31);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, -31);
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
	firstFrameAfterCustomStats:SetPoint("CENTER", lastStatsFrame, "CENTER", 58, 0);
	
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
			name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone = GetBattlefieldScore(index);
			rankName, rankNumber = GetPVPRankInfo(rank, faction);
			if ( rankNumber > 0 ) then
				scoreButton.rankButton.icon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank", rankNumber));
				scoreButton.rankButton:Show();
			else
				scoreButton.rankButton:Hide();
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
			scoreButton.rankButton.tooltip = rankName;
			scoreButton.killingBlows:SetText(killingBlows);
			teamDataFailed = 0;
			teamName, teamRating, newTeamRating, teamMMR = GetBattlefieldTeamInfo(faction);

			if ( not teamRating ) then
				teamDataFailed = 1;
			end
			
			if ( not newTeamRating ) then
				teamDataFailed = 1;
			end

			scoreButton.name.text:SetWidth(175);
			scoreButton.deaths:SetText(deaths);
			scoreButton.deaths:Show();
			scoreButton.honorGained:SetText(floor(honorGained));
			scoreButton.honorGained:Show();
			scoreButton.honorableKills:SetText(honorableKills);
			scoreButton.honorableKills:Show();

			scoreButton.damageDone:SetText(damageDone);
			scoreButton.healingDone:SetText(healingDone);
			if (WorldStateScoreFrame_CanSeeDamageAndHealing()) then
				scoreButton.damageDone:Show();
				scoreButton.healingDone:Show();
			else
				scoreButton.damageDone:Hide();
				scoreButton.healingDone:Hide();
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
					-- Horde
					scoreButton.factionLeft:SetTexCoord(0, 1, 0.5, 0.75);
					scoreButton.factionRight:SetTexCoord(0, 0.97265625, 0.75, 1.0);
					scoreButton.factionLeft:SetVertexColor(1.0, 0.1, 0.1);
					scoreButton.factionRight:SetVertexColor(1.0, 0.1, 0.1);
				else
					scoreButton.factionLeft:SetTexCoord(0, 1, 0, 0.25);
					scoreButton.factionRight:SetTexCoord(0, 0.97265625, 0.25, 0.5);
					scoreButton.factionLeft:SetVertexColor(0, 0.68, 0.94);
					scoreButton.factionRight:SetVertexColor(0, 0.68, 0.94);
				end
				if ( name == UnitName("player") ) then
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
	WorldStateScorePlayerCount:SetPoint("TOPLEFT", lastButtonShown, "BOTTOMLEFT", 15, -6);

	if GetBattlefieldInstanceRunTime() > 60000 then
		WorldStateScoreBattlegroundRunTime:Show();
		WorldStateScoreBattlegroundRunTime:SetText(TIME_ELAPSED.." "..SecondsToTime(GetBattlefieldInstanceRunTime()/1000, true));
	else
		WorldStateScoreBattlegroundRunTime:Hide();
	end
	WorldStateScoreBattlegroundRunTime:SetPoint("TOPRIGHT", lastButtonShown, "BOTTOMRIGHT", -20, -7);
end

function WorldStateScoreFrame_Resize()
	local scrollBar = 37;
	local name;
	local showDamageAndHealing = WorldStateScoreFrame_CanSeeDamageAndHealing();
	
	local width = SCOREFRAME_BASE_WIDTH;
	if (showDamageAndHealing) then
		width = width + SCOREFRAME_COMMENTATOR_BONUS_WIDTH;
	end

	local columns = GetNumBattlefieldStats();

	width = width + (columns*SCOREFRAME_COLUMN_SPACING);

	if ( WorldStateScoreScrollFrame:IsShown() ) then
		width = width + scrollBar;
	end

	WorldStateScoreFrame:SetWidth(width);

	WorldStateScoreFrameTopBackground:SetWidth(WorldStateScoreFrame:GetWidth()-129);
	WorldStateScoreFrameTopBackground:SetTexCoord(0, WorldStateScoreFrameTopBackground:GetWidth()/256, 0, 1.0);
		
	WorldStateScoreFrame.scrollBarButtonWidth = WorldStateScoreFrame:GetWidth() - 165;
	WorldStateScoreFrame.buttonWidth = WorldStateScoreFrame:GetWidth() - 137;
	WorldStateScoreScrollFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);

	if (showDamageAndHealing) then
		WorldStateScoreFrameDamageDone:Show();
		WorldStateScoreFrameHealingDone:Show();
		WorldStateScoreFrameHonorGained:SetPoint("CENTER", WorldStateScoreFrameHealingDone, "CENTER", 58, 0);
		WorldStateScoreColumn1:SetPoint("CENTER", WorldStateScoreFrameHealingDone, "RIGHT", 38, 0);
	else
		WorldStateScoreFrameDamageDone:Hide();
		WorldStateScoreFrameHealingDone:Hide();
		WorldStateScoreFrameHonorGained:SetPoint("CENTER", WorldStateScoreFrameHK, "CENTER", 58, 0);
		WorldStateScoreColumn1:SetPoint("CENTER", WorldStateScoreFrameHK, "RIGHT", 38, 0);
	end

	-- Position Column data horizontally
	for i=1, MAX_SCORE_BUTTONS do
		local scoreButton = _G["WorldStateScoreButton"..i];
		
		if ( i == 1 ) then
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreFrameHK", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreFrameKB", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreFrameDeaths", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreFrameHonorGained", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.damageDone:SetPoint("CENTER", "WorldStateScoreFrameDamageDone", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			scoreButton.healingDone:SetPoint("CENTER", "WorldStateScoreFrameHealingDone", "CENTER", 0, SCOREFRAME_BUTTON_TEXT_OFFSET);
			for j=1, MAX_NUM_STAT_COLUMNS do
				_G["WorldStateScoreButton"..i.."Column"..j.."Text"]:SetPoint("CENTER", _G["WorldStateScoreColumn"..j], "CENTER", 0,  SCOREFRAME_BUTTON_TEXT_OFFSET);
			end
		else
			scoreButton.honorableKills:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorableKills", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.killingBlows:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."KillingBlows", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.deaths:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Deaths", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.honorGained:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorGained", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.damageDone:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."DamageDone", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
			scoreButton.healingDone:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HealingDone", "CENTER", 0, -SCORE_BUTTON_HEIGHT);
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

function WorldStateScoreFrame_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, SCORE_BUTTON_HEIGHT, WorldStateScoreFrame_Update);
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

		if ( inBattlefield ) then
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

function WorldStateScoreFrame_CanSeeDamageAndHealing()
	return C_Commentator.GetMode() > 0;
end