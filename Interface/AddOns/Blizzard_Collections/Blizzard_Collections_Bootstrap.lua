local AddonName = ...;

function CollectionsJournal_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS = 1;
COLLECTIONS_JOURNAL_TAB_INDEX_PETS = COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_TOYS = COLLECTIONS_JOURNAL_TAB_INDEX_PETS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS = COLLECTIONS_JOURNAL_TAB_INDEX_TOYS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES = COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_WARBAND_SCENES = COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES + 1;

function ToggleCollectionsJournal(tabIndex)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CollectionsPanelDisabled) then
		if CollectionsJournal and CollectionsJournal:IsShown() then
			HideUIPanel(CollectionsJournal);
		end
		return;
	end

	if CollectionsJournal or CollectionsJournal_LoadUI() then
		local tabMatches = not tabIndex or tabIndex == PanelTemplates_GetSelectedTab(CollectionsJournal);
		local isShown = CollectionsJournal:IsShown() and tabMatches;
		SetCollectionsJournalShown(not isShown, tabIndex);
	end
end

function SetCollectionsJournalShown(shown, tabIndex)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CollectionsPanelDisabled) then
		if not shown and CollectionsJournal then
			HideUIPanel(CollectionsJournal);
		end
		return;
	end

	if CollectionsJournal_LoadUI() then
		if shown then
			ShowUIPanel(CollectionsJournal);
			if tabIndex then
				CollectionsJournal_SetTab(CollectionsJournal, tabIndex);
			end
		else
			HideUIPanel(CollectionsJournal);
		end
	end
end

function ToggleToyCollection(autoPageToCollectedToyID)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CollectionsPanelDisabled) then
		return;
	end

	if CollectionsJournal_LoadUI() then
		ToyBox.autoPageToCollectedToyID = autoPageToCollectedToyID;
		SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
	end
end

function ShowHeirloomsJournalToClosestUpgradeablePage()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CollectionsPanelDisabled) then
		return;
	end

	if CollectionsJournal_LoadUI() then
		HeirloomsJournal:SetFindClosestUpgradeablePage(true);
		SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS);
	end
end
