CharacterServicesCharacterSelectorMixin = {};

function CharacterServicesCharacterSelectorMixin:OnLoad()
	self.ButtonPools = CreateFramePoolCollection();

	self.ButtonPools:CreatePool("Frame", self, "CharacterServicesBonusIconTemplate", function(pool, obj)
		Pool_HideAndClearAnchors(pool, obj);
		obj:GetParent().SelectionBonusIcon = nil;
	end);

	local doNotIterateExisting = false;
	ScrollUtil.AddInitializedFrameCallback(CharacterSelectCharacterFrame.ScrollBox, self.InitializedFrameCallback, self, doNotIterateExisting);
end

function CharacterServicesCharacterSelectorMixin:InitializedFrameCallback(frame)
	local function updateSingleCharacterFrame(character)
		self:UpdateSingleCharacter(character);
	end
	CharacterSelectListUtil.RunCallbackOnSlot(frame, updateSingleCharacterFrame);
end

function CharacterServicesCharacterSelectorMixin:UpdateDisplay(block)
	CharacterSelectListUtil.SetScrollListInteractiveState(true);
	CharacterSelectListUtil.SaveCharacterOrder();

	self:SetBlock(block);

	-- Set up the GlowBox around the show characters
	self.GlowBox:SetPoint("TOPRIGHT", CharacterSelectCharacterFrame.ScrollBar, -21, 0);
	self.GlowBox:SetPoint("BOTTOM", CharacterSelectCharacterFrame.ScrollBar, 0, -2);
	self.GlowBox:SetWidth(328);

	self.ButtonPools:ReleaseAll();

	self.initialSelectedCharacterIndex = GetCharacterSelection();
	CharacterSelect.selectedIndex = -1;
	CharacterSelectCharacterFrame:UpdateCharacterSelection();

	CharacterSelectListUtil.ForEachCharacterDo(function(frame)
		self:UpdateSingleCharacter(frame);
	end);

	local hasAnyValidCharacter = CharacterSelectListUtil.AreAnyCharactersEligible(self:GetBlock());
	self.GlowBox:SetShown(hasAnyValidCharacter);
end

function CharacterServicesCharacterSelectorMixin:UpdateSingleCharacter(frame)
	if not self:IsActive() then
		return false;
	end

	frame.PaidService:Hide();

	local isEnabled, showBonus = self:ProcessCharacterFromBlock(frame);
	frame.InnerContent:SetEnabledState(isEnabled);
	self:SetupAttachedCharacterButtonFrames(frame, isEnabled, showBonus);

	return isEnabled;
end

function CharacterServicesCharacterSelectorMixin:SetupAttachedCharacterButtonFrames(frame, isEnabled, showBonus)
	frame:SetArrowButtonShown(isEnabled);

	if isEnabled and showBonus then
		if not frame.SelectionBonusIcon then
			local bonusIcon = self.ButtonPools:Acquire("CharacterServicesBonusIconTemplate");
			frame.SelectionBonusIcon = bonusIcon;
			bonusIcon:SetPoint("LEFT", frame.InnerContent.Text.Name, "RIGHT", -1, 0);
			bonusIcon:Show();
		end
	elseif frame.SelectionBonusIcon then
		self.ButtonPools:Release(frame.SelectionBonusIcon);
		frame.SelectionBonusIcon = nil;
	end
end

function CharacterServicesCharacterSelectorMixin:ProcessCharacterFromBlock(frame)
	local block = self:GetBlock();
	local serviceInfo = block:GetServiceInfoByCharacterID(frame.characterID);

	-- Determine if this should auto-advance and cache off relevant information
	-- NOTE: CharacterUpgradeCharacterSelectBlock always uses auto-advance, there's no "next"
	-- button, so once a character is selected it has to advance automatically.
	if serviceInfo.isEligible and serviceInfo.checkAutoSelect and CharacterUpgradeFlow:GetAutoSelectGuid() == serviceInfo.playerguid then
		block:SaveResultInfo(frame, serviceInfo.playerguid);
		frame:SetSelectedState(true);
	end

	local function CharacterServicesOnClick()
		local serviceInfo = block:GetServiceInfoByCharacterID(frame.characterID);
		if not serviceInfo.isEligible then
			return;
		end

		if serviceInfo.requiresLogin then
			GlueDialog_Show("MUST_LOG_IN_FIRST");
			CharSelectServicesFlowFrame:Hide();
			return;
		end

		block:SaveResultInfo(frame, serviceInfo.playerguid);

		-- The user entered a normal boost flow and selected a trial boost character, at this point
		-- put the flow into the auto-select state.
		if serviceInfo.checkTrialBoost then
			local trialBoostFlowGuid = serviceInfo.isTrialBoost and playerguid or nil;
			CharacterUpgradeFlow:SetTrialBoostGuid(trialBoostFlowGuid);
		end

		if not frame:CanSelect() then
			return;
		end

		-- Fixes cases of selecting a character, backing out, then selecting them again causing visual issues.
		CharacterSelect.selectedIndex = GetCharacterSelection();

		frame:OnClick();
		frame:SetSelectedState(true);

		CharacterServicesMaster_Update();
	end

	local function CharacterServicesOnEnter()
		if frame:CanSelect() then
			local isSelected = frame:IsSelected();
			local innerContent = frame.InnerContent;
			if isSelected then
				innerContent.SelectedHighlight:Show();
			else
				innerContent.Highlight:Show();
				innerContent.FactionEmblemHighlight:Show();
			end
		end

		local serviceInfo = block:GetServiceInfoByCharacterID(frame.characterID);
		if not serviceInfo.checkErrors then
			return;
		end

		if #serviceInfo.errors > 0 then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT", -25, 70);
			local tooltipTitle = #serviceInfo.errors == 1 and BLIZZARD_STORE_VAS_ERROR_SINGULAR_LABEL or BLIZZARD_STORE_VAS_ERROR_LABEL;
			GameTooltip_SetTitle(tooltip, tooltipTitle);
			for _, errorMsg in pairs(serviceInfo.errors) do
				GameTooltip_AddErrorLine(tooltip, errorMsg);
			end

			tooltip:Show();
		end
	end

	local function CharacterServicesOnLeave()
		if frame:CanSelect() then
			local isSelected = frame:IsSelected();
			local innerContent = frame.InnerContent;
			if isSelected then
				innerContent.SelectedHighlight:Hide();
			else
				innerContent.Highlight:Hide();
				innerContent.FactionEmblemHighlight:Hide();
			end
		end

		local tooltip = GetAppropriateTooltip();
		tooltip:Hide();
	end

	frame:SetScript("OnClick", CharacterServicesOnClick);
	frame:SetScript("OnEnter", CharacterServicesOnEnter);
	frame:SetScript("OnLeave", CharacterServicesOnLeave);

	return serviceInfo.isEligible, serviceInfo.hasBonus;
end

function CharacterServicesCharacterSelectorMixin:HasAnyEligibleCharacter()
	return self.GlowBox:IsShown();
end

function CharacterServicesCharacterSelectorMixin:ResetState(selectedButtonIndex)
	self:Hide();
	self.ButtonPools:ReleaseAll();
	CharacterSelectListUtil.SetScrollListInteractiveState(true);

	CharacterUpgradeCharacterSelectBlock_SetFilteringByBoostable(false);

	CharacterSelectCharacterFrame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition);

	UpdateCharacterList(true);
	local selectedCharacterIndex;
	if selectedButtonIndex and selectedButtonIndex > 0 then
		selectedCharacterIndex = selectedButtonIndex;
	else
		selectedCharacterIndex = self.initialSelectedCharacterIndex;
	end

	local frame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		local characterID = CharacterSelectListUtil.GetCharIDFromIndex(selectedCharacterIndex);
		return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
	end);

	if frame then
		CharacterSelect.selectedIndex = selectedCharacterIndex;
		CharacterSelectCharacterFrame:UpdateCharacterSelection();
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