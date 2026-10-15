local DefaultMaxPoints = 5;	-- Default number of max points for normal layout handling
local DefaultLeftPadding = 0;	-- Padding to use while at or below DefaultMaxPoints
local LeftPaddingPerPointOverDefault = -20;	-- Padding to add for each max point above DefaultMaxPoints

RogueComboPointBarMixin = {};

function RogueComboPointBarMixin:UpdatePower()
	local unit = self:GetUnit();
	local comboPoints = UnitPower(unit, self.powerType);
	local chargedPowerPoints = GetUnitChargedPowerPoints(unit);
	for i = 1, #self.classResourceButtonTable do
		local isFull = i <= comboPoints;
		local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i) or false;

		self.classResourceButtonTable[i]:Update(isFull, isCharged);
	end
end

function RogueComboPointBarMixin:UpdateChargedPowerPoints()
	self:UpdatePower();
end

function RogueComboPointBarMixin:UpdateMaxPower()
	local maxPoints = UnitPowerMax(self:GetUnit(), self.powerType);
	if maxPoints <= DefaultMaxPoints then
		self.leftPadding = DefaultLeftPadding;
	else
		local pointsOverDefault = maxPoints - DefaultMaxPoints;
		self.leftPadding = pointsOverDefault * LeftPaddingPerPointOverDefault;
	end

	ClassResourceBarMixin.UpdateMaxPower(self);
end
