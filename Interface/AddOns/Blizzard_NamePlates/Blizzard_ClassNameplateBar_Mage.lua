ClassNameplateBarMage = {};


function ClassNameplateBarMage:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end 

function ClassNameplateBarMage:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarMage:Setup()
	local showBar = ClassNameplateBar.Setup(self);
	if(showBar) then 
		self:ShowNameplateBar();
	end 
	return showBar; 
end

function ClassNameplateBarMage:UpdatePower()
	local charges = UnitPower("player", Enum.PowerType.ArcaneCharges);
	for i = 1, min(charges, #self.classResourceButtonTable) do
		local charge = self.classResourceButtonTable[i]; 
		if (charge and not charge.on) then
			self:TurnOn(charge, charge.ChargeTexture, 1);
		end
	end
	for i = charges + 1, #self.classResourceButtonTable do
		local charge = self.classResourceButtonTable[i]; 
		if (charge and charge.on) then
			self:TurnOff(charge, charge.ChargeTexture, 0.3);
		end
	end
end

ClassNameplateBarArcaneChargeMixin = { };
function ClassNameplateBarArcaneChargeMixin:Setup()
	self.on = false; 
end		