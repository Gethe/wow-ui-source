
MOVIE_CAPTION_FADE_TIME = 1.0;

function MovieFrame_OnLoad(self)
	self:RegisterEvent("PLAY_MOVIE");
end

function MovieFrame_OnEvent(self, event, ...)
	if ( event == "PLAY_MOVIE" ) then
		local name, volume = ...;
		if ( name ) then
			MovieFrame_PlayMovie(self, name, volume);
		end
	end
end

function MovieFrame_PlayMovie(self, name, volume)
	volume = volume or 150;
	self:Show();
	if (not self:StartMovie(name, volume) ) then
		self:Hide();
		GameMovieFinished();
	end
end

function MovieFrame_OnShow(self)
	WorldFrame:Hide();
	self.uiParentShown = UIParent:IsShown();
	UIParent:Hide();
	self:EnableSubtitles(GetCVarBool("movieSubtitle"));
end

function MovieFrame_OnHide(self)
	MovieFrameSubtitleString:Hide();
	self:StopMovie();
	WorldFrame:Show();
	if ( self.uiParentShown ) then
		UIParent:Show();
		SetUIVisibility(true);
	end
end

function MovieFrame_OnUpdate(self, elapsed)
	if ( MovieFrameSubtitleString:IsShown() and self.fadingAlpha ) then
		self.fadingAlpha = self.fadingAlpha + ((elapsed / self.fadeSpeed) * self.fadeDirection);
		if ( self.fadingAlpha > 1.0 ) then
			MovieFrameSubtitleString:SetAlpha(1.0);
			self.fadingAlpha = nil;
		elseif ( self.fadingAlpha < 0.0 ) then
			MovieFrameSubtitleString:Hide();
			self.fadingAlpha = nil;
		else
			MovieFrameSubtitleString:SetAlpha(self.fadingAlpha);
		end
	end
end

function MovieFrame_OnKeyUp(self, key)
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		self:Hide();
	elseif ( key == "SPACE" or key == "ENTER" ) then
		self:StopMovie();
	end
end

function MovieFrame_OnMovieFinished(self)
	GameMovieFinished();
	if ( self:IsShown() ) then
		self:Hide();
	end
end

function MovieFrame_OnMovieShowSubtitle(self, text)
	MovieFrameSubtitleString:SetText(text);
	MovieFrameSubtitleString:Show();
	self.fadingAlpha = 0.0;
	self.fadeDirection = 1.0;
	self.fadeSpeed = MOVIE_CAPTION_FADE_TIME;
	MovieFrameSubtitleString:SetAlpha(self.fadingAlpha);
end

function MovieFrame_OnMovieHideSubtitle(self)
	self.fadingAlpha = 1.0;
	self.fadeDirection = -1.0;
	self.fadeSpeed = MOVIE_CAPTION_FADE_TIME / 2;
	MovieFrameSubtitleString:SetAlpha(self.fadingAlpha);
end

