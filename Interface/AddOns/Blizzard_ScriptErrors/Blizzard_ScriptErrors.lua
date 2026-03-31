local errorHandlers = {};

ScriptErrorsMixin = {};

function ScriptErrorsMixin:Init()
	self.unhandledErrors = {};
	self.isErrorHandlingDeferred = false;
end

function ScriptErrorsMixin:AddUnhandledError(errorMessage, stack, locals)
	table.insert(self.unhandledErrors, { errorMessage = errorMessage, stack = stack, locals = locals });

	if not self.isErrorHandlingDeferred then
		self.isErrorHandlingDeferred = true;

		local processUnhandledErrors = nil;
		processUnhandledErrors = function()
			if #errorHandlers > 0 then
				self.isErrorHandlingDeferred = false;

				for _i, handler in ipairs(errorHandlers) do
					for _j, error in pairs(self.unhandledErrors) do
						pcall(handler, error.errorMessage, error.stack, error.locals);
					end
				end

				self.unhandledErrors = {};
			else
				-- Try again. This else is not expected to be entered unless error
				-- handler registration became deferred. If that ever happens it is
				-- important we don't drop the errors on the floor.
				RunNextFrame(processUnhandledErrors);
			end
		end
		RunNextFrame(processUnhandledErrors);
	end
end

ScriptErrors = CreateFromMixins(ScriptErrorsMixin);
ScriptErrors:Init();

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

	if #errorHandlers > 0 then
		for index, handler in ipairs(errorHandlers) do
			pcall(handler, errorMessage, stack, locals);
		end
	else
		ScriptErrors:AddUnhandledError(errorMessage, stack, locals);
	end

	if ProcessExceptionClient then
		-- Skip HandleLuaError and the C++ error handler
		local framesToSkip = 2;
		ProcessExceptionClient(string.format("%s\nLocals: %s", errorMessage or "", locals or ""), errorMessage, framesToSkip);
	end
end

seterrorhandler(HandleLuaError);
