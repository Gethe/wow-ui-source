NineSliceMixin = {};

function AnchorUtil.CreateNineSlice(container)
	local nineSlice = CreateFromMixins(NineSliceMixin);
	nineSlice:OnLoad(container);
	return nineSlice;
end

function NineSliceMixin:OnLoad(container)
	assert(AnchorUtil ~= nil);

	self.topLeftCorner = AnchorUtil.CreateAnchor();
	self.topRightCorner = AnchorUtil.CreateAnchor();
	self.bottomLeftCorner = AnchorUtil.CreateAnchor();
	self.bottomRightCorner = AnchorUtil.CreateAnchor();
	self.topEdge = { AnchorUtil.CreateAnchor(), AnchorUtil.CreateAnchor(false) };
	self.bottomEdge = { AnchorUtil.CreateAnchor(), AnchorUtil.CreateAnchor(false) };
	self.leftEdge = { AnchorUtil.CreateAnchor(), AnchorUtil.CreateAnchor(false) };
	self.rightEdge = { AnchorUtil.CreateAnchor(), AnchorUtil.CreateAnchor(false) };

	self:SetContainer(container);
end

function NineSliceMixin:SetContainer(container)
	self.container = container;
end

function NineSliceMixin:SetTopLeftCorner(frame, x, y, point, relativePoint)
	self.topLeftCorner:SetAnchor(frame, point or "TOPLEFT", self.container, relativePoint, x, y);
end

function NineSliceMixin:SetTopRightCorner(frame, x, y, point, relativePoint)
	self.topRightCorner:SetAnchor(frame, point or "TOPRIGHT", self.container, relativePoint, x, y);
end

function NineSliceMixin:SetBottomLeftCorner(frame, x, y, point, relativePoint)
	self.bottomLeftCorner:SetAnchor(frame, point or "BOTTOMLEFT", self.container, relativePoint, x, y);
end

function NineSliceMixin:SetBottomRightCorner(frame, x, y, point, relativePoint)
	self.bottomRightCorner:SetAnchor(frame, point or "BOTTOMRIGHT", self.container, relativePoint, x, y);
end

function NineSliceMixin:SetTopEdge(frame, x1, y1, x2, y2)
	local first, second = unpack(self.topEdge);
	first:SetAnchor(frame, "TOPLEFT", self.topLeftCorner:GetFrame(), "TOPRIGHT", x1, y1);
	second:SetAnchor(frame, "TOPRIGHT", self.topRightCorner:GetFrame(), "TOPLEFT", x2, y2);
end

function NineSliceMixin:SetBottomEdge(frame, x1, y1, x2, y2)
	local first, second = unpack(self.bottomEdge);
	first:SetAnchor(frame, "BOTTOMLEFT", self.bottomLeftCorner:GetFrame(), "BOTTOMRIGHT", x1, y1);
	second:SetAnchor(frame, "BOTTOMRIGHT", self.bottomRightCorner:GetFrame(), "BOTTOMLEFT", x2, y21);
end

function NineSliceMixin:SetLeftEdge(frame, x1, y1, x2, y2)
	local first, second = unpack(self.leftEdge);
	first:SetAnchor(frame, "TOPLEFT", self.topLeftCorner:GetFrame(), "BOTTOMLEFT", x1, y1);
	second:SetAnchor(frame, "BOTTOMLEFT", self.bottomLeftCorner:GetFrame(), "TOPLEFT", x2, y2);
end

function NineSliceMixin:SetRightEdge(frame, x1, y1, x2, y2)
	local first, second = unpack(self.rightEdge);
	first:SetAnchor(frame, "TOPRIGHT", self.topRightCorner:GetFrame(), "BOTTOMRIGHT", x1, y1);
	second:SetAnchor(frame, "BOTTOMRIGHT", self.bottomRightCorner:GetFrame(), "TOPRIGHT", x2, y2);
end

function NineSliceMixin:SetCenter(frame, x1, y1, x2, y2)
	if not self.center then
		self.center = { AnchorUtil.CreateAnchor(), AnchorUtil.CreateAnchor(false) };
	end

	local first, second = unpack(self.center);
	first:SetAnchor(frame, "TOPLEFT", self.topLeftCorner:GetFrame(), "BOTTOMRIGHT", x1, y1);
	second:SetAnchor(frame, "BOTTOMRIGHT", self.bottomRightCorner:GetFrame(), "TOPLEFT", x2, y2);
end

function NineSliceMixin:Apply()
	self.topLeftCorner:Apply();
	self.topRightCorner:Apply();
	self.bottomLeftCorner:Apply();
	self.bottomRightCorner:Apply();

	self.topEdge[1]:Apply();
	self.topEdge[2]:Apply();
	self.bottomEdge[1]:Apply();
	self.bottomEdge[2]:Apply();
	self.leftEdge[1]:Apply();
	self.leftEdge[2]:Apply();
	self.rightEdge[1]:Apply();
	self.rightEdge[2]:Apply();

	if self.center then
		self.center[1]:Apply();
		self.center[2]:Apply();
	end
end