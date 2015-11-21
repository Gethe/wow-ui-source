-- The ids will be used to track whether character has seen a splash screen. Have to assign unique ones to each splash screen in each category (normal and boost)
PREPATCH_QUESTS = { Alliance = {id=36498 , text=SPLASH_BOOST_RIGHT_DESC_ALLIANCE}
					, Horde = {id=36499 , text=SPLASH_BOOST_RIGHT_DESC_HORDE}
				};

POSTPATCH_QUEST = 34398;

SPLASH_SCREENS = {
	["BASE"] =	{	id = 1,
					questID = nil,
					leftTex = "splash-600-topleft",
					rightTex = "splash-600-right",
					bottomTex = "splash-600-botleft",
					header = SPLASH_BASE_HEADER,
					label = SPLASH_BASE_LABEL,
					feature1Title = SPLASH_BASE_FEATURE1_TITLE,
					feature1Desc = SPLASH_BASE_FEATURE1_DESC,
					feature2Title = SPLASH_BASE_FEATURE2_TITLE,
					feature2Desc = SPLASH_BASE_FEATURE2_DESC,
					rightTitle = SPLASH_BASE_RIGHT_TITLE,
					rightDesc = SPLASH_BASE_RIGHT_DESC,
					cVar="splashScreenNormal",
					hideStartButton = false;
					features = {
						[1] = { EnterFunc = function()
									MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, COLLECTIONS_MICRO_BUTTON_SPEC_TUTORIAL);
									MicroButtonPulse(CollectionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CollectionsMicroButton);
								end,
								},
						[2] = { EnterFunc = function()
									LFDMicroButtonAlert:Show();
									MicroButtonPulse(LFDMicroButton);
								end,
								LeaveFunc = function()
									LFDMicroButtonAlert:Hide();
									MicroButtonPulseStop(LFDMicroButton);
								end,
								},
					},
				},
	["BASE_90"] =	{	id = 1,
					questID = nil,	-- questID is set in SplashFrame_OnOpen
					leftTex = "splash-600-topleft",
					rightTex = "splash-boost-right",
					bottomTex = "splash-600-botleft",
					header = SPLASH_BASE_HEADER,
					label = SPLASH_BASE_LABEL,
					feature1Title = SPLASH_BASE_FEATURE1_TITLE,
					feature1Desc = SPLASH_BASE_FEATURE1_DESC,
					feature2Title = SPLASH_BASE_FEATURE2_TITLE,
					feature2Desc = SPLASH_BASE_FEATURE2_DESC,
					rightTitle = SPLASH_BASE_90_RIGHT_TITLE,
					rightDesc = SPLASH_BASE_90_RIGHT_DESC,
					cVar="splashScreenNormal",
					hideStartButton = false;
					features = {
						[1] = { EnterFunc = function() 
									MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, COLLECTIONS_MICRO_BUTTON_SPEC_TUTORIAL);
									MicroButtonPulse(CollectionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CollectionsMicroButton);
								end,
								},
						[2] = { EnterFunc = function()
									LFDMicroButtonAlert:Show();
									MicroButtonPulse(LFDMicroButton);
								end,
								LeaveFunc = function()
									LFDMicroButtonAlert:Hide();
									MicroButtonPulseStop(LFDMicroButton);
								end,
								},
					},
				},
				-- 2 : 6.0
	["NEW"] =	{	id = 4, -- 6.2
					expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
					questID = nil,			
					leftTex = "splash-620-topleft",
					rightTex = "splash-620-right",
					bottomTex = "splash-620-botleft",
					header = SPLASH_NEW_HEADER,
					label = SPLASH_NEW_6_2_LABEL,
					feature1Title = SPLASH_NEW_6_2_FEATURE1_TITLE,
					feature1Desc = SPLASH_NEW_6_2_FEATURE1_DESC,
					feature2Title = SPLASH_NEW_6_2_FEATURE2_TITLE,
					feature2Desc = SPLASH_NEW_6_2_FEATURE2_DESC,
					rightTitle = SPLASH_NEW_6_2_RIGHT_TITLE,
					rightDesc = SPLASH_NEW_6_2_RIGHT_DESC,
					cVar="splashScreenNormal",
					hideStartButton = true;
					features = {
						[1] = { EnterFunc = function() end,
								LeaveFunc = function() end,
								},
						[2] = { EnterFunc = function() end,
								LeaveFunc = function() end,
								},
					},
				},
	["BOOST"] =	{	id = 1,
					questID = nil, -- questID is set in SplashFrame_OnLoad
					leftTex = "splash-boost-topleft",
					rightTex = "splash-boost-right",
					bottomTex = "splash-boost-botleft",
					header = SPLASH_BOOST_HEADER,
					label = SPLASH_BOOST_LABEL,
					feature1Title = SPLASH_BOOST_FEATURE1_TITLE,
					feature1Desc = SPLASH_BOOST_FEATURE1_DESC,
					feature2Title = SPLASH_BOOST_FEATURE2_TITLE,
					feature2Desc = SPLASH_BOOST_FEATURE2_DESC,
					rightTitle = SPLASH_BOOST_RIGHT_TITLE,
					rightDesc = SPLASH_BOOST_RIGHT_DESC,
					cVar="splashScreenBoost",
					hideStartButton = false;
					features = {
						[1] = { EnterFunc = function() 
									MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, COLLECTIONS_MICRO_BUTTON_SPEC_TUTORIAL);
									MicroButtonPulse(CollectionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CollectionsMicroButton);
								end,
								},
						[2] = { EnterFunc = function() end,
								LeaveFunc = function() end,
								},
					},
				},
	["BOOST2"] ={	id = 2,
					expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
					questID = POSTPATCH_QUEST,
					leftTex = "splash-boost-topleft",
					rightTex = "splash-boost-right",
					bottomTex = "splash-boost-botleft",
					header = SPLASH_BOOST_HEADER,
					label = SPLASH_BOOST_LABEL,
					feature1Title = SPLASH_BOOST_FEATURE1_TITLE,
					feature1Desc = SPLASH_BOOST_FEATURE1_DESC,
					feature2Title = SPLASH_BOOST_FEATURE2_TITLE,
					feature2Desc = SPLASH_BOOST2_FEATURE2_DESC,
					rightTitle = SPLASH_BOOST_RIGHT_TITLE,
					rightDesc = SPLASH_BOOST2_RIGHT_DESC,
					cVar="splashScreenBoost",
					hideStartButton = false;
					features = {
							[1] = { EnterFunc = function() 
									MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, COLLECTIONS_MICRO_BUTTON_SPEC_TUTORIAL);
									MicroButtonPulse(CollectionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CollectionsMicroButton);
								end,
								},
						[2] = { EnterFunc = function() end,
								LeaveFunc = function() end,
								},
					},
				},				
};

local function GetSplashFrameTag()
	local tag;
	local expansionLevel = GetExpansionLevel();
	if ( IsCharacterNewlyBoosted() ) then
		if ( expansionLevel >= SPLASH_SCREENS["BOOST2"].expansion ) then		
			tag = "BOOST2";
		else
			tag = "BOOST";
		end
	else
		if ( expansionLevel >= SPLASH_SCREENS["NEW"].expansion) then
			tag = "NEW";
		else
			local playerLevel = UnitLevel("player");
			tag = (playerLevel >= 90 and "BASE_90") or "BASE";
		end
	end
	return tag;
end

function SplashFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
end

local function ShouldShowStartButton( questID )
	if (SPLASH_SCREENS["NEW"].hideStartButton) then
		return false;
	end
	return SplashFrame.firstTimeViewed and questID and not IsQuestFlaggedCompleted(questID) and UnitLevel("player") >= 90;
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

function SplashFrame_OnEvent(self, event)
	if ( IsKioskModeEnabled() ) then
		return;
	end

	if( event == "QUEST_LOG_UPDATE" ) then
		local tag = GetSplashFrameTag();
		if( self:IsShown() and tag )then
			SplashFrame_SetStartButtonDisplay( ShouldShowStartButton(SPLASH_SCREENS[tag].questID) );
		end
	elseif( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self.playerEntered = true;
	elseif( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	elseif( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		self.zoneEntered = true;
	end
	
	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
		if( self.playerEntered and self.varsLoaded and self.zoneEntered) then
			if ( not SplashFrameCanBeShown() ) then
				return;
			end
			
			local tag = GetSplashFrameTag();
			-- check if they've seen this screen already
			local lastScreenID = tonumber(GetCVar(SPLASH_SCREENS[tag].cVar)) or 0;
			if( lastScreenID >= SPLASH_SCREENS[tag].id ) then
				return;
			end	

			SplashFrame_Open(tag);
			SplashFrame.firstTimeViewed = true;
			SetCVar(SPLASH_SCREENS[tag].cVar, SPLASH_SCREENS[tag].id); -- update cVar value;
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
	frame.RightTitle:SetSize( 400, 32 );	
	frame.RightTitle:SetWordWrap( false );

	local fontSizeFound = false;
	local fonts = {
		"Game72Font",
		"Game60Font",
		"Game48Font",
		"Game36Font",
		"Game32Font",
		"Game27Font",
		"Game24Font",
		"Game18Font",
	}
	
	for _, font in pairs(fonts) do
		frame.RightTitle:SetFontObject(font);
		if( frame.RightTitle:GetStringWidth() < 310 ) then
			fontSizeFound = true
			break;
		end
	end
	if( not fontSizeFound ) then
		frame.RightTitle:SetSize( 300, 40 );
		frame.RightTitle:SetWordWrap( true );
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
	end
end

function SplashFrame_Open( tag )
	if( not tag ) then
		tag = GetSplashFrameTag();
	end
	
	-- need an event for expansion becoming active
	if( not SplashFrame.initialized ) then
		SplashFrame.initialized = true;
		local faction = UnitFactionGroup("player");
		local questData = PREPATCH_QUESTS[faction];
		if( questData ) then
			SPLASH_SCREENS["BASE_90"].questID = questData.id;
			SPLASH_SCREENS["BOOST"].questID = questData.id;
			SPLASH_SCREENS["BOOST"].rightDesc = questData.text;
		end
	end
	
	if( tag == "NEW" ) then
		local displayQuest = UnitLevel("player") >= 90;
		SPLASH_SCREENS["NEW"].questID = displayQuest and POSTPATCH_QUEST;
		if( not SPLASH_SCREENS["NEW"].hideStartButton ) then
			SPLASH_SCREENS["NEW"].rightDesc = displayQuest and SPLASH_NEW_90_RIGHT_DESC or SPLASH_NEW_RIGHT_DESC;
		end
	end
	
	SplashFrame_Display( tag, ShouldShowStartButton(SPLASH_SCREENS[tag].questID) );
	
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
								  (SPLASH_SCREENS[tag].hideStartButton and SplashFrame.firstTimeViewed and not IsQuestFlaggedCompleted(questID) and UnitLevel("player") >= 90
										and ShouldEnableStartButton(questID)) );
		HideUIPanel(frame);
		
		if( showQuestDialog ) then
			OpenQuestDialog();
		end	
	end
	PlaySound("igMainMenuQuit");
end

function SplashFrameStartButton_OnClick(self)
	HideParentPanel(self);
	OpenQuestDialog();
	PlaySound("igMainMenuOpen");
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

function SplashFrame_OnHide(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:SetScript("OnUpdate", nil);
	
	SplashFrame.firstTimeViewed = false;
	
	ObjectiveTracker_Update();
end