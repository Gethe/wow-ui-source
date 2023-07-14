
-- A note on naming:
-- Adventure Guide refers to the UI panel that contains:
-- C_AdventureJournal for the "suggested content" tab
-- C_EncounterJournal is for dungeons and raids tabs
-- C_PerksActivities is for traveler's log tab

AdventureGuideUtil = {};

function AdventureGuideUtil.IsAvailable()
	return not Kiosk.IsEnabled() and C_AdventureJournal.CanBeShown();
end

function AdventureGuideUtil.OpenHyperLink(tag, journalType, id, difficultyID)
	if not AdventureGuideUtil.IsAvailable() then
		return;
	end

	AdventureGuideUtil.OpenJournalLink(tonumber(journalType), tonumber(id), tonumber(difficultyID));
end

function AdventureGuideUtil.OpenJournalLink(journalType, id, difficultyID)
	if not EncounterJournal then
		EncounterJournal_LoadUI();
	end

	local instanceID, encounterID, sectionID, tierIndex = EJ_HandleLinkPath(journalType, id);
	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, nil, nil, tierIndex);
end

function AdventureGuideUtil.GetCurrentJournalInstance()
	local currentMapID = select(8, GetInstanceInfo());
	return currentMapID and C_EncounterJournal.GetInstanceForGameMap(currentMapID) or nil;
end

function AdventureGuideUtil.IsInInstance(journalInstanceID)
	local journalInstanceMapID = select(10, EJ_GetInstanceInfo(journalInstanceID));
	local currentMapID = select(8, GetInstanceInfo());
	return journalInstanceMapID == currentMapID;
end
