function ReputationFrame_OnShow()
	ReputationFrame_Update();
end

function ReputationFrame_SetRowType(factionRow, rowType, hasRep)	--rowType is a binary table of type isHeader, isChild
	local factionRowName = factionRow:GetName()
	local factionBar = _G[factionRowName.."ReputationBar"];
	local factionTitle = _G[factionRowName.."FactionName"];
	local factionButton = _G[factionRowName.."ExpandOrCollapseButton"];
	local factionStanding = _G[factionRowName.."ReputationBarFactionStanding"];
	local factionBackground = _G[factionRowName.."Background"];
	local factionLeftTexture = _G[factionRowName.."ReputationBarLeftTexture"];
	local factionRightTexture = _G[factionRowName.."ReputationBarRightTexture"];
	factionLeftTexture:SetWidth(62);
	factionRightTexture:SetWidth(42);
	factionBar:SetPoint("RIGHT", factionRow, "RIGHT", 0, 0);
	if ( rowType == 0 ) then --Not header, not child
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 44, 0);
		factionButton:Hide();
		factionTitle:SetPoint("LEFT", factionRow, "LEFT", 10, 0);
		factionTitle:SetFontObject(GameFontHighlightSmall);
		factionTitle:SetWidth(160);
		factionBackground:Show();
		factionLeftTexture:SetHeight(21);
		factionRightTexture:SetHeight(21);
		factionLeftTexture:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125);
		factionRightTexture:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875);
		factionBar:SetWidth(101)
	elseif ( rowType == 1 ) then --Child, not header
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 62, 0);
		factionButton:Hide()
		factionTitle:SetPoint("LEFT", factionRow, "LEFT", 10, 0);
		factionTitle:SetFontObject(GameFontHighlightSmall);
		factionTitle:SetWidth(150);
		factionBackground:Show();
		factionLeftTexture:SetHeight(21);
		factionRightTexture:SetHeight(21);
		factionLeftTexture:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125);
		factionRightTexture:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875);
		factionBar:SetWidth(101)
	elseif ( rowType == 2 ) then	--Header, not child
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 20, 0);
		factionButton:SetPoint("LEFT", factionRow, "LEFT", 3, 0);
		factionButton:Show();
		factionTitle:SetPoint("LEFT",factionButton,"RIGHT",10,0);
		factionTitle:SetFontObject(GameFontNormalLeft);
		factionTitle:SetWidth(145);
		factionBackground:Hide()	
		factionLeftTexture:SetHeight(15);
		factionLeftTexture:SetWidth(60);
		factionRightTexture:SetHeight(15);
		factionRightTexture:SetWidth(39);
		factionLeftTexture:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125);
		factionRightTexture:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625);
		factionBar:SetWidth(99);
	elseif ( rowType == 3 ) then --Header and child
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 39, 0);
		factionButton:SetPoint("LEFT", factionRow, "LEFT", 3, 0);
		factionButton:Show();
		factionTitle:SetPoint("LEFT" ,factionButton, "RIGHT", 10, 0);
		factionTitle:SetFontObject(GameFontNormalLeft);
		factionTitle:SetWidth(135);
		factionBackground:Hide()
		factionLeftTexture:SetHeight(15);
		factionLeftTexture:SetWidth(60);
		factionRightTexture:SetHeight(15);
		factionRightTexture:SetWidth(39);
		factionLeftTexture:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125);
		factionRightTexture:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625);
		factionBar:SetWidth(99);
	end
	
	if ( (hasRep) or (rowType == 0) or (rowType == 1)) then
		factionStanding:Show();
		factionBar:Show();
		factionBar:GetParent().hasRep = true;
	else
		factionStanding:Hide();
		factionBar:Hide();
		factionBar:GetParent().hasRep = false;
	end
end

function ReputationWatchBar_Update(newLevel)
	local name, reaction, min, max, value = GetWatchedFactionInfo();
	local visibilityChanged = nil;
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	if ( name ) then
		-- See if it was already shown or not
		if ( not ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		
		-- Normalize values
		max = max - min;
		value = value - min;
		min = 0;
		ReputationWatchStatusBar:SetMinMaxValues(min, max);
		ReputationWatchStatusBar:SetValue(value);
		ReputationWatchStatusBarText:SetText(name.." "..value.." / "..max);
		local color = FACTION_BAR_COLORS[reaction];
		ReputationWatchStatusBar:SetStatusBarColor(color.r, color.g, color.b);
		ReputationWatchBar:Show();
		
		-- If the player is max level then replace the xp bar with the watched reputation, otherwise stack the reputation watch bar on top of the xp bar
		ReputationWatchStatusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
		if ( newLevel < MAX_PLAYER_LEVEL and not IsXPUserDisabled() ) then
			-- Reconfigure reputation bar
			ReputationWatchStatusBar:SetHeight(8);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, -3);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 3);
			ReputationWatchBarTexture0:Show();
			ReputationWatchBarTexture1:Show();
			ReputationWatchBarTexture2:Show();
			ReputationWatchBarTexture3:Show();

			ReputationXPBarTexture0:Hide();
			ReputationXPBarTexture1:Hide();
			ReputationXPBarTexture2:Hide();
			ReputationXPBarTexture3:Hide();

			-- Show the XP bar
			MainMenuExpBar:Show();
			MainMenuExpBar.pauseUpdates = nil;
			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		else
			-- Replace xp bar
			ReputationWatchStatusBar:SetHeight(13);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("TOP", MainMenuBar, "TOP", 0, 0);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);
			ReputationWatchBarTexture0:Hide();
			ReputationWatchBarTexture1:Hide();
			ReputationWatchBarTexture2:Hide();
			ReputationWatchBarTexture3:Hide();

			ReputationXPBarTexture0:Show();
			ReputationXPBarTexture1:Show();
			ReputationXPBarTexture2:Show();
			ReputationXPBarTexture3:Show();
	
			ExhaustionTick:Hide();

			-- Hide the XP bar
			MainMenuExpBar:Hide();
			MainMenuExpBar.pauseUpdates = true;
			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		end
		
	else
		if ( ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		ReputationWatchBar:Hide();
		if ( newLevel < MAX_PLAYER_LEVEL and not IsXPUserDisabled() ) then
			MainMenuExpBar:Show();
			MainMenuExpBar.pauseUpdates = nil;
			MainMenuBarMaxLevelBar:Hide();
		else
			MainMenuExpBar:Hide();
			MainMenuExpBar.pauseUpdates = true;
			MainMenuBarMaxLevelBar:Show();
			ExhaustionTick:Hide();
		end
	end
	
	-- update the xp bar
	TextStatusBar_UpdateTextString(MainMenuExpBar);
	MainMenuBar_UpdateExperienceBars();
	
	if ( visibilityChanged ) then
		UIParent_ManageFramePositions();
		updateContainerFrameAnchors();
	end
end

function ShowWatchedReputationBarText(lock)
	if ( lock ) then
		ReputationWatchBar.cvarLocked = lock;
	end
	if ( ReputationWatchBar:IsShown() ) then
		ReputationWatchStatusBarText:Show();
		ReputationWatchBar.textLocked = 1;
	else
		HideWatchedReputationBarText();
	end
end

function HideWatchedReputationBarText(unlock)
	if ( unlock or not ReputationWatchBar.cvarLocked ) then
		ReputationWatchBar.cvarLocked = nil;
		ReputationWatchStatusBarText:Hide();
		ReputationWatchBar.textLocked = nil;
	end
end

function ReputationWatchBar_UpdateMaxLevel()
	-- Initialize max player level
	MAX_PLAYER_LEVEL = GetMaxPlayerLevel();
end