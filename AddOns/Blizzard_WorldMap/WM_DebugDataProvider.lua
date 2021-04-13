if not IsGMClient() then
	return;
end

WorldMap_DebugDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local function IsTeleportModifierKeyDown()
	return IsAltKeyDown();
end

function WorldMap_DebugDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	local priority = 100;
	self.onCanvasClickHandler = self.onCanvasClickHandler or function(mapCanvas, button, cursorX, cursorY) return self:OnCanvasClickHandler(button, cursorX, cursorY) end;
	mapCanvas:AddCanvasClickHandler(self.onCanvasClickHandler, priority);
	self.onPinMouseActionHandler = self.onPinMouseActionHandler or function(mapCanvas, mouseAction, button) return self:OnPinMouseActionHandler(mouseAction, button) end;
	mapCanvas:AddGlobalPinMouseActionHandler(self.onPinMouseActionHandler, priority);
	self.cursorHandler = self.cursorHandler or
		function()
			if IsTeleportModifierKeyDown() then
				return "TAXI_CURSOR";
			end
		end
	;
	mapCanvas:AddCursorHandler(self.cursorHandler, priority);
end

function WorldMap_DebugDataProviderMixin:OnCanvasClickHandler(button, cursorX, cursorY)
	if IsTeleportModifierKeyDown() and button == "LeftButton" then
		self:Teleport();
		return true;
	end
	return false;
end

function WorldMap_DebugDataProviderMixin:OnPinMouseActionHandler(mouseAction, button)
	if button ~= "LeftButton" or mouseAction == MapCanvasMixin.MouseAction.Up or not IsTeleportModifierKeyDown() then
		return false;
	end

	if mouseAction == MapCanvasMixin.MouseAction.Click then
		self:Teleport();
	end
	-- do nothing on MapCanvasMixin.MouseAction.Down
	return true;
end

function WorldMap_DebugDataProviderMixin:Teleport()
	local pinFrameLevel = 0;
	local pinIndex;
	for pin in self:GetMap():EnumeratePinsByTemplate("WorldMap_DebugObjectPinTemplate") do
		if pin:IsMouseOver() then
			-- there might be overlapping pins, find topmost
			local frameLevel = pin:GetFrameLevel();
			if frameLevel > pinFrameLevel then
				pinFrameLevel = frameLevel;
				pinIndex = pin:GetDebugObjectIndex();
			end
		end
	end
	if pinIndex then
		C_Debug.TeleportToMapDebugObject(pinIndex);
	else
		local scrollContainer = self:GetMap().ScrollContainer;
		local cursorX, cursorY = scrollContainer:NormalizeUIPosition(scrollContainer:GetCursorPosition());
		C_Debug.TeleportToMapLocation(self:GetMap():GetMapID(), cursorX, cursorY);
	end
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

WorldMap_DebugObjectPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldMap_DebugObjectPinMixin:OnAcquired(debugObjectInfo)
	self.index = debugObjectInfo.index;
	self.name = debugObjectInfo.name;
	local info = DEBUG_ICON_INFO[debugObjectInfo.size];
	self:SetWidth(info.size);
	self:SetHeight(info.size);
	self.Texture:SetVertexColor(info.r, info.g, info.b, 0.5);
end

function WorldMap_DebugObjectPinMixin:GetDebugObjectIndex()
	return self.index;
end

function WorldMap_DebugObjectPinMixin:GetName()
	return self.name;
end

function WorldMap_DebugObjectPinMixin:OnMouseEnter(motion)
	local tooltipText = {};
	for pin in self:GetMap():EnumeratePinsByTemplate("WorldMap_DebugObjectPinTemplate") do
		if pin:IsMouseOver() then
			table.insert(tooltipText, pin:GetName());
		end
	end
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(table.concat(tooltipText, "|n"));
	GameTooltip:Show();
end

function WorldMap_DebugObjectPinMixin:OnMouseLeave(motion)
	GameTooltip:Hide();
end

WorldMap_DebugPortLocPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DEBUG");