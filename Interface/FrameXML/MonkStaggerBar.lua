-- percentages at which bar should change color
STAGGER_YELLOW_TRANSITION = .30
STAGGER_RED_TRANSITION = .60

-- table indices of bar colors
STAGGER_GREEN_INDEX = 1;
STAGGER_YELLOW_INDEX = 2;
STAGGER_RED_INDEX = 3;

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

	if percent >= STAGGER_RED_TRANSITION then
		artInfo = artInfo[STAGGER_RED_INDEX];
	elseif percent >= STAGGER_YELLOW_TRANSITION then
		artInfo = artInfo[STAGGER_YELLOW_INDEX];
	else
		artInfo = artInfo[STAGGER_GREEN_INDEX];
	end
	self.overrideArtInfo = artInfo;

	self.baseMixin.UpdateArt(self);
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