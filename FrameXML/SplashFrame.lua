SPLASH_START_QUEST_NOW = "Start Quest Now"

SPLASH_BASE_HEADER = "What's New"
SPLASH_BASE_LABEL = "New in Warlords of Draenor Pre-Patch:"
SPLASH_BASE_FEATURE1_TITLE = "Interface Features"
SPLASH_BASE_FEATURE1_DESC = "Check out the new Toy Box, bag improvements, and reagents bank."
SPLASH_BASE_FEATURE2_TITLE = "Premade Group Finder"
SPLASH_BASE_FEATURE2_DESC = "List and browse groups for dungeons, raids, PvP, and more."
SPLASH_BASE_RIGHT_TITLE = "New Character Models"
SPLASH_BASE_RIGHT_DESC = "Your character has been upgraded with higher detail and upgraded animations."

SPLASH_NEW_HEADER = "What's New"
SPLASH_NEW_LABEL = "New in Warlords of Draenor"
SPLASH_NEW_FEATURE1_TITLE = "Garrisons"
SPLASH_NEW_FEATURE1_DESC = "Build and customize your own personal fortress"
SPLASH_NEW_FEATURE2_TITLE = "New Character Models"
SPLASH_NEW_FEATURE2_DESC = "Your character has been upgraded with higher detail and upgraded animations."
SPLASH_NEW_RIGHT_TITLE = "Draenor"
SPLASH_NEW_RIGHT_DESC = "Head to the Blasted Lands.\nA new continent awaits."

SPLASH_BOOST_HEADER = "Character Boost"
SPLASH_BOOST_LABEL = "Tips for your boosted character"
SPLASH_BOOST_FEATURE1_TITLE = "Where are my items?"
SPLASH_BOOST_FEATURE1_DESC = "We gave you a new set of gear and your old gear has been mailed to you."
SPLASH_BOOST_FEATURE2_TITLE = "Abilities"
SPLASH_BOOST_FEATURE2_DESC = "You will earn your abilities while questing in the Blasted Lands."
SPLASH_BOOST_RIGHT_TITLE = "Where should I go?"
SPLASH_BOOST_RIGHT_DESC = "Head to the Blasted Lands and talk to Watch Commander Relthorn Netherwane."
SPLASH_BOOST2_RIGHT_DESC = "Head to the Blasted Lands and talk to [Need NPC]."

-- The ids will be used to track whether character has seen a splash screen. Have to assign unique ones to each splash screen in each category (normal and boost)
SPLASH_SCREENS = {
	["BASE"] =	{	id = 1,
					questID = 0,	
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
				};
	["NEW"] =	{	id = 2,
					expansion = 6,
					questID = 0,			
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
				};
	["BOOST"] =	{	id = 1,
					questID = 0,
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
				};
	["BOOST2"] ={	id = 2,
					expansion = 6,
					questID = 0,
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
				};				
};

function SplashFrame_OnLoad(self)
	--self:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- need an event for expansion becoming active
end

function SplashFrame_OnEvent(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	
	-- add cvars
	local cvarNormal = tonumber(GetCVar("splashScreenNormal")) or 0;
	local cvarBoost = tonumber(GetCVar("splashScreenBoost")) or 0;

	local tag;
	-- should change ShouldHideGlyphTab to be IsCharacterNewlyBoosted or something
	if ( ShouldHideGlyphTab() ) then
		if ( GetExpansionLevel() >= SPLASH_SCREENS["BOOST2"].expansion and cvarBoost < SPLASH_SCREENS["BOOST2"].id ) then		
			tag = "BOOST2";
			-- save new cvar value
		elseif ( cvarBoost < SPLASH_SCREENS["BOOST"].id ) then
			tag = "BOOST";
			-- save new cvar value		
		end
	end
	if ( not tag and GetExpansionLevel() >= SPLASH_SCREENS["NEW"].expansion and cvarNormal < SPLASH_SCREENS["NEW"].id ) then
		tag = "NEW";
		-- save new cvar value
	end
	if ( not tag and cvarNormal < SPLASH_SCREENS["BASE"].id ) then
		tag = "BASE";
		-- save new cvar value
	end
	if ( tag ) then
		-- also needs to check quest log
		local hasStartButton = not IsQuestFlaggedCompleted(SPLASH_SCREENS[tag].questID);
		--SplashFrame_Display(tag, hasStartButton);
	end
end

function SplashFrame_Display(tag, hasStartButton)
	local frame = SplashFrame;
	local screenInfo = SPLASH_SCREENS[tag];
	frame.LeftTexture:SetAtlas(screenInfo.leftTex);
	frame.RightTexture:SetAtlas(screenInfo.rightTex);
	frame.BottomTexture:SetAtlas(screenInfo.bottomTex);
	frame.Header:SetText(screenInfo.Header);
	frame.Label:SetText(screenInfo.Label);
	frame.Feature1.Title:SetText(screenInfo.feature1Title);
	frame.Feature1.Description:SetText(screenInfo.feature1Desc);
	frame.Feature2.Title:SetText(screenInfo.feature2Title);
	frame.Feature2.Description:SetText(screenInfo.feature2Desc);
	frame.RightTitle:SetText(screenInfo.rightTitle);
	frame.RightDescription:SetText(screenInfo.rightDesc);
	if ( hasStartButton ) then
		frame.StartButton:Show();
		frame.StartButton.questID = screenInfo.questID;
		frame.RightDescription:SetWidth(300);
		frame.RightDescription:SetPoint("BOTTOM", 164, 183);
		frame.TopCloseButton:Hide();
		frame.BottomCloseButton:Hide();
	else
		frame.StartButton:Hide();
		frame.RightDescription:SetWidth(234);
		frame.RightDescription:SetPoint("BOTTOM", 164, 133);
		frame.TopCloseButton:Show();
		frame.BottomCloseButton:Show();		
	end
	frame:Show();
end

function SplashFrameStartButton_OnClick(self)
	-- launch quest and hide
end
