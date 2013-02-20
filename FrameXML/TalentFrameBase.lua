MAX_NUM_TALENT_TIERS = 6;
NUM_TALENT_COLUMNS = 3;



MAX_TALENT_GROUPS = 2;
MAX_TALENT_TABS = 4;
MAX_NUM_TALENTS = 18;

DEFAULT_TALENT_SPEC = "spec1";
DEFAULT_TALENT_TAB = 1;

local min = min;
local max = max;
local huge = math.huge;
local rshift = bit.rshift;

function TalentFrame_Load(TalentFrame)
	TalentFrame.TALENT_BRANCH_ARRAY={};
	for i=1, MAX_NUM_TALENT_TIERS do
		TalentFrame.TALENT_BRANCH_ARRAY[i] = {};
		for j=1, NUM_TALENT_COLUMNS do
			TalentFrame.TALENT_BRANCH_ARRAY[i][j] = {id=nil, up=0, left=0, right=0, down=0, leftArrow=0, rightArrow=0, topArrow=0};
		end
	end
end

function TalentFrame_Clear(TalentFrame)
	if ( not TalentFrame ) then
		return;
	end

	for tier=1, 6 do
		for column=1, 3 do
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

	local numTalents = GetNumTalents(TalentFrame.inspect);
	-- Just a reminder error if there are more talents than available buttons
	if ( numTalents > MAX_NUM_TALENTS ) then
		message("Too many talents in talent frame!");
	end

	-- have to disable stuff if not active talent group
	local disable;
	if ( TalentFrame.inspect ) then
		-- even though we have inspection data for more than one talent group, we're only showing one for now
		disable = false;
	else
		disable = ( TalentFrame.talentGroup ~= GetActiveSpecGroup(TalentFrame.inspect) );
	end
	if(TalentFrame.bg ~= nil) then
		TalentFrame.bg:SetDesaturated(disable);
	end
	
	local classDisplayName, class, classID;
	if( TalentFrame.inspect ) then
		 classDisplayName, class, classID = UnitClass(talentUnit); 
	end
	
	local rowAvailable = true;
	local numTalentSelections = 0;
	for i=1, MAX_NUM_TALENTS do
		if ( i <= numTalents ) then
			-- Set the button info
			local name, iconTexture, tier, column, selected, available = GetTalentInfo(i, TalentFrame.inspect, TalentFrame.talentGroup, talentUnit, classID);
			local button = TalentFrame["tier"..tier]["talent"..column];
			local talentRow = TalentFrame["tier"..tier];
			
			if (button and name and tier <= MAX_NUM_TALENT_TIERS) then
				button:SetID(i);

				SetItemButtonTexture(button, iconTexture);
				if(button.name ~= nil) then
					button.name:SetText(name);
				end
				
				if(button.knownSelection ~= nil) then
					if( selected ) then
						button.knownSelection:Show();
						button.knownSelection:SetDesaturated(disable);
					else
						button.knownSelection:Hide();
					end
				end
				
				if( TalentFrame.inspect ) then
					if ( selected ) then
						SetDesaturation(button.icon, false);
						--button.highlight:SetAlpha(1);
						button.border:Show();
					else
						SetDesaturation(button.icon, true);
						--button.highlight:SetAlpha(0);
						button.border:Hide();
					end
				else
					if ( not available or disable ) then
						SetDesaturation(button.icon, true);
						button.highlight:SetAlpha(0);
						button.learnSelection:Hide();
						rowAvailable = false;
					else
						SetDesaturation(button.icon, false);
						button.highlight:SetAlpha(1);
						if ( talentRow.selectionId == i ) then
							button.learnSelection:Show();
							numTalentSelections = numTalentSelections + 1;
						else
							button.learnSelection:Hide();
						end
					end
				end
				
				button:Show();
			elseif (button) then
				button:Hide();
			end

			-- do tier level number after every row
			if(talentRow.level ~= nil) then
				if ( mod(i, NUM_TALENT_COLUMNS) == 0 ) then
					if ( rowAvailable ) then
						talentRow.level:SetTextColor(1, 0.82, 0);
					else
						talentRow.level:SetTextColor(0.5, 0.5, 0.5);
					end
					rowAvailable = true;
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


function TalentFrame_UpdateSpecInfoCache(cache, inspect, pet, talentGroup)
	-- initialize some cache info
	cache.primaryTabIndex = 0;

	local numTabs = GetNumSpecializations(inspect);
	cache.numTabs = numTabs;
	for i = 1, MAX_TALENT_TABS do
		cache[i] = cache[i] or { };
		if ( i <= numTabs ) then
			local id, name, description, icon, background = GetSpecializationInfo(i, inspect);

			-- cache the info we care about
			cache[i].name = name;
			cache[i].icon = icon;
		else
			cache[i].name = nil;
		end
	end
end

