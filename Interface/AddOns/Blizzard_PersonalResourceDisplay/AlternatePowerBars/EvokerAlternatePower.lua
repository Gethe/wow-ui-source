-- NOTE: If you make changes here, you likely need to make changes to EvokerEbonMightBar.lua

-- Evoker Alternate Power Bar: Ebon Might
EvokerAlternatePowerBarMixin = {};

-- Ebon Might Spell that applies Aura on Self
local EBON_MIGHT_SELF_AURA_SPELL_ID = 395296;
-- Design-specified, useful visual range from testing, roughly based on upper potential duration range
local EBON_MIGHT_DISPLAY_MAX = 20;

function EvokerAlternatePowerBarMixin:Initialize()
	self.requiredClass = "EVOKER";
	self.requiredSpec = SPEC_EVOKER_AUGMENTATION;
	self.auraExpirationTime = nil;
    self.powerName = "EBON_MIGHT";
	self.alternatePowerRequirementsMet = false;

    local statusBarTexture = self:GetStatusBarTexture();
	statusBarTexture:SetTexelSnappingBias(0);
	statusBarTexture:SetSnapToPixelGrid(false);

    self:EvaluateUnit();
end

function EvokerAlternatePowerBarMixin:EvaluateUnit()
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

function EvokerAlternatePowerBarMixin:UpdatePower()
    self:UpdateMinMaxPower();

	local currentPower = self:GetCurrentPower();
	self:SetValue(currentPower);
	self.currentPower = currentPower;

    self:UpdateArt();
end

function EvokerAlternatePowerBarMixin:UpdateMinMaxPower()
	local minPower, maxPower = self:GetCurrentMinMaxPower();
	self:SetMinMaxValues(minPower, maxPower);
	self.minPower = minPower;
	self.maxPower = maxPower;
end


function EvokerAlternatePowerBarMixin:GetCurrentPower()
	if not self.auraExpirationTime then
		return 0;
	end

	return self.auraExpirationTime - GetTime();
end

function EvokerAlternatePowerBarMixin:UpdateAuraState()
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(EBON_MIGHT_SELF_AURA_SPELL_ID);

	local auraExpirationTime = auraInfo and auraInfo.expirationTime or nil;

	if auraExpirationTime ~= self.auraExpirationTime then
		self.auraExpirationTime = auraExpirationTime;
		self:UpdatePower();
	end
end

function EvokerAlternatePowerBarMixin:GetCurrentMinMaxPower()
	return 0, EBON_MIGHT_DISPLAY_MAX;
end

function EvokerAlternatePowerBarMixin:UpdateArt()
	local info = self.overrideArtInfo or PowerBarColor[self.powerName];
	if info then
        self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status-Rectangle");
        self:SetStatusBarColor(info.r, info.g, info.b);
	else
		self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana");
		self:SetStatusBarColor(1, 1, 1);
	end
end