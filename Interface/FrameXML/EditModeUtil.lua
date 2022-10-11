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

function EditModeUtil:GetRightActionBarWidth()
	local offset = 0;
	if MultiBar3_IsVisible and MultiBar3_IsVisible() and MultiBarRight:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarRight:GetPoint(1);
		offset = (MultiBarRight:GetScale() * MultiBarRight:GetWidth()) - offsetX; -- Subtract x offset since it will be a negative value due to us anchoring to the right side and anchoring towards the middle
	end

	if MultiBar4_IsVisible and MultiBar4_IsVisible() and MultiBarLeft:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarLeft:GetPoint(1);
		offset = offset + (MultiBarLeft:GetScale() * MultiBarLeft:GetWidth()) - offsetX;
	end

	return offset;
end

function EditModeUtil:GetBottomActionBarHeight()
	local actionBarHeight = 0;

	if OverrideActionBar and OverrideActionBar:IsShown() then
		actionBarHeight = actionBarHeight + OverrideActionBar:GetBottomAnchoredHeight();
	else
		actionBarHeight = actionBarHeight + MainMenuBar:GetBottomAnchoredHeight();
		actionBarHeight = actionBarHeight + (MultiBarBottomLeft and MultiBarBottomLeft:GetBottomAnchoredHeight() or 0);
		actionBarHeight = actionBarHeight + (MultiBarBottomRight and MultiBarBottomRight:GetBottomAnchoredHeight() or 0);
	end

	actionBarHeight = actionBarHeight + (StanceBar and StanceBar:GetBottomAnchoredHeight() or 0);
	actionBarHeight = actionBarHeight + (PetActionBar and PetActionBar:GetBottomAnchoredHeight() or 0);
	actionBarHeight = actionBarHeight + (PossessActionBar and PossessActionBar:GetBottomAnchoredHeight() or 0);
	actionBarHeight = actionBarHeight + (MainMenuBarVehicleLeaveButton and MainMenuBarVehicleLeaveButton:GetBottomAnchoredHeight() or 0);

	return actionBarHeight;
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

EditModeMagnetismManager.magneticFrames = {};

-- Default magnetism range
EditModeMagnetismManager.magnetismRange = 8;

function EditModeMagnetismManager:UpdateUIParentPoints()
	self.uiParentCenterX, self.uiParentCenterY = UIParent:GetCenter();

	local left, bottom, width, height = UIParent:GetRect();
	self.uiParentLeft = left;
	self.uiParentRight = left + width;
	self.uiParentBottom = bottom;
	self.uiParentTop = bottom + height;
end

function EditModeMagnetismManager:SetMagnetismRange(magnetismRange)
	self.magnetismRange = magnetismRange;
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

function EditModeMagnetismManager:GetMagneticFrameInfoTable(frame, point, relativePoint, distance, offset, isHorizontal)
	return { frame = frame, point = point, relativePoint = relativePoint, distance = distance, offset = offset, isHorizontal = isHorizontal };
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

-- Finds up to 2 frames or grid lines that are within magnetic range of systemFrame
function EditModeMagnetismManager:FindMagneticFrames(systemFrame)
	local eligibleFrames = self:GetEligibleMagneticFrames(systemFrame);
	local magneticHorizontalFrame, magneticVerticalFrame;
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

		magneticVerticalFrame = self:CheckReplaceMagneticFrame(magneticVerticalFrame, frame, point, relativePoint, distance, offset, horizontalNo);
	end

	-- Return the magnetic horizontal and vertical frames (these can be nil if none is found)
	return magneticHorizontalFrame, magneticVerticalFrame;
end

function EditModeMagnetismManager:ApplyMagnetism(systemFrame)
	local magneticHorizontalFrame, magneticVerticalFrame = self:FindMagneticFrames(systemFrame);

	if magneticHorizontalFrame or magneticVerticalFrame then
		systemFrame:ClearAllPoints();

		if magneticHorizontalFrame and magneticVerticalFrame and magneticHorizontalFrame.frame == magneticVerticalFrame.frame then
			-- This can only happen if both magnetic frames are UIParent
			-- If one of the frames is a center alignment (systemFrame is going to be snapped to one of UIParent's center lines) then ignore the other one
			if magneticHorizontalFrame.point == "CENTER" then
				systemFrame:SnapToFrame(magneticHorizontalFrame);
			elseif magneticVerticalFrame.point == "CENTER" then
				systemFrame:SnapToFrame(magneticVerticalFrame);
			else
				-- Otherwise snap to both (note that this is only safe in the UIParent case because anchor cycles can result otherwise)
				systemFrame:SnapToFrame(magneticHorizontalFrame);
				systemFrame:SnapToFrame(magneticVerticalFrame);
			end
		else
			-- Otherwise pick the closest magnetic frame and ignore the other
			local useHorizontalFrame = magneticHorizontalFrame and (not magneticVerticalFrame or magneticHorizontalFrame.distance < magneticVerticalFrame.distance);
			if useHorizontalFrame then
				systemFrame:SnapToFrame(magneticHorizontalFrame);
			else
				systemFrame:SnapToFrame(magneticVerticalFrame);
			end
		end
	end
end