-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function CastingInfo()
	return UnitCastingInfo("player");
end

function ChannelInfo()
	return UnitChannelInfo("player");
end
