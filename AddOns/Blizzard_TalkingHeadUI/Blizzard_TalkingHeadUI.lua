function TalkingHeadFrame_OnLoad(self)
	self:RegisterEvent("TALKINGHEAD_REQUESTED");
	self:RegisterEvent("TALKINGHEAD_CLOSE");
	self:RegisterEvent("SOUNDKIT_FINISHED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterForClicks("RightButtonUp");
	
	self.NameFrame.Name:SetPoint("TOPLEFT", self.PortraitFrame.Portrait, "TOPRIGHT", 2, -19);

	local anchorFrameSubSystem = AlertFrame:AddJustAnchorFrameSubSystem(self);
	AlertFrame:SetSubSustemAnchorPriority(anchorFrameSubSystem, 0);
end

function TalkingHeadFrame_OnShow(self)
	UIParent_ManageFramePositions();
	AlertFrame:UpdateAnchors();
end

function TalkingHeadFrame_OnHide(self)
	UIParent_ManageFramePositions();
	AlertFrame:UpdateAnchors();
end

function TalkingHeadFrame_OnEvent(self, event, ...)
	if ( event == "TALKINGHEAD_REQUESTED" ) then
		TalkingHeadFrame_PlayCurrent();
	elseif ( event == "TALKINGHEAD_CLOSE" ) then
		TalkingHeadFrame_Close();
	elseif ( event == "SOUNDKIT_FINISHED" ) then
		local voHandle = ...;
		if ( self.voHandle == voHandle ) then
			TalkingHeadFrame_IdleAnim(self.MainFrame.Model);
			self.voHandle = nil;
		end
	elseif ( event == "LOADING_SCREEN_ENABLED" ) then
		TalkingHeadFrame_Reset(TalkingHeadFrame);
		TalkingHeadFrame_CloseImmediately();
	end
end

function TalkingHeadFrame_CloseImmediately()
	local frame = TalkingHeadFrame;
	if (frame.finishTimer) then
		frame.finishTimer:Cancel();
		frame.finishTimer = nil;
	end
	C_TalkingHead.IgnoreCurrentTalkingHead();
	frame:Hide();
	if ( frame.voHandle ) then
		StopSound(frame.voHandle);
		frame.voHandle = nil;
	end
end

function TalkingHeadFrame_OnClick(self, button)
	if ( button == "RightButton" ) then
		TalkingHeadFrame_CloseImmediately();
		return true;
	end
	
	return false;
end

function TalkingHeadFrame_FadeinFrames()
	local frame = TalkingHeadFrame;
	frame.MainFrame.TalkingHeadsInAnim:Play();
	C_Timer.After(0.5, function()
		frame.NameFrame.Fadein:Play();
	end);
	C_Timer.After(0.75, function()
		frame.TextFrame.Fadein:Play();
	end);
	frame.BackgroundFrame.Fadein:Play();
	frame.PortraitFrame.Fadein:Play();
end

function TalkingHeadFrame_FadeoutFrames()
	local frame = TalkingHeadFrame;
	frame.MainFrame.Close:Play();
	frame.NameFrame.Close:Play();
	frame.TextFrame.Close:Play();
	frame.BackgroundFrame.Close:Play();
	frame.PortraitFrame.Close:Play();
end

function TalkingHeadFrame_Reset(frame, text, name)
	-- set alpha for all animating textures
	frame:StopAnimating();
	frame.BackgroundFrame.TextBackground:SetAlpha(0.01);
	frame.NameFrame.Name:SetAlpha(0.01);
	frame.TextFrame.Text:SetAlpha(0.01);
	frame.MainFrame.Sheen:SetAlpha(0.01);
	frame.MainFrame.TextSheen:SetAlpha(0.01);
	
	frame.MainFrame.Model:SetAlpha(0.01);
	frame.MainFrame.Model.PortraitBg:SetAlpha(0.01);
	frame.PortraitFrame.Portrait:SetAlpha(0.01);
	frame.MainFrame.Overlay.Glow_LeftBar:SetAlpha(0.01);
	frame.MainFrame.Overlay.Glow_RightBar:SetAlpha(0.01);
	frame.MainFrame.CloseButton:SetAlpha(0.01);
	
	frame.MainFrame:SetAlpha(1);
	frame.TextFrame.Text:SetText(text);
	frame.NameFrame.Name:SetText(name);
end

function TalkingHeadFrame_PlayCurrent()
	local frame = TalkingHeadFrame;
	local model = frame.MainFrame.Model;
	
	if( frame.finishTimer ) then
		frame.finishTimer:Cancel();
		frame.finishTimer = nil;
	end
	if ( frame.voHandle ) then
		StopSound(frame.voHandle);
		frame.voHandle = nil;
	end
	
	local currentDisplayInfo = model:GetDisplayInfo();
	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead = C_TalkingHead.GetCurrentLineInfo();
	if ( displayInfo and displayInfo ~= 0 ) then
		frame:Show();
		if ( currentDisplayInfo ~= displayInfo ) then
			model.uiCameraID = cameraID;
			model:SetDisplayInfo(displayInfo);
		else
			if ( model.uiCameraID ~= cameraID ) then
				model.uiCameraID = cameraID;
				Model_ApplyUICamera(model, model.uiCameraID);
			end
			TalkingHeadFrame_SetupAnimations(model);
		end
		
		if ( isNewTalkingHead ) then
			TalkingHeadFrame_Reset(frame, text, name);
			TalkingHeadFrame_FadeinFrames();
		else
			if ( text ~= frame.TextFrame.Text:GetText() ) then
				-- Fade out the old text and fade in the new text
				frame.TextFrame.Fadeout:Play();
				C_Timer.After(0.25, function()
					frame.TextFrame.Text:SetText(text);
				end);
				C_Timer.After(0.5, function()
					frame.TextFrame.Fadein:Play();
				end);
			end
			
			if ( name ~= frame.NameFrame.Name:GetText() ) then
				-- Fade out the old name and fade in the new name
				frame.NameFrame.Fadeout:Play();
				C_Timer.After(0.25, function()
					frame.NameFrame.Name:SetText(name);
				end);
				C_Timer.After(0.5, function()
					frame.NameFrame.Fadein:Play();
				end);
				
				frame.MainFrame.TalkingHeadsInAnim:Play();
			end
		end
		
		
		local success, voHandle = PlaySoundKitID(vo, "Talking Head", true, true);
		if ( success ) then
			frame.voHandle = voHandle;
		end
	end
end

function TalkingHeadFrame_Close()
	local frame = TalkingHeadFrame;
	TalkingHeadFrame_IdleAnim(frame.MainFrame.Model);
	if( frame.voHandle ) then
		if( frame.finishTimer ) then
			frame.finishTimer:Cancel();
		end
		StopSound(frame.voHandle, 2000);
		frame.finishTimer = C_Timer.NewTimer(1, function()
			TalkingHeadFrame_FadeoutFrames();
			frame.finishTimer = nil;
			frame.voHandle = nil;
			end
		);
	else
		TalkingHeadFrame_FadeoutFrames();
		frame.finishTimer = nil;
	end
	
	frame.voHandle = nil;
end

function TalkingHeadFrame_OnModelLoaded(self)
	self:RefreshCamera();
	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
	
	TalkingHeadFrame_SetupAnimations(self);
end

function TalkingHeadFrame_SetupAnimations(self)
	local animKit = C_TalkingHead.GetCurrentLineAnimationInfo();
	if ( animKit == nil ) then
		return;
	end
	if( animKit ~= self.animKit ) then
		self:StopAnimKit();
	end
	
	if ( animKit > 0 ) then
		self.animKit = animKit;
	else
		self.anim = 60; -- Talking emote
	end
	
	self.idleAnimEnabled = false;
	if (self.animKit) then
		self:PlayAnimKit(self.animKit, true);
		self:SetScript("OnAnimFinished", nil);
	elseif (self.anim) then
		self:SetAnimation(self.anim, 0, true);
		self:SetScript("OnAnimFinished", TalkingHeadFrame_IdleAnim);
	else
		self:SetScript("OnAnimFinished", nil);
	end
end

function TalkingHeadFrame_IdleAnim(self)
	-- Stop looping
	self.anim = nil;
	self:SetScript("OnAnimFinished", nil);
	
	-- play idle animation
	if ( self.animKit ) then
		self:StopAnimKit();
		self.animKit = nil;
	elseif ( not self.idleAnimEnabled ) then
		self:SetAnimation(0, 0);
	end
	self.idleAnimEnabled = true;
end

function TalkingHeadFrame_Close_OnFinished(self)
	TalkingHeadFrame:Hide();
end