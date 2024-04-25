--[[
	Paged Content Frame implementation for Grid-based layouts
	Uses GridLayoutUtil to arrange elements in ViewFrames

	Note: 
	Standard Grid is not supported as it does not work with full-row elements like headers or spacers
	Use the Natural Grid or Cell Size Grid templates instead
]]

BasePagedGridContentFrameMixin = CreateFromMixins(PagedContentFrameBaseMixin);

function BasePagedGridContentFrameMixin:InitializeElementSplit(splitData, viewFrame)
	splitData.filledStrideInCurrentRow = 0;
end

function BasePagedGridContentFrameMixin:GetTotalViewSpace(viewFrame)
	return viewFrame:GetHeight();
end

function BasePagedGridContentFrameMixin:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo)
	return elementTemplateInfo.height + self.viewLayout.secondarySizePadding;
end

function BasePagedGridContentFrameMixin:GetViewSpaceNeededForSpacer(splitData, spacerTemplateInfo)
	return self.spacerSize + self.viewLayout.secondarySizePadding;
end

function BasePagedGridContentFrameMixin:WillElementUseTrackedViewSpace(splitData, elementData, elementTemplateInfo, needsGroupSpacer)
	local isFirstInRow = splitData.filledStrideInCurrentRow == 0;
	local elementStride = self:GetElementStride(elementTemplateInfo, elementData.isHeader, isFirstInRow);
	local isFullRowElement = elementStride >= self.viewLayout.stride;

	-- If there's a group break, or current row isn't populated, or not enough room in current row,
	-- this element will start the fill of a new row, whose height will take from remaining space
	return needsGroupSpacer
		or isFullRowElement
		or isFirstInRow
		or (splitData.filledStrideInCurrentRow + elementStride) > self.viewLayout.stride;
end

function BasePagedGridContentFrameMixin:OnElementSpaceTakenFromView(splitData, elementData, elementTemplateInfo, spaceTaken, sizeOfNextElement)
	-- If element space was removed from view space, it's the start of a new row so reset filled stride for it
	-- The element's stride will then be added in OnElementAddedToView
	splitData.filledStrideInCurrentRow = 0;
end

function BasePagedGridContentFrameMixin:OnElementAddedToView(splitData, elementData, elementTemplateInfo)
	local elementStride = self:GetElementStride(elementTemplateInfo, elementData.isHeader);
	splitData.filledStrideInCurrentRow = splitData.filledStrideInCurrentRow + elementStride;
end

function BasePagedGridContentFrameMixin:ApplyLayout(layoutFrames, viewFrame)
	GridLayoutUtil.ApplyGridLayout(layoutFrames, AnchorUtil.CreateAnchor("TOPLEFT", viewFrame, "TOPLEFT"), self.viewLayout);
end


----------------- Cell Size Grid -----------------
-- Elements take up a specified cell size out of available cellsPerRow

PagedCellSizeGridContentFrameMixin = CreateFromMixins(BasePagedGridContentFrameMixin);

function PagedCellSizeGridContentFrameMixin:InitializeElementSplit(splitData, viewFrame)
	BasePagedGridContentFrameMixin.InitializeElementSplit(self, splitData, viewFrame);

	local function GetCellSize(regionFrame)
		return regionFrame.cellSize or 1;
	end

	self.viewLayout = GridLayoutUtil.CreateCellSizeGridLayout(self.cellsPerRow, self.xPadding, self.yPadding, 1, -1, GetCellSize);
	local fullWidth = viewFrame:GetWidth();
	local fullPadding = self.xPadding * (self.cellsPerRow - 1);
	self.autoExpandWidthPerCell = (fullWidth - fullPadding) / self.cellsPerRow;
end

function PagedCellSizeGridContentFrameMixin:GetElementStride(elementTemplateInfo, isHeader, isFirstInRow)
	if isHeader and self.autoExpandHeaders then
		return self.viewLayout.stride;
	end
	return elementTemplateInfo.cellSize;
end

function PagedCellSizeGridContentFrameMixin:ProcessTemplateInfo(templateInfo)
	templateInfo.cellSize = 1;

	for i, keyValue in ipairs(templateInfo.keyValues) do
		if keyValue.key and keyValue.key == "cellSize" then
			templateInfo.cellSize = tonumber(keyValue.value) or 1;
		end
	end
end

function PagedCellSizeGridContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementData, elementIndex)
	spacerFrame:SetHeight(self.spacerSize);
	spacerFrame.cellSize = self.viewLayout.stride;
end

function PagedCellSizeGridContentFrameMixin:ProcessElementFrame(elementFrame, elementData, elementIndex)
	if self.autoExpandHeaders and elementData.isHeader then
		elementFrame.cellSize = self.viewLayout.stride;
		elementFrame:SetWidth(self.ViewFrames[1]:GetWidth());
	elseif self.autoExpandElements and not elementData.isHeader then
		if elementFrame.cellSize >= self.viewLayout.stride then
			elementFrame:SetWidth(self.ViewFrames[1]:GetWidth());
		else
			elementFrame:SetWidth(self.autoExpandWidthPerCell);
		end
	end
end


----------------- Natural Size Grid -----------------
-- Elements take up actual frame width out of available view width per row

PagedNaturalSizeGridContentFrameMixin = CreateFromMixins(BasePagedGridContentFrameMixin);

function PagedNaturalSizeGridContentFrameMixin:InitializeElementSplit(splitData, viewFrame)
	BasePagedGridContentFrameMixin.InitializeElementSplit(self, splitData, viewFrame);

	self.viewLayout = GridLayoutUtil.CreateNaturalGridLayout(viewFrame:GetWidth(), self.xPadding, self.yPadding, 1, -1);
end

function PagedNaturalSizeGridContentFrameMixin:GetElementStride(elementTemplateInfo, isHeader, isFirstInRow)
	if isHeader and self.autoExpandHeaders then
		return self.viewLayout.stride;
	end
	local stride = elementTemplateInfo.width;
	if not isFirstInRow then
		stride = stride + self.viewLayout.primarySizePadding;
	end
	return stride;
end

function PagedNaturalSizeGridContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementData, elementIndex)
	spacerFrame:SetHeight(self.spacerSize);
	spacerFrame:SetWidth(self.ViewFrames[1]:GetWidth());
end

function PagedNaturalSizeGridContentFrameMixin:ProcessElementFrame(elementFrame, elementData, elementIndex)
	if self.autoExpandHeaders and elementData.isHeader then
		elementFrame:SetWidth(self.ViewFrames[1]:GetWidth());
	end
end