MAX_ARENA_TEAMS = 3;
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_ARENA_TEAM_NAME_WIDTH = 310;

function PVPFrame_OnLoad(self)
	PVPFrameLine1:SetAlpha(0.3);
	PVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);
	PVPHonorHonorLabel:SetVertexColor(0.6, 0.6, 0.6);
	PVPHonorTodayLabel:SetVertexColor(0.6, 0.6, 0.6);
	PVPHonorYesterdayLabel:SetVertexColor(0.6, 0.6, 0.6);
	PVPHonorLifetimeLabel:SetVertexColor(0.6, 0.6, 0.6);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
	self:RegisterEvent("HONOR_CURRENCY_UPDATE");
	--self:RegisterEvent("ARENA_SEASON_WORLD_STATE");
end

function PVPFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		-- PVPFrame.season = GetCurrentArenaSeason();
		PVPFrame_Update();
		PVPHonor_Update();
	elseif ( event == "PLAYER_PVP_KILLS_CHANGED" or event == "PLAYER_PVP_RANK_CHANGED") then
		PVPHonor_Update();
	elseif ( event == "ARENA_TEAM_UPDATE" ) then
		PVPFrame_Update();
		if ( PVPTeamDetails:IsShown() ) then
			local team = GetArenaTeam(PVPTeamDetails.team);
			if ( not team ) then
				PVPTeamDetails:Hide();
			else
				PVPTeamDetails_Update(PVPTeamDetails.team); -- team games played/won are shown in the detail frame
			end
		end
	--[[ elseif ( event == "ARENA_SEASON_WORLD_STATE" ) then
		 PVPFrame.season = GetCurrentArenaSeason();
		PVPFrame_Update(); ]]
	elseif ( event == "HONOR_CURRENCY_UPDATE" ) then
		PVPHonor_Update();
	elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
		if ( arg1 ) then
			if ( PVPTeamDetails:IsShown() ) then
				ArenaTeamRoster(PVPTeamDetails.team);
			end
		elseif ( PVPTeamDetails.team ) then
			PVPTeamDetails_Update(PVPTeamDetails.team);
			PVPFrame_Update();
		end
	end
end

function PVPFrame_OnShow()
	PVPFrame_SetFaction();
	PVPFrame_Update();
	PVPMicroButton_SetPushed();
	UpdateMicroButtons();
	SetPortraitTexture(PVPFramePortrait, "player");
	PlaySound("igCharacterInfoOpen");
end

function PVPFrame_OnHide()
	PVPTeamDetails:Hide();
	PVPFrame_SetJustBG(false);
	PVPMicroButton_SetNormal();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
end

function PVPFrame_SetFaction()
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		PVPFrameHonorIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		PVPFrameHonorIcon:Show();
	end
end

function PVPFrame_Update()
	for i=1, MAX_ARENA_TEAMS do
		GetArenaTeam(i);
	end	
	PVPHonor_Update();
	PVPTeam_Update();
	
	if ( GetCurrentArenaSeason() == 0 ) then	--We're in an off-season.
		PVPFrame_SetToOffSeason();
	elseif ( PVPFrameOffSeason:IsShown() ) then
		PVPFrame_SetToInSeason();
	end
end

function PVPTeam_Update()
	-- Display Elements
	local button, buttonName, highlight, data, standard, emblem, border;
	-- Data Elements
	local teamName, teamSize, teamRating, teamPlayed, teamWins, teamLoss,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, playerPlayedPct, teamRank, playerRating;
	local played, wins, loss;
	local background = {};
	local borderColor = {};
	local emblemColor = {};
	local ARENA_TEAMS = {};
	ARENA_TEAMS[1] = {size = 2};
	ARENA_TEAMS[2] = {size = 3};
	ARENA_TEAMS[3] = {size = 5};

	-- Sort teams by size

	local count = 0;
	local buttonIndex = 0;
	for index, value in pairs(ARENA_TEAMS) do
		for i=1, MAX_ARENA_TEAMS do
			teamName, teamSize = GetArenaTeam(i);
			if ( value.size == teamSize ) then
				value.index = i;
			end
		end
	end

	-- fill out data
	for index, value in pairs(ARENA_TEAMS) do
		buttonIndex = buttonIndex + 1;
		button = _G["PVPTeam"..buttonIndex];
		if ( value.index ) then
			-- Pull Values
			teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating, background.r, background.g, background.b, emblem, emblemColor.r, emblemColor.g, emblemColor.b, border, borderColor.r, borderColor.g, borderColor.b = GetArenaTeam(value.index);

			-- Set button elements to variables 
			buttonName = "PVPTeam"..buttonIndex;
			data = buttonName.."Data";
			standard = buttonName.."Standard";

			button:SetID(value.index);
			
			
			if ( PVPFrame.seasonStats ) then
				_G[data.."TypeLabel"]:SetText(ARENA_THIS_SEASON);
				PVPFrameToggleButton:SetText(ARENA_THIS_WEEK_TOGGLE);
				played = seasonTeamPlayed;
				wins = seasonTeamWins;
				playerPlayed = seasonPlayerPlayed;
			else
				_G[data.."TypeLabel"]:SetText(ARENA_THIS_WEEK);
				PVPFrameToggleButton:SetText(ARENA_THIS_SEASON_TOGGLE);
				played = teamPlayed;
				wins = teamWins;
				playerPlayed = playerPlayed;
			end

			loss = played - wins;
			if ( played ~= 0 ) then
				playerPlayedPct =  floor( ( playerPlayed / played ) * 100 );		
			else
				playerPlayedPct =  floor( ( playerPlayed / 1 ) * 100 );
			end

			-- Populate Data
			_G[data.."Name"]:SetText(teamName);
			_G[data.."Rating"]:SetText(teamRating);
			_G[data.."Games"]:SetText(played);
			_G[data.."Wins"]:SetText(wins);
			_G[data.."Loss"]:SetText(loss);
			
			if ( PVPFrame.seasonStats ) then
				_G[data.."Played"]:SetText(playerRating);
				_G[data.."Played"]:SetVertexColor(1.0, 1.0, 1.0);
				_G[data.."PlayedLabel"]:SetText(PVP_YOUR_RATING);
			else
				-- played %
				if ( playerPlayedPct < 10 ) then
					_G[data.."Played"]:SetVertexColor(1.0, 0, 0);
				else
					_G[data.."Played"]:SetVertexColor(1.0, 1.0, 1.0);
				end
				-- FIXME: Turn this into a localized format string
				playerPlayedPct = format("%d", playerPlayedPct);
				_G[data.."Played"]:SetText(playerPlayed.." ("..playerPlayedPct.."%)");
				_G[data.."PlayedLabel"]:SetText(PLAYED);
			end
			

			-- Set TeamSize Banner
			_G[standard.."Banner"]:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize);
			_G[standard.."Banner"]:SetVertexColor(background.r, background.g, background.b);
			_G[standard.."Border"]:SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
			_G[standard.."Emblem"]:SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b);
			if ( border ~= -1 ) then
				_G[standard.."Border"]:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize.."-Border-"..border);
			end
			if ( emblem ~= -1 ) then
				_G[standard.."Emblem"]:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
			end

			-- Set visual elements
			_G[data]:Show();
			button:SetAlpha(1);
			_G[buttonName.."Highlight"]:SetAlpha(1);
			_G[buttonName.."Highlight"]:SetBackdropBorderColor(1.0, 0.82, 0);
			_G[standard]:SetAlpha(1);
			_G[standard.."Border"]:Show();
			_G[standard.."Emblem"]:Show();
			_G[buttonName.."Background"]:SetVertexColor(0, 0, 0);
			_G[buttonName.."Background"]:SetAlpha(1);
			_G[buttonName.."TeamType"]:Hide();
		else
			-- Set button elements to variables 
			buttonName = "PVPTeam"..buttonIndex;
			data = buttonName.."Data";
			
			button:SetID(0);

			-- Set standard type
			local standardBanner = _G[buttonName.."StandardBanner"];
			standardBanner:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..value.size);
			standardBanner:SetVertexColor(1, 1, 1);

			-- Hide or Show items
			button:SetAlpha(0.4);
			_G[data]:Hide();
			_G[buttonName.."Background"]:SetVertexColor(0, 0, 0);
			_G[buttonName.."Standard"]:SetAlpha(0.1);
			_G[buttonName.."StandardBorder"]:Hide();
			_G[buttonName.."StandardEmblem"]:Hide();
			_G[buttonName.."TeamType"]:SetFormattedText(PVP_TEAMSIZE, value.size, value.size);
			_G[buttonName.."TeamType"]:Show();		end
			count = count +1;
	end
	if ( count == 3 ) then
		PVPFrameToggleButton:Hide();
	else
		PVPFrameToggleButton:Show();
	end

end

function PVPTeam_OnEnter(self)
	if ( GetArenaTeam(self:GetID() ) ) then
		_G[self:GetName().."Highlight"]:Show();
		GameTooltip_AddNewbieTip(self, ARENA_TEAM, 1.0, 1.0, 1.0, CLICK_FOR_DETAILS, 1);
	else
		GameTooltip_AddNewbieTip(self, ARENA_TEAM, 1.0, 1.0, 1.0, ARENA_TEAM_LEAD_IN, 1);
	end		
end

function PVPTeam_OnLeave(self)
	_G[self:GetName().."Highlight"]:Hide();	
	GameTooltip:Hide();
end

function PVPTeamDetails_OnShow()
	PlaySound("igSpellBookOpen");
end

function PVPTeamDetails_OnHide()
	CloseArenaTeamRoster();
	PlaySound("igSpellBookClose");
end

function PVPTeamDetails_Update(id)
	local numMembers = GetNumArenaTeamMembers(id, 1);
	local name, rank, level, class, online, played, win, loss, seasonPlayed, seasonWin, seasonLoss, rating;
	local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, personalRating  = GetArenaTeam(id);		
	local button;
	local teamIndex;

	-- Display General Team Stats
	PVPTeamDetailsName:SetText(teamName);
	PVPTeamDetailsSize:SetFormattedText(PVP_TEAMSIZE, teamSize, teamSize);
	PVPTeamDetailsRank:SetText(teamRank);
	PVPTeamDetailsRating:SetText(teamRating);
	
	-- Tidy up team name display if it's too long - mostly for CN
	PVPTeamDetailsName:SetWidth(0);
	if ( PVPTeamDetailsName:GetWidth() > MAX_ARENA_TEAM_NAME_WIDTH ) then
		PVPTeamDetailsName:SetWidth(MAX_ARENA_TEAM_NAME_WIDTH);
	end
	
	-- Display General Team Data
	if ( PVPTeamDetails.season ) then
		PVPTeamDetailsFrameColumnHeader3.sortType = "seasonplayed";
		PVPTeamDetailsFrameColumnHeader4.sortType = "seasonwon";
		PVPTeamDetailsGames:SetText(seasonTeamPlayed);
		PVPTeamDetailsWins:SetText(seasonTeamWins);
		PVPTeamDetailsLoss:SetText(seasonTeamPlayed - seasonTeamWins);
		PVPTeamDetailsStatsType:SetText(strupper(ARENA_THIS_SEASON));
		PVPTeamDetailsToggleButton:SetText(ARENA_THIS_WEEK_TOGGLE);
	else
		PVPTeamDetailsFrameColumnHeader3.sortType = "played";
		PVPTeamDetailsFrameColumnHeader4.sortType = "won";
		PVPTeamDetailsGames:SetText(teamPlayed);
		PVPTeamDetailsWins:SetText(teamWins);
		PVPTeamDetailsLoss:SetText(teamPlayed - teamWins);
		PVPTeamDetailsStatsType:SetText(strupper(ARENA_THIS_WEEK));
		PVPTeamDetailsToggleButton:SetText(ARENA_THIS_SEASON_TOGGLE);
	end

	local nameText, classText, playedText, winLossWin, winLossLoss, ratingText;
	local nameButton, classButton, playedButton, winLossButton;
	-- Display Team Member Specific Info
	local playedValue, winValue, lossValue, playedPct;
	for i=1, MAX_ARENA_TEAM_MEMBERS, 1 do
		button = _G["PVPTeamDetailsButton"..i];
		if ( i > numMembers ) then
			button:Hide();
		else
			
			button.teamIndex = i;
			-- Get Data
			name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = GetArenaTeamRosterInfo(id, i);
			loss = played - win;
			seasonLoss = seasonPlayed - seasonWin;
			if ( class ) then
				button.tooltip = LEVEL.." "..level.." "..class;
			else
				button.tooltip = LEVEL.." "..level;
			end

			-- Populate Data into the display, season or this week
			if ( PVPTeamDetails.season ) then
				playedValue = seasonPlayed;
				winValue = seasonWin;
				lossValue = seasonLoss;
				teamPlayed = seasonTeamPlayed;
			else
				playedValue = played;
				winValue = win;
				lossValue = loss;
				teamPlayed = teamPlayed;
			end

			if ( teamPlayed ~= 0 ) then
				playedPct =  floor( ( playedValue / teamPlayed ) * 100 );		
			else
				playedPct =  floor( (playedValue / 1 ) * 100 );
			end

			if ( playedPct < 10 ) then
				_G["PVPTeamDetailsButton"..i.."PlayedText"]:SetVertexColor(1.0, 0, 0);
			else
				_G["PVPTeamDetailsButton"..i.."PlayedText"]:SetVertexColor(1.0, 1.0, 1.0);
			end
			
			playedPct = format("%d", playedPct);

			_G["PVPTeamDetailsButton"..i.."Played"].tooltip = playedPct.."%";

			nameText = _G["PVPTeamDetailsButton"..i.."NameText"];
			classText = _G["PVPTeamDetailsButton"..i.."ClassText"];
			playedText = _G["PVPTeamDetailsButton"..i.."PlayedText"]
			winLossWin = _G["PVPTeamDetailsButton"..i.."WinLossWin"];
			winLossLoss = _G["PVPTeamDetailsButton"..i.."WinLossLoss"];
			ratingText = _G["PVPTeamDetailsButton"..i.."RatingText"];

			--- Not needed after Arena Season 3 change.
			nameButton = _G["PVPTeamDetailsButton"..i.."Name"];
			classButton = _G["PVPTeamDetailsButton"..i.."Class"];
			playedButton = _G["PVPTeamDetailsButton"..i.."Played"]
			winLossButton = _G["PVPTeamDetailsButton"..i.."WinLoss"];

			nameText:SetText(name);
			classText:SetText(class);
			playedText:SetText(playedValue);
			winLossWin:SetText(winValue)
			winLossLoss:SetText(lossValue);
			ratingText:SetText(rating);
		
			-- Color Entries based on Online status
			local r, g, b;
			if ( online ) then
				if ( rank > 0 ) then
					r = 1.0;
					g = 1.0;
					b = 1.0;
				else
					r = 1.0;
					g = 0.82;
					b = 0.0;
				end
			else
				r = 0.5;
				g = 0.5;
				b = 0.5;
			end

			nameText:SetTextColor(r, g, b);
			classText:SetTextColor(r, g, b);
			playedText:SetTextColor(r, g, b);
			winLossWin:SetTextColor(r, g, b);
			_G["PVPTeamDetailsButton"..i.."WinLoss-"]:SetTextColor(r, g, b);
			winLossLoss:SetTextColor(r, g, b);
			ratingText:SetTextColor(r, g, b);

			button:Show();

			-- Highlight the correct who
			if ( GetArenaTeamRosterSelection(id) == i ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		end
		
	end


end

function PVPTeamDetailsToggleButton_OnClick()
	if ( PVPTeamDetails.season ) then
		PVPTeamDetails.season = nil;
	else
		PVPTeamDetails.season = 1;		
	end
	PVPTeamDetails_Update(PVPTeamDetails.team);
end

function PVPFrameToggleButton_OnClick()
	if ( PVPFrame.seasonStats ) then
		PVPFrame.seasonStats = nil;
	else
		PVPFrame.seasonStats = 1;		
	end
	PVPTeam_Update();
end
						

function PVPTeamDetailsButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PVPTeamDetails.previousSelectedTeamMember = PVPTeamDetails.selectedTeamMember;
		PVPTeamDetails.selectedTeamMember = self.teamIndex;
		SetArenaTeamRosterSelection(PVPTeamDetails.team, PVPTeamDetails.selectedTeamMember);
		PVPTeamDetails_Update(PVPTeamDetails.team);
	else
		local name, rank, level, class, online = GetArenaTeamRosterInfo(PVPTeamDetails.team, self.teamIndex);
		PVPFrame_ShowDropdown(name, online);
	end
end

function PVPDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "TEAM", nil, PVPDropDown.name);
end

function PVPFrame_ShowDropdown(name, online)
	HideDropDownMenu(1);
	
	if ( not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
		if ( online ) then
			PVPDropDown.initialize = PVPDropDown_Initialize;
			PVPDropDown.displayMode = "MENU";
			PVPDropDown.name = name;
			PVPDropDown.online = online;
			ToggleDropDownMenu(1, nil, PVPDropDown, "cursor");
		end
	else
		PVPDropDown.initialize = PVPDropDown_Initialize;
		PVPDropDown.displayMode = "MENU";
		PVPDropDown.name = name;
		PVPDropDown.online = online;
		ToggleDropDownMenu(1, nil, PVPDropDown, "cursor");
	end
end

function PVPStandard_OnLoad(self)
	self:SetAlpha(0.1);
end

function PVPTeam_OnClick(self)
	local id = self:GetID();

	local teamName, teamSize = GetArenaTeam(id);
	if ( not teamName ) then
		return;
	else
		if ( PVPTeamDetails:IsShown() and id == PVPTeamDetails.team ) then
			PVPTeamDetails:Hide();
		else
			PVPTeamDetails.team = id;
			ArenaTeamRoster(id);
			PVPTeamDetails_Update(id);
			PVPTeamDetails:Show();
		end
	end
end

function PVPTeam_OnMouseDown(self)
	if ( GetArenaTeam(self:GetID()) and (not self.isDown) ) then
		self.isDown = true;
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
		self:SetPoint(point, relativeTo, relativePoint, offsetX-2, offsetY-2);
	end
end
function PVPTeam_OnMouseUp(self)
	--Note that this function is also called OnShow. Make sure it always checks if it was previously down.
	if ( GetArenaTeam(self:GetID()) and (self.isDown) ) then
		self.isDown = false;
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
		self:SetPoint(point, relativeTo, relativePoint, offsetX+2, offsetY+2);
	end
end

-- PVP Honor Data
function PVPHonor_Update()
	local hk, cp, dk, contribution, rank, highestRank, rankName, rankNumber;
	
	-- Yesterday's values
	hk, contribution = GetPVPYesterdayStats();
	PVPHonorYesterdayKills:SetText(hk);
	PVPHonorYesterdayHonor:SetText(contribution);

	-- Lifetime values
	hk, contribution =  GetPVPLifetimeStats();
	PVPHonorLifetimeKills:SetText(hk);
	PVPFrameHonorPoints:SetText(GetHonorCurrency());
	PVPFrameArenaPoints:SetText(GetArenaCurrency())	
	
	-- Today's values
	hk, cp = GetPVPSessionStats();
	PVPHonorTodayKills:SetText(hk);
	PVPHonorTodayHonor:SetText(cp);
	PVPHonorTodayHonor:SetHeight(14);
end

function PVPMicroButton_SetPushed()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 5, -31);
	PVPMicroButtonTexture:SetAlpha(0.5);
end

function PVPMicroButton_SetNormal()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 6, -30);
	PVPMicroButtonTexture:SetAlpha(1.0);
end

function PVPFrame_SetToOffSeason()
	PVPTeam1:Hide();
	PVPTeam1Standard:Hide();
	PVPTeam2:Hide();
	PVPTeam2Standard:Hide();
	PVPTeam3:Hide();
	PVPTeam3Standard:Hide();
	
	PVPFrameBlackFilter:Show();
	
	PVPFrameOffSeason:Show();
	
	local previousArenaSeason = GetPreviousArenaSeason();
	PVPFrameOffSeasonText:SetText(format(ARENA_OFF_SEASON_TEXT, previousArenaSeason, previousArenaSeason+1));
end

function PVPFrame_SetToInSeason()
	PVPTeam1:Show();
	PVPTeam1Standard:Show();
	PVPTeam2:Show();
	PVPTeam2Standard:Show();
	PVPTeam3:Show();
	PVPTeam3Standard:Show();
	
	PVPFrameBlackFilter:Hide();
	
	PVPFrameOffSeason:Hide();
end

function TogglePVPFrame()
	if ( PVPFrame_IsJustBG() ) then
		PVPFrame_SetJustBG(false);
	else
		if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
			ToggleFrame(PVPParentFrame);
		end
	end
end

function PVPFrame_IsJustBG()
	return PVPParentFrame.justBG;
end

function PVPFrame_SetJustBG(justBG)
	local pvpParentFrame = PVPParentFrame;
	if ( justBG ) then
		pvpParentFrame.justBG = true;
		pvpParentFrame.savedSelectedTab = PanelTemplates_GetSelectedTab(pvpParentFrame);
		PVPParentFrameTab2:Click();
		PVPParentFrameTab1:Hide();
		PVPParentFrameTab2:Hide();
		UpdateMicroButtons();
	else
		pvpParentFrame.justBG = false;
		if ( pvpParentFrame.savedSelectedTab ) then
			_G["PVPParentFrameTab"..pvpParentFrame.savedSelectedTab]:Click();
			pvpParentFrame.savedSelectedTab = nil;
		end
		CloseBattlefield();
		PVPBattlegroundFrame_UpdateVisible();
		UpdateMicroButtons();
	end
end
