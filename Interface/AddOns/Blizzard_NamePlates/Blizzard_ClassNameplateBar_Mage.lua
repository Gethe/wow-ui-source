ClassNameplateBarMage = {};

function ClassNameplateBarMage:OnLoad()
	self.class = "MAGE";
	self.spec = SPEC_MAGE_ARCANE;
	self.powerToken = "ARCANE_CHARGES";

	for i = 1, #self.Charges do
		self.Charges[i].on = false;
	end
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarMage:UpdatePower()
	local charges = UnitPower("player", Enum.PowerType.ArcaneCharges);
	for i = 1, min(charges, #self.Charges) do
		if (not self.Charges[i].on) then
			self:TurnOn(self.Charges[i], self.Charges[i].ChargeTexture, 1);
		end
	end
	for i = charges + 1, #self.Charges do
		if (self.Charges[i].on) then
			self:TurnOff(self.Charges[i], self.Charges[i].ChargeTexture, 0.3);
		end
	end
end
