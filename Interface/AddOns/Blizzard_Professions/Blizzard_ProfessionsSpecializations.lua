
g_professionsSpecsSelectedTabs = {};
g_professionsSpecsSelectedPaths = {};


StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_ASK_TO_SAVE"] = 
{
	text = PROFESSIONS_SPECIALIZATION_ASK_TO_SAVE,
	button1 = YES,
	button2 = NO,

	OnAccept = function(self, info)
		info.onAccept();
	end,

	OnCancel = function(self, info)
		info.onCancel();
	end,

	hideOnEscape = 1,
};

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

StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_PATH"] = 
{
	text = PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_PATH_TITLE,
	button1 = YES,
	button2 = CANCEL,

	OnAccept = function(self, info)
		info.onAccept();
	end,

	OnShow = function(self, info)
		self.SubText:SetText(PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_PATH:format(info.pathName));
		self.SubText:Show();
	end,

	hideOnEscape = 1,
};


ProfessionsSpecFrameMixin = {};

function ProfessionsSpecFrameMixin:GetDesiredPageWidth()
	return 1105;
end

function ProfessionsSpecFrameMixin:ConfigureButtons()
	self.ApplyButton:SetScript("OnClick", function() self:CommitConfig(); end);
	self.UndoButton:SetScript("OnClick", function() self:RollbackConfig(); end)

	self.UnlockTabButton:SetScript("OnClick", function()
		self:CheckConfirmPurchaseTab();
	end);
	self.UnlockTabButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DetailedView.SpendPointsButton:SetScript("OnClick", function()
		self:PurchaseRank(self:GetDetailedPanelNodeID(), C_ProfSpecs.GetSpendEntryForPath(self:GetDetailedPanelNodeID()));
	end);

	self.DetailedView.RefundPointsButton:SetScript("OnClick", function()
		self:AttemptConfigOperation(C_Traits.RefundRank, self:GetDetailedPanelNodeID());
	end);

	self.DetailedView.UnlockPathButton:SetScript("OnClick", function()
		self:CheckConfirmPurchasePath();
	end);
	self.DetailedView.UnlockPathButton:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsSpecFrameMixin:CheckConfirmPurchasePath()
	if not self:AnyPopupShown() then
		local info = {};
		info.onAccept = function()
			self:PurchaseRank(self:GetDetailedPanelNodeID(), C_ProfSpecs.GetUnlockEntryForPath(self:GetDetailedPanelNodeID()));
			local configID = self:GetConfigID();
			self:CommitConfig();
			C_Traits.StageConfig(configID);
		end;

		info.pathName = self.DetailedView.Path:GetName();

		StaticPopup_Show("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_PATH", info.pathName, nil, info);
	end
end

function ProfessionsSpecFrameMixin:CheckConfirmPurchaseTab()
	if not self:AnyPopupShown() then
		local info = {};
		info.onAccept = function()
			self:PurchaseRank(self.tabInfo.rootNodeID, C_ProfSpecs.GetUnlockEntryForPath(self.tabInfo.rootNodeID));
			self:CommitConfig();
			EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", self.tabInfo.rootNodeID);
		end;

		info.specName = self.tabInfo.name;
		info.profName = self.professionInfo.professionName;

		StaticPopup_Show("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", self.tabInfo.name, self.professionInfo.professionName, info);
	end
end

function ProfessionsSpecFrameMixin:RegisterCallbacks()
	local function PathSelectedCallback(_, selectedID)
		self:SetDetailedPanel(selectedID);
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
	self:UpdateTreeCurrencyInfo();

	for tab, _ in self.tabsPool:EnumerateActive() do
		tab:UpdateState();
	end

	-- HRO TODO: Remove. Traits API should send an update here.
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

local staticPopups =
{
	"PROFESSIONS_SPECIALIZATION_ASK_TO_SAVE",
	"PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB",
	"PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_PATH",
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

	-- HRO TODO: Remove. Traits API should send an update here.
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
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
	elseif event == "TRAIT_CONFIG_UPDATED" then
		self:UpdateDetailedPanel();
	-- HRO TODO: Remove. Traits API should send an update here.
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		local updatedCurrencyTypesID = ...;
		if self.tabSpendCurrency then
			local _, _, currencyTypesID = C_Traits.GetTraitCurrencyInfo(self.tabSpendCurrency);
			if currencyTypesID == updatedCurrencyTypesID then
				self:UpdateTreeCurrencyInfo();
				self:MarkTreeDirty();
				self:UpdateDetailedPanel();
			end
		end
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

	local tabs = {};
	for _, traitTreeID in ipairs(tabTreeIDs) do
		local tab = self.tabsPool:Acquire();
		if tab:Init(traitTreeID) then
			table.insert(tabs, tab);
		end
	end

	local rowSize = 9;
	local xPadding = -10;
	local yPadding = 0;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, rowSize, xPadding, yPadding);
	local initialAnchor = AnchorUtil.CreateAnchor("BOTTOMLEFT", self.TreeView, "TOPLEFT", 60, 0);
	AnchorUtil.GridLayout(tabs, initialAnchor, layout);

	EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self:GetDefaultTab(tabTreeIDs));
end

function ProfessionsSpecFrameMixin:UpdateTreeCurrencyInfo() -- Override
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfoMap[self.tabSpendCurrency];
	self.TreeView.UnspentPointsCount:SetText(GREEN_FONT_COLOR:WrapTextInColorCode(currencyInfo and currencyInfo.quantity or 0));
end

function ProfessionsSpecFrameMixin.getTemplateType(nodeInfo, talentType)
	return "ProfessionsSpecPathTemplate";
end

function ProfessionsSpecFrameMixin.getSpecializedMixin(nodeInfo, talentType)
	return ProfessionsSpecPathMixin;
end

function ProfessionsSpecFrameMixin:InstantiateTalentButton(nodeID, xPos, yPos) -- Override
	local talentNodeInfo = self:GetAndCacheTalentNodeInfo(nodeID);

	local activeEntryID = talentNodeInfo.activeEntry and talentNodeInfo.activeEntry.entryID or nil;
	local entryInfo = (activeEntryID ~= nil) and self:GetAndCacheEntryInfo(activeEntryID) or nil;
	local talentType = (entryInfo ~= nil) and entryInfo.type or nil;
	local function InitTalentButton(newTalentButton)
		newTalentButton:SetTalentNodeID(nodeID);
		newTalentButton:SetAndApplySize(newTalentButton.iconSize, newTalentButton.iconSize);
		TalentButtonUtil.ApplyPosition(newTalentButton, self, xPos, yPos)
		newTalentButton:SetSelected(nodeID == self:GetDetailedPanelNodeID());
		newTalentButton:Show();
	end

	local offsetX = nil;
	local offsetY = nil;
	local newTalentButton = self:AcquireTalentButton(talentNodeInfo, talentType, offsetX, offsetY, InitTalentButton);

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
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1300 },
			[2] = { rotationBetweenChildren = 0, distanceToChild = 1300 },
			[3] = { rotationBetweenChildren = 0, distanceToChild = 1300 },
			[4] = { rotationBetweenChildren = 0, distanceToChild = 1300 },
			[5] = { rotationBetweenChildren = 0, distanceToChild = 1300 },
		},
		[2] =
		{
			[1] = { rotationBetweenChildren = 90, distanceToChild = 1300 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1300 },
			[3] = { rotationBetweenChildren = 90, distanceToChild = 1300 },
			[4] = { rotationBetweenChildren = 90, distanceToChild = 1300 },
			[5] = { rotationBetweenChildren = 90, distanceToChild = 1300 },
		},
		[3] =
		{
			[1] = { rotationBetweenChildren = 70, distanceToChild = 1300 },
			[2] = { rotationBetweenChildren = 70, distanceToChild = 1300 },
			[3] = { rotationBetweenChildren = 70, distanceToChild = 1300 },
			[4] = { rotationBetweenChildren = 80, distanceToChild = 1300 },
		},
		[4] =
		{
			[1] = { rotationBetweenChildren = 60, distanceToChild = 1300 },
			[2] = { rotationBetweenChildren = 60, distanceToChild = 1300 },
			[3] = { rotationBetweenChildren = 55, distanceToChild = 1300 },
		},
		[5] =
		{
			[1] = { rotationBetweenChildren = 40, distanceToChild = 1300 },
			[2] = { rotationBetweenChildren = 40, distanceToChild = 1300 },
		},
		--forceNumChildren = 4,
	},
	[PathLayers.Secondary] =
	{
		[1] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1000 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1000 },
			[3] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
			[4] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
			[5] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
		},
		[2] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1000 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1000 },
			[3] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
			[4] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
			[5] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
		},
		[3] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1000 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1000 },
			[3] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
			[4] = { rotationBetweenChildren = 40, distanceToChild = 1000 },
		},
		[4] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1000 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1000 },
			[3] = { rotationBetweenChildren = 30, distanceToChild = 1000 },
		},
		[5] =
		{
			[1] = { rotationBetweenChildren = 0, distanceToChild = 1000 },
			[2] = { rotationBetweenChildren = 90, distanceToChild = 1000 },
		},
		--forceNumChildren = 3,
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

	-- HRO TODO: Remove. For testing different numbers of children
	maxLayerChildren[PathLayers.Primary] = PathLayoutInfo[PathLayers.Primary].forceNumChildren or maxLayerChildren[PathLayers.Primary];
	maxLayerChildren[PathLayers.Secondary] = PathLayoutInfo[PathLayers.Secondary].forceNumChildren or maxLayerChildren[PathLayers.Secondary];

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

		-- HRO TODO: Remove. For testing different numbers of children
		if PathLayoutInfo[currLayer].forceNumChildren ~= nil then
			local forceNumChildren = PathLayoutInfo[currLayer].forceNumChildren;
			local dupChildID = childrenIDs[1];
			childrenIDs = {};
			for i = 1, forceNumChildren do
				table.insert(childrenIDs, dupChildID)
			end
			numChildren = forceNumChildren;
		end

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

	local rootPosX = 4220;
	local rootPosY = 2800;
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

	self.ApplyButton:SetShown(not isLocked);
	self.UndoButton:SetShown(not isLocked);
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
	self.TreeView.TreeDescription:SetWidth(280);
	self.TreeView.TreeDescription:SetText(self.tabInfo.description);

	local forceUpdate = true;
	self:SetTalentTreeID(traitTreeID, forceUpdate);

	self.tabSpendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self.tabInfo.rootNodeID);
	self:UpdateTreeCurrencyInfo();
	
	self:UpdateSelectedTabState();

	local detailedViewNode = g_professionsSpecsSelectedPaths[traitTreeID] or self.tabInfo.rootNodeID;
	EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", detailedViewNode);

	self:UpdateConfigButtonsState()
	self:HideAllPopups();
end

function ProfessionsSpecFrameMixin:Refresh(professionInfo)
	if not Professions.InLocalCraftingMode() 
	   or not C_ProfSpecs.SkillLineHasSpecialization(professionInfo.professionID)
	   or (self.professionInfo ~= nil and self.professionInfo.professionID == professionInfo.professionID) then
		return;
	end

	self:ClearInfoCaches();

	self.professionInfo = professionInfo;
	self:SetConfigID(C_ProfSpecs.GetConfigIDForSkillLine(professionInfo.professionID));
	self:InitializeTabs();
	self.TreeView.Background:SetAtlas(Professions.GetProfessionBackgroundAtlas(professionInfo), TextureKitConstants.UseAtlasSize);
	self.TreeView.ProfessionName:SetText(string.upper(professionInfo.parentProfessionName));
end

function ProfessionsSpecFrameMixin:GetDetailedPanelPath()
	return self.DetailedView.Path;
end

function ProfessionsSpecFrameMixin:GetDetailedPanelNodeID()
	return self:GetDetailedPanelPath():GetTalentNodeID();
end

function ProfessionsSpecFrameMixin:GetRootNodeID()
	return self.tabInfo.rootNodeID;
end

function ProfessionsSpecFrameMixin:SetDetailedPanel(pathID)
	self:GetDetailedPanelPath():SetTalentNodeID(pathID);

	self:UpdateDetailedPanel();
	self:HideAllPopups();
end

function ProfessionsSpecFrameMixin:UpdateDetailedPanelPerks()
	self.perksPool:ReleaseAll();

	local unlockPerkFound = false;
	local perkIDs = C_ProfSpecs.GetPerksForPath(self:GetDetailedPanelNodeID());
	for _, perkID in ipairs(perkIDs) do
		local perk = self.perksPool:Acquire();
		perk:Init(self);
		perk:SetPerkID(perkID);

		local rotation = perk:GetRotation();
		local distanceFromPath = 99;
		-- sin/cos swapped due to 90 degree phase shift, negation due to clockwise rotation
		local xOfs = -(distanceFromPath * math.sin(rotation));
		local yOfs = -(distanceFromPath * math.cos(rotation));

		-- Handle overlap of 0 and max rank perks, since they both have 0 rotaton
		local unlockRank = C_ProfSpecs.GetUnlockRankForPerk(perkID);
		local _, maxRank = self:GetDetailedPanelPath():GetRanks();
		if unlockRank == 0 then
			unlockPerkFound = true;
		elseif unlockRank == maxRank and unlockPerkFound then
			yOfs = yOfs - 32;
		end

		perk:SetPoint("CENTER", self:GetDetailedPanelPath(), "CENTER", xOfs, yOfs);

		perk:Show();
	end
end

function ProfessionsSpecFrameMixin:UpdateDetailedPanel()
	local detailedViewPath = self:GetDetailedPanelPath();
	detailedViewPath:UpdateTalentNodeInfo();

	local nodeID = self:GetDetailedPanelNodeID();

	self.DetailedView.PathName:SetText(detailedViewPath:GetName());
	local currRank, maxRank = detailedViewPath:GetRanks();
	self.DetailedView.PointsText:SetFormattedText(PROFESSIONS_SPECS_POINTS_SPENT_FORMAT, currRank, maxRank);
	local state = C_ProfSpecs.GetStateForPath(nodeID, self:GetConfigID());
	local canPurchase = detailedViewPath:GetNextEntry() ~= nil and C_Traits.CanPurchaseRank(self:GetConfigID(), nodeID, detailedViewPath:GetNextEntry()) and detailedViewPath:CanAfford();

	local canRefund = C_ProfSpecs.CanRefundPath(nodeID, self:GetConfigID());
	local showPointsButtons = (state == Enum.ProfessionsSpecPathState.Progressing) or (state == Enum.ProfessionsSpecPathState.Completed);
	self.DetailedView.RefundPointsButton:SetShown(showPointsButtons);
	self.DetailedView.SpendPointsButton:SetShown(showPointsButtons);
	self.DetailedView.PointsText:SetShown(showPointsButtons);
	if showPointsButtons then
		self.DetailedView.RefundPointsButton:SetEnabled(canRefund);
		self.DetailedView.SpendPointsButton:SetEnabled(canPurchase);
	end

	local showUnlockButton = (state == Enum.ProfessionsSpecPathState.Locked) and nodeID ~= self.tabInfo.rootNodeID;
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

	self:UpdateDetailedPanelPerks();
	self:UpdateNextPerkText();
end

function ProfessionsSpecFrameMixin:SetDefaultPath(pathID)
	g_professionsSpecsSelectedPaths[self:GetTalentTreeID()] = pathID;
end

function ProfessionsSpecFrameMixin:SetDefaultTab(tabID)
	g_professionsSpecsSelectedTabs[self:GetProfessionID()] = tabID;
end

function ProfessionsSpecFrameMixin:PurchaseRank(pathID, entryID)
	self:AttemptConfigOperation(C_Traits.PurchaseRank, pathID, entryID)
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
	self.DetailedView.RefundPointsButton:SetEnabled(false);
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
	self.UndoButton:SetEnabledState(hasAnyChanges);

	if hasAnyChanges then
		GlowEmitterFactory:Show(self.ApplyButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
	end
end

function ProfessionsSpecFrameMixin:UpdateNextPerkText()
	local descriptionText = self:GetDetailedPanelPath():GetNextPerkDescription();
	self.DetailedView.NextPerkText:SetText(descriptionText);
end