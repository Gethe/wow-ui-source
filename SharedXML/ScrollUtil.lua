ScrollUtil = {};

-- Function provided for community addons to modify an element frame.
function ScrollUtil.AddInitializationCallback(scrollBox, callback, owner, iterateExisting)
	if iterateExisting then
		scrollBox:ForEachFrame(callback);
	end

	local function OnAcquired(o, frame, elementData, new)
		callback(frame, elementData, new);
	end
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, OnAcquired, owner);
end

function ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)
	ScrollUtil.RegisterWithScrollBox(scrollBox, scrollBar);
	ScrollUtil.RegisterWithScrollBar(scrollBox, scrollBar);

	if not scrollBar:CanInterpolateScroll() or not scrollBox:CanInterpolateScroll() then
		scrollBar:SetInterpolateScroll(false);
		scrollBox:SetInterpolateScroll(false);
	end
end

function ScrollUtil.RegisterWithScrollBox(scrollBox, scrollBar)
	local onScrollBoxScroll = function(o, scrollPercentage, visibleExtentPercentage, panExtentPercentage)
		scrollBar:SetScrollPercentage(scrollPercentage, ScrollBoxConstants.NoScrollInterpolation);
		scrollBar:SetVisibleExtentPercentage(visibleExtentPercentage);
		scrollBar:SetPanExtentPercentage(panExtentPercentage);
	end;
	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, onScrollBoxScroll, scrollBar);
	
	local onSizeChanged = function(o, width, height, visibleExtentPercentage)
		scrollBar:SetVisibleExtentPercentage(visibleExtentPercentage);
	end;
	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnSizeChanged, onSizeChanged, scrollBar);
	
	local onScrollBoxAllowScroll = function(o, allowScroll)
		scrollBar:SetScrollAllowed(allowScroll);
	end;
	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnAllowScrollChanged, onScrollBoxAllowScroll, scrollBar);
end

function ScrollUtil.RegisterWithScrollBar(scrollBox, scrollBar)
	local onScrollBarScroll = function(o, scrollPercentage)
		scrollBox:SetScrollPercentage(scrollPercentage, ScrollBoxConstants.NoScrollInterpolation);
	end;
	scrollBar:RegisterCallback(BaseScrollBoxEvents.OnScroll, onScrollBarScroll, scrollBox);

	local onScollBarAllowScroll = function(o, allowScroll)
		scrollBox:SetScrollAllowed(allowScroll);
	end;

	scrollBar:RegisterCallback(BaseScrollBoxEvents.OnAllowScrollChanged, onScollBarAllowScroll, scrollBox);
end

local function InitScrollBar(scrollBox, scrollBar)
	scrollBar:Init(scrollBox:GetVisibleExtentPercentage(), scrollBox:CalculatePanExtentPercentage());
end

function ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollBoxView)
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	scrollBox:Init(scrollBoxView);
	InitScrollBar(scrollBox, scrollBar);
end

function ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollBoxView)
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	scrollBox:Init(scrollBoxView);
	InitScrollBar(scrollBox, scrollBar);
end

function ScrollUtil.InitScrollBar(scrollBox, scrollBar)
	ScrollUtil.RegisterWithScrollBar(scrollBox, scrollBar);
	InitScrollBar(scrollBox, scrollBar);
end

-- Utility for managing the visibility of a ScrollBar and reanchoring of the
-- ScrollBox as the visibility changes.
ManagedScrollBarVisibilityBehaviorMixin = CreateFromMixins(CallbackRegistryMixin);

ManagedScrollBarVisibilityBehaviorMixin:GenerateCallbackEvents(
	{
		"OnVisibilityChanged",
	}
);


function ManagedScrollBarVisibilityBehaviorMixin:Init(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)
	CallbackRegistryMixin.OnLoad(self);

	self.scrollBox = scrollBox;
	self.scrollBar = scrollBar;
	self.scrollBoxAnchorsWithBar = scrollBoxAnchorsWithBar;
	self.scrollBoxAnchorsWithoutBar = scrollBoxAnchorsWithoutBar;

	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnLayout, self.EvaluateVisibility, self);

	self:EvaluateVisibility();
end

function ManagedScrollBarVisibilityBehaviorMixin:GetScrollBox()
	return self.scrollBox;
end

function ManagedScrollBarVisibilityBehaviorMixin:GetScrollBar()
	return self.scrollBar;
end

function ManagedScrollBarVisibilityBehaviorMixin:EvaluateVisibility()
	local hasScrollableExtent = self:GetScrollBox():HasScrollableExtent();
	self:SetScrollBarVisible(hasScrollableExtent);
end

function ManagedScrollBarVisibilityBehaviorMixin:SetScrollBarVisible(visible)
	self:GetScrollBar():SetShown(visible);

	self:ApplyAnchors(visible and self.scrollBoxAnchorsWithBar or self.scrollBoxAnchorsWithoutBar)
end

function ManagedScrollBarVisibilityBehaviorMixin:ApplyAnchors(anchors)
	if self.appliedAnchors == anchors then
		return;
	end
	self.appliedAnchors = anchors;

	local scrollBox = self:GetScrollBox();
	scrollBox:ClearAllPoints();

	local clearAllPoints = false;
	for index, anchor in ipairs(anchors) do
		anchor:SetPoint(scrollBox, clearAllPoints);
	end

	self:TriggerEvent(ManagedScrollBarVisibilityBehaviorMixin.Event.OnVisibilityChanged, self.scrollBar:IsShown());
end

function ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)
	local behavior = CreateFromMixins(ManagedScrollBarVisibilityBehaviorMixin);
	behavior:Init(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
	return behavior;
end

SelectionBehaviorMixin = CreateFromMixins(CallbackRegistryMixin);

SelectionBehaviorPolicy =
{
	Deselectable = 1,
};

SelectionBehaviorMixin:GenerateCallbackEvents(
	{
		"OnSelectionChanged",
	}
);

function SelectionBehaviorMixin.IsSelected(frame)
	return frame and SelectionBehaviorMixin.IsElementDataSelected(frame.elementData) or false;
end

function SelectionBehaviorMixin.IsElementDataSelected(elementData)
	return elementData and elementData.selected or false;
end

function SelectionBehaviorMixin:OnLoad(scrollBox, selectionPolicy)
	CallbackRegistryMixin.OnLoad(self);
	
	self.scrollBox = scrollBox;

	self:SetSelectionPolicy(selectionPolicy);
end

function SelectionBehaviorMixin:SetSelectionPolicy(selectionPolicy)
	self.selectionPolicy = selectionPolicy;
end

function SelectionBehaviorMixin:HasSelection()
	return #self:GetSelectedElementData() > 0;
end

function SelectionBehaviorMixin:GetSelectedElementData()
	local selected = {};
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		for index, elementData in dataProvider:Enumerate() do
			if elementData.selected then
				table.insert(selected, elementData);
			end
		end
	end
	return selected;
end

function SelectionBehaviorMixin:IsDeselectable()
	return self.selectionPolicy == SelectionBehaviorPolicy.Deselectable;
end

function SelectionBehaviorMixin:DeselectByPredicate(predicate)
	local deselected = {};
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		for index, elementData in dataProvider:Enumerate() do
			if predicate(elementData) then
				elementData.selected = nil;
				table.insert(deselected, elementData);
			end
		end
	end
	return deselected;
end

function SelectionBehaviorMixin:DeselectSelectedElements()
	return self:DeselectByPredicate(function(elementData)
		return elementData.selected;
	end);
end

function SelectionBehaviorMixin:ClearSelections()
	local deselected = self:DeselectSelectedElements();
	for index, data in ipairs(deselected) do
		self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, data, false);
	end
end

function SelectionBehaviorMixin:ToggleSelectElementData(elementData)
	local oldSelected = elementData.selected;
	if oldSelected and not self:IsDeselectable() then
		return;
	end
	
	local newSelected = not oldSelected;
	self:SetElementDataSelected_Internal(elementData, newSelected);
end

function SelectionBehaviorMixin:SelectElementData(elementData)
	self:SetElementDataSelected_Internal(elementData, true);
end

function SelectionBehaviorMixin:SetElementDataSelected_Internal(elementData, newSelected)
	local deselected = nil;
	if newSelected then
		-- Works under the current single selection policy. When multi-select is added,
		-- change this.
		deselected = self:DeselectByPredicate(function(data)
			return data.selected and data ~= elementData;
		end);
	end

	local changed = (not not elementData.selected) ~= newSelected;
	elementData.selected = newSelected;

	if deselected then
		for index, data in ipairs(deselected) do
			self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, data, false);
		end
	end

	if changed then
		if elementData.scrollBoxChild then
			self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, elementData, newSelected);
		end
	end
end

function SelectionBehaviorMixin:Select(frame)
	self:SelectElementData(frame.elementData);
end

function SelectionBehaviorMixin:ToggleSelect(frame)
	self:ToggleSelectElementData(frame.elementData);
end

function ScrollUtil.AddSelectionBehavior(scrollBox, selectionPolicy)
	local behavior = CreateFromMixins(SelectionBehaviorMixin);
	behavior:OnLoad(scrollBox, selectionPolicy);
	return behavior;
end

function ScrollUtil.AddResizableChildrenBehavior(scrollBox)
	local onSizeChanged = function(o, width, height)
		scrollBox:QueueUpdate();
	end;
	local onSubscribe = function(frame, elementData)
		frame:RegisterCallback(BaseScrollBoxEvents.OnSizeChanged, onSizeChanged, scrollBox);
	end

	local onAcquired = function(o, frame, elementData)
		onSubscribe(frame, elementData);
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, onAcquired, onAcquired);

	local onReleased = function(o, frame, elementData)
		frame:UnregisterCallback(BaseScrollBoxEvents.OnSizeChanged, scrollBox);
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);

	scrollBox:ForEachFrame(onSubscribe);
end

function ScrollUtil.RegisterTableBuilder(scrollBox, tableBuilder, elementDataTranslator)
	local onAcquired = function(o, frame, elementData)
		tableBuilder:AddRow(frame, elementDataTranslator(elementData));
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, onAcquired, onAcquired);

	local onReleased = function(o, frame, elementData)
		tableBuilder:RemoveRow(frame, elementDataTranslator(elementData));
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);
end