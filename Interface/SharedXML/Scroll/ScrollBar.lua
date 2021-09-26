ScrollBarMixin = CreateFromMixins(CallbackRegistryMixin, ScrollControllerMixin, EventFrameMixin);
ScrollBarMixin:GenerateCallbackEvents(
	{
		"OnScroll",
		"OnAllowScrollChanged",
	}
);

function ScrollBarMixin:OnLoad()
	ScrollControllerMixin.OnLoad(self);

	self.visibleExtentPercentage = 0;

	-- Levels are assigned here because it's the closest we can get to a relative
	-- frame level. The order of these components is an internal detail to this
	-- object, and we want to avoid defining an absolute frame level in the XML
	-- resulting in confusion as frames unintentionally appear out of the expected order.
	local level = self:GetFrameLevel();
	self:GetTrack():SetFrameLevel(level + 2);
	self:GetTrack():SetScript("OnMouseDown", GenerateClosure(self.OnTrackMouseDown, self));

	local buttonLevel = level + 3;
	self:GetBackStepper():SetFrameLevel(buttonLevel);
	self:GetBackStepper():RegisterCallback("OnMouseDown", GenerateClosure(self.OnStepperMouseDown, self, self:GetBackStepper()), self);

	self:GetForwardStepper():SetFrameLevel(buttonLevel);
	self:GetForwardStepper():RegisterCallback("OnMouseDown", GenerateClosure(self.OnStepperMouseDown, self, self:GetForwardStepper()), self);

	self:GetThumb():SetFrameLevel(buttonLevel);
	self:GetThumb():RegisterCallback("OnMouseDown", GenerateClosure(self.OnThumbMouseDown, self), self);

	self.scrollInternal = GenerateClosure(self.SetScrollPercentageInternal, self);

	self:DisableControls();
end

function ScrollBarMixin:Init(visibleExtentPercentage, panExtentPercentage)
	ScrollControllerMixin.SetScrollPercentage(self, 0);
	self:SetPanExtentPercentage(panExtentPercentage);
	self:SetVisibleExtentPercentage(visibleExtentPercentage);
end

function ScrollBarMixin:GetBackStepper()
	return self.Back;
end

function ScrollBarMixin:GetForwardStepper()
	return self.Forward;
end

function ScrollBarMixin:GetTrack()
	return self.Track;
end

function ScrollBarMixin:GetThumb()
	return self:GetTrack().Thumb;
end

function ScrollBarMixin:GetThumbAnchor()
	return self.thumbAnchor;
end

function ScrollBarMixin:GetPanRepeatTime()
	return self.panRepeatTime;
end

function ScrollBarMixin:GetPanRepeatDelay()
	return self.panDelay;
end

function ScrollBarMixin:OnStepperMouseDown(stepper)
	local direction = stepper.direction;
	self:ScrollStepInDirection(direction);

	local elapsed = 0;
	local repeatTime = self:GetPanRepeatTime();
	local delay = self:GetPanRepeatDelay();
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
	return self:GetFrameExtent(self:GetTrack());
end;

function ScrollBarMixin:ScrollInDirection(percentage, direction)
	ScrollControllerMixin.ScrollInDirection(self, percentage, direction);

	self:Update();

	self:TriggerEvent(ScrollBarMixin.Event.OnScroll, self:GetScrollPercentage());
end

function ScrollBarMixin:ScrollWheelInDirection(direction)
	self:ScrollInDirection(self:GetWheelExtent(), direction);
end

function ScrollBarMixin:ScrollStepInDirection(direction)
	self:ScrollInDirection(self:GetPanExtentPercentage(), direction);
end

function ScrollBarMixin:ScrollPageInDirection(direction)
	local visibleExtentPercentage = self:GetVisibleExtentPercentage();
	if visibleExtentPercentage > 0 then
		local pages = 1 / visibleExtentPercentage;
		local magnitude = .95;
		local span = pages - 1;
		if span > 0 then
			self:ScrollInDirection((1 / span) * magnitude, direction);
		end
	end
end

function ScrollBarMixin:SetVisibleExtentPercentage(visibleExtentPercentage)
	self.visibleExtentPercentage = Saturate(visibleExtentPercentage);

	self:Update();
end

function ScrollBarMixin:GetVisibleExtentPercentage()
	return self.visibleExtentPercentage or 0;
end

function ScrollBarMixin:SetScrollPercentage(scrollPercentage, forceImmediate)
	if not forceImmediate and self:CanInterpolateScroll() then
		self:Interpolate(scrollPercentage, self.scrollInternal);
	else
		self:SetScrollPercentageInternal(scrollPercentage);
	end
end

function ScrollBarMixin:SetScrollPercentageInternal(scrollPercentage)
	ScrollControllerMixin.SetScrollPercentage(self, scrollPercentage);
	
	self:Update();

	self:TriggerEvent(ScrollBarMixin.Event.OnScroll, self:GetScrollPercentage());
end

function ScrollBarMixin:HasScrollableExtent()
	return WithinRangeExclusive(self:GetVisibleExtentPercentage(), 0, 1);
end

function ScrollBarMixin:SetScrollAllowed(allowScroll)
	local oldAllowScroll = self:IsScrollAllowed();
	if oldAllowScroll ~= allowScroll then
		ScrollControllerMixin.SetScrollAllowed(self, allowScroll);

		self:Update();

		self:TriggerEvent(ScrollBarMixin.Event.OnAllowScrollChanged, allowScroll);
	end
end

function ScrollBarMixin:Update()
	if self:HasScrollableExtent() then
		local visibleExtentPercentage = self:GetVisibleExtentPercentage();
		local trackExtent = self:GetTrackExtent();
		
		local thumb = self:GetThumb();
		local thumbExtent;
		if self.useProportionalThumb then
			local minimumThumbExtent = self.minThumbExtent;
			thumbExtent = Clamp(trackExtent * visibleExtentPercentage, minimumThumbExtent, trackExtent);
			self:SetFrameExtent(thumb, thumbExtent);
		else
			thumbExtent = self:GetFrameExtent(thumb);
		end

		local allowScroll = self:IsScrollAllowed();
		local scrollPercentage = self:GetScrollPercentage();

		-- Consider interpolation so the enabled or disabled state is not delayed as it approaches
		-- 0 or 1.
		local targetScrollPercentage = scrollPercentage;
		local interpolateTo = self:GetScrollInterpolator():GetInterpolateTo();
		if interpolateTo then
			targetScrollPercentage = interpolateTo;
		end

		-- Small exponential representations of zero (ex. E-15) don't evaluate as > 0, 
		-- and 1.0 can be represented by .99999XXXXXX.
		self:GetBackStepper():SetEnabled(allowScroll and targetScrollPercentage > MathUtil.Epsilon);
		self:GetForwardStepper():SetEnabled(allowScroll and targetScrollPercentage < 1);

		local offset = (trackExtent - thumbExtent) * scrollPercentage;
		local x, y = 0, -offset;
		if self.isHorizontal then
			x, y = -y, x;
		end

		thumb:SetPoint(self:GetThumbAnchor(), self:GetTrack(), self:GetThumbAnchor(), x, y);
		thumb:Show();
		thumb:SetEnabled(allowScroll);
	else
		self:DisableControls();
	end
end

function ScrollBarMixin:DisableControls()
	self:GetBackStepper():SetEnabled(false);
	self:GetForwardStepper():SetEnabled(false);
	self:GetThumb():Hide();
	self:GetThumb():SetEnabled(false);
end

function ScrollBarMixin:CanCursorStepInDirection(direction)
	local c = self:SelectCursorComponent();
	if direction ==  ScrollControllerMixin.Directions.Decrease then
		if self.isHorizontal then
			return c < self:GetUpper(self:GetThumb());
		else
			return c > self:GetUpper(self:GetThumb());
		end
	else
		if self.isHorizontal then
			return c > self:GetLower(self:GetThumb());
		else
			return c < self:GetLower(self:GetThumb());
		end
	end
	return false;
end

function ScrollBarMixin:OnTrackMouseDown(button, buttonName)
	if buttonName ~= "LeftButton" then
		return;
	end

	if not self:HasScrollableExtent() or not self:IsScrollAllowed() then
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
		local repeatTime = self:GetPanRepeatTime();
		local delay = self:GetPanRepeatDelay();
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

		self:GetTrack():SetScript("OnMouseUp", GenerateClosure(self.UnregisterUpdate, self));
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
	
	local c = self:SelectCursorComponent();
	local scrollPercentage = self:GetScrollPercentage();
	local extentRemaining = self:GetTrackExtent() - self:GetFrameExtent(self:GetThumb());
	
	local min, max;
	if self.isHorizontal then
		min = c - scrollPercentage * extentRemaining;
		max = c + (1.0 - scrollPercentage) * extentRemaining;
	else
		min = c - (1.0 - scrollPercentage) * extentRemaining;
		max = c + scrollPercentage * extentRemaining;
	end

	self:SetScript("OnUpdate", function()
		local c = Clamp(self:SelectCursorComponent(), min, max);
		local scrollPercentage;
		if self.isHorizontal then
			scrollPercentage = PercentageBetween(c, min, max);
		else
			scrollPercentage = 1.0 - PercentageBetween(c, min, max);
		end
		self:SetScrollPercentage(scrollPercentage);
	end);

	self:GetThumb():RegisterCallback("OnMouseUp", GenerateClosure(self.UnregisterUpdate, self), self);
end