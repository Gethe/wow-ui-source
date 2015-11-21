GlueCreditsSoundKits = { }; -- this is off by 1 with other "expansion" arrays
GlueCreditsSoundKits[1] = "Menu-Credits01";
GlueCreditsSoundKits[2] = "Menu-Credits02";
GlueCreditsSoundKits[3] = "Menu-Credits03";
GlueCreditsSoundKits[4] = "Menu-Credits04";
GlueCreditsSoundKits[5] = "Menu-Credits05";
GlueCreditsSoundKits[6] = "Menu-Credits06";
GlueCreditsSoundKits[7] = "Menu-Credits07";


GlueScreenInfo = { };
GlueScreenInfo["login"]			= "AccountLogin";
GlueScreenInfo["charselect"]	= "CharacterSelect";
GlueScreenInfo["kioskmodesplash"] = "KioskModeSplash";
GlueScreenInfo["realmwizard"]	= "RealmWizard";
GlueScreenInfo["realmlist"]		= "RealmListUI";
GlueScreenInfo["charcreate"]	= "CharacterCreate";
GlueScreenInfo["patchdownload"]	= "PatchDownload";
GlueScreenInfo["trialconvert"]	= "TrialConvert";
GlueScreenInfo["movie"]			= "MovieFrame";
GlueScreenInfo["credits"]		= "CreditsFrame";
GlueScreenInfo["options"]		= "OptionsFrame";

GlueAmbienceTracks = { };
GlueAmbienceTracks["HUMAN"] = "AMB_GlueScreen_Human";
GlueAmbienceTracks["ORC"] = "AMB_GlueScreen_Orc";
GlueAmbienceTracks["TROLL"] = "AMB_GlueScreen_Troll";
GlueAmbienceTracks["DWARF"] = "AMB_GlueScreen_Dwarf";
GlueAmbienceTracks["GNOME"] = "AMB_GlueScreen_Gnome";
GlueAmbienceTracks["TAUREN"] = "AMB_GlueScreen_Tauren";
GlueAmbienceTracks["SCOURGE"] = "AMB_GlueScreen_Undead";
GlueAmbienceTracks["NIGHTELF"] = "AMB_GlueScreen_NightElf";
GlueAmbienceTracks["DRAENEI"] = "AMB_GlueScreen_Draenei";
GlueAmbienceTracks["BLOODELF"] = "AMB_GlueScreen_BloodElf";
GlueAmbienceTracks["GOBLIN"] = "AMB_GlueScreen_Goblin";
GlueAmbienceTracks["WORGEN"] = "AMB_GlueScreen_Worgen";
GlueAmbienceTracks["DEATHKNIGHT"] = "AMB_GlueScreen_Deathknight";
GlueAmbienceTracks["CHARACTERSELECT"] = "GlueScreenIntro";
GlueAmbienceTracks["PANDAREN"] = "AMB_GlueScreen_Pandaren";
GlueAmbienceTracks["HORDE"] = "AMB_50_GlueScreen_HORDE";
GlueAmbienceTracks["ALLIANCE"] = "AMB_50_GlueScreen_ALLIANCE";
GlueAmbienceTracks["NEUTRAL"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";
GlueAmbienceTracks["PANDARENCHARACTERSELECT"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";
GlueAmbienceTracks["DEMONHUNTER"] = "AMB_GlueScreen_DemonHunter";

-- indicies for adding lights ModelFFX:Add*Light
LIGHT_LIVE  = 0;
LIGHT_GHOST = 1;

-- Alpha animation stuff
FADEFRAMES = {};
CURRENT_GLUE_SCREEN = nil;
PENDING_GLUE_SCREEN = nil;
-- Time in seconds to fade
LOGIN_FADE_IN = 0.75;
LOGIN_FADE_OUT = 0.5;
CHARACTER_SELECT_FADE_IN = 0.75;
RACE_SELECT_INFO_FADE_IN = .5;
RACE_SELECT_INFO_FADE_OUT = .5;

-- Realm Split info
SERVER_SPLIT_SHOW_DIALOG = false;
SERVER_SPLIT_CLIENT_STATE = -1;	--	-1 uninitialized; 0 - no choice; 1 - realm 1; 2 - realm 2
SERVER_SPLIT_STATE_PENDING = -1;	--	-1 uninitialized; 0 - no server split; 1 - server split (choice mode); 2 - server split (no choice mode)
SERVER_SPLIT_DATE = nil;

-- Account Messaging info
ACCOUNT_MSG_NUM_AVAILABLE = 0;
ACCOUNT_MSG_PRIORITY = 0;
ACCOUNT_MSG_HEADERS_LOADED = false;
ACCOUNT_MSG_BODY_LOADED = false;
ACCOUNT_MSG_CURRENT_INDEX = nil;

-- Gender Constants
SEX_NONE = 1;
SEX_MALE = 2;
SEX_FEMALE = 3;

--Logos
EXPANSION_LOGOS = {
	TRIAL = {texture="Interface\\Glues\\Common\\Glues-WoW-StarterLogo"},
	[1] = {texture="Interface\\Glues\\Common\\Glues-WoW-ClassicLogo"},
	[2] = {texture="Interface\\Glues\\Common\\Glues-WoW-WotLKLogo"},
	[3] = {texture="Interface\\Glues\\Common\\Glues-WoW-CCLogo"},
	[4] = {texture="Interface\\Glues\\Common\\Glues-WoW-MPLogo"},
	[5] = {texture="Interface\\Glues\\Common\\GLUES-WOW-WODLOGO"},
	-- logos after WoD should be atlas
	[6] = {atlas="Glues-WoW-LegionLogo"},
	--When adding entries to here, make sure to update the zhTW and zhCN localization files.
};

--Login Screen Ambience
EXPANSION_GLUE_AMBIENCE = {
	TRIAL = "GlueScreenIntro",
	VETERAN = "GlueScreenIntro",
	[1] = "GlueScreenIntro",
	[2] = "GlueScreenIntro",
	[3] = "GlueScreenIntro",
	[4] = "GlueScreenIntro",
	[5] = "AMB_GlueScreen_WarlordsofDraenor",
	[6] = "GlueScreenIntro", --FIXME
}

--Music
EXPANSION_GLUE_MUSIC = {
	TRIAL = "GS_Cataclysm",
	VETERAN = "GS_Cataclysm",
	[1] = "MUS_1.0_MainTitle_Original",
	[2] = "GS_Cataclysm",
	[3] = "GS_Cataclysm",
	[4] = "MUS_50_HeartofPandaria_MainTitle",
	[5] = "MUS_60_MainTitle",
	[6] = "MUS_70_MainTitle",
}

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	TRIAL = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	VETERAN = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Warlords.m2",
	[1] = "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[2] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[3] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[4] = "Interface\\Glues\\Models\\UI_MainMenu_Pandaria\\UI_MainMenu_Pandaria.m2",
	[5] = "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords.m2",
	[6] = "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",   -- FIXME
}

EXPANSION_LOW_RES_BG = {
	TRIAL =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	VETERAN =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Warlords_LowBandwidth.m2",
	[1] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",
	[2] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[3] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[4] =  "Interface\\Glues\\Models\\UI_MainMenu_LowBandwidth\\UI_MainMenu_LowBandwidth.m2",
	[5] =  "Interface\\Glues\\Models\\UI_MainMenu_Warlords\\UI_MainMenu_Warlords_LowBandwidth.m2",
	[6] =  "Interface\\Glues\\Models\\UI_MAINMENU\\UI_MainMenu.m2",   -- FIXME
}

--Credits titles
CREDITS_TITLES = { --Note: These are off by 1 from the other expansion tables
	CREDITS_WOW_CLASSIC,
	CREDITS_WOW_BC,
	CREDITS_WOW_LK,
	CREDITS_WOW_CC,
	CREDITS_WOW_MOP,
	CREDITS_WOW_WOD,
	CREDITS_WOW_7,   -- FIXME
}

-- replace the C functions with local lua versions
function getglobal(varr)
	return _G[varr];
end

function setglobal(varr,value)
	_G[varr] = value;
end


function SetGlueScreen(name)
	local newFrame;
	for index, value in pairs(GlueScreenInfo) do
		local frame = _G[value];
		if ( frame ) then
			frame:Hide();
			if ( index == name ) then
				newFrame = frame;
			end
		end
	end
	
	if ( newFrame ) then
		newFrame:Show();
		SetCurrentScreen(name);
		SetCurrentGlueScreenName(name);
		if ( name == "credits" ) then
			PlayCreditsMusic( GlueCreditsSoundKits[CreditsFrame.creditsType] );
			StopGlueAmbience();
		elseif ( name ~= "movie" ) then
			local displayedExpansionLevel = GetClientDisplayExpansionLevel();
			PlayGlueMusic(EXPANSION_GLUE_MUSIC[displayedExpansionLevel]);
			if (name == "login") then
				PlayGlueAmbience(EXPANSION_GLUE_AMBIENCE[displayedExpansionLevel], 4.0);
			end
		end
	end
end

function SetCurrentGlueScreenName(name)
	CURRENT_GLUE_SCREEN = name;
end

function GetCurrentGlueScreenName()
	return CURRENT_GLUE_SCREEN;
end

function SetPendingGlueScreenName(name)
	PENDING_GLUE_SCREEN = name;
end

function GetPendingGlueScreenName()
	return PENDING_GLUE_SCREEN;
end

function GlueParent_OnDisplaySizeChanged(self)
	local width = GetScreenWidth();
	local height = GetScreenHeight();

	local minAspect = 5 / 4;
	local maxAspect = 16 / 9;
	
	if ( width / height > maxAspect ) then
		local maxWidth = height * maxAspect;
		local barWidth = ( width - maxWidth ) / 2;
		self:SetScale(1);
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", barWidth, 0); 
		self:SetPoint("BOTTOMRIGHT", -barWidth, 0);
	elseif ( width / height < minAspect ) then
		local maxHeight = width / minAspect;
		local scale = (width / height) / minAspect;
		local barHeight = ( height - maxHeight ) / (2 * scale);
		self:SetScale(maxHeight/height);
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", 0, -barHeight);
		self:SetPoint("BOTTOMRIGHT", 0, barHeight);
	else
		self:SetScale(1);
		self:SetAllPoints();
	end
end

function GlueParent_OnLoad(self)
	
	GlueParent_OnDisplaySizeChanged(self);

	self:RegisterEvent("FRAMES_LOADED");
	self:RegisterEvent("SET_GLUE_SCREEN");
	self:RegisterEvent("START_GLUE_MUSIC");
	self:RegisterEvent("DISCONNECTED_FROM_SERVER");
	self:RegisterEvent("GET_PREFERRED_REALM_INFO");
	self:RegisterEvent("SERVER_SPLIT_NOTICE");
	self:RegisterEvent("ACCOUNT_MESSAGES_AVAILABLE");
	self:RegisterEvent("ACCOUNT_MESSAGES_HEADERS_LOADED");
	self:RegisterEvent("ACCOUNT_MESSAGES_BODY_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	-- TODO: actually rename GlueParent to UIParent
	UIParent = self;
end

function GlueParent_OnEvent(event, arg1, arg2, arg3)
	if ( event == "FRAMES_LOADED" ) then
		LocalizeFrames();
	elseif ( event == "SET_GLUE_SCREEN" ) then
		GlueScreenExit(GetCurrentGlueScreenName(), arg1);
	elseif ( event == "START_GLUE_MUSIC" ) then
		local displayedExpansionLevel = GetClientDisplayExpansionLevel();
		PlayGlueMusic(EXPANSION_GLUE_MUSIC[displayedExpansionLevel]);
		PlayGlueAmbience(EXPANSION_GLUE_AMBIENCE[displayedExpansionLevel], 4.0);
	elseif ( event == "DISCONNECTED_FROM_SERVER" ) then
		TokenEntry_Cancel(TokenEnterDialog);
		SetGlueScreen("login");
		GlueDialog_Show(arg1, arg2);
		AddonList:Hide();
	elseif ( event == "GET_PREFERRED_REALM_INFO" ) then
		if( arg1 == 1) then
			SetPreferredInfo(1);
		else
			SetGlueScreen("realmwizard");
			PlayGlueAmbience(EXPANSION_GLUE_AMBIENCE[GetClientDisplayExpansionLevel()], 4.0);
		end
	elseif ( event == "SERVER_SPLIT_NOTICE" ) then
		CharacterSelectRealmSplitButton:Show();
		if ( SERVER_SPLIT_STATE_PENDING == -1 and arg1 == 0 and arg2 == 1 ) then
			SERVER_SPLIT_SHOW_DIALOG = true;
		end
		SERVER_SPLIT_CLIENT_STATE = arg1;
		SERVER_SPLIT_STATE_PENDING = arg2;
		SERVER_SPLIT_DATE = arg3;
	elseif ( event == "ACCOUNT_MESSAGES_AVAILABLE" ) then
--		ACCOUNT_MSG_NUM_AVAILABLE = arg1;
		ACCOUNT_MSG_HEADERS_LOADED = false;
		ACCOUNT_MSG_BODY_LOADED = false;
		ACCOUNT_MSG_CURRENT_INDEX = nil;
		AccountMsg_LoadHeaders();
	elseif ( event == "ACCOUNT_MESSAGES_HEADERS_LOADED" ) then
		ACCOUNT_MSG_HEADERS_LOADED = true;
		ACCOUNT_MSG_NUM_AVAILABLE = AccountMsg_GetNumUnreadMsgs();
		ACCOUNT_MSG_CURRENT_INDEX = AccountMsg_GetIndexNextUnreadMsg();
		if ( ACCOUNT_MSG_NUM_AVAILABLE > 0 ) then
			AccountMsg_LoadBody( ACCOUNT_MSG_CURRENT_INDEX );
		end
	elseif ( event == "ACCOUNT_MESSAGES_BODY_LOADED" ) then
		ACCOUNT_MSG_BODY_LOADED = true;
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		GlueParent_OnDisplaySizeChanged(GlueParent);
	end
end

-- Glue screen animation handling
function GlueScreenExit(currentFrame, pendingFrame)
	if ( currentFrame == "login" and pendingFrame == "charselect" ) then
		GlueFrameFadeOut(AccountLoginUI, LOGIN_FADE_OUT, GoToPendingGlueScreen);
		SetPendingGlueScreenName(pendingFrame);
	else
		SetGlueScreen(pendingFrame);
	end
end

function GoToPendingGlueScreen()
	SetGlueScreen(GetPendingGlueScreenName());
end

-- Generic fade function
function GlueFrameFade(frame, timeToFade, mode, finishedFunction)
	if ( frame ) then
		frame.fadeTimer = 0;
		frame.timeToFade = timeToFade;
		frame.mode = mode;
		-- finishedFunction is an optional function that is called when the animation is complete
		if ( finishedFunction ) then
			frame.finishedFunction = finishedFunction;
		end
		tinsert(FADEFRAMES, frame);
	end
end

-- Fade in function
function GlueFrameFadeIn(frame, timeToFade, finishedFunction)
	GlueFrameFade(frame, timeToFade, "IN", finishedFunction);
end

-- Fade out function
function GlueFrameFadeOut(frame, timeToFade, finishedFunction)
	GlueFrameFade(frame, timeToFade, "OUT", finishedFunction);
end

-- Function that actually performs the alpha change
function GlueFrameFadeUpdate(elapsed)
	local index = 1;
	while FADEFRAMES[index] do
		local frame = FADEFRAMES[index];
		frame.fadeTimer = frame.fadeTimer + elapsed;
		if ( frame.fadeTimer < frame.timeToFade ) then
			if ( frame.mode == "IN" ) then
				frame:SetAlpha(frame.fadeTimer / frame.timeToFade);
			elseif ( frame.mode == "OUT" ) then
				frame:SetAlpha((frame.timeToFade - frame.fadeTimer) / frame.timeToFade);
			end
		else
			if ( frame.mode == "IN" ) then
				frame:SetAlpha(1.0);
			elseif ( frame.mode == "OUT" ) then
				frame:SetAlpha(0);
			end
			GlueFrameFadeRemoveFrame(frame);
			if ( frame.finishedFunction ) then
				frame.finishedFunction();
				frame.finishedFunction = nil;
			end
		end
		index = index + 1;
	end
end

function GlueFrameRemoveFrame(frame, list)
	local index = 1;
	while list[index] do
		if ( frame == list[index] ) then
			tremove(list, index);
		end
		index = index + 1;
	end
end

function GlueFrameFadeRemoveFrame(frame)
	GlueFrameRemoveFrame(frame, FADEFRAMES);
end

function ResetLighting(model)
	--model:SetSequence(0);
	model:SetCamera(0);
	model:ClearFog();
	model:SetGlow(0.3);

    model:ResetLights();
end

-- Function to get the background tag from a full path ( '..\UI_tagName.m2' )
function GetBackgroundModelTag(path)
	local pathUpper = strupper(path);
	local matchStart;
	local matchEnd;
	local tag;
	matchStart, matchEnd, tag = string.find(pathUpper, 'UI_(%a+).M2');
	if ( not tag ) then
		tag = "CHARACTERSELECT"; -- default
	end
	return tag;
end

-- Function to set the background model for character select and create screens
function SetBackgroundModel(model, path)
	local nameupper = GetBackgroundModelTag(path);
	if ( model == CharacterCreate ) then
		SetCharCustomizeBackground(path);
	else
		SetCharSelectBackground(path);
	end
	if ( GlueAmbienceTracks[nameupper] ) then
		PlayGlueAmbience(GlueAmbienceTracks[nameupper], 4.0);
	end
	ResetLighting(model);

	return nameupper;
end

function SecondsToTime(seconds, noSeconds)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = floor(seconds);
	if ( seconds >= 86400  ) then
		tempTime = floor(seconds / 86400);
		time = tempTime.." "..DAYS_ABBR.." ";
		seconds = mod(seconds, 86400);
		count = count + 1;
	end
	if ( seconds >= 3600  ) then
		tempTime = floor(seconds / 3600);
		time = time..tempTime.." "..HOURS_ABBR.." ";
		seconds = mod(seconds, 3600);
		count = count + 1;
	end
	if ( count < 2 and seconds >= 60  ) then
		tempTime = floor(seconds / 60);
		time = time..tempTime.." "..MINUTES_ABBR.." ";
		seconds = mod(seconds, 60);
		count = count + 1;
	end
	if ( count < 2 and seconds > 0 and not noSeconds ) then
		seconds = format("%d", seconds);
		time = time..seconds.." "..SECONDS_ABBR.." ";
	end
	return time;
end

function MinutesToTime(mins, hideDays)
	local time = "";
	local count = 0;
	local tempTime;
	-- only show days if hideDays is false
	if ( mins > 1440 and not hideDays ) then
		tempTime = floor(mins / 1440);
		time = tempTime..TIME_UNIT_DELIMITER..DAYS_ABBR..TIME_UNIT_DELIMITER;
		mins = mod(mins, 1440);
		count = count + 1;
	end
	if ( mins > 60  ) then
		tempTime = floor(mins / 60);
		time = time..tempTime..TIME_UNIT_DELIMITER..HOURS_ABBR..TIME_UNIT_DELIMITER;
		mins = mod(mins, 60);
		count = count + 1;
	end
	if ( count < 2 ) then
		tempTime = mins;
		time = time..tempTime..TIME_UNIT_DELIMITER..MINUTES_ABBR..TIME_UNIT_DELIMITER;
		count = count + 1;
	end
	return time;
end

function SetStateRequestInfo( choice )
	if ( SERVER_SPLIT_CLIENT_STATE ~= choice ) then
		SERVER_SPLIT_CLIENT_STATE = choice;
		SetRealmSplitState(choice);
		RealmSplit_SetChoiceText();
--		RequestRealmSplitInfo();
	end
end

function UpgradeAccount()
	PlaySound("gsLoginNewAccount");
	LoadURLIndex(2);
end

function ReactivateAccount()
	PlaySound("gsLoginNewAccount");
	LoadURLIndex(22);
end

function SetLoginScreenModel(model)
	model:SetCamera(0);
	model:SetSequence(0);
	
	local expansionLevel = GetClientDisplayExpansionLevel();
	local lowResBG = EXPANSION_LOW_RES_BG[expansionLevel];
	local highResBG = EXPANSION_HIGH_RES_BG[expansionLevel];
	local background = GetLoginScreenBackground(highResBG, lowResBG);
							
	model:SetModel(background, true);	
end

function InGlue()
	return true;
end

function SecureCapsuleGet(name)
	return _G[name];
end

function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
end

function SetExpansionLogo(texture, expansionLevel)
	if ( EXPANSION_LOGOS[expansionLevel].texture ) then
		texture:SetTexture(EXPANSION_LOGOS[expansionLevel].texture);
	else
		texture:SetAtlas(EXPANSION_LOGOS[expansionLevel].atlas);
	end
end