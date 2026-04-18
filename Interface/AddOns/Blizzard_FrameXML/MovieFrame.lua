
MovieFrameMixin = {}

function MovieFrameMixin:OnLoad()
	self:RegisterEvent("PLAY_MOVIE");
	self:RegisterEvent("STOP_MOVIE");

	self.CloseDialog.Buttons.ConfirmButton:SetScript("OnClick", function()
		self:FinishMovie();
	end);
	self.CloseDialog.Buttons.ResumeButton:SetScript("OnClick", function()
		self.CloseDialog:Hide();
	end);

	local backgroundAtlas = "collections-background-tile";
	local exists = C_Texture.GetAtlasExists(backgroundAtlas);
	self.CloseDialog.BackgroundTile:SetShown(exists);
	if exists then
		self.CloseDialog.BackgroundTile:SetAtlas(backgroundAtlas, true);
	end
end

function MovieFrameMixin:OnEvent(event, ...)
	if event == "PLAY_MOVIE" then
		local movieID = ...;
		if ( movieID ) then
			self:PlayMovie(movieID);
		end
	elseif event == "STOP_MOVIE" then
		self:FinishMovie();
	end
end

function MovieFrameMixin:PlayMovie(movieID)
	self:Show();
	self.CloseDialog:Hide();
	local playSuccess, errorCode = self:StartMovie(movieID);
	if not playSuccess then
		StaticPopup_Show("ERROR_CINEMATIC");
		self:Hide();
		local userCanceled = false;
		local didError = true;
		CinematicFinished(Enum.CinematicType.GameMovie, userCanceled, didError);
		self.movieID = nil;
	else
		CinematicStarted(Enum.CinematicType.GameMovie, movieID);
		EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicPlay", self);
		self.movieID = movieID;
	end
end

function MovieFrameMixin:FinishMovie()
	self:StopMovie(movieID);
	self:Hide();
	CinematicFinished(Enum.CinematicType.GameMovie);
	EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicStop");
end

function MovieFrameMixin:OnShow()
	WorldFrame:Hide();
	self.uiParentShown = UIParent:IsShown();
	UIParent:Hide();
	self:EnableSubtitles(GetCVarBool("movieSubtitle"));
	SpellStopTargeting();
end

function MovieFrameMixin:OnHide()
	self:StopMovie();
	self.movieID = nil;
	WorldFrame:Show();
	if ( self.uiParentShown ) then
		UIParent:Show();
		SetUIVisibility(true);
	end
end

function MovieFrameMixin:OnCinematicStopped()
	-- It's possible that both frames are trying to play around the same time, but the cinematic stop comes after we've already started a movie
	-- In that case just make sure the UI stays hidden
	if MovieFrame:IsShown() and UIParent:IsShown() then
		MovieFrame.uiParentShown = true;
		UIParent:Hide();
	end
end

function MovieFrameMixin:OnKeyUp(key)
	local keybind = GetBindingFromClick(key);
	if keybind == "TOGGLEGAMEMENU" or key == "SPACE" or key == "ENTER" then
		self:ShowCloseDialog();
	elseif keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" then
		RunBinding(keybind);
	end
end

function MovieFrameMixin:OnMovieFinished(userCanceled)
	CinematicFinished(Enum.CinematicType.GameMovie, userCanceled);
	self:Hide();
end

function MovieFrameMixin:ShowCloseDialog()
	local summary = GetCurrentCinematicSummary();

	if summary then
		self.CloseDialog.Summary:SetText(summary);
		self.CloseDialog.Summary:Show();
	else
		self.CloseDialog.Summary:Hide();
	end

	self.CloseDialog:Layout();
	self.CloseDialog:Show();
end

function MovieFrame_PlayMovie(movieFrame, movieID)
	movieFrame:PlayMovie(movieID);
end
