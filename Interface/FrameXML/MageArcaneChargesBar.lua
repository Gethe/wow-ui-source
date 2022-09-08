MagePowerBar = {};

function MagePowerBar:UpdatePower()
	local power = UnitPower("player", Enum.PowerType.ArcaneCharges, true);

	for i = 1, power do
		local charge =  self.classResourceButtonTable[i];
		if (charge and not charge.on) then
			charge.on = true;
			charge.TurnOff:Stop();
			charge.TurnOn:Play();
		end
	end
	for i = power + 1, #self.classResourceButtonTable do
		local charge = self.classResourceButtonTable[i];
		if (charge and charge.on) then
			charge.on = false;
			charge.TurnOn:Stop();
			charge.TurnOff:Play();
		end
	end
end

ArcaneChargeMixin = { };
function ArcaneChargeMixin:Setup()
	self.on = false; 
end		