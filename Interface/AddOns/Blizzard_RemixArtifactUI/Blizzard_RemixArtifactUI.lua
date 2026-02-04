RemixArtifactFrameMixin = {};

local RemixArtifactFrameEvents = {
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
	"TRY_PURCHASE_TO_NODE_PARTIAL_SUCCESS",
};

function RemixArtifactFrameMixin:OnLoad()
	-- This needs to be a part of the ButtonsParent frame for layering reasons since it's flattened by clipChildren
	self.ButtonsParent.Overlay = CreateFrame("FRAME", nil, self.ButtonsParent, "RemixArtifactButtonsParentOverlayTemplate");

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

	TalentFrameBaseMixin.OnLoad(self);

	-- Reset Popup Data should be set before init of controls
	local resetPopupData = {
		text = REMIX_ARTIFACT_RESPEC_POPUP_DESC,
		acceptText = REMIX_ARTIFACT_RESPEC_POPUP_CONFIRM,
		cancelText = REMIX_ARTIFACT_RESPEC_POPUP_CANCEL,
		callback = function()
			local traitTreeID = self:GetTalentTreeID();
			self:AttemptConfigOperation(C_Traits.ResetTree, traitTreeID);
		end,
	};
	self.CommitConfigControls:SetResetPopupData(resetPopupData);
	self.CommitConfigControls:Init();

	local attributes = {
		area = "center",
		whileDead = 1,
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 1,
		checkFitExtraWidth = 200,
		checkFitExtraHeight = 140,
	};
	RegisterUIPanel(RemixArtifactFrame, attributes);
end

local HEADER_WIDTH = 500;
local HEADER_HEIGHT = 50;
local BUTTON_PURCHASE_FXIDS = { 150, 142, 143 };

function RemixArtifactFrameMixin:UpdateLayout()
	self.Header:SetSize(HEADER_WIDTH, HEADER_HEIGHT);
	self.buttonPurchaseFXIDs = BUTTON_PURCHASE_FXIDS;
end

function RemixArtifactFrameMixin:OnShow()

	-- Changes can happen to the tree while it was hidden that may require a full update so mark it
	-- as dirty before calling the base OnShow.
	self:MarkTreeDirty();

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, RemixArtifactFrameEvents);

	self:UpdateTreeCurrencyInfo();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);

	local shown = true;
	EventRegistry:TriggerEvent("RemixArtifactFrame.VisibilityUpdated", shown);
end

function RemixArtifactFrameMixin:OnHide()
	C_RemixArtifactUI.ClearRemixArtifactItem();

	-- We need this to occur before calling the base to clean up some functionality
	local shown = false;
	EventRegistry:TriggerEvent("RemixArtifactFrame.VisibilityUpdated", shown);

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, RemixArtifactFrameEvents);

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);
end

function RemixArtifactFrameMixin:OnEvent(event, ...)
	TalentFrameBaseMixin.OnEvent(self, event, ...);

	if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
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
	elseif event == "TRY_PURCHASE_TO_NODE_PARTIAL_SUCCESS" then
		local nodeID = ...;
		self:PlaySelectSoundForNode(nodeID);
		self:ShowPurchaseVisuals(nodeID);
	end
end

function RemixArtifactFrameMixin:UpdateTraitTree()
	self:UpdateLayout();

	local itemID = C_RemixArtifactUI.GetCurrArtifactItemID();
	local traitTreeID = C_RemixArtifactUI.GetCurrTraitTreeID();

	-- If the item hasn't been set up in C++ yet we want to return here
	if not itemID or not traitTreeID then
		return;
	end

	self:SetArtifactItem(itemID);

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	EventRegistry:TriggerEvent("RemixArtifactFrame.SetTreeID", traitTreeID, configID);
end

function RemixArtifactFrameMixin:SetArtifactItem(itemID)
	self.attachedItemID = itemID;

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.continuableContainer = ContinuableContainer:Create();
	self.continuableContainer:AddContinuable(Item:CreateFromItemID(self.attachedItemID));
	self.continuableContainer:ContinueOnLoad(function()
		self:RefreshTitle();
		self:RefreshBackgroundModel();
		self:RefreshBackground();
	end);
end

function RemixArtifactFrameMixin:CheckAndReportCommitOperation()
	if not C_Traits.IsReadyForCommit() then
		self:ReportConfigCommitError();
		return false;
	end

	return TalentFrameBaseMixin.CheckAndReportCommitOperation(self);
end

function RemixArtifactFrameMixin:HasValidConfig()
	return (self:GetConfigID() ~= nil) and (self:GetTalentTreeID() ~= nil);
end

function RemixArtifactFrameMixin:HasAnyConfigChanges()
	if self:IsCommitInProgress() then
		return false;
	end

	return self:HasValidConfig() and C_Traits.ConfigHasStagedChanges(self:GetConfigID());
end

function RemixArtifactFrameMixin:AttemptConfigOperation(...)
	local operationSuccessful = TalentFrameBaseMixin.AttemptConfigOperation(self, ...);
	self.CommitConfigControls:UpdateConfigButtonsState();

	if not operationSuccessful then
		self:MarkTreeDirty();
	end

	return operationSuccessful;
end

function RemixArtifactFrameMixin:SetSelection(nodeID, entryID)
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

function RemixArtifactFrameMixin:SetSelectionCallback(nodeID, entryID)
	if TalentFrameBaseMixin.SetSelection(self, nodeID, entryID) then
		if entryID then
			self:ShowPurchaseVisuals(nodeID);
			self:PlaySelectSoundForNode(nodeID);
		else
			self:PlayDeselectSoundForNode(nodeID);
		end
	end
end

function RemixArtifactFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function RemixArtifactFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local hasCurrencyInfo = currencyInfo ~= nil;
	self.Currency:SetShown(hasCurrencyInfo);
	if hasCurrencyInfo then
		local displayText = self.getDisplayTextFromTreeCurrency and self.getDisplayTextFromTreeCurrency(currencyInfo);
		self.Currency:Setup(currencyInfo, displayText);
	end
end

function RemixArtifactFrameMixin:IsLocked()
	-- Overrides TalentFrameBaseMixin.

	local canEditTalents, errorMessage = C_Traits.CanEditConfig(self:GetConfigID());
	return not canEditTalents, errorMessage;
end

function RemixArtifactFrameMixin:PurchaseRank(nodeID)
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

function RemixArtifactFrameMixin:PurchaseRankCallback(nodeID)
	if TalentFrameBaseMixin.PurchaseRank(self, nodeID) then
		self:ShowPurchaseVisuals(nodeID);
	end
end

function RemixArtifactFrameMixin:ShowPurchaseVisuals(nodeID)
	if not self.buttonPurchaseFXIDs then
		return;
	end

	local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
	if buttonWithPurchase and buttonWithPurchase.PlayPurchaseCompleteEffect then
		buttonWithPurchase:PlayPurchaseCompleteEffect(self.FxModelScene, self.buttonPurchaseFXIDs);
	end
end

function RemixArtifactFrameMixin:PlaySelectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlaySelectSound", nodeID);
end

function RemixArtifactFrameMixin:PlayDeselectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlayDeselectSound", nodeID);
end

function RemixArtifactFrameMixin:ShouldShowConfirmation()
	local traitSystemFlags = C_Traits.GetTraitSystemFlags(self:GetConfigID());
	return traitSystemFlags and FlagsUtil.IsSet(traitSystemFlags, Enum.TraitSystemFlag.ShowSpendConfirmation);
end

function RemixArtifactFrameMixin:RefreshBackgroundModel()
	local itemID, altItemID, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_RemixArtifactUI.GetArtifactItemInfo();
	local uiCameraID, altHandUICameraID = C_RemixArtifactUI.GetAppearanceInfoByID(artifactAppearanceID);

	self.Model.uiCameraID = uiCameraID;
	if itemAppearanceID then
		self.Model:SetItemAppearance(itemAppearanceID);
	else
		self.Model:SetItem(itemID, appearanceModID);
	end

	local baseModelFrameLevel = 505;
	local baseAltModelFrameLevel = 500;
	if altOnTop then
		baseModelFrameLevel, baseAltModelFrameLevel = baseAltModelFrameLevel, baseModelFrameLevel;
	end

	self.Model:SetFrameLevel(baseModelFrameLevel);

	if altItemID and altHandUICameraID then
		self.AltModel.uiCameraID = altHandUICameraID;
		if altItemAppearanceID then
			self.AltModel:SetItemAppearance(altItemAppearanceID);
		else
			self.AltModel:SetItem(altItemID, appearanceModID);
		end

		self.AltModel:Show();
		self.AltModel:SetFrameLevel(baseAltModelFrameLevel);
	else
		self.AltModel:Hide();
	end
end

function RemixArtifactFrameMixin:RefreshBackground()
	local artifactArtInfo = C_RemixArtifactUI.GetArtifactArtInfo();
	if artifactArtInfo and artifactArtInfo.textureKit then
		self.textureKit = artifactArtInfo.textureKit;

		local bgAtlas = ("%s-BG"):format(artifactArtInfo.textureKit);
		self.Background:SetAtlas(bgAtlas, TextureKitConstants.UseAtlasSize);
	else
		self.textureKit = nil;
	end
end

function RemixArtifactFrameMixin:RefreshTitle()
	local artifactArtInfo = C_RemixArtifactUI.GetArtifactArtInfo();
	
	self.Header.Title:Show();
	self.Header.Title:SetText(artifactArtInfo.titleName);
end

function RemixArtifactFrameMixin:GetFrameLevelForButton(nodeInfo, visualState)
	return 750;
end

function RemixArtifactFrameMixin:GetFrameLevelForEdge(startButton, unused_endButton)
	return startButton:GetFrameLevel() - 10;
end

function RemixArtifactFrameMixin:GetButtonAnimationStates()
	return {
		{ TalentButtonAnimUtil.TalentButtonAnimState.Increased, "BronzeIncreasedNodeAnim" },
		{ TalentButtonAnimUtil.TalentButtonAnimState.Infinite, "BronzeInfiniteIncreasedNodeAnim" },
	};
end

function RemixArtifactFrameMixin:TryPurchaseToNode(nodeID)
	if self:AttemptConfigOperationWithErrorsSuppressed(C_Traits.TryPurchaseToNode, nodeID) then
		self:PlaySelectSoundForNode(nodeID);
		self:ShowPurchaseVisuals(nodeID);

		return true;
	end

	return false;
end

function RemixArtifactFrameMixin:TryRefundToNode(nodeID, entryID)
	if self:AttemptConfigOperationWithErrorsSuppressed(C_Traits.TryRefundToNode, nodeID, entryID) then
		self:PlayDeselectSoundForNode(nodeID);

		return true;
	end

	return false;
end

RemixArtifactCurrencyFrameMixin = {};

function RemixArtifactCurrencyFrameMixin:Setup(currencyInfo, displayText)
	displayText = displayText or "";
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);
	local LEGION_REMIX_TRAIT_CURRENCY_TYPE_ID = 3268;
	self.currencyTypeID = LEGION_REMIX_TRAIT_CURRENCY_TYPE_ID;
	self.UnspentPointsCount:SetText(currencyText);
end

function RemixArtifactCurrencyFrameMixin:OnEnter()
	if not self.currencyTypeID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:SetCurrencyByID(self.currencyTypeID);
	GameTooltip:Show();
end

RemixArtifactModelMixin = {}

function RemixArtifactModelMixin:OnLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

local function ApplyRemixArtifactUICamera(self, uiCameraID)
	local posX, posY, posZ, yaw, pitch, roll, _animId, _animVariation, _animFrame, centerModel = GetUICameraInfo(uiCameraID);
	if posX and posY and posZ and yaw and pitch and roll then
		self:MakeCurrentCameraCustom();
		self:SetPaused(true);

		self:SetPosition(posX, posY, posZ);
		self:SetFacing(yaw);
		self:SetPitch(pitch);
		self:SetRoll(roll);
		self:UseModelCenterToTransform(centerModel);

		local cameraX, cameraY, cameraZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_POSITION):GetXYZ();
		local targetX, targetY, targetZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_TARGET):GetXYZ();

		self:SetCameraPosition(cameraX, cameraY, cameraZ);
		self:SetCameraTarget(targetX, targetY, targetZ);
	end

	local CUSTOM_ANIMATION_SEQUENCE = 213;
	local animationSequence = self:HasAnimation(CUSTOM_ANIMATION_SEQUENCE) and CUSTOM_ANIMATION_SEQUENCE or 0;
	self:FreezeAnimation(animationSequence, 0, 1);
end

function RemixArtifactModelMixin:OnEvent()
	self:RefreshCamera();
	if self.uiCameraID then
		ApplyRemixArtifactUICamera(self, self.uiCameraID);
	end
end

function RemixArtifactModelMixin:OnModelLoaded()
	if self.uiCameraID then
		ApplyRemixArtifactUICamera(self, self.uiCameraID);
	end

	local lightValues = { omnidirectional = false, point = CreateVector3D(0, 0, 0), ambientIntensity = .7, ambientColor = CreateColor(1, 1, 1), diffuseIntensity = 0, diffuseColor = CreateColor(1, 1, 1) };
	local enabled = true;
	self:SetLight(enabled, lightValues);
	self:SetViewTranslation(-88, 0);
end

RemixArtifactUtil = {};

local LegionTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonLegionSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonLegionCircleTemplate",
	[Enum.TraitNodeEntryType.SpendSmallCircle] = "TalentButtonLegionSmallCircleTemplate",
	[Enum.TraitNodeEntryType.SpendInfinite] = "TalentButtonLegionInfiniteNode",
};

function RemixArtifactUtil.GetTemplateForTalentType(nodeInfo, talentType, _useLarge)
	-- By default, any use of SubTreeSelection nodes without a bespoke override will treat them like regular Selection nodes
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowExpandedSelection) then
			return "TalentButtonSelectExpandedTemplate";
		end

		return "TalentButtonLegionChoiceTemplate"
	end

	-- Anything without a specific shared template will be a circle for now.
	return LegionTemplatesByTalentType[talentType] or "TalentButtonLegionCircleTemplate";
end

local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

function RemixArtifactUtil.GetEdgeTemplateType(edgeVisualStyle)
	return TemplatesByEdgeVisualStyle[edgeVisualStyle];
end
