
g_professionsSpecsSelectedTabs = {};
g_professionsSpecsSelectedPaths = {};
local helptipSystemName = "Profession Specializations";

StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB"] = 
{
	text = PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB_TITLE,
	button1 = YES,
	button2 = CANCEL,

	OnAccept = function(self, info)
		info.onAccept();
	end,

	OnShow = function(self, info)
		self.SubText:SetText(PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB:format(info.specName, info.profName));
		self.SubText:Show();
	end,

	hideOnEscape = 1,
};


ProfessionsSpecFrameMixin = {};

function ProfessionsSpecFrameMixin:GetDesiredPageWidth()
	return 1144;
end

-- The intention is for only UI_PROFESSION_SPEC_DIAL_LOCKIN (207714) to be played.
local SuppressedSoundsOnUnlockPath = {
	SOUNDKIT.UI_PROFESSION_SPEC_PERK_EARNED, 
};

function ProfessionsSpecFrameMixin:ConfigureButtons()
	self.ApplyButton:SetScript("OnClick", function() self:CommitConfig(); end);
	self.UndoButton:SetScript("OnClick", function() self:RollbackConfig(); end);

	self.UnlockTabButton:SetScript("OnClick", function()
		self:CheckConfirmPurchaseTab();
	end);
	self.UnlockTabButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DetailedView.SpendPointsButton:SetScript("OnClick", function()
		self:PurchaseRank(self:GetDetailedPanelNodeID());
		PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PATH_SPEND);
	end);

	self.DetailedView.UnlockPathButton:SetScript("OnClick", function()
		self:SetSuppressedSounds(SuppressedSoundsOnUnlockPath);

		self:PurchaseRank(self:GetDetailedPanelNodeID());
		self:PlayDialLockInAnimation();

		self:ClearSuppressedSounds();
	end);
	self.DetailedView.UnlockPathButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DetailedView.SpendPointsButton:SetScript("OnEnter", function()
		local spendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self:GetDetailedPanelNodeID());
		if spendCurrency ~= nil then
			local currencyTypesID = self:GetSpendCurrencyTypesID();
			if currencyTypesID then
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID);
				if self.treeCurrencyInfoMap[spendCurrency] ~= nil and self.treeCurrencyInfoMap[spendCurrency].quantity == 0 then
					GameTooltip:SetOwner(self.DetailedView.SpendPointsButton, "ANCHOR_RIGHT", 0, 0);
					GameTooltip_AddErrorLine(GameTooltip, PROFESSIONS_SPECS_OUT_OF_KNOWLEDGE:format(currencyInfo.name));
					GameTooltip:Show();
				end
			end
		end
	end);
	self.DetailedView.SpendPointsButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DetailedView.Path.LockInAnimation:SetScript("OnFinished", function() self:UpdateDetailedPanel(true); end);
end

function ProfessionsSpecFrameMixin:GetSpendCurrencyTypesID()
	local detailedPath = self:GetDetailedPanelNodeID();
	local spendCurrency = detailedPath and C_ProfSpecs.GetSpendCurrencyForPath(detailedPath);
	if spendCurrency then
		local _, _, currencyTypesID = C_Traits.GetTraitCurrencyInfo(spendCurrency);
		return currencyTypesID;
	end
end

-- The intention is for only UI_PROFESSION_SPEC_DIAL_LOCKIN (207714) to be played.
local SuppressedSoundsOnPurchase = {
	SOUNDKIT.UI_PROFESSION_SPEC_PATH_SELECT, 
	SOUNDKIT.UI_PROFESSION_SPEC_PERK_EARNED, 
	SOUNDKIT.UI_PROFESSION_SPEC_APPLY_CHANGES,
};

function ProfessionsSpecFrameMixin:CheckConfirmPurchaseTab()
	if not self:AnyPopupShown() then
		local info = {};
		info.onAccept = function()
			self:SetSuppressedSounds(SuppressedSoundsOnPurchase);

			EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", self.tabInfo.rootNodeID);
			self:PurchaseRank(self.tabInfo.rootNodeID);
			self:CommitConfig();
			self:PlayDialLockInAnimation();
			HelpTip:HideAllSystem(helptipSystemName);

			self:ClearSuppressedSounds();
		end;

		info.specName = self.tabInfo.name;
		info.profName = self.professionInfo.professionName;

		StaticPopup_Show("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", self.tabInfo.name, self.professionInfo.professionName, info);
	end
end

function ProfessionsSpecFrameMixin:RegisterCallbacks()
	local function PathSelectedCallback(_, selectedID, skipSound)
		self:SetDetailedPanel(selectedID);

		if not skipSound then
			self:TryPlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PATH_SELECT);
		end
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.PathSelected", PathSelectedCallback, self);

	local function TabSelectedCallback(_, selectedID)
		self:SetSelectedTab(selectedID);
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.TabSelected", TabSelectedCallback, self);
end

function ProfessionsSpecFrameMixin:OnLoad() -- Override
	TalentFrameBaseMixin.OnLoad(self);

	self.tabsPool = CreateFramePool("BUTTON", self, "ProfessionSpecTabTemplate");
	self.perksPool = CreateFramePool("FRAME", self, "ProfessionsSpecPerkTemplate");

	self:ConfigureButtons();
	self:RegisterCallbacks();

	self.DetailedView.Path:Init(self);

	self.DetailedView.Path.CenterOuter:SetTexelSnappingBias(0);
	self.DetailedView.Path.CenterOuter:SetSnapToPixelGrid(false);
end

function ProfessionsSpecFrameMixin:OnUpdate() -- Override
	TalentFrameBaseMixin.OnUpdate(self);

	if self.detailedViewDirty then
		self:UpdateDetailedPanel();
		self.detailedViewDirty = nil;
	end

	if self.tabStateDirty then
		self:UpdateSelectedTabState();
		self.tabStateDirty = nil;
	end
end

function ProfessionsSpecFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	C_Traits.StageConfig(self:GetConfigID());

	self:SetTitle();
	self:UpdateTabs();
	self:UpdateSelectedTabState();
	self:UpdateTreeCurrencyInfo();
	self:UpdateDetailedPanel();
end

local staticPopups =
{
	"PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB",
};

function ProfessionsSpecFrameMixin:HideAllPopups()
	for _, popup in ipairs(staticPopups) do
		StaticPopup_Hide(popup);
	end
end

function ProfessionsSpecFrameMixin:AnyPopupShown()
	for _, popup in ipairs(staticPopups) do
		if StaticPopup_Visible(popup) then
			return true;
		end
	end

	-- Not owned by the professions page
	if StaticPopup_Visible("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE") then
		return true;
	end

	return false;
end

function ProfessionsSpecFrameMixin:OnHide()
	self:MarkTreeDirty();
	TalentFrameBaseMixin.OnHide(self);

	self:HideAllPopups();
	self:CancelShake();
end

function ProfessionsSpecFrameMixin:OnEvent(event, ...) -- Override
	TalentFrameBaseMixin.OnEvent(self, event, ...);

	if event == "TRAIT_NODE_CHANGED" then
		local nodeID = ...;

		if nodeID == self.tabInfo.rootNodeID then
			self.tabStateDirty = true;
			self:RegisterOnUpdate();
		end

		if nodeID == self:GetDetailedPanelNodeID() then
			self.detailedViewDirty = true;
			self:RegisterOnUpdate();
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		self:UpdateDetailedPanel();
	end
end

function ProfessionsSpecFrameMixin:OnTraitConfigUpdated(configID)
	TalentFrameBaseMixin.OnTraitConfigUpdated(self, configID);

	if self:IsVisible() then
		self:UpdateDetailedPanel();
		self:UpdateTabs();
	end
end

function ProfessionsSpecFrameMixin:GetProfessionInfo()
	return self.professionInfo;
end

function ProfessionsSpecFrameMixin:GetProfessionID()
	return self.professionInfo and self.professionInfo.professionID;
end

function ProfessionsSpecFrameMixin:GetDefaultTab(tabTreeIDs)
	local professionID = self:GetProfessionID();
	if g_professionsSpecsSelectedTabs[professionID] ~= nil and C_ProfSpecs.GetTabInfo(g_professionsSpecsSelectedTabs[professionID]) ~= nil then
		return g_professionsSpecsSelectedTabs[professionID];
	else
		-- Default to an unlocked tab if there is one; otherwise just pick the first one
		local configID = self:GetConfigID();
		for _, treeID in ipairs(tabTreeIDs) do
			if C_ProfSpecs.GetStateForTab(treeID, configID) == Enum.ProfessionsSpecTabState.Unlocked then
				return treeID;
			end
		end
		return tabTreeIDs[1];
	end
end

function ProfessionsSpecFrameMixin:InitializeTabs()
	self.tabsPool:ReleaseAll();

	local professionID = self:GetProfessionID();
	local tabTreeIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(professionID);

	local lastTab;
	local anyTabUnlocked = false;
	for _, traitTreeID in ipairs(tabTreeIDs) do
		local tab = self.tabsPool:Acquire();
		if tab:Init(traitTreeID) then
			if tab:GetState() == Enum.ProfessionsSpecTabState.Unlocked then
				anyTabUnlocked = true;
			end

			tab:ClearAllPoints();

			if lastTab then
				tab:SetPoint("LEFT", lastTab, "RIGHT", 1, 0);
			else
				tab:SetPoint("BOTTOMLEFT", self.TreeView, "TOPLEFT", 60, 0);
			end

			lastTab = tab;
		end
	end

	if lastTab and not anyTabUnlocked then
		local unlockableSpecHelpTipInfo =
		{
			text = PROFESSIONS_NEW_CHOICE_AVAILABLE_SPECIALIZATION_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			system = helptipSystemName,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_SPEC_CHOICE,
			autoHorizontalSlide = true,
		};
		-- NOTE: Helptips are shown on the next game frame to side-step a bug if the frame they are pointing at is instantiated in the same game frame the helptip is shown in.
		RunNextFrame(function() HelpTip:Show(self, unlockableSpecHelpTipInfo, lastTab); end);
	end

	EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self:GetDefaultTab(tabTreeIDs));
end

function ProfessionsSpecFrameMixin:UpdateTabs(tabCallback)
	for tab, _ in self.tabsPool:EnumerateActive() do
		tab:UpdateState();
		if tabCallback then
			tabCallback(tab);
		end
	end

	return false;
end

function ProfessionsSpecFrameMixin:HasUnlockableTab()
	local hasUnlockable = false;
	self:UpdateTabs(function(tab)
		if tab:GetState() == Enum.ProfessionsSpecTabState.Unlockable then
			hasUnlockable = true;
		end
	end);

	return hasUnlockable;
end

function ProfessionsSpecFrameMixin:UpdateCurrencyDisplay()
	local currencyInfo = self.treeCurrencyInfoMap[self.tabSpendCurrency];
	local currencyCount = currencyInfo and currencyInfo.quantity or 0;
	self.DetailedView.UnspentPoints.Count:SetText(currencyCount);

	local currencyTypesID = self:GetSpendCurrencyTypesID();
	local currencyTypesInfo = currencyTypesID and C_CurrencyInfo.GetCurrencyInfo(currencyTypesID);
	if currencyTypesInfo then
		self.DetailedView.UnspentPoints.Icon:SetTexture(currencyTypesInfo.iconFileID);
		self.DetailedView.UnspentPoints.Icon:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.DetailedView.UnspentPoints.Icon, "ANCHOR_RIGHT", 0, 0);
			Professions.SetupProfessionsCurrencyTooltip(currencyTypesInfo, currencyCount);
			GameTooltip:Show();
		end);
	end
end

function ProfessionsSpecFrameMixin:UpdateTreeCurrencyInfo() -- Override
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	self:UpdateCurrencyDisplay();
end

function ProfessionsSpecFrameMixin.getTemplateType(nodeInfo, talentType)
	return "ProfessionsSpecPathTemplate";
end

function ProfessionsSpecFrameMixin.getSpecializedMixin(nodeInfo, talentType)
	return ProfessionsSpecPathMixin;
end

function ProfessionsSpecFrameMixin.getEdgeTemplateType()
	return "ProfessionSpecEdgeArrowTemplate";
end

function ProfessionsSpecFrameMixin:InstantiateTalentButton(nodeID, xPos, yPos) -- Override
	local nodeInfo = self:GetAndCacheNodeInfo(nodeID);

	local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
	local entryInfo = (activeEntryID ~= nil) and self:GetAndCacheEntryInfo(activeEntryID) or nil;
	local talentType = (entryInfo ~= nil) and entryInfo.type or nil;
	local function InitTalentButton(newTalentButton)
		newTalentButton:SetNodeID(nodeID);
		newTalentButton:SetAndApplySize(newTalentButton.iconSize, newTalentButton.iconSize);
		TalentButtonUtil.ApplyPosition(newTalentButton, self, xPos, yPos)
		newTalentButton:SetSelected(nodeID == self:GetDetailedPanelNodeID());
		newTalentButton:Show();
	end

	local offsetX = nil;
	local offsetY = nil;
	local newTalentButton = self:AcquireTalentButton(nodeInfo, talentType, offsetX, offsetY, InitTalentButton);

	return newTalentButton;
end

local PathLayers = EnumUtil.MakeEnum("Root", "Primary", "Secondary");
local ParentLayerToChildLayer =
{
	[PathLayers.Root] = PathLayers.Primary,
	[PathLayers.Primary] = PathLayers.Secondary,
};

local PathLayoutInfo =
{
	[PathLayers.Primary] =
	{
		[1] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
		},
		[2] =
		{
			[1] = { rotationBetweenChildren = 90, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 90, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 100, distanceToChild = 1300 },
		},
		[3] =
		{
			[1] = { rotationBetweenChildren = 70, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 70, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 70, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 70, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 60, distanceToChild = 1300 },
		},
		[4] =
		{
			[1] = { rotationBetweenChildren = 50, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 60, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 55, distanceToChild = 1200 },
		},
		[5] =
		{
			[1] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
		},
	},
	[PathLayers.Secondary] =
	{
		[1] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 60, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 50, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
		},
		[2] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 35, distanceToChild = 1200 },
		},
		[3] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[4] = { rotationBetweenChildren = 40, distanceToChild = 1200 },
			[5] = { rotationBetweenChildren = 30, distanceToChild = 1200 },
		},
		[4] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
			[3] = { rotationBetweenChildren = 30, distanceToChild = 1200 },
		},
		[5] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1200 },
			[2] = { rotationBetweenChildren = 80, distanceToChild = 1200 },
		},
	},
};

function ProfessionsSpecFrameMixin:LoadTalentTreeInternal() -- Override
	self:ReleaseAllTalentButtons();

	local childrenMap = {};
	local maxLayerChildren =
	{
		[PathLayers.Primary] = 1,
		[PathLayers.Secondary] = 1,
	};

	local function ParseChildren(pathID, parentLayer)
		local childrenIDs = C_ProfSpecs.GetChildrenForPath(pathID);
		local numChildren = #childrenIDs;
		childrenMap[pathID] = childrenIDs;
		if numChildren == 0 then
			return;
		end
		
		local currLayer = ParentLayerToChildLayer[parentLayer];
		if numChildren > maxLayerChildren[currLayer] then
			maxLayerChildren[currLayer] = numChildren;
		end
		for i, childID in ipairs(childrenIDs) do
			ParseChildren(childID, currLayer);
		end
	end
	ParseChildren(self.tabInfo.rootNodeID, PathLayers.Root);

	local function SetUpChildren(parentNodeID, parentPosX, parentPosY, parentRotation, parentLayer)
		local childrenIDs = childrenMap[parentNodeID];
		local numChildren = #childrenIDs;
		if numChildren == 0 then
			return;
		end

		local currLayer = ParentLayerToChildLayer[parentLayer];
		local maxLayerOneChildren = maxLayerChildren[PathLayers.Primary];
		local maxLayerTwoChildren = maxLayerChildren[PathLayers.Secondary];
		local layoutInfo = PathLayoutInfo[currLayer][maxLayerOneChildren][maxLayerTwoChildren];
		local rotationBetweenChildren = layoutInfo.rotationBetweenChildren;
		local distanceToChild = layoutInfo.distanceToChild;

		local pivotVal = (numChildren / 2) + 0.5;
		for i, childID in ipairs(childrenIDs) do
			local numFromPivot = i - pivotVal;
			local childRotation = parentRotation + (numFromPivot * rotationBetweenChildren);
			-- sin/cos swapped due to 90 degree phase shift (0 rotation is vertical on the panel, positive Y offset moves down on the panel)
			local rotRadians = childRotation / 180 * math.pi;
			local childPosX = parentPosX + (math.sin(rotRadians) * distanceToChild);
			local childPosY = parentPosY + (math.cos(rotRadians) * distanceToChild);

			self:InstantiateTalentButton(childID, childPosX, childPosY);
			SetUpChildren(childID, childPosX, childPosY, childRotation, currLayer);
		end
	end

	local rootPosX = 3470;
	local rootPosY = 2910;
	self:InstantiateTalentButton(self.tabInfo.rootNodeID, rootPosX, rootPosY);
	SetUpChildren(self.tabInfo.rootNodeID, rootPosX, rootPosY, 0, PathLayers.Root);

	self:MarkTreeClean();
end

function ProfessionsSpecFrameMixin:UpdateSelectedTabState()
	local isLocked = C_ProfSpecs.GetStateForTab(self:GetTalentTreeID(), self:GetConfigID()) ~= Enum.ProfessionsSpecTabState.Unlocked;

	self.UnlockTabButton:SetShown(isLocked);
	if isLocked then
		local canUnlock = C_Traits.CanPurchaseRank(self:GetConfigID(), self.tabInfo.rootNodeID, C_ProfSpecs.GetUnlockEntryForPath(self.tabInfo.rootNodeID)) and self:CanAfford(self:GetNodeCost(self.tabInfo.rootNodeID));
		self.UnlockTabButton:SetEnabled(canUnlock);
		if not canUnlock then
			GlowEmitterFactory:Hide(self.UnlockTabButton);
			self.UnlockTabButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self.UnlockTabButton, "ANCHOR_RIGHT");
				local addBlankLine = false;
				self.selectedTab:AddTooltipSource(GameTooltip, addBlankLine);
				GameTooltip:Show();
			end);
		else
			GlowEmitterFactory:Show(self.UnlockTabButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
			self.UnlockTabButton:SetScript("OnEnter", nil);
		end
	end
end

function ProfessionsSpecFrameMixin:SetSelectedTab(traitTreeID)
	local firstTree;
	local found = false;
	for tab in self.tabsPool:EnumerateActive() do
		if firstTree == nil then
			firstTree = tab;
		end

		if tab.traitTreeID == traitTreeID then
			found = true;
			self.selectedTab = tab;
			break;
		end
	end
	if not found then
		self.selectedTab = firstTree;
	end

	self.tabInfo = C_ProfSpecs.GetTabInfo(traitTreeID);
	self.TreeView.TreeName:SetText(self.tabInfo.name);
	self.TreeView.TreeDescription:SetWidth(325);
	self.TreeView.TreeDescription:SetText(self.tabInfo.description);

	local forceUpdate = true;
	self:SetTalentTreeID(traitTreeID, forceUpdate);

	self.tabSpendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self.tabInfo.rootNodeID);
	self:UpdateTreeCurrencyInfo();
	
	self:UpdateSelectedTabState();

	local detailedViewNode = g_professionsSpecsSelectedPaths[traitTreeID] or self.tabInfo.rootNodeID;
	local skipSound = true;
	EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", detailedViewNode, skipSound);
	-- Need to update currency display after the path changes to get new icon
	self:UpdateCurrencyDisplay();

	self:UpdateConfigButtonsState()
	self:HideAllPopups();
end

function ProfessionsSpecFrameMixin:Refresh(professionInfo)
	local configID = C_ProfSpecs.GetConfigIDForSkillLine(professionInfo.professionID);
	if not Professions.InLocalCraftingMode() 
	   or not C_ProfSpecs.SkillLineHasSpecialization(professionInfo.professionID)
	   or configID == 0 then
		return;
	end

	if self:IsVisible() then
		self:SetTitle();
	end

	if self.professionInfo ~= nil and self.professionInfo.professionID == professionInfo.professionID then
		return;
	end

	self:ClearInfoCaches();

	self.professionInfo = professionInfo;
	self:SetConfigID(configID);
	self:InitializeTabs();
	self.TreeView.Background:SetAtlas(Professions.GetProfessionSpecializationBackgroundAtlas(professionInfo), TextureKitConstants.UseAtlasSize);
	self.DetailedView.Path:UpdateAssets();
end

function ProfessionsSpecFrameMixin:GetDetailedPanelPath()
	return self.DetailedView.Path;
end

function ProfessionsSpecFrameMixin:GetDetailedPanelNodeID()
	return self:GetDetailedPanelPath():GetNodeID();
end

function ProfessionsSpecFrameMixin:GetRootNodeID()
	return self.tabInfo.rootNodeID;
end

function ProfessionsSpecFrameMixin:SetDetailedPanel(pathID)
	self:GetDetailedPanelPath():SetNodeID(pathID);

	self:InitDetailedPanelPerks();
	local setLocked = true;
	self:UpdateDetailedPanel(setLocked);
	self:HideAllPopups();
	self:CancelShake();
end

function ProfessionsSpecFrameMixin:InitDetailedPanelPerks()
	self.perksPool:ReleaseAll();

	local perkInfos = C_ProfSpecs.GetPerksForPath(self:GetDetailedPanelNodeID());
	for _, perkInfo in ipairs(perkInfos) do
		local perk = self.perksPool:Acquire();
		perk:Init(self);
		perk:SetPerk(perkInfo);

		local rotation = perk:GetRotation();
		local distanceFromPath = perkInfo.isMajorPerk and 189 or 177;
		-- sin/cos swapped due to 90 degree phase shift, negation due to clockwise rotation
		local xOfs = -(distanceFromPath * math.sin(rotation));
		local yOfs = -(distanceFromPath * math.cos(rotation));

		perk:ClearAllPoints();
		perk:SetPoint("CENTER", self:GetDetailedPanelPath(), "CENTER", xOfs, yOfs);
		
		perk.PendingGlow:ClearAllPoints();
		local highlightDistanceFromPerk = 8;
		local highlightXOfs = -(highlightDistanceFromPerk * math.sin(rotation));
		local highlightYOfs = -(highlightDistanceFromPerk * math.cos(rotation));
		perk.PendingGlow:SetPoint("CENTER", perk, "CENTER", highlightXOfs, highlightYOfs);

		perk:Show();
	end
end

function ProfessionsSpecFrameMixin:UpdateDetailedPanelPerks()
	for perk, _ in self.perksPool:EnumerateActive() do
		perk:UpdateIconTexture();
	end
end

function ProfessionsSpecFrameMixin:UpdateDetailedPanel(setLocked)
	local detailedViewPath = self:GetDetailedPanelPath();
	detailedViewPath:UpdateNodeInfo();

	local nodeID = self:GetDetailedPanelNodeID();

	self.DetailedView.PathName:SetText(string.upper(detailedViewPath:GetName()));
	local currRank, maxRank = detailedViewPath:GetRanks();
	self.DetailedView.PointsText:SetFormattedText(PROFESSIONS_SPECS_POINTS_SPENT_FORMAT, currRank, maxRank);
	local state = C_ProfSpecs.GetStateForPath(nodeID, self:GetConfigID());
	local canPurchase = detailedViewPath:GetNextEntry() ~= nil and C_Traits.CanPurchaseRank(self:GetConfigID(), nodeID, detailedViewPath:GetNextEntry()) and detailedViewPath:CanAfford();

	local showPointsButtons = (state == Enum.ProfessionsSpecPathState.Progressing) or (state == Enum.ProfessionsSpecPathState.Completed);
	self.DetailedView.SpendPointsButton:SetShown(showPointsButtons);
	self.DetailedView.PointsText:SetShown(showPointsButtons);
	if showPointsButtons then
		self.DetailedView.SpendPointsButton:SetEnabled(canPurchase);
	end

	local isLocked = state == Enum.ProfessionsSpecPathState.Locked;
	local showUnlockButton = isLocked and nodeID ~= self.tabInfo.rootNodeID;
	self.DetailedView.UnlockPathButton:SetShown(showUnlockButton);
	if showUnlockButton then
		self.DetailedView.UnlockPathButton:SetEnabled(canPurchase);
		if not canPurchase then
			self.DetailedView.UnlockPathButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self.DetailedView.UnlockPathButton, "ANCHOR_RIGHT");
				local addBlankLine = false;
				detailedViewPath:AddTooltipSource(GameTooltip, addBlankLine);
				GameTooltip:Show();
			end);
		else
			self.DetailedView.UnlockPathButton:SetScript("OnEnter", nil);
		end
	end

	if setLocked or isLocked then
		detailedViewPath.LockInAnimation:Stop();
		detailedViewPath:SetLocked(isLocked);
	end

	local showDivider = currRank ~= 0 and currRank ~= maxRank;
	detailedViewPath.Divider:SetShown(showDivider);
	detailedViewPath.DividerGlow:SetShown(showDivider);
	if showDivider then
		local rotation = ProfessionDial_GetRelativeRotation(currRank, maxRank);
		local distanceFromPath = 152;
		-- sin/cos swapped due to 90 degree phase shift, negation due to clockwise rotation
		local xOfs = -(distanceFromPath * math.sin(rotation));
		local yOfs = -(distanceFromPath * math.cos(rotation));
		detailedViewPath.Divider:SetRotation(-rotation);
		detailedViewPath.Divider:ClearAllPoints();
		detailedViewPath.Divider:SetPoint("CENTER", detailedViewPath, "CENTER", xOfs, yOfs);
		detailedViewPath.DividerGlow:SetRotation(-(rotation + math.pi));
	end

	self:UpdateDetailedPanelPerks();
end

function ProfessionsSpecFrameMixin:SetDefaultPath(pathID)
	g_professionsSpecsSelectedPaths[self:GetTalentTreeID()] = pathID;
end

function ProfessionsSpecFrameMixin:SetDefaultTab(tabID)
	g_professionsSpecsSelectedTabs[self:GetProfessionID()] = tabID;
end

function ProfessionsSpecFrameMixin:PurchaseRank(pathID)
	self:AttemptConfigOperation(C_Traits.PurchaseRank, pathID)
	RunNextFrame(function() self.DetailedView.Path.AddKnowledgeAnim:Restart(); end);
	self:SetDefaultPath(pathID);
	self:SetDefaultTab(self:GetTalentTreeID());
end

function ProfessionsSpecFrameMixin:ShouldButtonShowEdges(button) -- Override
	return button:ShouldBeVisible() and not button.isDetailedView;
end

function ProfessionsSpecFrameMixin:GetConfigCommitErrorString()
	return PROFESSIONS_SPECS_CONFIG_OPERATION_TOO_FAST;
end

function ProfessionsSpecFrameMixin:CommitConfig() -- Override
	TalentFrameBaseMixin.CommitConfig(self);

	self:UpdateConfigButtonsState();
end

function ProfessionsSpecFrameMixin:RollbackConfig() -- Override
	TalentFrameBaseMixin.RollbackConfig(self);

	self:UpdateConfigButtonsState();
	self:UpdateTreeCurrencyInfo();
end

function ProfessionsSpecFrameMixin:AttemptConfigOperation(...) -- Override
	TalentFrameBaseMixin.AttemptConfigOperation(self, ...);

	self:UpdateConfigButtonsState();
end

function ProfessionsSpecFrameMixin:HasValidConfig()
	return (self:GetConfigID() ~= nil) and (self:GetTalentTreeID() ~= nil);
end

function ProfessionsSpecFrameMixin:HasAnyConfigChanges()
	if self:IsCommitInProgress() then
		return false;
	end

	return self:HasValidConfig() and C_Traits.ConfigHasStagedChanges(self:GetConfigID());
end

function ProfessionsSpecFrameMixin:UpdateConfigButtonsState()
	local hasAnyChanges = self:HasAnyConfigChanges();
	self.ApplyButton:SetEnabled(hasAnyChanges);
	self.UndoButton:SetShown(hasAnyChanges);

	if hasAnyChanges then
		GlowEmitterFactory:Show(self.ApplyButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
	end
end

local SHAKE = { { x = 0, y = -7}, { x = 0, y = 7}, { x = 0, y = -7}, { x = 0, y = 7}, { x = -3, y = -3}, { x = 3, y = 3}, { x = -1, y = -2}, { x = 3, y = 2}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 2}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 2}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -1, y = 1}, { x = -1, y = 1}, { x = -1, y = -1}, { x = 1, y = 1}, { x = -1, y = -1}, { x = -1, y = -1}, { x = 1, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, };
local SHAKE_DURATION = 0.1;
local SHAKE_FREQUENCY = 0.001;
function ProfessionsSpecFrameMixin:StartShake(delay)
	if self.shakeTimer then
		return;
	end

	self.shakeTimer = C_Timer.NewTimer(delay,
		function()
			ScriptAnimationUtil.ShakeFrame(ProfessionsFrame, SHAKE, SHAKE_DURATION, SHAKE_FREQUENCY);
			self.shakeTimer = nil;
		end
	);
end

function ProfessionsSpecFrameMixin:CancelShake()
	if self.shakeTimer then
		self.shakeTimer:Cancel();
		self.shakeTimer = nil;
	end
end

function ProfessionsSpecFrameMixin:PlayDialLockInAnimation()
	self.DetailedView.Path.Icon:SetScale(1, 1);
	self.DetailedView.Path.IconMask:SetScale(1, 1);
	self.DetailedView.Path.CenterInner:SetScale(1, 1);
	self.DetailedView.Path.LockInAnimation:Restart();
	local delay = 1.15;
	self:StartShake(delay);
	PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_DIAL_LOCKIN);
end

function ProfessionsSpecFrameMixin:PlayCompleteDialAnimation()
	self.DetailedView.Path.CompleteDialAnimation:Restart();
	PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PATH_FINISHED);
end

function ProfessionsSpecFrameMixin:SetTitle()
	local professionFrame = self:GetParent();
	local professionInfo = professionFrame.professionInfo;
	if not professionInfo then
		return;
	end

	professionFrame:SetTitle(PROFESSIONS_SPECIALIZATIONS_PAGE_NAME:format(professionInfo.professionName or professionInfo.parentProfessionName));
end


ProfessionsDetailedSpecPathMixin = CreateFromMixins(ProfessionsSpecPathMixin);

function ProfessionsDetailedSpecPathMixin:SetLocked(locked)
	if locked then
		self.DialLineWork:SetRotation(0);
		self.CenterLineWork:SetRotation(0);
		self.CenterOuter:SetScale(1, 1);
		self.CenterLineWork:SetScale(1, 1);
		self.CenterShadow:SetAlpha(0.4, 0.4);
		self.Icon:SetScale(0.9, 0.9);
		self.IconMask:SetScale(0.9, 0.9);
		self.CenterInner:SetScale(0.9, 0.9);
	else
		self.DialLineWork:SetRotation(math.pi);
		self.CenterLineWork:SetRotation(-(math.pi / 2));
		self.CenterOuter:SetScale(0.8, 0.8);
		self.CenterLineWork:SetScale(0.8, 0.8);
		self.CenterShadow:SetAlpha(0);
		self.CenterInner:SetScale(1, 1);
		self.Icon:SetScale(1, 1);
		self.IconMask:SetScale(1, 1);
		self.CenterInner:SetScale(1, 1);
	end
end

local flipbookAnimDuration =
{
	[Enum.Profession.Blacksmithing] = 2.6,
	[Enum.Profession.Enchanting] = 1.5,
	[Enum.Profession.Tailoring] = 3,
	[Enum.Profession.Jewelcrafting] = 1.2,
	[Enum.Profession.Alchemy] = 2.2,
	[Enum.Profession.Leatherworking] = 2.5,
	[Enum.Profession.Engineering] = 1.5,
	[Enum.Profession.Herbalism] = 1.5,
	[Enum.Profession.Mining] = 1.5,
	[Enum.Profession.Skinning] = 1.5,
	[Enum.Profession.Inscription] = 1.5,
};

local flipbookAnimEndDelay =
{
	[Enum.Profession.Jewelcrafting] = 2,
	[Enum.Profession.Mining] = 1.5,
};

function ProfessionsDetailedSpecPathMixin:UpdateAssets() -- Override
	local professionInfo = self:GetTalentFrame().professionInfo;
	local kitSpecifier = Professions.GetAtlasKitSpecifier(professionInfo);
	local fillArtAtlasFormat = "SpecDial_Fill_Flipbook_%s";
	local stylizedFillAtlasName = kitSpecifier and fillArtAtlasFormat:format(kitSpecifier);
	local stylizedFillInfo = stylizedFillAtlasName and C_Texture.GetAtlasInfo(stylizedFillAtlasName);
	local duration = flipbookAnimDuration[professionInfo.profession];
	if not stylizedFillInfo or not duration then
		stylizedFillAtlasName = fillArtAtlasFormat:format("DefaultBlue");
		stylizedFillInfo = C_Texture.GetAtlasInfo(stylizedFillAtlasName);
		duration = flipbookAnimDuration[Enum.Profession.Blacksmithing];
	end

	self.ProgressBar:SetSwipeTexture(stylizedFillInfo.file or stylizedFillInfo.filename);

	local frameSize = 330;
	self.flipBookNumRows = stylizedFillInfo.height / frameSize;
	self.flipBookNumCols = stylizedFillInfo.width / frameSize;
	self.timePerFrame = duration / (self.flipBookNumRows * self.flipBookNumCols);
	self.endDelay = flipbookAnimEndDelay[professionInfo.profession];
	self.flipBookULx = stylizedFillInfo.leftTexCoord;
	self.flipBookULy = stylizedFillInfo.topTexCoord;
	self.flipBookBRx = stylizedFillInfo.rightTexCoord;
	self.flipBookBRy = stylizedFillInfo.bottomTexCoord;

	self.frameRow = 1;
	self.frameCol = 1;

	local dividerAtlasFormat = "SpecDial_DividerGlow_%s";
	local stylizedDividerAtlasName = kitSpecifier and dividerAtlasFormat:format(kitSpecifier);
	local stylizedDividerInfo = stylizedDividerAtlasName and C_Texture.GetAtlasInfo(stylizedDividerAtlasName);
	if not stylizedDividerInfo then
		stylizedDividerAtlasName = dividerAtlasFormat:format("Blacksmithing");
	end
	self.DividerGlow:SetAtlas(stylizedDividerAtlasName, TextureKitConstants.UseAtlasSize);
end

function ProfessionsDetailedSpecPathMixin:OnUpdate(dt)
	if not self.timePerFrame then
		return;
	end

	if self.timeOnFrame then
		self.timeOnFrame = self.timeOnFrame + dt;
	end

	local isLastFrame = self.frameCol == self.flipBookNumCols and self.frameRow == self.flipBookNumRows;
	local frameTime = self.timePerFrame;
	if isLastFrame then
		frameTime = frameTime + (self.endDelay or 0);
	end
	if not self.timeOnFrame or self.timeOnFrame > frameTime then
		self.timeOnFrame = 0;
		self.frameCol = self.frameCol + 1;
		if self.frameCol > self.flipBookNumCols then
			self.frameCol = 1;
			self.frameRow = self.frameRow + 1;
			if self.frameRow > self.flipBookNumRows then
				self.frameRow = 1;
			end
		end

		local lowTexCoords =
		{
			x = Lerp(self.flipBookULx, self.flipBookBRx, (self.frameCol - 1) / self.flipBookNumCols),
			y = Lerp(self.flipBookULy, self.flipBookBRy, (self.frameRow - 1) / self.flipBookNumRows),
		};
		local highTexCoords =
		{
			x = Lerp(self.flipBookULx, self.flipBookBRx, self.frameCol / self.flipBookNumCols),
			y = Lerp(self.flipBookULy, self.flipBookBRy, self.frameRow / self.flipBookNumRows),
		};
		self.ProgressBar:SetTexCoordRange(lowTexCoords, highTexCoords);
	end
end