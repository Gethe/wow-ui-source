-- /////////////////////////////////////////////////////////////
-- // Dispatcher 1.0 by Josh Leyshock of Blizzard Entertainment //
-- /////////////////////////////////////////////////////////////

-- [[ Versioning ]]
if ( not Dispatcher or (not DISPATCHER_VERSION or DISPATCHER_VERSION < 1.0) ) then
DISPATCHER_VERSION = 1.0;


-- ------------------------------------------------------------------------------------------------------------
-- Global
-- ------------------------------------------------------------------------------------------------------------
Dispatcher =
{
	EventFrame		= nil;
	DebugFrame		= nil;

	-- Unique identifiers for registration
	NextEventID		= 1;
	NextFunctionID	= 1;
	NextScriptID	= 1;

	-- Containers for all the callbacks
	Events			= {};
	Functions		= {};
	Scripts			= {};
};

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:Initialize()
	self.EventFrame = CreateFrame("frame", "DispatcherFrame");
	self.EventFrame:SetScript("OnEvent", function(obj, ...) self:OnEvent(...) end);
	self.EventFrame:Show();

	self.DebugFrame = CreateFrame("frame", "DispatcherDebugFrame");
	self.DebugFrame.Events = {};
	self.DebugFrame:SetScript("OnEvent", function(obj, ...) self:OnDebugEvent(...) end);
	self.DebugFrame:Show();

	SLASH_EVENT1 = "/event";
	SlashCmdList.EVENT = function(msg) self:OnSlash(msg) end;
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:OnSlash(text)
	if (text == "all") then
		self:DebugAllEvents();
	elseif (text == "none") then
		self:ClearDebugEvents();
	else
		self:ToggleDebugEvent(text);
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Returns the first key that of the given table that has a matching value
-- if the value is a function, it calls that function, passing in the value for compairson, the function should return true or false
function Dispatcher:FindKeyByValue(t, valueOrFunction)
	for k, v in pairs(t) do
		if (type(valueOrFunction) == "function") then
			if (valueOrFunction(v)) then
				return k;
			end
		else
			if (v == value) then
				return k;
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
local mtCallbackData = {
	__tostring = function(self) return string.format("%s - %s", type(self.Callback), tostring(self.OneTime or false)); end;
	__index = {
		Invoke = function(self, ...)
			-- Function type callbacks are invoked directly
			if (type(self.Callback) == "function") then
				self.Callback(...);
			-- If the callback is a table, invoke the function on that table matching the Event, Function, or Script name
			elseif (type(self.Callback) == "table") then
				local dispatcherCallback = self.Callback[self.EventFunctionOrScript];
				if (type(dispatcherCallback) == "function") then
					dispatcherCallback(self.Callback, ...);
				end
			end
		end
	}
}

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:_CreateCallbackData(eventFunctionOrScript, callback, oneTime)
	return setmetatable({
		EventFunctionOrScript	= eventFunctionOrScript;
		Callback				= callback;
		OneTime					= oneTime;
	}, mtCallbackData);
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterAll(obj)
	Dispatcher:UnregisterAllEvents(obj);
	Dispatcher:UnregisterAllFunctions(obj);
	Dispatcher:UnregisterAllScripts(obj);
end

-- ------------------------------------------------------------------------------------------------------------
-- Events
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:RegisterEvent(event, callback, oneTime)
	-- print("RegisterEvent", event, callback)

	-- Unregister any existing event with that owner (each owner can only have each event registered once)
	if (type(callback) == "table") then
		self:UnregisterEvent(event, callback);
	end

	-- Create an empty table if this is the first handler for this event
	if (self.Events[event] == nil) then
		self.Events[event] = {};

		-- handle OnUpdate
		if (event == "OnUpdate") then
			self.EventFrame:SetScript("OnUpdate", function(frame, elapsed) self:OnEvent("OnUpdate", elapsed) end);
		else
			self.EventFrame:RegisterEvent(event);
		end
	end

	local id = self.NextEventID;
	self.Events[event][id] = self:_CreateCallbackData(event, callback, oneTime);

	self.NextEventID = self.NextEventID + 1;

	return id;
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterEvent(event, ownerOrID)
	-- print("UnregisterEvent", event, ownerOrID)

	if ((event ~= nil) and (self.Events[event] ~= nil) and (ownerOrID ~= nil)) then

		-- First, Remove the callback
		local callbackTable = self.Events[event];
		local id = ownerOrID;

		if (type(ownerOrID) == "table") then
			id = self:FindKeyByValue(callbackTable, function(callbackData) return callbackData.Callback == ownerOrID; end);
		end

		if (id) then
			callbackTable[id] = nil;
		end

		-- Second, Remove the event if no callbacks remain
		local first = next(self.Events[event]);
		if (first == nil) then
			self.Events[event] = nil;

			-- Handle OnUpdate
			if (event == "OnUpdate") then
				self.EventFrame:SetScript("OnUpdate", nil);
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterAllEvents(owner)
	for event, callbacks in pairs(self.Events) do
		for id, callbackData in pairs(callbacks) do
			local callback = callbackData.Callback;
			if ((type(callback) == "table") and (callback == owner)) then
				self:UnregisterEvent(event, owner);
				break;
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:OnEvent(event, ...)
	if (self.Events[event] ~= nil) then
		for id, CallbackData in pairs(self.Events[event]) do
			CallbackData:Invoke(...);

			if (CallbackData.OneTime) then
				self:UnregisterEvent(event, id);
			end
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------
-- Functions
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
-- @usage Dispatcher:RegisterFunction([functionOwner, ]functionName, callback, oneTime)
function Dispatcher:RegisterFunction(functionOwner, functionName, callback, oneTime)

	-- funcOwner is optional.  if it's not supplied, all the arguments are effectively slid one to the left
	if (type(functionOwner) ~= "table") then
		functionOwner, functionName, callback, oneTime = nil, functionOwner, functionName, callback;
	end

	-- First, secure hook the func to our internal callback handler.
	-- There should only ever be one secure hook per object/function for all callbacks
	if (functionOwner) then
		if (not self.Functions[functionOwner]) then
			self.Functions[functionOwner] = {};
		end

		if (not self.Functions[functionOwner][functionName]) then
			self.Functions[functionOwner][functionName] = {};
			hooksecurefunc(functionOwner, functionName, function(...) self:OnSecureFunc(functionOwner, functionName, ...) end);
		end
	else
		if (not self.Functions.Global) then
			self.Functions.Global = {};
		end

		if (not self.Functions.Global[functionName]) then
			self.Functions.Global[functionName] = {};
			hooksecurefunc(functionName, function(...) self:OnSecureFunc(nil, functionName, ...) end);
		end
	end

	-- Second, store off the callback for callback forwarding and unregistering
	local callback = self:_CreateCallbackData(functionName, callback, oneTime);
	local id = self.NextFunctionID;

	if (functionOwner) then
		self.Functions[functionOwner][functionName][id] = callback;
	else
		self.Functions.Global[functionName][id] = callback;
	end

	self.NextFunctionID = self.NextFunctionID + 1;
	return id;
end

-- ------------------------------------------------------------------------------------------------------------
-- @usage Dispatcher:UnregisterFunction([functionOwner, ]functionName, ownerOrID)
function Dispatcher:UnregisterFunction(functionOwner, functionName, ownerOrID)
	-- funcOwner is optional.  if it's not supplied, all the arguments are effectively slid one to the left
	if (type(functionOwner) ~= "table") then
		functionOwner, functionName, ownerOrID = nil, functionOwner, functionName;
	end

	-- First, find the tbale that contains the callback.  This will either be .Global[functionName] or .[functionOwner][functionName]
	local callbackTable;
	if (functionOwner) then
		if (self.Functions[functionOwner]) then
			callbackTable = self.Functions[functionOwner][functionName];
		end
	else
		callbackTable = self.Functions.Global[functionName];
	end

	-- Second, find the key of the callback
	-- this will be ownerOrID if a number was passed or if a table was passed, that table will match the callbackData.Callback
	local id = ownerOrID;
	if (type(ownerOrID) == "table") then
		id = self:FindKeyByValue(callbackTable, function(callbackData) return callbackData.Callback == ownerOrID end);
	end

	if (id) then
		callbackTable[id] = nil;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterAllFunctions(owner)
	for funcOwner, funcOwnerFunctions in pairs(self.Functions) do
		for funcName, callbacks in pairs(funcOwnerFunctions) do
			for id, callbackData in pairs(callbacks) do
				if (callbackData.Callback == owner) then
					self.Functions[funcOwner][funcName][id] = nil;
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:OnSecureFunc(functionOwner, functionName, ...)
	-- print("OnSecureFunc, owner:", functionOwner, "name", functionName)

	local callbackTable;
	if (functionOwner) then
		callbackTable = self.Functions[functionOwner][functionName];
	else
		callbackTable = self.Functions.Global[functionName];
	end

	for id, callbackData in pairs(callbackTable) do
		callbackData:Invoke(...);

		-- remove the callback if it was a one-time callback
		if (callbackData.OneTime) then
			callbackTable[id] = nil;
		end

		-- unlike events, securehooks can not be removed, so there is no need to clear out the callbackTable if there are no mroe callbacks
		-- in fact, the table should not be cleared out because it's existance means a new hook won't be created the next time a hook is requested for that function
	end
end




-- ------------------------------------------------------------------------------------------------------------
-- Scripts
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:RegisterScript(frame, script, callback, oneTime)
	if ((not frame) or (not type(frame) == "table") or (frame.IsObjectType and (not frame:IsObjectType("frame")))) then
		print("Dispatcher:RegisterScript - ERROR - object passed to frame is not a UI Frame");
		return;
	end

	if (not frame:HasScript(script)) then
		print("Dispatcher:RegisterScript - ERROR - frame does not have the script [" .. script .. "]");
		return;
	end

	-- First. see if this is the first time this frame has had any script hook for it.  If so, create a new table
	if (not self.Scripts[frame]) then
		self.Scripts[frame] = {};
	end

	-- Second, See if the frame already has the script hooked, if not, hook it
	if (not self.Scripts[frame][script]) then
		self.Scripts[frame][script] = {};
		frame:HookScript(script, function(...) self:OnScript(frame, script, ...) end);
	end

	-- Finally, store off the callback
	local callbackData = self:_CreateCallbackData(script, callback, oneTime);
	local id = self.NextScriptID;

	self.Scripts[frame][script][id] = callbackData;
	self.NextScriptID = self.NextScriptID + 1;

	return id;
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterScript(frame, script, ownerOrID)
	local callbackTable = self.Scripts[frame][script];

	local id = ownerOrID;
	if (type(ownerOrID) == "table") then
		id = self:FindKeyByValue(callbackTable, function(callbackData) return callbackData.Callback == ownerOrID end);
	end

	if (id) then
		self.Scripts[frame][script][id] = nil;
	end

end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterAllScripts(owner)
	for frame, scripts in pairs(self.Scripts) do
		for script, callbacks in pairs(scripts) do
			for id, callbackData in pairs(callbacks) do
				if (callbackData.Callback == owner) then
					self.Scripts[frame][script][id] = nil;
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:OnScript(frame, script, ...)
	-- print("Dispatcher - OnScript", frame, script, ...)

	if (self.Scripts[frame]) then
		if (self.Scripts[frame][script]) then
			for id, callbackData in pairs(self.Scripts[frame][script]) do
				callbackData:Invoke(...);

				if (callbackData.OneTime) then
					self.Scripts[frame][script][id] = nil;
				end
			end
		end
	end
end



-- ------------------------------------------------------------------------------------------------------------
-- DEBUG
-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:RegisterDebugEvent(event)
	if (not self.DebugFrame.Events[event]) then
		self.DebugFrame:RegisterEvent(event);
		self.DebugFrame.Events[event] = true;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:UnregisterDebugEvent(event)
	if (self.DebugFrame.Events[event]) then
		self.DebugFrame:UnregisterEvent(event);
		self.DebugFrame.Events[event] = nil;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:ToggleDebugEvent(event, absolute)
	local register;

	if (absolute == true) then
 		register = true;
	elseif (absolute == false) then -- nil is toggle
		register = false;
	else
		register = not self.DebugFrame.Events[event];
	end

	if (register) then
		self:RegisterDebugEvent(event);
	else
		self:UnregisterDebugEvent(event);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:DebugAllEvents()
	self.DebugFrame:RegisterAllEvents();
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:ClearDebugEvents()
	self.DebugFrame:UnregisterAllEvents();
	for k, v in pairs(self.DebugFrame.Events) do
		self.DebugFrame.Events[k] = nil;
	end
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:OnDebugEvent(event, ...)
	print("Dispatcher Debug - ", event);
end

-- ------------------------------------------------------------------------------------------------------------
function Dispatcher:DumpEvents()
	for event, eventCallbacks in pairs(self.Events) do
		print(string.format("[%s] = {", event))

		for id, callback in pairs(eventCallbacks) do
			local callbackString = tostring(callback);
			if ((type(callback) == "table") and (callback.ToString ~= nil)) then
				callbackString = callback:ToString();
			end

			print(string.format("   [%s] = %s", id, callbackString));
		end

		print("},");
	end
end



end --[[ End Versioning ]]

Dispatcher:Initialize();