-- NOTE: If you make changes here, you likely need to make changes to DemonHunterSoulFragmentsBar.lua

-- Demon Hunter Alternate Power Bar: Soul Fragments
DemonHunterAlternatePowerBarMixin = {};

function DemonHunterAlternatePowerBarMixin:Initialize()
	self.requiredClass = "DEMONHUNTER";
	self.requiredSpec = SPEC_DEMONHUNTER_DEVOURER;
	self.powerName = "SOUL_FRAGMENTS";
	self.alternatePowerRequirementsMet = false;

	self.inVoidMetamorphosis = false;

	local statusBarTexture = self:GetStatusBarTexture();
	statusBarTexture:SetTexelSnappingBias(0);
	statusBarTexture:SetSnapToPixelGrid(false);

	self:EvaluateUnit();
end

function DemonHunterAlternatePowerBarMixin:EvaluateUnit()
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

function DemonHunterAlternatePowerBarMixin:UpdatePower()
	self:UpdateMinMaxPower();

	local currentPower = self:GetCurrentPower();
	self:SetValue(currentPower);
	self.currentPower = currentPower;

	self:UpdateArt();
end

function DemonHunterAlternatePowerBarMixin:UpdateMinMaxPower()
	local minPower, maxPower = self:GetCurrentMinMaxPower();
	self:SetMinMaxValues(minPower, maxPower);
	self.minPower = minPower;
	self.maxPower = maxPower;
end

function DemonHunterAlternatePowerBarMixin:UpdateAuraState()
	local inVoidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID);

	if inVoidMetamorphosis ~= self.inVoidMetamorphosis then
		self.inVoidMetamorphosis = inVoidMetamorphosis;
		self:UpdatePower();
	end
end

function DemonHunterAlternatePowerBarMixin:GetCurrentPower()
	local currentPower = 0;

	if self.inVoidMetamorphosis then
		local silenceTheWhispersAura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.SILENCE_THE_WHISPERS_SPELL_ID);
		if silenceTheWhispersAura then
			currentPower = silenceTheWhispersAura.applications;
		end
	else
		local darkHeartAura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID);
		if darkHeartAura then
			currentPower = darkHeartAura.applications;
		end
	end

	return currentPower;
end

function DemonHunterAlternatePowerBarMixin:GetCurrentMinMaxPower()
	local maxPower = 0;
	if self.inVoidMetamorphosis then
		maxPower = GetCollapsingStarCost();
	else
		maxPower = C_Spell.GetSpellMaxCumulativeAuraApplications(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID);
	end

	return 0, maxPower;
end

function DemonHunterAlternatePowerBarMixin:UpdateArt()
	local artInfo = PowerBarColor[self.powerName];
	if self.inVoidMetamorphosis then
		self.overrideArtInfo = artInfo.collapsingStarProgess;
	else
		self.overrideArtInfo = artInfo.voidMetamorphosisProgess;
	end

	if self.overrideArtInfo then
		self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status-Rectangle");
		self:SetStatusBarColor(self.overrideArtInfo.r, self.overrideArtInfo.g, self.overrideArtInfo.b);
	else
		self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana");
		self:SetStatusBarColor(1, 1, 1);
	end
end