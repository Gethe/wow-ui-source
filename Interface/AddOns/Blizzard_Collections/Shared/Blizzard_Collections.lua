COLLECTIONS_FANFARE_ICON = "Interface/Icons/Item_Shop_GiftBox01";

function CollectionsJournal_ClickTab(self)
	CollectionsJournal_SetTab(CollectionsJournal, self:GetID());
	PlaySound(SOUNDKIT.UI_TOYBOX_TABS);
end

function CollectionsJournal_SetTab(self, tab)
	CollectionsJournal_SetTab_Internal(self.TabContainer, tab);
	SetCVar("petJournalTab", tab);
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_GetTab(self)
	return CollectionsJournal_GetTab_Internal(self.TabContainer);
end

function CollectionsJournal_ValidateTab(tabIndex)
	-- if individual Collections are disabled, don't bother showing their tab
	if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS then
		return C_HeirloomInfo.HeirloomsAvailable() and not PlayerIsTimerunning();
	end

	if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_WARBAND_SCENES then
		return C_WarbandScene.WarbandScenesAvailable();
	end
	
	if C_CVar.GetCVarBool("onlyShowCollectedItemsInJournal") then
		if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS then
			return C_MountJournal.HasDisplayableMount();
		end

		if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_PETS then
			return select(2, C_PetJournal.GetNumPets()) > 0;
		end

		if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_TOYS then
			return C_ToyBoxInfo.HasAnyToy();
		end

		if tabIndex == COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES then
			return C_TransmogCollection.HasAnyAppearance();
		end
	end

	return true;
end

-- Start tab (PanelTabButtonTemplate) wrappers --

function CollectionsJournal_SetTab_Internal(tabContainer, tab)
	PanelTemplates_SetTab(tabContainer, tab);
end

function CollectionsJournal_GetTab_Internal(tabContainer)
	return PanelTemplates_GetSelectedTab(tabContainer);
end

function CollectionsJournal_ShowTab_Internal(tabContainer, tabID)
	PanelTemplates_ShowTab(tabContainer, tabID);
end

function CollectionsJournal_HideTab_Internal(tabContainer, tabID)
	PanelTemplates_HideTab(tabContainer, tabID);
end

function CollectionsJournal_SetNumTabs_Internal(tabContainer, numTabs)
	PanelTemplates_SetNumTabs(tabContainer, numTabs);
end

-- End tab (PanelTabButtonTemplate) wrappers --

CollectionsJournalMixin =
{
	TABS_DATA = {
		[1] = { title = MOUNTS, icon = "Interface/ICONS/INV_Horse3Saddle008_Chestnut.blp"},
		[2] = { title = PET_JOURNAL, icon = "Interface/ICONS/INV_ArfusPet_Classic.blp"},
		[3] = { title = TOY_BOX, icon = "Interface/ICONS/INV_SideTab_ToyBox_c60.blp"},
		[4] = { title = HEIRLOOM, icon = "Interface/ICONS/INV_Misc_Bag_EnchantedRunecloth.blp"},
		[5] = { title = WARDROBE, icon = "Interface/ICONS/UI_Transmog_ShowEquippedGear.BLP"},
		[6] = { title = WARBAND_SCENES, icon = "Interface/ICONS/UI_CampCollection.blp"},
	}
};

function CollectionsJournalMixin:GetPageTitleText(tabID)
	return self.TABS_DATA[tabID].title or "";
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selectedID = CollectionsJournal_GetTab(self);

	if (not CollectionsJournal_ValidateTab(selectedID)) then
		-- find first valid tab to display
		for i, tab in ipairs(CollectionsJournal.TabContainer.Tabs) do
			if CollectionsJournal_ValidateTab(tab:GetID()) then
				CollectionsJournal_SetTab_Internal(self, i);
				selectedID = i;
				break;
			end
		end
	end

	MountJournal:SetShown(selectedID == 1);
	PetJournal:SetShown(selectedID == 2);
	ToyBox:SetShown(selectedID == 3);
	HeirloomsJournal:SetShown(selectedID == 4);
	WardrobeCollectionFrame:SetShown(selectedID == 5);
	WarbandSceneJournal:SetShown(selectedID == 6);

	self:SetTitle(self:GetPageTitleText(selectedID));

	EventRegistry:TriggerEvent("CollectionsJournal.TabSet", CollectionsJournal.TabContainer, selectedID);
end

function CollectionsJournal_HideTabHelpTips()
	HelpTip:HideAll(CollectionsJournal.TabContainer);
end

function CollectionsJournal_CheckAndDisplayTabs()
	local previousShownTab = nil;
	for i, tab in ipairs(CollectionsJournal.TabContainer.Tabs) do
		if CollectionsJournal_ValidateTab(tab:GetID()) then
			CollectionsJournal_ShowTab_Internal(CollectionsJournal.TabContainer, tab:GetID());

			tab:ClearAllPoints();
			if previousShownTab then
				if(BLIZZARD_COLLECTIONS_TAB_STYLE == BLIZZARD_COLLECTIONS_TAB_STYLE_SIDE) then
					tab:SetPoint("TOPLEFT", previousShownTab, "BOTTOMLEFT", 0, -2);
				else
					tab:SetPoint("LEFT", previousShownTab, "RIGHT", 3, 0);
				end
			else
				if(BLIZZARD_COLLECTIONS_TAB_STYLE == BLIZZARD_COLLECTIONS_TAB_STYLE_SIDE) then
					tab:SetPoint("TOPLEFT", CollectionsJournal.TabContainer, "TOPLEFT", 0, -60);
				else
					tab:SetPoint("TOPLEFT", CollectionsJournal.TabContainer, "TOPLEFT", 11, 2);
				end
			end

			previousShownTab = tab;
		else
			CollectionsJournal_HideTab_Internal(CollectionsJournal.TabContainer, tab:GetID());
		end
	end
end

-- overridden
function CollectionsJournalMixin:SetupTabs()
end

function CollectionsJournal_OnLoad(self)
	self:SetTitle(COLLECTIONS);
	self:SetupTabs();
	CollectionsJournal_SetNumTabs_Internal(self.TabContainer, #self.TabContainer.Tabs);
	CollectionsJournal_SetTab_Internal(self.TabContainer, tonumber(GetCVar("petJournalTab")) or 1);
end

function CollectionsJournal_OnShow(self)
	MainMenuMicroButton_HideAlert(CollectionsMicroButton);
	MicroButtonPulseStop(CollectionsMicroButton);

	CollectionsJournal_CheckAndDisplayTabs();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	CollectionsJournal_UpdateSelectedTab(self);
	UpdateMicroButtons();

	-- trigger with selected tab
	EventRegistry:TriggerEvent("CollectionsJournal.OnShow", CollectionsJournal_GetTab(self));
end

function CollectionsJournal_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	CollectionsMicroButton:EvaluateAlertVisibility();

	EventRegistry:TriggerEvent("CollectionsJournal.OnHide", CollectionsJournal_GetTab(self));
end
