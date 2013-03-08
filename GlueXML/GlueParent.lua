GlueCreditsSoundKits = { };
GlueCreditsSoundKits[1] = "Menu-Credits01";
GlueCreditsSoundKits[2] = "Menu-Credits02";
GlueCreditsSoundKits[3] = "Menu-Credits03";
GlueCreditsSoundKits[4] = "Menu-Credits04";
GlueCreditsSoundKits[5] = "Menu-Credits05";


GlueScreenInfo = { };
GlueScreenInfo["login"]			= "AccountLogin";
GlueScreenInfo["charselect"]	= "CharacterSelect";
GlueScreenInfo["realmwizard"]	= "RealmWizard";
GlueScreenInfo["realmlist"]		= "RealmListUI";
GlueScreenInfo["charcreate"]	= "CharacterCreate";
GlueScreenInfo["patchdownload"]	= "PatchDownload";
GlueScreenInfo["trialconvert"]	= "TrialConvert";
GlueScreenInfo["movie"]			= "MovieFrame";
GlueScreenInfo["credits"]		= "CreditsFrame";
GlueScreenInfo["options"]		= "OptionsFrame";

CharModelFogInfo = { };
CharModelFogInfo["HUMAN"] = { r=0.8, g=0.65, b=0.73, far=222 };
CharModelFogInfo["ORC"] = { r=0.5, g=0.5, b=0.5, far=270 };
CharModelFogInfo["DWARF"] = { r=0.85, g=0.88, b=1.0, far=500 };
CharModelFogInfo["NIGHTELF"] = { r=0.25, g=0.22, b=0.55, far=611 };
CharModelFogInfo["TAUREN"] = { r=1.0, g=0.61, b=0.42, far=153 };
CharModelFogInfo["SCOURGE"] = { r=0, g=0.22, b=0.22, far=26 };
CharModelFogInfo["CHARACTERSELECT"] = { r=0.8, g=0.65, b=0.73, far=222 };

CharModelGlowInfo = { };
CharModelGlowInfo["WORGEN"] = 0.0;
CharModelGlowInfo["GOBLIN"] = 0.0;
CharModelGlowInfo["HUMAN"] = 0.15;
CharModelGlowInfo["DWARF"] = 0.15;
CharModelGlowInfo["CHARACTERSELECT"] = 0.3;

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
GlueAmbienceTracks["DARKPORTAL"] = "GlueScreenIntro";
GlueAmbienceTracks["DEATHKNIGHT"] = "AMB_GlueScreen_Deathknight";
GlueAmbienceTracks["CHARACTERSELECT"] = "GlueScreenIntro";
GlueAmbienceTracks["PANDAREN"] = "AMB_GlueScreen_Pandaren";
GlueAmbienceTracks["HORDE"] = "AMB_50_GlueScreen_HORDE";
GlueAmbienceTracks["ALLIANCE"] = "AMB_50_GlueScreen_ALLIANCE";
GlueAmbienceTracks["NEUTRAL"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";
GlueAmbienceTracks["PANDARENCHARACTERSELECT"] = "AMB_50_GlueScreen_PANDAREN_NEUTRAL";

-- indicies for adding lights ModelFFX:Add*Light
LIGHT_LIVE  = 0;
LIGHT_GHOST = 1;

-- Alpha animation stuff
FADEFRAMES = {};
CURRENT_GLUE_SCREEN = nil;
PENDING_GLUE_SCREEN = nil;
-- Time in seconds to fade
LOGIN_FADE_IN = 1.5;
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
	TRIAL = "Interface\\Glues\\Common\\Glues-WoW-StarterLogo",
	[1] = "Interface\\Glues\\Common\\Glues-WoW-ClassicLogo",
	[2] = "Interface\\Glues\\Common\\Glues-WoW-WotLKLogo",
	[3] = "Interface\\Glues\\Common\\Glues-WoW-CCLogo",
	[4] = "Interface\\Glues\\Common\\Glues-WoW-MPLogo",
	--When adding entries to here, make sure to update the zhTW and zhCN localization files.
};

--Music
EXPANSION_GLUE_MUSIC = {
	TRIAL = "GS_Cataclysm",
	[1] = "GS_Cataclysm",
	[2] = "GS_Cataclysm",
	[3] = "GS_Cataclysm",
	[4] = "MUS_50_HeartofPandaria_MainTitle",
}

--Backgrounds
EXPANSION_HIGH_RES_BG = {
	TRIAL = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[1] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[2] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[3] = "Interface\\Glues\\Models\\UI_MainMenu_Cataclysm\\UI_MainMenu_Cataclysm.m2",
	[4] = "Interface\\Glues\\Models\\UI_MainMenu_Pandaria\\UI_MainMenu_Pandaria.m2",
}

EXPANSION_LOW_RES_BG = {
	TRIAL =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[1] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[2] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[3] =  "Interface\\Glues\\Models\\UI_MainMenu_Cata_LowBandwidth\\UI_MainMenu_Cata_LowBandwidth.m2",
	[4] =  "Interface\\Glues\\Models\\UI_MainMenu_LowBandwidth\\UI_MainMenu_LowBandwidth.m2",
}

--Credits titles
CREDITS_TITLES = { --Note: These are off by 1 from the other expansion tables
	CREDITS_WOW_CLASSIC,
	CREDITS_WOW_BC,
	CREDITS_WOW_LK,
	CREDITS_WOW_CC,
	CREDITS_WOW_MOP,
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
			PlayGlueMusic(EXPANSION_GLUE_MUSIC[GetClientDisplayExpansionLevel()]);
			if (name == "login") then
				PlayGlueAmbience(GlueAmbienceTracks["DARKPORTAL"], 4.0);
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
	self:RegisterEvent("SET_GLUE_SCREEN");
	self:RegisterEvent("START_GLUE_MUSIC");
	self:RegisterEvent("DISCONNECTED_FROM_SERVER");
	self:RegisterEvent("GET_PREFERRED_REALM_INFO");
	self:RegisterEvent("SERVER_SPLIT_NOTICE");
	self:RegisterEvent("ACCOUNT_MESSAGES_AVAILABLE");
	self:RegisterEvent("ACCOUNT_MESSAGES_HEADERS_LOADED");
	self:RegisterEvent("ACCOUNT_MESSAGES_BODY_LOADED");
end

function GlueParent_OnEvent(event, arg1, arg2, arg3)
	if ( event == "FRAMES_LOADED" ) then
		LocalizeFrames();
	elseif ( event == "SET_GLUE_SCREEN" ) then
		GlueScreenExit(GetCurrentGlueScreenName(), arg1);
	elseif ( event == "START_GLUE_MUSIC" ) then
		PlayGlueMusic(EXPANSION_GLUE_MUSIC[GetClientDisplayExpansionLevel()]);
		PlayGlueAmbience(GlueAmbienceTracks["DARKPORTAL"], 4.0);
	elseif ( event == "DISCONNECTED_FROM_SERVER" ) then
		TokenEntry_Cancel(TokenEnterDialog);
		SetGlueScreen("login");
		if ( arg1 == 4 ) then
			GlueDialog_Show("PARENTAL_CONTROL");
		elseif ( arg1 == 5 ) then
			GlueDialog_Show("STREAMING_ERROR");
		else
			GlueDialog_Show("DISCONNECTED");
		end
		AddonList:Hide();
	elseif ( event == "GET_PREFERRED_REALM_INFO" ) then
		if( arg1 == 1) then
			SetPreferredInfo(1);
		else
			SetGlueScreen("realmwizard");
			PlayGlueAmbience(GlueAmbienceTracks["DARKPORTAL"], 4.0);
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

function SetLighting(model, race)
	--model:SetSequence(0);
	model:SetCamera(0);
	local fogInfo = CharModelFogInfo[race];
	if ( fogInfo ) then
		model:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b);
		model:SetFogNear(0);
		model:SetFogFar(fogInfo.far);
	else
		model:ClearFog();
    end

    local glowInfo = CharModelGlowInfo[race];
    if ( glowInfo ) then
        model:SetGlow(glowInfo);
    else
        model:SetGlow(0.3);
    end

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
	if ( ( model == CharacterSelect ) and ( string.find(model:GetModel(), 'lowres') == nil ) ) then
		SetLighting(model, nameupper)
	else
		SetLighting(model, "DEFAULT")
	end

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

function TriStateCheckbox_SetState(checked, checkButton)
	local checkedTexture = _G[checkButton:GetName().."CheckedTexture"];
	if ( not checkedTexture ) then
		message("Can't find checked texture");
	end
	if ( not checked or checked == 0 ) then
		-- nil or 0 means not checked
		checkButton:SetChecked(nil);
		checkButton.state = 0;
	elseif ( checked == 2 ) then
		-- 2 is a normal
		checkButton:SetChecked(1);
		checkedTexture:SetVertexColor(1, 1, 1);
		checkedTexture:SetDesaturated(0);
		checkButton.state = 2;
	else
		-- 1 is a gray check
		checkButton:SetChecked(1);
		checkedTexture:SetDesaturated(1);
		checkButton.state = 1;
	end
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

function SetLoginScreenModel(model)
	model:SetCamera(0);
	model:SetSequence(0);
	
	local expansionLevel = GetClientDisplayExpansionLevel();
	local lowResBG = EXPANSION_LOW_RES_BG[expansionLevel];
	local highResBG = EXPANSION_HIGH_RES_BG[expansionLevel];
	local background = GetLoginScreenBackground(highResBG, lowResBG);
							
	model:SetModel(background, 1);	
end
