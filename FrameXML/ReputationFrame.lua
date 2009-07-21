
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
MAX_PLAYER_LEVEL = 0;
REPUTATIONFRAME_ROWSPACING = 23;

function ReputationFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_FACTION");
	-- Initialize max player level
	MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()];
	--[[for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		_G["ReputationBar"..i.."FactionStanding"]:SetPoint("CENTER",_G["ReputationBar"..i.."ReputationBar"]);
	end
	--]]
end

function ReputationFrame_OnShow()
	ReputationFrame_Update();
end

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" ) then
		if ( self:IsVisible() ) then
			ReputationFrame_Update();
		end
	end
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

function ReputationFrame_Update()
	local numFactions = GetNumFactions();
	local factionIndex, factionRow, factionTitle, factionStanding, factionBar, factionButton, factionLeftLine, factionBottomLine, factionBackground, color, tooltipStanding;
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild;
	local atWarIndicator, rightBarTexture;

	local previousBigTexture = ReputationFrameTopTreeTexture;	--In case we have a line going off the panel to the top
	previousBigTexture:Hide();
	local previousBigTexture2 = ReputationFrameTopTreeTexture2;
	previousBigTexture2:Hide();

	-- Update scroll frame
	if ( not FauxScrollFrame_Update(ReputationListScrollFrame, numFactions, NUM_FACTIONS_DISPLAYED, REPUTATIONFRAME_FACTIONHEIGHT ) ) then
		ReputationListScrollFrameScrollBar:SetValue(0);
	end
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame);

	local gender = UnitSex("player");
	
	local i;
	
	local offScreenFudgeFactor = 5;
	local previousBigTextureRows = 0;
	local previousBigTextureRows2 = 0;
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		factionIndex = factionOffset + i;
		factionRow = _G["ReputationBar"..i];
		factionBar = _G["ReputationBar"..i.."ReputationBar"];
		factionTitle = _G["ReputationBar"..i.."FactionName"];
		factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"];
		factionLeftLine = _G["ReputationBar"..i.."LeftLine"];
		factionBottomLine = _G["ReputationBar"..i.."BottomLine"];
		factionStanding = _G["ReputationBar"..i.."ReputationBarFactionStanding"];
		factionBackground = _G["ReputationBar"..i.."Background"];
		if ( factionIndex <= numFactions ) then
			name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex);
			factionTitle:SetText(name);
			if ( isCollapsed ) then
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
			else
				factionButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
			end
			factionRow.index = factionIndex;
			factionRow.isCollapsed = isCollapsed;
			local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
			factionStanding:SetText(factionStandingtext);

			--Normalize Values
			barMax = barMax - barMin;
			barValue = barValue - barMin;
			barMin = 0;
			
			factionRow.standingText = factionStandingtext;
			factionRow.tooltip = HIGHLIGHT_FONT_COLOR_CODE.." "..barValue.." / "..barMax..FONT_COLOR_CODE_CLOSE;
			factionBar:SetMinMaxValues(0, barMax);
			factionBar:SetValue(barValue);
			local color = FACTION_BAR_COLORS[standingID];
			factionBar:SetStatusBarColor(color.r, color.g, color.b);
			
			if ( isHeader and not isChild ) then
				factionLeftLine:SetTexCoord(0, 0.25, 0, 2);
				factionBottomLine:Hide();
				factionLeftLine:Hide();
				if ( previousBigTextureRows == 0 ) then
					previousBigTexture:Hide();
				end
				previousBigTexture = factionBottomLine;
				previousBigTextureRows = 0;
			elseif ( isHeader and isChild ) then
				ReputationBar_DrawHorizontalLine(factionLeftLine, 11, factionButton);
				if ( previousBigTexture2 and previousBigTextureRows2 == 0 ) then
					previousBigTexture2:Hide();
				end
				factionBottomLine:Hide();
				previousBigTexture2 = factionBottomLine;
				previousBigTextureRows2 = 0;
				previousBigTextureRows = previousBigTextureRows+1;
				ReputationBar_DrawVerticalLine(previousBigTexture, previousBigTextureRows);
				
			elseif ( isChild ) then
				ReputationBar_DrawHorizontalLine(factionLeftLine, 11, factionBackground);
				factionBottomLine:Hide();
				previousBigTextureRows = previousBigTextureRows+1;
				previousBigTextureRows2 = previousBigTextureRows2+1;
				ReputationBar_DrawVerticalLine(previousBigTexture2, previousBigTextureRows2);
			else
				-- is immediately under a main category
				ReputationBar_DrawHorizontalLine(factionLeftLine, 13, factionBackground);
				factionBottomLine:Hide();
				previousBigTextureRows = previousBigTextureRows+1;
				ReputationBar_DrawVerticalLine(previousBigTexture, previousBigTextureRows);
			end
			
			ReputationFrame_SetRowType(factionRow, ((isChild and 1 or 0) + (isHeader and 2 or 0)), hasRep);
			
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
	
	local i = NUM_
	for i = (NUM_FACTIONS_DISPLAYED + factionOffset + 1), numFactions, 1 do
		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild  = GetFactionInfo(i);
		if not name then break; end
		
		if ( isHeader and not isChild ) then
			break;
		elseif ( (isHeader and isChild) or not(isHeader or isChild) ) then
			ReputationBar_DrawVerticalLine(previousBigTexture, previousBigTextureRows+1);
			break;
		elseif ( isChild ) then
			ReputationBar_DrawVerticalLine(previousBigTexture2, previousBigTextureRows2+1);
			break;
		end
	end
end

function ReputationBar_DrawVerticalLine(texture, rows)
	-- Need to add this fudge factor because the lines are anchored to the top of the screen in this case, not another button
	local fudgeFactor = 0;
	if ( texture == ReputationFrameTopTreeTexture or texture == ReputationFrameTopTreeTexture2) then
		fudgeFactor = 5;
	end
	texture:SetHeight(rows*REPUTATIONFRAME_ROWSPACING-fudgeFactor);
	texture:SetTexCoord(0, 0.25, 0, texture:GetHeight()/2);
	texture:Show();
end

function ReputationBar_DrawHorizontalLine(texture, width, anchorTo)
	texture:SetPoint("RIGHT", anchorTo, "LEFT", 3, 0);
	texture:SetWidth(width);
	texture:SetTexCoord(0, width/2, 0, 0.25);
	texture:Show();
end

function ReputationBar_OnClick(self)
	if ( ReputationDetailFrame:IsShown() and (GetSelectedFaction() == self.index) ) then
		ReputationDetailFrame:Hide();
	else
		if ( self.hasRep ) then
			SetSelectedFaction(self.index);
			ReputationDetailFrame:Show();
			ReputationFrame_Update();
		end
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
	MainMenuExpBar_Update();
	
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
