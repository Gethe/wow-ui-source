ClassNameplateBarWarlock = {};

function ClassNameplateBarWarlock:OnLoad()
	WarlockPowerBar.OnLoad(self);
end

function ClassNameplateBarWarlock:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarWarlock:OnEvent(event, ...)
	WarlockPowerBar.OnEvent(self, event, ...);
end

function ClassNameplateBarWarlock:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarWarlock:UpdatePower()
	WarlockPowerBar.UpdatePower(self);
end
