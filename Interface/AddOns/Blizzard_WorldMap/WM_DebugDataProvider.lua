if not IsGMClient() then
	return;
end

WorldMap_DebugDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WorldMap_DebugDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self.onClickHandler = self.onClickHandler or function(mapCanvas, button, cursorX, cursorY) return self:OnCanvasClicked(button, cursorX, cursorY) end;
	mapCanvas:AddCanvasClickHandler(self.onClickHandler);
end

function WorldMap_DebugDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	mapCanvas:RemoveCanvasClickHandler(self.onClickHandler);
end

local DEBUG_ICON_INFO = {
	[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 },
	[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 },
	[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 },
	[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 },
};

function WorldMap_DebugDataProviderMixin:OnShow()
	self:RegisterEvent("DEBUG_MAP_OBJECTS_UPDATED");
	self:RegisterEvent("DEBUG_PORT_LOCS_UPDATED");
end

function WorldMap_DebugDataProviderMixin:OnHide()
	self:UnregisterEvent("DEBUG_MAP_OBJECTS_UPDATED");
	self:UnregisterEvent("DEBUG_PORT_LOCS_UPDATED");
end

function WorldMap_DebugDataProviderMixin:OnEvent(event, ...)
	if event == "DEBUG_MAP_OBJECTS_UPDATED" then
		self:RefreshAllData();
	elseif event == "DEBUG_PORT_LOCS_UPDATED" then
		self:RefreshAllData();
	end
end

function WorldMap_DebugDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WorldMap_DebugObjectPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("WorldMap_DebugPortLocPinTemplate");
end

function WorldMap_DebugDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();

	self:RefreshDebugObjects(mapID);
	self:RefreshPortLocs(mapID);
end

function WorldMap_DebugDataProviderMixin:RefreshDebugObjects(mapID)
	local debugObjects = C_Debug.GetMapDebugObjects(mapID);
	if debugObjects then
		for i, debugObjectInfo in ipairs(debugObjects) do
			local pin = self:GetMap():AcquirePin("WorldMap_DebugObjectPinTemplate", debugObjectInfo);
			pin:SetPosition(debugObjectInfo.position:GetXY());
			pin:UseFrameLevelType("PIN_FRAME_LEVEL_DEBUG", (#DEBUG_ICON_INFO - debugObjectInfo.size) + 1);
			pin:Show();
		end
	end
end

function WorldMap_DebugDataProviderMixin:RefreshPortLocs(mapID)
	local portLocs = C_Debug.GetAllPortLocsForMap(mapID);
	if portLocs then
		for i, portLocInfo in ipairs(portLocs) do
			self:GetMap():AcquirePin("WorldMap_DebugPortLocPinTemplate", portLocInfo);
		end
	end
end

function WorldMap_DebugDataProviderMixin:OnCanvasClicked(button, cursorX, cursorY)
	if IsAltKeyDown() and button == "LeftButton" then
		return C_Debug.TeleportToMapLocation(self:GetMap():GetMapID(), cursorX, cursorY);
	end
	return false;
end

WorldMap_DebugObjectPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldMap_DebugObjectPinMixin:OnAcquired(debugObjectInfo)
	self.index = debugObjectInfo.index;
	local info = DEBUG_ICON_INFO[debugObjectInfo.size];
	self:SetWidth(info.size);
	self:SetHeight(info.size);
	self.Texture:SetVertexColor(info.r, info.g, info.b, 0.5);
end

function WorldMap_DebugObjectPinMixin:GetDebugObjectIndex()
	return self.index;
end

function WorldMap_DebugObjectPinMixin:OnMouseEnter(motion)
	local tooltipText = {};
	for pin in self:GetMap():EnumeratePinsByTemplate("WorldMap_DebugObjectPinTemplate") do
		if pin:IsMouseOver() then
			local debugObjectInfo = C_Debug.GetMapDebugObjectInfo(pin:GetDebugObjectIndex());
			if debugObjectInfo then
				table.insert(tooltipText, debugObjectInfo.name);
			end
		end
	end
	WorldMapTooltip:SetOwner(self);
	WorldMapTooltip:SetText(table.concat(tooltipText, "|n"));
	WorldMapTooltip:Show();
end

function WorldMap_DebugObjectPinMixin:OnMouseLeave(motion)
	WorldMapTooltip:Hide();
end

function WorldMap_DebugObjectPinMixin:OnClick()
	if IsModifierKeyDown("ALT") then
		C_Debug.TeleportToMapDebugObject(self.index);
	end
end

WorldMap_DebugPortLocPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DEBUG");