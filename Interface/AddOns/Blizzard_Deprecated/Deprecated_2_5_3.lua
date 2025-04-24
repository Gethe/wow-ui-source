
-- These are functions are deprecated, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- Unit Sex enum conversions
do
	Enum.Unitsex = Enum.UnitSex;
end
