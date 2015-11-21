ClassNameplateBarRogue = {};

function ClassNameplateBarRogue:OnLoad()
	self.class = "ROGUE";
	self.powerToken = "COMBO_POINTS";
	
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i].on = false;
	end
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarRogue:UpdatePower()
	local comboPoints = UnitPower("player", SPELL_POWER_COMBO_POINTS);
	for i = 1, min(comboPoints, #self.ComboPoints) do
		if (not self.ComboPoints[i].on) then
			self:TurnOn(self.ComboPoints[i], self.ComboPoints[i].Point, 1);
		end
	end
	for i = comboPoints + 1, #self.ComboPoints do
		if (self.ComboPoints[i].on) then
			self:TurnOff(self.ComboPoints[i], self.ComboPoints[i].Point, 0);
		end
	end
end
