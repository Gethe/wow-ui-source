
-- Override
function WardrobeCollectionFrameMixin:InitItemsFilterButtonSetupMenu(dropdown, rootDescription, CreateSourceFilters)
	-- In Camelot we dont want to show uncollected appearances
	C_TransmogCollection.SetUncollectedShown(false);
	C_TransmogCollection.SetCollectedShown(true);

	-- Given that we dont need to filter by race / faction and are hiding uncollected appearances
	-- we can directly show the source options instead of them being a sub menu
	CreateSourceFilters(rootDescription);
end

-- Override
function WardrobeItemsCollectionMixin:SetProgressBarVisibility(category)
	WardrobeCollectionFrame.progressBar:SetShown(false);
end

-- Override
function WardrobeSetsCollectionMixin:SetProgressBarVisibility(show)
	WardrobeCollectionFrame.progressBar:SetShown(false);
end

-- Override
function WardrobeItemsCollectionMixin:OverrideDefaults()
	self.defaultSectionSpacing = 19;
	self.slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", self.defaultSectionSpacing, "hands", "waist", "legs", "feet", self.defaultSectionSpacing, "mainhand", "secondaryhand", "ranged" };
end

