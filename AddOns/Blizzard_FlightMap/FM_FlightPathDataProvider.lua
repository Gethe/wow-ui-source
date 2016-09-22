FlightMap_FlightPathDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

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

	local taxiNodes = GetAllTaxiNodes();
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
	end
end

function FlightMap_FlightPathDataProviderMixin:ShowBackgroundRoutesFromCurrent()
	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	for slotIndex, pin in pairs(self.slotIndexToPin) do
		if pin.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
			for routeIndex = 1, 1 do
				local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
				local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);
				local startPin = self.slotIndexToPin[sourceSlotIndex];
				local destinationPin = self.slotIndexToPin[destinationSlotIndex];

				if not startPin or not destinationPin then
					return; -- Incorrect flight data, will look broken until the data is adjusted
				end

				if not startPin.linkedPins[destinationPin] and not destinationPin.linkedPins[startPin] then
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

function FlightMap_FlightPathDataProviderMixin:RemoveRoute()
	if not self.highlightLinePool then
		return;
	end
	self.highlightLinePool:ReleaseAll();
end

function FlightMap_FlightPathDataProviderMixin:AddFlightNode(taxiNodeData)
	local pin = self:GetMap():AcquirePin("FlightMap_FlightPointPinTemplate");
	self.slotIndexToPin[taxiNodeData.slotIndex] = pin;

	pin:SetPosition(taxiNodeData.x, taxiNodeData.y);
	pin.taxiNodeData = taxiNodeData;
	pin.owner = self;
	pin.linkedPins = {};

	if taxiNodeData.type == LE_FLIGHT_PATH_TYPE_CURRENT then
		pin.Icon:SetAtlas("Taxi_Frame_Green");
		pin.IconHighlight:SetAtlas("Taxi_Frame_Gray");
		pin:SetSize(28, 28);
		pin:Show();
	elseif taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
		pin.Icon:SetAtlas("Taxi_Frame_Gray");
		pin.IconHighlight:SetAtlas("Taxi_Frame_Gray");
		pin:SetSize(20, 20);
		pin:Show();
	elseif taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
		pin.Icon:SetAtlas("UI-Taxi-Icon-Nub");
		pin.IconHighlight:SetAtlas("UI-Taxi-Icon-Nub");
		pin:SetSize(14, 14);
		pin:Hide(); -- Only show if part of a route, handled in the route building functions
	end
end

function FlightMap_FlightPathDataProviderMixin:CalculateLineThickness()
	self.lineThickness = Lerp(1, 1.5, Saturate(1.25 * self:GetMap():GetCanvasZoomPercent())) * 25;
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
	self:SetScalingLimits(1.25, 3.5, 1.5);

	-- Flight points nudge other pins away.
	self:SetNudgeSourceFactor(1);
end

function FlightMap_FlightPointPinMixin:OnAcquired()
	self.OnAddAnim:Play();
end

function FlightMap_FlightPointPinMixin:OnClick(button)
	if button == "LeftButton" then
		TakeTaxiNode(self.taxiNodeData.slotIndex);
	end
end

function FlightMap_FlightPointPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 20, 0);

	GameTooltip:AddLine(self.taxiNodeData.name, nil, nil, nil, true);

	if self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_CURRENT then
		GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true);
	elseif self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
		local cost = TaxiNodeCost(self.taxiNodeData.slotIndex);
		if cost > 0 then
			SetTooltipMoney(GameTooltip, cost);
		end

		self.Icon:SetAtlas("Taxi_Frame_Yellow");
		self.owner:RemoveRoute();
		self.owner:HighlightRouteToPin(self);
	elseif self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
		GameTooltip:AddLine(TAXI_PATH_UNREACHABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function FlightMap_FlightPointPinMixin:OnMouseLeave()
	if self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
		self.Icon:SetAtlas("Taxi_Frame_Gray");
	end
	GameTooltip_Hide();
end