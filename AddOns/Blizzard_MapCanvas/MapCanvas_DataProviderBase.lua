-- Provides a basic interface for something that manages the adding, updating, and removing of data like icons, blobs or text to the map canvas
MapCanvasDataProviderMixin = {};

function MapCanvasDataProviderMixin:OnAdded(owningMap)
	-- Optionally override in your mixin, called when this provider is added to a map canvas
	self.owningMap = owningMap;
end

function MapCanvasDataProviderMixin:OnRemoved(owningMap)
	-- Optionally override in your mixin, called when this provider is removed from a map canvas
	assert(owningMap == self.owningMap);
	self.owningMap = nil;

	if self.registeredEvents then
		for event in pairs(self.registeredEvents) do
			owningMap:UnregisterEvent(event);
		end
		self.registeredEvents = nil;
	end
end

function MapCanvasDataProviderMixin:RemoveAllData()
	-- Override in your mixin, this method should remove everything that has been added to the map
end

function MapCanvasDataProviderMixin:RefreshAllData(fromOnShow)
	-- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
end

function MapCanvasDataProviderMixin:OnShow()
	-- Override in your mixin, called when the map canvas is shown
end

function MapCanvasDataProviderMixin:OnHide()
	-- Override in your mixin, called when the map canvas is closed
end

function MapCanvasDataProviderMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function MapCanvasDataProviderMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function MapCanvasDataProviderMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function MapCanvasDataProviderMixin:OnCanvasScaleChanged()
	-- Optionally override in your mixin, called when the canvas scale changes
end

function MapCanvasDataProviderMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function MapCanvasDataProviderMixin:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function MapCanvasDataProviderMixin:GetMap()
	return self.owningMap;
end

function MapCanvasDataProviderMixin:OnMapChanged()
	--  Optionally override in your mixin, called when map ID changes
end

function MapCanvasDataProviderMixin:RegisterEvent(event)
	-- Since data providers aren't frames this provides a similar method of event registration, but always calls self:OnEvent(event, ...)
	if not self.registeredEvents then
		self.registeredEvents = {}
	end
	if not self.registeredEvents[event] then
		self.registeredEvents[event] = true;
		self:GetMap():AddDataProviderEvent(event);
	end
end

function MapCanvasDataProviderMixin:UnregisterEvent(event)
	if self.registeredEvents and self.registeredEvents[event] then
		self.registeredEvents[event] = nil;
		self:GetMap():RemoveDataProviderEvent(event);
	end
end

function MapCanvasDataProviderMixin:SignalEvent(event, ...)
	if self.registeredEvents and self.registeredEvents[event] then
		self:OnEvent(event, ...);
	end
end

-- Provides a basic interface for something that is visible on the map canvas, like icons, blobs or text
MapCanvasPinMixin = {};

function MapCanvasPinMixin:OnLoad()
	-- Override in your mixin, called when this pin is created
end

function MapCanvasPinMixin:OnAcquired()
	-- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
end

function MapCanvasPinMixin:OnReleased()
	-- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
end

function MapCanvasPinMixin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
end

function MapCanvasPinMixin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
end

function MapCanvasPinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

function MapCanvasPinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function MapCanvasPinMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function MapCanvasPinMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function MapCanvasPinMixin:SetNudgeTargetFactor(newFactor)
	self.nudgeTargetFactor = newFactor;
end

function MapCanvasPinMixin:GetNudgeTargetFactor()
	return self.nudgeTargetFactor or 0;
end

function MapCanvasPinMixin:SetNudgeSourceFactor(newFactor)
	self.nudgeSourceFactor = newFactor;
end

function MapCanvasPinMixin:GetNudgeSourceFactor()
	return self.nudgeSourceFactor or 0;
end

function MapCanvasPinMixin:SetNudgeZoomedInFactor(newFactor)
	self.zoomedInNudge = newFactor;
end

function MapCanvasPinMixin:GetZoomedInNudgeFactor()
	return self.zoomedInNudge or 0;
end

function MapCanvasPinMixin:SetNudgeZoomedOutFactor(newFactor)
	self.zoomedOutNudge = newFactor;
end

function MapCanvasPinMixin:GetZoomedOutNudgeFactor()
	return self.zoomedOutNudge or 0;
end

function MapCanvasPinMixin:IgnoresNudging()
	return self.insetIndex or (self:GetNudgeSourceFactor() == 0 and self:GetNudgeTargetFactor() == 0);
end

function MapCanvasPinMixin:GetMap()
	return self.owningMap;
end

function MapCanvasPinMixin:GetNudgeVector()
	return self.nudgeVectorX, self.nudgeVectorY;
end

-- x and y should be a normalized vector.
function MapCanvasPinMixin:SetNudgeVector(x, y)
	self.nudgeVectorX = x;
	self.nudgeVectorY = y;
	self:ApplyCurrentPosition();
end

function MapCanvasPinMixin:GetNudgeFactor()
	return self.nudgeFactor or 0;
end

function MapCanvasPinMixin:SetNudgeFactor(nudgeFactor)
	self.nudgeFactor = nudgeFactor;
	self:ApplyCurrentPosition();
end

function MapCanvasPinMixin:GetNudgeZoomFactor()
	return Lerp(self:GetZoomedOutNudgeFactor(), self:GetZoomedInNudgeFactor(), self:GetMap():GetCanvasZoomPercent());
end

function MapCanvasPinMixin:SetPosition(normalizedX, normalizedY, insetIndex)
	self.normalizedX = normalizedX;
	self.normalizedY = normalizedY;
	self.insetIndex = insetIndex;
	self:GetMap():SetPinPosition(self, normalizedX, normalizedY, insetIndex);
end

-- Returns the global position if not part of an inset, otherwise returns local coordinates of that inset
function MapCanvasPinMixin:GetPosition()
	return self.normalizedX, self.normalizedY, self.insetIndex;
end

-- Returns the global position, even if part of an inset
function MapCanvasPinMixin:GetGlobalPosition()
	if self.insetIndex then
		return self:GetMap():GetGlobalPosition(self.normalizedX, self.normalizedY, self.insetIndex);
	end
	return self.normalizedX, self.normalizedY;
end

-- Adjusts the pin's scale so that at max zoom it is this scale
function MapCanvasPinMixin:SetMaxZoomScale(scale)
	local scaleForMaxZoom = self:GetMap():GetScaleForMaxZoom();
	self:SetScale(scale / scaleForMaxZoom);
end

function MapCanvasPinMixin:PanTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetMap():PanTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function MapCanvasPinMixin:PanAndZoomTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetMap():PanAndZoomTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function MapCanvasPinMixin:OnCanvasScaleChanged()
	self:ApplyCurrentScale();
	self:ApplyCurrentAlpha();
end

function MapCanvasPinMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function MapCanvasPinMixin:SetScalingLimits(scaleFactor, startScale, endScale)
	self.scaleFactor = scaleFactor;
	self.startScale = startScale and math.max(startScale, .01) or nil;
	self.endScale = endScale and math.max(endScale, .01) or nil;
end

AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_SCALE_STYLE_WITH_TERRAIN = 3;

function MapCanvasPinMixin:SetScaleStyle(scaleStyle)
	if scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetScalingLimits(1.5, 0.0, 3.0);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetScalingLimits(1.5, 3.0, 0.0);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_WITH_TERRAIN then
		self:SetScalingLimits(nil, nil, nil);
		self:SetScale(1.0);
	end
end

function MapCanvasPinMixin:SetAlphaLimits(alphaFactor, startAlpha, endAlpha)
	self.alphaFactor = alphaFactor;
	self.startAlpha = startAlpha;
	self.endAlpha = endAlpha;
end

AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE = 3;

function MapCanvasPinMixin:SetAlphaStyle(alphaStyle)
	if alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetAlphaLimits(2.0, 0.0, 1.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetAlphaLimits(2.0, 1.0, 0.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE then
		self:SetAlphaLimits(nil, nil, nil);
	end
end

function MapCanvasPinMixin:ApplyCurrentPosition()
	self:GetMap():ApplyPinPosition(self, self.normalizedX, self.normalizedY, self.insetIndex);
end

function MapCanvasPinMixin:ApplyCurrentScale()
	if self.startScale and self.startScale and self.endScale then
		self:SetScale(Lerp(self.startScale, self.endScale, Saturate(self.scaleFactor * self:GetMap():GetCanvasZoomPercent())));
		self:ApplyCurrentPosition();
	end
end

function MapCanvasPinMixin:ApplyCurrentAlpha()
	if self.alphaFactor and self.startAlpha and self.endAlpha then
		local alpha = Lerp(self.startAlpha, self.endAlpha, Saturate(self.alphaFactor * self:GetMap():GetCanvasZoomPercent()));
		self:SetAlpha(alpha);
		self:SetShown(alpha > 0.05);
	end
end