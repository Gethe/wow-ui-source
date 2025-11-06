DamageMeterUnitBreakdownMixin = {};

local DamageMeterUnitBreakdownEvents = {
	"DAMAGE_METER_COMBAT_SESSION_SOURCE_UPDATED",
	"DAMAGE_METER_RESET",
	"GLOBAL_MOUSE_DOWN",
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
	if event == "DAMAGE_METER_COMBAT_SESSION_SOURCE_UPDATED" then
		local type, sessionID, sourceGUID = ...;
		if self:GetTrackedStat() == type then
			if self:GetSessionID() == sessionID or self:GetSessionType() ~= nil then
				if self:GetSourceGUID() == sourceGUID then
					self:Refresh(ScrollBoxConstants.RetainScrollPosition);
				end
			end
		end
	elseif event == "DAMAGE_METER_RESET" then
		self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
	elseif event == "GLOBAL_MOUSE_DOWN" then
		if not DoesAncestryIncludeAny(self, GetMouseFoci()) then
			self:Hide();
		end
	end
end

function DamageMeterUnitBreakdownMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSpellEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
		frame:SetUseClassColor(self:ShouldUseClassColor());
		frame:SetBarHeight(self:GetBarHeight());
		frame:SetTextScale(self:GetTextScale());
		frame:SetShowBarIcons(self:ShouldShowBarIcons());
		frame:SetStyle(self:GetStyle());
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

function DamageMeterUnitBreakdownMixin:GetCombatSessionSource()
	if not self.sourceGUID then
		return nil;
	end

	local trackedStat = self:GetTrackedStat();

	local sessionType = self:GetSessionType();
	if sessionType then
		return C_DamageMeter.GetCombatSessionSourceFromType(sessionType, trackedStat, self.sourceGUID);
	end

	local sessionID = self:GetSessionID();
	if sessionID then
		return C_DamageMeter.GetCombatSessionSourceFromID(sessionID, trackedStat, self.sourceGUID);
	end

	return nil;
end

function DamageMeterUnitBreakdownMixin:BuildDataProvider()
	local combatSessionSource = self:GetCombatSessionSource();
	local combatSpells = combatSessionSource and combatSessionSource.combatSpells or {};
	local maxAmount = combatSessionSource and combatSessionSource.maxAmount or 0;

	local dataProvider = CreateDataProvider();
	for i, combatSpell in ipairs(combatSpells) do
		combatSpell.sourceGUID = self.sourceGUID;
		combatSpell.classFilename = self.classFilename;
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

function DamageMeterUnitBreakdownMixin:SetSource(source)
	self.sourceGUID = source.sourceGUID;
	self.sourceName = source.name;
	self.classFilename = source.classFilename;

	self:UpdateName();
end

function DamageMeterUnitBreakdownMixin:GetSourceGUID()
	return self.sourceGUID;
end

function DamageMeterUnitBreakdownMixin:SetTrackedStat(trackedStat)
	self.trackedStat = trackedStat;
end

function DamageMeterUnitBreakdownMixin:GetTrackedStat()
	return self.trackedStat;
end

function DamageMeterUnitBreakdownMixin:SetSession(sessionType, sessionID)
	self.sessionType = sessionType;
	self.sessionID = sessionID;

	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterUnitBreakdownMixin:GetSessionType()
	return self.sessionType;
end

function DamageMeterUnitBreakdownMixin:GetSessionID()
	return self.sessionID;
end

function DamageMeterUnitBreakdownMixin:AnchorToWindow(windowFrame)
	self:ClearAllPoints();

	local windowCenterX, _windowCenterY = windowFrame:GetCenter();
	local screenCenterX, _screenCenterY = UIParent:GetCenter();

	-- Anchor in whatever direction has more room.
	if windowCenterX < screenCenterX then
		self:SetPoint("TOPLEFT", windowFrame, "TOPRIGHT");
	else
		self:SetPoint("TOPRIGHT", windowFrame, "TOPLEFT");
	end
end

function DamageMeterUnitBreakdownMixin:GetNameText()
	return self.sourceName;
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

function DamageMeterUnitBreakdownMixin:OnShowBarIconsChanged(showBarIcons)
	self:ForEachEntryFrame(function(frame) frame:SetShowBarIcons(showBarIcons); end);
end

function DamageMeterUnitBreakdownMixin:ShouldShowBarIcons()
	return self.showBarIcons == true;
end

function DamageMeterUnitBreakdownMixin:SetShowBarIcons(showBarIcons)
	showBarIcons = (showBarIcons == true);

	if self.showBarIcons ~= showBarIcons then
		self.showBarIcons = showBarIcons;
		self:OnShowBarIconsChanged(showBarIcons);
	end
end

function DamageMeterUnitBreakdownMixin:OnStyleChanged(style)
	self:ForEachEntryFrame(function(frame) frame:SetStyle(style); end);
end

function DamageMeterUnitBreakdownMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterUnitBreakdownMixin:SetStyle(style)
	if self.style ~= style then
		self.style = style;
		self:OnStyleChanged(style);
	end
end
