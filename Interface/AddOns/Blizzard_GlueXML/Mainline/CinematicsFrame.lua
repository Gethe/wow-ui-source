
MOVIE_CAPTION_FADE_TIME = 1.0;

-- These are movieID from the MOVIE database file.
MOVIE_LIST = {
  -- Movie sequence 1 = Wow Classic
  { expansion=LE_EXPANSION_CLASSIC, 
	movieIDs = { 1, 2 }, 
	upAtlas="StreamCinematic-Classic-Up", 
	downAtlas="StreamCinematic-Classic-Down",
  },
  -- Movie sequence 2 = BC
  { expansion=LE_EXPANSION_BURNING_CRUSADE, 
	movieIDs = { 27 }, 
	upAtlas="StreamCinematic-BC-Up", 
	downAtlas="StreamCinematic-BC-Down",
  },
  -- Movie sequence 3 = LK
  { expansion=LE_EXPANSION_WRATH_OF_THE_LICH_KING, 
	movieIDs = { 18 }, 
	upAtlas="StreamCinematic-LK-Up", 
	downAtlas="StreamCinematic-LK-Down",
  },
  -- Movie sequence 4 = CC
  { expansion=LE_EXPANSION_CATACLYSM, 
	movieIDs = { 23 }, 
	upAtlas="StreamCinematic-CC-Up", 
	downAtlas="StreamCinematic-CC-Down",
  },
  -- Movie sequence 5 = MP
  { expansion=LE_EXPANSION_MISTS_OF_PANDARIA, 
	movieIDs = { 115 }, 
	upAtlas="StreamCinematic-MOP-Up", 
	downAtlas="StreamCinematic-MOP-Down",
  },
  -- Movie sequence 6 = WoD
  { expansion=LE_EXPANSION_WARLORDS_OF_DRAENOR,
	movieIDs = { 195 }, 
	upAtlas="StreamCinematic-WOD-Up", 
	downAtlas="StreamCinematic-WOD-Down",
  },
  -- Movie sequence 7 = Legion
  { expansion=LE_EXPANSION_LEGION, 
	movieIDs = { 470 }, 
	upAtlas="StreamCinematic-Legion-Up", 
	downAtlas="StreamCinematic-Legion-Down",
  },
  -- Movie sequence 8 = BFA
  { expansion=LE_EXPANSION_BATTLE_FOR_AZEROTH, 
	movieIDs = { 852 }, 
	upAtlas="StreamCinematic-BFA-Up", 
	downAtlas="StreamCinematic-BFA-Down",
  },
  -- Movie sequence 9 = Shadowlands
  { expansion=LE_EXPANSION_SHADOWLANDS, 
	movieIDs = { 936 }, 
	upAtlas="StreamCinematic-Shadowlands-Up", 
	downAtlas="StreamCinematic-Shadowlands-Down",
  },
  -- Movie sequence 10 = Dragonflight
  { expansion=LE_EXPANSION_DRAGONFLIGHT, 
	movieIDs = { 960 }, 
	upAtlas="StreamCinematic-Dragonflight-Up", 
	downAtlas="StreamCinematic-Dragonflight-Down",
  },
  -- Movie sequence 11
  { expansion=LE_EXPANSION_DRAGONFLIGHT, 
	movieIDs = { 973 }, 
	upAtlas="StreamCinematic-Dragonflight2-Up", 
	downAtlas="StreamCinematic-Dragonflight2-Down", 
	title=DRAGONFLIGHT_TOTHESKIES,
	disableAutoPlay=true,
  },
};

do
	local function FilterMovieList()
		local filteredMovieList = {};
		local maxExpansion = GetClientDisplayExpansionLevel();
		for _, movieEntry in ipairs(MOVIE_LIST) do
			if movieEntry.expansion <= maxExpansion then
				table.insert(filteredMovieList, movieEntry);
			end
		end
		MOVIE_LIST = filteredMovieList;
	end
	FilterMovieList();
end

function CinematicFrame_IsAutoPlayDisabled(movieIndex)
	local movieEntry = MOVIE_LIST[movieIndex];
	return movieEntry and movieEntry.disableAutoPlay;
end

function CinematicsFrame_GetIndexRangeForExpansion(expansion)
	local firstEntry, lastEntry;
	for i, movieEntry in ipairs(MOVIE_LIST) do
		if movieEntry.expansion == expansion then
			firstEntry = firstEntry or i;
			lastEntry = i;
		end
	end
	return firstEntry, lastEntry;
end

local function GetMovieIDs(movieIndex)
	local movieEntry = MOVIE_LIST[movieIndex];
	local movieIDs = movieEntry and movieEntry.movieIDs;
	return movieIDs;
end

function CinematicsFrame_OnLoad(self)
	local buttonPadding = 8;
	local framePadding = 80;
	local columnSize = math.ceil(#MOVIE_LIST / 2);
	local buttonHeight = 0;

	local prevButton = nil;
	self.cinematicsButtonPool = CreateFramePool("BUTTON", self, "CinematicsButtonTemplate")
	for i, movieEntry in ipairs(MOVIE_LIST) do
		local button = self.cinematicsButtonPool:Acquire();
		if i == 1 then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 40, -44);
		elseif i == columnSize + 1 then
			button:SetPoint("TOPRIGHT", self, "TOPRIGHT", -40, -44);
		else
			button:SetPoint("TOP", prevButton, "BOTTOM", 0, -8);
		end
		button:SetID(i);

		local buttonText = movieEntry.title or _G["EXPANSION_NAME"..movieEntry.expansion];
		button:SetText(buttonText);
		button:Show();
		button:SetNormalAtlas(movieEntry.upAtlas);
		button:SetPushedAtlas(movieEntry.downAtlas);
		buttonHeight = button:GetHeight();
		prevButton = button;
	end

	local frameHeight = (buttonHeight + buttonPadding) * columnSize + framePadding;
	CinematicsFrame:SetHeight(frameHeight);
end

local function CheckMovieList(movieIndex, func)
	local movieIDs = GetMovieIDs(movieIndex)
	if (not movieIDs) then 
		return false; 
	end
	for _, movieId in ipairs(movieIDs) do
		if (not func(movieId)) then 
			return false;
		end
	end
	return true;
end

function CinematicsFrame_IsMovieListLocal(movieIndex)
	return CheckMovieList(movieIndex, IsMovieLocal);
end

function CinematicsFrame_IsMovieListPlayable(movieIndex)
	return CheckMovieList(movieIndex, IsMoviePlayable);
end

function CinematicsFrame_GetMovieDownloadProgress(movieIndex)
	local movieIDs = GetMovieIDs(movieIndex);
	if (not movieIDs) then
		return;
	end
	local anyInProgress = false;
	local allDownloaded = 0;
	local allTotal = 0;
	for _, movieId in ipairs(movieIDs) do
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
		self.PlayButton:SetDesaturated(false);
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
			self.PlayButton:SetDesaturated(false);
			self.DownloadIcon:Hide();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", CinematicsButton_Update);
		elseif (inProgress) then
			self:GetNormalTexture():SetDesaturated(true);
			self:GetPushedTexture():SetDesaturated(true);
			self.PlayButton:Show();
			self.PlayButton:SetDesaturated(true);
			self.DownloadIcon:Hide();
			self.StreamingIcon:Show();
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
	local numMovies = #MOVIE_LIST;
	for button in self.cinematicsButtonPool:EnumerateActive() do
		CinematicsButton_Update(button);
	end
	GlueParent_AddModalFrame(self);
end

function CinematicsFrame_OnHide(self)
	GlueParent_RemoveModalFrame(self);
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
		local movieIDs = GetMovieIDs(self:GetID());
		if (movieIDs) then
			for _, movieID in ipairs(movieIDs) do
				if (not IsMovieLocal(movieID)) then 
					if (inProgress) then
						CancelPreloadingMovie(movieID);
					else
						PreloadMovie(movieID);
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