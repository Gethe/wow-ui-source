
SubtitlesFrameMixin = {};
function SubtitlesFrameMixin:OnLoad()
	self:RegisterEvent("SHOW_SUBTITLE");
	self:RegisterEvent("HIDE_SUBTITLE");
	EventRegistry:RegisterCallback("Subtitles.OnMovieCinematicPlay", self.OnMovieCinematicPlay, self);
	EventRegistry:RegisterCallback("Subtitles.OnMovieCinematicStop", self.OnMovieCinematicStop, self);
	self.showSubtitles = true;
end

function SubtitlesFrameMixin:OnMovieCinematicPlay(frame)
	if frame then
		self:SetFrameLevel(frame:GetFrameLevel() + 1);		
	end
	self.showSubtitles = GetCVarBool("movieSubtitle");
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
	fontString:Show();
end

function SubtitlesFrameMixin:HideSubtitles()
	for i=1, #self.Subtitles do
		self.Subtitles[i]:SetText("");
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
