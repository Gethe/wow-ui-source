-- Used by the Personal Resource Display.
-- Shared logic for alternate power bars that display Mana as the alternate resource.
-- Class-specific mixins should be created and must define requiredClass and requiredSpec as table fields.
ManaAlternatePowerMixin = {};

function ManaAlternatePowerMixin:Initialize()
	self.powerName = "MANA";
	self.powerType = Enum.PowerType.Mana;

	local powerBarColor = PowerBarColor[self.powerName];
	if powerBarColor then
		self:SetStatusBarColor(powerBarColor.r, powerBarColor.g, powerBarColor.b);
	end

	self:EvaluateUnit();
end

function ManaAlternatePowerMixin:EvaluateUnit()
	local _className, classFileName, _classID = UnitClass("player");
	local specialization = C_SpecializationInfo.GetSpecialization();
	self.alternatePowerRequirementsMet = classFileName == self.requiredClass and specialization == self.requiredSpec;

	if self.alternatePowerRequirementsMet then
		self:UpdatePower();
		self:Show();
	else
		self:Hide();
	end
end

function ManaAlternatePowerMixin:UpdatePower()
	self:UpdateMinMaxPower();

	local currentPower = self:GetCurrentPower();
	self:SetValue(currentPower);
end

function ManaAlternatePowerMixin:UpdateMinMaxPower()
	local minPower, maxPower = self:GetCurrentMinMaxPower();
	self:SetMinMaxValues(minPower, maxPower);
end

function ManaAlternatePowerMixin:GetCurrentPower()
	return UnitPower("player", self.powerType);
end

function ManaAlternatePowerMixin:GetCurrentMinMaxPower()
	return 0, UnitPowerMax("player", self.powerType);
end

PriestAlternatePowerBarMixin = CreateFromMixins(ManaAlternatePowerMixin);
PriestAlternatePowerBarMixin.requiredClass = "PRIEST";
PriestAlternatePowerBarMixin.requiredSpec = SPEC_PRIEST_SHADOW;

DruidAlternatePowerBarMixin = CreateFromMixins(ManaAlternatePowerMixin);
DruidAlternatePowerBarMixin.requiredClass = "DRUID";
DruidAlternatePowerBarMixin.requiredSpec = SPEC_DRUID_BALANCE;
