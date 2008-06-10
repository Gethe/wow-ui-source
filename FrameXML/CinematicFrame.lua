
function CinematicFrame_OnLoad()
	this:RegisterEvent("CINEMATIC_START");
	this:RegisterEvent("CINEMATIC_STOP");

	local width = GetScreenWidth();
	local height = GetScreenHeight();
	
	if ( width / height > 4 / 3) then
		local desiredHeight = width / 2;
		if ( desiredHeight > height ) then
			desiredHeight = height;
		end
		
		local blackBarHeight = ( height - desiredHeight ) / 2;

		UpperBlackBar:SetHeight( blackBarHeight );
		UpperBlackBar:SetWidth( width );
		LowerBlackBar:SetHeight( blackBarHeight );
		LowerBlackBar:SetWidth( width );
	end
	

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
