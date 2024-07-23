--[[
	Condensed Vertical Grid

	Elements are positioned column-first from the left, with a static column count and resizing row count, taking up as few rows as needed for the total element count.
	See base mixin file for breakdown on base PagedContent layout functionality and terms like Element, View, DataGroup, etc.

	Layout Mechanics:
		- There's a set number of columns (columnsPerRow)
		- The number of rows needed is the total number of elements, divided by the number of columns, rounded up (ex: 3 columns of 10 elements => ceil(10 / 3) = 4 rows)
		- Elements are placed column-first starting on the left, filling each column before moving onto the next column
		- Columns are "filled" when they reach the calculated number of rows, OR until vertical View space runs out, whichever comes first
		- Once a View is filled, a new View is started and row count is recalculated for the remaining set of Elements yet to be placed
		- Row calculations are done separately for each DataGroup (ex: DataGroup of 10 elements gets 4 rows, next DataGroup of 6 elements gets 2, etc)
		- Headers/Spacers take up the full row of the View and are not part of these grid mechanics, aside from taking up available vertical View space

	---
	Example element counts for a 3-column layout:
		(total element count => [num elements in col1] [elements in col2] [elements in col3])
		1 => 1 0 0
		2 => 1 1 0
		3 => 1 1 1
		4 => 2 2 0
		5 => 2 2 1
		6 => 2 2 2
		7 => 3 3 1
		8 => 3 3 2
		9 => 3 3 3
		10 => 4 4 2
		11 => 4 4 3
		12 => 4 4 4
		13 => 5 5 3

	---
	Example placement distribution of 2 DataGroups with a 3 Column layout:

	DataGroup1: { header = d1header, elements = { d1e1, d1e2, d1e3, d1e4, d1e5 } }
	DataGroup2: { header = d2header, elements = { d2e1, d2e2, d2e3, d2e4, d2e5, d2e6, d2e7, d2e8, d2e9, d2e10 } }

     ________view1______       ________view2______  
	|      d1header      |    |  __elementSet3___  |
	|  __elementSet1___  |    | | d2e7 d2e9      | |
	| | d1e1 d1e3 d1e5 | |    | | d2e8 d2e10     | |
	| | d1e2 d1e4      | |    | |________________| |
	| |________________| |    |                    |
	|                    |    |                    |
	|      d2header      |    |                    |
	|  __elementSet2___  |    |                    |
	| | d2e1 d2e3 d2e5 | |    |                    |
	| | d2e2 d2e4 d2e6 | |    |                    |
	| |________________| |    |                    |
	|____________________|    |____________________|
]]

----------------- DataGroup Progress Helper -----------------

local VerticalDataGroupMixin = {};

function VerticalDataGroupMixin:Init()
	self:Reset(0);
end

function VerticalDataGroupMixin:Reset(totalElements)
	self.totalElements = totalElements;
	self.placedElements = 0;
end

function VerticalDataGroupMixin:NumUnplacedElements()
	return self.totalElements - self.placedElements;
end

function VerticalDataGroupMixin:IncrementPlacedElements()
	self.placedElements = self.placedElements + 1;
end

function VerticalDataGroupMixin:HasUnplacedElements()
	return self:NumUnplacedElements() > 0;
end


----------------- ElementSet Progress Helper -----------------

local VerticalElementSetMixin = {};

function VerticalElementSetMixin:Init(columnsPerRow)
	self.columnsPerRow = columnsPerRow;
	self:Reset(0);
end

function VerticalElementSetMixin:Reset(numElements)
	self.rowsNeeded = math.ceil(numElements / self.columnsPerRow);
	self.currentColumn = 1;
	self.filledRowsInCurrentColumn = 0;

	self.viewRowsFilledAtStartOfSet = 0;
	self.viewSpaceAvailableAtStartOfSet = 0;
	self.viewSpaceAvailableAtEndOfSet = 0;
end

function VerticalElementSetMixin:StartNewColumn()
	self.currentColumn = self.currentColumn + 1;
	self.filledRowsInCurrentColumn = 0;
end

function VerticalElementSetMixin:IncrementFilledRows()
	self.filledRowsInCurrentColumn = self.filledRowsInCurrentColumn + 1;
end

function VerticalElementSetMixin:SetViewRowsFilledAtStartOfSet(viewRowsFilled)
	self.viewRowsFilledAtStartOfSet = viewRowsFilled;
end

function VerticalElementSetMixin:SetSpaceAvailableAtStartOfSet(viewSpace)
	self.viewSpaceAvailableAtStartOfSet = viewSpace;
end

function VerticalElementSetMixin:GetSpaceAvailableAtStartOfSet()
	return self.viewSpaceAvailableAtStartOfSet;
end

function VerticalElementSetMixin:SetSpaceAvailableAtEndOfSet(viewSpace)
	self.viewSpaceAvailableAtEndOfSet = viewSpace;
end

function VerticalElementSetMixin:GetSpaceAvailableAtEndOfSet()
	return self.viewSpaceAvailableAtEndOfSet;
end

function VerticalElementSetMixin:GetCurrentColumn()
	return self.currentColumn;
end

function VerticalElementSetMixin:GetCurrentViewRow()
	-- filledRowsInCurrentColumn is local to this current column, in this current set
	-- So to get the current row at the view-scope, adds that to the filledRowsInView cached at the start of the set
	return self.viewRowsFilledAtStartOfSet + self.filledRowsInCurrentColumn;
end

function VerticalElementSetMixin:IsInFirstColumn()
	return self.currentColumn == 1;
end

function VerticalElementSetMixin:IsCurrentColumnFilled()
	return self.filledRowsInCurrentColumn >= self.rowsNeeded;
end

function VerticalElementSetMixin:CanStartNewColumn()
	return self.currentColumn < self.columnsPerRow;
end

function VerticalElementSetMixin:AnyElementsPlaced()
	return not self:IsInFirstColumn() or self.filledRowsInCurrentColumn > 0;
end


----------------- Condensed Vertical Grid Layout -----------------

PagedCondensedVerticalGridContentFrameMixin = CreateFromMixins(PagedContentFrameBaseMixin);

function PagedCondensedVerticalGridContentFrameMixin:InitializeElementSplit(splitData, viewFrame)
	if not viewFrame.IsLayoutFrame or not viewFrame:IsLayoutFrame() then
		error("View frames need to inherit from StaticGridLayoutFrame");
	end

	local fullWidth = viewFrame:GetWidth();
	local fullPadding = self.xPadding * (self.columnsPerRow - 1);
	self.autoExpandWidthPerColumn = (fullWidth - fullPadding) / self.columnsPerRow;

	-- Initialize helper instances to track element placement progress
	splitData.currentDataGroup = CreateAndInitFromMixin(VerticalDataGroupMixin);
	splitData.currentElementSet = CreateAndInitFromMixin(VerticalElementSetMixin, self.columnsPerRow);
end

function PagedCondensedVerticalGridContentFrameMixin:GetTotalViewSpace(viewFrame)
	return viewFrame:GetHeight();
end

function PagedCondensedVerticalGridContentFrameMixin:OnDataGroupStarted(splitData, dataGroup)
	local numElements = #dataGroup.elements;
	splitData.currentDataGroup:Reset(numElements);
	-- Starting up a new group also means starting up a new Set for its elements
	splitData.currentElementSet:Reset(numElements);
end

function PagedCondensedVerticalGridContentFrameMixin:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo)
	return elementTemplateInfo.height + self.yPadding;
end

function PagedCondensedVerticalGridContentFrameMixin:GetViewSpaceNeededForSpacer(splitData, spacerTemplateInfo)
	return self.spacerSize + self.yPadding;
end

function PagedCondensedVerticalGridContentFrameMixin:WillElementUseTrackedViewSpace(splitData, elementData, elementTemplateInfo, needsGroupSpacer)
	-- Since we want to track available remaining vertical space as we go down each column, all elements should get accounted against it
	return true;
end

function PagedCondensedVerticalGridContentFrameMixin:ShouldStartNewView(viewSpaceRemaining, totalSizeNeededForElement, splitData)
	local cannotContinueInCurrentColumn = (viewSpaceRemaining < totalSizeNeededForElement) or splitData.currentElementSet:IsCurrentColumnFilled();

	-- Start a new View if there is no room for the next element in this column, and we've either not managed to place any elements yet, OR we've just run out of columns
	return cannotContinueInCurrentColumn and (not splitData.currentElementSet:AnyElementsPlaced() or not splitData.currentElementSet:CanStartNewColumn());
end

function PagedCondensedVerticalGridContentFrameMixin:OnNewViewStarted(splitData)
	local numGroupElementsRemaining = splitData.currentDataGroup:NumUnplacedElements();
	if numGroupElementsRemaining > 0 then
		-- If we were partway through placing elements in Group, starting a new View means starting up a new Set with the remaining elements
		splitData.currentElementSet:Reset(numGroupElementsRemaining);
	end

	splitData.filledRowsInView = 0;
end

function PagedCondensedVerticalGridContentFrameMixin:OnSpacerAddedToView(splitData, elementData)
	-- Spacers are simple, not part of the grid cell logic, just takes up a row in the view
	splitData.filledRowsInView = splitData.filledRowsInView + 1;
	elementData.gridColumn = 1;
	elementData.gridRow = splitData.filledRowsInView;
end

function PagedCondensedVerticalGridContentFrameMixin:OnElementSpaceTakenFromView(splitData, elementData, elementTemplateInfo, spaceTaken, sizeOfNextElement)
	if elementData.isHeader then
		-- Headers are simple since they're not part of all the grid cell logic, just take up a row and return early
		splitData.filledRowsInView = splitData.filledRowsInView + 1;
		elementData.gridColumn = 1;
		elementData.gridRow = splitData.filledRowsInView;
		return;
	end

	local currentElementSet = splitData.currentElementSet;
	local currentDataGroup = splitData.currentDataGroup;

	if not currentElementSet:AnyElementsPlaced() then
		-- On starting a set, cache how many rows were filled and how much space was available in the View, so we can reset vertically at the start of each column
		currentElementSet:SetViewRowsFilledAtStartOfSet(splitData.filledRowsInView);
		local spaceAvailableBeforeElementPlaced = splitData.viewSpaceRemaining + spaceTaken; -- Add back spaceTaken as it was already removed from spaceRemaining
		currentElementSet:SetSpaceAvailableAtStartOfSet(spaceAvailableBeforeElementPlaced);
	end

	if currentElementSet:IsInFirstColumn() then
		-- Since we fill each column in turn, we can use the first (leftmost) column to count how many total rows this current ElementSet is taking up
		splitData.filledRowsInView = splitData.filledRowsInView + 1;
	end

	-- Now that any starting state is cached, increment placement progress
	currentDataGroup:IncrementPlacedElements();
	currentElementSet:IncrementFilledRows();

	-- Store the view-scope column & row this element is being placed at
	elementData.gridColumn = currentElementSet:GetCurrentColumn();
	elementData.gridRow = currentElementSet:GetCurrentViewRow();

	local groupHasMoreElementsToPlace = currentDataGroup:HasUnplacedElements();
	-- Can't continue this column if: We've run out of elements to place OR We've run out of vertical space OR We've reached our current calculated row count
	local reachedTheEndOfThisColumn = (not groupHasMoreElementsToPlace) or (splitData.viewSpaceRemaining < sizeOfNextElement) or (currentElementSet:IsCurrentColumnFilled());

	if reachedTheEndOfThisColumn then
		if currentElementSet:IsInFirstColumn() or splitData.viewSpaceRemaining < currentElementSet:GetSpaceAvailableAtEndOfSet() then
			-- Either reached end of first column, or a column that went longer than the first, so cache current available space as what will be left after this Set
			currentElementSet:SetSpaceAvailableAtEndOfSet(splitData.viewSpaceRemaining);
		end

		if groupHasMoreElementsToPlace and currentElementSet:CanStartNewColumn() then
			-- Start a new column and reset the space available to the top of the set
			currentElementSet:StartNewColumn();
			splitData.viewSpaceRemaining = currentElementSet:GetSpaceAvailableAtStartOfSet();
		else
			-- Ran out of either space or elements, meaning we've reached the end of the current ElementSet
			-- Reset space remaining so when we either start a new DataGroup or check whether to start a new View, we're starting beneath this finished ElementSet
			splitData.viewSpaceRemaining = currentElementSet:GetSpaceAvailableAtEndOfSet();
		end
	end
end

function PagedCondensedVerticalGridContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementData, elementIndex)
	spacerFrame.gridColumn = elementData.gridColumn;
	spacerFrame.gridRow = elementData.gridRow;
	spacerFrame.gridColumnSize = self.columnsPerRow;

	spacerFrame:SetHeight(self.spacerSize);
end

function PagedCondensedVerticalGridContentFrameMixin:ProcessElementFrame(elementFrame, elementData, elementIndex)
	elementFrame.gridColumn = elementData.gridColumn;
	elementFrame.gridRow = elementData.gridRow;

	elementFrame.gridColumnSize = elementData.isHeader and self.columnsPerRow or 1;

	if self.autoExpandHeaders and elementData.isHeader then
		elementFrame:SetWidth(self.ViewFrames[1]:GetWidth());
	elseif self.autoExpandElements and not elementData.isHeader then
		elementFrame:SetWidth(self.autoExpandWidthPerColumn);
	end
end

function PagedCondensedVerticalGridContentFrameMixin:ApplyLayout(layoutFrames, viewFrame)
	viewFrame.childXPadding = self.xPadding;
	viewFrame.childYPadding = self.yPadding;

	-- Need to ensure all the child frames are shown first, so that StaticGridLayoutFrame actually knows what frames to work with
	for index, elementFrame in ipairs(layoutFrames) do
		elementFrame:Show();
	end

	viewFrame:Layout();
end