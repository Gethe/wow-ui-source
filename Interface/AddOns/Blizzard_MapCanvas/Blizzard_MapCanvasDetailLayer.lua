
MapCanvasDetailLayerMixin = {};

function MapCanvasDetailLayerMixin:OnLoad()
	self.detailTilePool = CreateTexturePool(self, "BACKGROUND", -7, "MapCanvasDetailTileTemplate");
	self.textureLoadGroup = CreateFromMixins(TextureLoadingGroupMixin);
end

function MapCanvasDetailLayerMixin:SetMapAndLayer(mapID, layerIndex, mapCanvas)
	local mapArtID = C_Map.GetMapArtID(mapID) -- phased map art may be different for the same mapID
	if self.mapID ~= mapID or self.mapArtID ~= mapArtID or self.layerIndex ~= layerIndex then
		self.mapID = mapID;
		self.mapArtID = mapArtID;
		self.layerIndex = layerIndex;

		self:RefreshDetailTiles(mapCanvas);
	end
end

function MapCanvasDetailLayerMixin:GetLayerIndex()
	return self.layerIndex;
end

function MapCanvasDetailLayerMixin:IsFullyLoaded()
	return not self.isWaitingForLoad;
end

function MapCanvasDetailLayerMixin:SetLayerAlpha(layerAlpha)
	self.layerAlpha = layerAlpha;
	self:RefreshAlpha();
end

function MapCanvasDetailLayerMixin:GetLayerAlpha()
	return self.layerAlpha or 1;
end

function MapCanvasDetailLayerMixin:SetGlobalAlpha(globalAlpha)
	self.globalAlpha = globalAlpha;
	self:RefreshAlpha();
end

function MapCanvasDetailLayerMixin:GetGlobalAlpha()
	return self.globalAlpha or 1;
end

function MapCanvasDetailLayerMixin:RefreshDetailTiles(mapCanvas)
	self.detailTilePool:ReleaseAll();
	self.textureLoadGroup:Reset();
	self.isWaitingForLoad = true;

	local layers = C_Map.GetMapArtLayers(self.mapID);
	local layerInfo = layers[self.layerIndex];
	local numDetailTilesRows = math.ceil(layerInfo.layerHeight / layerInfo.tileHeight);
	local numDetailTilesCols = math.ceil(layerInfo.layerWidth / layerInfo.tileWidth);
	local textures = C_Map.GetMapArtLayerTextures(self.mapID, self.layerIndex);

	local prevRowDetailTile;
	local prevColDetailTile;
	for tileCol = 1, numDetailTilesCols do
		for tileRow = 1, numDetailTilesRows do
			if tileRow == 1 then
				prevRowDetailTile = nil;
			end
			local detailTile = self.detailTilePool:Acquire();
			mapCanvas:AddMaskableTexture(detailTile);
			self.textureLoadGroup:AddTexture(detailTile);
			local textureIndex = (tileRow - 1) * numDetailTilesCols + tileCol;
			detailTile:SetTexture(textures[textureIndex], nil, nil, "TRILINEAR");
			detailTile:ClearAllPoints();
			if prevRowDetailTile then
				detailTile:SetPoint("TOPLEFT", prevRowDetailTile, "BOTTOMLEFT");
			else
				if prevColDetailTile then
					detailTile:SetPoint("TOPLEFT", prevColDetailTile, "TOPRIGHT");
				else
					detailTile:SetPoint("TOPLEFT", self);
				end
			end
			detailTile:SetDrawLayer("BACKGROUND", -8 + self.layerIndex);
			detailTile:Show();
			prevRowDetailTile = detailTile;
			if tileRow == 1 then
				prevColDetailTile = detailTile;
			end
		end
	end

	self:RefreshAlpha();
end

function MapCanvasDetailLayerMixin:OnUpdate()
	if self.isWaitingForLoad and self.textureLoadGroup:IsFullyLoaded() then
		self.isWaitingForLoad = nil;
		self:RefreshAlpha();
		self.textureLoadGroup:Reset();
	end
end

function MapCanvasDetailLayerMixin:RefreshAlpha()
	if self:IsFullyLoaded() then
		self:SetAlpha(self:GetLayerAlpha() * self:GetGlobalAlpha());
	else
		self:SetAlpha(0.0);
	end
end