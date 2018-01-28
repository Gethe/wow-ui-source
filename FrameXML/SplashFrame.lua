LEGION_POSTPATCH_QUESTS = { Alliance = { 40519, 44663 }, Horde = { 43926, 44663 }};

BASE_SPLASH_SCREEN_VERSION = 7;
NEWEST_SPLASH_SCREEN_VERSION = 12;

local function GetLegionQuestID()
	local faction = UnitFactionGroup("player");

	local startIndex = 1;
	if (select(2, UnitClass("player")) == "DEMONHUNTER") then
		startIndex = 2;
	end

	local tbl = LEGION_POSTPATCH_QUESTS[faction];

	local questID = nil;

	if (tbl) then
		for i = startIndex, #tbl do
			if (not IsQuestFlaggedCompleted(tbl[i])) then
				questID = tbl[i];
				break;
			end
		end
	end

	return questID;
end

SPLASH_SCREENS = {
	["LEGION_BASE"] = {	id = BASE_SPLASH_SCREEN_VERSION, -- Legion (7.0) Base
						expansion = LE_EXPANSION_LEGION,
						questID = nil,
						getQuestID = GetLegionQuestID,
						leftTex = "splash-705-topleft",
						rightTex = "splash-705-right",
						bottomTex = "splash-705-botleft",
						header = SPLASH_BASE_HEADER,
						label = SPLASH_LEGION_BOX_LABEL,
						feature1Title = SPLASH_LEGION_BOX_FEATURE1_TITLE,
						feature1Desc = SPLASH_LEGION_BOX_FEATURE1_DESC,
						feature2Title = SPLASH_LEGION_BOX_FEATURE2_TITLE,
						feature2Desc = SPLASH_LEGION_BOX_FEATURE2_DESC,
						rightTitle = SPLASH_LEGION_BOX_RIGHT_TITLE,
						rightDesc = SPLASH_LEGION_BOX_RIGHT_DESC,
						cVar="splashScreenNormal",
						hideStartButton = false,
						minQuestLevel = 98,
						features = {
								[1] = { EnterFunc = function() end,
								        LeaveFunc = function() end,
								        },
						        [2] = { EnterFunc = function() end,
								        LeaveFunc = function() end,
								        },
						},
	},
	["LEGION_CURRENT"] = {	id = NEWEST_SPLASH_SCREEN_VERSION, -- 7.3.5
					questID = nil,
					getQuestID = function()
						return nil;
					end,
					leftTex = "splash-735-topleft",
					rightTex = "splash-735-right",
					bottomTex = "splash-735-botleft",
					header = SPLASH_BASE_HEADER,
					label = SPLASH_LEGION_NEW_7_3_5_LABEL,
					feature1Title = SPLASH_LEGION_NEW_7_3_5_FEATURE1_TITLE,
					feature1Desc = SPLASH_LEGION_NEW_7_3_5_FEATURE1_DESC,
					feature2Title = SPLASH_LEGION_NEW_7_3_5_FEATURE2_TITLE,
					feature2Desc = SPLASH_LEGION_NEW_7_3_5_FEATURE2_DESC,
					rightTitle = SPLASH_LEGION_NEW_7_3_5_RIGHT_TITLE,
					rightDesc = SPLASH_LEGION_NEW_7_3_5_RIGHT_DESC,
					rightDescSubText = SPLASH_OPENS_SOON,
					rightDescSubTextPredicate = function() return not IsSplashFramePrimaryFeatureUnlocked() end,
					rightTitleMaxLines = 1,
					cVar="splashScreenNormal",
					hideStartButton = true,
					minDisplayLevel = 101,
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

BASE_SPLASH_TAG = "LEGION_BASE";
CURRENT_SPLASH_TAG = "LEGION_CURRENT";

local function GetSplashFrameTag()
	if (not SPLASH_SCREENS[CURRENT_SPLASH_TAG].minDisplayLevel or UnitLevel("player") >= SPLASH_SCREENS[CURRENT_SPLASH_TAG].minDisplayLevel) then
		return CURRENT_SPLASH_TAG;
	else
		return BASE_SPLASH_TAG;
	end
	return;
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
	return SplashFrame.firstTimeViewed and questID and not IsQuestFlaggedCompleted(questID) and (not SPLASH_SCREENS[tag].minQuestLevel or UnitLevel("player") >= SPLASH_SCREENS[tag].minQuestLevel);
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
	if SplashFrameCanBeShown() and not IsCharacterNewlyBoosted() then
		local tag = GetSplashFrameTag();
		if tag then
			-- check if they've seen this screen already
			local lastScreenID = tonumber(GetCVar(SPLASH_SCREENS[tag].cVar)) or 0;
			if lastScreenID < SPLASH_SCREENS[tag].id then
				SplashFrame_Open(tag);
				SplashFrame.firstTimeViewed = true;
				SetCVar(SPLASH_SCREENS[tag].cVar, SPLASH_SCREENS[tag].id); -- update cVar value
			end
		end
	end

	-- Once initial check performed and there was nothing to show, alerts can be re-enabled.
	if not SplashFrame:IsShown() then
		AlertFrame:SetAlertsEnabled(true, "splashFrame");
	end
end

function SplashFrame_OnEvent(self, event)
	if ( IsKioskModeEnabled() ) then
		return;
	end

	if( event == "QUEST_LOG_UPDATE" ) then
		local tag = GetSplashFrameTag();
		if( self:IsShown() and tag )then
			SplashFrame_SetStartButtonDisplay( ShouldShowStartButton(SPLASH_SCREENS[tag].questID, tag) );
		end
	elseif( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self.playerEntered = true;
	elseif( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	end

	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" ) then
		if( self.playerEntered and self.varsLoaded ) then
			CheckSplashScreenShow();
		end
	end
end

function SplashFrame_Display(tag, showStartButton)
	local frame = SplashFrame;
	frame.tag = tag;
	local screenInfo = SPLASH_SCREENS[tag];
	frame.LeftTexture:SetAtlas(screenInfo.leftTex);
	frame.RightTexture:SetAtlas(screenInfo.rightTex);
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
		frame.RightDescription:SetWidth(300);
		frame.RightDescription:SetPoint("BOTTOM", 164, 183);
		frame.RightDescriptionSubtext:Hide();
		frame.BottomCloseButton:Hide();
		if( ShouldEnableStartButton( SPLASH_SCREENS[tag].questID ) ) then
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
		frame.RightDescription:SetPoint("BOTTOM", 164, 133);
		frame.BottomCloseButton:Show();

		local rightDescSubText = SPLASH_SCREENS[tag].rightDescSubText;
		local rightDescSubTextPredicate = SPLASH_SCREENS[tag].rightDescSubTextPredicate;
		if rightDescSubText and rightDescSubText ~= "" and (not rightDescSubTextPredicate or rightDescSubTextPredicate()) then
			frame.RightDescriptionSubtext:SetText(rightDescSubText);
			frame.RightDescriptionSubtext:Show();
		else
			frame.RightDescriptionSubtext:Hide();
		end
	end
end

function SplashFrame_Open( tag )
	tag = tag or GetSplashFrameTag();
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
		local showQuestDialog = questID and
								( (frame.StartButton:IsShown() and frame.StartButton:IsEnabled()) or
								  (SPLASH_SCREENS[tag].hideStartButton and SplashFrame.firstTimeViewed and not IsQuestFlaggedCompleted(questID) and
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