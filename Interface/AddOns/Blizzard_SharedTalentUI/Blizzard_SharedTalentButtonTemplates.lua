
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


local SubTypeToColor = {
	[Enum.TraitDefinitionSubType.DragonflightRed] = DRAGONFLIGHT_RED_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBlue] = DRAGONFLIGHT_BLUE_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightGreen] = DRAGONFLIGHT_GREEN_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBronze] = DRAGONFLIGHT_BRONZE_COLOR,
	[Enum.TraitDefinitionSubType.DragonflightBlack] = DRAGONFLIGHT_BLACK_COLOR,
};


TalentDisplayMixin = {};

function TalentDisplayMixin:OnEnter()
	local spellID = self:GetSpellID();
	local spell = (spellID ~= nil) and Spell:CreateFromSpellID(spellID) or nil;
	if spell and not spell:IsSpellEmpty() then
		self.spellLoadCancel = spell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.SetTooltipInternal, self));
	else
		self:SetTooltipInternal();
	end

	self:OnEnterVisuals();
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

	self:OnLeaveVisuals();
end

function TalentDisplayMixin:Init(talentFrame)
	self.talentFrame = talentFrame;
end

function TalentDisplayMixin:OnRelease()
	-- We don't do a full reset for efficency. The next time the button is acquired it'll end up being updated.

	self.visualState = nil;
	self.spellLoadCancel = nil;
	self.matchType = nil;
	self.shouldGlow = nil;
	self.isGhosted = nil;

	self:ResetActiveVisuals();
end

function TalentDisplayMixin:SetTooltipInternal()
	local tooltip = self:AcquireTooltip();
	self:AddTooltipTitle(tooltip);

	-- Used for debug purposes.
	EventRegistry:TriggerEvent("TalentDisplay.TooltipHook", self);

	self:AddTooltipInfo(tooltip);
	self:AddTooltipDescription(tooltip);
	self:AddTooltipCost(tooltip);

	if not self:IsInspecting() then
		self:AddTooltipInstructions(tooltip);
		self:AddTooltipErrors(tooltip);
	end

	tooltip:Show();

    -- Used client issue submission tools
    EventRegistry:TriggerEvent("TalentDisplay.TooltipCreated", self, tooltip);
end

function TalentDisplayMixin:AcquireTooltip()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	if self.tooltipBackdropStyle then
		SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
	end
	return tooltip;
end

function TalentDisplayMixin:SetDefinitionID(definitionID, skipUpdate)
	self.definitionID = definitionID;
	self:UpdateDefinitionInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateDefinitionInfo(skipUpdate)
	local definitionID = self.definitionID;
	self.definitionInfo = (definitionID ~= nil) and self:GetTalentFrame():GetAndCacheDefinitionInfo(definitionID) or nil;

	if not skipUpdate then
		self:FullUpdate();
	end

	self:UpdateMouseOverInfo();
end

function TalentDisplayMixin:SetEntryID(entryID, skipUpdate)
	self.entryID = entryID;
	self:UpdateEntryInfo(skipUpdate);
end

function TalentDisplayMixin:UpdateEntryInfo(skipUpdate)
	local hasEntryID = (self.entryID ~= nil);
	self.entryInfo = hasEntryID and self:GetTalentFrame():GetAndCacheEntryInfo(self.entryID) or nil;

	self:SetDefinitionID(hasEntryID and self.entryInfo.definitionID or nil, skipUpdate);
end

function TalentDisplayMixin:GetDefinitionID()
	return self.definitionID;
end

function TalentDisplayMixin:GetEntryID()
	return self.entryID;
end

function TalentDisplayMixin:GetDefinitionInfo()
	return self.definitionInfo;
end

function TalentDisplayMixin:GetEntryInfo()
	return self.entryInfo;
end

function TalentDisplayMixin:GetSpellID()
	return (self.definitionInfo ~= nil) and self.definitionInfo.spellID or nil;
end

function TalentDisplayMixin:GetOverrideIcon()
	return self.definitionInfo.overrideIcon;
end

function TalentDisplayMixin:CalculateIconTexture()
	return TalentButtonUtil.CalculateIconTexture(self.definitionInfo, self:GetSpellID());
end

function TalentDisplayMixin:UpdateIconTexture()
	self.Icon:SetTexture(self:CalculateIconTexture());
end

function TalentDisplayMixin:GetActiveIcon()
	return self.Icon:GetTexture();
end

function TalentDisplayMixin:UpdateVisualState()
	self:SetVisualState(self:CalculateVisualState());
	self:UpdateMouseOverInfo();
end

function TalentDisplayMixin:FullUpdate()
	self:UpdateVisualState();
	self:UpdateIconTexture();
	self:UpdateNonStateVisuals();
end

function TalentDisplayMixin:SetVisualState(visualState)
	if self.visualState == visualState then
		return;
	end

	self.visualState = visualState;

	self:ApplyVisualState(visualState);

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
	return self.definitionInfo and TalentUtil.GetTalentName(self.definitionInfo.overrideName, self:GetSpellID()) or "";
end

function TalentDisplayMixin:GetSubtext()
	return self.definitionInfo and TalentUtil.GetTalentSubtext(self.definitionInfo.overrideSubtext, self:GetSpellID()) or nil;
end

function TalentDisplayMixin:GetDescription()
	return self.definitionInfo and TalentUtil.GetTalentDescription(self.definitionInfo.overrideDescription, self:GetSpellID()) or "";
end

function TalentDisplayMixin:AddTooltipTitle(tooltip)
	GameTooltip_SetTitle(tooltip, self:GetName());
end

function TalentDisplayMixin:AddTooltipInfo(tooltip)
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
	local blankLineAdded = false;
	if self:ShouldShowSubText() then
		local talentSubtext = self:GetSubtext();
		if talentSubtext and (talentSubtext ~= "") then
			blankLineAdded = true;
			GameTooltip_AddBlankLineToTooltip(tooltip);

			local color = self.definitionInfo and self.definitionInfo.subType and SubTypeToColor[self.definitionInfo.subType];
			GameTooltip_AddColoredLine(tooltip, talentSubtext, color or DISABLED_FONT_COLOR);
		end
	end

	if self.nodeInfo then
		local activeEntry = self.nodeInfo.activeEntry;
		if activeEntry then
			if not blankLineAdded then
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			tooltip:AppendInfo("GetTraitEntry", activeEntry.entryID, activeEntry.rank);
		end

		local nextEntry = self.nodeInfo.nextEntry;
		if nextEntry and self.nodeInfo.ranksPurchased > 0 then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
			tooltip:AppendInfo("GetTraitEntry", nextEntry.entryID, nextEntry.rank);
		end
	elseif self.entryID then
		-- If this tooltip isn't coming from a node, we can't know what rank to show other than 1.
		local rank = 1;
		tooltip:AppendInfo("GetTraitEntry", self.entryID, rank);
	end
end

function TalentDisplayMixin:AddTooltipErrors(tooltip)
	local talentFrame = self:GetTalentFrame();

	local shouldAddSpacer = true;
	talentFrame:AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer);

	local isLocked, errorMessage = talentFrame:IsLocked();
	if isLocked and errorMessage then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, errorMessage);
	end
end

function TalentDisplayMixin:SetSearchMatchType(matchType)
	self.matchType = matchType;
	self:UpdateSearchIcon();
end

function TalentDisplayMixin:SetGlowing(shouldGlow)
	self.shouldGlow = shouldGlow;
	self:UpdateGlow();
end

function TalentDisplayMixin:GetTalentFrame()
	return self.talentFrame;
end

function TalentDisplayMixin:IsInspecting()
	return self:GetTalentFrame():IsInspecting();
end

function TalentDisplayMixin:UpdateMouseOverInfo()
	if GetMouseFocus() == self then
		self:OnEnter();
	end
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
	return self.definitionInfo and self.definitionInfo.subType and SubTypeToColor[self.definitionInfo.subType];
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

function TalentDisplayMixin:UpdateNonStateVisuals()
	-- Implement in your derived mixin.
	-- Should include updating visuals that are not dependent on the current VisualState.
end

function TalentDisplayMixin:ResetActiveVisuals()
	-- Implement in your derived mixin.
	-- Should include disabling active dynamic visuals like animations, FX, etc.
end

function TalentDisplayMixin:UpdateSearchIcon()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:UpdateGlow()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:OnEnterVisuals()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:OnLeaveVisuals()
	-- Implement in your derived mixin.
end

function TalentDisplayMixin:UpdateColorBlindVisuals(isColorBlindModeActive)
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
		local checkForPassive = true;
		PickupSpell(spellID, checkForPassive);
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

	self:SetDefinitionID(hasEntryID and self.entryInfo.definitionID or nil, skipUpdate);
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

function TalentButtonBaseMixin:OnTalentReset()
	self:ResetDynamic();
end

function TalentButtonBaseMixin:GetSpendText()
	local nodeInfo = self.nodeInfo;
	if nodeInfo then
		if (nodeInfo.ranksPurchased < 1) and not self:IsSelectable() then
			return "";
		end

		if (nodeInfo.currentRank <= 1) and (nodeInfo.maxRanks == 1) and self:GetTalentFrame():ShouldHideSingleRankNumbers() then
			return "";
		end

		if (nodeInfo.ranksPurchased > 0) or (nodeInfo.currentRank < nodeInfo.maxRanks) then
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
end

function TalentButtonBaseMixin:ResetDynamic()
	self:ResetActiveVisuals();
	self:FullUpdate();
end

function TalentButtonBaseMixin:ResetAll()
	local skipUpdate = true;
	self:SetNodeID(nil, skipUpdate);
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
	elseif self:IsRefundInvalid() then
		return TalentButtonUtil.BaseVisualState.RefundInvalid;
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

function TalentButtonBaseMixin:ShouldBeVisible()
	return (self.nodeInfo ~= nil) and self.nodeInfo.isVisible;
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

function TalentButtonBaseMixin:IsCascadeRepurchasable()
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

	return self.nodeInfo and self.nodeInfo.isCascadeRepurchasable and self:CanAfford();
end

function TalentButtonBaseMixin:CanCascadeRepurchaseRanks()
	return not self:IsLocked() and not self:IsGated() and self:IsCascadeRepurchasable();
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
	},

	Large = {
		{ region = "Icon", adjust = 0, },
		{ region = "IconMask", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "DisabledOverlayMask", adjust = 0, },
		{ region = "StateBorder", adjust = 0, },
		{ region = "Ghost", adjust = 0, },
		{ region = "Glow", adjust = 0, },
		{ region = "SelectableGlow", adjust = 0, },
		{ region = "SpendText", anchorX = 20 },
	}
};

function TalentButtonBasicArtMixin:OnLoad()
	self:ApplySize(self:GetSize());
end

function TalentButtonBasicArtMixin:ApplyVisualState(visualState)
	local color = TalentButtonUtil.GetColorForBaseVisualState(visualState);
	local r, g, b = color:GetRGB();
	self.SpendText:SetTextColor(r, g, b);
	self.StateBorder:SetColorTexture(r, g, b);

	local isRefundInvalid = (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	local disabledColor = isRefundInvalid and DIM_RED_FONT_COLOR or WHITE_FONT_COLOR;
	self.Icon:SetVertexColor(disabledColor:GetRGBA());

	local isGated = (visualState == TalentButtonUtil.BaseVisualState.Gated);
	local isStrongDisabledOverlay = not isRefundInvalid and isGated;
	self.Icon:SetAlpha(isStrongDisabledOverlay and 0.5 or 1.0);
	self.DisabledOverlay:SetAlpha(isStrongDisabledOverlay and 0.7 or 0.3);

	local isLocked = (visualState == TalentButtonUtil.BaseVisualState.Locked);
	local isDimmed = not isRefundInvalid and (isGated or isLocked);
	self.Icon:SetDesaturated(isDimmed);

	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Disabled);
	local showDisabledOverlay = not isRefundInvalid and (isGated or isLocked or isDisabled);
	self.DisabledOverlay:SetShown(showDisabledOverlay);
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

	for _, sizingAdjustmentInfo in ipairs(sizingAdjustment) do
		local region = self[sizingAdjustmentInfo.region];
		if region then
			local sizeAdjustment = sizingAdjustmentInfo.adjust;
			local anchorX = sizingAdjustmentInfo.anchorX;
			local anchorY = sizingAdjustmentInfo.anchorY;

			if sizeAdjustment then
				region:SetSize(width + sizeAdjustment, height + sizeAdjustment);
			end
			if anchorX or anchorY then
				local point, relativeTo, relativePoint, x, y = region:GetPoint();
				region:SetPoint(point, relativeTo, relativePoint, anchorX or x, anchorY or y);
			end
		end
	end
end


TalentButtonArtMixin = {};

-- Split out for easier adjustment.
local RefundInvalidOverlayAlpha = 0.3;

TalentButtonArtMixin.ArtSet = {
	Square = {
		iconMask = nil,
		shadow = "talents-node-square-shadow",
		normal = "talents-node-square-yellow",
		disabled = "talents-node-square-gray",
		selectable = "talents-node-square-green",
		maxed = "talents-node-square-yellow",
		locked = "talents-node-square-locked",
		refundInvalid = "talents-node-square-red",
		glow = "talents-node-square-greenglow",
		ghost = "talents-node-square-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	Circle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-circle-shadow",
		normal = "talents-node-circle-yellow",
		disabled = "talents-node-circle-gray",
		selectable = "talents-node-circle-green",
		maxed = "talents-node-circle-yellow",
		refundInvalid = "talents-node-circle-red",
		locked = "talents-node-circle-locked",
		glow = "talents-node-circle-greenglow",
		ghost = "talents-node-circle-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	Choice = {
		iconMask = "talents-node-choice-mask",
		shadow = "talents-node-choice-shadow",
		normal = "talents-node-choice-yellow",
		disabled = "talents-node-choice-gray",
		selectable = "talents-node-choice-green",
		maxed = "talents-node-choice-yellow",
		refundInvalid = "talents-node-choice-red",
		locked = "talents-node-choice-locked",
		glow = "talents-node-choice-greenglow",
		ghost = "talents-node-choice-ghost",
		spendFont = "SystemFont16_Shadow_ThickOutline",
	},

	LargeSquare = {
		iconMask = "talents-node-choiceflyout-mask",
		shadow = "talents-node-choiceflyout-square-shadow",
		normal = "talents-node-choiceflyout-square-yellow",
		disabled = "talents-node-choiceflyout-square-gray",
		selectable = "talents-node-choiceflyout-square-green",
		maxed = "talents-node-choiceflyout-square-yellow",
		refundInvalid = "talents-node-choiceflyout-square-red",
		locked = "talents-node-choiceflyout-square-locked",
		glow = "talents-node-choiceflyout-square-greenglow",
		ghost = "talents-node-choiceflyout-square-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
	},

	LargeCircle = {
		iconMask = "talents-node-circle-mask",
		shadow = "talents-node-choiceflyout-circle-shadow",
		normal = "talents-node-choiceflyout-circle-gray",
		disabled = "talents-node-choiceflyout-circle-gray",
		selectable = "talents-node-choiceflyout-circle-green",
		maxed = "talents-node-choiceflyout-circle-yellow",
		refundInvalid = "talents-node-choiceflyout-circle-red",
		locked = "talents-node-choiceflyout-circle-locked",
		glow = "talents-node-choiceflyout-circle-greenglow",
		ghost = "talents-node-choiceflyout-circle-ghost",
		spendFont = "SystemFont22_Shadow_ThickOutline",
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

	self.Glow:SetAtlas(self.artSet.glow, TextureKitConstants.UseAtlasSize);
	self.Ghost:SetAtlas(self.artSet.ghost, TextureKitConstants.UseAtlasSize);
	self.Shadow:SetAtlas(self.artSet.shadow, TextureKitConstants.UseAtlasSize);

	self.SpendText:SetFontObject(self.artSet.spendFont);
	if self.spendTextShadows then
		for _, shadow in ipairs(self.spendTextShadows) do
			shadow:SetFontObject(self.artSet.spendFont);
		end
	end

	if self.SearchIcon then
		self.SearchIcon.Mouseover:SetScript("OnEnter", GenerateClosure(self.OnSearchIconEnter, self));
	end
end

function TalentButtonArtMixin:ApplyVisualState(visualState)
	local color = TalentButtonUtil.GetColorForBaseVisualState(visualState);
	local r, g, b = color:GetRGB();
	self.SpendText:SetTextColor(r, g, b);

	local isRefundInvalid = (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid);
	local disabledColor = isRefundInvalid and DIM_RED_FONT_COLOR or WHITE_FONT_COLOR;
	self.Icon:SetVertexColor(disabledColor:GetRGBA());

	local isGated = (visualState == TalentButtonUtil.BaseVisualState.Gated);
	self.DisabledOverlay:SetAlpha((isGated and 0.7) or (isRefundInvalid and RefundInvalidOverlayAlpha) or 0.25);

	local isLocked = (visualState == TalentButtonUtil.BaseVisualState.Locked);
	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Disabled);
	local isDimmed = isGated or isLocked or isDisabled;
	self.Icon:SetDesaturated(not isRefundInvalid and isDimmed);
	self.DisabledOverlay:SetShown(isRefundInvalid or isDimmed);

	if self.SelectableIcon then
		local isSelectable = (visualState == TalentButtonUtil.BaseVisualState.Selectable);
		self.SelectableIcon:SetShown(isSelectable and CVarCallbackRegistry:GetCVarValueBool("colorblindMode"));
	end

	self:UpdateStateBorder(visualState);
end

function TalentButtonArtMixin:UpdateNonStateVisuals()
	self.Ghost:SetShown(self.isGhosted);
	self:UpdateSearchIcon();
	self:UpdateGlow();
end

function TalentButtonArtMixin:UpdateStateBorder(visualState)
	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Gated)
					or (visualState == TalentButtonUtil.BaseVisualState.Locked)
					or (visualState == TalentButtonUtil.BaseVisualState.Disabled);

	local function SetAtlas(atlas)
		self.StateBorder:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

		if self.StateBorderHover then
			self.StateBorderHover:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
			self.StateBorderHover:SetAlpha(TalentButtonUtil.GetHoverAlphaForVisualStyle(visualState));
		end
	end

	if (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid) then
		SetAtlas(self.artSet.refundInvalid);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Gated) then
		SetAtlas(self.artSet.locked);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Selectable) then
		SetAtlas(self.artSet.selectable);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Maxed) then
		SetAtlas(self.artSet.maxed);
	elseif not isDisabled then
		SetAtlas(self.artSet.normal);
	else
		SetAtlas(self.artSet.disabled);
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

	for _, sizingAdjustmentInfo in ipairs(sizingAdjustment) do
		local region = self[sizingAdjustmentInfo.region];
		if region then
			local sizeAdjustment = sizingAdjustmentInfo.adjust;
			local anchorX = sizingAdjustmentInfo.anchorX;
			local anchorY = sizingAdjustmentInfo.anchorY;

			if sizeAdjustment then
				region:SetSize(width + sizeAdjustment, height + sizeAdjustment);
			end
			if anchorX or anchorY then
				local point, relativeTo, relativePoint, x, y = region:GetPoint();
				region:SetPoint(point, relativeTo, relativePoint, anchorX or x, anchorY or y);
			end
		end
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

function TalentButtonArtMixin:DisableSearchIconMouseover()
	if self.SearchIcon then
		self.SearchIcon.Mouseover:Hide();
	end
end

function TalentButtonArtMixin:EnableSearchIconMouseover()
	if self.SearchIcon then
		self.SearchIcon.Mouseover:Show();
	end
end

function TalentButtonArtMixin:OnSearchIconEnter()
	if self.searchIconTooltipText then
		GameTooltip:SetOwner(self.SearchIcon.Mouseover, "ANCHOR_RIGHT", 0, 0);
		if self.tooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(GameTooltip, self.tooltipBackdropStyle);
		end
		GameTooltip_AddNormalLine(GameTooltip, self.searchIconTooltipText);
		GameTooltip:Show();
	end
end

function TalentButtonArtMixin:UpdateSearchIcon()
	if not self.SearchIcon then
		return;
	end

	if not self.matchType then
		self.searchIconTooltipText = nil;
		self.SearchIcon:SetShown(false);
	else
		self.SearchIcon:SetFrameLevel(self:GetFrameLevel() + 50);
		self.SearchIcon:SetShown(true);
		local matchStyle = TalentButtonUtil.GetStyleForSearchMatchType(self.matchType);
		self.SearchIcon.Icon:SetAtlas(matchStyle.icon);
		self.SearchIcon.OverlayIcon:SetAtlas(matchStyle.icon);
		self.searchIconTooltipText = matchStyle.tooltipText;
	end
end

function TalentButtonArtMixin:UpdateGlow()
	if self.Glow then
		self.Glow:SetShown(self.shouldGlow);
	end
end

function TalentButtonArtMixin:OnEnterVisuals()
	if self.StateBorderHover then
		self.StateBorderHover:Show();
	end
end

function TalentButtonArtMixin:OnLeaveVisuals()
	if self.StateBorderHover then
		self.StateBorderHover:Hide();
	end
end

function TalentButtonArtMixin:UpdateColorBlindVisuals(isColorBlindModeActive)
	local visualState = self:GetVisualState();
	if self.SelectableIcon then
		self.SelectableIcon:SetShown(visualState == TalentButtonUtil.BaseVisualState.Selectable and isColorBlindModeActive);
	end
end

function TalentButtonArtMixin:PlayPurchaseInProgressEffect(fxModelScene, fxIDs)
	self.purchaseInProgressEffects = self:InternalPlayAnimEffects(self.purchaseInProgressEffects, fxModelScene, fxIDs);
end

function TalentButtonArtMixin:StopPurchaseInProgressEffect()
	self:InternalStopAnimEffects(self.purchaseInProgressEffects);
	self.purchaseInProgressEffects = nil;
end

function TalentButtonArtMixin:PlayPurchaseCompleteEffect(fxModelScene, fxIDs)
	self.purchaseCompleteEffects = self:InternalPlayAnimEffects(self.purchaseCompleteEffects, fxModelScene, fxIDs);
end

function TalentButtonArtMixin:StopPurchaseCompleteEffect()
	self:InternalStopAnimEffects(self.purchaseCompleteEffects);
	self.purchaseCompleteEffects = nil;
end

function TalentButtonArtMixin:InternalPlayAnimEffects(animEffectControllers, fxModelScene, fxIDs)
	if animEffectControllers then
		self:InternalStopAnimEffects();
		animEffectControllers = nil;
	end

	if (fxIDs) then
		animEffectControllers = {};
		for _, fxID in ipairs(fxIDs) do
			table.insert(animEffectControllers, fxModelScene:AddEffect(fxID, self, self, nil, nil, self.animEffectScaleMultiplier));
		end
	end

	return animEffectControllers;
end

function TalentButtonArtMixin:InternalStopAnimEffects(animEffectControllers)
	if not animEffectControllers then
		return;
	end

	for _, fxController in ipairs(animEffectControllers) do
		if fxController and fxController.CancelEffect then
			fxController:CancelEffect();
		end
	end
end

function TalentButtonArtMixin:ResetActiveVisuals()
	self:StopPurchaseInProgressEffect();
	self:StopPurchaseCompleteEffect();
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
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			self:CascadeRepurchaseRanks();
		elseif IsModifiedClick("CHATLINK") then
			local spellLink = GetSpellLink(self:GetSpellID());
			ChatEdit_InsertLink(spellLink);
		elseif self:CanPurchaseRank() then
			self:PurchaseRank();
		end
	elseif button == "RightButton" then
		if self:CanRefundRank() then
			self:RefundRank();
		elseif self:IsGhosted() then
			self:ClearCascadeRepurchaseHistory();
		end
	end
end

function TalentButtonSpendMixin:Init(...)
	TalentDisplayMixin.Init(self, ...);

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
end

function TalentButtonSpendMixin:CanPurchaseRank()
	return self.nodeInfo and not self:IsLocked() and self.nodeInfo.canPurchaseRank and self:CanAfford();
end

function TalentButtonSpendMixin:CanRefundRank()
	-- We shouldn't be checking ranksPurchased directly.
	return self.nodeInfo and not self:GetTalentFrame():IsLocked() and self.nodeInfo.canRefundRank and self.nodeInfo.ranksPurchased and (self.nodeInfo.ranksPurchased > 0);
end

function TalentButtonSpendMixin:PurchaseRank()
	self:PlaySelectSound();
	self:GetTalentFrame():PurchaseRank(self:GetNodeID());
	self:UpdateMouseOverInfo();
end

function TalentButtonSpendMixin:RefundRank()
	self:PlayDeselectSound();
	self:GetTalentFrame():RefundRank(self:GetNodeID());
	self:UpdateMouseOverInfo();
end

function TalentButtonSpendMixin:IsSelectable()
	return self:CanPurchaseRank();
end

function TalentButtonSpendMixin:IsMaxed()
	local activeRank = (self.nodeInfo ~= nil) and self.nodeInfo.activeRank or 0;
	return (activeRank > 0) and (activeRank >= self.nodeInfo.maxRanks);
end

function TalentButtonSpendMixin:HasProgress()
	return self.nodeInfo and self.nodeInfo.activeRank > 0;
end

function TalentButtonSpendMixin:ResetDynamic()
	local nodeID = self:GetNodeID();
	if nodeID ~= nil then
		self:GetTalentFrame():RefundAllRanks(nodeID);
	end

	TalentButtonBaseMixin.ResetDynamic(self);
end

function TalentButtonSpendMixin:AddTooltipInfo(tooltip)
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(self.nodeInfo.currentRank, self.nodeInfo.maxRanks));

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentButtonSpendMixin:AddTooltipInstructions(tooltip)
	TalentDisplayMixin.AddTooltipInstructions(self, tooltip);

	local canPurchase = self:CanPurchaseRank();
	local canRefund = self:CanRefundRank();
	local canRepurchase = self:CanCascadeRepurchaseRanks();
	local isGhosted = self:IsGhosted();

	-- We want a preceding blank line if there are any instructions, but not lines between instructions.
	if canPurchase or canRefund or canRepurchase or isGhosted then
		GameTooltip_AddBlankLineToTooltip(tooltip);
	end

	if canPurchase then
		GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS);
	elseif canRefund then
		GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS);
	end

	if canRepurchase then
		GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_REPURCHASE_INSTRUCTIONS, BRIGHTBLUE_FONT_COLOR);
	elseif isGhosted then
		GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_CLEAR_REPURCHASE_INSTRUCTIONS, BRIGHTBLUE_FONT_COLOR);
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

local TimeToHideSeconds = 0;
local TimeToShowSelections = 0;
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
			self:ShowSelections();
		end
	end
end

function TalentButtonSelectMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if self:IsInspecting() then
		return;
	end

	if button == "RightButton" then
		if self:IsGhosted() then
			self:ClearCascadeRepurchaseHistory();
		end

		if self.nodeInfo.canRefundRank then
			self:SetSelectedEntryID(nil);

			-- If we just refunded, we should be able to select a choice unless we're in a refund invalid state.
			-- We're not using CanSelectChoice since that won't be accurate at this point.
			local canSelectChoice = not self:IsRefundInvalid();
			self:GetTalentFrame():UpdateSelections(self, canSelectChoice, self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
		end
	elseif button == "LeftButton" then
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			self:CascadeRepurchaseRanks();
		elseif IsModifiedClick("CHATLINK") then
			local spellID = self:GetSpellID();
			if spellID then
				local spellLink = GetSpellLink(spellID);
				ChatEdit_InsertLink(spellLink);
			end
		end
	end
end

function TalentButtonSelectMixin:AcquireTooltip()
	-- Overrides TalentDisplayMixin.
	
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT");
	if self.tooltipBackdropStyle then
		SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
	end
	return tooltip;
end

function TalentButtonSelectMixin:ShowSelections()
	self:GetTalentFrame():ShowSelections(self, self.talentSelections, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
	-- Prevent SearchIcon from potentially interrupting selection mouseover
	self:DisableSearchIconMouseover();
end

function TalentButtonSelectMixin:ClearSelections()
	self:GetTalentFrame():HideSelections(self);
	self.timeSinceMouseOver = nil;
	self:SetScript("OnUpdate", nil);
	self:EnableSearchIconMouseover();
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

function TalentButtonSelectMixin:AddTooltipErrors(unused_tooltip)
	-- Overrides TalentDisplayMixin.
end

function TalentButtonSelectMixin:UpdateNodeInfo(skipUpdate)
	local baseSkipUpdate = true;
	TalentButtonBaseMixin.UpdateNodeInfo(self, baseSkipUpdate);

	local nodeInfo = self:GetNodeInfo();
	local hasNodeInfo = nodeInfo ~= nil;
	self.talentSelections = hasNodeInfo and nodeInfo.entryIDs or {};

	if hasNodeInfo then
		local isUserInput = false;
		self:UpdateSelectedEntryID(nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil, isUserInput);
	end

	self:GetTalentFrame():UpdateSelections(self, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());

	if not skipUpdate then
		self:FullUpdate();
	end
end

function TalentButtonSelectMixin:CanSelectChoice()
	if self:IsRefundInvalid() then
		return false;
	end

	if self:HasSelectedEntryID() then
		return true;
	end

	if self:IsLocked() or not self:CanAfford() then
		return false;
	end

	if not self.nodeInfo or not self.nodeInfo.isAvailable then
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

	local selectedDefinitionInfo = self:GetSelectedDefinitionInfo();
	return selectedDefinitionInfo and selectedDefinitionInfo.spellID or nil;
end

function TalentButtonSelectMixin:GetName()
	-- Overrides TalentButtonBaseMixin.

	local definitionInfo = self:GetSelectedDefinitionInfo();
	if definitionInfo == nil then
		return "";
	end

	return TalentUtil.GetTalentName(definitionInfo.overrideName, self:GetSpellID());
end

function TalentButtonSelectMixin:GetSubtext()
	-- Overrides TalentButtonBaseMixin.

	local definitionInfo = self:GetSelectedDefinitionInfo();
	if definitionInfo == nil then
		return nil;
	end

	return TalentUtil.GetTalentSubtext(definitionInfo.overrideSubtext, self:GetSpellID());
end

function TalentButtonSelectMixin:GetDescription()
	-- Overrides TalentButtonBaseMixin.

	local definitionInfo = self:GetSelectedDefinitionInfo();
	if definitionInfo == nil then
		return "";
	end

	return TalentUtil.GetTalentDescription(definitionInfo.overrideDescription, self:GetSpellID());
end

function TalentButtonSelectMixin:CalculateIconTexture()
	-- Overrides TalentButtonBaseMixin.

	return TalentButtonUtil.CalculateIconTexture(self:GetSelectedDefinitionInfo(), self:GetSpellID());
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

function TalentButtonSelectMixin:GetSelectedDefinitionInfo()
	return self.selectedDefinitionInfo;
end

function TalentButtonSelectMixin:SetSelectedEntryID(selectedEntryID, selectedDefinitionInfo)
	local oldSelection = self.selectedEntryID;

	if not self:GetTalentFrame():ShouldShowConfirmation() then
		local isUserInput = true;
		if not self:UpdateSelectedEntryID(selectedEntryID, isUserInput, selectedDefinitionInfo) then
			return;
		end
	end

	local nodeID = self:GetNodeID();
	if nodeID then
		self:GetTalentFrame():SetSelection(nodeID, selectedEntryID, oldSelection);
	end
end

function TalentButtonSelectMixin:UpdateSelectedEntryID(selectedEntryID, isUserInput, selectedDefinitionInfo)
	if self.selectedEntryID == selectedEntryID then
		return false;
	end

	if isUserInput then
		if selectedEntryID == nil then
			self:PlayDeselectSound();
		else
			self:PlaySelectSound();
		end
	end

	self.selectedEntryID = selectedEntryID;

	if (selectedDefinitionInfo == nil) and (self.selectedEntryID ~= nil) then
		local talentFrame = self:GetTalentFrame();
		local definitionID = talentFrame:GetAndCacheEntryInfo(selectedEntryID).definitionID;
		self.selectedDefinitionInfo = talentFrame:GetAndCacheDefinitionInfo(definitionID);
	else
		self.selectedDefinitionInfo = (self.selectedEntryID ~= nil) and selectedDefinitionInfo or nil;
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
	local nodeID = self:GetNodeID();
	if nodeID ~= nil then
		self:GetTalentFrame():SetSelection(nodeID, nil);
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
		local firstDefinitionInfo = self:GetTalentFrame():GetAndCacheDefinitionInfo(firstEntryInfo.definitionID);
		self.Icon:SetTexture(TalentButtonUtil.CalculateIconTexture(firstDefinitionInfo));

		local secondEntryID = self.talentSelections[2];
		self:SetSplitIconShown(secondEntryID ~= nil);
		if secondEntryID then
			local secondEntryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(secondEntryID);
			local secondDefinitionInfo = self:GetTalentFrame():GetAndCacheDefinitionInfo(secondEntryInfo.definitionID);
			self.Icon2:SetTexture(TalentButtonUtil.CalculateIconTexture(secondDefinitionInfo));
		end
	end
end
