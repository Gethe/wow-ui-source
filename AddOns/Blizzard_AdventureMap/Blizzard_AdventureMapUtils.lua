function AdventureMap_IsZoneIDBlockedByZoneChoice(mapID, zoneMapID)
	for choiceIndex = 1, C_AdventureMap.GetNumZoneChoices() do
		local questID, name, zoneDescription, normalizedX, normalizedY = C_AdventureMap.GetZoneChoiceInfo(choiceIndex);
		if AdventureMap_IsQuestValid(questID, normalizedX, normalizedY) then
			if C_MapCanvas.FindZoneAtPosition(mapID, normalizedX, normalizedY) == zoneMapID then
				return true;
			end
		end
	end
	return false;
end

function AdventureMap_IsPositionBlockedByZoneChoice(mapID, normalizedX, normalizedY, insetIndex)
	if not insetIndex then
		local zoneMapID = C_MapCanvas.FindZoneAtPosition(mapID, normalizedX, normalizedY);
		if zoneMapID then
			return AdventureMap_IsZoneIDBlockedByZoneChoice(mapID, zoneMapID);
		end
	end
	return false;
end

function AdventureMap_IsQuestValid(questID, normalizedX, normalizedY)
	return questID and not IsQuestFlaggedCompleted(questID) and normalizedX and normalizedY and GetQuestLogIndexByID(questID) == 0;
end