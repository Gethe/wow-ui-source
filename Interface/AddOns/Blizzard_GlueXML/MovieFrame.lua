function MovieFrame_OnLoad(self)
	if ( not IsMacClient() ) then
		MovieFrameSubtitleArea:Hide();
	end
end

function MovieFrame_PlayMovie(self, index)
	self.movieIndex = index;
	local movieEntry = MOVIE_LIST[self.version];
	local movieID = movieEntry and movieEntry.movieIDs[index];
	if ( not movieID ) then
		GlueParent_CloseSecondaryScreen();
		return;
	end
	local playSuccess, errorCode = self:StartMovie(movieID);
	if ( playSuccess ) then
		StopGlueMusic();
		StopGlueAmbience();
	else
		if ( self.showError ) then
			GlueDialog_Show("ERROR_CINEMATIC");
		end
		GlueParent_CloseSecondaryScreen();
	end
	EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicPlay", self);
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
	EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicStop");
	self:StopMovie();
	ShowCursor();
end

function MovieFrame_OnUpdate(self, elapsed)
	if ( self.fadingAlpha ) then
		self.fadingAlpha = self.fadingAlpha + ((elapsed / self.fadeSpeed) * self.fadeDirection);
		if ( self.fadingAlpha > 1.0 ) then
			self.fadingAlpha = nil;
		elseif ( self.fadingAlpha < 0.0 ) then
			self.fadingAlpha = nil;
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


