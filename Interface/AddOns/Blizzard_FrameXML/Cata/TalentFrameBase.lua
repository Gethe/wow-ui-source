MAX_TALENT_GROUPS = 2;
MAX_TALENT_TABS = 3;
MAX_NUM_TALENT_TIERS = 7;
NUM_TALENT_COLUMNS = 4;
MAX_NUM_TALENTS = 28;
PLAYER_TALENTS_PER_TIER = 5;
PET_TALENTS_PER_TIER = 3;

DEFAULT_TALENT_TAB = 1;

TALENT_BUTTON_SIZE_DEFAULT = 32;
MAX_NUM_BRANCH_TEXTURES = 30;
MAX_NUM_ARROW_TEXTURES = 30;
INITIAL_TALENT_OFFSET_X_DEFAULT = 35;
INITIAL_TALENT_OFFSET_Y_DEFAULT = 20;
TALENT_GOLD_BORDER_WIDTH = 5;

TALENT_HYBRID_ICON = "Interface\\Icons\\Ability_DualWieldSpecialization";

local min = min;
local max = max;

function TalentFrame_Update(TalentFrame)
	if ( not TalentFrame ) then
		return;
	end

	local talentFrameName = TalentFrame:GetName();
	local selectedTab = PanelTemplates_GetSelectedTab(TalentFrame) or TalentFrame.talentTree;
	local preview = GetCVarBool("previewTalentsOption");
	local talentButtonSize = TalentFrame.talentButtonSize or TALENT_BUTTON_SIZE_DEFAULT;
	local initialOffsetX = TalentFrame.initialOffsetX or INITIAL_TALENT_OFFSET_X_DEFAULT;
	local initialOffsetY = TalentFrame.initialOffsetY or INITIAL_TALENT_OFFSET_Y_DEFAULT;
	local buttonSpacingX = TalentFrame.buttonSpacingX or (2*talentButtonSize-1);
	local buttonSpacingY = TalentFrame.buttonSpacingY or (2*talentButtonSize-1);
	
	-- get active talent group
	local isActiveTalentGroup;
	if ( TalentFrame.inspect ) then
		-- even though we have inspection data for more than one talent group, we're only showing one for now
		isActiveTalentGroup = true;
	else
		isActiveTalentGroup = TalentFrame.talentGroup == C_SpecializationInfo.GetActiveSpecGroup(TalentFrame.inspect, TalentFrame.pet);
	end
	-- Setup Frame
	local base;
	local id, name, description, icon, _, _, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(selectedTab, TalentFrame.inspect, TalentFrame.pet, nil, nil, TalentFrame.talentGroup);
	if ( name ) then
		base = "Interface\\TalentFrame\\"..background.."-";
	else
		-- temporary default for classes without talents poor guys
		base = "Interface\\TalentFrame\\MageFire-";
	end
	-- desaturate the background if this isn't the active talent group
	local backgroundPiece = _G[talentFrameName.."BackgroundTopLeft"];
	backgroundPiece:SetTexture(base.."TopLeft");
	SetDesaturation(backgroundPiece, not isActiveTalentGroup);
	backgroundPiece = _G[talentFrameName.."BackgroundTopRight"];
	backgroundPiece:SetTexture(base.."TopRight");
	SetDesaturation(backgroundPiece, not isActiveTalentGroup);
	backgroundPiece = _G[talentFrameName.."BackgroundBottomLeft"];
	backgroundPiece:SetTexture(base.."BottomLeft");
	SetDesaturation(backgroundPiece, not isActiveTalentGroup);
	backgroundPiece = _G[talentFrameName.."BackgroundBottomRight"];
	backgroundPiece:SetTexture(base.."BottomRight");
	SetDesaturation(backgroundPiece, not isActiveTalentGroup);

	local numTalents = GetNumTalents(selectedTab, TalentFrame.inspect, TalentFrame.pet);
	-- Just a reminder error if there are more talents than available buttons
	if ( numTalents > MAX_NUM_TALENTS ) then
		SetBasicMessageDialogText("Too many talents in talent frame!");
	end

	-- get unspent talent points
	local unspentPoints = TalentFrame_GetUnspentTalentPoints(TalentFrame);
	-- compute tab points spent if any
	local tabPointsSpent;
	if ( TalentFrame.pointsSpent and TalentFrame.previewPointsSpent ) then
		tabPointsSpent = TalentFrame.pointsSpent + TalentFrame.previewPointsSpent;
	else
		tabPointsSpent = pointsSpent + previewPointsSpent;
	end
	
	TalentFrame_ResetBranches(TalentFrame);
	local talentFrameTalentName = talentFrameName.."Talent";
	local forceDesaturated, tierUnlocked;
	for i=1, MAX_NUM_TALENTS do
		local button = _G[talentFrameTalentName..i];
		if ( i <= numTalents ) then
			-- Set the button info
			local talentInfoQuery = {};
			talentInfoQuery.specializationIndex = selectedTab;
			talentInfoQuery.talentIndex = i;
			talentInfoQuery.isInspect = TalentFrame.inspect;
			talentInfoQuery.isPet = TalentFrame.pet;
			talentInfoQuery.groupIndex = TalentFrame.talentGroup;
			local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);

			if ( talentInfo and talentInfo.tier <= MAX_NUM_TALENT_TIERS) then
				-- Temp hack - For now, we are just ignoring the "goldBorder" flag and putting the gold border on any "exceptional" talents.
				talentInfo.goldBorder = talentInfo.isExceptional;
			
				local displayRank;
				if ( preview ) then
					displayRank = talentInfo.previewRank;
				else
					displayRank = talentInfo.rank;
				end

				button.Rank:SetText(displayRank);
				SetTalentButtonLocation(button, talentInfo.tier, talentInfo.column, talentButtonSize, initialOffsetX, initialOffsetY, buttonSpacingX, buttonSpacingY);
				TalentFrame.TALENT_BRANCH_ARRAY[talentInfo.tier][talentInfo.column].id = button:GetID();
			
				-- If player has no talent points or this is the inactive talent group then show only talents with points in them
				if ( (unspentPoints <= 0 or not isActiveTalentGroup) and displayRank == 0 ) then
					forceDesaturated = 1;
				else
					forceDesaturated = nil;
				end

				-- is this talent's tier unlocked?
				if ( isUnlocked and ((talentInfo.tier - 1) * (TalentFrame.pet and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= tabPointsSpent) ) then
					tierUnlocked = 1;
				else
					tierUnlocked = nil;
				end
					
				SetItemButtonTexture(button, talentInfo.icon); 
				
				if (talentInfo.goldBorder and button.GoldBorder) then
					button.GoldBorder:Show();
					button.Slot:Hide();
					button.SlotShadow:Hide();
				else
					if (button.GoldBorder) then
						button.GoldBorder:Hide();
					end
					button.Slot:Show();
					button.SlotShadow:Show();
				end
				
				-- Talent must meet prereqs or the player must have no points to spend
				local prereqsSet =
					TalentFrame_SetPrereqs(TalentFrame, talentInfo.tier, talentInfo.column, forceDesaturated, tierUnlocked, preview,
					GetTalentPrereqs(selectedTab, i, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup));
				if ( prereqsSet and ((preview and talentInfo.meetsPreviewPrereq) or (not preview and talentInfo.meetsPrereq)) ) then
					SetItemButtonDesaturated(button, nil);
					button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
					button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
					button.RankBorder:Show();
					button.RankBorder:SetVertexColor(1, 1, 1);
					button.Rank:Show();
					
					button.GoldBorder:SetDesaturated(nil);

					if ( displayRank < talentInfo.maxRank ) then
						-- Rank is green if not maxed out
						button.Rank:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
						
						if (button.RankBorderGreen) then
							button.RankBorder:Hide();
							button.RankBorderGreen:Show();
							button.Slot:SetVertexColor(1.0, 0.82, 0);
						else
							button.Slot:SetVertexColor(0.1, 1.0, 0.1);
						end
						
						if (button.GlowBorder) then
							if (unspentPoints > 0 and not talentInfo.goldBorder) then
								button.GlowBorder:Show();
							else
								button.GlowBorder:Hide();
							end
						end
						
						if (button.GoldBorderGlow) then
							if (unspentPoints > 0 and talentInfo.goldBorder) then
								button.GoldBorderGlow:Show();
							else
								button.GoldBorderGlow:Hide();
							end
						end
					else
						button.Slot:SetVertexColor(1.0, 0.82, 0);
						button.Rank:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
						if (button.GlowBorder) then
							button.GlowBorder:Hide();
						end
						if (button.GoldBorderGlow) then
							button.GoldBorderGlow:Hide();
						end
						if (button.RankBorderGreen) then
							button.RankBorderGreen:Hide();
						end
					end
				else
					SetItemButtonDesaturated(button, 1);
					button:ClearPushedTexture();
					button:ClearHighlightTexture();
					button.GoldBorder:SetDesaturated(1);
					button.Slot:SetVertexColor(0.5, 0.5, 0.5);
					if ( talentInfo.rank == 0 ) then
						button.RankBorder:Hide();
						button.Rank:Hide();
					else
						button.RankBorder:SetVertexColor(0.5, 0.5, 0.5);
						button.Rank:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					end
					if (button.GlowBorder) then
						button.GlowBorder:Hide();
					end
					if (button.GoldBorderGlow) then
						button.GoldBorderGlow:Hide();
					end
					if (button.RankBorderGreen) then
						button.RankBorderGreen:Hide();
					end
				end
				
				TalentFrame.TALENT_BRANCH_ARRAY[talentInfo.tier][talentInfo.column].goldBorder = talentInfo.goldBorder;
				
				button:Show();
			else
				button:Hide();
			end
		else	
			if (button) then
				button:Hide();
			end
		end
	end

	-- Hide unused inspect talent buttons
	if ( TalentFrame.inspect ) then
		for i=MAX_NUM_TALENTS + 1, NUM_INSPECT_TALENT_SLOTS do
			local button = _G["InspectTalentFrameTalent"..i];
			button:Hide();
		end
	end

	-- Draw the prereq branches
	local node;
	local textureIndex = 1;
	local xOffset, yOffset;
	local texCoords;
	local tempNode;
	TalentFrame_ResetBranchTextureCount(TalentFrame);
	TalentFrame_ResetArrowTextureCount(TalentFrame);
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			node = TalentFrame.TALENT_BRANCH_ARRAY[i][j];
			
			-- Setup offsets
			xOffset = ((j - 1) * buttonSpacingX) + initialOffsetX + (TalentFrame.branchOffsetX or 0);
			yOffset = -((i - 1) * buttonSpacingY) - initialOffsetY + (TalentFrame.branchOffsetY or 0);
			
			-- Always draw Right and Down branches, never draw Left and Up branches as those will be drawn by the preceeding talent
			if ( node.down ~= 0 ) then
				TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - talentButtonSize, TalentFrame, talentButtonSize, buttonSpacingY - talentButtonSize);
			end
			if ( node.right ~= 0 ) then
				TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + talentButtonSize, yOffset, TalentFrame, buttonSpacingX - talentButtonSize, talentButtonSize);
			end
			
			if (node.id) then
				-- There is a talent in this slot; draw arrows
				local arrowInsetX, arrowInsetY = (TalentFrame.arrowInsetX or 0), (TalentFrame.arrowInsetY or 0);
				if (node.goldBorder) then
					arrowInsetX = arrowInsetX - TALENT_GOLD_BORDER_WIDTH;
					arrowInsetY = arrowInsetY - TALENT_GOLD_BORDER_WIDTH;
				end
				
				if ( node.rightArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + talentButtonSize/2 - arrowInsetX, yOffset, TalentFrame);
				end
				if ( node.leftArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - talentButtonSize/2 + arrowInsetX, yOffset, TalentFrame);
				end
				if ( node.topArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + talentButtonSize/2 - arrowInsetY, TalentFrame);
				end
			else
				-- No talent; draw branches
				if ( node.up ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset , yOffset, TalentFrame);
				elseif ( node.down ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset , yOffset, TalentFrame);
				elseif ( node.left ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset , yOffset, TalentFrame);
				elseif ( node.left ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset , yOffset, TalentFrame);
				elseif ( node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + talentButtonSize, yOffset, TalentFrame);
				elseif ( node.right ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset , yOffset, TalentFrame);
				elseif ( node.right ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset , yOffset, TalentFrame);
				elseif ( node.up ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset , yOffset, TalentFrame);
				end
			end
		end
	end
	-- Hide any unused branch textures
	for i=TalentFrame_GetBranchTextureCount(TalentFrame), MAX_NUM_BRANCH_TEXTURES do
		_G[talentFrameName.."Branch"..i]:Hide();
	end
	-- Hide and unused arrowl textures
	for i=TalentFrame_GetArrowTextureCount(TalentFrame), MAX_NUM_ARROW_TEXTURES do
		_G[talentFrameName.."Arrow"..i]:Hide();
	end
end

function TalentFrame_SetArrowTexture(tier, column, texCoords, xOffset, yOffset, TalentFrame)
	local talentFrameName = TalentFrame:GetName();
	local arrowTexture = TalentFrame_GetArrowTexture(TalentFrame);
	arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	arrowTexture:SetPoint("TOPLEFT", arrowTexture:GetParent(), "TOPLEFT", xOffset, yOffset);
end

function TalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset, TalentFrame, xSize, ySize)
	local talentFrameName = TalentFrame:GetName();
	local branchTexture = TalentFrame_GetBranchTexture(TalentFrame);
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	branchTexture:SetPoint("TOPLEFT", branchTexture:GetParent(), "TOPLEFT", xOffset, yOffset);
	branchTexture:SetWidth(xSize or TalentFrame.talentButtonSize or TALENT_BUTTON_SIZE_DEFAULT);
	branchTexture:SetHeight(ySize or TalentFrame.talentButtonSize or TALENT_BUTTON_SIZE_DEFAULT);
end

function TalentFrame_GetArrowTexture(TalentFrame)
	local talentFrameName = TalentFrame:GetName();
	local arrowTexture = _G[talentFrameName.."Arrow"..TalentFrame.arrowIndex];
	TalentFrame.arrowIndex = TalentFrame.arrowIndex + 1;
	if ( not arrowTexture ) then
		SetBasicMessageDialogText("Not enough arrow textures");
	else
		arrowTexture:Show();
		return arrowTexture;
	end
end

function TalentFrame_GetBranchTexture(TalentFrame)
	local talentFrameName = TalentFrame:GetName();
	local branchTexture = _G[talentFrameName.."Branch"..TalentFrame.textureIndex];
	TalentFrame.textureIndex = TalentFrame.textureIndex + 1;
	if ( not branchTexture ) then
		--branchTexture = CreateTexture("TalentFrameBranch"..TalentFrame.textureIndex);
		SetBasicMessageDialogText("Not enough branch textures");
	else
		branchTexture:Show();
		return branchTexture;
	end
end



function TalentFrame_SetPrereqs(TalentFrame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, preview, ...)
	local requirementsMet = tierUnlocked and not forceDesaturated;
	for i=1, select("#", ...), 4 do
		local tier, column, isLearnable, isPreviewLearnable = select(i, ...);
		if ( forceDesaturated or
			 (preview and not isPreviewLearnable) or
			 (not preview and not isLearnable) ) then
			requirementsMet = nil;
		end
		TalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet, TalentFrame);
	end
	return requirementsMet;
end






-- Helper functions

function TalentFrame_GetUnspentTalentPoints(TalentFrame)
	local talentPoints = GetUnspentTalentPoints(TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
	local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(TalentFrame.pet, TalentFrame.talentGroup);
	return unspentPoints;
end

function SetTalentButtonLocation(button, tier, column, talentButtonSize, initialOffsetX, initialOffsetY, buttonSpacingX, buttonSpacingY)
	column = ((column - 1) * (buttonSpacingX)) + initialOffsetX;
	tier = -((tier - 1) * (buttonSpacingY)) - initialOffsetY;
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", column, tier);
end

