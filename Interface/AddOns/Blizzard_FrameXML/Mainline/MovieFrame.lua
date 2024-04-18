
MOVIE_CAPTION_FADE_TIME = 1.0;

function MovieFrame_OnLoad(self)
	self:RegisterEvent("PLAY_MOVIE");
	self:RegisterEvent("STOP_MOVIE");
end

function MovieFrame_OnEvent(self, event, ...)
	if ( event == "PLAY_MOVIE" ) then
		local movieID = ...;
		if ( movieID ) then
			MovieFrame_PlayMovie(self, movieID);
		end
	elseif (event == "STOP_MOVIE") then
		MovieFrame_StopMovie(self);
	end
end

function MovieFrame_PlayMovie(self, movieID)
	self:Show();
	self.CloseDialog:Hide();
	local playSuccess, errorCode = self:StartMovie(movieID);
	if ( not playSuccess ) then
		StaticPopup_Show("ERROR_CINEMATIC");
		self:Hide();
		GameMovieFinished();
	else
		EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicPlay", self);
	end
end

function MovieFrame_StopMovie(self)
	self:StopMovie(movieID);
	self:Hide();
	GameMovieFinished();
	EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicStop");
end

function MovieFrame_OnShow(self)
	WorldFrame:Hide();
	self.uiParentShown = UIParent:IsShown();
	UIParent:Hide();
	self:EnableSubtitles(GetCVarBool("movieSubtitle"));
	SpellStopTargeting();
end

function MovieFrame_OnHide(self)
	self:StopMovie();
	WorldFrame:Show();
	if ( self.uiParentShown ) then
		UIParent:Show();
		SetUIVisibility(true);
	end
end

function MovieFrame_OnCinematicStopped()
	-- It's possible that both frames are trying to play around the same time, but the cinematic stop comes after we've already started a movie
	-- In that case just make sure the UI stays hidden
	if MovieFrame:IsShown() and UIParent:IsShown() then
		MovieFrame.uiParentShown = true;
		UIParent:Hide();
	end
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
	local keybind = GetBindingFromClick(key);
	if ( keybind == "TOGGLEGAMEMENU" or key == "SPACE" or key == "ENTER" ) then
		self.CloseDialog:Show();
	elseif ( keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" ) then
		RunBinding(keybind);
	end
end

function MovieFrame_OnMovieFinished(self)
	GameMovieFinished();
	if ( self:IsShown() ) then
		self:Hide();
	end
end
