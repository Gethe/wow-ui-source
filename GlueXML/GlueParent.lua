
GLUE_SCREENS = {
	["login"] = 		{ frame = "AccountLogin", 		playMusic = true,	playAmbience = true },
	["realmlist"] = 	{ frame = "RealmListUI", 		playMusic = true,	playAmbience = false },
	["charselect"] = 	{ frame = "CharacterSelect",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["charcreate"] =	{ frame = "CharacterCreate",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["kioskmodesplash"]={ frame = "KioskModeSplash",	playMusic = true,	playAmbience = false },
};

GLUE_SECONDARY_SCREENS = {
	["cinematics"] =	{ frame = "CinematicsFrame", 	playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = SOUNDKIT.GS_TITLE_OPTIONS },
	["credits"] = 		{ frame = "CreditsFrame", 		playMusic = false,	playAmbience = false,	fullScreen = true,	showSound = SOUNDKIT.GS_TITLE_CREDITS },
	-- Bug 477070 We have some rare race condition crash in the sound engine that happens when the MovieFrame's "showSound" sound plays at the same time the movie audio is starting.
	-- Removing the showSound from the MovieFrame in attempt to avoid the crash, until we can actually find and fix the bug in the sound engine.
	["movie"] = 		{ frame = "MovieFrame", 		playMusic = false,	playAmbience = false,	fullScreen = true },
	["options"] = 		{ frame = "VideoOptionsFrame",	playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = SOUNDKIT.GS_TITLE_OPTIONS },
};

ACCOUNT_SUSPENDED_ERROR_CODE = 53;

-- Mirror of the same variables in Blizzard_StoreUISecure.lua and UIParent.lua
local WOW_GAMES_CATEGORY_ID = 33; 
WOW_GAME_TIME_CATEGORY_ID = 37;

local function OnDisplaySizeChanged(self)
	local width = GetScreenWidth();
	local height = GetScreenHeight();

	local MIN_ASPECT = 5 / 4;
	local MAX_ASPECT = 16 / 9;
	local currentAspect = width / height;

	self:ClearAllPoints();

	if ( currentAspect > MAX_ASPECT ) then
		local maxWidth = height * MAX_ASPECT;
		local barWidth = ( width - maxWidth ) / 2;
		self:SetScale(1);
		self:SetPoint("TOPLEFT", barWidth, 0);
		self:SetPoint("BOTTOMRIGHT", -barWidth, 0);
	elseif ( currentAspect < MIN_ASPECT ) then
		local maxHeight = width / MIN_ASPECT;
		local scale = currentAspect / MIN_ASPECT;
		local barHeight = ( height - maxHeight ) / (2 * scale);
		self:SetScale(maxHeight/height);
		self:SetPoint("TOPLEFT", 0, -barHeight);
		self:SetPoint("BOTTOMRIGHT", 0, barHeight);
	else
		self:SetScale(1);
		self:SetAllPoints();
	end
end

function GlueParent_OnLoad(self)
	-- alias GlueParent to UIParent
	UIParent = self;

	self:RegisterEvent("FRAMES_LOADED");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("OPEN_STATUS_DIALOG");
	self:RegisterEvent("REALM_LIST_UPDATED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("LUA_WARNING");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self:RegisterEvent("KIOSK_SESSION_SHUTDOWN");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");

	OnDisplaySizeChanged(self);
end

function GlueParent_OnEvent(self, event, ...)
	if ( event == "FRAMES_LOADED" ) then
		LocalizeFrames();
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
		GlueParent_CheckCinematic();
		if ( AccountLogin:IsVisible() ) then
			SetClassicLogo(AccountLogin.UI.GameLogo, GetClientDisplayExpansionLevel());
		end
	elseif ( event == "LOGIN_STATE_CHANGED" ) then
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
	elseif ( event == "OPEN_STATUS_DIALOG" ) then
		local dialog, text = ...;
		GlueDialog_Show(dialog, text);
	elseif ( event == "REALM_LIST_UPDATED" ) then
		RealmList_Update();
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		OnDisplaySizeChanged(self);
	elseif ( event == "LUA_WARNING" ) then
		HandleLuaWarning(...);
	elseif ( event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT" ) then
		if not StoreFrame_IsShown() then
			GlueDialog_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		end
	elseif (event == "KIOSK_SESSION_SHUTDOWN" or event == "KIOSK_SESSION_EXPIRED") then
		GlueParent_SetScreen("kioskmodesplash");
	elseif (event == "KIOSK_SESSION_EXPIRATION_CHANGED") then
		GlueDialog_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);
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

		if ( errorCategory == "BNET" and errorID == ACCOUNT_SUSPENDED_ERROR_CODE ) then
			local remaining = C_Login.GetAccountSuspensionRemainingTime();
			if (remaining) then
				local days = floor(remaining / 86400);
				local hours = floor((remaining / 3600) - (days * 24));
				local minutes = floor((remaining / 60) - (days * 1440) - (hours * 60));
				localizedString = localizedString:format(" "..ACCOUNT_SUSPENSION_EXPIRATION:format(days, hours, minutes));
			else
				localizedString = localizedString:format("");
			end
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
		local serverName, pvp, rp, down = GetServerName();
		local waitPosition, waitMinutes, hasFCM = C_Login.GetWaitQueueInfo();

		local queueString;
		if (serverName) then
			if ( waitMinutes == 0 ) then
				queueString = string.format(_G["QUEUE_NAME_TIME_LEFT_UNKNOWN"], serverName, waitPosition);
			elseif ( waitMinutes == 1 ) then
				queueString = string.format(_G["QUEUE_NAME_TIME_LEFT_SECONDS"], serverName, waitPosition);
			else
				queueString = string.format(_G["QUEUE_NAME_TIME_LEFT"], serverName, waitPosition, waitMinutes);
			end
		else
			if ( waitMinutes == 0 ) then
				queueString = string.format(_G["QUEUE_TIME_LEFT_UNKNOWN"], waitPosition);
			elseif ( waitMinutes == 1 ) then
				queueString = string.format(_G["QUEUE_TIME_LEFT_SECONDS"], waitPosition);
			else
				queueString = string.format(_G["QUEUE_TIME_LEFT"], waitPosition, waitMinutes);
			end
		end

		if ( hasFCM ) then
			queueString = queueString .. "\n\n" .. _G["QUEUE_FCM"];
			GlueDialog_Show("QUEUED_WITH_FCM", queueString);
		else
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

		GlueParent_SetScreen(bestScreen);
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

--[[
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
--]]

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
		["VOIDELF"] = true,
		["LIGHTFORGEDDRAENEI"] = true,
		["NIGHTBORNE"] = true,
		["HIGHMOUNTAINTAUREN"] = true,
		["DARKIRONDWARF"] = true,
		["MAGHARORC"] = true,
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

	local race, class, faction, currentTag;

	-- Determine which API to use to get character information
	if ( currentScreen == "charselect") then
		class = select(5, GetCharacterInfo(GetCharacterSelection()));
		race = select(2, GetCharacterRace(GetCharacterSelection()));
		faction = ""; -- Don't need faction for character selection, its currently irrelevant

	elseif ( currentScreen == "charcreate" ) then
		local classInfo = C_CharacterCreation.GetSelectedClass();
		if (classInfo) then
			class = classInfo.fileName;
		end
		local raceID = C_CharacterCreation.GetSelectedRace();
		race = select(2, C_CharacterCreation.GetNameForRace(raceID));
		faction = C_CharacterCreation.GetFactionForRace(raceID);
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
		C_CharacterCreation.SetCharCustomizeBackground(path);
	else
		SetCharSelectBackground(path);
	end

	UpdateGlueTag();
	PlayGlueAmbienceFromTag();

	ResetLighting(model);
	UpdateLighting(model);

	-- In 1.12, the Character Create screen shows fog but the Character Select screen doesn't.
	-- (CCharacterSelection::SetBackgroundModel() sets the lighing back to GenericLightingCallback)
	-- Showing fog on Character Select looks bad when the character is a ghost.
	if ( model ~= CharacterCreate ) then
		model:ClearFog();
	end
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

function HideUIPanel(self)
	-- Glue specific implementation of this function, doesn't need to leverage FrameXML data.
	self:Hide();
end

function IsKioskGlueEnabled()
	return Kiosk.IsEnabled() and not IsCompetitiveModeEnabled();
end

function GetDisplayedExpansionLogo(expansionLevel)
	local isTrial = expansionLevel == nil;
	if isTrial then
		return [[Interface\Glues\Common\Glues-WoW-FreeTrial]];
	elseif expansionLevel <= GetMinimumExpansionLevel() then
		local expansionInfo = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC);
		if expansionInfo then
			return expansionInfo.logo;
		end
	else
		local expansionInfo = GetExpansionDisplayInfo(expansionLevel);
		if expansionInfo then
			return expansionInfo.logo;
		end
	end
	
	return nil;
end

-- For Classic, most places should call "SetClassicLogo" instead.
function SetExpansionLogo(texture, expansionLevel)
	local logo = GetDisplayedExpansionLogo(expansionLevel);
	if logo then
		texture:SetTexture(logo);
		texture:Show();
	else
		texture:Hide();
	end
end

classicLogo = 'Interface\\Glues\\Common\\WOW_Classic-LogoHR';
classicLogoTexCoords = { 0.125, 0.875, 0.3125, 0.6875 };
function SetClassicLogo(texture)
	texture:SetTexture(classicLogo);
	texture:SetTexCoord(classicLogoTexCoords[1], classicLogoTexCoords[2], classicLogoTexCoords[3], classicLogoTexCoords[4]);
	texture:Show();
end

function UpgradeAccount()
	if not IsTrialAccount() and C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAMES_CATEGORY_ID) then
		StoreFrame_SetGamesCategory();
		ToggleStoreUI();
	else
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
		LoadURLIndex(2);
	end
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

function CheckSystemRequirements(includeSeenWarnings)
	local configWarnings = C_ConfigurationWarnings.GetConfigurationWarnings(includeSeenWarnings);
	for i, warning in ipairs(configWarnings) do
		local text = C_ConfigurationWarnings.GetConfigurationWarningString(warning);
		if text then
			GlueDialog_Queue("CONFIGURATION_WARNING", text, { configurationWarning = warning });
		end
	end
end

function GetScaledCursorPosition()
	local uiScale = GlueParent:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / uiScale, y / uiScale;
end

function GetScaledCursorDelta()
	local uiScale = GlueParent:GetEffectiveScale();
	local x, y = GetCursorDelta();
	return x / uiScale, y / uiScale;
end

function GMError(...)
	if ( IsGMClient() ) then
		error(...);
	end
end

function OnExcessiveErrors()
	-- Glue Implementation, no-op.
end

SecureMixin = Mixin;
CreateFromSecureMixins = CreateFromMixins;

-- =============================================================
-- Backwards Compatibility
-- =============================================================
function getglobal(var)
	return _G[var];
end

function setglobal(var, val)
	_G[var] = val;
end
