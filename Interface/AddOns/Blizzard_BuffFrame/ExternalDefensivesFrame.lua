ExternalDefensivesFrameMixin = CreateFromMixins(BaseAuraFrameMixin);

function ExternalDefensivesFrameMixin:UpdateAuras()
	AuraFrameEditModeMixin.UpdateAuras(self);

	local usePackedAura = true;
	local auraIndex = 0;
	AuraUtil.ForEachAura(PlayerFrame.unit, "HELPFUL|EXTERNAL_DEFENSIVE", self.maxAuras, function(auraData)
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
