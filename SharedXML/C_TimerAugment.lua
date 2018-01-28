local TickerPrototype = {};
local TickerMetatable = {
	__index = TickerPrototype,
	__metatable = true,	--Probably not needed, but if I don't put this here someone is going to mess with this metatable and end up tainting everything...
};

--Creates and starts a ticker that calls callback every duration seconds for N iterations.
--If iterations is nil, the ticker will loop until cancelled.
--
--If callback throws a Lua error, the ticker will stop firing.
function C_Timer.NewTicker(duration, callback, iterations)
	local ticker = setmetatable({}, TickerMetatable);
	ticker._remainingIterations = iterations;
	ticker._callback = function()
		if ( not ticker._cancelled ) then
			callback(ticker);

			--Make sure we weren't cancelled during the callback
			if ( not ticker._cancelled ) then
				if ( ticker._remainingIterations ) then
					ticker._remainingIterations = ticker._remainingIterations - 1;
				end
				if ( not ticker._remainingIterations or ticker._remainingIterations > 0 ) then
					C_Timer.After(duration, ticker._callback);
				end
			end
		end
	end;

	C_Timer.After(duration, ticker._callback);
	return ticker;
end

--Creates and starts a cancellable timer that calls callback after duration seconds.
--Note that C_Timer.NewTimer is significantly more expensive than C_Timer.After and should
--only be used if you actually need any of its additional functionality.
--
--While timers are currently just tickers with an iteration count of 1, this is likely
--to change in the future and shouldn't be relied on.
function C_Timer.NewTimer(duration, callback)
	return C_Timer.NewTicker(duration, callback, 1);
end

--Cancels a ticker or timer. May be safely called within the ticker's callback in which
--case the ticker simply won't be started again.
--Cancel is guaranteed to be idempotent.
function TickerPrototype:Cancel()
	self._cancelled = true;
end

function TickerPrototype:IsCancelled()
	return self._cancelled;
end
