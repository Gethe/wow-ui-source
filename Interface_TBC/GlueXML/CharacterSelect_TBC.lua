-- These are purposely different for Classic Era and TBC
characterCopyRegions = {
	[41] = NORTH_AMERICA,
	[42] = KOREA,
	[43] = EUROPE,
	[44] = TAIWAN,
	[45] = CHINA,
};

function CharacterSelect_OnHide(self)
    -- the user may have gotten d/c while dragging
    if ( CharacterSelect.draggedIndex ) then
        local button = _G["CharSelectCharacterButton"..(CharacterSelect.draggedIndex - CHARACTER_LIST_OFFSET)];
        CharacterSelectButton_OnDragStop(button);
    end
    CharacterSelect_SaveCharacterOrder();
    CharacterDeleteDialog:Hide();
    CharacterRenameDialog:Hide();
    AccountReactivate_CloseDialogs();

    if ( DeclensionFrame ) then
        DeclensionFrame:Hide();
    end

    PromotionFrame_Hide();
    C_AuthChallenge.Cancel();
    if ( StoreFrame ) then
        StoreFrame:Hide();
    end
    CopyCharacterFrame:Hide();
    if ( AddonDialog:IsShown() ) then
        AddonDialog:Hide();
        HasShownAddonOutOfDateDialog = false;
    end

    if ( self.undeleting ) then
        CharacterSelect_EndCharacterUndelete();
    end

    if ( CharSelectServicesFlowFrame:IsShown() ) then
        CharSelectServicesFlowFrame:Hide();
    end
	
	SocialContractFrame:Hide();

    AccountReactivate_CloseDialogs();
    SetInCharacterSelect(false);
end

-- Global because of localization
tbcInfoPaneInfographicAtlas = "classic-announcementpopup-bcinfographic";
function TBCInfoPane_OnShow(self)
	self.TBCInfoPaneDiagram:SetAtlas(tbcInfoPaneInfographicAtlas, true);
end

function TBCInfoPane_RefreshPrice()
	if( BURNING_CRUSADE_PREVIEW_DESCRIPTION2 ) then
		local formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
		if ( GetTBCInfoPanePriceEnabled() ) then
			formattedPrice = GetFormattedClonePrice();
		end

		TBCInfoPane.TBCInfoPaneHTMLDesc:SetText(string.format(BURNING_CRUSADE_PREVIEW_DESCRIPTION2, formattedPrice));
	end
end

function TBCInfoPaneHTMLDesc_OnLoad(self)
	TBCInfoPane_RefreshPrice();
end

local cloneServiceProductId = 679
function GetFormattedClonePrice()
	local formattedPrice = SecureCurrencyUtil.GetFormattedPrice(cloneServiceProductId);

	if not formattedPrice then
		formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
	end

	return formattedPrice;
end

function ChoicePane_OnPlay()
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.YOU_ARE_NOT_PREPARED);
	else
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	end
	ChoiceConfirmation:Show();
	ChoicePane:Hide();
end

function ChoicePane_OnExitGame()
	CharacterSelect_SaveCharacterOrder();
	QuitGame();
end

function ChoicePane_Toggle()
	ChoicePane:SetShown(not ChoicePane:IsShown());
end

-- Global because of localization
choicePaneCurrentLogoAtlas = "classic-burningcrusadetransition-choice-logo-current";
choicePaneOtherLogoAtlas = "classic-burningcrusadetransition-choice-logo-other";
function ChoicePane_OnShow(self)
	PlaySound(SOUNDKIT.JEWEL_CRAFTING_FINALIZE);

	local selectedCharName = GetCharacterInfo(GetCharacterSelection());
	ChoicePaneCurrentDesc:SetText(string.format(BURNING_CRUSADE_TRANSITION_CHOICE_CURRENT_DESCRIPTION, selectedCharName, selectedCharName, GetFormattedClonePrice()));

	self.CurrentLogo:SetAtlas(choicePaneCurrentLogoAtlas);
	self.OtherLogo:SetAtlas(choicePaneOtherLogoAtlas);

	FitToParent(GlueParent, self);
end

function ChoiceConfirmation_OnConfirm(self)
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.FELREAVER);
		SetCVar("heardChoiceSFX", 1);
	else
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	end
    StopGlueAmbience();
	ChoiceConfirmation:Hide();
    EnterWorldWithTransitionChoice();
end

