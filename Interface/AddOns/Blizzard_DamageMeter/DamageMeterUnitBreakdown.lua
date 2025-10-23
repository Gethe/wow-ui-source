DamageMeterUnitBreakdownMixin = {};

local DamageMeterUnitBreakdownEvents = {
	--"DAMAGE_METER_UNIT_LIST_UPDATE",
};

function DamageMeterUnitBreakdownMixin:OnLoad()
	self:InitializeScrollBox();
end

function DamageMeterUnitBreakdownMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DamageMeterUnitBreakdownEvents);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterUnitBreakdownMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DamageMeterUnitBreakdownEvents);
end

function DamageMeterUnitBreakdownMixin:OnEvent(event, ...)
	if event == "DAMAGE_METER_UNIT_LIST_UPDATE" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
	end
end

function DamageMeterUnitBreakdownMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
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

function DamageMeterUnitBreakdownMixin:GetEntryList()
	local entryList =
	{
		{texture = 135987; maxValue = 100; value = 100; },
		{texture = 132864; maxValue = 100; value = 80; }
	};
	return entryList;
end

function DamageMeterUnitBreakdownMixin:BuildDataProvider()
	local entryList = self:GetEntryList();

	local dataProvider = CreateDataProvider();
	for i, entryData in ipairs(entryList) do
		entryData.index = i;
		dataProvider:Insert(entryData);
	end

	return dataProvider;
end

function DamageMeterUnitBreakdownMixin:Refresh(retainScrollPosition)
	self.ScrollBox:SetDataProvider(self:BuildDataProvider(), retainScrollPosition);
end

function DamageMeterUnitBreakdownMixin:SetTrackedData(trackedStat, trackedUnit)
	self.trackedStat = trackedStat;
	self.trackedUnit = trackedUnit;
end

function DamageMeterUnitBreakdownMixin:AnchorToWindow(windowFrame)
	self:ClearAllPoints();

	local windowCenterX, _windowCenterY = windowFrame:GetCenter();
	local screenCenterX, _screenCenterY = UIParent:GetCenter();

	-- Anchor in whatever direction has more room.
	if windowCenterX < screenCenterX then
		self:SetPoint("LEFT", windowFrame, "RIGHT");
	else
		self:SetPoint("RIGHT", windowFrame, "LEFT");
	end
end
