
local dialBaseAngle = 1.4;

local professionVertexColors =
{
	[Enum.Profession.FirstAid] = PROFESSION_SPEC_COLOR_FIRST_AID,
	[Enum.Profession.Blacksmithing] = PROFESSION_SPEC_COLOR_BLACKSMITHING,
	[Enum.Profession.Leatherworking] = PROFESSION_SPEC_COLOR_LEATHERWORKING,
	[Enum.Profession.Alchemy] = PROFESSION_SPEC_COLOR_ALCHEMY,
	[Enum.Profession.Herbalism] = PROFESSION_SPEC_COLOR_HERBALISM,
	[Enum.Profession.Cooking] = PROFESSION_SPEC_COLOR_COOKING,
	[Enum.Profession.Mining] = PROFESSION_SPEC_COLOR_MINING,
	[Enum.Profession.Tailoring] = PROFESSION_SPEC_COLOR_TAILORING,
	[Enum.Profession.Engineering] = PROFESSION_SPEC_COLOR_ENGINEERING,
	[Enum.Profession.Enchanting] = PROFESSION_SPEC_COLOR_ENCHANTING,
	[Enum.Profession.Fishing] = PROFESSION_SPEC_COLOR_FISHING,
	[Enum.Profession.Skinning] = PROFESSION_SPEC_COLOR_SKINNING,
	[Enum.Profession.Jewelcrafting] = PROFESSION_SPEC_COLOR_JEWELCRAFTING,
	[Enum.Profession.Inscription] = PROFESSION_SPEC_COLOR_INSCRIPTION,
	[Enum.Profession.Archaeology] = PROFESSION_SPEC_COLOR_ARCHAEOLOGY,
};

function ProfessionDial_GetRelativeRotation(currRank, maxRank, inPct)
	local rads = (currRank / maxRank) * (2 * math.pi - dialBaseAngle) + (dialBaseAngle / 2);
	return inPct and rads / (2 * math.pi) or rads;
end


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
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
		EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", self.traitTreeID);
	end
end

function ProfessionSpecTabMixin:OnLoad()
	local function TabSelectedCallback(_, selectedID)
		self.isSelected = (selectedID == self.traitTreeID);
		self:SetTabSelected(self.isSelected);
		self.StateIconGlow:SetShown(self.state == Enum.ProfessionsSpecTabState.Unlockable and not self.isSelected);
		self.BottomBorderGlow:SetShown(self.isSelected);
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.TabSelected", TabSelectedCallback, self);

	self.StateIcon:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_NEW_CHOICE_SPECIALIZATION:format(self:GetParent().professionInfo.professionName));
		GameTooltip:Show();
	end);

	self:HandleRotation();
end

function ProfessionSpecTabMixin:SetState(state)
	self.state = state;

	local isUnlocked = state == Enum.ProfessionsSpecTabState.Unlocked;
	local nameText = (state ~= Enum.ProfessionsSpecTabState.Locked) and self.tabInfo.name or DISABLED_FONT_COLOR:WrapTextInColorCode(self.tabInfo.name);
	self.Text:SetText(nameText);
	self.StateIcon:SetShown(not isUnlocked);
	if not isUnlocked then
		self.StateIcon:ClearAllPoints();
		self.StateIcon:SetPoint("LEFT", self.Text, "RIGHT", 6, 0);
	end

	local unlockable = (state == Enum.ProfessionsSpecTabState.Unlockable);
	self.StateIcon:SetMouseMotionEnabled(unlockable);
	self.StateIconGlow:SetShown(self.state == Enum.ProfessionsSpecTabState.Unlockable and not self.isSelected);
	if unlockable then
		self.StateIconGlowAnim:Play();
	else
		self.StateIconGlowAnim:Stop();
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

	EventRegistry:TriggerEvent("ProfessionSpecs.SpecTabEntered", self.traitTreeID);
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

	self.Text:SetText(tabInfo.name);
	self:SetTabSelected(false);
	self:UpdateState();
	self:Show();

	local minWidth = 180;
	local bufferWidth = 40;
	local stretchWidth = self.Text:GetStringWidth() + (self.StateIcon:GetWidth() * 2) + bufferWidth;
	self:SetTabWidth(math.max(minWidth, stretchWidth));

	return true;
end


ProfessionsSpecPathMixin = CreateFromMixins(TalentButtonSpendMixin);

function ProfessionsSpecPathMixin:Reset()
	self.state = nil;
	self:CancelEffects();
end

function ProfessionsSpecPathMixin:AdjustBaseArt()
	self.SpendText:ClearAllPoints();
	self.SpendText:SetPoint("BOTTOM", self, "BOTTOM", 1, -2);
end

function ProfessionsSpecPathMixin:OnLoad()
	TalentButtonArtMixin.OnLoad(self);

	self:AdjustBaseArt();
	self:SetAndApplySize(self.iconSize, self.iconSize);
	self.ProgressBar:SetSize(self.progressBarSizeX, self.progressBarSizeY);
	self.StateBorder:SetShown(false);
	self.selectSound = SOUNDKIT.UI_PROFESSION_SPEC_PATH_SPEND;

	if not self.isDetailedView then
		local function PathSelectedCallback(_, selectedID)
			self:SetSelected(selectedID == self:GetNodeID());
		end
		EventRegistry:RegisterCallback("ProfessionsSpecializations.PathSelected", PathSelectedCallback, self);
	end

	local function LockInPathCallback(_, nodeID)
		if nodeID == self:GetNodeID() and self:IsShown() then
			self:QueueUnlockPathEffects();
		end
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.LockInPath", LockInPathCallback, self);

	local function CompletePathCallback(_, nodeID)
		if nodeID == self:GetNodeID() and self:IsShown() then
			self:QueueFinishPathEffects();
		end
	end
	EventRegistry:RegisterCallback("ProfessionsSpecializations.CompletePath", CompletePathCallback, self);

	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
end

function ProfessionsSpecPathMixin:OnShow()
	if not self.isDetailedView then
		self.AvailableGlowAnim:Play();
	end
end

function ProfessionsSpecPathMixin:OnHide()
	if not self.isDetailedView then
		self.AvailableGlowAnim:Pause();
	end
	self:CancelEffects();
end

function ProfessionsSpecPathMixin:SetAndApplySize(width, height) -- Override
	self.Icon:SetSize(width, height);
	local maskOffset = -7;
	self.IconMask:SetSize(width + maskOffset, height + maskOffset);
	local displayWidth, displayHeight = self:GetSize();
	local dx = (displayWidth - width) / 2;
	local dy = (displayHeight - height) / 2;
	self:SetHitRectInsets(dx, dx, dy, dy);
end

function ProfessionsSpecPathMixin:OnClick(button, down) -- Override
	if not self.isDetailedView and not self:GetTalentFrame():AnyPopupShown() then
		if not self.selected then
			EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", self:GetNodeID());
		elseif button == "LeftButton" and IsShiftKeyDown() and self:CanPurchaseRank() then
			local talentFrame = self:GetTalentFrame();
			if talentFrame:GetRootNodeID() == self:GetNodeID() and self.state == Enum.ProfessionsSpecPathState.Locked then
				talentFrame:CheckConfirmPurchaseTab();
			else
				self:PurchaseRank();
			end
		end
		self:OnEnter();
	end
end

-- The intention is for only UI_PROFESSION_SPEC_DIAL_LOCKIN (207714) to be played.
local SuppressedSoundsOnPurchaseRank = {
	SOUNDKIT.UI_PROFESSION_SPEC_PERK_EARNED, 
};

function ProfessionsSpecPathMixin:PurchaseRank() -- Override
	if self.state == Enum.ProfessionsSpecPathState.Locked then
		self:GetTalentFrame():SetSuppressedSounds(SuppressedSoundsOnPurchaseRank);
		self:GetTalentFrame():PlayDialLockInAnimation();
	else
		self:PlaySelectSound();
	end
	self:GetTalentFrame():PurchaseRank(self:GetNodeID());
	self:GetTalentFrame():ClearSuppressedSounds();

	self:OnEnter();
end

function ProfessionsSpecPathMixin:GetConfigID()
	return self:GetTalentFrame():GetConfigID();
end

function ProfessionsSpecPathMixin:GetActiveEntry()
	return self.nodeInfo.activeEntry and self.nodeInfo.activeEntry.entryID;
end

function ProfessionsSpecPathMixin:GetNextEntry()
	return self.nodeInfo.nextEntry and self.nodeInfo.nextEntry.entryID;
end

function ProfessionsSpecPathMixin:GetRanks()
	-- First tier for the path node is the unlock entry, which we do not want to include in the count. It can have a max ranks of either 0 or 1
	local unlockNodeEntry = C_ProfSpecs.GetUnlockEntryForPath(self:GetNodeID());
	local nodeEntryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), unlockNodeEntry);
	local numUnlockPoints = nodeEntryInfo and nodeEntryInfo.maxRanks or 0;
	local currRank = (self.nodeInfo.currentRank > 0) and (self.nodeInfo.currentRank - numUnlockPoints) or self.nodeInfo.currentRank;
	local maxRank = self.nodeInfo.maxRanks - numUnlockPoints;
	return currRank, maxRank;
end

function ProfessionsSpecPathMixin:GetSpendText() -- Override
	local currRank, maxRank = self:GetRanks();
	return currRank;
end

function ProfessionsSpecPathMixin:CanPurchaseUnlock()
	return self.nodeInfo and self:GetConfigID() and C_Traits.CanPurchaseRank(self:GetConfigID(), self.nodeInfo.ID, C_ProfSpecs.GetUnlockEntryForPath(self.nodeInfo.ID)) and self:CanAfford();
end

function ProfessionsSpecPathMixin:CanPurchaseSpend()
	return self.nodeInfo and self:GetConfigID() and C_Traits.CanPurchaseRank(self:GetConfigID(), self.nodeInfo.ID, C_ProfSpecs.GetSpendEntryForPath(self.nodeInfo.ID)) and self:CanAfford();
end

function ProfessionsSpecPathMixin:OnEvent(event, ...)
	if event == "SPELL_TEXT_UPDATE" then
		self:OnEnter();
	end
end

function ProfessionsSpecPathMixin:OnEnter() -- Override
	if GetMouseFocus() ~= self then
		return;
	end

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

	if not self.isDetailedView then
		self.MouseoverOverlay:Show();
		self.IconMouseoverHighlight:Show();
	end

	EventRegistry:TriggerEvent("ProfessionSpecs.SpecPathEntered", self.nodeInfo.ID, self:GetName());
end

function ProfessionsSpecPathMixin:OnLeave() -- Override
	GameTooltip_Hide();
	self:SetScript("OnEvent", nil);
	self:UnregisterEvent("SPELL_TEXT_UPDATE");
	self.MouseoverOverlay:Hide();
	self.IconMouseoverHighlight:Hide();
end

function ProfessionsSpecPathMixin:ShouldDisplaySource()
	return (self.state == Enum.ProfessionsSpecPathState.Locked) and (not self:CanAfford());
end

function ProfessionsSpecPathMixin:GetNextPerkDescription()
	local perkInfos = C_ProfSpecs.GetPerksForPath(self.nodeInfo.ID);
	for _, perkInfo in ipairs(perkInfos) do
		local perkID = perkInfo.perkID;
		if C_ProfSpecs.GetStateForPerk(perkID, self:GetConfigID()) == Enum.ProfessionsSpecPerkState.Unearned then
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
		descriptionText = descriptionText:gsub("\|cffffffff(.-)\|r", "%1");
		GameTooltip_AddNormalLine(tooltip, descriptionText);
	end
end

function ProfessionsSpecPathMixin:AddTooltipSource(tooltip, addBlankLine)
	if self:ShouldDisplaySource() then
		if addBlankLine then
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end

		local sourceDescription = C_ProfSpecs.GetSourceTextForPath(self.nodeInfo.ID, self:GetConfigID());
		GameTooltip_AddErrorLine(tooltip, sourceDescription);
	end
end

function ProfessionsSpecPathMixin:AddTooltipInfo(tooltip) -- Override
	local subtext = (self.state == Enum.ProfessionsSpecPathState.Locked) and PROFESSIONS_SPECIALIZATION_LOCKED or PROFESSIONS_SPECIALIZATION;
	GameTooltip_AddColoredLine(tooltip, subtext, GRAY_FONT_COLOR);

	local currRank, maxRank = self:GetRanks();
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(currRank, maxRank));

	GameTooltip_AddBlankLineToTooltip(tooltip);

	GameTooltip_AddNormalLine(tooltip, C_ProfSpecs.GetDescriptionForPath(self.nodeInfo.ID));
end

function ProfessionsSpecPathMixin:AddTooltipInstructions(tooltip) -- Override
	TalentDisplayMixin.AddTooltipInstructions(self, tooltip);

	if not self.isDetailedView then
		if not self.selected then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddInstructionLine(tooltip, PROFESSIONS_SPECIALIZATION_VIEW_DETAILS);
		else
			local canPurchase = self:CanPurchaseRank();
			if canPurchase then
				GameTooltip_AddBlankLineToTooltip(tooltip);
				local spendInstruction = self.state == Enum.ProfessionsSpecPathState.Locked and PROFESSIONS_SPECS_TOOLTIP_UNLOCK or PROFESSIONS_SPECS_TOOLTIP_SPEND;
				GameTooltip_AddInstructionLine(tooltip, spendInstruction);
			end
		end
	end
end

function ProfessionsSpecPathMixin:CalculateVisualState() -- Override
	return C_ProfSpecs.GetStateForPath(self.nodeInfo.ID, self:GetConfigID());
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
		showLock = true,
	},
	[Enum.ProfessionsSpecPathState.Progressing] =
	{
		showPoints = true,
		showLock = false,
	},
	[Enum.ProfessionsSpecPathState.Completed] =
	{
		showPoints = true,
		showLock = false,
	},
};

function ProfessionsSpecPathMixin:SetVisualState(state) -- Override
	local baseVisualState;
	if state == Enum.ProfessionsSpecPathState.Locked then
		local showPathAvailable = self:CanPurchaseUnlock() and self:GetNodeID() ~= self:GetTalentFrame():GetRootNodeID();
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
	for i, shadow in ipairs(self.spendTextShadows) do
		shadow:SetShown(stateInfo.showPoints and not self.isDetailedView);
	end
	self.LockedIcon:SetShown(stateInfo.showLock);
	self.ProgressBarBackground:SetShown(not self.isDetailedView)

	if not self.isDetailedView then
		local overrideSize = 60;
		self:SetSize(overrideSize, overrideSize);
	end

	local isUnlockable = (state == Enum.ProfessionsSpecPathState.Locked and self:CanPurchaseUnlock() and not self.isDetailedView);
	self.ProgressBarAvailableGlow:SetShown(isUnlockable);
end

function ProfessionsSpecPathMixin:UpdateProgressBar()
	if self.ProgressBar:IsShown() then
		local currRank, maxRank = self:GetRanks();
		local inPct = true;
		local progress = self.isDetailedView and ProfessionDial_GetRelativeRotation(currRank, maxRank, inPct) or (currRank / maxRank);
		CooldownFrame_SetDisplayAsPercentage(self.ProgressBar, progress);
	end
end

function ProfessionsSpecPathMixin:UpdateSpendText() -- Override
	if self.definitionInfo ~= nil then
		TalentButtonUtil.SetSpendText(self, self:GetSpendText());
		self:UpdateProgressBar();
	end
end

function ProfessionsSpecPathMixin:UpdateIconTexture() -- Override
	local texture = self:CalculateIconTexture();
	self.Icon:SetTexture(texture);
	self.IconMouseoverHighlight:SetTexture(texture);
end

function ProfessionsSpecPathMixin:SetNodeID(nodeID, skipUpdate) -- Override
	local oldNodeID = self.nodeID;
	self.nodeID = nodeID;
	self:UpdateNodeInfo(skipUpdate);
	if not self.isDetailedView then
		self:GetTalentFrame():OnButtonNodeIDSet(self, oldNodeID, nodeID);
	end
	self:UpdateAssets();
end

function ProfessionsSpecPathMixin:UpdateAssets()
	local kitSpecifier = Professions.GetAtlasKitSpecifier(self:GetTalentFrame().professionInfo);
	local stylizedProgressBarAtlasName = kitSpecifier and string.format("Professions-Specialization-Node-%s", kitSpecifier);
	local stylizedProgressBarInfo = stylizedProgressBarAtlasName and C_Texture.GetAtlasInfo(stylizedProgressBarAtlasName);
	self.ProgressBar:SetSwipeTexture(stylizedProgressBarInfo.file or stylizedProgressBarInfo.filename);
end

function ProfessionsSpecPathMixin:CancelEffects()
	if self.FxEffectTimer then
		self.FxEffectTimer:Cancel();
	end
end

function ProfessionsSpecPathMixin:QueueUnlockPathEffects()
	self:CancelEffects();

	local delay = 1.15;
	self.FxEffectTimer = C_Timer.NewTimer(delay, function()
		local fxIDs = {150};
		self:PlayPurchaseCompleteEffect(self:GetTalentFrame().FxModelScene, fxIDs)
	end);
end

function ProfessionsSpecPathMixin:QueueFinishPathEffects()
	self:CancelEffects();

	local delay = 0.203;
	self.FxEffectTimer = C_Timer.NewTimer(delay, function()
		local fxIDs = {150, 142, 143};
		self:PlayPurchaseCompleteEffect(self:GetTalentFrame().FxModelScene, fxIDs)
	end);
end

-- Do not want to reinstantiate when the entry changes, so we use the base display mixin's version
ProfessionsSpecPathMixin.UpdateEntryInfo = TalentDisplayMixin.UpdateEntryInfo;


ProfessionsSpecPerkMixin = CreateFromMixins(TalentButtonBasicArtMixin, TalentDisplayMixin);

function ProfessionsSpecPerkMixin:OnLoad()
	TalentButtonBasicArtMixin.OnLoad(self);

	self.PipLockinAnim:SetScript("OnFinished", function() self:UpdateIconTexture(true); end);
end

function ProfessionsSpecPerkMixin:GetParentMaxRank()
	local _, parentMaxRank = self:GetTalentFrame():GetDetailedPanelPath():GetRanks();
	return parentMaxRank;
end

function ProfessionsSpecPerkMixin:GetRotation()
	return ProfessionDial_GetRelativeRotation(self.unlockRank, self:GetParentMaxRank());
end

function ProfessionsSpecPerkMixin:SetPerk(perkInfo)
	self.PipLockinAnim:Stop();
	self.state = nil;
	self.perkID = perkInfo.perkID;
	self.isMajorPerk = perkInfo.isMajorPerk;
	self.unlockRank = C_ProfSpecs.GetUnlockRankForPerk(self.perkID);

	self:UpdateAssets();

	local rotation = self:GetRotation();
	-- Convert rotation to counter-clockwise rotation
	rotation = (math.pi * 2) - rotation;
	-- Asset starts facting up, but we rotate from the bottom
	rotation = rotation + math.pi;
	for _, texture in ipairs(self.RotatedTextures) do
		texture:SetRotation(rotation);
	end

	local entryID = C_ProfSpecs.GetEntryIDForPerk(perkInfo.perkID);
	self:SetEntryID(entryID);
end

function ProfessionsSpecPerkMixin:IsEarned()
	return self.state ~= Enum.ProfessionsSpecPerkState.Unearned;
end

function ProfessionsSpecPerkMixin:UpdateIconTexture(fromAnimEnded) -- Override
	local newState = C_ProfSpecs.GetStateForPerk(self.perkID, self:GetTalentFrame():GetConfigID());
	if newState == self.state and not fromAnimEnded then
		return;
	end

	self.PipLockinAnim:Stop();
	self.PendingGlow:SetShown(newState == Enum.ProfessionsSpecPerkState.Pending);

	if newState == Enum.ProfessionsSpecPerkState.Unearned then
		self.Artwork:SetTexCoord(self.initialLeft, self.initialRight, self.initialTop, self.initialBottom);
	elseif newState == Enum.ProfessionsSpecPerkState.Pending then
		self.Artwork:SetTexCoord(self.initialLeft, self.initialRight, self.initialTop, self.initialBottom);
		if self.state == Enum.ProfessionsSpecPerkState.Unearned then
			if self.unlockRank == self:GetParentMaxRank() then
				PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PATH_FINISHED);
			else
				self:GetTalentFrame():TryPlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PERK_EARNED);
			end
		end
	elseif newState == Enum.ProfessionsSpecPerkState.Earned then
		if fromAnimEnded or self.state == nil then
			self.Artwork:SetTexCoord(self.finalLeft, self.finalRight, self.finalTop, self.finalBottom);
		else
			self.PipLockinAnim:Restart();
			if self.unlockRank == self:GetParentMaxRank() then
				self:GetTalentFrame():PlayCompleteDialAnimation();
				PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PIP_MAX_RANK_LOCKIN);
			else
				PlaySound(SOUNDKIT.UI_PROFESSION_SPEC_PIP_LOCKIN);
			end
			local delay = 0.2;
			self:GetTalentFrame():StartShake(delay);
		end
	end

	self.state = newState;
end

function ProfessionsSpecPerkMixin:OnEvent(event, ...)
	if event == "SPELL_TEXT_UPDATE" then
		self:OnEnter();
	end
end

function ProfessionsSpecPerkMixin:AcquireTooltip() -- Override
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", -25, -25);
	return tooltip;
end

function ProfessionsSpecPerkMixin:OnEnter() -- Override
	local tooltip = self:AcquireTooltip();

	local descriptionText = C_ProfSpecs.GetDescriptionForPerk(self.perkID);
	descriptionText = descriptionText:gsub("\|cffffffff(.-)\|r", "%1");
	GameTooltip_AddNormalLine(tooltip, descriptionText);
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

	EventRegistry:TriggerEvent("ProfessionSpecs.SpecPerkEntered", self.perkID);
end

function ProfessionsSpecPerkMixin:OnLeave()
	GameTooltip_Hide();
	self:SetScript("OnEvent", nil);
	self:UnregisterEvent("SPELL_TEXT_UPDATE");
end

function ProfessionsSpecPerkMixin:UpdateAssets()
	local kitSpecifier = Professions.GetAtlasKitSpecifier(self:GetTalentFrame().professionInfo);
	local pipArtAtlasFormat = self.isMajorPerk and "SpecDial_EndPip_Flipbook_%s" or "SpecDial_Pip_Flipbook_%s";
	local stylizedPipAtlasName = kitSpecifier and pipArtAtlasFormat:format(kitSpecifier);
	local stylizedPipInfo = stylizedPipAtlasName and C_Texture.GetAtlasInfo(stylizedPipAtlasName);
	if not stylizedPipInfo then
		stylizedPipAtlasName = pipArtAtlasFormat:format("Tailoring");
		stylizedPipInfo = C_Texture.GetAtlasInfo(stylizedPipAtlasName);
	end

	self.Artwork:SetAtlas(stylizedPipAtlasName, TextureKitConstants.IgnoreAtlasSize);

	local frameSize = 90;
	local numRows = stylizedPipInfo.height / frameSize;
	local numCols = stylizedPipInfo.width / frameSize;
	local numFrames = numRows * numCols; -- Expected that all rows are filled
	self.PipLockinAnim.FlipBook:SetFlipBookRows(numRows);
	self.PipLockinAnim.FlipBook:SetFlipBookColumns(numCols);
	self.PipLockinAnim.FlipBook:SetFlipBookFrames(numFrames);

	self.initialLeft = 0;
	self.initialRight = 1 / numCols;
	self.initialTop = 0;
	self.initialBottom = 1 / numRows;
	self.finalLeft = 1 - self.initialRight;
	self.finalRight = 1;
	self.finalTop = 1 - self.initialBottom;
	self.finalBottom = 1;

	self.PendingGlow:SetAtlas(self.isMajorPerk and "SpecDial_LastPip_BorderGlow" or "SpecDial_Pip_BorderGlow", TextureKitConstants.UseAtlasSize);
end


ProfessionSpecEdgeArrowMixin = {};

function ProfessionSpecEdgeArrowMixin:UpdateState() -- Override
	local endButton = self:GetEndButton();
	endButton:CanPurchaseUnlock();

	local overrideArrowColor = false;
	
	if endButton.state ~= Enum.ProfessionsSpecPathState.Locked  then
		self.Line:SetAtlas("Professions_Specialization_arrowline", TextureKitConstants.IgnoreAtlasSize);
		self.ArrowHead:SetAtlas("Professions_Specialization_arrowhead", TextureKitConstants.IgnoreAtlasSize);
		overrideArrowColor = true;
	elseif endButton:CanPurchaseUnlock() then
		self.Line:SetAtlas("talents-arrow-line-gray", TextureKitConstants.IgnoreAtlasSize);
		self.ArrowHead:SetAtlas("talents-arrow-head-gray", TextureKitConstants.IgnoreAtlasSize);
	else
		self.Line:SetAtlas("talents-arrow-line-locked", TextureKitConstants.IgnoreAtlasSize);
		self.ArrowHead:SetAtlas("talents-arrow-head-locked", TextureKitConstants.IgnoreAtlasSize);
	end

	local r, g, b = 1, 1, 1;
	if overrideArrowColor then
		local profession = endButton:GetTalentFrame().professionInfo and endButton:GetTalentFrame().professionInfo.profession;
		local color = profession and professionVertexColors[profession] or HIGHLIGHT_FONT_COLOR;
		r, g, b = color:GetRGB();
	end
	self.Line:SetVertexColor(r, g, b);
	self.ArrowHead:SetVertexColor(r, g, b);
end