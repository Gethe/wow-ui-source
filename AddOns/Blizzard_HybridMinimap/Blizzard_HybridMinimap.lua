HybridMinimapMixin = { };

function HybridMinimapMixin:OnLoad()
	self:SetFrameStrata("BACKGROUND");

	local mapCanvas = self.MapCanvas;
	mapCanvas:SetShouldZoomInOnClick(false);
	mapCanvas:SetShouldPanOnClick(false);
	mapCanvas:SetShouldNavigateOnClick(false);
	mapCanvas:SetShouldZoomInstantly(true);
	mapCanvas:SetMouseWheelZoomMode(MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE);

	mapCanvas:SetMaskTexture(self.CircleMask);
	mapCanvas:SetUseMaskTexture(true);

	mapCanvas:AddDataProvider(CreateFromMixins(MapExplorationDataProviderMixin));

	local pinFrameLevelsManager = mapCanvas:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
end

function HybridMinimapMixin:OnShow()
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:CheckMap();
	self.MapCanvas:Show();
	C_Minimap.SetDrawGroundTextures(false);
end

function HybridMinimapMixin:OnHide()
	self:UnregisterEvent("MINIMAP_UPDATE_ZOOM");
	self.MapCanvas:Hide();
	C_Minimap.SetDrawGroundTextures(true);
end

function HybridMinimapMixin:OnEvent(event)
	if event == "MINIMAP_UPDATE_ZOOM" then
		self:UpdateZoom();
	end
end

function HybridMinimapMixin:OnUpdate(elapsed)
	self:CheckMap();
	self:UpdatePosition();
end

function HybridMinimapMixin:CheckMap()
	local mapID = MapUtil.GetDisplayableMapForPlayer();
	if mapID ~= self.mapID then
		self:SetMapID(mapID);
	end
end

function HybridMinimapMixin:SetMapID(mapID)
	self.mapID = mapID;
	local layers = C_Map.GetMapArtLayers(self.mapID);
	self.contentWidth = layers[1].layerWidth;
	self.contentHeight = layers[1].layerHeight;
	self.MapCanvas:SetMapID(mapID);
	self:UpdateZoom();
end

function HybridMinimapMixin:GetMapID()
	return self.mapID;
end

function HybridMinimapMixin:UpdateZoom()
	local yardsWidth, yardsHeight = C_Map.GetMapWorldSize(self.mapID);
	-- using widths for calculations, could also use heights instead
	local pixelsPerYard = self.contentWidth / yardsWidth;
	local minimapViewPixels = C_Minimap.GetViewRadius() * 2 * pixelsPerYard;	-- x2 for diameter
	local scale = Minimap:GetWidth() / minimapViewPixels;
	self:SetZoom(scale);
end

function HybridMinimapMixin:SetZoom(zoom)
	self.MapCanvas:SetSize(self.contentWidth * zoom, self.contentHeight * zoom);
	self.MapCanvas.ScrollContainer:InstantPanAndZoom(zoom, 0.5, 0.5);
	self:UpdatePosition();
end

function HybridMinimapMixin:UpdatePosition()
	local pos = C_Map.GetPlayerMapPosition(self.mapID, "player");
	if not pos then
		return;
	end

	local scale = self.MapCanvas.ScrollContainer:GetCanvasScale();
	local deltaX = (0.5 - pos.x) * self.contentWidth;
	local deltaY = (pos.y - 0.5) * self.contentHeight;
	self.MapCanvas:SetPoint("CENTER", deltaX * scale, deltaY * scale);
end