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
	return C_ArtifactUI.IsAtForge() or C_ArtifactUI.GetTotalPurchasedRanks() > 0;
end

local TAB_PERKS = 1;
local TAB_APPEARANCE = 2;
local TAB_CHALLENGES = 3;

local PERK_PANEL_WIDTH = 720;
local STANDARD_PANEL_WIDTH = 460;

ArtifactUIMixin = {}

------------------------------------------------------------------
--   ArtifactFrame
------------------------------------------------------------------
function ArtifactUIMixin:OnLoad()
	self.AppearancesTab:OnLoad();

	PanelTemplates_SetNumTabs(self, 2);

	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterEvent("ARTIFACT_CLOSE");
	self:RegisterEvent("ARTIFACT_MAX_RANKS_UPDATE");
end

function ArtifactUIMixin:OnShow()
	PlaySound("igCharacterInfoOpen");

	self:EvaulateForgeState();
	self:SetupPerArtifactData();
	self:RefreshKnowledgeRanks();
	self.PerksTab:Refresh(true);
end

function ArtifactUIMixin:OnHide()
	ArtifactFrameUnderlay:Hide();
	PlaySound("igCharacterInfoClose");
	C_ArtifactUI.Clear();

	StaticPopup_Hide("CONFIRM_ARTIFACT_RESPEC");
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
		else
			ShowUIPanel(self);
		end
	elseif event == "ARTIFACT_XP_UPDATE" then
		if self:IsShown() then
			self.PerksTab:Refresh();
		end
	elseif event == "ARTIFACT_CLOSE" then
		HideUIPanel(self);
	end
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
			self.AppearanceTabHelpBox:Show();
		end
	else
		self.AppearanceTabHelpBox:Hide();
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
		self.AppearanceTabHelpBox:Hide();
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB, true)
	end

	self.PerksTab:SetShown(id == TAB_PERKS);
	self.AppearancesTab:SetShown(id == TAB_APPEARANCE);
end

function ArtifactUIMixin:SetupPerArtifactData()
	local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	if textureKit then
		local classBadgeTexture = ("%s-ClassBadge"):format(textureKit);
		self.ForgeBadgeFrame.ForgeClassBadgeIcon:SetAtlas(classBadgeTexture, true);
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
	if totalRanks > 0 then
		self.ForgeBadgeFrame.ForgeLevelLabel:SetText(totalRanks);
		self.ForgeBadgeFrame.ForgeLevelLabel:Show();
		self.ForgeBadgeFrame.ForgeLevelBackground:Show();
		self.ForgeBadgeFrame.ForgeLevelBackgroundBlack:Show();
		self.ForgeLevelFrame:Show();
		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_KNOWLEDGE)) then
			self.KnowledgeLevelHelpBox:Show();
		end
	else
		self.ForgeBadgeFrame.ForgeLevelLabel:Hide();
		self.ForgeBadgeFrame.ForgeLevelBackground:Hide();
		self.ForgeBadgeFrame.ForgeLevelBackgroundBlack:Hide();
		self.ForgeLevelFrame:Hide();
		self.KnowledgeLevelHelpBox:Hide();
	end
end

function ArtifactUIMixin:OnKnowledgeEnter(knowledgeFrame)
	GameTooltip:SetOwner(knowledgeFrame, "ANCHOR_BOTTOMRIGHT", -25, 27);
	local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	GameTooltip:SetText(titleName, titleR, titleG, titleB);

	GameTooltip:AddLine(ARTIFACTS_NUM_PURCHASED_RANKS:format(C_ArtifactUI.GetTotalPurchasedRanks()), HIGHLIGHT_FONT_COLOR:GetRGB());

	local addedAnyMetaPowers = MetaPowerTooltipHelper(C_ArtifactUI.GetMetaPowerInfo());

	local knowledgeLevel = C_ArtifactUI.GetArtifactKnowledgeLevel();
	if knowledgeLevel and knowledgeLevel > 0 then
		if addedAnyMetaPowers then
			GameTooltip:AddLine(" ");
		end

		local knowledgeMultiplier = C_ArtifactUI.GetArtifactKnowledgeMultiplier();

		GameTooltip:AddLine(ARTIFACTS_KNOWLEDGE_TOOLTIP_LEVEL:format(knowledgeLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(ARTIFACTS_KNOWLEDGE_TOOLTIP_DESC:format(BreakUpLargeNumbers(knowledgeMultiplier * 100)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	
	GameTooltip:Show();
end

function ArtifactUIMixin:OnInventoryItemMouseEnter(bag, slot)
	if self:IsVisible() then
		local itemID = select(10, GetContainerItemInfo(bag, slot));
		if itemID and IsArtifactRelicItem(itemID) and not CursorHasItem() then
			self.PerksTab:ShowHighlightForRelicItemID(itemID);
		end
	end
end

function ArtifactUIMixin:OnInventoryItemMouseLeave(bag, slot)
	local itemID = select(10, GetContainerItemInfo(bag, slot));
	if itemID and IsArtifactRelicItem(itemID) and not CursorHasItem() then
		self.PerksTab:HideHighlightForRelicItemID(itemID);
	end
end

------------------------------------------------------------------
--   ArtifactFrameUnderlay
------------------------------------------------------------------

ArtifactFrameUnderlayMixin = {};


ARTIFACT_ITEM_SPEED_FACTOR = 0.15;
ARTIFACT_ITEM_BASE_Y_ROTATION = 0;

function ArtifactFrameUnderlayMixin:OnUpdate(elapsed)
	if self.draggingStartX and self.draggingStartY then
		local dx, dy = self:CalculateDeltas();
		C_ArtifactUI.SetForgeRotation(0, ARTIFACT_ITEM_BASE_Y_ROTATION, dx + (self.rotationOffsetX or 0));
	else
		self.rotationOffsetX = (self.rotationOffsetX or 0) + ARTIFACT_ITEM_SPEED_FACTOR * elapsed;
		C_ArtifactUI.SetForgeRotation(0, ARTIFACT_ITEM_BASE_Y_ROTATION, self.rotationOffsetX);
	end
end

ARTIFACT_ITEM_DRAG_FACTOR = .0065;
function ArtifactFrameUnderlayMixin:CalculateDeltas()
	local x, y = GetCursorPosition();
	local scale = UIParent:GetScale();
	return (x - self.draggingStartX) / scale * ARTIFACT_ITEM_DRAG_FACTOR, (y - self.draggingStartY) / scale * ARTIFACT_ITEM_DRAG_FACTOR;
end