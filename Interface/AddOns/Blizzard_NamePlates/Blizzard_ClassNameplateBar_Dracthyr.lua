ClassNameplateBarDracthyr = { };

function ClassNameplateBarDracthyr:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end 

function ClassNameplateBarDracthyr:SetupDracthyr()
	self:ShowNameplateBar();
	return EssencePowerBar.SetupEvoker(self);
end

function ClassNameplateBarDracthyr:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarDracthyr:UpdatePower()
	EssencePowerBar.UpdatePower(self);
end 