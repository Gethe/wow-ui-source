---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("assert");
	Import("NegateIf");
	Import("Saturate");
end
----------------

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

function SelectionBehaviorMixin:SelectFirstElementData()
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		local elementData = dataProvider:Find(1);
		if elementData then
			self:SelectElementData(elementData);
		end
	end
end

function SelectionBehaviorMixin:SelectNextElementData()
	return self:SelectOffsetElementData(1);
end

function SelectionBehaviorMixin:SelectPreviousElementData()
	return self:SelectOffsetElementData(-1);
end

function SelectionBehaviorMixin:SelectOffsetElementData(offset)
	local dataProvider = self.scrollBox:GetDataProvider();
	if dataProvider then
		local currentElementData = self:GetFirstSelectedElementData();
		local currentIndex = dataProvider:FindIndex(currentElementData);
		local offsetIndex = currentIndex + offset;
		local offsetElementData = dataProvider:Find(offsetIndex);
		if offsetElementData then
			self:SelectElementData(offsetElementData);
			return offsetElementData, offsetIndex;
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

ScrollBoxDragBehavior = {};

-- Returns an unbounded percentage of where the cursor position releative to the frame. It's intentional
-- for this to be unbounded because we still want a reference as the cursor exceeds the bounds
-- of the frame (i.e. a return of 1.6 informs us that the cursor is above the frame).
local function GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop)
	local bottom = frame:GetBottom() + cursorHitInsetBottom;
	local height = frame:GetHeight() - (cursorHitInsetBottom - cursorHitInsetTop);
	return (cy - bottom) / height;
end

function ScrollBoxDragBehavior:Init(scrollBox)
	scrollBox.dragBehavior = self;
	
	self.dragEnabled = true;
	self.scrollBox = scrollBox;
	self.delegate = scrollBox.DragDelegate;
	self.delegate.pools = CreateFramePoolCollection();
end

function ScrollBoxDragBehavior:SetDragEnabled(dragEnabled)
	self.dragEnabled = dragEnabled;
end

function ScrollBoxDragBehavior:SetDragProperties(dragProperties)
	self.dragProperties = dragProperties;
end

function ScrollBoxDragBehavior:GetNotifyDragSource()
	return self.dragProperties.notifyDragSource;
end

function ScrollBoxDragBehavior:SetNotifyDragSource(callback)
	self.dragProperties.notifyDragSource = callback;
end

function ScrollBoxDragBehavior:GetSourceDragCondition()
	return self.dragProperties.sourceDragCondition;
end

function ScrollBoxDragBehavior:SetSourceDragCondition(callback)
	self.dragProperties.sourceDragCondition = callback;
end

function ScrollBoxDragBehavior:GetDragRelativeToCursor()
	return self.dragProperties.dragRelativeToCursor;
end

function ScrollBoxDragBehavior:SetDragRelativeToCursor(dragRelativeToCursor)
	self.dragProperties.dragRelativeToCursor = dragRelativeToCursor;
end

function ScrollBoxDragBehavior:SetNotifyDragCandidates(callback)
	self.dragProperties.notifyDragCandidates = callback;
end

function ScrollBoxDragBehavior:GetNotifyDragCandidates()
	return self.dragProperties.notifyDragCandidates;
end

function ScrollBoxDragBehavior:SetNotifyDragReceived(callback)
	self.dragProperties.notifyDragReceived = callback;
end

function ScrollBoxDragBehavior:GetNotifyDragReceived()
	return self.dragProperties.notifyDragReceived;
end

function ScrollBoxDragBehavior:SetReorderable(reorderable)
	self.dragProperties.reorderable = reorderable;
end

function ScrollBoxDragBehavior:GetReorderable()
	return self.dragProperties.reorderable;
end

function ScrollBoxDragBehavior:GetCursorHitInsets()
	local cursorHitInsets = self.dragProperties.cursorHitInsets;
	if not cursorHitInsets then
		return 0, 0;
	end
	
	local bottom = cursorHitInsets.bottom or 0;
	local top = cursorHitInsets.top or 0;
	return bottom, top;
end

function ScrollBoxDragBehavior:SetCursorHitInsets(bottom, top)
	self.dragProperties.cursorHitInsets = {bottom = bottom, top = top};
end

function ScrollBoxDragBehavior:ScrollBoxContainsCursor(cx, cy)
	return cy <= self.scrollBox:GetTop() and cy >= self.scrollBox:GetBottom()
		and cx >= self.scrollBox:GetLeft() and cx <= self.scrollBox:GetRight();
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

function ScrollBoxDragBehavior:Register(cursorFactory, lineFactory, onDragStop, onDragUpdate, dragProperties)
	self:SetDragProperties(dragProperties or {});

	local dragging = false;
	local sourceFrame = nil;
	local sourceElementData = nil;
	local cursorFrame = nil;
	local cursorLine = nil;
	local cursorParent = FrameUtil.GetRootParent(self.scrollBox);

	local lineTemplate, lineInitializer = lineFactory(elementData);
	local cursorLine = self:AcquireFromPool(lineTemplate);
	cursorLine:SetParent(self.scrollBox);
	cursorLine:SetFrameStrata("DIALOG");
	if lineInitializer then
		lineInitializer(cursorLine);
	end
	
	local function NotifyDragSource(frame, drag)
		local notifyDragSource = self:GetNotifyDragSource();
		if notifyDragSource and dragging then
			notifyDragSource(frame, drag);
		end
	end
	
	local function OnDragStopInternal()
		self.delegate:SetScript("OnUpdate", nil);
		self.delegate.pools:ReleaseAll();
		cursorFrame = nil;

		cursorLine:Hide();
		
		local dragFrame = self.scrollBox:FindFrame(sourceElementData);
		if dragFrame then
			NotifyDragSource(dragFrame, false);
		end

		local notifyDragCandidates = self:GetNotifyDragCandidates();
		if notifyDragCandidates then
			for index, frame in self.scrollBox:EnumerateFrames() do
				if frame ~= sourceFrame then
					notifyDragCandidates(frame, false);
				end
			end
		end

		local copyElementData = sourceElementData;

		dragging = false;
		sourceFrame = nil;
		sourceElementData = nil;

		-- This drag stop can cause the underlying data provider to change, so we have
		-- no guarantee that the elementData can be matched beyond this call.
		onDragStop(copyElementData);
	end
	self.delegate:SetScript("OnDragStop", OnDragStopInternal);

	local function OnDragStartInternal(frame)
		if not self.dragEnabled then
			return;
		end

		local sourceDragCondition = self:GetSourceDragCondition();
		if sourceDragCondition and not sourceDragCondition(frame, frame:GetElementData()) then
			return;
		end

		dragging = true;
		sourceFrame = frame;
		sourceFrame:InterceptStartDrag(self.delegate);

		sourceElementData = sourceFrame:GetElementData();

		local cursorTemplate, cursorInitializer = cursorFactory(sourceElementData);
		cursorFrame = self:AcquireFromPool(cursorTemplate);
		-- Disable any mouse interactions that may have accompanied the template,
		-- particularly if we're mirroring an element from the list.
		cursorFrame:SetMouseMotionEnabled(false);
		-- Cannot be mouse click enabled otherwise it will block the OnReceiveDrag
		-- of any frame beneath it.
		cursorFrame:SetMouseClickEnabled(false);
		cursorFrame:SetFrameStrata("DIALOG");
		cursorFrame:Show();
		if cursorInitializer then
			cursorInitializer(cursorFrame, frame, sourceElementData);
		end

		NotifyDragSource(frame, dragging);

		local notifyDragCandidates = self:GetNotifyDragCandidates();
		if notifyDragCandidates then
			for index, frame in self.scrollBox:EnumerateFrames() do
				if frame ~= sourceFrame then
					notifyDragCandidates(frame, dragging);
				end
			end
		end

		local dx, dy = 0, 0;
		if self:GetDragRelativeToCursor() then
			local cx, cy = InputUtil.GetCursorPosition(cursorParent);
			dx = cx - sourceFrame:GetLeft();
			dy = cy - sourceFrame:GetTop();
		end

		local sourceElementDataIndex = self.scrollBox:FindFrameElementDataIndex(sourceFrame);

		self.delegate:SetScript("OnUpdate", function()
			local cx, cy = InputUtil.GetCursorPosition(cursorParent);
			local x, y = cx - dx, cy - dy;

			cursorFrame:SetPoint("TOPLEFT", x, y - cursorParent:GetHeight());
			cursorLine:Hide();
			onDragUpdate(cursorFrame, cursorLine, sourceElementData, sourceElementDataIndex, cx, cy);
		end);
	end

	local onSubscribe = function(frame, elementData)
		frame:RegisterForDrag("LeftButton");
		frame:SetScript("OnDragStart", OnDragStartInternal);
		
		local notifyDragReceived = self:GetNotifyDragReceived();
		if notifyDragReceived then
			frame:SetScript("OnReceiveDrag", notifyDragReceived);
		end

		if elementData == sourceElementData then
			NotifyDragSource(frame, dragging);
		else
			local notifyDragCandidates = self:GetNotifyDragCandidates();
			if notifyDragCandidates then
				notifyDragCandidates(frame, dragging);
			end
		end
	end

	local onAcquired = function(o, frame, elementData)
		onSubscribe(frame, elementData);
	end;
	self.scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, onAcquired, onAcquired);

	local onReleased = function(o, frame, elementData)
		if elementData == sourceElementData then
			NotifyDragSource(frame, not dragging);
		end

		frame:ClearAllPoints();
		frame:Hide();
		frame:SetScript("OnDragStart", nil);
		frame:SetScript("OnReceiveDrag", nil);
	end;
	self.scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnReleasedFrame, onReleased, onReleased);

	self.scrollBox:ForEachFrame(onSubscribe);
end

function CreateScrollBoxDragBehavior(scrollBox)
	local dragBehavior = CreateFromMixins(ScrollBoxDragBehavior);
	dragBehavior:Init(scrollBox);
	return dragBehavior;
end

DragIntersectionArea =
{
	Below = 1,
	Above = 2,
	Inside = 3,
};

local function GetLinearCursorIntersectionArea(p)
	-- Linear interaction area does not require the cursor to be within the frame bounds. This
	-- is desirable so that detection can continue when overlapping another frame, but still have
	-- a different frame be a better candidate.
	if p < .5 then
		return DragIntersectionArea.Below;
	elseif p >= .5 then
		return DragIntersectionArea.Above;
	end
end

function ScrollUtil.AddLinearDragBehavior(scrollBox, cursorFactory, lineFactory, anchoringHandler, dragProperties)
	local dragBehavior = CreateScrollBoxDragBehavior(scrollBox);
	local candidateElementData = nil;
	local candidateElementDataIndex = nil;

	local function OnDragUpdate(cursorFrame, cursorLine, sourceElementData, sourceElementDataIndex, cx, cy)
		if not dragBehavior:GetReorderable() then
			return;
		end

		local candidate = nil;
		candidateElementDataIndex = nil;

		local containsCursor = dragBehavior:ScrollBoxContainsCursor(cx, cy);
		if containsCursor then
			local cursorHitInsetBottom, cursorHitInsetTop = dragBehavior:GetCursorHitInsets();
			scrollBox:ForEachFrame(function(frame)
				local elementDataIndex = scrollBox:FindFrameElementDataIndex(frame);
				if elementDataIndex < sourceElementDataIndex then
					local p = GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop);
					local area = GetLinearCursorIntersectionArea(p);
					if area and area == DragIntersectionArea.Above then
						candidate = frame;
						candidateElementDataIndex = elementDataIndex;
						return ScrollBoxConstants.StopIteration;
					end
				elseif elementDataIndex > sourceElementDataIndex then
					local p = GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop);
					local area = GetLinearCursorIntersectionArea(p);
					if area and area == DragIntersectionArea.Below then
						candidate = frame;
						candidateElementDataIndex = elementDataIndex;
					end
				end
			end);
		end

		if candidate then
			cursorLine:Show();
			cursorLine:ClearAllPoints();

			local above = candidateElementDataIndex < sourceElementDataIndex;
			local candidateArea = above and DragIntersectionArea.Above or DragIntersectionArea.Below; 
			anchoringHandler(cursorLine, candidate, candidateArea);
		end
	end
	
	local function OnDragStop(sourceElementData)
		if candidateElementDataIndex then
			local dataProvider = scrollBox:GetDataProvider();
			dataProvider:MoveElementDataToIndex(sourceElementData, candidateElementDataIndex);
		end

		candidateElementData = nil;
		candidateElementDataIndex = nil;
	end

	dragBehavior:Register(cursorFactory, lineFactory, OnDragStop, OnDragUpdate, dragProperties);
	return dragBehavior;
end

local function GetTreeCursorIntersectionArea(p)
	-- Tree interaction areas require the cursor to be within the frame bounds.
	if p < 0 or p > 1 then
		return nil;
	end

	if p < .33 then
		return DragIntersectionArea.Below;
	elseif p > .66 then
		return DragIntersectionArea.Above;
	end
	return DragIntersectionArea.Inside;
end

function ScrollUtil.AddTreeDragBehavior(scrollBox, cursorFactory, lineFactory, boxFactory, anchoringHandler, dragProperties)
	local dragBehavior = CreateScrollBoxDragBehavior(scrollBox);
	local candidateArea = nil;
	local candidateElementData = nil;

	local boxTemplate, boxInitializer = boxFactory(elementData);
	local cursorBox = dragBehavior:AcquireFromPool(boxTemplate);
	cursorBox:SetParent(scrollBox);
	cursorBox:SetFrameStrata("DIALOG");
	if boxInitializer then
		boxInitializer(cursorBox);
	end
	
	local function OnDragUpdate(cursorFrame, cursorLine, sourceElementData, sourceElementDataIndex, cx, cy)
		if not dragBehavior:GetReorderable() then
			return;
		end

		local candidate = nil;
		candidateArea = nil;
		candidateElementData = nil;

		cursorBox:Hide();

		local containsCursor = dragBehavior:ScrollBoxContainsCursor(cx, cy);
		if containsCursor then
			local cursorHitInsetBottom, cursorHitInsetTop = dragBehavior:GetCursorHitInsets();

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

				local p = GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop);
				local area = GetTreeCursorIntersectionArea(p);
				if area then
					candidate = frame;
					candidateArea = area;
					candidateElementData = elementData;

					local elementDataIndex = scrollBox:FindFrameElementDataIndex(frame);
					if elementDataIndex < sourceElementDataIndex then
						return ScrollBoxConstants.StopIteration;
					end
				end
			end);

			if candidate then
				local isInside = candidateArea == DragIntersectionArea.Inside;
				local candidateFrame = isInside and cursorBox or cursorLine;
				candidateFrame:Show();
				candidateFrame:ClearAllPoints();
				anchoringHandler(candidateFrame, candidate, candidateArea);
			end
		end
	end
	
	local function OnDragStop(sourceElementData)
		if candidateElementData and candidateArea then
			if candidateArea == DragIntersectionArea.Below then
				local parent = candidateElementData:GetParent();
				parent:MoveNodeRelativeTo(sourceElementData, candidateElementData, 1);
			elseif candidateArea == DragIntersectionArea.Inside then
				candidateElementData:MoveNode(sourceElementData);
			elseif candidateArea == DragIntersectionArea.Above then
				local parent = candidateElementData:GetParent();
				parent:MoveNodeRelativeTo(sourceElementData, candidateElementData, 0);
			end
		end

		cursorBox:Hide();

		candidateArea = nil;
		candidateElementData = nil;
	end

	dragBehavior:Register(cursorFactory, lineFactory, OnDragStop, OnDragUpdate, dragProperties);
	return dragBehavior;
end

do
	local function LineFactory(elementData)
		return "ScrollBoxDragLineTemplate";
	end
	
	local function SourceDragCondition(sourceFrame, sourceElementData)
		return true;
	end

	local function NotifyDragSource(sourceFrame, drag)
		sourceFrame:SetAlpha(drag and .5 or 1);
		sourceFrame:SetMouseMotionEnabled(not drag);
	end
	
	local function NotifyDragCandidates(candidateFrame, drag)
		candidateFrame:SetMouseMotionEnabled(not drag);
	end

	local function GenerateCursorFactory(scrollBox)
		local function CursorFactory(elementData)
			local view = scrollBox:GetView();
			
			local function CursorInitializer(cursorFrame, candidateFrame, elementData)
				cursorFrame:SetSize(candidateFrame:GetSize());
		
				-- Acquires whatever initialize was assigned to this element from the view.
				local template, initializer = view:GetFactoryDataFromElementData(elementData);
				initializer(cursorFrame, elementData);
			end
			
			local template = view:GetFactoryDataFromElementData(elementData);
			return template, CursorInitializer;
		end
		return CursorFactory;
	end

	local function ConfigureDragBehavior(dragBehavior)
		dragBehavior:SetSourceDragCondition(SourceDragCondition);
		dragBehavior:SetNotifyDragSource(NotifyDragSource);
		dragBehavior:SetNotifyDragCandidates(NotifyDragCandidates);
		dragBehavior:SetDragRelativeToCursor(true);
	end

	function ScrollUtil.InitDefaultLinearDragBehavior(scrollBox)
		local function AnchoringHandler(anchorFrame, candidateFrame, candidateArea)
			if candidateArea == DragIntersectionArea.Above then
				anchorFrame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", 0, 3);
				anchorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", 0, 3);
			elseif candidateArea == DragIntersectionArea.Below then
				anchorFrame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", 0, -3);
				anchorFrame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", 0, -3);
			end
		end
		
		local dragBehavior = ScrollUtil.AddLinearDragBehavior(scrollBox, GenerateCursorFactory(scrollBox), 
			LineFactory, AnchoringHandler);
		ConfigureDragBehavior(dragBehavior);
		return dragBehavior;
	end
	
	function ScrollUtil.InitDefaultTreeDragBehavior(scrollBox)
		local function BoxFactory(elementData)
			return "ScrollBoxDragBoxTemplate";
		end
	
		local function AnchoringHandler(anchorFrame, candidateFrame, candidateArea)
			if candidateArea == DragIntersectionArea.Above then
				anchorFrame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", 0, 3);
				anchorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", 0, 3);
			elseif candidateArea == DragIntersectionArea.Below then
				anchorFrame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", 0, -3);
				anchorFrame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", 0, -3);
			elseif candidateArea == DragIntersectionArea.Inside then
				anchorFrame:SetPoint("TOPLEFT", candidateFrame, "TOPLEFT", 5, -5);
				anchorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "BOTTOMRIGHT", -5, 5);
			end
		end
	
		local dragBehavior = ScrollUtil.AddTreeDragBehavior(scrollBox, GenerateCursorFactory(scrollBox), 
			LineFactory, BoxFactory, AnchoringHandler, dragProperties);
		ConfigureDragBehavior(dragBehavior);
		return dragBehavior
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