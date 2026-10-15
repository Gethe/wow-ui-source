
-- Override
function WardrobeCollectionFrameMixin:InitItemsFilterButtonSetupMenu(dropdown, rootDescription, CreateSourceFilters)
	rootDescription:SetTag("MENU_WARDROBE_FILTER");

	rootDescription:CreateCheckbox(COLLECTED, C_TransmogCollection.GetCollectedShown, function()
		C_TransmogCollection.SetCollectedShown(not C_TransmogCollection.GetCollectedShown());
	end);

	rootDescription:CreateCheckbox(NOT_COLLECTED, C_TransmogCollection.GetUncollectedShown, function()
		C_TransmogCollection.SetUncollectedShown(not C_TransmogCollection.GetUncollectedShown());
	end);

	rootDescription:CreateCheckbox(TRANSMOG_SHOW_ALL_FACTIONS, C_TransmogCollection.GetAllFactionsShown, function()
		C_TransmogCollection.SetAllFactionsShown(not C_TransmogCollection.GetAllFactionsShown());
	end);

	rootDescription:CreateCheckbox(TRANSMOG_SHOW_ALL_RACES, C_TransmogCollection.GetAllRacesShown, function()
		C_TransmogCollection.SetAllRacesShown(not C_TransmogCollection.GetAllRacesShown());
	end);

	local submenu = rootDescription:CreateButton(SOURCES);
	CreateSourceFilters(submenu);
end

-- Override
function WardrobeItemsCollectionMixin:SetProgressBarVisibility(category)
	WardrobeCollectionFrame.progressBar:SetShown(not TransmogUtil.IsCategoryLegionArtifact(category));
end

-- Override
function WardrobeSetsCollectionMixin:SetProgressBarVisibility(show)
	WardrobeCollectionFrame.progressBar:SetShown(show);
end

-- Override
function WardrobeItemsCollectionMixin:OverrideDefaults()
	self.slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", self.defaultSectionSpacing, "hands", "waist", "legs", "feet", self.defaultSectionSpacing, "mainhand", self.spacingWithSmallButton, "secondaryhand" };
end
