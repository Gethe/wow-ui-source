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

function ScrollDirectionMixin:SelectCursorComponent()
	local x, y = GetScaledCursorPosition();
	return self.isHorizontal and x or y;
end

function ScrollDirectionMixin:SelectPointComponent(frame)
	local index = self.isHorizontal and 4 or 5;
	return select(index, frame:GetPoint("TOPLEFT"));
end

ScrollControllerMixin = CreateFromMixins(ScrollDirectionMixin);

ScrollControllerMixin.Directions = 
{
	Increase = 1,
	Decrease = -1,
}

function ScrollControllerMixin:OnLoad()
	self.panExtentPercentage = .1;
	self.allowScroll = true;

	if not self.wheelPanScalar then
		self.wheelPanScalar = 2.0;
	end
end

function ScrollControllerMixin:OnMouseWheel(value)
	if value < 0 then
		self:ScrollInDirection(self:GetWheelPanPercentage(), ScrollControllerMixin.Directions.Increase);
	else
		self:ScrollInDirection(self:GetWheelPanPercentage(), ScrollControllerMixin.Directions.Decrease);
	end
end

function ScrollControllerMixin:ScrollInDirection(scrollPercentage, direction)
	if self:IsScrollAllowed() then
		local delta = scrollPercentage * direction;
		self:SetScrollPercentage(Saturate(self:GetScrollPercentage() + delta));
	end
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

function ScrollControllerMixin:SetScrollPercentage(scrollPercentage)
	self.scrollPercentage = Saturate(scrollPercentage);
end

function ScrollControllerMixin:CanInterpolateScroll()
	return self.canInterpolateScroll or false;
end

function ScrollControllerMixin:SetInterpolateScroll(canInterpolateScroll)
	self.canInterpolateScroll = canInterpolateScroll;
end

function ScrollControllerMixin:GetScrollInterpolator()
	if not self.interpolator then
		self.interpolator = CreateFromMixins(InterpolatorMixin);
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