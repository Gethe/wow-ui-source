-- These are functions that were deprecated in 10.1.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

do
	TooltipUtil.SurfaceArgs = nop;

	GetAddOnMetadata = C_AddOns.GetAddOnMetadata;
end