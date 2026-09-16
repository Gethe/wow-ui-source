---@diagnostic disable: duplicate-set-field

-- Mainline FramerateFrame Overrides

function FramerateFrameMixin:OnLoad()
	-- For Mainline, position is based on position of micro menu
	local position = FrameUtil.GetScreenQuadrant(MicroMenuContainer);
	MicroMenu:UpdateFramerateFrameAnchor(position);
end

-- Helper function for FramerateFrameMixin:UpdatePosition.
local function GetDefaultRelativeAnchoring(microMenuPosition, isMenuHorizontal)
	return "BOTTOMRIGHT", "BOTTOMLEFT", -5, 0;
end

-- Helper function for FramerateFrameMixin:UpdatePosition.
local function GetMicroMenuRelativeAnchoring(microMenuPosition, isMenuHorizontal, isDefaultPosition)
	if isDefaultPosition then
		return GetDefaultRelativeAnchoring(microMenuPosition, isMenuHorizontal);
	end

	if isMenuHorizontal then
		if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
			return "BOTTOMLEFT", "BOTTOMRIGHT", 5, 0;
		elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
			return "BOTTOMRIGHT", "BOTTOMLEFT", -5, 0;
		elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
			return "TOPLEFT", "TOPRIGHT", 5, 0;
		elseif microMenuPosition == FrameUtilQuadrantEnum.TopRight then
			return "TOPRIGHT", "TOPLEFT", -5, 0;
		end
	else
		if microMenuPosition == FrameUtilQuadrantEnum.BottomLeft then
			return "BOTTOMLEFT", "TOPLEFT", 0, 5;
		elseif microMenuPosition == FrameUtilQuadrantEnum.BottomRight then
			return "BOTTOMRIGHT", "TOPRIGHT", 0, 5;
		elseif microMenuPosition == FrameUtilQuadrantEnum.TopLeft then
			return "TOPLEFT", "BOTTOMLEFT", 0, -5;
		else -- FrameUtilQuadrantEnum.TopRight
			return "TOPRIGHT", "BOTTOMRIGHT", 0, -5;
		end
	end
end

function FramerateFrameMixin:UpdatePosition(microMenuPosition, isMenuHorizontal, isDefaultPosition)
	-- Position relative to micro menu's position to avoid going off screen
	local point, relativePoint, offsetX, offsetY = GetMicroMenuRelativeAnchoring(microMenuPosition, isMenuHorizontal, isDefaultPosition);

	self:ClearAllPoints();
	self:SetPoint(point, MicroMenuContainer, relativePoint, offsetX, offsetY);
end
