COLLECTIONS_FANFARE_ICON = "Interface/Icons/Item_Shop_GiftBox01";

function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	SetCVar("petJournalTab", tab);
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_GetTab(self)
	return PanelTemplates_GetSelectedTab(self);
end

local function ShouldShowHeirloomTabHelpTip()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB) then
		return false;
	end

	if PetJournal_HelpPlate and HelpPlate_IsShowing(PetJournal_HelpPlate) then
		return false;
	end

	return C_Heirloom.ShouldShowHeirloomHelp();
end

local function ShouldShowWardrobeTabHelpTip()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB) then
		return false;
	end

	if PetJournal_HelpPlate and HelpPlate_IsShowing(PetJournal_HelpPlate) then
		return false;
	end

	return true;
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
	if ( WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() ) then
		if ( selected == 5 ) then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame:SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	self:SetTitle(GetTitleText(selected));

    EventRegistry:TriggerEvent("CollectionsJournal.TabSet", CollectionsJournal, selected);

	HelpTip:HideAll(self);
	if ShouldShowHeirloomTabHelpTip() then
		local helpTipInfo = {
			text = HEIRLOOMS_JOURNAL_TUTORIAL_TAB,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetY = -7,
		};
		HelpTip:Show(self, helpTipInfo, CollectionsJournalTab4);
	elseif ShouldShowWardrobeTabHelpTip() then
		local helpTipInfo = {
			text = TRANSMOG_JOURNAL_TAB_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetY = -7,
		};
		HelpTip:Show(self, helpTipInfo, CollectionsJournalTab5);
	end
end

function CollectionsJournal_HideTabHelpTips()
	HelpTip:HideAll(CollectionsJournal);
end

function CollectionsJournal_OnShow(self)
	HideUIPanel(WardrobeFrame);
	MainMenuMicroButton_HideAlert(CollectionsMicroButton);
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
