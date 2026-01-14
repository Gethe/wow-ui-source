TalentButtonCapstonePipMixin = CreateFromMixins(TalentButtonArtMixin);

function TalentButtonCapstonePipMixin:OnLoad()
	TalentButtonArtMixin.OnLoad(self);
	self:InitializeVisuals();
end

function TalentButtonCapstonePipMixin:InitializeVisuals()
	-- Shadows make it hard to see the track progress bar
	MixinUtil.CallMethodSafe(self.Shadow, "Hide");

	-- Pips are not clickable, hide the "selectable" icon
	MixinUtil.CallMethodSafe(self.SelectableIcon, "SetAlpha", 0);
end

function TalentButtonCapstonePipMixin:OnEnterVisuals()
	-- Skipping inherited hover state for pips
end

function TalentButtonCapstonePipMixin:OnLeaveVisuals()
	-- Skipping inherited hover state for pips
end

function TalentButtonCapstonePipMixin:CalculateIconTexture()
	-- We always want pips to use the same icon
	return "Interface\\Icons\\UI_LemixGem_White";
end

function TalentButtonCapstonePipMixin:CalculateVisualState()
	local parentState = self:GetParent():GetVisualState();
	local hasErrorState = parentState == TalentButtonUtil.BaseVisualState.RefundInvalid or parentState == TalentButtonUtil.BaseVisualState.DisplayError;
	local hasGatedState = parentState == TalentButtonUtil.BaseVisualState.Gated;
	if hasErrorState or hasGatedState then
		return parentState;
	end

	local spendStateData = self:CalculateSpendStateForPip();
	return spendStateData.ranksSpent > 0 and TalentButtonUtil.BaseVisualState.Normal or TalentButtonUtil.BaseVisualState.Disabled;
end

function TalentButtonCapstonePipMixin:CalculateSpendStateForPip()
	local nodeInfo = self:GetParent():GetNodeInfo();
	if not nodeInfo then
		return { ranksSpent = 0, isActivePip = false };
	end
	
	local tierEntryID = self:GetEntryID();
	-- We need to calculate how many ranks have been spent on this specific tier's entryID.
	-- Start with the total number of ranks purchased in the node...
	local remainingRanks = nodeInfo.ranksPurchased or 0;
	local isPreviousTierComplete = true;
	-- ...then iterate through each entryID, subtracting their maxRanks until we reach the tier's entryID.
	for _index, entryID in ipairs(nodeInfo.entryIDs) do
		local currentEntryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(entryID);
		local spentInTier = math.min(remainingRanks, currentEntryInfo.maxRanks);
		if entryID == tierEntryID then
			return { ranksSpent = spentInTier, isActivePip = isPreviousTierComplete and (spentInTier < currentEntryInfo.maxRanks) or false };
		end
		
		if spentInTier < currentEntryInfo.maxRanks then
			isPreviousTierComplete = false;
		end
			
		remainingRanks = math.max(remainingRanks - currentEntryInfo.maxRanks, 0);
	end

	return { ranksSpent = 0, isActivePip = false };
end

function TalentButtonCapstonePipMixin:IsPipInProgress()
	return self:CalculateSpendStateForPip().isActivePip;
end

function TalentButtonCapstonePipMixin:TrySetPipInProgressTextColor(visualState)
	local showingErrorState = visualState == TalentButtonUtil.BaseVisualState.RefundInvalid or visualState == TalentButtonUtil.BaseVisualState.DisplayError;
	if showingErrorState or not self:IsPipInProgress() then
		return;
	end

	MixinUtil.CallMethodSafe(self.SpendText, "SetTextColor", GREEN_FONT_COLOR:GetRGB());
end

function TalentButtonCapstonePipMixin:ApplyVisualState(visualState)
	TalentButtonArtMixin.ApplyVisualState(self, visualState);
	self:TrySetPipInProgressTextColor(visualState);
end

function TalentButtonCapstonePipMixin:CalculateSpendText()
	local parent = self:GetParent();
	local parentVisualState = parent:GetVisualState();
	local shouldForceHideSpendText = parentVisualState == TalentButtonUtil.BaseVisualState.Disabled
									or parentVisualState == TalentButtonUtil.BaseVisualState.Locked
									or parentVisualState == TalentButtonUtil.BaseVisualState.Gated;
	if shouldForceHideSpendText then
		return nil;
	end

	local spendStateData = self:CalculateSpendStateForPip();
	local shouldShowSpendText = spendStateData.ranksSpent > 0 or (spendStateData.isActivePip and parent:CanPurchaseRank());
	return shouldShowSpendText and tostring(spendStateData.ranksSpent) or nil;
end

function TalentButtonCapstonePipMixin:UpdateSpendText()
	TalentButtonUtil.SetSpendText(self, self:CalculateSpendText());
end

function TalentButtonCapstonePipMixin:AddTooltipInfo(tooltip)
	local nodeInfo = self:GetParent():GetNodeInfo();
	if not nodeInfo then
		return;
	end

	local entryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(self:GetEntryID());
	local spendStateData = self:CalculateSpendStateForPip();
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(spendStateData.ranksSpent, entryInfo.maxRanks));

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentButtonCapstonePipMixin:AddTooltipDescription(tooltip)
	if self:ShouldShowSubText() then
		local talentSubtext = self:GetSubtext();
		if talentSubtext and (talentSubtext ~= "") then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			local textColor = self.definitionInfo and SubTypeToColor[self.definitionInfo.subType] or DISABLED_FONT_COLOR;
			GameTooltip_AddColoredLine(tooltip, talentSubtext, textColor);
		end
	end

	local entryID = self:GetEntryID();
	local entryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(entryID);
	local spendStateData = self:CalculateSpendStateForPip();
	for rankIndex = 1, entryInfo.maxRanks do
		GameTooltip_AddBlankLineToTooltip(tooltip);

		local isFirstRank = rankIndex == 1;
		local tooltipInfo = CreateBaseTooltipInfo("GetTraitEntry", entryID, rankIndex);
		tooltipInfo.excludeLines = isFirstRank and { Enum.TooltipDataLineType.SpellName } or { Enum.TooltipDataLineType.SpellName, Enum.TooltipDataLineType.SpellPassive };
		tooltipInfo.append = true;
		tooltipInfo.linePreCall = function(tooltip, lineData)
			if lineData.type == Enum.TooltipDataLineType.SpellDescription then
				local useRankStageFormat = entryInfo.maxRanks > 1;
				if useRankStageFormat then
					lineData.leftText = TALENT_BUTTON_TOOLTIP_CAPSTONE_RANK_STAGE_FORMAT:format(rankIndex, lineData.leftText);
				end

				local isPurchased = rankIndex <= spendStateData.ranksSpent;
				lineData.leftColor = isPurchased and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR;
			end
		end;
		tooltip:ProcessInfo(tooltipInfo);
	end
end

TalentButtonCapstoneWithTrackMixin = CreateFromMixins(TalentButtonSpendMixin);

function TalentButtonCapstoneWithTrackMixin:OnLoad()
	TalentButtonSpendMixin.OnLoad(self);
	self.trackPipArray = {};
	self:InitializeVisuals();
end

function TalentButtonCapstoneWithTrackMixin:OnRelease()
	self:ReleaseTrackPips();
	TalentDisplayMixin.OnRelease(self);
end

-- Overriding TalentDisplayMixin OnEnter/OnLeave to load all pip spells for the capstone track
function TalentButtonCapstoneWithTrackMixin:OnEnter()
	self:LoadPipSpellsAndShowTooltip();
	self:OnEnterVisuals();
end

function TalentButtonCapstoneWithTrackMixin:GetPipSpellIDs()
	local spellIDs = {};
	local nodeInfo = self:GetNodeInfo();
	if not nodeInfo or not nodeInfo.entryIDs then
		return spellIDs;
	end

	local talentFrame = self:GetTalentFrame();
	for _index, entryID in ipairs(nodeInfo.entryIDs) do
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);
		local definitionInfo = entryInfo and talentFrame:GetAndCacheDefinitionInfo(entryInfo.definitionID);
		if definitionInfo and definitionInfo.spellID then
			table.insert(spellIDs, definitionInfo.spellID);
		end
	end

	return spellIDs;
end

function TalentButtonCapstoneWithTrackMixin:LoadPipSpellsAndShowTooltip()
	if self.spellContinuableContainer then
		self.spellContinuableContainer:Cancel();
	end

	self.spellContinuableContainer = ContinuableContainer:Create();
	for _index, spellID in ipairs(self:GetPipSpellIDs()) do
		local spell = Spell:CreateFromSpellID(spellID);
		if not spell:IsSpellEmpty() then
			self.spellContinuableContainer:AddContinuable(spell);
		end
	end

	self.spellContinuableContainer:ContinueOnLoad(function()
		if self:IsMouseOver() then
			self:SetTooltipInternal();
		end
	end);
end

function TalentButtonCapstoneWithTrackMixin:OnHide()
	if self.spellContinuableContainer then
		self.spellContinuableContainer:Cancel();
	end
end

function TalentButtonCapstoneWithTrackMixin:InitializeVisuals()
	-- We don't show "selectable" visuals or spend text when a capstone button has a progress track (aside from the border)
	-- The pips on the track indicate spend progress instead.
	if self.SelectableIcon then
		self.SelectableIcon:SetAlpha(0);
	end
	if self.SpendText then
		self.SpendText:Hide();
	end	
	if self.spendTextShadows then
		for _index, shadow in ipairs(self.spendTextShadows) do
			shadow:Hide();
		end
	end

	-- Shadows make it hard to see the track
	if self.Shadow then
		self.Shadow:Hide();
	end
end

function TalentButtonCapstoneWithTrackMixin:FullUpdate()
	TalentButtonSpendMixin.FullUpdate(self);
	self:UpdateTrack();
end

function TalentButtonCapstoneWithTrackMixin:CalculateIconTexture()
	local nodeInfo = self:GetNodeInfo();
	if nodeInfo then
		-- For capstones with a tier track, the icon is always the first tier's icon (the remaining tiers are just pips on the track)
		local firstEntryID = nodeInfo.entryIDs[1];
		local talentFrame = self:GetTalentFrame();
		local entryInfo = talentFrame:GetAndCacheEntryInfo(firstEntryID);
		local definitionInfo = entryInfo and talentFrame:GetAndCacheDefinitionInfo(entryInfo.definitionID) or nil;
		return TalentButtonUtil.CalculateIconTextureFromInfo(definitionInfo);
	end

	return TalentButtonUtil.CalculateIconTextureFromInfo(self.definitionInfo);
end

function TalentButtonCapstoneWithTrackMixin:GetProgressBarAtlas()
	local trackType = self.Track.trackType;
	if self:IsMaxed() then
		return trackType == "Round" and "talents-node-apex-bar-full" or "talents-node-apex-active-bar-full";
	elseif self:HasProgress() then
		return trackType == "Round" and "talents-node-apex-bar-half" or "talents-node-apex-active-bar-half";
	else
		return trackType == "Round" and "talents-node-apex-bar-base" or "talents-node-apex-active-bar-base";
	end
end

function TalentButtonCapstoneWithTrackMixin:UpdateProgressBar()
	self.Track.ProgressBar:SetAtlas(self:GetProgressBarAtlas(), TextureKitConstants.UseAtlasSize);
end

function TalentButtonCapstoneWithTrackMixin:ReleaseTrackPips()
	local talentFrame = self:GetTalentFrame();
	for _index, pipFrame in ipairs(self.trackPipArray) do
		talentFrame:ReleaseTalentDisplayFrame(pipFrame);
	end
	self.trackPipArray = {};
end

function TalentButtonCapstoneWithTrackMixin:GetCapstonePipMixin()
	return TalentButtonCapstonePipMixin;
end

function TalentButtonCapstoneWithTrackMixin:AcquirePipFrame(talentFrame, talentType)
	local pipFrame, isNew = talentFrame:AcquireTalentDisplayFrame(talentType, self:GetCapstonePipMixin());
	return pipFrame, isNew;
end

-- Note: The existing progress bar art assets only support 3 pips per track
-- If we want more pips in the future we need new art
local PipAnchorTable = {
	Round = {
		{ point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT", x = -8, y = 10 },
		{ point = "CENTER", relativePoint = "BOTTOM", x = 0, y = 4 },
		{ point = "BOTTOMRIGHT", relativePoint = "BOTTOMRIGHT", x = 8, y = 10 },
	},
	Line = {
		{ point = "CENTER", relativePoint = "LEFT", x = 0, y = 0 },
		{ point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 },
		{ point = "CENTER", relativePoint = "RIGHT", x = 0, y = 0 },
	},
};

function TalentButtonCapstoneWithTrackMixin:UpdateTrack()
	self:UpdateProgressBar();

	self:ReleaseTrackPips();

	local talentFrame = self:GetTalentFrame();
	local nodeInfo = self:GetNodeInfo();
	local pipAnchorPoints = PipAnchorTable[self.Track.trackType];
	for index, entryID in ipairs(nodeInfo.entryIDs) do
		local pipFrame, _isNew = self:AcquirePipFrame(talentFrame, Enum.TraitNodeEntryType.SpendCapstoneCircle);
		
		pipFrame:SetParent(self);
		pipFrame:Init(talentFrame);
		pipFrame:SetEntryID(entryID);
		pipFrame:SetLayoutIndex(index);

		pipFrame:UpdateVisualState();
		pipFrame:UpdateSpendText();

		local anchorInfo = pipAnchorPoints[index];
		if anchorInfo then
			pipFrame:SetPoint(anchorInfo.point, self.Track.ProgressBar, anchorInfo.relativePoint, anchorInfo.x, anchorInfo.y);
			pipFrame:Show();
		end

		table.insert(self.trackPipArray, pipFrame);
	end
end

function TalentButtonCapstoneWithTrackMixin:AddTooltipTitle(tooltip)
	local name = self:GetName();
	local nodeInfo = self:GetNodeInfo();
	if nodeInfo and nodeInfo.totalMaxRanks > 0 then
		GameTooltip_SetTitle(tooltip, TALENT_BUTTON_TOOLTIP_CAPSTONE_TRACK_TITLE_FORMAT:format(name, nodeInfo.currentRank, nodeInfo.totalMaxRanks));
	else
		GameTooltip_SetTitle(tooltip, name);
	end

	if nodeInfo and nodeInfo.entryIDs then
		local talentFrame = self:GetTalentFrame();
		local entryInfo = talentFrame:GetAndCacheEntryInfo(nodeInfo.entryIDs[1]);
		local definitionInfo = entryInfo and talentFrame:GetAndCacheDefinitionInfo(entryInfo.definitionID);
		if definitionInfo and C_Spell.IsSpellPassive(definitionInfo.spellID) then
			GameTooltip_AddHighlightLine(tooltip, SPELL_PASSIVE);
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end
	end
end

function TalentButtonCapstoneWithTrackMixin:AddTooltipInfo(tooltip)
	-- Skip the inherited logic of TalentButtonSpendMixin:AddTooltipInfo to avoid showing ranks
	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentButtonCapstoneWithTrackMixin:AddTooltipDescription(tooltip)
	local nodeInfo = self:GetNodeInfo();
	if not nodeInfo then
		TalentDisplayMixin.AddTooltipDescription(self, tooltip);
		return;
	end

	local talentFrame = self:GetTalentFrame();
	local remainingRanks = nodeInfo.ranksPurchased or 0;
	for index, entryID in ipairs(nodeInfo.entryIDs) do
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);
		local maxRanks = entryInfo and entryInfo.maxRanks or 0;
		local spentInTier = math.min(remainingRanks, maxRanks);
		remainingRanks = math.max(remainingRanks - maxRanks, 0);

		local isFirstTier = index == 1;
		if not isFirstTier then
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end
		GameTooltip_AddHighlightLine(tooltip, TOOLTIP_TALENT_RANK_CAPSTONE:format(index));

		for rank = 1, maxRanks do
			local isFirstRank = rank == 1;
			if not isFirstRank then
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			local isPurchased = rank <= spentInTier;
			local tooltipInfo = CreateBaseTooltipInfo("GetTraitEntry", entryID, rank);
			local entryHasMultipleRanks = maxRanks > 1;
			tooltipInfo.excludeLines = { Enum.TooltipDataLineType.SpellPassive,	};
			tooltipInfo.linePreCall = function(tooltip, lineData)
				local useRankStageFormat = entryHasMultipleRanks and lineData.type == Enum.TooltipDataLineType.SpellDescription;
				if useRankStageFormat then
					lineData.leftText = TALENT_BUTTON_TOOLTIP_CAPSTONE_RANK_STAGE_FORMAT:format(rank, lineData.leftText);
				end

				lineData.leftColor = isPurchased and NORMAL_FONT_COLOR or DISABLED_FONT_COLOR;
			end;
			tooltipInfo.append = true;
			tooltip:ProcessInfo(tooltipInfo);
		end
	end
end

function TalentButtonCapstoneWithTrackMixin:AddTooltipInstructions(tooltip)
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
	end
	
	if canRefund then
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
