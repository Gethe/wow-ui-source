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
	self.ButtonPools:CreatePool("Frame", self, "CharacterServicesArrowTemplate", function(pool, obj)
		FramePool_HideAndClearAnchors(pool, obj);
		obj:GetParent().SelectionEnabledArrow = nil;
	end);

	self.ButtonPools:CreatePool("Frame", self, "CharacterServicesBonusIconTemplate", function(pool, obj)
		FramePool_HideAndClearAnchors(pool, obj);
		obj:GetParent().SelectionBonusIcon = nil;
	end);

	local doNotIterateExisting = false;
	ScrollUtil.AddInitializedFrameCallback(CharacterSelectCharacterFrame.ScrollBox, self.UpdateSingleCharacter, self, doNotIterateExisting);
end

function CharacterServicesCharacterSelectorMixin:UpdateDisplay(block)
	CharacterSelect_SetScrollEnabled(true);
	CharacterSelect_SaveCharacterOrder();

	self:SetBlock(block);

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
		hasAnyValidCharacter = self:UpdateSingleCharacter(button) or hasAnyValidCharacter;
	end);

	self.GlowBox:SetShown(hasAnyValidCharacter);
end

function CharacterServicesCharacterSelectorMixin:UpdateSingleCharacter(button)
	if not self:IsActive() then
		return false;
	end

	button.paidService:Hide();

	local isEnabled, showBonus = self:ProcessCharacterFromBlock(button);
	CharacterSelect_SetCharacterButtonEnabled(button, isEnabled);
	self:SetupAttachedCharacterButtonFrames(button, isEnabled, showBonus);

	return isEnabled;
end

function CharacterServicesCharacterSelectorMixin:SetupAttachedCharacterButtonFrames(button, isEnabled, showBonus)
	if isEnabled then
		if not button.SelectionEnabledArrow then
			local arrow = self.ButtonPools:Acquire("CharacterServicesArrowTemplate");
			button.SelectionEnabledArrow = arrow;

			arrow:SetParent(button);
			arrow:SetPoint("RIGHT", button, "LEFT", -8, 8);
			arrow:Show();
		end
	elseif button.SelectionEnabledArrow then
		self.ButtonPools:Release(button.SelectionEnabledArrow);
		button.SelectionEnabledArrow = nil;
	end

	if isEnabled and showBonus then
		if not button.SelectionBonusIcon then
			local bonusIcon = self.ButtonPools:Acquire("CharacterServicesBonusIconTemplate");
			button.SelectionBonusIcon = bonusIcon;
			bonusIcon.SelectionBonusIcon:SetPoint("LEFT", button.buttonText.name, "RIGHT", -1, 0);
			bonusIcon.SelectionBonusIcon:Show();
		end
	elseif button.SelectionBonusIcon then
		self.ButtonPools:Release(button.SelectionBonusIcon);
		button.SelectionBonusIcon = nil;
	end
end

function CharacterServicesCharacterSelectorMixin:ProcessCharacterFromBlock(characterButton)
	local block = self:GetBlock();
	local serviceInfo = block:GetServiceInfoByCharacterID(characterButton.characterID);

	-- Determine if this should auto-advance and cache off relevant information
	-- NOTE: CharacterUpgradeCharacterSelectBlock always uses auto-advance, there's no "next"
	-- button, so once a character is selected it has to advance automatically.
	if serviceInfo.isEligible and serviceInfo.checkAutoSelect and CharacterUpgradeFlow:GetAutoSelectGuid() == serviceInfo.playerguid then
		block:SaveResultInfo(characterButton, serviceInfo.playerguid);
		characterButton.selection:Show();
	end

	characterButton:SetScript("OnClick", function(characterButton, button)
		local serviceInfo = block:GetServiceInfoByCharacterID(characterButton.characterID);
		if not serviceInfo.isEligible then
			return;
		end

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

	characterButton:SetScript("OnEnter", function(characterButton)
		local serviceInfo = block:GetServiceInfoByCharacterID(characterButton.characterID);
		if not serviceInfo.checkErrors then
			return;
		end

		if #serviceInfo.errors > 0 then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(characterButton, "ANCHOR_BOTTOMLEFT", -25, 70);
			GameTooltip_SetTitle(tooltip, BLIZZARD_STORE_VAS_ERROR_LABEL);
			for index, errorMsg in pairs(serviceInfo.errors) do
				GameTooltip_AddErrorLine(tooltip, errorMsg);
			end

			tooltip:Show();
		end
	end);

	characterButton:SetScript("OnLeave", function(characterButton)
		local tooltip = GetAppropriateTooltip();
		tooltip:Hide();
	end);

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

	CharacterSelectCharacterFrame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition);

	restoreAllButtonScripts();

	UpdateCharacterList(true);
	local selectedCharacterIndex;
	if selectedButtonIndex and selectedButtonIndex > 0 then
		selectedCharacterIndex = selectedButtonIndex;
	else
		selectedCharacterIndex = self.initialSelectedCharacterIndex;
	end

	local button = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return frame.index == selectedCharacterIndex;
	end);

	if button then
		CharacterSelect.selectedIndex = selectedCharacterIndex;
		UpdateCharacterSelection(CharacterSelect);
	end
end

function CharacterServicesCharacterSelectorMixin:IsActive()
	return self:IsShown();
end

function CharacterServicesCharacterSelectorMixin:SetBlock(block)
	self.block = block;
end

function CharacterServicesCharacterSelectorMixin:GetBlock()
	return self.block;
end