
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

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" ) then
		if ( self:IsVisible() ) then
			ReputationFrame_Update();
		end
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
			color = FACTION_BAR_COLORS[standingID];
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
						ReputationDetailAtWarCheckbox:SetChecked(1);
					else
						ReputationDetailAtWarCheckbox:SetChecked(nil);
					end
					if ( canToggleAtWar and (not isHeader)) then
						ReputationDetailAtWarCheckbox:Enable();
						ReputationDetailAtWarCheckboxText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					else
						ReputationDetailAtWarCheckbox:Disable();
						ReputationDetailAtWarCheckboxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
					if ( not isHeader ) then
						ReputationDetailInactiveCheckbox:Enable();
						ReputationDetailInactiveCheckboxText:SetTextColor(ReputationDetailInactiveCheckboxText:GetFontObject():GetTextColor());
					else
						ReputationDetailInactiveCheckbox:Disable();
						ReputationDetailInactiveCheckboxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
					if ( IsFactionInactive(factionIndex) ) then
						ReputationDetailInactiveCheckbox:SetChecked(1);
					else
						ReputationDetailInactiveCheckbox:SetChecked(nil);
					end
					if ( isWatched ) then
						ReputationDetailMainScreenCheckbox:SetChecked(1);
					else
						ReputationDetailMainScreenCheckbox:SetChecked(nil);
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
	
	for i = (NUM_FACTIONS_DISPLAYED + factionOffset + 1), numFactions, 1 do
		name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild  = GetFactionInfo(i);
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