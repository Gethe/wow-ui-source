
local ParentFunction = LossOfControlMixin.OnLoad;

local CooldownEdgeTexture = 666943;

function LossOfControlMixin:OnLoad()
	ParentFunction(self);
	self.Cooldown:SetEdgeTexture(CooldownEdgeTexture);
	self.Cooldown:SetEdgeColor(1.0, 1.0, 0.0, 1.0);
end