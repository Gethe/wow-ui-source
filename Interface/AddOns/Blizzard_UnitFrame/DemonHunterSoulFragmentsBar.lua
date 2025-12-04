-- NOTE: If you make changes here, you likely need to make changes to DemonHunterAlternatePower.lua

DemonHunterSoulFragmentsBarMixin = {
	VOID_METAMORPHOSIS_ANIM_ART = {
		glow = "UF-DDH-VoidMeta-Bar-Glow",
		ready = "UF-DDH-VoidMeta-Bar-Ready",
		deplete = "UF-DDH-VoidMeta-Bar-Deplete"
	};
	COLLAPSING_STAR_ANIM_ART = {
		glow = "UF-DDH-CollapsingStar-Bar-Glow",
		ready = "UF-DDH-CollapsingStar-Bar-Ready",
		deplete = "UF-DDH-CollapsingStar-Bar-Deplete"
	};
};

function DemonHunterSoulFragmentsBarMixin:Initialize()
	self.requiredClass = "DEMONHUNTER";
	self.requiredSpec = SPEC_DEMONHUNTER_DEVOURER;
	self.frequentUpdates = true;
	self.disablePercentages = true;

	self.inVoidMetamorphosis = false;

	-- When void metamorphosis state starts.
	self.VoidMetaDepleteAnim:SetScript("OnFinished", function()
		self.CollapsingStarBackground:SetAlpha(1);
		self.CollapsingStarBackground:Show();

		self:UpdateArt();
	end);

	-- When void metamorphosis state ends.
	self.CollapsingStarDepleteFinAnim:SetScript("OnFinished", function()
		self.CollapsingStarBackground:Hide();

		self:UpdateArt();
	end);

	self.GlowAnim:SetScript("OnFinished", function()
		self.ReadyAnim:Restart();
	end);

	self.baseMixin.Initialize(self);
end

function DemonHunterSoulFragmentsBarMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local _unitToken, auraUpdateInfo = ...;
		self:OnUnitAuraUpdate(auraUpdateInfo);
	elseif event == "UNIT_SPELLCAST_START" then
		local _unit, _castID, spellID = ...;
		if spellID == Constants.UnitPowerSpellIDs.COLLAPSING_STAR_SPELL_ID then
			self.CollapsingStarDepleteAnim:Restart();
		end
	end

	self.baseMixin.OnEvent(self, event, ...);
end

function DemonHunterSoulFragmentsBarMixin:OnUnitAuraUpdate(unitAuraUpdateInfo)
	if unitAuraUpdateInfo == nil then
		return;
	end

	-- It's possible for UI to get a UNIT_AURA event with no update info, avoid reacting to that
	local isUpdatePopulated = unitAuraUpdateInfo.isFullUpdate
		or (unitAuraUpdateInfo.addedAuras ~= nil and #unitAuraUpdateInfo.addedAuras > 0)
		or (unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.removedAuraInstanceIDs > 0)
		or (unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil and #unitAuraUpdateInfo.updatedAuraInstanceIDs > 0);

	if isUpdatePopulated then
		self:UpdateAuraState();
	end
end

function DemonHunterSoulFragmentsBarMixin:UpdateAuraState()
	local inVoidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID) ~= nil;

	if inVoidMetamorphosis ~= self.inVoidMetamorphosis then
		self.inVoidMetamorphosis = inVoidMetamorphosis;

		-- Transition animations, deplete anims will call UpdateArt when finished to swap to new assets.
		self.GlowAnim:Stop();
		self.ReadyAnim:Stop();

		if self.inVoidMetamorphosis then
			self.VoidMetaDepleteAnim:Restart();
		else
			self.CollapsingStarDepleteFinAnim:Restart();
		end
	end
end

function DemonHunterSoulFragmentsBarMixin:UpdatePower()
	self:UpdateMinMaxPower();
	self.baseMixin.UpdatePower(self);

	-- Determine if any anims should play/stop based on current power.
	local _minPower, maxPower = self:GetCurrentMinMaxPower();
	local currentPower = self:GetCurrentPower();
	if currentPower >= maxPower and not self.GlowAnim:IsPlaying() and not self.ReadyAnim:IsPlaying() then
		self.GlowAnim:Restart();
	elseif currentPower < maxPower and (self.GlowAnim:IsPlaying() or self.ReadyAnim:IsPlaying()) then
		self.GlowAnim:Stop();
		self.ReadyAnim:Stop();
	end
end

function DemonHunterSoulFragmentsBarMixin:UpdateArt()
	local artInfo = PowerBarColor[self.powerName];
	local animArt;
	if self.inVoidMetamorphosis then
		self.overrideArtInfo = artInfo.collapsingStarProgess;
		animArt = self.COLLAPSING_STAR_ANIM_ART;
	else
		self.overrideArtInfo = artInfo.voidMetamorphosisProgess;
		animArt = self.VOID_METAMORPHOSIS_ANIM_ART;
	end

	self.Glow:SetAtlas(animArt.glow, TextureKitConstants.UseAtlasSize);
	self.Ready:SetAtlas(animArt.ready, TextureKitConstants.UseAtlasSize);
	self.Deplete:SetAtlas(animArt.deplete, TextureKitConstants.UseAtlasSize);

	self.baseMixin.UpdateArt(self);
end

function DemonHunterSoulFragmentsBarMixin:EvaluateUnit()
	local meetsRequirements = false;

	local _, class = UnitClass(self:GetUnit());
	meetsRequirements = class == self.requiredClass and C_SpecializationInfo.GetSpecialization() == self.requiredSpec;

	self:SetBarEnabled(meetsRequirements);
end

function DemonHunterSoulFragmentsBarMixin:OnBarEnabled()
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");

	self:UpdateAuraState();
end

function DemonHunterSoulFragmentsBarMixin:OnBarDisabled()
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UNIT_SPELLCAST_START");

	self.inVoidMetamorphosis = false;
end

function DemonHunterSoulFragmentsBarMixin:GetCurrentPower()
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

function DemonHunterSoulFragmentsBarMixin:GetCurrentMinMaxPower()
	local maxPower = 0;
	if self.inVoidMetamorphosis then
		maxPower = GetCollapsingStarCost();
	else
		maxPower = C_Spell.GetSpellMaxCumulativeAuraApplications(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID);
	end

	return 0, maxPower;
end
