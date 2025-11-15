-- TODO: This whole TransformManipulator thing and its controls are supposed to be generic and decoupled from housing
-- Rework this frame to be a ScriptObject so we're not leaning on housing-specific APIs and events like this
local RotationWhileShownEvents =
{
	"HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED",
};

RotateControlFrameMixin = {};

function RotateControlFrameMixin:OnLoad()
	FrameUtil.RegisterForTopLevelParentChanged(self);
	FrameUtil.UpdateTopLevelParent(self);

	local doOnEnter = GenerateClosure(self.OnEnter, self);
	local doOnLeave = GenerateClosure(self.OnLeave, self);
	self.LeftButton:SetHoverCallbacks(doOnEnter, doOnLeave);
	self.RightButton:SetHoverCallbacks(doOnEnter, doOnLeave);
end

function RotateControlFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_DECOR_PRECISION_MANIPULATION_STATUS_CHANGED" then
		self.isManipulating = ...;
		self:UpdateActiveState();
	end
end

function RotateControlFrameMixin:OnShow()
	FrameUtil.UpdateTopLevelParent(self);
	FrameUtil.RegisterFrameForEvents(self, RotationWhileShownEvents);
	self:UpdateActiveState();
end

function RotateControlFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RotationWhileShownEvents);
	self.isManipulating = nil;
end

function RotateControlFrameMixin:OnEnter()
	self:UpdateActiveState();
end

function RotateControlFrameMixin:OnLeave()
	self:UpdateActiveState();
end

function RotateControlFrameMixin:UpdateActiveState()
	local isHovered = self:IsMouseMotionFocus() or self.LeftButton:IsOver() or self.RightButton:IsOver();
	local isPressed = self.isManipulating or self.LeftButton:IsDown() or self.RightButton:IsDown();
	if isPressed then
		self:SetAlpha(1);
	elseif isHovered then
		self:SetAlpha(1);
	else
		self:SetAlpha(0.5);
	end
end


RotateControlArrowButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function RotateControlArrowButtonMixin:OnLoad()
	self.Icon:SetAtlas(self.atlas);
	self.HoverIcon:SetAtlas(self.atlas);
	self.PushedIcon:SetAtlas(self.atlas);

	ButtonStateBehaviorMixin.OnLoad(self);
end

function RotateControlArrowButtonMixin:OnButtonStateChanged()
	self.HoverIcon:SetShown(self.over and not self.down);
	self.PushedIcon:SetShown(self.down);
end

function RotateControlArrowButtonMixin:SetHoverCallbacks(onEnterCallback, onLeaveCallback)
	self.onEnterCallback = onEnterCallback;
	self.onLeaveCallback = onLeaveCallback;
end

function RotateControlArrowButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
	if self.onEnterCallback then
		self.onEnterCallback();
	end
end

function RotateControlArrowButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
	if self.onLeaveCallback then
		self.onLeaveCallback();
	end
end

function RotateControlArrowButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYDOWN);
	C_HousingExpertMode.SetPrecisionIncrementingActive(self.incrementType, true);
end

function RotateControlArrowButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_AXIS_SELECT_KEYUP);
	C_HousingExpertMode.SetPrecisionIncrementingActive(self.incrementType, false);
end
