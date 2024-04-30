function PVPFrame_ExpansionSpecificOnLoad(self)
	-- This is a base version, nothing specific here
	PVPFrameLine1:SetAlpha(0.3);
	PVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);
end

function PVPFrame_OnShow(self)
	if ( not GetCurrentArenaSeasonUsesTeams() ) then
		RequestRatedInfo();
	end
	PVPFrame_SetFaction(self);
	PVPFrame_Update(self);
end

function PVPFrame_OnHide(self)
	PVPTeamDetails:Hide();
end

function PVPFrame_ExpansionSpecificOnEvent(self, event, ...)
	-- This is a base version, nothing specific here
	if ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
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

function PVPTeam_Update()
	if ( GetCurrentArenaSeasonUsesTeams() ) then
		PVPTeam_TeamsUpdate();
	else
		PVPTeam_SoloUpdate();
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
