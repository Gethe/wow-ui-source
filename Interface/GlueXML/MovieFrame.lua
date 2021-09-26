function MovieFrame_OnLoad(self)
	if ( not IsMacClient() ) then
		MovieFrameSubtitleArea:Hide();
	end
end

function MovieFrame_PlayMovie(self, index)
	self.movieIndex = index;
	if ( not MOVIE_LIST[self.version] or not MOVIE_LIST[self.version][index] ) then
		GlueParent_CloseSecondaryScreen();
		return;
	end
	local playSuccess, errorCode = self:StartMovie(MOVIE_LIST[self.version][index]);
	if ( playSuccess ) then
		StopGlueMusic();
		StopGlueAmbience();
	else
		if ( self.showError ) then
			GlueDialog_Show("ERROR_CINEMATIC");
		end
		GlueParent_CloseSecondaryScreen();
	end
end

function MovieFrame_PlayNextMovie(self)
	self:StopMovie();
	MovieFrame_PlayMovie(self, self.movieIndex + 1);
end

function MovieFrame_OnShow(self)
	self:EnableSubtitles(GetCVarBool("movieSubtitle"));

	HideCursor();
	MovieFrame_PlayMovie(self, 1);
	
	-- formula empirically determined to provide acceptable subtitles positioning for all resolutions
	-- at 4/3 resolutions this will put the point at -630, the previous default
	-- at wider resolutions the point will be lower
	local y = 497 + 100 * self:GetWidth() / self:GetHeight();
	MovieFrameSubtitleArea:SetPoint("TOP", 0, -y);
	MovieFrameSubtitleArea:SetHeight(768 - y);
end

function MovieFrame_OnHide(self)
	MovieFrameSubtitleString:Hide();
	self:StopMovie();
	ShowCursor();
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
	if ( key == "ESCAPE" ) then
		GlueParent_CloseSecondaryScreen();
	elseif ( key == "SPACE" or key == "ENTER" ) then
		self:StopMovie();
	end
end

function MovieFrame_OnMovieFinished(self)
	if ( self:IsShown() ) then
		MovieFrame_PlayNextMovie(self);
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

