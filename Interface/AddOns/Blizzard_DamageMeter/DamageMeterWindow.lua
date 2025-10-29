
local DAMAGE_METER_TYPE_NAMES = {
	[Enum.DamageMeterType.DamageDone] = "Damage Done",
	[Enum.DamageMeterType.Dps] = "DPS",
	[Enum.DamageMeterType.HealingDone] = "Healing Done",
	[Enum.DamageMeterType.Hps] = "HPS",
};

local function GetDamageMeterTypeName(damageMeterType)
	return DAMAGE_METER_TYPE_NAMES[damageMeterType] or "Unknown";
end

DamageMeterWindowMixin = {};

local DamageMeterWindowListEvents = {
	--"DAMAGE_METER_LIST_UPDATE",
};

function DamageMeterWindowMixin:OnLoad()
	self:RegisterForDrag("LeftButton");

	self:InitializeScrollBox();
	self:InitializeTrackedStatDropdown();
	self:InitializeSegmentDropdown();
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
	if event == "DAMAGE_METER_LIST_UPDATE" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
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
			self:SetScript("OnUpdate", self.OnUpdate);
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

function DamageMeterWindowMixin:OnUpdate()
	local retainScrollPosition = true;
	self:Refresh(retainScrollPosition);
end

function DamageMeterWindowMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSourceEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
		frame:SetUseClassColor(self:ShouldUseClassColor());
		frame:SetBarHeight(self:GetBarHeight());
		frame:SetTextScale(self:GetTextScale());

		frame:SetScript("OnClick", function(button, mouseButtonName)
			if mouseButtonName == "LeftButton" then
				self:ShowBreakdownFrame(elementData);
			end
		end);
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 4;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local topLeftX, topLeftY = 20, -5;
	local bottomRightX, bottomRightY = -20, 0;
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
	local function GetCategories()
		local categoryList =
		{
			{ name = "Damage"; types = {Enum.DamageMeterType.DamageDone, Enum.DamageMeterType.Dps}; },
			{ name = "Healing"; types = {Enum.DamageMeterType.HealingDone, Enum.DamageMeterType.Hps}; },
		};
		return categoryList;
	end

	local categoryList = GetCategories();

	local function IsSelected(option)
		return self:GetTrackedStat() == option;
	end

	local function SetSelected(option)
		-- Tracked stat changes need to go through the owner.
		self:GetDamageMeterOwner():SetWindowFrameTrackedStat(self, option);
	end

	self.TrackedStatDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_TRACKED_TYPE");

		for _i, categoryData in ipairs(categoryList) do
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

function DamageMeterWindowMixin:InitializeSegmentDropdown()
	self.SegmentDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_SEGMENTS");

	end);
end

function DamageMeterWindowMixin:InitializeSettingsDropdown()
	local function IsCreateNewWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanShowNewWindowFrame();
	end

	local function IsDeleteWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanHideWindowFrame(self);
	end

	self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_SETTINGS");

		rootDescription:CreateButton("PH - Settings", function(...)
			Settings.OpenToCategory(Settings.ADVANCED_OPTIONS_CATEGORY_ID);
		end);

		rootDescription:CreateButton("PH - Edit Mode", function(...)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ShowUIPanel(EditModeManagerFrame);
		end);

		local createNewWindowFrameButton = rootDescription:CreateButton("PH - Create New Window", function(...)
			self:GetDamageMeterOwner():ShowNewWindowFrame();
		end);
		createNewWindowFrameButton:SetEnabled(IsCreateNewWindowFrameEnabled);

		local deleteWindowFrameButton = rootDescription:CreateButton("PH - Delete Window", function(...)
			self:GetDamageMeterOwner():HideWindowFrame(self);
		end);
		deleteWindowFrameButton:SetEnabled(IsDeleteWindowFrameEnabled)
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

function DamageMeterWindowMixin:BuildDataProvider()
	local dataProvider = CreateDataProvider();

	local combatSession = C_DamageMeter.GetCurrentCombatSession(Enum.DamageMeterType.DamageDone);
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
	self.TrackedStatDropdown.StatName:SetText(GetDamageMeterTypeName(trackedStat));
end

function DamageMeterWindowMixin:GetTrackedStat()
	return self.trackedStat;
end

function DamageMeterWindowMixin:IsResizing()
	return self.isResizing == true;
end

function DamageMeterWindowMixin:RefreshLayout()

end

function DamageMeterWindowMixin:ShowBreakdownFrame(elementData)
	self.UnitBreakdownFrame:SetTrackedData(self:GetTrackedStat(), elementData.unitToken);
	self.UnitBreakdownFrame:AnchorToWindow(self);
	self.UnitBreakdownFrame:Show();
end

function DamageMeterWindowMixin:HideBreakdownFrame()
	self.UnitBreakdownFrame:Hide();
end

function DamageMeterWindowMixin:OnUseClassColorChanged(useClassColor)
	self.ScrollBox:ForEachFrame(function(frame) frame:SetUseClassColor(useClassColor); end);
	self.UnitBreakdownFrame:SetUseClassColor(useClassColor);
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
	local retainScrollPosition = true;
	self.ScrollBox:GetView():SetElementExtent(barHeight);
	self.UnitBreakdownFrame:SetBarHeight(barHeight);
	self:Refresh(retainScrollPosition);
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
