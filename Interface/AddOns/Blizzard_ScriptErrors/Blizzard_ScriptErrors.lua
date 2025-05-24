if not IsInGlobalEnvironment() then
	return;
end

local function GetErrorData()
	-- Example of how debug stack level is calculated
	-- Current stack: [1, 2, 3, 4, 5] (current function is at 1, total current height is 5)
	-- Stack at time of error: [1, 2] (these are currently now index 4 and 5, but at the time of error the stack height is 2)
	-- To calcuate the level to debug (4): curentStackHeight - (errorStackHeight - 1) = 5 - (2 - 1) = 4
	local currentStackHeight = GetCallstackHeight();
	local errorCallStackHeight = GetErrorCallstackHeight();
	local errorStackOffset = errorCallStackHeight and (errorCallStackHeight - 1);
	local debugStackLevel = currentStackHeight - (errorStackOffset or 0);
	local skipFunctionsAndUserdata = true;

	local stack = debugstack(debugStackLevel);
	local locals = debuglocals(debugStackLevel, skipFunctionsAndUserdata);
	locals = string.gsub(locals, "|([kK])", "%1");
	
	return stack, locals;
end

local errorHandlers = {};

function AddLuaErrorHandler(handler)
	assert(issecure());
	table.insert(errorHandlers, handler);
end

local function HandleLuaError(errorMessage)
	local stack, locals = GetErrorData();
	local formattedMessage = string.format("Lua Error: %s\n%s", errorMessage, stack);
	addframetext(formattedMessage);
	
	-- Eventually remove this from Lua. Stack information should be obtainable from
	-- the native error handler.
	C_Log.LogErrorMessage(formattedMessage);

	for index, handler in ipairs(errorHandlers) do
		pcall(handler, errorMessage, stack, locals);
	end

	if ProcessExceptionClient then
		ProcessExceptionClient(string.format("%sLocals: %s", errorMessage or "", locals or ""), errorMessage);
	end
end

seterrorhandler(HandleLuaError);