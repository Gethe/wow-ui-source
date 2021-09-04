
FlightMap_VignetteDataProviderMixin = CreateFromMixins(VignetteDataProviderMixin);

function FlightMap_VignetteDataProviderMixin:GetPinTemplate()
	return "FlightMap_VignettePinTemplate";
end

-- Only show vignettes on the flight map if they are flagged as zoneInfiniteAOI
function FlightMap_VignetteDataProviderMixin:ShouldShowVignette(vignetteInfo)
	return vignetteInfo and vignetteInfo.onWorldMap and vignetteInfo.zoneInfiniteAOI;
end

FlightMap_VignettePinMixin = CreateFromMixins(VignettePinMixin);

function FlightMap_VignettePinMixin:OnLoad()
	VignettePinMixin.OnLoad(self);

	self:SetAlphaLimits(2.0, 0.0, 1.0);

	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end

