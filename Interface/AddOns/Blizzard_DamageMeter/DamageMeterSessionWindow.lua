local DAMAGE_METER_CATEGORIES = {
	{ name = DAMAGE_METER_CATEGORY_DAMAGE; types = {Enum.DamageMeterType.DamageDone, Enum.DamageMeterType.Dps, Enum.DamageMeterType.DamageTaken, Enum.DamageMeterType.AvoidableDamageTaken, Enum.DamageMeterType.EnemyDamageTaken}; },
	{ name = DAMAGE_METER_CATEGORY_HEALING; types = {Enum.DamageMeterType.HealingDone, Enum.DamageMeterType.Hps }; },
	{ name = DAMAGE_METER_CATEGORY_ACTIONS; types = {Enum.DamageMeterType.Interrupts, Enum.DamageMeterType.Dispels, Enum.DamageMeterType.Deaths}; },
};

local DAMAGE_METER_TYPE_VALUE_PER_SECOND_AS_PRIMARY = {
	[Enum.DamageMeterType.Dps] = true,
	[Enum.DamageMeterType.Hps] = true,
};

local DAMAGE_METER_TYPE_ALWAYS_SHOWS_LOCAL_PLAYER = {
	[Enum.DamageMeterType.DamageDone] = true,
	[Enum.DamageMeterType.Dps] = true,
	[Enum.DamageMeterType.HealingDone] = true,
	[Enum.DamageMeterType.Hps] = true,
	[Enum.DamageMeterType.Absorbs] = true,
	[Enum.DamageMeterType.Interrupts] = true,
	[Enum.DamageMeterType.Dispels] = true,
	[Enum.DamageMeterType.DamageTaken] = true,
	[Enum.DamageMeterType.AvoidableDamageTaken] = true,
};

local DAMAGE_METER_TYPE_NAMES = {
	[Enum.DamageMeterType.DamageDone] = DAMAGE_METER_TYPE_DAMAGE_DONE,
	[Enum.DamageMeterType.Dps] = DAMAGE_METER_TYPE_DPS,
	[Enum.DamageMeterType.HealingDone] = DAMAGE_METER_TYPE_HEALING_DONE,
	[Enum.DamageMeterType.Hps] = DAMAGE_METER_TYPE_HPS,
	[Enum.DamageMeterType.Absorbs] = DAMAGE_METER_TYPE_ABSORBS,
	[Enum.DamageMeterType.Interrupts] = DAMAGE_METER_TYPE_INTERRUPTS,
	[Enum.DamageMeterType.Dispels] = DAMAGE_METER_TYPE_DISPELS,
	[Enum.DamageMeterType.DamageTaken] = DAMAGE_METER_TYPE_DAMAGE_TAKEN,
	[Enum.DamageMeterType.AvoidableDamageTaken] = DAMAGE_METER_TYPE_AVOIDABLE_DAMAGE_TAKEN,
	[Enum.DamageMeterType.Deaths] = DAMAGE_METER_TYPE_DEATHS,
	[Enum.DamageMeterType.EnemyDamageTaken] = DAMAGE_METER_TYPE_ENEMY_DAMAGE_TAKEN,
};

local function GetDamageMeterTypeName(damageMeterType)
	return DAMAGE_METER_TYPE_NAMES[damageMeterType] or "Unknown";
end

local DAMAGE_METER_SESSION_TYPE_SHORT_NAMES = {
	[Enum.DamageMeterSessionType.Overall] = DAMAGE_METER_OVERALL_SESSION_SHORT,
	[Enum.DamageMeterSessionType.Current] = DAMAGE_METER_CURRENT_SESSION_SHORT,
};

local function GetDamageMeterSessionShortName(sessionType, sessionID)
	if sessionType then
		return DAMAGE_METER_SESSION_TYPE_SHORT_NAMES[sessionType] or "?";
	end

	return sessionID or "?";
end

-- Some languages can't fit their short name into a single character.
local function HasLongSessionTypeShortNames()
	for _sessionType, shortName in pairs(DAMAGE_METER_SESSION_TYPE_SHORT_NAMES) do
		if shortName and #shortName > 1 then
			return true;
		end
	end

	return false;
end

local EDIT_MODE_SESSION =
{
	combatSources =
	{
		{ totalAmount = 100; name = DAMAGE_METER_EDIT_MODE_SOURCE_1; classFilename = "DEATHKNIGHT"; },
		{ totalAmount = 100; name = DAMAGE_METER_EDIT_MODE_SOURCE_2; classFilename = "MAGE"; },
		{ totalAmount = 80; name = DAMAGE_METER_EDIT_MODE_SOURCE_3; classFilename = "WARLOCK"; },
		{ totalAmount = 80; name = DAMAGE_METER_EDIT_MODE_SOURCE_7; classFilename = "HUNTER"; },
		{ totalAmount = 70; name = DAMAGE_METER_EDIT_MODE_SOURCE_6; classFilename = "DEMONHUNTER"; },
		{ totalAmount = 70; name = DAMAGE_METER_EDIT_MODE_SOURCE_4; classFilename = "SHAMAN"; },
		{ totalAmount = 50; name = DAMAGE_METER_EDIT_MODE_SOURCE_5; classFilename = "PALADIN"; },
	};
	maxAmount = 100;
};

DamageMeterSessionWindowMixin = {};

local DamageMeterSessionWindowMixinEvents = {
	"DAMAGE_METER_COMBAT_SESSION_UPDATED",
	"DAMAGE_METER_RESET",
	"DAMAGE_METER_CURRENT_SESSION_UPDATED",
};

function DamageMeterSessionWindowMixin:GetDamageMeterTypeDropdown()
	return self.DamageMeterTypeDropdown;
end

function DamageMeterSessionWindowMixin:GetDamageMeterTypeName()
	return self:GetDamageMeterTypeDropdown().TypeName;
end

function DamageMeterSessionWindowMixin:GetSessionDropdown()
	return self.SessionDropdown;
end

function DamageMeterSessionWindowMixin:GetSessionName()
	return self:GetSessionDropdown().SessionName;
end

function DamageMeterSessionWindowMixin:GetSettingsDropdown()
	return self.SettingsDropdown;
end

function DamageMeterSessionWindowMixin:GetSourceWindow()
	return self.SourceWindow;
end

function DamageMeterSessionWindowMixin:GetScrollBox()
	return self.ScrollBox;
end

function DamageMeterSessionWindowMixin:GetScrollBar()
	return self.ScrollBar;
end

function DamageMeterSessionWindowMixin:GetHeader()
	return self.Header;
end

function DamageMeterSessionWindowMixin:GetLocalPlayerEntry()
	return self.LocalPlayerEntry;
end

function DamageMeterSessionWindowMixin:GetResizeButton()
	return self.ResizeButton;
end

function DamageMeterSessionWindowMixin:GetBackground()
	return self.Background;
end

function DamageMeterSessionWindowMixin:GetNotActiveFontString()
	return self.NotActive;
end

function DamageMeterSessionWindowMixin:GetSessionTimerFontString()
	return self.SessionTimer;
end

function DamageMeterSessionWindowMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	self:InitializeScrollBox();
	self:InitializeDamageMeterTypeDropdown();
	self:InitializeSessionDropdown();
	self:InitializeResizeButton();
end

function DamageMeterSessionWindowMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DamageMeterSessionWindowMixinEvents);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterSessionWindowMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DamageMeterSessionWindowMixinEvents);

	self:HideSourceWindow();
end

function DamageMeterSessionWindowMixin:OnEvent(event, ...)
	if event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
		local type, sessionID = ...;
		if self:GetDamageMeterType() == type then
			-- Two events are always dispatched: one for the overall session (with no sessionID) and one for
			-- the current session with its sessionID. The window should only ever process one of them to avoid
			-- doing double work.
			if self:GetSessionID() == sessionID or (sessionID == 0 and self:GetSessionType() ~= nil) then
				self:Refresh(ScrollBoxConstants.RetainScrollPosition);
			end
		end
	elseif event == "DAMAGE_METER_RESET" then
		self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
	elseif event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
		if self:GetSessionType() == Enum.DamageMeterSessionType.Current then
			self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
		end
	end
end

function DamageMeterSessionWindowMixin:OnEnter()
	-- NOTE: This intentionally omits an OnLeave handler because the OnLeave processing is handled in the OnUpdate.
	self:SetOnUpdateReason("MouseOver", true);
end

function DamageMeterSessionWindowMixin:OnDragStart()
	if not self:CanMoveOrResize() then
		return;
	end

	self:StartMoving();
end

function DamageMeterSessionWindowMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function DamageMeterSessionWindowMixin:ShouldEnableOnUpdate()
	if self.onUpdateReasons then
		for _reason, enabled in pairs(self.onUpdateReasons) do
			if enabled then
				return true;
			end
		end
	end

	return false;
end

function DamageMeterSessionWindowMixin:IsUpdateReasonEnabled(reason)
	return self.onUpdateReasons and self.onUpdateReasons[reason];
end

function DamageMeterSessionWindowMixin:SetOnUpdateReason(reason, enabled)
	local onUpdateReasons = GetOrCreateTableEntry(self, "onUpdateReasons");
	onUpdateReasons[reason] = enabled;

	local hasOnUpdate = self:GetScript("OnUpdate") ~= nil;
	local shouldHaveOnUpdate = self:ShouldEnableOnUpdate();
	if hasOnUpdate ~= shouldHaveOnUpdate then
		if self:ShouldEnableOnUpdate() then
			self:SetScript("OnUpdate", self.OnUpdate);
		else
			self:SetScript("OnUpdate", nil);
		end
	end
end

-- Dynamically installed script handler for OnUpdate depending on reasons like "mouse over" or "has active session timer"
function DamageMeterSessionWindowMixin:OnUpdate()
	if self:IsUpdateReasonEnabled("MouseOver") then
		-- Handle showing the ResizeButton under the correct conditions.
		local resizeButton = self:GetResizeButton();
		local isMouseOver = self:IsMouseOver() or resizeButton:IsMouseOver() or self:IsResizing();
		local shouldResizeButtonBeShown = self:CanMoveOrResize();
		local shouldChangeBackgroundOpacity = not self:DoesCurrentStyleUseBackground();

		if isMouseOver and self.playedMouseOverAnims ~= true then
			self.playedMouseOverAnims = true;

			self.EmphasizeScrollBar:Play();

			if shouldResizeButtonBeShown then
				self.ShowResizeButton:Play();
			end

			if shouldChangeBackgroundOpacity then
				self.ShowBackground:Play();
			end
		elseif not isMouseOver then
			self.playedMouseOverAnims = false;

			local reverse = true;

			self.EmphasizeScrollBar:Play(reverse);

			if shouldResizeButtonBeShown then
				self.ShowResizeButton:Play(reverse);
			end

			if shouldChangeBackgroundOpacity then
				self.ShowBackground:Play(reverse);
			end

			self:SetOnUpdateReason("MouseOver", false);
		end
	end

	if self:IsUpdateReasonEnabled("SessionTimer") then
		local sessionType = self:GetSessionType();
		local sessionDuration = C_DamageMeter.GetSessionDurationSeconds(sessionType);
		self:SetSessionDuration(sessionDuration);
	end
end

function DamageMeterSessionWindowMixin:SetupEntry(frame)
	frame.hasBeenSetup = true;

	frame:SetUseClassColor(self:ShouldUseClassColor());
	frame:SetBarHeight(self:GetBarHeight());
	frame:SetTextScale(self:GetTextScale());
	frame:SetShowBarIcons(self:ShouldShowBarIcons());
	frame:SetStyle(self:GetStyle());
	frame:SetNumberDisplayType(self:GetNumberDisplayType());
	frame:SetBackgroundAlpha(self:GetBackgroundAlpha());
	frame:EnableMouse(not self:IsNonInteractive());

	-- For the existing implementation, clicks need to happen on mouse down because rebuilding the data
	-- provider with every change ends up hiding all frames and clearing their button state, meaning a
	-- mouse up might not happen.
	frame:RegisterForClicks("LeftButtonDown", "RightButtonDown");
end

function DamageMeterSessionWindowMixin:InitEntry(frame, elementData)
	frame:Init(elementData);

	frame:SetScript("OnClick", function(button, mouseButtonName)
		if mouseButtonName == "LeftButton" or mouseButtonName == "RightButton" then
			self:ShowSourceWindow(elementData);
		end
	end);
end

function DamageMeterSessionWindowMixin:InitializeScrollBoxPadding(view)
	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = self:GetBarSpacing();

	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
end

function DamageMeterSessionWindowMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSourceEntryTemplate", function(frame, elementData)
		self:InitEntry(frame, elementData);
	end);

	ScrollUtil.AddAcquiredFrameCallback(self:GetScrollBox(), function(o, frame, elementData, new)
		if not frame.hasBeenSetup then
			self:SetupEntry(frame);
		end
	end);

	ScrollUtil.AddReleasedFrameCallback(self:GetScrollBox(), function(o, frame, elementData)
		-- Settings can change while the frame isn't being used, so it needs to be setup once it's aquired again.
		frame.hasBeenSetup = false;
	end);

	self:InitializeScrollBoxPadding(view);
	ScrollUtil.InitScrollBoxListWithScrollBar(self:GetScrollBox(), self:GetScrollBar(), view);

	local topLeftX, topLeftY = 20, -5;
	local bottomRightX, bottomRightY = -22, 6;
	local withBarXOffset = 20;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self:GetHeader(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX - withBarXOffset, bottomRightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self:GetHeader(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX, bottomRightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self:GetScrollBox(), self:GetScrollBar(), scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);

	self:GetScrollBox():RegisterCallback(BaseScrollBoxEvents.OnScroll, self.OnScrollBoxScroll, self);
end

function DamageMeterSessionWindowMixin:InitializeDamageMeterTypeDropdown()
	local function IsSelected(option)
		return self:GetDamageMeterType() == option;
	end

	local function SetSelected(option)
		-- Damage meter type changes need to go through the owner.
		self:GetDamageMeterOwner():SetSessionWindowDamageMeterType(self, option);
	end

	local damageMeterTypeDropdown = self:GetDamageMeterTypeDropdown();

	damageMeterTypeDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_TRACKED_TYPE");

		for _i, categoryData in ipairs(DAMAGE_METER_CATEGORIES) do
			local categorySubmenu = rootDescription:CreateButton(categoryData.name);

			for _j, typeData in ipairs(categoryData.types) do
				categorySubmenu:CreateRadio(GetDamageMeterTypeName(typeData), IsSelected, SetSelected, typeData);
			end
		end
	end);
end

function DamageMeterSessionWindowMixin:InitializeSessionDropdown()
	local sessionDropdown = self:GetSessionDropdown();

	if HasLongSessionTypeShortNames() then
		sessionDropdown:SetWidth(sessionDropdown.longShortNameWidth);
	else
		sessionDropdown:SetWidth(sessionDropdown.shortShortNameWidth);
	end

	local function IsSelected(option)
		return self:GetSessionType() == option.type and self:GetSessionID() == option.sessionID;
	end

	local function SetSelected(option)
		-- Session changes need to go through the owner.
		self:GetDamageMeterOwner():SetSessionWindowSessionID(self, option.type, option.sessionID);
	end

	sessionDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_SESSIONS");

		local availableCombatSessions = C_DamageMeter.GetAvailableCombatSessions();
		for _i, availableCombatSession in ipairs(availableCombatSessions) do
			local sessionData = {type = nil; sessionID = availableCombatSession.sessionID; };
			local sessionName = availableCombatSession.name;
			if not availableCombatSession.name or availableCombatSession.name == "" then
				sessionName = DAMAGE_METER_COMBAT_NUMBER:format(availableCombatSession.sessionID);
			end

			if availableCombatSession.durationSeconds then
				sessionName = ("%s [%s]"):format(sessionName, SecondsToClock(availableCombatSession.durationSeconds));
			end

			rootDescription:CreateRadio(sessionName, IsSelected, SetSelected, sessionData);
		end

		rootDescription:CreateDivider();

		local currentSessionData = {type = Enum.DamageMeterSessionType.Current; sessionID = nil; };
		rootDescription:CreateRadio(DAMAGE_METER_CURRENT_SESSION, IsSelected, SetSelected, currentSessionData);

		local overallSessionData = {type = Enum.DamageMeterSessionType.Overall; sessionID = nil; };
		rootDescription:CreateRadio(DAMAGE_METER_OVERALL_SESSION, IsSelected, SetSelected, overallSessionData);
	end);
end

function DamageMeterSessionWindowMixin:InitializeSettingsDropdown()
	local function IsCreateNewSessionWindowEnabled()
		return self:GetDamageMeterOwner():CanShowNewSessionWindow();
	end

	local function IsDeleteSessionWindowEnabled()
		return self:GetDamageMeterOwner():CanHideSessionWindow(self);
	end

	local function CanLockSessionWindow()
		return self:GetDamageMeterOwner():CanMoveOrResizeSessionWindow(self) and not self:IsLocked();
	end

	local function CanUnlockSessionWindow()
		return self:GetDamageMeterOwner():CanMoveOrResizeSessionWindow(self) and self:IsLocked();
	end

	local function CanMakeSessionWindowNonInteractive()
		return not self:IsNonInteractive();
	end

	local function CanMakeSessionWindowInteractive()
		return self:IsNonInteractive();
	end

	self:GetSettingsDropdown():SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_SETTINGS");

		rootDescription:CreateButton(DAMAGE_METER_OPEN_SETTINGS, function(...)
			Settings.OpenToCategory(Settings.ADVANCED_OPTIONS_CATEGORY_ID);
		end);

		rootDescription:CreateButton(DAMAGE_METER_OPEN_EDIT_MODE, function(...)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ShowUIPanel(EditModeManagerFrame);
		end);

		rootDescription:CreateSpacer();

		if CanLockSessionWindow() then
			rootDescription:CreateButton(DAMAGE_METER_LOCK_WINDOW, function(...)
				self:GetDamageMeterOwner():SetSessionWindowLocked(self, true);
			end);
		end

		if CanUnlockSessionWindow() then
			rootDescription:CreateButton(DAMAGE_METER_UNLOCK_WINDOW, function(...)
				self:GetDamageMeterOwner():SetSessionWindowLocked(self, false);
			end);
		end

		if CanMakeSessionWindowNonInteractive() then
			rootDescription:CreateButton(DAMAGE_METER_MAKE_UNINTERACTABLE, function(...)
				self:GetDamageMeterOwner():SetSessionWindowNonInteractive(self, true);
			end);
		end

		if CanMakeSessionWindowInteractive() then
			rootDescription:CreateButton(DAMAGE_METER_MAKE_INTERACTABLE, function(...)
				self:GetDamageMeterOwner():SetSessionWindowNonInteractive(self, false);
			end);
		end

		rootDescription:CreateButton(DAMAGE_METER_RESET_ALL_SESSIONS, function(...)
			C_DamageMeter.ResetAllCombatSessions();
		end);

		local deleteSessionWindowButton = rootDescription:CreateButton(DAMAGE_METER_HIDE_WINDOW, function(...)
			self:GetDamageMeterOwner():HideSessionWindow(self);
		end);
		deleteSessionWindowButton:SetEnabled(IsDeleteSessionWindowEnabled)

		rootDescription:CreateSpacer();

		local createNewSessionWindowButton = rootDescription:CreateButton(DAMAGE_METER_SHOW_NEW_WINDOW, function(...)
			self:GetDamageMeterOwner():ShowNewSessionWindow();
		end);
		createNewSessionWindowButton:SetEnabled(IsCreateNewSessionWindowEnabled);
	end);
end

function DamageMeterSessionWindowMixin:InitializeResizeButton()
	local resizeButton = self:GetResizeButton();

	resizeButton:SetScript("OnMouseDown", function(button, mouseButtonName, _down)
		if not self:CanMoveOrResize() then
			return;
		end

		if mouseButtonName == "LeftButton" then
			button:SetButtonState("PUSHED", true);
			button:GetHighlightTexture():Hide();
			self:StartSizing("BOTTOMRIGHT");
			self.isResizing = true;
		end
	end);

	resizeButton:SetScript("OnMouseUp", function(button, mouseButtonName, _down)
		if mouseButtonName == "LeftButton" then
			button:SetButtonState("NORMAL", false);
			button:GetHighlightTexture():Show();
			self:StopMovingOrSizing();
			self.isResizing = false;
		end
	end);

	resizeButton:SetScript("OnEnter", function()
		self:OnEnter();
	end);
end

function DamageMeterSessionWindowMixin:GetCombatSession()
	if self:IsEditing() then
		return EDIT_MODE_SESSION;
	end

	local damageMeterType = self:GetDamageMeterType();

	local sessionType = self:GetSessionType();
	if sessionType then
		return C_DamageMeter.GetCombatSessionFromType(sessionType, damageMeterType);
	end

	local sessionID = self:GetSessionID();
	if sessionID then
		return C_DamageMeter.GetCombatSessionFromID(sessionID, damageMeterType);
	end

	return nil;
end

function DamageMeterSessionWindowMixin:ShowsValuePerSecondAsPrimary()
	local damageMeterType = self:GetDamageMeterType();
	return DAMAGE_METER_TYPE_VALUE_PER_SECOND_AS_PRIMARY[damageMeterType];
end

function DamageMeterSessionWindowMixin:AlwaysShowsLocalPlayer()
	local damageMeterType = self:GetDamageMeterType();
	return DAMAGE_METER_TYPE_ALWAYS_SHOWS_LOCAL_PLAYER[damageMeterType];
end

function DamageMeterSessionWindowMixin:BuildDataProvider(combatSession)
	combatSession = combatSession or self:GetCombatSession();

	local sourceWindow = self:GetSourceWindow();
	local dataProvider = CreateDataProvider();
	local combatSources = combatSession and combatSession.combatSources or {};
	local maxAmount = combatSession and combatSession.maxAmount or 0;
	local sessionTotalAmount = combatSession and combatSession.totalAmount or 0;
	local hadLocalPlayerIndex = self.localPlayerIndex ~= nil;
	local showsValuePerSecondAsPrimary = self:ShowsValuePerSecondAsPrimary();
	local alwaysShowsLocalPlayer = self:AlwaysShowsLocalPlayer();
	local damageMeterType = self:GetDamageMeterType();

	self.localPlayerIndex = nil;
	self.needsSourceWindowRefresh = false;

	for i, combatSource in ipairs(combatSources) do
		if combatSource.isLocalPlayer and alwaysShowsLocalPlayer then
			self.localPlayerIndex = i;
		end

		-- Determine if the source window is currently showing for this source and if its data is stale.
		if sourceWindow:IsShowingSource(combatSource) then
			-- Changes in the total amount need to be reflected in the source window.
			if combatSource.totalAmount ~= sourceWindow:GetTotalAmount() then
				self.needsSourceWindowRefresh = true;
			-- For the time-bound displays, any changes in overall data need to be reflected in the
			-- source window so it stays in sync with the source entry in the session window.
			elseif showsValuePerSecondAsPrimary then
				self.needsSourceWindowRefresh = true;
			end
		end

		combatSource.maxAmount = maxAmount;
		combatSource.sessionTotalAmount = sessionTotalAmount;
		combatSource.index = i;
		combatSource.showsValuePerSecondAsPrimary = showsValuePerSecondAsPrimary;
		combatSource.damageMeterType = damageMeterType;

		dataProvider:Insert(combatSource);
	end

	if hadLocalPlayerIndex and self.localPlayerIndex == nil then
		self:HideLocalPlayerEntry();
	end

	return dataProvider;
end

function DamageMeterSessionWindowMixin:ShowLocalPlayerEntry(earlierInList)
	local scrollBox = self:GetScrollBox();
	local elementData = scrollBox:FindElementData(self.localPlayerIndex);

	local localPlayerEntry = self:GetLocalPlayerEntry();
	self:SetupEntry(localPlayerEntry);
	self:InitEntry(localPlayerEntry, elementData);

	localPlayerEntry:ClearAllPoints();
	if earlierInList then
		localPlayerEntry:SetPoint("TOPLEFT", scrollBox, "TOPLEFT", 0, 4);
		localPlayerEntry:SetPoint("TOPRIGHT", scrollBox, "TOPRIGHT", 0, 4);
	else
		localPlayerEntry:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMLEFT", 0, -4);
		localPlayerEntry:SetPoint("BOTTOMRIGHT", scrollBox, "BOTTOMRIGHT", 0, -4);
	end

	localPlayerEntry:Show();
end

function DamageMeterSessionWindowMixin:HideLocalPlayerEntry()
	self:GetLocalPlayerEntry():Hide();
end

function DamageMeterSessionWindowMixin:EnsureLocalPlayerPresent()
	if not self.localPlayerIndex then
		return;
	end

	local scrollBox = self:GetScrollBox();
	local extentToLocalPlayer = scrollBox:GetExtentUntil(self.localPlayerIndex);
	local scrollOffset = scrollBox:GetDerivedScrollOffset();
	local visibleExtent = scrollBox:GetVisibleExtent();

	if extentToLocalPlayer < scrollOffset then
		local earlierInList = true;
		self:ShowLocalPlayerEntry(earlierInList);
	elseif extentToLocalPlayer > scrollOffset + visibleExtent then
		local earlierInList = false;
		self:ShowLocalPlayerEntry(earlierInList);
	else
		self:HideLocalPlayerEntry();
	end
end

function DamageMeterSessionWindowMixin:EnsureSourceWindowUpToDate()
	if not self.needsSourceWindowRefresh then
		return;
	end

	self.needsSourceWindowRefresh = false;

	self:GetSourceWindow():Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSessionWindowMixin:UpdateNotActiveText()
	if self:GetDamageMeterType() == Enum.DamageMeterType.AvoidableDamageTaken and self:GetScrollBox():GetDataProvider():IsEmpty() then
		self:GetNotActiveFontString():SetText(DAMAGE_METER_AVOIDABLE_DAMAGE_NOT_ACTIVE);
	else
		self:GetNotActiveFontString():SetText(nil);
	end
end

function DamageMeterSessionWindowMixin:OnScrollBoxScroll()
	self:EnsureLocalPlayerPresent();
end

function DamageMeterSessionWindowMixin:UpdateExistingDataProvider(dataProvider)
	local currentProvider = self:GetScrollBox():GetDataProvider();
	if not currentProvider then
		return false;
	end

	if currentProvider:GetSize() ~= dataProvider:GetSize() then
		return false;
	end

	-- It's important to leave the collection the same, but the values of each item in the collection
	-- can be updated, as long as the frames to which the elements are attached are updated with
	-- the new values.
	for i = 1, currentProvider:GetSize() do
		-- This could use SetTablePairsToTable in the future, but if so check for self assignment
		-- so the table isn't wiped. It's possible that the new and old elements are pointers to
		-- the same element.
		Mixin(currentProvider.collection[i], dataProvider.collection[i]);
	end

	self:GetScrollBox():ForEachFrame(function(frame)
		local elementData = currentProvider:Find(frame:GetOrderIndex());
		self:InitEntry(frame, elementData);
	end);

	return true;
end

function DamageMeterSessionWindowMixin:Refresh(retainScrollPosition)
	local combatSession = self:GetCombatSession();
	local dataProvider = self:BuildDataProvider(combatSession);

	-- Only completely rebuild the data provider if necessary. Avoid rebuilding it on basic updates
	-- to the internal data as that results in a lot of unnecessary work.
	if not retainScrollPosition or not self:UpdateExistingDataProvider(dataProvider) then
		self:GetScrollBox():SetDataProvider(dataProvider, retainScrollPosition);
	end

	self:EnsureLocalPlayerPresent();
	self:EnsureSourceWindowUpToDate();
	self:UpdateNotActiveText();
	self:UpdateSessionTimerState(combatSession);
end

function DamageMeterSessionWindowMixin:EnumerateEntryFrames()
	return self:GetScrollBox():EnumerateFrames();
end

function DamageMeterSessionWindowMixin:ForEachEntryFrame(func, ...)
	for _index, frame in self:EnumerateEntryFrames() do
		func(frame, ...);
	end
end

function DamageMeterSessionWindowMixin:GetEntryFrameCount()
	return self:GetScrollBox():GetFrameCount();
end

function DamageMeterSessionWindowMixin:SetDamageMeterOwner(damageMeterOwner, sessionWindowIndex)
	self.damageMeterOwner = damageMeterOwner;
	self.sessionWindowIndex = sessionWindowIndex;

	self:InitializeSettingsDropdown();
end

function DamageMeterSessionWindowMixin:GetDamageMeterOwner()
	return self.damageMeterOwner;
end

function DamageMeterSessionWindowMixin:GetSessionWindowIndex()
	return self.sessionWindowIndex;
end

-- To keep the window, owner, and persistent data in sync this shouldn't be called directly by
-- any code other than DamageMeterMixin:SetSessionWindowDamageMeterType
function DamageMeterSessionWindowMixin:SetDamageMeterType(damageMeterType)
	self.damageMeterType = damageMeterType;

	self:GetDamageMeterTypeName():SetText(GetDamageMeterTypeName(damageMeterType));

	self:GetSourceWindow():SetDamageMeterType(damageMeterType);

	-- Changes to the damage meter type should always hide the source window.
	self:HideSourceWindow();

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterSessionWindowMixin:GetDamageMeterType()
	return self.damageMeterType;
end

-- To keep the window, owner, and persistent data in sync this shouldn't be called directly by
-- any code other than DamageMeterMixin:SetSessionWindowSessionID
function DamageMeterSessionWindowMixin:SetSession(sessionType, sessionID)
	self.sessionType = sessionType;
	self.sessionID = sessionID;

	self:GetSessionName():SetText(GetDamageMeterSessionShortName(sessionType, sessionID));

	self:GetSourceWindow():SetSession(sessionType, sessionID);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterSessionWindowMixin:GetSessionType()
	return self.sessionType;
end

function DamageMeterSessionWindowMixin:GetSessionID()
	return self.sessionID;
end

function DamageMeterSessionWindowMixin:IsResizing()
	return self.isResizing;
end

-- To keep the window, owner, and persistent data in sync this shouldn't be called directly by
-- any code other than DamageMeterMixin:SetSessionWindowLocked
function DamageMeterSessionWindowMixin:SetLocked(locked)
	self.isLocked = locked;

	self:InitializeSettingsDropdown();
end

function DamageMeterSessionWindowMixin:IsLocked()
	return self.isLocked;
end

function DamageMeterSessionWindowMixin:IsNonInteractive()
	return self.isNonInteractive;
end

function DamageMeterSessionWindowMixin:SetNonInteractive(nonInteractive)
	if nonInteractive ~= self:IsNonInteractive() then
		self.isNonInteractive = nonInteractive;
		self:InitializeSettingsDropdown();

		local enabled = not nonInteractive;
		self:EnableMouse(enabled);
		self:GetSessionDropdown():EnableMouse(enabled);
		self:GetDamageMeterTypeDropdown():EnableMouse(enabled);
		self:GetResizeButton():EnableMouse(enabled);

		self:ForEachEntryFrame(function(frame) frame:EnableMouse(enabled); end);
	end
end

function DamageMeterSessionWindowMixin:CanMoveOrResize()
	if not self:GetDamageMeterOwner():CanMoveOrResizeSessionWindow(self) then
		return false;
	end

	if self:IsLocked() then
		return false;
	end

	return true;
end

function DamageMeterSessionWindowMixin:RefreshLayout()
	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

-- Returns whether or not to display a session timer and if that session timer needs to be updated each frame.
local function ShouldDisplaySessionTimer(sessionType, sessionID, inCombat)
	if (not sessionType and sessionID) or sessionType == Enum.DamageMeterSessionType.Expired then
		return true, false;
	end

	return inCombat, true;
end

function DamageMeterSessionWindowMixin:IsPlayerInCombat()
	local isInCombat = UnitAffectingCombat("player");
	return isInCombat;
end

function DamageMeterSessionWindowMixin:SetSessionDuration(durationSeconds)
	if durationSeconds and durationSeconds ~= 0 then
		local timerText = ("[%s] "):format(SecondsToClock(durationSeconds));
		self:GetSessionTimerFontString():SetText(timerText);
	else
		self:GetSessionTimerFontString():SetText("");
	end
end

function DamageMeterSessionWindowMixin:ShowSessionTimerFromCombatSession(combatSession)
	local durationSeconds = combatSession and combatSession.durationSeconds;
	self:SetSessionDuration(durationSeconds);
end

function DamageMeterSessionWindowMixin:ShowSessionTimer(needsOnUpdate, combatSession)
	self:ClearSessionTimer();
	self:ShowSessionTimerFromCombatSession(combatSession);
	self:SetOnUpdateReason("SessionTimer", needsOnUpdate);
end

function DamageMeterSessionWindowMixin:ClearSessionTimer()
	self:SetOnUpdateReason("SessionTimer", false);
	self:GetSessionTimerFontString():SetText("");
end

function DamageMeterSessionWindowMixin:UpdateSessionTimerState(combatSession)
	combatSession = combatSession or self:GetCombatSession();
	local sessionType = self:GetSessionType();
	local sessionID = self:GetSessionID();
	local inCombat = self:IsPlayerInCombat();
	local showTimer, needsTimerUpdate = ShouldDisplaySessionTimer(sessionType, sessionID, inCombat);
	if showTimer then
		self:ShowSessionTimer(needsTimerUpdate, combatSession);
	else
		self:ClearSessionTimer();
	end
end

function DamageMeterSessionWindowMixin:ShowSourceWindow(source)
	-- Leverage the death recap UI to show death breakdown.
	if source.deathRecapID and source.deathRecapID ~= 0 then
		OpenDeathRecapUI(source.deathRecapID);
		return;
	end

	local sourceWindow = self:GetSourceWindow();
	sourceWindow:SetSource(source);
	sourceWindow:AnchorToSessionWindow(self);
	sourceWindow:Show();
end

function DamageMeterSessionWindowMixin:HideSourceWindow()
	self:GetSourceWindow():Hide();
end

function DamageMeterSessionWindowMixin:SetIsEditing(isEditing)
	self.isEditing = isEditing;

	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSessionWindowMixin:IsEditing()
	return self.isEditing;
end

function DamageMeterSessionWindowMixin:OnUseClassColorChanged(useClassColor)
	self:GetScrollBox():ForEachFrame(function(frame) frame:SetUseClassColor(useClassColor); end);

	self:GetSourceWindow():SetUseClassColor(useClassColor);
end

function DamageMeterSessionWindowMixin:ShouldUseClassColor()
	return self.useClassColor;
end

function DamageMeterSessionWindowMixin:SetUseClassColor(useClassColor)
	if self.useClassColor ~= useClassColor then
		self.useClassColor = useClassColor;
		self:OnUseClassColorChanged(useClassColor);
	end
end

function DamageMeterSessionWindowMixin:OnBarHeightChanged(barHeight)
	self:GetScrollBox():GetView():SetElementExtent(barHeight);
	self:GetSourceWindow():SetBarHeight(barHeight);
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSessionWindowMixin:GetBarHeight()
	return self.barHeight or DAMAGE_METER_DEFAULT_BAR_HEIGHT;
end

function DamageMeterSessionWindowMixin:SetBarHeight(barHeight)
	if not ApproximatelyEqual(self:GetBarHeight(), barHeight) then
		self.barHeight = barHeight;
		self:OnBarHeightChanged(barHeight);
	end
end

function DamageMeterSessionWindowMixin:OnTextScaleChanged(textScale)
	self:GetScrollBox():ForEachFrame(function(frame) frame:SetTextScale(textScale); end);
	self:GetSourceWindow():SetTextScale(textScale);
end

function DamageMeterSessionWindowMixin:GetTextScale()
	return self.textScale or 1;
end

function DamageMeterSessionWindowMixin:SetTextScale(textScale)
	if not ApproximatelyEqual(self:GetTextScale(), textScale) then
		self.textScale = textScale;
		self:OnTextScaleChanged(textScale);
	end
end

function DamageMeterSessionWindowMixin:OnShowBarIconsChanged(showBarIcons)
	self:ForEachEntryFrame(function(frame) frame:SetShowBarIcons(showBarIcons); end);
	self:GetSourceWindow():SetShowBarIcons(showBarIcons);
end

function DamageMeterSessionWindowMixin:ShouldShowBarIcons()
	return self.showBarIcons;
end

function DamageMeterSessionWindowMixin:SetShowBarIcons(showBarIcons)
	if self.showBarIcons ~= showBarIcons then
		self.showBarIcons = showBarIcons;
		self:OnShowBarIconsChanged(showBarIcons);
	end
end

function DamageMeterSessionWindowMixin:OnBarSpacingChanged(spacing)
	self:GetSourceWindow():SetBarSpacing(spacing);
	self:InitializeScrollBoxPadding(self:GetScrollBox():GetView());
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSessionWindowMixin:GetBarSpacing()
	return self.barSpacing or DAMAGE_METER_DEFAULT_BAR_SPACING;
end

function DamageMeterSessionWindowMixin:SetBarSpacing(spacing)
	if self.barSpacing ~= spacing then
		self.barSpacing = spacing;
		self:OnBarSpacingChanged(spacing);
	end
end

function DamageMeterSessionWindowMixin:OnStyleChanged(style)
	self:ForEachEntryFrame(function(frame) frame:SetStyle(style); end);
	self:GetSourceWindow():SetStyle(style);
	self:UpdateBackground();
end

function DamageMeterSessionWindowMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterSessionWindowMixin:SetStyle(style)
	if self.style ~= style then
		self.style = style;
		self:OnStyleChanged(style);
	end
end

function DamageMeterSessionWindowMixin:OnNumberDisplayTypeChanged(numberDisplayType)
	self:ForEachEntryFrame(function(frame) frame:SetNumberDisplayType(numberDisplayType); end);
end

function DamageMeterSessionWindowMixin:GetNumberDisplayType()
	return self.numberDisplayType or Enum.DamageMeterNumbers.Minimal;
end

function DamageMeterSessionWindowMixin:SetNumberDisplayType(numberDisplayType)
	if self.numberDisplayType ~= numberDisplayType then
		self.numberDisplayType = numberDisplayType;
		self:OnNumberDisplayTypeChanged(numberDisplayType);
	end
end

function DamageMeterSessionWindowMixin:OnBackgroundAlphaChanged(alpha)
	self:ForEachEntryFrame(function(frame) frame:SetBackgroundAlpha(alpha); end);
	self:GetSourceWindow():SetBackgroundAlpha(alpha);
	self:UpdateBackground();
end

function DamageMeterSessionWindowMixin:GetBackgroundAlpha()
	return self.backgroundAlpha or 1;
end

function DamageMeterSessionWindowMixin:SetBackgroundAlpha(alpha)
	if not ApproximatelyEqual(self:GetBackgroundAlpha(), alpha) then
		self.backgroundAlpha = alpha;
		self:OnBackgroundAlphaChanged(alpha);
	end
end

function DamageMeterSessionWindowMixin:DoesCurrentStyleUseBackground()
	-- return self:GetStyle() == Enum.DamageMeterStyle.FullBackground;
	return true;
end

function DamageMeterSessionWindowMixin:UpdateBackground()
	if self:DoesCurrentStyleUseBackground() then
		self:GetBackground():SetAlpha(self:GetBackgroundAlpha());
	else
		self:GetBackground():SetAlpha(0);
	end
end
