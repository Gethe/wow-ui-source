-- The ids will be used to track whether character has seen a splash screen. Have to assign unique ones to each splash screen in each category (normal and boost)
PREPATCH_BOOST_QUESTS = { Alliance = {id=35460, text=SPLASH_BOOST_RIGHT_DESC_ALLIANCE}
						, Horde = {id=35745, text=SPLASH_BOOST_RIGHT_DESC_HORDE}
						};
						
PREPATCH_QUESTS = { Alliance = 36498,
					Horde = 36499
				  };
				  
POSTPATCH_BOOST_QUEST = 34398;

SPLASH_SCREENS = {
	["BASE"] =	{	id = 1,
					questID = 0,	-- questID is set in SplashFrame_OnLoad
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
					features = {
						[1] = { EnterFunc = function() 
									CollectionsMicroButtonAlert:Show();
									MicroButtonPulse(CompanionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CompanionsMicroButton);
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
					}
				},
	["NEW"] =	{	id = 2,
					expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
					questID = POSTPATCH_BOOST_QUEST,			
					leftTex = "splash-601-topleft",
					rightTex = "splash-601-right",
					bottomTex = "splash-601-botleft",
					header = SPLASH_NEW_HEADER,
					label = SPLASH_NEW_LABEL,
					feature1Title = SPLASH_NEW_FEATURE1_TITLE,
					feature1Desc = SPLASH_NEW_FEATURE1_DESC,
					feature2Title = SPLASH_NEW_FEATURE2_TITLE,
					feature2Desc = SPLASH_NEW_FEATURE2_DESC,
					rightTitle = SPLASH_NEW_RIGHT_TITLE,
					rightDesc = SPLASH_NEW_RIGHT_DESC,
					cVar="splashScreenNormal",
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
					questID = 0, -- questID is set in SplashFrame_OnLoad
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
					features = {
						[1] = { EnterFunc = function() 
									CollectionsMicroButtonAlert:Show();
									MicroButtonPulse(CompanionsMicroButton);
								end,
								LeaveFunc = function()
									CollectionsMicroButtonAlert:Hide();
									MicroButtonPulseStop(CompanionsMicroButton);
								end,
								},
						[2] = { EnterFunc = function() end,
								LeaveFunc = function() end,
								},
					},
				},
	["BOOST2"] ={	id = 2,
					expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
					questID = POSTPATCH_BOOST_QUEST,
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
					rightDesc = SPLASH_BOOST2_RIGHT_DESC,
					cVar="splashScreenBoost",
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

local function GetSplashFrameTag()
	local tag;
	local expansionLevel = GetExpansionLevel();
	if ( IsCharacterNewlyBoosted() ) then
		if ( expansionLevel >= SPLASH_SCREENS["BOOST2"].expansion ) then		
			tag = "BOOST2";
		else
			tag = "BOOST";
		end
	end
	
	if( not tag ) then
		if ( expansionLevel >= SPLASH_SCREENS["NEW"].expansion) then
			tag = "NEW";
		else
			tag = "BASE";
		end
	end
	return tag;
end

function SplashFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- need an event for expansion becoming active
	local faction = UnitFactionGroup("player");
	local data = PREPATCH_BOOST_QUESTS[faction];
	if( data ) then
		SPLASH_SCREENS["BASE"].questID = PREPATCH_QUESTS[faction];
		SPLASH_SCREENS["BOOST"].questID = PREPATCH_BOOST_QUESTS[faction].id;
		SPLASH_SCREENS["BOOST"].rightDesc = PREPATCH_BOOST_QUESTS[faction].text;
	else
		SPLASH_SCREENS["NEW"].questID = nil;
	end
end

local function IsQuestAutoQuest( questID )
	if( questID )then
		for i = 1, GetNumAutoQuestPopUps() do
			local id, popUpType = GetAutoQuestPopUp(i);	
			if( id == questID and popUpType ) then
				return true;
			end
		end
	end
	return false;
end

function SplashFrame_OnEvent(self, event)
	if( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		local playerLevel = UnitLevel("player");
		
		--We don't want to show the splash screen for new players so we wait until they are 20 or higher.
		if ( playerLevel < 20 ) then
			return;
		end
		
		local tag = GetSplashFrameTag();
		-- check if they've seen this screen already
		local lastScreenID = tonumber(GetCVar(SPLASH_SCREENS[tag].cVar)) or 0;
		if( lastScreenID >= SPLASH_SCREENS[tag].id ) then
			return;
		end	
		
		if ( tag ) then
			SplashFrame_Open(tag);
			SetCVar(SPLASH_SCREENS[tag].cVar, SPLASH_SCREENS[tag].id); -- update cVar value;
		end
	elseif( event == "QUEST_LOG_UPDATE" ) then
		local tag = GetSplashFrameTag();
		if( self:IsShown() and tag )then
			local showStartButton = false;
			local questID = SPLASH_SCREENS[tag].questID;
			if(questID)then
				local playerLevel = UnitLevel("player");
				showStartButton = not IsQuestFlaggedCompleted(questID) and playerLevel >= 90;
			end

			SplashFrame_SetStartButtonDisplay(showStartButton);
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
		"Game32Font",
		"Game27Font",
		"Game24Font",
		"Game18Font",
	}
	for _, font in pairs(fonts) do
		frame.RightTitle:SetFontObject(font);
		if( frame.RightTitle:GetStringWidth() < 300 ) then
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
	if( tag == "NEW" ) then
		local faction = UnitFactionGroup("player");
		local data = PREPATCH_BOOST_QUESTS[faction];
		if( showStartButton and data )then 
			SPLASH_SCREENS["NEW"].rightDesc = data.text;
		else
			SPLASH_SCREENS["NEW"].rightDesc = SPLASH_NEW_RIGHT_DESC;
		end
	end
	frame.RightDescription:SetText(SPLASH_SCREENS[tag].rightDesc);
	if ( showStartButton ) then
		frame.StartButton:Show();
		frame.RightDescription:SetWidth(300);
		frame.RightDescription:SetPoint("BOTTOM", 164, 183);
		frame.BottomCloseButton:Hide();
		local questID = SPLASH_SCREENS[tag].questID;
		if(questID)then
			local questIndex = GetQuestLogIndexByID(questID);
			if( IsQuestAutoQuest(questID) or questIndex > 0 ) then
				frame.StartButton.Text:SetTextColor(1, 1, 1);
				frame.StartButton.Texture:SetDesaturated(false);
				frame.StartButton:Enable();
				frame.TopCloseButton:Hide();
				frame:UnregisterEvent("QUEST_LOG_UPDATE");
				frame:SetScript("OnUpdate", nil);
			else
				frame.StartButton.Text:SetTextColor(0.5, 0.5, 0.5);
				frame.StartButton.Texture:SetDesaturated(true);
				frame.StartButton:Disable();
			end
		end
	else
		frame.StartButton:Hide();
		frame.RightDescription:SetWidth(234);
		frame.RightDescription:SetPoint("BOTTOM", 164, 133);
		frame.TopCloseButton:Show();
		frame.BottomCloseButton:Show();		
	end
end

function SplashFrame_Open( tag )
	if( not tag ) then
		tag = GetSplashFrameTag();
	end
	local showStartButton = false;
	local questID = SPLASH_SCREENS[tag].questID;
	local frame = SplashFrame;
	if(questID)then
		local playerLevel = UnitLevel("player");
		local questIndex = GetQuestLogIndexByID(questID);
		
		if( not IsQuestFlaggedCompleted(questID) and playerLevel >= 90 and questIndex == 0 ) then
			showStartButton = true;
			frame.timeSinceOpen = 0;
			frame:SetScript("OnUpdate", SplashFrame_OnUpdate);
		end
	end
	frame.TopCloseButton:Hide();
	SplashFrame_Display( tag, showStartButton );
end

function SplashFrame_Close()
	local frame = SplashFrame;
	if(frame.StartButton:IsShown())then
		return;
	end
	
	HideParentPanel(SplashFrame.BottomCloseButton);
	PlaySound("igMainMenuQuit");
end

function SplashFrameStartButton_OnClick(self)
	HideParentPanel(self);
	local frame = SplashFrame;
	local questID = SPLASH_SCREENS[frame.tag].questID;
	frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	ShowQuestOffer(GetQuestLogIndexByID(questID));
	AutoQuestPopupTracker_RemovePopUp(questID);
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
end

function SplashFrame_OnUpdate(self, elasped)
	self.timeSinceOpen = self.timeSinceOpen + elasped;
	if( self.timeSinceOpen > 2 and not self.TopCloseButton:IsShown() ) then
		self.TopCloseButton:Show();
		self:SetScript("OnUpdate", nil);
	end
end