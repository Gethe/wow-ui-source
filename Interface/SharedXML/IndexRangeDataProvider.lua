-- IndexRangeDataProviderMixin originally written for parity with ScrollBox API to 
-- simulate extremely large ranges (i.e. 20,000 macro icons). As a result, this
-- data provider has a minimal API.
IndexRangeDataProviderMixin = CreateFromMixins(CallbackRegistryMixin);

IndexRangeDataProviderMixin:GenerateCallbackEvents(
	{
		"OnSizeChanged",
	}
);

function IndexRangeDataProviderMixin:Init(size)
	CallbackRegistryMixin.OnLoad(self);

	self:SetSize(size);
end

function IndexRangeDataProviderMixin:Enumerate(indexBegin, indexEnd)
	indexBegin = indexBegin and (indexBegin - 1) or 0;
	indexEnd = indexEnd or math.huge;

	local function Enumerator(invariant, index)
		index = index + 1;
		if index <= indexEnd then
			return index, index;
		end
	end
	
	local invariant = nil;
	return Enumerator, invariant, indexBegin;
end

function IndexRangeDataProviderMixin:GetSize()
	return self.size;
end

function IndexRangeDataProviderMixin:SetSize(size)
	self.size = math.max(0, size);

	local pendingSort = false;
	self:TriggerEvent(IndexRangeDataProviderMixin.Event.OnSizeChanged, pendingSort);
end

function IndexRangeDataProviderMixin:Flush()
	self:SetSize(0);
end

function IndexRangeDataProviderMixin:Find(index)
	if index <= self:GetSize() then
		return index;
	end
end

function IndexRangeDataProviderMixin:FindByPredicate(predicate)
	for index = 1, self:GetSize() do
		if predicate(index) then
			return index;
		end
	end
end

function IndexRangeDataProviderMixin:ContainsByPredicate(predicate)
	return self:FindByPredicate(predicate) ~= nil;
end

function CreateIndexRangeDataProvider(size)
	return CreateAndInitFromMixin(IndexRangeDataProviderMixin, size or 0);
end