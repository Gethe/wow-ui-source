ScaleControlFrameMixin = {};

function ScaleControlFrameMixin:OnLoad()
	MinimalSliderMixin.OnLoad(self);
	EventRegistry:RegisterCallback("UI.AlternateTopLevelParentChanged", self.UpdateParent, self);
	self:UpdateParent();
end

function ScaleControlFrameMixin:OnShow()
	self:UpdateParent();
	self:FormatValue(self:GetValue());
end

function ScaleControlFrameMixin:OnValueChanged(value)
	self:FormatValue(value);
end

function ScaleControlFrameMixin:UpdateParent()
	local oldParent = self:GetParent();
	local newParent = GetAppropriateTopLevelParent();
	if newParent and newParent ~= oldParent then
		FrameUtil.SetParentMaintainRenderLayering(self, newParent);
	end
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
