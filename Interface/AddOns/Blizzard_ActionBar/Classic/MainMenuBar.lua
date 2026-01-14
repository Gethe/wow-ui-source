local MAINMENU_SLIDETIME = 0.30;
local MAINMENU_GONEYPOS = 130;	--Distance off screen for MainMenuBar to be completely hidden
local MAINMENU_XPOS = 0;

function MainMenuBar_OnLoad(self)
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("BAG_UPDATE");

	if (ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA)) then
		self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	end

	MainMenuBar.state = "player";

	if (ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) and GetClassicExpansionLevel() < LE_EXPANSION_MISTS_OF_PANDARIA) then
		--starting in 3.4.3 we need to make space for the new Collections micro button
		UpdateMainMenuBarArt(self);
	else
		MainMenuBarTextureExtender:Hide();
	end
end


local firstEnteringWorld = true;
function MainMenuBar_OnEvent(self, event, ...)
	if ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame = GetCVarBool("showTokenFrame");
		if ( not showTokenFrame ) then
			local name, isHeader, isExpanded, isUnused, isWatched, count, icon;
			local hasNormalTokens;
			local currencyTab = HonorFrame_GetCurrencyFrame();
			for index=1, GetCurrencyListSize() do
				name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(index);
				if ( (not isHeader) and (count>0) ) then
					hasNormalTokens = true;
				end
			end
			if ( (not showTokenFrame) and (hasNormalTokens) ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					MicroButtonPulse(CharacterMicroButton, 60);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(currencyTab, 60, 1);
				end
			end
			
			if ( hasNormalTokens or showTokenFrame ) then
				TokenFrame_LoadUI();
				TokenFrame_Update();
				BackpackTokenFrame_Update();
			else
				currencyTab:Hide();
			end
		else
			TokenFrame_LoadUI();
			TokenFrame_Update();
			BackpackTokenFrame_Update();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		local unitToken = ...;
		if ( unitToken == "player" ) then
			UpdateMicroButtons();
		end
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		UpdateMicroButtons();
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "BAG_UPDATE" ) then
		if( HasKey() ) then
			if(not GetCVarBool("showKeyring")) then
				-- Show Tutorial and flash keyring
				TriggerTutorial(50); --TUTORIAL_KEYRING
				SetButtonPulse(KeyRingButton, 60, 1);
				SetCVar("showKeyring", 1);
			end
		end
		MainMenuBar_UpdateKeyRing();
	end
end

function MainMenuBar_OnShow(self)
	UIParent_ManageFramePositions();
end

function MainMenuBar_OnHide(self)
	UIParent_ManageFramePositions();
end

function MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, artifactXP, artifactTier)
	local numPoints = 0;
	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
		artifactXP = artifactXP - xpForNextPoint;

		pointsSpent = pointsSpent + 1;
		numPoints = numPoints + 1;

		xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	end
	return numPoints, artifactXP, xpForNextPoint;
end

function MainMenuBar_SetMaxLevelBarShown(shown)
	MainMenuBarMaxLevelBar:SetShown(shown);
end

function UpdateMainMenuBarArt(self)
	--adjust sizing to make space for MainMenuBarTextureExtender
	MainMenuBar:SetSize(1044, 53);
	MainMenuBarTexture0:SetPoint("BOTTOM", -394, 0);
	MainMenuBarTexture1:SetPoint("BOTTOM", -138, 0);
	MainMenuBarTexture2:SetPoint("BOTTOM", 118, 0);
	MainMenuBarTexture3:SetPoint("BOTTOM", 394, 0);
	MainMenuBarLeftEndCap:SetPoint("BOTTOM", -554, 0);
	MainMenuBarRightEndCap:SetPoint("BOTTOM", 554, 0);
end

function MainMenuTrackingBar_Configure(frame, isOnTop)
	local statusBar = frame.StatusBar;
	statusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
	if ( isOnTop ) then
		statusBar:SetHeight(8);
		frame:ClearAllPoints();
		frame:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, -3);
		frame.OverlayFrame.Text:SetPoint("CENTER", frame.OverlayFrame, "CENTER", 0, 3);
		statusBar.WatchBarTexture0:Show();
		statusBar.WatchBarTexture1:Show();
		statusBar.WatchBarTexture2:Show();
		statusBar.WatchBarTexture3:Show();
	else
		statusBar:SetHeight(13);
		frame:ClearAllPoints();
		frame:SetPoint("TOP", MainMenuBar, "TOP", 0, 0);
		frame.OverlayFrame.Text:SetPoint("CENTER", frame.OverlayFrame, "CENTER", 0, 1);
		statusBar.WatchBarTexture0:Hide();
		statusBar.WatchBarTexture1:Hide();
		statusBar.WatchBarTexture2:Hide();
		statusBar.WatchBarTexture3:Hide();
	end
end

function MainMenuBar_UpdateKeyRing()
	if ( IsKeyRingEnabled() and GetCVarBool("showKeyring") ) then
		MainMenuBarTexture3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture3:SetTexCoord(0, 1, 0.1640625, 0.5);
		MainMenuBarTexture2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture2:SetTexCoord(0, 1, 0.6640625, 1);
		MainMenuBarPerformanceBarFrame:SetPoint("BOTTOMRIGHT", MainMenuBar, "BOTTOMRIGHT", -235, -10);
		KeyRingButton:Show();
	end
end
