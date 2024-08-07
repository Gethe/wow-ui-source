
G_CinematicsMenuContextKey = "CinematicsMenu";

-- These are movieID from the MOVIE database file.
MOVIE_LIST = {
	-- Movie sequence 13 - WarWithin
	{
		expansion = LE_EXPANSION_WAR_WITHIN,
		movieIDs = { 1023 },
		upAtlas = "StreamCinematic-WarWithin2-Large-Up",
		downAtlas = "StreamCinematic-WarWithin2-Large-Down",
		title = WARWITHIN_TITLE2,
		disableAutoPlay = true,
	},

	-- Movie sequence 12 = WarWithin
	{
		expansion = LE_EXPANSION_WAR_WITHIN,
		movieIDs = { 1014 },
		upAtlas = "StreamCinematic-WarWithin-Large-Up",
		downAtlas = "StreamCinematic-WarWithin-Large-Down",
	},

	-- Movie sequence 11 = Dragonflight2
	{
		expansion = LE_EXPANSION_DRAGONFLIGHT,
		movieIDs = { 973 },
		upAtlas = "StreamCinematic-Dragonflight2-Large-Up",
		downAtlas = "StreamCinematic-Dragonflight2-Large-Down",
		title = DRAGONFLIGHT_TOTHESKIES,
		disableAutoPlay = true,
	},

	-- Movie sequence 10 = Dragonflight
	{
		expansion = LE_EXPANSION_DRAGONFLIGHT,
		movieIDs = { 960 },
		upAtlas = "StreamCinematic-Dragonflight-Large-Up",
		downAtlas = "StreamCinematic-Dragonflight-Large-Down",
	},

	-- Movie sequence 9 = Shadowlands
	{
		expansion = LE_EXPANSION_SHADOWLANDS,
		movieIDs = { 936 },
		upAtlas = "StreamCinematic-Shadowlands-Large-Up",
		downAtlas = "StreamCinematic-Shadowlands-Large-Down",
	},

	-- Movie sequence 8 = BFA
	{
		expansion = LE_EXPANSION_BATTLE_FOR_AZEROTH,
		movieIDs = { 852 },
		upAtlas = "StreamCinematic-BFA-Large-Up",
		downAtlas = "StreamCinematic-BFA-Large-Down",
	},

	-- Movie sequence 7 = Legion
	{
		expansion = LE_EXPANSION_LEGION,
		movieIDs = { 470 },
		upAtlas = "StreamCinematic-Legion-Large-Up",
		downAtlas = "StreamCinematic-Legion-Large-Down",
	},

	-- Movie sequence 6 = WoD
	{
		expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
		movieIDs = { 195 },
		upAtlas = "StreamCinematic-WOD-Large-Up",
		downAtlas = "StreamCinematic-WOD-Large-Down",
	},

	-- Movie sequence 5 = MP
	{
		expansion = LE_EXPANSION_MISTS_OF_PANDARIA,
		movieIDs = { 115 },
		upAtlas = "StreamCinematic-MOP-Large-Up",
		downAtlas = "StreamCinematic-MOP-Large-Down",
	},

	-- Movie sequence 4 = CC
	{
		expansion = LE_EXPANSION_CATACLYSM,
		movieIDs = { 23 },
		upAtlas = "StreamCinematic-CC-Large-Up",
		downAtlas = "StreamCinematic-CC-Large-Down",
	},

	-- Movie sequence 3 = LK
	{
		expansion = LE_EXPANSION_WRATH_OF_THE_LICH_KING,
		movieIDs = { 18 },
		upAtlas = "StreamCinematic-LK-Large-Up",
		downAtlas = "StreamCinematic-LK-Large-Down",
	},

	-- Movie sequence 2 = BC
	{
		expansion = LE_EXPANSION_BURNING_CRUSADE,
		movieIDs = { 27 },
		upAtlas = "StreamCinematic-BC-Large-Up",
		downAtlas = "StreamCinematic-BC-Large-Down",
	},

	-- Movie sequence 1 = Wow Classic
	{
		expansion = LE_EXPANSION_CLASSIC, 
		movieIDs = { 1, 2 },
		upAtlas = "StreamCinematic-Classic-Large-Up",
		downAtlas = "StreamCinematic-Classic-Large-Down",
	},
};

local function GetMovieIDs(movieIndex)
	local movieEntry = MOVIE_LIST[movieIndex];
	local movieIDs = movieEntry and movieEntry.movieIDs;
	return movieIDs;
end

local function CheckMovieList(movieIndex, func)
	local movieIDs = GetMovieIDs(movieIndex)
	if not movieIDs then
		return false;
	end
	for _, movieId in ipairs(movieIDs) do
		if not func(movieId) then
			return false;
		end
	end
	return true;
end

local function IsMovieReadableByIndex(movieIndex)
	return CheckMovieList(movieIndex, IsMovieReadable);
end

local function IsMovieLocalByIndex(movieIndex)
	return CheckMovieList(movieIndex, IsMovieLocal);
end

local function IsMoviePlayableByIndex(movieIndex)
	return CheckMovieList(movieIndex, IsMoviePlayable);
end

do
	local function FilterMovieList()
		local filteredMovieList = {};
		local maxExpansion = GetClientDisplayExpansionLevel();
		for index, movieEntry in ipairs(MOVIE_LIST) do
			if movieEntry.expansion <= maxExpansion then
				if IsMovieReadableByIndex(index) then
					table.insert(filteredMovieList, movieEntry);
				end
			end
		end
		MOVIE_LIST = filteredMovieList;
	end
	FilterMovieList();
end

local function GetMovieDownloadProgressByIndex(movieIndex)
	local movieIDs = GetMovieIDs(movieIndex);
	if not movieIDs then
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

CinematicsMenuMixin = {};

function CinematicsMenuMixin:OnLoad()
	self:SetTitle(CINEMATICS);

	self.CloseButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		GlueParent_CloseSecondaryScreen();
	end);

	self.ButtonList:SetElementTemplate("CinematicsMenuButtonTemplate");
	self.ButtonList:SetGetNumResultsFunction(function()
		return #MOVIE_LIST;
	end);

	local stride = 3;
	local padding = 17;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, padding, padding);
	local numDisplayedElements = stride * 3;
	self.ButtonList:SetLayout(layout, numDisplayedElements);

	self.PageControl:SetPagedList(self.ButtonList);
end

function CinematicsMenuMixin:OnShow()
	self:Raise();

	GlueParent_AddModalFrame(self);
end

function CinematicsMenuMixin:OnHide()
	GlueParent_RemoveModalFrame(self);
end

function CinematicsMenuMixin:OnKeyDown(key)
	if key == "PRINTSCREEN" then
		Screenshot();
	elseif key == "ESCAPE" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		GlueParent_CloseSecondaryScreen();
	end
end

CinematicsMenuButtonMixin = {};

function CinematicsMenuButtonMixin:OnEnter()
	self.mouseIsOverMe = true;

	if self.isLocal or (self.inProgress and self.isPlayable) then
		GlueTooltip:Hide();
	else
		if self.inProgress then
			GlueTooltip:SetText(CINEMATIC_DOWNLOADING:format(self.downloaded / self.total * 100));
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

function CinematicsMenuButtonMixin:OnLeave()
	self.mouseIsOverMe = false;

	GlueTooltip:Hide();
end

function CinematicsMenuButtonMixin:OnMouseDown()
	self.PlayButton:SetPoint("TOPRIGHT", -3, -7);
	self.DownloadIcon:SetPoint("TOPRIGHT", -3, -7);
	self.StreamingIcon:SetPoint("TOPRIGHT", -9, -13);
	self.StatusBar:SetPoint("BOTTOMLEFT", 4, 29);
end

function CinematicsMenuButtonMixin:OnMouseUp()
	self.PlayButton:SetPoint("TOPRIGHT", -5, -5);
	self.DownloadIcon:SetPoint("TOPRIGHT", -5, -5);
	self.StreamingIcon:SetPoint("TOPRIGHT", -11, -11);
	self.StatusBar:SetPoint("BOTTOMLEFT", 4, 31);
end

function CinematicsMenuButtonMixin:UpdateDisplay()
	self:UpdateState();
end

function CinematicsMenuButtonMixin:OnSelected()
	-- Overrides TemplatedListElementMixin.

	local movieIndex = self:GetListIndex();
	if self.isLocal or (self.inProgress and self.isPlayable) then
		MovieFrame.version = movieIndex;
		MovieFrame.showError = true;
		GlueParent_OpenSecondaryScreen("movie", G_CinematicsMenuContextKey);
	else
		local inProgress = GetMovieDownloadProgressByIndex(movieIndex);
		local movieIDs = GetMovieIDs(movieIndex);
		if movieIDs then
			for _, movieID in ipairs(movieIDs) do
				if not IsMovieLocal(movieID) then
					if inProgress then
						CancelPreloadingMovie(movieID);
					else
						PreloadMovie(movieID);
					end
				end
			end
		end

		self:UpdateState();
	end
end

function CinematicsMenuButtonMixin:UpdateState()
	local movieIndex = self:GetListIndex();

	local movieEntry = MOVIE_LIST[movieIndex];
	local buttonText = movieEntry.title or _G["EXPANSION_NAME" .. movieEntry.expansion];
	self:SetText(buttonText);
	self:SetNormalAtlas(movieEntry.upAtlas);
	self:SetPushedAtlas(movieEntry.downAtlas);

	if IsMovieLocalByIndex(movieIndex) then
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
		local inProgress, downloaded, total = GetMovieDownloadProgressByIndex(movieIndex);
		local isPlayable = IsMoviePlayableByIndex(movieIndex);

		-- HACK - When you pause the download, sometimes the progress will appear to rewind temporarily (bug with the API?)
		-- This ensures that the progress bar never goes backwards
		downloaded = math.max(downloaded, self.downloaded or 0);

		self.inProgress = inProgress;
		self.downloaded = downloaded;
		self.total = total;
		self.isLocal = false;
		self.isPlayable = isPlayable;

		if inProgress or (total > 0 and ((downloaded / total) > 0.1)) then
			self.StatusBar:SetMinMaxValues(0, total);
			self.StatusBar:SetValue(downloaded);
			self.StatusBar:Show();
		else
			self.StatusBar:Hide();
		end

		if isPlayable and inProgress then
			self:GetNormalTexture():SetDesaturated(false);
			self:GetPushedTexture():SetDesaturated(false);
			self.PlayButton:Show();
			self.PlayButton:SetDesaturated(false);
			self.DownloadIcon:Hide();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", self.UpdateState);
		elseif inProgress then
			self:GetNormalTexture():SetDesaturated(true);
			self:GetPushedTexture():SetDesaturated(true);
			self.PlayButton:Show();
			self.PlayButton:SetDesaturated(true);
			self.DownloadIcon:Hide();
			self.StreamingIcon:Show();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", self.UpdateState);
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

	if self.mouseIsOverMe then
		self:OnEnter();
	end
end

CinematicsMenuSubtitlesCheckboxMixin = {};

function CinematicsMenuSubtitlesCheckboxMixin:OnShow()
	self:SetChecked(GetCVarBool("movieSubtitle"));
end

function CinematicsMenuSubtitlesCheckboxMixin:OnClick()
	SetCVar("movieSubtitle", self:GetChecked());
end