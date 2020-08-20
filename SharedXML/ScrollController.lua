ScrollControllerMixin = {};

ScrollControllerMixin.Directions = 
{
	Increase = 1,
	Decrease = -1,
}

function ScrollControllerMixin:OnLoad()
	if not self.stepExtent then
		self.stepExtent = .1;
	end
end

function ScrollControllerMixin:ScrollInDirection(ratio, direction)
	local scrollValue = (ratio * direction) + self:GetScrollValue();
	self:SetScrollValue(Clamp(scrollValue, 0, 1));
end

function ScrollControllerMixin:GetStepExtent()
	return self.stepExtent;
end

function ScrollControllerMixin:SetStepExtent(stepExtent)
	self.stepExtent = stepExtent;
end

function ScrollControllerMixin:GetWheelExtent()
	return Clamp(self:GetStepExtent() * 2, 0, 1);
end

function ScrollControllerMixin:GetScrollValue()
	return self.scrollValue or 0;
end

function ScrollControllerMixin:SetScrollValue(scrollValue)
	self.scrollValue = scrollValue;
end

ControlExtentAccessorMixin = {};

function ControlExtentAccessorMixin:GetControlExtent(control)
	return self.isHorizontal and control:GetWidth() or control:GetHeight();
end

function ControlExtentAccessorMixin:SetControlExtent(control, value)
	if self.isHorizontal then
		control:SetWidth(value);
	else
		control:SetHeight(value);
	end
end

function ControlExtentAccessorMixin:GetUpper(control)
	return self.isHorizontal and control:GetLeft() or control:GetTop();
end

function ControlExtentAccessorMixin:GetLower(control)
	return self.isHorizontal and control:GetRight() or control:GetBottom();
end

function ControlExtentAccessorMixin:GetUpperAnchor()
	return self.isHorizontal and "LEFT" or "TOP";
end

function ControlExtentAccessorMixin:GetLowerAnchor()
	return self.isHorizontal and "RIGHT" or "BOTTOM";
end
