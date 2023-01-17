ButtonStateBehaviorMixin = {};

function ButtonStateBehaviorMixin:OnEnter()
	if self:IsEnabled() then
		self.over = true;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnLeave()
	if self:IsEnabled() then
		self.over = nil;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseDown()
	if self:IsEnabled() then
		self.down = true;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseUp()
	if self:IsEnabled() then
		self.down = nil;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnDisable()
	self.over = nil;
	self.down = nil;
end