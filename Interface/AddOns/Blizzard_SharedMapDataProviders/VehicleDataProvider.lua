VehicleDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function VehicleDataProviderMixin:OnShow()
	self:RegisterEvent("PVP_VEHICLE_INFO_UPDATED");
end

function VehicleDataProviderMixin:OnHide()
	self:UnregisterEvent("PVP_VEHICLE_INFO_UPDATED");
end

function VehicleDataProviderMixin:OnEvent(event, ...)
	if event == "PVP_VEHICLE_INFO_UPDATED" then
		self:RefreshAllData();
	end
end

function VehicleDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("VehiclePinTemplate");
end

function VehicleDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	local mapID = self:GetMap():GetMapID();
	-- no vehicles above zone maps
	local mapInfo = C_Map.GetMapInfo(mapID);
	if not mapInfo or mapInfo.mapType < Enum.UIMapType.Zone then
		return;
	end

	local vehicleInfos = C_PvP.GetBattlefieldVehicles(mapID);
	if vehicleInfos then
		for i, vehicleInfo in ipairs(vehicleInfos) do
			if vehicleInfo.x and vehicleInfo.isAlive and not vehicleInfo.isPlayer and vehicleInfo.atlas then
				self:GetMap():AcquirePin("VehiclePinTemplate", i);
			end
		end
	end
end

--[[ Pin ]]--
VehiclePinMixin = CreateFromMixins(MapCanvasPinMixin);

function VehiclePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.825, 0.85);
end

function VehiclePinMixin:GetVehicleIndex()
	return self.vehicleIndex;
end

function VehiclePinMixin:OnAcquired(vehicleIndex)
	self.vehicleIndex = vehicleIndex;
	self:Refresh();
end

function VehiclePinMixin:Refresh()
	local vehicleInfo = C_PvP.GetBattlefieldVehicleInfo(self.vehicleIndex, self:GetMap():GetMapID());
	self.Texture:SetRotation(vehicleInfo.facing);
	self.Texture:SetAtlas(vehicleInfo.atlas);
	self:SetWidth(vehicleInfo.textureWidth);
	self:SetHeight(vehicleInfo.textureHeight);
	self.name = vehicleInfo.name;
	if vehicleInfo.shouldDrawBelowPlayerBlips then
		self:UseFrameLevelType("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	else
		self:UseFrameLevelType("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	end
	self:SetPosition(vehicleInfo.x, vehicleInfo.y);
end

function VehiclePinMixin:OnUpdate()
	local vehicleInfo = C_PvP.GetBattlefieldVehicleInfo(self.vehicleIndex, self:GetMap():GetMapID());
	if vehicleInfo and vehicleInfo.x and vehicleInfo.isAlive and not vehicleInfo.isPlayer then
		self:SetPosition(vehicleInfo.x, vehicleInfo.y);
		self.Texture:SetRotation(vehicleInfo.facing);
	else
		self:Hide();
	end
end

function VehiclePinMixin:OnMouseEnter(motion)
	local tooltipText = "";
	for pin in self:GetMap():EnumeratePinsByTemplate("VehiclePinTemplate") do
		if pin:IsVisible() and pin:IsMouseOver() and pin.name then
			if tooltipText == "" then
				tooltipText = pin.name;
			else
				tooltipText = tooltipText.."|n"..pin.name;
			end
		end
	end
	
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end

function VehiclePinMixin:OnMouseLeave(motion)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end