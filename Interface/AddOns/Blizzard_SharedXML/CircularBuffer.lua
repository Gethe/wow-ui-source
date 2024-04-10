local securecall = securecall;
local type = type;
local error = error;
local CreateFromMixins = CreateFromMixins;

local function safesecurecall(fn, ...)
	if type(fn) ~= "function" then
		error("Function lookups forbidden");
		return;
	end

	return securecall(fn, ...);
end

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
	-- We want the new elements array to have entries in order from oldest to newest so we use a reverse iterator.  After we are done with removals, the headIndex will point to the last (newest) element.
	for i, entry in self:ReverseEnumerateIndexedEntries() do
		if not safesecurecall(predicateFunction, safesecurecall(transformFunction, entry)) then
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
		if safesecurecall(predicateFunction, safesecurecall(entryTransform, entry)) then
			self.elements[i] = safesecurecall(transformFunction, safesecurecall(entryTransform, entry));
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

			local elementIndex = self:CalculateElementIndex(currentIndex);
			return currentIndex, self.elements[elementIndex];
		end
	end

	-- Returns elements from front to back
	function CircularBufferMixin:EnumerateIndexedEntries()
		return IteratorHelper, self, 0;
	end

	local function ReverseIteratorHelper(self, currentIndex)
		if currentIndex > 1 then
			currentIndex = currentIndex - 1;

			local elementIndex = self:CalculateElementIndex(currentIndex);
			return currentIndex, self.elements[elementIndex];
		end
	end

	-- Returns elements from back to front
	function CircularBufferMixin:ReverseEnumerateIndexedEntries()
		return ReverseIteratorHelper, self, self:GetNumElements()+1;
	end
end

-- "private" functions
function CircularBufferMixin:OnLoad(maxElements)
    self.maxElements = maxElements;
    self:Clear();
end

-- index 1 is front
function CircularBufferMixin:CalculateElementIndex(index)
	local globalIndex = self.headIndex - index + 1;
    return self:CalculateElementIndexFromGlobalIndex(globalIndex);
end

function CircularBufferMixin:CalculateElementIndexFromGlobalIndex(globalIndex)
	if(globalIndex == 0) then
		return self:GetMaxNumElements();
	end

	-- Note that it is fine for globalIndex to be negative, because in lua a modulo operation on a negative number gives you a positive number.
	return (globalIndex - 1) % self:GetMaxNumElements() + 1; -- 0 based modulo then adjusted for 1 based indexing
end

function CircularBufferMixin:ReplaceElements(elements)
	if #elements == 0 then
		self.headIndex = 0;
	else
		self.headIndex = (#elements - 1) % self.maxElements + 1;
	end
	self.elements = elements;
end