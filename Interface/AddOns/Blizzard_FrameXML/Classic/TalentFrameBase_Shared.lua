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
