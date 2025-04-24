
ButtonStateBehaviorMixin = {};

function ButtonStateBehaviorMixin:OnLoad()
	self:OnButtonStateChanged();
end

-- Will displace regions on mouse down and on mouse up.
function ButtonStateBehaviorMixin:SetDisplacedRegions(x, y, ...)
	self.displacedRegions = {...};
	self.displaceX = x;
	self.displaceY = y;
end

-- Will saturate/desaturate the entire button hierarchy when enabled and disabled.
function ButtonStateBehaviorMixin:DesaturateIfDisabled()
	self.desaturateIfDisabled = true;
end

function ButtonStateBehaviorMixin:OnButtonStateChanged()
	-- Derive and configure your button to the correct state.
end

function ButtonStateBehaviorMixin:IsDownOver()
	return self.down and self.over;
end

function ButtonStateBehaviorMixin:IsDown()
	return self.down;
end

function ButtonStateBehaviorMixin:IsOver()
	return self.over;
end

function ButtonStateBehaviorMixin:OnEnter()
	if self:IsEnabled() then
		self.over = true;
		self:OnButtonStateChanged();
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnLeave()
	if self:IsEnabled() then
		self.over = nil;
		self:OnButtonStateChanged();
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseDown()
	if self:IsEnabled() then
		self.down = true;

		if self.displacedRegions then
			local x, y = self.displaceX, self.displaceY;
			for index, region in ipairs(self.displacedRegions) do
				region:AdjustPointsOffset(x, y);
			end
		end

		self:OnButtonStateChanged();
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseUp()
	if self:IsEnabled() then
		self.down = nil;

		if self.displacedRegions then
			local x, y = self.displaceX, self.displaceY;
			for index, region in ipairs(self.displacedRegions) do
				region:AdjustPointsOffset(-x, -y);
			end
		end

		self:OnButtonStateChanged();

		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnEnable()
	self:OnButtonStateChanged();

	if self.desaturateIfDisabled then
		self:DesaturateHierarchy(0);
	end
end

function ButtonStateBehaviorMixin:OnDisable()
	self.over = nil;
	self.down = nil;

	if self.displacedRegions then
		local x, y = self.displaceX, self.displaceY;
		for index, region in ipairs(self.displacedRegions) do
			region:ClearPointsOffset();
		end
	end

	if self.desaturateIfDisabled then
		self:DesaturateHierarchy(1);
	end

	self:OnButtonStateChanged();
end