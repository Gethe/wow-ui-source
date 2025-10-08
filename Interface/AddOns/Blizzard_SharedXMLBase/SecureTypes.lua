local assert = assert;
local ContainsIf = ContainsIf;
local FindInTableIf = FindInTableIf;
local ipairs = ipairs;
local ipairs_reverse = ipairs_reverse;
local issecretvalue = issecretvalue;
local Mixin = Mixin;
local next = next;
local pairs = pairs;
local rawget = rawget;
local securecallfunction = securecallfunction;
local secureexecuterange = secureexecuterange;
local setmetatable = setmetatable;
local tContains = tContains;
local tCount = table.count;
local tDeleteItem = tDeleteItem;
local tinsert = table.insert;
local tremove = table.remove;
local wipe = wipe;

-- Secure types are expected to be used by Blizzard code to prevent taint propagation
-- while accessing values, particularly in cases where container types are used that can have
-- a mixture of secure and insecurely sourced values. See Pools.lua for use cases.
SecureTypes = {};

do
	local SecureMap = {};

	function SecureMap:GetValue(key)
		return securecallfunction(rawget, self.tbl, key);
	end

	function SecureMap:SetValue(key, value)
		assert(not issecretvalue(key), "attempted to store a secret key in a SecureMap");
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureMap");
		self.tbl[key] = value;
	end

	function SecureMap:ClearValue(key)
		self.tbl[key] = nil;
	end

	function SecureMap:HasKey(key)
		return self:GetValue(key) ~= nil;
	end

	function SecureMap:GetNext(key)
		return securecallfunction(next, self.tbl, key);
	end

	function SecureMap:GetSize()
		local count = securecallfunction(tCount, self.tbl);
		return count;
	end

	function SecureMap:IsEmpty()
		return self:GetNext() == nil;
	end

	function SecureMap:Wipe()
		securecallfunction(wipe, self.tbl);
	end

	function SecureMap:Enumerate()
		local iterator, tbl, index = next, self.tbl, nil;
		local function Iterator(_, key)
			return securecallfunction(iterator, tbl, key);
		end

		return Iterator, nil, index;
	end

	function SecureMap:ExecuteRange(func, ...)
		secureexecuterange(self.tbl, func, ...);
	end

	function SecureMap:ExecuteTable(func)
		securecallfunction(func, self.tbl);
	end

	SecureMap.__index = function(t, k)
		local sv = SecureMap[k];
		if sv then
			return sv;
		end

		return SecureMap.GetValue(t, k);
	end

	SecureMap.__newindex = function(t, k, v)
		t:SetValue(k, v);
	end

	function SecureTypes.CreateSecureMap(mixin)
		local tbl = { tbl = {}};
		setmetatable(tbl, SecureMap);

		if mixin then
			Mixin(tbl, mixin);
		end

		return tbl;
	end
end

do
	local SecureArray = {};

	function SecureArray:GetValue(index)
		return securecallfunction(rawget, self.tbl, index);
	end

	function SecureArray:Insert(value, index)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureArray");
		assert(not issecretvalue(index), "attempted to store a secret index in a SecureArray");

		if index == nil then
			tinsert(self.tbl, value);
		else
			-- Element move will taint execution.
			securecallfunction(tinsert, self.tbl, index, value);
		end
	end

	function SecureArray:UniqueInsert(value, index)
		if not self:Contains(value) then
			self:Insert(value, index);
		end
	end

	function SecureArray:Remove(index)
		-- Element move will taint execution.
		return securecallfunction(tremove, self.tbl, index);
	end

	function SecureArray:RemoveValue(value)
		-- Element move will taint execution.
		return securecallfunction(tDeleteItem, self.tbl, value);
	end

	function SecureArray:FindInTableIf(predicate)
		return securecallfunction(FindInTableIf, self.tbl, predicate);
	end

	function SecureArray:ContainsIf(predicate)
		return securecallfunction(ContainsIf, self.tbl, predicate);
	end

	function SecureArray:Contains(value)
		return securecallfunction(tContains, self.tbl, value);
	end

	function SecureArray:GetSize()
		return #self.tbl;
	end

	function SecureArray:IsEmpty()
		return self:GetSize() == 0;
	end

	function SecureArray:Wipe()
		securecallfunction(wipe, self.tbl);
	end

	function SecureArray:HasValues()
		return self:GetSize() > 0;
	end

	function SecureArray:Enumerate()
		local iterator, tbl, index = next, self.tbl, nil;
		local function Iterator(_, index)
			return securecallfunction(iterator, tbl, index);
		end

		return Iterator, nil, index;
	end

	function SecureArray:EnumerateReverse()
		local iterator, tbl, index = securecallfunction(ipairs_reverse, self.tbl);
		local function Iterator(_, index)
			return securecallfunction(iterator, tbl, index);
		end

		return Iterator, nil, index;
	end

	function SecureArray:EnumerateIterator(iter)
		local iterator, tbl, index = securecallfunction(iter, self.tbl);
		local function Iterator(_, index)
			return securecallfunction(iterator, tbl, index);
		end

		return Iterator, nil, index;
	end

	function SecureArray:ExecuteRange(func, ...)
		secureexecuterange(self.tbl, func, ...);
	end

	function SecureArray:ExecuteTable(func)
		securecallfunction(func, self.tbl);
	end

	SecureArray.__index = function(t, k)
		local v = SecureArray[k];
		if v then
			return v;
		end

		return SecureArray.GetValue(t, k);
	end

	SecureArray.__newindex = function(t, k, v)
		t:Insert(v, k);
	end

	function SecureTypes.CreateSecureArray()
		local tbl = { tbl = {}};
		setmetatable(tbl, SecureArray);
		return tbl;
	end
end

function SecureTypes.CreateSecureStack()
	--[[
	The storage tbl is private. This is necessary to prevent any external code from
	accessing the container directly.
	--]]
	local tbl = {};

	local SecureStack = {};

	function SecureStack:Push(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureStack");
		tinsert(tbl, value);
	end

	function SecureStack:Pop()
		return securecallfunction(tremove, tbl);
	end

	function SecureStack:Contains(value)
		return securecallfunction(tContains, tbl, value);
	end

	return SecureStack;
end

do
	local SecureValue = {};
	SecureValue.__index = SecureValue;

	local function GetValueSecure(self)
		return self.value;
	end

	function SecureValue:GetValue()
		return securecallfunction(GetValueSecure, self);
	end

	function SecureValue:SetValue(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureValue");
		self.value = value;
	end

	function SecureTypes.CreateSecureValue(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureValue");
		local tbl = {value = value};
		setmetatable(tbl, SecureValue);
		return tbl;
	end
end

do
	local SecureNumber = {};
	SecureNumber.__index = SecureNumber;

	local function GetValueSecure(self)
		return self.value;
	end

	function SecureNumber:GetValue()
		return securecallfunction(GetValueSecure, self);
	end

	function SecureNumber:SetValue(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureNumber");
		self.value = value;
	end

	function SecureNumber:Add(value)
		self:SetValue(self:GetValue() + value);
	end

	function SecureNumber:Subtract(value)
		self:SetValue(self:GetValue() - value);
	end

	function SecureNumber:Increment()
		self:SetValue(self:GetValue() + 1);
	end

	function SecureNumber:Decrement()
		self:SetValue(self:GetValue() - 1);
	end

	function SecureTypes.CreateSecureNumber(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureNumber");
		local tbl = {value = value or 0};
		setmetatable(tbl, SecureNumber);
		return tbl;
	end
end

do
	local SecureBoolean = {};
	SecureBoolean.__index = SecureBoolean;

	local function GetValueSecure(self)
		return self.value;
	end

	function SecureBoolean:GetValue()
		return securecallfunction(GetValueSecure, self);
	end

	function SecureBoolean:SetValue(value)
		assert(not issecretvalue(value), "attempted to store a secret value in a SecureBoolean");
		self.value = value;
	end

	function SecureBoolean:ToggleValue()
		self:SetValue(not self:GetValue());
	end

	function SecureBoolean:IsTrue()
		return self:GetValue() == true;
	end

	function SecureTypes.CreateSecureBoolean(v)
		assert(not issecretvalue(v), "attempted to store a secret value in a SecureBoolean");
		local tbl = {value = (v == true)};
		setmetatable(tbl, SecureBoolean);
		return tbl;
	end
end

do
	local SecureFunction = {};
	SecureFunction.__index = SecureFunction;

	function SecureFunction:IsSet()
		return self:GetWrapperSecure() ~= nil;
	end

	function SecureFunction:SetFunction(func)
		assert(not issecretvalue(func), "attempted to store a secret value in a SecureFunction");

		if func then
			self.wrapper = function(...)
				return func(...);
			end
		else
			self.wrapper = nil;
		end
	end

	local function GetWrapperSecure(self)
		return self.wrapper;
	end

	function SecureFunction:GetWrapperSecure()
		return securecallfunction(GetWrapperSecure, self);
	end

	function SecureFunction:CallFunction(...)
		return securecallfunction(self:GetWrapperSecure(), ...);
	end

	function SecureFunction:CallFunctionIfSet(...)
		if not self:IsSet() then
			return false;
		end

		return securecallfunction(self:GetWrapperSecure(), ...);
	end

	function SecureTypes.CreateSecureFunction()
		local tbl = {};
		setmetatable(tbl, SecureFunction);
		return tbl;
	end
end
