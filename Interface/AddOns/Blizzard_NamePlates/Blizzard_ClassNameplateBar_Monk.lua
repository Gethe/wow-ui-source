--------------------------------------------------------------------------------
--
-- ClassNameplateBarWindwalkerMonk
--
--------------------------------------------------------------------------------


ClassNameplateBarWindwalkerMonk = {};

function ClassNameplateBarWindwalkerMonk:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarWindwalkerMonk:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarWindwalkerMonk:OnEvent(event, ...)
	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function ClassNameplateBarWindwalkerMonk:UpdateMaxPower()
	MonkPowerBar.UpdateMaxPower(self);
end

function ClassNameplateBarWindwalkerMonk:UpdatePower()
	MonkPowerBar.UpdatePower(self);
end


--------------------------------------------------------------------------------
--
-- ClassNameplateBarBrewmasterMonk
--
--------------------------------------------------------------------------------


ClassNameplateBarBrewmasterMonk = {};

function ClassNameplateBarBrewmasterMonk:Initialize()
	self.Border:SetVertexColor(0, 0, 0, 1);
	self.Border:SetBorderSizes(nil, nil, 0, 0);
	MonkStaggerBarMixin.Initialize(self);
end