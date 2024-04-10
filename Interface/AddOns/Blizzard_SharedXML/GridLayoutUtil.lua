
-- Utility for laying out regions in a loosely grid-like structure. A list of regions is grouped into sections,
-- and then into cross section groups, each of which is composed of subgroups. For illustration, consider a grid
-- of frames (potentially different sizes) that are grouped into rows and columns. For this utility, each column might
-- contain multiple elements from each row, or even different number of elements from each different row, i.e. two small
-- elements might be grouped into the same column.
--
-- [  1  2  3  ]
-- [  4  5  6  ]
-- [  7  8  9  ]
-- sections: { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }
-- crossSections: [ { 1 }, { 4 }, { 7 } ], [ { 2 }, { 5 }, { 8 } ], [ { 3 }, { 6 }, { 9 } ]
-- (each cross section considers groups of elements, even if there is only a single element present in each).
--
-- [ 1 2   3    4  ]
-- [  5    6    7  ]
-- [ 8 9   a   b c ]
-- sections: { 1, 2, 3, 4 }, { 5, 6, 7 }, { 8, 9, a, b, c }
-- crossSections: [ { 1, 2 }, { 5 }, { 8, 9 } ], [ { 3 }, { 6 }, { a } ], [ { 4 }, { 7 }, { b, c } ]
--
-- Groupings and measurings are axis-agnostic so the primary grouping might be horizontally based on rows and widths,
-- or vertically based on columns and heights.
-- 
-- GridLayoutManagerMixin is used to house all the different specifications required to described different layouts.
--
-- The primary elements of GridLayoutManagerMixin are:
--  primarySizeCalculator: how to measure regions. Typically GetWidth or GetHeight.
--  secondarySizeCalculator: how to measure regions. Typically GetWidth or GetHeight.
--  primaryMultiplier: to be used when applying offsets. Typically 1 or -1.
--  secondaryMultiplier: to be used when applying offsets. Typically 1 or -1.
--  primarySizePadding: padding between elements in sections.
--  secondarySizePadding: padding between sections.
--  isHeightPrimary: by default, width is primary. Set to switch to height as primary.
--
--  sectionStrategy: how elements are grouped into sections.
--  crossSectionStrategy: how elements are grouped into crossSections based on the given sections.
--  Notes: For example, sub-divide regions based on count. Or group by width with a fixed rowSize, and subdivide into
--         crossSections where multiple smaller elements may be grouped together.
--
--  primaryPaddingStrategy: resolution between different sized regions/groupings, applied based on crossSections.
--  secondaryPaddingStrategy: resolution between different size regions in a section.
--  Notes: "leading" space is referred to as padding, and "trailing" space is referred to as spacing. This is all relative to direction though.
--
-- GridLayoutManagerMixin:ApplyToRegions is the engine that runs at the heart of the system. The algorithm is:
-- 1. Group regions into sections.
-- 2. Based on sections, generate cross sections.
-- 3. Add extra padding along the primary axis based on cross sections.
-- 4. Add extra padding along the secondary axis based on sections.
-- 5. Apply the initial anchor to each frame, with offsets for each based driection and the sizes and spacings calculated for sections and regions.


GridLayoutUtil = {};

-- First pass at a compatilibity layer to interface with the AnchorUtil version of this stuff.
function GridLayoutUtil.GridLayoutRegions(regions, initialAnchor, layout)
	if #regions == 0 then
		return;
	end

	local isColumnBased = layout.isColumnBased;
	local primarySizeCalculator = isColumnBased and regions[1].GetHeight or regions[1].GetWidth;
	local secondarySizeCalculator = isColumnBased and regions[1].GetWidth or regions[1].GetHeight;
	local primarySizePadding = isColumnBased and layout.paddingY or layout.paddingX;
	local secondarySizePadding = isColumnBased and layout.paddingX or layout.paddingY;
	local primaryMultiplier = isColumnBased and layout.direction.y or layout.direction.x;
	local secondaryMultiplier = isColumnBased and layout.direction.x or layout.direction.y;
	local layoutManager = CreateAndInitFromMixin(GridLayoutManagerMixin, primarySizeCalculator, secondarySizeCalculator, primaryMultiplier, secondaryMultiplier, primarySizePadding, secondarySizePadding);

	layoutManager:SetHeightAsPrimary(layout.isColumnBased);

	layoutManager:SetPrimaryPaddingStrategy(GridLayoutUtilPrimaryPaddingStrategy.AllPaddingToFirst);
	layoutManager:SetSecondaryPaddingStrategy(GridLayoutUtilSecondaryPaddingStrategy.Equal);

	local sectionSize = layout.stride;
	if layout.direction.isVertical then
		layoutManager:SetSectionStrategy(GenerateClosure(GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSectionsVertical, sectionSize));
	else
		layoutManager:SetSectionStrategy(GenerateClosure(GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSections, sectionSize));
	end

	layoutManager:SetCrossSectionStrategy(GridLayoutUtilCrossSectionStrategy.CalculateGridCrossSections);
	layoutManager:ApplyToRegions(initialAnchor, regions);
end

-- Layout a grid with each frame taking up one cell regardless of actual width/height.
function GridLayoutUtil.CreateStandardGridLayout(stride, xPadding, yPadding, xMultiplier, yMultiplier, isColumnBased)
	local layout = GridLayoutUtil.CreateGridLayout();
	layout.primarySizePadding = (xPadding or layout.primarySizePadding);
	layout.secondarySizePadding = (yPadding or layout.secondarySizePadding);
	layout.primaryMultiplier = (xMultiplier or layout.primaryMultiplier);
	layout.secondaryMultiplier = (yMultiplier or layout.secondaryMultiplier);
	layout.isColumnBased = isColumnBased;
	layout.sectionStrategy = GenerateClosure(GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSections, stride);

	layout.crossSectionStrategy = GridLayoutUtilCrossSectionStrategy.CalculateGridCrossSections;

	return layout;
end

-- Layout a grid with each frame taking up one cell regardless of actual width/height.
function GridLayoutUtil.CreateVerticalGridLayout(stride, xPadding, yPadding, xMultiplier, yMultiplier)
	-- Calling standard grid layout but flipping x and y to account for being vertical rather than horizontal
	local isColumnBased = true;
	return GridLayoutUtil.CreateStandardGridLayout(stride, yPadding, xPadding, yMultiplier, xMultiplier, isColumnBased);
end

-- Layout a grid based on the frame's actual UI width/height.
function GridLayoutUtil.CreateNaturalGridLayout(stride, xPadding, yPadding, xMultiplier, yMultiplier)
	local gridLayout = GridLayoutUtil.CreateGridLayout();
	gridLayout.primarySizePadding = (xPadding or gridLayout.primarySizePadding);
	gridLayout.secondarySizePadding = (yPadding or gridLayout.secondarySizePadding);
	gridLayout.primaryMultiplier = (xMultiplier or gridLayout.primaryMultiplier);
	gridLayout.secondaryMultiplier = (yMultiplier or gridLayout.secondaryMultiplier);

	gridLayout.primaryPaddingStrategy = GridLayoutUtilPrimaryPaddingStrategy.AllSpacingToLast;
	gridLayout.secondaryPaddingStrategy = GridLayoutUtilSecondaryPaddingStrategy.Equal;

	gridLayout.sectionStrategy = GenerateClosure(GridLayoutUtilSectionStrategy.SplitRegionsIntoSectionsByNaturalSize, stride);
	gridLayout.crossSectionStrategy = GridLayoutUtilCrossSectionStrategy.CalculateFlatCrossSections;

	return gridLayout;
end

function GridLayoutUtil.ApplyGridLayout(regions, initialAnchor, gridLayout)
	if #regions == 0 then
		return;
	end

	local isColumnBased = gridLayout.isColumnBased;
	local primarySizeCalculator = isColumnBased and regions[1].GetHeight or regions[1].GetWidth;
	local secondarySizeCalculator = isColumnBased and regions[1].GetWidth or regions[1].GetHeight;
	local layoutManager = CreateAndInitFromMixin(GridLayoutManagerMixin, primarySizeCalculator, secondarySizeCalculator, gridLayout.primaryMultiplier, gridLayout.secondaryMultiplier,
													gridLayout.primarySizePadding, gridLayout.secondarySizePadding);

	layoutManager:SetHeightAsPrimary(isColumnBased);

	layoutManager:SetPrimaryPaddingStrategy(gridLayout.primaryPaddingStrategy, gridLayout.minimumPrimarySize);
	layoutManager:SetSecondaryPaddingStrategy(gridLayout.secondaryPaddingStrategy, gridLayout.minimumSecondarySize);
	layoutManager:SetSectionStrategy(gridLayout.sectionStrategy);
	layoutManager:SetCrossSectionStrategy(gridLayout.crossSectionStrategy);
	layoutManager:ApplyToRegions(initialAnchor, regions);
end

function GridLayoutUtil.CreateGridLayout()
	return {
		primarySizeCalculator = UIParent.GetWidth,
		secondarySizeCalculator = UIParent.GetHeight,
		primarySizePadding = 0,
		secondarySizePadding = 0,
		primaryMultiplier = 1,
		secondaryMultiplier = -1,
		primaryPaddingStrategy = GridLayoutUtilPrimaryPaddingStrategy.AllPaddingToFirst,
		secondaryPaddingStrategy = GridLayoutUtilSecondaryPaddingStrategy.Equal,
		isColumnBased = false,
	};
end


GridLayoutManagerMixin = {};

function GridLayoutManagerMixin:Init(primarySizeCalculator, secondarySizeCalculator, primaryMultiplier, secondaryMultiplier, primarySizePadding, secondarySizePadding)
	self.primarySizeCalculator = primarySizeCalculator;
	self.secondarySizeCalculator = secondarySizeCalculator;
	self.primaryMultiplier = primaryMultiplier;
	self.secondaryMultiplier = secondaryMultiplier;
	self.primarySizePadding = primarySizePadding;
	self.secondarySizePadding = secondarySizePadding;
end

function GridLayoutManagerMixin:SetSectionStrategy(sectionStrategy)
	self.sectionStrategy = sectionStrategy;
end

function GridLayoutManagerMixin:SetCrossSectionStrategy(crossSectionStrategy)
	self.crossSectionStrategy = crossSectionStrategy;
end

function GridLayoutManagerMixin:SetPrimaryPaddingStrategy(primaryPaddingStrategy, minimumPrimarySize)
	self.primaryPaddingStrategy = primaryPaddingStrategy;
	self.minimumPrimarySize = minimumPrimarySize;
end

function GridLayoutManagerMixin:SetSecondaryPaddingStrategy(secondaryPaddingStrategy, minimumSecondarySize)
	self.secondaryPaddingStrategy = secondaryPaddingStrategy;
	self.minimumSecondarySize = minimumSecondarySize;
end

function GridLayoutManagerMixin:SetHeightAsPrimary(isHeightPrimary)
	self.isHeightPrimary = isHeightPrimary;
end

function GridLayoutManagerMixin:ApplyToRegions(initialAnchor, regions)
	if #regions == 0 then
		return;
	end

	local sectionGroup = self.sectionStrategy(self, regions);
	local crossSectionGroups = self.crossSectionStrategy(self, sectionGroup);
	self:ApplyPrimaryPadding(crossSectionGroups);
	self:ApplySecondaryPadding(sectionGroup);
	self:ApplyAnchoring(sectionGroup, initialAnchor);
end

function GridLayoutManagerMixin:ApplyPrimaryPadding(crossSectionGroups)
	if self.primaryPaddingStrategy == nil then
		return;
	end

	local minimumPrimarySize = self.minimumPrimarySize or 0;
	for crossSectionIndex, crossSectionGroup in ipairs(crossSectionGroups) do
		local crossSectionPrimarySize = math.max(minimumPrimarySize, crossSectionGroup:GetCachedPrimarySize());
		for sectionIndex, section in crossSectionGroup:EnumerateSections() do
			local availableSpace = crossSectionPrimarySize - section:GetCachedPrimarySize();
			self.primaryPaddingStrategy(section, GridLayoutRegionEntryMixin.GetPrimarySize, GridLayoutRegionEntryMixin.SetExtraPrimaryPadding, GridLayoutRegionEntryMixin.SetExtraPrimarySpacing, availableSpace);
		end
	end
end

function GridLayoutManagerMixin:ApplySecondaryPadding(sectionGroup)
	if self.secondaryPaddingStrategy == nil then
		return;
	end

	local minimumSecondarySize = self.minimumSecondarySize or 0;
	for sectionIndex, section in sectionGroup:EnumerateSections() do
		local sectionSecondarySize = math.max(minimumSecondarySize, section:GetCachedSecondarySize());
		self.secondaryPaddingStrategy(section, GridLayoutRegionEntryMixin.GetSecondarySize, GridLayoutRegionEntryMixin.SetExtraSecondaryPadding, GridLayoutRegionEntryMixin.SetExtraSecondarySpacing, sectionSecondarySize);
	end
end

function GridLayoutManagerMixin:ApplyAnchoring(sectionGroup, initialAnchor)
	local isHeightPrimary = self.isHeightPrimary;
	local primaryMultiplier = self.primaryMultiplier;
	local secondaryMultiplier = self.secondaryMultiplier;

	local primaryOffset = 0;
	local secondaryOffset = 0;
	local sectionPrimaryPadding = (self:GetPrimarySizePadding() * primaryMultiplier);
	for sectionIndex, section in sectionGroup:EnumerateSections() do
		primaryOffset = 0;

		for regionEntryIndex, regionEntry in section:EnumerateRegionEntries() do
			if regionEntryIndex ~= 1 then
				primaryOffset = primaryOffset + sectionPrimaryPadding;
			end

			local extraPrimaryPadding = (regionEntry:GetExtraPrimaryPadding() * primaryMultiplier);
			primaryOffset = primaryOffset + extraPrimaryPadding;

			local secondaryPadding = regionEntry:GetExtraSecondaryPadding() * secondaryMultiplier;
			local clearAllPoints = true;

			if isHeightPrimary then
				initialAnchor:SetPointWithExtraOffset(regionEntry:GetRegion(), clearAllPoints, secondaryOffset + secondaryPadding, primaryOffset);
			else
				initialAnchor:SetPointWithExtraOffset(regionEntry:GetRegion(), clearAllPoints, primaryOffset, secondaryOffset + secondaryPadding);
			end

			local primaryAdjustment = ((regionEntry:GetPrimarySize() + regionEntry:GetExtraPrimarySpacing()) * primaryMultiplier);
			primaryOffset = primaryOffset + primaryAdjustment;
		end

		local sectionSpacing = (section:GetSecondarySize() + self:GetSecondarySizePadding()) * secondaryMultiplier;
		secondaryOffset = secondaryOffset + sectionSpacing;
	end
end

function GridLayoutManagerMixin:CalculatePrimarySize(region)
	return self.primarySizeCalculator(region);
end

function GridLayoutManagerMixin:CalculateSecondarySize(region)
	return self.secondarySizeCalculator(region);
end

function GridLayoutManagerMixin:GetPrimarySizePadding()
	return self.primarySizePadding;
end

function GridLayoutManagerMixin:GetSecondarySizePadding()
	return self.secondarySizePadding;
end


GridLayoutRegionEntryMixin = {};

function GridLayoutRegionEntryMixin:Init(layoutManager, region)
	self.region = region;
	self.primarySize = layoutManager:CalculatePrimarySize(region);
	self.secondarySize = layoutManager:CalculateSecondarySize(region);
end

function GridLayoutRegionEntryMixin:GetRegion()
	return self.region;
end

function GridLayoutRegionEntryMixin:GetPrimarySize()
	return self.primarySize;
end

function GridLayoutRegionEntryMixin:GetSecondarySize()
	return self.secondarySize;
end

function GridLayoutRegionEntryMixin:SetExtraPrimaryPadding(extraPrimaryPadding)
	self.extraPrimaryPadding = extraPrimaryPadding;
end

function GridLayoutRegionEntryMixin:GetExtraPrimaryPadding()
	return self.extraPrimaryPadding or 0;
end

function GridLayoutRegionEntryMixin:SetExtraSecondaryPadding(extraSecondaryPadding)
	self.extraSecondaryPadding = extraSecondaryPadding;
end

function GridLayoutRegionEntryMixin:GetExtraSecondaryPadding()
	return self.extraSecondaryPadding or 0;
end

function GridLayoutRegionEntryMixin:SetExtraPrimarySpacing(extraPrimarySpacing)
	self.extraPrimarySpacing = extraPrimarySpacing;
end

function GridLayoutRegionEntryMixin:GetExtraPrimarySpacing()
	return self.extraPrimarySpacing or 0;
end

function GridLayoutRegionEntryMixin:SetExtraSecondarySpacing(extraSecondarySpacing)
	self.extraSecondarySpacing = extraSecondarySpacing;
end

function GridLayoutRegionEntryMixin:GetExtraSecondarySpacing()
	return self.extraSecondarySpacing or 0;
end


GridLayoutSectionMixin = {};

function GridLayoutSectionMixin:Init(layoutManager)
	self.layoutManager = layoutManager;
	self.regionEntries = {};
end

function GridLayoutSectionMixin:AddRegion(region)
	table.insert(self.regionEntries, CreateAndInitFromMixin(GridLayoutRegionEntryMixin, self.layoutManager, region));
end

function GridLayoutSectionMixin:AddRegionEntry(regionEntry)
	table.insert(self.regionEntries, regionEntry);
end

function GridLayoutSectionMixin:GetRegionEntry(index)
	return self.regionEntries[index];
end

function GridLayoutSectionMixin:GetNumRegionEntries()
	return #self.regionEntries;
end

function GridLayoutSectionMixin:EnumerateRegionEntries()
	return ipairs(self.regionEntries);
end

function GridLayoutSectionMixin:GetCachedPrimarySize()
	if self.cachedPrimarySize then
		return self.cachedPrimarySize;
	end

	self.cachedPrimarySize = self:GetPrimarySize();
	return self.cachedPrimarySize;
end

function GridLayoutSectionMixin:GetPrimarySize()
	local totalPrimarySize = 0;
	local numRegionEntries = #self.regionEntries;
	for i, regionEntry in ipairs(self.regionEntries) do
		totalPrimarySize = totalPrimarySize + regionEntry:GetPrimarySize();

		if i ~= numRegionEntries then
			totalPrimarySize = totalPrimarySize + self.layoutManager:GetPrimarySizePadding();
		end
	end

	return totalPrimarySize;
end

function GridLayoutSectionMixin:GetCachedSecondarySize()
	if self.cachedSecondarySize then
		return self.cachedSecondarySize;
	end

	self.cachedSecondarySize = self:GetSecondarySize();
	return self.cachedSecondarySize;
end

function GridLayoutSectionMixin:GetSecondarySize()
	local maxSecondarySize = 0;
	for i, regionEntry in ipairs(self.regionEntries) do
		maxSecondarySize = math.max(maxSecondarySize, regionEntry:GetSecondarySize());
	end

	return maxSecondarySize;
end


GridLayoutSectionGroupMixin = {};

function GridLayoutSectionGroupMixin:Init(layoutManager)
	self.layoutManager = layoutManager;
	self.sections = {};
end

function GridLayoutSectionGroupMixin:AddEmptySection()
	local newSection = CreateAndInitFromMixin(GridLayoutSectionMixin, self.layoutManager);
	table.insert(self.sections, newSection);
	return newSection;
end

function GridLayoutSectionGroupMixin:AddToSection(sectionIndex, regionEntry)
	self.sections[sectionIndex] = self.sections[sectionIndex] or CreateAndInitFromMixin(GridLayoutSectionMixin, self.layoutManager);
	self.sections[sectionIndex]:AddRegionEntry(regionEntry);
end

function GridLayoutSectionGroupMixin:EnumerateSections()
	return ipairs(self.sections);
end

function GridLayoutSectionGroupMixin:GetCachedPrimarySize()
	if self.cachedPrimarySize then
		return self.cachedPrimarySize;
	end

	self.cachedPrimarySize = self:GetPrimarySize();
	return self.cachedPrimarySize;
end

function GridLayoutSectionGroupMixin:GetPrimarySize()
	local maxPrimarySize = 0;
	for i, section in ipairs(self.sections) do
		maxPrimarySize = math.max(maxPrimarySize, section:GetPrimarySize());
	end

	return maxPrimarySize;
end

function GridLayoutSectionGroupMixin:GetCachedSecondarySize()
	if self.cachedSecondarySize then
		return self.cachedSecondarySize;
	end

	self.cachedSecondarySize = self:GetSecondarySize();
	return self.cachedSecondarySize;
end

function GridLayoutSectionGroupMixin:GetSecondarySize()
	local maxSecondarySize = 0;
	for i, section in ipairs(self.sections) do
		maxSecondarySize = math.max(maxSecondarySize, section:GetSecondarySize());
	end

	return maxSecondarySize;
end


GridLayoutUtilSectionStrategy = {};

function GridLayoutUtilSectionStrategy.SplitRegionsIntoSectionsBySize(maxSectionSize, layoutManager, regionDataProvider, sectionSizeCalculator)
	local sectionGroup = CreateAndInitFromMixin(GridLayoutSectionGroupMixin, layoutManager);
	local currentSection = sectionGroup:AddEmptySection();
	local currentSectionSize = 0;

	local infiniteGuard = 300;
	for i = 1, infiniteGuard do
		local region = regionDataProvider(i);
		if region == nil then
			break;
		end

		local isFirstInSection = (currentSectionSize == 0);
		local regionSize = sectionSizeCalculator(region, currentSectionSize);
		local newSectionSize = (currentSectionSize + regionSize);
		if isFirstInSection or (newSectionSize <= maxSectionSize) then
			currentSectionSize = newSectionSize;
		else
			currentSection = sectionGroup:AddEmptySection();
			currentSectionSize = regionSize;
		end

		currentSection:AddRegion(region);
	end

	return sectionGroup;
end

function GridLayoutUtilSectionStrategy.SplitRegionsIntoSectionsByNaturalSize(sectionSize, layoutManager, regions)
	local function NaturalRegionDataProvider(i)
		return regions[i];
	end

	local function NaturalSectionSizeCalculator(region, currentSectionSize)
		if currentSectionSize == 0 then
			return layoutManager:CalculatePrimarySize(region);
		else
			return layoutManager:CalculatePrimarySize(region) + layoutManager:GetPrimarySizePadding();
		end
	end

	return GridLayoutUtilSectionStrategy.SplitRegionsIntoSectionsBySize(sectionSize, layoutManager, NaturalRegionDataProvider, NaturalSectionSizeCalculator);
end

function GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSectionsInternal(sectionSize, layoutManager, regionDataProvider)
	local function GridSectionSizeCalculator(region, currentSectionSize)
		return 1;
	end

	return GridLayoutUtilSectionStrategy.SplitRegionsIntoSectionsBySize(sectionSize, layoutManager, regionDataProvider, GridSectionSizeCalculator);
end

function GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSections(sectionSize, layoutManager, regions)
	local function GridRegionDataProviderByRow(i)
		return regions[i];
	end

	return GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSectionsInternal(sectionSize, layoutManager, GridRegionDataProviderByRow);
end

function GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSectionsVertical(sectionSize, layoutManager, regions)
	local numRegions = #regions;
	local numCrossSections = math.ceil(numRegions / sectionSize);
	local function GridRegionDataProviderVertical(i)
		if i > numRegions then
			return nil;
		end

		local row = ((i - 1) % sectionSize) * numCrossSections;
		local column = math.ceil(i / sectionSize);
		return regions[row + column];
	end

	return GridLayoutUtilSectionStrategy.SplitRegionsIntoGridSectionsInternal(sectionSize, layoutManager, GridRegionDataProviderVertical);
end


GridLayoutUtilCrossSectionStrategy = {};

function GridLayoutUtilCrossSectionStrategy.CalculateGridCrossSections(layoutManager, sectionGroup)
	local crossSectionGroups = {};

	local infiniteGuard = 300;
	for crossSectionIndex = 1, infiniteGuard do
		local crossSection = CreateAndInitFromMixin(GridLayoutSectionGroupMixin, layoutManager);
		local crossSectionIsEmpty = true;
		for i, section in sectionGroup:EnumerateSections() do
			local sectionRegion = section:GetRegionEntry(crossSectionIndex);
			if sectionRegion then
				crossSection:AddToSection(i, sectionRegion);
				crossSectionIsEmpty = false;
			else
				crossSection:AddEmptySection();
			end
		end

		if crossSectionIsEmpty then
			break;
		end

		table.insert(crossSectionGroups, crossSection);
	end

	return crossSectionGroups;
end

function GridLayoutUtilCrossSectionStrategy.CalculateFlatCrossSections(layoutManager, sectionGroup)
	local crossSectionGroups = {};

	local crossSectionGroup = CreateAndInitFromMixin(GridLayoutSectionGroupMixin, layoutManager);
	for i, section in sectionGroup:EnumerateSections() do
		for j, region in section:EnumerateRegionEntries() do
			crossSectionGroup:AddToSection(i, region);
		end

	end
	table.insert(crossSectionGroups, crossSectionGroup);

	return crossSectionGroups;
end


GridLayoutUtilPrimaryPaddingStrategy = {};

function GridLayoutUtilPrimaryPaddingStrategy.AllPaddingToFirst(section, regionSizeCalculator, paddingSetter, spacingSetter, availableSize)
	local firstRegionEntry = section:GetRegionEntry(1);
	if firstRegionEntry ~= nil then
		paddingSetter(firstRegionEntry, availableSize);
	end
end

function GridLayoutUtilPrimaryPaddingStrategy.AllSpacingToLast(section, regionSizeCalculator, paddingSetter, spacingSetter, availableSize)
	local lastRegionIndex = section:GetNumRegionEntries();
	if lastRegionIndex ~= 0 then
		local lastRegionEntry = section:GetRegionEntry(lastRegionIndex);
		spacingSetter(lastRegionEntry, availableSize);
	end
end

function GridLayoutUtilPrimaryPaddingStrategy.EvenSpacing(section, regionSizeCalculator, paddingSetter, spacingSetter, availableSize)
	local numRegionEntries = section:GetNumRegionEntries();
	if numRegionEntries == 0 then
		return;
	end

	if numRegionEntries == 1 then
		local regionEntry = section:GetRegionEntry(1);
		local equalPadding = availableSize / 2;
		paddingSetter(regionEntry, equalPadding);
		spacingSetter(regionEntry, equalPadding);
		return;
	end

	local spacedEntries = numRegionEntries - 1;
	local equalSpacing = availableSize / spacedEntries;

	for i = 1, spacedEntries do
		local regionEntry = section:GetRegionEntry(i);
		spacingSetter(regionEntry, equalSpacing);
	end
end


GridLayoutUtilSecondaryPaddingStrategy = {};

function GridLayoutUtilSecondaryPaddingStrategy.Equal(section, regionSizeCalculator, paddingSetter, spacingSetter, sectionSecondarySize)
	for i, regionEntry in section:EnumerateRegionEntries() do
		local padding = (sectionSecondarySize - regionSizeCalculator(regionEntry)) / 2;
		paddingSetter(regionEntry, padding);
		spacingSetter(regionEntry, padding);
	end
end

function GridLayoutUtilSecondaryPaddingStrategy.AllPadding(section, regionSizeCalculator, paddingSetter, spacingSetter, sectionSecondarySize)
	for i, regionEntry in section:EnumerateRegionEntries() do
		local availableSize = sectionSecondarySize - regionSizeCalculator(regionEntry);
		paddingSetter(regionEntry, availableSize);
	end
end

function GridLayoutUtilSecondaryPaddingStrategy.AllSpacing(section, regionSizeCalculator, paddingSetter, spacingSetter, sectionSecondarySize)
	for i, regionEntry in section:EnumerateRegionEntries() do
		local availableSize = sectionSecondarySize - regionSizeCalculator(regionEntry);
		spacingSetter(regionEntry, availableSize);
	end
end
