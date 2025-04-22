-- percentages at which bar should change color
STAGGER_STATES = {
	RED 	= { key = "red", threshold = .60 },
	YELLOW 	= { key = "yellow", threshold = .30 },
	GREEN 	= { key = "green" }
}

MonkStaggerBarMixin = {};

function MonkStaggerBarMixin:Initialize()
	self.frequentUpdates = true;
	self.requiredClass = "MONK";
	self.requiredSpec = SPEC_MONK_BREWMASTER;

	self.baseMixin.Initialize(self);
end

function MonkStaggerBarMixin:UpdatePower()
	self:UpdateMinMaxPower();
	self.baseMixin.UpdatePower(self);
	self:UpdateArt();
end

function MonkStaggerBarMixin:UpdateArt()
	if not self.currentPower or not self.maxPower then
		self.overrideArtInfo = nil;
		self.baseMixin.UpdateArt(self);
		return;
	end

	local percent = self.maxPower > 0 and self.currentPower / self.maxPower or 0;
	local artInfo = PowerBarColor[self.powerName];
	local staggerStateKey;

	if percent >= STAGGER_STATES.RED.threshold then
		staggerStateKey = STAGGER_STATES.RED.key;
	elseif percent >= STAGGER_STATES.YELLOW.threshold then
		staggerStateKey = STAGGER_STATES.YELLOW.key;
	else
		staggerStateKey = STAGGER_STATES.GREEN.key;
	end

	if self.staggerStateKey ~= staggerStateKey then
		self.staggerStateKey = staggerStateKey;

		self.overrideArtInfo = artInfo[staggerStateKey];
		self.overrideArtInfo.spark = artInfo.spark;

		self.baseMixin.UpdateArt(self);
	end
end

function MonkStaggerBarMixin:EvaluateUnit()
	local meetsRequirements = false;

	local _, class = UnitClass(self:GetUnit());
	meetsRequirements = class == self.requiredClass and GetSpecialization() == self.requiredSpec;

	self:SetBarEnabled(meetsRequirements);
end

function MonkStaggerBarMixin:OnBarEnabled()
	self:UpdatePower();
end

function MonkStaggerBarMixin:GetCurrentPower()
	return UnitStagger(self:GetUnit()) or 0;
end

function MonkStaggerBarMixin:GetCurrentMinMaxPower()
	local maxHealth = UnitHealthMax(self:GetUnit());
	return 0, maxHealth;
end