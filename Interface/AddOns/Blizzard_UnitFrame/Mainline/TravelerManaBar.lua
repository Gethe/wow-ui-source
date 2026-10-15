local MANA_PER_TRAVELER_PIP = 10;

TravelerManaBarMixin = {};

function TravelerManaBarMixin:UpdateMaxPower()
	local oldMaxPoints = self.maxUsablePoints;
	local unit = self:GetUnit();
	self.unit = unit;
	local maxMana = UnitPowerMax(unit, self.powerType);
	self.maxUsablePoints = math.floor(maxMana / MANA_PER_TRAVELER_PIP);

	if self.usePooledResourceButtons then
		if oldMaxPoints and self.maxUsablePoints == oldMaxPoints and self.classResourceButtonTable and #self.classResourceButtonTable == self.maxUsablePoints then
			return;
		end

		self.classResourceButtonPool:ReleaseAll();
		self.classResourceButtonTable = {};

		assertsafe(self.maxUsablePoints <= 100, "TravelerManaBar: maxUsablePoints unexpectedly high = " .. self.maxUsablePoints);

		for i = 1, self.maxUsablePoints do
			local resourcePoint = self.classResourceButtonPool:Acquire();
			self.classResourceButtonTable[i] = resourcePoint;
			self.resourcePointMixin.Setup(resourcePoint);
			resourcePoint.layoutIndex = i;
			resourcePoint:Show();
		end

		self:Layout();
		self:UpdatePower();
	end
end

function TravelerManaBarMixin:UpdatePower()
	local currentMana = UnitPower(self:GetUnit(), self.powerType);
	local filledPips = math.floor(currentMana / MANA_PER_TRAVELER_PIP);

	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetActive(i <= filledPips);
	end
end
