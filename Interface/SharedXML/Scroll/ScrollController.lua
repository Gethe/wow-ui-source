---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("GetScaledCursorPosition");
	Import("Saturate");
	Import("CreateInterpolator");
	Import("ApproximatelyEqual");
end
----------------

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

function ScrollControllerMixin:IsAtBegin()
	return ApproximatelyEqual(self:GetScrollPercentage(), 0);
end

function ScrollControllerMixin:IsAtEnd()
	return ApproximatelyEqual(self:GetScrollPercentage(), 1);
end

function ScrollControllerMixin:SetScrollPercentage(scrollPercentage)
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