function TalkingHeadFrame_OnLoad(self)
	self:RegisterEvent("TALKINGHEAD_REQUESTED");
	self:RegisterEvent("TALKINGHEAD_CLOSE");
	self:RegisterEvent("SOUNDKIT_FINISHED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterForClicks("RightButtonUp");

	self.NameFrame.Name:SetPoint("TOPLEFT", self.PortraitFrame.Portrait, "TOPRIGHT", 2, -19);
	self.TextFrame.Text:SetFontObjectsToTry(SystemFont_Shadow_Large, SystemFont_Shadow_Med2, SystemFont_Shadow_Med1);

	local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
	AlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function TalkingHeadFrame_OnShow(self)
	UIParent_ManageFramePositions();
end

function TalkingHeadFrame_OnHide(self)
	UIParent_ManageFramePositions();
end

function TalkingHeadFrame_OnEvent(self, event, ...)
	if ( event == "TALKINGHEAD_REQUESTED" ) then
		TalkingHeadFrame_PlayCurrent();
	elseif ( event == "TALKINGHEAD_CLOSE" ) then
		TalkingHeadFrame_Close();
	elseif ( event == "SOUNDKIT_FINISHED" ) then
		local voHandle = ...;
		if ( self.voHandle == voHandle ) then
			TalkingHeadFrame_VOComplete(self.MainFrame.Model);
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
	frame.NameFrame.Name:SetText(name);
	frame.TextFrame.Text:SetText(text);
end

local textureKitRegionFormatStrings = {
	["TextBackground"] = "%s-TextBackground",
	["Portrait"] = "%s-PortraitFrame",
}
local defaultAtlases = {
	["TextBackground"] = "TalkingHeads-TextBackground",
	["Portrait"] = "TalkingHeads-Alliance-PortraitFrame",
}


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
	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKitID = C_TalkingHead.GetCurrentLineInfo();
	local textFormatted = string.format(text);
	if ( displayInfo and displayInfo ~= 0 ) then
		if ( textureKitID ~= 0 ) then
			SetupTextureKits(textureKitID, frame, textureKitRegionFormatStrings, false, true);
		else
			SetupAtlasesOnRegions(frame, defaultAtlases, true);
		end
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
			TalkingHeadFrame_Reset(frame, textFormatted, name);
			TalkingHeadFrame_FadeinFrames();
		else
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

			if ( textFormatted ~= frame.TextFrame.Text:GetText() ) then
				-- Fade out the old text and fade in the new text
				frame.TextFrame.Fadeout:Play();
				C_Timer.After(0.25, function()
					frame.TextFrame.Text:SetText(textFormatted);
				end);
				C_Timer.After(0.5, function()
					frame.TextFrame.Fadein:Play();
				end);
			end
		end


		local success, voHandle = PlaySound(vo, "Talking Head", true, true);
		if ( success ) then
			frame.voHandle = voHandle;
		end
	end
end

function TalkingHeadFrame_Close()
	local frame = TalkingHeadFrame;
	TalkingHeadFrame_VOComplete(frame.MainFrame.Model);
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
	local animKit, animIntro, animLoop, lineDuration = C_TalkingHead.GetCurrentLineAnimationInfo();
	if ( animKit == nil ) then
		return;
	end
	if( animKit ~= self.animKit ) then
		self:StopAnimKit();
		self.animKit = nil;
	end

	if ( animKit > 0 ) then
		self.animKit = animKit;
	-- If intro is 0 (stand) we are assuming that is no-op and skipping to loop.
	elseif (animIntro > 0) then
		self.animIntro = animIntro;
		self.animLoop = animLoop;
	else
		self.animLoop = animLoop;
	end

	if (self.animKit) then
		self:PlayAnimKit(self.animKit, true);
		self:SetScript("OnAnimFinished", nil);
		self.shouldLoop = false;
	elseif (self.animIntro) then
		self:SetAnimation(self.animIntro, 0);
		self.shouldLoop = true;
		self:SetScript("OnAnimFinished", TalkingHeadFrame_IdleAnim);
	else
		self:SetAnimation(self.animLoop, 0);
		self.shouldLoop = true;
		self:SetScript("OnAnimFinished", TalkingHeadFrame_IdleAnim);
	end

	self.lineAnimDone = false;
	if (lineDuration and self.shouldLoop) then
		if (lineDuration > 1.5) then
			C_Timer.After(lineDuration - 1.5, function()
				self.shouldLoop = false;
				end);
		end
	end
end

function TalkingHeadFrame_VOComplete(self)
	self.shouldLoop = false;
end

function TalkingHeadFrame_IdleAnim(self)
	if (self.lineAnimDone) then
		return;
	end

	-- Stop the animKit
	if ( self.animKit ) then
		self:StopAnimKit();
		self.animKit = nil;
	end
	-- Keep looping
	if (self.animLoop and self.shouldLoop) then
		self:SetAnimation(self.animLoop, 0);
	else
		self:SetAnimation(0, 0);
		self:SetScript("OnAnimFinished", nil);
		self.lineAnimDone = true;
	end
end

function TalkingHeadFrame_Close_OnFinished(self)
	TalkingHeadFrame:Hide();
end