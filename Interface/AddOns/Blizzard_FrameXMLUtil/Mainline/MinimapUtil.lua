MinimapUtil = {};

local MINIMAP_FILTER_SETTINGS_ENTRY = {
	[Enum.MinimapTrackingFilter.AccountCompletedQuests] = "PROXY_ACCOUNT_COMPLETED_QUEST_FILTERING",
	[Enum.MinimapTrackingFilter.TrivialQuests] = "PROXY_TRIVIAL_QUEST_FILTERING",
};

local function HasSettingsEntry(filterID)
	return MINIMAP_FILTER_SETTINGS_ENTRY[filterID] ~= nil;
end

local function SetSettingsEntry(filterID, selected)
	local settingsEntry = MINIMAP_FILTER_SETTINGS_ENTRY[filterID];
	if not settingsEntry or not Settings.GetSetting(settingsEntry) then
		return;
	end

	Settings.SetValue(settingsEntry, selected);
end

function MinimapUtil.GetFilterIndexForFilterID(filterID)
	for filterIndex = 1, C_Minimap.GetNumTrackingTypes() do
		local trackingFilter = C_Minimap.GetTrackingFilter(filterIndex);
		if trackingFilter and trackingFilter.filterID == filterID then
			return filterIndex;
		end
	end
end

function MinimapUtil.SetTrackingFilterByFilterID(filterID, set)
	-- Some filters have dedicated entries in the "Options" panel
	-- In those cases we should go through the Settings system instead to ensure it is properly updated
	if HasSettingsEntry(filterID) then
		SetSettingsEntry(filterID, set);
		return;
	end

	local filterIndex = MinimapUtil.GetFilterIndexForFilterID(filterID);
	if filterIndex then
		C_Minimap.SetTracking(filterIndex, set);
	end
end

function MinimapUtil.SetTrackingFilterByFilterIndex(filterIndex, set)
	local filter = C_Minimap.GetTrackingFilter(filterIndex);
	if filter and filter.filterID and HasSettingsEntry(filter.filterID) then
		SetSettingsEntry(filter.filterID, set);
	end

	C_Minimap.SetTracking(filterIndex, set);
end

local function NormalizeAngleRadians(angle)
	local twoPi = 2 * math.pi;
	while angle < 0 do
		angle = angle + twoPi;
	end
	while angle >= twoPi do
		angle = angle - twoPi;
	end
	return angle;
end

-- Derive the minimap arc covered by this frame and submit it as inset data.
-- distanceScalar is the baseline radial inset amount; isCircular selects C++ arc behavior.
function MinimapUtil.UpdateInsetForFrame(frame, id, distanceScalar, isCircular, anglePadding)
	-- If the source frame is hidden, clear any previously published inset for this id.
	if not frame:IsShown() then
		C_Minimap.ClearMinimapInsetInfo(id);
		return;
	end

	-- Missing bounds/center means we cannot compute a reliable arc this frame.
	local minimapCenterX, minimapCenterY = Minimap:GetCenter();
	local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom();
	if not minimapCenterX or not minimapCenterY or not left or not right or not top or not bottom then
		C_Minimap.ClearMinimapInsetInfo(id);
		return;
	end

	-- Put minimap center and frame corners into the same scaled coordinate space
	-- so angle math stays correct under mixed frame scales.
	local minimapScale = Minimap:GetEffectiveScale();
	local frameScale = frame:GetEffectiveScale();

	minimapCenterX = minimapCenterX * minimapScale;
	minimapCenterY = minimapCenterY * minimapScale;

	local angles = {};
	local points = {
		{ left, top },
		{ right, top },
		{ right, bottom },
		{ left, bottom },
	};

	-- Convert each corner to a polar angle around minimap center.
	-- The atan2 argument order/sign matches minimap's angle convention.
	for _, point in ipairs(points) do
		local pointX = point[1] * frameScale;
		local pointY = point[2] * frameScale;
		local deltaX = pointX - minimapCenterX;
		local deltaY = pointY - minimapCenterY;
		if deltaX ~= 0 or deltaY ~= 0 then
			angles[#angles + 1] = NormalizeAngleRadians(math.atan2(-deltaX, deltaY));
		end
	end

	if #angles == 0 then
		C_Minimap.ClearMinimapInsetInfo(id);
		return;
	end

	-- The covered arc is the complement of the largest gap between sorted corner angles.
	table.sort(angles);

	local largestGap = -1;
	local largestGapIndex = 1;
	for i, angle in ipairs(angles) do
		local nextAngle = angles[i + 1] or (angles[1] + (2 * math.pi));
		local gap = nextAngle - angle;
		if gap > largestGap then
			largestGap = gap;
			largestGapIndex = i;
		end
	end

	local firstArcIndex = largestGapIndex + 1;
	if firstArcIndex > #angles then
		firstArcIndex = 1;
	end

	-- Pad arc ends slightly to reduce boundary flicker from tiny geometry changes.
	local insetMinAngle = angles[firstArcIndex];
	local insetMaxAngle = angles[largestGapIndex];
	local padding = anglePadding or 0.05;
	insetMinAngle = NormalizeAngleRadians(insetMinAngle - padding);
	insetMaxAngle = NormalizeAngleRadians(insetMaxAngle + padding);

	local minimapContainerScale = MinimapCluster.MinimapContainer:GetScale();
	-- Compensate for minimap container scale so perceived inset strength remains stable.
	-- Convert to "strength" space first to keep compensation linear.
	local insetStrength = 1.0 - distanceScalar;
	local compensatedStrength = insetStrength / minimapContainerScale;
	local appliedDistanceScalar = math.max(0.0, math.min(1.0, 1.0 - compensatedStrength));

	C_Minimap.SetMinimapInsetInfo(id, insetMinAngle, insetMaxAngle, appliedDistanceScalar, isCircular);
end
