
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
	local arg1 = ...;
	if ( event == "CINEMATIC_START" ) then
		self.isRealCinematic = arg1;	--If it isn't real, it's a vehicle cinematic
		self.closeDialog:Hide();
		ShowUIPanel(self, 1);
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);
	end
end

function CinematicFrame_OnKeyDown(self, key)
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		if ( self.isRealCinematic and IsGMClient() ) then
			StopCinematic();
		elseif ( self.isRealCinematic or CanExitVehicle() ) then	--If it's not a real cinematic, we can cancel it by leaving the vehicle.
			self.closeDialog:Show();
		end
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	end
end

function CinematicFrame_CancelCinematic()
	if ( CinematicFrame.isRealCinematic ) then
		StopCinematic();
	else
		VehicleExit();
	end
end