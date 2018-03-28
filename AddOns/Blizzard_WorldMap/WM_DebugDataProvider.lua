WorldMap_DebugDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local DEBUG_ICON_INFO = {
	[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 },
	[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 },
	[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 },
	[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 },
};

function WorldMap_DebugDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WorldMap_DebugObjectPinTemplate");
end

function WorldMap_DebugDataProviderMixin:RefreshAllData(fromOnShow)
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	for index = 1, GetNumMapDebugObjects() do
		local name, size, x, y = GetMapDebugObjectInfo(index);
		if ( x ~= 0 or y ~= 0 ) then
			local pin = self:GetMap():AcquirePin("WorldMap_DebugObjectPinTemplate", index);
			pin:SetPosition(x, y);
			pin:UseFrameLevelType("PIN_FRAME_LEVEL_DEBUG", 4 - size);
			pin:Show();
		end
	end
end

function WorldMap_DebugDataProviderMixin:OnMapChanged()
	self:RefreshAllData();
end

WorldMap_DebugObjectPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WorldMap_DebugObjectPinMixin:OnAcquired(index)
	local name, size, x, y = GetMapDebugObjectInfo(index);

	self.index = index;
	local info = DEBUG_ICON_INFO[size];
	if ( mapID == WORLDMAP_AZEROTH_ID ) then
		self:SetWidth(info.size / 2);
		self:SetHeight(info.size / 2);
	else
		self:SetWidth(info.size);
		self:SetHeight(info.size);
	end
	self.Texture:SetVertexColor(info.r, info.g, info.b, 0.5);
end

function WorldMap_DebugObjectPinMixin:GetDebugObjectIndex()
	return self.index;
end

function WorldMap_DebugObjectPinMixin:OnMouseEnter(motion)
	WorldMap_HijackTooltip(self:GetMap());

	local tooltipText = "";
	for pin in self:GetMap():EnumeratePinsByTemplate("WorldMap_DebugObjectPinTemplate") do
		if (pin:IsVisible() and pin:IsMouseOver()) then
			local name, size, x, y = GetMapDebugObjectInfo(pin:GetDebugObjectIndex());
			if (name) then
				if (toolipText == "") then
					tooltipText = name;
				else
					tooltipText = tooltipText.."|n"..name;
				end
			end
		end
	end
	WorldMapTooltip:SetOwner(self);
	WorldMapTooltip:SetText(tooltipText);
	WorldMapTooltip:Show();
end

function WorldMap_DebugObjectPinMixin:OnMouseLeave(motion)
	WorldMapTooltip:Hide();

	WorldMap_RestoreTooltip();
end

function WorldMap_DebugObjectPinMixin:OnClick()
	if ( IsModifierKeyDown("CTRL") ) then
		TeleportToDebugObject(self.index);
	end
end