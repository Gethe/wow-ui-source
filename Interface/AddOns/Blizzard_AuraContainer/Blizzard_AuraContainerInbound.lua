local _addonName, addonTable = ...;

AuraContainerInbound = {};

function AuraContainerInbound.GetDefaultAuraDurationFormatter()
	return addonTable.DefaultAuraDurationFormatter;
end

AuraContainerInbound.SetTooltipNineSlice = addonTable.InboundSetTooltipNineSlice;
AuraContainerInbound.SetTooltipTextureSlice = addonTable.InboundSetTooltipTextureSlice;
AuraContainerInbound.SetTooltipBackdrop = addonTable.InboundSetTooltipBackdrop;

function AuraContainerInbound.ResetTooltipStyle()
	AuraContainerInbound.SetTooltipNineSlice({ layoutName = "TooltipDefaultLayout", centerColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR });
end
