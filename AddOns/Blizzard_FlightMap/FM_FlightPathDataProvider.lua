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
	frame.Fill:SetAlpha(0);
	frame:Hide();
end

function FlightMap_FlightPathDataProviderMixin:HighlightRouteToPin(pin)
	if not self.highlightLinePool then
		self.highlightLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_HighlightFlightLineTemplate", OnRelease);
	end

	local slotIndex = pin.taxiNodeData.slotIndex;
	for routeIndex = 1, GetNumRoutes(slotIndex) do
		local sourceSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, true);
		local destinationSlotIndex = TaxiGetNodeSlot(slotIndex, routeIndex, false);

		local startPin = self.slotIndexToPin[sourceSlotIndex];
		local destinationPin = self.slotIndexToPin[destinationSlotIndex];

		local lineContainer = self.highlightLinePool:Acquire();

		lineContainer.Fill:SetStartPoint("CENTER", startPin);
		lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

		local startDelay = (routeIndex - 1) * lineContainer.RevealAnim.Alpha:GetDuration();
		lineContainer.RevealAnim.Alpha:SetStartDelay(startDelay);
		lineContainer.RevealAnim.Scale:SetStartDelay(startDelay);
		lineContainer.RevealAnim:Play();

		lineContainer:Show();
	end
end

function FlightMap_FlightPathDataProviderMixin:ShowBackgroundRoutesFromCurrent()
	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "FlightMap_BackgroundFlightLineTemplate", OnRelease);
	end

	for slotIndex, pin in pairs(self.slotIndexToPin) do
		if pin.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
			for routeIndex = 1, GetNumRoutes(slotIndex) do
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

					lineContainer.Fill:SetStartPoint("CENTER", startPin);
					lineContainer.Fill:SetEndPoint("CENTER", destinationPin);

					local startDelay = (routeIndex - 1) * lineContainer.RevealAnim.Alpha:GetDuration() + .35;
					lineContainer.RevealAnim.Alpha:SetStartDelay(startDelay);
					lineContainer.RevealAnim.Scale:SetStartDelay(startDelay);
					lineContainer.RevealAnim:Play();

					lineContainer:Show();

					startPin:Show();
					destinationPin:Show();
				end
			end
		end
	end
end

local function OnHighlightLineFadeFinish(anim)
	anim.releasePool:Release(anim:GetParent());
end

function FlightMap_FlightPathDataProviderMixin:RemoveRoute()
	for lineContainer in self.highlightLinePool:EnumerateActive() do
		lineContainer.RevealAnim:Stop();
		if not lineContainer.FadeAnim:IsPlaying() then
			lineContainer.FadeAnim.Alpha:SetFromAlpha(lineContainer.Fill:GetAlpha());
			lineContainer.FadeAnim:Play();
			lineContainer.FadeAnim.releasePool = self.highlightLinePool;
			lineContainer.FadeAnim:SetScript("OnFinished", OnHighlightLineFadeFinish);
		end
	end
end

function FlightMap_FlightPathDataProviderMixin:AddFlightNode(taxiNodeData)
	local pin = self:GetMap():AcquirePin("FlightMap_FlightPointPinTemplate");
	self.slotIndexToPin[taxiNodeData.slotIndex] = pin;

	pin:SetPosition(taxiNodeData.x, taxiNodeData.y);
	pin.taxiNodeData = taxiNodeData;
	pin.owner = self;
	pin.linkedPins = {};

	if taxiNodeData.type == LE_FLIGHT_PATH_TYPE_CURRENT then
		pin.Icon:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-Green]]);
		pin.IconHighlight:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-White]]);
		pin:Show();
	elseif taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
		pin.Icon:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-White]]);
		pin.IconHighlight:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-White]]);
		pin:Show();
	elseif taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
		pin.Icon:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-Nub]]);
		pin.IconHighlight:SetTexture([[Interface/TaxiFrame/UI-Taxi-Icon-Nub]]);
		pin:Hide(); -- Only show if part of a route, handled in the route building functions
	end
end

--[[ Flight Point Pin ]]--
FlightMap_FlightPointPinMixin = CreateFromMixins(MapCanvasPinMixin);

function FlightMap_FlightPointPinMixin:OnLoad()
	self:SetScalingLimits(1.25, 3.0, 1.5);
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

		self.owner:HighlightRouteToPin(self);
	elseif self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_UNREACHABLE then
		GameTooltip:AddLine(TAXI_PATH_UNREACHABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	end

	GameTooltip:Show();
end

function FlightMap_FlightPointPinMixin:OnMouseLeave()
	if self.taxiNodeData.type == LE_FLIGHT_PATH_TYPE_REACHABLE then
		self.owner:RemoveRoute();
	end
	GameTooltip_Hide();
end