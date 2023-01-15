
UIPanelWindows["GenericTraitFrame"] = { area = "left", };

local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;

local GenericTraitFrameLayoutOptions =
{
	Default = {
		NineSliceTextureKit = nil, 
		DetailTopAtlas = nil,
		Title = GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE,
		TitleDividerAtlas = nil,
		BackgroundAtlas = "ui-frame-dragonflight-backgroundtile", 
		HeaderSize = {
			Width = 500,
			Height = 50
		},
		ShowInset = true,
		HeaderOffset = { x = 0, y=0 },
		CurrencyOffset = { x=0, y=50 },
		CurrencyBackgroundAtlas = nil,
		PanOffset = {x=0, y=0},
		ButtonPurchaseFXIDs = nil,
	},
	Dragonflight = {
		NineSliceTextureKit = "Dragonflight", 
		DetailTopAtlas = "dragonflight-golddetailtop",
		Title = GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE,
		TitleDividerAtlas = "dragonriding-talents-line",
		BackgroundAtlas = "dragonriding-talents-background",
		HeaderSize = {
			Width = 500,
			Height = 130
		},
		ShowInset = false,
		HeaderOffset = { x = 0, y=-30 },
		CurrencyOffset = { x=0, y=-20 },
		CurrencyBackgroundAtlas = "dragonriding-talents-currencybg",
		PanOffset = {x=-80, y=-35},
		ButtonPurchaseFXIDs = {150, 142, 143},
	}
};

local genericTraitFrameTutorials = 
{ 
	-- DragonRiding TreeID
	[672] = 
	{ 
		tutorial = 
		{
			text = DRAGON_RIDING_SKILLS_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_SKILLS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = false,
		},
	},
}

local genericTraitCurrencyTutorials = 
{ 
	-- DragonRiding
	[2563] = 
	{ 
		tutorial = 
		{
			text = DRAGON_RIDING_CURRENCY_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_DRAGON_RIDING_GLYPHS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = true,
		},
	},
}

GenericTraitFrameMixin = {};

local GenericTraitFrameEvents = {
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED"
};

function GenericTraitFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);

	self:ApplyLayout(GenericTraitFrameLayoutOptions.Dragonflight)

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
	self.Header.Title:SetText(layoutInfo.Title);
	self.Header:SetSize(layoutInfo.HeaderSize.Width, layoutInfo.HeaderSize.Height);
	self.Header.TitleDivider:SetAtlas(layoutInfo.TitleDividerAtlas, true);
	self.Inset:SetShown(layoutInfo.ShowInset);
	self.Header:SetPoint("TOP", layoutInfo.HeaderOffset.x, layoutInfo.HeaderOffset.y);
	self.Currency:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", layoutInfo.CurrencyOffset.x, layoutInfo.CurrencyOffset.y);
	self.Currency.CurrencyBackground:SetAtlas(layoutInfo.CurrencyBackgroundAtlas, true);

	self.NineSlice.DetailTop:SetAtlas(layoutInfo.DetailTopAtlas, true);
	if layoutInfo.NineSliceTextureKit ~= nil then
		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, layoutInfo.NineSliceTextureKit);
	end
	self.NineSlice:SetShown(layoutInfo.NineSliceTextureKit ~= nil);

	self.basePanOffsetX = layoutInfo.PanOffset.x;
	self.basePanOffsetY = layoutInfo.PanOffset.y;

	self.buttonPurchaseFXIDs = layoutInfo.ButtonPurchaseFXIDs;
end

function GenericTraitFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	self:UpdateTreeCurrencyInfo();
	self:ShowGenericTraitFrameTutorial();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);

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
end

function GenericTraitFrameMixin:SetTreeID(traitTreeID)
	self.traitTreeID = traitTreeID;

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);
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

function GenericTraitFrameMixin:AttemptConfigOperation(...)
	if TalentFrameBaseMixin.AttemptConfigOperation(self, ...) then
		if not self:CommitConfig() then
			UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
		end
	end
end

function GenericTraitFrameMixin:SetSelection(nodeID, entryID)
	TalentFrameBaseMixin.SetSelection(self, nodeID, entryID );
	self:ShowPurchaseVisuals(nodeID);
end

function GenericTraitFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function GenericTraitFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo[1];
	local displayText = currencyInfo and self.getDisplayTextFromTreeCurrency(currencyInfo) or nil;
	self.Currency:Setup(currencyInfo, displayText); 
end

function GenericTraitFrameMixin:GetFrameLevelForButton(nodeInfo)
	-- Overrides TalentFrameBaseMixin.

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((nodeInfo.posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	return TotalFrameLevelSpread - scaledYOffset;
end

function GenericTraitFrameMixin:PurchaseRank(nodeID)
	-- Overrides TalentFrameBaseMixin.

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
end

function GenericTraitFrameMixin:PurchaseRankCallback( nodeID )
	TalentFrameBaseMixin.PurchaseRank(self, nodeID);
	self:ShowPurchaseVisuals(nodeID);
end


function GenericTraitFrameMixin:ShowGenericTraitFrameTutorial()
	
	local treeID = self:GetTalentTreeID();
	local nodeIDs = C_Traits.GetTreeNodes(self.talentTreeID);

	local firstButton = self:GetTalentButtonByNodeID(nodeIDs[1]);
	local tutorialInfo = genericTraitFrameTutorials[self.talentTreeID];
	if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial, firstButton);
	end
	
end

function GenericTraitFrameMixin:ShowPurchaseVisuals(nodeID)
	if (self.buttonPurchaseFXIDs == nil) then
		return;
	end

	local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
	if buttonWithPurchase and buttonWithPurchase.PlayPurchaseCompleteEffect then
		buttonWithPurchase:PlayPurchaseCompleteEffect(self.FxModelScene, self.buttonPurchaseFXIDs);
	end

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_LEARN_TALENT);
end

GenericTraitFrameCurrencyFrameMixin = { }; 
function GenericTraitFrameCurrencyFrameMixin:UpdateWidgetSet()
	local configID = self:GetParent():GetConfigID();
	if configID then
		self.uiWidgetSetID = C_Traits.GetTraitSystemWidgetSetID(configID); 
	else
		self.uiWidgetSetID = nil;
	end
end 

function GenericTraitFrameCurrencyFrameMixin:Setup(currencyInfo, displayText) 
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);

	self.UnspentPointsCount:SetText(currencyText);
	self:UpdateWidgetSet();

	if (currencyInfo and currencyInfo.traitCurrencyID) then 
		local tutorialInfo = genericTraitCurrencyTutorials[currencyInfo.traitCurrencyID];
		if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial);
		end
	end
end

function GenericTraitFrameCurrencyFrameMixin:OnEnter()
	if(not self.uiWidgetSetID) then 
		return; 
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddWidgetSet(GameTooltip, self.uiWidgetSetID);
	GameTooltip:Show();
end 