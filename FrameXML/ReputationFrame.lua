
NUM_FACTIONS_DISPLAYED = 15;
REPUTATIONFRAME_FACTIONHEIGHT = 26;
FACTION_BAR_COLORS = {
	[1] = {r = 0.8, g = 0.3, b = 0.22},
	[2] = {r = 0.8, g = 0.3, b = 0.22},
	[3] = {r = 0.75, g = 0.27, b = 0},
	[4] = {r = 0.9, g = 0.7, b = 0},
	[5] = {r = 0, g = 0.6, b = 0.1},
	[6] = {r = 0, g = 0.6, b = 0.1},
	[7] = {r = 0, g = 0.6, b = 0.1},
	[8] = {r = 0, g = 0.6, b = 0.1},
};
-- Hard coded =(, will need to add entries for each expansion
MAX_PLAYER_LEVEL_TABLE = {};
MAX_PLAYER_LEVEL_TABLE[0] = 60;
MAX_PLAYER_LEVEL_TABLE[1] = 70;
MAX_PLAYER_LEVEL_TABLE[2] = 80;
MAX_PLAYER_LEVEL_TABLE[3] = 85;
MAX_PLAYER_LEVEL_TABLE[4] = 90;
MAX_PLAYER_LEVEL = 0;
REPUTATIONFRAME_ROWSPACING = 23;

function ReputationFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("LFG_BONUS_FACTION_ID_UPDATED");
	ReputationWatchBar_UpdateMaxLevel();
	--[[for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		_G["ReputationBar"..i.."FactionStanding"]:SetPoint("CENTER",_G["ReputationBar"..i.."ReputationBar"]);
	end
	--]]
end

function ReputationFrame_OnShow()
	CharacterFrameTitleText:SetText(UnitPVPName("player"));
	ReputationFrame_Update();
end

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" ) then
		if ( self:IsVisible() ) then
			ReputationFrame_Update();
		end
	end
end

function ReputationFrame_SetRowType(factionRow, isChild, isHeader, hasRep)	--rowType is a binary table of type isHeader, isChild
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
	if ( isHeader ) then
		if ( isChild ) then
			factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 29, 0);
			factionTitle:SetWidth(135);
		else
			factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 10, 0);
			factionTitle:SetWidth(145);
		end

		factionButton:SetPoint("LEFT", factionRow, "LEFT", 3, 0);
		factionButton:Show();
		factionTitle:SetPoint("LEFT",factionButton,"RIGHT",10,0);
		factionTitle:SetFontObject(GameFontNormalLeft);
		factionBackground:Hide()	
		factionLeftTexture:SetHeight(15);
		factionLeftTexture:SetWidth(60);
		factionRightTexture:SetHeight(15);
		factionRightTexture:SetWidth(39);
		factionLeftTexture:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125);
		factionRightTexture:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625);
		factionBar:SetWidth(99);
		factionRow.LFGBonusRepButton:SetPoint("RIGHT", factionButton, "LEFT", 0, 1);
	else
		if ( isChild ) then
			factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 52, 0);
			factionTitle:SetWidth(150);
		else
			factionRow:SetPoint("LEFT", ReputationFrame, "LEFT", 34, 0);
			factionTitle:SetWidth(160);
		end

		factionButton:Hide();
		factionTitle:SetPoint("LEFT", factionRow, "LEFT", 10, 0);
		factionTitle:SetFontObject(GameFontHighlightSmall);
		factionBackground:Show();
		factionLeftTexture:SetHeight(21);
		factionRightTexture:SetHeight(21);
		factionLeftTexture:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125);
		factionRightTexture:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875);
		factionBar:SetWidth(101)
		factionRow.LFGBonusRepButton:SetPoint("RIGHT", factionBackground, "LEFT", -2, 0);
	end
	
	if ( (hasRep) or (not isHeader) ) then
		factionStanding:Show();
		factionBar:Show();
		factionBar:GetParent().hasRep = true;
	else
		factionStanding:Hide();
		factionBar:Hide();
		factionBar:GetParent().hasRep = false;
	end
end

function ReputationFrame_Update()
	local numFactions = GetNumFactions();

	-- Update scroll frame
	if ( not FauxScrollFrame_Update(ReputationListScrollFrame, numFactions, NUM_FACTIONS_DISPLAYED, REPUTATIONFRAME_FACTIONHEIGHT ) ) then
		ReputationListScrollFrameScrollBar:SetValue(0);
	end
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame);

	local gender = UnitSex("player");
	local lfgBonusFactionID = GetLFGBonusFactionID();
	
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + i;
		local factionRow = _G["ReputationBar"..i];
		local factionBar = _G["ReputationBar"..i.."ReputationBar"];
		local factionTitle = _G["ReputationBar"..i.."FactionName"];
		local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"];
		local factionStanding = _G["ReputationBar"..i.."ReputationBarFactionStanding"];
		local factionBackground = _G["ReputationBar"..i.."Background"];
		if ( factionIndex <= numFactions ) then
			local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex);
			factionTitle:SetText(name);
			if ( isCollapsed ) then
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
			else
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
			end
			factionRow.index = factionIndex;
			factionRow.isCollapsed = isCollapsed;

			local colorIndex = standingID;
			local factionStandingtext;

			-- check if this is a friendship faction 
			local isCappedFriendship;
			local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
			if (friendID ~= nil) then
				factionStandingtext = friendTextLevel;
				if ( nextFriendThreshold ) then
					barMin, barMax, barValue = friendThreshold, nextFriendThreshold, friendRep;
				else
					-- max rank, make it look like a full bar
					barMin, barMax, barValue = 0, 1, 1;
					isCappedFriendship = true;
				end
				colorIndex = 5;								-- always color friendships green
				factionRow.friendshipID = friendID;			-- for doing friendship tooltip
			else
				factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
				factionRow.friendshipID = nil;
			end

			factionStanding:SetText(factionStandingtext);

			--Normalize Values
			barMax = barMax - barMin;
			barValue = barValue - barMin;
			barMin = 0;
			
			factionRow.standingText = factionStandingtext;
			if ( isCappedFriendship ) then
				factionRow.tooltip = nil;
			else
				factionRow.tooltip = HIGHLIGHT_FONT_COLOR_CODE.." "..barValue.." / "..barMax..FONT_COLOR_CODE_CLOSE;
			end
			factionBar:SetMinMaxValues(0, barMax);
			factionBar:SetValue(barValue);
			local color = FACTION_BAR_COLORS[colorIndex];
			factionBar:SetStatusBarColor(color.r, color.g, color.b);
			
			factionBar.BonusIcon:SetShown(hasBonusRepGain);

			factionRow.LFGBonusRepButton.factionID = factionID;
			factionRow.LFGBonusRepButton:SetShown(canBeLFGBonus);
			factionRow.LFGBonusRepButton:SetChecked(lfgBonusFactionID == factionID);
			factionRow.LFGBonusRepButton:SetEnabled(lfgBonusFactionID ~= factionID);

			ReputationFrame_SetRowType(factionRow, isChild, isHeader, hasRep);
			
			factionRow:Show();

			-- Update details if this is the selected faction
			if ( atWarWith ) then
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:Show();
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:Show();
			else
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:Hide();
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:Hide();
			end
			if ( factionIndex == GetSelectedFaction() ) then
				if ( ReputationDetailFrame:IsShown() ) then
					ReputationDetailFactionName:SetText(name);
					ReputationDetailFactionDescription:SetText(description);
					if ( atWarWith ) then
						ReputationDetailAtWarCheckBox:SetChecked(1);
					else
						ReputationDetailAtWarCheckBox:SetChecked(nil);
					end
					if ( canToggleAtWar and (not isHeader)) then
						ReputationDetailAtWarCheckBox:Enable();
						ReputationDetailAtWarCheckBoxText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					else
						ReputationDetailAtWarCheckBox:Disable();
						ReputationDetailAtWarCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
					if ( not isHeader ) then
						ReputationDetailInactiveCheckBox:Enable();
						ReputationDetailInactiveCheckBoxText:SetTextColor(ReputationDetailInactiveCheckBoxText:GetFontObject():GetTextColor());
					else
						ReputationDetailInactiveCheckBox:Disable();
						ReputationDetailInactiveCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
					if ( IsFactionInactive(factionIndex) ) then
						ReputationDetailInactiveCheckBox:SetChecked(1);
					else
						ReputationDetailInactiveCheckBox:SetChecked(nil);
					end
					if ( isWatched ) then
						ReputationDetailMainScreenCheckBox:SetChecked(1);
					else
						ReputationDetailMainScreenCheckBox:SetChecked(nil);
					end
					_G["ReputationBar"..i.."ReputationBarHighlight1"]:Show();
					_G["ReputationBar"..i.."ReputationBarHighlight2"]:Show();
				end
			else
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:Hide();
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:Hide();
			end
		else
			factionRow:Hide();
		end
	end
	if ( GetSelectedFaction() == 0 ) then
		ReputationDetailFrame:Hide();
	end
end

function ReputationBar_OnClick(self)
	if ( ReputationDetailFrame:IsShown() and (GetSelectedFaction() == self.index) ) then
		PlaySound("igCharacterInfoClose");
		ReputationDetailFrame:Hide();
	else
		if ( self.hasRep ) then
			PlaySound("igCharacterInfoOpen");
			SetSelectedFaction(self.index);
			ReputationDetailFrame:Show();
			ReputationFrame_Update();
		end
	end
end

function ReputationBarLFGBonusRepButton_OnClick(self)
	SetLFGBonusFactionID(self.factionID);
	self:Disable();
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionRow = _G["ReputationBar"..i];
		local button = factionRow.LFGBonusRepButton;
		if ( button ~= self ) then
			--It feels really weird when the client waits to update until it receives a response from the server.
			--Instead, we'll fake it. Hopefully we don't end up lying to people
			button:SetChecked(false);
		end
	end
end

function ReputationWatchBar_Update(newLevel)
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
	local visibilityChanged = nil;
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	if ( name ) then
		local colorIndex = reaction;
		-- if it's a different faction, save possible friendship id
		if ( ReputationWatchBar.factionID ~= factionID ) then
			ReputationWatchBar.factionID = factionID;
			ReputationWatchBar.friendshipID = GetFriendshipReputation(factionID);
		end

		local isCappedFriendship;
		-- do something different for friendships
		if ( ReputationWatchBar.friendshipID ) then
			local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
			if ( nextFriendThreshold ) then
				min, max, value = friendThreshold, nextFriendThreshold, friendRep;
			else
				-- max rank, make it look like a full bar
				min, max, value = 0, 1, 1;
				isCappedFriendship = true;
			end
			colorIndex = 5;		-- always color friendships green
		end

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
		if ( isCappedFriendship ) then
			ReputationWatchStatusBarText:SetText(name);
		else
			ReputationWatchStatusBarText:SetText(name.." "..value.." / "..max);
		end
		local color = FACTION_BAR_COLORS[colorIndex];
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
	ExpBar_Update();
	
	if ( visibilityChanged ) then
		UIParent_ManageFramePositions();
		UpdateContainerFrameAnchors();
	end
end

function ReputationWatchBar_UpdateMaxLevel()
	-- Initialize max player level
	MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()];
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

function ShowFriendshipReputationTooltip(friendshipID, parent, anchor)
	local id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold = GetFriendshipReputation(friendshipID);
	if ( id and id > 0) then
		GameTooltip:SetOwner(parent, anchor);
		local currentRank, maxRank = GetFriendshipReputationRanks(id);
		if ( maxRank > 0 ) then
			GameTooltip:SetText(name.." ("..currentRank.." / "..maxRank..")", 1, 1, 1);
		else
			GameTooltip:SetText(name, 1, 1, 1);
		end
		GameTooltip:AddLine(text, nil, nil, nil, true);
		if ( nextThreshold ) then
			local current = rep - threshold;
			local max = nextThreshold - threshold;
			GameTooltip:AddLine(reaction.." ("..current.." / "..max..")" , 1, 1, 1, true);
		else
			GameTooltip:AddLine(reaction);
		end
		GameTooltip:Show();
	end
end
