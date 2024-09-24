
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
	
	-- Shared by steppers, track, and thumb.
	self.onButtonMouseUp = function(button, buttonName, upInside)
		if buttonName == "LeftButton" then
			self:UnregisterUpdate();
		end
	end
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

function ScrollBarMixin:ScrollToBegin(forceImmediate)
	self:SetScrollPercentage(0, forceImmediate);
end

function ScrollBarMixin:ScrollToEnd(forceImmediate)
	self:SetScrollPercentage(1, forceImmediate);
end

function ScrollBarMixin:EnableInternalPriority()
	self.internalPriority = true;
end

function ScrollBarMixin:EnableSnapToInterval(snapToInterval)
	self.snapToInterval = true;
end

function ScrollBarMixin:SetScrollPercentage(scrollPercentage, forceImmediate)
	-- While steppers, track, or thumb is held, attempts to change the scroll percentage
	-- externally are discarded. This is to prevent scroll bars from jittering when receiving
	-- scroll position adjustments from scrolling message frames (SMF) where the scroll bar's position
	-- can't match the SMF offset position exactly. This is only enabled for SMF. See
	-- ScrollUtil.InitScrollingMessageFrameWithScrollBar
	if self.internalPriority and self.requireInternalScope and not self.internalScope then
		return;
	end

	if not forceImmediate and self:CanInterpolateScroll() then
		self:Interpolate(scrollPercentage, self.scrollInternal);
	else
		self:SetScrollPercentageInternal(scrollPercentage);
	end
end

function ScrollBarMixin:SetScrollPercentageInternal(scrollPercentage)
	-- Constrains the scroll percentage to intervals. This is useful for SMF where message
	-- lines are never partially visible and it is undesirable to have the thumb position change
	-- without actually causing any messages to scroll.
	if self.snapToInterval then
		local visibleExtentPercentage = self:GetVisibleExtentPercentage();
		if visibleExtentPercentage > 0 then
			local intervals = math.floor((1 / visibleExtentPercentage) + MathUtil.Epsilon);
			local r = intervals - 1;
			scrollPercentage = math.min(math.floor(scrollPercentage / visibleExtentPercentage), r) / math.max(r, 1);
		end
	end
	
	ScrollControllerMixin.SetScrollPercentage(self, scrollPercentage);
	
	self:Update();

	self:TriggerEvent(ScrollBarMixin.Event.OnScroll, self:GetScrollPercentage());
end

function ScrollBarMixin:HasScrollableExtent()
	return WithinRangeExclusive(self:GetVisibleExtentPercentage(), MathUtil.Epsilon, 1 - MathUtil.Epsilon);
end

function ScrollBarMixin:SetScrollAllowed(allowScroll)
	local oldAllowScroll = self:IsScrollAllowed();
	if oldAllowScroll ~= allowScroll then
		ScrollControllerMixin.SetScrollAllowed(self, allowScroll);

		self:Update();

		self:TriggerEvent(ScrollBarMixin.Event.OnAllowScrollChanged, allowScroll);
	end
end

function ScrollBarMixin:SetThumbExtent(thumbExtent)
	thumbExtent = math.max(self.minThumbExtent, thumbExtent);

	local trackExtent = self:GetTrackExtent();
	local clamped = thumbExtent > trackExtent;
	if clamped then
		thumbExtent = trackExtent;
	end
	self:SetFrameExtent(self:GetThumb(), thumbExtent);

	return thumbExtent, clamped;
end

function ScrollBarMixin:SetHideIfUnscrollable(hide)
	self.hideIfUnscrollable = hide;
	self:Update();
end

function ScrollBarMixin:SetHideTrackIfThumbExceedsTrack(hide)
	self.hideTrackIfThumbExceedsTrack = hide;
	self:Update();
end

function ScrollBarMixin:Update()
	local visibleExtentPercentage = self:GetVisibleExtentPercentage();
	local trackExtent = self:GetTrackExtent();

	local thumb = self:GetThumb();
	local thumbExtent;
	local clampedThumb = false;
	if self.fixedThumbExtent then
		thumbExtent, clampedThumb = self:SetThumbExtent(self.fixedThumbExtent);
	elseif self.useProportionalThumb then
		local proportionalThumbExtent = trackExtent * visibleExtentPercentage;
		thumbExtent, clampedThumb = self:SetThumbExtent(proportionalThumbExtent);
	else
		-- No enforcement of thumb extent <= track extent for unspecified thumb
		-- behavior because the original size would be unrecoverable without additional support.
		thumbExtent = self:GetFrameExtent(thumb);
	end

	-- Consider interpolation so the enabled or disabled state is not delayed as it approaches
	-- 0 or 1.
	local scrollPercentage = self:GetScrollPercentage();
	local targetScrollPercentage = scrollPercentage;
	local interpolateTo = self:GetScrollInterpolator():GetInterpolateTo();
	if interpolateTo then
		targetScrollPercentage = interpolateTo;
	end

	-- Small exponential representations of zero (ex. E-15) don't evaluate as > 0, 
	-- and 1.0 can be represented by .99999XXXXXX.
	local hasScrollableExtent = self:HasScrollableExtent();
	local scrollEnabled = hasScrollableExtent and self:IsScrollAllowed();
	self:GetBackStepper():SetEnabled(scrollEnabled and targetScrollPercentage > MathUtil.Epsilon);
	self:GetForwardStepper():SetEnabled(scrollEnabled and targetScrollPercentage < (1 - MathUtil.Epsilon));

	local offset = (trackExtent - thumbExtent) * scrollPercentage;
	local x, y = 0, -offset;
	if self.isHorizontal then
		x, y = -y, x;
	end

	thumb:SetPoint(self:GetThumbAnchor(), self:GetTrack(), self:GetThumbAnchor(), x, y);
	
	-- hideTrack and hideTrackIfThumbExceedsTrack are not expected to be enabled unless
	-- the thumb's cannot appear correctly when it's extent is clamped to the track's extent.
	local showThumb = hasScrollableExtent and not clampedThumb;
	thumb:SetShown(showThumb);
	thumb:SetEnabled(scrollEnabled);

	local showTrack = not self.hideTrack and not (clampedThumb and self.hideTrackIfThumbExceedsTrack);
	self:GetTrack():SetShown(showTrack);

	-- Automatically toggling visibility here only occurs if .hideIfUnscrollable was enabled, 
	-- otherwise we expect any explicit Show or Hide calls from owning code to be respected.
	if self.hideIfUnscrollable then
		self:SetShown(hasScrollableExtent);
	end
end

function ScrollBarMixin:DisableControls()
	self:GetBackStepper():SetEnabled(false);
	self:GetForwardStepper():SetEnabled(false);
	self:GetThumb():Hide();
	self:GetThumb():SetEnabled(false);
end

function ScrollBarMixin:CanCursorStepInDirection(direction)
	local c = self:SelectCursorComponent(self);
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
end

function ScrollBarMixin:IsThumbMouseDown()
	return self:GetThumb():GetButtonState() == "PUSHED";
end

function ScrollBarMixin:UnregisterUpdate()
	self:SetScript("OnUpdate", nil);
	self.requireInternalScope = nil;
end

function ScrollBarMixin:CallInternalScope(func, ...)
	self.internalScope = true;
	func(...);
	self.internalScope = false;
end

function ScrollBarMixin:OnStepperMouseDown(stepper)
	local direction = stepper.direction;
	self:ScrollStepInDirection(direction);

	self.requireInternalScope = true;

	local function ScrollStepInDirection()
		self:ScrollStepInDirection(direction);
	end

	local elapsed = 0;
	local repeatTime = self:GetPanRepeatTime();
	local delay = self:GetPanRepeatDelay();
	self:SetScript("OnUpdate", function(tbl, dt)
		if not stepper.leave then
			elapsed = elapsed + dt;
			if elapsed > delay then
				elapsed = 0;
				delay = repeatTime;

				self:CallInternalScope(ScrollStepInDirection);
			end
		end
	end);

	stepper:RegisterCallback("OnEnter", function()
		stepper.leave = nil;
	end, self);

	stepper:RegisterCallback("OnLeave", function()
		stepper.leave = true;
	end, self);

	stepper:RegisterCallback("OnMouseUp", self.onButtonMouseUp, self);
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
	
		self.requireInternalScope = true;

		local function ScrollPageInDirection()
			self:ScrollPageInDirection(direction);
		end

		local elapsed = 0;
		local repeatTime = self:GetPanRepeatTime();
		local delay = self:GetPanRepeatDelay();
		local stepCount = 0;
		self:SetScript("OnUpdate", function(tbl, dt)
			elapsed = elapsed + dt;
			if elapsed > delay then
				elapsed = 0;

				if self:CanCursorStepInDirection(direction) then
					self:CallInternalScope(ScrollPageInDirection);
				end

				if stepCount < 1 then
					stepCount = stepCount + 1;
					delay = repeatTime;
				end
			end
		end);

		self:GetTrack():SetScript("OnMouseUp", self.onButtonMouseUp);
	end
end

function ScrollBarMixin:OnThumbMouseDown(button, buttonName)
	if buttonName ~= "LeftButton" then
		return;
	end

	self.requireInternalScope = true;
	
	local c = self:SelectCursorComponent(self);
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

	local function SetScrollPercentage(scrollPercentage)
		self:SetScrollPercentage(scrollPercentage);
	end

	self:SetScript("OnUpdate", function()
		local c = Clamp(self:SelectCursorComponent(self), min, max);
		local scrollPercentage;
		if self.isHorizontal then
			scrollPercentage = PercentageBetween(c, min, max);
		else
			scrollPercentage = 1.0 - PercentageBetween(c, min, max);
		end

		self:CallInternalScope(SetScrollPercentage, scrollPercentage);
	end);

	self:GetThumb():RegisterCallback("OnMouseUp", self.onButtonMouseUp, self);
end