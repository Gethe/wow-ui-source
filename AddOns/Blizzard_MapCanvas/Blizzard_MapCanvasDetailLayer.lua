
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

	local layers = C_Map.GetMapArtLayers(self.mapID);
	local layerInfo = layers[self.layerIndex];
	local numDetailTilesRows = math.ceil(layerInfo.layerHeight / layerInfo.tileHeight);
	local numDetailTilesCols = math.ceil(layerInfo.layerWidth / layerInfo.tileWidth);
	local textures = C_Map.GetMapArtLayerTextures(self.mapID, self.layerIndex);

	for tileCol = 1, numDetailTilesCols do
		for tileRow = 1, numDetailTilesRows do
			local detailTile = self.detailTilePool:Acquire();
			local textureIndex = (tileRow - 1) * numDetailTilesCols + tileCol;
			detailTile:SetTexture(textures[textureIndex]);

			local offsetX = math.floor(layerInfo.tileWidth * (tileCol - 1));
			local offsetY = math.floor(layerInfo.tileHeight * (tileRow - 1));

			detailTile:ClearAllPoints();
			detailTile:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, -offsetY);
			detailTile:SetDrawLayer("BACKGROUND", -8 + self.layerIndex);
			detailTile:Show();
		end
	end
end