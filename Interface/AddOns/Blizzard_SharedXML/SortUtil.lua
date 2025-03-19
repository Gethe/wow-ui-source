SortUtil = {};

function SortUtil.CompareNumeric(lhs, rhs)
	return Sign(lhs - rhs);
end

function SortUtil.CompareUtf8i(lhs, rhs)
	return Sign(strcmputf8i(lhs, rhs));
end

local SortManagerMixin = {};

function SortManagerMixin:Init()
	self.comparatorsTbls = {};
end

function SortManagerMixin:InsertComparator(sortOrder, comparator)
	assert(sortOrder, comparator);
	table.insert(self.comparatorsTbls, {sortOrder = sortOrder, comparator = comparator, ascending = false});
end

function SortManagerMixin:SetDefaultComparator(defaultComparatorFunc)
	self.defaultComparatorFunc = defaultComparatorFunc;
end

function SortManagerMixin:SetSortOrderFunc(sortOrderFunc)
	self.sortOrderFunc = sortOrderFunc;
end

function SortManagerMixin:FindComparatorTbl(sortOrder)
	return FindValueInTableIf(self.comparatorsTbls, function(comparatorsTbl)
		return comparatorsTbl.sortOrder == sortOrder;
	end);
end

function SortManagerMixin:ToggleSortAscending(sortOrder)
	local comparatorTbl = self:FindComparatorTbl(sortOrder);
	comparatorTbl.ascending = not comparatorTbl.ascending;
end

function SortManagerMixin:SetSortAscending(sortOrder, ascending)
	local comparatorTbl = self:FindComparatorTbl(sortOrder);
	comparatorTbl.ascending = ascending;
end

function SortManagerMixin:IsSortAscending(sortOrder)
	local comparatorTbl = self:FindComparatorTbl(sortOrder);
	return comparatorTbl.ascending;
end

function SortManagerMixin:CreateComparator()
	return function(lhs, rhs)
		local comparatorsTbls = self.comparatorsTbls;

		local result = 0;
		local sortOrder = self.sortOrderFunc();
		if sortOrder then
			local comparatorTbl = self:FindComparatorTbl(sortOrder);
			if comparatorTbl then
				result = NegateIf(comparatorTbl.comparator(lhs, rhs), comparatorTbl.ascending);
			end
		end

		if result == 0 then
			for _, comparatorTbl in ipairs(comparatorsTbls) do
				if comparatorTbl.sortOrder ~= sortOrder then
					result = NegateIf(comparatorTbl.comparator(lhs, rhs), comparatorTbl.ascending);
					if result < 0 then
						return true;
					elseif result > 0 then
						return false;
					end
				end
			end

			if not self.defaultComparatorFunc then
				error("Provide a default comparator that guarantees strict ordering.");
			end
			return self.defaultComparatorFunc(lhs, rhs);
		end

		return result < 0;
	end;
end

function SortUtil.CreateSortManager()
	local sortManager = CreateFromMixins(SortManagerMixin);
	sortManager:Init();
	return sortManager;
end