
-- These are functions are deprecated, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	GetAddOnMetadata = C_AddOns.GetAddOnMetadata;
end
