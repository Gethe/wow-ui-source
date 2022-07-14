ScrollBarButtonMixin = CreateFromMixins(CallbackRegistryMixin);

ScrollBarButtonMixin:GenerateCallbackEvents(
	{
		"OnMouseUp",
		"OnMouseDown",
		"OnEnter",
		"OnLeave",
	}
);

function ScrollBarButtonMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function ScrollBarButtonMixin:OnMouseDown_Intrinsic(buttonName)
	self:TriggerEvent("OnMouseDown", buttonName);
end

function ScrollBarButtonMixin:OnMouseUp_Intrinsic(buttonName)
	self:TriggerEvent("OnMouseUp", buttonName);
end

function ScrollBarButtonMixin:OnEnter_Intrinsic()
	self:TriggerEvent("OnEnter");
end

function ScrollBarButtonMixin:OnLeave_Intrinsic()
	self:TriggerEvent("OnLeave");
end

ScrollBarMixin = CreateFromMixins(CallbackRegistryMixin, ControlExtentAccessorMixin, ScrollControllerMixin);

ScrollBarMixin:GenerateCallbackEvents(
	{
		"OnScroll",
	}
);

function ScrollBarMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	ScrollControllerMixin.OnLoad(self);

	if not self.stepRepeatTime then
		self.stepRepeatTime = .1;
	end

	if not self.stepDelay then
		self.stepDelay = .5;
	end

	self.extentVisibleRatio = 0;

	self.Track:SetPoint(self:GetUpperAnchor(), self.Decrease, self:GetLowerAnchor());
	self.Track:SetPoint(self:GetLowerAnchor(), self.Increase, self:GetUpperAnchor());
	self.Track:SetScript("OnMouseDown", GenerateClosure(self.OnTrackMouseDown, self));

	self.Decrease:SetPoint(self:GetUpperAnchor());
	self.Decrease:RegisterCallback("OnMouseDown", GenerateClosure(self.OnStepperMouseDown, self, self.Decrease), self);

	self.Increase:SetPoint(self:GetLowerAnchor());
	self.Increase:RegisterCallback("OnMouseDown", GenerateClosure(self.OnStepperMouseDown, self, self.Increase), self);

	self.Thumb:RegisterCallback("OnMouseDown", GenerateClosure(self.OnThumbMouseDown, self), self);
end

function ScrollBarMixin:Init(scrollValue, extentVisibleRatio, stepExtent)
	ScrollControllerMixin.SetScrollValue(self, scrollValue);
	self:SetStepExtent(stepExtent);
	self:SetExtentVisibleRatio(extentVisibleRatio);
end

function ScrollBarMixin:GetCursorComponent()
	local x, y = GetScaledCursorPosition();
	return self.isHorizontal and x or y;
end

function ScrollBarMixin:GetStepRepeatTime()
	return self.stepRepeatTime;
end

function ScrollBarMixin:GetStepRepeatDelay()
	return self.stepDelay;
end

function ScrollBarMixin:OnMouseWheel(direction)
	if direction < 0 then
		self:ScrollWheelInDirection(ScrollControllerMixin.Directions.Increase);
	else
		self:ScrollWheelInDirection(ScrollControllerMixin.Directions.Decrease);
	end
end

function ScrollBarMixin:OnStepperMouseDown(stepper)
	local direction = stepper.direction;
	self:ScrollStepInDirection(direction);

	local elapsed = 0;
	local repeatTime = self:GetStepRepeatTime();
	local delay = self:GetStepRepeatDelay();
	self:SetScript("OnUpdate", function(tbl, dt)
		if not stepper.leave then
			elapsed = elapsed + dt;
			if elapsed > delay then
				elapsed = 0;
				delay = repeatTime;
				self:ScrollStepInDirection(direction);
			end
		end
	end);

	stepper:RegisterCallback("OnEnter", function()
		stepper.leave = nil;
	end, self);

	stepper:RegisterCallback("OnLeave", function()
		stepper.leave = true;
	end, self);

	stepper:RegisterCallback("OnMouseUp", GenerateClosure(self.UnregisterUpdate, self), self);
end

function ScrollBarMixin:GetTrackExtent()
	return self:GetControlExtent(self) - (self:GetControlExtent(self.Increase) + self:GetControlExtent(self.Decrease));
end;

function ScrollBarMixin:ScrollInDirection(ratio, direction)
	ScrollControllerMixin.ScrollInDirection(self, ratio, direction);

	self:UpdateVisuals();

	self:TriggerEvent("OnScroll", self:GetScrollValue());
end

function ScrollBarMixin:ScrollWheelInDirection(direction)
	self:ScrollInDirection(self:GetWheelExtent(), direction);
end

function ScrollBarMixin:ScrollStepInDirection(direction)
	self:ScrollInDirection(self:GetStepExtent(), direction);
end

function ScrollBarMixin:ScrollPageInDirection(direction)
	local extentVisibleRatio = self:GetExtentVisibleRatio();
	if extentVisibleRatio > 0 then
		local pages = 1 / extentVisibleRatio;
		local magnitude = .95;
		local span = pages - 1;
		if span > 0 then
			self:ScrollInDirection((1 / span) * magnitude, direction);
		end
	end
end

function ScrollBarMixin:SetExtentVisibleRatio(extentVisibleRatio)
	self.extentVisibleRatio = Clamp(extentVisibleRatio, 0, 1);
	self:UpdateVisuals();
end

function ScrollBarMixin:GetExtentVisibleRatio()
	return self.extentVisibleRatio;
end

function ScrollBarMixin:SetScrollValue(scrollValue)
	ScrollControllerMixin.SetScrollValue(self, scrollValue);
	self:UpdateVisuals();
end

function ScrollBarMixin:SetStepperEnabled(stepper, enabled)
	stepper:DesaturateHierarchy(enabled and 0 or 1);
	stepper:SetEnabled(enabled);
end

function ScrollBarMixin:CanScroll()
	local extentVisibleRatio = self:GetExtentVisibleRatio();
	return extentVisibleRatio > 0 and extentVisibleRatio < 1;
end

function ScrollBarMixin:UpdateVisuals()
	if self:CanScroll() then
		local extentVisibleRatio = self:GetExtentVisibleRatio();
		local trackExtent = self:GetTrackExtent();
		local thumbExtent = trackExtent * extentVisibleRatio;
		self:SetControlExtent(self.Thumb, Clamp(thumbExtent, 5, trackExtent));

		local scrollValue = self:GetScrollValue();
		self:SetStepperEnabled(self.Decrease, scrollValue > 0);
		self:SetStepperEnabled(self.Increase, scrollValue < 1);

		local offset = (trackExtent - thumbExtent) * self:GetScrollValue();
		local x, y = 0, -offset;
		if self.isHorizontal then
			x, y = -y, x;
		end
		self.Thumb:SetPoint(self:GetUpperAnchor(), self.Decrease, self:GetLowerAnchor(), x, y);
		self.Thumb:Show();
	else
		self:SetStepperEnabled(self.Decrease, false);
		self:SetStepperEnabled(self.Increase, false);
		self.Thumb:Hide();
	end
end

function ScrollBarMixin:CanCursorStepInDirection(direction)
	local c = self:GetCursorComponent();
	if direction ==  ScrollControllerMixin.Directions.Decrease then
		if self.isHorizontal then
			return c < self:GetUpper(self.Thumb);
		else
			return c > self:GetUpper(self.Thumb);
		end
	else
		if self.isHorizontal then
			return c > self:GetLower(self.Thumb);
		else
			return c < self:GetLower(self.Thumb);
		end
	end
	return false;
end

function ScrollBarMixin:OnTrackMouseDown(button, buttonName)
	if buttonName ~= "LeftButton" then
		return;
	end

	if not self:CanScroll() then
		return;
	end

	local direction;
	if self:CanCursorStepInDirection(ScrollControllerMixin.Directions.Decrease) then
		direction = ScrollControllerMixin.Directions.Decrease;
	elseif self:CanCursorStepInDirection(ScrollControllerMixin.Directions.Increase) then
		direction = ScrollControllerMixin.Directions.Increase;
	end

	if direction then
		self:ScrollPageInDirection(direction);

		local elapsed = 0;
		local repeatTime = self:GetStepRepeatTime();
		local delay = self:GetStepRepeatDelay();
		local stepCount = 0;
		self:SetScript("OnUpdate", function(tbl, dt)
			elapsed = elapsed + dt;
			if elapsed > delay then
				elapsed = 0;

				if self:CanCursorStepInDirection(direction) then
					self:ScrollPageInDirection(direction);
				end

				if stepCount < 1 then
					stepCount = stepCount + 1;
					delay = repeatTime;
				end
			end
		end);

		self.Track:SetScript("OnMouseUp", GenerateClosure(self.UnregisterUpdate, self));
	end
end

function ScrollBarMixin:UnregisterUpdate(button, buttonName)
	if buttonName == "LeftButton" then
		self:SetScript("OnUpdate", nil);
	end
end

function ScrollBarMixin:OnThumbMouseDown(button, buttonName)
	if buttonName ~= "LeftButton" then
		return;
	end
	
	local c = self:GetCursorComponent();
	local scrollValue = self:GetScrollValue();
	local extentRemaining = self:GetTrackExtent() - self:GetControlExtent(self.Thumb);
	
	local min, max;
	if self.isHorizontal then
		min = c - scrollValue * extentRemaining;
		max = c + (1.0 - scrollValue) * extentRemaining;
	else
		min = c - (1.0 - scrollValue) * extentRemaining;
		max = c + scrollValue * extentRemaining;
	end

	self:SetScript("OnUpdate", function()
		local c = Clamp(self:GetCursorComponent(), min, max);
		local scrollValue;
		if self.isHorizontal then
			scrollValue = PercentageBetween(c, min, max);
		else
			scrollValue = 1.0 - PercentageBetween(c, min, max);
		end
		self:SetScrollValue(scrollValue);
		self:TriggerEvent("OnScroll", scrollValue);
	end);

	self.Thumb:RegisterCallback("OnMouseUp", GenerateClosure(self.UnregisterUpdate, self), self);
end