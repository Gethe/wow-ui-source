DragonridingUtil = {};

function DragonridingUtil.IsDragonridingUnlocked()
	return C_MountJournal.IsDragonridingUnlocked();
end

function DragonridingUtil.IsDragonridingTreeOpen()
	if not GenericTraitFrame or not GenericTraitFrame:IsShown()then
		return false;
	end

	return GenericTraitFrame:GetConfigID() == C_Traits.GetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
end

function DragonridingUtil.CanSpendDragonridingGlyphs()
	if not DragonridingUtil.IsDragonridingUnlocked() then
		return false;
	end

	local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
	if not dragonridingConfigID then
		return false;
	end
	
	local excludeStagedChanges = false;
	local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, Constants.MountDynamicFlightConsts.TREE_ID, excludeStagedChanges);
	if #treeCurrencies <= 0 then
		return false;
	end

	local unspentGlyphCount = treeCurrencies[1].quantity;
	local hasUnspentDragonridingGlyphs = unspentGlyphCount > 0;
	if not hasUnspentDragonridingGlyphs then
		return false;
	end

	-- We have unspent glyphs, but can we actually purchase something?
	local dragonridingNodeIDs = C_Traits.GetTreeNodes(Constants.MountDynamicFlightConsts.TREE_ID);
	for _, nodeID in ipairs(dragonridingNodeIDs) do
		local nodeCosts = C_Traits.GetNodeCost(dragonridingConfigID, nodeID);
		local canAffordNode = (#nodeCosts == 0) or (unspentGlyphCount >= nodeCosts[1].amount);
		if canAffordNode then
			-- Some nodes give you multiple choices and let you pick one, let's see if you can purchase any of them
			local nodeInfo = C_Traits.GetNodeInfo(dragonridingConfigID, nodeID);
			for _, entryID in ipairs(nodeInfo.entryIDs) do
				if C_Traits.CanPurchaseRank(dragonridingConfigID, nodeID, entryID) then
					-- We can spend our glyphs on something!
					return true;
				end
			end
		end
	end

	return false;
end
