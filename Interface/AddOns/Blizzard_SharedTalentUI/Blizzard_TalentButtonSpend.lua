
TalentButtonSpendMixin = CreateFromMixins(TalentButtonBaseMixin);

function TalentButtonSpendMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if button == "LeftButton" then
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			self:CascadeRepurchaseRanks();
		elseif IsControlKeyDown() and self:HasMassPurchase() then
			self:GetTalentFrame():TryPurchaseToNode(self:GetNodeID());
		elseif IsModifiedClick("CHATLINK") then
			local spellLink = C_Spell.GetSpellLink(self:GetSpellID());
			ChatFrameUtil.InsertLink(spellLink);
		elseif self:CanPurchaseRank() then
			self:PurchaseRank();
		end
	elseif button == "RightButton" then
		if IsControlKeyDown() and self:HasMassPurchase() then
			self:GetTalentFrame():TryRefundToNode(self:GetNodeID(), self:GetEntryID());
		elseif self:CanRefundRank() then
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
	return self.nodeInfo and not self:IsInspecting() and not self:IsLocked() and self.nodeInfo.canPurchaseRank and self:CanAfford();
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

function TalentButtonSpendMixin:HasIncreasedRanks()
	return self.nodeInfo and (self.nodeInfo.ranksIncreased or 0) > 0;
end

function TalentButtonSpendMixin:ResetDynamic()
	local nodeID = self:GetNodeID();
	if nodeID ~= nil then
		self:GetTalentFrame():RefundAllRanks(nodeID);
	end

	TalentButtonBaseMixin.ResetDynamic(self);
end

function TalentButtonSpendMixin:AddTooltipInfo(tooltip)
	local hasIncreasedRanks = self:HasIncreasedRanks();
	local rankShown = self.nodeInfo.currentRank;
	local rankColor = hasIncreasedRanks and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	rankShown = rankColor:WrapTextInColorCode(rankShown);

	local rankLine = TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(rankShown, self.nodeInfo.maxRanks);
	if FlagsUtil.IsSet(self.nodeInfo.flags, Enum.TraitNodeFlag.HideMaxRank) then
		rankLine = TALENT_BUTTON_TOOLTIP_RANK_NO_MAX_FORMAT:format(rankShown);
	end

	GameTooltip_AddHighlightLine(tooltip, rankLine);

	if hasIncreasedRanks then
		local increasedTraitDataList = C_Traits.GetIncreasedTraitData(self:GetNodeID(), self:GetEntryID());
		for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
			local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
			local qualityColor = CreateColor(r, g, b, 1);
			local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
			local wrapText = true;
			GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
		end
	end

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

	if self:HasMassPurchase() then
		GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_QUICK_ASSIGN_INSTRUCTIONS);
	end
end
