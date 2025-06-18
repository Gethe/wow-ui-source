function TogglePVPFrame()
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
		if ( PVPFrame:IsShown() ) then
			HideUIPanel(PVPFrame);
		else
			ShowUIPanel(PVPFrame);
			PVPFrame_UpdateTabs();
		end
	end
	UpdateMicroButtons();
end
