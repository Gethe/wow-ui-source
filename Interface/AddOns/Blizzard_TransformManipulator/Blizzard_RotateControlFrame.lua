RotateControlFrameMixin = {};

function RotateControlFrameMixin:OnLoad()
	MinimalSliderMixin.OnLoad(self);
	FrameUtil.RegisterForTopLevelParentChanged(self);
	FrameUtil.UpdateTopLevelParent(self);
end

function RotateControlFrameMixin:OnShow()
	FrameUtil.UpdateTopLevelParent(self);
end