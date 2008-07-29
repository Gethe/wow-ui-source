
function CinematicFrame_OnLoad(self)
	self:RegisterEvent("CINEMATIC_START");
	self:RegisterEvent("CINEMATIC_STOP");

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

function CinematicFrame_OnEvent(self, event, ...)
	if ( event == "CINEMATIC_START" ) then
		ShowUIPanel(self, 1);
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);
	end
end
