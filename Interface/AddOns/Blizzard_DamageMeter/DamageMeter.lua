local DAMAGE_METER_ENABLED_CVAR = "damageMeterEnabled";
CVarCallbackRegistry:SetCVarCachable(DAMAGE_METER_ENABLED_CVAR);

local MAX_DAMAGE_METER_WINDOW_FRAMES = 3;

-- Saved Variable. Stores which windows were previously shown and what stat they were tracking.
do
	if not DamageMeterPerCharacterSettings then
		DamageMeterPerCharacterSettings = {
			windowDataList = {};
		};
	end
end

local function HasSavedWindowDataList()
	return DamageMeterPerCharacterSettings and DamageMeterPerCharacterSettings.windowDataList and #DamageMeterPerCharacterSettings.windowDataList > 0;
end

local function AddToSavedWindowDataList(windowData)
	-- Saved window data and actual window data aren't identical structures.
	local savedWindowData = {
		trackedStat = windowData.trackedStat;
		shown = true;
	};

	table.insert(DamageMeterPerCharacterSettings.windowDataList, savedWindowData);
end

DamageMeterMixin = {
	windowDataList = {};
};

function DamageMeterMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCallback(DAMAGE_METER_ENABLED_CVAR, self.OnEnabledCVarChanged, self);

	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	-- Recreate all previously open windows and their respective tracked stats.
	-- Any windows that were previously moved or resized will be positioned when the
	-- SavedFramePositionCache is loaded.
	self:LoadSavedWindowDataList();

	-- If it doesn't exist, create the primary window frame, which much always exist and can't be hidden.
	-- This can happen if the saved window data doesn't exist or has been corrupted.
	if self:GetPrimaryWindowFrame() == nil then
		self:ShowNewWindowFrame();
	end
end

function DamageMeterMixin:OnEvent(event, ...)
	if event == "PLAYER_IN_COMBAT_CHANGED" or event == "PLAYER_LEVEL_CHANGED" then
		self:UpdateShownState();
	end
end

function DamageMeterMixin:OnVariablesLoaded()
	self:UpdateShownState();
end

function DamageMeterMixin:OnEnabledCVarChanged()
	self:UpdateShownState();
end

function DamageMeterMixin:GetWindowDataList()
	return self.windowDataList;
end

function DamageMeterMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;

	self:UpdateShownState();
end

function DamageMeterMixin:IsEditing()
	return self.isEditing;
end

function DamageMeterMixin:ShouldBeShown()
	if self:IsEditing() then
		return true;
	end

	if CVarCallbackRegistry:GetCVarValueBool(DAMAGE_METER_ENABLED_CVAR) ~= true then
		return false;
	end

	local isAvailable, _failureReason = C_DamageMeter.IsDamageMeterAvailable();
	if not isAvailable then
		return false;
	end

	if self.visibility then
		if self.visibility == Enum.DamageMeterVisibility.Always then
			return true;
		elseif self.visibility == Enum.DamageMeterVisibility.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibility == Enum.DamageMeterVisibility.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: " .. self.visibleSetting);
		end
	end

	return true;
end

function DamageMeterMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
end

function DamageMeterMixin:RefreshLayout()
	local windowDataList = self:GetWindowDataList();
	for i, windowData in ipairs(windowDataList) do
		if windowData.frame then
			windowData.frame:RefreshLayout();
		end
	end
end

function DamageMeterMixin:GetWindowFrame(index)
	return self.windowDataList and self.windowDataList[index] and self.windowDataList[index].frame or nil;
end

function DamageMeterMixin:GetPrimaryWindowFrame()
	return self:GetWindowFrame(1);
end

function DamageMeterMixin:GetMaxWindowFrameCount()
	return MAX_DAMAGE_METER_WINDOW_FRAMES;
end

function DamageMeterMixin:GetCurrentWindowFrameCount()
	local currentCount = 0;

	local windowDataList = self:GetWindowDataList();
	for i, windowData in ipairs(windowDataList) do
		if windowData.frame and windowData.frame:IsShown() then
			currentCount = currentCount + 1;
		end
	end

	return currentCount;
end

function DamageMeterMixin:CanShowNewWindowFrame()
	return self:GetCurrentWindowFrameCount() < self:GetMaxWindowFrameCount();
end

function DamageMeterMixin:GetAvailableWindowIndex()
	local windowDataList = self:GetWindowDataList();
	for i, windowData in ipairs(windowDataList) do
		if windowData.frame == nil or windowData.frame:IsShown() == false then
			return i;
		end
	end

	return nil;
end

function DamageMeterMixin:SetupWindowFrame(windowData, windowIndex)
	local windowFrame = windowData.frame or CreateFrame("FRAME", "DamageMeterWindow" .. windowIndex, self, "DamageMeterWindowTemplate");
	windowFrame:SetDamageMeterOwner(self, windowIndex);
	windowFrame:SetTrackedStat(windowData.trackedStat);

	-- Give the window initial positioning that may be overwritten by the saved frame position cache when it's loaded.
	windowFrame:ClearAllPoints();
	windowFrame:SetPoint("TOPLEFT");

	-- Ensure that the window frame's position won't be saved out until it's restored from the frame
	-- position cache, or if the player moves it. Important for the case when the player hides a
	-- window and shows a new one that's reusing a name already in the cache.
	windowFrame:SetUserPlaced(false);

	windowFrame:Show();

	windowData.frame = windowFrame;
end

function DamageMeterMixin:LoadSavedWindowDataList()
	if HasSavedWindowDataList() ~= true then
		return;
	end

	local savedWindowDataList = DamageMeterPerCharacterSettings.windowDataList;

	local maxWindowFrameCount = self:GetMaxWindowFrameCount();
	for i = 1, maxWindowFrameCount do
		local savedWindowData = savedWindowDataList[i];
		if savedWindowData == nil then
			break;
		end

		local windowData = {
			trackedStat = savedWindowData.trackedStat;
		};
		table.insert(self.windowDataList, windowData);

		if savedWindowData.shown then
			self:SetupWindowFrame(windowData, i);
		end
	end
end

function DamageMeterMixin:ShowNewWindowFrame()
	if self:CanShowNewWindowFrame() ~= true then
		return;
	end

	local windowData;

	local windowIndex = self:GetAvailableWindowIndex();
	if windowIndex then
		windowData = self.windowDataList[windowIndex];
		DamageMeterPerCharacterSettings.windowDataList[windowIndex].shown = true;
	else
		windowData = {
			trackedStat = "Damage Done";
		};
		table.insert(self.windowDataList, windowData );

		windowIndex = #self.windowDataList;

		AddToSavedWindowDataList(windowData);
	end

	self:SetupWindowFrame(windowData, windowIndex);
end

function DamageMeterMixin:CanHideWindowFrame(windowFrame)
	if windowFrame == nil then
		return false;
	end

	return self:GetPrimaryWindowFrame() ~= windowFrame;
end

function DamageMeterMixin:HideWindowFrame(windowFrame)
	if self:CanHideWindowFrame(windowFrame) ~= true then
		return;
	end

	local windowFrameIndex = windowFrame:GetWindowFrameIndex();

	self.windowDataList[windowFrameIndex].frame:Hide();

	DamageMeterPerCharacterSettings.windowDataList[windowFrameIndex].shown = false;
end

function DamageMeterMixin:HideAllWindowFrames()
	-- Hides all window frames except for the primary one, which can't be hidden.
	local windowDataList = self:GetWindowDataList();
	for i, windowData in ipairs(windowDataList) do
		if windowDataList[i] and windowDataList[i].frame then
			self:HideWindowFrame(windowDataList[i].frame);
		end
	end
end

function DamageMeterMixin:SetWindowFrameTrackedStat(windowFrame, trackedStat)
	local windowFrameIndex = windowFrame:GetWindowFrameIndex();

	self.windowDataList[windowFrameIndex].trackedStat = trackedStat;

	DamageMeterPerCharacterSettings.windowDataList[windowFrameIndex].trackedStat = trackedStat;

	windowFrame:SetTrackedStat(trackedStat);
end

function DamageMeterMixin:GetWindowFrameTrackedStat(windowFrame)
	local windowFrameIndex = windowFrame:GetWindowFrameIndex();

	return self.windowDataList[windowFrameIndex].trackedStat;
end
