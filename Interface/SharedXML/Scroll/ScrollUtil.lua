ScrollUtil = {};

-- For public addons to access frames post-acquire, post-initialization and post-release. It can be correct
-- to use both AddInitializedFrameCallback and AddAcquiredFrameCallback depending on the modifications
-- being made.

-- Assigns a callback to be invoked every time a frame is initialized. Initialization occurs after
-- every frame has been anchored and a layout pass performed, which is necessary if the frame's initializer
-- needs to ask for information about it's size to inform layout decisions within itself.
-- For convenience, you can leverage the 'iterateExisting' argument to immediately invoke the callback on any existing frames.
function ScrollUtil.AddInitializedFrameCallback(scrollBox, callback, owner, iterateExisting)
	if iterateExisting then
		scrollBox:ForEachFrame(callback);
	end

	local function OnInitialized(o, frame, elementData)
		callback(o, frame, elementData);
	end
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, OnInitialized, owner);
end

-- Assigns a callback to be invoked every time a frame is acquired. This is suitable if you need to perform
-- modifications to the frame prior to the initializer being called, or more likely if you're trying to make
-- one-time modifications if it's the first time the frame has ever been displayed in the ScrollBox (see 'new').
function ScrollUtil.AddAcquiredFrameCallback(scrollBox, callback, owner, iterateExisting)
	if iterateExisting then
		scrollBox:ForEachFrame(callback);
	end

	local function OnAcquired(o, frame, elementData, new)
		callback(o, frame, elementData, new);
	end
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, OnAcquired, owner);
end

-- Useful for being notified when a frame has been released and to remove any behavior
-- if you've opted into using a single template type for frames with varied behavior.
function ScrollUtil.AddReleasedFrameCallback(scrollBox, callback, owner)
	local function OnReleased(o, frame, elementData)
		callback(o, frame, elementData);
	end
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, OnReleased, owner);
end

local function RegisterWithScrollBox(scrollBox, scrollBar)
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

local function RegisterWithScrollBar(scrollBox, scrollBar)
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

-- ScrollBoxList variant intended for the majority of registration and initialization cases.
function ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollBoxView)
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	scrollBox:Init(scrollBoxView);
	InitScrollBar(scrollBox, scrollBar);
end

-- ScrollBox variant intended for the majority of registration and initialization cases.
-- Currently implemented identically to InitScrollBoxListWithScrollBar but allows for
-- changes to be made easier without public deprecation problems.
function ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollBoxView)
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	scrollBox:Init(scrollBoxView);
	InitScrollBar(scrollBox, scrollBar);
end

-- Rarely used in cases where the ScrollBox was previously initialized.
function ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)
	RegisterWithScrollBox(scrollBox, scrollBar);
	RegisterWithScrollBar(scrollBox, scrollBar);

	if not scrollBar:CanInterpolateScroll() or not scrollBox:CanInterpolateScroll() then
		scrollBar:SetInterpolateScroll(false);
		scrollBox:SetInterpolateScroll(false);
	end
end

-- Rarely used in cases where a ScrollBox was previously initialized.
function ScrollUtil.InitScrollBar(scrollBox, scrollBar)
	RegisterWithScrollBar(scrollBox, scrollBar);
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

	if scrollBoxAnchorsWithBar and scrollBoxAnchorsWithoutBar then
		self.scrollBoxAnchorsWithBar = scrollBoxAnchorsWithBar;
		self.scrollBoxAnchorsWithoutBar = scrollBoxAnchorsWithoutBar;
	end

	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnLayout, self.EvaluateVisibility, self);

	local onSizeChanged = function(o, width, height, visibleExtentPercentage)
		self:EvaluateVisibility();
	end;
	scrollBox:RegisterCallback(BaseScrollBoxEvents.OnSizeChanged, onSizeChanged, scrollBar);

	local force = true;
	self:EvaluateVisibility(force);
end

function ManagedScrollBarVisibilityBehaviorMixin:GetScrollBox()
	return self.scrollBox;
end

function ManagedScrollBarVisibilityBehaviorMixin:GetScrollBar()
	return self.scrollBar;
end

function ManagedScrollBarVisibilityBehaviorMixin:EvaluateVisibility(force)
	local visible = self:GetScrollBox():HasScrollableExtent();
	if not force and visible == self:GetScrollBar():IsShown() then
		return;
	end

	self:GetScrollBar():SetShown(visible);

	if self.scrollBoxAnchorsWithBar and self.scrollBoxAnchorsWithoutBar then
		local anchors = visible and self.scrollBoxAnchorsWithBar or self.scrollBoxAnchorsWithoutBar;
		if self.appliedAnchors == anchors then
			return;
		end
		self.appliedAnchors = anchors;

		local scrollBox = self:GetScrollBox();
		scrollBox:ClearAllPoints();

		-- Issue here to resolve:
		-- This will invalidate the ScrollBox and scroll target rects, preventing layout calculations from
		-- being correct in grid view. The incorrect calculations are overwritten by doing a full update
		-- in the size changed handler (see OnScrollTargetSizeChanged in ScrollBox.lua).
		local clearAllPoints = false;
		for index, anchor in ipairs(anchors) do
			anchor:SetPoint(scrollBox, clearAllPoints);
		end
	end

	self:TriggerEvent(ManagedScrollBarVisibilityBehaviorMixin.Event.OnVisibilityChanged, visible);
end

function ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)
	local behavior = CreateFromMixins(ManagedScrollBarVisibilityBehaviorMixin);
	behavior:Init(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
	return behavior;
end

SelectionBehaviorMixin = CreateFromMixins(CallbackRegistryMixin);

SelectionBehaviorFlags = FlagsUtil.MakeFlags("Deselectable", "Intrusive");

SelectionBehaviorMixin:GenerateCallbackEvents(
	{
		"OnSelectionChanged",
	}
);

function SelectionBehaviorMixin.IsIntrusiveSelected(frame)
	if frame then
		return SelectionBehaviorMixin.IsElementDataIntrusiveSelected(frame:GetElementData());
	end
	return false;
end

-- Intrusive accessors
function SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData)
	if elementData then
		return not not elementData.selected;
	end
	return false;
end

-- Extrusive accessors (default)
function SelectionBehaviorMixin:IsSelected(frame)
	if frame then
		return self:IsElementDataSelected(frame:GetElementData());
	end
	return false;
end

function SelectionBehaviorMixin:IsElementDataSelected(elementData)
	if elementData then
		return (self.selections and self.selections[elementData] == true) or (not not elementData.selected);
	end
	return false;
end

-- "..." are SelectionBehaviorFlags
function SelectionBehaviorMixin:Init(scrollBox, ...)
	CallbackRegistryMixin.OnLoad(self);

	self.scrollBox = scrollBox;
	self.selectionFlags = CreateFromMixins(FlagsMixin);
	self.selectionFlags:OnLoad();

	self:SetSelectionFlags(...);

	if not self.selectionFlags:IsSet(SelectionBehaviorFlags.Intrusive) then
		self.selections = {};
	end
end

function SelectionBehaviorMixin:SetSelectionFlags(...)
	for index = 1, select("#", ...) do
		self.selectionFlags:Set(select(index, ...));
	end
end

function SelectionBehaviorMixin:HasSelection()
	return #self:GetSelectedElementData() > 0;
end

function SelectionBehaviorMixin:GetFirstSelectedElementData()
	local selected = self:GetSelectedElementData();
	return selected[1];
end

function SelectionBehaviorMixin:GetSelectedElementData()
	local selected = {};
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		for index, elementData in dataProvider:Enumerate() do
			if self:IsElementDataSelected(elementData) then
				table.insert(selected, elementData);
			end
		end
	end
	return selected;
end

function SelectionBehaviorMixin:IsFlagSet(flag)
	return self.selectionFlags:IsSet(flag);
end

function SelectionBehaviorMixin:DeselectByPredicate(predicate)
	local deselected = {};
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		for index, elementData in dataProvider:Enumerate() do
			if predicate(elementData) then
				self:SetElementDataSelected_Internal(elementData, false);
				table.insert(deselected, elementData);
			end
		end
	end
	return deselected;
end

function SelectionBehaviorMixin:DeselectSelectedElements()
	return self:DeselectByPredicate(function(elementData)
		return self:IsElementDataSelected(elementData);
	end);
end

function SelectionBehaviorMixin:ClearSelections()
	local deselected = self:DeselectSelectedElements();
	for index, data in ipairs(deselected) do
		self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, data, false);
	end
end

function SelectionBehaviorMixin:ToggleSelectElementData(elementData)
	local oldSelected = self:IsElementDataSelected(elementData);
	if oldSelected and not self:IsFlagSet(SelectionBehaviorFlags.Deselectable) then
		return;
	end

	local newSelected = not oldSelected;
	self:SetElementDataSelected_Internal(elementData, newSelected);
end

function SelectionBehaviorMixin:SelectElementData(elementData)
	self:SetElementDataSelected_Internal(elementData, true);
end

function SelectionBehaviorMixin:SelectElementDataByPredicate(predicate)
	local elementData = self.scrollBox:FindElementDataByPredicate(predicate);
	if elementData then
		self:SelectElementData(elementData);
	end
	return elementData;
end

function SelectionBehaviorMixin:SetElementDataSelected_Internal(elementData, newSelected)
	local deselected = nil;
	if newSelected then
		-- Works under the current single selection policy. When multi-select is added,
		-- change this.
		deselected = self:DeselectByPredicate(function(data)
			return data ~= elementData and self:IsElementDataSelected(data);
		end);
	end

	local changed = self:IsElementDataSelected(elementData) ~= newSelected;
	if self.selectionFlags:IsSet(SelectionBehaviorFlags.Intrusive) then
		elementData.selected = newSelected;
	else
		self.selections[elementData] = newSelected;
	end

	if deselected then
		for index, data in ipairs(deselected) do
			self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, data, false);
		end
	end

	if changed then
		self:TriggerEvent(SelectionBehaviorMixin.Event.OnSelectionChanged, elementData, newSelected);
	end
end

function SelectionBehaviorMixin:Select(frame)
	self:SelectElementData(frame:GetElementData());
end

function SelectionBehaviorMixin:ToggleSelect(frame)
	self:ToggleSelectElementData(frame:GetElementData());
end

function ScrollUtil.AddSelectionBehavior(scrollBox, ...)
	local behavior = CreateFromMixins(SelectionBehaviorMixin);
	behavior:Init(scrollBox, ...);
	return behavior;
end

-- Frame must support the OnSizeChanged callback (EventButton).
function ScrollUtil.AddResizableChildrenBehavior(scrollBox)
	local onSizeChanged = function(o, width, height)
		--[[
			Few issues here to resolve:
			1) This is called if the size changed during layout or acquire.
			2) We're invalidating every calculated element extent instead of the element that changed.
			3) We cannot update immediately because of a rentrant frame flag invalidation issue.
		]]
		scrollBox:FullUpdate(ScrollBoxConstants.UpdateQueued);
	end;

	local onSubscribe = function(frame, elementData)
		if CallbackRegistryMixin.DoesFrameHaveEvent(frame, EventFrameMixin.Event.OnSizeChanged) then
			frame:RegisterCallback(EventFrameMixin.Event.OnSizeChanged, onSizeChanged, scrollBox);
		end
	end

	local onAcquired = function(o, frame, elementData)
		onSubscribe(frame, elementData);
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, onAcquired, onAcquired);

	local onReleased = function(o, frame, elementData)
		if CallbackRegistryMixin.DoesFrameHaveEvent(frame, EventFrameMixin.Event.OnSizeChanged) then
			frame:UnregisterCallback(BaseScrollBoxEvents.OnSizeChanged, scrollBox);
		end
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);

	scrollBox:ForEachFrame(onSubscribe);
end

function ScrollUtil.RegisterTableBuilder(scrollBox, tableBuilder, elementDataTranslator)
	local onInitialized = function(o, frame, elementData)
		tableBuilder:AddRow(frame, elementDataTranslator(elementData));
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, onInitialized, onInitialized);

	local onReleased = function(o, frame, elementData)
		tableBuilder:RemoveRow(frame, elementDataTranslator(elementData));
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);
end

function ScrollUtil.CalculateScrollBoxElementExtent(count, frameExtent, spacing)
	return (count * frameExtent) + (math.max(0, count-1) * spacing);
end

ScrollBoxFactoryInitializerMixin = {};

function ScrollBoxFactoryInitializerMixin:Init(frameTemplate)
	self.frameTemplate = frameTemplate;
end

function ScrollBoxFactoryInitializerMixin:GetTemplate()
	assert(self.frameTemplate);
	return self.frameTemplate;
end

function ScrollBoxFactoryInitializerMixin:GetExtent()
	return nil;
end

function ScrollBoxFactoryInitializerMixin:Factory(factory, initializer)
	factory(self:GetTemplate(), initializer);
end

function ScrollBoxFactoryInitializerMixin:InitFrame(frame)
	if frame.Init then
		frame:Init(self);
	end
end

function ScrollBoxFactoryInitializerMixin:Resetter(frame)
	if frame.Release then
		frame:Release(self);
	end
end

function ScrollBoxFactoryInitializerMixin:IsTemplate(frameTemplate)
	return frameTemplate == self.frameTemplate;
end