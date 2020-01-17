BASE_SPLASH_SCREEN_VERSION = 18;
NEWEST_SPLASH_SCREEN_VERSION = 19;
SEASON_SPLASH_SCREEN_VERSION = 4;
PREVIOUS_SEASON_SPLASH_VERSION = 3;

local FACTION_OVERRIDES = {
	["Alliance"] = {
		questID = 56031,
	},
	["Horde"] = {
		questID = 56030,
	},
}

SPLASH_SCREENS = {
	["8_3_LEVEL"] = {
		id = NEWEST_SPLASH_SCREEN_VERSION, -- 8.3 Live
		expansion = LE_EXPANSION_BATTLE_FOR_AZEROTH,
		header = SPLASH_BASE_HEADER,
		label = SPLASH_BATTLEFORAZEROTH_8_3_0_LABEL,
		leftTex = "splash-830-topleft",
		rightTex = "splash-830-right",
		bottomTex = "splash-830-botleft",
		feature1Title = SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_TITLE,
		feature1Desc = SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_DESC,
		feature2Title = SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE2_TITLE,
		feature2Desc = SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE2_DESC,
		rightTitle = SPLASH_BATTLEFORAZEROTH_8_3_0_RIGHT_TITLE,
		rightDescSubText = SPLASH_BATTLEFORAZEROTH_8_3_0_RIGHT_DESC,
		cVar="splashScreenNormal",
		hideStartButton = true,
		minQuestLevel = 120,
		minDisplayLevel = 120,

		features = {
			[1] = { EnterFunc = function() end,
					LeaveFunc = function() end,
					},
			[2] = { EnterFunc = function() end,
					LeaveFunc = function() end,
					},
		},
	},
	["8_3_NEW_SEASON"] = {
		id = SEASON_SPLASH_SCREEN_VERSION, -- 8.3 New season rollout.
		expansion = LE_EXPANSION_BATTLE_FOR_AZEROTH,
		header = SPLASH_NEW_HEADER_SEASON,
		leftTex = "splash-8302-topleft",
		rightTex = "splash-8302-right",
		bottomTex = "splash-8302-botleft",
		feature1Title = SPLASH_BATTLEFORAZEROTH_8_3_0_2_FEATURE1_TITLE,
		feature1Desc = SPLASH_BATTLEFORAZEROTH_8_3_0_2_FEATURE1_DESC,
		feature2Title = SPLASH_BATTLEFORAZEROTH_8_3_0_2_FEATURE2_TITLE,
		feature2Desc = SPLASH_BATTLEFORAZEROTH_8_3_0_2_FEATURE2_DESC,
		rightTitle = SPLASH_BATTLEFORAZEROTH_8_3_0_2_RIGHT_TITLE,
		rightDescSubText = SPLASH_BATTLEFORAZEROTH_8_3_0_2_RIGHT_DESC,
		cVar="splashScreenSeason",
		hideStartButton = true,
		minQuestLevel = 120,
		minDisplayLevel = 120,

		features = {
			[1] = { EnterFunc = function() end,
					LeaveFunc = function() end,
					},
			[2] = { EnterFunc = function() end,
					LeaveFunc = function() end,
					},
		},
	},
};

BASE_SPLASH_TAG = nil;
CURRENT_SPLASH_TAG = "8_3_LEVEL";
SEASON_SPLASH_TAG = "8_3_NEW_SEASON"; -- This will be nil in patches that don't have a season change

-- For the case where we want to skip showing the first screen.
local function UpdateOtherSplashScreenCvar(tag)
	SetCVar(SPLASH_SCREENS[tag].cVar, SPLASH_SCREENS[tag].id);
end

local function GetSplashFrameTag(forceShow)
	local passesExpansionCheck = not SPLASH_SCREENS[CURRENT_SPLASH_TAG].expansion or GetExpansionLevel() >= SPLASH_SCREENS[CURRENT_SPLASH_TAG].expansion;

	if passesExpansionCheck and (not SPLASH_SCREENS[CURRENT_SPLASH_TAG].minDisplayLevel or UnitLevel("player") >= SPLASH_SCREENS[CURRENT_SPLASH_TAG].minDisplayLevel) then
		local lastScreenID = tonumber(GetCVar(SPLASH_SCREENS[CURRENT_SPLASH_TAG].cVar)) or 0;

		if SEASON_SPLASH_TAG == nil then
			if (forceShow) then
				lastScreenID = lastScreenID - 1;
			end

			if lastScreenID < SPLASH_SCREENS[CURRENT_SPLASH_TAG].id then
				return CURRENT_SPLASH_TAG;
			end
		else
			local seasonScreenID = tonumber(GetCVar(SPLASH_SCREENS[SEASON_SPLASH_TAG].cVar)) or 0;
			if (forceShow) then
				lastScreenID = lastScreenID - 1;
				seasonScreenID = seasonScreenID - 1;
			end

			--The case where a player has never viewed a what's new for seasons.
			if seasonScreenID < PREVIOUS_SEASON_SPLASH_VERSION then
				SetCVar(SPLASH_SCREENS[SEASON_SPLASH_TAG].cVar, PREVIOUS_SEASON_SPLASH_VERSION);
				seasonScreenID = PREVIOUS_SEASON_SPLASH_VERSION;
			end

			if seasonScreenID < C_MythicPlus.GetCurrentSeason() then
				UpdateOtherSplashScreenCvar(CURRENT_SPLASH_TAG);
				return SEASON_SPLASH_TAG;
			elseif lastScreenID < SPLASH_SCREENS[CURRENT_SPLASH_TAG].id then
				return CURRENT_SPLASH_TAG;
			end
		end
	else
		return BASE_SPLASH_TAG; -- Kept this for when we have an expansion. Won't be used until then though.
	end
end

function SplashFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");

	-- Splash frame should disable alerts until it completes its checks to determine shown state.
	AlertFrame:SetAlertsEnabled(false, "splashFrame");
end

local function ShouldShowStartButton( questID, tag )
	if (SPLASH_SCREENS[tag].hideStartButton) then
		return false;
	end
	return questID and not C_QuestLog.IsQuestFlaggedCompleted(questID) and (not SPLASH_SCREENS[tag].minQuestLevel or UnitLevel("player") >= SPLASH_SCREENS[tag].minQuestLevel);
end

local function ShouldEnableStartButton( questID )
	if( questID ) then
		local autoQuest = false;
		for i = 1, GetNumAutoQuestPopUps() do
			local id, popUpType = GetAutoQuestPopUp(i);
			if( id == questID and popUpType ) then
				autoQuest = true;
				break;
			end
		end
		return autoQuest or GetQuestLogIndexByID(questID) > 0;
	end

	return false;
end

local function CheckSplashScreenShow()
	local shouldForceCurrent = false;
	local tag = SplashFrame_GetShowTag(shouldForceCurrent);
	if tag then
		-- check if they've seen this screen already
		local lastScreenID = tonumber(GetCVar(SPLASH_SCREENS[tag].cVar)) or 0;
		if lastScreenID < SPLASH_SCREENS[tag].id then
			SplashFrame_Open(tag, shouldForceCurrent);
			SplashFrame.firstTimeViewed = true;
			SetCVar(SPLASH_SCREENS[tag].cVar, SPLASH_SCREENS[tag].id); -- update cVar value
		end
	end

	-- Once initial check performed and there was nothing to show, alerts can be re-enabled.
	if not SplashFrame:IsShown() then
		AlertFrame:SetAlertsEnabled(true, "splashFrame");
	end
end

local function ApplyFactionOverrides()
	local factionGroup = UnitFactionGroup("player");
	local override = FACTION_OVERRIDES[factionGroup];
	if override then
		for k, v in pairs(override) do
			SPLASH_SCREENS[CURRENT_SPLASH_TAG][k] = v;
		end
	end
end

function SplashFrame_GetShowTag(forceShow)
	if SplashFrameCanBeShown() and not IsCharacterNewlyBoosted() then
		return GetSplashFrameTag(forceShow);
	end

	return nil;
end

function SplashFrame_ShowCurrent()
	local shouldForceCurrent = true;
	tag = GetSplashFrameTag(shouldForceCurrent);
	SplashFrame_Open(tag, shouldForceCurrent);
end

function SplashFrame_OnEvent(self, event)
	if ( IsKioskModeEnabled() ) then
		return;
	end

	if( event == "QUEST_LOG_UPDATE" ) then
		local shouldForceCurrent = true;
		local tag = GetSplashFrameTag(shouldForceCurrent);
		if( self:IsShown() and tag )then
			SplashFrame_SetStartButtonDisplay( ShouldShowStartButton(SPLASH_SCREENS[tag].questID, tag) );
		end
	elseif( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
		self.playerEntered = true;
		ApplyFactionOverrides();
		C_MythicPlus.RequestMapInfo();
	elseif( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	end

	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" ) then
		if( self.playerEntered and self.varsLoaded ) then
			CheckSplashScreenShow();
		end
	end

	if( event == "CHALLENGE_MODE_MAPS_UPDATE" ) then
		if (self.playerEntered) then
			self:UnregisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
			CheckSplashScreenShow();
		end
	end
end

function SplashFrame_Display(tag, showStartButton)
	local frame = SplashFrame;
	frame.tag = tag;
	local screenInfo = SPLASH_SCREENS[tag];
	frame.LeftTexture:SetAtlas(screenInfo.leftTex, true);
	frame.RightTexture:SetAtlas(screenInfo.rightTex, true);
	frame.BottomTexture:SetAtlas(screenInfo.bottomTex);
	frame.Header:SetText(screenInfo.header);
	frame.Label:SetText(screenInfo.label);
	frame.Feature1.Title:SetText(screenInfo.feature1Title);
	frame.Feature1.Description:SetText(screenInfo.feature1Desc);
	frame.Feature2.Title:SetText(screenInfo.feature2Title);
	frame.Feature2.Description:SetText(screenInfo.feature2Desc);
	frame.RightTitle:SetText(screenInfo.rightTitle);
	frame.RightTitle:SetSize(310, 0);

	local fontSizeFound = false;
	local fonts = {
		"Game72Font",
		"Game60Font",
		"Game48Font",
		"Game46Font",
		"Game36Font",
		"Game32Font",
		"Game27Font",
		"Game24Font",
		"Game18Font",
	}

	local rightTitleMaxLines = screenInfo.rightTitleMaxLines or 1;
	frame.RightTitle:SetMaxLines(rightTitleMaxLines);

	for _, font in pairs(fonts) do
		frame.RightTitle:SetFontObject(font);

		if( not frame.RightTitle:IsTruncated() ) then
			fontSizeFound = true
			break;
		end
	end
	if( not fontSizeFound ) then
		frame.RightTitle:SetSize(310, 0);
	end

	SplashFrame_SetStartButtonDisplay(showStartButton);
	frame:Show();

	frame:RegisterEvent("QUEST_LOG_UPDATE");
end

function SplashFrame_SetStartButtonDisplay( showStartButton )
	local frame = SplashFrame;
	local tag = frame.tag;
	frame.RightDescription:SetText(SPLASH_SCREENS[tag].rightDesc);
	if ( showStartButton ) then
		frame.StartButton:Show();

		frame.RightDescriptionSubtext:ClearAllPoints();
		frame.RightDescriptionSubtext:SetPoint("TOP", frame.StartButton, "TOP", 0, 50);
		frame.RightDescriptionSubtext:SetWidth(300);
		local rightDescSubText = SPLASH_SCREENS[tag].rightDescSubText;
		frame.RightDescriptionSubtext:SetText(rightDescSubText);
		frame.RightDescriptionSubtext:Show();

		frame.RightTitle:ClearAllPoints();
		frame.RightTitle:SetPoint("TOP", frame.RightDescriptionSubtext, "TOP", 0, 85);

		frame.BottomCloseButton:Hide();
		if( ShouldEnableStartButton( SPLASH_SCREENS[tag].questID )) then
			frame.StartButton.Text:SetTextColor(1, 1, 1);
			frame.StartButton.Texture:SetDesaturated(false);
			frame.StartButton:Enable();
			frame:SetScript("OnUpdate", nil);
		else
			frame.StartButton.Text:SetTextColor(0.5, 0.5, 0.5);
			frame.StartButton.Texture:SetDesaturated(true);
			frame.StartButton:Disable();
		end
	else
		frame.StartButton:Hide();
		frame.RightDescription:SetWidth(234);
		frame.RightDescription:SetPoint("CENTER", 164, -100);
		frame.BottomCloseButton:Show();

		frame.RightTitle:ClearAllPoints();
		frame.RightTitle:SetPoint("CENTER", 164, -80);

		local rightDescSubText = SPLASH_SCREENS[tag].rightDescSubText;
		local rightDescSubTextPredicate = SPLASH_SCREENS[tag].rightDescSubTextPredicate;
		if rightDescSubText and rightDescSubText ~= "" and (not rightDescSubTextPredicate or rightDescSubTextPredicate()) then
			frame.RightDescriptionSubtext:SetText(rightDescSubText);
			frame.RightDescriptionSubtext:ClearAllPoints();
			frame.RightDescriptionSubtext:SetPoint("BOTTOM", frame.RightTitle, "BOTTOM", 0, -50);
			frame.RightDescriptionSubtext:SetWidth(234);

			frame.RightDescriptionSubtext:Show();
		else
			frame.RightDescriptionSubtext:Hide();
		end
	end
end

function SplashFrame_Open( tag, forceShow )
	tag = tag or GetSplashFrameTag(forceShow);
	if not tag then return end

	-- need an event for expansion becoming active
	if( not SplashFrame.initialized ) then
		SplashFrame.initialized = true;
	end

	if (SPLASH_SCREENS[tag].getQuestID) then
		SPLASH_SCREENS[tag].questID = SPLASH_SCREENS[tag].getQuestID();
	end

	SplashFrame_Display( tag, ShouldShowStartButton(SPLASH_SCREENS[tag].questID, tag) );

	-- hide some quest elements when splash frame is up
	ObjectiveTracker_Update();
	if( QuestFrame:IsShown() )then
		HideUIPanel(QuestFrame);
	end
end

local function OpenQuestDialog()
	local frame = SplashFrame;
	local questID = SPLASH_SCREENS[frame.tag].questID;
	if( questID ) then
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		ShowQuestOffer(GetQuestLogIndexByID(questID));
		AutoQuestPopupTracker_RemovePopUp(questID);

		local questLogIndex = GetQuestLogIndexByID(questID);
		AddQuestWatch(questLogIndex);
		SetSuperTrackedQuestID(questID);
	end
end

function SplashFrame_Close()
	local frame = SplashFrame;
	local tag = frame.tag;
	if( tag ) then
		local questID = SPLASH_SCREENS[tag].questID;
		local showQuestDialog = questID and ( (frame.StartButton:IsShown() and frame.StartButton:IsEnabled()) or
		(SPLASH_SCREENS[tag].hideStartButton and SplashFrame.firstTimeViewed and not C_QuestLog.IsQuestFlaggedCompleted(questID) and
			UnitLevel("player") >= (SPLASH_SCREENS[tag].minDisplayLevel)
			and ShouldEnableStartButton(questID)) );
		HideUIPanel(frame);

		if( showQuestDialog ) then
			OpenQuestDialog();
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
end

function SplashFrameStartButton_OnClick(self)
	HideParentPanel(self);
	OpenQuestDialog();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

--- Splash Feature Sections---

function SplashFeature_OnEnter(self)
	local frame = SplashFrame;
	SPLASH_SCREENS[frame.tag].features[self:GetID()].EnterFunc();
end

function SplashFeature_OnLeave(self)
	local frame = SplashFrame;
	SPLASH_SCREENS[frame.tag].features[self:GetID()].LeaveFunc();
end

function SplashFrame_OnShow(self)
	C_TalkingHead.SetConversationsDeferred(true);
	AlertFrame:SetAlertsEnabled(false, "splashFrame");
end

function SplashFrame_OnHide(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:SetScript("OnUpdate", nil);

	SplashFrame.firstTimeViewed = false;
	C_TalkingHead.SetConversationsDeferred(false);
	AlertFrame:SetAlertsEnabled(true, "splashFrame");

	ObjectiveTracker_Update();
end