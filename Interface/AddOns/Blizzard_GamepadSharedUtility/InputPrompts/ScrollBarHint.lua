GamepadScrollBarHintMixin = {};

function GamepadScrollBarHintMixin:OnLoad()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.GamepadUninit, self));
end

function GamepadScrollBarHintMixin:GamepadUninit()
	self:Hide();
end

function GamepadScrollBarHintMixin:SetOwner(owner, anchor, offsetX, offsetY)
	self:ClearAllPoints();
	self:SetParent(owner);
	self:SetPoint("CENTER", owner, anchor, offsetX, offsetY);
end
