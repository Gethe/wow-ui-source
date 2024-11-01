
UIPanelWindows["GenericTraitFrame"] = { area = "left", };

local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;

local GenericTraitFrameLayoutOptions = {
	-- Note: It might be a good idea to have a more generic style in the future but for
	-- now we're just going to use what we have.
	Default = {
		NineSliceTextureKit = "thewarwithin",
		TitleDividerAtlas = "dragonriding-talents-line",
		BackgroundAtlas = "ui-frame-thewarwithin-backgroundtile",
		HeaderSize = { Width = 500, Height = 50 },
		ShowInset = false,
		HeaderOffset = { x = 0, y = -30 },
		CurrencyOffset = { x = 0, y = -20 },
		CurrencyBackgroundAtlas = "dragonriding-talents-currencybg",
		PanOffset = { x = 0, y = 0 },
		ButtonPurchaseFXIDs = { 150, 142, 143 },
		CloseButtonOffset = { x = -9, y = -9 },
	},

	Dragonflight = {
		NineSliceTextureKit = "Dragonflight",
		DetailTopAtlas = "dragonflight-golddetailtop",
		BackgroundAtlas = "dragonriding-talents-background",
		HeaderSize = { Width = 500, Height = 130 },
		PanOffset = { x = -80, y = -35 },
		CloseButtonOffset = { x = -3, y = -10 },
		UseOldNineSlice = true,
	},

	Skyriding = {
		Title = GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE,
		HeaderSize = { Width = 500, Height = 130 },
		PanOffset = { x = -80, y = -35 },
	},

	TheWeaver = {
		Title = GENERIC_TRAIT_FRAME_THE_WEAVER_TITLE,
	},

	TheGeneral = {
		Title = GENERIC_TRAIT_FRAME_THE_GENERAL_TITLE,
	},

	TheVizier = {
		Title = GENERIC_TRAIT_FRAME_THE_VIZIER_TITLE,
	},
};

local GenericTraitFrameLayouts = {
	-- Add custom layouts in here

	-- Skyriding
	[672] = GenericTraitFrameLayoutOptions.Skyriding,

	-- Pact: The Weaver
	[1042] = GenericTraitFrameLayoutOptions.TheWeaver,

	-- Pact: The General
	[1045] = GenericTraitFrameLayoutOptions.TheGeneral,

	-- Pact: The Vizier
	[1046] = GenericTraitFrameLayoutOptions.TheVizier,
};

function GetGenericTraitFrameLayoutInfo(treeID)
	local layoutInfo = GenericTraitFrameLayouts[treeID] or {};
	return setmetatable(layoutInfo, {__index = GenericTraitFrameLayoutOptions.Default});
end

local GenericTraitFrameTutorials = {
	-- Dragonriding TreeID
	--[[ This tutorial is no longer needed or correct but keeping it here as an example of usage.
	[672] = {
		tutorial = {
			text = DRAGON_RIDING_SKILLS_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_SKILLS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = false,
		},
	},
	]]
};

local GenericTraitCurrencyTutorials = {
	-- Dragonriding
	[2563] = {
		tutorial = {
			text = DRAGON_RIDING_CURRENCY_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_GLYPHS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = true,
		},
	},
};


GenericTraitFrameMixin = {};

local GenericTraitFrameEvents = {
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

function GenericTraitFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);

	-- Show costs by default.
	local function GetDisplayTextFromTreeCurrency(treeCurrency)
		local flags, traitCurrencyType, currencyTypesID, overrideIcon = C_Traits.GetTraitCurrencyInfo(treeCurrency.traitCurrencyID);
		if overrideIcon then
			local width = 24;
			local height = 24;
			return CreateSimpleTextureMarkup(overrideIcon, width, height);
		end

		return nil;
	end

	self:SetTreeCurrencyDisplayTextCallback(GetDisplayTextFromTreeCurrency);
end

function GenericTraitFrameMixin:ApplyLayout(layoutInfo)
	self.Background:SetAtlas(layoutInfo.BackgroundAtlas);
	self.Header.Title:SetText(layoutInfo.Title or "");
	self.Header:SetSize(layoutInfo.HeaderSize.Width, layoutInfo.HeaderSize.Height);
	self.Header.TitleDivider:SetAtlas(layoutInfo.TitleDividerAtlas, true);
	self.Inset:SetShown(layoutInfo.ShowInset);
	self.Header:SetPoint("TOP", layoutInfo.HeaderOffset.x, layoutInfo.HeaderOffset.y);
	self.Currency:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", layoutInfo.CurrencyOffset.x, layoutInfo.CurrencyOffset.y);
	self.Currency.CurrencyBackground:SetAtlas(layoutInfo.CurrencyBackgroundAtlas, true);

	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layoutInfo.CloseButtonOffset.x, layoutInfo.CloseButtonOffset.y);

	local useNewNineSlice = not layoutInfo.UseOldNineSlice;

	self.NineSlice:SetShown(layoutInfo.NineSliceTextureKit ~= nil and not useNewNineSlice);
	self.BorderOverlay:SetShown(useNewNineSlice);

	if useNewNineSlice then
		local borderFrameTextureKitRegion = "UI-Frame-%s-Border";
		self.BorderOverlay:SetAtlas(borderFrameTextureKitRegion:format(layoutInfo.NineSliceTextureKit));
	else
		self.NineSlice.DetailTop:SetAtlas(layoutInfo.DetailTopAtlas, true);
		if layoutInfo.NineSliceTextureKit ~= nil then
			NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, layoutInfo.NineSliceTextureKit);
		end
	end

	self.basePanOffsetX = layoutInfo.PanOffset.x;
	self.basePanOffsetY = layoutInfo.PanOffset.y;

	self.buttonPurchaseFXIDs = layoutInfo.ButtonPurchaseFXIDs;
end

function GenericTraitFrameMixin:OnShow()
	-- Changes can happen to the tree while it was hidden that may require a full update so mark it
	-- as dirty before calling the base OnShow. For example, skyriding talents can be automatically
	-- purchased on level up.
	self:MarkTreeDirty();

	-- 11.0 Placeholder
	local treeID = self.traitTreeID;
	local layout = GetGenericTraitFrameLayoutInfo(treeID);
	self:ApplyLayout(layout);

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnShow");

	self:UpdateTreeCurrencyInfo();
	self:ShowGenericTraitFrameTutorial();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnHide");

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);
end

function GenericTraitFrameMixin:OnEvent(event, ...)
	TalentFrameBaseMixin.OnEvent(self, event, ...);

	if event == "TRAIT_SYSTEM_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		-- Hack: traitNodeInfo.canPurchaseRank is not getting updated after currency changes, so button state does not get updated.
		-- This is a temp fix to dirty all nodes to force it to get latest node info.
		local treeID = ...;
		if treeID == self:GetTalentTreeID() then
			for talentButton in self:EnumerateAllTalentButtons() do
				local nodeID = talentButton:GetNodeID();
				if nodeID then
					self:MarkNodeInfoCacheDirty(nodeID);
				end
			end
		end
	end
end

function GenericTraitFrameMixin:SetSystemID(systemID)
	local configID = C_Traits.GetConfigIDBySystemID(systemID);
	self:SetConfigID(configID);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetSystemID", systemID, configID);
end

function GenericTraitFrameMixin:SetTreeID(traitTreeID)
	self.traitTreeID = traitTreeID;

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetTreeID", traitTreeID, configID);
end

function GenericTraitFrameMixin:SetConfigID(configID, forceUpdate)
	if not forceUpdate and (configID == self:GetConfigID()) then
		return;
	end

	local configInfo = configID and C_Traits.GetConfigInfo(configID) or nil;
	if not configInfo then
		return;
	end

	TalentFrameBaseMixin.SetConfigID(self, configID);

	self.configurationInfo = configInfo;

	local forceTreeUpdate = true;
	self:SetTalentTreeID(self.configurationInfo.treeIDs[1], forceTreeUpdate);
end

function GenericTraitFrameMixin:GetConfigID()
	return self.configurationInfo and self.configurationInfo.ID or nil;
end

function GenericTraitFrameMixin:CheckAndReportCommitOperation()
	if not C_Traits.IsReadyForCommit() then
		self:ReportConfigCommitError();
		return false;
	end

	return TalentFrameBaseMixin.CheckAndReportCommitOperation(self);
end

function GenericTraitFrameMixin:AttemptConfigOperation(...)
	if TalentFrameBaseMixin.AttemptConfigOperation(self, ...) then
		if not self:CommitConfig() then
			UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
			self:MarkTreeDirty();
			return false;
		end

		return true;
	else
		self:MarkTreeDirty();
	end

	return false;
end

function GenericTraitFrameMixin:SetSelection(nodeID, entryID)
	if self:ShouldShowConfirmation() then
		local baseButton = self:GetTalentButtonByNodeID(nodeID);
		if baseButton and baseButton:IsMaxed() then
			self:SetSelectionCallback(nodeID, entryID);
			return;
		end

		local referenceKey = self;
		if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			StaticPopup_Hide("GENERIC_CONFIRMATION");
		end

		local cost = self:GetNodeCost(nodeID);
		local costStrings = self:GetCostStrings(cost);
		local costString = GENERIC_TRAIT_FRAME_CONFIRM_PURCHASE_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));

		local setSelectionCallback = GenerateClosure(self.SetSelectionCallback, self, nodeID, entryID);
		local customData = {
			text = costString,
			callback = setSelectionCallback,
			referenceKey = self,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	else
		self:SetSelectionCallback(nodeID, entryID);
	end
end

function GenericTraitFrameMixin:SetSelectionCallback(nodeID, entryID)
	if TalentFrameBaseMixin.SetSelection(self, nodeID, entryID) then
		if entryID then
			self:ShowPurchaseVisuals(nodeID);
			self:PlaySelectSoundForNode(nodeID);
		else
			self:PlayDeselectSoundForNode(nodeID);
		end
	end
end

function GenericTraitFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function GenericTraitFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local hasCurrencyInfo = currencyInfo ~= nil;
	self.Currency:SetShown(hasCurrencyInfo);
	if hasCurrencyInfo then
		local displayText = self.getDisplayTextFromTreeCurrency(currencyInfo);
		self.Currency:Setup(currencyInfo, displayText);
	end
end

function GenericTraitFrameMixin:GetFrameLevelForButton(nodeInfo)
	-- Overrides TalentFrameBaseMixin.

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((nodeInfo.posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	return TotalFrameLevelSpread - scaledYOffset;
end

function GenericTraitFrameMixin:IsLocked()
	-- Overrides TalentFrameBaseMixin.

	local canEditTalents, errorMessage = C_Traits.CanEditConfig(self:GetConfigID());
	return not canEditTalents, errorMessage;
end

function GenericTraitFrameMixin:PurchaseRank(nodeID)
	if self:ShouldShowConfirmation() then
		local referenceKey = self;
		if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			StaticPopup_Hide("GENERIC_CONFIRMATION");
		end

		local cost = self:GetNodeCost(nodeID);
		local costStrings = self:GetCostStrings(cost);
		local costString = GENERIC_TRAIT_FRAME_CONFIRM_PURCHASE_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));


		local purchaseRankCallback = GenerateClosure(self.PurchaseRankCallback, self, nodeID);
		local customData = {
			text = costString,
			callback = purchaseRankCallback,
			referenceKey = self,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	else
		self:PurchaseRankCallback(nodeID);
	end
end

function GenericTraitFrameMixin:PurchaseRankCallback(nodeID)
	if TalentFrameBaseMixin.PurchaseRank(self, nodeID) then
		self:ShowPurchaseVisuals(nodeID);
	end
end

function GenericTraitFrameMixin:ShowGenericTraitFrameTutorial()
	local treeID = self:GetTalentTreeID();
	if not treeID then
		return;
	end

	local nodeIDs = C_Traits.GetTreeNodes(treeID);

	local firstButton = self:GetTalentButtonByNodeID(nodeIDs[1]);
	local tutorialInfo = GenericTraitFrameTutorials[treeID];
	if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
		HelpTip:Show(self, tutorialInfo.tutorial, firstButton);
	end
end

function GenericTraitFrameMixin:ShowPurchaseVisuals(nodeID)
	if not self.buttonPurchaseFXIDs then
		return;
	end

	local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
	if buttonWithPurchase and buttonWithPurchase.PlayPurchaseCompleteEffect then
		buttonWithPurchase:PlayPurchaseCompleteEffect(self.FxModelScene, self.buttonPurchaseFXIDs);
	end
end

function GenericTraitFrameMixin:PlaySelectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlaySelectSound", nodeID);
end

function GenericTraitFrameMixin:PlayDeselectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlayDeselectSound", nodeID);
end

function GenericTraitFrameMixin:ShouldShowConfirmation()
	local traitSystemFlags = C_Traits.GetTraitSystemFlags(self:GetConfigID());
	return traitSystemFlags and FlagsUtil.IsSet(traitSystemFlags, Enum.TraitSystemFlag.ShowSpendConfirmation);
end


GenericTraitFrameCurrencyFrameMixin = {};

function GenericTraitFrameCurrencyFrameMixin:UpdateWidgetSet()
	local configID = self:GetParent():GetConfigID();
	self.uiWidgetSetID = configID and C_Traits.GetTraitSystemWidgetSetID(configID) or nil;
end

function GenericTraitFrameCurrencyFrameMixin:Setup(currencyInfo, displayText)
	displayText = displayText or "";
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);

	self.UnspentPointsCount:SetText(currencyText);
	self:UpdateWidgetSet();

	if currencyInfo and currencyInfo.traitCurrencyID then
		local tutorialInfo = GenericTraitCurrencyTutorials[currencyInfo.traitCurrencyID];
		if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial);
		end
	end
end

function GenericTraitFrameCurrencyFrameMixin:OnEnter()
	if not self.uiWidgetSetID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddWidgetSet(GameTooltip, self.uiWidgetSetID);
	GameTooltip:Show();
end
