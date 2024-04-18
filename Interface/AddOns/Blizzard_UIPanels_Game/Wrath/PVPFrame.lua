function PVPFrame_ExpansionSpecificOnLoad(self)
	PVPFrameLine1:SetAlpha(0.3);
	PVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);
	self:RegisterEvent("BATTLEFIELDS_SHOW");
end

function PVPFrame_OnShow()
	if ( not GetCurrentArenaSeasonUsesTeams() ) then
		RequestRatedInfo();
	end
	PVPFrame_SetFaction();
	PVPFrame_Update();
	UpdateMicroButtons();
	SetPortraitTexture(PVPFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function PVPFrame_OnHide()
	PVPTeamDetails:Hide();
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function PVPFrame_ExpansionSpecificOnEvent(self, event, ...)
	if ( event == "BATTLEFIELDS_SHOW" and not IsBattlefieldArena() ) then
		ShowUIPanel(PVPParentFrame);
		PVPParentFrameTab2:Click();
		BattlefieldFrame_UpdatePanelInfo();
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

function TogglePVPFrame()
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
		if ( PVPParentFrame:IsShown() ) then
			HideUIPanel(PVPParentFrame);
		else
			ShowUIPanel(PVPParentFrame);
			PVPFrame_UpdateTabs();
		end
	end
	UpdateMicroButtons();
end

function PVPFrame_UpdateTabs()
	local selectedTab = PanelTemplates_GetSelectedTab(PVPParentFrame)
	if (selectedTab == nil or selectedTab == 1) then
		PVPParentFrameTab1:Click();
	elseif (selectedTab == 2) then
		PVPParentFrameTab2:Click();
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
