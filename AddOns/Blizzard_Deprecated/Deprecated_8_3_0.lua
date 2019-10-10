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
end