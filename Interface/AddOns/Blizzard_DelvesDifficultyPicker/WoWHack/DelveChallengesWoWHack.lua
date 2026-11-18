-- WoWHack-only implementation: expand Selection/SubTreeSelection nodes inline in the Delve challenges grid
-- instead of the default single-node display.

function DelveChallengesContainerFrameMixin.GetTemplateForTalentType(nodeInfo, _talentType, _useLarge)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) then
		return "TalentButtonSelectExpandedTemplate";
	end

	return "TalentButtonDelveChallengeCircleTemplate";
end

-- The original implementation of ShouldHideSingleRankNumbers() was a bit ambiguous,
-- so we created a specialized tooltip mixin that respects the ShouldHideSingleRankNumbers() logic.
-- We should eventually revisit the flag and make sure that is uniform along all trait
-- trees as intended. This was done here to fix it for WoWHack specifically.
local singleRankTooltipMixins = {};

local function GetSingleRankTooltipMixin(baseMixin)
	if not singleRankTooltipMixins[baseMixin] then
		local tooltipMixin = CreateFromMixins(baseMixin);
		function tooltipMixin:AddTooltipInfo(tooltip)
			if self:GetTalentFrame():ShouldHideSingleRankNumbers() then
				TalentDisplayMixin.AddTooltipInfo(self, tooltip);
			else
				baseMixin.AddTooltipInfo(self, tooltip);
			end
		end

		singleRankTooltipMixins[baseMixin] = tooltipMixin;
	end

	return singleRankTooltipMixins[baseMixin];
end

local DelveChallengesContainerFrameMixin_OnLoad = DelveChallengesContainerFrameMixin.OnLoad;
function DelveChallengesContainerFrameMixin:OnLoad()
	local getSpecializedMixin = self.getSpecializedMixin;
	self.getSpecializedMixin = function(nodeInfo, talentType)
		local baseMixin = getSpecializedMixin(nodeInfo, talentType);
		if baseMixin == TalentButtonSpendMixin then
			return GetSingleRankTooltipMixin(baseMixin);
		end
		return baseMixin;
	end;

	local getSpecializedChoiceMixin = self.getSpecializedChoiceMixin;
	self.getSpecializedChoiceMixin = function(entryInfo, talentType)
		local baseMixin = getSpecializedChoiceMixin(entryInfo, talentType) or TalentSelectionChoiceMixin;
		return GetSingleRankTooltipMixin(baseMixin);
	end;

	self.initializedChallengeConfigs = {};
	DelveChallengesContainerFrameMixin_OnLoad(self);
	self.buttonsMethod = TalentFrameGridSelectionMixin.GetButtonsInDefaultOrder;
end

function DelveChallengesContainerFrameMixin:LoadTalentTreeInternal()
	TalentFrameBaseMixin.LoadTalentTreeInternal(self);

	local configID = self:GetConfigID();
	if self.initializedChallengeConfigs[configID] then
		return;
	end
	self.initializedChallengeConfigs[configID] = true;

	if UnitInParty("player") and not UnitIsGroupLeader("player") then
		return;
	end

	local buttons = TalentFrameBaseMixin.GetButtonsInDefaultOrder(self);
	for _index, button in ipairs(buttons) do
		if button:HasProgress() or (button.HasSelectedEntryID and button:HasSelectedEntryID()) then
			return;
		end
	end

	local firstButton = buttons[1];
	if not firstButton or not firstButton:IsShown() then
		return;
	end

	local nodeInfo = firstButton:GetNodeInfo();
	if nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection then
		local entryID = nodeInfo.entryIDs[1];
		local entryInfo = entryID and self:GetAndCacheEntryInfo(entryID);
		if entryInfo and entryInfo.isAvailable and firstButton:CanSelectChoice() then
			self:SetSelection(firstButton:GetNodeID(), entryID);
		end
	elseif firstButton:CanPurchaseRank() then
		self:PurchaseRank(firstButton:GetNodeID());
	end
end
