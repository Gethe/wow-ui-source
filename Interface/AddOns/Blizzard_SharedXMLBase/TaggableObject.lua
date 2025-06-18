local TAG_BANK_SIZE = 31;

local function GetTagValues(tag)
	local index = math.floor(tag / TAG_BANK_SIZE);
	local tagIndexInBank = tag - (index * TAG_BANK_SIZE);
	local tagBit = bit.lshift(1, tagIndexInBank);

	return index, tagBit;
end

local function AddTagToTable(tags, tag)
	local index, tagBit = GetTagValues(tag);
	local tagValue = tags[index] or 0;
	tags[index] = bit.bor(tagValue, tagBit);
end

local function RemoveTagFromTable(tags, tag)
	local index, tagBit = GetTagValues(tag);
	local tagValue = tags[index];
	if tagValue ~= nil and tagValue > 0 then
		tags[index] = bit.band(tagValue, bit.bnot(tagBit));
	end
end

local function TableHasTag(tags, tag)
	local index, tagBit = GetTagValues(tag);
	local tagValue = tags[index];
	if tagValue ~= nil and tagValue > 0 then
		return bit.band(tagValue, tagBit) == tagBit;
	end

	return false;
end

TaggableObjectMixin = {};

function TaggableObjectMixin:AddTag(tag)
	AddTagToTable(GetOrCreateTableEntry(self, "tags"), tag);
end

function TaggableObjectMixin:RemoveTag(tag)
	if self.tags then
		RemoveTagFromTable(self.tags, tag);
	end
end

function TaggableObjectMixin:MatchesTag(tag)
	if self.tags then
		return TableHasTag(self.tags, tag);
	end

	return false;
end

function TaggableObjectMixin:MatchesAnyTag(...)
	if self.tags then
		for i = 1, select("#", ...) do
			local tag = select(i, ...);
			if TableHasTag(self.tags, tag) then
				return true;
			end
		end
	end

	return false;
end

function TaggableObjectMixin:MatchesAllTags(...)
	if self.tags then
		for i = 1, select("#", ...) do
			local tag = select(i, ...);
			if not TableHasTag(self.tags, tag) then
				return false;
			end
		end

		return true;
	end

	return false;
end