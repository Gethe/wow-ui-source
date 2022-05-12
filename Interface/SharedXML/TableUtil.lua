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

function CreateTableEnumerator(tbl, indexBegin, indexEnd)
	indexBegin = indexBegin and (indexBegin - 1) or 0;
	indexEnd = indexEnd or math.huge;

	local function Enumerator(tbl, index)
		index = index + 1;
		if index <= indexEnd then
			local value = tbl[index];
			if value ~= nil then
				return index, value;
			end
		end
	end

	return Enumerator, tbl, indexBegin;
end

function tDeleteItem(tbl, item)
	local size = #tbl;
	local index = size;
	while index > 0 do
		if item == tbl[index] then
			tremove(tbl, index);
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

function tUnorderedRemove(tbl, index)
	if index ~= #tbl then
		tbl[index] = tbl[#tbl];
	end

	table.remove(tbl);
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

function ContainsIf(tbl, pred)
	for k, v in pairs(tbl) do
		if (pred(v)) then
			return true;
		end
	end

	return false;
end

function FindInTableIf(tbl, pred)
	for k, v in pairs(tbl) do
		if (pred(v)) then
			return k, v;
		end
	end

	return nil;
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

function SafePack(...)
	local tbl = { ... };
	tbl.n = select("#", ...);
	return tbl;
end

function SafeUnpack(tbl)
	return unpack(tbl, 1, tbl.n);
end

function GetOrCreateTableEntry(table, key, defaultValue)
	local currentValue = table[key];
	if currentValue == nil then
		if defaultValue ~= nil then
			currentValue = defaultValue;
		else
			currentValue = {};
		end
		table[key] = currentValue;
	end

	return currentValue;
end

function GetOrCreateTableEntryByCallback(table, key, callback)
	local currentValue = table[key];
	if currentValue == nil then
		currentValue = callback();
		table[key] = currentValue;
	end

	return currentValue;
end

function GetRandomArrayEntry(array)
	return array[math.random(1, #array)];
end

function GetKeysArray(tbl)
	local keysArray = {};
	for key in pairs(tbl) do
		table.insert(keysArray, key);
	end

	return keysArray;
end

function SwapTableEntries(lhsTable, rhsTable, key)
	local lhsValue = lhsTable[key];
	lhsTable[key] = rhsTable[key];
	rhsTable[key] = lhsValue;
end
