
-- Talent buttons are set up with 2 overlapping hierarchies to maximize reuse and reduce boilerplate.
--
-- The first hierarchy starts with TalentDisplayTemplate and covers the basic structure of the template:
-- textures, tooltip, etc. This does not include any dynamic states directly, such as availability
-- and purchased ranks. These can be set up through CalculateVisualState and ApplyVisualState. This also
-- doesn't not include any textures or fontstrings directly; those are covered by TalentButtonArtTemplate and
-- other visual templates. TalentDisplayTemplate can be used on its own for display purposes outside of the
-- usual usage directly on the talent frame (i.e. selection options).
--
-- The second hierarchy starts with TalentButtonBaseMixin which covers the basic structure of integration
-- into an actual talent frame with node information that includes some dynamic state. It is expected that
-- the actual behaviors of the buttons will be implemented by derived mixins like TalentButtonSpendMixin and
-- TalentButtonSelectMixin. These Mixins expect to be applied on top of a frame template that is derived
-- from TalentDisplayTemplate.

TalentButtonBaseMixin = {};

function TalentButtonBaseMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function TalentButtonBaseMixin:OnEnter()
	if self:ShouldBeVisible() then
		TalentDisplayMixin.OnEnter(self);
	end
end

function TalentButtonBaseMixin:OnDragStart()
	local spellID = self:GetSpellID();
	if spellID and not C_Spell.IsSpellPassive(spellID) then
		C_Spell.PickupSpell(spellID);
	end
end

function TalentButtonBaseMixin:UpdateEntryInfo(skipUpdate)
	-- Overrides TalentDisplayMixin.

	local previousEntryInfo = self.entryInfo;

	local hasEntryID = (self.entryID ~= nil);
	self.entryInfo = hasEntryID and self:GetTalentFrame():GetAndCacheEntryInfo(self.entryID) or nil;

	if (previousEntryInfo ~= nil) and hasEntryID then
		if previousEntryInfo.type ~= self.entryInfo.type then
			self:GetTalentFrame():ReleaseAndReinstantiateTalentButton(self);
			return;
		end
	end

	self:UpdateEntryContentIDs(skipUpdate);
end

function TalentButtonBaseMixin:SetNodeID(nodeID, skipUpdate)
	local oldNodeID = self.nodeID;
	self.nodeID = nodeID;
	self:UpdateNodeInfo(skipUpdate);
	self:GetTalentFrame():OnButtonNodeIDSet(self, oldNodeID, nodeID);
end

function TalentButtonBaseMixin:UpdateNodeInfo(skipUpdate)
	local nodeInfo = (self.nodeID ~= nil) and self:GetTalentFrame():GetAndCacheNodeInfo(self.nodeID) or nil;
	self.nodeInfo = nodeInfo;

	local hasNodeInfo = (nodeInfo ~= nil);
	self:SetEntryID((hasNodeInfo and nodeInfo.activeEntry) and nodeInfo.activeEntry.entryID or nil, skipUpdate);
	self:MarkEdgesDirty();
	self:GetTalentFrame():OnButtonUpdateNodeInfo(self.nodeID);
end

function TalentButtonBaseMixin:SetAttachedCard(card)
	self.attachedCard = card;

	if card then
		card:Attach(self);
	end
end

function TalentButtonBaseMixin:GetAttachedCard()
	return self.attachedCard;
end

function TalentButtonBaseMixin:MarkEdgesDirty()
	-- If talentFrame is nil we're being released and the edges will be cleaned up anyway.
	local talentFrame = self:GetTalentFrame();
	if talentFrame ~= nil then
		talentFrame:MarkEdgesDirty(self);
	end
end

function TalentButtonBaseMixin:GetNodeID()
	return self.nodeID;
end

function TalentButtonBaseMixin:GetNodeInfo()
	return self.nodeInfo;
end

-- Returns the SubTree this node belongs to (note this is NOT the same as GetEntrySubTreeID, which is only used by SubTreeSelection nodes)
function TalentButtonBaseMixin:GetNodeSubTreeID()
	return self.nodeInfo and self.nodeInfo.subTreeID;
end

-- True if this Node is part of a SubTree (note this is NOT the same as being a SubTreeSelection node)
function TalentButtonBaseMixin:IsSubTreeNode()
	return self:GetNodeSubTreeID() ~= nil;
end

function TalentButtonBaseMixin:OnTalentReset()
	self:ResetDynamic();
end

function TalentButtonBaseMixin:GetSpendText()
	local nodeInfo = self.nodeInfo;
	if nodeInfo then
		local entryInfo = self:GetEntryInfo();
		if entryInfo and entryInfo.type == Enum.TraitNodeEntryType.SpendSmallCircle then
			return "";
		end

		local ranksIncreased = nodeInfo.ranksIncreased or 0;
		local isSelectable = self:IsSelectable();
		-- Ranks Increased is not a part of a partial update, so we need to nil check ranksIncreased
		if nodeInfo.ranksPurchased < 1 and ranksIncreased < 1 and not isSelectable then
			return "";
		end

		if (nodeInfo.currentRank <= 1) and (nodeInfo.maxRanks == 1) and self:GetTalentFrame():ShouldHideSingleRankNumbers() then
			return "";
		end

		if (nodeInfo.ranksPurchased > 0) or isSelectable then
			return tostring(nodeInfo.currentRank);
		end
	end

	return "";
end

function TalentButtonBaseMixin:UpdateSpendText()
	if self.nodeInfo then
		local spendText = self:GetSpendText();
		TalentButtonUtil.SetSpendText(self, spendText);
	end
end

function TalentButtonBaseMixin:FullUpdate()
	local wasGhosted = self.isGhosted;

	-- TODO: need a better way to handle additional visual states on top of base state
	self.isGhosted = self:IsGhosted();

	TalentDisplayMixin.FullUpdate(self);

	self:UpdateSpendText();

	if wasGhosted and not self.isGhosted then
		self:MarkEdgesDirty();
	end

	self:UpdateMouseOverInfo();

	if self.attachedCard then
		self.attachedCard:Update();
	end
end

function TalentButtonBaseMixin:ResetDynamic()
	self:ResetActiveVisuals();
	self:StopGlow();
	self:FullUpdate();
end

function TalentButtonBaseMixin:ResetAll()
	local skipUpdate = true;
	self:SetNodeID(nil, skipUpdate);
	self:ResetDynamic();
end

function TalentButtonBaseMixin:UpdateVisualState()
	TalentDisplayMixin.UpdateVisualState(self);

	local visualState = self:GetVisualState();

	self:UpdateAnimations();

	-- Offset invisible nodes behind visible ones so that they don't intercept mouse input.
	-- Using a jump of 2 rather than 1 JUST IN CASE to avoid any floating point off-by-one shenanigans.
	-- Since Talent Frames have their own logic for determining base button frame levels,
	-- update it through our frame rather than overriding it ourselves directly and potentially conflicting.
	self.frameLevelOffset = visualState == TalentButtonUtil.BaseVisualState.Invisible and 0 or 2;
	self:GetTalentFrame():UpdateButtonFrameLevel(self);
end

function TalentButtonBaseMixin:CalculateVisualState()
	-- Overrides TalentDisplayMixin.

	if not self:ShouldBeVisible() then
		return TalentButtonUtil.BaseVisualState.Invisible;
	elseif self:IsRefundInvalid() then
		return TalentButtonUtil.BaseVisualState.RefundInvalid;
	elseif self:IsDisplayError() then
		return TalentButtonUtil.BaseVisualState.DisplayError;
	elseif self:IsMaxed() then
		return TalentButtonUtil.BaseVisualState.Maxed;
	elseif self:IsSelectable() then
		return TalentButtonUtil.BaseVisualState.Selectable;
	elseif self:HasProgress() then
		return TalentButtonUtil.BaseVisualState.Normal;
	elseif self:HasIncreasedRanks() then
		return TalentButtonUtil.BaseVisualState.Maxed;
	elseif self:IsGated() then
		return TalentButtonUtil.BaseVisualState.Gated;
	elseif self:IsLocked() then
		return TalentButtonUtil.BaseVisualState.Locked;
	else
		return TalentButtonUtil.BaseVisualState.Disabled;
	end
end

function TalentButtonBaseMixin:GetTraitCurrenciesCost()
	local nodeCost = self:GetTalentFrame():GetNodeCost(self.nodeID);
	if self.nodeInfo and (self.nodeInfo.type == Enum.TraitNodeType.Tiered) then
		return TalentUtil.CombineCostArrays(nodeCost, self:GetEntryInfo().entryCost);
	end

	return nodeCost;
end

function TalentButtonBaseMixin:AddTooltipCost(tooltip)
	-- Overrides TalentDisplayMixin.

	-- Only show cost if we can refund or increase the rank.
	if self:CanRefundRank() or not self:IsMaxed() then
		local traitCurrenciesCost = self:GetTraitCurrenciesCost();
		self:GetTalentFrame():AddCostToTooltip(tooltip, traitCurrenciesCost);
	end
end

function TalentButtonBaseMixin:AddTooltipErrors(tooltip)
	-- Overrides TalentDisplayMixin.

	local isRefundInvalid, refundInvalidInstructions = self:IsRefundInvalid();
	if TalentButtonUtil.CheckAddRefundInvalidInfo(tooltip, isRefundInvalid, refundInvalidInstructions) then
		return;
	end

	local talentFrame = self:GetTalentFrame()

	local shouldAddSpacer = true;
	talentFrame:AddConditionsToTooltip(tooltip, self.nodeInfo.conditionIDs, shouldAddSpacer);
	talentFrame:AddEdgeRequirementsToTooltip(tooltip, self:GetNodeID(), shouldAddSpacer);

	local isLocked, errorMessage = talentFrame:IsLocked();
	if isLocked and errorMessage then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, errorMessage);
	end
end

function TalentButtonBaseMixin:IsInDeactivatedSubTree()
	-- If a node is in a SubTree and subTreeActive isn't true, it's in a deactivated tree
	return self.nodeInfo and self.nodeInfo.subTreeID and not self.nodeInfo.subTreeActive;
end

function TalentButtonBaseMixin:ShouldBeVisible()
	return (self.nodeInfo ~= nil) and self.nodeInfo.isVisible and not self:IsInDeactivatedSubTree();
end

function TalentButtonBaseMixin:IsVisibleAndSelectable()
	return self:ShouldBeVisible() and self:IsSelectable();
end

function TalentButtonBaseMixin:IsRefundInvalid()
	return TalentButtonUtil.GetRefundInvalidInfo(self.nodeInfo);
end

function TalentButtonBaseMixin:HasProgress()
	-- Implement in your derived mixin.
	return false;
end

function TalentButtonBaseMixin:HasIncreasedRanks()
	-- Implement in your derived mixin.
	return false;
end

function TalentButtonBaseMixin:IsMaxed()
	-- Implement in your derived mixin.
	return false;
end

function TalentButtonBaseMixin:IsGated()
	-- Override in your derived mixin as desired.
	return not self.nodeInfo or not self.nodeInfo.isAvailable;
end

function TalentButtonBaseMixin:IsLocked()
	-- Override in your derived mixin as desired.
	return not self.nodeInfo or not self.nodeInfo.meetsEdgeRequirements or self:GetTalentFrame():IsLocked();
end

function TalentButtonBaseMixin:IsDisplayError()
	-- Override in your derived mixin as desired.

	-- The player must spent at least one point into the talent before it can be visually displayed as an error.
	if not self:HasProgress() then
		return false;
	end

	return self.nodeInfo and self.nodeInfo.isDisplayError;
end

function TalentButtonBaseMixin:IsCascadeRepurchasable()
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

	return self.nodeInfo and self.nodeInfo.isCascadeRepurchasable and self:CanAfford();
end

function TalentButtonBaseMixin:CanCascadeRepurchaseRanks()
	return not self:IsLocked() and not self:IsGated() and self:IsCascadeRepurchasable();
end

function TalentButtonBaseMixin:HasMassPurchase()
	return self:GetTalentFrame():HasMassPurchase();
end

function TalentButtonBaseMixin:IsGhosted()
	-- Override in your derived mixin as desired.

	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

	return not self.nodeInfo or self:IsCascadeRepurchasable();
end

function TalentButtonBaseMixin:CanAfford()
	-- Override in your derived mixin as desired.
	if not self.nodeID then
		return false;
	end

	return self:GetTalentFrame():CanAfford(self:GetTraitCurrenciesCost());
end

function TalentButtonBaseMixin:CanRefundRank()
	-- Override in your derived mixin as desired.
	return self.nodeInfo and not self:IsInspecting() and not self:GetTalentFrame():IsLocked() and self.nodeInfo.canRefundRank and self.nodeInfo.ranksPurchased and (self.nodeInfo.ranksPurchased > 0);
end

function TalentButtonBaseMixin:IsSelectable()
	-- Override in your derived mixin as desired.
	return not self:IsMaxed() and not self:IsLocked() and self:CanAfford();
end

function TalentButtonBaseMixin:CascadeRepurchaseRanks()
	self:PlaySelectSound();
	self:GetTalentFrame():CascadeRepurchaseRanks(self:GetNodeID());
	self:UpdateMouseOverInfo();
end

function TalentButtonBaseMixin:ClearCascadeRepurchaseHistory()
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return;
	end

	self:PlayDeselectSound();
	self:GetTalentFrame():ClearCascadeRepurchaseHistory();
	self:UpdateMouseOverInfo();
end

function TalentButtonBaseMixin:PlaySelectSound()
	if self.selectSound then
		PlaySound(self.selectSound);
	else
		self:GetTalentFrame():PlaySelectSoundForButton(self);
	end
end

function TalentButtonBaseMixin:PlayDeselectSound()
	if self.deselectSound then
		PlaySound(self.deselectSound);
	else
		self:GetTalentFrame():PlayDeselectSoundForButton(self);
	end
end

function TalentButtonBaseMixin:StartGlow()
	local entryInfo = self:GetEntryInfo();
	local isCircular = entryInfo and (entryInfo.type == Enum.TraitNodeEntryType.SpendCircle);
	if isCircular then
		if not self.circularGlowTexture then
			self.circularGlowTexture = CreateFrame("FRAME", nil, self, "TalentButtonCircularGlowTemplate");
		end

		self.circularGlowTexture:SetFrameLevel(self:GetFrameLevel() - 1);
		self.circularGlowTexture:Show();
		GlowEmitterFactory:Hide(self);
	else
		local width = nil;
		GlowEmitterFactory:Show(self, GlowEmitterMixin.Anims.GreenGlow, 26, 0, width, self:GetHeight() + 52);

		if self.circularGlowTexture then
			self.circularGlowTexture:Hide();
		end
	end
end

function TalentButtonBaseMixin:StopGlow()
	GlowEmitterFactory:Hide(self);

	if self.circularGlowTexture then
		self.circularGlowTexture:Hide();
	end
end
