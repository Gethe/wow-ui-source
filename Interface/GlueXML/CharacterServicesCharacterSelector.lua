local function restoreButtonScripts(button)
	button:SetScript("OnClick", CharacterSelectButton_OnClick);
	button:SetScript("OnDoubleClick", CharacterSelectButton_OnDoubleClick);
	button:SetScript("OnDragStart", CharacterSelectButton_OnDragStart);
	button:SetScript("OnDragStop", CharacterSelectButton_OnDragStop);
	button:SetScript("OnMouseDown", CharacterSelectButton_OnMouseDown);
	button:SetScript("OnMouseUp", CharacterSelectButton_OnDragStop);
	button:SetScript("OnEnter", CharacterSelectButton_OnEnter);
	button:SetScript("OnLeave", CharacterSelectButton_OnLeave);
end

local function restoreAllButtonScripts()
	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(function(button)
		restoreButtonScripts(button);
	end);
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
	self.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, -11, -64);
	self.GlowBox:SetWidth(CharacterSelectCharacterFrame.ScrollBar:IsShown() and 238 or 244);

	self.ButtonPools:ReleaseAll();

	self.initialSelectedCharacterIndex = GetCharacterSelection();
	CharacterSelect.selectedIndex = -1;
	UpdateCharacterSelection(CharacterSelect);

	local hasAnyValidCharacter = false;
	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(function(button)
		button.paidService:Hide();

		local characterID = GetCharIDFromIndex(button.index);
		local isEnabled, showBonus = self:ProcessCharacterFromBlock(characterID, button, block);
		CharacterSelect_SetCharacterButtonEnabled(button, isEnabled);

		if isEnabled then
			hasAnyValidCharacter = true;
			local arrow = self.ButtonPools:Acquire("CharacterServicesArrowTemplate");
			arrow:SetParent(button);
			arrow:SetPoint("RIGHT", button, "LEFT", -8, 8);
			arrow:Show();

			if showBonus then
				local bonus = self.ButtonPools:Acquire("CharacterServicesBonusIconTemplate");
				bonus:SetPoint("LEFT", button.buttonText.name, "RIGHT", -1, 0);
				bonus:Show();
			end
		end
	end);

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
	self.ButtonPools:ReleaseAll();
	CharacterSelect_SetScrollEnabled(true);
	CharacterUpgradeCharacterSelectBlock_SetFilteringByBoostable(false);

	CharacterSelectCharacterFrame.ScrollBox:Rebuild();
	restoreAllButtonScripts();

	UpdateCharacterList(true);
	local selectedCharacterIndex;
	if selectedButtonIndex and selectedButtonIndex > 0 then
		selectedCharacterIndex = selectedButtonIndex + CHARACTER_LIST_OFFSET;
	else
		selectedCharacterIndex = self.initialSelectedCharacterIndex;
	end

	local button = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(elementData)
		return elementData.index == selectedCharacterIndex;
	end);

	if button then
		CharacterSelect.selectedIndex = selectedCharacterIndex;
		UpdateCharacterSelection(CharacterSelect);
	end
end