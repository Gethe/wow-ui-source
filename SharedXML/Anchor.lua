AnchorUtil = {};

AnchorMixin = {};

function AnchorUtil.CreateAnchor(clearPointsOnApply)
	local anchor = CreateFromMixins(AnchorMixin);
	anchor:OnLoad(clearPointsOnApply);
	return anchor;
end

function AnchorMixin:OnLoad(clearPointsOnApply)
	if clearPointsOnApply == nil then
		clearPointsOnApply = true;
	end

	self:SetClearPointsOnApply(clearPointsOnApply);
end

function AnchorMixin:SetAnchor(frame, point, relativeTo, relativePoint, x, y)
	self.frame = frame;
	self.point = point;
	self.relativeTo = relativeTo;
	self.relativePoint = relativePoint;
	self.x = x;
	self.y = y;
end

function AnchorMixin:GetFrame()
	return self.frame;
end

function AnchorMixin:SetClearPointsOnApply(clearPointsOnApply)
	self.clearPointsOnApply = clearPointsOnApply;
end

function AnchorMixin:Apply(frame, relativeTo)
	if self.clearPointsOnApply then
		self.frame:ClearAllPoints();
	end

	frame = frame or self.frame;
	relativeTo = relativeTo or self.relativeTo or frame:GetParent();
	local point = self.point or "TOPLEFT";
	local relativePoint = self.relativePoint or point;
	local x = self.x or 0;
	local y = self.y or 0;
	frame:SetPoint(point, relativeTo, relativePoint, x, y);
end