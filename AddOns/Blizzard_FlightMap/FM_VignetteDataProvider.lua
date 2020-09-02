
FlightMap_VignetteDataProviderMixin = CreateFromMixins(VignetteDataProviderMixin);

function FlightMap_VignetteDataProviderMixin:GetPinTemplate()
	return "FlightMap_VignettePinTemplate";
end

FlightMap_VignettePinMixin = CreateFromMixins(VignettePinMixin);

function FlightMap_VignettePinMixin:OnLoad()
	VignettePinMixin.OnLoad(self);

	self:SetAlphaLimits(2.0, 0.0, 1.0);

	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end

