function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	SetCVar("petJournalTab", tab);
	CollectionsJournal_UpdateSelectedTab(self);
end

local function ShouldShowHeirloomTabHelpTip()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB) then
		return false;
	end

	if PetJournal_HelpPlate and HelpPlate_IsShowing(PetJournal_HelpPlate) then
		return false;
	end

	for i = 1, C_Heirloom.GetNumHeirlooms() do
		local itemID = C_Heirloom.GetHeirloomItemIDFromIndex(i);
		if C_Heirloom.PlayerHasHeirloom(itemID) then
			return true;
		end
	end

	return false;
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = PanelTemplates_GetSelectedTab(self);

	MountJournal:SetShown(selected == 1);
	PetJournal:SetShown(selected == 2);
	ToyBox:SetShown(selected == 3);
	HeirloomsJournal:SetShown(selected == 4);

	if ( selected == 1 ) then
		CollectionsJournalTitleText:SetText(MOUNTS);
	elseif (selected == 2 ) then
		CollectionsJournalTitleText:SetText(PET_JOURNAL);
	elseif (selected == 3 ) then
		CollectionsJournalTitleText:SetText(TOY_BOX);
	elseif (selected == 4 ) then
		CollectionsJournalTitleText:SetText(HEIRLOOMS);
	end

	self.HeirloomTabHelpBox:SetShown(ShouldShowHeirloomTabHelpTip());
end

function CollectionsJournal_OnShow(self)
	CollectionsMicroButtonAlert:Hide();
	MicroButtonPulseStop(CollectionsMicroButton);

	PlaySound("igCharacterInfoOpen");
	CollectionsJournal_UpdateSelectedTab(self);
	UpdateMicroButtons();
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end
