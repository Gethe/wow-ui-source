WorldMapPOIQuantizerMixin = {};

function WorldMapPOIQuantizerMixin:OnLoad(numCellsWide, numCellsHigh)
	self:Resize(numCellsWide, numCellsHigh);
end

function WorldMapPOIQuantizerMixin:Resize(numCellsWide, numCellsHigh)
	self.grid = CreateFromMixins(SparseGridMixin);
	self.grid:OnLoad(numCellsWide, numCellsHigh);

	self.numCellsWide = numCellsWide;
	self.numCellsHigh = numCellsHigh;
end

function WorldMapPOIQuantizerMixin:Clear()
	self.grid:Clear();
end

local CENTER = { 0, 0 };
local UPPER_RIGHT = { 1, 1 };
local RIGHT = { 1, 0 };
local LOWER_RIGHT = { 1, -1 };
local LOWER = { 0, -1 };
local LOWER_LEFT = { -1, -1 };
local LEFT = { -1, 0 };
local UPPER_LEFT = { -1, 1 };
local UPPER = { 0, 1 };

local RIGHT_TOP = { CENTER, UPPER_RIGHT, RIGHT, UPPER, LOWER_RIGHT, UPPER_LEFT, LOWER, LEFT, LOWER_LEFT };
local TOP_RIGHT = { CENTER, UPPER_RIGHT, UPPER, RIGHT, UPPER_LEFT, LOWER_RIGHT, LEFT, LOWER, LOWER_LEFT };

local LEFT_TOP = { CENTER, UPPER_LEFT, LEFT, UPPER, LOWER_LEFT, UPPER_RIGHT, LOWER, RIGHT, LOWER_RIGHT };
local TOP_LEFT = { CENTER, UPPER_LEFT, UPPER, LEFT, UPPER_RIGHT, LOWER_LEFT, RIGHT, LOWER, LOWER_RIGHT };

local LEFT_BOTTOM = { CENTER, LOWER_LEFT, LEFT, LOWER, UPPER_LEFT, LOWER_RIGHT, UPPER, RIGHT, UPPER_RIGHT };
local BOTTOM_LEFT = { CENTER, LOWER_LEFT, LOWER, LEFT, LOWER_RIGHT, UPPER_LEFT, RIGHT, UPPER, UPPER_RIGHT };

local RIGHT_BOTTOM = { CENTER, LOWER_RIGHT, RIGHT, LOWER, UPPER_RIGHT, LOWER_LEFT, UPPER, LEFT, UPPER_LEFT };
local BOTTOM_RIGHT = { CENTER, LOWER_RIGHT, LOWER, RIGHT, LOWER_LEFT, UPPER_RIGHT, LEFT, UPPER, UPPER_LEFT };

local function FindBestEnumerator(normalizedX, normalizedY)
	if normalizedX > .5 then -- right
		if normalizedY > .5 then -- topright
			if normalizedX > normalizedY then -- more right than top
				return ipairs(RIGHT_TOP);
			else							  -- more top than right
				return ipairs(TOP_RIGHT);
			end
		else -- bottomright
			if 1.0 - normalizedX < normalizedY then -- more right than bottom
				return ipairs(RIGHT_BOTTOM);
			else								    -- more bottom than right
				return ipairs(BOTTOM_RIGHT);
			end
		end
	else -- left
		if normalizedY > .5 then -- topleft
			if normalizedX < 1.0 - normalizedY then -- more left than top
				return ipairs(LEFT_TOP);
			else									-- more top than left
				return ipairs(TOP_LEFT);
			end
		else -- bottomleft
			if normalizedX < normalizedY then -- more left than bottom
				return ipairs(LEFT_BOTTOM);
			else							  -- more bottom than left
				return ipairs(BOTTOM_LEFT);
			end
		end
	end
end

function WorldMapPOIQuantizerMixin:ClearAndQuantize(poiList)
	self:Clear();
	self:RemoveQuantization(poiList);
	self:Quantize(poiList);
end

function WorldMapPOIQuantizerMixin:RemoveQuantization(poiList)
	for i, poiData in pairs(poiList) do
		poiData.quantizedX = nil;
		poiData.quantizedY = nil;
	end
end

function WorldMapPOIQuantizerMixin:Quantize(poiList)
	for i, poiData in pairs(poiList) do
		local normalizedX, normalizedY = poiData.normalizedX or poiData.x, poiData.normalizedY or poiData.y;
		local cellX = normalizedX * self.numCellsWide;
		local cellY = normalizedY * self.numCellsHigh;
		local cellIndexX = math.min(math.floor(cellX) + 1, self.numCellsWide);
		local cellIndexY = math.min(math.floor(cellY) + 1, self.numCellsHigh);

		local foundCell = false; 
		local hasNeighbor = false;
		for j, offsetData in FindBestEnumerator(cellX % 1, cellY % 1) do
			local xOffset, yOffset = unpack(offsetData);
			if self.grid:IsInRange(cellIndexX + xOffset, cellIndexY + yOffset) then
				local existingPOIData = self.grid:GetCell(cellIndexX + xOffset, cellIndexY + yOffset);
				if existingPOIData then
					self:QuantizePOI(existingPOIData, cellIndexX + xOffset, cellIndexY + yOffset);

					hasNeighbor = true;
				elseif not foundCell then
					foundCell = true;

					self.grid:SetCell(cellIndexX + xOffset, cellIndexY + yOffset, poiData);
					self:QuantizePOI(poiData, cellIndexX + xOffset, cellIndexY + yOffset);
				end
			end
		end
		if foundCell and not hasNeighbor then
			-- Nothing near us, just leave us alone
			poiData.quantizedX = nil;
			poiData.quantizedY = nil;		
		end
		-- If we don't find an open cell just leave it where its at, the grid is too small
	end
end

function WorldMapPOIQuantizerMixin:QuantizePOI(poiData, cellIndexX, cellIndexY)
	poiData.quantizedX = poiData.quantizedX or (cellIndexX - .5) / self.numCellsWide;
	poiData.quantizedY = poiData.quantizedY or (cellIndexY - .5) / self.numCellsHigh;
end