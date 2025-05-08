MAX_NUM_TALENT_TIERS = 6;
NUM_TALENT_COLUMNS = 3;



MAX_TALENT_GROUPS = 2;
MAX_TALENT_TABS = 4;
MAX_NUM_TALENTS = 18;

DEFAULT_TALENT_TAB = 1;

local min = min;
local max = max;

function TalentFrame_Clear(TalentFrame)
	if ( not TalentFrame ) then
		return;
	end

	for tier=1, MAX_NUM_TALENT_TIERS do
		for column=1, NUM_TALENT_COLUMNS do
			local button = TalentFrame["tier"..tier]["talent"..column];
			if(button ~= nil) then
				SetDesaturation(button.icon, true);
				button.border:Hide();
			end
		end
	end
end

function TalentFrame_Update(TalentFrame, talentUnit)
	if ( not TalentFrame ) then
		return;
	end

	-- have to disable stuff if not active talent group
	local disable;
	if ( TalentFrame.inspect ) then
		-- even though we have inspection data for more than one talent group, we're only showing one for now
		disable = false;
	else
		disable = ( TalentFrame.talentGroup ~= C_SpecializationInfo.GetActiveSpecGroup(TalentFrame.inspect) );
	end
	if(TalentFrame.bg ~= nil) then
		TalentFrame.bg:SetDesaturated(disable);
	end
	
	if (not TalentFrame.talentInfo) then
		TalentFrame.talentInfo = {};
	end

	local numTalentSelections = 0;
	for tier=1, MAX_NUM_TALENT_TIERS do
		local talentRow = TalentFrame["tier"..tier];
		local rowAvailable = true;
		
		local tierAvailable, selectedTalent, tierUnlockLevel = GetTalentTierInfo(tier, TalentFrame.talentGroup, TalentFrame.inspect, talentUnit);
		-- Skip updating rows that we recently selected a talent for but have not received a server response
		if (TalentFrame.inspect or not TalentFrame.talentInfo[tier] or
			(selectedTalent ~= 0 and TalentFrame.talentInfo[tier] == selectedTalent)) then
			
			if (not TalentFrame.inspect and selectedTalent ~= 0) then
				TalentFrame.talentInfo[tier] = nil;
			end
			
			local restartGlow = false;
			for column=1, NUM_TALENT_COLUMNS do
				-- Set the button info
				local talentInfoQuery = {};
				talentInfoQuery.tier = tier;
				talentInfoQuery.column= column;
				talentInfoQuery.groupIndex = TalentFrame.talentGroup;
				talentInfoQuery.isInspect = TalentFrame.inspect;
				talentInfoQuery.target = talentUnit;
				local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);

				local button = talentRow["talent"..column];
				button.tier = tier;
				button.column = column;

				if (button and talentInfo) then
					button:SetID(talentInfo.talentID);

					SetItemButtonTexture(button, talentInfo.icon);
					if(button.name ~= nil) then
						button.name:SetText(talentInfo.name);
					end

					if(button.knownSelection ~= nil) then
						if ( talentInfo.selected ) then
							button.knownSelection:Show();
							button.knownSelection:SetDesaturated(disable);
						else
							button.knownSelection:Hide();
						end
					end
					button.shouldGlow = (talentInfo.available and not talentInfo.selected) and talentUnit == "player";
					
					if( TalentFrame.inspect ) then
						SetDesaturation(button.icon, not talentInfo.selected);
						button.border:SetShown(talentInfo.selected);
					else
						button.disabled = (not tierAvailable or disable);
						SetDesaturation(button.icon, (button.disabled or (selectedTalent ~= 0 and not talentInfo.selected)));
						button.highlight:SetAlpha((selected or not tierAvailable) and 0 or 1);
						button.learnSelection:SetShown((talentInfo.available and not disable) and (talentRow.selectionId == talentInfo.talentID));
						if (button.learnSelection:IsShown()) then
							numTalentSelections = numTalentSelections + 1;
						end
					end
					
					button:Show();
				elseif (button) then
					button:Hide();
				end
			end
			
			-- do tier level number after every row
			if(talentRow.level ~= nil) then
				talentRow.level:SetText(tierUnlockLevel);

				if ( selectedTalent == 0 and tierAvailable) then
					talentRow.level:SetTextColor(1, 0.82, 0);
				else
					talentRow.level:SetTextColor(0.5, 0.5, 0.5);
				end
			end
		end
	end
	if(TalentFrame.learnButton ~= nil) then
		if ( numTalentSelections > 0 ) then
			TalentFrame.learnButton:Enable();
			TalentFrame.learnButton.Flash:Show();
			TalentFrame.learnButton.FlashAnim:Play();
		else
			TalentFrame.learnButton:Disable();
			TalentFrame.learnButton.Flash:Hide();
			TalentFrame.learnButton.FlashAnim:Stop();
		end
	end
	if(TalentFrame.unspentText ~= nil) then
		local numUnspentTalents = GetNumUnspentTalents();
		if ( not disable and numUnspentTalents > 0 ) then
			TalentFrame.unspentText:SetFormattedText(PLAYER_UNSPENT_TALENT_POINTS, numUnspentTalents);
		else
			TalentFrame.unspentText:SetText("");
		end
	end
end
