Event = {};

-- Callback helpers for global event callback registration that do not require a frame or owner at all
-- To unregister the event callback, call handle:Unregister() on the returned table
function Event.RegisterCallback(event, cb)
	local cbContainer = C_FunctionContainers.CreateCallback(function(_nilOwner, ...) cb(...) end);

	local handle =
	{
		Unregister = function()
			UnregisterEventCallback(event, cbContainer);
		end,
	};
	RegisterEventCallback(event, cbContainer);

	return handle;
end

function Event.RegisterUnitCallback(event, cb, unit)
	local cbContainer = C_FunctionContainers.CreateCallback(function(_nilOwner, ...) cb(...) end);

	local handle =
	{
		Unregister = function()
			UnregisterUnitEventCallback(event, cbContainer, unit);
		end,
	};
	RegisterUnitEventCallback(event, cbContainer, unit);

	return handle;
end
