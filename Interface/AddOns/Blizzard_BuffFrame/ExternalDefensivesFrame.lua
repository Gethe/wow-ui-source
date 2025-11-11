local externalDefensiveTrackerEnabledCVar = "externalDefensivesEnabled";
CVarCallbackRegistry:SetCVarCachable(externalDefensiveTrackerEnabledCVar);

ExternalDefensivesFrameMixin = CreateFromMixins(BaseAuraFrameMixin);

function ExternalDefensivesFrameMixin:ExternalDefensives_OnLoad()
	CVarCallbackRegistry:RegisterCallback(externalDefensiveTrackerEnabledCVar, self.OnExternalDefensivesEnabledCVarChanged, self);
end

function ExternalDefensivesFrameMixin:OnExternalDefensivesEnabledCVarChanged()
	self:UpdateShownState();
end

function ExternalDefensivesFrameMixin:ShouldBeShown()
	if CVarCallbackRegistry:GetCVarValueBool(externalDefensiveTrackerEnabledCVar) ~= true then
		return false;
	end

	return AuraFrameEditModeMixin.ShouldBeShown(self);
end

function ExternalDefensivesFrameMixin:UpdateAuras()
	AuraFrameEditModeMixin.UpdateAuras(self);

	local usePackedAura = true;
	local auraIndex = 0;
	local filter = AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful, AuraUtil.AuraFilters.ExternalDefensive);
	AuraUtil.ForEachAura(PlayerFrame.unit, filter, self.maxAuras, function(auraData)
		local auraInfoIndex = #self.auraInfo + 1; -- Note that if we started with auras in self.auraInfo (e.g., Weapon Enchants), this may be offset from auraIndex.
		auraIndex = auraIndex + 1;

		self.auraInfo[auraInfoIndex] = {
			index = auraIndex,
			texture = auraData.icon,
			count = auraData.applications,
			debuffType = auraData.dispelName,
			duration = auraData.duration,
			expirationTime = auraData.expirationTime,
			timeMod = auraData.timeMod,
			hideUnlessExpanded = hideUnlessExpanded,
			auraType = "Buff",
			auraInstanceID =  auraData.auraInstanceID,
		};
		return #self.auraInfo > self.maxAuras;
	end, usePackedAura);
end
