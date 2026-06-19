-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function getglobal(var)
	return _G[var];
end

local forceinsecure = forceinsecure;
function setglobal(var, val)
	if forceinsecure then
		forceinsecure();
	end

	_G[var] = val;
end

