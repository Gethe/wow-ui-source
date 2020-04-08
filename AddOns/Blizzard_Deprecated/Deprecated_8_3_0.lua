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

-- Deprecated a bunch of ContainerFrame global constants that don't need to be global
-- Addon developers: if you need these, make local versions of them
do
	MAX_CONTAINER_ITEMS = 36;
	NUM_CONTAINER_COLUMNS = 4;
	ROWS_IN_BG_TEXTURE = 6;
	MAX_BG_TEXTURES = 2;
	BG_TEXTURE_HEIGHT = 512;
	CONTAINER_WIDTH = 192;
	CONTAINER_SPACING = 0;
	VISIBLE_CONTAINER_SPACING = 3;
	MINIMUM_CONTAINER_OFFSET_X = 10;
	CONTAINER_SCALE = 0.75;
	BACKPACK_MONEY_OFFSET_DEFAULT = -231;
	BACKPACK_MONEY_HEIGHT_OFFSET_PER_EXTRA_ROW = 41;
	BACKPACK_BASE_HEIGHT = 255;
	BACKPACK_HEIGHT_OFFSET_PER_EXTRA_ROW = 43;
	BACKPACK_DEFAULT_TOPHEIGHT = 255;
	BACKPACK_EXTENDED_TOPHEIGHT = 226;
	BACKPACK_BASE_SIZE = 16;
	FIRST_BACKPACK_BUTTON_OFFSET_BASE = -225;
	FIRST_BACKPACK_BUTTON_OFFSET_PER_EXTRA_ROW = 41;
	CONTAINER_BOTTOM_TEXTURE_DEFAULT_HEIGHT = 10;
	CONTAINER_BOTTOM_TEXTURE_DEFAULT_TOP_COORD = 0.330078125;
	CONTAINER_BOTTOM_TEXTURE_DEFAULT_BOTTOM_COORD = 0.349609375;
end
