-- These are functions that were deprecated in 10.2.5 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	GetTimeToWellRested = function() return nil; end
	FillLocalizedClassList = function(tbl, isFemale)
		local classList = LocalizedClassList(isFemale);
		MergeTable(tbl, classList);
		return tbl;
	end
	GetSetBonusesForSpecializationByItemID = C_Item.GetSetBonusesForSpecializationByItemID;
	GetItemStats = function(itemLink, existingTable)
		local statTable = C_Item.GetItemStats(itemLink);
		if existingTable then
			MergeTable(existingTable, statTable);
			return existingTable;
		else
			return statTable;
		end
	end
	GetItemStatDelta = function(itemLink1, itemLink2, existingTable)
		local statTable = C_Item.GetItemStatDelta(itemLink1, itemLink2);
		if existingTable then
			MergeTable(existingTable, statTable);
			return existingTable;
		else
			return statTable;
		end
	end
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
	UnitAuraBySlot = function(unitToken, index)
		local auraData = C_UnitAuras.GetAuraDataBySlot(unitToken, index);
		if not auraData then
			return nil;
		end

		return AuraUtil.UnpackAuraData(auraData);
	end
	UnitAuraSlots = C_UnitAuras.GetAuraSlots;
end