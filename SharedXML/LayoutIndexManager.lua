LayoutIndexManagerMixin = {}

function LayoutIndexManagerMixin:AddManagedLayoutIndex(key, startingIndex)
	if (not self.managedLayoutIndexes) then
		self.managedLayoutIndexes = {};
		self.startingLayoutIndexes = {};
	end
	self.managedLayoutIndexes[key] = startingIndex;
	self.startingLayoutIndexes[key] = startingIndex;
end

function LayoutIndexManagerMixin:GetManagedLayoutIndex(key)
	if (not self.managedLayoutIndexes or not self.managedLayoutIndexes[key]) then
		return 0;
	end

	local layoutIndex = self.managedLayoutIndexes[key];
	self.managedLayoutIndexes[key] = self.managedLayoutIndexes[key] + 1;
	return layoutIndex;
end

function LayoutIndexManagerMixin:Reset()
	for k, _ in pairs(self.managedLayoutIndexes) do
		self.managedLayoutIndexes[k] = self.startingLayoutIndexes[k];
	end
end

function CreateLayoutIndexManager()
	return CreateFromMixins(LayoutIndexManagerMixin);
end