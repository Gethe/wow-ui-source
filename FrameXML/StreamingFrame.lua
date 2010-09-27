
STREAMING_CURRENT_STATUS = 0;
STREAMING_ICON_ALPHA = 0;
STREAMING_ICON_FADEIN_TIME = 2;
STREAMING_ICON_FADEOUT_TIME = 10;


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
		StreamingIcon_FadeIn(StreamingIcon);
	elseif(STREAMING_CURRENT_STATUS > 0) then
		StreamingIconSpinSpinner:SetVertexColor(0,1,0);
		StreamingIconFrameBackground:SetVertexColor(0,1,0);
		StreamingIcon.tooltip = STATUS_ADDL_FILE_TOOLTIP;
		StreamingIcon_FadeOut(StreamingIcon);
	end
	STREAMING_CURRENT_STATUS = status;
end

function StreamingIcon_OnShow()
	StreamingIcon.Loop:Play();
end

function StreamingIcon_OnHide()
	StreamingIcon.Loop:Stop();
end

function StreamingIcon_FadeIn(self)
	if( not self:IsShown()) then
		self:Show()
		STREAMING_ICON_ALPHA = 0;
		self:SetAlpha(0.0);
		self:SetScript("OnUpdate", StreamingIcon_OnUpdate_FadeIn);
	elseif(STREAMING_CURRENT_STATUS == 0) then
		STREAMING_ICON_ALPHA = self:GetAlpha() * STREAMING_ICON_FADEIN_TIME;
		self:SetScript("OnUpdate", StreamingIcon_OnUpdate_FadeIn);
	else
		self:SetAlpha(1.0);
		self:SetScript("OnUpdate", nil);
	end
end

function StreamingIcon_FadeOut(self)
	STREAMING_ICON_ALPHA = self:GetAlpha() * STREAMING_ICON_FADEOUT_TIME;
	self:SetScript("OnUpdate", StreamingIcon_OnUpdate_FadeOut);
end

function StreamingIcon_OnUpdate_FadeIn(self, elapsed)
	STREAMING_ICON_ALPHA = STREAMING_ICON_ALPHA + elapsed;
	if (STREAMING_ICON_ALPHA >= STREAMING_ICON_FADEIN_TIME) then
		self:SetAlpha(1.0);
		self:SetScript("OnUpdate", nil);
	else
		self:SetAlpha( STREAMING_ICON_ALPHA / STREAMING_ICON_FADEIN_TIME );
	end
end

function StreamingIcon_OnUpdate_FadeOut(self, elapsed)
	STREAMING_ICON_ALPHA = STREAMING_ICON_ALPHA - elapsed;
	if (STREAMING_ICON_ALPHA <= 0) then
		self:SetAlpha(0.0);
		self:SetScript("OnUpdate", nil);
		self:Hide();
	else
		self:SetAlpha( sqrt( (STREAMING_ICON_ALPHA * STREAMING_ICON_ALPHA) / (STREAMING_ICON_FADEOUT_TIME * STREAMING_ICON_FADEOUT_TIME)) );
	end
end

