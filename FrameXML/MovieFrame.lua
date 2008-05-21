
MOVIE_CAPTION_FADE_TIME = 1.0;

function MovieFrame_OnLoad()
	this:RegisterEvent("PLAY_MOVIE");
end

function MovieFrame_OnEvent(self, event, ...)
	if ( event == "PLAY_MOVIE" ) then
		local name, volume = ...;
		if ( name ) then
			MovieFrame_PlayMovie(name, volume);
		end
	end
end

function MovieFrame_PlayMovie(name, volume)
	if ( GetMovieResolution() < 1024 ) then
		name = name.."_800";
	else
		name = name.."_1024";
	end
	volume = volume or 150;
	this:Show();
	this:StartMovie(name, volume);
end

function MovieFrame_OnShow()
	WorldFrame:Hide();
	this.uiParentShown = UIParent:IsShown();
	UIParent:Hide();
	this:EnableSubtitles(GetMovieSubtitles());
end

function MovieFrame_OnHide()
	MovieFrameSubtitleString:Hide();
	this:StopMovie();
	WorldFrame:Show();
	if ( this.uiParentShown ) then
		UIParent:Show();
	end
end

function MovieFrame_OnUpdate(elapsed)
	if ( MovieFrameSubtitleString:IsShown() and this.fadingAlpha ) then
		this.fadingAlpha = this.fadingAlpha + ((elapsed / this.fadeSpeed) * this.fadeDirection);
		if ( this.fadingAlpha > 1.0 ) then
			MovieFrameSubtitleString:SetAlpha(1.0);
			this.fadingAlpha = nil;
		elseif ( this.fadingAlpha < 0.0 ) then
			MovieFrameSubtitleString:Hide();
			this.fadingAlpha = nil;
		else
			MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
		end
	end
end

function MovieFrame_OnKeyUp()
	if ( arg1 == "ESCAPE" ) then
		this:Hide();
	elseif ( arg1 == "SPACE" or arg1 == "ENTER" ) then
		this:StopMovie();
	end
end

function MovieFrame_OnMovieFinished()
	GameMovieFinished();
	if ( this:IsShown() ) then
		this:Hide();
	end
end

function MovieFrame_OnMovieShowSubtitle(text)
	MovieFrameSubtitleString:SetText(text);
	MovieFrameSubtitleString:Show();
	this.fadingAlpha = 0.0;
	this.fadeDirection = 1.0;
	this.fadeSpeed = MOVIE_CAPTION_FADE_TIME;
	MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
end

function MovieFrame_OnMovieHideSubtitle()
	this.fadingAlpha = 1.0;
	this.fadeDirection = -1.0;
	this.fadeSpeed = MOVIE_CAPTION_FADE_TIME / 2;
	MovieFrameSubtitleString:SetAlpha(this.fadingAlpha);
end

