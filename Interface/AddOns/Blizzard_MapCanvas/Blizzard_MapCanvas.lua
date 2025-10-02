MapCanvasMixin = CreateFromMixins(CallbackRegistryMixin);

MapCanvasMixin.MouseAction = { Up = 1, Down = 2, Click = 3 };

function MapCanvasMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:SetUndefinedEventsAllowed(true);

	self.detailLayerPool = CreateFramePool("FRAME", self:GetCanvas(), "MapCanvasDetailLayerTemplate");
	self.dataProviders = {};
	self.dataProviderEventsCount = {};
	self.pinPools = {};
	self.pinTemplateTypes = {};
	self.activeAreaTriggers = {};
	self.lockReasons = {};
	self.pinsToNudge = {};
	self.pinFrameLevelsManager = CreateFromMixins(MapCanvasPinFrameLevelsManagerMixin);
	self.pinFrameLevelsManager:Initialize();
	self.mouseClickHandlers = MapCanvasSecureUtil.CreateHandlerRegistry();
	self.globalPinMouseActionHandlers = MapCanvasSecureUtil.CreateHandlerRegistry();
	self.cursorHandlers = MapCanvasSecureUtil.CreateHandlerRegistry();
	self.pinSuppressors = {};

	self:EvaluateLockReasons();

	self.debugAreaTriggers = false;
end

function MapCanvasMixin:OnUpdate()
	ClearCachedActivitiesForPlayer();
	self:UpdatePinSuppression();
	self:UpdatePinNudging();
	self:ProcessCursorHandlers();
	self:RunDataProviderOnUpdate();
end

function MapCanvasMixin:SetMapID(mapID)
	if KioskFrame and KioskFrame:HasAllowedMaps() then
		local mapIDs = KioskFrame:GetAllowedMapIDs();
		if not tContains(mapIDs, mapID) then
			if not self.mapID then
				-- Initialize to an allowed map and assert. Using approved maps is only
				-- suitable if we know exactly the maps the player should be in.
				assert(false, "Map ID "..mapID.." is not amongst the approved maps.");
				mapID = mapIDs[1];
			else
				-- Not in our list, so don't change the map.
				return;
			end;
		end
	end

	local mapArtID = C_Map.GetMapArtID(mapID) -- phased map art may be different for the same mapID
	if self.mapID ~= mapID or self.mapArtID ~= mapArtID then
		self.areDetailLayersDirty = true;
		self.mapID = mapID;
		self.mapArtID = mapArtID;
		self.expandedMapInsetsByMapID = {};
		self.ScrollContainer:SetMapID(mapID);
		if self:IsShown() then
			self:RefreshDetailLayers();
		end
		self:OnMapChanged();
	end
end

function MapCanvasMixin:OnFrameSizeChanged()
	self.ScrollContainer:OnCanvasSizeChanged();
end

function MapCanvasMixin:GetMapID()
	-- normally the mapID is set in OnShow, however if the player has never opened the quest log or the map, and then
	-- hides the UI, and while the UI is hidden opens the quest log, mapID will be nil and we get a lua error.
	-- under these very rare circumstances, dig out the diplayable mapID.
	return self.mapID or MapUtil.GetDisplayableMapForPlayer();
end

function MapCanvasMixin:SetMapInsetPool(mapInsetPool)
	self.mapInsetPool = mapInsetPool;
end

function MapCanvasMixin:GetMapInsetPool()
	return self.mapInsetPool;
end

do
	local function MapCanvasOnDataProviderShow(dataProvider, _included)
		dataProvider:OnShow();
	end

	function MapCanvasMixin:OnShow()
		ClearCachedActivitiesForPlayer();

		local FROM_ON_SHOW = true;
		self:RefreshAll(FROM_ON_SHOW);

		secureexecuterange(self.dataProviders, MapCanvasOnDataProviderShow);

		self:RegisterEvent("HANDLE_UI_ACTION");
	end
end

do
	local function MapCanvasOnDataProviderHide(dataProvider, _included)
		dataProvider:OnHide();
	end

	function MapCanvasMixin:OnHide()
		self:UnregisterEvent("HANDLE_UI_ACTION");

		secureexecuterange(self.dataProviders, MapCanvasOnDataProviderHide);
	end
end

do
	local function MapCanvasOnDataProviderEvent(dataProvider, _included, event, ...)
		dataProvider:SignalEvent(event, ...);
	end

	function MapCanvasMixin:OnEvent(event, ...)
		-- UIActions are now directly delivered to data providers
		if event == "HANDLE_UI_ACTION" then
			self:HandleUIAction(...);
		else
			secureexecuterange(self.dataProviders, MapCanvasOnDataProviderEvent, event, ...);
		end
	end
end

function MapCanvasMixin:ModifyDataProviderOnUpdate(dataProvider, registered)
	GetOrCreateTableEntry(self, "pendingOnUpdateDataProviders")[dataProvider] = registered;
	self.onUpdateDataProvidersDirty = true;
end

function MapCanvasMixin:RegisterDataProviderOnUpdate(dataProvider)
	self:ModifyDataProviderOnUpdate(dataProvider, true);
end

function MapCanvasMixin:UnregisterDataProviderOnUpdate(dataProvider)
	self:ModifyDataProviderOnUpdate(dataProvider, false);
end

do
	local function MapCanvasOnDataProviderOnUpdate(dataProvider, _included)
		dataProvider:OnUpdate();
	end

	function MapCanvasMixin:RunDataProviderOnUpdate()
		if self.onUpdateDataProvidersDirty then
			local onUpdateContainer = GetOrCreateTableEntry(self, "onUpdateDataProviders");
			for provider, registered in pairs(self.pendingOnUpdateDataProviders) do
				onUpdateContainer[provider] = registered and true or nil;
			end
		end

		if self.onUpdateDataProviders then
			secureexecuterange(self.onUpdateDataProviders, MapCanvasOnDataProviderOnUpdate);
		end
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

function MapCanvasMixin:SetPinNudgingDirty()
	self.pinNudgingDirty = true;
end

function MapCanvasMixin:AddPinToNudge(pin)
	table.insert(self.pinsToNudge, pin);
end

function MapCanvasMixin:IsPinNudgingDirty()
	return self.pinNudgingDirty or (self.pinsToNudge and #self.pinsToNudge > 0);
end

function MapCanvasMixin:ExecuteOnPinsToNudge(callbackAllPins, callbackSpecificPins, ...)
	if self.pinNudgingDirty then
		self:ExecuteOnAllPins(callbackAllPins, ...);
	elseif #self.pinsToNudge then
		secureexecuterange(self.pinsToNudge, callbackSpecificPins, ...);
	end
end

function MapCanvasMixin:MarkPinNudgingClean()
	self.pinNudgingDirty = false;
	self.pinsToNudge = {};
end

function MapCanvasMixin:SetPinSuppressionDirty()
	self.pinSuppressionDirty = true;
end

function MapCanvasMixin:IsPinSuppressionDirty()
	return self.pinSuppressionDirty;
end

function MapCanvasMixin:MarkPinSuppressionClean()
	self.pinSuppressionDirty = false;
end

function MapCanvasMixin:SetPinPostProcessDirty()
	self:SetPinNudgingDirty();
	self:SetPinSuppressionDirty();
end

do
	local function OnPinReleased(pinPool, pin)
		local map = pin:GetMap();
		if map then
			map:UnregisterPin(pin);
		end

		Pool_HideAndClearAnchors(pinPool, pin);
		pin:OnReleased();

		pin.pinTemplate = nil;
		pin:SetOwningMap(nil);
	end

	local function OnPinMouseUp(pin, button, upInside)
		pin:OnMouseUp(button, upInside);
		if upInside then
			pin:OnClick(button);
		end
	end

	function MapCanvasMixin:AcquirePin(pinTemplate, ...)
		if not self.pinPools[pinTemplate] then
			local pinTemplateType = self:GetPinTemplateType(pinTemplate);
			self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased);
		end

		local pin, newPin = self.pinPools[pinTemplate]:Acquire();

		pin.pinTemplate = pinTemplate;
		pin:SetOwningMap(self);

		if newPin then
			local isMouseClickEnabled = pin:IsMouseClickEnabled();
			local isMouseMotionEnabled = pin:IsMouseMotionEnabled();

			if isMouseClickEnabled then
				pin:SetScript("OnMouseUp", OnPinMouseUp);
				pin:SetScript("OnMouseDown", pin.OnMouseDown);

				-- Prevent OnClick handlers from being run twice, once a frame is in the mapCanvas ecosystem it needs
				-- to process mouse events only via the map system.
				if pin:IsObjectType("Button") then
					pin:SetScript("OnClick", nil);
				end
			end

			if isMouseMotionEnabled then
				if newPin and not pin:DisableInheritedMotionScriptsWarning() then
					-- These will never be called, just define a OnMouseEnter and OnMouseLeave on the pin mixin and it'll be called when appropriate
					assert(pin:GetScript("OnEnter") == nil);
					assert(pin:GetScript("OnLeave") == nil);
				end
				pin:SetScript("OnEnter", pin.OnMouseEnter);
				pin:SetScript("OnLeave", pin.OnMouseLeave);
			end

			pin:SetMouseClickEnabled(isMouseClickEnabled);
			pin:SetMouseMotionEnabled(isMouseMotionEnabled);
		end

		if newPin then
			pin:OnLoad();
		end

		self.ScrollContainer:MarkCanvasDirty();
		pin:Show();
		pin:OnAcquired(...);

		-- Most pins should pass through right clicks to allow the map to zoom out
		-- This needs to be checked after OnAcquired because re-used pins can have
		-- dynamic setups that requires input propagation adjustment.
		pin:CheckMouseButtonPassthrough("RightButton");

		self:RegisterPin(pin);

		return pin;
	end
end

function MapCanvasMixin:SetPinTemplateType(pinTemplate, pinTemplateType)
	self.pinTemplateTypes[pinTemplate] = pinTemplateType;
end

function MapCanvasMixin:GetPinTemplateType(pinTemplate)
	-- Can always be overridden by manually calling SetPinTemplateType, but by default this will use the template
	-- to look up type information and discover the most likely type so that pins can avoid needing to call
	-- SetPinTemplateType.
	local pinTemplateType = self.pinTemplateTypes[pinTemplate];
	if not pinTemplateType then
		local templateInfo = C_XMLUtil.GetTemplateInfo(pinTemplate);
		pinTemplateType = templateInfo and templateInfo.type or "FRAME";
		self.pinTemplateTypes[pinTemplate] = pinTemplateType;
	end

	return pinTemplateType;
end

function MapCanvasMixin:RemoveAllPinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		self.pinPools[pinTemplate]:ReleaseAll();
		self.ScrollContainer:MarkCanvasDirty();
	end
end

function MapCanvasMixin:RemovePin(pin)
	if pin:GetNudgeSourceRadius() > 0 then
		self:SetPinPostProcessDirty();
	end

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

do
	local function MapCanvasExecuteOnPinPools(_poolKey, pool, callback, ...)
		for activePin in pool:EnumerateActive() do
			callback(activePin, ...);
		end
	end

	function MapCanvasMixin:ExecuteOnAllPins(callback, ...)
		secureexecuterange(self.pinPools, MapCanvasExecuteOnPinPools, callback, ...);
	end
end

function MapCanvasMixin:RegisterPin(pin)
	if pin:IsPinSuppressor() and not tContains(self.pinSuppressors, pin) then
		table.insert(self.pinSuppressors, pin);
		self:SetPinSuppressionDirty();
	end
end

function MapCanvasMixin:UnregisterPin(pin)
	if pin:IsPinSuppressor() then
		tDeleteItem(self.pinSuppressors, pin);
		self:SetPinSuppressionDirty();
	end	
end

function MapCanvasMixin:GetPinSuppressors()
	return self.pinSuppressors;
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

do
	local function DoPinSuppression(targetPin, mapCanvas)
		-- If the pin was already suppressed by another suppressor it doesn't need a check.
		if targetPin:IsSuppressed() then
			return;
		end

		for index, suppressor in ipairs(mapCanvas:GetPinSuppressors()) do
			if suppressor:ShouldSuppressPin(targetPin) then
				suppressor:TrackSuppressedPin(targetPin);
				targetPin:SetSuppressed(suppressor);
			end
		end
	end

	function MapCanvasMixin:UpdatePinSuppression()
		if self:IsPinSuppressionDirty() then
			-- Every time the user zooms in or out suppression needs to be rechecked for each pin that was suppressed.
			-- So restore the state to be in the right position and visible.			
			for index, suppressor in ipairs(self:GetPinSuppressors()) do
				suppressor:ResetSuppression();
			end

			-- Now check each pin to see if it needs to be suppressed.
			self:ExecuteOnAllPins(DoPinSuppression, self);

			-- Finalize suppressors so they can do any necessary updates afterwards
			for index, suppressor in ipairs(self:GetPinSuppressors()) do
				suppressor:FinalizeSuppression();
			end

			self:MarkPinSuppressionClean();
		end
	end
end

function SquaredDistanceBetweenPoints(firstX, firstY, secondX, secondY)
	local xDiff = firstX - secondX;
	local yDiff = firstY - secondY;

	return xDiff * xDiff + yDiff * yDiff;
end

function MapCanvasMixin:CalculatePinNudging(targetPin)
	local normalizedX, normalizedY = targetPin:GetPosition();
	if not normalizedX then
		return;
	end

	targetPin:SetNudgeVector(nil, nil, nil, nil);
	if not targetPin:IgnoresNudging() and targetPin:GetNudgeTargetFactor() > 0 then

		local hasBeenNudged = false;
		local function MapCanvasNudgePin(sourcePin)
			-- This is a bit of a hack, but the underlying API doesn't allow exiting early since we want to avoid AddOns controlling
			-- the flow of execution. In this particular case, it's ok if an AddOn pin nudges a pin instead of a secure one.
			if hasBeenNudged then
				return;
			end

			if targetPin ~= sourcePin and not sourcePin:IgnoresNudging() and sourcePin:GetNudgeSourceRadius() > 0 then
				local otherNormalizedX, otherNormalizedY = sourcePin:GetPosition();
				local distanceSquared = SquaredDistanceBetweenPoints(normalizedX, normalizedY, otherNormalizedX, otherNormalizedY);

				local nudgeFactor = targetPin:GetNudgeTargetFactor() * sourcePin:GetNudgeSourceRadius();
				if distanceSquared < nudgeFactor * nudgeFactor then
					local distance = math.sqrt(distanceSquared);

					-- Avoid divide by zero: just push it right.
					if distanceSquared == 0 then
						targetPin:SetNudgeVector(sourcePin:GetNudgeSourceZoomedOutMagnitude(), sourcePin:GetNudgeSourceZoomedInMagnitude(), 1, 0);
					else
						targetPin:SetNudgeVector(sourcePin:GetNudgeSourceZoomedOutMagnitude(), sourcePin:GetNudgeSourceZoomedInMagnitude(), (normalizedX - otherNormalizedX) / distance, (normalizedY - otherNormalizedY) / distance);
					end

					targetPin:SetNudgeFactor(1 - (distance / nudgeFactor));
					hasBeenNudged = true; -- This is non-exact: each target pin only gets pushed by one source pin.
				end
			end
		end

		self:ExecuteOnAllPins(MapCanvasNudgePin);
	end
end

do
	local function MapCanvasCalculatePinNudgingCallback(targetPin, mapCanvas)
		if targetPin:GetMap() == mapCanvas then
			mapCanvas:CalculatePinNudging(targetPin);
		end
	end
	
	local function MapCanvasCalculatePinNudgingCallbackSpecificPins(pinIndex, pin, mapCanvas)
		MapCanvasCalculatePinNudgingCallback(pin, mapCanvas);
	end

	function MapCanvasMixin:UpdatePinNudging()
		if self:IsPinNudgingDirty() then
			self:ExecuteOnPinsToNudge(MapCanvasCalculatePinNudgingCallback, MapCanvasCalculatePinNudgingCallbackSpecificPins, self);
			self:MarkPinNudgingClean();
		end
	end
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

function MapCanvasMixin:ForceRefreshDetailLayers()
	self.areDetailLayersDirty = true;
	self:RefreshDetailLayers();
end

function MapCanvasMixin:RefreshDetailLayers()
	if not self.areDetailLayersDirty then return end;
	self.detailLayerPool:ReleaseAll();

	local layers = C_Map.GetMapArtLayers(self.mapID);
	for layerIndex, layerInfo in ipairs(layers) do
		local detailLayer = self.detailLayerPool:Acquire();
		detailLayer:SetAllPoints(self:GetCanvas());
		detailLayer:SetMapAndLayer(self.mapID, layerIndex, self);
		detailLayer:SetGlobalAlpha(self:GetGlobalAlpha());
		detailLayer:Show();
	end

	self:AdjustDetailLayerAlpha();

	self.areDetailLayersDirty = false;
end

function MapCanvasMixin:AreDetailLayersLoaded()
	for detailLayer in self.detailLayerPool:EnumerateActive() do
		if not detailLayer:IsFullyLoaded() then
			return false;
		end
	end
	return true;
end

function MapCanvasMixin:AdjustDetailLayerAlpha()
	self.ScrollContainer:AdjustDetailLayerAlpha(self.detailLayerPool);
end

do
	local function MapCanvasRefreshAllDataProvidersCallback(dataProvider, _included)
		dataProvider:RefreshAllData(fromOnShow);
	end

	function MapCanvasMixin:RefreshAllDataProviders(fromOnShow)
		secureexecuterange(self.dataProviders, MapCanvasRefreshAllDataProvidersCallback);
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
	self:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex);
	if not pin:IgnoresNudging() then
		if pin:GetNudgeSourceRadius() > 0 then
			-- If we nudge other things we need to recalculate all nudging.
			self:SetPinNudgingDirty();
		else
			self:AddPinToNudge(pin);
		end
	end
end

function MapCanvasMixin:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex)
	if insetIndex then
		if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
			self.mapInsetsByIndex[insetIndex]:SetLocalPinPosition(pin, normalizedX, normalizedY);
			pin:ApplyFrameLevel();
		end
	else
		pin:ClearAllPoints();
		if normalizedX and normalizedY then
			local x = normalizedX;
			local y = normalizedY;

			local nudgeVectorX, nudgeVectorY = pin:GetNudgeVector();
			if nudgeVectorX and nudgeVectorY then
				local finalNudgeFactor = pin:GetNudgeFactor() * pin:GetNudgeTargetFactor() * pin:GetNudgeZoomFactor();
				x = normalizedX + nudgeVectorX * finalNudgeFactor;
				y = normalizedY + nudgeVectorY * finalNudgeFactor;
			end

			local canvas = self:GetCanvas();
			local scale = pin:GetScale();
			pin:SetParent(canvas);
			pin:ApplyFrameLevel();
			pin:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * x) / scale, -(canvas:GetHeight() * y) / scale);
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

function MapCanvasMixin:GetCanvasContainer()
	return self.ScrollContainer;
end

do
	local function MapCanvasCallMethodOnDataProvidersCallback(dataProvider, _included, methodName, ...)
		dataProvider[methodName](dataProvider, ...);
	end

	local function MapCanvasCallMethodOnPinsCallback(pin, methodName, ...)
		pin[methodName](pin, ...);
	end

	function MapCanvasMixin:CallMethodOnDataProviders(methodName, ...)
		secureexecuterange(self.dataProviders, MapCanvasCallMethodOnDataProvidersCallback, methodName, ...);
	end	

	function MapCanvasMixin:CallMethodOnPinsAndDataProviders(methodName, ...)
		self:CallMethodOnDataProviders(methodName, ...);
		self:ExecuteOnAllPins(MapCanvasCallMethodOnPinsCallback, methodName, ...);
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

do
	local function MapCanvasOnMapChangedCallback(dataProvider, _included)
		dataProvider:OnMapChanged();
	end

	function MapCanvasMixin:OnMapChanged()
		ClearCachedActivitiesForPlayer();
		secureexecuterange(self.dataProviders, MapCanvasOnMapChangedCallback);
	end
end

function MapCanvasMixin:OnCanvasScaleChanged()
	self:AdjustDetailLayerAlpha();

	if self.mapInsetsByIndex then
		for insetIndex, mapInset in pairs(self.mapInsetsByIndex) do
			mapInset:OnCanvasScaleChanged();
		end
	end

	self:CallMethodOnPinsAndDataProviders("OnCanvasScaleChanged");
	self:SetPinSuppressionDirty();
end

function MapCanvasMixin:OnCanvasPanChanged()
	self:CallMethodOnPinsAndDataProviders("OnCanvasPanChanged");
end

function MapCanvasMixin:OnCanvasSizeChanged()
	self:CallMethodOnPinsAndDataProviders("OnCanvasSizeChanged");
end

function MapCanvasMixin:GetCanvasScale()
	return self.ScrollContainer:GetCanvasScale();
end

function MapCanvasMixin:HasZoomLevels()
	return self.ScrollContainer:HasZoomLevels();
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

function MapCanvasMixin:ResetZoom()
	self.ScrollContainer:ResetZoom();
end

function MapCanvasMixin:InstantPanAndZoom(scale, x, y, ignoreScaleRatio)
	self.ScrollContainer:InstantPanAndZoom(scale, x, y, ignoreScaleRatio);
end

function MapCanvasMixin:IsAtMaxZoom()
	return self.ScrollContainer:IsAtMaxZoom();
end

function MapCanvasMixin:IsAtMinZoom()
	return self.ScrollContainer:IsAtMinZoom();
end

function MapCanvasMixin:PanTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
end

function MapCanvasMixin:PanAndZoomTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
	self.ScrollContainer:ZoomIn();
end

function MapCanvasMixin:SetMouseWheelZoomMode(zoomMode)
	self.ScrollContainer:SetMouseWheelZoomMode(zoomMode);
end

function MapCanvasMixin:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.ScrollContainer:SetShouldZoomInOnClick(shouldZoomInOnClick);
end

function MapCanvasMixin:ShouldZoomInOnClick()
	return self.ScrollContainer:ShouldZoomInOnClick();
end

function MapCanvasMixin:SetShouldNavigateOnClick(shouldNavigateOnClick)
	self.ScrollContainer:SetShouldNavigateOnClick(shouldNavigateOnClick);
end

function MapCanvasMixin:ShouldNavigateOnClick()
	return self.ScrollContainer:ShouldNavigateOnClick();
end

-- Optional limiter related to shouldNavigateOnClick checks.
function MapCanvasMixin:SetShouldNavigateIgnoreZoneMapPositionData(ignoreZoneMapPositionData)
	self.ScrollContainer:SetShouldNavigateIgnoreZoneMapPositionData(ignoreZoneMapPositionData);
end

function MapCanvasMixin:ShouldNavigateIgnoreZoneMapPositionData()
	return self.ScrollContainer:ShouldNavigateIgnoreZoneMapPositionData();
end

function MapCanvasMixin:SetShouldPanOnClick(shouldPanOnClick)
	self.ScrollContainer:SetShouldPanOnClick(shouldPanOnClick);
end

function MapCanvasMixin:ShouldPanOnClick()
	return self.ScrollContainer:ShouldPanOnClick();
end

function MapCanvasMixin:SetShouldZoomInstantly(shouldZoomInstantly)
	self.ScrollContainer:SetShouldZoomInstantly(shouldZoomInstantly);
end

function MapCanvasMixin:ShouldZoomInstantly()
	return self.ScrollContainer:ShouldZoomInstantly();
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
	return self.ScrollContainer:IsMouseMotionFocus();
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
		if self.BorderFrame.Underlay then
			self.BorderFrame.Underlay:Show();
		end
	else
		self.BorderFrame:EnableMouse(false);
		self.BorderFrame:EnableMouseWheel(false);
		if self.BorderFrame.Underlay then
			self.BorderFrame.Underlay:Hide();
		end
	end
end

function MapCanvasMixin:GetPinFrameLevelsManager()
	return self.pinFrameLevelsManager;
end

do
	local function MapCanvasReapplyPinFrameLevelsCallback(pin, pinFrameLevelType)
		if pin:GetFrameLevelType() == pinFrameLevelType then
			pin:ApplyFrameLevel();
		end
	end

	function MapCanvasMixin:ReapplyPinFrameLevels(pinFrameLevelType)
		self:ExecuteOnAllPins(MapCanvasReapplyPinFrameLevelsCallback, pinFrameLevelType);
	end
end

function MapCanvasMixin:NavigateToParentMap()
	local mapInfo = C_Map.GetMapInfo(self:GetMapID());
	if mapInfo.parentMapID > 0 then
		self:SetMapID(mapInfo.parentMapID);
	end
end

function MapCanvasMixin:NavigateToCursor(ignoreZoneMapPositionData)
	local normalizedCursorX, normalizedCursorY = self:GetNormalizedCursorPosition();
	local mapInfo = C_Map.GetMapInfoAtPosition(self:GetMapID(), normalizedCursorX, normalizedCursorY, ignoreZoneMapPositionData);
	if mapInfo then
		self:SetMapID(mapInfo.mapID);
		return true;
	end
	return false;
end

-- Add a function that will be checked when the canvas is clicked
-- If the function returns true then handling will stop
-- A priority can optionally be specified, higher priority values will be called first
function MapCanvasMixin:AddCanvasClickHandler(handler, priority)
	self.mouseClickHandlers:AddHandler(handler, priority);
end

function MapCanvasMixin:RemoveCanvasClickHandler(handler, priority)
	self.mouseClickHandlers:RemoveHandler(handler, priority);
end

function MapCanvasMixin:ProcessCanvasClickHandlers(button, cursorX, cursorY)
	local success, stopChecking = self.mouseClickHandlers:InvokeHandlers(self, button, cursorX, cursorY);
	return success, stopChecking;
end

-- Add a function that will be checked when any pin is clicked
-- If the function returns true then handling will stop
-- A priority can optionally be specified, higher priority values will be called first
function MapCanvasMixin:AddGlobalPinMouseActionHandler(handler, priority)
	self.globalPinMouseActionHandlers:AddHandler(handler, priority);
end

function MapCanvasMixin:RemoveGlobalPinMouseActionHandler(handler, priority)
	self.globalPinMouseActionHandlers:RemoveHandler(handler, priority);
end

function MapCanvasMixin:ProcessGlobalPinMouseActionHandlers(mouseAction, button)
	local success, stopChecking = self.globalPinMouseActionHandlers:InvokeHandlers(self, mouseAction, button);
	return success, stopChecking;
end

function MapCanvasMixin:AddCursorHandler(handler, priority)
	self.cursorHandlers:AddHandler(handler, priority);
end

function MapCanvasMixin:RemoveCursorHandler(handler, priority)
	self.cursorHandlers:RemoveHandler(handler, priority);
end

function MapCanvasMixin:ProcessCursorHandlers()
	local mouseFoci = GetMouseFoci();
	local isFocusOwningMap = false;
	for _, focus in ipairs(mouseFoci) do
		if focus.owningMap == self then
			isFocusOwningMap = true;
			break;
		end
	end
	-- pins have a .owningMap, our pins should be pointing to us
	if self.ScrollContainer:IsMouseMotionFocus() or isFocusOwningMap then
		local success, cursor = self.cursorHandlers:InvokeHandlers(self);
		if success and cursor then
			self.lastCursor = cursor;
			SetCursor(cursor);
			return;
		end
	end

	if self.lastCursor then
		self.lastCursor = nil;
		ResetCursor();
	end
end

function MapCanvasMixin:GetGlobalPinScale()
	return self.globalPinScale or 1;
end

do
	local function MapCanvasSetPinScaleCallback(pin)
		pin:ApplyCurrentScale();
	end

	function MapCanvasMixin:SetGlobalPinScale(scale)
		if self.globalPinScale ~= scale then
			self.globalPinScale = scale;
			self:ExecuteOnAllPins(MapCanvasSetPinScaleCallback);
		end
	end
end

function MapCanvasMixin:GetGlobalAlpha()
	return self.globalAlpha or 1;
end

do
	local function MapCanvasOnGlobalAlphaChangedCallback(dataProvider, _included)
		dataProvider:OnGlobalAlphaChanged();
	end

	function MapCanvasMixin:SetGlobalAlpha(globalAlpha)
		if self.globalAlpha ~= globalAlpha then
			self.globalAlpha = globalAlpha;
			for detailLayer in self.detailLayerPool:EnumerateActive() do
				detailLayer:SetGlobalAlpha(globalAlpha);
			end

			secureexecuterange(self.dataProviders, MapCanvasOnGlobalAlphaChangedCallback);
		end
	end
end

function MapCanvasMixin:SetMaskTexture(maskTexture)
	if self.maskTexture then
		for texture, value in pairs(self.maskableTextures) do
			self.maskableTextures[texture] = false;
			texture:RemoveMaskTexture(self.maskTexture);
		end
	end
	self.maskTexture = maskTexture;
	if self.maskableTextures then
		self:RefreshMaskableTextures();
	else
		self.maskableTextures = { };
	end
end

function MapCanvasMixin:GetMaskTexture()
	return self.maskTexture;
end

function MapCanvasMixin:SetUseMaskTexture(useMaskTexture)
	if not self:GetMaskTexture() then
		error("Must have a mask texture");
	end
	self.useMaskTexture = useMaskTexture;
	self:RefreshMaskableTextures();
end

function MapCanvasMixin:GetUseMaskTexture()
	return not not self.useMaskTexture;
end

function MapCanvasMixin:AddMaskableTexture(texture)
	local maskTexture = self:GetMaskTexture();
	if not maskTexture then
		return;
	end
	if self.maskableTextures[texture] ~= nil then
		return;
	end

	local useMaskTexture = self:GetUseMaskTexture();
	self.maskableTextures[texture] = useMaskTexture;
	if useMaskTexture then
		texture:AddMaskTexture(maskTexture);
	end
end

function MapCanvasMixin:RefreshMaskableTextures()
	local useMaskTexture = self:GetUseMaskTexture();
	local maskTexture = self:GetMaskTexture();
	for texture, value in pairs(self.maskableTextures) do
		if value ~= useMaskTexture then
			self.maskableTextures[texture] = useMaskTexture;
			if useMaskTexture then
				texture:AddMaskTexture(maskTexture);
			else
				texture:RemoveMaskTexture(maskTexture);
			end
		end
	end
end

function MapCanvasMixin:HandleUIAction(actionType)
	if actionType == Enum.UIActionType.UpdateMapSystem then
		self:RefreshAllDataProviders();
	end
end

function MapCanvasMixin:SetAllPinsByTemplateGlowing(pinTemplate, glowing, glowLoopCount)
	local pinPool = self.pinPools[pinTemplate];
	if pinPool then
		for pin in pinPool:EnumerateActive() do
			if glowing then
				if pin.StartGlow then
					pin:StartGlow(glowLoopCount);
				end
			else
				if pin.StopGlow then
					pin:StopGlow();
				end
			end
		end

		self.ScrollContainer:MarkCanvasDirty();
	end
end
