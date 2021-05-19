NUM_FACTIONS_DISPLAYED = 15;
REPUTATIONFRAME_FACTIONHEIGHT = 26;
MAX_PLAYER_LEVEL = 0;
MAX_REPUTATION_REACTION = 8;

function ReputationFrame_OnLoad(self)
	ReputationWatchBar_UpdateMaxLevel();
end

function ReputationFrame_OnShow(self)
	ReputationFrame_Update();
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
end

function ReputationFrame_OnHide(self)
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:UnregisterEvent("UPDATE_FACTION");
end

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" or event == "QUEST_LOG_UPDATE" ) then
		ReputationFrame_Update();
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		ReputationWatchBar_UpdateMaxLevel();
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
	
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + i;
		local factionBar = _G["ReputationBar"..i];
		local factionHeader = _G["ReputationHeader"..i];
		local factionCheck = _G["ReputationBar"..i.."Check"];
		if ( factionIndex <= numFactions ) then
			local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex);
			if ( isHeader ) then
				factionHeader.Text:SetText(name);
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
				factionName = _G["ReputationBar"..i.."FactionName"];
				factionName:SetText(name);
				_G["ReputationBar"..i.."FactionStanding"]:SetText(factionStanding);
				
				atWarIndicator = _G["ReputationBar"..i.."AtWarCheck"];
				rightBarTexture = _G["ReputationBar"..i.."ReputationBarRight"];
				
				if ( atWarWith ) then
					atWarIndicator:Show();
			else
					atWarIndicator:Hide();
			end

				-- Normalize values
			barMax = barMax - barMin;
			barValue = barValue - barMin;
			barMin = 0;
				
				factionBar.index = factionIndex;
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
					_G["ReputationBar"..i.."Highlight1"]:Show();
					_G["ReputationBar"..i.."Highlight2"]:Show();
			else
					_G["ReputationBar"..i.."Highlight1"]:Hide();
					_G["ReputationBar"..i.."Highlight2"]:Hide();
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

function ReputationBar_OnClick(self)
	if ( ReputationDetailFrame:IsShown() and (GetSelectedFaction() == self.index) ) then
		ReputationDetailFrame:Hide();
	else
			SetSelectedFaction(self.index);
			ReputationDetailFrame:Show();
			ReputationFrame_Update();
		end
end

function ReputationWatchBar_UpdateMaxLevel()
	-- Initialize max player level
	MAX_PLAYER_LEVEL = GetMaxPlayerLevel();
end
