MapCanvasMixin = {};

function MapCanvasMixin:OnLoad()
	self.detailLayerPool = CreateFramePool("FRAME", self:GetCanvas(), "MapCanvasDetailLayerTemplate");
	self.dataProviders = {};
	self.dataProviderEventsCount = {};
	self.pinPools = {};
	self.activeAreaTriggers = {};
	self.lockReasons = {};

	self:EvaluateLockReasons();

	self.debugAreaTriggers = false;
end

function MapCanvasMixin:SetMapID(mapID)
	if self.mapID ~= mapID then
		self.areDetailLayersDirty = true;
		self.mapID = mapID; 
		self.expandedMapInsetsByMapID = {};
		self.ScrollContainer:SetMapID(mapID);
	end
end

function MapCanvasMixin:GetMapID()
	return self.mapID;
end

function MapCanvasMixin:SetMapInsetPool(mapInsetPool)
	self.mapInsetPool = mapInsetPool;
end

function MapCanvasMixin:GetMapInsetPool()
	return self.mapInsetPool;
end

function MapCanvasMixin:OnShow()
	local FROM_ON_SHOW = true;
	self:RefreshAll(FROM_ON_SHOW);

	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnShow();
	end
end

function MapCanvasMixin:OnHide()
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnHide();
	end
end

function MapCanvasMixin:OnEvent(event, ...)
	-- Data provider event
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:SignalEvent(event, ...);
	end
end

function MapCanvasMixin:AddDataProvider(dataProvider)
	self.dataProviders[dataProvider] = true;
	dataProvider:OnAdded(self);
end

function MapCanvasMixin:RemoveDataProvider(dataProvider)
	dataProvider:RemoveAllData();
	self.dataProviders[dataProvider] = nil;
	dataProvider:OnRemoved(self);
end

function MapCanvasMixin:AddDataProviderEvent(event)
	self.dataProviderEventsCount[event] = (self.dataProviderEventsCount[event] or 0) + 1;
	self:RegisterEvent(event);
end

function MapCanvasMixin:RemoveDataProviderEvent(event)
	if self.dataProviderEventsCount[event] then
		self.dataProviderEventsCount[event] = self.dataProviderEventsCount[event] - 1;
		if self.dataProviderEventsCount[event] == 0 then
			self.dataProviderEventsCount[event] = nil;
			self:UnregisterEvent(event);
		end
	end
end

do
	local function OnPinReleased(pinPool, pin)
		FramePool_HideAndClearAnchors(pinPool, pin);
		pin:OnReleased();

		pin.pinTemplate = nil;
		pin.owningMap = nil;
	end

	local function OnPinMouseUp(pin, button, upInside)
		if upInside then
			pin:OnClick(button);
		end
	end

	function MapCanvasMixin:AcquirePin(pinTemplate, ...)
		if not self.pinPools[pinTemplate] then
			self.pinPools[pinTemplate] = CreateFramePool("FRAME", self:GetCanvas(), pinTemplate, OnPinReleased);
		end

		local pin, newPin = self.pinPools[pinTemplate]:Acquire();

		if pin:IsMouseClickEnabled() then
			pin:SetScript("OnMouseUp", OnPinMouseUp);
		end

		if pin:IsMouseMotionEnabled() then
			pin:SetScript("OnEnter", pin.OnMouseEnter);
			pin:SetScript("OnLeave", pin.OnMouseLeave);
		end

		pin.pinTemplate = pinTemplate;
		pin.owningMap = self;

		if newPin then
			pin:OnLoad();
		end

		self.ScrollContainer:MarkCanvasDirty();

		pin:OnAcquired(...);

		return pin;
	end
end

function MapCanvasMixin:RemoveAllPinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		self.pinPools[pinTemplate]:ReleaseAll();
		self.ScrollContainer:MarkCanvasDirty();
	end
end

function MapCanvasMixin:RemovePin(pin)
	self.pinPools[pin.pinTemplate]:Release(pin);
	self.ScrollContainer:MarkCanvasDirty();
end

function MapCanvasMixin:EnumeratePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:EnumerateActive();
	end
	return nop;
end

function MapCanvasMixin:GetNumActivePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:GetNumActive();
	end
	return 0;
end

function MapCanvasMixin:EnumerateAllPins()
	local currentPoolKey, currentPool = next(self.pinPools, nil);
	local currentPin = nil;
	return function()
		if currentPool then
			currentPin = currentPool:GetNextActive(currentPin);
			while not currentPin do
				currentPoolKey, currentPool = next(self.pinPools, currentPoolKey);
				if currentPool then
					currentPin = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentPin;
	end, nil;
end

function MapCanvasMixin:AcquireAreaTrigger(namespace)
	if not self.activeAreaTriggers[namespace] then
		self.activeAreaTriggers[namespace] = {};
	end
	local areaTrigger = CreateRectangle();
	areaTrigger.enclosed = false;
	areaTrigger.intersects = false;

	areaTrigger.intersectCallback = nil;
	areaTrigger.enclosedCallback = nil;
	areaTrigger.triggerPredicate = nil;

	self.activeAreaTriggers[namespace][areaTrigger] = true;
	self.ScrollContainer:MarkAreaTriggersDirty();
	return areaTrigger;
end

function MapCanvasMixin:SetAreaTriggerEnclosedCallback(areaTrigger, enclosedCallback)
	areaTrigger.enclosedCallback = enclosedCallback;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:SetAreaTriggerIntersectsCallback(areaTrigger, intersectCallback)
	areaTrigger.intersectCallback = intersectCallback;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:SetAreaTriggerPredicate(areaTrigger, triggerPredicate)
	areaTrigger.triggerPredicate = triggerPredicate;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:ReleaseAreaTriggers(namespace)
	self.activeAreaTriggers[namespace] = nil;
	self:TryRefreshingDebugAreaTriggers();
end

function MapCanvasMixin:ReleaseAreaTrigger(namespace, areaTrigger)
	if self.activeAreaTriggers[namespace] then
		self.activeAreaTriggers[namespace][areaTrigger] = nil;
		self:TryRefreshingDebugAreaTriggers();
	end
end

function MapCanvasMixin:UpdateAreaTriggers(scrollRect)
	for namespace, areaTriggers in pairs(self.activeAreaTriggers) do
		for areaTrigger in pairs(areaTriggers) do
			if areaTrigger.intersectCallback then
				local intersects = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:IntersectsRect(areaTrigger);
				if areaTrigger.intersects ~= intersects then
					areaTrigger.intersects = intersects;
					areaTrigger.intersectCallback(areaTrigger, intersects);
				end
			end

			if areaTrigger.enclosedCallback then
				local enclosed = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:EnclosesRect(areaTrigger);

				if areaTrigger.enclosed ~= enclosed then
					areaTrigger.enclosed = enclosed;
					areaTrigger.enclosedCallback(areaTrigger, enclosed);
				end
			end
		end
	end

	self:TryRefreshingDebugAreaTriggers();
end

function MapCanvasMixin:TryRefreshingDebugAreaTriggers()
	if self.debugAreaTriggers then
		self:RefreshDebugAreaTriggers();
	elseif self.debugAreaTriggerPool then
		self.debugAreaTriggerPool:ReleaseAll();
	end
end

function MapCanvasMixin:RefreshDebugAreaTriggers()
	if not self.debugAreaTriggerPool then
		self.debugAreaTriggerPool = CreateTexturePool(self:GetCanvas(), "OVERLAY", 7, "MapCanvasDebugTriggerAreaTemplate");
		self.debugAreaTriggerColors = {};
	end
	
	self.debugAreaTriggerPool:ReleaseAll();

	local canvas = self:GetCanvas();

	for namespace, areaTriggers in pairs(self.activeAreaTriggers) do
		if not self.debugAreaTriggerColors[namespace] then
			self.debugAreaTriggerColors[namespace] = { math.random(), math.random(), math.random(), 0.45 };
		end
		for areaTrigger in pairs(areaTriggers) do
			local debugAreaTexture = self.debugAreaTriggerPool:Acquire();
			debugAreaTexture:SetPoint("TOPLEFT", canvas, "TOPLEFT", canvas:GetWidth() * areaTrigger:GetLeft(), -canvas:GetHeight() * areaTrigger:GetTop());
			debugAreaTexture:SetPoint("BOTTOMRIGHT", canvas, "TOPLEFT", canvas:GetWidth() * areaTrigger:GetRight(), -canvas:GetHeight() * areaTrigger:GetBottom());
			debugAreaTexture:SetColorTexture(unpack(self.debugAreaTriggerColors[namespace]));
			debugAreaTexture:Show();
		end
	end
end

function MapCanvasMixin:SetDebugAreaTriggersEnabled(enabled)
	self.debugAreaTriggers = enabled;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:RefreshDetailLayers()
	if not self.areDetailLayersDirty then return end;
	self.detailLayerPool:ReleaseAll();

	for layerIndex = 1, C_MapCanvas.GetNumDetailLayers(self.mapID) do
		if layerIndex == 1 then
			-- Layer 1 is our base layer, set the canvas to that size
			local numDetailTilesCols, numDetailTilesRows = C_MapCanvas.GetNumDetailTiles(self.mapID, layerIndex);
			self.ScrollContainer:SetCanvasSize(MapCanvasDetailLayer_CalculateTotalLayerSize(numDetailTilesCols, numDetailTilesRows));
		end

		local detailLayer = self.detailLayerPool:Acquire();
		detailLayer:SetAllPoints(self:GetCanvas());
		detailLayer:SetMapAndLayer(self.mapID, layerIndex);
		detailLayer:Show();
	end

	self:AdjustDetailLayerAlpha();

	self.areDetailLayersDirty = false;
end

function MapCanvasMixin:AdjustDetailLayerAlpha()
	-- For right now we're supporting just two layers, one zoomed out and one fully zoomed in
	local zoomPercent = self:GetCanvasZoomPercent();

	for layer in self.detailLayerPool:EnumerateActive() do
		local layerIndex = layer:GetLayerIndex();
		if layerIndex == 1 then
			layer:SetAlpha(1);
		else
			layer:SetAlpha(zoomPercent);
		end
	end
end

function MapCanvasMixin:RefreshAllDataProviders(fromOnShow)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:RefreshAllData(fromOnShow);
	end
end

function MapCanvasMixin:ResetInsets()
	if self.mapInsetPool then
		self.mapInsetPool:ReleaseAll();
		self.mapInsetsByIndex = {};
	end
end

function MapCanvasMixin:RefreshInsets()
	self:ResetInsets();
end

function MapCanvasMixin:AddInset(insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY)
	if self.mapInsetPool then
		local mapInset = self.mapInsetPool:Acquire();
		local expanded = self.expandedMapInsetsByMapID[mapID];
		mapInset:Initialize(self, not expanded, insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY);

		self.mapInsetsByIndex[insetIndex] = mapInset;
	end
end

function MapCanvasMixin:RefreshAll(fromOnShow)
	self:RefreshDetailLayers();
	self:RefreshInsets();
	self:RefreshAllDataProviders(fromOnShow);
end

function MapCanvasMixin:SetPinPosition(pin, normalizedX, normalizedY, insetIndex)
	if insetIndex then
		if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
			self.mapInsetsByIndex[insetIndex]:SetLocalPinPosition(pin, normalizedX, normalizedY);
		end
	else
		pin:ClearAllPoints();
		if normalizedX and normalizedY then
			local canvas = self:GetCanvas();
			local scale = pin:GetScale();
			pin:SetParent(canvas);
			pin:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * normalizedX) / scale, -(canvas:GetHeight() * normalizedY) / scale);
		end
	end
end

function MapCanvasMixin:GetGlobalPosition(normalizedX, normalizedY, insetIndex)
	if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
		return self.mapInsetsByIndex[insetIndex]:GetGlobalPosition(normalizedX, normalizedY);
	end
	return normalizedX, normalizedY;
end

function MapCanvasMixin:GetCanvas()
	return self.ScrollContainer.Child;
end

function MapCanvasMixin:CallMethodOnPinsAndDataProviders(methodName, ...)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider[methodName](dataProvider, ...);
	end

	for pin in self:EnumerateAllPins() do
		pin[methodName](pin, ...);
	end
end

function MapCanvasMixin:OnMapInsetSizeChanged(mapID, mapInsetIndex, expanded)
	self.expandedMapInsetsByMapID[mapID] = expanded;
	self:CallMethodOnPinsAndDataProviders("OnMapInsetSizeChanged", mapInsetIndex, expanded);
end

function MapCanvasMixin:OnMapInsetMouseEnter(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders("OnMapInsetMouseEnter", mapInsetIndex);
end

function MapCanvasMixin:OnMapInsetMouseLeave(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders("OnMapInsetMouseLeave", mapInsetIndex);
end

function MapCanvasMixin:OnCanvasScaleChanged()
	self:AdjustDetailLayerAlpha();

	if self.mapInsetsByIndex then
		for insetIndex, mapInset in pairs(self.mapInsetsByIndex) do
			mapInset:OnCanvasScaleChanged();
		end
	end

	self:CallMethodOnPinsAndDataProviders("OnCanvasScaleChanged");
end

function MapCanvasMixin:OnCanvasPanChanged()
	self:CallMethodOnPinsAndDataProviders("OnCanvasPanChanged");
end

function MapCanvasMixin:GetCanvasScale()
	return self.ScrollContainer:GetCanvasScale();
end

function MapCanvasMixin:GetCanvasZoomPercent()
	return self.ScrollContainer:GetCanvasZoomPercent();
end

function MapCanvasMixin:IsZoomingIn()
	return self.ScrollContainer:IsZoomingIn();
end

function MapCanvasMixin:IsZoomingOut()
	return self.ScrollContainer:IsZoomingOut();
end

function MapCanvasMixin:ZoomIn()
	self.ScrollContainer:ZoomIn();
end

function MapCanvasMixin:ZoomOut()
	self.ScrollContainer:ZoomOut();
end

function MapCanvasMixin:IsZoomedIn()
	return self.ScrollContainer:IsZoomedIn();
end

function MapCanvasMixin:IsZoomedOut()
	return self.ScrollContainer:IsZoomedOut();
end

function MapCanvasMixin:PanTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
end

function MapCanvasMixin:PanAndZoomTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
	self.ScrollContainer:ZoomIn();
end

function MapCanvasMixin:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.ScrollContainer:SetShouldZoomInOnClick(shouldZoomInOnClick);
end

function MapCanvasMixin:ShouldZoomInOnClick()
	return self.ScrollContainer:ShouldZoomInOnClick();
end

function MapCanvasMixin:SetShouldPanOnClick(shouldPanOnClick)
	self.ScrollContainer:SetShouldPanOnClick(shouldPanOnClick);
end

function MapCanvasMixin:ShouldPanOnClick()
	return self.ScrollContainer:ShouldPanOnClick();
end

function MapCanvasMixin:SetDefaultMaxZoom()
	self.ScrollContainer:SetMaxZoom(self.ScrollContainer.defaultMaxScale);
end

function MapCanvasMixin:SetDefaultMinZoom()
	self.ScrollContainer:SetMinZoom(self.ScrollContainer.defaultMinScale);
end

function MapCanvasMixin:SetMaxZoom(scale)
	self.ScrollContainer:SetMaxZoom(scale);
end

function MapCanvasMixin:SetMinZoom(scale)
	self.ScrollContainer:SetMinZoom(scale);
end

function MapCanvasMixin:GetViewRect()
	return self.ScrollContainer:GetViewRect();
end

function MapCanvasMixin:GetMaxZoomViewRect()
	return self.ScrollContainer:GetMaxZoomViewRect();
end

function MapCanvasMixin:GetMinZoomViewRect()
	return self.ScrollContainer:GetMinZoomViewRect();
end

function MapCanvasMixin:GetScaleForMaxZoom()
	return self.ScrollContainer:GetScaleForMaxZoom();
end

function MapCanvasMixin:GetScaleForMinZoom()
	return self.ScrollContainer:GetScaleForMinZoom();
end

function MapCanvasMixin:CalculateZoomScaleAndPositionForAreaInViewRect(...)
	return self.ScrollContainer:CalculateZoomScaleAndPositionForAreaInViewRect(...);
end

function MapCanvasMixin:NormalizeHorizontalSize(size)
	return self.ScrollContainer:NormalizeHorizontalSize(size);
end

function MapCanvasMixin:DenormalizeHorizontalSize(size)
	return self.ScrollContainer:DenormalizeHorizontalSize(size);
end

function MapCanvasMixin:NormalizeVerticalSize(size)
	return self.ScrollContainer:NormalizeVerticalSize(size);
end

function MapCanvasMixin:DenormalizeVerticalSize(size)
	return self.ScrollContainer:DenormalizeVerticalSize(size);
end

function MapCanvasMixin:GetNormalizedCursorPosition()
	return self.ScrollContainer:GetNormalizedCursorPosition()
end

function MapCanvasMixin:IsCanvasMouseFocus()
	return self.ScrollContainer == GetMouseFocus();
end

function MapCanvasMixin:AddLockReason(reason)
	self.lockReasons[reason] = true;
	self:EvaluateLockReasons();
end

function MapCanvasMixin:RemoveLockReason(reason)
	self.lockReasons[reason] = nil;
	self:EvaluateLockReasons();
end

function MapCanvasMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		self.BorderFrame:EnableMouse(true);
		self.BorderFrame:EnableMouseWheel(true);
		
		self.BorderFrame.Underlay:Show();
	else
		self.BorderFrame:EnableMouse(false);
		self.BorderFrame:EnableMouseWheel(false);

		self.BorderFrame.Underlay:Hide();
	end
end

MapCanvasScrollControllerMixin = {};

MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH = 1;
MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL = 2;
MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE = 3;

function MapCanvasScrollControllerMixin:OnLoad()
	self.targetScrollX = 0.5;
	self.targetScrollY = 0.5;

	self.defaultMaxScale = .75;
	self.defaultMinScale = .275;

	self.zoomAmountPerMouseWheelDelta = .075;

	self.mouseWheelZoomMode = MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL;
	self:SetScalingMode("SCALING_MODE_TRANSLATE_FASTER_THAN_SCALE");

	self.normalizedZoomLerpAmount = .15;
	self.normalizedPanXLerpAmount = .15;
	self.normalizedPanYLerpAmount = .15;
end

function MapCanvasScrollControllerMixin:OnMouseDown(button)
	if button == "LeftButton" then
		self.isLeftButtonDown = true;

		self.lastCursorX, self.lastCursorY = self:GetCursorPosition();
		self.startCursorX, self.startCursorY = self.lastCursorX, self.lastCursorY;

		if self:IsPanning() then
			self.currentScrollX = self:GetNormalizedHorizontalScroll();
			self.currentScrollY = self:GetNormalizedVerticalScroll();

			self.targetScrollX = self.currentScrollX;
			self.targetScrollY = self.currentScrollY;
		end

		self.accumulatedMouseDeltaX = 0.0;
		self.accumulatedMouseDeltaY = 0.0;
	end
end

function MapCanvasScrollControllerMixin:FindBestZoneLocationForClick()
	local endCursorX, endCursorY = self:GetCursorPosition();
	local startDeltaX, startDeltaY = endCursorX - self.startCursorX, endCursorY - self.startCursorY;
	local MAX_DIST_FOR_CLICK_SQ = 10;
	-- Make sure it was a click and not a pan
	if startDeltaX * startDeltaX + startDeltaY * startDeltaY < MAX_DIST_FOR_CLICK_SQ then
		local normalizedCursorX = self:NormalizeHorizontalSize(endCursorX / self:GetCanvasScale() - self.Child:GetLeft());
		local normalizedCursorY = self:NormalizeVerticalSize(self.Child:GetTop() - endCursorY / self:GetCanvasScale());

		local zoneMapID = C_MapCanvas.FindZoneAtPosition(self.mapID, normalizedCursorX, normalizedCursorY);
		if zoneMapID then
			local zoneName, zoneDepth, left, right, top, bottom = C_MapCanvas.GetZoneInfoByID(self.mapID, zoneMapID);
			local centerX = left + (right - left) * .5;
			local centerY = top + (bottom - top) * .5;

			return centerX, centerY;
		end
	end
end

function MapCanvasScrollControllerMixin:TryPanOrZoomOnClick()
	if self.mapID then
		local shouldZoomOnClick = self:ShouldZoomInOnClick() and (self:IsZoomedOut() or self:IsZoomingOut());
		if self:ShouldPanOnClick() or shouldZoomOnClick then
			local x, y = self:FindBestZoneLocationForClick();
			if x and y then
				self:SetPanTarget(x, y);
				if shouldZoomOnClick then
					self:ZoomIn();
				end
				return true;
			end
		end
	end

	return false;
end

function MapCanvasScrollControllerMixin:OnMouseUp(button)
	if button == "LeftButton" then
		if not self:TryPanOrZoomOnClick() and self:IsPanning() then
			local deltaX, deltaY = self:GetNormalizedMouseDelta();
			self:AccumulateMouseDeltas(GetTickTime(), deltaX, deltaY);

			self.targetScrollX = Clamp(self.targetScrollX + self.accumulatedMouseDeltaX, self.scrollXExtentsMin, self.scrollXExtentsMax);
			self.targetScrollY = Clamp(self.targetScrollY + self.accumulatedMouseDeltaY, self.scrollYExtentsMin, self.scrollYExtentsMax);
		end
		self.isLeftButtonDown = false;
	elseif button == "RightButton" then
		if self:ShouldZoomInOnClick() then
			self:ZoomOut();
		end
	end
end

function MapCanvasScrollControllerMixin:OnMouseWheel(delta)
	if self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE then
		return;
	end

	if delta > 0 then
		if self:IsZoomedOut() or self:IsZoomingOut() or self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			local cursorX, cursorY = self:GetCursorPosition();
			local normalizedCursorX = self:NormalizeHorizontalSize(cursorX / self:GetCanvasScale() - self.Child:GetLeft());
			local normalizedCursorY = self:NormalizeVerticalSize(self.Child:GetTop() - cursorY / self:GetCanvasScale());

			local minX, maxX, minY, maxY = self:CalculateScrollExtentsAtScale(self.maxScale);
			
			self:SetPanTarget(Clamp(normalizedCursorX, minX, maxX), Clamp(normalizedCursorY, minY, maxY));
		end

		if self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			self:SetZoomTarget(self:GetCanvasScale() + self.zoomAmountPerMouseWheelDelta)
		elseif self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL then
			self:ZoomIn();
		end
	else
		if self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_SMOOTH then
			self:SetZoomTarget(self:GetCanvasScale() - self.zoomAmountPerMouseWheelDelta)
		elseif self.mouseWheelZoomMode == MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_FULL then
			self:ZoomOut();
		end
	end
end

function MapCanvasScrollControllerMixin:OnHide()
	self.isLeftButtonDown = false;

	self.currentScale = nil;
	self.currentScrollX = nil;
	self.currentScrollY = nil;
end

function MapCanvasScrollControllerMixin:SetCanvasSize(width, height)
	self.Child:SetSize(width, height);
	self.Child.TiledBackground:SetSize(width * 2, height * 2);
	self:CalculateScaleExtents();
	self:CalculateScrollExtents();
end

function MapCanvasScrollControllerMixin:CalculateScaleExtents()
	if not self.maxScale then
		self:SetMaxZoom(self.defaultMaxScale);
	end

	if not self.minScale then
		self:SetMinZoom(self.defaultMinScale);
	end

	self.targetScale = Clamp(self.targetScale or self.minScale, self.minScale, self.maxScale);
end

function MapCanvasScrollControllerMixin:CalculateScrollExtents()
	self.scrollXExtentsMin, self.scrollXExtentsMax, self.scrollYExtentsMin, self.scrollYExtentsMax = self:CalculateScrollExtentsAtScale(self:GetCanvasScale());
end

function MapCanvasScrollControllerMixin:CalculateScrollExtentsAtScale(scale)
	local xOffset = self:NormalizeHorizontalSize((self:GetWidth() * .5) / scale);
	local yOffset = self:NormalizeVerticalSize((self:GetHeight() * .5) / scale);
	return 0.0 + xOffset, 1.0 - xOffset, 0.0 + yOffset, 1.0 - yOffset;
end

do
	local MOUSE_DELTA_SAMPLES = 100;
	local MOUSE_DELTA_FACTOR = 250;
	function MapCanvasScrollControllerMixin:AccumulateMouseDeltas(elapsed, deltaX, deltaY)
		-- If the mouse changes direction then clear out the old values so it doesn't slide the wrong direction
		if deltaX > 0 and self.accumulatedMouseDeltaX < 0 or deltaX < 0 and self.accumulatedMouseDeltaX > 0 then
			self.accumulatedMouseDeltaX = 0.0;
		end

		if deltaY > 0 and self.accumulatedMouseDeltaY < 0 or deltaY < 0 and self.accumulatedMouseDeltaY > 0 then
			self.accumulatedMouseDeltaY = 0.0;
		end
			
		local normalizedSamples = MOUSE_DELTA_SAMPLES * elapsed * 60;
		self.accumulatedMouseDeltaX = (self.accumulatedMouseDeltaX / normalizedSamples) + (deltaX * MOUSE_DELTA_FACTOR) / normalizedSamples;
		self.accumulatedMouseDeltaY = (self.accumulatedMouseDeltaY / normalizedSamples) + (deltaY * MOUSE_DELTA_FACTOR) / normalizedSamples;
	end
end

function MapCanvasScrollControllerMixin:CalculateLerpScaling()
	if self:ScalingMode() == "SCALING_MODE_TRANSLATE_FASTER_THAN_SCALE" then
		-- Because of the way zooming in + isLeftButtonDown is perceived, we want to reduce the zoom weight so that panning completes first
		-- However, for zooming out we want to prefer the zoom then pan
		local SCALE_DELTA_FACTOR = self:IsZoomingOut() and 1.5 or .01; 
		local scaleDelta = (math.abs(self:GetCanvasScale() - self.targetScale) / (self.maxScale - self.minScale)) * SCALE_DELTA_FACTOR;
		local scrollXDelta = math.abs(self:GetCurrentScrollX() - self.targetScrollX);
		local scrollYDelta = math.abs(self:GetCurrentScrollY() - self.targetScrollY);

		local largestDelta = math.max(math.max(scaleDelta, scrollXDelta), scrollYDelta);
		if largestDelta ~= 0.0 then
			return scaleDelta / largestDelta, scrollXDelta / largestDelta, scrollYDelta / largestDelta;
		end
		return 1.0, 1.0, 1.0;
	elseif self:ScalingMode() == "SCALING_MODE_LINEAR" then
		return 1.0, 1.0, 1.0;
	end
end

function MapCanvasScrollControllerMixin:SetScalingMode(mode)
	self.scalingMode = mode;
end

function MapCanvasScrollControllerMixin:ScalingMode()
	return self.scalingMode;
end

local DELTA_SCALE_BEFORE_SNAP = .0001;
local DELTA_POSITION_BEFORE_SNAP = .0001;
function MapCanvasScrollControllerMixin:OnUpdate(elapsed)
	if self:IsPanning() then
		local deltaX, deltaY = self:GetNormalizedMouseDelta();

		self.targetScrollX = Clamp(self.targetScrollX + deltaX, self.scrollXExtentsMin, self.scrollXExtentsMax);
		self.targetScrollY = Clamp(self.targetScrollY + deltaY, self.scrollYExtentsMin, self.scrollYExtentsMax);

		self.lastCursorX, self.lastCursorY = self:GetCursorPosition();

		self:AccumulateMouseDeltas(elapsed, deltaX, deltaY);
	end

	local scaleScaling, scrollXScaling, scrollYScaling = self:CalculateLerpScaling();

	if self.currentScale ~= self.targetScale then
		local oldScrollX = self:GetNormalizedHorizontalScroll();
		local oldScrollY = self:GetNormalizedVerticalScroll();

		if not self.currentScale or math.abs(self.currentScale - self.targetScale) < DELTA_SCALE_BEFORE_SNAP then
			self.currentScale = self.targetScale;
		else
			self.currentScale = FrameDeltaLerp(self.currentScale, self.targetScale, self.normalizedZoomLerpAmount * scaleScaling);
		end

		self.Child:SetScale(self.currentScale);
		self:CalculateScrollExtents();

		self:SetNormalizedHorizontalScroll(oldScrollX);
		self:SetNormalizedVerticalScroll(oldScrollY);

		self:GetParent():OnCanvasScaleChanged();
		self:MarkAreaTriggersDirty();
		self:MarkViewRectDirty();
	end

	local panChanged = false;
	if not self.currentScrollX or self.currentScrollX ~= self.targetScrollX then
		if not self.currentScrollX or self:IsPanning() or math.abs(self.currentScrollX - self.targetScrollX) < DELTA_POSITION_BEFORE_SNAP then
			self.currentScrollX = self.targetScrollX;
		else
			self.currentScrollX = FrameDeltaLerp(self.currentScrollX, self.targetScrollX, self.normalizedPanXLerpAmount * scrollXScaling);
		end

		self:SetNormalizedHorizontalScroll(self.currentScrollX);
		self:MarkAreaTriggersDirty();
		self:MarkViewRectDirty();

		panChanged = true;
	end

	if not self.currentScrollY or self.currentScrollY ~= self.targetScrollY then
		if not self.currentScrollY or self:IsPanning() or math.abs(self.currentScrollY - self.targetScrollY) < DELTA_POSITION_BEFORE_SNAP then
			self.currentScrollY = self.targetScrollY;
		else
			self.currentScrollY = FrameDeltaLerp(self.currentScrollY, self.targetScrollY, self.normalizedPanYLerpAmount * scrollYScaling);
		end
		self:SetNormalizedVerticalScroll(self.currentScrollY);
		self:MarkAreaTriggersDirty();
		self:MarkViewRectDirty();

		panChanged = true;
	end
	
	if panChanged then
		self:GetParent():OnCanvasPanChanged();
	end

	if self.areaTriggersDirty then
		self.areaTriggersDirty = false;
		local viewRect = self:GetViewRect();
		self:GetParent():UpdateAreaTriggers(viewRect);
	end
end

function MapCanvasScrollControllerMixin:MarkAreaTriggersDirty()
	self.areaTriggersDirty = true;
end

function MapCanvasScrollControllerMixin:MarkViewRectDirty()
	self.viewRect = nil;
end

function MapCanvasScrollControllerMixin:MarkCanvasDirty()
	-- Force an update unless an update is already going to occur
	if self.currentScale == self.targetScale then
		self.currentScale = nil;
	end
	if self.currentScrollX == self.targetScrollX then
		self.currentScrollX = nil;
	end
	if self.currentScrollY == self.targetScrollY then
		self.currentScrollY = nil;
	end
end

function MapCanvasScrollControllerMixin:GetViewRect()
	if not self.viewRect then
		self.viewRect = self:CalculateViewRect(self:GetCanvasScale());
	end
	return self.viewRect;
end

function MapCanvasScrollControllerMixin:SetMapID(mapID)
	self.mapID = mapID;
end

function MapCanvasScrollControllerMixin:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.shouldZoomInOnClick = shouldZoomInOnClick;
end

function MapCanvasScrollControllerMixin:ShouldZoomInOnClick()
	return not not self.shouldZoomInOnClick;
end

function MapCanvasScrollControllerMixin:SetShouldPanOnClick(shouldPanOnClick)
	self.shouldPanOnClick = shouldPanOnClick;
end

function MapCanvasScrollControllerMixin:ShouldPanOnClick()
	return not not self.shouldPanOnClick;
end

function MapCanvasScrollControllerMixin:SetMaxZoom(scale)
	self.maxScale = scale;
end

function MapCanvasScrollControllerMixin:SetMinZoom(scale)
	self.minScale = scale;
end

function MapCanvasScrollControllerMixin:GetMaxZoomViewRect()
	return self:CalculateViewRect(self.maxScale);
end

function MapCanvasScrollControllerMixin:GetMinZoomViewRect()
	return self:CalculateViewRect(self.minScale);
end

function MapCanvasScrollControllerMixin:CalculateViewRect(scale)
	local childWidth, childHeight = self.Child:GetSize();
	local left = self:GetHorizontalScroll() / childWidth;
	local right = left + (self:GetWidth() / scale) / childWidth;
	local top = self:GetVerticalScroll() / childHeight;
	local bottom = top + (self:GetHeight() / scale) / childHeight;
	return CreateRectangle(left, right, top, bottom);
end

function MapCanvasScrollControllerMixin:CalculateZoomScaleAndPositionForAreaInViewRect(left, right, top, bottom, subViewLeft, subViewRight, subViewTop, subViewBottom)
	local childWidth, childHeight = self.Child:GetSize();
	local viewWidth, viewHeight = self:GetSize();

	-- this is the desired width/height of the full view given the desired positions for the subview
	local fullWidth = (right - left) / (subViewRight - subViewLeft);
	local fullHeight = (bottom - top) / (subViewTop - subViewBottom);

	local scale = ( viewWidth / fullWidth ) / childWidth;

	-- translate from the upper-left of the subview to the center of the view.
	local fullLeft = left - (fullWidth * subViewLeft);
	local fullBottom = (1.0 - bottom) - (fullHeight * subViewBottom);

	local fullCenterX = fullLeft + (fullWidth / 2);
	local fullCenterY = 1.0 - (fullBottom + (fullHeight / 2));

	return scale, fullCenterX, fullCenterY;
end

function MapCanvasScrollControllerMixin:SetPanTarget(normalizedX, normalizedY)
	self.targetScrollX = normalizedX;
	self.targetScrollY = normalizedY;
end

function MapCanvasScrollControllerMixin:SetZoomTarget(zoomTarget)
	self.targetScale = Clamp(zoomTarget, self.minScale, self.maxScale);
end

function MapCanvasScrollControllerMixin:ZoomIn()
	self:SetZoomTarget(self.maxScale);
end

function MapCanvasScrollControllerMixin:ZoomOut()
	self:SetZoomTarget(self.minScale);
	self:SetPanTarget(.5, .5);
end

function MapCanvasScrollControllerMixin:IsZoomingIn()
	return self:GetCanvasScale() < self.targetScale;
end

function MapCanvasScrollControllerMixin:IsZoomingOut()
	return self.targetScale < self:GetCanvasScale();
end

function MapCanvasScrollControllerMixin:IsZoomedIn()
	return self:GetCanvasScale() == self.maxScale;
end

function MapCanvasScrollControllerMixin:IsZoomedOut()
	return self:GetCanvasScale() == self.minScale;
end

function MapCanvasScrollControllerMixin:GetScaleForMaxZoom()
	return self.maxScale;
end

function MapCanvasScrollControllerMixin:GetScaleForMinZoom()
	return self.minScale;
end

function MapCanvasScrollControllerMixin:IsPanning()
	return self.isLeftButtonDown and not self:IsZoomingOut() and not self:IsZoomedOut();
end

function MapCanvasScrollControllerMixin:GetCanvasScale()
	return self.currentScale or self.targetScale;
end

function MapCanvasScrollControllerMixin:GetCurrentScrollX()
	return self.currentScrollX or self.targetScrollX;
end

function MapCanvasScrollControllerMixin:GetCurrentScrollY()
	return self.currentScrollY or self.targetScrollY;
end

function MapCanvasScrollControllerMixin:GetCanvasZoomPercent()
	return PercentageBetween(self:GetCanvasScale(), self.minScale, self.maxScale);
end

function MapCanvasScrollControllerMixin:SetNormalizedHorizontalScroll(scrollAmount)
	local offset = self:DenormalizeHorizontalSize(scrollAmount);
	self:SetHorizontalScroll(offset - (self:GetWidth() * .5) / self:GetCanvasScale());
end

function MapCanvasScrollControllerMixin:GetNormalizedHorizontalScroll()
	return (2.0 * self:GetHorizontalScroll() * self:GetCanvasScale() + self:GetWidth()) / (2.0 * self.Child:GetWidth() * self:GetCanvasScale());
end

function MapCanvasScrollControllerMixin:SetNormalizedVerticalScroll(scrollAmount)
	local offset = self:DenormalizeVerticalSize(scrollAmount);
	self:SetVerticalScroll(offset - (self:GetHeight() * .5) / self:GetCanvasScale());
end

function MapCanvasScrollControllerMixin:GetNormalizedVerticalScroll()
	return (2.0 * self:GetVerticalScroll() * self:GetCanvasScale() + self:GetHeight()) / (2.0 * self.Child:GetHeight() * self:GetCanvasScale());
end

function MapCanvasScrollControllerMixin:NormalizeHorizontalSize(size)
	return size / self.Child:GetWidth();
end

function MapCanvasScrollControllerMixin:DenormalizeHorizontalSize(size)
	return size * self.Child:GetWidth();
end

function MapCanvasScrollControllerMixin:NormalizeVerticalSize(size)
	return size / self.Child:GetHeight();
end

function MapCanvasScrollControllerMixin:DenormalizeVerticalSize(size)
	return size * self.Child:GetHeight();
end

function MapCanvasScrollControllerMixin:GetCursorPosition()
	local currentX, currentY = GetCursorPosition();
	local effectiveScale = UIParent:GetEffectiveScale();
	return currentX / effectiveScale, currentY / effectiveScale;
end

function MapCanvasScrollControllerMixin:GetNormalizedMouseDelta()
	if self.lastCursorX and self.lastCursorY then
		local currentX, currentY = self:GetCursorPosition();
		return self:NormalizeHorizontalSize(self.lastCursorX - currentX) / self:GetCanvasScale(), self:NormalizeVerticalSize(currentY - self.lastCursorY) / self:GetCanvasScale();
	end
	return 0.0, 0.0;
end

-- Normalizes a global UI position to the map canvas
function MapCanvasScrollControllerMixin:NormalizeUIPosition(x, y)
	return Saturate(self:NormalizeHorizontalSize(x / self:GetCanvasScale() - self.Child:GetLeft())),
		   Saturate(self:NormalizeVerticalSize(self.Child:GetTop() - y / self:GetCanvasScale()));
end

function MapCanvasScrollControllerMixin:GetNormalizedCursorPosition()
	local x, y = self:GetCursorPosition();
	return self:NormalizeUIPosition(x, y);
end