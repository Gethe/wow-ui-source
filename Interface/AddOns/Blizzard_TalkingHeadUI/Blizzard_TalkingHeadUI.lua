TalkingHeadFrameMixin = {};

function TalkingHeadFrameMixin:OnLoad()
	self:RegisterEvent("TALKINGHEAD_REQUESTED");
	self:RegisterEvent("TALKINGHEAD_CLOSE");
	self:RegisterEvent("SOUNDKIT_FINISHED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterForClicks("RightButtonUp");

	self.NameFrame.Name:SetPoint("TOPLEFT", self.PortraitFrame.Portrait, "TOPRIGHT", 2, -19);

	local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
	AlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function TalkingHeadFrameMixin:OnEvent(event, ...)
	if ( event == "TALKINGHEAD_REQUESTED" ) then
		self:PlayCurrent();
	elseif ( event == "TALKINGHEAD_CLOSE" ) then
		self:Close();
	elseif ( event == "SOUNDKIT_FINISHED" ) then
		local voHandle = ...;
		if ( self.voHandle == voHandle ) then
			self.MainFrame.Model:VOComplete();
			self.voHandle = nil;
		end
	elseif ( event == "LOADING_SCREEN_ENABLED" ) then
		self:Reset();
		self:CloseImmediately();
	end
end

function TalkingHeadFrameMixin:CloseImmediately()
	self.isPlaying = false;

	if (self.finishTimer) then
		self.finishTimer:Cancel();
		self.finishTimer = nil;
	end
	C_TalkingHead.IgnoreCurrentTalkingHead();
	self:UpdateShownState();
	if ( self.voHandle ) then
		StopSound(self.voHandle);
		self.voHandle = nil;
	end
end

function TalkingHeadFrameMixin:OnClick(button)
	if ( button == "RightButton" ) then
		self:CloseImmediately();
		return true;
	end

	return false;
end

function TalkingHeadFrameMixin:FadeinFrames()
	self.MainFrame.TalkingHeadsInAnim:Play();
	C_Timer.After(0.5, function()
		self.NameFrame.Fadein:Play();
	end);
	C_Timer.After(0.75, function()
		self.TextFrame.Fadein:Play();
	end);
	self.BackgroundFrame.Fadein:Play();
	self.PortraitFrame.Fadein:Play();
end

function TalkingHeadFrameMixin:FadeoutFrames()
	self.MainFrame.Close:Play();
	self.NameFrame.Close:Play();
	self.TextFrame.Close:Play();
	self.BackgroundFrame.Close:Play();
	self.PortraitFrame.Close:Play();
	self.isClosing = true;
end

function TalkingHeadFrameMixin:Reset(text, name)
	-- set alpha for all animating textures
	self:StopAnimating();
	self.BackgroundFrame.TextBackground:SetAlpha(0.01);
	self.NameFrame.Name:SetAlpha(0.01);
	self.TextFrame.Text:SetAlpha(0.01);
	self.MainFrame.Sheen:SetAlpha(0.01);
	self.MainFrame.TextSheen:SetAlpha(0.01);

	self.MainFrame.Model:SetAlpha(0.01);
	self.MainFrame.Model.PortraitBg:SetAlpha(0.01);
	self.PortraitFrame.Portrait:SetAlpha(0.01);
	self.MainFrame.Overlay.Glow_LeftBar:SetAlpha(0.01);
	self.MainFrame.Overlay.Glow_RightBar:SetAlpha(0.01);
	self.MainFrame.CloseButton:SetAlpha(0.01);

	self.MainFrame:SetAlpha(1);
	self.NameFrame.Name:SetText(name);
	self.TextFrame.Text:SetText(text);

	self.isClosing = false;
end

local talkingHeadTextureKitRegionFormatStrings = {
	["TextBackground"] = "%s-TextBackground",
	["Portrait"] = "%s-PortraitFrame",
}
local talkingHeadDefaultAtlases = {
	["TextBackground"] = "TalkingHeads-TextBackground",
	["Portrait"] = "TalkingHeads-Alliance-PortraitFrame",
}
local talkingHeadFontColor = {
	["TalkingHeads-Horde"] = {Name = CreateColor(0.28, 0.02, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	["TalkingHeads-Alliance"] = {Name = CreateColor(0.02, 0.17, 0.33), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	["TalkingHeads-Neutral"] = {Name = CreateColor(0.33, 0.16, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	["Normal"] = {Name = CreateColor(1, 0.82, 0.02), Text = CreateColor(1, 1, 1), Shadow = CreateColor(0.0, 0.0, 0.0, 1.0)},
}

function TalkingHeadFrameMixin:PlayCurrent()
	self.isPlaying = true;

	local model = self.MainFrame.Model;

	if( self.finishTimer ) then
		self.finishTimer:Cancel();
		self.finishTimer = nil;
	end
	if ( self.voHandle ) then
		StopSound(self.voHandle);
		self.voHandle = nil;
	end

	local currentDisplayInfo = model:GetDisplayInfo();
	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKit = C_TalkingHead.GetCurrentLineInfo();
	local textFormatted = string.format(text);
	if ( displayInfo and displayInfo ~= 0 ) then
		if textureKit then
			SetupTextureKitOnRegions(textureKit, self.BackgroundFrame, talkingHeadTextureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
			SetupTextureKitOnRegions(textureKit, self.PortraitFrame, talkingHeadTextureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
		else
			SetupAtlasesOnRegions(self.BackgroundFrame, talkingHeadDefaultAtlases, true);
			SetupAtlasesOnRegions(self.PortraitFrame, talkingHeadDefaultAtlases, true);
			textureKit = "Normal";
		end
		local nameColor = talkingHeadFontColor[textureKit].Name;
		local textColor = talkingHeadFontColor[textureKit].Text;
		local shadowColor = talkingHeadFontColor[textureKit].Shadow;
		self.NameFrame.Name:SetTextColor(nameColor:GetRGB());
		self.NameFrame.Name:SetShadowColor(shadowColor:GetRGBA());
		self.TextFrame.Text:SetTextColor(textColor:GetRGB());
		self.TextFrame.Text:SetShadowColor(shadowColor:GetRGBA());
		local wasShown = self:IsShown();
		self:UpdateShownState();
		if ( currentDisplayInfo ~= displayInfo ) then
			model.uiCameraID = cameraID;
			model:SetDisplayInfo(displayInfo);
		else
			if ( model.uiCameraID ~= cameraID ) then
				model.uiCameraID = cameraID;
				Model_ApplyUICamera(model, model.uiCameraID);
			end
			model:SetupAnimations();
		end

		if ( isNewTalkingHead or not wasShown or self.isClosing ) then
			self:Reset(textFormatted, name);
			self:FadeinFrames();
		else
			if ( name ~= self.NameFrame.Name:GetText() ) then
				-- Fade out the old name and fade in the new name
				self.NameFrame.Fadeout:Play();
				C_Timer.After(0.25, function()
					self.NameFrame.Name:SetText(name);
				end);
				C_Timer.After(0.5, function()
					self.NameFrame.Fadein:Play();
				end);

				self.MainFrame.TalkingHeadsInAnim:Play();
			end

			if ( textFormatted ~= self.TextFrame.Text:GetText() ) then
				-- Fade out the old text and fade in the new text
				self.TextFrame.Fadeout:Play();
				C_Timer.After(0.25, function()
					self.TextFrame.Text:SetText(textFormatted);
				end);
				C_Timer.After(0.5, function()
					self.TextFrame.Fadein:Play();
				end);
			end
		end


		local success, voHandle = PlaySound(vo, "Talking Head", true, true);
		if ( success ) then
			self.voHandle = voHandle;
		end
	end
end

function TalkingHeadFrameMixin:Close()
	self.MainFrame.Model:VOComplete();
	self.MainFrame.Model:IdleAnim();
	if( self.voHandle ) then
		if( self.finishTimer ) then
			self.finishTimer:Cancel();
		end
		StopSound(self.voHandle, 2000);
		self.finishTimer = C_Timer.NewTimer(1, function()
			self:FadeoutFrames();
			self.finishTimer = nil;
			self.voHandle = nil;
			end
		);
	else
		self:FadeoutFrames();
		self.finishTimer = nil;
	end

	self.voHandle = nil;
end

function TalkingHeadFrameMixin:Close_OnFinished()
	self.isPlaying = false;
	self.isClosing = false;
	self:UpdateShownState();
end

function TalkingHeadFrameMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self.isPlaying);
end

TalkingHeadFrameModelMixin = {};

function TalkingHeadFrameModelMixin:OnLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function TalkingHeadFrameModelMixin:OnEvent()
	self:RefreshCamera();
	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
end

function TalkingHeadFrameModelMixin:OnModelLoaded()
	self:RefreshCamera();
	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end

	self:SetupAnimations();
end

function TalkingHeadFrameModelMixin:SetupAnimations()
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
		self:SetScript("OnAnimFinished", self.IdleAnim);
	else
		self:SetAnimation(self.animLoop, 0);
		self.shouldLoop = true;
		self:SetScript("OnAnimFinished", self.IdleAnim);
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

function TalkingHeadFrameModelMixin:VOComplete()
	self.shouldLoop = false;
end

function TalkingHeadFrameModelMixin:IdleAnim()
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
		self:SetScript("OnAnimFinished", nil);
		self.lineAnimDone = true;
	end
end