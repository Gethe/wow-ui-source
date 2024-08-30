
local tRemove = table.remove;
local tInsert = table.insert;
local tWipe = table.wipe;

TableUtil = {};

TableUtil.Constants =
{
	AssociativePriorityTable = true,
	ArraylikePriorityTable = false,
	IsIndexTable = true,
};

function ipairs_reverse(table)
	local function Enumerator(table, index)
		index = index - 1;
		local value = table[index];
		if value ~= nil then
			return index, value;
		end
	end
	return Enumerator, table, #table + 1;
end

function CreateTableEnumerator(tbl, minIndex, maxIndex)
	minIndex = minIndex and (minIndex - 1) or 0;
	maxIndex = maxIndex or math.huge;

	local function Enumerator(tbl, index)
		index = index + 1;
		if index <= maxIndex then
			local value = tbl[index];
			if value ~= nil then
				return index, value;
			end
		end
	end

	return Enumerator, tbl, minIndex;
end

function CreateTableReverseEnumerator(tbl, minIndex, maxIndex)
	minIndex = minIndex or 1;
	maxIndex = (maxIndex or #tbl) + 1;

	local function Enumerator(tbl, index)
		index = index - 1;
		if index >= minIndex then
			local value = tbl[index];
			if value ~= nil then
				return index, value;
			end
		end
	end

	return Enumerator, tbl, maxIndex;
end

function tDeleteItem(tbl, item)
	local size = #tbl;
	local index = size;
	while index > 0 do
		if item == tbl[index] then
			tRemove(tbl, index);
		end
		index = index - 1;
	end
	return size - #tbl;
end

function tIndexOf(tbl, item)
	for i, v in ipairs(tbl) do
		if item == v then
			return i;
		end
	end
end

function tContains(tbl, item)
	for k, v in pairs(tbl) do
		if item == v then
			return true;
		end
	end
	return false;
end

function TableUtil.ContainsAllKeys(lhsTable, rhsTable)
	for key, _ in pairs(lhsTable) do
		if rhsTable[key] == nil then
			return false;
		end
	end
	-- Check for any keys that are in rhsTable and not lhsTable.
	for key, _ in pairs(rhsTable) do
		if lhsTable[key] == nil then
			return false;
		end
	end
	return true;
end

function TableUtil.CompareValuesAsKeys(lhsTable, rhsTable, valueToKeyOp)
	local lhsKeys = CopyTransformedValuesAsKeys(lhsTable, valueToKeyOp);
	local rhsKeys = CopyTransformedValuesAsKeys(rhsTable, valueToKeyOp);
	return TableUtil.ContainsAllKeys(lhsKeys, rhsKeys)
end

-- This is a deep compare on the values of the table (based on depth) but not a deep comparison
-- of the keys, as this would be an expensive check and won't be necessary in most cases.
function tCompare(lhsTable, rhsTable, depth)
	depth = depth or 1;
	for key, value in pairs(lhsTable) do
		if type(value) == "table" then
			local rhsValue = rhsTable[key];
			if type(rhsValue) ~= "table" then
				return false;
			end
			if depth > 1 then
				if not tCompare(value, rhsValue, depth - 1) then
					return false;
				end
			end
		elseif value ~= rhsTable[key] then
			return false;
		end
	end

	-- Check for any keys that are in rhsTable and not lhsTable.
	for key, value in pairs(rhsTable) do
		if lhsTable[key] == nil then
			return false;
		end
	end

	return true;
end

function tInvert(tbl)
	local inverted = {};
	for k, v in pairs(tbl) do
		inverted[v] = k;
	end
	return inverted;
end

function TableUtil.TrySet(tbl, key)
	if not tbl[key] then
		tbl[key] = true;
		return true;
	end
	return false;
end

function TableUtil.CopyUnique(tbl, isIndexTable)
	local found = {};
	local function FilterPredicate(value)
		return TableUtil.TrySet(found, value);
	end

	return tFilter(tbl, FilterPredicate, isIndexTable);
end

function TableUtil.CopyUniqueByPredicate(tbl, isIndexTable, unaryPredicate)
	local found = {};
	local function FilterPredicate(value)
		return TableUtil.TrySet(found, unaryPredicate(value));
	end

	return tFilter(tbl, FilterPredicate, isIndexTable);
end

function tFilter(tbl, pred, isIndexTable)
	local out = {};

	if (isIndexTable) then
		local currentIndex = 1;
		for i, v in ipairs(tbl) do
			if (pred(v)) then
				out[currentIndex] = v;
				currentIndex = currentIndex + 1;
			end
		end
	else
		for k, v in pairs(tbl) do
			if (pred(v)) then
				out[k] = v;
			end
		end
	end

	return out;
end

function tAppendAll(table, addedArray)
	for i, element in ipairs(addedArray) do
		tinsert(table, element);
	end
end

function tInsertUnique(tbl, item)
	if not tContains(tbl, item) then
		table.insert(tbl, item);
		return #tbl;
	end
	return nil;
end

function tUnorderedRemove(tbl, index)
	if index ~= #tbl then
		tbl[index] = tbl[#tbl];
	end

	tRemove(tbl);
end

function CopyTable(settings, shallow)
	local copy = {};
	for k, v in pairs(settings) do
		if type(v) == "table" and not shallow then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

function MergeTable(destination, source)
	for k, v in pairs(source) do
		destination[k] = v;
	end
end

-- Useful if there are external references to a table but we want to set
-- that table's key-value pairs to be exactly the same as another table's key-value pairs.
function SetTablePairsToTable(destination, source)
	tWipe(destination);
	MergeTable(destination, source);
end

function CountTable(tbl)
	local count = 0;
	for k, v in pairs(tbl) do
		count = count + 1;
	end
	return count;
end

function Accumulate(tbl)
	local count = 0;
	for k, v in pairs(tbl) do
		count = count + v;
	end
	return count;
end

function AccumulateOp(tbl, op)
	local count = 0;
	for k, v in pairs(tbl) do
		count = count + op(v);
	end
	return count;
end

function TableUtil.Execute(tbl, op)
	for k, v in pairs(tbl) do
		op(v);
	end
end

function TableUtil.ExecuteUntil(tbl, op)
	for k, v in pairs(tbl) do
		local operationResult = op(v);
		if operationResult then
			return operationResult;
		end
	end

	return nil;
end

function TableUtil.Transform(tbl, op)
	local result = {};
	for k, v in pairs(tbl) do
		table.insert(result, op(v));
	end
	return result;
end

function ContainsIf(tbl, pred)
	for k, v in pairs(tbl) do
		if (pred(v)) then
			return true;
		end
	end

	return false;
end

function FindInTable(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return k, v;
		end
	end

	return nil;
end

function FindInTableIf(tbl, pred)
	for k, v in pairs(tbl) do
		if (pred(v)) then
			return k, v;
		end
	end

	return nil;
end

function FindValueInTableIf(tbl, pred)
	local _, value = FindInTableIf(tbl, pred);
	return value;
end

local function FindSortedIndexImplementation(tbl, searchComparison, startIndex, rangeStart, rangeEnd)
	local comparisonResult = searchComparison(tbl[startIndex]);
	if comparisonResult == 0 then
		return startIndex;
	end

	if comparisonResult > 0 then
		if startIndex >= rangeEnd then
			return startIndex + 1;
		end

		rangeStart = startIndex + 1;
		return FindSortedIndexImplementation(tbl, searchComparison, startIndex + math.ceil((rangeEnd - startIndex) / 2), rangeStart, rangeEnd);
	end

	-- comparisonResult < 0
	if startIndex <= rangeStart then
		return startIndex;
	end

	rangeEnd = startIndex - 1;
	return FindSortedIndexImplementation(tbl, searchComparison, math.floor(startIndex / 2), rangeStart, rangeEnd);
end

function FindSortedIndex(tbl, searchComparison)
	local numTable = #tbl;
	local startingIndex = math.ceil(numTable / 2);
	if startingIndex == 0 then
		return 1;
	end

	return FindSortedIndexImplementation(tbl, searchComparison, startingIndex, 1, numTable);
end

function TableIsEmpty(tbl)
	return next(tbl) == nil;
end

function TableHasAnyEntries(tbl)
	return next(tbl) ~= nil;
end

function CopyValuesAsKeys(tbl)
	local output = {};
	for k, v in ipairs(tbl) do
		output[v] = v;
	end
	return output;
end

function CopyTransformedValuesAsKeys(tbl, transformOp)
	local output = {};
	for _, v in ipairs(tbl) do
		output[transformOp(v)] = v;
	end
	return output;
end

function SafePack(...)
	local tbl = { ... };
	tbl.n = select("#", ...);
	return tbl;
end

function SafeUnpack(tbl, startIndex)
	return unpack(tbl, startIndex or 1, tbl.n);
end

function GetOrCreateTableEntry(table, key, defaultValue)
	local currentValue = table[key];
	local isNewValue = (currentValue == nil);
	if isNewValue then
		if defaultValue ~= nil then
			currentValue = defaultValue;
		else
			currentValue = {};
		end
		table[key] = currentValue;
	end

	return currentValue, isNewValue;
end

function GetOrCreateTableEntryByCallback(table, key, callback)
	local currentValue = table[key];
	local isNewValue = (currentValue == nil);
	if isNewValue then
		currentValue = callback(key);
		table[key] = currentValue;
	end

	return currentValue, isNewValue;
end

function GetRandomArrayEntry(array)
	return array[math.random(1, #array)];
end

function GetRandomTableValue(tbl)
	local value;
	local n = 0;
	for k, v in pairs(tbl) do
		n = n + 1;
		local r = math.random();
		if r <= (1 / n) then
			value = v;
		end
	end
	return value;
end

function GetKeysArray(tbl)
	local keysArray = {};
	for key in pairs(tbl) do
		tInsert(keysArray, key);
	end

	return keysArray;
end

function GetValuesArray(tbl)
	local valuesArray = {};
	for key, value in pairs(tbl) do
		tInsert(valuesArray, value);
	end

	return valuesArray;
end

function GetPairsArray(tbl)
	local pairsArray = {};
	for key, value in pairs(tbl) do
		tInsert(pairsArray, { key = key, value = value, });
	end

	return pairsArray;
end

function SwapTableEntries(lhsTable, rhsTable, key)
	local lhsValue = lhsTable[key];
	lhsTable[key] = rhsTable[key];
	rhsTable[key] = lhsValue;
end

function GetKeysArraySortedByValue(tbl)
	local keysArray = GetKeysArray(tbl);

	table.sort(keysArray, function(a, b) 
		return tbl[a] < tbl[b];
	end);
	
	return keysArray;
end

function TableUtil.GetTableValueListFromEnumeration(tableKey, ...)
	local values = {};
	for enumerationKey, tbl in ... do
		table.insert(values, tbl[tableKey]);
	end

	return values;
end

function TableUtil.GetHighestNumericalValueInTable(table)
	local highestValue = nil;
	for key, value in pairs(table) do
		if type(value) == "number" and (not highestValue or value > highestValue) then
			highestValue = value;
		end
	end
	return highestValue;
end

--[[
This utility creates and returns a table of elements that are sorted by value "priority".

Arguments:
comparator - comparator(A, B) returns whether A has higher priority than B
isAssociative - whether the table should be associative (true) or array-like (false). Only values have priorities for associative tables, not keys.

Return usage:
t[k]/t:Get(k) - returns the value stored with key/index k
t[k] = v (Associative only) - stores the value v at key k, sorting accordingly
t:Insert(v) (Array-like only) - inserts the value v, sorting accordingly
t:Remove(k) - removes the element at key/index k
t:Iterate(cb) - calls function cb on each key/index value pair in sorted priority order. !!WARNING!! This must be used instead of pairs(t)/ipairs(t)
t:GetTop() - returns the highest priority element
t:Pop() - returns and removes the highest priority element
t:GetBottom() - returns the lowest priority element
t:Size() - returns the number of stored elements. !!WARNING!! This must be used instead of #t
t:Clear() - removes all elements
--]]
function TableUtil.CreatePriorityTable(comparator, isAssociative)
	local sortedArray = {};

	local ShiftPositionMap;
	local keyToPosMap;
	if isAssociative then
		keyToPosMap = {};

		ShiftPositionMap = function(position, shiftUp)
			local mod = shiftUp and 1 or -1;
			for k, p in pairs(keyToPosMap) do
				if p >= position then
					keyToPosMap[k] = p + mod;
				end
			end
		end
	end

	local function SortedInsert(k, v)
		if isAssociative then
			local prevPos = keyToPosMap[k];
			if prevPos then
				tRemove(sortedArray, prevPos);
				local shiftUp = false;
				ShiftPositionMap(prevPos, shiftUp);
			end
		end

		local top = (#sortedArray > 0) and (#sortedArray + 1) or 1;
		local bottom = 1;
		while top ~= bottom do
			local mid = math.floor((top - bottom) / 2) + bottom;
			if not comparator(v, sortedArray[mid]) then
				bottom = mid + 1;
			else
				top = mid;
			end
		end
		local idx = bottom;
		tInsert(sortedArray, idx, v);

		if isAssociative then
			local shiftUp = true;
			ShiftPositionMap(idx, shiftUp);
			keyToPosMap[k] = idx;
		end
	end

	local t = {};

	function t:Get(k)
		local key = isAssociative and keyToPosMap[k] or k;
		return sortedArray[key];
	end

	if not isAssociative then
		function t:Insert(v)
			SortedInsert(nil, v)
		end
	end

	function t:Remove(k)
		local key = isAssociative and keyToPosMap[k] or k;
		tRemove(sortedArray, key);
		if isAssociative then
			keyToPosMap[k] = nil;
			local shiftUp = false;
			ShiftPositionMap(key, shiftUp);
		end
	end

	function t:GetTop()
		return #sortedArray > 0 and sortedArray[1];
	end

	function t:GetBottom()
		return #sortedArray > 0 and sortedArray[#sortedArray];
	end

	function t:Pop()
		if t:Size() == 0 then
			return nil;
		end

		local top = t:GetTop();
		local removalKey = isAssociative and tInvert(keyToPosMap)[1] or 1;
		t:Remove(removalKey);
		return top;
	end

	function t:Iterate(callback)
		local posToKeyMap = isAssociative and tInvert(keyToPosMap) or nil;
		for pos, v in ipairs(sortedArray) do
			local key = isAssociative and posToKeyMap[pos] or pos;
			local done = callback(key, v);
			if done then
				return;
			end
		end
	end

	function t:Size()
		return #sortedArray;
	end

	function t:Clear()
		sortedArray = {};
		if isAssociative then
			keyToPosMap = {};
		end
	end

	local mt =
	{
		__index = function(t, k)
			return t:Get(k);
		end,
	};
	if isAssociative then
		mt.__newindex = function(t, k, v)
			if v ~= nil then
				SortedInsert(k, v);
			else
				t:Remove(k);
			end
		end
	else
		mt.__newindex = function(t, k, v)
			error("Attempted to assign a value to an array-like priority queue index. Use Insert()/Remove() instead.")
		end
	end

	setmetatable(t, mt);

	return t;
end