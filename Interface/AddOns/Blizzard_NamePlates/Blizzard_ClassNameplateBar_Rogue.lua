ClassNameplateBarRogue = {};

function ClassNameplateBarRogue:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarRogue:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarRogue:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarRogue:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarRogue:UpdatePower()
	RogueComboPointBarMixin.UpdatePower(self);
end