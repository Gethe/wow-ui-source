MAX_TALENT_GROUPS = 2;
MAX_TALENT_TABS = 3;
MAX_NUM_TALENT_TIERS = 7;
NUM_TALENT_COLUMNS = 4;
MAX_NUM_TALENTS = 28;
PLAYER_TALENTS_PER_TIER = 5;
PET_TALENTS_PER_TIER = 3;

DEFAULT_TALENT_SPEC = "spec1";
DEFAULT_TALENT_TAB = 1;

TALENT_BUTTON_SIZE_DEFAULT = 32;
MAX_NUM_BRANCH_TEXTURES = 30;
MAX_NUM_ARROW_TEXTURES = 30;
INITIAL_TALENT_OFFSET_X_DEFAULT = 35;
INITIAL_TALENT_OFFSET_Y_DEFAULT = 20;
TALENT_GOLD_BORDER_WIDTH = 5;

TALENT_HYBRID_ICON = "Interface\\Icons\\Ability_DualWieldSpecialization";

TALENT_BRANCH_TEXTURECOORDS = {
	up = {
		[1] = {0.12890625, 0.25390625, 0 , 0.484375},
		[-1] = {0.12890625, 0.25390625, 0.515625 , 1.0}
	},
	down = {
		[1] = {0, 0.125, 0, 0.484375},
		[-1] = {0, 0.125, 0.515625, 1.0}
	},
	left = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	right = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	topright = {
		[1] = {0.515625, 0.640625, 0, 0.5},
		[-1] = {0.515625, 0.640625, 0.5, 1.0}
	},
	topleft = {
		[1] = {0.640625, 0.515625, 0, 0.5},
		[-1] = {0.640625, 0.515625, 0.5, 1.0}
	},
	bottomright = {
		[1] = {0.38671875, 0.51171875, 0, 0.5},
		[-1] = {0.38671875, 0.51171875, 0.5, 1.0}
	},
	bottomleft = {
		[1] = {0.51171875, 0.38671875, 0, 0.5},
		[-1] = {0.51171875, 0.38671875, 0.5, 1.0}
	},
	tdown = {
		[1] = {0.64453125, 0.76953125, 0, 0.5},
		[-1] = {0.64453125, 0.76953125, 0.5, 1.0}
	},
	tup = {
		[1] = {0.7734375, 0.8984375, 0, 0.5},
		[-1] = {0.7734375, 0.8984375, 0.5, 1.0}
	},
};

TALENT_ARROW_TEXTURECOORDS = {
	top = {
		[1] = {0, 0.5, 0, 0.5},
		[-1] = {0, 0.5, 0.5, 1.0}
	},
	right = {
		[1] = {1.0, 0.5, 0, 0.5},
		[-1] = {1.0, 0.5, 0.5, 1.0}
	},
	left = {
		[1] = {0.5, 1.0, 0, 0.5},
		[-1] = {0.5, 1.0, 0.5, 1.0}
	},
};


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
		isActiveTalentGroup = TalentFrame.talentGroup == GetActiveTalentGroup(TalentFrame.inspect, TalentFrame.pet);
	end
	-- Setup Frame
	local base;
	local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(selectedTab, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
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
		message("Too many talents in talent frame!");
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
			local name, iconTexture, tier, column, rank, maxRank, meetsPrereq, previewRank, meetsPreviewPrereq, isExceptional, goldBorder =
				GetTalentInfo(selectedTab, i, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
				
			-- Temp hack - For now, we are just ignoring the "goldBorder" flag and putting the gold border on any "exceptional" talents
			goldBorder = isExceptional;
			
			if ( name and tier <= MAX_NUM_TALENT_TIERS) then
				local displayRank;
				if ( preview ) then
					displayRank = previewRank;
				else
					displayRank = rank;
				end

				button.Rank:SetText(displayRank);
				SetTalentButtonLocation(button, tier, column, talentButtonSize, initialOffsetX, initialOffsetY, buttonSpacingX, buttonSpacingY);
				TalentFrame.TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();
			
				-- If player has no talent points or this is the inactive talent group then show only talents with points in them
				if ( (unspentPoints <= 0 or not isActiveTalentGroup) and displayRank == 0 ) then
					forceDesaturated = 1;
				else
					forceDesaturated = nil;
				end

				-- is this talent's tier unlocked?
				if ( isUnlocked and ((tier - 1) * (TalentFrame.pet and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= tabPointsSpent) ) then
					tierUnlocked = 1;
				else
					tierUnlocked = nil;
				end
					
				SetItemButtonTexture(button, iconTexture); 
				
				if (goldBorder and button.GoldBorder) then
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
					TalentFrame_SetPrereqs(TalentFrame, tier, column, forceDesaturated, tierUnlocked, preview,
					GetTalentPrereqs(selectedTab, i, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup));
				if ( prereqsSet and ((preview and meetsPreviewPrereq) or (not preview and meetsPrereq)) ) then
					SetItemButtonDesaturated(button, nil);
					
					button.RankBorder:Show();
					button.RankBorder:SetVertexColor(1, 1, 1);
					button.Rank:Show();
					
					button.GoldBorder:SetDesaturated(nil);

					if ( displayRank < maxRank ) then
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
							if (unspentPoints > 0 and not goldBorder) then
								button.GlowBorder:Show();
							else
								button.GlowBorder:Hide();
							end
						end
						
						if (button.GoldBorderGlow) then
							if (unspentPoints > 0 and goldBorder) then
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
					button.GoldBorder:SetDesaturated(1);
					button.Slot:SetVertexColor(0.5, 0.5, 0.5);
					if ( rank == 0 ) then
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
				
				TalentFrame.TALENT_BRANCH_ARRAY[tier][column].goldBorder = goldBorder;
				
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
		message("Not enough arrow textures");
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
		message("Not enough branch textures");
	else
		branchTexture:Show();
		return branchTexture;
	end
end

function TalentFrame_ResetArrowTextureCount(TalentFrame)
	TalentFrame.arrowIndex = 1;
end

function TalentFrame_ResetBranchTextureCount(TalentFrame)
	TalentFrame.textureIndex = 1;
end

function TalentFrame_GetArrowTextureCount(TalentFrame)
	return TalentFrame.arrowIndex;
end

function TalentFrame_GetBranchTextureCount(TalentFrame)
	return TalentFrame.textureIndex;
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


function TalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet, TalentFrame)
	if ( requirementsMet ) then
		requirementsMet = 1;
	else
		requirementsMet = -1;
	end
	
	-- Check to see if are in the same column
	if ( buttonColumn == column ) then
		-- Check for blocking talents
		if ( (buttonTier - tier) > 1 ) then
			-- If more than one tier difference
			for i=tier + 1, buttonTier - 1 do
				if ( TalentFrame.TALENT_BRANCH_ARRAY[i][buttonColumn].id ) then
					-- If there's an id, there's a blocker
					message("Error this layout is blocked vertically "..TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][i].id);
					return;
				end
			end
		end
		
		-- Draw the lines
		for i=tier, buttonTier - 1 do
			TalentFrame.TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
			if ( (i + 1) <= (buttonTier - 1) ) then
				TalentFrame.TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
			end
		end
		
		-- Set the arrow
		TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
		return;
	end
	-- Check to see if they're in the same tier
	if ( buttonTier == tier ) then
		local left = min(buttonColumn, column);
		local right = max(buttonColumn, column);
		
		-- See if the distance is greater than one space
		if ( (right - left) > 1 ) then
			-- Check for blocking talents
			for i=left + 1, right - 1 do
				if ( TalentFrame.TALENT_BRANCH_ARRAY[tier][i].id ) then
					-- If there's an id, there's a blocker
					message("there's a blocker "..tier.." "..i);
					return;
				end
			end
		end
		-- If we get here then we're in the clear
		for i=left, right - 1 do
			TalentFrame.TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
			TalentFrame.TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
		end
		-- Determine where the arrow goes
		if ( buttonColumn < column ) then
			TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow = requirementsMet;
		else
			TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow = requirementsMet;
		end
		return;
	end
	-- Now we know the prereq is diagonal from us
	local left = min(buttonColumn, column);
	local right = max(buttonColumn, column);
	-- Don't check the location of the current button
	if ( left == column ) then
		left = left + 1;
	else
		right = right - 1;
	end
	-- Check for blocking talents
	local blocked = nil;
	for i=left, right do
		if ( TalentFrame.TALENT_BRANCH_ARRAY[tier][i].id ) then
			-- If there's an id, there's a blocker
			blocked = 1;
		end
	end
	left = min(buttonColumn, column);
	right = max(buttonColumn, column);
	if ( not blocked ) then
		TalentFrame.TALENT_BRANCH_ARRAY[tier][buttonColumn].down = requirementsMet;
		TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].up = requirementsMet;
		
		for i=tier, buttonTier - 1 do
			TalentFrame.TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
			TalentFrame.TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
		end

		for i=left, right - 1 do
			TalentFrame.TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
			TalentFrame.TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
		end
		-- Place the arrow
		TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
		return;
	end
	-- If we're here then we were blocked trying to go vertically first so we have to go over first, then up
	if ( left == buttonColumn ) then
		left = left + 1;
	else
		right = right - 1;
	end
	-- Check for blocking talents
	for i=left, right do
		if ( TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][i].id ) then
			-- If there's an id, then throw an error
			message("Error, this layout is undrawable "..TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][i].id);
			return;
		end
	end
	-- If we're here we can draw the line
	left = min(buttonColumn, column);
	right = max(buttonColumn, column);
	--TALENT_BRANCH_ARRAY[tier][column].down = requirementsMet;
	--TALENT_BRANCH_ARRAY[buttonTier][column].up = requirementsMet;

	for i=tier, buttonTier-1 do
		TalentFrame.TALENT_BRANCH_ARRAY[i][column].up = requirementsMet;
		TalentFrame.TALENT_BRANCH_ARRAY[i+1][column].down = requirementsMet;
	end

	-- Determine where the arrow goes
	if ( buttonColumn < column ) then
		TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow =  requirementsMet;
	else
		TalentFrame.TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow =  requirementsMet;
	end
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

function TalentFrame_ResetBranches(TalentFrame)
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].id = nil;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].up = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].down = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].left = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].right = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].rightArrow = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].leftArrow = 0;
			TalentFrame.TALENT_BRANCH_ARRAY[i][j].topArrow = 0;
		end
	end
end

local sortedTabPointsSpentBuf = { };
function TalentFrame_UpdateSpecInfoCache(cache, inspect, pet, talentGroup)
	-- initialize some cache info
	cache.primaryTabIndex = 0;
	cache.totalPointsSpent = 0;

	local preview = GetCVarBool("previewTalentsOption");

	local highPointsSpent = 0;
	local highPointsSpentIndex;
	local lowPointsSpent = huge;
	local lowPointsSpentIndex;

	local numTabs = GetNumTalentTabs(inspect, pet);
	cache.numTabs = numTabs;
	for i = 1, MAX_TALENT_TABS do
		cache[i] = cache[i] or { };
		if ( i <= numTabs ) then
			local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(i, inspect, pet, talentGroup);

			local displayPointsSpent = pointsSpent + previewPointsSpent;

			-- cache the info we care about
			cache[i].name = name;
			cache[i].pointsSpent = displayPointsSpent;
			cache[i].icon = icon;

			-- update total points
			cache.totalPointsSpent = cache.totalPointsSpent + displayPointsSpent;

			-- update the high and low points spent info
			if ( displayPointsSpent > highPointsSpent ) then
				highPointsSpent = displayPointsSpent;
				highPointsSpentIndex = i;
			end
			if ( displayPointsSpent < lowPointsSpent ) then
				lowPointsSpent = displayPointsSpent;
				lowPointsSpentIndex = i;
			end

			-- initialize the points spent buffer element
			sortedTabPointsSpentBuf[i] = 0;
			-- insert the points spent into our buffer in ascending order
			local insertIndex = i;
			for j = 1, i, 1 do
				local currPointsSpent = sortedTabPointsSpentBuf[j];
				if ( currPointsSpent > displayPointsSpent ) then
					insertIndex = j;
					break;
				end
			end
			for j = i, insertIndex + 1, -1 do
				sortedTabPointsSpentBuf[j] = sortedTabPointsSpentBuf[j - 1];
			end
			sortedTabPointsSpentBuf[insertIndex] = displayPointsSpent;
		else
			cache[i].name = nil;
		end
	end

	if ( highPointsSpentIndex and lowPointsSpentIndex ) then
		-- now that our points spent buffer is filled, we can compute the mid points spent
		local midPointsSpentIndex = rshift(numTabs, 1) + 1;
		local midPointsSpent = sortedTabPointsSpentBuf[midPointsSpentIndex];
		-- now let's use our crazy formula to determine which tab is the primary one
		if ( 3*(midPointsSpent-lowPointsSpent) < 2*(highPointsSpent-lowPointsSpent) ) then
			cache.primaryTabIndex = highPointsSpentIndex;
		end
	end
end

