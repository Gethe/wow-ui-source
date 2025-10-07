
TalentButtonSelectMixin = CreateFromMixins(TalentButtonBaseMixin);

function TalentButtonSelectMixin:OnLoad()
	TalentButtonBaseMixin.OnLoad(self);

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown", "MiddleButtonDown");
end

function TalentButtonSelectMixin:OnEnter()
	TalentButtonBaseMixin.OnEnter(self);

	self.isMouseOver = true;

	if self:ShouldBeVisible() and (self.talentSelections ~= nil) then
		self.timeSinceMouseOver = 0;
		self.mouseOverTime = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function TalentButtonSelectMixin:OnLeave()
	TalentDisplayMixin.OnLeave(self);

	self.isMouseOver = false;
end

local TimeToHideSeconds = 0;
local TimeToShowSelections = 0;
function TalentButtonSelectMixin:OnUpdate(dt)
	local talentFrame = self:GetTalentFrame();
	if not talentFrame:IsMouseOverSelections() and (not self:IsMouseMotionFocus()) then
		self.timeSinceMouseOver = self.timeSinceMouseOver + dt;
		if self.timeSinceMouseOver > TimeToHideSeconds then
			self:ClearSelections();
		end
	end

	if self.isMouseOver then
		self.mouseOverTime = self.mouseOverTime + dt;
		if (self.mouseOverTime > TimeToShowSelections) and not talentFrame:AreSelectionsOpen(self) then
			self:ShowSelections();
		end
	end
end

function TalentButtonSelectMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if self:IsInspecting() then
		return;
	end

	if self:IsLocked() then
		return;
	end

	if button == "RightButton" then
		if self:IsGhosted() then
			self:ClearCascadeRepurchaseHistory();
		end

		if self.nodeInfo.canRefundRank then
			self:SetSelectedEntryID(nil);

			-- If we just refunded, we should be able to select a choice unless we're in a refund invalid state.
			-- We're not using CanSelectChoice since that won't be accurate at this point.
			local canSelectChoice = not self:IsRefundInvalid();
			self:UpdateSelections(canSelectChoice, self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
		end
	elseif button == "LeftButton" then
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			self:CascadeRepurchaseRanks();
		elseif IsModifiedClick("CHATLINK") then
			local spellID = self:GetSpellID();
			if spellID then
				local spellLink = C_Spell.GetSpellLink(spellID);
				ChatEdit_InsertLink(spellLink);
			end
		end
	end
end

function TalentButtonSelectMixin:AcquireTooltip()
	-- Overrides TalentDisplayMixin.
	
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT");
	if self.tooltipBackdropStyle then
		SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
	end
	return tooltip;
end

function TalentButtonSelectMixin:ShowSelections()
	self:GetTalentFrame():ShowSelections(self, self.talentSelections, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());

	-- Prevent SearchIcon from potentially interrupting selection mouseover
	if self.SearchIcon then
		self.SearchIcon:SetMouseoverEnabled(false);
	end
end

function TalentButtonSelectMixin:ClearSelections()
	self:GetTalentFrame():HideSelections(self);
	self.timeSinceMouseOver = nil;
	self:SetScript("OnUpdate", nil);

	if self.SearchIcon then
		self.SearchIcon:SetMouseoverEnabled(true);
	end
end

function TalentButtonSelectMixin:AddTooltipTitle(tooltip)
	-- Override TalentButtonBaseMixin.
end

function TalentButtonSelectMixin:AddTooltipDescription(tooltip)
	-- Override TalentButtonBaseMixin.
end

function TalentButtonSelectMixin:AddTooltipCost(tooltip)
	-- Override TalentButtonBaseMixin.
end

function TalentButtonSelectMixin:AddTooltipErrors(tooltip)
	-- Overrides TalentDisplayMixin.

	local isLocked, errorMessage = self:GetTalentFrame():IsLocked();
	if isLocked and errorMessage then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, errorMessage);
	end
end

function TalentButtonSelectMixin:UpdateNodeInfo(skipUpdate)
	local baseSkipUpdate = true;
	TalentButtonBaseMixin.UpdateNodeInfo(self, baseSkipUpdate);

	local nodeInfo = self:GetNodeInfo();
	local hasNodeInfo = nodeInfo ~= nil;
	self.talentSelections = hasNodeInfo and nodeInfo.entryIDs or {};

	if hasNodeInfo then
		local isUserInput = false;
		self:UpdateSelectedEntryID(nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil, isUserInput);
	end

	self:UpdateSelections(self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());

	if not skipUpdate then
		self:FullUpdate();
	end
end

function TalentButtonSelectMixin:SetSelection(nodeID, selectedEntryID, oldSelection)
	self:GetTalentFrame():SetSelection(nodeID, selectedEntryID, oldSelection);
end

function TalentButtonSelectMixin:UpdateSelections(canSelectChoice, currentSelection, baseCost)
	self:GetTalentFrame():UpdateSelections(self, canSelectChoice, currentSelection, baseCost);
end

function TalentButtonSelectMixin:CanSelectChoice()
	if self:IsInspecting() then
		return false;
	end

	if self:IsRefundInvalid() then
		return false;
	end

	if self:HasSelectedEntryID() then
		return true;
	end

	if self:IsLocked() or not self:CanAfford() then
		return false;
	end

	if not self.nodeInfo or not self.nodeInfo.isAvailable then
		return false;
	end

	return true;
end

function TalentButtonSelectMixin:IsSelectable()
	-- Overrides TalentButtonBaseMixin.

	return TalentButtonBaseMixin.IsSelectable(self) and self:CanSelectChoice();
end

function TalentButtonSelectMixin:HasProgress()
	return self:HasSelectedEntryID() and self.nodeInfo and self.nodeInfo.activeRank > 0;
end

function TalentButtonSelectMixin:HasIncreasedRanks()
	if not self.nodeInfo then
		return false;
	end

	local totalIncreasedRanks = 0;
	if self.talentSelections then
		for _i, entryID in ipairs(self.talentSelections) do
			if self.nodeInfo.entryIDToRanksIncreased and self.nodeInfo.entryIDToRanksIncreased[entryID] then
				totalIncreasedRanks = totalIncreasedRanks + self.nodeInfo.entryIDToRanksIncreased[entryID];
			end
		end
	end

	return totalIncreasedRanks > 0 or (self.nodeInfo.ranksIncreased or 0) > 0;
end

function TalentButtonSelectMixin:IsMaxed()
	local activeRank = (self.nodeInfo ~= nil) and self.nodeInfo.activeRank or 0;
	return self:HasSelectedEntryID() and (activeRank > 0) and (activeRank >= self.nodeInfo.maxRanks);
end

function TalentButtonSelectMixin:IsDisplayError()
	-- Overrides TalentButtonBaseMixin.

	-- If one of the entries has been selected and that entry is in the DisplayError state this node
	-- should also be in the DisplayError state.
	if self:HasSelectedEntryID() then
		local talentFrame = self:GetTalentFrame();
		local selectedEntryInfo = talentFrame:GetAndCacheEntryInfo(self:GetSelectedEntryID());
		if selectedEntryInfo and selectedEntryInfo.isDisplayError then
			return true;
		end
	end

	return TalentButtonBaseMixin.IsDisplayError(self);
end

function TalentButtonSelectMixin:GetSpellID()
	-- Overrides TalentButtonBaseMixin.

	local selectedDefinitionInfo = self:GetSelectedDefinitionInfo();
	return selectedDefinitionInfo and selectedDefinitionInfo.spellID or nil;
end

function TalentButtonSelectMixin:GetName()
	-- Overrides TalentButtonBaseMixin.

	local subTreeInfo = self:GetSelectedSubTreeInfo();
	if subTreeInfo and subTreeInfo.name then
		return subTreeInfo.name;
	end

	local definitionInfo = self:GetSelectedDefinitionInfo();
	if definitionInfo then
		return TalentUtil.GetTalentName(definitionInfo.overrideName, self:GetSpellID());
	end

	return "";
end

function TalentButtonSelectMixin:GetSubtext()
	-- Overrides TalentButtonBaseMixin.

	local subTreeInfo = self:GetSelectedSubTreeInfo();
	if subTreeInfo and subTreeInfo.description then
		return subTreeInfo.description;
	end

	local definitionInfo = self:GetSelectedDefinitionInfo();

	return definitionInfo and TalentUtil.GetTalentSubtext(definitionInfo.overrideSubtext, self:GetSpellID()) or nil;
end

function TalentButtonSelectMixin:GetDescription()
	-- Overrides TalentButtonBaseMixin.

	local definitionInfo = self:GetSelectedDefinitionInfo();
	return definitionInfo and TalentUtil.GetTalentDescription(definitionInfo.overrideDescription, self:GetSpellID()) or "";
end

function TalentButtonSelectMixin:CalculateIconTexture()
	-- Overrides TalentButtonBaseMixin.
	return TalentButtonUtil.CalculateIconTextureFromInfo(self:GetSelectedDefinitionInfo(), self:GetSelectedSubTreeInfo());
end

function TalentButtonSelectMixin:UpdateIconTexture()
	-- Overrides TalentDisplayMixin.

	if not self.Icon then
		return;
	end

	if self:HasSelectedEntryID() then
		TalentDisplayMixin.UpdateIconTexture(self);
	else
		self.Icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]);
	end
end

function TalentButtonSelectMixin:GetSelectedDefinitionInfo()
	return self.selectedDefinitionInfo;
end

function TalentButtonSelectMixin:GetSelectedSubTreeInfo()
	return self.selectedSubTreeInfo;
end

function TalentButtonSelectMixin:SetSelectedEntryID(selectedEntryID)
	local oldSelection = self.selectedEntryID;

	if not self:GetTalentFrame():ShouldShowConfirmation() then
		local isUserInput = true;
		if not self:UpdateSelectedEntryID(selectedEntryID, isUserInput) then
			return;
		end
	end

	local nodeID = self:GetNodeID();
	if nodeID then
		self:SetSelection(nodeID, selectedEntryID, oldSelection);
	end
end

function TalentButtonSelectMixin:UpdateSelectedEntryID(selectedEntryID, isUserInput)
	if self.selectedEntryID == selectedEntryID then
		return false;
	end

	if isUserInput then
		if selectedEntryID == nil then
			self:PlayDeselectSound();
		else
			self:PlaySelectSound();
		end
	end

	self.selectedEntryID = selectedEntryID;

	if self.selectedEntryID ~= nil then
		local talentFrame = self:GetTalentFrame();
		local selectedEntryInfo = talentFrame:GetAndCacheEntryInfo(selectedEntryID);
		self.selectedDefinitionInfo = selectedEntryInfo.definitionID and talentFrame:GetAndCacheDefinitionInfo(selectedEntryInfo.definitionID) or nil;
		self.selectedSubTreeInfo = selectedEntryInfo.subTreeID and talentFrame:GetAndCacheSubTreeInfo(selectedEntryInfo.subTreeID) or nil;
	else
		self.selectedDefinitionInfo = nil;
		self.selectedSubTreeInfo = nil;
	end

	self:FullUpdate();
	return true;
end

function TalentButtonSelectMixin:GetSelectedEntryID()
	return self.selectedEntryID;
end

function TalentButtonSelectMixin:HasSelectedEntryID()
	return self.selectedEntryID ~= nil;
end

function TalentButtonSelectMixin:ResetDynamic()
	local nodeID = self:GetNodeID();
	if nodeID ~= nil then
		self:SetSelection(nodeID, nil, nil);
	end

	TalentButtonBaseMixin.ResetDynamic(self);
end


-- This breaks the usual pattern of talent button's two hierarchies and
-- inherits TalentButtonSplitIconMixin directly so that overrides are handled properly.
TalentButtonSplitSelectMixin = CreateFromMixins(TalentButtonSelectMixin, TalentButtonSplitIconMixin);

function TalentButtonSplitSelectMixin:UpdateIconTexture()
	-- Overrides TalentDisplayMixin.

	self.Icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]);
	self:SetSplitIconShown(false);
	if self:HasSelectedEntryID() then
		TalentButtonSelectMixin.UpdateIconTexture(self);
	elseif self.talentSelections and (#self.talentSelections > 1) then
		local talentFrame = self:GetTalentFrame();

		local firstEntryID = self.talentSelections[1];
		local firstEntryInfo = talentFrame:GetAndCacheEntryInfo(firstEntryID);
		local firstDefinitionInfo = firstEntryInfo.definitionID and talentFrame:GetAndCacheDefinitionInfo(firstEntryInfo.definitionID) or nil;
		local firstSubTreeInfo = firstEntryInfo.subTreeID and talentFrame:GetAndCacheSubTreeInfo(firstEntryInfo.subTreeID) or nil;

		-- By default, any use of SubTreeSelection nodes without a bespoke override will treat them like regular Selection nodes
		-- So we need to handle getting an icon from either an entry's subTree icon OR its definition texture
		local firstIcon, firstIconIsAtlas = TalentButtonUtil.CalculateIconTextureFromInfo(firstDefinitionInfo, firstSubTreeInfo);
		if firstIconIsAtlas then
			self.Icon:SetAtlas(firstIcon);
		else
			self.Icon:SetTexture(firstIcon);
		end

		local secondEntryID = self.talentSelections[2];
		self:SetSplitIconShown(secondEntryID ~= nil);
		if secondEntryID then
			local secondEntryInfo = talentFrame:GetAndCacheEntryInfo(secondEntryID);
			local secondDefinitionInfo = secondEntryInfo.definitionID and talentFrame:GetAndCacheDefinitionInfo(secondEntryInfo.definitionID) or nil;
			local secondSubTreeInfo = secondEntryInfo.subTreeID and talentFrame:GetAndCacheSubTreeInfo(secondEntryInfo.subTreeID) or nil;

			local secondIcon, secondIconIsAtlas = TalentButtonUtil.CalculateIconTextureFromInfo(secondDefinitionInfo, secondSubTreeInfo);
			if secondIconIsAtlas then
				self.Icon2:SetAtlas(secondIcon);
			else
				self.Icon2:SetTexture(secondIcon);
			end
		end
	end
end
