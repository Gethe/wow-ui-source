function AdventureMap_IsZoneIDBlockedByZoneChoice(mapID, zoneMapID)
	for choiceIndex = 1, C_AdventureMap.GetNumZoneChoices() do
		local questID, textureKit, name, zoneDescription, normalizedX, normalizedY = C_AdventureMap.GetZoneChoiceInfo(choiceIndex);
		if AdventureMap_IsQuestValid(questID, normalizedX, normalizedY) then
			local mapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedX, normalizedY);
			if mapInfo and mapInfo.mapID == zoneMapID then
				return true;
			end
		end
	end
	return false;
end

function AdventureMap_IsPositionBlockedByZoneChoice(mapID, normalizedX, normalizedY, insetIndex)
	if not insetIndex then
		local mapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedX, normalizedY);
		if mapInfo then
			return AdventureMap_IsZoneIDBlockedByZoneChoice(mapID, mapInfo.mapID);
		end
	end
	return false;
end

function AdventureMap_IsQuestValid(questID, normalizedX, normalizedY)
	return questID and not C_QuestLog.IsQuestFlaggedCompleted(questID) and normalizedX and normalizedY and not C_QuestLog.GetLogIndexForQuestID(questID);
end