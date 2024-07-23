
local function ContainsCursor(frame, cx, cy)
	return cy <= frame:GetTop() and cy >= frame:GetBottom()
		and cx >= frame:GetLeft() and cx <= frame:GetRight();
end

local function ContainsCursorVertically(frame, cy)
	return cy <= frame:GetTop() and cy >= frame:GetBottom();
end

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

local function ConvertScrollPercentage(messageFrame, scrollPercentage)
	if messageFrame:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
		return scrollPercentage;
	end
	return 1.0 - scrollPercentage;
end

function ScrollUtil.InitScrollingMessageFrameWithScrollBar(messageFrame, scrollBar, noMouseWheel)
	-- Prevent message frame outbound messages from interferring with scroll bar while a drag or hold
	-- is in progress.
	scrollBar:EnableInternalPriority();

	-- Require snapping so that any scrollbar position changes cannot occur without a corresponding
	-- SMF offset change.
	scrollBar:EnableSnapToInterval();

	messageFrame:AddOnDisplayRefreshedCallback(function(messageFrame)
		local maxScrollRange = messageFrame:GetMaxScrollRange();
		local scrollPercentage = 0;
		local panExtentPercentage = 0;
		if maxScrollRange > 0 then
			scrollPercentage = messageFrame:GetScrollOffset() / maxScrollRange;
			panExtentPercentage = 1 / maxScrollRange;
		end

		scrollPercentage = ConvertScrollPercentage(messageFrame, scrollPercentage);
		scrollBar:SetScrollPercentage(scrollPercentage, ScrollBoxConstants.NoScrollInterpolation);

		local visibleExtentPercentage = 0;
		local messages = messageFrame:GetNumMessages();
		if messages > 1 then
			visibleExtentPercentage = 1 / messages;
		end

		scrollBar:SetVisibleExtentPercentage(visibleExtentPercentage);
		scrollBar:SetPanExtentPercentage(panExtentPercentage);
	end);

	if not noMouseWheel then
		local function onMouseWheel(scrollFrame, value)
			value = NegateIf(value, scrollFrame:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP);
			messageFrame:ScrollByAmount(value * 3);
		end
		messageFrame:EnableMouseWheel(true);
		messageFrame:SetScript("OnMouseWheel", onMouseWheel);
	end

	local onScrollBarScroll = function(o, scrollPercentage)
		scrollPercentage = ConvertScrollPercentage(messageFrame, scrollPercentage);
		local scrollOffset = math.floor((scrollPercentage * messageFrame:GetMaxScrollRange()) + .0001);
		messageFrame:SetScrollOffset(scrollOffset);
	end;
	scrollBar:RegisterCallback(BaseScrollBoxEvents.OnScroll, onScrollBarScroll, messageFrame);
end

-- Compatible with "ScrollFrameTemplate"
function ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar)
	local onVerticalScroll = function(scrollFrame, offset)
		local verticalScrollRange = scrollFrame:GetVerticalScrollRange();
		local scrollPercentage = 0;
		if verticalScrollRange > 0 then
			scrollPercentage = offset / verticalScrollRange;
		end
		scrollBar:SetScrollPercentage(scrollPercentage, ScrollBoxConstants.NoScrollInterpolation);
	end

	scrollFrame:SetScript("OnVerticalScroll", onVerticalScroll);
	
	scrollFrame.GetPanExtent = function(self)
		return self.panExtent;
	end

	scrollFrame.SetPanExtent = function(self, panExtent)
		self.panExtent = panExtent;
	end
	
	-- 30 is used in the absence of accurate individual element extents.
	-- Anything larger will require multiple scrolls of the mouse, but shouldn't 
	-- be too much friction to be annoying.
	scrollFrame:SetPanExtent(30);

	local onScrollRangeChanged = function(scrollFrame, hScrollRange, vScrollRange)
		onVerticalScroll(scrollFrame, scrollFrame:GetVerticalScroll());

		local visibleExtentPercentage = 0;
		local height = scrollFrame:GetHeight();
		if height > 0 then
			visibleExtentPercentage = height / (vScrollRange + height);
		end

		scrollBar:SetVisibleExtentPercentage(visibleExtentPercentage);

		local panExtentPercentage = 0;
		local verticalScrollRange = scrollFrame:GetVerticalScrollRange();
		if verticalScrollRange > 0 then
			panExtentPercentage = Saturate(scrollFrame:GetPanExtent() / verticalScrollRange);
		end
		scrollBar:SetPanExtentPercentage(panExtentPercentage);
	end;

	scrollFrame:SetScript("OnScrollRangeChanged", onScrollRangeChanged);

	local onMouseWheel = function(scrollFrame, value)
		scrollBar:ScrollStepInDirection(-value);
	end

	scrollFrame:SetScript("OnMouseWheel", onMouseWheel);

	local onScrollBarScroll = function(o, scrollPercentage)
		local scroll = scrollPercentage * scrollFrame:GetVerticalScrollRange();
		scrollFrame:SetVerticalScroll(scroll);
	end;
	scrollBar:RegisterCallback(BaseScrollBoxEvents.OnScroll, onScrollBarScroll, scrollFrame);
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
	if self.scrollBox:HasDataProvider() then
		for index, elementData in self.scrollBox:EnumerateDataProviderEntireRange() do
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
	if self.scrollBox:HasDataProvider() then
		for index, elementData in self.scrollBox:EnumerateDataProviderEntireRange() do
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

function SelectionBehaviorMixin:SelectFirstElementData(predicate)
	-- Select the first element which satisfies the predicate
	for index, elementData in self.scrollBox:EnumerateDataProviderEntireRange() do
		if not predicate or predicate(elementData) then
			self:SelectElementData(elementData);
			return;
		end
	end
end

function SelectionBehaviorMixin:SelectNextElementData(predicate)
	return self:SelectOffsetElementData(1, predicate);
end

function SelectionBehaviorMixin:SelectPreviousElementData(predicate)
	return self:SelectOffsetElementData(-1, predicate);
end

function SelectionBehaviorMixin:SelectOffsetElementData(offset, predicate)
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		local currentElementData = self:GetFirstSelectedElementData();
		local currentIndex = dataProvider:FindIndex(currentElementData);
		local offsetIndex = currentIndex + offset;
		local searchOffset = offset > 0 and 1 or -1;

		-- Find the first element data which satisfies the predicate
		-- Starting at the current offsetIndex and moving in the direction of the offset
		local offsetElementData = dataProvider:Find(offsetIndex);
		while offsetElementData do
			if not predicate or predicate(offsetElementData) then
				self:SelectElementData(offsetElementData);
				return offsetElementData, offsetIndex;
			end

			offsetIndex = offsetIndex + searchOffset;
			offsetElementData = dataProvider:Find(offsetIndex);
		end
	end
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

DragIntersectionArea =
{
	Below = 1,
	Above = 2,
	Inside = 3,
};

ScrollBoxDragBehavior = {};

-- Returns a cursor y relative to the bottom of the frame, and the height of the frame accounting for insets.
local function GetRelativeCursorRange(frame, cy, dragBehavior)
	local insetBottom, insetTop = dragBehavior:GetCursorHitInsets();
	local bottom = frame:GetBottom() + insetBottom;
	local height = frame:GetHeight() - (insetBottom + insetTop);
	local relativeCursorY = cy - bottom;
	return relativeCursorY, height;
end

local function GetAreaOfRelativeCursor(dragBehavior, relativeCursorY, height, frame)
	local destinationData = {};
	local parentFrame = dragBehavior.childToParent[frame];
	if parentFrame then
		destinationData.parentElementData = parentFrame:GetElementData();
	end

	local contextData = {
		sourceData = dragBehavior.sourceData,
		destinationData = destinationData,
	}

	local elementData = frame:GetElementData();
	local areaMargin = dragBehavior:GetAreaIntersectMargin(elementData, sourceElementData, contextData);
	if relativeCursorY < areaMargin then
		return DragIntersectionArea.Below;
	elseif relativeCursorY + areaMargin > height then
		return DragIntersectionArea.Above;
	end
	return DragIntersectionArea.Inside;
end

function ScrollBoxDragBehavior:Init(scrollBox)
	scrollBox.dragBehavior = self;
	
	self.dragging = false;
	self.dragEnabled = true;
	self.candidate = {};
	self.lastCandidate = {};
	self.scrollBox = scrollBox;
	self.delegate = scrollBox.DragDelegate;
	self.delegate.pools = CreateFramePoolCollection();
	self.childToParent = {};

	self.dropPreviewFactory = function(template)
		local frame = self:AcquireFromPool(template);
		self.dropPreview = frame;

		frame:Show();
		frame:ClearAllPoints();
		frame:SetParent(scrollBox);
		frame:SetFrameStrata("DIALOG");
		return frame;
	end
end

function ScrollBoxDragBehavior:RebuildOnDrop()
	local hasDraggableChildren = (self.getChildrenFrames ~= nil) and (self.getChildrenElementData ~= nil);
	return hasDraggableChildren;
end

function ScrollBoxDragBehavior:ClearCandidate()
	wipe(self.candidate);
end

function ScrollBoxDragBehavior:GetDragging()
	return self.dragging;
end

function ScrollBoxDragBehavior:SetDragging(dragging)
	self.dragging = dragging;
end

function ScrollBoxDragBehavior:SetDragEnabled(dragEnabled)
	self.dragEnabled = dragEnabled;
end

function ScrollBoxDragBehavior:IsDragEnabled()
	return self.dragEnabled;
end

-- areaMargin can be a number or function:
-- areaMargin(elementData, sourceElementData, contextData)
function ScrollBoxDragBehavior:SetAreaIntersectMargin(areaMargin)
	if type(margin) == "number" then
		self.areaMargin = math.max(areaMargin, 0);
	else
		self.areaMargin = areaMargin;
	end
end

function ScrollBoxDragBehavior:GetAreaIntersectMargin(elementData, sourceElementData, contextData)
	if not self.areaMargin then
		return 5;
	end

	if type(self.areaMargin) == "number" then
		return self.areaMargin;
	end

	return self.areaMargin(elementData, sourceElementData, contextData);
end

function ScrollBoxDragBehavior:GetNotifyDragStart()
	return self.notifyDragStart;
end

function ScrollBoxDragBehavior:SetNotifyDragStart(notifyDragStart)
	self.notifyDragStart = notifyDragStart;
end

--[[
dragPredicate: function(frame, elementData)
]]
function ScrollBoxDragBehavior:GetDragPredicate()
	return self.dragPredicate;
end

function ScrollBoxDragBehavior:SetDragPredicate(dragPredicate)
	self.dragPredicate = dragPredicate;
end

function ScrollBoxDragBehavior:GetDragRelativeToCursor()
	return self.dragRelativeToCursor;
end

function ScrollBoxDragBehavior:SetDragRelativeToCursor(dragRelativeToCursor)
	self.dragRelativeToCursor = dragRelativeToCursor;
end

function ScrollBoxDragBehavior:SetNotifyDropCandidates(notifyDropCandidates)
	self.notifyDropCandidates = notifyDropCandidates;
end

function ScrollBoxDragBehavior:GetNotifyDropCandidates()
	return self.notifyDropCandidates;
end

function ScrollBoxDragBehavior:SetNotifyDragReceived(dragReceived)
	self.notifyDragReceived = dragReceived;
end

function ScrollBoxDragBehavior:GetNotifyDragReceived()
	return self.notifyDragReceived;
end

--[[
See ScrollUtil.GenerateCursorFactory for example.
cursorFactory: function(elementData)
]]
function ScrollBoxDragBehavior:GetCursorFactory()
	if not self.cursorFactory then
		self.cursorFactory = ScrollUtil.GenerateCursorFactory(self.scrollBox);
	end
	return self.cursorFactory;
end

function ScrollBoxDragBehavior:SetCursorFactory(cursorFactory)
	self.cursorFactory = cursorFactory;
end

--[[
dropLeave: function(candidate)
]]
function ScrollBoxDragBehavior:GetDropLeave()
	return self.dropLeave;
end

function ScrollBoxDragBehavior:SetDropLeave(dropLeave)
	self.dropLeave = dropLeave;
end

--[[
dropEnter: function(factory, candidate)
]]
function ScrollBoxDragBehavior:GetDropEnter()
	return self.dropEnter;
end

function ScrollBoxDragBehavior:SetDropEnter(dropEnter)
	self.dropEnter = dropEnter;
end

--[[
dropPredicate = function(sourceElementData, contextData)
]]
function ScrollBoxDragBehavior:GetDropPredicate()
	return self.dropPredicate;
end

function ScrollBoxDragBehavior:SetDropPredicate(dropPredicate)
	self.dropPredicate = dropPredicate;
end

--[[
postDrop = function(contextData)
]]
function ScrollBoxDragBehavior:GetPostDrop()
	return self.postDrop;
end

function ScrollBoxDragBehavior:SetPostDrop(postDrop)
	self.postDrop = postDrop;
end

--[[
funalizeDrop = function(contextData)
]]
function ScrollBoxDragBehavior:GetFinalizeDrop()
	return self.finalizeDrop;
end

function ScrollBoxDragBehavior:SetFinalizeDrop(finalizeDrop)
	self.finalizeDrop = finalizeDrop;
end

--[[
getChildrenFrames = function(frame)
]]
function ScrollBoxDragBehavior:GetChildrenFrames()
	return self.getChildrenFrames;
end

function ScrollBoxDragBehavior:SetGetChildrenFrames(getChildrenFrames)
	self.getChildrenFrames = getChildrenFrames;
end

--[[
getChildrenElementData = function(elementData)
]]
function ScrollBoxDragBehavior:GetChildrenElementData()
	return self.getChildrenElementData;
end

function ScrollBoxDragBehavior:SetGetChildrenElementData(getChildrenElementData)
	self.getChildrenElementData = getChildrenElementData;
end

function ScrollBoxDragBehavior:GetChildrenElementDataTbl(parentElementData)
	return self.getChildrenElementData and self.getChildrenElementData(parentElementData) or nil;
end

function ScrollBoxDragBehavior:SetReorderable(reorderable)
	self.reorderable = reorderable;
end

function ScrollBoxDragBehavior:GetReorderable()
	return self.reorderable;
end

function ScrollBoxDragBehavior:GetCursorHitInsets()
	local cursorHitInsets = self.cursorHitInsets;
	if not cursorHitInsets then
		return 0, 0;
	end
	
	local bottom = cursorHitInsets.bottom or 0;
	local top = cursorHitInsets.top or 0;
	return bottom, top;
end

function ScrollBoxDragBehavior:SetCursorHitInsets(bottom, top)
	self.cursorHitInsets = {bottom = bottom, top = top};
end

function ScrollBoxDragBehavior:ScrollBoxContainsCursor(cx, cy)
	return ContainsCursor(self.scrollBox, cx, cy);
end

function ScrollBoxDragBehavior:ReleaseToPool(frame)
	self.delegate.pools:Release(frame);
end

function ScrollBoxDragBehavior:AcquireFromPool(template)
	local templateInfo = C_XMLUtil.GetTemplateInfo(template);
	local cursorParent = FrameUtil.GetRootParent(self.scrollBox);
	local pool = self.delegate.pools:GetOrCreatePool(templateInfo.type, cursorParent, template);
	return pool:Acquire();
end

function ScrollBoxDragBehavior:AbortDrag()
	self.delegate:AbortDrag();
end

function ScrollBoxDragBehavior:NotifyStateInternal(frame, dragging)
	if frame:GetElementData() == self.sourceData.elementData then
		local notifyDragStart = self:GetNotifyDragStart();
		if notifyDragStart then
			notifyDragStart(frame, dragging);
		end	
	else
		local notifyDropCandidates = self:GetNotifyDropCandidates();
		if notifyDropCandidates then
			notifyDropCandidates(frame, dragging, self.sourceData.elementData);
		end
	end
end

function ScrollBoxDragBehavior:NotifyState(frame, dragging)
	self:NotifyStateInternal(frame, dragging);

	local getChildrenFrames = self:GetChildrenFrames();
	local childrenFrames = getChildrenFrames and getChildrenFrames(frame);
	if childrenFrames then
		for index, childFrame in ipairs(childrenFrames) do
			self:NotifyStateInternal(childFrame, dragging);
		end
	end
end
	
function ScrollBoxDragBehavior:NotifyStates(dragging)
	for index, frame in self.scrollBox:EnumerateFrames() do
		self:NotifyState(frame, dragging);
	end
end
	
function ScrollBoxDragBehavior:ClearDropPreview()
	self:DropLeave();

	if self.dropPreview then
		self:ReleaseToPool(self.dropPreview);
		self.dropPreview = nil;
	end
end
		
function ScrollBoxDragBehavior:DropLeave()
	-- The frame may have released. If so, avoid any notification as the caller can't get to the
	-- data that would inform them what type of frame it was to undo any effect.
	local candidate = self.lastCandidate;
	if not candidate or not candidate.frame or not candidate.frame.GetElementData then
		return;
	end

	local dropLeave = self:GetDropLeave();
	if dropLeave then
		dropLeave(candidate);
	end
end

function ScrollBoxDragBehavior:FindFrame(elementData)
	for _, frame in self.scrollBox:EnumerateFrames() do
		if frame:GetElementData() == elementData then
			return frame;
		end

		local getChildrenFrames = self:GetChildrenFrames();
		local childrenFrames = getChildrenFrames and getChildrenFrames(frame);
		if childrenFrames then
			for _, childFrame in ipairs(childrenFrames) do
				if childFrame:GetElementData() == elementData then
					return frame;
				end
			end
		end
	end
end

local function GetPanFactor(elapsed, delta)
	local coef = 4;
	local range = 50;
	local v = Clamp(math.abs(delta) / range, 0, 1);
	return coef * elapsed * math.max(.1, math.pow(v, 3));
end

function ScrollBoxDragBehavior:TryVerticalEdgeScroll(elapsed, cx, cy)
	local top = self.scrollBox:GetTop();
	local topDelta = cy - top;
	if topDelta > 0 then
		local panFactor = GetPanFactor(elapsed, topDelta);
		self.scrollBox:ScrollDecrease(panFactor);
	else
		local bottom = self.scrollBox:GetBottom();
		local bottomDelta = cy - bottom;
		if bottomDelta < 0 then
			local panFactor = GetPanFactor(elapsed, bottomDelta);
			self.scrollBox:ScrollIncrease(panFactor);
		end
	end
end

function ScrollBoxDragBehavior:Register(onDragStop, onDragUpdate)
	local cursorParent = FrameUtil.GetRootParent(self.scrollBox);

	local function OnDragStopInternal()
		self.delegate:SetScript("OnUpdate", nil);

		self:DropLeave();
		self:NotifyStates(false);

		-- Will release both the cursor and drop preview frames.
		self.delegate.pools:ReleaseAll();
		self.dropPreview = nil;
		self.cursorFrame = nil;
		self:SetDragging(false);

		-- Save the current scroll offset and reapply it if any changes occurred.
		local scrollOffset = self.scrollBox:GetDerivedScrollOffset();
		local handled = onDragStop();
		if handled then
			self.scrollBox:ScrollToOffset(scrollOffset);

			-- Because the drop operation can easily affect the positions of elements other than the drag or drop
			-- candidate, it is inferred that the data provider will need to be parsed anyways to process all of
			-- the element order changes. Also passing both the new and old state of the source and destination data
			-- for ease of finding where elements were removed or inserted from.
			local contextData = 
			{
				dataProvider = self.scrollBox:GetDataProvider(),
			};

			if self.dropResult then
				MergeTable(contextData, self.dropResult);
			end

			local postDrop = self:GetPostDrop();
			if postDrop then
				postDrop(contextData);
			end

			-- Will rebuild if any child frames were involved in the drop.
			if self:RebuildOnDrop() then
				self.scrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition);
			end

			local finalizeDrop = self:GetFinalizeDrop();
			if finalizeDrop then
				finalizeDrop(contextData);
			end
		end

		self:ClearCandidate();
	end

	self.delegate:SetScript("OnDragStop", OnDragStopInternal);

	local function OnDragStartInternal(frame)
		if not self:IsDragEnabled() then
			-- Dragging is explicitly disabled.
			return;
		end

		local dragPredicate = self:GetDragPredicate();
		if dragPredicate and not dragPredicate(frame, frame:GetElementData()) then
			-- Cannot drag this frame.
			return;
		end

		
		-- The drag operation is transfered to a delegate frame that is always visible so that the dragging continues after
		-- the frame the OnDragStart actually originated from becomes hidden. If this returns false, it indicates capture was
		-- already released, which could be the case if the frame was quickly hidden before this event was received.
		if not frame:InterceptStartDrag(self.delegate) then
			return;
		end

		self:SetDragging(true);

		self.sourceData = {
			elementData = frame:GetElementData(),
			elementDataIndex = frame:GetElementDataIndex();
		};

		local parentFrame = self.childToParent[frame];
		if parentFrame then
			self.sourceData.parentElementData = parentFrame:GetElementData();
		end

		local elementData = self.sourceData.elementData;

		local cursorFactory = self:GetCursorFactory();
		local cursorTemplate, cursorInitializer = cursorFactory(elementData);
		local cursorFrame = self:AcquireFromPool(cursorTemplate);
		self.cursorFrame = cursorFrame;
		cursorFrame:SetMouseMotionEnabled(false);
		cursorFrame:SetMouseClickEnabled(false);
		cursorFrame:SetFrameStrata("DIALOG");
		cursorFrame:Show();
		if cursorInitializer then
			cursorInitializer(cursorFrame, frame, elementData);
		end

		self:NotifyStates(true);

		local dx, dy = 0, 0;
		if self:GetDragRelativeToCursor() then
			local cx, cy = InputUtil.GetCursorPosition(cursorParent);
			dx = cx - frame:GetLeft();
			dy = cy - frame:GetTop();
		end

		self.delegate:SetScript("OnUpdate", function(delegateFrame, elapsed)
			local cx, cy = InputUtil.GetCursorPosition(cursorParent);
			local x, y = cx - dx, cy - dy;
			self.cursorFrame:SetPoint("TOPLEFT", x, y - cursorParent:GetHeight());

			self:TryVerticalEdgeScroll(elapsed, cx, cy);

			if not self:GetReorderable() then
				return;
			end

			local shallow = true;
			-- self.candidate will be updated on return from the onDragUpdate call. Retain the last candidate
			-- so we can notify of a change, if any.
			self.lastCandidate = CopyTable(self.candidate, shallow);
			self:ClearCandidate();

			local cannotFindCandidate = false;
			local containsCursor = self:ScrollBoxContainsCursor(cx, cy);
			if not containsCursor then
				cannotFindCandidate = true;
			elseif not onDragUpdate(cx, cy) then
				cannotFindCandidate = true;
			end

			if cannotFindCandidate then
				self:ClearDropPreview();
				return;
			end

			local changed = self.lastCandidate.frame ~= self.candidate.frame or self.lastCandidate.area ~= self.candidate.area;
			if not changed then
				-- A valid candidate was found, but was already our current candidate. Keep the
				-- current preview and return.
				return;
			end

			-- Discard the current preview and create a new one.
			self:ClearDropPreview();

			local dropEnter = self:GetDropEnter();
			if dropEnter then
				dropEnter(self.dropPreviewFactory, self.candidate);
			end

			if self.dropPreview then
				self.dropPreview:Show();
			end
		end);
	end

	local onInitialized = function(o, frame, elementData)
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnDragStart", OnDragStartInternal);
		
		local notifyDragReceived = self:GetNotifyDragReceived();
		frame:SetScript("OnReceiveDrag", notifyDragReceived);

		local getChildrenFrames = self:GetChildrenFrames();
		local childrenFrames = getChildrenFrames and getChildrenFrames(frame);
		if childrenFrames then
			for index, childFrame in ipairs(childrenFrames) do
				self.childToParent[childFrame] = frame;

				childFrame:RegisterForDrag("LeftButton");
				childFrame:SetScript("OnDragStart", OnDragStartInternal);
				childFrame.GetElementData = function()
					-- The underlying elementData representing this frame cannot be captured else it will refer
					-- to the wrong elementData after a drag operation has shifted it's position. This is also true
					-- of the table containing each child, as it may be replaced rather than emptied or wiped.
					local elementDatas = self:GetChildrenElementDataTbl(elementData);
					return elementDatas[index];
				end;

				childFrame.GetElementDataIndex = function(self)
					return index;
				end;
			end
		end

		if self:GetDragging() then
			self:NotifyState(frame, true);
		end
	end;

	self.scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, onInitialized, onInitialized);

	local onReleased = function(o, frame, elementData)
		if self:GetDragging() then
			self:NotifyState(frame, false);
		end

		frame:SetScript("OnDragStart", nil);
		frame:SetScript("OnReceiveDrag", nil);
	end;
	self.scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);
end

function CreateScrollBoxDragBehavior(scrollBox)
	local dragBehavior = CreateFromMixins(ScrollBoxDragBehavior);
	dragBehavior:Init(scrollBox);
	return dragBehavior;
end

local function GetTreeCursorIntersectionArea(frame, cy, dragBehavior)
	local relativeCursorY, height = GetRelativeCursorRange(frame, cy, dragBehavior);
	-- Unlike linear, tree interactions require the cursor to be within the frame bounds.
	if relativeCursorY < 0 or relativeCursorY > height then
		return nil;
	end

	return GetAreaOfRelativeCursor(dragBehavior, relativeCursorY, height, frame);
end

function ScrollUtil.AddTreeDragBehavior(scrollBox)
	local dragBehavior = CreateScrollBoxDragBehavior(scrollBox);

	local function OnDragUpdate(cx, cy)
		local sourceData = dragBehavior.sourceData;
		local sourceElementData = sourceData.elementData;
		local sourceElementDataIndex = sourceData.elementDataIndex;

		local candidate = dragBehavior.candidate;
		
		scrollBox:ForEachFrame(function(frame, elementData)
			if sourceElementData == elementData then
				return ScrollBoxConstants.ContinueIteration;
			end

			local parent = elementData:GetParent();
			while parent do
				if parent == sourceElementData then
					return ScrollBoxConstants.ContinueIteration;
				end
				parent = parent:GetParent();
			end

			local area = GetTreeCursorIntersectionArea(frame, cy, dragBehavior);
			if area then
				candidate.frame = frame;
				candidate.area = area;
				candidate.elementData = elementData;

				local elementDataIndex = frame:GetElementDataIndex();
				if elementDataIndex < sourceElementDataIndex then
					return ScrollBoxConstants.StopIteration;
				end
			end
		end);

		return candidate.frame ~= nil;
	end

	local function OnDragStop()
		local sourceData = dragBehavior.sourceData;
		local sourceElementData = sourceData.elementData;

		local candidate = dragBehavior.candidate;
		local elementData = candidate.elementData;
		local area = candidate.area;
		if elementData and area then
			if area == DragIntersectionArea.Below then
				local parent = elementData:GetParent();
				parent:MoveNodeRelativeTo(sourceElementData, elementData, 1);
			elseif area == DragIntersectionArea.Inside then
				elementData:MoveNode(sourceElementData);
			elseif area == DragIntersectionArea.Above then
				local parent = elementData:GetParent();
				parent:MoveNodeRelativeTo(sourceElementData, elementData, 0);
			end

			dragBehavior.dropResult = {};
			return true;
		end
		return false;
	end
	
	dragBehavior:Register(OnDragStop, OnDragUpdate);
	return dragBehavior;
end

function ScrollUtil.GenerateCursorFactory(scrollBox)
	local function CursorFactory(elementData)
		local view = scrollBox:GetView();
		
		local function CursorInitializer(cursorFrame, candidateFrame, elementData)
			cursorFrame:SetSize(candidateFrame:GetSize());
	
			-- Uses the candidate frame's initializer on the cursor frame.
			local template, initializer = view:GetFactoryDataFromElementData(elementData);
			if initializer then
				initializer(cursorFrame, elementData);
			end
		end

		local template = view:GetFactoryDataFromElementData(elementData);
		return template, CursorInitializer;
	end
	return CursorFactory;
end

function ScrollUtil.AddLinearDragBehavior(scrollBox)
	local dragBehavior = CreateScrollBoxDragBehavior(scrollBox);
	
	local function GetArea(frame, cy)
		local relativeCursorY, height = GetRelativeCursorRange(frame, cy, dragBehavior);
		return GetAreaOfRelativeCursor(dragBehavior, relativeCursorY, height, frame);
	end

	local function FindIntersect(frames, cy)
		if not frames then
			return nil;
		end

		local last;
		for index, frame in ipairs(frames) do
			local elementData = frame:GetElementData();
			-- If the frame is configured to support child drags, and the cursor is contained
			-- by the frame, then we return any intersection result that is returned. 
			if ContainsCursorVertically(frame, cy) then
				local getChildrenFrames = dragBehavior:GetChildrenFrames();
				local childrenFrames = getChildrenFrames and getChildrenFrames(frame);
				local childData = FindIntersect(childrenFrames, cy);
				if childData then
					childData.parentElementData = elementData;
					return childData;
				end
			end

			local area = GetArea(frame, cy);
			local data = 
			{
				area = area,
				frame = frame,
				elementData = elementData,
				prevFrame = frames[index - 1],
				nextFrame = frames[index + 1],
			};

			if area == DragIntersectionArea.Above then
				return data;
			elseif area == DragIntersectionArea.Inside then
				return data;
			elseif area == DragIntersectionArea.Below then
				last = data;
			end
		end
	
		return last;
	end

	-- Cannot intersect with a frame above, below, or inside itself.
	local function AllowIntersect(intersectData)
		if not intersectData then
			return false;
		end

		local sourceElementData = dragBehavior.sourceData.elementData;

		-- Cannot intersect with itself
		if intersectData.elementData == sourceElementData then
			return false;
		end

		if intersectData.area == DragIntersectionArea.Below then
			local nextFrame = intersectData.nextFrame;
			if nextFrame and nextFrame:GetElementData() == sourceElementData then
				return false;
				end
		elseif intersectData.area == DragIntersectionArea.Above then
			local prevFrame = intersectData.prevFrame;
			if prevFrame and prevFrame:GetElementData() == sourceElementData then
				return false;
			end
		end

		return true;
	end

	local function OnDragUpdate(cx, cy)
		local intersectData = FindIntersect(scrollBox:GetFrames(), cy);
		if not AllowIntersect(intersectData) then
			return false;
		end

		local dropPredicate = dragBehavior:GetDropPredicate();
		if dropPredicate and (not dropPredicate(dragBehavior.sourceData.elementData, intersectData)) then
			return false;
		end

		local candidate = dragBehavior.candidate;
		MergeTable(candidate, intersectData);
		return true;
	end

	local function OnDragStop()
		local candidate = dragBehavior.candidate;
		if candidate.elementData then
			local area = candidate.area;

			local sourceData = dragBehavior.sourceData;
			local destinationData = {
				elementData = candidate.elementData,
				elementDataIndex = candidate.frame:GetElementDataIndex();
				parentElementData = candidate.parentElementData;
			};

			local dataProvider = dragBehavior.scrollBox:GetDataProvider();

			local function Remove(data)
				local elementData = data.elementData;
				local parentElementData = data.parentElementData;
				if parentElementData then
					local childrenData = dragBehavior:GetChildrenElementDataTbl(parentElementData);
					local index = tIndexOf(childrenData, elementData);
					table.remove(childrenData, index);
				else
					dataProvider:Remove(elementData);
				end
			end

			-- The fixed behavior of an Inside intersection is to swap the elements, and Above or Below
			-- is to move an element. These can support other behaviors in the future, but support for that is being
			-- postponed until we have a use case.

			local insertStates = 
			{
				[sourceData.elementData] = {},
				[destinationData.elementData] = {},
			};

			local function Insert(elementData, insertIndex, parentElementData)
				if parentElementData then
					local childrenData = dragBehavior:GetChildrenElementDataTbl(parentElementData);
					table.insert(childrenData, insertIndex, elementData);
					insertStates[elementData].parentElementData = parentElementData;
				else
					dataProvider:InsertAtIndex(elementData, insertIndex);
				end
				insertStates[elementData].insertIndex = insertIndex;
			end

			local isSwap = area == DragIntersectionArea.Inside;
			if isSwap then

				local function SwapInsert(locationData, elementData)
					local insertIndex = locationData.elementDataIndex;
					local parentElementData = locationData.parentElementData;
					Insert(elementData, insertIndex, parentElementData);
				end

				Remove(destinationData);
				Remove(sourceData);
	
				-- The elements need to be reinserted in ascending index order to restore
				-- the desired positions.
				local datas = {sourceData, destinationData};
				table.sort(datas, function(lhs, rhs)
					return lhs.elementDataIndex < rhs.elementDataIndex;
				end);
				SwapInsert(datas[1], datas[2].elementData);
				SwapInsert(datas[2], datas[1].elementData);
			else
				-- If the intersect is beneath the frame, then the insert index is incremented.
				local insertIndex = candidate.frame:GetElementDataIndex();
				if area == DragIntersectionArea.Below then
					insertIndex = insertIndex + 1;
				end

				-- If the source precedes the destination, then it's removal will cause the insert index to be off by 1.
				-- This is only relevant to elements of the same logical parent, which is either the data provider 
				-- root (parentElementData == nil) or the same parent container table.
				if sourceData.parentElementData == destinationData.parentElementData then
					if sourceData.elementDataIndex < destinationData.elementDataIndex then
						insertIndex = insertIndex - 1;
					end
				end

				Remove(sourceData);
			
				local elementData = sourceData.elementData;
				local parentElementData = destinationData.parentElementData;
				Insert(elementData, insertIndex, parentElementData);
			end

			local function GetUpdatedElementState(elementData)
				local state = insertStates[elementData];
				return {
					elementData = elementData,
					elementDataIndex = state.insertIndex,
					parentElementData = state.parentElementData,
				};
			end

			dragBehavior.dropResult = {
				sourceData = sourceData;
				destinationData = destinationData,
				newSourceData = GetUpdatedElementState(sourceData.elementData),
				newDestinationData = GetUpdatedElementState(destinationData.elementData),
				isSwap = isSwap;
			};

			return true;
		end

		return false;
	end
			
	dragBehavior:Register(OnDragStop, OnDragUpdate);
	return dragBehavior;
end

do
	local function ConfigureDragBehavior(dragBehavior)
		dragBehavior:SetDragRelativeToCursor(true);

		dragBehavior:SetNotifyDragStart(function(sourceFrame, dragging)
			sourceFrame:SetAlpha(dragging and .5 or 1);
			sourceFrame:SetMouseMotionEnabled(not dragging);
		end);

		dragBehavior:SetNotifyDropCandidates(function(candidateFrame, dragging, sourceElementData)
			candidateFrame:SetMouseMotionEnabled(not dragging);
		end);

		dragBehavior:SetDropEnter(function(factory, candidate)
			local candidateArea = candidate.area;
			local candidateFrame = candidate.frame;
			if candidateArea == DragIntersectionArea.Above then
				local frame = factory("ScrollBoxDragLineTemplate");
				frame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", 0, 3);
				frame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", 0, 3);
			elseif candidateArea == DragIntersectionArea.Below then
				local frame = factory("ScrollBoxDragLineTemplate");
				frame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", 0, -3);
				frame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", 0, -3);
			elseif candidateArea == DragIntersectionArea.Inside then
				local frame = factory("ScrollBoxDragBoxTemplate");
				frame:SetPoint("TOPLEFT", candidateFrame, "TOPLEFT", 3, -3);
				frame:SetPoint("BOTTOMRIGHT", candidateFrame, "BOTTOMRIGHT", -3, 3);
			end
		end);
		end
		
	function ScrollUtil.InitDefaultLinearDragBehavior(scrollBox)
		local dragBehavior = ScrollUtil.AddLinearDragBehavior(scrollBox);
		ConfigureDragBehavior(dragBehavior);
		return dragBehavior;
	end
	
	function ScrollUtil.InitDefaultTreeDragBehavior(scrollBox)
		local dragBehavior = ScrollUtil.AddTreeDragBehavior(scrollBox);
		dragBehavior:SetAreaIntersectMargin(5);
		ConfigureDragBehavior(dragBehavior);
		return dragBehavior;
	end
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

function ScrollUtil.RegisterAlternateRowBehavior(scrollBox, callback)
	local function OnDataRangeChanged(sortPending)
		local index = scrollBox:GetDataIndexBegin();
		scrollBox:ForEachFrame(function(frame)
			local alternate = index % 2 == 0;
			callback(frame, alternate);
			index = index + 1;
		end);
	end;
	scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged, OnDataRangeChanged);
end

function ScrollUtil.AlternateDataValue(dataProvider, predicate, field, initValue)
	if type(initValue) ~= boolean then
		initValue = true;
	end
	if field == nil then
		field = "odd";
	end
	local odd = initValue ~= nil and initValue or true;
	for index, elementDataIter in dataProvider:EnumerateEntireRange() do
		local data = elementDataIter:GetData();
		if predicate and predicate(data) then
			odd = initValue or true;
		else
			data[field] = odd;
			odd = not odd;
		end
	end
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