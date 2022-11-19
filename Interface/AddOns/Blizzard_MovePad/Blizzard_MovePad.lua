MovePadMixin = {};

function MovePadMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	local function OnValueChanged(o, setting, value)
		self:SetShown(value);
	end
	Settings.SetOnValueChangedCallback("enableMovePad", OnValueChanged);
end

function MovePadMixin:OnDragStart()
	if self.canMove then
		self.moving = true;
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
	end
end

function MovePadMixin:OnDragStop()
	if self.canMove and self.moving then
		self.moving = false;
		self:StopMovingOrSizing();
		self:SetFrameStrata("BACKGROUND");
		ValidateFramePosition(self, 25);
	end
end