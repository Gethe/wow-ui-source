------------------------------------------------------------------------------
-- Dump.lua
--
-- Contributed by Iriel, Esamynn and Kirov from DevTools v1.11
-- /dump Implementation
--
-- Globals: DevTools, SLASH_DEVTOOLSDUMP1, DevTools_Dump, DevTools_RunDump
-- Globals: DEVTOOLS_MAX_ENTRY_CUTOFF, DEVTOOLS_LONG_STRING_CUTOFF
-- Globals: DEVTOOLS_DEPTH_CUTOFF, DEVTOOLS_INDENT
-- Globals: DEVTOOLS_USE_TABLE_CACHE, DEVTOOLS_USE_FUNCTION_CACHE
-- Globals: DEVTOOLS_USE_USERDATA_CACHE
---------------------------------------------------------------------------

local forceinsecure = forceinsecure;

local DT = {};

DEVTOOLS_MAX_ENTRY_CUTOFF = 30;    -- Maximum table entries shown
DEVTOOLS_LONG_STRING_CUTOFF = 200; -- Maximum string size shown
DEVTOOLS_DEPTH_CUTOFF = 10;        -- Maximum table depth
DEVTOOLS_USE_TABLE_CACHE = true;   -- Look up table names
DEVTOOLS_USE_FUNCTION_CACHE = true;-- Look up function names
DEVTOOLS_USE_USERDATA_CACHE = true;-- Look up userdata names
DEVTOOLS_USE_THREAD_CACHE = true;  -- Look up coroutine names
DEVTOOLS_INDENT='  ';              -- Indentation string

local DEVTOOLS_TYPE_COLOR="|cff88ff88";
local DEVTOOLS_TABLEREF_COLOR="|cffffcc00";
local DEVTOOLS_CUTOFF_COLOR="|cffff0000";
local DEVTOOLS_TABLEKEY_COLOR="|cff88ccff";
local DEVTOOLS_SECRET_COLOR="|cff88ff88";

local FORMATS = {};
-- prefix type suffix
FORMATS["opaqueTypeVal"] = "%s" .. DEVTOOLS_TYPE_COLOR .. "<%s>|r%s";
-- prefix type name suffix
FORMATS["opaqueTypeValName"] = "%s" .. DEVTOOLS_TYPE_COLOR .. "<%s %s>|r%s";
-- prefix type suffix
FORMATS["opaqueTypeValSecret"] = "%s" .. DEVTOOLS_TYPE_COLOR .. "<secret %s>|r%s";
-- type
FORMATS["opaqueTypeKey"] = "<%s>";
-- type name
FORMATS["opaqueTypeKeyName"] = "<%s %s>";
-- type
FORMATS["opaqueTypeKeySecret"] = "<secret %s>";
-- value
FORMATS["bracketTableKey"] = "[%s]";
-- prefix value
FORMATS["tableKeyAssignPrefix"] = DEVTOOLS_TABLEKEY_COLOR .. "%s%s|r=";
-- prefix cutoff
FORMATS["tableEntriesSkipped"] = "%s" .. DEVTOOLS_CUTOFF_COLOR .. "<skipped %s>|r";
-- prefix suffix
FORMATS["tableTooDeep"] = "%s" .. DEVTOOLS_CUTOFF_COLOR .. "<table (too deep)>|r%s";
-- prefix value suffix
FORMATS["simpleValue"] = "%s%s%s";
-- prefix value suffix
FORMATS["simpleValueSecret"] = "%s" .. DEVTOOLS_SECRET_COLOR .. "<secret>|r %s%s";
-- prefix tablename suffix
FORMATS["tableReference"] = "%s" .. DEVTOOLS_TABLEREF_COLOR .. "%s|r%s";

-- Grab a copy various oft-used functions
local rawget = rawget;
local type = type;
local table_insert = table.insert;
local secureexecuterange = secureexecuterange;

local messageHandlers = {};

local function CallCallback(index, callback, msg)
	callback(msg);
end

local function WriteMessage(msg)
	secureexecuterange(messageHandlers, CallCallback, msg);
end

local function DevTools_Write(self, msg)
	WriteMessage(msg);
end

function DevTools_AddMessageHandler(callback)
	table_insert(messageHandlers, callback);
end

local function IsLuaIdentifier(str)
	return string.find(str, "^[a-zA-Z_][a-zA-Z0-9_]*$") ~= nil;
end

local function IsSimpleType(valueType)
	return valueType == "nil" or valueType == "number" or valueType == "boolean" or valueType == "string";
end

local function ShouldTruncateString(str)
	return DEVTOOLS_LONG_STRING_CUTOFF > 0 and #str > DEVTOOLS_LONG_STRING_CUTOFF;
end

local function prepSimple(val, context)
	local valType = type(val);
	if (valType == "nil")  then
		return "nil";
	elseif (valType == "number") then
		return tostring(val);
	elseif (valType == "boolean") then
		return tostring(val);
	elseif (valType == "string") then
		if (canaccessvalue(val) and ShouldTruncateString(val)) then
			local more = #val - DEVTOOLS_LONG_STRING_CUTOFF;
			val = string.sub(val, 1, DEVTOOLS_LONG_STRING_CUTOFF);
			return C_StringUtil.EscapeQuotedCodes(string.format("%q...+%s",val,more));
		else
			return C_StringUtil.EscapeQuotedCodes(string.format("%q",val));
		end
	elseif (not canaccessvalue(val)) then
		return string.format(FORMATS.opaqueTypeKeySecret, valType);
	elseif (valType == "function") then
		local functionName = context:GetFunctionName(val);
		if (functionName) then
			return string.format(FORMATS.opaqueTypeKeyName, valType, functionName);
		else
			return string.format(FORMATS.opaqueTypeKey, valType);
		end
	elseif (valType == "userdata") then
		local userdataName = context:GetUserdataName(val);
		if (userdataName) then
			return string.format(FORMATS.opaqueTypeKeyName, valType, userdataName);
		else
			return string.format(FORMATS.opaqueTypeKey, valType);
		end
	elseif (valType == "thread") then
		local threadName = context:GetThreadName(val);
		if (threadName) then
			return string.format(FORMATS.opaqueTypeKeyName, valType, threadName);
		else
			return string.format(FORMATS.opaqueTypeKey, valType);
		end
	elseif (valType == 'table') then
		local tableName = context:GetTableName(val);
		if (tableName) then
			return string.format(FORMATS.opaqueTypeKeyName, valType, tableName);
		else
			return string.format(FORMATS.opaqueTypeKey, valType);
		end
	end
	assertsafe(false, "Bad type '" .. valType .. "' to prepSimple");
	return string.format(FORMATS.opaqueTypeKey, valType);
end

local function prepSimpleKey(val, context)
	local valType = type(val);
	if (valType == "string") then
		if (canaccessvalue(val) and IsLuaIdentifier(val) and not ShouldTruncateString(val)) then
			return val;
		end
	end
	return string.format(FORMATS.bracketTableKey, prepSimple(val, context));
end

local function DevTools_InitFunctionCache(context)
	local ret = {};

	for _,k in ipairs(DT.functionSymbols) do
		local v = getglobal(k);
		if (type(v) == 'function') then
			ret[v] = '[' .. k .. ']';
		end
	end

	for k,v in pairs(getfenv(0)) do
		if (type(v) == 'function') then
			if (not ret[v]) then
				ret[v] = '[' .. k .. ']';
			end
		end
	end

	return ret;
end

local function DevTools_InitUserdataCache(context)
	local ret = {};

	for _,k in ipairs(DT.userdataSymbols) do
		local v = getglobal(k);
		if (type(v) == 'table') then
			local u = rawget(v,0);
			if (type(u) == 'userdata') then
				ret[u] = k .. '[0]';
			end
		end
	end

	for k,v in pairs(getfenv(0)) do
		if (type(v) == 'table') then
			local u = rawget(v, 0);
			if (type(u) == 'userdata') then
				if (not ret[u]) then
					ret[u] = k .. '[0]';
				end
			end
		end
	end

	return ret;
end

local function DevTools_Cache_Nil(self, value, newName)
	return nil;
end

local function DevTools_Cache_Function(self, value, newName)
	if (not self.functionCache) then
		self.functionCache = DevTools_InitFunctionCache(self);
	end
	local name = self.functionCache[value];
	if ((not name) and newName) then
		self.functionCache[value] = newName;
	end
	return name;
end

local function DevTools_Cache_Userdata(self, value, newName)
	if (not self.userdataCache) then
		self.userdataCache = DevTools_InitUserdataCache(self);
	end
	local name = self.userdataCache[value];
	if ((not name) and newName) then
		self.userdataCache[value] = newName;
	end
	return name;
end

local function DevTools_Cache_Thread(self, value, newName)
	if (not self.threadCache) then
		self.threadCache = {};
	end
	local name = self.threadCache[value];
	if ((not name) and newName) then
		self.threadCache[value] = newName;
	end
	return name;
end

local function DevTools_Cache_Table(self, value, newName)
	if (not self.tableCache) then
		self.tableCache = {};
	end
	local name = self.tableCache[value];
	if ((not name) and newName) then
		self.tableCache[value] = newName;
	end
	return name;
end

local DevTools_DumpValue;

local function DevTools_DumpTableContents(val, prefix, firstPrefix, context)
	local showCount = 0;
	local oldDepth = context.depth;
	local oldKey = context.key;

	-- Use this to set the cache name
	context:GetTableName(val, oldKey or 'value');

	local iter = pairs(val);
	local nextK, nextV = iter(val, nil);

	while (nextK) do
		local k,v = nextK, nextV;
		nextK, nextV = iter(val, k);

		showCount = showCount + 1;
		if ((showCount <= DEVTOOLS_MAX_ENTRY_CUTOFF) or
			(DEVTOOLS_MAX_ENTRY_CUTOFF <= 0)) then
			local prepKey = prepSimpleKey(k, context);
			if (oldKey == nil) then
				context.key = prepKey;
			elseif (string.sub(prepKey, 1, 1) == "[") then
				context.key = oldKey .. prepKey
			else
				context.key = oldKey .. "." .. prepKey
			end
			context.depth = oldDepth + 1;

			local rp = string.format(FORMATS.tableKeyAssignPrefix, firstPrefix,
									 prepKey);
			firstPrefix = prefix;
			DevTools_DumpValue(v, prefix, rp,
							   (nextK and ",") or '',
							   context);
		end
	end
	local cutoff = showCount - DEVTOOLS_MAX_ENTRY_CUTOFF;
	if ((cutoff > 0) and (DEVTOOLS_MAX_ENTRY_CUTOFF > 0)) then
		context:Write(string.format(FORMATS.tableEntriesSkipped,firstPrefix,
									cutoff));
	end
	context.key = oldKey;
	context.depth = oldDepth;
	return (showCount > 0)
end

-- Return the specified value
function DevTools_DumpValue(val, prefix, firstPrefix, suffix, context)
	local valType = type(val);

	if (IsSimpleType(valType)) then
		local format = issecretvalue(val) and FORMATS.simpleValueSecret or FORMATS.simpleValue;
		context:Write(string.format(format, firstPrefix,prepSimple(val, context), suffix));
		return;
	elseif (not canaccessvalue(val) or (valType == "table" and not canaccesstable(val))) then
		-- Opaque secret values will error if passed to the GetName functions,
		-- so handle them specially first.
		--
		-- For tables that are internally secret and inacessible, also consider
		-- them opaque. Ideally we'd dump their contents but the write callbacks
		-- being one-call-per-value could be used as a channel to work out the
		-- length of such tables.

		context:Write(string.format(FORMATS.opaqueTypeValSecret,
										firstPrefix, valType, suffix));
		return;
	elseif (valType == "userdata") then
		local userdataName = context:GetUserdataName(val, 'value');
		if (userdataName) then
			context:Write(string.format(FORMATS.opaqueTypeValName,
										firstPrefix, valType, userdataName, suffix));
		else
			context:Write(string.format(FORMATS.opaqueTypeVal,
										firstPrefix, valType, suffix));
		end
		return;
	elseif (valType == "function") then
		local functionName = context:GetFunctionName(val, 'value');
		if (functionName) then
			context:Write(string.format(FORMATS.opaqueTypeValName,
										firstPrefix, valType, functionName, suffix));
		else
			context:Write(string.format(FORMATS.opaqueTypeVal,
										firstPrefix, valType, suffix));
		end
		return;
	elseif (valType == "thread") then
		local threadName = context:GetThreadName(val, 'value');
		if (threadName) then
			context:Write(string.format(FORMATS.opaqueTypeValName,
										firstPrefix, valType, threadName, suffix));
		else
			context:Write(string.format(FORMATS.opaqueTypeVal,
										firstPrefix, valType, suffix));
		end
		return;
	elseif (valType ~= "table") then
		assertsafe(false, "Bad type '" .. valType .. "' to DevTools_DumpValue");
		context:Write(string.format(FORMATS.opaqueTypeVal, firstPrefix, valType, suffix));
		return;
	end

	local cacheName = context:GetTableName(val);
	if (cacheName) then
		context:Write(string.format(FORMATS.tableReference,
									firstPrefix, cacheName, suffix));
		return;
	end

	if ((context.depth >= DEVTOOLS_DEPTH_CUTOFF) and
		(DEVTOOLS_DEPTH_CUTOFF > 0)) then
		context:Write(string.format(FORMATS.tableTooDeep,
									firstPrefix, suffix));
		return;
	end

	firstPrefix = firstPrefix .. "{";
	local oldPrefix = prefix;
	prefix = prefix .. DEVTOOLS_INDENT;

	context:Write(firstPrefix);
	firstPrefix = prefix;
	local anyContents = DevTools_DumpTableContents(val, prefix, firstPrefix, context);
	context:Write(oldPrefix .. "}" .. suffix);
end

local function Pick_Cache_Function(func, setting)
	if (setting) then
		return func;
	else
		return DevTools_Cache_Nil;
	end
end

function DevTools_RunDump(value, context)
	local prefix = "";
	local firstPrefix = prefix;

	local valType = type(value);
	if (valType == 'table' and canaccesstable(value)) then
		local any =
			DevTools_DumpTableContents(value, prefix, firstPrefix, context);
		if (context.Result) then
			return context:Result();
		end
		if (not any) then
			context:Write("empty result");
		end
		return;
	end

	DevTools_DumpValue(value, '', '', '', context);
	if (context.Result) then
		return context:Result();
	end
end

-- Dump the specified list of value
function DevTools_Dump(value, startKey)
	local context = {
		depth = 0,
		key = startKey,
	};

	context.GetTableName = Pick_Cache_Function(DevTools_Cache_Table, DEVTOOLS_USE_TABLE_CACHE);
	context.GetFunctionName = Pick_Cache_Function(DevTools_Cache_Function, DEVTOOLS_USE_FUNCTION_CACHE);
	context.GetUserdataName = Pick_Cache_Function(DevTools_Cache_Userdata, DEVTOOLS_USE_USERDATA_CACHE);
	context.GetThreadName = Pick_Cache_Function(DevTools_Cache_Thread, DEVTOOLS_USE_THREAD_CACHE)
	context.Write = DevTools_Write;

	DevTools_RunDump(value, context);
end

function DevTools_DumpCommand(msg, editBox)
	forceinsecure();
	if (IsLuaIdentifier(msg)) then
		WriteMessage("Dump: " .. msg);
		local val = _G[msg];
		local tmp = {};
		if (type(val) == "nil") then
			local key = string.format(FORMATS.tableKeyAssignPrefix,
									  '', prepSimpleKey(msg, {}));
			WriteMessage(key .. "nil,");
		else
			tmp[msg] = val;
		end
		DevTools_Dump(tmp);
		return;
	end

	WriteMessage("Dump: value=" .. msg);
	local func,err = loadstring("return " .. msg);
	if (not func) then
		WriteMessage("Dump: ERROR: " .. err);
	else
		DevTools_Dump({ func() }, "value");
	end
end

DT.functionSymbols = {};
DT.userdataSymbols = {};

local funcSyms = DT.functionSymbols;
local userSyms = DT.userdataSymbols;

for k,v in pairs(getfenv(0)) do
	if (type(v) == 'function') then
		table.insert(funcSyms, k);
	elseif (type(v) == 'table') then
		if (type(rawget(v,0)) == 'userdata') then
			table.insert(userSyms, k);
		end
	end
end

