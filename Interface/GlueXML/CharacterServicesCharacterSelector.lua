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

function CharacterServicesCharacterSelectorMixin:UpdateDisplay(block)
	CharacterSelect_SetScrollEnabled(true);
	CharacterSelect_SaveCharacterOrder();

	local numCharacters = GetNumCharacters();
	local numDisplayedCharacters = math.min(numCharacters, MAX_CHARACTERS_DISPLAYED);

	-- Set up the GlowBox around the show characters
	self.GlowBox:SetHeight(53 * numDisplayedCharacters);
	self.GlowBox:SetPoint("TOP", CharSelectCharacterButton1, -20, 0);
	self.GlowBox:SetWidth(CharacterSelectCharacterFrame.scrollBar:IsShown() and 238 or 244);

	self.ButtonPools:ReleaseAll();

	self.initialSelectedCharacterIndex = GetCharacterSelection();
	CharacterSelect.selectedIndex = -1;
	UpdateCharacterSelection(CharacterSelect);

	disableAllScripts();

	local hasAnyValidCharacter = false;

	for i = 1, numDisplayedCharacters do
		local button = _G["CharSelectCharacterButton"..i];
		_G["CharSelectPaidService"..i]:Hide();

		local characterID = GetCharIDFromIndex(i + CHARACTER_LIST_OFFSET);

		local isEnabled, showBonus = self:ProcessCharacterFromBlock(characterID, button, block);
		CharacterSelect_SetCharacterButtonEnabled(i, isEnabled);

		if isEnabled then
			hasAnyValidCharacter = true;
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

	self.GlowBox:SetShown(hasAnyValidCharacter);
end

function CharacterServicesCharacterSelectorMixin:ProcessCharacterFromBlock(characterID, characterButton, block)
	local serviceInfo = block:GetServiceInfoByCharacterID(characterID);
	if serviceInfo.isEligible then
		characterButton:SetScript("OnClick", function(characterButton, button)
			if serviceInfo.requiresLogin then
				GlueDialog_Show("MUST_LOG_IN_FIRST");
				CharSelectServicesFlowFrame:Hide();
				return;
			end
			block:SaveResultInfo(characterButton, serviceInfo.playerguid);
		
			-- The user entered a normal boost flow and selected a trial boost character, at this point
			-- put the flow into the auto-select state.
			if serviceInfo.checkTrialBoost then
				local trialBoostFlowGuid = serviceInfo.isTrialBoost and playerguid or nil;
				CharacterUpgradeFlow:SetTrialBoostGuid(trialBoostFlowGuid);
			end

			CharacterSelectButton_OnClick(characterButton);
			characterButton.selection:Show();
			CharacterServicesMaster_Update();
		end);

		-- Determine if this should auto-advance and cache off relevant information
		-- NOTE: CharacterUpgradeCharacterSelectBlock always uses auto-advance, there's no "next"
		-- button, so once a character is selected it has to advance automatically.
		if serviceInfo.checkAutoSelect and CharacterUpgradeFlow:GetAutoSelectGuid() == serviceInfo.playerguid then
			block:SaveResultInfo(characterButton, serviceInfo.playerguid);
			characterButton.selection:Show();
		end
	elseif serviceInfo.checkErrors then
		characterButton:SetScript("OnEnter", function(self)
			if #serviceInfo.errors > 0 then
				local tooltip = GetAppropriateTooltip();
				tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -25, 70);
				GameTooltip_SetTitle(tooltip, BLIZZARD_STORE_VAS_ERROR_LABEL);
				for index, errorMsg in pairs(serviceInfo.errors) do
					GameTooltip_AddErrorLine(tooltip, errorMsg);
				end

				tooltip:Show();
			end
		end);

		characterButton:SetScript("OnLeave", function(self)
			local tooltip = GetAppropriateTooltip();
			tooltip:Hide();
		end);
	end

	return serviceInfo.isEligible, serviceInfo.hasBonus;
end

function CharacterServicesCharacterSelectorMixin:HasAnyEligibleCharacter()
	return self.GlowBox:IsShown();
end

function CharacterServicesCharacterSelectorMixin:ResetState(selectedButtonIndex)
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
	local selectedCharacterIndex;
	if selectedButtonIndex and selectedButtonIndex > 0 then
		selectedCharacterIndex = selectedButtonIndex + CHARACTER_LIST_OFFSET;
	else
		selectedCharacterIndex = self.initialSelectedCharacterIndex;
	end
	if selectedCharacterIndex and selectedCharacterIndex > 0 then
		CharacterSelect.selectedIndex = selectedCharacterIndex;
		UpdateCharacterSelection(CharacterSelect);
	end
end