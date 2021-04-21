MAX_TALENT_TABS = 5;
MAX_NUM_TALENT_TIERS = 10;
NUM_TALENT_COLUMNS = 4;
MAX_NUM_TALENTS = 40;

TALENT_BUTTON_SIZE = 32;
MAX_NUM_BRANCH_TEXTURES = 30;
MAX_NUM_ARROW_TEXTURES = 30;
INITIAL_TALENT_OFFSET_X = 35;
INITIAL_TALENT_OFFSET_Y = 20;

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

	if ( TalentFrame.updateFunction ) then
		TalentFrame.updateFunction();
	end

	if ( TalentFrame.inspect ) then
		TalentFrame.talentPoints = 0;
	else
		TalentFrame_UpdateTalentPoints(TalentFrame);
	end

	-- Setup Frame
	local base;
	local name, texture, points, fileName = GetTalentTabInfo(TalentFrame.currentSelectedTab, TalentFrame.inspect);
	if ( name ) then
		base = "Interface\\TalentFrame\\"..fileName.."-";
	else
		-- temporary default for classes without talents poor guys
		base = "Interface\\TalentFrame\\MageFire-";
	end
	
	getglobal(TalentFrame:GetName().."BackgroundTopLeft"):SetTexture(base.."TopLeft");
	getglobal(TalentFrame:GetName().."BackgroundTopRight"):SetTexture(base.."TopRight");
	getglobal(TalentFrame:GetName().."BackgroundBottomLeft"):SetTexture(base.."BottomLeft");
	getglobal(TalentFrame:GetName().."BackgroundBottomRight"):SetTexture(base.."BottomRight");
	
	local numTalents = GetNumTalents(TalentFrame.currentSelectedTab, TalentFrame.inspect);
	-- Just a reminder error if there are more talents than available buttons
	if ( numTalents > MAX_NUM_TALENTS ) then
		message("Too many talents in talent frame!");
	end

	TalentFrame_ResetBranches(TalentFrame);
	local forceDesaturated, tierUnlocked;
	for i=1, MAX_NUM_TALENTS do
		local button = getglobal(TalentFrame:GetName().."Talent"..i);
		if ( i <= numTalents ) then
			-- Set the button info
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(TalentFrame.currentSelectedTab, i, TalentFrame.inspect);
			getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):SetText(rank);
			SetTalentButtonLocation(button, tier, column);
			TalentFrame.TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();
			
			-- If player has no talent points then show only talents with points in them
			if ( (TalentFrame.talentPoints <= 0 and rank == 0)  ) then
				forceDesaturated = 1;
			else
				forceDesaturated = nil;
			end

			-- If the player has spent at least 5 talent points in the previous tier
			if ( ( (tier - 1) * 5 <= TalentFrame.pointsSpent ) ) then
				tierUnlocked = 1;
			else
				tierUnlocked = nil;
			end
			SetItemButtonTexture(button, iconTexture);
	
			-- Talent must meet prereqs or the player must have no points to spend
			if ( TalentFrame_SetPrereqs(TalentFrame, tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(TalentFrame.currentSelectedTab, i, TalentFrame.inspect)) and meetsPrereq ) then
				SetItemButtonDesaturated(button, nil);
				
				if ( rank < maxRank ) then
					-- Rank is green if not maxed out
					getglobal(TalentFrame:GetName().."Talent"..i.."Slot"):SetVertexColor(0.1, 1.0, 0.1);
					getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					getglobal(TalentFrame:GetName().."Talent"..i.."Slot"):SetVertexColor(1.0, 0.82, 0);
					getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				getglobal(TalentFrame:GetName().."Talent"..i.."RankBorder"):Show();
				getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):Show();
			else
				SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65);
				getglobal(TalentFrame:GetName().."Talent"..i.."Slot"):SetVertexColor(0.5, 0.5, 0.5);
				if ( rank == 0 ) then
					getglobal(TalentFrame:GetName().."Talent"..i.."RankBorder"):Hide();
					getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):Hide();
				else
					getglobal(TalentFrame:GetName().."Talent"..i.."RankBorder"):SetVertexColor(0.5, 0.5, 0.5);
					getglobal(TalentFrame:GetName().."Talent"..i.."Rank"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end
			end
			
			button:Show();
		else	
			button:Hide();
		end
	end
	
	-- Draw the prerq branches
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
		getglobal(TalentFrame:GetName().."Branch"..i):Hide();
	end
	-- Hide and unused arrowl textures
	for i=TalentFrame_GetArrowTextureCount(TalentFrame), MAX_NUM_ARROW_TEXTURES do
		getglobal(TalentFrame:GetName().."Arrow"..i):Hide();
	end
end

function TalentFrame_SetArrowTexture(tier, column, texCoords, xOffset, yOffset, TalentFrame)
	local arrowTexture = TalentFrame_GetArrowTexture(TalentFrame);
	arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	arrowTexture:SetPoint("TOPLEFT", TalentFrame:GetName().."ArrowFrame", "TOPLEFT", xOffset, yOffset);
end

function TalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset, TalentFrame)
	local branchTexture = TalentFrame_GetBranchTexture(TalentFrame);
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	branchTexture:SetPoint("TOPLEFT", TalentFrame:GetName().."ScrollChildFrame", "TOPLEFT", xOffset, yOffset);
end

function TalentFrame_GetArrowTexture(TalentFrame)
	local arrowTexture = getglobal(TalentFrame:GetName().."Arrow"..TalentFrame.arrowIndex);
	TalentFrame.arrowIndex = TalentFrame.arrowIndex + 1;
	if ( not arrowTexture ) then
		message("Not enough arrow textures");
	else
		arrowTexture:Show();
		return arrowTexture;
	end
end

function TalentFrame_GetBranchTexture(TalentFrame)
	local branchTexture = getglobal(TalentFrame:GetName().."Branch"..TalentFrame.textureIndex);
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

function TalentFrame_SetPrereqs(TalentFrame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
	local tier, column, isLearnable;
	local requirementsMet;
	if ( tierUnlocked and not forceDesaturated ) then
		requirementsMet = 1;
	else
		requirementsMet = nil;
	end
	for i=1, select("#", ...), 3 do
		tier, column, isLearnable = select(i, ...);
		if ( not isLearnable or forceDesaturated ) then
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
					message("Error this layout is blocked vertically "..TalentFrame.TALENT_BRANCH_ARRAY[i][buttonColumn].id);
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
					message("there's a blocker");
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

function TalentFrame_UpdateTalentPoints(TalentFrame)
	local talentPoints = UnitCharacterPoints(TalentFrame.unit);
	getglobal(TalentFrame:GetName().."TalentPointsText"):SetText(talentPoints);
	TalentFrame.talentPoints = talentPoints;
	TalentFrame_ResetBranches(TalentFrame);
	getglobal(TalentFrame:GetName().."ScrollFrameScrollBarScrollDownButton"):SetScript("OnClick", getglobal(TalentFrame:GetName().."DownArrow_OnClick"));
end

function SetTalentButtonLocation(button, tier, column)
	column = ((column - 1) * 63) + INITIAL_TALENT_OFFSET_X;
	tier = -((tier - 1) * 63) - INITIAL_TALENT_OFFSET_Y;
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

