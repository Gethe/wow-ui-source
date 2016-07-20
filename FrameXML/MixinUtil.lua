-- The following function is used with permission from Daniel Stephens <iriel@vigilance-committee.org>
-- texture			- Texture
-- canvasFrame      - Canvas Frame (for anchoring)
-- startX,startY    - Coordinate of start of line
-- endX,endY		- Coordinate of end of line
-- lineWidth        - Width of line
-- relPoint			- Relative point on canvas to interpret coords (Default BOTTOMLEFT)
function DrawLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, lineFactor, relPoint)
	if (not relPoint) then relPoint = "BOTTOMLEFT"; end
	lineFactor = lineFactor * .5;

	-- Determine dimensions and center point of line
	local dx,dy = endX - startX, endY - startY;
	local cx,cy = (startX + endX) / 2, (startY + endY) / 2;

	-- Normalize direction if necessary
	if (dx < 0) then
		dx,dy = -dx,-dy;
	end

	-- Calculate actual length of line
	local lineLength = sqrt((dx * dx) + (dy * dy));

	-- Quick escape if it'sin zero length
	if (lineLength == 0) then
		texture:SetTexCoord(0,0,0,0,0,0,0,0);
		texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx,cy);
		texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx,cy);
		return;
	end

	-- Sin and Cosine of rotation, and combination (for later)
	local sin, cos = -dy / lineLength, dx / lineLength;
	local sinCos = sin * cos;

	-- Calculate bounding box size and texture coordinates
	local boundingWidth, boundingHeight, bottomLeftX, bottomLeftY, topLeftX, topLeftY, topRightX, topRightY, bottomRightX, bottomRightY;
	if (dy >= 0) then
		boundingWidth = ((lineLength * cos) - (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) - (lineLength * sin)) * lineFactor;

		bottomLeftX = (lineWidth / lineLength) * sinCos; 
		bottomLeftY = sin * sin;
		bottomRightY = (lineLength / lineWidth) * sinCos;
		bottomRightX = 1 - bottomLeftY;

		topLeftX = bottomLeftY;
		topLeftY = 1 - bottomRightY;
		topRightX = 1 - bottomLeftX; 
		topRightY = bottomRightX;
	else
		boundingWidth = ((lineLength * cos) + (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) + (lineLength * sin)) * lineFactor;

		bottomLeftX = sin * sin; 
		bottomLeftY = -(lineLength / lineWidth) * sinCos; 
		bottomRightX = 1 + (lineWidth / lineLength) * sinCos;
		bottomRightY = bottomLeftX;

		topLeftX = 1 - bottomRightX;
		topLeftY = 1 - bottomLeftX;
		topRightY = 1 - bottomLeftY;
		topRightX = topLeftY;
	end

	-- Set texture coordinates and anchors
	texture:ClearAllPoints();
	texture:SetTexCoord(topLeftX, topLeftY, bottomLeftX, bottomLeftY, topRightX, topRightY, bottomRightX, bottomRightY);
	texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx - boundingWidth, cy - boundingHeight);
	texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx + boundingWidth, cy + boundingHeight);
end

-- Mix this into a Texture to be able to treat it like a line
LineMixin = {};

function LineMixin:SetStartPoint(x, y)
	self.startX, self.startY = x, y;
end

function LineMixin:SetEndPoint(x, y)
	self.endX, self.endY = x, y;
end

function LineMixin:SetThickness(thickness)
	self.thickness = thickness;
end

function LineMixin:Draw()
	local parent = self:GetParent();
	local x, y = parent:GetLeft(), parent:GetBottom();

	self:ClearAllPoints();
	DrawLine(self, parent, self.startX - x, self.startY - y, self.endX - x, self.endY - y, self.thickness or 32, 1);
end

-- Mix this into a FontString to have it animate towards its value, call UpdateAnimatedValue every frame
AnimatedNumericFontStringMixin = {};

-- How long should it take to animate
function AnimatedNumericFontStringMixin:SetAnimatedDurationTimeSec(animatedDurationTimeSec)
	self.animatedDurationTimeSec = animatedDurationTimeSec;
end

function AnimatedNumericFontStringMixin:GetAnimatedDurationTimeSec()
	return self.animatedDurationTimeSec or 1.0;
end

function AnimatedNumericFontStringMixin:SetAnimatedValue(value)
	self.targetAnimatedValue = value;
	if not self.currentAnimatedValue then
		self.currentAnimatedValue = self.targetAnimatedValue;
	end
	self.initialAnimatedValueDelta = math.abs(self.targetAnimatedValue - self.currentAnimatedValue);
end

local function Round(value)
	if value < 0.0 then
		return math.ceil(value - .5);
	end
	return math.floor(value + .5);
end

-- Stops animating the value and just snaps to it
function AnimatedNumericFontStringMixin:SnapToTarget()
	if self.targetAnimatedValue then
		self:SetText(BreakUpLargeNumbers(Round(self.targetAnimatedValue)));
		self.currentAnimatedValue = self.targetAnimatedValue;
		self.targetAnimatedValue = nil;
	end
end

-- Call this every frame
function AnimatedNumericFontStringMixin:UpdateAnimatedValue(elapsed)
	if self.targetAnimatedValue then
		local change = self.initialAnimatedValueDelta * self:GetAnimatedDurationTimeSec() * elapsed;
		if math.abs(self.targetAnimatedValue - self.currentAnimatedValue) <= change then
			self:SnapToTarget();
		else
			local direction = self.targetAnimatedValue > self.currentAnimatedValue and 1 or -1;
			self.currentAnimatedValue = self.currentAnimatedValue + direction * change;

			self:SetText(BreakUpLargeNumbers(Round(self.currentAnimatedValue)));
		end
	end
end

-- Mix this into a FontString to have it resize until it stops truncating, or gets too small
ShrinkUntilTruncateFontStringMixin = {};

-- From largest to smallest
function ShrinkUntilTruncateFontStringMixin:SetFontObjectsToTry(...)
	self.fontObjectsToTry = { ... };
	if self:GetText() then
		self:ApplyFontObjects();
	end
end

function ShrinkUntilTruncateFontStringMixin:ApplyFontObjects()
	if not self.fontObjectsToTry then
		error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
	end

	for i, fontObject in ipairs(self.fontObjectsToTry) do
		self:SetFontObject(fontObject);
		if not self:IsTruncated() then
			break;
		end
	end
end

function ShrinkUntilTruncateFontStringMixin:SetText(text)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetText(self, text);
	self:ApplyFontObjects();
end

function ShrinkUntilTruncateFontStringMixin:SetFormattedText(format, ...)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetFormattedText(self, format, ...);
	self:ApplyFontObjects();
end