
local SHADOWLANDS_CONTINENT_MAP_ID = 1550;
local ORIBOS_UI_MAP_IDS = { 1670, 1671, 1672, 1673 };


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
	if not HaveQuestData(info.questId) then
		return false;
	end
	-- callings are allowed on other maps if they are zone maps 
	if C_QuestLog.IsQuestCalling(info.questId) and MapUtil.IsMapTypeZone(mapID) then
		return true;
	end
	return mapID == info.mapID;
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

function MapUtil.IsChildMap(mapID, ancestorMapID)
	local mapInfo = C_Map.GetMapInfo(mapID);
	while (mapInfo ~= nil) and (mapInfo.parentMapID ~= nil) do
		if mapInfo.parentMapID == ancestorMapID then
			return true;
		end

		mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
	end

	return false;
end

function MapUtil.IsOribosMap(mapID)
	return tContains(ORIBOS_UI_MAP_IDS, mapID);
end

function MapUtil.IsShadowlandsZoneMap(mapID)
	if mapID == SHADOWLANDS_CONTINENT_MAP_ID or MapUtil.IsOribosMap(mapID) then
		return true;
	end

	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo.mapType ~= Enum.UIMapType.Zone) and (mapInfo.mapType ~= Enum.UIMapType.Continent) then
		return false;
	end

	return MapUtil.IsChildMap(mapID, SHADOWLANDS_CONTINENT_MAP_ID);
end

function MapUtil.MapShouldShowWorldQuestFilters(mapID)
	return MapUtil.MapHasEmissaries(mapID) or MapUtil.IsShadowlandsZoneMap(mapID);
end
