function ReputationFrame_OnShow()
	CharacterFrameTitleText:SetText(UnitPVPName("player"));
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
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 34, 0);
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
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 52, 0);
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
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 10, 0);
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
		factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 29, 0);
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
	local name, reaction, min, max, value, factionID  = GetWatchedFactionInfo();
	local visibilityChanged = nil;
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	if ( name ) then
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);
		local colorIndex = reaction;
		-- if it's a different faction, save possible friendship id
		if ( ReputationWatchBar.factionID ~= factionID ) then
			ReputationWatchBar.factionID = factionID;
			ReputationWatchBar.friendshipID = repInfo.friendshipFactionID;
		end

		local isCappedFriendship;
		-- do something different for friendships
		if ( ReputationWatchBar.friendshipID and ReputationWatchBar.friendshipID > 0) then
			
			if ( repInfo.nextThreshold ) then
				min, max, value =  repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
			else
				-- max rank, make it look like a full bar
				min, max, value = 0, 1, 1;
				isCappedFriendship = true;
			end
			colorIndex = 5; -- always color friendships green
		end

		-- See if it was already shown or not
		if ( not ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		
		-- Normalize values
		max = max - min;
		value = value - min;
		min = 0;
		ReputationWatchBar.StatusBar:SetMinMaxValues(min, max);
		ReputationWatchBar.StatusBar:SetValue(value);
		
		if ( isCappedFriendship ) then
			ReputationWatchBar.OverlayFrame.Text:SetText(name);
		else
			ReputationWatchBar.OverlayFrame.Text:SetText(name.." "..value.." / "..max);
		end
		local color = FACTION_BAR_COLORS[colorIndex];
		ReputationWatchBar.StatusBar:SetStatusBarColor(color.r, color.g, color.b);
		ReputationWatchBar:Show();
		
		-- If the player is max level then replace the xp bar with the watched reputation, otherwise stack the reputation watch bar on top of the xp bar
		ReputationWatchBar.StatusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
		if ( newLevel < MAX_PLAYER_LEVEL and not IsXPUserDisabled() ) then
			-- Reconfigure reputation bar
			ReputationWatchBar.StatusBar:SetHeight(8);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, -3);
			ReputationWatchBar.OverlayFrame.Text:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 3);
			ReputationWatchBar.StatusBar.WatchBarTexture0:Show();
			ReputationWatchBar.StatusBar.WatchBarTexture1:Show();
			ReputationWatchBar.StatusBar.WatchBarTexture2:Show();
			ReputationWatchBar.StatusBar.WatchBarTexture3:Show();

			ReputationWatchBar.StatusBar.XPBarTexture0:Hide();
			ReputationWatchBar.StatusBar.XPBarTexture1:Hide();
			ReputationWatchBar.StatusBar.XPBarTexture2:Hide();
			ReputationWatchBar.StatusBar.XPBarTexture3:Hide();

			-- Show the XP bar
			MainMenuExpBar:Show();
			MainMenuExpBar.pauseUpdates = nil;
			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		else
			-- Replace xp bar
			ReputationWatchBar.StatusBar:SetHeight(13);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("TOP", MainMenuBar, "TOP", 0, 0);
			ReputationWatchBar.OverlayFrame.Text:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);
			ReputationWatchBar.StatusBar.WatchBarTexture0:Hide();
			ReputationWatchBar.StatusBar.WatchBarTexture1:Hide();
			ReputationWatchBar.StatusBar.WatchBarTexture2:Hide();
			ReputationWatchBar.StatusBar.WatchBarTexture3:Hide();

			ReputationWatchBar.StatusBar.XPBarTexture0:Show();
			ReputationWatchBar.StatusBar.XPBarTexture1:Show();
			ReputationWatchBar.StatusBar.XPBarTexture2:Show();
			ReputationWatchBar.StatusBar.XPBarTexture3:Show();
	
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
		UpdateContainerFrameAnchors();
	end
end

function ShowWatchedReputationBarText(lock)
	if ( lock ) then
		ReputationWatchBar.cvarLocked = lock;
	end
	if ( ReputationWatchBar:IsShown() ) then
		ReputationWatchBar.OverlayFrame.Text:Show();
		ReputationWatchBar.textLocked = 1;
	else
		HideWatchedReputationBarText();
	end
end

function HideWatchedReputationBarText(unlock)
	if ( unlock or not ReputationWatchBar.cvarLocked ) then
		ReputationWatchBar.cvarLocked = nil;
		ReputationWatchBar.OverlayFrame.Text:Hide();
		ReputationWatchBar.textLocked = nil;
	end
end
