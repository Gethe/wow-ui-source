function CallErrorHandler(...)
	SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
	local result = geterrorhandler()(...);
	SetErrorCallstackHeight(nil);
	return result;
end

function assertsafe(cond, msgStringOrFunction, ...)
	if not cond then
		local error = msgStringOrFunction or "non-fatal assertion failed";
		if type(msgStringOrFunction) == 'string' and select('#', ...) > 0 then
			error = msgStringOrFunction:format(...);
		elseif type(msgStringOrFunction) == 'function' then
			error = msgStringOrFunction(...);
		end

		SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
		if HandleLuaError then
			HandleLuaError(error);
		elseif ProcessExceptionClient then
			ProcessExceptionClient(error);
		end
		SetErrorCallstackHeight(nil);
	end
end
