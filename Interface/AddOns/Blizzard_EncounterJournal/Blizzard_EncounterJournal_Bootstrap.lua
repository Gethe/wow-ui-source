local AddonName = ...;

function EncounterJournal_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function CanShowEncounterJournal()
	return AdventureGuideUtil.IsAvailable();
end

function ToggleEncounterJournal()
	if EncounterJournal_LoadUI() then
		ToggleFrame(EncounterJournal);
		return true;
	end
	return false;
end

function OpenEncounterJournalToJourney(factionID)
	if EncounterJournal_LoadUI() then
		EncounterJournal_OpenToJourney(factionID);
	end
end

function OpenEncounterJournalToTieredEntrance(instanceID, difficultyID)
	if EncounterJournal_LoadUI() then
		EncounterJournal_OpenToTieredEntrance(instanceID, difficultyID);
	end
end

local function ShowAdventureJournal()
	if C_AdventureJournal.CanBeShown() then
		ShowUIPanel(EncounterJournal);
		EJSuggestFrame_OpenFrame();
	end
end

local function ShowMajorFactionRenown()
	local majorFactionID = C_MajorFactions.GetRenownNPCFactionID();
	HideUIPanel(EncounterJournal);
	if majorFactionID > 0 then
		ShowUIPanel(EncounterJournal);
		EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID());
		EncounterJournalJourneysFrame:ResetView(nil, majorFactionID);
	end
end

local function RegisterWithPlayerInteractionManager()
	RegisterPlayerInteraction(Enum.PlayerInteractionType.AdventureJournal,
		{
			frame = "EncounterJournal",
			loadFunc = EncounterJournal_LoadUI,
			showFunc = ShowAdventureJournal,
		});

	RegisterPlayerInteraction(Enum.PlayerInteractionType.MajorFactionRenown,
		{
			frame = "EncounterJournal",
			loadFunc = EncounterJournal_LoadUI,
			showFunc = ShowMajorFactionRenown,
		});
end

RegisterWithPlayerInteractionManager();
