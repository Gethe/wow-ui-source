
AnchorMixin = {};

function AnchorMixin:Init(point, relativeTo, relativePoint, x, y)
	self:Set(point, relativeTo, relativePoint, x, y);
end

function AnchorMixin:Set(point, relativeTo, relativePoint, x, y)
	self.point = point;
	self.relativeTo = relativeTo;
	self.relativePoint = relativePoint;
	self.x = x;
	self.y = y;
end

function AnchorMixin:SetRelativeTo(relativeTo)
	self.relativeTo = relativeTo;
end

function AnchorMixin:SetOffsets(x, y)
	self.x = x;
	self.y = y;
end

function AnchorMixin:SetFromPoint(region, pointIndex)
	-- TODO: Need to check if this has no point set...probably don't want default behavior in some cases, probably
	-- want to signal something or return an invalid anchor.
	self:Set(region:GetPoint(pointIndex));
end

function AnchorMixin:Get()
	local point = self.point or "TOPLEFT";
	local relativePoint = self.relativePoint or "TOPLEFT";
	local x = self.x or 0;
	local y = self.y or 0;
	return point, self.relativeTo, relativePoint, x, y;
end

function AnchorMixin:GetRelativeTo()
	return self.relativeTo;
end

function AnchorMixin:SetPoint(region, clearAllPoints)
	if clearAllPoints then
		region:ClearAllPoints();
	end
	region:SetPoint(self:Get());
end

function AnchorMixin:SetPointWithExtraOffset(region, clearAllPoints, extraOffsetX, extraOffsetY)
	if clearAllPoints then
		region:ClearAllPoints();
	end
	local point, relativeTo, relativePoint, x, y = self:Get();
	region:SetPoint(point, relativeTo, relativePoint, x + extraOffsetX, y + extraOffsetY);
end

function CreateAnchor(point, relativeTo, relativePoint, x, y)
	return CreateAndInitFromMixin(AnchorMixin, point, relativeTo, relativePoint or point, x or 0, y or 0);
end

GridLayoutMixin = {};

-- If isVertical is true lay out columns first then rows, otherwise we lay out rows then columns
-- So for example with a stride of 2 and 6 frames this is how they would look using TopLeftToBottomRight and TopLeftToBottomRightVertical:
--
-- TopLeftToBottomRight				TopLeftToBottomRightVertical
-- 1	2							1	3	5
-- 3	4							2	4	6
-- 5	6
--
-- NOTE: The point/relativePoint fields are used in ChainLayout (which doesn't support wrapping) for subsequent frames anchored in the chain.
GridLayoutMixin.Direction = {
	TopLeftToBottomRight = { x = 1, y = -1, point = "TOPLEFT", relativePoint = "TOPRIGHT", },
	TopRightToBottomLeft = { x = -1, y = -1, point = "TOPRIGHT", relativePoint = "TOPLEFT", },
	BottomLeftToTopRight = { x = 1, y = -1, point = "BOTTOMLEFT", relativePoint = "BOTTOMRIGHT", },
	BottomRightToTopLeft = { x = -1, y = 1, point = "BOTTOMRIGHT", relativePoint = "BOTTOMLEFT", },
	TopLeftToBottomRightVertical = { x = 1, y = -1, isVertical = true, point = "TOPLEFT", relativePoint = "TOPRIGHT", },
	TopRightToBottomLeftVertical = { x = -1, y = -1, isVertical = true, point = "TOPRIGHT", relativePoint = "TOPLEFT", },
	BottomLeftToTopRightVertical = { x = 1, y = 1, isVertical = true, point = "BOTTOMLEFT", relativePoint = "BOTTOMRIGHT" },
	BottomRightToTopLeftVertical = { x = -1, y = 1, isVertical = true, point = "BOTTOMRIGHT", relativePoint = "BOTTOMLEFT" },
	LeftToRight = { x = 1, y = 0, point = "LEFT", relativePoint = "RIGHT", },
	RightToLeft = { x = -1, y = 0, point = "RIGHT", relativePoint = "LEFT", },
	TopToBottom = { x = 0, y = 1, isVertical = true, point = "TOP", relativePoint = "BOTTOM", },
	BottomToTop = { x = 0, y = -1, isVertical = true, point = "BOTTOM", relativePoint = "TOP", },
};

function GridLayoutMixin:Init(direction, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing)
	self.direction = direction or GridLayoutMixin.Direction.TopLeftToBottomRight;
	self.stride = stride or 1;
	self.paddingX = paddingX or 0;
	self.paddingY = paddingY or 0;
	self.horizontalSpacing = horizontalSpacing;
	self.verticalSpacing = verticalSpacing;
end

function GridLayoutMixin:SetCustomOffsetFunction(func)
	self.customOffsetFunction = func;
end

function GridLayoutMixin:GetCustomOffset(row, col)
	if self.customOffsetFunction then
		return self.customOffsetFunction(row, col);
	end

	return 0, 0;
end


AnchorUtil = {};

AnchorUtil.CreateAnchor = GenerateClosure(CreateAndInitFromMixin, AnchorMixin);
AnchorUtil.CreateGridLayout = GenerateClosure(CreateAndInitFromMixin, GridLayoutMixin);

function AnchorUtil.CreateAnchorFromPoint(region, pointIndex)
	local anchor = AnchorUtil.CreateAnchor();
	anchor:SetFromPoint(region, pointIndex);
	return anchor;
end

-- For initialAnchor and layout, use AnchorUtil.CreateAnchor(...) and AnchorUtil.CreateGridLayout(...)
function AnchorUtil.GridLayout(frames, initialAnchor, layout)
	if #frames <= 0 then
		return;
	end

	local width = layout.horizontalSpacing or frames[1]:GetWidth();
	local height = layout.verticalSpacing or frames[1]:GetHeight();
	local stride = layout.stride;
	local paddingX = layout.paddingX;
	local paddingY = layout.paddingY;
	local direction = layout.direction;
	for i, frame in ipairs(frames) do
		local row = math.floor((i - 1) / stride) + 1;
		local col = (i - 1) % stride + 1;
		if direction.isVertical then
			local tempRow = row;
			row = col;
			col = tempRow;
		end
		local clearAllPoints = true;
		local customOffsetX, customOffsetY = layout:GetCustomOffset(row, col);
		local extraOffsetX = (col - 1) * (width + paddingX) * direction.x + customOffsetX;
		local extraOffsetY = (row - 1) * (height + paddingY) * direction.y + customOffsetY;
		initialAnchor:SetPointWithExtraOffset(frame, clearAllPoints, extraOffsetX, extraOffsetY);
	end
end

local function UpdateAnchorForChain(previousFrame, anchor, layout, resetAnchorOffsetsAfterInitialAnchor)
	local _point, _relativeTo, _relativePoint, x, y = anchor:Get();

	if resetAnchorOffsetsAfterInitialAnchor then
		x = 0;
		y = 0;
	end

	-- Spacing can still be applied to subsequent anchors, when the initial offset may have been reset.
	if layout then
		x = layout.horizontalSpacing or x;
		y = layout.verticalSpacing or y;
	end

	local direction = (layout and layout.direction) or GridLayoutMixin.Direction.LeftToRight;
	anchor:Set(direction.point, previousFrame, direction.relativePoint, x, y);
end

function AnchorUtil.ChainLayout(frames, initialAnchor, layout, resetAnchorOffsetsAfterInitialAnchor)
	local anchor = CreateAnchor(initialAnchor:Get());
	for i, frame in ipairs(frames) do
		anchor:SetPoint(frame);
		UpdateAnchorForChain(frame, anchor, layout, resetAnchorOffsetsAfterInitialAnchor);
	end
end

-- For initialAnchor and layout, use AnchorUtil.CreateAnchor(...)
function AnchorUtil.VerticalLayout(frames, initialAnchor, padding)
	if #frames <= 0 then
		return;
	end

	local clearAllPoints = true;
	initialAnchor:SetPoint(frames[1], clearAllPoints);

	padding = padding or 0;

	for index, region in CreateTableEnumerator(frames, 2) do
		region:ClearAllPoints();
		region:SetPoint("TOPLEFT", frames[index-1], "BOTTOMLEFT", 0, -padding);
	end
end

local function GetFrameSpacing(totalSize, numElements, elementSize)
	if numElements <= 1 then
		return 0;
	end

	return (totalSize - (numElements * elementSize)) / (numElements - 1);
end

local function SanitizeTotalSize(size)
	if not size or size == 0 then
		return math.huge;
	else
		return Round(size);
	end
end

-- For initialAnchor and layout, use AnchorUtil.CreateAnchor(...) and AnchorUtil.CreateGridLayout(...)
function AnchorUtil.GridLayoutFactoryByCount(factoryFunction, count, initialAnchor, layout)
	if count <= 0 then
		return;
	end

	local frames = { };
	while #frames < count do
		local frame = factoryFunction(#frames + 1);
		if not frame then
			break;
		end

		table.insert(frames, frame);
	end

	AnchorUtil.GridLayout(frames, initialAnchor, layout);

	return frames;
end

-- For initialAnchor, use AnchorUtil.CreateAnchor(...)
function AnchorUtil.GridLayoutFactory(factoryFunction, initialAnchor, totalWidth, totalHeight, overrideDirection, overridePaddingX, overridePaddingY)
	local frame = factoryFunction(1);
	if not frame then
		return;
	end

	totalWidth = SanitizeTotalSize(totalWidth);
	totalHeight = SanitizeTotalSize(totalHeight);

	-- If we have an override padding, count it in the frame width. We add a padding to totalWidth/totalHeight to account for the
	-- extra space we save for the last element which doesn't need padding.
	local width = Round(frame:GetWidth()) + (overridePaddingX or 0);
	local height = Round(frame:GetHeight()) + (overridePaddingY or 0);
	local rowSize = math.floor((totalWidth + (overridePaddingX or 0)) / width);
	local colSize = math.floor((totalHeight + (overridePaddingY or 0)) / height);

	local spacingX = overridePaddingX or GetFrameSpacing(totalWidth, rowSize, width);
	local spacingY = overridePaddingY or GetFrameSpacing(totalHeight, colSize, height);

	local frames = { frame };
	while #frames < rowSize * colSize do
		frame = factoryFunction(#frames + 1);
		if not frame then
			break;
		end

		table.insert(frames, frame);
	end

	local direction = overrideDirection or GridLayoutMixin.Direction.TopLeftToBottomRight;

	AnchorUtil.GridLayout(frames, initialAnchor, AnchorUtil.CreateGridLayout(direction, rowSize, spacingX, spacingY));
end

local function LongestCommonPrefix(s1, s2)
	if s1 == s2 then
		return s1;
	end

	for i = 1, math.min(#s1, #s2) do
		if s1:byte(i) ~= s2:byte(i) then
			return (i > 1) and s1:sub(1, i - 1) or "";
		end
	end

	-- If one string is empty and the other isn't, then we won't enter the loop.
	-- Returning the empty string since there's no common prefix.
	return "";
end

function AnchorUtil.GetRelativeToAttributeStrings(target, relativeTo, alwaysReturnAttributesIfPossible)
	-- Maybe this is just anchored to its parent and we don't need a relativeTo attribute
	local anchoredToParent = relativeTo and target:GetParent() == relativeTo;
	if not relativeTo or anchoredToParent then
		if alwaysReturnAttributesIfPossible then
			return "relativeKey", "$parent";
		end

		return;
	end

	local relativeToName = relativeTo:GetDebugName();
	local targetName = target:GetDebugName();
	local useRelativeKey = relativeToName:find(".", 1, true) ~= nil;
	local delimiter = useRelativeKey and "." or "";
	local s, e = relativeToName:find(LongestCommonPrefix(targetName, relativeToName));

	-- Found that some substring of targetName was relativeToName.
	if e ~= nil then
		local relativeToValue = relativeToName:sub(e + 1);
		local value = "$parent" .. delimiter .. relativeToValue;

		if useRelativeKey then
			return "relativeKey", value;
		else
			return "relativeTo", value;
		end
	end

	-- If there's no match here, then just use the full name of relativeTo
	return "relativeTo", relativeToName;
end

-- Mirrors an array of regions along the specified axis. For example, if horizontal, a region
-- anchored LEFT TOPLEFT 20 20 will become anchored RIGHT TOPRIGHT -20 20.
-- Mirror description format: {region = region, mirrorUV = [true, false]}
local function MirrorRegionsAlongAxis(mirrorDescriptions, exchangeables, setPointWrapper, setTexCoordsWrapper)
	for _, description in ipairs(mirrorDescriptions) do
		local exchanged = {};

		local region = description.region;
		local mirrorUV = description.mirrorUV;
		for p in pairs(exchangeables) do
			if not exchanged[p] then
				local point1, relative1, relativePoint1, x1, y1 = region:GetPointByName(p);
				if point1 then
					-- Retrieve point information for what we're replacing, if any.
					local mirrorPoint1 = exchangeables[point1];
					local point2, relative2, relativePoint2, x2, y2 = region:GetPointByName(mirrorPoint1);
					setPointWrapper(region, point1, relative1, relativePoint1, x1, y1);

					-- If we replaced a point, mirror the information to the original point.
					if point2 then
						setPointWrapper(region, point2, relative2, relativePoint2, x2, y2);
					else
						-- Otherwise, clear the original point.
						region:ClearPoint(point1);
					end

					exchanged[point1] = true;
					exchanged[mirrorPoint1] = true;
				end
			end
		end

		if mirrorUV then
			setTexCoordsWrapper(region);
		end
	end
end

local SetPointAlongAxis = function(points, region, point, relative, relativePoint, x, y)
	local mirrorPoint = points[point];
	local mirrorRelativePoint = points[relativePoint] or relativePoint;
	region:SetPoint(mirrorPoint, relative, mirrorRelativePoint, x, y);
end

local VERTICAL_MIRROR_POINTS =
{
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOP"] = "BOTTOM",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOM"] = "TOP",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["CENTER"] = "CENTER", -- Mirrored only along x and y offsets.
	["LEFT"] = "LEFT", -- Mirrored only  along x and y offsets.
	["RIGHT"] = "RIGHT", -- Mirrored only along x and y offsets.
};

function AnchorUtil.SetMirroredPointAlongVerticalAxis(region, point, relative, relativePoint, x, y)
	SetPointAlongAxis(VERTICAL_MIRROR_POINTS, region, point, relative, relativePoint, x, -y);
end

function AnchorUtil.SetMirroredTexCoordAlongVerticalAxis(region, x1, y1, x2, y2, x3, y3, x4, y4)
	region:SetTexCoord(x2, y2, x1, y1, x4, y4, x3, y3);
end

local SetTexCoordVertical = function(region)
	AnchorUtil.SetMirroredTexCoordAlongVerticalAxis(region, region:GetTexCoord());
end

function AnchorUtil.MirrorRegionsAlongVerticalAxis(mirrorDescriptions)
	local setPointWrapper = AnchorUtil.SetMirroredPointAlongVerticalAxis;
	local setTexCoordsWrapper = SetTexCoordVertical;
	MirrorRegionsAlongAxis(mirrorDescriptions, VERTICAL_MIRROR_POINTS, setPointWrapper, setTexCoordsWrapper);
end

local HORIZONTAL_MIRROR_POINTS =
{
	["TOPLEFT"] = "TOPRIGHT",
	["LEFT"] = "RIGHT",
	["BOTTOMLEFT"] = "BOTTOMRIGHT",
	["TOPRIGHT"] = "TOPLEFT",
	["RIGHT"] = "LEFT",
	["BOTTOMRIGHT"] = "BOTTOMLEFT",
	["CENTER"] = "CENTER", -- Mirrored only along x and y offsets.
	["TOP"] = "TOP", -- Mirrored only along x and y offsets.
	["BOTTOM"] = "BOTTOM", -- Mirrored only along x and y offsets.
};

function AnchorUtil.SetMirroredPointAlongHorizontalAxis(region, point, relative, relativePoint, x, y)
	SetPointAlongAxis(HORIZONTAL_MIRROR_POINTS, region, point, relative, relativePoint, -x, y);
end

function AnchorUtil.SetMirroredTexCoordAlongHorizontalAxis(region, x1, y1, x2, y2, x3, y3, x4, y4)
	region:SetTexCoord(x3, y3, x4, y4, x1, y1, x2, y2);
end

local SetTexCoordHorizontal = function(region)
	AnchorUtil.SetMirroredTexCoordAlongHorizontalAxis(region, region:GetTexCoord());
end

function AnchorUtil.MirrorRegionsAlongHorizontalAxis(mirrorDescriptions)
	local setPointWrapper = AnchorUtil.SetMirroredPointAlongHorizontalAxis;
	local setTexCoordsWrapper = SetTexCoordHorizontal;
	MirrorRegionsAlongAxis(mirrorDescriptions, HORIZONTAL_MIRROR_POINTS, setPointWrapper, setTexCoordsWrapper);
end

local function DebugAnchorGraph(frame, indent, visited, output)
	local indentString = "      ";
	indent = indent or indentString;
	output = output or {};
	visited = visited or {};

	if frame.GetWindowSize then
		return output;
	end

	if visited[frame] then
		return output;
	end

	visited[frame] = true;

	local function FormatFrame(frame)
		local color = frame:IsRectValid() and GREEN_FONT_COLOR or RED_FONT_COLOR;
		local x, y = frame:GetSize();
		local x2, y2 = frame:GetSize(true);
		return color:WrapTextInColorCode(frame:GetDebugName() .. (" calculated size <%.2f, %.2f> explicit size <%.2f, %.2f> points <%d>, scale <%.2f> effective scale <%.2f>"):format(
			x, y, x2, y2, frame:GetNumPoints(), frame:GetScale(), frame:GetEffectiveScale()));
	end
	table.insert(output, indent .. FormatFrame(frame));

	for i = 1, frame:GetNumPoints() do
		local point, relativeTo, relativePoint, x, y = frame:GetPoint(i);
		local anchorString = ("Anchor%d %s to %s at %s offset <%.2f, %.2f>"):format(i, point, relativeTo and relativeTo:GetDebugName() or "?", relativePoint, x, y);
		table.insert(output, indent .. LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(anchorString));
		if relativeTo then
			DebugAnchorGraph(relativeTo, indent .. indentString, visited, output);
		end
	end

	return output;
end

function AnchorUtil.PrintAnchorGraph(frame)
	C_Log.LogMessage(table.concat(DebugAnchorGraph(frame), "\n"));
end

function AnchorUtil.AdjustPointByName(region, pointName, extraOffsetX, extraOffsetY)
	local point, relativeTo, relativePoint, offsetX, offsetY = region:GetPointByName(pointName);
	region:SetPoint(point, relativeTo, relativePoint, offsetX + extraOffsetX, offsetY + extraOffsetY);
end

AnchorUtil.FlowLayoutAxis =
{
	Horizontal = 0,
	Vertical = 1,
};

AnchorUtil.FlowDirection =
{
	Left = -1,
	Right = 1,
	Up = 1,
	Down = -1,
};

local FlowLayoutMixin = {};
AnchorUtil.FlowLayoutMixin = FlowLayoutMixin;

function FlowLayoutMixin:Init()
	self:ResetOptions();
end

function FlowLayoutMixin:ResetOptions()
	self.layoutAxis = AnchorUtil.FlowLayoutAxis.Horizontal;
	self.anchorPoint = "TOPLEFT";
	self.horizontalGrowthDirection = AnchorUtil.FlowDirection.Right;
	self.verticalGrowthDirection = AnchorUtil.FlowDirection.Down;
	self.paddingLeft = 0;
	self.paddingRight = 0;
	self.paddingTop = 0;
	self.paddingBottom = 0;
	self.maximumLineSize = math.huge;
end

function FlowLayoutMixin:GetLayoutAxis()
	return self.layoutAxis;
end

function FlowLayoutMixin:SetLayoutAxis(layoutAxis)
	if self.layoutAxis == layoutAxis then
		return false;
	end

	self.layoutAxis = layoutAxis;
	return true;
end

function FlowLayoutMixin:GetAnchorPoint()
	return self.anchorPoint;
end

function FlowLayoutMixin:SetAnchorPoint(anchorPoint)
	if self.anchorPoint == anchorPoint then
		return false;
	end

	self.anchorPoint = anchorPoint;
	return true;
end

function FlowLayoutMixin:GetHorizontalGrowthDirection()
	return self.horizontalGrowthDirection;
end

function FlowLayoutMixin:GetVerticalGrowthDirection()
	return self.verticalGrowthDirection;
end

function FlowLayoutMixin:GetGrowthDirection()
	return self.horizontalGrowthDirection, self.verticalGrowthDirection;
end

function FlowLayoutMixin:SetGrowthDirection(horizontalDirection, verticalDirection)
	if self.horizontalGrowthDirection == horizontalDirection and self.verticalGrowthDirection == verticalDirection then
		return false;
	end

	self.horizontalGrowthDirection = horizontalDirection;
	self.verticalGrowthDirection = verticalDirection;
	return true;
end

function FlowLayoutMixin:GetPadding()
	return self.paddingLeft, self.paddingRight, self.paddingTop, self.paddingBottom;
end

function FlowLayoutMixin:SetPadding(left, right, top, bottom)
	if self.paddingLeft == left and self.paddingRight == right and self.paddingTop == top and self.paddingBottom == bottom then
		return false;
	end

	self.paddingLeft = left;
	self.paddingRight = right;
	self.paddingTop = top;
	self.paddingBottom = bottom;
	return true;
end

function FlowLayoutMixin:GetMaximumLineSize()
	return self.maximumLineSize;
end

function FlowLayoutMixin:SetMaximumLineSize(maximumLineSize)
	if self.maximumLineSize == maximumLineSize then
		return false;
	end

	self.maximumLineSize = maximumLineSize;
	return true;
end

function FlowLayoutMixin:GetMaximumLineSizeForLine(_container, _lineIndex, _group)
	-- Override to determine the maximum space available along the primary
	-- axis for a specific line. The default uses the configured maximum.
	return self:GetMaximumLineSize();
end

function FlowLayoutMixin:GetElementSize(_container, element, _group)
	-- Override to return the space this element should consume in the layout.
	-- This default implementation uses the natural size of the element.
	return element:GetSize();
end

function FlowLayoutMixin:ApplyElementLayout(container, element, anchorPoint, offsetX, offsetY, _width, _height)
	-- Override to apply calculated layout properties to elements. This should
	-- at minimum apply the anchor point.
	--
	-- Width and height are ignored in this default implementation because the
	-- element's natural size is used for layout.
	element:ClearAllPoints();
	element:SetPoint(anchorPoint, container, anchorPoint, offsetX, offsetY);
end

function FlowLayoutMixin:OnLayoutComplete(container, width, height, _hasPlacedElement, _lineCount)
	-- Override to apply any final changes after the layout pass has completed.
	container:SetSize(width, height);
end

function FlowLayoutMixin:Apply(container, groups)
	AnchorUtil.ApplyFlowLayout(container, groups, self);
end

function AnchorUtil.CreateFlowLayout()
	local layout = CreateFromMixins(FlowLayoutMixin);
	layout:Init();
	return layout;
end

-- Flow layout groups support the following options:
--
-- elements
--     An array of elements, or a function returning one. Empty groups do not
--     contribute spacing or force a new line.
--
-- elementSpacing
--     Spacing between elements along the primary axis.
--
-- lineSpacing
--     Spacing along the cross axis when element placement wraps naturally
--     onto a new line.
--
-- groupSpacing
--     Spacing along the primary axis before a non-empty group that continues
--     on the current line. This spacing may itself cause the group to wrap.
--
-- groupLineSpacing
--     Spacing along the cross axis when a group starts a new line, either
--     explicitly or because groupSpacing caused wrapping. Defaults to
--     lineSpacing.
--
-- forceNewLine
--     Starts a non-empty group on a new line when another element has already
--     been placed.
function AnchorUtil.ApplyFlowLayout(container, groups, layout)
	local anchorPoint = layout:GetAnchorPoint();
	local layoutAxis = layout:GetLayoutAxis();
	local horizontalDirection = layout:GetHorizontalGrowthDirection();
	local verticalDirection = layout:GetVerticalGrowthDirection();
	local paddingLeft, paddingRight, paddingTop, paddingBottom = layout:GetPadding();

	-- Padding is applied relative to the growth direction on each physical axis.
	local startPaddingX = horizontalDirection == AnchorUtil.FlowDirection.Right and paddingLeft or paddingRight;
	local endPaddingX = horizontalDirection == AnchorUtil.FlowDirection.Right and paddingRight or paddingLeft;
	local startPaddingY = verticalDirection == AnchorUtil.FlowDirection.Down and paddingTop or paddingBottom;
	local endPaddingY = verticalDirection == AnchorUtil.FlowDirection.Down and paddingBottom or paddingTop;

	-- The primary axis determines the direction in which elements flow.
	-- The cross axis determines the direction in which new lines are added.
	local isVertical = layoutAxis == AnchorUtil.FlowLayoutAxis.Vertical;
	local primaryDirection = isVertical and verticalDirection or horizontalDirection;
	local crossDirection = isVertical and horizontalDirection or verticalDirection;
	local startPrimaryPadding = isVertical and startPaddingY or startPaddingX;
	local endPrimaryPadding = isVertical and endPaddingY or endPaddingX;
	local startCrossPadding = isVertical and startPaddingX or startPaddingY;
	local endCrossPadding = isVertical and endPaddingX or endPaddingY;

	-- Cursor offsets describe element placement along the primary and cross
	-- axes. Elements are anchored relative to the container rather than
	-- chaining anchors between one another.
	local cursorPrimary = startPrimaryPadding * primaryDirection;
	local cursorCross = startCrossPadding * crossDirection;

	-- The primary size tracks the consumed space along the current line,
	-- including trailing element spacing. The cross size tracks the largest
	-- element extent perpendicular to the line.
	local lineIndex = 1;
	local linePrimarySize = 0;
	local lineCrossSize = 0;
	local layoutPrimarySize = startPrimaryPadding + endPrimaryPadding;
	local layoutCrossSize = startCrossPadding + endCrossPadding;
	local hasPlacedElement = false;

	local function AdvanceToNextLine(crossGap)
		cursorPrimary = startPrimaryPadding * primaryDirection;
		cursorCross = cursorCross + ((lineCrossSize + crossGap) * crossDirection);
		lineIndex = lineIndex + 1;
		linePrimarySize = 0;
		lineCrossSize = 0;
	end

	for _groupIndex, group in ipairs(groups) do
		local elements = GetValueOrCallFunction(group, "elements");
		local elementSpacing = group.elementSpacing or 0;
		local lineSpacing = group.lineSpacing or 0;
		local groupSpacing = group.groupSpacing or 0;
		local groupLineSpacing = group.groupLineSpacing or lineSpacing;

		-- Groups may force a new line or continue on the current line after
		-- optional spacing. That spacing may itself trigger wrapping.
		if hasPlacedElement and #elements > 0 then
			if group.forceNewLine then
				AdvanceToNextLine(groupLineSpacing);
			elseif groupSpacing > 0 then
				local maximumLineSize = layout:GetMaximumLineSizeForLine(container, lineIndex, group);

				if linePrimarySize > 0 and linePrimarySize + groupSpacing > maximumLineSize then
					AdvanceToNextLine(groupLineSpacing);
				else
					cursorPrimary = cursorPrimary + (groupSpacing * primaryDirection);
					linePrimarySize = linePrimarySize + groupSpacing;
				end
			end
		end

		for _elementIndex, element in ipairs(elements) do
			local width, height = layout:GetElementSize(container, element, group);
			local elementPrimarySize = isVertical and height or width;
			local elementCrossSize = isVertical and width or height;
			local maximumLineSize = layout:GetMaximumLineSizeForLine(container, lineIndex, group);
			local nextLinePrimarySize = linePrimarySize > 0 and linePrimarySize + elementPrimarySize or elementPrimarySize;

			if linePrimarySize > 0 and nextLinePrimarySize > maximumLineSize then
				AdvanceToNextLine(lineSpacing);
				nextLinePrimarySize = elementPrimarySize;
			end

			-- Convert the primary/cross-axis cursors back into physical offsets
			-- before applying the element layout.
			local offsetX = isVertical and cursorCross or cursorPrimary;
			local offsetY = isVertical and cursorPrimary or cursorCross;
			layout:ApplyElementLayout(container, element, anchorPoint, offsetX, offsetY, width, height);

			cursorPrimary = cursorPrimary + ((elementPrimarySize + elementSpacing) * primaryDirection);
			linePrimarySize = nextLinePrimarySize + elementSpacing;
			lineCrossSize = math.max(lineCrossSize, elementCrossSize);

			-- Bounds exclude trailing element spacing because spacing belongs
			-- between elements, not after the final element in a line.
			--
			-- The consumed primary size does not include start padding, so add it
			-- explicitly. The trailing element spacing is excluded from the bound.
			layoutPrimarySize = math.max(layoutPrimarySize, startPrimaryPadding + linePrimarySize - elementSpacing + endPrimaryPadding);

			-- The cross cursor already includes start padding through its initial offset.
			layoutCrossSize = math.max(layoutCrossSize, math.abs(cursorCross) + elementCrossSize + endCrossPadding);
			hasPlacedElement = true;
		end
	end

	local lineCount = hasPlacedElement and lineIndex or 0;
	local layoutWidth = isVertical and layoutCrossSize or layoutPrimarySize;
	local layoutHeight = isVertical and layoutPrimarySize or layoutCrossSize;
	layout:OnLayoutComplete(container, math.max(layoutWidth, 1), math.max(layoutHeight, 1), hasPlacedElement, lineCount);
end
