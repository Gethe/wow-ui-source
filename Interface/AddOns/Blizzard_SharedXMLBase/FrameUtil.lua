
local tDeleteItem = tDeleteItem;

-- Alpha animation stuff
FADEFRAMES = {};
FLASHFRAMES = {};


FrameUtil = {};

function FrameUtil.RegisterUpdateFunction(frame, frequencySeconds, func)
	-- Prevents the OnUpdate handler from running the same frame it was
	-- removed.
	frame.canUpdate = true;

	local elapsed = frequencySeconds;
	frame:SetScript("OnUpdate", function(self, dt)
		if self.canUpdate then
			elapsed = elapsed - dt;
			if elapsed <= 0 then
				elapsed = frequencySeconds;
				func(frame, dt);
			end
		end
	end);
end

function FrameUtil.UnregisterUpdateFunction(frame)
	frame.canUpdate = false;
	frame:SetScript("OnUpdate", nil);
end

function FrameUtil.RegisterFrameForEvents(frame, events)
	for i, event in ipairs(events) do
		frame:RegisterEvent(event);
	end
end

function FrameUtil.UnregisterFrameForEvents(frame, events)
	for i, event in ipairs(events) do
		frame:UnregisterEvent(event);
	end
end

function FrameUtil.RegisterFrameForUnitEvents(frame, events, ...)
	for i, event in ipairs(events) do
		frame:RegisterUnitEvent(event, ...);
	end
end

function FrameUtil.DialogStyleGlobalMouseDown(frame, buttonName, ...)
	local mouseFoci = GetMouseFoci();
	if DoesAncestryIncludeAny(frame, mouseFoci) then
		return;
	end

	for i = 1, select("#", ...) do
		local alternateFrame = select(i, ...);
		if DoesAncestryIncludeAny(alternateFrame, mouseFoci) then
			return;
		end
	end

	frame:Hide();
end

local StandardScriptHandlerSet = {
	OnLoad = true,
	OnShow = true,
	OnHide = true,
	OnEvent = true,
	OnEnter = true,
	OnLeave = true,
	OnClick = true,
	OnDragStart = true,
	OnReceiveDrag = true,

	-- Other scripts can/should be added here as needed.

	-- Many OnUpdates are set dynamically. Leave this off for now.
	-- OnUpdate = false,
};

-- ... is a list of tables to mixin.
function FrameUtil.SpecializeFrameWithMixins(frame, ...)
	Mixin(frame, ...);
	FrameUtil.ReflectStandardScriptHandlers(frame);
end

function FrameUtil.ReflectStandardScriptHandlers(frame)
	for scriptHandlerKey, shouldBeSet in pairs(StandardScriptHandlerSet) do
		local scriptHandler = frame[scriptHandlerKey];
		if scriptHandler ~= nil then
			frame:SetScript(scriptHandlerKey, scriptHandler);
		end
	end

	if frame.OnLoad then
		frame:OnLoad();
	end

	if frame.OnShow and frame:IsVisible() then
		frame:OnShow();
	end
end

-- This doesn't strictly speaking require a frame, but that's the likely usage of it so I'm leaving it here for now.
function FrameUtil.RegisterForVariablesLoaded(frame, loadMethod)
	if frame.savedVariablesEventRegistered then
		error("Cannot re-register for variables loaded.");
		return;
	end

	frame.savedVariablesEventRegistered = true;

	local function VariablesLoadedCallback(callbackSelf)
		loadMethod(frame);
	end

	EventUtil.ContinueOnVariablesLoaded(VariablesLoadedCallback);
end

-- Only expected to return differently in glues and in-game.
function FrameUtil.GetRootParent(frame)
	local parent = frame:GetParent();
	while parent do
		local nextParent = parent:GetParent();
		if not nextParent then
			break;
		end
		parent = nextParent;
	end
	return parent;
end

function FrameUtil.CreateFrame(name, parent, template)
	-- NOTE: This use of the template type is not strictly correct, but should mostly work.
	local templateInfo = C_XMLUtil.GetTemplateInfo(template);
	local frameType = templateInfo and templateInfo.type or "Frame";
	return CreateFrame(frameType, name, parent, template);
end

function FrameUtil.UpdateScaleForFit(frame, extraWidth, extraHeight)
	extraWidth = extraWidth or 0;
	extraHeight = extraHeight or 0;

	FrameUtil.UpdateScaleForFitSpecific(frame, frame:GetWidth() + extraWidth, frame:GetHeight() + extraHeight);
end

function FrameUtil.UpdateScaleForFitSpecific(frame, specificWidth, specificHeight)
	frame:SetScale(1);

	local topLevelParent = GetAppropriateTopLevelParent();
	local horizRatio = topLevelParent:GetWidth() / (specificWidth or frame:GetWidth());
	local vertRatio = topLevelParent:GetHeight() / (specificHeight or frame:GetHeight());

	if (horizRatio < 1 or vertRatio < 1) then
		frame:SetScale(min(horizRatio, vertRatio));
	end
end

function DoesAncestryInclude(ancestry, frame)
	if ancestry then
		local currentFrame = frame;
		while currentFrame do
			if currentFrame == ancestry then
				return true;
			end
			currentFrame = currentFrame:GetParent();
		end
	end
	return false;
end

function DoesAncestryIncludeAny(ancestry, frames)
	for _, frame in ipairs(frames) do
		if DoesAncestryInclude(ancestry, frame) then
			return true;
		end
	end
	return false;
end

function GetUnscaledFrameRect(frame, scale)
	local frameLeft, frameBottom, frameWidth, frameHeight = frame:GetScaledRect();
	if frameLeft == nil then
		-- Defaulted returned for diagnosing invalid rects in layout frames.
		local defaulted = true;
		return 1, 1, 1, 1, defaulted;
	end

	return frameLeft / scale, frameBottom / scale, frameWidth / scale, frameHeight / scale;
end

function GetScaledCenter(frame)
	local x, y = frame:GetCenter();
	local effectiveScale = frame:GetEffectiveScale();
	if x == nil or y == nil or effectiveScale == nil then
		-- Defaulted returned for diagnosing invalid rects in layout frames.
		local defaulted = true;
		return 0, 0, defaulted;
	end

	return x * effectiveScale, y * effectiveScale;
end

function ApplyDefaultScale(frame, minScale, maxScale)
	local scale = GetDefaultScale();

	if minScale then
		scale = math.max(scale, minScale);
	end

	if maxScale then
		scale = math.min(scale, maxScale);
	end

	frame:SetScale(scale);
end

function FitToParent(parent, frame)
	local horizRatio = parent:GetWidth() / frame:GetWidth();
	local vertRatio = parent:GetHeight() / frame:GetHeight();

	if ( horizRatio < 1 or vertRatio < 1 ) then
		frame:SetScale(min(horizRatio, vertRatio));
		frame:SetPoint("CENTER", 0, 0);
	end

end

local alternateTopLevelParent;
function SetAlternateTopLevelParent(parent)
	alternateTopLevelParent = parent;
	EventRegistry:TriggerEvent("UI.AlternateTopLevelParentChanged", parent);
end

function ClearAlternateTopLevelParent()
	alternateTopLevelParent = nil;
	EventRegistry:TriggerEvent("UI.AlternateTopLevelParentChanged");
end

-- optionalExcludedParent: Frame to avoid returning if it is currently the alternateTopLevelParent; Useful for frames that might currently be the alternate but need the root top for scaling
function GetAppropriateTopLevelParent(optionalExcludedParent)
	if alternateTopLevelParent and alternateTopLevelParent:IsShown() and (not optionalExcludedParent or alternateTopLevelParent ~= optionalExcludedParent) then
		return alternateTopLevelParent;
	end

	return UIParent or GlueParent;
end

function SetAppropriateTopLevelParent(frame)
	local parent = GetAppropriateTopLevelParent();
	if parent then
		frame:SetParent(parent);
	end
end
function GetAppropriateTooltip()
	return UIParent and GameTooltip or GlueTooltip;
end

-- Frame fading and flashing --

local frameFadeManager = CreateFrame("FRAME");

local function UIFrameFadeContains(frame)
	for i, fadeFrame in ipairs(FADEFRAMES) do
		if ( fadeFrame == frame ) then
			return true;
		end
	end

	return false;
end

-- Generic fade function
function UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN";
	end
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;
	frame:Show();
	
	-- secure so we don't spread taint to other frames in FADEFRAMES
	if securecallfunction(UIFrameFadeContains, frame) then
		return;
	end
	tinsert(FADEFRAMES, frame);
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate);
end

-- Convenience function to do a simple fade in
function UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

-- Convenience function to do a simple fade out
function UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

function UIFrameFadeRemoveFrame(frame)
	securecallfunction(tDeleteItem, FADEFRAMES, frame);
end

-- Function that actually performs the alpha change
--[[
Fading frame attribute listing
============================================================
frame.timeToFade  [Num]		Time it takes to fade the frame in or out
frame.mode  ["IN", "OUT"]	Fade mode
frame.finishedFunc [func()]	Function that is called when fading is finished
frame.finishedArg1 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg2 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg3 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg4 [ANYTHING]	Argument to the finishedFunc
frame.fadeHoldTime [Num]	Time to hold the faded state
 ]]

function UIFrameFade_OnUpdate(self, elapsed)
	local index = 1;
	local frame, fadeInfo;
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index];
		fadeInfo = FADEFRAMES[index].fadeInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not fadeInfo.fadeTimer ) then
			fadeInfo.fadeTimer = 0;
		end
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
		if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha);
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if ( fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  ) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
			else
				-- Complete the fade and call the finished function if there is one
				UIFrameFadeRemoveFrame(frame);
				if ( fadeInfo.finishedFunc ) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
					fadeInfo.finishedFunc = nil;
				end
			end
		end

		index = index + 1;
	end

	if ( #FADEFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

function UIFrameIsFading(frame)
	-- secure so we don't spread taint to other frames in FADEFRAMES
	return securecallfunction(UIFrameFadeContains, frame);
end

local frameFlashManager = CreateFrame("FRAME");

local UIFrameFlashTimers = {};
local UIFrameFlashTimerRefCount = {};

-- Function to start a frame flashing
function UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if ( frame ) then
		-- If frame is already set to flash then return
		if (UIFrameIsFlashing(frame)) then
			return;
		end

		if (syncId) then
			frame.syncId = syncId;
			if (UIFrameFlashTimers[syncId] == nil) then
				UIFrameFlashTimers[syncId] = 0;
				UIFrameFlashTimerRefCount[syncId] = 0;
			end
			UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId]+1;
		else
			frame.syncId = nil;
		end

		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing, -1 means forever
		frame.flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone;
		-- Internal timer
		frame.flashTimer = 0;
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;

		tinsert(FLASHFRAMES, frame);

		frameFlashManager:SetScript("OnUpdate", UIFrameFlash_OnUpdate);
	end
end

local function UIFrameFlashUpdateTimers(syncId, timer, elapsed)
	UIFrameFlashTimers[syncId] = timer + elapsed;
end

-- Called every frame to update flashing frames
function UIFrameFlash_OnUpdate(self, elapsed)
	local frame;
	local index = #FLASHFRAMES;

	-- Update timers for all synced frames
	-- secure so we don't spread taint to other frames
	secureexecuterange(UIFrameFlashTimers, UIFrameFlashUpdateTimers, elapsed);

	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame.flashTimer = frame.flashTimer + elapsed;

		if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			UIFrameFlashStop(frame);
		else
			local flashTime = frame.flashTimer;
			local alpha;

			if (frame.syncId) then
				flashTime = UIFrameFlashTimers[frame.syncId];
			end

			flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0));
			if (flashTime < frame.fadeInTime) then
				alpha = flashTime/frame.fadeInTime;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)) then
				alpha = 1;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime) then
				alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime);
			else
				alpha = 0;
			end

			frame:SetAlpha(alpha);
			frame:Show();
		end

		-- Loop in reverse so that removing frames is safe
		index = index - 1;
	end

	if ( #FLASHFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Function to see if a frame is already flashing
local function UIFrameFlashContains(frame)
	for i, fadeFrame in ipairs(FLASHFRAMES) do
		if ( fadeFrame == frame ) then
			return true;
		end
	end

	return false;
end

function UIFrameIsFlashing(frame)
	-- secure so we don't spread taint to other frames in FLASHFRAMES
	return securecallfunction(UIFrameFlashContains, frame);
end

-- Function to stop flashing
function UIFrameFlashStop(frame)
	-- secure so we don't spread taint to other frames in FLASHFRAMES
	securecallfunction(tDeleteItem, FLASHFRAMES, frame);
	frame:SetAlpha(1.0);
	frame.flashTimer = nil;
	if (frame.syncId) then
		UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId]-1;
		if (UIFrameFlashTimerRefCount[frame.syncId] == 0) then
			UIFrameFlashTimers[frame.syncId] = nil;
			UIFrameFlashTimerRefCount[frame.syncId] = nil;
		end
		frame.syncId = nil;
	end
	if ( frame.showWhenDone ) then
		frame:Show();
	else
		frame:Hide();
	end
end

-- Sets a frame parent, but retains old frame strata and frame level
function FrameUtil.SetParentMaintainRenderLayering(frame, parent)
	local origStrata = frame:GetFrameStrata();
	local origFrameLevel = frame:GetFrameLevel();
	frame:SetParent(parent);
	frame:SetFrameStrata(origStrata);
	frame:SetFrameLevel(origFrameLevel);
end