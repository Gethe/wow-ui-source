
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


TalentDisplayMixin = {};

function TalentDisplayMixin:OnEnter()
	local spellID = self:GetSpellID();
	local spell = (spellID ~= nil) and Spell:CreateFromSpellID(spellID) or nil;
	if spell and not spell:IsSpellEmpty() then
		self.spellLoadCancel = spell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.SetTooltipInternal, self));
	else
		self:SetTooltipInternal();
	end
end

function TalentDisplayMixin:OnLeave()
	GameTooltip_Hide();

	if self.spellLoadCancel then
		self.spellLoadCancel();
		self.spellLoadCancel = nil;
	end

	if self.overrideSpellLoadCancel then
		self.overrideSpellLoadCancel();
		self.overrideSpellLoadCancel = nil;
	end
end

function TalentDisplayMixin:Init(talentFrame)
	self.talentFrame = talentFrame;
end

function TalentDisplayMixin:OnRelease()
	-- We don't do a full reset for efficency. The next time the button is acquired it'll end up being updated.

	self.visualState = nil;
	self.spellLoadCancel = nil;
end

function TalentDisplayMixin:SetTooltipInternal()
	local tooltip = self:AcquireTooltip();
	self:AddTooltipTitle(tooltip);

	-- Used for debug purposes.
	EventRegistry:TriggerEvent("TalentDisplay.TooltipHook", self);

	self:AddTooltipInfo(tooltip);
	self:AddTooltipDescription(tooltip);
	self:AddTooltipCost(tooltip);
	self:AddTooltipInstructions(tooltip);
	self:AddTooltipErrors(tooltip);
	tooltip:Show();
end

function TalentDisplayMixin:AcquireTooltip()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	return tooltip;
end

function TalentDisplayMixin:SetTalentID(talentID, skipUpdate)
	self.talentID = talentID;
	self:UpdateTalentInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateTalentInfo(skipUpdate)
	local talentID = self.talentID;
	self.talentInfo = (talentID ~= nil) and self:GetTalentFrame():GetAndCacheTalentInfo(talentID) or nil;

	if not skipUpdate then
		self:FullUpdate();
	end

	if self:IsMouseOver() then
		self:OnEnter();
	end
end

function TalentDisplayMixin:SetEntryID(entryID, skipUpdate)
	self.entryID = entryID;
	self:UpdateEntryInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateEntryInfo(skipUpdate)
	local hasEntryID = (self.entryID ~= nil);
	self.entryInfo = hasEntryID and self:GetTalentFrame():GetAndCacheEntryInfo(self.entryID) or nil;

	self:SetTalentID(hasEntryID and self.entryInfo.talentID or nil, skipUpdate);
end

function TalentDisplayMixin:GetTalentID()
	return self.talentID;
end

function TalentDisplayMixin:GetEntryID()
	return self.entryID;
end

function TalentDisplayMixin:GetTalentInfo()
	return self.talentInfo;
end

function TalentDisplayMixin:GetEntryInfo()
	return self.entryInfo;
end

function TalentDisplayMixin:GetSpellID()
	return (self.talentInfo ~= nil) and self.talentInfo.spellID or nil;
end

function TalentDisplayMixin:GetOverrideIcon()
	return self.talentInfo.overrideIcon;
end

function TalentDisplayMixin:CalculateIconTexture()
	return TalentButtonUtil.CalculateIconTexture(self.talentInfo, self:GetSpellID());
end

function TalentDisplayMixin:UpdateIconTexture()
	self.Icon:SetTexture(self:CalculateIconTexture());
end

function TalentDisplayMixin:GetActiveIcon()
	return self.Icon:GetTexture();
end

function TalentDisplayMixin:UpdateVisualState()
	self:SetVisualState(self:CalculateVisualState());
end

function TalentDisplayMixin:FullUpdate()
	self:UpdateVisualState();
	self:UpdateIconTexture();
end

function TalentDisplayMixin:SetVisualState(visualState)
	if self.visualState == visualState then
		return;
	end

	self.visualState = visualState;

	self:ApplyVisualState(visualState);

	-- TODO:: Temporary hack to implement visibility.
	local previousAlpha = self:GetAlpha();
	local newAlpha = (visualState ~= TalentButtonUtil.BaseVisualState.Invisible) and 1.0 or 0.0;
	if not ApproximatelyEqual(previousAlpha, newAlpha) then
		self:SetAlpha(newAlpha);
	end
end

function TalentDisplayMixin:GetVisualState()
	return self.visualState;
end

function TalentDisplayMixin:GetName()
	return TalentButtonUtil.GetTalentName(self.talentInfo.overrideName, self:GetSpellID());
end

function TalentDisplayMixin:GetSubtext()
	return self.talentInfo.talentSubtext or GetSpellSubtext(self:GetSpellID());
end

function TalentDisplayMixin:AddTooltipTitle(tooltip)
	GameTooltip_SetTitle(tooltip, self:GetName());
end

function TalentDisplayMixin:AddTooltipInfo(tooltip)
	if self:ShouldShowSubText() then
		local talentSubtext = self:GetSubtext();
		if talentSubtext then
			GameTooltip_AddDisabledLine(tooltip, talentSubtext);
		end
	end

	local spellID = self:GetSpellID();
	if spellID then
		local overrideSpellID = C_SpellBook.GetOverrideSpell(spellID);
		if overrideSpellID ~= spellID then
			local overrideSpell = Spell:CreateFromSpellID(overrideSpellID);
			if overrideSpell and not overrideSpell:IsSpellDataCached() then
				self.overrideSpellLoadCancel = overrideSpell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.SetTooltipInternal, self));
			elseif strcmputf8i(self:GetName(), overrideSpell:GetSpellName()) ~= 0 then
				GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_REPLACED_BY_FORMAT:format(overrideSpell:GetSpellName()), SPELL_LINK_COLOR);
			end
		end
	end
end

function TalentDisplayMixin:AddTooltipDescription(tooltip)
	if self.talentNodeInfo then
		local activeEntry = self.talentNodeInfo.activeEntry;
		if activeEntry then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			tooltip:AddTraitEntry(activeEntry.entryID, activeEntry.rank);
		end

		local nextEntry = self.talentNodeInfo.nextEntry;
		if nextEntry and self.talentNodeInfo.ranksPurchased > 0 then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
			tooltip:AddTraitEntry(nextEntry.entryID, nextEntry.rank);
		end
	elseif self.entryID then
		-- If this tooltip isn't coming from a node, we can't know what rank to show other than 1.
		local rank = 1;
		tooltip:AddTraitEntry(self.entryID, rank);
	end
end

function TalentDisplayMixin:AddTooltipErrors(tooltip)
	local shouldAddSpacer = true;
	self:GetTalentFrame():AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer);
end

function TalentDisplayMixin:GetTalentFrame()
	return self.talentFrame;
end

function TalentDisplayMixin:SetAndApplySize(width, height)
	-- Override in your derived mixin.
	self:SetSize(width, height);
end

function TalentDisplayMixin:CalculateVisualState()
	-- Implement in your derived mixin.
	return TalentButtonUtil.BaseVisualState.Normal;
end

function TalentDisplayMixin:ShouldShowSubText()
	-- Implement in your derived mixin.
	return false;
end

function TalentDisplayMixin:AddTooltipCost(tooltip)
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:AddTooltipInstructions(tooltip)
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:ApplyVisualState(visualState)
	-- Implement in your derived mixin.
end


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
	if spellID then
		PickupSpell(spellID);
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

	self:SetTalentID(hasEntryID and self.entryInfo.talentID or nil, skipUpdate);
end

function TalentButtonBaseMixin:SetTalentNodeID(talentNodeID, skipUpdate)
	local oldNodeID = self.talentNodeID;
	self.talentNodeID = talentNodeID;
	self:UpdateTalentNodeInfo(skipUpdate);
	self:GetTalentFrame():OnButtonNodeIDSet(self, oldNodeID, talentNodeID);
end

function TalentButtonBaseMixin:UpdateTalentNodeInfo(skipUpdate)
	local talentNodeInfo = (self.talentNodeID ~= nil) and self:GetTalentFrame():GetAndCacheTalentNodeInfo(self.talentNodeID) or nil;
	self.talentNodeInfo = talentNodeInfo;

	local hasTalentNodeInfo = (talentNodeInfo ~= nil);
	self:SetEntryID((hasTalentNodeInfo and talentNodeInfo.activeEntry) and talentNodeInfo.activeEntry.entryID or nil, skipUpdate);
	self:MarkEdgesDirty();
end

function TalentButtonBaseMixin:MarkEdgesDirty()
	-- If talentFrame is nil we're being released and the edges will be cleaned up anyway.
	local talentFrame = self:GetTalentFrame();
	if talentFrame ~= nil then
		talentFrame:MarkEdgesDirty(self);
	end
end

function TalentButtonBaseMixin:GetTalentNodeID()
	return self.talentNodeID;
end

function TalentButtonBaseMixin:GetTalentNodeInfo()
	return self.talentNodeInfo;
end

function TalentButtonBaseMixin:OnTalentReset()
	self:ResetDynamic();
end

function TalentButtonBaseMixin:GetSpendText()
	local nodeInfo = self.talentNodeInfo;
	if nodeInfo then
		if (nodeInfo.ranksPurchased < 1) and not self:IsSelectable() then
			return "";
		end

		if (nodeInfo.ranksPurchased > 0) or (nodeInfo.currentRank < nodeInfo.maxRanks) then
			return tostring(nodeInfo.currentRank);
		end
	end

	return "";
end

function TalentButtonBaseMixin:UpdateSpendText()
	if self.talentNodeInfo then
		self.SpendText:SetText(self:GetSpendText());
	end
end

function TalentButtonBaseMixin:FullUpdate()
	TalentDisplayMixin.FullUpdate(self);

	self:UpdateSpendText();
end

function TalentButtonBaseMixin:ResetDynamic()
	self:FullUpdate();
end

function TalentButtonBaseMixin:ResetAll()
	local skipUpdate = true;
	self:SetTalentNodeID(nil, skipUpdate);
	self:ResetDynamic();
end

function TalentButtonBaseMixin:UpdateVisualState()
	TalentDisplayMixin.UpdateVisualState(self);

	-- TODO:: Revisit the implementation of invisible buttons.
	local visualState = self:GetVisualState();
	if visualState == TalentButtonUtil.BaseVisualState.Invisible then
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1);
	else
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
	end
end

function TalentButtonBaseMixin:CalculateVisualState()
	-- Overrides TalentDisplayMixin.

	if not self:ShouldBeVisible() then
		return TalentButtonUtil.BaseVisualState.Invisible;
	elseif self:IsMaxed() then
		return TalentButtonUtil.BaseVisualState.Maxed;
	elseif self:IsSelectable() then
		return TalentButtonUtil.BaseVisualState.Selectable;
	elseif self:HasProgress() then
		return TalentButtonUtil.BaseVisualState.Normal;
	elseif self:IsGated() then
		return TalentButtonUtil.BaseVisualState.Gated;
	elseif self:IsLocked() then
		return TalentButtonUtil.BaseVisualState.Locked;
	else
		return TalentButtonUtil.BaseVisualState.Disabled;
	end
end

function TalentButtonBaseMixin:GetTraitCurrenciesCost()
	return self:GetTalentFrame():GetNodeCost(self.talentNodeID);
end

function TalentButtonBaseMixin:AddTooltipCost(tooltip)
	-- Overrides TalentDisplayMixin.

	local traitCurrenciesCost = self:GetTraitCurrenciesCost();
	self:GetTalentFrame():AddCostToTooltip(tooltip, traitCurrenciesCost);
end

function TalentButtonBaseMixin:AddTooltipErrors(tooltip)
	-- Overrides TalentDisplayMixin.

	local shouldAddSpacer = true;
	self:GetTalentFrame():AddConditionsToTooltip(tooltip, self.talentNodeInfo.conditionIDs, shouldAddSpacer);
end

function TalentButtonBaseMixin:ShouldBeVisible()
	return (self.talentNodeInfo ~= nil) and self.talentNodeInfo.isVisible;
end

function TalentButtonBaseMixin:IsVisibleAndSelectable()
	return self:ShouldBeVisible() and self:IsSelectable();
end

function TalentButtonBaseMixin:HasProgress()
	-- Implement in your derived mixin.
	return false;
end

function TalentButtonBaseMixin:IsMaxed()
	-- Implement in your derived mixin.
	return false;
end

function TalentButtonBaseMixin:IsGated()
	-- Override in your derived mixin as desired.
	return not self.talentNodeInfo or not self.talentNodeInfo.isAvailable;
end

function TalentButtonBaseMixin:IsLocked()
	-- Override in your derived mixin as desired.
	return not self.talentNodeInfo or not self.talentNodeInfo.meetsEdgeRequirements;
end

function TalentButtonBaseMixin:CanAfford()
	-- Override in your derived mixin as desired.
	if not self.talentNodeID then
		return false;
	end

	return self:GetTalentFrame():CanAfford(self:GetTraitCurrenciesCost());
end

function TalentButtonBaseMixin:IsSelectable()
	-- Override in your derived mixin as desired.
	return not self:IsMaxed() and not self:IsLocked() and self:CanAfford();
end


TalentButtonBasicArtMixin = {};

TalentButtonBasicArtMixin.SizingAdjustment = {
	Circle = {
		{ region = "Icon", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "BorderShadow", adjust = -2, },
		{ region = "StateBorder", adjust = -4, },
		{ region = "Border2", adjust = -4, },
		{ region = "Border", adjust = -7, },
		{ region = "IconMask", adjust = -8, },
		{ region = "BorderMask", adjust = -7, },
		{ region = "Border2Mask", adjust = -4, },
		{ region = "BorderShadowMask", adjust = -2, },
		{ region = "DisabledOverlayMask", adjust = -3, },
	},

	ProfessionPerk = {
		{ region = "Icon", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "BorderShadow", adjust = 2, },
		{ region = "StateBorder", adjust = 0, },
		{ region = "Border2", adjust = 0, },
		{ region = "Border", adjust = -3, },
		{ region = "IconMask", adjust = -4, },
		{ region = "BorderMask", adjust = -3, },
		{ region = "Border2Mask", adjust = 0, },
		{ region = "BorderShadowMask", adjust = 2, },
	},
};

function TalentButtonBasicArtMixin:OnLoad()
	self:ApplySize(self:GetSize());
end

function TalentButtonBasicArtMixin:ApplyVisualState(visualState)
	local color = TalentButtonUtil.GetColorForBaseVisualState(visualState);
	local r, g, b = color:GetRGB();
	self.SpendText:SetTextColor(r, g, b);
	self.StateBorder:SetColorTexture(r, g, b);

	local isGated = (visualState == TalentButtonUtil.BaseVisualState.Gated);
	self.Icon:SetAlpha(isGated and 0.5 or 1.0);
	self.DisabledOverlay:SetAlpha(isGated and 0.7 or 0.3);

	local isLocked = isGated or (visualState == TalentButtonUtil.BaseVisualState.Locked);
	self.Icon:SetDesaturated(isLocked);

	local isDisabled = isLocked or (visualState == TalentButtonUtil.BaseVisualState.Disabled);
	self.DisabledOverlay:SetShown(isDisabled);
end

function TalentButtonBasicArtMixin:SetAndApplySize(width, height)
	self:SetSize(width, height);
	self:ApplySize(width, height);
end

function TalentButtonBasicArtMixin:ApplySize(width, height)
	local sizingAdjustment = self.sizingAdjustment;
	if sizingAdjustment == nil then
		return;
	end

	for i, sizingAdjustmentInfo in ipairs(sizingAdjustment) do
		local adjustment = sizingAdjustmentInfo.adjust;
		self[sizingAdjustmentInfo.region]:SetSize(width + adjustment, height + adjustment);
	end
end


TalentButtonArtMixin = {};

TalentButtonArtMixin.ArtSet = {
	Square = {
		iconMask = nil,
		shadow = "talents-node-square-shadow",
		normal = "talents-node-square-gray",
		selectable = "talents-node-square-green",
		maxed = "talents-node-square-yellow",
		locked = "talents-node-square-locked",
	},

	Circle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-circle-shadow",
		normal = "talents-node-circle-gray",
		selectable = "talents-node-circle-green",
		maxed = "talents-node-circle-yellow",
		locked = "talents-node-circle-locked",
	},

	Choice = {
		iconMask = "talents-node-choice-mask",
		shadow = "talents-node-choice-shadow",
		normal = "talents-node-choice-gray",
		selectable = "talents-node-choice-green",
		maxed = "talents-node-choice-yellow",
		locked = "talents-node-choice-locked",
	},
};

function TalentButtonArtMixin:OnLoad()
	self:ApplySize(self:GetSize());

	if not self.artSet.iconMask then
		self.IconMask:Hide();
		self.DisabledOverlayMask:Hide();
	else
		self.IconMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
		self.DisabledOverlayMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
	end

	self.Shadow:SetAtlas(self.artSet.shadow, TextureKitConstants.UseAtlasSize);
end

function TalentButtonArtMixin:ApplyVisualState(visualState)
	local color = TalentButtonUtil.GetColorForBaseVisualState(visualState);
	local r, g, b = color:GetRGB();
	self.SpendText:SetTextColor(r, g, b);

	local isGated = (visualState == TalentButtonUtil.BaseVisualState.Gated);
	self.DisabledOverlay:SetAlpha(isGated and 0.7 or 0.25);

	local isLocked = isGated or (visualState == TalentButtonUtil.BaseVisualState.Locked);
	self.Icon:SetDesaturated(isLocked);

	local isDisabled = isLocked or (visualState == TalentButtonUtil.BaseVisualState.Disabled);
	self.DisabledOverlay:SetShown(isDisabled);

	if isGated then
		self.StateBorder:SetAtlas(self.artSet.locked, TextureKitConstants.UseAtlasSize);
	elseif visualState == TalentButtonUtil.BaseVisualState.Selectable then
		self.StateBorder:SetAtlas(self.artSet.selectable, TextureKitConstants.UseAtlasSize);
	elseif visualState == TalentButtonUtil.BaseVisualState.Maxed then
		self.StateBorder:SetAtlas(self.artSet.maxed, TextureKitConstants.UseAtlasSize);
	else
		self.StateBorder:SetAtlas(self.artSet.normal, TextureKitConstants.UseAtlasSize);
	end
end

function TalentButtonArtMixin:SetAndApplySize(width, height)
	self:SetSize(width, height);
	self:ApplySize(width, height);
end

function TalentButtonArtMixin:ApplySize(width, height)
	local sizingAdjustment = self.sizingAdjustment;
	if sizingAdjustment == nil then
		return;
	end

	for i, sizingAdjustmentInfo in ipairs(sizingAdjustment) do
		local adjustment = sizingAdjustmentInfo.adjust;
		self[sizingAdjustmentInfo.region]:SetSize(width + adjustment, height + adjustment);
	end
end

function TalentButtonArtMixin:GetCircleEdgeDiameterOffset(unused_angle)
	return TalentButtonUtil.CircleEdgeDiameterOffset;
end

function TalentButtonArtMixin:GetSquareEdgeDiameterOffset(angle)
	local quarterRotation = math.pi / 2;
	local eighthRotation = quarterRotation / 2;
	local progress = math.abs(((eighthRotation + angle) % quarterRotation) - eighthRotation);
	return Lerp(TalentButtonUtil.SquareEdgeMinDiameterOffset, TalentButtonUtil.SquareEdgeMaxDiameterOffset, progress);
end

function TalentButtonArtMixin:GetChoiceEdgeDiameterOffset(angle)
	local eighthRotation = math.pi / 4;
	local sixteenthRotation = eighthRotation / 2;
	local progress = math.abs(((sixteenthRotation + angle) % eighthRotation) - sixteenthRotation);
	return Lerp(TalentButtonUtil.ChoiceEdgeMinDiameterOffset, TalentButtonUtil.ChoiceEdgeMaxDiameterOffset, progress);
end


TalentButtonSplitIconMixin = {};

function TalentButtonSplitIconMixin:ApplyVisualState(visualState)
	TalentButtonArtMixin.ApplyVisualState(self, visualState);

	local desaturation = self.Icon:GetDesaturation();
	self.Icon2:SetDesaturation(desaturation);
end

function TalentButtonSplitIconMixin:SetSplitIconShown(isSplitShown)
	self.IconSplitMask:SetShown(isSplitShown);
	self.Icon2:SetShown(isSplitShown);
end


TalentButtonSpendMixin = CreateFromMixins(TalentButtonBaseMixin);

function TalentButtonSpendMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if button == "LeftButton" then
		if self:CanPurchaseRank() then
			self:PurchaseRank();
		end
	elseif button == "RightButton" then
		if self:CanRefundRank() then
			self:RefundRank();
		end
	end
end

function TalentButtonSpendMixin:Init(...)
	TalentDisplayMixin.Init(self, ...);

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
end

function TalentButtonSpendMixin:CheckTooltip()
	if self:IsMouseOver() then
		ExecuteFrameScript(self, "OnEnter");
	end
end

function TalentButtonSpendMixin:CanPurchaseRank()
	return not self:IsLocked() and self.talentNodeInfo.canPurchaseRank and self:CanAfford();
end

function TalentButtonSpendMixin:CanRefundRank()
	-- We shouldn't be checking ranksPurchased directly.
	return not self:IsLocked() and self.talentNodeInfo.canRefundRank and self.talentNodeInfo.ranksPurchased and (self.talentNodeInfo.ranksPurchased > 0);
end

function TalentButtonSpendMixin:PurchaseRank()
	self:GetTalentFrame():PurchaseRank(self:GetTalentNodeID());
	self:CheckTooltip();
end

function TalentButtonSpendMixin:RefundRank()
	self:GetTalentFrame():RefundRank(self:GetTalentNodeID(), self:GetEntryID());
	self:CheckTooltip();
end

function TalentButtonSpendMixin:IsSelectable()
	return self:CanPurchaseRank();
end

function TalentButtonSpendMixin:IsMaxed()
	local activeRank = (self.talentNodeInfo ~= nil) and self.talentNodeInfo.activeRank or 0;
	return (activeRank > 0) and (activeRank >= self.talentNodeInfo.maxRanks);
end

function TalentButtonSpendMixin:HasProgress()
	return self.talentNodeInfo.activeRank > 0;
end

function TalentButtonSpendMixin:ResetDynamic()
	local talentNodeID = self:GetTalentNodeID();
	if talentNodeID ~= nil then
		self:GetTalentFrame():RefundAllRanks(talentNodeID);
	end

	TalentButtonBaseMixin.ResetDynamic(self);
end

function TalentButtonSpendMixin:AddTooltipInfo(tooltip)
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(self.talentNodeInfo.currentRank, self.talentNodeInfo.maxRanks));

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentButtonSpendMixin:AddTooltipInstructions(tooltip)
	TalentDisplayMixin.AddTooltipInstructions(self, tooltip);

	local canPurchase = self:CanPurchaseRank();
	local canRefund = self:CanRefundRank();
	if canPurchase or canRefund then
		GameTooltip_AddBlankLineToTooltip(tooltip);
	end

	if canPurchase then
		GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS);
	elseif canRefund then
		GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS);
	end
end


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

local TimeToHideSeconds = 0.5;
local TimeToShowSelections = 0.2;
function TalentButtonSelectMixin:OnUpdate(dt)
	local talentFrame = self:GetTalentFrame();
	if not talentFrame:IsMouseOverSelections() and (GetMouseFocus() ~= self) then
		self.timeSinceMouseOver = self.timeSinceMouseOver + dt;
		if self.timeSinceMouseOver > TimeToHideSeconds then
			self:ClearSelections();
		end
	end

	if self.isMouseOver then
		self.mouseOverTime = self.mouseOverTime + dt;
		if (self.mouseOverTime > TimeToShowSelections) and not talentFrame:AreSelectionsOpen(self) then
			talentFrame:ShowSelections(self, self.talentSelections, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
		end
	end
end

function TalentButtonSelectMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if button ~= "LeftButton" then
		self:SetSelectedEntryID(nil);

		local canSelectChoice = true;
		self:GetTalentFrame():UpdateSelections(self, canSelectChoice, self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
	end
end

function TalentButtonSelectMixin:AcquireTooltip()
	-- Overrides TalentDisplayMixin.
	
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT");
	return tooltip;
end

function TalentButtonSelectMixin:ClearSelections()
	self:GetTalentFrame():HideSelections(self);
	self.timeSinceMouseOver = nil;
	self:SetScript("OnUpdate", nil);
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

function TalentButtonSelectMixin:AddTooltipInstructions(tooltip)
	-- Override TalentButtonBaseMixin.
end

function TalentButtonSelectMixin:AddTooltipErrors(unused_tooltip)
	-- Overrides TalentDisplayMixin.
end

function TalentButtonSelectMixin:UpdateTalentNodeInfo(skipUpdate)
	local baseSkipUpdate = true;
	TalentButtonBaseMixin.UpdateTalentNodeInfo(self, baseSkipUpdate);

	local talentNodeInfo = self:GetTalentNodeInfo();
	local hasTalentNodeInfo = talentNodeInfo ~= nil;
	self.talentSelections = hasTalentNodeInfo and talentNodeInfo.entryIDs or {};

	if hasTalentNodeInfo then
		self:UpdateSelectedEntryID(talentNodeInfo.activeEntry and talentNodeInfo.activeEntry.entryID or nil);
	end

	self:GetTalentFrame():UpdateSelections(self, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());

	if not skipUpdate then
		self:FullUpdate();
	end
end

function TalentButtonSelectMixin:CanSelectChoice()
	if self:HasSelectedEntryID() then
		return true;
	end

	if self:IsLocked() then
		return false;
	end

	if not self.talentNodeInfo or not self.talentNodeInfo.isAvailable then
		return false;
	end

	return true;
end

function TalentButtonSelectMixin:IsSelectable()
	-- Overrides TalentButtonBaseMixin.

	return TalentButtonBaseMixin.IsSelectable(self) and self:CanSelectChoice();
end

function TalentButtonSelectMixin:HasProgress()
	-- Overrides TalentButtonBaseMixin.

	return self:HasSelectedEntryID();
end

function TalentButtonSelectMixin:IsMaxed()
	-- Overrides TalentButtonBaseMixin.

	return self:HasSelectedEntryID();
end

function TalentButtonSelectMixin:GetSpellID()
	-- Overrides TalentButtonBaseMixin.

	local selectedTalentInfo = self:GetSelectedTalentInfo();
	return selectedTalentInfo and selectedTalentInfo.spellID or nil;
end

function TalentButtonSelectMixin:GetName()
	-- Overrides TalentButtonBaseMixin.

	local talentInfo = self:GetSelectedTalentInfo();
	if talentInfo == nil then
		return "";
	end

	return TalentButtonUtil.GetTalentName(talentInfo.overrideName, self:GetSpellID());
end

function TalentButtonSelectMixin:GetSubtext()
	-- Overrides TalentButtonBaseMixin.

	local talentInfo = self:GetSelectedTalentInfo();
	if talentInfo == nil then
		return nil;
	end

	return talentInfo.talentSubtext or GetSpellSubtext(self:GetSpellID());
end

function TalentButtonSelectMixin:CalculateIconTexture()
	-- Overrides TalentButtonBaseMixin.

	return TalentButtonUtil.CalculateIconTexture(self:GetSelectedTalentInfo(), self:GetSpellID());
end

function TalentButtonSelectMixin:UpdateIconTexture()
	-- Overrides TalentDisplayMixin.

	if self:HasSelectedEntryID() then
		TalentDisplayMixin.UpdateIconTexture(self);
	else
		-- TODO:: Better empty state.
		self.Icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]);
	end
end

function TalentButtonSelectMixin:GetSelectedTalentInfo()
	return self.selectedTalentInfo;
end

function TalentButtonSelectMixin:SetSelectedEntryID(selectedEntryID, selectedTalentInfo)
	if not self:UpdateSelectedEntryID(selectedEntryID, selectedTalentInfo) then
		return;
	end

	local nodeID = self:GetTalentNodeID();
	if nodeID then
		self:GetTalentFrame():SetSelection(nodeID, selectedEntryID);
	end
end

function TalentButtonSelectMixin:UpdateSelectedEntryID(selectedEntryID, selectedTalentInfo)
	if self.selectedEntryID == selectedEntryID then
		return false;
	end

	self.selectedEntryID = selectedEntryID;

	if (selectedTalentInfo == nil) and (self.selectedEntryID ~= nil) then
		local talentFrame = self:GetTalentFrame();
		local talentID = talentFrame:GetAndCacheEntryInfo(selectedEntryID).talentID;
		self.selectedTalentInfo = talentFrame:GetAndCacheTalentInfo(talentID);
	else
		self.selectedTalentInfo = (self.selectedEntryID ~= nil) and selectedTalentInfo or nil;
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
	local talentNodeID = self:GetTalentNodeID();
	if talentNodeID ~= nil then
		self:GetTalentFrame():SetSelection(talentNodeID, nil);
	end

	TalentButtonBaseMixin.ResetDynamic(self);
end


-- This breaks the usual pattern and inherits TalentButtonSplitIconMixin directly so that overrides are handled properly.
TalentButtonSplitSelectMixin = CreateFromMixins(TalentButtonSelectMixin, TalentButtonSplitIconMixin);

function TalentButtonSplitSelectMixin:UpdateIconTexture()
	-- Overrides TalentDisplayMixin.

	self.Icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]);
	self:SetSplitIconShown(false);
	if self:HasSelectedEntryID() then
		TalentButtonSelectMixin.UpdateIconTexture(self);
	elseif self.talentSelections and (#self.talentSelections > 1) then
		local firstEntryID = self.talentSelections[1];
		local firstEntryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(firstEntryID);
		local firstTalentInfo = self:GetTalentFrame():GetAndCacheTalentInfo(firstEntryInfo.talentID);
		self.Icon:SetTexture(TalentButtonUtil.CalculateIconTexture(firstTalentInfo));

		local secondEntryID = self.talentSelections[2];
		self:SetSplitIconShown(secondEntryID ~= nil);
		if secondEntryID then
			local secondEntryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(secondEntryID);
			local secondTalentInfo = self:GetTalentFrame():GetAndCacheTalentInfo(secondEntryInfo.talentID);
			self.Icon2:SetTexture(TalentButtonUtil.CalculateIconTexture(secondTalentInfo));
		end
	end
end
