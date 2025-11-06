local DAMAGE_METER_CATEGORIES = {
	{ name = DAMAGE_METER_CATEGORY_DAMAGE; types = {Enum.DamageMeterType.DamageDone, Enum.DamageMeterType.Dps}; },
	{ name = DAMAGE_METER_CATEGORY_HEALING; types = {Enum.DamageMeterType.HealingDone, Enum.DamageMeterType.Hps}; },
	{ name = DAMAGE_METER_CATEGORY_ACTIONS; types = {Enum.DamageMeterType.Interrupts, Enum.DamageMeterType.Dispels}; },
};

local DAMAGE_METER_TYPE_NAMES = {
	[Enum.DamageMeterType.DamageDone] = DAMAGE_METER_TYPE_DAMAGE_DONE,
	[Enum.DamageMeterType.Dps] = DAMAGE_METER_TYPE_DPS,
	[Enum.DamageMeterType.HealingDone] = DAMAGE_METER_TYPE_HEALING_DONE,
	[Enum.DamageMeterType.Hps] = DAMAGE_METER_TYPE_HPS,
	[Enum.DamageMeterType.Interrupts] = DAMAGE_METER_TYPE_INTERRUPTS,
	[Enum.DamageMeterType.Dispels] = DAMAGE_METER_TYPE_DISPELS,
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

DamageMeterWindowMixin = {};

local DamageMeterWindowListEvents = {
	"DAMAGE_METER_COMBAT_SESSION_UPDATED",
	"DAMAGE_METER_RESET",
};

function DamageMeterWindowMixin:GetTrackedStatDropdown()
	return self.TrackedStatDropdown;
end

function DamageMeterWindowMixin:GetTrackedStatName()
	return self:GetTrackedStatDropdown().StatName;
end

function DamageMeterWindowMixin:GetSessionDropdown()
	return self.SessionDropdown;
end

function DamageMeterWindowMixin:GetSessionName()
	return self:GetSessionDropdown().SessionName;
end

function DamageMeterWindowMixin:GetSettingsDropdown()
	return self.SettingsDropdown;
end

function DamageMeterWindowMixin:GetUnitBreakdownFrame()
	return self.UnitBreakdownFrame;
end

function DamageMeterWindowMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	self:InitializeScrollBox();
	self:InitializeTrackedStatDropdown();
	self:InitializeSessionDropdown();
	self:InitializeSettingsDropdown();
	self:InitializeResizeButton();
end

function DamageMeterWindowMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DamageMeterWindowListEvents);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterWindowMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DamageMeterWindowListEvents);

	self:HideBreakdownFrame();
end

function DamageMeterWindowMixin:OnEvent(event, ...)
	if event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
		local type, sessionID = ...;
		if self:GetTrackedStat() == type then
			if self:GetSessionID() == sessionID or self:GetSessionType() ~= nil then
				self:Refresh(ScrollBoxConstants.RetainScrollPosition);
			end
		end
	elseif event == "DAMAGE_METER_RESET" then
		self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
	end
end

function DamageMeterWindowMixin:OnEnter()
	-- Handle showing the ResizeButton under the correct conditions.
	self:SetScript("OnUpdate", function()
		local shouldResizeButtonBeShown = self:IsMouseOver() or self.ResizeButton:IsMouseOver() or self:IsResizing();

		if shouldResizeButtonBeShown and self.ResizeButton:GetAlpha() == 0 then
			self.HideResizeButton:Stop();
			self.ShowResizeButton:Play();
		elseif not shouldResizeButtonBeShown and self.ResizeButton:GetAlpha() > 0 then
			self.ShowResizeButton:Stop();
			self.HideResizeButton:Play();
		end
	end);
end

function DamageMeterWindowMixin:OnDragStart()
	self:StartMoving();
end

function DamageMeterWindowMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function DamageMeterWindowMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSourceEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
		frame:SetUseClassColor(self:ShouldUseClassColor());
		frame:SetBarHeight(self:GetBarHeight());
		frame:SetTextScale(self:GetTextScale());
		frame:SetShowBarIcons(self:ShouldShowBarIcons());
		frame:SetStyle(self:GetStyle());
		frame:RegisterForClicks("RightButtonUp");

		frame:SetScript("OnClick", function(button, mouseButtonName)
			if mouseButtonName == "RightButton" then
				self:ShowBreakdownFrame(elementData);
			end
		end);
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 4;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local topLeftX, topLeftY = 20, -5;
	local bottomRightX, bottomRightY = -22, 6;
	local withBarXOffset = 20;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self.Header, "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX - withBarXOffset, bottomRightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self.Header, "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX, bottomRightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function DamageMeterWindowMixin:InitializeTrackedStatDropdown()
	local function IsSelected(option)
		return self:GetTrackedStat() == option;
	end

	local function SetSelected(option)
		-- Tracked stat changes need to go through the owner.
		self:GetDamageMeterOwner():SetWindowFrameTrackedStat(self, option);
	end

	self:GetTrackedStatDropdown():SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_TRACKED_TYPE");

		for _i, categoryData in ipairs(DAMAGE_METER_CATEGORIES) do
			local categorySubmenu = rootDescription:CreateButton(categoryData.name);

			for _j, typeData in ipairs(categoryData.types) do
				categorySubmenu:CreateRadio(GetDamageMeterTypeName(typeData), IsSelected, SetSelected, typeData);
			end
		end
	end);

	-- Override Arrow positioning from the template.
	self.TrackedStatDropdown.Arrow:ClearAllPoints();
	self.TrackedStatDropdown.Arrow:SetPoint("LEFT", self.TrackedStatDropdown, "LEFT", 0, -2);
end

function DamageMeterWindowMixin:InitializeSessionDropdown()
	local function IsSelected(option)
		return self:GetSessionType() == option.type and self:GetSessionID() == option.sessionID;
	end

	local function SetSelected(option)
		-- Session changes need to go through the owner.
		self:GetDamageMeterOwner():SetWindowFrameSession(self, option.type, option.sessionID);
	end

	self:GetSessionDropdown():SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_SESSIONS");

		local availableCombatSessions = C_DamageMeter.GetAvailableCombatSessions();
		for _i, availableCombatSession in ipairs(availableCombatSessions) do
			local sessionData = {type = nil; sessionID = availableCombatSession.sessionID; };

			rootDescription:CreateRadio("PH - Unnamed Segment", IsSelected, SetSelected, sessionData);
		end

		rootDescription:CreateDivider();

		local currentSessionData = {type = Enum.DamageMeterSessionType.Current; sessionID = nil; };
		rootDescription:CreateRadio(DAMAGE_METER_CURRENT_SESSION, IsSelected, SetSelected, currentSessionData);

		local overallSessionData = {type = Enum.DamageMeterSessionType.Overall; sessionID = nil; };
		rootDescription:CreateRadio(DAMAGE_METER_OVERALL_SESSION, IsSelected, SetSelected, overallSessionData);
	end);
end

function DamageMeterWindowMixin:InitializeSettingsDropdown()
	local function IsCreateNewWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanShowNewWindowFrame();
	end

	local function IsDeleteWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanHideWindowFrame(self);
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

		rootDescription:CreateButton(DAMAGE_METER_RESET_ALL_SESSIONS, function(...)
			C_DamageMeter.ResetAllCombatSessions();
		end);

		local deleteWindowFrameButton = rootDescription:CreateButton(DAMAGE_METER_HIDE_WINDOW, function(...)
			self:GetDamageMeterOwner():HideWindowFrame(self);
		end);
		deleteWindowFrameButton:SetEnabled(IsDeleteWindowFrameEnabled)

		rootDescription:CreateSpacer();

		local createNewWindowFrameButton = rootDescription:CreateButton(DAMAGE_METER_SHOW_NEW_WINDOW, function(...)
			self:GetDamageMeterOwner():ShowNewWindowFrame();
		end);
		createNewWindowFrameButton:SetEnabled(IsCreateNewWindowFrameEnabled);
	end);
end

function DamageMeterWindowMixin:InitializeResizeButton()
		self.ResizeButton:SetScript("OnMouseDown", function(button, mouseButtonName, _down)
			if mouseButtonName == "LeftButton" then
				button:SetButtonState("PUSHED", true);
				button:GetHighlightTexture():Hide();
				self:StartSizing("BOTTOMRIGHT");
				self.isResizing = true;
			end
		end);

		self.ResizeButton:SetScript("OnMouseUp", function(button, mouseButtonName, _down)
			if mouseButtonName == "LeftButton" then
				button:SetButtonState("NORMAL", false);
				button:GetHighlightTexture():Show();
				self:StopMovingOrSizing();
				self.isResizing = false;
			end
		end);

		self.ResizeButton:SetScript("OnEnter", function()
			self:OnEnter();
		end);
end

function DamageMeterWindowMixin:GetCombatSession()
	local trackedStat = self:GetTrackedStat();

	local sessionType = self:GetSessionType();
	if sessionType then
		return C_DamageMeter.GetCombatSessionFromType(sessionType, trackedStat);
	end

	local sessionID = self:GetSessionID();
	if sessionID then
		return C_DamageMeter.GetCombatSessionFromID(sessionID, trackedStat);
	end

	return nil;
end

function DamageMeterWindowMixin:BuildDataProvider()
	local dataProvider = CreateDataProvider();

	local combatSession = self:GetCombatSession();
	local combatSources = combatSession and combatSession.combatSources or {};
	local maxAmount = combatSession and combatSession.maxAmount or 0;

	for i, combatSource in ipairs(combatSources) do
		combatSource.maxAmount = maxAmount;
		combatSource.index = i;

		dataProvider:Insert(combatSource);
	end

	return dataProvider;
end

function DamageMeterWindowMixin:Refresh(retainScrollPosition)
	self.ScrollBox:SetDataProvider(self:BuildDataProvider(), retainScrollPosition);
end

function DamageMeterWindowMixin:EnumerateEntryFrames()
	return self.ScrollBox:EnumerateFrames();
end

function DamageMeterWindowMixin:ForEachEntryFrame(func, ...)
	for _index, frame in self:EnumerateEntryFrames() do
		func(frame, ...);
	end
end

function DamageMeterWindowMixin:GetEntryFrameCount()
	return self.ScrollBox:GetFrameCount();
end

function DamageMeterWindowMixin:SetDamageMeterOwner(damageMeterOwner, windowFrameIndex)
	self.damageMeterOwner = damageMeterOwner;
	self.windowFrameIndex = windowFrameIndex;
end

function DamageMeterWindowMixin:GetDamageMeterOwner()
	return self.damageMeterOwner;
end

function DamageMeterWindowMixin:GetWindowFrameIndex()
	return self.windowFrameIndex;
end

-- To keep the window, owner, and persistent data in sync this shouldn't be called directly by
-- any code other than DamageMeterMixin:SetWindowFrameTrackedStat
function DamageMeterWindowMixin:SetTrackedStat(trackedStat)
	self.trackedStat = trackedStat;

	self:GetTrackedStatName():SetText(GetDamageMeterTypeName(trackedStat));

	self:GetUnitBreakdownFrame():SetTrackedStat(trackedStat);

	-- Changes to the tracked stat should always hide the breakdown frame.
	self:HideBreakdownFrame();

	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterWindowMixin:GetTrackedStat()
	return self.trackedStat;
end

-- To keep the window, owner, and persistent data in sync this shouldn't be called directly by
-- any code other than DamageMeterMixin:SetWindowFrameSession
function DamageMeterWindowMixin:SetSession(sessionType, sessionID)
	self.sessionType = sessionType;
	self.sessionID = sessionID;

	self:GetSessionName():SetText(GetDamageMeterSessionShortName(sessionType, sessionID));

	self:GetUnitBreakdownFrame():SetSession(sessionType, sessionID);

	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterWindowMixin:GetSessionType()
	return self.sessionType;
end

function DamageMeterWindowMixin:GetSessionID()
	return self.sessionID;
end

function DamageMeterWindowMixin:IsResizing()
	return self.isResizing == true;
end

function DamageMeterWindowMixin:RefreshLayout()

end

function DamageMeterWindowMixin:ShowBreakdownFrame(source)
	local unitBreakdownFrame = self:GetUnitBreakdownFrame();
	unitBreakdownFrame:SetSource(source);
	unitBreakdownFrame:AnchorToWindow(self);
	unitBreakdownFrame:Show();
end

function DamageMeterWindowMixin:HideBreakdownFrame()
	self:GetUnitBreakdownFrame():Hide();
end

function DamageMeterWindowMixin:OnUseClassColorChanged(useClassColor)
	self.ScrollBox:ForEachFrame(function(frame) frame:SetUseClassColor(useClassColor); end);

	self:GetUnitBreakdownFrame():SetUseClassColor(useClassColor);
end

function DamageMeterWindowMixin:ShouldUseClassColor()
	return self.useClassColor == true;
end

function DamageMeterWindowMixin:SetUseClassColor(useClassColor)
	useClassColor = (useClassColor == true);

	if self.useClassColor ~= useClassColor then
		self.useClassColor = useClassColor;
		self:OnUseClassColorChanged(useClassColor);
	end
end

function DamageMeterWindowMixin:OnBarHeightChanged(barHeight)
	self.ScrollBox:GetView():SetElementExtent(barHeight);
	self:GetUnitBreakdownFrame():SetBarHeight(barHeight);
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterWindowMixin:GetBarHeight()
	return self.barHeight or DAMAGE_METER_DEFAULT_BAR_HEIGHT;
end

function DamageMeterWindowMixin:SetBarHeight(barHeight)
	if not ApproximatelyEqual(self:GetBarHeight(), barHeight) then
		self.barHeight = barHeight;
		self:OnBarHeightChanged(barHeight);
	end
end

function DamageMeterWindowMixin:OnTextScaleChanged(textScale)
	self.ScrollBox:ForEachFrame(function(frame) frame:SetTextScale(textScale); end);
	self.UnitBreakdownFrame:SetTextScale(textScale);
end

function DamageMeterWindowMixin:GetTextScale()
	return self.textScale or 1;
end

function DamageMeterWindowMixin:SetTextScale(textScale)
	if not ApproximatelyEqual(self:GetTextScale(), textScale) then
		self.textScale = textScale;
		self:OnTextScaleChanged(textScale);
	end
end

function DamageMeterWindowMixin:OnShowBarIconsChanged(showBarIcons)
	self:ForEachEntryFrame(function(frame) frame:SetShowBarIcons(showBarIcons); end);
	self:GetUnitBreakdownFrame():SetShowBarIcons(showBarIcons);
end

function DamageMeterWindowMixin:ShouldShowBarIcons()
	return self.showBarIcons == true;
end

function DamageMeterWindowMixin:SetShowBarIcons(showBarIcons)
	showBarIcons = (showBarIcons == true);

	if self.showBarIcons ~= showBarIcons then
		self.showBarIcons = showBarIcons;
		self:OnShowBarIconsChanged(showBarIcons);
	end
end

function DamageMeterWindowMixin:OnStyleChanged(style)
	self:ForEachEntryFrame(function(frame) frame:SetStyle(style); end);
	self:GetUnitBreakdownFrame():SetStyle(style);
end

function DamageMeterWindowMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterWindowMixin:SetStyle(style)
	if self.style ~= style then
		self.style = style;
		self:OnStyleChanged(style);
	end
end
