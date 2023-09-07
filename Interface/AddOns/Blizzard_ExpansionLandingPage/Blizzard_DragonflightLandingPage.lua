DragonflightLandingOverlayMixin = {};

local DRAGONRIDING_INTRO_QUEST_ID = 68798;
local DRAGONRIDING_ACCOUNT_ACHIEVEMENT_ID = 15794;
local DRAGONRIDING_TRAIT_SYSTEM_ID = 1;
local DRAGONRIDING_TREE_ID = 672;

local function IsDragonridingUnlocked()
	local hasAccountAchievement = select(4, GetAchievementInfo(DRAGONRIDING_ACCOUNT_ACHIEVEMENT_ID));
	return hasAccountAchievement or C_QuestLog.IsQuestFlaggedCompleted(DRAGONRIDING_INTRO_QUEST_ID)
end

local function IsDragonridingTreeOpen()
	if not GenericTraitFrame or not GenericTraitFrame:IsShown()then
		return false;
	end

	return GenericTraitFrame:GetConfigID() == C_Traits.GetConfigIDBySystemID(DRAGONRIDING_TRAIT_SYSTEM_ID);
end

local function CanSpendDragonridingGlyphs()
	if not IsDragonridingUnlocked() then
		return false;
	end

	local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(DRAGONRIDING_TRAIT_SYSTEM_ID);
	if not dragonridingConfigID then
		return false;
	end
	
	local excludeStagedChanges = false;
	local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, DRAGONRIDING_TREE_ID, excludeStagedChanges);
	if #treeCurrencies <= 0 then
		return false;
	end

	local unspentGlyphCount = treeCurrencies[1].quantity;
	local hasUnspentDragonridingGlyphs = unspentGlyphCount > 0;
	if not hasUnspentDragonridingGlyphs then
		return false;
	end

	-- We have unspent glyphs, but can we actually purchase something?
	local dragonridingNodeIDs = C_Traits.GetTreeNodes(DRAGONRIDING_TREE_ID);
	for index, nodeID in ipairs(dragonridingNodeIDs) do
		local nodeCosts = C_Traits.GetNodeCost(dragonridingConfigID, nodeID);
		local canAffordNode = (#nodeCosts == 0) or (unspentGlyphCount >= nodeCosts[1].amount);
		if canAffordNode then
			-- Some nodes give you multiple choices and let you pick one, let's see if you can purchase any of them
			local nodeInfo = C_Traits.GetNodeInfo(dragonridingConfigID, nodeID);
			for index, entryID in ipairs(nodeInfo.entryIDs) do
				if C_Traits.CanPurchaseRank(dragonridingConfigID, nodeID, entryID) then
					-- We can spend our glyphs on something!
					return true;
				end
			end
		end
	end

	return false;
end

local function TryShowUnspentDragonridingGlyphReminder()
	if IsDragonridingTreeOpen() then
		return;
	end

	if CanSpendDragonridingGlyphs() then
		local helpTipInfo =
		{
			text = DRAGONFLIGHT_LANDING_PAGE_UNSPENT_GLYPHS,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
		};
		HelpTip:Show(ExpansionLandingPageMinimapButton, helpTipInfo, ExpansionLandingPageMinimapButton);
	end
end

local minimapDisplayInfo = {
	useDefaultButtonSize = true;
	["normalAtlas"] = "dragonflight-landingbutton-up",
	["pushedAtlas"] = "dragonflight-landingbutton-down",
	["highlightAtlas"] = "dragonflight-landingbutton-circlehighlight",
	["glowAtlas"] = "dragonflight-landingbutton-circleglow",
	["title"] = DRAGONFLIGHT_LANDING_PAGE_TITLE,
	["description"] = DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
};

local unlockEvents = {
	-- Insert events related to overlay unlock requirements here
};

local minimapAnimationEvents = {
	"MAJOR_FACTION_UNLOCKED",
	"QUEST_TURNED_IN",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

local minimapPulseLocks = EnumUtil.MakeEnum(
	"DragonridingUnlocked",
	"DragonflightSummaryUnlocked",
	"MajorFactionUnlocked"
);

function DragonflightLandingOverlayMixin.IsOverlayUnlocked()
	return C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_DRAGONFLIGHT);
end

function DragonflightLandingOverlayMixin.GetMinimapDisplayInfo()
	return minimapDisplayInfo;
end

function DragonflightLandingOverlayMixin.GetMinimapAnimationEvents()
	return minimapAnimationEvents;
end

function DragonflightLandingOverlayMixin.GetUnlockEvents()
	return unlockEvents;
end

function DragonflightLandingOverlayMixin.CreateOverlay(parent)
	return CreateFrame("Frame", nil, parent, "DragonflightLandingOverlayTemplate");
end

function DragonflightLandingOverlayMixin:TryCelebrateUnlock()
	if not GetCVarBitfield("unlockedExpansionLandingPages", Enum.ExpansionLandingPageType.Dragonflight) then
		SetCVarBitfield("unlockedExpansionLandingPages", Enum.ExpansionLandingPageType.Dragonflight, true);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_SUMMARY_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.DragonflightSummaryUnlocked);
	end
end

function DragonflightLandingOverlayMixin.HandleUnlockEvent(event, ...)
end

function DragonflightLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
	if event == "QUEST_TURNED_IN" then
		local questID, xpReward, moneyReward = ...;
		if questID == DRAGONRIDING_INTRO_QUEST_ID then
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_DRAGONRIDING_UNLOCKED);
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.DragonridingUnlocked);
		end
	elseif event == "MAJOR_FACTION_UNLOCKED" then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_MAJOR_FACTION_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.MajorFactionUnlocked);
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...;
		if treeID == DRAGONRIDING_TREE_ID then
			TryShowUnspentDragonridingGlyphReminder();
		end
	end
end

function DragonflightLandingOverlayMixin:OnLoad()
	self.CloseButton:ClearAllPoints();
	local xOffset, yOffset = -3, -10;
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", xOffset, yOffset);
	self:RefreshOverlay();
	TryShowUnspentDragonridingGlyphReminder();
end

function DragonflightLandingOverlayMixin:OnShow()
	EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
end

function DragonflightLandingOverlayMixin:RefreshOverlay()
	self:RefreshMajorFactionList();
end

function DragonflightLandingOverlayMixin:RefreshMajorFactionList()
	if not self.MajorFactionList then
		self:SetUpMajorFactionList();
	end

	self.MajorFactionList:Refresh();
end

function DragonflightLandingOverlayMixin:SetUpMajorFactionList()
	MajorFactions_LoadUI();
	
	self.MajorFactionList = LandingPageMajorFactionList.Create(self);
	self.MajorFactionList:ClearAllPoints();
	local xOffset, yOffset = 45, -20;
	self.MajorFactionList:SetPoint("TOPRIGHT", self.Header.TitleDivider, "BOTTOMRIGHT", xOffset, yOffset);

	-- The ScrollFadeOverlay should be on top of the Major Faction List to fade out elements as you scroll
	self.ScrollFadeOverlay:SetFrameLevel(self.MajorFactionList:GetFrameLevel() + 10);
	-- And the ScrollBar should be on top of the ScrollFadeOverlay so we can still use it
	self.MajorFactionList.ScrollBar:SetFrameLevel(self.ScrollFadeOverlay:GetFrameLevel() + 10);


	self.MajorFactionList:SetExpansionFilter(LE_EXPANSION_DRAGONFLIGHT);
end

------------------------- Dragonriding Skills Button -------------------------
local DragonridingPanelSkillsButtonEvents =
{
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

DragonridingPanelSkillsButtonMixin = CreateFromMixins(CallbackRegistryMixin);

function DragonridingPanelSkillsButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(EventRegistry, "GenericTraitFrame.OnShow", self.UpdateUnspentGlyphsAnimation);
	self:AddDynamicEventMethod(EventRegistry, "GenericTraitFrame.OnHide", self.UpdateUnspentGlyphsAnimation);
end

function DragonridingPanelSkillsButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DragonridingPanelSkillsButtonEvents);

	self:SetEnabled(IsDragonridingUnlocked());
	self:UpdateUnspentGlyphsAnimation();
end

function DragonridingPanelSkillsButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DragonridingPanelSkillsButtonEvents);
end

function DragonridingPanelSkillsButtonMixin:OnEvent(event, ...)
	if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...;
		if treeID == DRAGONRIDING_TREE_ID then
			self:UpdateUnspentGlyphsAnimation();
		end
	end
end

function DragonridingPanelSkillsButtonMixin:OnClick()
	GenericTraitUI_LoadUI();

	GenericTraitFrame:SetSystemID(DRAGONRIDING_TRAIT_SYSTEM_ID);
	ToggleFrame(GenericTraitFrame);

	HelpTip:Acknowledge(ExpansionLandingPageMinimapButton, DRAGONFLIGHT_LANDING_PAGE_UNSPENT_GLYPHS);
end

function DragonridingPanelSkillsButtonMixin:UpdateUnspentGlyphsAnimation()
	self.UnspentGlyphsAnim:SetPlaying(self:IsEnabled() and not IsDragonridingTreeOpen() and CanSpendDragonridingGlyphs());
end
