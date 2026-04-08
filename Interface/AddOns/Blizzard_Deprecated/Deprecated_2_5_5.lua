
-- These are functions are deprecated, and will be removed in a future patch.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	UnitAura = function(unitToken, index, filter)
		local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter);
		if not auraData then
			return nil;
		end

		return AuraUtil.UnpackAuraData(auraData);
	end
	UnitBuff = function(unitToken, index, filter)
		local auraData = C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter);
		if not auraData then
			return nil;
		end

		return AuraUtil.UnpackAuraData(auraData);
	end
	UnitDebuff = function(unitToken, index, filter)
		local auraData = C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter);
		if not auraData then
			return nil;
		end

		return AuraUtil.UnpackAuraData(auraData);
	end
end
