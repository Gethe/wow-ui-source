function PVPFrame_ExpansionSpecificOnLoad(self)
	-- This is a base version, nothing specific here
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
end
