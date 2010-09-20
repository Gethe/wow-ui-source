
--/script StreamingMessage_OnEvent(StreamingDialog, "STREAMING_IDLE")
--/script StreamingMessage_OnEvent(StreamingDialog, "STREAMING_ADDL_FILES")	
--/script StreamingMessage_OnEvent(StreamingDialog, "STREAMING_MAJOR_FILES")
--/script StreamingMessage_OnEvent(StreamingDialog, "STREAMING_CORE_FILES")

local state = "STREAMING_IDLE";
local hidden = false;

function UpdateIcon()
	if(hidden) then
		StreamingIcon:Hide();
		StreamingIconSpinAnimate:Stop();
	elseif(state ~= STREAMING_IDLE) then
		StreamingIcon:Show();
		StreamingIconSpinAnimate:Play();
	end
end

function StreamingDialog_OnEvent(self, event, ...)
	if(GetCVarBool("streamStatusMessage")) then
		if(event == state) then
			return;
		end
		state = event;
		self.grow:Stop();
		self.event = event;
		if event ==  "STREAMING_IDLE" then
			self:Hide();
			UpdateIcon();
		elseif event == "STREAMING_ADDL_FILES" then
			self.Text.Status:SetVertexColor(0, 1, 0, 1);
--			self.Text.Status:SetText(STATUS_ADDL_FILE1);
--			self.Text.Detail:SetText(STATUS_ADDL_FILE2);
			StreamingIconSpinSpinner:SetVertexColor(0,1,0,1);
			StreamingIconFrameBackground:SetVertexColor(0,1,0,1);
			StreamingIcon.tooltip = STATUS_ADDL_FILE_TOOLTIP;
			UpdateIcon();
		elseif event == "STREAMING_MAJOR_FILES" then
			self.Text.Status:SetVertexColor(1, .82, 0, 1);
--			self.Text.Status:SetText(STATUS_MAJOR_FILE1);
--			self.Text.Detail:SetText(STATUS_MAJOR_FILE2);
			StreamingIconSpinSpinner:SetVertexColor(1,.82,0,1);
			StreamingIconFrameBackground:SetVertexColor(1,0.82,0,1);
			StreamingIcon.tooltip = STATUS_MAJOR_FILE_TOOLTIP;
			UpdateIcon();
		elseif event == "STREAMING_CORE_FILES" then
			self.Text.Status:SetVertexColor(1, 0, 0, 1);
--			self.Text.Status:SetText(STATUS_CORE_FILE1);
--			self.Text.Detail:SetText(STATUS_CORE_FILE2);
			StreamingIconSpinSpinner:SetVertexColor(1,0,0,1);
			StreamingIconFrameBackground:SetVertexColor(1,0,0,1);
			StreamingIcon.tooltip = STATUS_CORE_FILE_TOOLTIP;
			UpdateIcon();
		end
		--[[
		if event ~=  "STREAMING_IDLE" then
			self.grow:Play();
		end
		]]
		UIParent_ManageFramePositions();
	end
end

function StreamingIcon_OnLoad()
	local status = GetFileStreamingStatus();
	local eventtable={
		"STREAMING_IDLE", "STREAMING_ADDL_FILES", "STREAMING_MAJOR_FILES", "STREAMING_CORE_FILES"
	}
	StreamingDialog_OnEvent(StreamingDialog, eventtable[1+status]);
end

function StreamingIcon_UpdateVisibility()
	if ( (not VehicleSeatIndicator:IsShown()) and ((not ArenaEnemyFrames) or (not ArenaEnemyFrames:IsShown())) ) then
		hidden = false;
	else
		hidden = true;	
	end
	UpdateIcon();
end
