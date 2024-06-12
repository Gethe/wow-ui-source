CharacterSelectNavBarButtonMixin = {};

function CharacterSelectNavBarButtonMixin:OnEnter()
	self.Highlight:Show();

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = true;
		self:formatButtonTextCallback(enabled, highlight);
	end
end

function CharacterSelectNavBarButtonMixin:OnLeave()
	self.Highlight:Hide();

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = false;
		self:formatButtonTextCallback(enabled, highlight);
	end
end


CharacterSelectNavBarMixin = {
	NavBarBackdropWidthBuffer = 270,
	NavBarButtonWidthBuffer = 70,
};

function CharacterSelectNavBarMixin:OnLoad()
	local function NavBarButtonSetup(newButton, label, controlCallback)
		newButton:SetText(label);
		newButton:SetWidth(newButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);
		newButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			controlCallback();
		end);
	end

	self.ButtonTray:SetButtonSetup(NavBarButtonSetup);

	local function CreateCharacterClicked()
		if not CharacterSelect_ShowTimerunningChoiceWhenActive() then
			CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal);
		end
	end

	local createCharacterCallback = CreateCharacterClicked;
	local realmsCallback = GenerateFlatClosure(CharacterSelectUtil.ChangeRealm);


	self.StoreButton = self.ButtonTray:AddControl(nil, ToggleStoreUI);
	self.MenuButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
	self.CreateCharacterButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_CREATE_CHARACTER, createCharacterCallback);
	self.RealmsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);

	-- Any specific button setups.
	self:SetButtonVisuals();

	self:RegisterEvent("CHARACTER_LIST_UPDATE");
	self:RegisterEvent("TIMERUNNING_SEASON_UPDATE");

	-- Rebuild to get valid width calculation in time.
	self.ButtonTray:Layout();
	local totalWidth = CharacterSelectNavBarMixin.NavBarBackdropWidthBuffer + self.ButtonTray:GetWidth();
	self.Backdrop:SetWidth(totalWidth);

	-- This event handler can only be added after the parent's OnLoad has run.
	RunNextFrame(function ()
		local characterSelectUI = self:GetParent();
		self:AddDynamicEventMethod(characterSelectUI, CharacterSelectUIMixin.Event.ExpansionTrialStateUpdated, CharacterSelectNavBarMixin.OnExpansionTrialStateUpdated);
	end);
end

function CharacterSelectNavBarMixin:OnEvent(event, ...)
	if event == "CHARACTER_LIST_UPDATE" then
		CharacterLoginUtil.EvaluateNewAlliedRaces();
		self:EvaluateCreateCharacterNewState();
	elseif event == "TIMERUNNING_SEASON_UPDATE" then
		self:EvaluateCreateCharacterTimerunningState();
	end
end

function CharacterSelectNavBarMixin:SetButtonVisuals()
	-- Do not show divider bar on rightmost option.
	self.RealmsButton.Bar:Hide();

	-- The leftmost and rightmost buttons in the nav bar have different highlight textures than the default.
	self.StoreButton.Highlight:ClearAllPoints();
	self.StoreButton.Highlight:SetPoint("TOPLEFT", -45, 0);
	self.StoreButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 5);
	self.StoreButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	self.StoreButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-left", TextureKitConstants.IgnoreAtlasSize);

	self.RealmsButton.Highlight:ClearAllPoints();
	self.RealmsButton.Highlight:SetPoint("TOPLEFT", 0, 0);
	self.RealmsButton.Highlight:SetPoint("BOTTOMRIGHT", 45, 5);
	self.RealmsButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-right", TextureKitConstants.IgnoreAtlasSize);
	self.RealmsButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-right", TextureKitConstants.IgnoreAtlasSize);

	-- The store button has a custom icon that must match the text state.
	local function FormatStoreButtonText(self, enabled, highlight)
		local shopIcon = "glues-characterselect-iconshop";
		if not enabled then
			shopIcon = "glues-characterselect-iconshop-dis";
		elseif highlight then
			shopIcon = "glues-characterselect-iconshop-hover";
		end
		self:SetText(CreateAtlasMarkup(shopIcon, 24, 24, -4)..CHARACTER_SELECT_NAV_BAR_SHOP);
	end
	self.StoreButton.formatButtonTextCallback = FormatStoreButtonText;

	local enabled = true;
	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);
	self.StoreButton:SetWidth(self.StoreButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);

	-- Character create button has some unique logic, set that up separately.
	self:InitCreateCharacterButton();
end

function CharacterSelectNavBarMixin:InitCreateCharacterButton()
	self.CreateCharacterButton:SetScript("OnEnter", function()
		self.CreateCharacterButton:OnEnter();

		GlueTooltip:SetOwner(self.CreateCharacterButton, "ANCHOR_BOTTOM");
		GameTooltip_SetTitle(GlueTooltip, CHARACTER_SELECT_NAV_BAR_CREATE_CHARACTER_TOOLTIP:format(CharacterSelectUtil.GetFormattedCurrentRealmName()));
		GlueTooltip:Show();
	end);

	self.CreateCharacterButton:SetScript("OnLeave", function()
		self.CreateCharacterButton:OnLeave();

		GlueTooltip:Hide();
	end);

	local newFeatureFrame = CreateFrame("Frame", nil, self.CreateCharacterButton, "NewFeatureLabelNoAnimateTemplate");
	newFeatureFrame:SetPoint("TOPLEFT", 18, -8);
	self.CreateCharacterButton.NewFeatureFrame = newFeatureFrame;
	self.CreateCharacterButton.NewFeatureFrame:Hide();

	local createCharacterGlow = CreateFrame("Frame", nil, self.CreateCharacterButton, "CharacterCreateTimerunningGlowTemplate");
	createCharacterGlow:SetPoint("BOTTOM", 0, -40);
	self.CreateCharacterButton.CreateCharacterGlow = createCharacterGlow;
	self:EvaluateCreateCharacterTimerunningState();
end

-- Multiple things can trigger the 'new' text on the create character button, ensure that we show it if any pass.
function CharacterSelectNavBarMixin:EvaluateCreateCharacterNewState()
	local isNew = self.isExpansionTrial or CharacterLoginUtil.HasNewAlliedRaces();
	self.CreateCharacterButton.NewFeatureFrame:SetShown(isNew);
end

function CharacterSelectNavBarMixin:EvaluateCreateCharacterTimerunningState()
	local showTimerunning = GetActiveTimerunningSeasonID() ~= nil;
	self.CreateCharacterButton.CreateCharacterGlow:SetShown(showTimerunning);
end

function CharacterSelectNavBarMixin:OnExpansionTrialStateUpdated(isExpansionTrial)
	self.isExpansionTrial = isExpansionTrial;
	self:EvaluateCreateCharacterNewState();
end

function CharacterSelectNavBarMixin:SetCharacterCreateButtonEnabled(enabled)
	self.CreateCharacterButton:SetEnabled(enabled);
end

function CharacterSelectNavBarMixin:SetStoreButtonEnabled(enabled)
	self.StoreButton:SetEnabled(enabled);

	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);
end

function CharacterSelectNavBarMixin:SetMenuButtonEnabled(enabled)
	self.MenuButton:SetEnabled(enabled);
end

function CharacterSelectNavBarMixin:SetRealmsButtonEnabled(enabled)
	self.RealmsButton:SetEnabled(enabled);
end
