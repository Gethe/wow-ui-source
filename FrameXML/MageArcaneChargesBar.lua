MagePowerBar = {};

function MagePowerBar:OnLoad()
	self.tooltipTitle = ARCANE_CHARGES;
	self.tooltip = ARCANE_CHARGES_TOOLTIP;
	self.class = "MAGE";
	self.spec = SPEC_MAGE_ARCANE;
	self.powerTokens = {"ARCANE_CHARGES"};
	
	ClassPowerBar.OnLoad(self);
end

function MagePowerBar:UpdatePower()
	local power = UnitPower("player", SPELL_POWER_ARCANE_CHARGES, true);
	
	for i = 1, power do
		local charge = self.Charges[i];
		if (not charge.on) then
			charge.on = true;
			charge.TurnOff:Stop();
			charge.TurnOn:Play();
		end
	end
	for i = power + 1, #self.Charges do
		local charge = self.Charges[i];
		if (charge.on) then
			charge.on = false;
			charge.TurnOn:Stop();
			charge.TurnOff:Play();
		end
	end
end
