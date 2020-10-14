UIPanelWindows["ArtifactFrame"] =		{ area = "doublewide",	pushable = 0, xoffset = 35, yoffset = -9, bottomClampOverride = 100, showFailedFunc = C_ArtifactUI.Clear, };

StaticPopupDialogs["CONFIRM_ARTIFACT_RESPEC"] = {
	text = ARTIFACT_RESPEC,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self) C_ArtifactUI.ConfirmRespec(); HideUIPanel(ArtifactFrame); end,
	OnCancel = function(self) HideUIPanel(ArtifactFrame); end,
	OnAlt = function(self) HideUIPanel(ArtifactFrame); end,
	OnUpdate = function(self, elapsed)
		if ( not C_ArtifactUI.CheckRespecNPC() ) then
			StaticPopup_Hide("CONFIRM_ARTIFACT_RESPEC");
			HideUIPanel(ArtifactFrame);
		end
	end,
	hideOnEscape = true,
	timeout = 0,
	exclusive = true,
	showAlert = true,
}

StaticPopupDialogs["NOT_ENOUGH_POWER_ARTIFACT_RESPEC"] = {
	text = ARTIFACT_RESPEC_NOT_ENOUGH_POWER,
	button1 = OKAY,
	OnAccept = function(self) HideUIPanel(ArtifactFrame); end,
	OnCancel = function(self) HideUIPanel(ArtifactFrame); end,
	OnAlt = function(self) HideUIPanel(ArtifactFrame); end,
	OnUpdate = function(self, elapsed)
		if ( not C_ArtifactUI.CheckRespecNPC() ) then
			StaticPopup_Hide("NOT_ENOUGH_POWER_ARTIFACT_RESPEC");
			HideUIPanel(ArtifactFrame);
		end
	end,
	hideOnEscape = true,
	timeout = 0,
	exclusive = true,
	showAlert = true,
}

function ArtifactUI_CanViewArtifact()
	return C_ArtifactUI.IsAtForge() or ArtifactUI_HasPurchasedAnything() or C_ArtifactUI.IsArtifactDisabled() or C_ArtifactUI.GetNumObtainedArtifacts() > 1;
end

function ArtifactUI_HasPurchasedAnything()
	return C_ArtifactUI.GetTotalPurchasedRanks() > 0 or C_ArtifactUI.IsMaxedByRulesOrEffect();
end

local TAB_PERKS = 1;
local TAB_APPEARANCE = 2;
local TAB_CHALLENGES = 3;

local PERK_PANEL_WIDTH = 896;
local STANDARD_PANEL_WIDTH = 460;

ArtifactUIMixin = {}

------------------------------------------------------------------
--   ArtifactFrame
------------------------------------------------------------------
function ArtifactUIMixin:OnLoad()
	self.AppearancesTab:OnLoad();

	PanelTemplates_SetNumTabs(self, 2);

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("ARTIFACT_CLOSE");
end

function ArtifactUIMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	if self.queueTier2UpgradeAnim then
		self.queueTier2UpgradeAnim = nil;
		-- Play anim
	end

	self:EvaulateForgeState();
	self:SetupPerArtifactData();
	self:RefreshKnowledgeRanks();
	self.PerksTab:OnUIOpened();

	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("ARTIFACT_RELIC_INFO_RECEIVED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function ArtifactUIMixin:OnHide()
	ArtifactFrameUnderlay:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	C_ArtifactUI.Clear();

	StaticPopup_Hide("CONFIRM_ARTIFACT_RESPEC");

	self:UnregisterEvent("ARTIFACT_XP_UPDATE");
	self:UnregisterEvent("ARTIFACT_RELIC_INFO_RECEIVED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
end

function ArtifactUIMixin:OnEvent(event, ...)
	if event == "ARTIFACT_UPDATE" then
		local newItem = ...;
		if newItem then
			self.AppearancesTab:OnNewItemEquipped();
		end

		if self:IsShown() then
			self:EvaulateForgeState();
			self:RefreshKnowledgeRanks();
			if newItem then
				self:SetupPerArtifactData();
			end
			self.PerksTab:Refresh(newItem);
		elseif ( not C_ArtifactRelicForgeUI.IsAtForge() ) then
			ShowUIPanel(self);
		end
	elseif event == "ARTIFACT_XP_UPDATE" then
		self.PerksTab:Refresh();
	elseif event == "ARTIFACT_CLOSE" then
		HideUIPanel(self);
	elseif event == "ARTIFACT_RELIC_INFO_RECEIVED" then
		self.PerksTab:Refresh(false);
	elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		self.PerksTab:Refresh(true);
	end
end

function ArtifactUIMixin:OnTraitsRefunded(numRefunded, refundedTier)
	self.PerksTab:OnTraitsRefunded(numRefunded, refundedTier);
end

function ArtifactUIMixin:OnAppearanceChanging()
	self.PerksTab:OnAppearanceChanging();
end

local function GetNumUnlockedAppearances()
	local count = 0;
	for setIndex = 1, C_ArtifactUI.GetNumAppearanceSets() do
		local setID, _, _, numAppearanceSlots = C_ArtifactUI.GetAppearanceSetInfo(setIndex);
		if setID and numAppearanceSlots > 0 then
			for appearanceIndex = 1, numAppearanceSlots do
				local _, _, _, appearanceUnlocked = C_ArtifactUI.GetAppearanceInfo(setIndex, appearanceIndex);

				if appearanceUnlocked then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

function ArtifactUIMixin:EvaulateForgeState()
	local isAtForge = C_ArtifactUI.IsAtForge();
	local isViewedArtifactEquipped = C_ArtifactUI.IsViewedArtifactEquipped();

	if self.wasAtForge ~= isAtForge or self.wasViewedArtifactEquipped ~= isViewedArtifactEquipped then
		self.AppearancesTabButton:SetShown(isAtForge);

		self:SetTab(TAB_PERKS);

		self.wasAtForge = isAtForge;
		self.wasViewedArtifactEquipped = isViewedArtifactEquipped;
	end

	if isAtForge and not self.AppearancesTab:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB) and C_ArtifactUI.GetTotalPurchasedRanks() > 0 then
		if GetNumUnlockedAppearances() > 1 then
			local helpTipInfo = {
				text = ARTIFACT_TUTORIAL_CUSTOMIZE_APPEARANCE,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				offsetY = -7,
			};
			HelpTip:Show(self, helpTipInfo, self.AppearancesTabButton);
		end
	else
		HelpTip:Hide(self, ARTIFACT_TUTORIAL_CUSTOMIZE_APPEARANCE);
	end

	ArtifactFrameUnderlay:SetShown(isAtForge);
	self.VisitForgeOverlay:SetShown(not ArtifactUI_CanViewArtifact());
end

function ArtifactUIMixin:SetTab(id)
	PanelTemplates_SetTab(self, id);

	if id == TAB_PERKS then
		self:SetWidth(PERK_PANEL_WIDTH);
	else
		self:SetWidth(STANDARD_PANEL_WIDTH);
	end

	UpdateUIPanelPositions(self);

	if id == TAB_APPEARANCE then
		HelpTip:Hide(self, ARTIFACT_TUTORIAL_CUSTOMIZE_APPEARANCE);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB, true)
	end

	self.PerksTab:SetShown(id == TAB_PERKS);
	self.AppearancesTab:SetShown(id == TAB_APPEARANCE);
end

function ArtifactUIMixin:SetupPerArtifactData()
	local _, _, _, icon = C_ArtifactUI.GetArtifactInfo();
	if icon then
		self.ForgeBadgeFrame.ItemIcon:SetTexture(icon);
	end
end

local function MetaPowerTooltipHelper(...)
	local hasAddedAny = false;
	for i = 1, select("#", ...), 3 do
		local spellID, cost, currentRank = select(i, ...);
		local metaPowerDescription = GetSpellDescription(spellID);
		if metaPowerDescription then
			if hasAddedAny then
				GameTooltip:AddLine(" ");
			end
			GameTooltip:AddLine(metaPowerDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
			hasAddedAny = true;
		end
	end

	return hasAddedAny;
end

function ArtifactUIMixin:RefreshKnowledgeRanks()
	local totalRanks = C_ArtifactUI.GetTotalPurchasedRanks();
	if totalRanks > 0 and not C_ArtifactUI.IsArtifactDisabled() then
		self.ForgeBadgeFrame.ForgeLevelLabel:SetText(totalRanks);
		self.ForgeBadgeFrame.ForgeLevelLabel:Show();
		self.ForgeBadgeFrame.ForgeLevelBackground:Show();
		self.ForgeBadgeFrame.ForgeLevelBackgroundBlack:Show();
		self.ForgeLevelFrame:Show();
	else
		self.ForgeBadgeFrame.ForgeLevelLabel:Hide();
		self.ForgeBadgeFrame.ForgeLevelBackground:Hide();
		self.ForgeBadgeFrame.ForgeLevelBackgroundBlack:Hide();
		self.ForgeLevelFrame:Hide();
	end
end

function ArtifactUIMixin:OnKnowledgeEnter(knowledgeFrame)
	GameTooltip:SetOwner(knowledgeFrame, "ANCHOR_BOTTOMRIGHT", -25, 27);
	local artifactArtInfo = C_ArtifactUI.GetArtifactArtInfo();
	local color = ITEM_QUALITY_COLORS[Enum.ItemQuality.Artifact];
	GameTooltip:SetText(artifactArtInfo.titleName, color.r, color.g, color.b);

	GameTooltip:AddLine(ARTIFACTS_NUM_PURCHASED_RANKS:format(C_ArtifactUI.GetTotalPurchasedRanks()), HIGHLIGHT_FONT_COLOR:GetRGB());

	local addedAnyMetaPowers = MetaPowerTooltipHelper(C_ArtifactUI.GetMetaPowerInfo());
	
	knowledgeFrame.UpdateTooltip = function() self:OnKnowledgeEnter(knowledgeFrame); end;
	GameTooltip:Show();
end

function ArtifactUIMixin:OnKnowledgeLeave(knowledgeFrame)
	knowledgeFrame.UpdateTooltip = nil;
	GameTooltip:Hide();
end

function ArtifactUIMixin:OnInventoryItemMouseEnter(bag, slot)
	if self:IsVisible() then
		local itemInfo = {GetContainerItemInfo(bag, slot)};
		local itemLink = itemInfo[7];
		local itemID = itemInfo[10];

		if itemID and IsArtifactRelicItem(itemID) and not CursorHasItem() then
			self.PerksTab:ShowHighlightForRelicItemID(itemID, itemLink);
			self.PerksTab.TitleContainer:RefreshRelicHighlights(itemID, itemLink);
		end
	end
end

function ArtifactUIMixin:OnInventoryItemMouseLeave(bag, slot)
	local itemInfo = {GetContainerItemInfo(bag, slot)};
	local itemLink = itemInfo[7];
	local itemID = itemInfo[10];

	if itemID and IsArtifactRelicItem(itemID) and not CursorHasItem() and self.PerksTab:IsVisible() then
		self.PerksTab:HideHighlightForRelicItemID(itemID, itemLink);
		self.PerksTab.TitleContainer:RefreshRelicHighlights();
	end
end

------------------------------------------------------------------
--   ArtifactFrameUnderlay
------------------------------------------------------------------

ArtifactFrameUnderlayMixin = {};


ARTIFACT_ITEM_SPEED_FACTOR = 0.15;
ARTIFACT_ITEM_BASE_Y_ROTATION = 0;

function ArtifactFrameUnderlayMixin:OnUpdate(elapsed)
	if not C_ArtifactUI.ShouldSuppressForgeRotation() then
		if self.draggingStartX and self.draggingStartY then
			local dx, dy = self:CalculateDeltas();
			C_ArtifactUI.SetForgeRotation(0, ARTIFACT_ITEM_BASE_Y_ROTATION, dx + (self.rotationOffsetX or 0));
		else
			self.rotationOffsetX = (self.rotationOffsetX or 0) + ARTIFACT_ITEM_SPEED_FACTOR * elapsed;
			C_ArtifactUI.SetForgeRotation(0, ARTIFACT_ITEM_BASE_Y_ROTATION, self.rotationOffsetX);
		end
	end
end

ARTIFACT_ITEM_DRAG_FACTOR = .0065;
function ArtifactFrameUnderlayMixin:CalculateDeltas()
	local x, y = GetCursorPosition();
	local scale = UIParent:GetScale();
	return (x - self.draggingStartX) / scale * ARTIFACT_ITEM_DRAG_FACTOR, (y - self.draggingStartY) / scale * ARTIFACT_ITEM_DRAG_FACTOR;
end