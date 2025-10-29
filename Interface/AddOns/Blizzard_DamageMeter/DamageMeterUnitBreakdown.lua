DamageMeterUnitBreakdownMixin = {};

local DamageMeterUnitBreakdownEvents = {
	--"DAMAGE_METER_UNIT_LIST_UPDATE",
};

function DamageMeterUnitBreakdownMixin:GetName()
	return self.Name;
end

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

function DamageMeterUnitBreakdownMixin:OnUpdate()
	local retainScrollPosition = true;
	self:Refresh(retainScrollPosition);
end

function DamageMeterUnitBreakdownMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSpellEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
		frame:SetUseClassColor(self:ShouldUseClassColor());
		frame:SetBarHeight(self:GetBarHeight());
		frame:SetTextScale(self:GetTextScale());
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

function DamageMeterUnitBreakdownMixin:BuildDataProvider()
	local combatSessionSource = self.unitToken and C_DamageMeter.GetCurrentCombatSessionSource(Enum.DamageMeterType.DamageDone, self.unitToken) or nil;
	local combatSpells = combatSessionSource and combatSessionSource.combatSpells or {};
	local maxAmount = combatSessionSource and combatSessionSource.maxAmount or 0;

	local dataProvider = CreateDataProvider();
	for i, combatSpell in ipairs(combatSpells) do
		combatSpell.unitToken = self.unitToken;
		combatSpell.maxAmount = maxAmount;
		combatSpell.index = i;

		dataProvider:Insert(combatSpell);
	end

	return dataProvider;
end

function DamageMeterUnitBreakdownMixin:Refresh(retainScrollPosition)
	self.ScrollBox:SetDataProvider(self:BuildDataProvider(), retainScrollPosition);
end

function DamageMeterUnitBreakdownMixin:EnumerateEntryFrames()
	return self.ScrollBox:EnumerateFrames();
end

function DamageMeterUnitBreakdownMixin:ForEachEntryFrame(func, ...)
	for _index, frame in self:EnumerateEntryFrames() do
		func(frame, ...);
	end
end

function DamageMeterUnitBreakdownMixin:GetEntryFrameCount()
	return self.ScrollBox:GetFrameCount();
end

function DamageMeterUnitBreakdownMixin:SetTrackedData(trackedStat, unitToken)
	self.trackedStat = trackedStat;
	self.unitToken = unitToken;

	self:UpdateName();
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

function DamageMeterUnitBreakdownMixin:GetNameText()
	if not self.unitToken then
		return nil;
	end

	return UnitName(self.unitToken);
end

function DamageMeterUnitBreakdownMixin:UpdateName()
	local text = self:GetNameText();
	self:GetName():SetText(text);
end

function DamageMeterUnitBreakdownMixin:OnUseClassColorChanged(useClassColor)
	self.ScrollBox:ForEachFrame(function(frame) frame:SetUseClassColor(useClassColor); end);
end

function DamageMeterUnitBreakdownMixin:ShouldUseClassColor()
	return self.useClassColor == true;
end

function DamageMeterUnitBreakdownMixin:SetUseClassColor(useClassColor)
	useClassColor = (useClassColor == true);

	if self.useClassColor ~= useClassColor then
		self.useClassColor = useClassColor;
		self:OnUseClassColorChanged(useClassColor);
	end
end

function DamageMeterUnitBreakdownMixin:OnBarHeightChanged(barHeight)
	local retainScrollPosition = true;
	self.ScrollBox:GetView():SetElementExtent(barHeight);
	self:Refresh(retainScrollPosition);
end

function DamageMeterUnitBreakdownMixin:GetBarHeight()
	return self.barHeight or DAMAGE_METER_DEFAULT_BAR_HEIGHT;
end

function DamageMeterUnitBreakdownMixin:SetBarHeight(barHeight)
	if not ApproximatelyEqual(self:GetBarHeight(), barHeight) then
		self.barHeight = barHeight;
		self:OnBarHeightChanged(barHeight);
	end
end

function DamageMeterUnitBreakdownMixin:OnTextScaleChanged(textScale)
	self.ScrollBox:ForEachFrame(function(frame) frame:SetTextScale(textScale); end);
end

function DamageMeterUnitBreakdownMixin:GetTextScale()
	return self.textScale or 1;
end

function DamageMeterUnitBreakdownMixin:SetTextScale(textScale)
	if not ApproximatelyEqual(self:GetTextScale(), textScale) then
		self.textScale = textScale;
		self:OnTextScaleChanged(textScale);
	end
end
