
UIPanelWindows["GenericTraitFrame"] = { area = "left", };

local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;

local GENERIC_TRAIT_FRAME_DEFAULT_PORTRIAT_TEXTURE = "Interface\\ICONS\\Ability_DragonRiding_Launch01";


GenericTraitFrameMixin = {};

local GenericTraitFrameEvents = {
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED"
};

function GenericTraitFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);

	self:SetTitle(GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE);

	-- Show costs by default.
	local function GetDisplayTextFromTreeCurrency(treeCurrency)
		local flags, traitCurrencyType, currencyTypesID, overrideIcon = C_Traits.GetTraitCurrencyInfo(treeCurrency.traitCurrencyID);
		if overrideIcon then
			local width = 16;
			local height = 16;
			return CreateSimpleTextureMarkup(overrideIcon, width, height);
		end

		return nil;
	end

	

	self:SetTreeCurrencyDisplayTextCallback(GetDisplayTextFromTreeCurrency);
end

function GenericTraitFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	self:UpdateTreeCurrencyInfo();

	if UnitExists("npc") then
		SetPortraitTexture(self.PortraitOverlay.Portrait, "npc");
	else
		-- TODO: get from data
		self.PortraitOverlay.Portrait:SetTexture(GENERIC_TRAIT_FRAME_DEFAULT_PORTRIAT_TEXTURE);
	end
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);
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

function GenericTraitFrameMixin:AttemptConfigOperation(...)
	if TalentFrameBaseMixin.AttemptConfigOperation(self, ...) then
		if not self:CommitConfig() then
			UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
		end
	end
end

function GenericTraitFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function GenericTraitFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo[1];
	local displayText = currencyInfo and self.getDisplayTextFromTreeCurrency(currencyInfo) or nil;

	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);

	self.Currency.UnspentPointsCount:SetText(currencyText);
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

	local purchaseRankCallback = GenerateClosure(TalentFrameBaseMixin.PurchaseRank, self, nodeID);
	local customData = {
		text = costString,
		callback = purchaseRankCallback,
		referenceKey = self,
	};

	StaticPopup_ShowCustomGenericConfirmation(customData);
end
