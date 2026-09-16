
STREAMING_CURRENT_STATUS = 0;

function StreamingIcon_OnLoad(self)
	self:RegisterEvent("STREAMING_ICON");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function StreamingIcon_OnEvent(self, event, ...)
	if(GetCVarBool("streamStatusMessage")) then
		if event ==  "STREAMING_ICON" then
			local status = ...;
			StreamingIcon_UpdateIcon(status);
		elseif event == "PLAYER_ENTERING_WORLD" then
			StreamingIcon_UpdateIcon(GetFileStreamingStatus());
		end
	end
end

function StreamingIcon_UpdateIcon(status)
	if(status > 0) then
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
		if (StreamingIcon.FadeOUT:IsPlaying()) then
			local alpha = StreamingIcon:GetAlpha();
			StreamingIcon.FadeOUT:Stop();
			StreamingIcon:SetAlpha(alpha);
		end
		StreamingIcon.FadeIN:Play();
		StreamingIcon.Loop:Play();
		StreamingIcon:Show();
	elseif(STREAMING_CURRENT_STATUS > 0) then
		StreamingIconSpinSpinner:SetVertexColor(0,1,0);
		StreamingIconFrameBackground:SetVertexColor(0,1,0);
		StreamingIcon.tooltip = STATUS_ADDL_FILE_TOOLTIP;
		if (StreamingIcon.FadeIN:IsPlaying()) then
			local alpha = StreamingIcon:GetAlpha();
			StreamingIcon.FadeIN:Stop();
			StreamingIcon:SetAlpha(alpha);
		end
		StreamingIcon.FadeOUT:Play();
	end
	STREAMING_CURRENT_STATUS = status;
end

function StreamingFrame_FadeIN_OnFinished()
	StreamingIcon:SetAlpha(1);
end

function StreamingFrame_FadeOUT_OnFinished()
	StreamingIcon:SetAlpha(0)
	StreamingIcon:Hide();
end
