DruidComboPointBarMixin = {};

function DruidComboPointBarMixin:ShouldShowComboPointBar()
	if not ClassPowerBar.ShouldShowBar(self) then
		return false;
	end

	local unit = self:GetUnit();
	local powerType = UnitPowerType(unit);
	return powerType == Enum.PowerType.Energy;
end

function DruidComboPointBarMixin:UpdatePower()
	local comboPoints = UnitPower(self:GetUnit(), self.powerType);

	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= comboPoints);
	end
end
