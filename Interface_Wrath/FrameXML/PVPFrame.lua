function PVPFrame_ExpansionSpecificOnLoad(self)
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
