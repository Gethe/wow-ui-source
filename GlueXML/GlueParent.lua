
GLUE_SCREENS = {
	["login"] = 		{ frame = "AccountLogin", 		playMusic = true,	playAmbience = true },
	["realmlist"] = 	{ frame = "RealmListUI", 		playMusic = true,	playAmbience = false },
	["charselect"] = 	{ frame = "CharacterSelect",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["charcreate"] =	{ frame = "CharacterCreate",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["kioskmodesplash"]={ frame = "KioskModeSplash",	playMusic = true,	playAmbience = false },
};

GLUE_SECONDARY_SCREENS = {
	["cinematics"] =	{ frame = "CinematicsFrame", 	playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = "gsTitleOptions" },
	["credits"] = 		{ frame = "CreditsFrame", 		playMusic = false,	playAmbience = false,	fullScreen = true,	showSound = "gsTitleCredits" },
	["movie"] = 		{ frame = "MovieFrame", 		playMusic = false,	playAmbience = false,	fullScreen = true,	showSound = "gsTitleOptionOK" },
	["options"] = 		{ frame = "VideoOptionsFrame",	playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = "gsTitleOptions" },
};

SEX_NONE = 1;
SEX_MALE = 2;
SEX_FEMALE = 3;

function GlueParent_OnLoad(self)
   	local width = GetScreenWidth();
	local height = GetScreenHeight();

	if ( width / height > 16 / 9) then
		local maxWidth = height * 16 / 9;
		local barWidth = ( width - maxWidth ) / 2;
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", barWidth, 0);
		self:SetPoint("BOTTOMRIGHT", -barWidth, 0);
	end

	self:RegisterEvent("FRAMES_LOADED");
	self:RegisterEvent("ACCOUNT_MESSAGES_BODY_LOADED");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("LOGIN_FAILED");
	self:RegisterEvent("OPEN_STATUS_DIALOG");
	self:RegisterEvent("REALM_LIST_UPDATED");
end

function GlueParent_OnEvent(self, event, ...)
	if ( event == "FRAMES_LOADED" ) then
		LocalizeFrames();
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
		GlueParent_CheckCinematic();
		if ( AccountLogin:IsVisible() ) then
			SetExpansionLogo(AccountLogin.UI.GameLogo, GetClientDisplayExpansionLevel());
		end
	elseif ( event == "LOGIN_STATE_CHANGED" ) then
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
	elseif ( event == "OPEN_STATUS_DIALOG" ) then
		local dialog, text = ...;
		GlueDialog_Show(dialog, text);
	elseif ( event == "REALM_LIST_UPDATED" ) then
		RealmList_Update();
	end
end

function InGlue()
	return true;
end

function SecureCapsuleGet(name)
	return _G[name];
end

function nop()
end

-- =============================================================
-- State/Screen functions
-- =============================================================

function GlueParent_IsScreenValid(screen)
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList = C_Login.GetState();
	if ( screen == "charselect" or screen == "charcreate" or screen == "kioskmodesplash" ) then
		return auroraState == LE_AURORA_STATE_NONE and (connectedToWoW or wowConnectionState == LE_WOW_CONNECTION_STATE_CONNECTING) and not hasRealmList;
	elseif ( screen == "realmlist" ) then
		return hasRealmList;
	elseif ( screen == "login" ) then
		return not connectedToWoW and not hasRealmList;
	else
		return false;
	end
end

function GlueParent_GetBestScreen()
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList = C_Login.GetState();
	if ( hasRealmList ) then
		return "realmlist";
	elseif ( connectedToWoW ) then
		return "charselect";
	else
		return "login";
	end
end

function GlueParent_UpdateDialogs()
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList, waitingForRealmList = C_Login.GetState();

	if ( auroraState == LE_AURORA_STATE_CONNECTING ) then
		local isQueued, queuePosition, estimatedSeconds = C_Login.GetLogonQueueInfo();
		if ( isQueued ) then
			local queueMessage;
			if ( estimatedSeconds < 60 ) then
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT_SECONDS, queuePosition);
			elseif ( estimatedSeconds > 3600 ) then
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT_UNKNOWN, queuePosition);
			else
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT, queuePosition, estimatedSeconds / 60);
			end

			GlueDialog_Show("CANCEL", queueMessage);
		else
			GlueDialog_Show("CANCEL", LOGIN_STATE_CONNECTING);
		end
	elseif ( auroraState == LE_AURORA_STATE_NONE and C_Login.GetLastError() ) then
		local errorCategory, errorID, localizedString, debugString, errorCodeString = C_Login.GetLastError();

		local isHTML = false;
		local hasURL = false;
		local useGenericURL = false;

		--If we didn't get a string from C, look one up in GlueStrings as HTML
		if ( not localizedString ) then
			local tag = string.format("%s_ERROR_%d_HTML", errorCategory, errorID);
			localizedString = _G[tag];
			if ( localizedString ) then
				isHTML = true;
			end
		end

		--If we didn't get a string from C, look one up in GlueStrings
		if ( not localizedString ) then
			local tag = string.format("%s_ERROR_%d", errorCategory, errorID);
			localizedString = _G[tag];
		end

		--If we still don't have one, just display a generic error with the ID
		if ( not localizedString ) then
			localizedString = _G[errorCategory.."_ERROR_OTHER"];
			useGenericURL = true;
		end

		--If we got a debug message, stick it on the end of the errorCodeString
		if ( debugString ) then
			errorCodeString = errorCodeString.." [[DBG "..debugString.."]]";
		end

		--See if we want a custom URL
		local urlTag = string.format("%s_ERROR_%d_URL", errorCategory, errorID);
		if ( _G[urlTag] ) then
			hasURL = true;
		end

		--Append the errorCodeString
		if ( isHTML ) then
			--Pretty hacky...
			local endOfHTML = "</p></body></html>";
			localizedString = string.gsub(localizedString, endOfHTML, string.format(" (%s)%s", errorCodeString, endOfHTML));
		else
			localizedString = string.format("%s (%s)", localizedString, errorCodeString);
		end

		if ( isHTML ) then
			GlueDialog_Show("OKAY_HTML", localizedString);
		elseif ( hasURL ) then
			GlueDialog_Show("OKAY_WITH_URL", localizedString, urlTag);
		elseif ( useGenericURL ) then
			GlueDialog_Show("OKAY_WITH_GENERIC_URL", localizedString);
		else
			GlueDialog_Show("OKAY", localizedString);
		end

		C_Login.ClearLastError();
	elseif (  waitingForRealmList ) then
		GlueDialog_Show("REALM_LIST_IN_PROGRESS");
	elseif ( wowConnectionState == LE_WOW_CONNECTION_STATE_CONNECTING ) then
		GlueDialog_Show("CANCEL", GAME_SERVER_LOGIN);
	elseif ( wowConnectionState == LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
		local waitPosition, waitMinutes, hasFCM = C_Login.GetWaitQueueInfo();

		if ( hasFCM ) then
			GlueDialog_Show("QUEUED_WITH_FCM", _G["QUEUE_FCM"]);
		elseif ( waitMinutes == 0 ) then
			local queueString = string.format(_G["QUEUE_TIME_LEFT_UNKNOWN"], waitPosition);
			GlueDialog_Show("QUEUED_NORMAL", queueString);
		elseif (waitMinutes == 1) then
			local queueString = string.format(_G["QUEUE_TIME_LEFT_SECONDS"], waitPosition);
			GlueDialog_Show("QUEUED_NORMAL", queueString);
		else
			local queueString = string.format(_G["QUEUE_TIME_LEFT"], waitPosition, waitMinutes);
			GlueDialog_Show("QUEUED_NORMAL", queueString);
		end
	else
		-- JS_TODO: make it so this only cancels state dialogs, like "Connecting"
		GlueDialog_Hide();
	end
end

function GlueParent_EnsureValidScreen()
	local currentScreen = GlueParent.currentScreen;
	if ( not GlueParent_IsScreenValid(currentScreen) ) then
		local bestScreen = GlueParent_GetBestScreen();

		LogAuroraClient("ae", "Screen invalid. Changing",
			"changingFrom", currentScreen,
			"changingTo", bestScreen);

		GlueParent_SetScreen(GlueParent_GetBestScreen());
	end
end

local function GlueParent_ChangeScreen(screenInfo, screenTable)
	LogAuroraClient("ae", "Switching to screen",
			"screen", screenInfo.frame);

	--Hide all other screens
	for key, info in pairs(screenTable) do
		if ( info ~= screenInfo ) then
			_G[info.frame]:Hide();
		end
	end

	--Start music. Have to do this before showing screen in case its OnShow changes screen.
	local displayedExpansionLevel = GetClientDisplayExpansionLevel();
	if ( screenInfo.playMusic ) then
		PlayGlueMusic(EXPANSION_GLUE_MUSIC[displayedExpansionLevel]);
	end
	if ( screenInfo.playAmbience ) then
		PlayGlueAmbience(EXPANSION_GLUE_AMBIENCE[displayedExpansionLevel], 4.0);
	end

	--Actually show this screen
	_G[screenInfo.frame]:Show();
end

function GlueParent_GetCurrentScreen()
	return GlueParent.currentScreen;
end

function GlueParent_SetScreen(screen)
	local screenInfo = GLUE_SCREENS[screen];
	if ( screenInfo ) then
		GlueParent.currentScreen = screen;

		--Sometimes, we have to do things we would normally do in OnShow even if the screen doesn't actually
		--get shown (due to a secondary screen being shown)
		if ( screenInfo.onAttemptShow ) then
			screenInfo.onAttemptShow();
		end

		local suppressScreen = false;
		if ( GlueParent.currentSecondaryScreen ) then
			local secondaryInfo = GLUE_SECONDARY_SCREENS[GlueParent.currentSecondaryScreen];
			if ( secondaryInfo and secondaryInfo.fullScreen ) then
				suppressScreen = true;
			end
		end

		--If there's a full-screen secondary screen showing right now, we'll wait to show this one.
		--Once the secondary screen hides, we'll be shown.
		if ( not suppressScreen ) then
			GlueParent_ChangeScreen(screenInfo, GLUE_SCREENS);
		end
	end
end

function GlueParent_OpenSecondaryScreen(screen)
	local screenInfo = GLUE_SECONDARY_SCREENS[screen];
	if ( screenInfo ) then
		--Close the last secondary screen
		if ( GlueParent.currentSecondaryScreen ) then
			GlueParent_CloseSecondaryScreen();
		end

		GlueParent.currentSecondaryScreen = screen;
		if ( screenInfo.fullScreen ) then
			GlueParent.ScreenFrame:Hide();

			--If it's full-screen, hide the main screen
			if ( GlueParent.currentScreen ) then
				local mainScreenInfo = GLUE_SCREENS[GlueParent.currentScreen];
				if ( mainScreenInfo ) then
					_G[mainScreenInfo.frame]:Hide();
				end
			end
		else
			GlueParent.ScreenFrame:Show();
		end
		if ( screenInfo.showSound ) then
			PlaySound(screenInfo.showSound);
		end
		GlueParent_ChangeScreen(screenInfo, GLUE_SECONDARY_SCREENS);
	end
end

function GlueParent_CloseSecondaryScreen()
	if ( GlueParent.currentSecondaryScreen ) then
		local screenInfo = GLUE_SECONDARY_SCREENS[GlueParent.currentSecondaryScreen];
		GlueParent.currentSecondaryScreen = nil;

		--The secondary screen may have started music. Start the primary screen's music if so
		local primaryScreen = GlueParent.currentScreen;
		if ( primaryScreen and GLUE_SCREENS[primaryScreen] ) then
			local displayedExpansionLevel = GetClientDisplayExpansionLevel();
			if ( GLUE_SCREENS[primaryScreen].playMusic ) then
				PlayGlueMusic(EXPANSION_GLUE_MUSIC[displayedExpansionLevel]);
			end
			if ( GLUE_SCREENS[primaryScreen].playAmbience ) then
				PlayGlueAmbience(EXPANSION_GLUE_AMBIENCE[displayedExpansionLevel], 4.0);
			end
		end

		_G[screenInfo.frame]:Hide();

		--Show the original screen if we hid it. Have to do this last in case it opens a new secondary screen.
		if ( screenInfo.fullScreen ) then
			GlueParent.ScreenFrame:Show();
			if ( GlueParent.currentScreen ) then
				GlueParent_SetScreen(GlueParent.currentScreen);
			end
		end
	end
end

function GlueParent_CheckCinematic()
	local cinematicIndex = tonumber(GetCVar("playIntroMovie"));
	local displayExpansionLevel = GetClientDisplayExpansionLevel();
	if ( not cinematicIndex or cinematicIndex <= displayExpansionLevel ) then
		SetCVar("playIntroMovie", displayExpansionLevel + 1);
		MovieFrame.version = tonumber(GetCVar("playIntroMovie"));
		GlueParent_OpenSecondaryScreen("movie");
	end
end

-- =============================================================
-- Model functions
-- =============================================================

function SetLoginScreenModel(model)

	local expansionLevel = GetClientDisplayExpansionLevel();
	local lowResBG = EXPANSION_LOW_RES_BG[expansionLevel];
	local highResBG = EXPANSION_HIGH_RES_BG[expansionLevel];
	local background = GetLoginScreenBackground(highResBG, lowResBG);

	model:SetModel(background, true);
	model:SetCamera(0);
	model:SetSequence(0);
end

local function ResetLighting(model)
	--model:SetSequence(0);
	model:SetCamera(0);
	model:ClearFog();
	model:SetGlow(0.3);

    model:ResetLights();
end

local function UpdateLighting(model)
	-- TODO: Remove this and CHAR_MODEL_FOG_INFO and bake fog into models as desired.
    local fogData = CHAR_MODEL_FOG_INFO[GetCurrentGlueTag()];
    if fogData then
    	model:SetFogNear(0);
    	model:SetFogFar(fogData.far);
    	model:SetFogColor(fogData.r, fogData.g, fogData.b);
    end
end

local glueScreenTags =
{
	["charselect"] =
	{
		["PANDAREN"] = "PANDARENCHARACTERSELECT",
	},

	["charcreate"] =
	{
		-- Classes
		["DEATHKNIGHT"] = true,
		["DEMONHUNTER"] = true,

		-- Races
		["PANDAREN"] = true,

		-- Factions
		["HORDE"] = true,
		["ALLIANCE"] = true,
		["NEUTRAL"] = true,
	},

	["default"] =
	{
		-- Classes
		["DEATHKNIGHT"] = true,
		["DEMONHUNTER"] = true,

		-- Races
		["HUMAN"] = true,
		["ORC"] = true,
		["TROLL"] = true,
		["DWARF"] = true,
		["GNOME"] = true,
		["TAUREN"] = true,
		["SCOURGE"] = true,
		["NIGHTELF"] = true,
		["DRAENEI"] = true,
		["BLOODELF"] = true,
		["GOBLIN"] = true,
		["WORGEN"] = true,
	},
};

local function GetGlueTagFromKey(subTable, key)
	if ( subTable and key ) then
		local value = subTable[key];
		local valueType = type(value);
		if ( valueType == "boolean" ) then
			return key;
		elseif ( valueType == "string" ) then
			return value;
		end
	end
end

local function UpdateGlueTagWithOrdering(subTable, ...)
	for i = 1, select("#", ...) do
		local tag = GetGlueTagFromKey(subTable, select(i, ...));
		if ( tag ) then
			GlueParent.currentTag = tag;
			return true;
		end
	end

	return false;
end

local function UpdateGlueTag()
	local currentScreen = GlueParent_GetCurrentScreen();

	local _, race, class, faction, currentTag;

	-- Determine which API to use to get character information
	if ( currentScreen == "charselect") then
		class = select(4, GetCharacterInfo(GetCharacterSelection()));
		race = select(2, GetCharacterRace(GetCharacterSelection()));
		faction = ""; -- Don't need faction for character selection, its currently irrelevant

	elseif ( currentScreen == "charcreate" ) then
		_, class = GetSelectedClass();
		_, race = GetNameForRace();
		_, faction = GetFactionForRace(GetSelectedRace());
	end

	-- Once valid information is available, determine the current tag
	if ( race and class and faction ) then
		race, class, faction = strupper(race), strupper(class), strupper(faction);

		-- Try lookup from current screen (current screen may have fixed bg's)
		if ( UpdateGlueTagWithOrdering(glueScreenTags[currentScreen], class, race, faction) ) then
			return;
		end

		-- Try lookup from defaults
		if ( UpdateGlueTagWithOrdering(glueScreenTags["default"], class, race, faction) ) then
			return;
		end
	end

	-- Fallback default value for the current glue tag
	GlueParent.currentTag = "CHARACTERSELECT";
end

function GetCurrentGlueTag()
	return GlueParent.currentTag;
end

local function PlayGlueAmbienceFromTag()
	PlayGlueAmbience(GLUE_AMBIENCE_TRACKS[GetCurrentGlueTag()], 4.0);
end

function GlueParent_DeathKnightButtonSwapMultiTexture(self)
	local textureBase;
	local highlightBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Highlight";

	if ( not self:IsEnabled() ) then
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Disabled";
	elseif ( self.down ) then
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Down";
	else
		textureBase = "Interface\\Glues\\Common\\Glue-Panel-Button-Up";
	end

	local currentGlueTag = GetCurrentGlueTag();

	if ( self.currentGlueTag ~= currentGlueTag or self.textureBase ~= textureBase ) then
		self.currentGlueTag = currentGlueTag;
		self.textureBase = textureBase;

		if ( currentGlueTag == "DEATHKNIGHT" ) then
			local suffix = self:IsEnabled() and "-Blue" or "";
			local texture = textureBase..suffix;
			local highlight = highlightBase..suffix;
			self.Left:SetTexture(texture);
			self.Middle:SetTexture(texture);
			self.Right:SetTexture(texture);
			self:SetHighlightTexture(highlight);
		else
			self.Left:SetTexture(textureBase);
			self.Middle:SetTexture(textureBase);
			self.Right:SetTexture(textureBase);
			self:SetHighlightTexture(highlightBase);
		end
	end
end

function GlueParent_DeathKnightButtonSwapSingleTexture(self)
	local currentTag = GetCurrentGlueTag();
	if ( self.currentGlueTag ~= currentTag ) then
		self.currentGlueTag = currentTag;

		if (currentTag == "DEATHKNIGHT") then
			-- Not currently needed, but could support other swaps here.
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		else
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function GlueParent_DeathKnightButtonSwap(self)
	if ( self.Left ) then
		GlueParent_DeathKnightButtonSwapMultiTexture(self);
	else
		GlueParent_DeathKnightButtonSwapSingleTexture(self);
	end
end

-- Function to set the background model for character select and create screens
function SetBackgroundModel(model, path)
	if ( model == CharacterCreate ) then
		SetCharCustomizeBackground(path);
	else
		SetCharSelectBackground(path);
	end

	UpdateGlueTag();
	PlayGlueAmbienceFromTag();

	ResetLighting(model);
	UpdateLighting(model);
end

-- =============================================================
-- Buttons
-- =============================================================

function GlueParent_ShowOptionsScreen()
	GlueParent_OpenSecondaryScreen("options");
end

function GlueParent_ShowCinematicsScreen()
	local numMovies = GetClientDisplayExpansionLevel() + 1;
	if ( numMovies == 1 ) then
		MovieFrame.version = 1;
		GlueParent_OpenSecondaryScreen("movie");
	else
		GlueParent_OpenSecondaryScreen("cinematics");
	end
end

function GlueParent_ShowCreditsScreen()
	GlueParent_OpenSecondaryScreen("credits");
end

-- =============================================================
-- Utils
-- =============================================================

function SetExpansionLogo(texture, expansionLevel)
	if ( EXPANSION_LOGOS[expansionLevel].texture ) then
		texture:SetTexture(EXPANSION_LOGOS[expansionLevel].texture);
		texture:Show();
	elseif ( EXPANSION_LOGOS[expansionLevel].atlas ) then
		texture:SetAtlas(EXPANSION_LOGOS[expansionLevel].atlas);
		texture:Show();
	else
		texture:Hide();
	end
end

function UpgradeAccount()
	PlaySound("gsLoginNewAccount");
	LoadURLIndex(2);
end

function MinutesToTime(mins, hideDays)
	local time = "";
	local count = 0;
	local tempTime;
	-- only show days if hideDays is false
	if ( mins > 1440 and not hideDays ) then
		tempTime = floor(mins / 1440);
		time = TIME_UNIT_DELIMITER .. format(DAYS_ABBR, tempTime);
		mins = mod(mins, 1440);
		count = count + 1;
	end
	if ( mins > 60  ) then
		tempTime = floor(mins / 60);
		time = time .. TIME_UNIT_DELIMITER .. format(HOURS_ABBR, tempTime);
		mins = mod(mins, 60);
		count = count + 1;
	end
	if ( count < 2 ) then
		tempTime = mins;
		time = time .. TIME_UNIT_DELIMITER .. format(MINUTES_ABBR, tempTime);
		count = count + 1;
	end
	return time;
end

function CheckSystemRequirements( previousCheck )
	if ( not previousCheck  ) then
		if ( not IsCPUSupported() ) then
			GlueDialog_Show("SYSTEM_INCOMPATIBLE_SSE");
			return;
		end
		previousCheck = nil;
	end

	if ( not previousCheck or previousCheck == "SSE" ) then
		if ( not IsShaderModelSupported() ) then
			GlueDialog_Show("FIXEDFUNCTION_UNSUPPORTED");
			return;
		end
		previousCheck = nil;
	end

	if ( not previousCheck or previousCheck == "SHADERMODEL" ) then
		if ( VideoDeviceState() == 1 ) then
			GlueDialog_Show("DEVICE_BLACKLISTED");
			return;
		end
		previousCheck = nil;
	end

	if ( not previousCheck or previousCheck == "DEVICE" ) then
		if ( VideoDriverState() == 2 ) then
			GlueDialog_Show("DRIVER_OUTOFDATE");
			return;
		end
		previousCheck = nil;
	end

	if ( not previousCheck or previousCheck == "DRIVER_OOD" ) then
		if ( VideoDriverState() == 1 ) then
			GlueDialog_Show("DRIVER_BLACKLISTED");
			return;
		end
		previousCheck = nil;
	end

	if ( not previousCheck or previousCheck == "DRIVER" ) then
		if ( not WillShaderModelBeSupported() ) then
			GlueDialog_Show("SHADER_MODEL_TO_BE_UNSUPPORTED");
			return;
		end
		previousCheck = nil;
	end
end
-- =============================================================
-- Backwards Compatibility
-- =============================================================
function getglobal(var)
	return _G[var];
end

function setglobal(var, val)
	_G[var] = val;
end
