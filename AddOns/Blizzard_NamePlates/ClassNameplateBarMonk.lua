ClassNameplateBarMonk = {};

function ClassNameplateBarMonk:OnLoad()
	self.class = "MONK";
	self.spec = SPEC_MONK_WINDWALKER;
	self.powerToken = "CHI";
	
	for i = 1, #self.Chi do
		self.Chi[i].on = false;
	end
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarMonk:UpdateMaxPower()
	local maxOrbs = UnitPowerMax("player", SPELL_POWER_CHI);
	self.Chi6:SetShown(maxOrbs == 6);
	self:SetWidth(self.Chi1:GetWidth() * maxOrbs);
end

function ClassNameplateBarMonk:UpdatePower()
	local chi = UnitPower("player", SPELL_POWER_CHI);
	for i = 1, min(chi, #self.Chi) do
		if (not self.Chi[i].on) then
			self:TurnOn(self.Chi[i], self.Chi[i].Orb, 1);
		end
	end
	for i = chi + 1, #self.Chi do
		if (self.Chi[i].on) then
			self:TurnOff(self.Chi[i], self.Chi[i].Orb, 0);
		end
	end
end
