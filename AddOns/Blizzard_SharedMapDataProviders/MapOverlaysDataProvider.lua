MapOverlaysDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapOverlaysDataProviderMixin:OnMapChanged()
	self:RefreshAllData();
end

function MapOverlaysDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:RefreshOverlays();
end

function MapOverlaysDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("MapOverlaysPinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;
end

function MapOverlaysDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("MapOverlaysPinTemplate");
end

--[[ THE Pin ]]--
MapOverlaysPinMixin = CreateFromMixins(MapCanvasPinMixin);

function MapOverlaysPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_OVERLAY");
	self.overlayTexturePool = CreateTexturePool(self, "ARTWORK", 0);
end

function MapOverlaysPinMixin:OnUpdate(elapsed)
	if self:IsMouseOver() then
		self:RefreshMouseOverOverlays();
	end
end

function MapOverlaysPinMixin:RefreshOverlays()
	self.overlayTexturePool:ReleaseAll();
	self.mouseOverHighlights = { };

	local TILE_SIZE = 256;

	for i = 1, GetNumMapOverlays() do
		local textureWidth, textureHeight, offsetX, offsetY, isShownByMouseOver, textureInfo  = GetMapOverlayInfo(i);
		if ( textureInfo ) then
			local numTexturesWide = ceil(textureWidth/TILE_SIZE);
			local numTexturesTall = ceil(textureHeight/TILE_SIZE);
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
			for j = 1, numTexturesTall do
				if ( j < numTexturesTall ) then
					texturePixelHeight = TILE_SIZE;
					textureFileHeight = TILE_SIZE;
				else
					texturePixelHeight = mod(textureHeight, TILE_SIZE);
					if ( texturePixelHeight == 0 ) then
						texturePixelHeight = TILE_SIZE;
					end
					textureFileHeight = 16;
					while(textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2;
					end
				end
				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire();
					if ( k < numTexturesWide ) then
						texturePixelWidth = TILE_SIZE;
						textureFileWidth = TILE_SIZE;
					else
						texturePixelWidth = mod(textureWidth, TILE_SIZE);
						if ( texturePixelWidth == 0 ) then
							texturePixelWidth = TILE_SIZE;
						end
						textureFileWidth = 16;
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2;
						end
					end
					texture:SetWidth(texturePixelWidth);
					texture:SetHeight(texturePixelHeight);
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight);
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE * (k-1)), -(offsetY + (TILE_SIZE * (j - 1))));
					texture:SetTexture(textureInfo[((j - 1) * numTexturesWide) + k]);

					if isShownByMouseOver == true then
						-- keep track of the textures to show by mouseover
						texture:SetDrawLayer("ARTWORK", 1);
						texture:Hide();
						if not self.mouseOverHighlights[i] then
							self.mouseOverHighlights[i] = { };
						end
						table.insert(self.mouseOverHighlights[i], texture);
					else
						texture:SetDrawLayer("ARTWORK", 0);
						texture:Show();
					end
				end
			end
		end
	end

	if #self.mouseOverHighlights > 0 then
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function MapOverlaysPinMixin:RefreshMouseOverOverlays()
	local normalizedCursorX, normalizedCursorY = self:GetMap():GetNormalizedCursorPosition();
	for index, textures in pairs(self.mouseOverHighlights) do
		local isHighlighted = IsMapOverlayHighlighted(index, normalizedCursorX, normalizedCursorY);
		for _, texture in pairs(textures) do
			texture:SetShown(isHighlighted);
		end
	end
end

function MapOverlaysPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end