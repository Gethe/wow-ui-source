TimerUtil = {};

-- Creates a timed signal map that associates generated keys with callbacks.
-- Registered callbacks are retained for the lifetime of the map and invoked
-- whenever their corresponding keys signal.
function TimerUtil.CreateTimedSignalCallbackMap()
	local signalKeyFactory = CreateCounter();
	local signalKeyCallbacks = {};

	local function DispatchSignal(key)
		local callback = signalKeyCallbacks[key];
		callback();
	end

	local signalMap = C_Timer.NewTimedSignalMap(DispatchSignal);

	function signalMap:RegisterCallback(callback)
		assert(callback ~= nil, "argument 'callback' must not be nil");

		local key = signalKeyFactory();
		signalKeyCallbacks[key] = callback;
		return key;
	end

	return signalMap;
end
