DragonflightLandingOverlayMixin = {};

local minimapDisplayInfo = {
	useDefaultButtonSize = true,
	expansionLandingPageType = Enum.ExpansionLandingPageType.Dragonflight,
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
};

local minimapPulseLocks = EnumUtil.MakeEnum(
	"DragonridingUnlocked",
	"DragonflightSummaryUnlocked",
	"MajorFactionUnlocked"
);

local overlayFrame = nil;

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
	if not overlayFrame then
		overlayFrame = CreateFrame("Frame", nil, parent, "DragonflightLandingOverlayTemplate");
	end

	return overlayFrame;
end

function DragonflightLandingOverlayMixin:TryCelebrateUnlock()
	if not GetCVarBitfield("unlockedExpansionLandingPages", minimapDisplayInfo.expansionLandingPageType) then
		SetCVarBitfield("unlockedExpansionLandingPages", minimapDisplayInfo.expansionLandingPageType, true);
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
	end
end

function DragonflightLandingOverlayMixin:OnLoad()
	self.CloseButton:ClearAllPoints();
	local xOffset, yOffset = -3, -10;
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", xOffset, yOffset);
	self:RefreshOverlay();
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

	self:SetEnabled(DragonridingUtil.IsDragonridingUnlocked());
	self:UpdateUnspentGlyphsAnimation();
end

function DragonridingPanelSkillsButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DragonridingPanelSkillsButtonEvents);
end

function DragonridingPanelSkillsButtonMixin:OnEvent(event, ...)
	if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...;
		if treeID == Constants.MountDynamicFlightConsts.TREE_ID then
			self:UpdateUnspentGlyphsAnimation();
		end
	end
end

function DragonridingPanelSkillsButtonMixin:OnClick()
	GenericTraitUI_LoadUI();

	GenericTraitFrame:SetSystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
	GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
	ToggleFrame(GenericTraitFrame);
end

function DragonridingPanelSkillsButtonMixin:UpdateUnspentGlyphsAnimation()
	self.UnspentGlyphsAnim:SetPlaying(self:IsEnabled() and not DragonridingUtil.IsDragonridingTreeOpen() and DragonridingUtil.CanSpendDragonridingGlyphs());
end
