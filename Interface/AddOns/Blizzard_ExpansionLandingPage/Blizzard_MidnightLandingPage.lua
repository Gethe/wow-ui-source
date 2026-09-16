local RUNES_OF_POWER_SYSTEM_ID = 48;
local RUNES_OF_POWER_TREE_ID = 1186;

MidnightLandingOverlayMixin = {};

local minimapDisplayInfo = {
	useDefaultButtonSize = true,
	expansionLandingPageType = Enum.ExpansionLandingPageType.Midnight,
	anchorOffset = { x = 12, y = -153 },
	["normalAtlas"] = "midnight-landingbutton-up",
	["pushedAtlas"] = "midnight-landingbutton-down",
	["highlightAtlas"] = "midnight-landingbutton-circlehighlight",
	["glowAtlas"] = "midnight-landingbutton-circleglow",
	["title"] = MIDNIGHT_LANDING_PAGE_TITLE,
	["description"] = MIDNIGHT_LANDING_PAGE_TOOLTIP,
	glowOverrides = { size = 32, offsetX = 3, offsetY = 2 },
};

local unlockEvents = {
	-- Insert events related to overlay unlock requirements here
	"QUEST_LOG_UPDATE",
};

local overlayFrame = nil;

local function ShouldShowRunesOfPowerTutorial()
	return not GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.RunesOfPower);
end

local function MarkRunesOfPowerTutorialDone()
	SetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.RunesOfPower, true);
end

local function CanPurchaseRuneOfPower()
	local configID = C_Traits.GetConfigIDBySystemID(RUNES_OF_POWER_SYSTEM_ID);
	if not configID then
		return false;
	end

	local excludeStagedChanges = false;
	local treeCurrencies = C_Traits.GetTreeCurrencyInfo(configID, RUNES_OF_POWER_TREE_ID, excludeStagedChanges);
	if #treeCurrencies <= 0 then
		return false;
	end

	local unspentCurrency = treeCurrencies[1].quantity;
	if unspentCurrency == 0 then
		return false;
	end

	-- We have unspent currency, but can we actually purchase something?
	local nodeIDs = C_Traits.GetTreeNodes(RUNES_OF_POWER_TREE_ID);
	for _nodeIndex, nodeID in ipairs(nodeIDs) do
		local nodeCosts = C_Traits.GetNodeCost(configID, nodeID);
		local canAffordNode = (#nodeCosts == 0) or (unspentCurrency >= nodeCosts[1].amount);
		if canAffordNode then
			-- Some nodes give you multiple choices and let you pick one, let's see if you can purchase any of them
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
			for _entryIndex, entryID in ipairs(nodeInfo.entryIDs) do
				if C_Traits.CanPurchaseRank(configID, nodeID, entryID) then
					-- We can spend our currency on something!
					return true;
				end
			end
		end
	end

	return false;
end

local function TryShowPurchasableRunesofPowerReminder()
	local overlay = ExpansionLandingPage.Overlay.MidnightLandingOverlay;
	if not overlay or overlay.RunesOfPowerFrame:IsVisible() then
		return;
	end

	if CanPurchaseRuneOfPower() then
		local helpTipInfo =
		{
			text = OMNIUM_FOLIO_UNSPENT_POINTS,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
		};
		HelpTip:Show(ExpansionLandingPageMinimapButton, helpTipInfo, ExpansionLandingPageMinimapButton);
		--- have to wait one frame, otherwise there's no handler for this event
		RunNextFrame(function()
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", MinimapPulseLock.RunesOfPower);
		end);
	end
end

function MidnightLandingOverlayMixin.IsOverlayUnlocked()
	return C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_MIDNIGHT);
end

function MidnightLandingOverlayMixin:TryCelebrateUnlock()
	if ShouldShowRunesOfPowerTutorial() then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", OMNIUM_FOLIO_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", MinimapPulseLock.RunesOfPower);
	end
end

function MidnightLandingOverlayMixin.GetMinimapDisplayInfo()
	return minimapDisplayInfo;
end

function MidnightLandingOverlayMixin.GetMinimapAnimationEvents()
	return minimapAnimationEvents;
end

function MidnightLandingOverlayMixin.GetUnlockEvents()
	return unlockEvents;
end

function MidnightLandingOverlayMixin.CreateOverlay(parent)
	if not overlayFrame then
		overlayFrame = CreateFrame("Frame", nil, parent, "MidnightLandingOverlayTemplate");
	end

	return overlayFrame;
end

function MidnightLandingOverlayMixin:OnLoad()
	self.CloseButton:ClearAllPoints();
	local xOffset, yOffset = -4, -5;
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", xOffset, yOffset);

	TryShowPurchasableRunesofPowerReminder();
end

function MidnightLandingOverlayMixin:OnShow()
	EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
end

function MidnightLandingOverlayMixin.GetMinimapInsetInfo()
	return 2.10, 2.54, 0.8;
end

local minimapAnimationEvents = {
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

function MidnightLandingOverlayMixin.GetMinimapAnimationEvents()
	return minimapAnimationEvents;
end

function MidnightLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
	TryShowPurchasableRunesofPowerReminder();
end

RunesOfPowerMixin = { };

function RunesOfPowerMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);
	self:SetConfigIDBySystemID(RUNES_OF_POWER_SYSTEM_ID);
	self:SetTreeCurrencyDisplayTextCallback(TalentFrameUtil.GenerateTreeCurrencyDisplayCallback());
	self.CurrencyDisplay:SetTalentFrame(self);
	self.CurrencyDisplay.Background:Hide();

	-- bump this up so helptip doesn't cover expanded choice nodes
	self.ButtonsParent:SetFrameStrata("HIGH");
end

function RunesOfPowerMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	if ShouldShowRunesOfPowerTutorial() then
		-- show a helptip for the first selectable node
		local buttons = self:GetButtonsInDefaultOrder();
		for i, button in ipairs(buttons) do
			if button:IsVisibleAndSelectable() then
				local helpTipInfo = {
					text = RUNES_OF_POWER_HELPTIP,
					buttonStyle = HelpTip.ButtonStyle.None,
					targetPoint = HelpTip.Point.LeftEdgeCenter,
					offsetX = -40,
					useParentStrata = true,
				};
				HelpTip:Show(self, helpTipInfo, button);
				break;
			end
		end
		if not HelpTip:IsShowing(self, RUNES_OF_POWER_HELPTIP) then
			MarkRunesOfPowerTutorialDone();
		end
	end

	HelpTip:Acknowledge(ExpansionLandingPageMinimapButton, OMNIUM_FOLIO_UNSPENT_POINTS);
end

function RunesOfPowerMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	if ShouldShowRunesOfPowerTutorial() then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", MinimapPulseLock.RunesOfPower);
	end
end

function RunesOfPowerMixin:ShowPurchaseVisuals(...)
	AutoCommitTraitFrameMixin.ShowPurchaseVisuals(self, ...);

	if ShouldShowRunesOfPowerTutorial() then
		HelpTip:Hide(self, RUNES_OF_POWER_HELPTIP);
		MarkRunesOfPowerTutorialDone();
	end
end
