
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
	if (info.isQuestStart and info.inProgress) then
		return false
	end
	return (mapID == info.mapID) and HaveQuestData(info.questId);
end

function MapUtil.MapHasUnlockedBounties(mapID)
	local displayLocation, lockedQuestID, bountySetID = C_QuestLog.GetBountySetInfoForMapID(mapID);
	if displayLocation and (not lockedQuestID or not C_QuestLog.IsOnQuest(lockedQuestID)) then
		local bounties = C_QuestLog.GetBountiesForMapID(mapID);
		return bounties and #bounties > 0;
	end

	return false;
end

function MapUtil.MapHasEmissaries(mapID)
	local displayLocation, lockedQuestID, bountySetID = C_QuestLog.GetBountySetInfoForMapID(mapID);
	return displayLocation ~= nil;
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

function MapUtil.GetMapCenterOnMap(mapID, topMapID)
	local left, right, top, bottom = C_Map.GetMapRectOnMap(mapID, topMapID);
	if left == nil then
		return nil, nil;
	end

	local centerX = left + (right - left) * .5;
	local centerY = top + (bottom - top) * .5;
	return centerX, centerY;
end
