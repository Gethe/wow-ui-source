
function CinematicFrame_OnLoad()
	this:RegisterEvent("CINEMATIC_START");
	this:RegisterEvent("CINEMATIC_STOP");
end

function CinematicFrame_OnEvent()
	if ( event == "CINEMATIC_START" ) then
		ShowUIPanel(this, 1);
		return;
	end
	if ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(this);
		return;
	end
end
