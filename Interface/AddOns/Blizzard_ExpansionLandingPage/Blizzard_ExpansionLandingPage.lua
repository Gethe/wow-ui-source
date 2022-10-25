----------------------------------- Expansion Landing Page -----------------------------------

local landingPageOverlay = {
	[LE_EXPANSION_DRAGONFLIGHT] = CreateFromMixins(DragonflightLandingOverlayMixin),
};

ExpansionLandingPageMixin = {};

ExpansionLandingPageEvents = {
	"QUEST_TURNED_IN",
	"PLAYER_LOGIN",
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
	if event == "QUEST_TURNED_IN" then
		local completedQuestID, xpReward, moneyReward = ...;
		self:RefreshExpansionOverlay(completedQuestID);
	elseif event == "PLAYER_LOGIN" then
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

function ExpansionLandingPageMixin:GetNewestExpansionOverlayForPlayer(completedQuestID)
	for expansion = LE_EXPANSION_LEVEL_CURRENT, LE_EXPANSION_CLASSIC, -1 do
		local overlay = landingPageOverlay[expansion];
		if overlay and overlay.IsOverlayUnlocked(completedQuestID) then
			return overlay;
		end
	end
end

function ExpansionLandingPageMixin:RefreshExpansionOverlay(completedQuestID)	
	local newestOverlay = self:GetNewestExpansionOverlayForPlayer(completedQuestID);
	if newestOverlay and newestOverlay ~= self.overlay then
		self.overlay = newestOverlay;
		newestOverlay.CreateOverlay(self.Overlay);

		local minimapAnimationEvents = self.overlay.GetMinimapAnimationEvents();
		if minimapAnimationEvents then
			FrameUtil.RegisterFrameForEvents(self, minimapAnimationEvents);
		end

		EventRegistry:TriggerEvent("ExpansionLandingPage.OverlayChanged");
	end
end

function ExpansionLandingPageMixin:GetOverlayMinimapDisplayInfo()
	return self.overlay and self.overlay.GetMinimapDisplayInfo();
end
