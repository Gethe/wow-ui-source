-- Provides a basic interface for something that manages the adding, updating, and removing of data like icons, blobs or text to the adventure map
AdventureMapDataProviderMixin = {};

function AdventureMapDataProviderMixin:OnAdded(adventureMap)
	-- Optionally override in your mixin, called when this provider is added to an adventure map
	self.adventureMap = adventureMap;
end

function AdventureMapDataProviderMixin:OnRemoved(adventureMap)
	-- Optionally override in your mixin, called when this provider is removed from an adventure map
	assert(adventureMap == self.adventureMap);
	self.adventureMap = nil;

	if self.registeredEvents then
		for event in pairs(self.registeredEvents) do
			adventureMap:UnregisterEvent(event);
		end
		self.registeredEvents = nil;
	end
end

function AdventureMapDataProviderMixin:RemoveAllData()
	-- Override in your mixin, this method should remove everything that has been added to the map
end

function AdventureMapDataProviderMixin:RefreshAllData(fromOnShow)
	-- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
end

function AdventureMapDataProviderMixin:OnShow()
	-- Override in your mixin, called when the adventure map is shown
end

function AdventureMapDataProviderMixin:OnHide()
	-- Override in your mixin, called when the adventure map is closed
end

function AdventureMapDataProviderMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function AdventureMapDataProviderMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function AdventureMapDataProviderMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function AdventureMapDataProviderMixin:OnCanvasScaleChanged()
	-- Optionally override in your mixin, called when the canvas scale changes
end

function AdventureMapDataProviderMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function AdventureMapDataProviderMixin:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function AdventureMapDataProviderMixin:GetAdventureMap()
	return self.adventureMap;
end

function AdventureMapDataProviderMixin:RegisterEvent(event)
	-- Since data providers aren't frames this provides a similar method of event registration, but always calls self:OnEvent(event, ...)
	if not self.registeredEvents then
		self.registeredEvents = {}
	end
	if not self.registeredEvents[event] then
		self.registeredEvents[event] = true;
		self:GetAdventureMap():AddDataProviderEvent(event);
	end
end

function AdventureMapDataProviderMixin:UnregisterEvent(event)
	if self.registeredEvents and self.registeredEvents[event] then
		self.registeredEvents[event] = nil;
		self:GetAdventureMap():RemoveDataProviderEvent(event);
	end
end

function AdventureMapDataProviderMixin:SignalEvent(event, ...)
	if self.registeredEvents and self.registeredEvents[event] then
		self:OnEvent(event, ...);
	end
end

-- Provides a basic interface for something that is visible on the adventure map, like icons, blobs or text
AdventureMapPinMixin = {};

function AdventureMapPinMixin:OnLoad()
	-- Override in your mixin, called when this pin is created
end

function AdventureMapPinMixin:OnAcquired()
	-- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
end

function AdventureMapPinMixin:OnReleased()
	-- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
end

function AdventureMapPinMixin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
end

function AdventureMapPinMixin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
end

function AdventureMapPinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

function AdventureMapPinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function AdventureMapPinMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function AdventureMapPinMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function AdventureMapPinMixin:GetAdventureMap()
	return self.adventureMap;
end

function AdventureMapPinMixin:SetPosition(normalizedX, normalizedY, insetIndex)
	self.normalizedX = normalizedX;
	self.normalizedY = normalizedY;
	self.insetIndex = insetIndex;
	self:ApplyCurrentPosition();
end

-- Returns the global position if not part of an inset, otherwise returns local coordinates of that inset
function AdventureMapPinMixin:GetPosition()
	return self.normalizedX, self.normalizedY, self.insetIndex;
end

-- Returns the global position, even if part of an inset
function AdventureMapPinMixin:GetGlobalPosition()
	if self.insetIndex then
		return self:GetAdventureMap():GetGlobalPosition(self.normalizedX, self.normalizedY, self.insetIndex);
	end
	return self.normalizedX, self.normalizedY;
end

-- Adjusts the pin's scale so that at max zoom it is this scale
function AdventureMapPinMixin:SetMaxZoomScale(scale)
	local scaleForMaxZoom = self:GetAdventureMap():GetScaleForMaxZoom();
	self:SetScale(scale / scaleForMaxZoom);
end

function AdventureMapPinMixin:PanTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetAdventureMap():PanTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function AdventureMapPinMixin:PanAndZoomTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetAdventureMap():PanAndZoomTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function AdventureMapPinMixin:OnCanvasScaleChanged()
	self:ApplyCurrentScale();
	self:ApplyCurrentAlpha();
end

function AdventureMapPinMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function AdventureMapPinMixin:SetScalingLimits(scaleFactor, startScale, endScale)
	self.scaleFactor = scaleFactor;
	self.startScale = startScale and math.max(startScale, .01) or nil;
	self.endScale = endScale and math.max(endScale, .01) or nil;
end

AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_SCALE_STYLE_WITH_TERRAIN = 3;

function AdventureMapPinMixin:SetScaleStyle(scaleStyle)
	if scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetScalingLimits(1.5, 0.0, 3.0);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetScalingLimits(1.5, 3.0, 0.0);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_WITH_TERRAIN then
		self:SetScalingLimits(nil, nil, nil);
		self:SetScale(1.0);
	end
end

function AdventureMapPinMixin:SetAlphaLimits(alphaFactor, startAlpha, endAlpha)
	self.alphaFactor = alphaFactor;
	self.startAlpha = startAlpha;
	self.endAlpha = endAlpha;
end

AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE = 3;

function AdventureMapPinMixin:SetAlphaStyle(alphaStyle)
	if alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetAlphaLimits(2.0, 0.0, 1.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetAlphaLimits(2.0, 1.0, 0.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE then
		self:SetAlphaLimits(nil, nil, nil);
	end
end

function AdventureMapPinMixin:ApplyCurrentPosition()
	self:GetAdventureMap():SetPinPosition(self, self.normalizedX, self.normalizedY, self.insetIndex);
end

function AdventureMapPinMixin:ApplyCurrentScale()
	if self.startScale and self.startScale and self.endScale then
		self:SetScale(Lerp(self.startScale, self.endScale, Saturate(self.scaleFactor * self:GetAdventureMap():GetCanvasZoomPercent())));
		self:ApplyCurrentPosition();
	end
end

function AdventureMapPinMixin:ApplyCurrentAlpha()
	if self.alphaFactor and self.startAlpha and self.endAlpha then
		local alpha = Lerp(self.startAlpha, self.endAlpha, Saturate(self.alphaFactor * self:GetAdventureMap():GetCanvasZoomPercent()));
		self:SetAlpha(alpha);
		self:SetShown(alpha > 0.05);
	end
end