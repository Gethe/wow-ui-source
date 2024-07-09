
function InspectPVPFrame_OnLoad(self)
	InspectPVPFrameLine1:SetAlpha(0.3);
	InspectPVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);

	self:RegisterEvent("INSPECT_HONOR_UPDATE");
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnShow(self)
	InspectPVPFrame_Update();
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_SetFaction(self)
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		InspectPVPFrameHonorIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		InspectPVPFrameHonorIcon:Show();
	end
end

function InspectPVPFrame_Update(self)
	if ( GetCurrentArenaSeasonUsesTeams() ) then
		for i=1, MAX_ARENA_TEAMS do
			GetInspectArenaTeamData(i);
		end	
	end
	InspectPVPFrame_SetFaction(self);
	InspectPVPHonor_Update(self);
	InspectPVPTeam_Update(self);
end

function InspectPVPTeam_Update()
	if ( GetCurrentArenaSeasonUsesTeams() ) then
		InspectPVPTeam_TeamsUpdate();
	else
		InspectPVPTeam_SoloUpdate();
	end
end

function InspectPVPTeam_SoloUpdate()
	-- Display Elements
	local button, buttonName, data, standard;
	local emblem, emblemColor, border, borderColor, banner, bannerColor, rankColor;
	-- Data Elements
	local teamSize, rating, played, wins, loss, rank;
	local _;

	local buttonIndex = 0;

	-- fill out data
	for index=1, MAX_ARENA_TEAMS do
		buttonIndex = buttonIndex + 1;

		-- Pull Values
		rating, played, wins, _, _, rank, teamSize = GetInspectArenaData(index);
		loss = played - wins;
		emblem, emblemColor, border, borderColor, banner, bannerColor, rankColor = ArenaUtil.GetArenaBannerInfo(rating, rank);

		-- Set button elements to variables 
		button = getglobal("InspectPVPTeam"..buttonIndex);
		buttonName = "InspectPVPTeam"..buttonIndex;
		data = buttonName.."Data";

		if (rating > 0 or played > 0) then
			-- Populate Data
			getglobal(data.."TypeLabel"):SetText(ARENA_THIS_SEASON);
			getglobal(data.."Name"):SetText(_G["ARENA_" .. teamSize .. "V" .. teamSize]);
			getglobal(data.."PlayedLabel"):SetText(RATING);  -- Using the "Played" element for rating in teamless mode
			getglobal(data.."Played"):SetText(rating);
			getglobal(data.."Games"):SetText(played);
			getglobal(data.."Wins"):SetText(wins);
			getglobal(data.."Loss"):SetText(loss);

			-- Set TeamSize Banner
			standard = buttonName.."Standard";
			getglobal(standard.."Banner"):SetTexture(banner);
			getglobal(standard.."Banner"):SetVertexColor(bannerColor.r, bannerColor.g, bannerColor.b);
			if (border) then
				getglobal(standard.."Border"):SetTexture(border);
				getglobal(standard.."Border"):SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
			end
			getglobal(standard.."Emblem"):SetTexture(emblem);
			getglobal(standard.."Emblem"):SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b);

			-- Set visual elements
			getglobal(data):Show();
			button:SetAlpha(1);
			getglobal(buttonName.."Highlight"):SetAlpha(1);
			getglobal(buttonName.."Highlight"):SetBackdropBorderColor(1.0, 0.82, 0);
			getglobal(standard):SetAlpha(1);
			getglobal(standard.."Border"):Show();
			getglobal(standard.."Emblem"):Show();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Background"):SetAlpha(1);
			getglobal(buttonName.."TeamType"):Hide();
			getglobal(standard.."Rank"):Hide();
			getglobal(data.."RatingLabel"):Hide();
			getglobal(data.."Rating"):Hide();
		else
			-- Set standard type
			getglobal(buttonName.."StandardBanner"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize);

			-- Hide or Show items
			button:SetAlpha(0.4);
			getglobal(data):Hide();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Standard"):SetAlpha(0.1);
			getglobal(buttonName.."StandardBorder"):Hide();
			getglobal(buttonName.."StandardEmblem"):Hide();
			getglobal(buttonName.."TeamType"):SetFormattedText(PVP_TEAMSIZE, teamSize, teamSize);
			getglobal(buttonName.."TeamType"):Show();
		end
	end
end

function InspectPVPTeam_TeamsUpdate()
	-- Display Elements
	local button, buttonName, highlight, data, standard, emblem, border;
	-- Data Elements
	local teamName, teamSize, teamRating, teamPlayed, teamWins, teamLoss, playerPlayed,  playerRating, teamRank;
	local background = {};
	local borderColor = {};
	local emblemColor = {};
	local ARENA_TEAMS = {};
	ARENA_TEAMS[1] = {size = 2};
	ARENA_TEAMS[2] = {size = 3};
	ARENA_TEAMS[3] = {size = 5};

	-- Sort teams by size

	local buttonIndex = 0;
	for index, value in pairs(ARENA_TEAMS) do
		for i=1, MAX_ARENA_TEAMS do
			teamName, teamSize = GetInspectArenaTeamData(i);
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
			teamName, teamSize, teamRating, teamPlayed, teamWins,  playerPlayed, playerRating, background.r, background.g, background.b, emblem, emblemColor.r, emblemColor.g, emblemColor.b, border, borderColor.r, borderColor.g, borderColor.b = GetInspectArenaTeamData(value.index);
			teamLoss = teamPlayed - teamWins;

			-- Set button elements to variables 
			button = getglobal("InspectPVPTeam"..buttonIndex);
			buttonName = "InspectPVPTeam"..buttonIndex;
			data = buttonName.."Data";
			standard = buttonName.."Standard";

			button:SetID(value.index);

			-- Populate Data
			getglobal(data.."TypeLabel"):SetText(ARENA_THIS_SEASON);
			getglobal(data.."Name"):SetText(teamName);
			getglobal(data.."Rating"):SetText(teamRating);
			getglobal(data.."Games"):SetText(teamPlayed);
			getglobal(data.."Wins"):SetText(teamWins);
			getglobal(data.."Loss"):SetText(teamLoss);
			
			getglobal(data.."Played"):SetText(playerRating);
			getglobal(data.."Played"):SetVertexColor(1.0, 1.0, 1.0);
			getglobal(data.."PlayedLabel"):SetText(RATING);

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
			getglobal(buttonName.."Highlight"):SetAlpha(1);
			getglobal(buttonName.."Highlight"):SetBackdropBorderColor(1.0, 0.82, 0);
			getglobal(standard):SetAlpha(1);
			getglobal(standard.."Border"):Show();
			getglobal(standard.."Emblem"):Show();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Background"):SetAlpha(1);
			getglobal(buttonName.."TeamType"):Hide();
			
		end
	end

	-- show unused teams
	for index, value in pairs(ARENA_TEAMS) do
		if ( not value.index ) then
			-- Set button elements to variables 
			buttonIndex = buttonIndex + 1;
			button = getglobal("InspectPVPTeam"..buttonIndex);
			buttonName = "InspectPVPTeam"..buttonIndex;
			data = buttonName.."Data";

			-- Set standard type
			getglobal(buttonName.."StandardBanner"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..value.size);

			-- Hide or Show items
			button:SetAlpha(0.4);
			getglobal(data):Hide();
			getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
			getglobal(buttonName.."Standard"):SetAlpha(0.1);
			getglobal(buttonName.."StandardBorder"):Hide();
			getglobal(buttonName.."StandardEmblem"):Hide();
			getglobal(buttonName.."TeamType"):SetFormattedText(PVP_TEAMSIZE, value.size, value.size);
			getglobal(buttonName.."TeamType"):Show();
		end
	end
end

-- PVP Honor Data
function InspectPVPHonor_Update(self)
	local sessionHK, sessionDK, yesterdayHK, yesterdayHonor, thisweekHK, thisweekHonor, lastweekHK, lastweekHonor, lastweekStanding, lifetimeHK, lifetimeDK, lifetimeRank = GetInspectHonorData();
	
	-- Yesterday's values
	InspectPVPHonorYesterdayKills:SetText(yesterdayHK);
	
	-- Lifetime values
	InspectPVPHonorLifetimeKills:SetText(lifetimeHK);
	InspectPVPFrameHonorPoints:SetText("");
	InspectPVPFrameArenaPoints:SetText("");

	-- Hide Point Values
	InspectPVPFrameHonorPoints:Hide();	
	InspectPVPFrameArenaPoints:Hide();
	
	-- This session's values
	InspectPVPHonorTodayKills:SetText(sessionHK);
end