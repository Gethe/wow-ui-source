
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


GridLayoutMixin = {};

-- If isVertical is true lay out columns first then rows, otherwise we lay out rows then columns
-- So for example with a stride of 2 and 6 frames this is how they would look using TopLeftToBottomRight and TopLeftToBottomRightVertical:
--
-- TopLeftToBottomRight				TopLeftToBottomRightVertical
-- 1	2							1	3	5
-- 3	4							2	4	6
-- 5	6
GridLayoutMixin.Direction = {
	TopLeftToBottomRight = { x = 1, y = -1 },
	TopRightToBottomLeft = { x = -1, y = -1 },
	TopLeftToBottomRightVertical = { x = 1, y = -1, isVertical = true },
	TopRightToBottomLeftVertical = { x = -1, y = -1, isVertical = true },
};

function GridLayoutMixin:Init(direction, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing)
	self.direction = direction or GridLayoutMixin.Direction.TopLeftToBottomRight;
	self.stride = stride or 1;
	self.paddingX = paddingX or 0;
	self.paddingY = paddingY or 0;
	self.horizontalSpacing = horizontalSpacing;
	self.verticalSpacing = verticalSpacing;
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
		local extraOffsetX = (col - 1) * (width + paddingX) * direction.x;
		local extraOffsetY = (row - 1) * (height + paddingY) * direction.y;
		initialAnchor:SetPointWithExtraOffset(frame, clearAllPoints, extraOffsetX, extraOffsetY);
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
		frame = factoryFunction(#frames + 1);
		if not frame then
			break;
		end

		table.insert(frames, frame);
	end

	AnchorUtil.GridLayout(frames, initialAnchor, layout);
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
