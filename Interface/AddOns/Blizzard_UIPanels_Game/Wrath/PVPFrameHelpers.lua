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
