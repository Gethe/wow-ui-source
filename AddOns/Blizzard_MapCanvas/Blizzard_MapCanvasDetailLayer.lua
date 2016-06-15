MAP_CANVAS_TILE_WIDTH = 256;
MAP_CANVAS_TILE_HEIGHT = 256;

MapCanvasDetailLayerMixin = {};

function MapCanvasDetailLayerMixin:OnLoad()
	self.detailTilePool = CreateTexturePool(self, "BACKGROUND", -7, "MapCanvasDetailTileTemplate");
end

function MapCanvasDetailLayerMixin:SetMapAndLayer(mapID, layerIndex)
	if self.mapID ~= mapID or self.layerIndex ~= layerIndex then
		self.mapID = mapID;
		self.layerIndex = layerIndex;

		self:RefreshDetailTiles();
	end
end

function MapCanvasDetailLayerMixin:GetLayerIndex()
	return self.layerIndex;
end

function MapCanvasDetailLayerMixin:RefreshDetailTiles()
	self.detailTilePool:ReleaseAll();

	local numDetailTilesCols, numDetailTilesRows = C_MapCanvas.GetNumDetailTiles(self.mapID, self.layerIndex);

	for tileCol = 1, numDetailTilesCols do
		for tileRow = 1, numDetailTilesRows do
			local texturePath = C_MapCanvas.GetDetailTileInfo(self.mapID, self.layerIndex, tileCol, tileRow);

			local detailTile = self.detailTilePool:Acquire();
			detailTile:SetTexture(texturePath);

			local offsetX = math.floor(MAP_CANVAS_TILE_WIDTH * (tileCol - 1));
			local offsetY = math.floor(MAP_CANVAS_TILE_HEIGHT * (tileRow - 1));

			detailTile:ClearAllPoints();
			detailTile:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, -offsetY);
			detailTile:SetDrawLayer("BACKGROUND", -8 + self.layerIndex);
			detailTile:Show();
		end
	end
end

function MapCanvasDetailLayer_CalculateTotalLayerSize(numDetailTilesCols, numDetailTilesRows)
	-- The last tiles aren't fully used, we have to adjust the size slightly :(
	local WIDTH_INSET = 175;
	local HEIGHT_INSET = 120;

	return MAP_CANVAS_TILE_WIDTH * numDetailTilesCols - WIDTH_INSET, MAP_CANVAS_TILE_HEIGHT * numDetailTilesRows - HEIGHT_INSET;
end