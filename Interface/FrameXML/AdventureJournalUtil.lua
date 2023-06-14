
AdventureJournalUtil = {};

function AdventureJournalUtil.IsAvailable()
	return not Kiosk.IsEnabled() and C_AdventureJournal.CanBeShown();
end

function AdventureJournalUtil.OpenHyperLink(tag, journalType, id, difficultyID)
	if not AdventureJournalUtil.IsAvailable() then
		return;
	end

	AdventureJournalUtil.OpenJournalLink(tonumber(journalType), tonumber(id), tonumber(difficultyID));
end

function AdventureJournalUtil.OpenJournalLink(journalType, id, difficultyID)
	if not EncounterJournal then
		EncounterJournal_LoadUI();
	end

	local instanceID, encounterID, sectionID, tierIndex = EJ_HandleLinkPath(journalType, id);
	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, nil, nil, tierIndex);
end
