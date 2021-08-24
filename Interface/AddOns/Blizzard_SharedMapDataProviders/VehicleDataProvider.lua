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
	local numVehicles = GetNumBattlefieldVehicles();
	for i = 1, numVehicles do
		local vehicleX, vehicleY, unitName, isOccupied, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(i, mapID);
		if vehicleX and isAlive and not isPlayer and VehicleUtil.IsValidVehicleType(vehicleType) then
			self:GetMap():AcquirePin("VehiclePinTemplate", i);
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
	local vehicleX, vehicleY, unitName, isOccupied, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(self.vehicleIndex, self:GetMap():GetMapID());
	local vehicleInfo = VehicleUtil.GetVehicleInfo(vehicleType);
	self.Texture:SetRotation(orientation);
	self.Texture:SetTexture(VehicleUtil.GetVehicleTexture(vehicleType, isOccupied));
	self:SetWidth(vehicleInfo:GetWidth());
	self:SetHeight(vehicleInfo:GetHeight());
	self.name = unitName;
	if vehicleInfo:ShouldDrawBelowPlayerBlips() then
		self:UseFrameLevelType("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	else
		self:UseFrameLevelType("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	end
	
	self:SetPosition(vehicleX, vehicleY);
end

function VehiclePinMixin:OnUpdate()
	local vehicleX, vehicleY, unitName, isOccupied, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(self.vehicleIndex, self:GetMap():GetMapID());
	if vehicleX and isAlive and not isPlayer then
		self:SetPosition(vehicleX, vehicleY);
		self.Texture:SetRotation(orientation);
	else
		self:Hide();
	end
end

function VehiclePinMixin:OnMouseEnter(motion)
	local tooltipText = "";
	for pin in self:GetMap():EnumeratePinsByTemplate("VehiclePinTemplate") do
		if pin:IsVisible() and pin:IsMouseOver() then
			local vehicleX, vehicleY, unitName, isOccupied, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(pin:GetVehicleIndex(), self:GetMap():GetMapID());
			if unitName then
				if tooltipText == "" then
					tooltipText = unitName;
				else
					tooltipText = tooltipText.."|n"..unitName;
				end
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