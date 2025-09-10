ScrollBoxListBiaxalViewMixin = CreateFromMixins(ScrollBoxListViewMixin);

function ScrollBoxListBiaxalViewMixin:Init(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	ScrollBoxListViewMixin.Init(self);
	self:SetPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing);

	-- Unsupported in Biaxal views. Will remain unsupported until it is requested.
	self.SetHorizontal = nil;
end

function ScrollBoxListBiaxalViewMixin:SetPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	local padding = CreateScrollBoxBiaxalPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing);
	ScrollBoxListViewMixin.SetPadding(self, padding);
end

function ScrollBoxListBiaxalViewMixin:GetHorizontalSpacing()
	return self.padding:GetHorizontalSpacing();
end

function ScrollBoxListBiaxalViewMixin:GetVerticalSpacing()
	return self.padding:GetVerticalSpacing();
end

function ScrollBoxListBiaxalViewMixin:GetExtentSpacing()
	return self:GetVerticalSpacing();
end

function ScrollBoxListBiaxalViewMixin:HasBiaxalLayout()
	return true;
end

function ScrollBoxListBiaxalViewMixin:ResizeFrame(scrollBox, frame, dataIndex, elementData)
	local width, height = self:CalculateFrameSize(dataIndex, elementData);
	frame:SetSize(width, height);
end

function ScrollBoxListBiaxalViewMixin:SetElementSizeCalculator(elementSizeCalculator)
	self:ClearElementSizeData();
	self.elementSizeCalculator = elementSizeCalculator;
end

function ScrollBoxListBiaxalViewMixin:GetElementSizeCalculator()
	return self.elementSizeCalculator;
end

function ScrollBoxListBiaxalViewMixin:ClearElementSizeData()
	self:ClearCachedData();
	ScrollBoxListViewMixin.ClearElementExtentData(self);
end

function ScrollBoxListBiaxalViewMixin:ClearCachedData()
	self.calculatedElementSizes = nil;
	self.templateSizes = nil;
end

function ScrollBoxListBiaxalViewMixin:HasIdenticalElementSize()
	if self.elementSizeCalculator then
		return false;
	end

	return self.hasIdenticalTemplateSize;
end

function ScrollBoxListBiaxalViewMixin:GetIdenticalElementSize()
	assert(self:HasIdenticalElementSize());

	local info = self:GetFirstTemplateInfo();
	return info.width, info.height;
end

function ScrollBoxListBiaxalViewMixin:GetTemplateSizeFromElementData(elementData)
	local frameTemplate, initializer = self:GetFactoryDataFromElementData(elementData);
	local info = self:GetTemplateInfo(frameTemplate);
	if not info then
		error(string.format("GetTemplateSizeFromElementData: Failed to obtain template info for frame template '%s'", frameTemplate));
	end

	return info.width, info.height;
end

function ScrollBoxListBiaxalViewMixin:CalculateFrameSize(dataIndex, elementData)
	if self.elementSizeCalculator then
		return self.elementSizeCalculator(dataIndex, elementData);
	end

	return self:GetTemplateSizeFromElementData(elementData);
end

function ScrollBoxListBiaxalViewMixin:GetElementSize(dataIndex)
	local size = self:GetDataProviderSize();
	if dataIndex < 1 or dataIndex > size then
		return 0, 0;
	end

	if self.calculatedElementSizes then
		return unpack(self.calculatedElementSizes[dataIndex]);
	elseif self:HasIdenticalElementSize() then 
		return self:GetIdenticalElementSize();
	elseif self.templateSizes then
		return unpack(self.templateSizes[dataIndex]);
	end
	return 0, 0;
end

function ScrollBoxListBiaxalViewMixin:HasAnyExtentOrSizeCalculator()
	return self.elementSizeCalculator ~= nil;
end

function ScrollBoxListBiaxalViewMixin:CalculateFrameExtent(dataIndex, elementData)
	if self.elementExtent then
		return self.elementExtent;
	end

	local width, height = self:CalculateFrameSize(dataIndex, elementData);
	return height;
end

function ScrollBoxListBiaxalViewMixin:GetElementExtent(dataIndex)
	local width, height = self:GetElementSize(dataIndex);
	return height;
end

do
	local function HasIdenticalTemplateSize(view, infos)
		local templateInfo = infos[next(infos)];
		if not templateInfo then
			return false;
		end

		local width = templateInfo.width;
		local height = templateInfo.height;
		if width <= 0 or height <= 0 then
			return false;
		end

		for frameTemplate, info in pairs(infos) do
			if not ApproximatelyEqual(width, info.width) or not ApproximatelyEqual(height, info.height) then
				return false;
			end
		end
	
		return true;
	end

	local function CalculateSizes(view, tbl, size)
		for dataIndex, elementData in view:EnumerateDataProvider() do
			local frameWidth, frameHeight = view:CalculateFrameSize(dataIndex, elementData);
			table.insert(tbl, {frameWidth, frameHeight});
		end
		
		return view:GetExtentTo(scrollBox, size);
	end

	function ScrollBoxListBiaxalViewMixin:RecalculateExtent(scrollBox)
		self:PrepareRecalculateExtent();

		local infos = self.templateInfoCache:GetTemplateInfos();
		self.hasIdenticalTemplateSize = HasIdenticalTemplateSize(self, infos);

		local extent = 0;
		local size = self:GetDataProviderSize();
		if size > 0 then
			if self.elementSizeCalculator then
				self.calculatedElementSizes = {};
				extent = CalculateSizes(self, self.calculatedElementSizes, size);
			elseif self:HasIdenticalElementSize() then 
				extent = self:GetExtentTo(scrollBox, size);
			else
				self.templateSizes = {};
				extent = CalculateSizes(self, self.templateSizes, size);
			end
		end
	
		self:SetExtent(extent + scrollBox:GetExtentPadding());
	end
end
