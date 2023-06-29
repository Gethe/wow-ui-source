function CallErrorHandler(...)
	return geterrorhandler()(...);
end

function assertsafe(cond, msg, ...)
	if not cond then
		if type(msg) == 'string' and select('#', ...) > 0 then
			msg = msg:format(...);
		end

		if HandleLuaError then
			HandleLuaError(msg);
		elseif ProcessExceptionClient then
			ProcessExceptionClient(msg);
		end
	end
end
