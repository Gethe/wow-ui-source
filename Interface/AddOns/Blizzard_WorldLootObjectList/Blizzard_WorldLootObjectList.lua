
local WorldLootObjectListDummySentinel = "WorldLootObjectList.DummySentinel";
local WorldObjectListRefreshCadence = 0.25;
local WorldLootObjectListMinimumInRangeCountToShow = 3;
local WorldLootObjectListMinimumInRangeCountToHide = 1;


WorldLootObjectListButtonMixin = {};

function WorldLootObjectListButtonMixin:Init(widget)
	local isDummy = WorldLootObjectListDummySentinel == widget;
	self:SetDummy(isDummy);
	if isDummy then
		return;
	end

	self.widgetID = widget.widgetID;
	self.attachedUnit = widget.attachedUnit;

	local widgetInfo = widget.widgetInfo;
	self.widgetContainer = widget.widgetContainer;
	self.WidgetDisplay:Setup(widget.widgetInfo, widget.widgetContainer);
	self.WidgetDisplay.Spell.tooltipXOffset = 230;

	local spellInfo = widgetInfo.spellInfo;

	if spellInfo.spellID == 0 then
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	local spellData = C_Spell.GetSpellInfo(spellInfo.spellID);
	local text = (spellInfo.text == "") and (spellData and spellData.name) or spellInfo.text;

	self.Name:SetText(text);
	self:UpdateDisabledState();
end

function WorldLootObjectListButtonMixin:OnUpdate(dt)
	if self.widgetID then
		self:Refresh();
	end
end

function WorldLootObjectListButtonMixin:OnEnter()
	self.WidgetDisplay.Spell:OnEnter();
end

function WorldLootObjectListButtonMixin:OnLeave()
	self.WidgetDisplay.Spell:OnLeave();
end

function WorldLootObjectListButtonMixin:OnMouseDown(...)
	self.WidgetDisplay:OnMouseDown(...);
end

function WorldLootObjectListButtonMixin:SetDummy(isDummy)
	if self.isDummy ~= isDummy then
		self.isDummy = isDummy;

		if isDummy then
			self.widgetID = nil;
			self.attachedUnit = nil;
			self.widgetContainer = nil;
		end

		self:UpdateDisabledState();
	end
end

function WorldLootObjectListButtonMixin:UpdateDisabledState()
	if self.isDummy then
		self.WidgetDisplay:Hide();
		self:SetAlpha(0);
	elseif self.attachedUnit and not C_WorldLootObject.IsWorldLootObjectInRange(self.attachedUnit) then
		self.WidgetDisplay:Show();
		self:SetAlpha(0.5);
	else
		self.WidgetDisplay:Show();
		self:SetAlpha(1);
	end
end

function WorldLootObjectListButtonMixin:Refresh()
	local widgetInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(self.widgetID);
	local spellInfo = widgetInfo and widgetInfo.spellInfo;
	if spellInfo.spellID == 0 then
		return;
	end

	self.WidgetDisplay:Setup(widgetInfo, self.widgetContainer);

	local spellData = C_Spell.GetSpellInfo(spellInfo.spellID);
	local text = (spellInfo.text == "") and (spellData and spellData.name) or spellInfo.text;

	self.Name:SetText(text);
	self:SetScript("OnUpdate", nil);
	self:UpdateDisabledState();
end


WorldLootObjectListMixin = {};

function WorldLootObjectListMixin:OnLoad()
	-- Objects that are displayed on screen as widgets that may or may not be in the list yet.
	self.widgetObjectSet = {};

	-- Objects that have been added to the list.
	self.shownObjectSet = {};

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("WorldLootObjectListButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(2, 2, 2, 2);

	self.ScrollBox:Init(view);

	EventRegistry:RegisterCallback("WorldLootObject.ObjectShown", self.OnObjectShown, self);
	EventRegistry:RegisterCallback("WorldLootObject.ObjectHidden", self.OnObjectHidden, self);

	self.dataProvider = CreateDataProvider();
	self.ScrollBox:SetDataProvider(self.dataProvider);

	local scrollBG = self.ScrollBox.ScrollTarget:CreateTexture("", "BACKGROUND");
	scrollBG:SetAllPoints();
	scrollBG:SetColorTexture(0, 0, 0, 0.5);
end

function WorldLootObjectListMixin:OnUpdate(dt)
	self.refreshTimer = (self.refreshTimer or WorldObjectListRefreshCadence) - dt;
	if self.refreshTimer <= 0 then
		self.widgetDistanceCache = {};
		self.refreshTimer = WorldObjectListRefreshCadence;
		self:Refresh();
	end
end

function WorldLootObjectListMixin:OnObjectShown(unitToken, widget)
	-- The WorldLootObjectListButtons include a widget that will trigger this so we want to ignore those.
	if self.widgetObjectSet[unitToken] then
		return;
	end

	self.widgetObjectSet[unitToken] = widget;
end

function WorldLootObjectListMixin:OnObjectHidden(unitToken, widget)
	local button = self.ScrollBox:FindFrame(unitToken);
	if button then
		button:SetDummy(true);
	end

	self.widgetObjectSet[unitToken] = nil;
	self.shownObjectSet[unitToken] = nil;

	local dataProviderIndex = self.dataProvider:FindIndex(widget);
	if dataProviderIndex then
		if dataProviderIndex == self.dataProvider:GetSize() then
			self.dataProvider:RemoveIndex(dataProviderIndex);

			-- Remove all trailing dummy/empty slots.
			while (self.dataProvider:GetSize() > 0) and (self.dataProvider:Find(self.dataProvider:GetSize()) == WorldLootObjectListDummySentinel) do
				self.dataProvider:RemoveIndex(self.dataProvider:GetSize());
			end
		else
			self.dataProvider:ReplaceAtIndex(dataProviderIndex, WorldLootObjectListDummySentinel);
		end
	end
end

function WorldLootObjectListMixin:EvaluateVisibility()
	local inRangeCount = 0;
	self.dataProvider:ForEach(function(widget)
		if (widget ~= WorldLootObjectListDummySentinel) and C_WorldLootObject.IsWorldLootObjectInRange(widget.attachedUnit) then
			inRangeCount = inRangeCount + 1;
		end
	end);

	if self.ScrollBox:IsShown() then
		if inRangeCount < WorldLootObjectListMinimumInRangeCountToHide then
			self.ScrollBox:Hide();
			self.shownObjectSet = {};
			self.dataProvider:Flush();
			-- We keep widgetObjectSet since these may be shown again when they're in range.
		end
	else
		if inRangeCount >= WorldLootObjectListMinimumInRangeCountToShow then
			self.ScrollBox:Show();
			self:RefreshScrollBox();
		end
	end
end

function WorldLootObjectListMixin:InsertNewWidget(widget)
	local dummyIndex = self.dataProvider:FindIndex(WorldLootObjectListDummySentinel);
	if dummyIndex then
		self.dataProvider:ReplaceAtIndex(dummyIndex, widget);
		local existingFrame = self.ScrollBox:FindFrame(widget);
		existingFrame:Init(widget);
	else
		self.dataProvider:Insert(widget);
	end
end

function WorldLootObjectListMixin:Refresh()
	for unitToken, widget in pairs(self.widgetObjectSet) do
		if not self.shownObjectSet[unitToken] and C_WorldLootObject.IsWorldLootObjectInRange(unitToken) then
			self.shownObjectSet[unitToken] = widget;
			self:InsertNewWidget(widget);
		end
	end

	self:EvaluateVisibility();
	self:RefreshScrollBox();
end

function WorldLootObjectListMixin:RefreshScrollBox()
	if self.ScrollBox:IsShown() then
		self.ScrollBox:ForEachFrame(function(button)
			button:UpdateDisabledState();
		end);
	end
end
