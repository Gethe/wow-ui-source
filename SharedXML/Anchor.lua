---------------
--NOTE - Please do not change this section without talking to Dan
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

	Import("pairs");
	Import("select");

	function Mixin(object, ...)
		for i = 1, select("#", ...) do
			local mixin = select(i, ...);
			for k, v in pairs(mixin) do
				object[k] = v;
			end
		end

		return object;
	end

	function CreateFromMixins(...)
		return Mixin({}, ...)
	end
end
---------------

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