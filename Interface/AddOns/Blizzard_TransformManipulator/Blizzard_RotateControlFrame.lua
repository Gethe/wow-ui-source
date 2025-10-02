RotateControlFrameMixin = {};

function RotateControlFrameMixin:OnLoad()
	MinimalSliderMixin.OnLoad(self);
	EventRegistry:RegisterCallback("UI.AlternateTopLevelParentChanged", self.UpdateParent, self);
	self:UpdateParent();
end

function RotateControlFrameMixin:UpdateParent()
	local oldParent = self:GetParent();
	local newParent = GetAppropriateTopLevelParent();
	if newParent and newParent ~= oldParent then
		FrameUtil.SetParentMaintainRenderLayering(self, newParent);
	end
end

function RotateControlFrameMixin:OnShow()
	self:UpdateParent();
end