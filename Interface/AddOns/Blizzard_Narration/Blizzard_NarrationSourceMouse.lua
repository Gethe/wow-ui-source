
-- Narration Source: Mouse
--
-- Polls cursor position each frame and triggers navigation narration when the mouse dwells
-- over a UI element. Also tracks visible tooltips via Tooltip.OnShown/Tooltip.OnHidden events
-- and queues tooltip narration after navigation.
--
-- Registers and unregisters polling in response to "Narration.SystemStatus" events.

-- This may be configurable via settings in the future.
DWELL_TIME_DEFAULT = 0.05;

local function GetNarrationKey(narrationInfo)
	return NarrationUtil.MakeNarrationStringFromInfo(narrationInfo);
end

local function ShouldNarrateRegion(region)
	if not region.NarrationShouldIgnoreFocus or not region:NarrationShouldIgnoreFocus() then
		return true;
	end

	return false;
end

local function DoesRegionAllowFocusReplay(region)
	if not region.NarrationShouldIgnoreFocusReplay or not region:NarrationShouldIgnoreFocusReplay() then
		return true;
	end

	return false;
end

local function BuildNarrationInfo(regions)
	local resolvedRegions = {};
	for i, region in ipairs(regions) do
		region = NarrationUtil.ResolveForwardedRegion(region);
		if ShouldNarrateRegion(region) then
			table.insert(resolvedRegions, region);
		end
	end

	local region = RegionUtil.GetTopLeftMost(resolvedRegions);
	return NarrationUtil.RegionToNarrationInfo(region, NarrationUtil.TriggerType.Navigation), region;
end

NarrationSourceMouseMixin = {};

function NarrationSourceMouseMixin:Init()
	self:Reset();

	EventRegistry:RegisterCallback("Narration.SystemStatus", self.OnSystemStatus, self);
end

function NarrationSourceMouseMixin:OnSystemStatus(isEnabled)
	if isEnabled then
		self:UpdateEventRegistration(isEnabled);
	else
		self:Reset();
	end
end

function NarrationSourceMouseMixin:UpdateEventRegistration(shouldBeRegistered)
	if shouldBeRegistered == self:AreCallbacksRegistered() then
		return;
	end

	if shouldBeRegistered then
		EventRegistry:RegisterCallback("Narration.Interrupted", self.OnNarrationInterrupted, self);
		EventRegistry:RegisterCallback("Tooltip.OnShown", self.OnTooltipShown, self);
		EventRegistry:RegisterCallback("Tooltip.OnHidden", self.OnTooltipHidden, self);
		EventRegistry:RegisterFrameEventAndCallback("GLOBAL_MOUSE_UP", self.OnGlobalMouseUp, self);
		EventRegistry:RegisterForOnUpdate(self, self.FrameUpdate);
		self.callbacksRegistered = true;
	else
		EventRegistry:UnregisterCallback("Narration.Interrupted", self);
		EventRegistry:UnregisterCallback("Tooltip.OnShown", self);
		EventRegistry:UnregisterCallback("Tooltip.OnHidden", self);
		EventRegistry:UnregisterFrameEventAndCallback("GLOBAL_MOUSE_UP", self);
		EventRegistry:UnregisterForOnUpdate(self);
		self.callbacksRegistered = false;
	end
end

function NarrationSourceMouseMixin:AreCallbacksRegistered()
	return not not self.callbacksRegistered;
end

function NarrationSourceMouseMixin:OnNarrationInterrupted(triggerType)
	if triggerType ~= NarrationUtil.TriggerType.Navigation then
		self.lastSpokenNavigationKey = nil;
	end
end

function NarrationSourceMouseMixin:OnGlobalMouseUp()
	if not self.lastFocusedRegion then
		return;
	end

	local regions = GetMouseFoci();
	local isIndexTable = true;
	regions = tFilter(regions, DoesRegionAllowFocusReplay, isIndexTable);
	if #regions == 0 then
		return;
	end

	-- The region's state may have changed due to the click (e.g. selection). So
	-- treat it like a new region to force narration.
	local isNewRegion = true;
	local narrationInfo = BuildNarrationInfo(regions);
	self:SpeakNavigation(narrationInfo, isNewRegion);
end

function NarrationSourceMouseMixin:OnTooltipShown(tooltip)
	self.activeTooltips[tooltip] = true;
end

function NarrationSourceMouseMixin:OnTooltipHidden(tooltip)
	self.activeTooltips[tooltip] = nil;
end

function NarrationSourceMouseMixin:Reset()
	local shouldBeRegistered = false;
	self:UpdateEventRegistration(shouldBeRegistered);

	self.dwellTimer = 0;

	-- This initialization avoids the necessity of nil checks.
	self.lastCursorX = math.huge;
	self.lastCursorY = math.huge;

	self.lastFocusedRegion = nil;
	self.lastSpokenNavigationKey = nil;
	self.activeTooltips = {};
end

function NarrationSourceMouseMixin:SpeakNavigation(narrationInfo, isNewRegion)
	if not narrationInfo then
		return;
	end

	local narrationKey = GetNarrationKey(narrationInfo);
	if not narrationKey then
		return;
	end

	if not isNewRegion and (narrationKey == self.lastSpokenNavigationKey) then
		return;
	end

	self.lastSpokenNavigationKey = narrationKey;
	EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
end

function NarrationSourceMouseMixin:PollTooltips(hasNavigationNarration)
	local sortedTooltips = {};
	for tooltip in pairs(self.activeTooltips) do
		if tooltip:IsShown() then
			sortedTooltips[#sortedTooltips + 1] = tooltip;
		end
	end

	if #sortedTooltips == 0 then
		return;
	end

	RegionUtil.SortByTopLeft(sortedTooltips);

	local shouldQueue = hasNavigationNarration;
	for _, tooltip in ipairs(sortedTooltips) do
		local narrationInfo = NarrationUtil.RegionToNarrationInfo(tooltip, NarrationUtil.TriggerType.Tooltip);
		if narrationInfo then
			if shouldQueue then
				EventRegistry:TriggerEvent("Narration.Queue", narrationInfo);
			else
				EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
				shouldQueue = true;
			end
		end
	end
end

function NarrationSourceMouseMixin:FrameUpdate(elapsed)
	local cursorX, cursorY = GetCursorPosition();
	local resetDwellTime = not ApproximatelyEqual(cursorX, self.lastCursorX) or not ApproximatelyEqual(cursorY, self.lastCursorY);
	self.lastCursorX = cursorX;
	self.lastCursorY = cursorY;
	if resetDwellTime then
		self.dwellTimer = 0;
		return;
	end

	-- If we've already checked this location, don't check again until the cursor moves.
	if self.dwellTimer >= DWELL_TIME_DEFAULT then
		return;
	end

	self.dwellTimer = self.dwellTimer + elapsed;
	if self.dwellTimer < DWELL_TIME_DEFAULT then
		return;
	end

	local regions = GetMouseFoci();
	if #regions == 0 then
		self.lastSpokenNavigationKey = nil;
		self.lastFocusedRegion = nil;
		return;
	end

	local narrationInfo, focusedRegion = BuildNarrationInfo(regions);
	local isNewRegion = (self.lastFocusedRegion ~= focusedRegion);
	if narrationInfo then
		self:SpeakNavigation(narrationInfo, isNewRegion);
	else
		self.lastSpokenNavigationKey = nil;
	end

	-- We want to read out any tooltips after our focus has changed unless we're mousing over a frame
	-- that wants to skip tooltips (because it includes the same info in its own narration).
	if isNewRegion and not NarrationUtil.ShouldRegionNavigationSkipTooltips(focusedRegion) then
		self:PollTooltips(narrationInfo ~= nil);
	end

	self.lastFocusedRegion = focusedRegion;
end

CreateAndInitFromMixin(NarrationSourceMouseMixin);
