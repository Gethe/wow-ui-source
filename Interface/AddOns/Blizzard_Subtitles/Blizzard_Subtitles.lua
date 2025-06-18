local SUBTITLES_ENABLED_CVAR = "movieSubtitle";
local SUBTITLES_BACKGROUND_CVAR = "movieSubtitleBackground";
local SUBTITLES_BACKGROUND_OPACITY_CVAR = "movieSubtitleBackgroundAlpha";
local BACKGROUND_TYPE_DEFAULT = 1; -- NONE

SubtitlesFrameMixin = {};

function SubtitlesFrameMixin:OnLoad()
	self:RegisterEvent("SHOW_SUBTITLE");
	self:RegisterEvent("HIDE_SUBTITLE");
	EventRegistry:RegisterCallback("Subtitles.OnMovieCinematicPlay", self.OnMovieCinematicPlay, self);
	EventRegistry:RegisterCallback("Subtitles.OnMovieCinematicStop", self.OnMovieCinematicStop, self);
	self.showSubtitles = true;

	-- Note: subtitle background types are also used in Subtitles.lua
	self.subtitleBackgroundTypes = {
		nil,
		CINEMATIC_SUBTITLES_BLACK_BACKGROUND_COLOR,
		CINEMATIC_SUBTITLES_LIGHT_BACKGROUND_COLOR,
	};
end

function SubtitlesFrameMixin:OnMovieCinematicPlay(frame)
	if frame then
		self:SetFrameLevel(frame:GetFrameLevel() + 1);
		self.forcedAspectRatio = frame.forcedAspectRatio;
	end
	self.showSubtitles = GetCVarBool(SUBTITLES_ENABLED_CVAR);
	self:Show();
end

function SubtitlesFrameMixin:OnMovieCinematicStop()
	self:HideSubtitles();
	self:Hide();
end

function SubtitlesFrameMixin:AddSubtitle(body)
	local fontString = nil;
	for i=1, #self.Subtitles do
		if ( not self.Subtitles[i]:IsShown() ) then
			fontString = self.Subtitles[i];
			break;
		end
	end

	if ( not fontString ) then
		--Scroll everything up.
		for i=1, #self.Subtitles - 1 do
			self.Subtitles[i]:SetText(self.Subtitles[i + 1]:GetText());
		end
		fontString = self.Subtitles[#self.Subtitles];
	end

	fontString:SetText(body);

	-- subtitle background and bg alpha are not available at glues (yet)
	if not C_Glue.IsOnGlueScreen() then
		local subtitleBackground = GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_CVAR);
		local subtitleBackgroundAlpha = (GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_OPACITY_CVAR) / 100);

		if subtitleBackground then
			if subtitleBackground > BACKGROUND_TYPE_DEFAULT and self.forcedAspectRatio ~= Enum.CameraModeAspectRatio.Cinemascope_2_Dot_4_X_1 then
				-- Set the background height/width to the string height/width + some padding, *or* the max height/width of that element
				local subtitleBackgroundHeight = (fontString:GetStringHeight() <= 123 and fontString:GetStringHeight() + 15 or 138);
				local subtitleBackgroundWidth = fontString:GetStringWidth() <= 780 and fontString:GetStringWidth() + 20 or 800;
				
				self.SubtitleBackground:SetHeight(subtitleBackgroundHeight);
				self.SubtitleBackground:SetWidth(subtitleBackgroundWidth);
				self.SubtitleBackground:SetColorTexture(self.subtitleBackgroundTypes[subtitleBackground]:GetRGB());
				self.SubtitleBackground:SetAlpha(subtitleBackgroundAlpha);
				self.SubtitleBackground:Show();
			end
		end
	end

	fontString:Show();
end

function SubtitlesFrameMixin:HideSubtitles()
	for i=1, #self.Subtitles do
		self.Subtitles[i]:SetText("");
		self.SubtitleBackground:SetAlpha(0);
		self.SubtitleBackground:Hide();
		self.Subtitles[i]:Hide();
	end
end

function SubtitlesFrameMixin:OnEvent(event, ...)
	if ( event == "SHOW_SUBTITLE" ) then
		if self.showSubtitles then
			local message, sender = ...;
			local body;
			if sender then
				body = format(SUBTITLE_FORMAT, sender, message);
			else
				body = message;
			end
			self:AddSubtitle(body);
		end
	elseif ( event == "HIDE_SUBTITLE") then
		self:HideSubtitles();
	end
end
