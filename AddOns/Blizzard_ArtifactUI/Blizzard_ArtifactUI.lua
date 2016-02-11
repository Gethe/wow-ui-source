UIPanelWindows["ArtifactFrame"] =		{ area = "doublewide",	pushable = 0, xoffset = 35, showFailedFunc = C_ArtifactUI.Clear, };

StaticPopupDialogs["CONFIRM_ARTIFACT_RESPEC"] = {
	text = "Are you sure you want to respec?",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self) C_ArtifactUI.ConfirmRespec(); end,
	OnUpdate = function(self, elapsed)
		if ( not C_ArtifactUI.CheckRespecNPC() ) then
			self:Hide();
		end
	end,
	hideOnEscape = true,
	timeout = 0,
	exclusive = true,
	whileDead = true,
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
	self.PerksTab:Refresh(true);

	self:UpdateForgeLevel();
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
			if newItem then
				self:SetupPerArtifactData();
			end
			self.PerksTab:Refresh(newItem);
		else
			ShowUIPanel(self);
		end

		if self:IsShown() then -- Could fail to show if blocked, only update if we were succesfully shown
			self:UpdateForgeLevel();
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

function ArtifactUIMixin:EvaulateForgeState()
	local isAtForge = C_ArtifactUI.IsAtForge();

	if self.wasAtForge ~= isAtForge then
		self.AppearancesTabButton:SetShown(isAtForge);

		self:SetTab(TAB_PERKS);

		self.wasAtForge = isAtForge;
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

	self.PerksTab:SetShown(id == TAB_PERKS);
	self.AppearancesTab:SetShown(id == TAB_APPEARANCE);
end

function ArtifactUIMixin:SetupPerArtifactData()
	local textureKit, titleName, titleR, titleG, titleB, barConnectedR, barConnectedG, barConnectedB, barDisconnectedR, barDisconnectedG, barDisconnectedB = C_ArtifactUI.GetArtifactArtInfo();
	if textureKit then
		local classBadgeTexture = ("%s-ClassBadge"):format(textureKit);
		self.ForgeBadgeFrame.ForgeClassBadgeIcon:SetAtlas(classBadgeTexture, true);

		local forgeBackgroundTexture = ("%s-KnowledgeRank"):format(textureKit);
		self.ForgeBadgeFrame.ForgeLevelBackground:SetAtlas(forgeBackgroundTexture, true);
	end
end

function ArtifactUIMixin:UpdateForgeLevel()
	--local numStartingRanks = C_ArtifactUI.GetNumStartingRanks();
	--local maxRanks = C_ArtifactUI.GetMaxPurchasedRanks();
	--local purchasedRanks = C_ArtifactUI.GetTotalPurchasedRanks();
    --
	--if maxRanks > numStartingRanks or purchasedRanks >= numStartingRanks - 2 then
	--	self.ForgeBadgeFrame.ForgeLevelLabel:SetText(maxRanks);
	--	self.ForgeBadgeFrame.ForgeLevelLabel:Show();
	--	self.ForgeBadgeFrame.ForgeLevelBackground:Show();
    --
	--    if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_KNOWLEDGE_LEVEL_LIMIT) then
	--		self.MaxKnowledgeLevelHelpBox:Show();
	--		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_KNOWLEDGE_LEVEL_LIMIT, true);
	--    end
	--else
		self.ForgeBadgeFrame.ForgeLevelLabel:Hide();
		self.ForgeBadgeFrame.ForgeLevelBackground:Hide();
	--end
end

------------------------------------------------------------------
--   ArtifactFrameUnderlay
------------------------------------------------------------------

ArtifactFrameUnderlayMixin = {};

function ArtifactFrameUnderlayMixin:OnMouseDown()
	self.draggingStartX, self.draggingStartY = GetCursorPosition();
end

function ArtifactFrameUnderlayMixin:OnMouseUp()
	if self.draggingStartX and self.draggingStartY then
		local dx, dy = self:CalculateDeltas();
		self.rotationOffsetX = self.rotationOffsetX + dx;
		self.draggingStartX, self.draggingStartY = nil, nil;
	end
end

ARTIFACT_ITEM_SPEED_FACTOR = 0;
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