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

function TogglePVPFrame()
    if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
        ToggleFrame(PVPParentFrame);
    end
end