----------------------------------- Expansion Landing Page -----------------------------------

local landingPageOverlay = {
	[LE_EXPANSION_DRAGONFLIGHT] = CreateFromMixins(DragonflightLandingOverlayMixin),
	[LE_EXPANSION_WAR_WITHIN] = CreateFromMixins(WarWithinLandingOverlayMixin),
};

ExpansionLandingPageMixin = {};

ExpansionLandingPageEvents = {
	"ACHIEVEMENT_EARNED",
	"MAJOR_FACTION_UNLOCKED",
	"NEW_MOUNT_ADDED",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"QUEST_REMOVED",
	"QUEST_TURNED_IN",
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
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
	if newestOverlay ~= self.overlay then
		if self.overlayFrame then
			self.overlayFrame:Hide();
		end

		if self.overlay then
			C_Minimap.ClearMinimapInsetInfo();
			local minimapAnimationEvents = self.overlay.GetMinimapAnimationEvents();
			if minimapAnimationEvents then
				FrameUtil.UnregisterFrameForEvents(self, minimapAnimationEvents);
			end
		end

		self.overlay = newestOverlay;

		if self.overlay then
			if self.overlay.GetMinimapInsetInfo then
				C_Minimap.SetMinimapInsetInfo(self.overlay.GetMinimapInsetInfo());
			end
			self.overlayFrame = newestOverlay.CreateOverlay(self.Overlay);
			self.overlayFrame:Show();

			local minimapAnimationEvents = self.overlay.GetMinimapAnimationEvents();
			if minimapAnimationEvents then
				FrameUtil.RegisterFrameForEvents(self, minimapAnimationEvents);
			end
		end

		EventRegistry:TriggerEvent("ExpansionLandingPage.ClearPulses");
		EventRegistry:TriggerEvent("ExpansionLandingPage.OverlayChanged");

		if self.overlay and self.overlay.TryCelebrateUnlock then
			self.overlay:TryCelebrateUnlock();
		end
	end
end

function ExpansionLandingPageMixin:GetOverlayMinimapDisplayInfo()
	return self.overlay and self.overlay.GetMinimapDisplayInfo();
end

function ExpansionLandingPageMixin:GetLandingPageType()
	local minimapDisplayInfo = self:GetOverlayMinimapDisplayInfo();
	if not minimapDisplayInfo then
		return Enum.ExpansionLandingPageType.None;
	end

	return minimapDisplayInfo.expansionLandingPageType;
end
