local _addonName, addonTable = ...;

function addonTable.CreateSecureAuraInstanceMap()
	-- Aura instance IDs are secret, but cooldown viewer needs to use them as
	-- map keys. Store entries through a proxy that unwraps keys before touching
	-- the secured backing table, preventing secret frame handles from spreading.
	--
	-- If this goes wrong, expect a few thousand errors in the SetScript calls
	-- around UpdateOnUpdateScript.

	local auraInstanceMap = {};
	local auraInstanceMapProxy = {};
	local auraInstanceMapMetatable = {};

	function auraInstanceMapMetatable:__index(key)
		return auraInstanceMap[secretunwrap(key)];
	end

	function auraInstanceMapMetatable:__newindex(key, value)
		auraInstanceMap[secretunwrap(key)] = value;
	end

	setmetatable(auraInstanceMapProxy, auraInstanceMapMetatable);

	-- The storage table should disallow secret keys more as an assertion that
	-- we're doing things right in our metatable. Both tables disallow tainted
	-- access to ensure nothing can access our declassified instance IDs. Note
	-- that technically we would only need to guard the proxy here, but we set
	-- the flag on both tables just to be safe.

	settablesecurity(auraInstanceMap, Enum.TableSecurityOption.DisallowSecretKeys);
	settablesecurity(auraInstanceMap, Enum.TableSecurityOption.DisallowTaintedAccess);
	settablesecurity(auraInstanceMapProxy, Enum.TableSecurityOption.DisallowTaintedAccess);

	return auraInstanceMapProxy;
end
