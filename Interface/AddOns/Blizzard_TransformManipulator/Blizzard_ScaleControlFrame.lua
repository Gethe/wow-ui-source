ScaleControlFrameMixin = {};

function ScaleControlFrameMixin:OnLoad()
	MinimalSliderMixin.OnLoad(self);
	FrameUtil.RegisterForTopLevelParentChanged(self);
	FrameUtil.UpdateTopLevelParent(self);
end

function ScaleControlFrameMixin:OnShow()
	FrameUtil.UpdateTopLevelParent(self);
	self:FormatValue(self:GetValue());
end

function ScaleControlFrameMixin:OnValueChanged(value)
	self:FormatValue(value);
end

function ScaleControlFrameMixin:FormatValue(value)
	local roundToNearestInteger = true;
	local valueStr = FormatPercentage(value / 1, roundToNearestInteger);
	self.Text:SetText(valueStr);
end

function ScaleControlFrameMixin:OnMouseDown()
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYDOWN);
			
end

function ScaleControlFrameMixin:OnMouseUp()
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYUP);
end
