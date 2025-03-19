COLLECTIONS_FANFARE_ICON = "Interface/Icons/Item_Shop_GiftBox01";

function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	SetCVar("petJournalTab", tab);
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_GetTab(self)
	return PanelTemplates_GetSelectedTab(self);
end

function CollectionsJournal_ValidateTab(tabNum)
	return true;
end

local titles =
{
	[1] = MOUNTS,
	[2] = PET_JOURNAL,
	[3] = TOY_BOX,
	[4] = HEIRLOOMS,
	[5] = WARDROBE,
};

local function GetTitleText(titleIndex)
	return titles[titleIndex] or "";
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = CollectionsJournal_GetTab(self);

	if (not CollectionsJournal_ValidateTab(selected)) then
		PanelTemplates_SetTab(self, 1);
		selected = 1;
	end

	MountJournal:SetShown(selected == 1);
	PetJournal:SetShown(selected == 2);
	ToyBox:SetShown(selected == 3);
	HeirloomsJournal:SetShown(selected == 4);

	-- don't touch the wardrobe frame if it's used by the transmogrifier
	if ( WardrobeCollectionFrame and WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() ) then
		if ( selected == 5 ) then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame:SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	self:SetTitle(GetTitleText(selected));

    EventRegistry:TriggerEvent("CollectionsJournal.TabSet", CollectionsJournal, selected);
end

function CollectionsJournal_HideTabHelpTips()
	HelpTip:HideAll(CollectionsJournal);
end

function CollectionsJournal_OnShow(self)
	HideUIPanel(WardrobeFrame);
	MicroButtonPulseStop(CollectionsMicroButton);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	CollectionsJournal_UpdateSelectedTab(self);
	UpdateMicroButtons();
end

function CollectionsJournal_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	CollectionsMicroButton:EvaluateAlertVisibility();
end