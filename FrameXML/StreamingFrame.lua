local STREAMING_ICON_DISPLAY = true;

--  script StreamingIcon_OnEvent(StreamingIcon, "STREAMING_ICON", 1)

function StreamingIcon_OnLoad(self)
	self:RegisterEvent("STREAMING_ICON");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function StreamingIcon_OnEvent(self, event, ...)
	if(GetCVarBool("streamStatusMessage")) then
		if event ==  "STREAMING_ICON" then
			local status = ...;
			UpdateIcon(status);
		elseif event == "PLAYER_ENTERING_WORLD" then
			StreamingIcon_UpdateVisibility();
		end
	end
end

function UpdateIcon(status)
	if(STREAMING_ICON_DISPLAY and status > 0) then
		if (status == 1) then
			StreamingIconSpinSpinner:SetVertexColor(0,1,0);
			StreamingIconFrameBackground:SetVertexColor(0,1,0);
			StreamingIcon.tooltip = STATUS_ADDL_FILE_TOOLTIP;
		elseif (status == 2) then
			StreamingIconSpinSpinner:SetVertexColor(1,.82,0);
			StreamingIconFrameBackground:SetVertexColor(1,0.82,0);
			StreamingIcon.tooltip = STATUS_MAJOR_FILE_TOOLTIP;
		elseif (status == 3) then
			StreamingIconSpinSpinner:SetVertexColor(1,0,0);
			StreamingIconFrameBackground:SetVertexColor(1,0,0);
			StreamingIcon.tooltip = STATUS_CORE_FILE_TOOLTIP;
		end
		StreamingIconTimer.Counter:Play();
	else
		StreamingIcon:Hide();
	end
end

function StreamingIcon_UpdateVisibility()
	if ( (not VehicleSeatIndicator:IsShown()) and ((not ArenaEnemyFrames) or (not ArenaEnemyFrames:IsShown())) ) then
		STREAMING_ICON_DISPLAY = true;
	else
		STREAMING_ICON_DISPLAY = false;	
	end
	local status = GetFileStreamingStatus();
	UpdateIcon(status);
end
