
ScrollDirectionMixin = {};

function ScrollDirectionMixin:SetHorizontal(isHorizontal)
	self.isHorizontal = isHorizontal;
end

function ScrollDirectionMixin:IsHorizontal()
	return self.isHorizontal;
end

function ScrollDirectionMixin:GetFrameExtent(frame)
	local width, height = frame:GetSize();
	return self.isHorizontal and width or height;
end

function ScrollDirectionMixin:SetFrameExtent(frame, value)
	if self.isHorizontal then
		frame:SetWidth(value);
	else
		frame:SetHeight(value);
	end
end

function ScrollDirectionMixin:GetUpper(frame)
	return self.isHorizontal and frame:GetLeft() or frame:GetTop();
end

function ScrollDirectionMixin:GetLower(frame)
	return self.isHorizontal and frame:GetRight() or frame:GetBottom();
end

function ScrollDirectionMixin:SelectCursorComponent(parent)
	local x, y = InputUtil.GetCursorPosition(parent);
	return self.isHorizontal and x or y;
end

function ScrollDirectionMixin:SelectPointComponent(frame)
	local index = self.isHorizontal and 4 or 5;
	return select(index, frame:GetPointByName("TOPLEFT"));
end

ScrollControllerMixin = CreateFromMixins(ScrollDirectionMixin);

ScrollControllerMixin.Directions = 
{
	Increase = 1,
	Decrease = -1,
}

function ScrollControllerMixin:OnLoad()
	self.isScrollController = true;
	self.panExtentPercentage = .1;
	self.allowScroll = true;

	if not self.wheelPanScalar then
		self.wheelPanScalar = 2.0;
	end
end

function ScrollControllerMixin:OnMouseWheel(value)
	local panFactor = 1.0;
	if value < 0 then
		self:ScrollIncrease(panFactor);
	else
		self:ScrollDecrease(panFactor);
	end
end

-- Constrains the scroll percentage to intervals, which can be used to prevent elements
-- from being partially clipped when dragging the scrollbar thumb. See most uses of
-- ScrollingMessageFrame for an example.
function ScrollControllerMixin:EnableSnapToInterval()
	self.snapToInterval = true;
end

function ScrollControllerMixin:GetIntervalRange()
	local visibleExtentPercentage = self:GetVisibleExtentPercentage();
	if visibleExtentPercentage > 0 then
		local intervals = math.floor((1 / visibleExtentPercentage) + MathUtil.Epsilon);
		return intervals - 1;
	end
	return 0;
end

function ScrollControllerMixin:ScrollIncrease(panFactor)
	local panPercentage = self:GetWheelPanPercentage() * (panFactor or 1.0);
	self:ScrollInDirection(panPercentage, ScrollControllerMixin.Directions.Increase);
end

function ScrollControllerMixin:ScrollDecrease(panFactor)
	local panPercentage = self:GetWheelPanPercentage() * (panFactor or 1.0);
	self:ScrollInDirection(panPercentage, ScrollControllerMixin.Directions.Decrease);
end

function ScrollControllerMixin:ScrollInDirection(scrollPercentage, direction)
	if not self:IsScrollAllowed() then
		return;
	end

	if self.snapToInterval then
		local range = self:GetIntervalRange();
		if range > 0 then
			scrollPercentage = math.max(1 / range, scrollPercentage);
		end
	end

	local delta = scrollPercentage * direction;
	self:SetScrollPercentage(Saturate(self:GetScrollPercentage() + delta));
end

function ScrollControllerMixin:GetPanExtentPercentage()
	return self.panExtentPercentage;
end

function ScrollControllerMixin:SetPanExtentPercentage(panExtentPercentage)
	self.panExtentPercentage = Saturate(panExtentPercentage);
end

function ScrollControllerMixin:GetWheelPanPercentage()
	return Saturate(self:GetPanExtentPercentage() * self.wheelPanScalar);
end

function ScrollControllerMixin:GetScrollPercentage()
	return self.scrollPercentage or 0;
end

function ScrollControllerMixin:IsAtBegin()
	return ApproximatelyEqual(self:GetScrollPercentage(), 0);
end

function ScrollControllerMixin:IsAtEnd()
	return ApproximatelyEqual(self:GetScrollPercentage(), 1);
end

function ScrollControllerMixin:SetScrollPercentage(scrollPercentage)
	if self.snapToInterval then
		local range = self:GetIntervalRange();
		if range > 0 then
			local percentage = 1 / range;
			scrollPercentage = Round(scrollPercentage / percentage) / range;
		end
	end

	self.scrollPercentage = Saturate(scrollPercentage);
end

function ScrollControllerMixin:CanInterpolateScroll()
	return self.canInterpolateScroll;
end

function ScrollControllerMixin:SetInterpolateScroll(canInterpolateScroll)
	self.canInterpolateScroll = canInterpolateScroll;
end

function ScrollControllerMixin:GetScrollInterpolator()
	if not self.interpolator then
		self.interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
	end
	return self.interpolator;
end

function ScrollControllerMixin:Interpolate(scrollPercentage, setter)
	local time = .11;
	local interpolator = self:GetScrollInterpolator();
	interpolator:Interpolate(self:GetScrollPercentage(), scrollPercentage, time, setter);
end

function ScrollControllerMixin:IsScrollAllowed()
	return self.allowScroll;
end

function ScrollControllerMixin:SetScrollAllowed(allowScroll)
	self.allowScroll = allowScroll;
end

function IsScrollController(object)
	return object.isScrollController;
end
