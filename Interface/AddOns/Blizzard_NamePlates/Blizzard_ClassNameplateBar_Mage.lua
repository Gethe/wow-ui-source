ClassNameplateBarMage = {};

function ClassNameplateBarMage:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarMage:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarMage:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarMage:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarMage:UpdatePower()
	MagePowerBar.UpdatePower(self);
end