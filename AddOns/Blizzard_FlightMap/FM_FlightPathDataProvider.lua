FlightMap_FlightPathDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local function IsVindicaarTextureKit(textureKitPrefix)
	-- TODO: remove
	return textureKitPrefix == "FlightMaster_VindicaarArgus" or textureKitPrefix == "FlightMaster_VindicaarStygianWake" or textureKitPrefix == "FlightMaster_VindicaarMacAree";
end

function FlightMap_FlightPathDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("FlightMap_FlightPointPinTemplate");
	if self.highlightLinePool then
		self.highlightLinePool:ReleaseAll();
	end
	if self.backgroundLinePool then
		self.backgroundLinePool:ReleaseAll();
	end
end

function FlightMap_FlightPathDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	self.slotIndexToPin = {};

	self:CalculateLineThickness();

	local taxiNodes = C_TaxiMap.GetAllTaxiNodes();
	for i, taxiNodeData in ipairs(taxiNodes) do
		self:AddFlightNode(taxiNodeData);
	end

	self:ShowBackgroundRoutesFromCurrent();
end

local function OnRelease(framePool, frame)
	frame.RevealAnim:Stop();
	if frame.FadeAnim then
		frame.FadeAnim:Stop();
	end
	frame:Hide();
end

function FlightMap_FlightPathDataProviderMixin:HighlightRouteToPin(pin)
	self:ClearBackgroundRoutes();

	if not self.highlightLinePool then
		self.highlightLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	local slotIndex = pin.taxiNodeData.slotIndex;
	for routeIndex = 1, GetNumRoutes(slotIndex) do
		local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
		local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);

		local startPin = self.slotIndexToPin[sourceSlotIndex];
		local destinationPin = self.slotIndexToPin[destinationSlotIndex];

		local lineContainer = self.highlightLinePool:Acquire();
		lineContainer.Fill:SetThickness(self.lineThickness);

		lineContainer.Fill:SetStartPoint("CENTER", startPin);
		lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

		lineContainer:Show();

		startPin:Show();
		destinationPin:Show();
	end
end

function FlightMap_FlightPathDataProviderMixin:RemoveRouteToPin(pin)
	if self.highlightLinePool then
		self.highlightLinePool:ReleaseAll();
	end

	local slotIndex = pin.taxiNodeData.slotIndex;
	for routeIndex = 1, GetNumRoutes(slotIndex) do
		local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
		local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);

		local startPin = self.slotIndexToPin[sourceSlotIndex];
		local destinationPin = self.slotIndexToPin[destinationSlotIndex];

		startPin:SetShown(startPin:GetTaxiNodeState() ~= Enum.FlightPathState.Unreachable);
		destinationPin:SetShown(destinationPin:GetTaxiNodeState() ~= Enum.FlightPathState.Unreachable);
	end
end

function FlightMap_FlightPathDataProviderMixin:ShowBackgroundRoutesFromCurrent()
	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	for slotIndex, pin in pairs(self.slotIndexToPin) do
		if pin:GetTaxiNodeState() == Enum.FlightPathState.Reachable then
			for routeIndex = 1, 1 do
				local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
				local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);
				local startPin = self.slotIndexToPin[sourceSlotIndex];
				local destinationPin = self.slotIndexToPin[destinationSlotIndex];

				if not startPin or not destinationPin then
					return; -- Incorrect flight data, will look broken until the data is adjusted
				end
				
				if startPin:ShouldShowOutgoingFlightPathPreviews() and destinationPin:GetTaxiNodeState() == Enum.FlightPathState.Reachable and not startPin.linkedPins[destinationPin] and not destinationPin.linkedPins[startPin] then
					startPin.linkedPins[destinationPin] = true;
					destinationPin.linkedPins[startPin] = true;

					local lineContainer = self.backgroundLinePool:Acquire();
					lineContainer.Fill:SetThickness(self.lineThickness);

					lineContainer.Fill:SetStartPoint("CENTER", startPin);
					lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

					lineContainer:Show();

					startPin:Show();
					destinationPin:Show();
				end
			end
		end
	end
end

function FlightMap_FlightPathDataProviderMixin:ClearBackgroundRoutes()
	self.backgroundLinePool:ReleaseAll();
end

local function OnHighlightLineFadeFinish(anim)
	anim.releasePool:Release(anim:GetParent());
end

function FlightMap_FlightPathDataProviderMixin:AddFlightNode(taxiNodeData)
	local playAnim = taxiNodeData.state ~= Enum.FlightPathState.Unreachable;
	local pin = self:GetMap():AcquirePin("FlightMap_FlightPointPinTemplate", playAnim);
	self.slotIndexToPin[taxiNodeData.slotIndex] = pin;

	pin:SetPosition(taxiNodeData.position:GetXY());
	pin.taxiNodeData = taxiNodeData;
	pin.owner = self;
	pin.linkedPins = {};
	pin:SetFlightPathStyle(taxiNodeData.textureKitPrefix, taxiNodeData.state);
	
	pin:UpdatePinSize(taxiNodeData.state);
	pin:SetShown(taxiNodeData.state ~= Enum.FlightPathState.Unreachable); -- Only show if part of a route, handled in the route building functions
end

function FlightMap_FlightPathDataProviderMixin:CalculateLineThickness()
	self.lineThickness = Lerp(1, 2, Saturate(1 - self:GetMap():GetCanvasZoomPercent())) * 45;
end

function FlightMap_FlightPathDataProviderMixin:OnCanvasScaleChanged()
	self:CalculateLineThickness();

	if self.backgroundLinePool then
		for lineContainer in self.backgroundLinePool:EnumerateActive() do
			lineContainer.Fill:SetThickness(self.lineThickness);
		end
	end

	if self.highlightLinePool then
		for lineContainer in self.highlightLinePool:EnumerateActive() do
			lineContainer.Fill:SetThickness(self.lineThickness);
		end
	end
end

--[[ Flight Point Pin ]]--
FlightMap_FlightPointPinMixin = CreateFromMixins(MapCanvasPinMixin);

function FlightMap_FlightPointPinMixin:OnLoad()
	self:SetScalingLimits(1.25, 0.9625, 1.275);

	-- Flight points nudge other pins away.
	self:SetNudgeSourceRadius(1);

	self:UseFrameLevelType("PIN_FRAME_LEVEL_FLIGHT_POINT");
end

function FlightMap_FlightPointPinMixin:OnAcquired(playAnim)
	if playAnim then
		self.OnAddAnim:Play();
	else
		self:SetAlpha(1);
	end
end

function FlightMap_FlightPointPinMixin:OnClick(button)
	if button == "LeftButton" then
		TakeTaxiNode(self.taxiNodeData.slotIndex);
	end
end

function FlightMap_FlightPointPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);

	GameTooltip:AddLine(self.taxiNodeData.name, nil, nil, nil, true);

	if self.taxiNodeData.state == Enum.FlightPathState.Current then
		GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true);
	elseif self.taxiNodeData.state == Enum.FlightPathState.Reachable then
		local cost = TaxiNodeCost(self.taxiNodeData.slotIndex);
		if cost > 0 then
			SetTooltipMoney(GameTooltip, cost);
		end

		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Yellow"));
		
		self.owner:HighlightRouteToPin(self);
	elseif self.taxiNodeData.state == Enum.FlightPathState.Unreachable then
		GameTooltip:AddLine(TAXI_PATH_UNREACHABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function FlightMap_FlightPointPinMixin:OnMouseLeave()
	if self.taxiNodeData.state == Enum.FlightPathState.Reachable then
		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
		self.owner:RemoveRouteToPin(self);
	end
	GameTooltip_Hide();
end

function FlightMap_FlightPointPinMixin:GetTaxiNodeState()
	return self.taxiNodeData.state;
end

function FlightMap_FlightPointPinMixin:UpdatePinSize(pinType)
	if IsVindicaarTextureKit(self.textureKitPrefix) then
		self:SetSize(39, 42);
	elseif self.textureKitPrefix == "FlightMaster_Argus" then
		self:SetSize(34, 28);
	elseif self.textureKitPrefix == "FlightMaster_Ferry" then
		if pinType == Enum.FlightPathState.Current then
			self:SetSize(36, 24);
		elseif pinType == Enum.FlightPathState.Reachable or pinType == Enum.FlightPathState.Unreachable then
			self:SetSize(28, 19);
		end
	elseif pinType == Enum.FlightPathState.Current then
		self:SetSize(28, 28);
	elseif pinType == Enum.FlightPathState.Reachable then
		self:SetSize(20, 20);
	elseif pinType == Enum.FlightPathState.Unreachable then
		self:SetSize(14, 14);
	end
end

function FlightMap_FlightPointPinMixin:SetFlightPathStyle(textureKitPrefix, taxiNodeType)
	self.textureKitPrefix = textureKitPrefix;
	self:SetNudgeSourceMagnitude(nil, nil);
	self:SetNudgeSourceRadius(1);
	if textureKitPrefix then
		self.atlasFormat = textureKitPrefix.."-%s";
		
		if IsVindicaarTextureKit(self.textureKitPrefix) then
			self:SetNudgeSourceRadius(2);
			self:SetNudgeSourceMagnitude(1.5, 3.65);
		elseif self.textureKitPrefix == "FlightMaster_Argus" then
			self:SetNudgeSourceRadius(1.5);
			self:SetNudgeSourceMagnitude(1, 2);
		end
	else
		self.atlasFormat = "%s";
	end

	if taxiNodeType == Enum.FlightPathState.Current then
		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Green"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
	elseif taxiNodeType == Enum.FlightPathState.Reachable then
		self.Icon:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("Taxi_Frame_Gray"));
	elseif taxiNodeType == Enum.FlightPathState.Unreachable then
		self.Icon:SetAtlas(self.atlasFormat:format("UI-Taxi-Icon-Nub"));
		self.IconHighlight:SetAtlas(self.atlasFormat:format("UI-Taxi-Icon-Nub"));
	end
end

function FlightMap_FlightPointPinMixin:ShouldShowOutgoingFlightPathPreviews()
	local isArgus = IsVindicaarTextureKit(self.textureKitPrefix) or self.textureKitPrefix == "FlightMaster_Argus";
	return not isArgus;
end