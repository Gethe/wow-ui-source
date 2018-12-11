
MapUtil = {};

function MapUtil.IsMapTypeZone(mapID)
	local mapInfo = C_Map.GetMapInfo(mapID);
	return mapInfo and mapInfo.mapType == Enum.UIMapType.Zone;
end

function MapUtil.GetMapParentInfo(mapID, mapType, topMost)
	local candidate;
	local mapInfo = C_Map.GetMapInfo(mapID);
	while mapInfo do
		if ( mapInfo.mapType == mapType ) then
			if ( topMost ) then
				candidate = mapInfo;
			else
				return mapInfo;
			end
		end
		mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
	end
	return candidate;
end

function MapUtil.ShouldMapTypeShowQuests(mapType)
	return mapType ~= Enum.UIMapType.World and mapType ~= Enum.UIMapType.Continent and mapType ~= Enum.UIMapType.Cosmic;
end

function MapUtil.ShouldShowTask(mapID, info)
	return (mapID == info.mapID) and HaveQuestData(info.questId);
end

function MapUtil.MapHasUnlockedBounties(mapID)
	local bounties, displayLocation, lockedQuestID = GetQuestBountyInfoForMapID(mapID);
	return displayLocation and not lockedQuestID and #bounties > 0;
end

function MapUtil.MapHasEmissaries(mapID)
	local bounties, displayLocation, lockedQuestID = GetQuestBountyInfoForMapID(mapID);
	return not not displayLocation;
end

function MapUtil.FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY)
	local exploredAreaIDs = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(mapID, CreateVector2D(normalizedCursorX, normalizedCursorY));
	if exploredAreaIDs then
		for i, areaID in ipairs(exploredAreaIDs) do
			local name = C_Map.GetAreaInfo(areaID);
			if name then
				return name;
			end
		end
	end
	return nil;
end

function MapUtil.GetDisplayableMapForPlayer()
	local mapID = C_Map.GetBestMapForUnit("player");
	if mapID then
		repeat
			if C_Map.MapHasArt(mapID) then
				return mapID;
			end
			local mapInfo = C_Map.GetMapInfo(mapID);
			mapID = mapInfo and mapInfo.parentMapID or 0;
		until mapID == 0;
	end
	return C_Map.GetFallbackWorldMapID();
end

function MapUtil.GetBountySetMaps(bountySetID)
	if not MapUtil.bountySetMaps then
		MapUtil.bountySetMaps = { };
	end
	local bountySetMaps = MapUtil.bountySetMaps[bountySetID];
	if not bountySetMaps then
		bountySetMaps = C_Map.GetBountySetMaps(bountySetID);
		MapUtil.bountySetMaps[bountySetID] = bountySetMaps;
	end
	return bountySetMaps;
end
