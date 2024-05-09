WarWithinLandingOverlayMixin = {};

local minimapDisplayInfo = {
	useDefaultButtonSize = true;
	["normalAtlas"] = "warwithin-landingbutton-up",
	["pushedAtlas"] = "warwithin-landingbutton-down",
	["highlightAtlas"] = "warwithin-landingbutton-highlight",
	["glowAtlas"] = "warwithin-landingbutton-glow",
	["title"] = WAR_WITHIN_LANDING_PAGE_TITLE,
	["description"] = WAR_WITHIN_LANDING_PAGE_TOOLTIP,
};

local unlockEvents = {
	-- Insert events related to overlay unlock requirements here
};

local minimapAnimationEvents = {

};

function WarWithinLandingOverlayMixin.IsOverlayUnlocked()
	return C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_11_0);
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
	return CreateFrame("Frame", nil, parent, "WarWithinLandingOverlayTemplate");
end

function WarWithinLandingOverlayMixin:TryCelebrateUnlock()
end

function WarWithinLandingOverlayMixin.HandleUnlockEvent(event, ...)
end

function WarWithinLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
end

function WarWithinLandingOverlayMixin:OnLoad()
	self.CloseButton:ClearAllPoints();
	local xOffset, yOffset = -3, -10;
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
	local xOffset, yOffset = 45, -20;
	self.MajorFactionList:SetPoint("TOPRIGHT", self.Header.TitleDivider, "BOTTOMRIGHT", xOffset, yOffset);

	-- The ScrollFadeOverlay should be on top of the Major Faction List to fade out elements as you scroll
	self.ScrollFadeOverlay:SetFrameLevel(self.MajorFactionList:GetFrameLevel() + 10);
	-- And the ScrollBar should be on top of the ScrollFadeOverlay so we can still use it
	self.MajorFactionList.ScrollBar:SetFrameLevel(self.ScrollFadeOverlay:GetFrameLevel() + 10);

	self.MajorFactionList:SetExpansionFilter(LE_EXPANSION_11_0);
end
