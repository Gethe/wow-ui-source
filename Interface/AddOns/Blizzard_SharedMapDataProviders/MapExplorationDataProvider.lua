MapExplorationDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapExplorationDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("MapExplorationPinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;
end

function MapExplorationDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("MapExplorationPinTemplate");
end

function MapExplorationDataProviderMixin:OnShow()
	self:RegisterEvent("MAP_EXPLORATION_UPDATED");
end

function MapExplorationDataProviderMixin:OnHide()
	self:UnregisterEvent("MAP_EXPLORATION_UPDATED");
end

function MapExplorationDataProviderMixin:OnEvent(event, ...)
	if event == "MAP_EXPLORATION_UPDATED" then
		self:RefreshAllData();
	end
end

function MapExplorationDataProviderMixin:OnMapChanged()
	local fullUpdate = true;
	self.pin:RefreshOverlays(fullUpdate);
end

function MapExplorationDataProviderMixin:RemoveAllData()
	self.pin:RemoveAllData();
end

function MapExplorationDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:RefreshOverlays(fromOnShow);
end

function MapExplorationDataProviderMixin:OnGlobalAlphaChanged()
	if not self.isWaitingForLoad then
		self.pin:RefreshAlpha();
	end
end

--[[ THE Pin ]]--
MapExplorationPinMixin = CreateFromMixins(MapCanvasPinMixin);

function MapExplorationPinMixin:OnLoad()
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_EXPLORATION");
	self.overlayTexturePool = CreateTexturePool(self, "ARTWORK", 0);
	self.highlightRectPool = CreateTexturePool(self, "ARTWORK", 0);		-- could be frames, but textures are lighter
	self.textureLoadGroup = CreateFromMixins(TextureLoadingGroupMixin);
end

function MapExplorationPinMixin:RemoveAllData()
	self.overlayTexturePool:ReleaseAll();
	self.highlightRectPool:ReleaseAll();
	self.textureLoadGroup:Reset();
	self.isWaitingForLoad = nil;
end

function MapExplorationPinMixin:RefreshAlpha()
	self:SetAlpha(self:GetMap():GetGlobalAlpha());
end

function MapExplorationPinMixin:OnUpdate(elapsed)
	if self.isWaitingForLoad and self:GetMap():AreDetailLayersLoaded() and self.textureLoadGroup:IsFullyLoaded() then
		self:RefreshAlpha();
		self.isWaitingForLoad = nil;
		self.textureLoadGroup:Reset();
	end

	if self:IsMouseOver() then
		self:RefreshMouseOverOverlays();
	end
end

function MapExplorationPinMixin:RefreshOverlays(fullUpdate)
	self:RemoveAllData();
	if fullUpdate then
		self.isWaitingForLoad = true;
		self:SetAlpha(0);
	end

	local mapID = self:GetMap():GetMapID();
	local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID);
	if exploredMapTextures then
		self.layerIndex = self:GetMap():GetCanvasContainer():GetCurrentLayerIndex();
		local layers = C_Map.GetMapArtLayers(mapID);
		local layerInfo = layers[self.layerIndex];
		local TILE_SIZE_WIDTH = layerInfo.tileWidth;
		local TILE_SIZE_HEIGHT = layerInfo.tileHeight;

		for i, exploredTextureInfo in ipairs(exploredMapTextures) do
			local numTexturesWide = ceil(exploredTextureInfo.textureWidth/TILE_SIZE_WIDTH);
			local numTexturesTall = ceil(exploredTextureInfo.textureHeight/TILE_SIZE_HEIGHT);
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
			for j = 1, numTexturesTall do
				if ( j < numTexturesTall ) then
					texturePixelHeight = TILE_SIZE_HEIGHT;
					textureFileHeight = TILE_SIZE_HEIGHT;
				else
					texturePixelHeight = mod(exploredTextureInfo.textureHeight, TILE_SIZE_HEIGHT);
					if ( texturePixelHeight == 0 ) then
						texturePixelHeight = TILE_SIZE_HEIGHT;
					end
					textureFileHeight = 16;
					while(textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2;
					end
				end
				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire();
					if ( k < numTexturesWide ) then
						texturePixelWidth = TILE_SIZE_WIDTH;
						textureFileWidth = TILE_SIZE_WIDTH;
					else
						texturePixelWidth = mod(exploredTextureInfo.textureWidth, TILE_SIZE_WIDTH);
						if ( texturePixelWidth == 0 ) then
							texturePixelWidth = TILE_SIZE_WIDTH;
						end
						textureFileWidth = 16;
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2;
						end
					end
					texture:SetWidth(texturePixelWidth);
					texture:SetHeight(texturePixelHeight);
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight);
					texture:SetPoint("TOPLEFT", exploredTextureInfo.offsetX + (TILE_SIZE_WIDTH * (k-1)), -(exploredTextureInfo.offsetY + (TILE_SIZE_HEIGHT * (j - 1))));
					texture:SetTexture(exploredTextureInfo.fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR");

					if exploredTextureInfo.isShownByMouseOver then
						-- keep track of the textures to show by mouseover
						texture:SetDrawLayer("ARTWORK", 1);
						texture:Hide();
						local highlightRect = self.highlightRectPool:Acquire();
						highlightRect:SetSize(exploredTextureInfo.hitRect.right - exploredTextureInfo.hitRect.left, exploredTextureInfo.hitRect.bottom - exploredTextureInfo.hitRect.top);
						highlightRect:SetPoint("TOPLEFT", exploredTextureInfo.hitRect.left, -exploredTextureInfo.hitRect.top);
						highlightRect.index = i;
						highlightRect.texture = texture;
					else
						texture:SetDrawLayer("ARTWORK", 0);
						texture:Show();

						if fullUpdate then
							self.textureLoadGroup:AddTexture(texture);
						end
					end
				end
			end
		end
	end
end

function MapExplorationPinMixin:OnCanvasScaleChanged()
	if self.layerIndex ~= self:GetMap():GetCanvasContainer():GetCurrentLayerIndex() then
		self:RefreshOverlays();
	end
end

function MapExplorationPinMixin:RefreshMouseOverOverlays()
	local highlightIndex = nil;
	-- first find if any have the mouse over
	for highlightRect in self.highlightRectPool:EnumerateActive() do
		if highlightRect:IsMouseOver() then
			highlightIndex = highlightRect.index;
			break;
		end
	end
	-- now show all who match the same index
	for highlightRect in self.highlightRectPool:EnumerateActive() do
		highlightRect.texture:SetShown(highlightRect.index == highlightIndex);
	end
end

function MapExplorationPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end