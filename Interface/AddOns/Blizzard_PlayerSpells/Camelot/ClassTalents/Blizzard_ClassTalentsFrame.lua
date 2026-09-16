--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
ClassTalentsFrameMixin.useFooterJumpHints = true;

-- Text to display next to jump hints on other frames, if the jump takes them here
function ClassTalentsFrameMixin:GetJumpHintLabel()
	return TALENTS;
end

function ClassTalentsFrameMixin:InitializeTreeHeaders()
	self.treeHeaderPool = CreateFramePoolCollection();
	self.treeHeaderPool:CreatePool("FRAME", self, "ClassTalentTreeHeaderTemplate");
end

local TAB_CHECKMARK_MARKUP = CreateAtlasMarkup("Talents-Checkmark-c60", 20, 15);
local TAB_LOCK_MARKUP = CreateAtlasMarkup("Talents-lock-c60", 10, 14);

ClassTalentsFrameTabMixin = {};

function ClassTalentsFrameTabMixin:SetIsActive(isActive)
	self.isActive = isActive;
	self:UpdateTabText();
end

function ClassTalentsFrameTabMixin:IsActive()
	return self.isActive;
end

function ClassTalentsFrameTabMixin:GetTextYOffset(_isSelected)
	-- This overrides logic in TabSystemButtonArtMixin:GetTextYOffset.
	-- It's not enough to just use self.textOffsetY because the base function does some
	-- extra logic involving selection not desired here.
	return -4;
end

function ClassTalentsFrameTabMixin:GetTabText()
	local primaryText = TabSystemButtonMixin.GetTabText(self);

	if self:IsActive() then
		return primaryText .. " " .. TAB_CHECKMARK_MARKUP;
	elseif not self:IsEnabled() then
		return primaryText .. " " .. TAB_LOCK_MARKUP;
	else
		return primaryText;
	end
end

function ClassTalentsFrameMixin:HasCopyButton()
	return false;
end

function ClassTalentsFrameMixin:OnShow()
	-- overriden in other flavors
	self:OnShowBase();
	PlayerSpellsFrame:UpdateSize();
end

function ClassTalentsFrameMixin:OnHide()
	self:OnHideBase();
	self:HideSpecChangeElements();
	self.loadConfigIDOnCreate = nil;
end

local TREE_HEADER_OFFSET_X = 140;
local TREE_HEADER_OFFSET_Y = -100;
local TREE_HEADER_SPACING_X = 400;
function ClassTalentsFrameMixin:RefreshTreeHeaders()
	self.treeHeaderPool:ReleaseAll();
	self.treeHeaders = {};
	local groupIDs = {};

	local function GroupCurrencyInfoForGroupID(groupInfos, groupID)
		for i, groupInfo in ipairs(groupInfos) do
			if groupInfo.traitNodeGroupID == groupID then
				return groupInfo;
			end
		end
	end

	local displayInfos = C_Traits.GetGroupDisplayInfoByTreeID(self:GetTalentTreeID());
	for i, displayInfo in ipairs(displayInfos) do
		table.insert(groupIDs, displayInfo.groupID);
	end

	local groupInfos = C_Traits.GetGroupCurrencyInfo(self:GetConfigID(), groupIDs);
	for i, displayInfo in ipairs(displayInfos) do
		local groupInfo = GroupCurrencyInfoForGroupID(groupInfos, displayInfo.groupID);
		local header = self.treeHeaderPool:Acquire("ClassTalentTreeHeaderTemplate");
		header:Setup(displayInfo, groupInfo);
		header:SetPoint("CENTER", self.BackgroundBorder, "TOPLEFT", TREE_HEADER_OFFSET_X + ((i-1) * TREE_HEADER_SPACING_X), TREE_HEADER_OFFSET_Y);
		header:Show();
		table.insert(self.treeHeaders, header);
	end
end

function ClassTalentsFrameMixin:GetActiveTab()
	if C_SpecializationInfo.GetActiveSpecGroup() == 1 then
		return self.primarySpecTabID;
	else
		return self.secondarySpecTabID;
	end
end

local function IsDualSpecUnlocked()
	return GetNumSpecGroups() > 1;
end

function ClassTalentsFrameMixin:InitializeOther()
	self:InitializeTabSystem();
	self:InitializeActiveSpec();

	self.DisabledOverlay:ClearAllPoints();
	self.DisabledOverlay:SetPoint("TOPLEFT", self.ClassBackground, "TOPLEFT");
	self.DisabledOverlay:SetPoint("BOTTOMRIGHT", self.ClassBackground, "BOTTOMRIGHT");
end

function ClassTalentsFrameMixin:IsActiveTabSelected()
	return self:GetActiveTab() == self:GetTab();
end

function ClassTalentsFrameMixin:InitializeTabSystem()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);

	self.primarySpecTabID = self:AddNamedTab(DUAL_SPEC_PRIMARY);
	self.secondarySpecTabID = self:AddNamedTab(DUAL_SPEC_SECONDARY);

	self:SetTab(self:GetActiveTab());

	self:UpdateTabs();
end

function ClassTalentsFrameMixin:GetTraitTreeName(traitTreeID, groupIDs)
	if groupIDs then
		local displayInfos = C_Traits.GetGroupDisplayInfoByTreeID(traitTreeID);
		for _, displayInfo in pairs(displayInfos) do
			for _, groupID in ipairs(groupIDs) do
				if displayInfo.groupID == groupID then
					return displayInfo.displayName;
				end
			end
		end
	end
	return "";
end

function ClassTalentsFrameMixin:UpdateTabs()
	self.TabSystem:SetTabEnabled(self.secondarySpecTabID, IsDualSpecUnlocked(), TALENT_SPEC_LOCKED);

	local activeTab = self:GetActiveTab();
	for _, tabID in ipairs(self:GetTabSet()) do
		self.TabSystem:GetTabButton(tabID):SetIsActive(activeTab == tabID);
	end
end

function ClassTalentsFrameMixin:SetTab(tabID, forcedOpen)
	TabSystemOwnerMixin.SetTab(self, tabID);

	local configID = C_SpecializationInfo.GetCombatConfigIDForSpecGroup(tabID);
	if configID then
		self:SetConfigID(configID);
		self.ActiveSpec:SetGlow(false);
		self:HideSpecChangeElements();
	else
		self:SetDisabledOverlayShown(true);
		self.ActiveSpec:SetGlow(true);
	end

	self.ActiveSpec:Refresh();
end

function ClassTalentsFrameMixin:HandlePlayerTalentUpdate()
	self:CheckSetSelectedConfigID();
	self:UpdateTabs();
	self:InitializeActiveSpec();
end

function ClassTalentsFrameMixin:IsLocked()
	return not self:IsActiveTabSelected();
end

function ClassTalentsFrameMixin:OnConfigChanged(configID)
	self.ActiveSpec:Refresh();

	self:HideSpecChangeElements();

	self:SetConfigID(configID, true);
	self.loadConfigIDOnCreate = configID;
end

function ClassTalentsFrameMixin:HideSpecChangeElements()
	self:SetDisabledOverlayShown(false);
	self:SetSpecSwitchCastBarActive(false);
end

function ClassTalentsFrameMixin:OnTraitConfigCreateFinished(configID)
	self:OnTraitConfigCreateFinishedBase(configID);
	if self.loadConfigIDOnCreate and self.loadConfigIDOnCreate == configID then
		self:SetConfigID(configID, true);
	end
end

function ClassTalentsFrameMixin:UpdateInspectingPvPSlots(isInspecting)
	-- No PvP talents in Camelot
end

function ClassTalentsFrameMixin:SetPvPTalentFrames(frame)
	-- No PvP talents in Camelot
end

function ClassTalentsFrameMixin:RefreshTreeCurrencyDisplay()
	-- No tree talent points in Camelot
end

function ClassTalentCurrencyDisplayMixin:SetPointTypeText(text)
	-- No class specific label in Camelot
end

function ClassTalentsFrameMixin:InitializeLoadSystem()
	self.LoadSystem:Hide();
	self:SetSearchBoxDefaultPosition();
	self:InitializeSearchOptionsDropdown();
end

function ClassTalentsFrameMixin:SetSearchBoxDefaultPosition()
	self.SearchBox:SetPoint("BOTTOMRIGHT", self.BackgroundBorder, "TOPRIGHT", -32, 4);
	self.SearchOptionsDropdown:SetPoint("LEFT", self.SearchBox, "RIGHT", 3, -2);
end

function ClassTalentsFrameMixin:InitializeSearchOptionsDropdown()
	self.hidePassivesFromSearch = false;
	self.showRanksInSearch = false;

	self.SearchOptionsDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_CLASS_TALENTS_SEARCH_OPTIONS");

		rootDescription:CreateCheckbox(CLASS_TALENT_SEARCH_OPTION_HIDE_PASSIVES,
			function() return self.hidePassivesFromSearch; end,
			function() self.hidePassivesFromSearch = not self.hidePassivesFromSearch; end
		);

		rootDescription:CreateCheckbox(CLASS_TALENT_SEARCH_OPTION_SHOW_RANKS,
			function() return self.showRanksInSearch; end,
			function() self.showRanksInSearch = not self.showRanksInSearch; end
		);
	end);
end

--Override of ClassTalentSearchMixin called just before results are passed to SearchPreviewContainer.
-- Applies the active search options: filtering out passives and/or annotating names with rank counts.
function ClassTalentsFrameMixin:TransformPreviewResults(previewResults)
	if not self.hidePassivesFromSearch and not self.showRanksInSearch then
		return previewResults;
	end

	local filteredResults = {};
	for _, resultInfo in ipairs(previewResults) do
		local definitionInfo = self:GetDefinitionInfoForEntry(resultInfo.resultID);
		local spellID = definitionInfo and definitionInfo.spellID;

		if self.hidePassivesFromSearch and spellID and C_Spell.IsSpellPassive(spellID) then
			-- Skip passive talents.
		else
			if self.showRanksInSearch and resultInfo.nodeID then
				local nodeInfo = self:GetAndCacheNodeInfo(resultInfo.nodeID);
				if nodeInfo then
					resultInfo = CopyTable(resultInfo);
					-- Preserve the original name separately so OnPreviewSearchResultClicked can
					-- still search by the unmodified spell name when the user selects a result.
					resultInfo.searchName = resultInfo.name;
					resultInfo.name = resultInfo.name .. " (" .. nodeInfo.ranksPurchased .. "/" .. nodeInfo.maxRanks .. ")";
				end
			end
			table.insert(filteredResults, resultInfo);
		end
	end

	return filteredResults;
end

function ClassTalentsFrameMixin:OnPreviewSearchResultClicked(resultInfo)
	-- When ranks are shown, resultInfo.name contains a display string like "Fireball (2/3)".
	-- The base implementation uses resultInfo.name for both the SearchBox text and the full search query,
	-- so restore the original spell name before delegating to avoid broken search matches.
	if resultInfo and resultInfo.searchName then
		resultInfo = CopyTable(resultInfo);
		resultInfo.name = resultInfo.searchName;
	end

	ClassTalentSearchMixin.OnPreviewSearchResultClicked(self, resultInfo);
end

function ClassTalentsFrameMixin:InitializeActiveSpec()
	self.ActiveSpec:SetShown(IsDualSpecUnlocked());
end

function ClassTalentsFrameMixin:SetSpecSwitchCastBarActive(active)
	if active then
		OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(self.DisabledOverlay, { overrideBarType = CastingBarType.ApplyingTalents });
	else
		OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
	end
end

ClassTalentTreeHeaderMixin = {};

function ClassTalentTreeHeaderMixin:Setup(displayInfo, groupInfo)
	self.displayInfo = displayInfo;
	self.Name:SetText(displayInfo.displayName);
	self.Icon:SetTexture(displayInfo.icon);

	if groupInfo then
		local currencyInfo = groupInfo.currencyInfos[1];
		if currencyInfo then
			self.Text:SetText(currencyInfo.spent);
		end
	else
		self.Text:SetText("0");
	end
end

ClassTalentActiveSpecMixin = {};

function ClassTalentActiveSpecMixin:OnLoad()
	self.ActivateButton:SetOnClickHandler(GenerateClosure(self.ActivateSpec, self));
end

function ClassTalentActiveSpecMixin:OnShow()
	self:SetGlow(false);
	self:Refresh();
end

function ClassTalentActiveSpecMixin:Refresh()
	if self:GetParent():IsActiveTabSelected() then
		self.ActivateButton:Hide();
		self.ActiveLabel:Show();
	else
		self.ActivateButton:Show();
		self.ActiveLabel:Hide();
	end
end

function ClassTalentActiveSpecMixin:ActivateSpec(index)
	self:GetParent():SetDisabledOverlayShown(true);
	self:GetParent():SetSpecSwitchCastBarActive(true);
	C_SpecializationInfo.SetActiveSpecGroup(self:GetParent():GetTab());
end

function ClassTalentActiveSpecMixin:SetGlow(enabled)
	self.ActivateButton.YellowGlow:SetShown(enabled);
end
