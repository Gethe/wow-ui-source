
ProfessionSpecTabMixin = {};

local ProfessionSpecTabEvents =
{
	"TRAIT_NODE_CHANGED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

function ProfessionSpecTabMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionSpecTabEvents);
end

function ProfessionSpecTabMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionSpecTabEvents);
end

function ProfessionSpecTabMixin:OnEvent(event, ...)
	if event == "TRAIT_NODE_CHANGED" then
		local nodeID = ...;
		if nodeID == self.tabInfo.rootNodeID then
			self:UpdateState();
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		self:UpdateState();
	end
end

function ProfessionSpecTabMixin:OnClick()
	if not self:GetParent():AnyPopupShown() then
		local talentFrame = self:GetParent();
		if talentFrame:HasAnyConfigChanges() then
			local info = {};
			info.onAccept = function()
				talentFrame:CommitConfig();
				EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self.traitTreeID);
			end
			info.onCancel = function()
				talentFrame:RollbackConfig();
				EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self.traitTreeID);
			end
			StaticPopup_Show("PROFESSIONS_SPECIALIZATION_ASK_TO_SAVE", nil, nil, info);
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
			EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self.traitTreeID);
		end
	end
end

function ProfessionSpecTabMixin:OnLoad()
	local function TabSelectedCallback(_, selectedID)
		self:SetTabSelected(selectedID == self.traitTreeID);
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.TabSelected", TabSelectedCallback, self);

	self:HandleRotation();
	self:SetTabWidth(180);
end

function ProfessionSpecTabMixin:SetState(state)
	self.state = state;

	local isUnlocked = state == Enum.ProfessionsSpecTabState.Unlocked;
	local nameText = (state ~= Enum.ProfessionsSpecTabState.Locked) and self.tabInfo.name or DISABLED_FONT_COLOR:WrapTextInColorCode(self.tabInfo.name);
	self.Text:SetText(nameText);
	self.StateIcon:SetShown(not isUnlocked);
	if not isUnlocked then
		self.StateIcon:ClearAllPoints();
		self.StateIcon:SetPoint("LEFT", self.Text, "RIGHT", 0, 0);
		local canUnlock = state == Enum.ProfessionsSpecTabState.Unlockable;
		-- HRO TODO: Different asset when unlockable
		self.StateIcon:SetAtlas(canUnlock and "AdventureMapIcon-Lock" or "AdventureMapIcon-Lock", TextureKitConstants.IgnoreAtlasSize);
	end
end

function ProfessionSpecTabMixin:GetState()
	return self.state;
end

function ProfessionSpecTabMixin:GetConfigID()
	return self:GetParent():GetConfigID();
end

function ProfessionSpecTabMixin:ShouldDisplaySource()
	return self:GetState() == Enum.ProfessionsSpecTabState.Locked;
end

function ProfessionSpecTabMixin:AddTooltipSource(tooltip, addBlankLine)
	if self:ShouldDisplaySource() then
		if addBlankLine then
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end

		local sourceDescription = C_ProfSpecs.GetSourceTextForPath(self.tabInfo.rootNodeID, self:GetConfigID());
		GameTooltip_AddErrorLine(tooltip, sourceDescription);
	end
end

function ProfessionSpecTabMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip_AddHighlightLine(GameTooltip, self.tabInfo.name);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, self.tabInfo.description);
	self:AddTooltipSource(GameTooltip, true);

	GameTooltip:Show();
end

function ProfessionSpecTabMixin:OnLeave()
	GameTooltip_Hide();
end

function ProfessionSpecTabMixin:UpdateState()
	local state = C_ProfSpecs.GetStateForTab(self.traitTreeID, self:GetConfigID());

	if state ~= self:GetState() then
		self:SetState(state);
	end
end

function ProfessionSpecTabMixin:Init(traitTreeID)
	local tabInfo = C_ProfSpecs.GetTabInfo(traitTreeID);
	if not tabInfo then
		self:Hide();
		return false;
	end

	self.traitTreeID = traitTreeID;
	self.tabInfo = tabInfo;
	self.state = nil;

	self:SetTabSelected(false);
	self:UpdateState();
	self:Show();

	return true;
end


ProfessionsSpecPathMixin = CreateFromMixins(TalentButtonSpendMixin);

function ProfessionsSpecPathMixin:OnLoad()
	TalentButtonBasicArtMixin.OnLoad(self);

	self:SetAndApplySize(self.iconSize, self.iconSize);
	self.ProgressBar:SetSize(self.progressBarSize, self.progressBarSize);
	self.ProgressBar.Background:SetSize(self.progressBarSize, self.progressBarSize);
	self.StateBorder:SetShown(false);

	if not self.isDetailedView then
		local function PathSelectedCallback(_, selectedID)
			self:SetSelected(selectedID == self:GetTalentNodeID());
		end
		EventRegistry:RegisterCallback("ProfessionsSpecializations.PathSelected", PathSelectedCallback, self);
	end
end

function ProfessionsSpecPathMixin:SetAndApplySize(width, height) -- Override
	self:ApplySize(width, height);
	local displayWidth, displayHeight = self:GetSize();
	local dx = (displayWidth - width) / 2;
	local dy = (displayHeight - height) / 2;
	self:SetHitRectInsets(dx, dx, dy, dy);
end

function ProfessionsSpecPathMixin:OnClick(button, down) -- Override
	if not self.isDetailedView and not self:GetTalentFrame():AnyPopupShown() then
		if not self.selected then
			EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", self:GetTalentNodeID());
		elseif self.state == Enum.ProfessionsSpecPathState.Locked and self:CanAfford() and button == "LeftButton" then
			local talentFrame = self:GetTalentFrame();
			if talentFrame:GetRootNodeID() == self:GetTalentNodeID() then
				talentFrame:CheckConfirmPurchaseTab();
			else
				talentFrame:CheckConfirmPurchasePath();
			end
		else
			TalentButtonSpendMixin.OnClick(self, button, down);
		end
		self:OnEnter();
	end
end

function ProfessionsSpecPathMixin:GetConfigID()
	return self:GetTalentFrame():GetConfigID();
end

function ProfessionsSpecPathMixin:GetActiveEntry()
	return self.talentNodeInfo.activeEntry and self.talentNodeInfo.activeEntry.entryID;
end

function ProfessionsSpecPathMixin:GetNextEntry()
	return self.talentNodeInfo.nextEntry and self.talentNodeInfo.nextEntry.entryID;
end

function ProfessionsSpecPathMixin:GetRanks()
	-- First tier for the path node is the unlock entry, which we do not want to include in the count. It can have a max ranks of either 0 or 1
	local unlockNodeEntry = C_ProfSpecs.GetUnlockEntryForPath(self:GetTalentNodeID());
	local nodeEntryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), unlockNodeEntry);
	local numUnlockPoints = nodeEntryInfo and nodeEntryInfo.maxRanks or 0;
	local currRank = (self.talentNodeInfo.currentRank > 0) and (self.talentNodeInfo.currentRank - numUnlockPoints) or self.talentNodeInfo.currentRank;
	local maxRank = self.talentNodeInfo.maxRanks - numUnlockPoints;
	return currRank, maxRank;
end

function ProfessionsSpecPathMixin:GetSpendText() -- Override
	local currRank, maxRank = self:GetRanks();
	return currRank;
end

function ProfessionsSpecPathMixin:CanPurchaseUnlock()
	return C_Traits.CanPurchaseRank(self:GetConfigID(), self.talentNodeInfo.ID, C_ProfSpecs.GetUnlockEntryForPath(self.talentNodeInfo.ID)) and self:CanAfford();
end

function ProfessionsSpecPathMixin:CanPurchaseSpend()
	return C_Traits.CanPurchaseRank(self:GetConfigID(), self.talentNodeInfo.ID, C_ProfSpecs.GetSpendEntryForPath(self.talentNodeInfo.ID)) and self:CanAfford();
end

function ProfessionsSpecPathMixin:OnEvent(event, ...)
	if event == "SPELL_TEXT_UPDATE" then
		self:OnEnter();
	end
end

function ProfessionsSpecPathMixin:OnEnter() -- Override
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self.Icon, "TOPRIGHT");

	self:AddTooltipTitle(tooltip);
	self:AddTooltipInfo(tooltip);
	self:AddTooltipNextPerk(tooltip);
	local addBlankLine = true;
	self:AddTooltipSource(tooltip, addBlankLine);
	self:AddTooltipInstructions(tooltip);

	tooltip:Show();

	self:SetScript("OnEvent", self.OnEvent);
	self:RegisterEvent("SPELL_TEXT_UPDATE");
end

function ProfessionsSpecPathMixin:OnLeave() -- Override
	GameTooltip_Hide();
	self:SetScript("OnEvent", nil);
	self:UnregisterEvent("SPELL_TEXT_UPDATE");
end

function ProfessionsSpecPathMixin:ShouldDisplaySource()
	return (self.state == Enum.ProfessionsSpecPathState.Locked) and (not self:CanAfford());
end

function ProfessionsSpecPathMixin:GetNextPerkDescription()
	local perkIDs = C_ProfSpecs.GetPerksForPath(self.talentNodeInfo.ID);
	for _, perkID in ipairs(perkIDs) do
		if not C_ProfSpecs.PerkIsEarned(perkID, self:GetConfigID()) then
			local unlockRank = C_ProfSpecs.GetUnlockRankForPerk(perkID);
			local perkDescription = C_ProfSpecs.GetDescriptionForPerk(perkID);
			local descriptionText;
			if unlockRank == 0 then
				descriptionText = PROFESSIONS_SPECIALIZATION_NEXT_PERK_UNLOCK:format(perkDescription);
			else
				descriptionText = PROFESSIONS_SPECIALIZATION_NEXT_PERK_RANK:format(unlockRank, perkDescription);
			end

			return descriptionText;
		end
	end
end

function ProfessionsSpecPathMixin:AddTooltipNextPerk(tooltip)
	local descriptionText = self:GetNextPerkDescription();
	if descriptionText ~= nil then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddNormalLine(tooltip, descriptionText);
	end
end

function ProfessionsSpecPathMixin:AddTooltipSource(tooltip, addBlankLine)
	if self:ShouldDisplaySource() then
		if addBlankLine then
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end

		local sourceDescription = C_ProfSpecs.GetSourceTextForPath(self.talentNodeInfo.ID, self:GetConfigID());
		GameTooltip_AddErrorLine(tooltip, sourceDescription);
	end
end

function ProfessionsSpecPathMixin:AddTooltipInfo(tooltip) -- Override
	local subtext = (self.state == Enum.ProfessionsSpecPathState.Locked) and PROFESSIONS_SPECIALIZATION_LOCKED or PROFESSIONS_SPECIALIZATION;
	GameTooltip_AddColoredLine(tooltip, subtext, GRAY_FONT_COLOR);

	local currRank, maxRank = self:GetRanks();
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(currRank, maxRank));

	GameTooltip_AddBlankLineToTooltip(tooltip);

	GameTooltip_AddNormalLine(tooltip, C_ProfSpecs.GetDescriptionForPath(self.talentNodeInfo.ID));
end

function ProfessionsSpecPathMixin:AddTooltipInstructions(tooltip) -- Override
	TalentDisplayMixin.AddTooltipInstructions(self, tooltip);

	if not self.isDetailedView then
		if not self.selected then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddInstructionLine(tooltip, PROFESSIONS_SPECIALIZATION_VIEW_DETAILS);
		else
			local canPurchase = self:CanPurchaseRank();
			local canRefund = self:CanRefundRank();
			if canPurchase or canRefund then
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			if canPurchase then
				local spendInstruction = self.state == Enum.ProfessionsSpecPathState.Locked and PROFESSIONS_SPECS_TOOLTIP_UNLOCK or PROFESSIONS_SPECS_TOOLTIP_SPEND;
				GameTooltip_AddInstructionLine(tooltip, spendInstruction);
			elseif canRefund then
				GameTooltip_AddDisabledLine(tooltip, PROFESSIONS_SPECS_TOOLTIP_REFUND);
			end
		end
	end
end

function ProfessionsSpecPathMixin:CalculateVisualState() -- Override
	return C_ProfSpecs.GetStateForPath(self.talentNodeInfo.ID, self:GetConfigID());
end

function ProfessionsSpecPathMixin:SetSelected(selected)
	self.selected = selected;

	self.SelectedOverlay:SetShown(selected);
end

local PathStateInfo =
{
	[Enum.ProfessionsSpecPathState.Locked] =
	{
		showPoints = false,
		showProgressBar = false,
		showLock = true,
	},
	[Enum.ProfessionsSpecPathState.Progressing] =
	{
		showPoints = true,
		showProgressBar = true,
		showLock = false,
	},
	[Enum.ProfessionsSpecPathState.Completed] =
	{
		showPoints = true,
		showProgressBar = true,
		showLock = false,
	},
};

function ProfessionsSpecPathMixin:SetVisualState(state) -- Override
	local baseVisualState;
	if state == Enum.ProfessionsSpecPathState.Locked then
		local showPathAvailable = self:CanPurchaseUnlock() and self:GetTalentNodeID() ~= self:GetTalentFrame():GetRootNodeID();
		baseVisualState = showPathAvailable and TalentButtonUtil.BaseVisualState.Selectable or TalentButtonUtil.BaseVisualState.Locked;
	elseif state == Enum.ProfessionsSpecPathState.Progressing then
		baseVisualState = self:CanPurchaseSpend() and TalentButtonUtil.BaseVisualState.Selectable or TalentButtonUtil.BaseVisualState.Normal;
	else
		baseVisualState = TalentButtonUtil.BaseVisualState.Maxed;
	end

	if self.state == state and self.visualState == baseVisualState then
		return;
	end

	TalentButtonBasicArtMixin.ApplyVisualState(self, baseVisualState);

	self.state = state;

	local stateInfo = PathStateInfo[state];
	self.SpendText:SetShown(stateInfo.showPoints and not self.isDetailedView);
	self.ProgressBar:SetShown(stateInfo.showProgressBar or self.isDetailedView);
	self.LockedIcon:SetShown(stateInfo.showLock);
end

function ProfessionsSpecPathMixin:UpdateProgressBar()
	if self.ProgressBar:IsShown() then
		local currRank, maxRank = self:GetRanks();
		CooldownFrame_SetDisplayAsPercentage(self.ProgressBar, currRank / maxRank);
	end
end

function ProfessionsSpecPathMixin:UpdateSpendText() -- Override
	if self.talentInfo ~= nil then
		self.SpendText:SetText(self:GetSpendText());
		self:UpdateProgressBar();
	end
end

function ProfessionsSpecPathMixin:SetTalentNodeID(talentNodeID, skipUpdate) -- Override
	local oldNodeID = self.talentNodeID;
	self.talentNodeID = talentNodeID;
	self:UpdateTalentNodeInfo(skipUpdate);
	if not self.isDetailedView then
		self:GetTalentFrame():OnButtonNodeIDSet(self, oldNodeID, talentNodeID);
	end
end

-- Do not want to reinstantiate when the entry changes, so we use the base display mixin's version
ProfessionsSpecPathMixin.UpdateEntryInfo = TalentDisplayMixin.UpdateEntryInfo;


ProfessionsSpecPerkMixin = CreateFromMixins(TalentButtonBasicArtMixin, TalentDisplayMixin);

function ProfessionsSpecPerkMixin:GetRotation()
	local _, parentMaxRank = self:GetTalentFrame():GetDetailedPanelPath():GetRanks();

	-- HRO TODO: (math.pi / 180) is a hack to sidestep issues at exactly 1/3-quarter rotation
	return (self.unlockRank / parentMaxRank) * 2 * math.pi + (math.pi / 180);
end

function ProfessionsSpecPerkMixin:SetPerkID(perkID)
	self.perkID = perkID;
	self.unlockRank = C_ProfSpecs.GetUnlockRankForPerk(self.perkID);

	local rotation = self:GetRotation();
	-- Convert rotation to counter-clockwise rotation
	rotation = (math.pi * 2) - rotation;
	for _, texture in ipairs(self.RotatedTextures) do
		texture:SetRotation(rotation);
	end

	local entryID = C_ProfSpecs.GetEntryIDForPerk(perkID);
	self:SetEntryID(entryID);
end

function ProfessionsSpecPerkMixin:IsEarned()
	return C_ProfSpecs.PerkIsEarned(self.perkID, self:GetTalentFrame():GetConfigID());
end

function ProfessionsSpecPerkMixin:UpdateIconTexture() -- Override
	local color = self:IsEarned() and HIGHLIGHT_FONT_COLOR or BLACK_FONT_COLOR;
	local r, g, b = color:GetRGB();
	local a = 1;
	self.Icon:SetColorTexture(r, g, b, a);
end

function ProfessionsSpecPerkMixin:OnEvent(event, ...)
	if event == "SPELL_TEXT_UPDATE" then
		self:OnEnter();
	end
end

function ProfessionsSpecPerkMixin:OnEnter() -- Override
	local tooltip = self:AcquireTooltip();

	GameTooltip_AddHighlightLine(tooltip, C_ProfSpecs.GetDescriptionForPerk(self.perkID));
	if not self:IsEarned() then
		GameTooltip_AddBlankLineToTooltip(tooltip);

		local parentPathName = self:GetTalentFrame():GetDetailedPanelPath():GetName();
		local sourceDescription;
		if self.unlockRank > 0 then
			sourceDescription = PROFESSIONS_SPECIALIZATION_PERK_RANK_SOURCE:format(self.unlockRank, parentPathName);
		else
			sourceDescription = PROFESSIONS_SPECIALIZATION_PERK_UNLOCK_SOURCE:format(parentPathName);
		end
		GameTooltip_AddErrorLine(tooltip, sourceDescription);
	end

	tooltip:Show();

	self:SetScript("OnEvent", self.OnEvent);
	self:RegisterEvent("SPELL_TEXT_UPDATE");
end

function ProfessionsSpecPerkMixin:OnLeave()
	GameTooltip_Hide();
	self:SetScript("OnEvent", nil);
	self:UnregisterEvent("SPELL_TEXT_UPDATE");
end