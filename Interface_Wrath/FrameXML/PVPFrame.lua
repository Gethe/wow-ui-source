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
	BattlefieldFrame:Hide();
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function TogglePVPFrame()
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
		if ( PVPParentFrame:IsShown() or BattlefieldFrame:IsShown() ) then
			if ( BattlefieldFrame:IsShown() ) then
				BattlefieldFrame:Hide();
				PVPParentFrame:Hide();
			else
				PVPParentFrame:Hide();
			end
		else
			PVPParentFrame:Show();
			PVPFrame_UpdateTabs();
		end
	end
	UpdateMicroButtons();
end

function PVPFrame_UpdateTabs()
	local selectedTab = PanelTemplates_GetSelectedTab(PVPParentFrame)
	if (selectedTab == nil or selectedTab == 1) then
		BattlefieldFrame:Hide();
		PVPFrame:Show();
		PVPParentFrameTab1:Click();
	elseif (selectedTab == 2) then
		PVPFrame:Hide();
		BattlefieldFrame:Show();
		PVPParentFrameTab2:Click();
	end
end
