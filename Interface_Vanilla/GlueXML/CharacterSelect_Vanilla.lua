-- These are purposely different for Classic Era and TBC
characterCopyRegions = {
	[81] = NORTH_AMERICA,
	[82] = KOREA,
	[83] = EUROPE,
	[84] = TAIWAN,
	[85] = CHINA,
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

	GlowEmitterFactory:Hide(CharSelectChangeRealmButton);
end



-- Global because of localization
tbcInfoPaneInfographicAtlas = "classic-announcementpopup-bcinfographic";
function TBCInfoPane_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	self.TBCInfoPaneDiagram:SetAtlas(tbcInfoPaneInfographicAtlas, true);
end

function TBCInfoPane_OnHide(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function TBCInfoPane_RefreshPrice()
	local formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
	if ( GetTBCInfoPanePriceEnabled() ) then
		formattedPrice = GetFormattedClonePrice();
	end

	local formatString = BURNING_CRUSADE_PREVIEW_DESCRIPTION2;
	if ( GetCurrentRegionName() == "CN" ) then
		formatString = BURNING_CRUSADE_PREVIEW_DESCRIPTION2_CN;
	end
	TBCInfoPane.TBCInfoPaneHTMLDesc:SetText(string.format(formatString, formattedPrice));
end

function TBCInfoPaneHTMLDesc_OnLoad(self)
	TBCInfoPane_RefreshPrice();
end

local cloneServiceProductId = 682
function GetFormattedClonePrice()
	local formattedPrice = SecureCurrencyUtil.GetFormattedPrice(cloneServiceProductId);

	if not formattedPrice then
		formattedPrice = BURNING_CRUSADE_TRANSITION_DEFAULT_PRICE;
	end

	return formattedPrice;
end

function ChoicePane_OnPlay()
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.LET_THE_GAMES_BEGIN);
		PlaySound(SOUNDKIT.UI_CHOICE_CLASSIC_ERA);
	else
		PlaySound(SOUNDKIT.UI_CHOICE_CLASSIC_ERA);
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
choicePaneCurrentLogoAtlas = "classic-burningcrusadetransition-choice-logo-classic";
choicePaneOtherLogoAtlas = "classic-burningcrusadetransition-choice-logo-bc";
function ChoicePane_OnShow(self)
	PlaySound(SOUNDKIT.UI_CHOICE_OPEN);

	local selectedCharName = GetCharacterInfo(GetCharacterSelection());
	ChoicePaneCurrentDesc:SetText(string.format(BURNING_CRUSADE_TRANSITION_CHOICE_CLASSIC_DESCRIPTION, selectedCharName, selectedCharName, GetFormattedClonePrice()));

	self.CurrentLogo:SetAtlas(choicePaneCurrentLogoAtlas);
	self.OtherLogo:SetAtlas(choicePaneOtherLogoAtlas);

	FitToParent(GlueParent, self);
end

function ChoiceConfirmation_OnConfirm(self)
	if (GetCVar("heardChoiceSFX") == "0") then
		PlaySound(SOUNDKIT.UI_CHOICE_ENTER_WORLD_MURLOC);
		SetCVar("heardChoiceSFX", 1);
	else
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD);
	end
    StopGlueAmbience();
	ChoiceConfirmation:Hide();
    EnterWorldWithTransitionChoice();
end
