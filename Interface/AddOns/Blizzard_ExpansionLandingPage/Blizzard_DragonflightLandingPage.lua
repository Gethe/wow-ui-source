DragonflightLandingOverlayMixin = {};

local MAJOR_FACTIONS_INTRO_QUEST_ID_ALLIANCE = 65436;
local MAJOR_FACTIONS_INTRO_QUEST_ID_HORDE = 65435;

local DRAGONRIDING_INTRO_QUEST_ID = 68798;
local DRAGONRIDING_TRAIT_SYSTEM_ID = 1;

local minimapDisplayInfo = { 
	["normalAtlas"] = "legionmission-landingbutton-druid-up",
	["pushedAtlas"] = "legionmission-landingbutton-druid-down",
	["highlightAtlas"] = "GarrLanding-CircleGlow",
	["glowAtlas"] = "GarrLanding-CircleGlow",
	["title"] = DRAGONFLIGHT_LANDING_PAGE_TITLE,
	["description"] = DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
};

local unlockEvents = {
	-- Insert events related to overlay unlock requirements here
};

local minimapAnimationEvents = {
	"QUEST_TURNED_IN",
	"MAJOR_FACTION_UNLOCKED",
};

local minimapPulseLocks = EnumUtil.MakeEnum(
	"DragonridingUnlocked",
	"DragonflightSummaryUnlocked",
	"MajorFactionUnlocked"
);

function DragonflightLandingOverlayMixin.IsOverlayUnlocked(completedQuestID)
	local playerFactionGroup = UnitFactionGroup("player");
	if playerFactionGroup == "Alliance" then
		return completedQuestID == MAJOR_FACTIONS_INTRO_QUEST_ID_ALLIANCE or C_QuestLog.IsQuestFlaggedCompleted(MAJOR_FACTIONS_INTRO_QUEST_ID_ALLIANCE);
	elseif playerFactionGroup == "Horde" then
		return completedQuestID == MAJOR_FACTIONS_INTRO_QUEST_ID_HORDE or C_QuestLog.IsQuestFlaggedCompleted(MAJOR_FACTIONS_INTRO_QUEST_ID_HORDE);
	end
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

function DragonflightLandingOverlayMixin.HandleUnlockEvent(event, ...)
end

function DragonflightLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
	if event == "QUEST_TURNED_IN" then
		local questID, xpReward, moneyReward = ...;
		if questID == DRAGONRIDING_INTRO_QUEST_ID then
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_DRAGONRIDING_UNLOCKED);
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.DragonridingUnlocked);
		elseif questID == MAJOR_FACTIONS_INTRO_QUEST_ID_ALLIANCE or questID == MAJOR_FACTIONS_INTRO_QUEST_ID_HORDE then
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_SUMMARY_UNLOCKED);
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.DragonflightSummaryUnlocked);
		end
	elseif event == "MAJOR_FACTION_UNLOCKED" then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_MAJOR_FACTION_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.MajorFactionUnlocked);
	end
end

function DragonflightLandingOverlayMixin:OnLoad()
	self:RefreshOverlay();
end

function DragonflightLandingOverlayMixin:OnShow()
	EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
	self.DragonridingPanel:Refresh();
end

function DragonflightLandingOverlayMixin:RefreshOverlay()
	self.DragonridingPanel:Refresh();
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
	local xOffset, yOffset = -45, 26;
	self.MajorFactionList:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", xOffset, yOffset);
	self.MajorFactionList:SetExpansionFilter(LE_EXPANSION_10_0);
end

------------------------- Dragonriding Panel -------------------------

LandingPageDragonridingPanelMixin = {};

function LandingPageDragonridingPanelMixin:Refresh()
	self:Layout();
	self.TalentTreeButton:SetEnabled(C_QuestLog.IsQuestFlaggedCompleted(DRAGONRIDING_INTRO_QUEST_ID));
end

DragonridingPanelTalentButtonMixin = {};

function DragonridingPanelTalentButtonMixin:OnLoad()
	self.PushedImage:SetAtlas(("shadowlands-landingpage-renownbutton-venthyr-down"));
end

function DragonridingPanelTalentButtonMixin:OnMouseDown()
	self.PushedImage:Show();
end

function DragonridingPanelTalentButtonMixin:OnMouseUp()
	self.PushedImage:Hide();
end

function DragonridingPanelTalentButtonMixin:OnClick()
	GenericTraitUI_LoadUI();

	GenericTraitFrame:SetSystemID(DRAGONRIDING_TRAIT_SYSTEM_ID);
	ShowUIPanel(GenericTraitFrame);
end
