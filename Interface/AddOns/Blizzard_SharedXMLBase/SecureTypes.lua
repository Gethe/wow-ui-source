local securecallfunction = securecallfunction;
local secureexecuterange = secureexecuterange;
local setmetatable = setmetatable;
local pairs = pairs;
local ipairs = ipairs;
local next = next;
local ipairs_reverse = ipairs_reverse;
local rawget = rawget;
local tDeleteItem = tDeleteItem;
local tinsert = table.insert;
local tremove = table.remove;
local tContains = tContains;
local FindInTableIf = FindInTableIf;
local ContainsIf = ContainsIf;
local CountTable = CountTable;
local Mixin = Mixin;
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
		return securecallfunction(CountTable, self.tbl);
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
		tinsert(tbl, value);
	end
	
	function SecureStack:Pop()
		return securecallfunction(tremove, tbl);
	end

	return SecureStack;
end

do
	local SecureValue = {};
	SecureValue.__index = SecureValue;

	function SecureValue:GetValue()
		return securecallfunction(function()
			return self.value;
		end);
	end
	
	function SecureValue:SetValue(value)
		self.value = value;
	end
	
	function SecureTypes.CreateSecureValue(value)
		local tbl = {value = value};
		setmetatable(tbl, SecureValue);
		return tbl;
	end
end

do
	local SecureNumber = {};
	SecureNumber.__index = SecureNumber;

	function SecureNumber:GetValue()
		return securecallfunction(function()
			return self.value;
		end);
	end
	
	function SecureNumber:SetValue(value)
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
		local tbl = {value = value or 0};
		setmetatable(tbl, SecureNumber);
		return tbl;
	end
end

do
	local SecureBoolean = {};
	SecureBoolean.__index = SecureBoolean;

	function SecureBoolean:GetValue()
		return securecallfunction(function()
			return self.value;
		end);
	end
	
	function SecureBoolean:SetValue(value)
		self.value = value;
	end

	function SecureBoolean:IsTrue()
		return self:GetValue() == true;
	end

	function SecureTypes.CreateSecureBoolean(v)
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
		if func then
			self.wrapper = function(...)
				return func(...);
			end
		else
			self.wrapper = nil;
		end
	end
	
	function SecureFunction:GetWrapperSecure()
		return securecallfunction(function()
			return self.wrapper;
		end);
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