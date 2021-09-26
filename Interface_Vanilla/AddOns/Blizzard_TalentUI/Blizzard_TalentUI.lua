MAX_TALENT_TABS = 5;
MAX_NUM_TALENTS = 20;
MAX_NUM_TALENT_TIERS = 8;
NUM_TALENT_COLUMNS = 4;
TALENT_BRANCH_ARRAY = {};
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

function PlayerTalentFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(PlayerTalentFrame, 3);
	PanelTemplates_SetTab(PlayerTalentFrame, 1);
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	for i=1, MAX_NUM_TALENT_TIERS do
		TALENT_BRANCH_ARRAY[i] = {};
		for j=1, NUM_TALENT_COLUMNS do
			TALENT_BRANCH_ARRAY[i][j] = {id=nil, up=0, left=0, right=0, down=0, leftArrow=0, rightArrow=0, topArrow=0};
		end
	end
	
	-- Should be removed once other things have been moved to the C-side and tied to game logic,
--	for i = 1, GetNumTalentTabs() do
-- 		spentTalentPoints[i] = {};
-- 		for j = 1, GetNumTalents(i) do
-- 			spentTalentPoints[i][j] = 0;
-- 		end
-- 	end
end

function PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound(SOUNDKIT.TALENT_SCREEN_OPEN);
	UpdateMicroButtons();

	PlayerTalentFrame_Update();
end

function PlayerTalentFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.TALENT_SCREEN_CLOSE);
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	if ( (event == "CHARACTER_POINTS_CHANGED") or (event == "SPELLS_CHANGED") ) then
		PlayerTalentFrame_Update();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( select(1, ...) == "player" ) then
			SetPortraitTexture(PlayerTalentFramePortrait, "player");
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID());
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID());
	self.UpdateTooltip = PlayerTalentFrameTalent_OnEnter;
end

function PlayerTalentFrameTalent_OnLeave(self)
	GameTooltip_Hide();
end

function PlayerTalentFrame_Update()
	-- Setup Tabs
	local tab, name, iconTexture, pointsSpent, button;
	local numTabs = GetNumTalentTabs();
	for i=1, MAX_TALENT_TABS do
		tab = _G["PlayerTalentFrameTab"..i];
		if ( i <= numTabs ) then
			name, iconTexture, pointsSpent = GetTalentTabInfo(i);
			if ( i == PanelTemplates_GetSelectedTab(PlayerTalentFrame) ) then
				-- If tab is the selected tab set the points spent info
				PlayerTalentFrameSpentPoints:SetText(MASTERY_POINTS_SPENT:format(name).." "..HIGHLIGHT_FONT_COLOR_CODE..pointsSpent..FONT_COLOR_CODE_CLOSE);
				PlayerTalentFrame.pointsSpent = pointsSpent;
			end
			tab:SetText(name);
			PanelTemplates_TabResize(tab, 10);
			tab:Show();
		else
			tab:Hide();
		end
	end
	PanelTemplates_SetNumTabs(PlayerTalentFrame, numTabs);
	PanelTemplates_UpdateTabs(PlayerTalentFrame);

	-- Setup Frame
	SetPortraitTexture(PlayerTalentFramePortrait, "player");
	PlayerTalentFrame_UpdateTalentPoints();
	local talentTabName = GetTalentTabInfo(PanelTemplates_GetSelectedTab(PlayerTalentFrame));
	local base;
	local name, texture, points, fileName = GetTalentTabInfo(PanelTemplates_GetSelectedTab(PlayerTalentFrame));
	if ( talentTabName ) then
		base = "Interface\\TalentFrame\\"..fileName.."-";
	else
		-- temporary default for classes without talents poor guys
		base = "Interface\\TalentFrame\\MageFire-";
	end
	
	PlayerTalentFrameBackgroundTopLeft:SetTexture(base.."TopLeft");
	PlayerTalentFrameBackgroundTopRight:SetTexture(base.."TopRight");
	PlayerTalentFrameBackgroundBottomLeft:SetTexture(base.."BottomLeft");
	PlayerTalentFrameBackgroundBottomRight:SetTexture(base.."BottomRight");
	
	local numTalents = GetNumTalents(PanelTemplates_GetSelectedTab(PlayerTalentFrame));
	-- Just a reminder error if there are more talents than available buttons
	if ( numTalents > MAX_NUM_TALENTS ) then
		message("Too many talents in talent frame!");
	end

	PlayerTalentFrame_ResetBranches();
	local forceDesaturated, tierUnlocked;
	for i=1, MAX_NUM_TALENTS do
		button = _G["PlayerTalentFrameTalent"..i];
		if ( i <= numTalents ) then
			-- Set the button info
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(PanelTemplates_GetSelectedTab(PlayerTalentFrame), i);
			_G["PlayerTalentFrameTalent"..i.."Rank"]:SetText(rank);
			SetTalentButtonLocation(button, tier, column);
			TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();
			
			-- If player has no talent points then show only talents with points in them
			if ( (PlayerTalentFrame.talentPoints <= 0 and rank == 0)  ) then
				forceDesaturated = 1;
			else
				forceDesaturated = nil;
			end

			-- If the player has spent at least 5 talent points in the previous tier
			if ( ( (tier - 1) * 5 <= PlayerTalentFrame.pointsSpent ) ) then
				tierUnlocked = 1;
			else
				tierUnlocked = nil;
			end
			SetItemButtonTexture(button, iconTexture);
			
			-- Talent must meet prereqs or the player must have no points to spend
			if ( PlayerTalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(PanelTemplates_GetSelectedTab(PlayerTalentFrame), i)) and available ) then
				SetItemButtonDesaturated(button, nil);
				
				if ( rank < maxRank ) then
					-- Rank is green if not maxed out
					_G["PlayerTalentFrameTalent"..i.."Slot"]:SetVertexColor(0.1, 1.0, 0.1);
					_G["PlayerTalentFrameTalent"..i.."Rank"]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					_G["PlayerTalentFrameTalent"..i.."Slot"]:SetVertexColor(1.0, 0.82, 0);
					_G["PlayerTalentFrameTalent"..i.."Rank"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				_G["PlayerTalentFrameTalent"..i.."RankBorder"]:Show();
				_G["PlayerTalentFrameTalent"..i.."Rank"]:Show();
			else
				SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65);
				_G["PlayerTalentFrameTalent"..i.."Slot"]:SetVertexColor(0.5, 0.5, 0.5);
				if ( rank == 0 ) then
					_G["PlayerTalentFrameTalent"..i.."RankBorder"]:Hide();
					_G["PlayerTalentFrameTalent"..i.."Rank"]:Hide();
				else
					_G["PlayerTalentFrameTalent"..i.."RankBorder"]:SetVertexColor(0.5, 0.5, 0.5);
					_G["PlayerTalentFrameTalent"..i.."Rank"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
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
	PlayerTalentFrame_ResetBranchTextureCount();
	PlayerTalentFrame_ResetArrowTextureCount();
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			node = TALENT_BRANCH_ARRAY[i][j];
			
			-- Setup offsets
			xOffset = ((j - 1) * 63) + INITIAL_TALENT_OFFSET_X + 2;
			yOffset = -((i - 1) * 63) - INITIAL_TALENT_OFFSET_Y - 2;
		
			if ( node.id ) then
				-- Has talent
				if ( node.up ~= 0 ) then
					if ( not ignoreUp ) then
						PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + TALENT_BUTTON_SIZE);
					else
						ignoreUp = nil;
					end
				end
				if ( node.down ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - TALENT_BUTTON_SIZE + 1);
				end
				if ( node.left ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - TALENT_BUTTON_SIZE, yOffset);
				end
				if ( node.right ~= 0 ) then
					-- See if any connecting branches are gray and if so color them gray
					tempNode = TALENT_BRANCH_ARRAY[i][j+1];	
					if ( tempNode.left ~= 0 and tempNode.down < 0 ) then
						PlayerTalentFrame_SetBranchTexture(i, j-1, TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + TALENT_BUTTON_SIZE, yOffset);
					else
						PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE + 1, yOffset);
					end
					
				end
				-- Draw arrows
				if ( node.rightArrow ~= 0 ) then
					PlayerTalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + TALENT_BUTTON_SIZE/2 + 5, yOffset);
				end
				if ( node.leftArrow ~= 0 ) then
					PlayerTalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - TALENT_BUTTON_SIZE/2 - 5, yOffset);
				end
				if ( node.topArrow ~= 0 ) then
					PlayerTalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + TALENT_BUTTON_SIZE/2 + 5);
				end
			else
				-- Doesn't have a talent
				if ( node.up ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset , yOffset);
				elseif ( node.down ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset , yOffset);
				elseif ( node.left ~= 0 and node.down ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset , yOffset);
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
				elseif ( node.left ~= 0 and node.up ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset , yOffset);
				elseif ( node.left ~= 0 and node.right ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE, yOffset);
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset);
				elseif ( node.right ~= 0 and node.down ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset , yOffset);
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
				elseif ( node.right ~= 0 and node.up ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset , yOffset);
				elseif ( node.up ~= 0 and node.down ~= 0 ) then
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset , yOffset);
					PlayerTalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
					ignoreUp = 1;
				end
			end
		end
		PlayerTalentFrameScrollFrame:UpdateScrollChildRect();
	end
	-- Hide any unused branch textures
	for i=PlayerTalentFrame_GetBranchTextureCount(), MAX_NUM_BRANCH_TEXTURES do
		_G["PlayerTalentFrameBranch"..i]:Hide();
	end
	-- Hide and unused arrowl textures
	for i=PlayerTalentFrame_GetArrowTextureCount(), MAX_NUM_ARROW_TEXTURES do
		_G["PlayerTalentFrameArrow"..i]:Hide();
	end
end

function PlayerTalentFrame_SetArrowTexture(tier, column, texCoords, xOffset, yOffset)
	local arrowTexture = PlayerTalentFrame_GetArrowTexture();
	arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	arrowTexture:SetPoint("TOPLEFT", "PlayerTalentFrameArrowFrame", "TOPLEFT", xOffset, yOffset);
end

function PlayerTalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset)
	local branchTexture = PlayerTalentFrame_GetBranchTexture();
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	branchTexture:SetPoint("TOPLEFT", "PlayerTalentFrameScrollChildFrame", "TOPLEFT", xOffset, yOffset);
end

function PlayerTalentFrame_GetArrowTexture()
	local arrowTexture = _G["PlayerTalentFrameArrow"..PlayerTalentFrame.arrowIndex];
	PlayerTalentFrame.arrowIndex = PlayerTalentFrame.arrowIndex + 1;
	if ( not arrowTexture ) then
		message("Not enough arrow textures");
	else
		arrowTexture:Show();
		return arrowTexture;
	end
end

function PlayerTalentFrame_GetBranchTexture()
	local branchTexture = _G["PlayerTalentFrameBranch"..PlayerTalentFrame.textureIndex];
	PlayerTalentFrame.textureIndex = PlayerTalentFrame.textureIndex + 1;
	if ( not branchTexture ) then
		message("Not enough branch textures");
	else
		branchTexture:Show();
		return branchTexture;
	end
end

function PlayerTalentFrame_ResetArrowTextureCount()
	PlayerTalentFrame.arrowIndex = 1;
end

function PlayerTalentFrame_ResetBranchTextureCount()
	PlayerTalentFrame.textureIndex = 1;
end

function PlayerTalentFrame_GetArrowTextureCount()
	return PlayerTalentFrame.arrowIndex;
end

function PlayerTalentFrame_GetBranchTextureCount()
	return PlayerTalentFrame.textureIndex;
end

function PlayerTalentFrame_SetPrereqs(buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
	local tier, column, isLearnable;
	local requirementsMet;
	if ( tierUnlocked and not forceDesaturated ) then
		requirementsMet = 1;
	else
		requirementsMet = nil;
	end
	for i = 1, select('#', ...), 3 do
		tier = select(i, ...);
		column = select(i+1, ...);
		isLearnable = select(i+2, ...);
		if ( not isLearnable or forceDesaturated ) then
			requirementsMet = nil;
		end
		PlayerTalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet);
	end
	return requirementsMet;
end

function PlayerTalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet)
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
				if ( TALENT_BRANCH_ARRAY[i][buttonColumn].id ) then
					-- If there's an id, there's a blocker
					message("Error this layout is blocked vertically "..TALENT_BRANCH_ARRAY[i][buttonColumn].id);
					return;
				end
			end
		end
		
		-- Draw the lines
		for i=tier, buttonTier - 1 do
			TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
			if ( (i + 1) <= (buttonTier - 1) ) then
				TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
			end
		end
		
		-- Set the arrow
		TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
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
				if ( TALENT_BRANCH_ARRAY[tier][i].id ) then
					-- If there's an id, there's a blocker
					message("there's a blocker");
					return;
				end
			end
		end
		-- If we get here then we're in the clear
		for i=left, right - 1 do
			TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
			TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
		end
		-- Determine where the arrow goes
		if ( buttonColumn < column ) then
			TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow = requirementsMet;
		else
			TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow = requirementsMet;
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
		if ( TALENT_BRANCH_ARRAY[tier][i].id ) then
			-- If there's an id, there's a blocker
			blocked = 1;
		end
	end
	left = min(buttonColumn, column);
	right = max(buttonColumn, column);
	if ( not blocked ) then
		TALENT_BRANCH_ARRAY[tier][buttonColumn].down = requirementsMet;
		TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].up = requirementsMet;
		
		for i=tier, buttonTier - 1 do
			TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
			TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
		end

		for i=left, right - 1 do
			TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
			TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
		end
		-- Place the arrow
		TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
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
		if ( TALENT_BRANCH_ARRAY[buttonTier][i].id ) then
			-- If there's an id, then throw an error
			message("Error, this layout is undrawable "..TALENT_BRANCH_ARRAY[buttonTier][i].id);
			return;
		end
	end
	-- If we're here we can draw the line
	left = min(buttonColumn, column);
	right = max(buttonColumn, column);
	--TALENT_BRANCH_ARRAY[tier][column].down = requirementsMet;
	--TALENT_BRANCH_ARRAY[buttonTier][column].up = requirementsMet;

	for i=tier, buttonTier-1 do
		TALENT_BRANCH_ARRAY[i][column].up = requirementsMet;
		TALENT_BRANCH_ARRAY[i+1][column].down = requirementsMet;
	end

	-- Determine where the arrow goes
	if ( buttonColumn < column ) then
		TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow =  requirementsMet;
	else
		TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow =  requirementsMet;
	end
end

function PlayerTalentFrameTalent_OnClick(self, mouseButton)
	if ( mouseButton == "LeftButton" ) then
		LearnTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID());
	end
end

function PlayerTalentFrameTab_OnClick(self)
	PanelTemplates_SetTab(PlayerTalentFrame, self:GetID());
	PlayerTalentFrame_Update();
	for i=1, MAX_TALENT_TABS do
		SetButtonPulse(_G["PlayerTalentFrameTab"..i], 0, 0);
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

-- Helper functions
function PlayerTalentFrame_UpdateTalentPoints()
	local talentPoints = UnitCharacterPoints("player");
	PlayerTalentFrameTalentPointsText:SetText(talentPoints);
	PlayerTalentFrame.talentPoints = talentPoints;
end

function SetTalentButtonLocation(button, tier, column)
	column = ((column - 1) * 63) + INITIAL_TALENT_OFFSET_X;
	tier = -((tier - 1) * 63) - INITIAL_TALENT_OFFSET_Y;
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", column, tier);
end

function PlayerTalentFrame_ResetBranches()
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			TALENT_BRANCH_ARRAY[i][j].id = nil;
			TALENT_BRANCH_ARRAY[i][j].up = 0;
			TALENT_BRANCH_ARRAY[i][j].down = 0;
			TALENT_BRANCH_ARRAY[i][j].left = 0;
			TALENT_BRANCH_ARRAY[i][j].right = 0;
			TALENT_BRANCH_ARRAY[i][j].rightArrow = 0;
			TALENT_BRANCH_ARRAY[i][j].leftArrow = 0;
			TALENT_BRANCH_ARRAY[i][j].topArrow = 0;
		end
	end
end
