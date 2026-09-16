local RegisterOutboundNamespace;

do
	local _ENV = GetCurrentEnvironment();
	SwapToGlobalEnvironment();

	function RegisterOutboundNamespace(namespaceName, namespaceTable)
		for key, func in pairs(namespaceTable) do
			namespaceTable[key] = function(...) return securecallfunction(func, ...); end;
		end

		_ENV[namespaceName] = namespaceTable;
	end
end

local CombatLogOutbound = {};

function CombatLogOutbound.SignalRefilterStarted()
	EventRegistry:TriggerEvent("OnCombatLogRefilterStarted");
end

function CombatLogOutbound.SignalRefilterUpdate(progress)
	EventRegistry:TriggerEvent("OnCombatLogRefilterUpdate", progress);
end

function CombatLogOutbound.SignalRefilterFinished()
	EventRegistry:TriggerEvent("OnCombatLogRefilterFinished");
end

RegisterOutboundNamespace("CombatLogOutbound", CombatLogOutbound);
