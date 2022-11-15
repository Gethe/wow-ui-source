----------------------------------- Expansion Landing Page -----------------------------------

local landingPageOverlay = {
	[LE_EXPANSION_DRAGONFLIGHT] = CreateFromMixins(DragonflightLandingOverlayMixin),
};

ExpansionLandingPageMixin = {};

ExpansionLandingPageEvents = {
	"ACHIEVEMENT_EARNED",
	"NEW_MOUNT_ADDED",
	"PLAYER_LOGIN",
	"PLAYER_LEVEL_UP",
	"QUEST_REMOVED",
	"QUEST_TURNED_IN",
	"ZONE_CHANGED",
	"ZONE_CHANGED_NEW_AREA",
	"ZONE_CHANGED_INDOORS",
};

function ExpansionLandingPageMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ExpansionLandingPageEvents);
end

function ExpansionLandingPageMixin:OnShow()
	PlaySound(SOUNDKIT.UI_EXPANSION_LANDING_PAGE_OPEN);
end

function ExpansionLandingPageMixin:OnHide()
	PlaySound(SOUNDKIT.UI_EXPANSION_LANDING_PAGE_CLOSE);
end

function ExpansionLandingPageMixin:OnEvent(event, ...)
	if tContains(ExpansionLandingPageEvents, event) then
		self:RefreshExpansionOverlay();
	end

	if self.overlay then
		local minimapAnimationEvents = self.overlay.GetMinimapAnimationEvents();
		if minimapAnimationEvents and tContains(minimapAnimationEvents, event) then
			self.overlay.HandleMinimapAnimationEvent(event, ...);
		end
	end
end

function ExpansionLandingPageMixin:IsOverlayApplied()
	return self.overlay ~= nil;
end

function ExpansionLandingPageMixin:GetNewestExpansionOverlayForPlayer()
	for expansion = LE_EXPANSION_LEVEL_CURRENT, LE_EXPANSION_CLASSIC, -1 do
		local overlay = landingPageOverlay[expansion];
		if overlay and overlay.IsOverlayUnlocked() then
			return overlay;
		end
	end
end

function ExpansionLandingPageMixin:RefreshExpansionOverlay()	
	local newestOverlay = self:GetNewestExpansionOverlayForPlayer();
	if newestOverlay and newestOverlay ~= self.overlay then
		self.overlay = newestOverlay;
		newestOverlay.CreateOverlay(self.Overlay);

		local minimapAnimationEvents = self.overlay.GetMinimapAnimationEvents();
		if minimapAnimationEvents then
			FrameUtil.RegisterFrameForEvents(self, minimapAnimationEvents);
		end

		EventRegistry:TriggerEvent("ExpansionLandingPage.OverlayChanged");

		if self.overlay.TryCelebrateUnlock then
			self.overlay:TryCelebrateUnlock();
		end
	end
end

function ExpansionLandingPageMixin:GetOverlayMinimapDisplayInfo()
	return self.overlay and self.overlay.GetMinimapDisplayInfo();
end
