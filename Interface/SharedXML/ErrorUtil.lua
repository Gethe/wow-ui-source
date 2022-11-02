function CallErrorHandler(...)
	return geterrorhandler()(...);
end

function assertsafe(cond, msg)
	if not cond then
		if ProcessExceptionClient then
			ProcessExceptionClient(msg);
		end
	end
end
