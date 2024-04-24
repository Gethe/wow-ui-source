function CallErrorHandler(...)
	return geterrorhandler()(...);
end

function assertsafe(cond, msgStringOrFunction, ...)
	if not cond then
		local error = msgStringOrFunction;
		if type(msgStringOrFunction) == 'string' and select('#', ...) > 0 then
			error = msgStringOrFunction:format(...);
		elseif type(msgStringOrFunction) == 'function' then
			error = msgStringOrFunction(...);
		end

		if HandleLuaError then
			HandleLuaError(error);
		elseif ProcessExceptionClient then
			ProcessExceptionClient(error);
		end
	end
end
