WarWithinLandingOverlayMixin = {};

local minimapDisplayInfo = {
	useDefaultButtonSize = true,
	expansionLandingPageType = Enum.ExpansionLandingPageType.WarWithin,
	["normalAtlas"] = "warwithin-landingbutton-up",
	["pushedAtlas"] = "warwithin-landingbutton-down",
	["highlightAtlas"] = "warwithin-landingbutton-highlight",
	["glowAtlas"] = "warwithin-landingbutton-glow",
	["title"] = WAR_WITHIN_LANDING_PAGE_TITLE,
	["description"] = WAR_WITHIN_LANDING_PAGE_TOOLTIP,
	["anchorOffset"] = { x = 12, y = -152 },
};

local unlockEvents = {
	-- Insert events related to overlay unlock requirements here
};

local minimapAnimationEvents = {
	"MAJOR_FACTION_UNLOCKED",
};

local minimapPulseLocks = EnumUtil.MakeEnum(
	"WarWithinSummaryUnlocked",
	"MajorFactionUnlocked"
);

local overlayFrame = nil;

function WarWithinLandingOverlayMixin.IsOverlayUnlocked()
	return C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_WAR_WITHIN);
end

function WarWithinLandingOverlayMixin.GetMinimapDisplayInfo()
	return minimapDisplayInfo;
end

function WarWithinLandingOverlayMixin.GetMinimapAnimationEvents()
	return minimapAnimationEvents;
end

function WarWithinLandingOverlayMixin.GetUnlockEvents()
	return unlockEvents;
end

function WarWithinLandingOverlayMixin.CreateOverlay(parent)
	if not overlayFrame then
		overlayFrame = CreateFrame("Frame", nil, parent, "WarWithinLandingOverlayTemplate");
	end

	return overlayFrame;
end

function WarWithinLandingOverlayMixin:TryCelebrateUnlock()
	if not GetCVarBitfield("unlockedExpansionLandingPages", minimapDisplayInfo.expansionLandingPageType) then
		SetCVarBitfield("unlockedExpansionLandingPages", minimapDisplayInfo.expansionLandingPageType, true);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", WAR_WITHIN_LANDING_PAGE_ALERT_SUMMARY_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.WarWithinSummaryUnlocked);
	end
end

function WarWithinLandingOverlayMixin.HandleUnlockEvent(event, ...)
end

function WarWithinLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
	if event == "MAJOR_FACTION_UNLOCKED" then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", WAR_WITHIN_LANDING_PAGE_ALERT_MAJOR_FACTION_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.MajorFactionUnlocked);
	end
end

function WarWithinLandingOverlayMixin:OnLoad()
	self.CloseButton:ClearAllPoints();
	local xOffset, yOffset = -9, -9;
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", xOffset, yOffset);
	self:RefreshOverlay();
end

function WarWithinLandingOverlayMixin:OnShow()
	EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
end

function WarWithinLandingOverlayMixin:RefreshOverlay()
	self:RefreshMajorFactionList();
end

function WarWithinLandingOverlayMixin:RefreshMajorFactionList()
	if not self.MajorFactionList then
		self:SetUpMajorFactionList();
	end

	self.MajorFactionList:Refresh();
end

function WarWithinLandingOverlayMixin:SetUpMajorFactionList()
	MajorFactions_LoadUI();
	
	self.MajorFactionList = LandingPageMajorFactionList.Create(self);
	self.MajorFactionList:ClearAllPoints();
	local xOffset, yOffset = 35, -10;
	self.MajorFactionList:SetPoint("TOPRIGHT", self.Header.TitleDivider, "BOTTOMRIGHT", xOffset, yOffset);
	self.MajorFactionList:SetSize(450, 488);

	-- The ScrollFadeOverlay should be on top of the Major Faction List to fade out elements as you scroll
	self.ScrollFadeOverlay:SetFrameLevel(self.MajorFactionList:GetFrameLevel() + 10);
	-- And the ScrollBar should be on top of the ScrollFadeOverlay so we can still use it
	self.MajorFactionList.ScrollBar:SetFrameLevel(self.ScrollFadeOverlay:GetFrameLevel() + 10);

	self.MajorFactionList:SetExpansionFilter(LE_EXPANSION_WAR_WITHIN);
end

function WarWithinLandingOverlayMixin:GetMinimapInsetInfo()
	return 2.07, 2.54, 0.8;
end