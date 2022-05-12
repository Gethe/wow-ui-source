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
