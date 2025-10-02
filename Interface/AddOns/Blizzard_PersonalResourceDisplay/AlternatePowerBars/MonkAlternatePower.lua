-- NOTE: If you make changes here, you likely need to make changes to MonkStaggerBar.lua

-- Monk Alternate Power Bar: Stagger
MonkAlternatePowerBarMixin = {};

-- percentages at which bar should change color
local STAGGER_STATES = {
	RED 	= { key = "red", threshold = .60 },
	YELLOW 	= { key = "yellow", threshold = .30 },
	GREEN 	= { key = "green" }
}

function MonkAlternatePowerBarMixin:Initialize()
	self.requiredClass = "MONK";
	self.requiredSpec = SPEC_MONK_BREWMASTER;
    self.powerName = "STAGGER";
	self.alternatePowerRequirementsMet = false;

	local statusBarTexture = self:GetStatusBarTexture();
	statusBarTexture:SetTexelSnappingBias(0);
	statusBarTexture:SetSnapToPixelGrid(false);

	self:EvaluateUnit();
end

function MonkAlternatePowerBarMixin:EvaluateUnit()
	local meetsRequirements = false;

	local _, class = UnitClass("player");
	meetsRequirements = class == self.requiredClass and C_SpecializationInfo.GetSpecialization() == self.requiredSpec;

	if meetsRequirements then
		self.alternatePowerRequirementsMet = true;
        self:UpdatePower();
        self:Show();
    else
        self:Hide();
    end
end

function MonkAlternatePowerBarMixin:UpdatePower()
	self:UpdateMinMaxPower();

    local currentPower = self:GetCurrentPower();
	self:SetValue(currentPower);
	self.currentPower = currentPower;

    self:UpdateArt();
end

function MonkAlternatePowerBarMixin:UpdateMinMaxPower()
	local minPower, maxPower = self:GetCurrentMinMaxPower();
	self:SetMinMaxValues(minPower, maxPower);
	self.minPower = minPower;
	self.maxPower = maxPower;
end

function MonkAlternatePowerBarMixin:GetCurrentPower()
	return UnitStagger("player") or 0;
end

function MonkAlternatePowerBarMixin:GetCurrentMinMaxPower()
	local maxHealth = UnitHealthMax("player");
	return 0, maxHealth;
end

function MonkAlternatePowerBarMixin:UpdateArt()
	if not self.currentPower or not self.maxPower then
		self.overrideArtInfo = nil;
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
	end

    local info = self.overrideArtInfo or PowerBarColor[self.powerName];
	if info then
        self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status-Rectangle");
        self:SetStatusBarColor(info.r, info.g, info.b);
	else
		self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana");
		self:SetStatusBarColor(1, 1, 1);
	end
end