function CinematicsFrame_OnLoad(self)
	local button;
	local height = 80;
	local numMovies = math.ceil((GetClientDisplayExpansionLevel() + 1) / 2);
	for i = 1, numMovies do
		button = _G["CinematicsButton"..i];
		if ( not button ) then
			break;
		end
		button:Show();
		height = height + button:GetHeight() + 8;
	end
	CinematicsFrame:SetHeight(height);
end

function CinematicsFrame_IsMovieListLocal(id)
	local MOVIE_LIST = MOVIE_LIST[id];
	if (not MOVIE_LIST) then return false; end
	for _, movieId in ipairs(MOVIE_LIST) do
		if (not IsMovieLocal(movieId)) then 
			return false;
		end
	end
	return true;
end

function CinematicsFrame_IsMovieListPlayable(id)
	local MOVIE_LIST = MOVIE_LIST[id];
	if (not MOVIE_LIST) then return false; end
	for _, movieId in ipairs(MOVIE_LIST) do
		if (not IsMoviePlayable(movieId)) then 
			return false;
		end
	end
	return true;
end

function CinematicsFrame_GetMovieDownloadProgress(id)
	local MOVIE_LIST = MOVIE_LIST[id];
	if (not MOVIE_LIST) then return; end
	
	local anyInProgress = false;
	local allDownloaded = 0;
	local allTotal = 0;
	for _, movieId in ipairs(MOVIE_LIST) do
		local inProgress, downloaded, total = GetMovieDownloadProgress(movieId);
		anyInProgress = anyInProgress or inProgress;
		allDownloaded = allDownloaded + downloaded;
		allTotal = allTotal + total;
	end
	
	return anyInProgress, allDownloaded, allTotal;
end

function CinematicsButton_Update(self)
	local movieId = self:GetID();
	if (CinematicsFrame_IsMovieListLocal(movieId)) then
		self:GetNormalTexture():SetDesaturated(false);
		self:GetPushedTexture():SetDesaturated(false);
		self.PlayButton:Show();
		self.DownloadIcon:Hide();
		self.StreamingIcon:Hide();
		self.StatusBar:Hide();
		self:SetScript("OnUpdate", nil);
		self.isLocal = true;
	else
		local inProgress, downloaded, total = CinematicsFrame_GetMovieDownloadProgress(movieId);
		local isPlayable = CinematicsFrame_IsMovieListPlayable(movieId);
		
		-- HACK - When you pause the download, sometimes the progress will appear to rewind temporarily (bug with the API?)
		-- This ensures that the progress bar never goes backwards
		downloaded = max(downloaded, self.downloaded or 0);
		
		self.inProgress = inProgress;
		self.downloaded = downloaded;
		self.total = total;
		self.isLocal = false;
		self.isPlayable = isPlayable;
		
		if (inProgress or (total > 0 and ((downloaded/total) > 0.1))) then
			self.StatusBar:SetMinMaxValues(0, total);
			self.StatusBar:SetValue(downloaded);
			self.StatusBar:Show();
		else 
			self.StatusBar:Hide();
		end

		if (isPlayable and inProgress) then
			self:GetNormalTexture():SetDesaturated(false);
			self:GetPushedTexture():SetDesaturated(false);
			self.PlayButton:Show();
			self.DownloadIcon:Hide();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", CinematicsButton_Update);
		elseif (inProgress) then
			self:GetNormalTexture():SetDesaturated(true);
			self:GetPushedTexture():SetDesaturated(true);
			self.PlayButton:Hide();
			self.DownloadIcon:Hide();
			self.StreamingIcon:Show();
			self.StreamingIcon.Loop:Play();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", CinematicsButton_Update);
		else
			self:GetNormalTexture():SetDesaturated(true);
			self:GetPushedTexture():SetDesaturated(true);
			self.PlayButton:Hide();
			self.DownloadIcon:Show();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6);
			self:SetScript("OnUpdate", nil);
		end
	end
	
	if (self.mouseIsOverMe) then
		CinematicsButton_OnEnter(self);
	end
end

function CinematicsFrame_OnShow(self)
	self:Raise();
	local numMovies = GetClientDisplayExpansionLevel() + 1;
	for i = 1, numMovies do
		local button = _G["CinematicsButton"..i];
		if ( not button ) then
			break;
		end
		button:Show();
		CinematicsButton_Update(button);
	end
end

function CinematicsFrame_OnKeyDown(self, key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "ESCAPE" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		GlueParent_CloseSecondaryScreen();
	end	
end

function CinematicsButton_OnClick(self)
	if (self.isLocal or (self.inProgress and self.isPlayable)) then
		MovieFrame.version = self:GetID();
		MovieFrame.showError = true;
		GlueParent_OpenSecondaryScreen("movie");
	else
		local inProgress, downloaded, total = CinematicsFrame_GetMovieDownloadProgress(self:GetID());
		if (inProgress) then
			local MOVIE_LIST = MOVIE_LIST[self:GetID()];
			if (MOVIE_LIST) then
				for _, movieId in ipairs(MOVIE_LIST) do
					if (not IsMovieLocal(movieId)) then 
						CancelPreloadingMovie(movieId);
					end
				end
			end
		else
			local MOVIE_LIST = MOVIE_LIST[self:GetID()];
			if (MOVIE_LIST) then
				for _, movieId in ipairs(MOVIE_LIST) do
					if (not IsMovieLocal(movieId)) then 
						PreloadMovie(movieId);
					end
				end
			end
		end
		CinematicsButton_Update(self);
	end
end

function CinematicsButton_OnEnter(self)
	self.mouseIsOverMe = true;
	if (self.isLocal or (self.inProgress and self.isPlayable)) then
		GlueTooltip:Hide();
	else
		if (self.inProgress) then
			GlueTooltip:SetText(format(CINEMATIC_DOWNLOADING, self.downloaded/self.total*100));
			GlueTooltip:AddLine(CINEMATIC_DOWNLOADING_DETAILS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			GlueTooltip:AddLine(CINEMATIC_CLICK_TO_PAUSE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		else
			GlueTooltip:SetText(CINEMATIC_UNAVAILABLE);
			GlueTooltip:AddLine(CINEMATIC_UNAVAILABLE_DETAILS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			GlueTooltip:AddLine(CINEMATIC_CLICK_TO_DOWNLOAD, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
		
		GlueTooltip:SetOwner(self);
		GlueTooltip:Show();
	end
end