MovePadMixin = {};

function MovePadMixin:OnLoad()
	local function OnValueChanged(o, setting, value)
		self:SetShown(value);
	end

	if Settings then
		Settings.SetOnValueChangedCallback("enableMovePad", OnValueChanged);
	end
end

function MovePadMixin:OnDragStart()
	if self.canMove then
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
	end
end

function MovePadMixin:OnDragStop()
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
	self:SetFrameStrata("BACKGROUND");
end