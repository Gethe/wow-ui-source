MAX_TALENT_GROUPS = 2;
MAX_TALENT_TABS = 3;
MAX_NUM_TALENT_TIERS = 15;
NUM_TALENT_COLUMNS = 4;
MAX_NUM_TALENTS = 40;
PLAYER_TALENTS_PER_TIER = 5;
PET_TALENTS_PER_TIER = 3;

DEFAULT_TALENT_SPEC = "spec1";
DEFAULT_TALENT_TAB = 1;

TALENT_BUTTON_SIZE = 32;
MAX_NUM_BRANCH_TEXTURES = 30;
MAX_NUM_ARROW_TEXTURES = 30;
INITIAL_TALENT_OFFSET_X = 35;
INITIAL_TALENT_OFFSET_Y = 20;






function TalentFrame_Update(TalentFrame)
	if ( not TalentFrame ) then
		return;
	end

	if ( TalentFrame.updateFunction ) then
		TalentFrame.updateFunction();
	end

	local talentFrameName = TalentFrame:GetName();
	local selectedTab = PanelTemplates_GetSelectedTab(TalentFrame);
	local preview = GetCVarBool("previewTalentsOption");

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
	local _, name, _, icon, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(selectedTab, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
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
	local unspentPoints = TalentFrame_UpdateTalentPoints(TalentFrame);
	-- compute tab points spent if any
	local tabPointsSpent;
	if ( TalentFrame.pointsSpent and TalentFrame.previewPointsSpent ) then
		tabPointsSpent = TalentFrame.pointsSpent + TalentFrame.previewPointsSpent;
	else
		tabPointsSpent = 0;
	end

	TalentFrame_ResetBranches(TalentFrame);
	local talentFrameTalentName = talentFrameName.."Talent";
	local forceDesaturated, tierUnlocked;
	for i=1, MAX_NUM_TALENTS do
		local buttonName = talentFrameTalentName..i;
		local button = _G[buttonName];
		if ( i <= numTalents ) then
			-- Set the button info
			local talentName, iconTexture, tier, column, rank, maxRank, meetsPrereq, previewRank, meetsPreviewPrereq, isExceptional =
				GetTalentInfo(selectedTab, i, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
			if ( talentName ) then
				local displayRank;
				if ( preview ) then
					displayRank = previewRank;
				else
					displayRank = rank;
				end

				_G[buttonName.."Rank"]:SetText(displayRank);
				SetTalentButtonLocation(button, tier, column);
				TalentFrame.TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();
			
				-- If player has no talent points or this is the inactive talent group then show only talents with points in them
				if ( (unspentPoints <= 0 or not isActiveTalentGroup) and displayRank == 0 ) then
				forceDesaturated = 1;
			else
				forceDesaturated = nil;
			end

			-- is this talent's tier unlocked?
			if ( ((tier - 1) * (TalentFrame.pet and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= tabPointsSpent) ) then
				tierUnlocked = 1;
			else
				tierUnlocked = nil;
			end

			SetItemButtonTexture(button, iconTexture);

			-- Talent must meet prereqs or the player must have no points to spend
			local prereqsSet =
				TalentFrame_SetPrereqs(TalentFrame, tier, column, forceDesaturated, tierUnlocked, preview,
				GetTalentPrereqs(selectedTab, i, TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup));
			if ( prereqsSet and ((preview and meetsPreviewPrereq) or (not preview and meetsPrereq)) ) then
				SetItemButtonDesaturated(button, nil);

				if ( displayRank < maxRank ) then
				-- Rank is green if not maxed out
					_G[buttonName.."Slot"]:SetVertexColor(0.1, 1.0, 0.1);
					_G[buttonName.."Rank"]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					_G[buttonName.."Slot"]:SetVertexColor(1.0, 0.82, 0);
					_G[buttonName.."Rank"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				_G[buttonName.."RankBorder"]:Show();
				_G[buttonName.."Rank"]:Show();
			else
				SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65);
					_G[buttonName.."Slot"]:SetVertexColor(0.5, 0.5, 0.5);
				if ( rank == 0 ) then
						_G[buttonName.."RankBorder"]:Hide();
						_G[buttonName.."Rank"]:Hide();
				else
						_G[buttonName.."RankBorder"]:SetVertexColor(0.5, 0.5, 0.5);
						_G[buttonName.."Rank"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end
			end
			button:Show();
			else
				button:Hide();
			end
		else	
			button:Hide();
		end
	end

	-- Draw the prereq branches
	local node;
	local textureIndex = 1;
	local xOffset, yOffset;
	local texCoords;
	-- Variable that decides whether or not to ignore drawing pieces
	local ignoreUp;
	local tempNode;
	TalentFrame_ResetBranchTextureCount(TalentFrame);
	TalentFrame_ResetArrowTextureCount(TalentFrame);
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			node = TalentFrame.TALENT_BRANCH_ARRAY[i][j];
			
			-- Setup offsets
			xOffset = ((j - 1) * 63) + INITIAL_TALENT_OFFSET_X + 2;
			yOffset = -((i - 1) * 63) - INITIAL_TALENT_OFFSET_Y - 2;
		
			if ( node.id ) then
				-- Has talent
				if ( node.up ~= 0 ) then
					if ( not ignoreUp ) then
						TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + TALENT_BUTTON_SIZE, TalentFrame);
					else
						ignoreUp = nil;
					end
				end
				if ( node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - TALENT_BUTTON_SIZE + 1, TalentFrame);
				end
				if ( node.left ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - TALENT_BUTTON_SIZE, yOffset, TalentFrame);
				end
				if ( node.right ~= 0 ) then
					-- See if any connecting branches are gray and if so color them gray
					tempNode = TalentFrame.TALENT_BRANCH_ARRAY[i][j+1];	
					if ( tempNode.left ~= 0 and tempNode.down < 0 ) then
						TalentFrame_SetBranchTexture(i, j-1, TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + TALENT_BUTTON_SIZE, yOffset, TalentFrame);
					else
						TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE + 1, yOffset, TalentFrame);
					end
					
				end
				-- Draw arrows
				if ( node.rightArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + TALENT_BUTTON_SIZE/2 + 5, yOffset, TalentFrame);
				end
				if ( node.leftArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - TALENT_BUTTON_SIZE/2 - 5, yOffset, TalentFrame);
				end
				if ( node.topArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + TALENT_BUTTON_SIZE/2 + 5, TalentFrame);
				end
			else
				-- Doesn't have a talent
				if ( node.up ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset , yOffset, TalentFrame);
				elseif ( node.down ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset , yOffset, TalentFrame);
				elseif ( node.left ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset , yOffset, TalentFrame);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32, TalentFrame);
				elseif ( node.left ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset , yOffset, TalentFrame);
				elseif ( node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE, yOffset, TalentFrame);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset, TalentFrame);
				elseif ( node.right ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset , yOffset, TalentFrame);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32, TalentFrame);
				elseif ( node.right ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset , yOffset, TalentFrame);
				elseif ( node.up ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset , yOffset, TalentFrame);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32, TalentFrame);
					ignoreUp = 1;
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
	arrowTexture:SetPoint("TOPLEFT", talentFrameName.."ArrowFrame", "TOPLEFT", xOffset, yOffset);
end

function TalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset, TalentFrame)
	local talentFrameName = TalentFrame:GetName();
	local branchTexture = TalentFrame_GetBranchTexture(TalentFrame);
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	branchTexture:SetPoint("TOPLEFT", talentFrameName.."ScrollChildFrame", "TOPLEFT", xOffset, yOffset);
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

function TalentFrame_UpdateTalentPoints(TalentFrame)
	local talentPoints = GetUnspentTalentPoints(TalentFrame.inspect, TalentFrame.pet, TalentFrame.talentGroup);
	local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(TalentFrame.pet, TalentFrame.talentGroup);
	local talentFrameName = TalentFrame:GetName();
	_G[talentFrameName.."TalentPointsText"]:SetFormattedText(UNSPENT_TALENT_POINTS, HIGHLIGHT_FONT_COLOR_CODE..unspentPoints..FONT_COLOR_CODE_CLOSE);
	TalentFrame_ResetBranches(TalentFrame);
	_G[talentFrameName.."ScrollFrameScrollBarScrollDownButton"]:SetScript("OnClick", _G[talentFrameName.."DownArrow_OnClick"]);
	return unspentPoints;
end

function SetTalentButtonLocation(button, tier, column)
	column = ((column - 1) * 63) + INITIAL_TALENT_OFFSET_X;
	tier = -((tier - 1) * 63) - INITIAL_TALENT_OFFSET_Y;
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", column, tier);
end

