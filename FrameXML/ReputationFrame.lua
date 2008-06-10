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
-- Hard coded =(, will need to change when we up the level cap
MAX_PLAYER_LEVEL = 60;

function ReputationFrame_OnLoad()
	this:RegisterEvent("UPDATE_FACTION");
end

function ReputationFrame_OnShow()
	ReputationFrame_Update();
end

function ReputationFrame_OnEvent(event)
	if ( event == "UPDATE_FACTION" ) then
		if ( this:IsVisible() ) then
			ReputationFrame_Update();
		end
	end
end

function ReputationFrame_Update()
	local numFactions = GetNumFactions();
	local factionIndex, factionName, factionCheck, factionStanding, factionBar, factionHeader, color, tooltipStanding;
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched;
	local atWarIndicator, rightBarTexture;

	-- Update scroll frame
	if ( not FauxScrollFrame_Update(ReputationListScrollFrame, numFactions, NUM_FACTIONS_DISPLAYED, REPUTATIONFRAME_FACTIONHEIGHT ) ) then
		ReputationListScrollFrameScrollBar:SetValue(0);
	end
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame);

	local gender = UnitSex("player");
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		factionIndex = factionOffset + i;
		factionBar = getglobal("ReputationBar"..i);
		factionHeader = getglobal("ReputationHeader"..i);
		factionCheck = getglobal("ReputationBar"..i.."Check");
		if ( factionIndex <= numFactions ) then
			name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(factionIndex);
			if ( isHeader ) then
				factionHeader:SetText(name);
				if ( isCollapsed ) then
					factionHeader:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					factionHeader:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
				end
				factionHeader.index = factionIndex;
				factionHeader.isCollapsed = isCollapsed;
				factionBar:Hide();
				factionHeader:Show();
				factionCheck:Hide();
			else
				factionStanding = GetText("FACTION_STANDING_LABEL"..standingID, gender);
				factionName = getglobal("ReputationBar"..i.."FactionName");
				factionName:SetText(name);
				getglobal("ReputationBar"..i.."FactionStanding"):SetText(factionStanding);
				
				atWarIndicator = getglobal("ReputationBar"..i.."AtWarCheck");
				rightBarTexture = getglobal("ReputationBar"..i.."ReputationBarRight");
				
				if ( atWarWith ) then
					atWarIndicator:Show();
				else
					atWarIndicator:Hide();
				end

				-- Normalize values
				barMax = barMax - barMin;
				barValue = barValue - barMin;
				barMin = 0;
				
				factionBar.id = factionIndex;
				factionBar.standingText = factionStanding;
				factionBar.tooltip = HIGHLIGHT_FONT_COLOR_CODE.." "..barValue.." / "..barMax..FONT_COLOR_CODE_CLOSE;
				factionBar:SetMinMaxValues(0, barMax);
				factionBar:SetValue(barValue);
				color = FACTION_BAR_COLORS[standingID];
				factionBar:SetStatusBarColor(color.r, color.g, color.b);
				factionBar:SetID(factionIndex);
				factionBar:Show();
				factionHeader:Hide();

				-- Show a checkmark if this faction is being watched
				if ( isWatched ) then
					factionCheck:Show();
					factionName:SetWidth(100);
					factionCheck:SetPoint("LEFT", factionName, "LEFT", factionName:GetStringWidth(), 0);
				else
					factionCheck:Hide();
					factionName:SetWidth(110);
				end
				
				-- Update details if this is the selected faction
				if ( factionIndex == GetSelectedFaction() ) then
					if ( ReputationDetailFrame:IsShown() ) then
						ReputationDetailFactionName:SetText(name);
						ReputationDetailFactionDescription:SetText(description);
						if ( atWarWith ) then
							ReputationDetailAtWarCheckBox:SetChecked(1);
						else
							ReputationDetailAtWarCheckBox:SetChecked(nil);
						end
						if ( canToggleAtWar ) then
							ReputationDetailAtWarCheckBox:Enable();
							ReputationDetailAtWarCheckBoxText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
						else
							ReputationDetailAtWarCheckBox:Disable();
							ReputationDetailAtWarCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

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
					end
					getglobal("ReputationBar"..i.."Highlight1"):Show();
					getglobal("ReputationBar"..i.."Highlight2"):Show();
				else
					getglobal("ReputationBar"..i.."Highlight1"):Hide();
					getglobal("ReputationBar"..i.."Highlight2"):Hide();
				end
			end
		else
			factionHeader:Hide();
			factionBar:Hide();
		end
	end
	if ( GetSelectedFaction() == 0 ) then
		ReputationDetailFrame:Hide();
	end
end

function ReputationBar_OnClick()
	if ( ReputationDetailFrame:IsShown() and (GetSelectedFaction() == this.id) ) then
		ReputationDetailFrame:Hide();
	else
		SetSelectedFaction(this.id);
		ReputationDetailFrame:Show();
		ReputationFrame_Update();
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
		if ( newLevel < MAX_PLAYER_LEVEL ) then
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

			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		end
		
	else
		if ( ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		ReputationWatchBar:Hide();
		if ( newLevel == MAX_PLAYER_LEVEL ) then
			MainMenuExpBar:Hide();
			MainMenuBarMaxLevelBar:Show();
			ExhaustionTick:Hide();
		else
			MainMenuExpBar:Show();
			MainMenuBarMaxLevelBar:Hide();
		end
	end
	if ( visibilityChanged ) then
		UIParent_ManageFramePositions();
		updateContainerFrameAnchors();
	end
end

function ShowWatchedReputationBarText(lock)
	if ( lock ) then
		ReputationWatchBar.cvarLocked = lock;
	end
	if ( UnitLevel("player") == MAX_PLAYER_LEVEL and ReputationWatchBar:IsVisible() ) then
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
