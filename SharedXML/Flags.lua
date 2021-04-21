function Flags_CreateMask(...)
	local mask = 0;
	for i = 1, select("#", ...) do
		mask = bit.bor(mask, select(i, ...));
	end

	return mask;
end

function Flags_CreateMaskFromTable(flagsTable)
	local mask = 0;
	for flagName, flagValue in pairs(flagsTable) do
		mask = bit.bor(mask, flagValue);
	end

	return mask;
end

FlagsUtil = {};

function FlagsUtil.IsSet(bitMask, flagOrMask)
	return bit.band(bitMask, flagOrMask) == flagOrMask;
end

function FlagsUtil.IsAnySet(bitMask, mask)
	return bit.band(bitMask, mask) ~= 0;
end

FlagsMixin = {};

function FlagsMixin:OnLoad()
	self:ClearAll();
end

function FlagsMixin:AddNamedFlagsFromTable(flagsTable)
	assert(flagsTable.flags == nil);
	Mixin(self, flagsTable);
end

function FlagsMixin:AddNamedMask(flagName, mask)
	assert(self[flagName] == nil);
	self[flagName] = mask;
end

function FlagsMixin:Set(flag)
	self.flags = bit.bor(self.flags, flag);
end

function FlagsMixin:Clear(flag)
	self.flags = bit.band(self.flags, bit.bnot(flag));
end

function FlagsMixin:SetOrClear(flag, isSet)
	if isSet then
		self:Set(flag);
	else
		self:Clear(flag);
	end
end

function FlagsMixin:ClearAll()
	self.flags = 0;
end

function FlagsMixin:IsAnySet()
	return self.flags ~= 0;
end

function FlagsMixin:IsSet(flagOrMask)
	return FlagsUtil.IsSet(self.flags, flagOrMask);
end

function FlagsMixin:GetFlags()
	return self.flags;
end

DirtyFlagsMixin = CreateFromMixins(FlagsMixin);

function DirtyFlagsMixin:OnLoad()
	FlagsMixin.OnLoad(self);
	self.isDirty = false;
end

function DirtyFlagsMixin:MarkDirty(flag)
	if flag ~= nil then
		self:Set(flag);
	end

	self.isDirty = true;
end

function DirtyFlagsMixin:MarkClean()
	self:ClearAll();
	self.isDirty = false;
end

function DirtyFlagsMixin:IsDirty(flag)
	if flag ~= nil then
		return self:IsSet(flag);
	else
		return self.isDirty;
	end
end