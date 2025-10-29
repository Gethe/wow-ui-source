local ScaleControlDirection = {
	None = 0,
	Negative = 1,
	Positive = 2
};

ScaleControlFrameMixin = {};

function ScaleControlFrameMixin:OnLoad()
	FrameUtil.RegisterForTopLevelParentChanged(self);
	FrameUtil.UpdateTopLevelParent(self);

	self.Fill:SetHeight(self:GetHeight());

	self.ThumbActive:ClearAllPoints();
	self.ThumbActive:SetPoint("TOPLEFT", self.Thumb, "TOPLEFT");
	self.ThumbActive:SetPoint("BOTTOMRIGHT", self.Thumb, "BOTTOMRIGHT");

	local doOnEnter = GenerateClosure(self.OnEnter, self);
	local doOnLeave = GenerateClosure(self.OnLeave, self);
	self.AmountFrame.LeftButton:SetHoverCallbacks(doOnEnter, doOnLeave);
	self.AmountFrame.RightButton:SetHoverCallbacks(doOnEnter, doOnLeave);
end

function ScaleControlFrameMixin:OnShow()
	FrameUtil.UpdateTopLevelParent(self);
	self.lastDirectionUpdate = nil;
	self:FormatValue(self:GetValue());
	self:UpdateActiveState();
	self:UpdateDefaultAnchor();
	self:UpdateFill();
end

function ScaleControlFrameMixin:OnEnter()
	self:UpdateActiveState();
end

function ScaleControlFrameMixin:OnLeave()
	self:UpdateActiveState();
end

function ScaleControlFrameMixin:OnValueChanged(value)
	self:FormatValue(value);
	self:UpdateFill();
end

function ScaleControlFrameMixin:OnMinMaxChanged()
	self:UpdateDefaultAnchor();
	self:UpdateFill();
end

function ScaleControlFrameMixin:FormatValue(value)
	local roundToNearestInteger = true;
	local valueStr = FormatPercentage(value / 1, roundToNearestInteger);
	self.AmountFrame.Text:SetText(valueStr);
end

function ScaleControlFrameMixin:OnMouseDown()
	self:UpdateActiveState();
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYDOWN);
end

function ScaleControlFrameMixin:OnMouseUp()
	self:UpdateActiveState();
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYUP);
end

function ScaleControlFrameMixin:UpdateActiveState()
	local isHovered = self:IsMouseMotionFocus() or self.AmountFrame.LeftButton:IsOver() or self.AmountFrame.RightButton:IsOver();
	local isPressed = self:IsDraggingThumb() or self.AmountFrame.LeftButton:IsDown() or self.AmountFrame.RightButton:IsDown();
	if isPressed then
		self.AmountFrame:SetAlpha(1);
		self.ThumbActive:Show();
		self.ThumbActive:SetAlpha(1);
	elseif isHovered then
		self.AmountFrame:SetAlpha(1);
		self.ThumbActive:Show();
		self.ThumbActive:SetAlpha(0.5);
	else
		self.AmountFrame:SetAlpha(0.5);
		self.ThumbActive:Hide();
	end
end

function ScaleControlFrameMixin:UpdateDefaultAnchor()
	-- Since min scale and max scale are individually configurabel by design
	-- the actual position of the "default" scale value (100%) may not be in the middle of the slider
	-- (At the time of writing the default range is 20% to 200% so it already isn't a symmetrical range)
	-- Since we want the "fill bar" to stretch from the default value to wherever it's currently been dragged to,
	-- we have to calculate where on the width of the slider that default currently lies
	local min, max = self:GetMinMaxValues();
	local range = max - min;

	local offsetFromMin = 0;
	if range ~= 0 then
		local defaultValue = 1; -- 1 == 100% == default scale
		offsetFromMin = (defaultValue - min) / range;
	end

	local width = self:GetWidth();
	self.defaultAnchorOffset = width * offsetFromMin;
end

function ScaleControlFrameMixin:UpdateFill()
	if not self:IsShown() then
		return;
	end

	local currentValue = self:GetValue();
	local currentDirection = ScaleControlDirection.None;
	
	if currentValue > 1 then
		currentDirection = ScaleControlDirection.Positive
	elseif currentValue < 1 then
		currentDirection = ScaleControlDirection.Negative
	end

	if self.lastDirectionUpdate == currentDirection then
		return;
	end

	-- We want the "fill bar" to stretch from the default value to wherever it's currently been dragged to
	-- That means if we're above 100% (positive), we want the left edge of the fill anchored to the default/100% mark, & right side anchored to the thumb
	-- For below 100% (negative) - right edge at the default mark, left side anchored to the thumb
	-- If we're at exactly 100% then obviously no fill needed
	if currentDirection == ScaleControlDirection.None then
		self.FillMask:ClearAllPoints();
		self.Fill:Hide();
	elseif currentDirection == ScaleControlDirection.Positive then
		self.FillMask:ClearAllPoints();
		self.FillMask:SetPoint("RIGHT", self.Thumb, "CENTER");
		self.FillMask:SetPoint("LEFT", self.defaultAnchorOffset, 0);
		self.Fill:Show();
	elseif currentDirection == ScaleControlDirection.Negative then
		self.FillMask:ClearAllPoints();
		self.FillMask:SetPoint("LEFT", self.Thumb, "CENTER");
		self.FillMask:SetPoint("RIGHT", self, "LEFT", self.defaultAnchorOffset, 0);
		self.Fill:Show();
	end

	self.lastDirectionUpdate = currentDirection;
end


ScaleControlArrowButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function ScaleControlArrowButtonMixin:OnLoad()
	self.Icon:SetAtlas(self.atlas);
	self.HoverIcon:SetAtlas(self.atlas);
	self.PushedIcon:SetAtlas(self.atlas);

	ButtonStateBehaviorMixin.OnLoad(self);
end

function ScaleControlArrowButtonMixin:OnButtonStateChanged()
	self.HoverIcon:SetShown(self.over and not self.down);
	self.PushedIcon:SetShown(self.down);
end

function ScaleControlArrowButtonMixin:SetHoverCallbacks(onEnterCallback, onLeaveCallback)
	self.onEnterCallback = onEnterCallback;
	self.onLeaveCallback = onLeaveCallback;
end

function ScaleControlArrowButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
	if self.onEnterCallback then
		self.onEnterCallback();
	end
end

function ScaleControlArrowButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
	if self.onLeaveCallback then
		self.onLeaveCallback();
	end
end

function ScaleControlArrowButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYDOWN);
	C_HousingExpertMode.SetPrecisionIncrementingActive(self.incrementType, true);
end

function ScaleControlArrowButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYUP);
	C_HousingExpertMode.SetPrecisionIncrementingActive(self.incrementType, false);
end

