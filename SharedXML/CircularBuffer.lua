CircularBufferMixin = {}

function CreateCircularBuffer(maxElements)
	local circularBuffer = CreateFromMixins(CircularBufferMixin);
	circularBuffer:OnLoad(maxElements);
	return circularBuffer;
end

-- "public" functions
function CircularBufferMixin:Clear()
    self.headIndex = 0;
    self.elements = {};
end

function CircularBufferMixin:SetMaxNumElements(maxElements)
	if self.maxElements ~= maxElements then
		local elements = {};
		local elementsToCopy = math.min(maxElements, #self.elements);
		for i = 1, elementsToCopy do
			elements[i] = self:GetEntryAtIndex(elementsToCopy - i + 1);
		end

		self.maxElements = maxElements;
		self:ReplaceElements(elements);
	end
end

function CircularBufferMixin:GetMaxNumElements()
    return self.maxElements;
end

function CircularBufferMixin:PushFront(element)
    self.headIndex = self.headIndex + 1;
    
	local insertIndex = self.headIndex;
    self.elements[insertIndex] = element;
    
    self.headIndex = self.headIndex % self.maxElements;

	return insertIndex;
end

function CircularBufferMixin:PushBack(element) -- Won't overwrite front
	if not self:IsFull() then
		table.insert(self.elements, 1, element);
		self.headIndex = (self.headIndex + 1) % self.maxElements;
		return 1;
	end
	return nil;
end

function CircularBufferMixin:GetEntryAtIndex(index)
    if index > 0 and index <= self:GetNumElements() then
        local elementIndex = self:CalculateElementIndex(index);
        return self.elements[elementIndex];
    end
end

local function PassThrough(...)
	return ...;
end

function CircularBufferMixin:RemoveIf(predicateFunction, transformFunction)
	if self:IsEmpty() then
		return false;
	end

	transformFunction = transformFunction or PassThrough;
	local elements = {};
	for i, entry in self:EnumerateIndexedEntries() do
		if not securecall(predicateFunction, securecall(transformFunction, entry)) then
			elements[#elements + 1] = entry;
		end
	end

	self:ReplaceElements(elements);
	return true;
end

function CircularBufferMixin:TransformIf(predicateFunction, transformFunction, entryTransform)
	local changed = false;
	if self:IsEmpty() then
		return changed;
	end

	entryTransform = entryTransform or PassThrough;
	for i, entry in ipairs(self.elements) do
		if securecall(predicateFunction, securecall(entryTransform, entry)) then
			self.elements[i] = securecall(transformFunction, securecall(entryTransform, entry));
			changed = true;
		end
	end

	return changed;
end

function CircularBufferMixin:GetNumElements()
    return #self.elements;
end

function CircularBufferMixin:IsFull()
    return self:GetMaxNumElements() == self:GetNumElements();
end

function CircularBufferMixin:IsEmpty()
	return self:GetNumElements() == 0;
end

do
	local function IteratorHelper(self, currentIndex)
		if currentIndex < self:GetNumElements() then
			currentIndex = currentIndex + 1;

			local elementIndex = self:CalculateElementIndexFromGlobalIndex(currentIndex);
			return currentIndex, self.elements[elementIndex];
		end
	end

	function CircularBufferMixin:EnumerateIndexedEntries()
		return IteratorHelper, self, 0;
	end
end

-- "private" functions
function CircularBufferMixin:OnLoad(maxElements)
    self.maxElements = maxElements;
    self:Clear();
end

function CircularBufferMixin:CalculateElementIndex(index)
	local globalIndex = self.headIndex - index + 1;
    return self:CalculateElementIndexFromGlobalIndex(globalIndex);
end

function CircularBufferMixin:CalculateElementIndexFromGlobalIndex(globalIndex)
	return (globalIndex - 1) % self:GetMaxNumElements() + 1; -- 0 based modulo then adjusted for 1 based indexing
end

function CircularBufferMixin:ReplaceElements(elements)
	self.headIndex = #elements % self.maxElements;
	self.elements = elements;
end