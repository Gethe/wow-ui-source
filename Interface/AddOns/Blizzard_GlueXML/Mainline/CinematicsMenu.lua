
G_CinematicsMenuContextKey = "CinematicsMenu";

local function GetMovieIDs(movieEntry)
	local movieIDs = movieEntry and movieEntry.movieIDs;
	return movieIDs;
end

local function CheckMovieList(movieEntry, func)
	local movieIDs = GetMovieIDs(movieEntry)
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

local function IsMovieEntryReadable(movieEntry)
	return CheckMovieList(movieEntry, IsMovieReadable);
end

local function IsMovieEntryLocal(movieEntry)
	return CheckMovieList(movieEntry, IsMovieLocal);
end

local function IsMovieEntryPlayable(movieEntry)
	return CheckMovieList(movieEntry, IsMoviePlayable);
end

local function RefreshMovieList()
	local unfilteredMovieList = C_CinematicList.GetUICinematicList();

	local filteredMovieList = {};
	local maxExpansion = GetClientDisplayExpansionLevel();
	for index, movieEntry in ipairs(unfilteredMovieList) do
		table.insert(filteredMovieList, movieEntry);
	end
	MOVIE_LIST = filteredMovieList;
end

local function GetMovieEntryDownloadProgress(movieEntry)
	local movieIDs = GetMovieIDs(movieEntry);
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

	RefreshMovieList();
	self.ButtonList:ResetList();

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

	local movieIndex = self:GetMovieIndex();
	local movieEntry = MOVIE_LIST[movieIndex];
	if self.isLocal or (self.inProgress and self.isPlayable) then
		MovieFrame.version = movieIndex;
		MovieFrame.showError = true;
		GlueParent_OpenSecondaryScreen("movie", G_CinematicsMenuContextKey);
	else
		local inProgress = GetMovieEntryDownloadProgress(movieEntry);
		local movieIDs = GetMovieIDs(movieEntry);
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

function CinematicsMenuButtonMixin:GetMovieIndex()
	-- We want to show newest cinematics first.
	-- Note we don't want to just invert the list because that screws up the autoplay functionality
	return #MOVIE_LIST - self:GetListIndex() + 1;
end

function CinematicsMenuButtonMixin:UpdateState()
	local movieIndex = self:GetMovieIndex();

	local movieEntry = MOVIE_LIST[movieIndex];
	local buttonText = movieEntry.title or _G["EXPANSION_NAME" .. movieEntry.expansion];
	self:SetText(buttonText);

	self:SetNormalAtlas(movieEntry.buttonUpAtlas);
	self:SetPushedAtlas(movieEntry.buttonDownAtlas);

	if IsMovieEntryLocal(movieEntry) then
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
		local inProgress, downloaded, total = GetMovieEntryDownloadProgress(movieEntry);
		local isPlayable = IsMovieEntryPlayable(movieEntry);

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

do
	RefreshMovieList();
end