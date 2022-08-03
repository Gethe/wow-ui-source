DragonflightLandingOverlayMixin = {};

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
};

function DragonflightLandingOverlayMixin.IsOverlayUnlocked(completedQuestID)
	local dragonridingIntroDone = completedQuestID == DRAGONRIDING_INTRO_QUEST_ID or C_QuestLog.IsQuestFlaggedCompleted(DRAGONRIDING_INTRO_QUEST_ID);
	return dragonridingIntroDone;
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
		end
	end
end

function DragonflightLandingOverlayMixin:OnLoad()
	self:RefreshOverlay();
end

function DragonflightLandingOverlayMixin:OnShow()
	EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
end

function DragonflightLandingOverlayMixin:RefreshOverlay()
	self.DragonridingPanel:Refresh();
end

------------------------- Dragonriding Panel -------------------------

LandingPageDragonridingPanelMixin = {};

function LandingPageDragonridingPanelMixin:Refresh()
	self:Layout();
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
