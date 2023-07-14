-- These are functions that were deprecated in 10.1.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	TooltipUtil.SurfaceArgs = nop;

	GetAddOnMetadata = C_AddOns.GetAddOnMetadata;
end