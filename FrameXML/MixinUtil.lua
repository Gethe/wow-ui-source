-- The following function is used with permission from Daniel Stephens
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
		local change = self.initialAnimatedValueDelta * (elapsed / self:GetAnimatedDurationTimeSec());
		if math.abs(self.targetAnimatedValue - self.currentAnimatedValue) <= change then
			self:SnapToTarget();
		else
			local direction = self.targetAnimatedValue > self.currentAnimatedValue and 1 or -1;
			self.currentAnimatedValue = self.currentAnimatedValue + direction * change;

			self:SetText(BreakUpLargeNumbers(Round(self.currentAnimatedValue)));
		end
	end
end

SparseGridMixin = {};

function SparseGridMixin:OnLoad(width, height)
	self.width = width;
	self.height = height;
	self.cells = {};
end

function SparseGridMixin:SetCell(x, y, data)
	if not self:IsInRange(x, y) then
		error("index of out of range");
	end

	local linearIndex = self:CalculateLinearIndex(x, y);
	self.cells[linearIndex] = data;
end

function SparseGridMixin:GetCell(x, y)
	if not self:IsInRange(x, y) then
		error("index of out of range");
	end

	local linearIndex = self:CalculateLinearIndex(x, y);
	return self.cells[linearIndex];
end

function SparseGridMixin:IsInRange(x, y)
	return x > 0 and x <= self.width and y > 0 and y <= self.height;
end

function SparseGridMixin:Clear()
	wipe(self.cells);
end

function SparseGridMixin:CalculateLinearIndex(x, y)
	return x + self.width * (y - 1);
end