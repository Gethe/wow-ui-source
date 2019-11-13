-- These are functions that were deprecated in 8.3.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- New auction house.
do
	-- For more information on the new auction house api, start with: /api C_AuctionHouse

	-- For 'allItem' auction house scans ONLY, the following APIs have been replaced with equivalents (arguments adjusted slightly):
	-- QueryAuctionItems(name, minLevel, maxLevel, offset, onlyUsable, quality, allItems, exactMatch) -> C_AuctionHouse.ReplicateItems()
	-- GetNumAuctionItems(type) 					-> C_AuctionHouse.GetNumReplicateItems()
	-- GetAuctionItemInfo(type, index)	 			-> C_AuctionHouse.GetReplicateItemInfo(index)
	-- GetAuctionItemLink(type, index) 				-> C_AuctionHouse.GetReplicateItemLink(index)
	-- GetAuctionItemBattlePetInfo(type, index) 	-> C_AuctionHouse.GetReplicateItemBattlePetInfo(index)
	-- GetAuctionItemTimeLeft(type, index) 			-> C_AuctionHouse.GetReplicateItemTimeLeft(index)
	--
	-- Important note: For querying the entire auction house, these APIs should be used instead of the other new C_AuctionHouse APIs,
	-- as those are throttled to smaller limits and will not allow an entire AH dump.
	--
end

-- unit alternate power
do
	GetAlternatePowerInfoByID = function(barID)
		local barInfo = GetUnitPowerBarInfoByID(barID);
		if barInfo then
			local name, tooltip, cost = GetUnitPowerBarStringsByID(barID);
			return barInfo.barType,barInfo.minPower, barInfo.startInset, barInfo.endInset, barInfo.smooth, barInfo.hideFromOthers, barInfo.showOnRaid, barInfo.opaqueSpark, barInfo.opaqueFlash,
					barInfo.anchorTop, name, tooltip, cost, barInfo.ID, barInfo.forcePercentage, barInfo.sparkUnderFrame;
		end
	end

	UnitAlternatePowerInfo = function(unit)
		local barID = UnitPowerBarID(unit);
		return GetAlternatePowerInfoByID(barID);
	end

	UnitAlternatePowerTextureInfo = function(unit, textureIndex, timerIndex)
		return GetUnitPowerBarTextureInfo(unit, textureIndex + 1, timerIndex);
	end

	UnitAlternatePowerCounterInfo = function(unit)
		local barInfo = GetUnitPowerBarInfo(unit);
		if barInfo then
			return barInfo.fractionalCounter, barInfo.animateNumbers;
		end
	end
end
