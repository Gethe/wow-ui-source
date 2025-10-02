local rawget = rawget;
local SafePack = SafePack;
local SafeUnpack = SafeUnpack;
local securecallfunction = securecallfunction;
local tinsert = table.insert;
local tremove = table.remove;
local tsort = table.sort;

MapCanvasSecureUtil = {};

local function PrioritySorter(left, right)
	return left.priority > right.priority;
end

local function EnumerateTaintedArray(tbl)
	local function NextElement(tbl_, i)
		i = i + 1;

		local v = securecallfunction(rawget, tbl_, i);

		if v ~= nil then
			return i, v;
		end
	end

	return NextElement, tbl, 0;
end

local function IsEquivalentHandler(handlerInfo, handler, priority)
	return handlerInfo.handler == handler and (not priority or handlerInfo.priority == priority);
end

local function InvokeTaintedHandler(handlerInfo, ...)
	return handlerInfo.handler(...);
end

function MapCanvasSecureUtil.CreateHandlerRegistry()
	local handlers = {};
	local registry = {};

	function registry:AddHandler(handler, priority)
		tinsert(handlers, { handler = handler, priority = priority or 0 });
		securecallfunction(tsort, handlers, PrioritySorter);
	end

	function registry:RemoveHandler(handler, priority)
		local index = self:FindHandler(handler, priority);

		if index then
			securecallfunction(tremove, handlers, index);
		end
	end

	function registry:FindHandler(handler, priority)
		for i, handlerInfo in EnumerateTaintedArray(handlers) do
			local isMatch = securecallfunction(IsEquivalentHandler, handlerInfo, handler, priority);

			if isMatch then
				return i;
			end
		end

		return nil;
	end

	function registry:InvokeHandlers(...)
		for i, handlerInfo in EnumerateTaintedArray(handlers) do
			local results = SafePack(securecallfunction(InvokeTaintedHandler, handlerInfo, ...));
			local stopChecking = results[1];

			if stopChecking then
				return true, SafeUnpack(results);
			end
		end
		return false;
	end

	return registry;
end
