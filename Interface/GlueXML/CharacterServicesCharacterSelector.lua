local function disableScripts(button)
	button:SetScript("OnClick", nil);
	button:SetScript("OnDoubleClick", nil);
	button:SetScript("OnDragStart", nil);
	button:SetScript("OnDragStop", nil);
	button:SetScript("OnMouseDown", nil);
	button:SetScript("OnMouseUp", nil);
	button.upButton:SetScript("OnClick", nil);
	button.downButton:SetScript("OnClick", nil);
	button:SetScript("OnEnter", nil);
	button:SetScript("OnLeave", nil);
end

local function resetScripts(button)
	button:SetScript("OnClick", CharacterSelectButton_OnClick);
	button:SetScript("OnDoubleClick", CharacterSelectButton_OnDoubleClick);
	button:SetScript("OnDragStart", CharacterSelectButton_OnDragStart);
	button:SetScript("OnDragStop", CharacterSelectButton_OnDragStop);
	-- Functions here copied from CharacterSelect.xml
	button:SetScript("OnMouseDown", function(self)
		CharacterSelect.pressDownButton = self;
		CharacterSelect.pressDownTime = 0;
	end);
	button.upButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local index = self:GetParent().index;
		MoveCharacter(index, index - 1);
	end);
	button.downButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local index = self:GetParent().index;
		MoveCharacter(index, index + 1);
	end);
	button:SetScript("OnEnter", function(self)
		if ( self.selection:IsShown() ) then
			CharacterSelectButton_ShowMoveButtons(self);
		end
		if ( self.isVeteranLocked ) then
			GlueTooltip:SetText(CHARSELECT_CHAR_LIMITED_TOOLTIP, nil, nil, nil, nil, true);
			GlueTooltip:Show();
			GlueTooltip:SetOwner(self, "ANCHOR_LEFT", -16, -5);
			CharSelectAccountUpgradeButtonPointerFrame:Show();
			CharSelectAccountUpgradeButtonGlow:Show();
		end
	end);
	button:SetScript("OnLeave", function(self)
		if ( self.upButton:IsShown() and not (self.upButton:IsMouseOver() or self.downButton:IsMouseOver()) ) then
			self.upButton:Hide();
			self.downButton:Hide();
		end
		CharSelectAccountUpgradeButtonPointerFrame:Hide();
		CharSelectAccountUpgradeButtonGlow:Hide();
		GlueTooltip:Hide();
	end);
	button:SetScript("OnMouseUp", CharacterSelectButton_OnDragStop);
end

local function disableAllScripts()
	for i = 1, math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED) do
		local button = _G["CharSelectCharacterButton"..i];
		disableScripts(button);
		button.upButton:Hide();
		button.downButton:Hide();
	end
end

CharacterServicesCharacterSelectorMixin = {};

function CharacterServicesCharacterSelectorMixin:OnLoad()
	self.ButtonPools = CreateFramePoolCollection();
	self.ButtonPools:CreatePool("Frame", self, "CharacterServicesArrowTemplate");
	self.ButtonPools:CreatePool("Frame", self, "CharacterServicesBonusIconTemplate");
end

-- The characterSelectableCallback recives a characterID and a characterSelectButton and should return:
-- bool: enable the character button (this will show the arrow indicator next to the character)
-- bool: enable the bonus icon, the bonus icon communicates some custom state
function CharacterServicesCharacterSelectorMixin:UpdateDisplay(characterSelectableCallback)
	CharacterSelect_SetScrollEnabled(true);
	CharacterSelect_SaveCharacterOrder();

	local numCharacters = GetNumCharacters();
	local numDisplayedCharacters = math.min(numCharacters, MAX_CHARACTERS_DISPLAYED);

	-- Set up the GlowBox around the show characters
	self.GlowBox:SetHeight(53 * numDisplayedCharacters);
	self.GlowBox:SetPoint("TOP", CharSelectCharacterButton1, -20, 0);
	self.GlowBox:SetWidth(CharacterSelectCharacterFrame.scrollBar:IsShown() and 238 or 244);

	self.ButtonPools:ReleaseAll();

	CharacterSelect.selectedIndex = -1;
	UpdateCharacterSelection(CharacterSelect);

	disableAllScripts();

	for i = 1, numDisplayedCharacters do
		local button = _G["CharSelectCharacterButton"..i];
		_G["CharSelectPaidService"..i]:Hide();

		local characterID = GetCharIDFromIndex(i + CHARACTER_LIST_OFFSET);

		local isEnabled, showBonus = characterSelectableCallback(characterID, button);
		CharacterSelect_SetCharacterButtonEnabled(i, isEnabled);

		if isEnabled then
			local arrow = self.ButtonPools:Acquire("CharacterServicesArrowTemplate");
			arrow:SetPoint("RIGHT", button, "LEFT", -8, 8);
			arrow:Show();

			if showBonus then
				local bonus = self.ButtonPools:Acquire("CharacterServicesBonusIconTemplate");
				bonus:SetPoint("LEFT", button.buttonText.name, "RIGHT", -1, 0);
				bonus:Show();
			end
		end
	end
end

-- glowBoxEnabledCallback takes a characterID and is expected to return true or false indicating that the character could be selected
-- for whatever service flow is active.
function CharacterServicesCharacterSelectorMixin:CheckGlowboxEnabled(checkCallback)
	self.GlowBox:Hide();

	--- Why not early out? Because this could have side effects; it's only run one time per flow.
	for i = 1, GetNumCharacters() do
		if checkCallback(GetCharIDFromIndex(i)) then
			self.GlowBox:SetShown(true);
		end
	end
end

function CharacterServicesCharacterSelectorMixin:HasAnyEligibleCharacter()
	return self.GlowBox:IsShown();
end

function CharacterServicesCharacterSelectorMixin:ResetState(selectedCharacterIndex)
	self:Hide();
	CharacterSelect_SetScrollEnabled(true);

	for i = 1, math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED) do
		local button = _G["CharSelectCharacterButton"..i];
		resetScripts(button);
		CharacterSelect_SetCharacterButtonEnabled(i, true);

		if (button.padlock) then
			button.padlock:Show();
		end
	end

	UpdateCharacterList(true);

	if selectedCharacterIndex and selectedCharacterIndex > 0 and selectedCharacterIndex <= MAX_CHARACTERS_DISPLAYED then
		CharacterSelect.selectedIndex = selectedCharacterIndex;
		local button = _G["CharSelectCharacterButton"..selectedCharacterIndex];
		CharacterSelectButton_OnClick(button);
		button.selection:Show();
	end
end