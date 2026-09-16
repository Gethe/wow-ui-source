RegionLayoutManager = {};

-- emptyKey refers to nothing; e.g. the first region comes after nothing, it's the spacing from the initial anchor.
-- allKey refers to any object; e.g. no matter what this region comes after use the given spacing.
function RegionLayoutManager:Init(emptyKey, allKey, defaultSpacingValue)
	self.emptyKey = emptyKey;
	self.allKey = allKey;
	self.spacing = {};
	self.defaultSpacingValue = defaultSpacingValue or 0;
end

function RegionLayoutManager:AddSpacingPair(previous, current, spacing)
	if not self.spacing[current] then
		self.spacing[current] = {};
	end

	self.spacing[current][previous] = spacing;
end

function RegionLayoutManager:GetSpacingData(spacingTable, key)
	local spacingData = spacingTable[key];
	if spacingData then
		return spacingData;
	end

	if self.allKey and key ~= self.emptyKey then
		return spacingTable[self.allKey];
	end

	return nil;
end

function RegionLayoutManager:GetSpacing(previousKey, currentKey, ...)
	local currentSpacingData = self:GetSpacingData(self.spacing, currentKey);

	if not currentSpacingData then
		return self.defaultSpacingValue;
	end

	local spacing = self:GetSpacingData(currentSpacingData, previousKey);

	if type(spacing) == "function" then
		return spacing(previousKey, currentKey, ...) or self.defaultSpacingValue;
	end

	return spacing or self.defaultSpacingValue;
end
