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

function EditModeMagnetismManager:CheckReplaceMagneticFrame(currentFrame, frame, point, relativePoint, distance, offset, isHorizontal)
	local scaledDistance = distance * UIParent:GetEffectiveScale();
	if scaledDistance > self.magnetismRange then
		return currentFrame;
	end

	if not currentFrame or scaledDistance < currentFrame.distance then
		return self:GetMagneticFrameInfoTable(frame, point, relativePoint, scaledDistance, offset, isHorizontal);
	else
		return currentFrame;
	end
end

-- Find the closest grid line (or UIParent side/center point) and returns the distance, point and offset to use (if it ends up being closer than any magnetic frames)
function EditModeMagnetismManager:FindClosestLine(systemFrame, verticalLines)
	local gridLines;
	if self.magneticGridLines then
		gridLines = verticalLines and self.magneticGridLines.vertical or self.magneticGridLines.horizontal;
	end

	local systemFrameCenterX, systemFrameCenterY = systemFrame:GetScaledSelectionCenter();
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();

	local checkPointsTable;

	-- First find the closest distance to the sides and center of UIParent
	if verticalLines then
		checkPointsTable = { LEFT = { self.uiParentLeft, systemFrameLeft }, RIGHT = { self.uiParentRight, systemFrameRight }, CENTER = { self.uiParentCenterX, systemFrameCenterX } };
	else
		checkPointsTable = { TOP = { self.uiParentTop, systemFrameTop }, BOTTOM = { self.uiParentBottom, systemFrameBottom }, CENTER = { self.uiParentCenterY, systemFrameCenterY } };
	end

	local closestDistance, closestPoint;
	local closestOffset = 0;
	for point, checkPoints in pairs(checkPointsTable) do
		local distance = abs(checkPoints[1] - checkPoints[2]);
		if not closestDistance or distance < closestDistance then
			closestDistance = distance;
			closestPoint = point;
		end
	end

	-- Then if the grid is on, see if we can find a closer grid line
	if gridLines then
		if verticalLines then
			checkPointsTable = { LEFT = systemFrameLeft, RIGHT = systemFrameRight } ;
		else
			checkPointsTable = { TOP = systemFrameTop, BOTTOM = systemFrameBottom } ;
		end

		for _, offset in pairs(gridLines) do
			for point, checkPoint in pairs(checkPointsTable) do
				local distance = abs(checkPoint - offset);
				if distance < closestDistance then
					-- This grid line is closer, use it instead
					closestDistance = distance;
					closestPoint = point;

					-- If the line is above or to the right of the system frame we need to invert the offset 
					if point == "TOP" then
						closestOffset = offset - self.uiParentTop;
					elseif point == "RIGHT" then
						closestOffset = offset - self.uiParentRight;
					else
						closestOffset = offset;
					end
				end
			end
		end
	end

	return closestDistance, closestPoint, closestOffset;
end

function EditModeMagnetismManager:IsPotentialMagneticCornerFrame(frame)
	return frame and frame.GetScaledSelectionSides;
end

function EditModeMagnetismManager:ShouldReplaceClosestCorner(closestSqrDistance, cornerSqrDistance)
	return cornerSqrDistance <= self.sqrCornerMagnetismRange and (not closestSqrDistance or cornerSqrDistance < closestSqrDistance);
end

-- Attempts to get a MagneticFrameInfoTable for a corner snap between the input frame and relativeToFrameInfo
-- If no corner is within range will return nil
function EditModeMagnetismManager:GetMagneticCornerFrameInfo(frame, relativeToFrameInfo)
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

-- Finds up to 3 frames or grid lines that are within magnetic range of systemFrame
function EditModeMagnetismManager:FindMagneticFrames(systemFrame)
	local eligibleFrames = self:GetEligibleMagneticFrames(systemFrame);
	local magneticHorizontalFrame, magneticVerticalFrame;

	-- Also track magnetic frames which can potentially be corner snapped to so we can look for corner snap opportunities even if
	-- the closest horizontal or vertical frames cannot be corner snapped to (like UIParent).
	-- We do this since we want to prioritize corner snaps when possible.
	local potentialMagneticHorizontalCornerFrame, potentialMagneticVerticalCornerFrame;

	local distance, point, relativePoint, offset;
	local systemFrameLeft, systemFrameRight, systemFrameBottom, systemFrameTop = systemFrame:GetScaledSelectionSides();

	-- Loop through all frames that are eligible for systemFrame to snap to horizontally and see if any are in range
	local horizontalYes = true;
	for _, frame in ipairs(eligibleFrames.horizontal) do
		if frame == UIParent then
			local verticalLinesYes = true;
			distance, point, offset = self:FindClosestLine(systemFrame, verticalLinesYes);
			relativePoint = point;
		else
			local frameLeft, frameRight, frameBottom, frameTop = frame:GetScaledSelectionSides();

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

		if self:IsPotentialMagneticCornerFrame(frame) then
			potentialMagneticHorizontalCornerFrame = self:CheckReplaceMagneticFrame(potentialMagneticHorizontalCornerFrame, frame, point, relativePoint, distance, offset, horizontalYes);
		end
		magneticHorizontalFrame = self:CheckReplaceMagneticFrame(magneticHorizontalFrame, frame, point, relativePoint, distance, offset, horizontalYes);
	end

	-- Loop through all frames that are eligible for systemFrame to snap to vertically and see if any are in range
	local horizontalNo = false;
	for _, frame in ipairs(eligibleFrames.vertical) do
		if frame == UIParent then
			local verticalLinesNo = false;
			distance, point, offset = self:FindClosestLine(systemFrame, verticalLinesNo);
			relativePoint = point;
		else
			local frameLeft, frameRight, frameBottom, frameTop = frame:GetScaledSelectionSides();

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

		if self:IsPotentialMagneticCornerFrame(frame) then
			potentialMagneticVerticalCornerFrame = self:CheckReplaceMagneticFrame(potentialMagneticVerticalCornerFrame, frame, point, relativePoint, distance, offset, horizontalNo);
		end
		magneticVerticalFrame = self:CheckReplaceMagneticFrame(magneticVerticalFrame, frame, point, relativePoint, distance, offset, horizontalNo);
	end

	-- Check for magnetic corners
	local magneticHorizontalCornerFrameInfo = self:GetMagneticCornerFrameInfo(systemFrame, potentialMagneticHorizontalCornerFrame);
	local magneticVerticalCornerFrameInfo = self:GetMagneticCornerFrameInfo(systemFrame, potentialMagneticVerticalCornerFrame);
	local magneticCornerFrame;
	if magneticHorizontalCornerFrameInfo and (not magneticVerticalCornerFrameInfo or magneticHorizontalCornerFrameInfo.distance < magneticVerticalCornerFrameInfo.distance) then
		magneticCornerFrame = magneticHorizontalCornerFrameInfo;
	elseif magneticVerticalCornerFrameInfo then
		magneticCornerFrame = magneticVerticalCornerFrameInfo;
	end

	-- Return the magnetic horizontal and vertical frames (these can be nil if none is found)
	return magneticHorizontalFrame, magneticVerticalFrame, magneticCornerFrame;
end

function EditModeMagnetismManager:GetMagneticFrameInfo(systemFrame)
	local magneticHorizontalFrame, magneticVerticalFrame, magneticCornerFrame = self:FindMagneticFrames(systemFrame);

	local primaryMagneticFrameInfo, secondaryMagneticFrameInfo;
	if magneticHorizontalFrame or magneticVerticalFrame or magneticCornerFrame then
		if magneticCornerFrame then
			-- Prioritize snapping to the corner of another frame
			primaryMagneticFrameInfo = magneticCornerFrame;
		elseif magneticHorizontalFrame and magneticVerticalFrame and magneticHorizontalFrame.frame == magneticVerticalFrame.frame then
			-- This can only happen if both magnetic frames are UIParent
			-- If one of the frames is a center alignment (systemFrame is going to be snapped to one of UIParent's center lines) then ignore the other one
			if magneticHorizontalFrame.point == "CENTER" then
				primaryMagneticFrameInfo = magneticHorizontalFrame;
			elseif magneticVerticalFrame.point == "CENTER" then
				primaryMagneticFrameInfo = magneticVerticalFrame;
			else
				-- Otherwise snap to both (note that this is only safe in the UIParent case because anchor cycles can result otherwise)
				primaryMagneticFrameInfo = magneticHorizontalFrame;
				secondaryMagneticFrameInfo =  magneticVerticalFrame;
			end
		else
			-- Otherwise pick the closest magnetic frame and ignore the other
			local useHorizontalFrame = magneticHorizontalFrame and (not magneticVerticalFrame or magneticHorizontalFrame.distance < magneticVerticalFrame.distance);
			if useHorizontalFrame then
				primaryMagneticFrameInfo = magneticHorizontalFrame;
			else
				primaryMagneticFrameInfo = magneticVerticalFrame;
			end
		end
	end

	return primaryMagneticFrameInfo, secondaryMagneticFrameInfo;
end

function EditModeMagnetismManager:ApplyMagnetism(systemFrame)
	local primaryMagneticFrameInfo, secondaryMagneticFrameInfo = self:GetMagneticFrameInfo(systemFrame);
	if primaryMagneticFrameInfo then
		systemFrame:ClearAllPoints();

		systemFrame:SnapToFrame(primaryMagneticFrameInfo);
		if secondaryMagneticFrameInfo then
			systemFrame:SnapToFrame(secondaryMagneticFrameInfo);
		end
	end
end