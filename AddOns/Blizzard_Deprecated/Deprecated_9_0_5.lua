
-- These are functions that were deprecated in 9.0.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Chat API Update
do
	IsActivePlayerMentor = IsActivePlayerGuide;
end

-- GuildInfo API Update
do
	QueryGuildMembersForRecipe = C_GuildInfo.QueryGuildMembersForRecipe;
end

-- WorldMap
do
	function WorldMap_AddQuestTimeToTooltip(questID)
		GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);
	end
end

-- Conduits: Use C_Soulbinds.GetConduitCollectionData to get the item level the player currently knows for conduitID
-- Querying the item level for an arbitrary conduit rank is no longer exposed
do
	function C_Soulbinds.GetConduitItemLevel(conduitID, rank)
		local collectionData = C_Soulbinds.GetConduitCollectionData(conduitID);
		if collectionData  then
			return collectionData.conduitItemLevel;
		else
			return 0;
		end
	end
end