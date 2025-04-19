ClassNameplateBarPaladin = {};

function ClassNameplateBarPaladin:OnLoad()
	PaladinPowerBar.OnLoad(self);
end

function ClassNameplateBarPaladin:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarPaladin:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarPaladin:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarPaladin:UpdatePower()
	PaladinPowerBar.UpdatePower(self);
end