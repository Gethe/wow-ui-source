if not IsInGlobalEnvironment() then
	-- Don't want to load this file into the secure environment
	return;
end

EditModeUtil = { };

function EditModeUtil:IsRightAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarRight)
		or (systemFrame == MultiBarLeft);
end

function EditModeUtil:IsBottomAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarBottomRight)
		or (systemFrame == MultiBarBottomLeft)
		or (systemFrame == MainMenuBar)
		or (systemFrame == StanceBar)
		or (systemFrame == PetActionBar)
		or (systemFrame == PossessActionBar)
		or (systemFrame == MainMenuBarVehicleLeaveButton);
end

local function GetBarsLayoutSize(barHeirarchy, getWidth)
	for _, bar in ipairs(barHeirarchy) do
		if bar and bar:IsVisible()
			and (not bar.IsInitialized or bar:IsInitialized())
			and (not bar.IsInDefaultPosition or bar:IsInDefaultPosition())
			then
			local offset, size;
			if getWidth then
				offset = select(4, bar:GetPoint(1));
				size = bar:GetWidth();
			else -- getHeight
				offset = select(5, bar:GetPoint(1));
				size = bar:GetHeight();
			end
			return math.abs(offset) + size;
		end
	end

	return 0;
end

function EditModeUtil:GetRightActionBarWidth()
	local barHeirarchy = { MultiBarLeft, MultiBarRight };
	local getWidthYes = true;
	return GetBarsLayoutSize(barHeirarchy, getWidthYes);
end

function EditModeUtil:GetBottomActionBarHeight()
	local barHeirarchy = { MainMenuBarVehicleLeaveButton, PossessActionBar, PetActionBar, StanceBar, OverrideActionBar, MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar };
	local getWidthNo = false;
	return GetBarsLayoutSize(barHeirarchy, getWidthNo);
end

function EditModeUtil:GetRightContainerAnchor()
	local xOffset = -EditModeUtil:GetRightActionBarWidth() - 5;
	local anchor = AnchorUtil.CreateAnchor("TOPRIGHT", UIParent, "TOPRIGHT", xOffset, -260);
	return anchor;
end

function EditModeUtil:GetSettingMapFromSettings(settings, displayInfoMap)
	local settingMap = {};
	for _, settingInfo in ipairs(settings) do
		settingMap[settingInfo.setting] = { value = settingInfo.value };

		if displayInfoMap and displayInfoMap[settingInfo.setting] then
			settingMap[settingInfo.setting].displayValue = displayInfoMap[settingInfo.setting]:ConvertValueForDisplay(settingInfo.value);
		end
	end
	return settingMap;
end

function EditModeUtil.CreateLinePool(ownerFrame, template)
	local function resetLine(pool, line)
		line:Hide();
		line:ClearAllPoints();
	end

	local linePool = CreateObjectPool(
		function(pool)
			return ownerFrame:CreateLine(nil, nil, template);
		end,

		resetLine
	);

	return linePool;
end

EditModeMagnetismManager = {};

hooksecurefunc("UpdateUIParentPosition", function() EditModeMagnetismManager:UpdateUIParentPoints() end);

EditModeMagnetismManager.magneticFrames = {};

-- Default magnetism range
EditModeMagnetismManager.magnetismRange = 8;
EditModeMagnetismManager.sqrMagnetismRange = EditModeMagnetismManager.magnetismRange * EditModeMagnetismManager.magnetismRange;
EditModeMagnetismManager.sqrCornerMagnetismRange = EditModeMagnetismManager.sqrMagnetismRange * 2;

function EditModeMagnetismManager:UpdateUIParentPoints()
	self.uiParentCenterX, self.uiParentCenterY = UIParent:GetCenter();

	local left, bottom, width, height = UIParent:GetRect();
	self.uiParentWidth = width;
	self.uiParentHeight = height;
	self.uiParentLeft = left;
	self.uiParentRight = left + width;
	self.uiParentBottom = bottom;
	self.uiParentTop = bottom + height;
end

function EditModeMagnetismManager:SetMagnetismRange(magnetismRange)
	self.magnetismRange = magnetismRange;
	self.sqrMagnetismRange = magnetismRange * magnetismRange;
	self.sqrCornerMagnetismRange = self.sqrMagnetismRange * 2;
end

function EditModeMagnetismManager:RegisterFrame(frame)
	self.magneticFrames[frame] = true;
end

function EditModeMagnetismManager:UnregisterFrame(frame)
	self.magneticFrames[frame] = nil;
end

function EditModeMagnetismManager:RegisterGrid()
	self.magneticGridLines = { horizontal = {}, vertical = {} };
end

function EditModeMagnetismManager:UnregisterGrid()
	self.magneticGridLines = nil;
end

function EditModeMagnetismManager:RegisterGridLine(line, verticalLine, centerOffset)
	if verticalLine then
		self.magneticGridLines.vertical[line] = self.uiParentCenterX + centerOffset;
	else
		self.magneticGridLines.horizontal[line] = self.uiParentCenterY + centerOffset;
	end
end

function EditModeMagnetismManager:GetEligibleMagneticFrames(systemFrame)
	-- UIParent is always eligible
	local eligibleFrames = {
		horizontal	= { UIParent },
		vertical	= { UIParent },
	};

	for magneticFrame in pairs(self.magneticFrames) do
		local horizontalEligible, verticalEligible = systemFrame:GetFrameMagneticEligibility(magneticFrame);

		if horizontalEligible then
			table.insert(eligibleFrames.horizontal, magneticFrame);
		end

		if verticalEligible then
			table.insert(eligibleFrames.vertical, magneticFrame);
		end
	end

	return eligibleFrames;
end

function EditModeMagnetismManager:GetMagneticFrameInfoTable(frame, point, relativePoint, distance, offset, isHorizontal, isCornerSnap)
	return { frame = frame, point = point, relativePoint = relativePoint, distance = distance, offset = offset, isHorizontal = isHorizontal, isCornerSnap = isCornerSnap };
end

function EditModeMagnetismManager:CheckReplaceMagneticFrameInfo(currentMagneticFrameInfo, frame, point, relativePoint, distance, offset, isHorizontal)
	local scaledDistance = distance * UIParent:GetEffectiveScale();
	if scaledDistance > self.magnetismRange then
		return currentMagneticFrameInfo;
	end

	if not currentMagneticFrameInfo or scaledDistance < currentMagneticFrameInfo.distance then
		return self:GetMagneticFrameInfoTable(frame, point, relativePoint, scaledDistance, offset, isHorizontal);
	else
		return currentMagneticFrameInfo;
	end
end

-- Returns the points we want to check when seeing if a point relative to UIParent is close enough to snap to.
function EditModeMagnetismManager:GetUIParentCheckPoints(systemFrame, verticalLines)
	local systemFrameCenterX, systemFrameCenterY = systemFrame:GetScaledSelectionCenter();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();

	return verticalLines
	and {
		{ point = "LEFT", relativePoint = "LEFT", source = systemFrameLeft, target = self.uiParentLeft },
		{ point = "RIGHT", relativePoint = "RIGHT", source = systemFrameRight, target = self.uiParentRight },
		{ point = "CENTER", relativePoint = "CENTER", source = systemFrameCenterX, target = self.uiParentCenterX },
		{ point = "LEFT", relativePoint = "CENTER", source = systemFrameLeft, target = self.uiParentCenterX },
		{ point = "RIGHT", relativePoint = "CENTER", source = systemFrameRight, target = self.uiParentCenterX },
	}
	or {
		{ point = "TOP", relativePoint = "TOP", source = systemFrameTop, target = self.uiParentTop },
		{ point = "BOTTOM", relativePoint = "BOTTOM", source = systemFrameBottom, target = self.uiParentBottom },
		{ point = "CENTER", relativePoint = "CENTER", source = systemFrameCenterY, target = self.uiParentCenterY },
		{ point = "TOP", relativePoint = "CENTER", source = systemFrameTop, target = self.uiParentCenterY },
		{ point = "BOTTOM", relativePoint = "CENTER", source = systemFrameBottom, target = self.uiParentCenterY },
	};
end

-- Returns the points we want to check when seeing if a grid line is close enough to snap to.
function EditModeMagnetismManager:GetGridLineCheckPoints(systemFrame, verticalLines)
	local systemFrameCenterX, systemFrameCenterY = systemFrame:GetScaledSelectionCenter();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();

	return verticalLines
	and {
		{ point = "LEFT", relativePoint = "LEFT", source = systemFrameLeft },
		{ point = "RIGHT", relativePoint = "RIGHT", source = systemFrameRight },
		{ point = "CENTER", relativePoint = "CENTER", source = systemFrameCenterX },
	}
	or {
		{ point = "TOP", relativePoint = "TOP", source = systemFrameTop },
		{ point = "BOTTOM", relativePoint = "BOTTOM", source = systemFrameBottom },
		{ point = "CENTER", relativePoint = "CENTER", source = systemFrameCenterY },
	};
end

-- Find the closest grid line (or UIParent side/center point) and returns the distance, point and offset to use (if it ends up being closer than any magnetic frames)
function EditModeMagnetismManager:FindClosestGridLine(systemFrame, verticalLines)
	local closestDistance, closestPoint, closestRelativePoint;
	local closestOffset = 0;

	-- First find the closest distance to the sides and center of UIParent
	local uiParentCheckPoints = self:GetUIParentCheckPoints(systemFrame, verticalLines);
	for _, checkPoint in ipairs(uiParentCheckPoints) do
		local distance = abs(checkPoint.target - checkPoint.source);
		if not closestDistance or distance < closestDistance then
			closestDistance = distance;
			closestPoint = checkPoint.point;
			closestRelativePoint = checkPoint.relativePoint;
		end
	end

	-- Then if the grid is on, see if we can find a closer grid line
	local gridLines;
	if self.magneticGridLines then
		gridLines = verticalLines and self.magneticGridLines.vertical or self.magneticGridLines.horizontal;
	end

	if gridLines then
		local gridLineCheckPoints = self:GetGridLineCheckPoints(systemFrame, verticalLines);
		for _, gridLineOffset in pairs(gridLines) do
			for _, checkPoint in ipairs(gridLineCheckPoints) do
				local distance = abs(gridLineOffset - checkPoint.source);
				if distance < closestDistance then
					-- This grid line is closer, use it instead
					closestDistance = distance;
					closestPoint = checkPoint.point;
					closestRelativePoint = checkPoint.relativePoint;

					-- In some scenarios we need to invert the offset
					if checkPoint.point == "TOP" then
						closestOffset = gridLineOffset - self.uiParentTop;
					elseif checkPoint.point == "RIGHT" then
						closestOffset = gridLineOffset - self.uiParentRight;
					elseif checkPoint.point == "CENTER" then
						if verticalLines then
							closestOffset = gridLineOffset - self.uiParentCenterX;
						else
							closestOffset = gridLineOffset - self.uiParentCenterY;
						end
					else
						closestOffset = gridLineOffset;
					end
				end
			end
		end
	end

	return closestDistance, closestPoint, closestRelativePoint, closestOffset;
end

function EditModeMagnetismManager:IsPotentialMagneticCornerFrame(frame)
	return frame and frame.GetScaledSelectionSides;
end

function EditModeMagnetismManager:ShouldReplaceClosestCorner(closestSqrDistance, cornerSqrDistance)
	return cornerSqrDistance <= self.sqrCornerMagnetismRange and (not closestSqrDistance or cornerSqrDistance < closestSqrDistance);
end

-- Attempts to get a MagneticFrameInfoTable for a corner snap between the input frame and relativeToFrameInfo
-- If no corner is within range will return nil
function EditModeMagnetismManager:GetCornerMagneticFrameInfo(frame, relativeToFrameInfo)
	if not self:IsPotentialMagneticCornerFrame(frame) or not relativeToFrameInfo or not self:IsPotentialMagneticCornerFrame(relativeToFrameInfo.frame) then
		return nil;
	end

	local frameLeft, frameRight, frameBottom, frameTop = frame:GetScaledSelectionSides();
	local framePoints = {
		TOPLEFT = { x = frameLeft, y = frameTop };
		TOPRIGHT = { x = frameRight, y = frameTop };
		BOTTOMLEFT = { x = frameLeft, y = frameBottom };
		BOTTOMRIGHT = { x = frameRight, y = frameBottom };
	};

	local relativeToFrameLeft, relativeToFrameRight, relativeToFrameBottom, relativeToFrameTop = relativeToFrameInfo.frame:GetScaledSelectionSides();
	local relativeToFramePoints = {
		TOPLEFT = { x = relativeToFrameLeft, y = relativeToFrameTop };
		TOPRIGHT = { x = relativeToFrameRight, y = relativeToFrameTop };
		BOTTOMLEFT = { x = relativeToFrameLeft, y = relativeToFrameBottom };
		BOTTOMRIGHT = { x = relativeToFrameRight, y = relativeToFrameBottom };
	};

	local closestPoint, closestRelativePoint, closestSqrDistance;
	local cornerSqrDistance;
	for framePointName, framePointPosition in pairs(framePoints) do
		for relativeToFramePointName, relativeToFramePointPosition in pairs(relativeToFramePoints) do
			-- Exclude diagonal corner connections
			if not ((framePointName == "TOPLEFT" and relativeToFramePointName == "BOTTOMRIGHT")
				 or (framePointName == "TOPRIGHT" and relativeToFramePointName == "BOTTOMLEFT")
				 or (framePointName == "BOTTOMLEFT" and relativeToFramePointName == "TOPRIGHT")
				 or (framePointName == "BOTTOMRIGHT" and relativeToFramePointName == "TOPLEFT")) then

				-- Check if this corner is closer
				cornerSqrDistance = CalculateDistanceSq(framePointPosition.x, framePointPosition.y, relativeToFramePointPosition.x, relativeToFramePointPosition.y);
				if self:ShouldReplaceClosestCorner(closestSqrDistance, cornerSqrDistance) then
					closestPoint, closestRelativePoint, closestSqrDistance = framePointName, relativeToFramePointName, cornerSqrDistance;
				end
			end
		end
	end

	if closestSqrDistance then
		local offset = 0;
		local isCornerSnap = true;
		return self:GetMagneticFrameInfoTable(relativeToFrameInfo.frame, closestPoint, closestRelativePoint, math.sqrt(closestSqrDistance), offset, relativeToFrameInfo.isHorizontal, isCornerSnap);
	end

	return nil;
end

-- Returns a horizontal, a vertical, and a corner MagneticFrameInfo option.
-- Only returns options which are within magnetism range.
-- If no frames are in range, returns nil for that option.
function EditModeMagnetismManager:GetMagneticFrameInfoOptions(systemFrame)
	local eligibleFrames = self:GetEligibleMagneticFrames(systemFrame);
	local horizontalMagneticFrameInfo, verticalMagneticFrameInfo;
	local potentialHorizontalCornerMagneticFrame, potentialVerticalCornerMagneticFrame;

	local distance, point, relativePoint, offset;
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();

	-- Find closest in range horizontal frame
	local horizontalYes = true;
	for _, frame in ipairs(eligibleFrames.horizontal) do
		if frame == UIParent then
			local verticalLinesYes = true;
			distance, point, relativePoint, offset = self:FindClosestGridLine(systemFrame, verticalLinesYes);
		else
			local frameLeft, frameRight = frame:GetScaledSelectionSides();
			if frame:IsToTheLeftOfFrame(systemFrame) then
				distance = systemFrameLeft - frameRight;
				point = "LEFT";
				relativePoint = "RIGHT";
			else
				distance = frameLeft - systemFrameRight;
				point = "RIGHT";
				relativePoint = "LEFT";
			end

			offset = 0;
		end

		horizontalMagneticFrameInfo = self:CheckReplaceMagneticFrameInfo(horizontalMagneticFrameInfo, frame, point, relativePoint, distance, offset, horizontalYes);

		if self:IsPotentialMagneticCornerFrame(frame) then
			potentialHorizontalCornerMagneticFrame = self:CheckReplaceMagneticFrameInfo(potentialHorizontalCornerMagneticFrame, frame, point, relativePoint, distance, offset, horizontalYes);
		end
	end

	-- Find closest in range vertical frame
	local horizontalNo = false;
	for _, frame in ipairs(eligibleFrames.vertical) do
		if frame == UIParent then
			local verticalLinesNo = false;
			distance, point, relativePoint, offset = self:FindClosestGridLine(systemFrame, verticalLinesNo);
		else
			local _, _, frameBottom, frameTop = frame:GetScaledSelectionSides();

			if frame:IsAboveFrame(systemFrame) then
				distance = frameBottom - systemFrameTop;
				point = "TOP";
				relativePoint = "BOTTOM";
			else
				distance = systemFrameBottom - frameTop;
				point = "BOTTOM";
				relativePoint = "TOP";
			end

			offset = 0;
		end

		verticalMagneticFrameInfo = self:CheckReplaceMagneticFrameInfo(verticalMagneticFrameInfo, frame, point, relativePoint, distance, offset, horizontalNo);

		if self:IsPotentialMagneticCornerFrame(frame) then
			potentialVerticalCornerMagneticFrame = self:CheckReplaceMagneticFrameInfo(potentialVerticalCornerMagneticFrame, frame, point, relativePoint, distance, offset, horizontalNo);
		end
	end

	-- Check for magnetic corners
	local horizontalCornerMagneticFrameInfo = self:GetCornerMagneticFrameInfo(systemFrame, potentialHorizontalCornerMagneticFrame);
	local verticalCornerMagneticFrameInfo = self:GetCornerMagneticFrameInfo(systemFrame, potentialVerticalCornerMagneticFrame);
	local cornerMagneticFrameInfo;
	if horizontalCornerMagneticFrameInfo and (not verticalCornerMagneticFrameInfo or horizontalCornerMagneticFrameInfo.distance < verticalCornerMagneticFrameInfo.distance) then
		cornerMagneticFrameInfo = horizontalCornerMagneticFrameInfo;
	elseif verticalCornerMagneticFrameInfo then
		cornerMagneticFrameInfo = verticalCornerMagneticFrameInfo;
	end

	return horizontalMagneticFrameInfo, verticalMagneticFrameInfo, cornerMagneticFrameInfo;
end

local function IsGridLineOrUIParent(frame)
	return frame and (frame.isGridLine or frame == UIParent);
end

-- Returns a table of frames this input frame would snap to.
function EditModeMagnetismManager:GetMagneticFrameInfos(systemFrame)
	local horizontalMagneticFrameInfo, verticalMagneticFrameInfo, cornerMagneticFrameInfo = self:GetMagneticFrameInfoOptions(systemFrame);

	if cornerMagneticFrameInfo then
		-- Prioritize corner snaps
		return { cornerMagneticFrameInfo };
	elseif horizontalMagneticFrameInfo and IsGridLineOrUIParent(horizontalMagneticFrameInfo.frame) and verticalMagneticFrameInfo and IsGridLineOrUIParent(verticalMagneticFrameInfo.frame) then
		-- If horizontal and vertical are both grid lines or UIParent then we are gonna double snap to them
		return { horizontalMagneticFrameInfo, verticalMagneticFrameInfo };
	elseif horizontalMagneticFrameInfo or verticalMagneticFrameInfo then
		-- Snap to the closest frame info between the horizontal and vertical
		if horizontalMagneticFrameInfo and (not verticalMagneticFrameInfo or horizontalMagneticFrameInfo.distance < verticalMagneticFrameInfo.distance) then
			return { horizontalMagneticFrameInfo };
		else
			return { verticalMagneticFrameInfo };
		end
	end

	return nil;
end

function EditModeMagnetismManager:ApplyMagnetism(systemFrame)
	local magneticFrameInfos = self:GetMagneticFrameInfos(systemFrame);
	if magneticFrameInfos then
		systemFrame:ClearAllPoints();

		for index, magneticFrameInfo in ipairs(magneticFrameInfos) do
			systemFrame:SnapToFrame(magneticFrameInfo);
		end
	end
end

-- Returns the positions that preview lines should anchor given a magnetic frame info.
-- This is specifically useful for corner snaps which have multiple preview lines we want to show.
function EditModeMagnetismManager:GetPreviewLineAnchors(magneticFrameInfo)
	local relativePoint = magneticFrameInfo.relativePoint;

	local anchors = {};
	if string.find(relativePoint, "CENTER") then
		if magneticFrameInfo.isHorizontal then
			table.insert(anchors, "CenterVertical");
		else
			table.insert(anchors, "CenterHorizontal");
		end
	else
		if string.find(relativePoint, "TOP") then
			table.insert(anchors, "Top");
		end
		if string.find(relativePoint, "BOTTOM") then
			table.insert(anchors, "Bottom");
		end
		if string.find(relativePoint, "LEFT") then
			table.insert(anchors, "Left");
		end
		if string.find(relativePoint, "RIGHT") then
			table.insert(anchors, "Right");
		end
	end

	return anchors;
end