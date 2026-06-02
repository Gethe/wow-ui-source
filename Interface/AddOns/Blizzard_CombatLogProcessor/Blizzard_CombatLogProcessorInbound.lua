local _ENV = GetCurrentEnvironment();
SwapToGlobalEnvironment();

CombatLogInbound = {};

function CombatLogInbound.GenerateMessage(filterSettings, ...)
	-- Parameters should match regular combat event payloads.
	local text, r, g, b = _ENV.CombatLogProcessor:GenerateMessage(filterSettings, ...);
	return text, r, g, b;
end
