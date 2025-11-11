local DAMAGE_METER_ENABLED_CVAR = "damageMeterEnabled";
CVarCallbackRegistry:SetCVarCachable(DAMAGE_METER_ENABLED_CVAR);

local MAX_DAMAGE_METER_SESSION_WINDOWS = 3;

-- Saved Variable. Stores which windows were previously shown and what damage meter type they were tracking.
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

local function IsSavedWindowDataValid(savedWindowData)
	if savedWindowData == nil then
		return false;
	end

	if savedWindowData.damageMeterType == nil then
		return false;
	end

	if type(savedWindowData.damageMeterType) ~= "number" then
		return false;
	end

	if savedWindowData.sessionType == nil then
		return false;
	end

	if type(savedWindowData.sessionType) ~= "number" then
		return false;
	end

	return true;
end

local function AddToSavedWindowDataList(windowData)
	-- Saved window data and actual window data aren't identical structures.
	local savedWindowData = {
		damageMeterType = windowData.damageMeterType;
		sessionType = windowData.sessionType;
		shown = true;
	};

	table.insert(DamageMeterPerCharacterSettings.windowDataList, savedWindowData);
end

DamageMeterMixin = {};

function DamageMeterMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCallback(DAMAGE_METER_ENABLED_CVAR, self.OnEnabledCVarChanged, self);

	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	self.windowDataList = {};

	-- Recreate all previously open windows and their respective damageMeterTypes.
	-- Any windows that were previously moved or resized will be positioned when the
	-- SavedFramePositionCache is loaded.
	self:LoadSavedWindowDataList();

	-- If it doesn't exist, create the primary sessoin window, which much always exist and can't be hidden.
	-- This can happen if the saved window data doesn't exist or has been corrupted.
	if self:GetPrimarySessionWindow() == nil then
		self:ShowNewSessionWindow();
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

	self:GetPrimarySessionWindow():SetIsEditing(isEditing);
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
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:RefreshLayout(); end);
end

function DamageMeterMixin:GetSessionWindow(index)
	return self.windowDataList and self.windowDataList[index] and self.windowDataList[index].sessionWindow or nil;
end

function DamageMeterMixin:EnumerateSessionWindows()
	local function GetNextSessionWindow(self_, index)
		while index < #self.windowDataList do
			index = index + 1;
			local window = self_:GetSessionWindow(index);

			if window ~= nil then
				return index, window;
			end
		end
	end;

	local initialIndex = 0;
	return GetNextSessionWindow, self, initialIndex;
end

function DamageMeterMixin:ForEachSessionWindow(func, ...)
	for _index, sessionWindow in self:EnumerateSessionWindows() do
		func(sessionWindow, ...);
	end
end

function DamageMeterMixin:GetPrimarySessionWindow()
	return self:GetSessionWindow(1);
end

function DamageMeterMixin:GetMaxSessionWindowCount()
	return MAX_DAMAGE_METER_SESSION_WINDOWS;
end

function DamageMeterMixin:GetCurrentSessionWindowCount()
	local currentCount = 0;

	self:ForEachSessionWindow(function(sessionWindow)
		if sessionWindow:IsShown() then
			currentCount = currentCount + 1;
		end
	end);

	return currentCount;
end

function DamageMeterMixin:CanShowNewSessionWindow()
	return self:GetCurrentSessionWindowCount() < self:GetMaxSessionWindowCount();
end

function DamageMeterMixin:GetAvailableWindowIndex()
	local windowDataList = self:GetWindowDataList();
	for i, windowData in ipairs(windowDataList) do
		if windowData.sessionWindow == nil or windowData.sessionWindow:IsShown() == false then
			return i;
		end
	end

	return nil;
end

function DamageMeterMixin:SetupSessionWindow(windowData, windowIndex)
	local sessionWindow = windowData.sessionWindow or CreateFrame("FRAME", "DamageMeterSessionWindow" .. windowIndex, self, "DamageMeterSessionWindowTemplate");
	sessionWindow:SetDamageMeterOwner(self, windowIndex);
	sessionWindow:SetDamageMeterType(windowData.damageMeterType);
	sessionWindow:SetSession(windowData.sessionType, windowData.sessionID);
	sessionWindow:SetUseClassColor(self:ShouldUseClassColor());

	-- Give the window initial positioning that may be overwritten by the saved frame position cache when it's loaded.
	sessionWindow:ClearAllPoints();
	sessionWindow:SetPoint("TOPLEFT");

	-- Ensure that the window's position won't be saved out until it's restored from the frame
	-- position cache, or if the player moves it. Important for the case when the player hides a
	-- window and shows a new one that's reusing a name already in the cache.
	sessionWindow:SetUserPlaced(false);

	sessionWindow:Show();

	windowData.sessionWindow = sessionWindow;
end

function DamageMeterMixin:LoadSavedWindowDataList()
	if HasSavedWindowDataList() ~= true then
		return;
	end

	local savedWindowDataList = DamageMeterPerCharacterSettings.windowDataList;

	local maxSessionWindowCount = self:GetMaxSessionWindowCount();
	for i = 1, maxSessionWindowCount do
		local savedWindowData = savedWindowDataList[i];

		if IsSavedWindowDataValid(savedWindowData) == true then
			local windowData = {
				damageMeterType = savedWindowData.damageMeterType;
				sessionType = savedWindowData.sessionType;
			};

			table.insert(self.windowDataList, windowData);

			if savedWindowData.shown then
				self:SetupSessionWindow(windowData, i);
			end
		end
	end
end

function DamageMeterMixin:ShowNewSessionWindow()
	if self:CanShowNewSessionWindow() ~= true then
		return;
	end

	local windowData;

	local windowIndex = self:GetAvailableWindowIndex();
	if windowIndex then
		windowData = self.windowDataList[windowIndex];
		DamageMeterPerCharacterSettings.windowDataList[windowIndex].shown = true;
	else
		windowData = {
			damageMeterType = Enum.DamageMeterType.DamageDone;
			sessionType = Enum.DamageMeterSessionType.Overall;
		};
		table.insert(self.windowDataList, windowData );

		windowIndex = #self.windowDataList;

		AddToSavedWindowDataList(windowData);
	end

	self:SetupSessionWindow(windowData, windowIndex);
end

function DamageMeterMixin:CanHideSessionWindow(sessionWindow)
	if sessionWindow == nil then
		return false;
	end

	return self:GetPrimarySessionWindow() ~= sessionWindow;
end

function DamageMeterMixin:HideSessionWindow(sessionWindow)
	if self:CanHideSessionWindow(sessionWindow) ~= true then
		return;
	end

	local sessionWindowIndex = sessionWindow:GetSessionWindowIndex();

	self.windowDataList[sessionWindowIndex].sessionWindow:Hide();

	DamageMeterPerCharacterSettings.windowDataList[sessionWindowIndex].shown = false;
end

function DamageMeterMixin:HideAllSessionWindows()
	-- Hides all session windows except for the primary one, which can't be hidden.
	self:ForEachSessionWindow(function(sessionWindow) self:HideSessionWindow(sessionWindow); end);
end

function DamageMeterMixin:SetSessionWindowDamageMeterType(sessionWindow, damageMeterType)
	local sessionWindowIndex = sessionWindow:GetSessionWindowIndex();

	self.windowDataList[sessionWindowIndex].damageMeterType = damageMeterType;

	DamageMeterPerCharacterSettings.windowDataList[sessionWindowIndex].damageMeterType = damageMeterType;

	sessionWindow:SetDamageMeterType(damageMeterType);
end

function DamageMeterMixin:GetSessionWindowDamageMeterType(sessionWindow)
	local sessionWindowIndex = sessionWindow:GetSessionWindowIndex();

	return self.windowDataList[sessionWindowIndex].damageMeterType;
end

function DamageMeterMixin:SetSessionWindowSessionID(sessionWindow, sessionType, sessionID)
	local sessionWindowIndex = sessionWindow:GetSessionWindowIndex();

	self.windowDataList[sessionWindowIndex].sessionType = sessionType;
	self.windowDataList[sessionWindowIndex].sessionID = sessionID;

	DamageMeterPerCharacterSettings.windowDataList[sessionWindowIndex].sessionType = sessionType;
	-- sessionID is intentionally not preserved in saved data as it's specific to the player's recent encounters.

	sessionWindow:SetSession(sessionType, sessionID);
end

function DamageMeterMixin:OnUseClassColorChanged(useClassColor)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetUseClassColor(useClassColor); end);
end

function DamageMeterMixin:ShouldUseClassColor()
	return self.useClassColor == true;
end

function DamageMeterMixin:SetUseClassColor(useClassColor)
	useClassColor = (useClassColor == true);

	if self.useClassColor ~= useClassColor then
		self.useClassColor = useClassColor;
		self:OnUseClassColorChanged(useClassColor);
	end
end

function DamageMeterMixin:OnBarHeightChanged(barHeight)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetBarHeight(barHeight); end);
end

function DamageMeterMixin:GetBarHeight()
	return self.barHeight or DAMAGE_METER_DEFAULT_BAR_HEIGHT;
end

function DamageMeterMixin:SetBarHeight(barHeight)
	if not ApproximatelyEqual(self:GetBarHeight(), barHeight) then
		self.barHeight = barHeight;
		self:OnBarHeightChanged(barHeight);
	end
end

function DamageMeterMixin:OnTextScaleChanged(textScale)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetTextScale(textScale); end);
end

function DamageMeterMixin:GetTextScale()
	return self.textScale or 1;
end

function DamageMeterMixin:SetTextScale(textScale)
	if not ApproximatelyEqual(self:GetTextScale(), textScale) then
		self.textScale = textScale;
		self:OnTextScaleChanged(textScale);
	end
end

function DamageMeterMixin:GetTextSize()
	return self:GetTextScale() / DAMAGE_METER_TEXT_SIZE_TO_SCALE_MULTIPLIER;
end

function DamageMeterMixin:SetTextSize(textSize)
	self:SetTextScale(textSize * DAMAGE_METER_TEXT_SIZE_TO_SCALE_MULTIPLIER);
end

function DamageMeterMixin:OnWindowAlphaChanged(alpha)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetAlpha(alpha); end);
end

function DamageMeterMixin:GetWindowAlpha()
	return self.windowAlpha or 1;
end

function DamageMeterMixin:SetWindowAlpha(alpha)
	if not ApproximatelyEqual(self:GetWindowAlpha(), alpha) then
		self.windowAlpha = alpha;
		self:OnWindowAlphaChanged(alpha);
	end
end

function DamageMeterMixin:GetWindowTransparency()
	return self:GetWindowAlpha() / DAMAGE_METER_TRANSPARENCY_TO_ALPHA_MULTIPLIER;
end

function DamageMeterMixin:SetWindowTransparency(transparency)
	return self:SetWindowAlpha(transparency * DAMAGE_METER_TRANSPARENCY_TO_ALPHA_MULTIPLIER);
end

function DamageMeterMixin:OnShowBarIconsChanged(showBarIcons)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetShowBarIcons(showBarIcons); end);
end

function DamageMeterMixin:ShouldShowBarIcons()
	return self.showBarIcons == true;
end

function DamageMeterMixin:SetShowBarIcons(showBarIcons)
	showBarIcons = (showBarIcons == true);

	if self.showBarIcons ~= showBarIcons then
		self.showBarIcons = showBarIcons;
		self:OnShowBarIconsChanged(showBarIcons);
	end
end

function DamageMeterMixin:OnStyleChanged(style)
	self:ForEachSessionWindow(function(sessionWindow) sessionWindow:SetStyle(style); end);
end

function DamageMeterMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterMixin:SetStyle(style)
	if self.style ~= style then
		self.style = style;
		self:OnStyleChanged(style);
	end
end
