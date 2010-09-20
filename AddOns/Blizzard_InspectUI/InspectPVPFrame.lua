
function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	InspectPVPFrame_Update();
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_SetFaction()
	local factionGroup = UnitFactionGroup("target");
	if ( factionGroup == "Alliance" ) then
		InspectPVPFrameFaction:SetTexCoord(0.69433594, 0.74804688, 0.60351563, 0.72851563);
	else
		InspectPVPFrameFaction:SetTexCoord(0.63867188, 0.69238281, 0.60351563, 0.73242188);
	end
end

function InspectPVPFrame_Update()
	for i=1, MAX_ARENA_TEAMS do
		GetInspectArenaTeamData(i);
	end	
	InspectPVPFrame_SetFaction();
	InspectPVPTeam_Update();
end

function InspectPVPTeam_Update()
	-- Display Elements
	local button, buttonName, highlight, data, standard, emblem, border;
	-- Data Elements
	local teamName, teamSize, teamRating, teamPlayed, teamWins, teamLoss, playerPlayed,  playerRating, playerPlayedPct, teamRank;
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
			if ( teamPlayed ~= 0 ) then
				playerPlayedPct =  floor( ( playerPlayed / teamPlayed ) * 100 );		
			else
				playerPlayedPct =  floor( ( playerPlayed / 1 ) * 100 );
			end

			-- Set button elements to variables 
			button = _G["InspectPVPTeam"..buttonIndex];
			buttonName = "InspectPVPTeam"..buttonIndex;
			data = buttonName.."Data";
			standard = buttonName.."Standard";

			button:SetID(value.index);

			-- Populate Data
			_G[data.."TypeLabel"]:SetText(ARENA_THIS_SEASON);
			_G[data.."Name"]:SetText(teamName);
			_G[data.."Rating"]:SetText(teamRating);
			_G[data.."Games"]:SetText(teamPlayed);
			_G[data.."Wins"]:SetText(teamWins);
			_G[data.."Loss"]:SetText(teamLoss);
			
			_G[data.."Played"]:SetText(playerRating);
			_G[data.."Played"]:SetVertexColor(1.0, 1.0, 1.0);
			_G[data.."PlayedLabel"]:SetText(RATING);

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
		end
	end

	-- show unused teams
	for index, value in pairs(ARENA_TEAMS) do
		if ( not value.index ) then
			-- Set button elements to variables 
			buttonIndex = buttonIndex + 1;
			button = _G["InspectPVPTeam"..buttonIndex];
			buttonName = "InspectPVPTeam"..buttonIndex;
			data = buttonName.."Data";

			-- Set standard type
			_G[buttonName.."StandardBanner"]:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..value.size);

			-- Hide or Show items
			button:SetAlpha(0.4);
			_G[data]:Hide();
			_G[buttonName.."Background"]:SetVertexColor(0, 0, 0);
			_G[buttonName.."Standard"]:SetAlpha(0.1);
			_G[buttonName.."StandardBanner"]:SetVertexColor(1, 1, 1);
			_G[buttonName.."StandardBorder"]:Hide();
			_G[buttonName.."StandardEmblem"]:Hide();
			_G[buttonName.."TeamType"]:SetFormattedText(PVP_TEAMSIZE, value.size, value.size);
			_G[buttonName.."TeamType"]:Show();
		end
	end
end
