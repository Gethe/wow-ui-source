MAX_ARENA_TEAMS = 3;
MAX_ARENA_TEAM_MEMBERS = 10;

function PVPFrame_OnLoad(self)
	PVPFrameLine1:SetAlpha(0.3);
	PVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	--self:RegisterEvent("ARENA_SEASON_WORLD_STATE");
end

function PVPFrame_OnEvent(self, event, ...)
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
			end
		end
	--[[ elseif ( event == "ARENA_SEASON_WORLD_STATE" ) then
		 PVPFrame.season = GetCurrentArenaSeason();
		PVPFrame_Update(); ]]
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local currencyID = ...;
		if currencyID == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID or
			currencyID == Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID then

			PVPHonor_Update();
		end
	elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
		if ( arg1 ) then
			if ( PVPTeamDetails:IsShown() ) then
				ArenaTeamRoster(PVPTeamDetails.team);
			end
		elseif ( PVPTeamDetails.team ) then
			PVPTeamDetails_Update(self, PVPTeamDetails.team);
			PVPFrame_Update();
		end
		if ( PVPTeamDetails:IsShown() ) then
			local team = GetArenaTeam(PVPTeamDetails.team);
			if ( not team ) then
				PVPTeamDetails:Hide();
			end
		end
	end
end

function PVPFrame_OnShow(self)
	PVPFrame_SetFaction(self);
	PVPFrame_Update(self);
end

function PVPFrame_SetFaction(self)
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		PVPFrameHonorIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		PVPFrameHonorIcon:Show();
	end
end

function PVPFrame_Update(self)
	for i=1, MAX_ARENA_TEAMS do
		GetArenaTeam(i);
	end	
	PVPHonor_Update();
	PVPTeam_Update();
end

function PVPFrame_OnHide(self)
	PVPTeamDetails:Hide();
end

function PVPTeam_Update()
	-- Display Elements
	local button, buttonName, highlight, data, standard, emblem, border;
	-- Data Elements
	local teamName, teamSize, teamRating, teamPlayed, teamWins, teamLoss,  seasonTeamPlayed, seasonTeamWins, playerPlayed, playerPlayedPct, teamRank, playerRating;
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
		if ( value.index ) then
			buttonIndex = buttonIndex + 1;
			-- Pull Values
			teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating, background.r, background.g, background.b, emblem, emblemColor.r, emblemColor.g, emblemColor.b, border, borderColor.r, borderColor.g, borderColor.b = GetArenaTeam(value.index);

			-- Set button elements to variables 
			button = getglobal("PVPTeam"..buttonIndex);
			buttonName = "PVPTeam"..buttonIndex;
			data = buttonName.."Data";
			standard = buttonName.."Standard";

			button:SetID(value.index);
			
			
			if ( PVPFrame.seasonStats ) then
				getglobal(data.."TypeLabel"):SetText(ARENA_THIS_SEASON);
				PVPFrameToggleButton:SetText(ARENA_THIS_WEEK_TOGGLE);
				played = seasonTeamPlayed;
				wins = seasonTeamWins;
				playerPlayed = seasonPlayerPlayed;
			else
				getglobal(data.."TypeLabel"):SetText(ARENA_THIS_WEEK);
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
			getglobal(data.."Name"):SetText(teamName);
			getglobal(data.."Rating"):SetText(teamRating);
			getglobal(data.."Games"):SetText(played);
			getglobal(data.."Wins"):SetText(wins);
			getglobal(data.."Loss"):SetText(loss);
			
			if ( PVPFrame.seasonStats ) then
				getglobal(data.."Played"):SetText(playerRating);
				getglobal(data.."Played"):SetVertexColor(1.0, 1.0, 1.0);
				getglobal(data.."PlayedLabel"):SetText(PVP_YOUR_RATING);
			else
				-- played %
				if ( playerPlayedPct < 10 ) then
					getglobal(data.."Played"):SetVertexColor(1.0, 0, 0);
				else
					getglobal(data.."Played"):SetVertexColor(1.0, 1.0, 1.0);
				end
				-- FIXME: Turn this into a localized format string
				playerPlayedPct = format("%d", playerPlayedPct);
				getglobal(data.."Played"):SetText(playerPlayed.." ("..playerPlayedPct.."%)");
				getglobal(data.."PlayedLabel"):SetText(PLAYED);
			end
			

			-- Set TeamSize Banner
			getglobal(standard.."Banner"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize);
			getglobal(standard.."Banner"):SetVertexColor(background.r, background.g, background.b);
			getglobal(standard.."Border"):SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
			getglobal(standard.."Emblem"):SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b);
			if ( border ~= -1 ) then
				getglobal(standard.."Border"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize.."-Border-"..border);
			end
			if ( emblem ~= -1 ) then
				getglobal(standard.."Emblem"):SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
			end

			-- Set visual elements
			getglobal(data):Show();
			button:SetAlpha(1);

			highlight = getglobal(buttonName.."Highlight");
			if highlight then
				highlight:SetAlpha(1);
				highlight:SetBackdropBorderColor(1.0, 0.82, 0);
			end
			getglobal(standard):SetAlpha(1);
			getglobal(standard.."Border"):Show();
			getglobal(standard.."Emblem"):Show();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Background"):SetAlpha(1);
			getglobal(buttonName.."TeamType"):Hide();
		end
	end
	--for i=(buttonIndex+1), MAX_ARENA_TEAMS do
		--getglobal("PVPTeam"..i):SetID(0);
	--end

	-- show unused teams
	for index, value in pairs(ARENA_TEAMS) do
		if ( not value.index ) then
			-- Set button elements to variables 
			buttonIndex = buttonIndex + 1;
			button = getglobal("PVPTeam"..buttonIndex);
			buttonName = "PVPTeam"..buttonIndex;
			data = buttonName.."Data";

			-- Set standard type
			local standardBanner = getglobal(buttonName.."StandardBanner");
			standardBanner:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..value.size);
			standardBanner:SetVertexColor(1, 1, 1);

			-- Hide or Show items
			button:SetAlpha(0.4);
			getglobal(data):Hide();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Standard"):SetAlpha(0.1);
			getglobal(buttonName.."StandardBorder"):Hide();
			getglobal(buttonName.."StandardEmblem"):Hide();
			getglobal(buttonName.."TeamType"):SetFormattedText(PVP_TEAMSIZE, value.size, value.size);
			getglobal(buttonName.."TeamType"):Show();
			count = count +1;
		end
	end
	if ( count == 3 ) then
		PVPFrameToggleButton:Hide();
	else
		PVPFrameToggleButton:Show();
	end
end

function PVPTeam_OnEnter(self)
	local name = self:GetName();
	local id = self:GetID();
	local highlight = getglobal(name.."Highlight");
	if ( GetArenaTeam(id) ) then
		highlight:Show();
		GameTooltip_AddNewbieTip(self, ARENA_TEAM, 1.0, 1.0, 1.0, CLICK_FOR_DETAILS, 1);
	else
		GameTooltip_AddNewbieTip(self, ARENA_TEAM, 1.0, 1.0, 1.0, ARENA_TEAM_LEAD_IN, 1);
	end		
end

function PVPTeam_OnLeave(self)
	local highlight = getglobal(self:GetName().."Highlight");
	highlight:Hide();	
	GameTooltip:Hide();
end

function PVPTeamDetails_OnShow(self)
	UIPanelWindows["CharacterFrame"].width = CharacterFrame:GetWidth() + PVPTeamDetails:GetWidth();
	UpdateUIPanelPositions(CharacterFrame);
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

function PVPTeamDetails_OnHide(self)
	CloseArenaTeamRoster();
	UIPanelWindows["CharacterFrame"].width = CharacterFrame:GetWidth();
	UpdateUIPanelPositions();
	PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
end

function PVPTeamDetails_Update(self, id)
	local numMembers = GetNumArenaTeamMembers(id, 1);
	local name, rank, level, class, online, played, win, loss, seasonPlayed, seasonWin, seasonLoss, rating;
	local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, personalRating  = GetArenaTeam(id);		
	local button;
	local teamIndex;
	
	if ( not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
		PVPTeamDetailsAddTeamMember:Hide();
	else
		PVPTeamDetailsAddTeamMember:Show();
	end

	-- If team is not part of top 5000 display a -
	if (teamRank == 0) then
		teamRank = '-';
	end
	-- Display General Team Stats
	PVPTeamDetailsName:SetText(teamName);
	PVPTeamDetailsSize:SetFormattedText(PVP_TEAMSIZE, teamSize, teamSize);
	PVPTeamDetailsRank:SetText(teamRank);
	PVPTeamDetailsRating:SetText(teamRating);

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
		button = getglobal("PVPTeamDetailsButton"..i);
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
				getglobal("PVPTeamDetailsButton"..i.."PlayedText"):SetVertexColor(1.0, 0, 0);
			else
				getglobal("PVPTeamDetailsButton"..i.."PlayedText"):SetVertexColor(1.0, 1.0, 1.0);
			end
			
			playedPct = format("%d", playedPct);

			getglobal("PVPTeamDetailsButton"..i.."Played").tooltip = playedPct.."%";

			nameText = getglobal("PVPTeamDetailsButton"..i.."NameText");
			classText = getglobal("PVPTeamDetailsButton"..i.."ClassText");
			playedText = getglobal("PVPTeamDetailsButton"..i.."PlayedText")
			winLossWin = getglobal("PVPTeamDetailsButton"..i.."WinLossWin");
			winLossLoss = getglobal("PVPTeamDetailsButton"..i.."WinLossLoss");
			ratingText = getglobal("PVPTeamDetailsButton"..i.."RatingText");

			--- Not needed after Arena Season 3 change.
			nameButton = getglobal("PVPTeamDetailsButton"..i.."Name");
			classButton = getglobal("PVPTeamDetailsButton"..i.."Class");
			playedButton = getglobal("PVPTeamDetailsButton"..i.."Played")
			winLossButton = getglobal("PVPTeamDetailsButton"..i.."WinLoss");

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
			getglobal("PVPTeamDetailsButton"..i.."WinLoss-"):SetTextColor(r, g, b);
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

function PVPTeamDetailsToggleButton_OnClick(self)
	if ( PVPTeamDetails.season ) then
		PVPTeamDetails.season = nil;
	else
		PVPTeamDetails.season = 1;		
	end
	PVPTeamDetails_Update(self, PVPTeamDetails.team);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function PVPFrameToggleButton_OnClick()
	if ( PVPFrame.seasonStats ) then
		PVPFrame.seasonStats = nil;
	else
		PVPFrame.seasonStats = 1;		
	end
	PVPTeam_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end
						

function PVPTeamDetailsButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PVPTeamDetails.previousSelectedTeamMember = PVPTeamDetails.selectedTeamMember;
		PVPTeamDetails.selectedTeamMember = self.teamIndex;
		SetArenaTeamRosterSelection(PVPTeamDetails.team, PVPTeamDetails.selectedTeamMember);
		PVPTeamDetails_Update(self, PVPTeamDetails.team);
	else
		local teamIndex = self.teamIndex;
		local name, rank, level, class, online = GetArenaTeamRosterInfo(PVPTeamDetails.team, teamIndex);
		PVPFrame_ShowDropdown(name, online);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

function PVPTeam_OnClick(self, id)
	local teamName, teamSize = GetArenaTeam(id);
	if ( not teamName ) then
		return;
	else
		if ( PVPTeamDetails:IsShown() and id == PVPTeamDetails.team ) then
			PVPTeamDetails:Hide();
		else
			PVPTeamDetails.team = id;
			ArenaTeamRoster(id);
			PVPTeamDetails_Update(self, id);
			if (PVPTeamDetails:IsShown()) then
				PlaySound(SOUNDKIT.UI_CLASSIC_ARENA_TEAM_SELECT);
			else 
				PVPTeamDetails:Show();
			end
		end
	end
end

function PVPTeam_OnMouseDown(self)
	if ( GetArenaTeam(self:GetID()) ) then
		local button = getglobal(self:GetName());
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
		button:SetPoint(point, relativeTo, relativePoint, offsetX-2, offsetY-2);
	end
end
function PVPTeam_OnMouseUp(self)
	if ( GetArenaTeam(self:GetID()) ) then
		local button = getglobal(self:GetName());
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
		button:SetPoint(point, relativeTo, relativePoint, offsetX+2, offsetY+2);
	end
end

-- PVP Honor Data
function PVPHonor_Update()
	local hk, cp, dk, contribution, rank, highestRank, rankName, rankNumber;
	
	-- Yesterday's values
	hk = GetPVPYesterdayStats();
	PVPHonorYesterdayKills:SetText(hk);

	-- Lifetime values
	hk =  GetPVPLifetimeStats();
	PVPHonorLifetimeKills:SetText(hk);

	local honorCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID);
	PVPFrameHonorPoints:SetText(honorCurrencyInfo.quantity);

	local arenaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CLASSIC_ARENA_POINTS_CURRENCY_ID);
	PVPFrameArenaPoints:SetText(arenaCurrencyInfo.quantity)	
	
	-- Today's values
	hk = GetPVPSessionStats();
	PVPHonorTodayKills:SetText(hk);
end

function PVPTeamDetailsAddTeamMember_OnClick(self)
	StaticPopup_Show("ADD_TEAMMEMBER");
end

function PVPTeamDetailsAddTeamMember_OnEnter(self)
	GameTooltip_AddNewbieTip(self, ADDMEMBER, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_ADDTEAMMEMBER, 1);
end

function PVPTeamDetailsAddTeamMember_OnLeave(self)
	GameTooltip:Hide();
end
