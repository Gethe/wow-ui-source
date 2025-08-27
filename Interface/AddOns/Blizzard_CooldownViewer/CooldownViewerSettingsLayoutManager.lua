local DATA_BLOCK_ALLOW_CREATE = true;
local DATA_BLOCK_ACCESS_ONLY = false;

CooldownViewerLayoutManagerMixin = {};

function CooldownViewerLayoutManagerMixin:Init(dataProvider, serializer)
	self.dataProvider = dataProvider;
	self.serializer = serializer;
	self.layouts = {};
end

function CooldownViewerLayoutManagerMixin:IsLoaded()
	if self.layouts == nil then
		return false;
	end

	local serializer = self:GetSerializer();
	return serializer and serializer:IsLoaded();
end

function CooldownViewerLayoutManagerMixin:SaveLayouts()
	local hadSomethingToSave = self:HasPendingChanges();
	self:GetSerializer():WriteData();
	self:SetHasPendingChanges(false);
	return hadSomethingToSave;
end

function CooldownViewerLayoutManagerMixin:GetDataProvider()
	return self.dataProvider;
end

function CooldownViewerLayoutManagerMixin:GetSerializer()
	return self.serializer;
end

function CooldownViewerLayoutManagerMixin:ResetToDefaults()
	self:GetSerializer():ResetToDefaults();
	self:ClearActiveLayoutName();
	self.layouts = {};
end

function CooldownViewerLayoutManagerMixin:ResetCurrentToDefaults()
	local activeLayoutName = self:GetActiveLayoutName();
	if activeLayoutName then
		self:RemoveLayout(activeLayoutName);
	end
end

function CooldownViewerLayoutManagerMixin:UseDefaultLayout()
	local activeLayoutName = self:GetActiveLayoutName();
	if activeLayoutName then
		self:ClearActiveLayoutName();
	end

	local tag = self:GetSerializer():GetCurrentClassAndSpecTag();
	if tag then
		self:SetPreviouslyActiveLayoutForSpecToDefault(tag);
	end
end

function CooldownViewerLayoutManagerMixin:GetActiveLayout(accessMode)
	local activeLayoutName = self:GetActiveLayoutName();
	if activeLayoutName then
		local layout = self:GetLayout(activeLayoutName, DATA_BLOCK_ACCESS_ONLY);
		if layout then
			return layout;
		end

		assertsafe(false, "ActiveLayout [%s] existed, but there was no valid layout for it.", tostring(activeLayoutName));
	end

	if accessMode == DATA_BLOCK_ALLOW_CREATE then
		local tag = self:GetSerializer():GetCurrentClassAndSpecTag();
		if tag then
			local defaultLayoutName = tostring(tag);
			local newLayout = self:AddLayout(defaultLayoutName, tag);
			self:SetActiveLayoutName(defaultLayoutName);
			return newLayout;
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:GetActiveLayoutName()
	return self.activeLayoutName;
end

function CooldownViewerLayoutManagerMixin:SetActiveLayoutName(layoutName)
	local layout = self:GetLayout(layoutName);
	assertsafe(layout ~= nil, "Attempting to set active layout to a layout that doesn't exist: %s", tostring(layoutName));

	if self:CanActivateLayout(layout) then
		self.activeLayoutName = layoutName;
		self:SetPreviouslyActiveLayoutNameForSpec(layout.classAndSpecTag, layoutName);
		return true;
	end

	return false;
end

function CooldownViewerLayoutManagerMixin:ClearActiveLayoutName()
	self.activeLayoutName = nil;
end

function CooldownViewerLayoutManagerMixin:CanActivateLayout(layout)
	return self:GetSpecTagForLayout(layout) == self:GetSerializer():GetCurrentClassAndSpecTag();
end

function CooldownViewerLayoutManagerMixin:GetBestLayoutNameForSpec()
	local specTag = self:GetSerializer():GetCurrentClassAndSpecTag();
	if specTag then
		if self:IsPreviouslyActiveLayoutForSpecDefault(specTag) then
			return nil;
		end

		local lastActiveLayoutNameForSpec = self:GetPreviouslyActiveLayoutNameForSpec(specTag);
		if lastActiveLayoutNameForSpec and self:GetLayout(lastActiveLayoutNameForSpec) then
			return lastActiveLayoutNameForSpec;
		end

		for layoutName, layout in self:EnumerateLayouts() do
			if self:GetSpecTagForLayout(layout) == specTag then
				return layoutName;
			end
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:SwitchToBestLayoutForSpec()
	local layoutName = self:GetBestLayoutNameForSpec();
	if layoutName then
		self:SetActiveLayoutName(layoutName);
	else
		self:ClearActiveLayoutName();
	end
end

function CooldownViewerLayoutManagerMixin:SetPreviouslyActiveLayoutNameForSpec(specTag, layoutName)
	if not self.lastActiveLayoutNamesPerSpec then
		self.lastActiveLayoutNamesPerSpec = {};
	end

	self.lastActiveLayoutNamesPerSpec[specTag] = layoutName;
end

function CooldownViewerLayoutManagerMixin:SetPreviouslyActiveLayoutForSpecToDefault(specTag)
	self:SetPreviouslyActiveLayoutNameForSpec(specTag, 0);
end

function CooldownViewerLayoutManagerMixin:RemovePreviouslyActiveLayoutNameForSpec(specTag, layoutName)
	if self.lastActiveLayoutNamesPerSpec and self.lastActiveLayoutNamesPerSpec[specTag] == layoutName then
		self.lastActiveLayoutNamesPerSpec[specTag] = nil;
	end
end

function CooldownViewerLayoutManagerMixin:GetPreviouslyActiveLayoutNameForSpec(specTag)
	if self.lastActiveLayoutNamesPerSpec then
		return self.lastActiveLayoutNamesPerSpec[specTag];
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:IsPreviouslyActiveLayoutForSpecDefault(specTag)
	if self.lastActiveLayoutNamesPerSpec then
		return self.lastActiveLayoutNamesPerSpec[specTag] == 0;
	end

	return false;
end

function CooldownViewerLayoutManagerMixin:EnumeratePreviouslyActiveLayoutNames()
	if self.lastActiveLayoutNamesPerSpec then
		return pairs(self.lastActiveLayoutNamesPerSpec);
	end

	return nop;
end

function CooldownViewerLayoutManagerMixin:AddLayout(layoutName, classAndSpecTag)
	assertsafe(self:GetLayout(layoutName) == nil, "Layout "..tostring(layoutName).." already exists");
	assertsafe(classAndSpecTag ~= nil, "Unable to add layout without valid class and spec");

	local newLayout = { classAndSpecTag = classAndSpecTag, };
	self.layouts[layoutName] = newLayout;
	return newLayout;
end

function CooldownViewerLayoutManagerMixin:SetLayout(layoutName, layout)
	assertsafe(layout.classAndSpecTag ~= nil, "Unable to set layout without valid class and spec, is layout [%s] using correct format?", tostring(layoutName));
	self.layouts[layoutName] = layout;
	return layout;
end

function CooldownViewerLayoutManagerMixin:RemoveLayout(layoutName)
	if layoutName == self:GetActiveLayoutName() then
		self:ClearActiveLayoutName();
	end

	local layout = self:GetLayout(layoutName);
	if layout then
		self.layouts[layoutName] = nil;
		self:RemovePreviouslyActiveLayoutNameForSpec(layout.classAndSpecTag, layoutName);
	end
end

function CooldownViewerLayoutManagerMixin:GetLayout(layoutName, accessMode)
	local existingLayout = self.layouts[layoutName];
	if existingLayout then
		return existingLayout;
	end

	if accessMode == DATA_BLOCK_ALLOW_CREATE then
		return self:AddLayout(layoutName, self:GetSerializer():GetCurrentClassAndSpecTag());
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:GetSpecTagForLayout(layout)
	return layout and layout.classAndSpecTag;
end

function CooldownViewerLayoutManagerMixin:EnumerateLayouts()
	if self.layouts then
		return pairs(self.layouts);
	end

	return nop;
end

function CooldownViewerLayoutManagerMixin:GetCooldownIDDataBlockForLayout(layout, cooldownID, accessMode)
	local allowCreate = (accessMode == DATA_BLOCK_ALLOW_CREATE);

	if allowCreate and not layout.cooldownInfo then
		layout.cooldownInfo = {};
	end

	local infoTable = layout.cooldownInfo;
	if infoTable then
		if allowCreate and not infoTable[cooldownID] then
			infoTable[cooldownID] = {};
		end

		return infoTable[cooldownID];
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:GetCooldownIDDataBlock(cooldownID, accessMode)
	local layout = self:GetActiveLayout(accessMode);
	if layout then
		return self:GetCooldownIDDataBlockForLayout(layout, cooldownID, accessMode);
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:GetCooldownInfoDataBlock(cooldownInfo, accessMode)
	return self:GetCooldownIDDataBlock(cooldownInfo.cooldownID, accessMode);
end

function CooldownViewerLayoutManagerMixin:RemoveCooldownInfoDataBlock(cooldownInfo)
	-- Only call this if you know the block exists.
	assertsafe(self:GetCooldownInfoDataBlock(cooldownInfo, DATA_BLOCK_ACCESS_ONLY) ~= nil, "Illegal call to RemoveCooldownInfoDataBlock, block must already exist");

	-- TODO: This is potentially dangerous to do if something is iterating over the cooldown blocks because it will rehash...maybe it's better to mark it as "do not save"?
	local layout = self:GetActiveLayout(DATA_BLOCK_ACCESS_ONLY);
	if layout then
		if layout.cooldownInfo then
			layout.cooldownInfo[cooldownInfo.cooldownID] = nil;
		end
	end
end

function CooldownViewerLayoutManagerMixin:SetHasPendingChanges(hasPendingChanges)
	self.hasPendingChanges = hasPendingChanges;
	EventRegistry:TriggerEvent("CooldownViewerSettings.OnPendingChanges", self, hasPendingChanges);
end

function CooldownViewerLayoutManagerMixin:HasPendingChanges()
	return self.hasPendingChanges;
end

function CooldownViewerLayoutManagerMixin:WriteCooldownOrderToActiveLayout(orderedCooldownIDs)
	assertsafe(orderedCooldownIDs ~= nil, "Invalid orderedCooldownIDs");

	local layout = self:GetActiveLayout(DATA_BLOCK_ALLOW_CREATE);
	if layout then
		local currentCooldownIDs = self:ReadCooldownOrderFromLayout(layout);
		if not currentCooldownIDs or not tCompare(currentCooldownIDs, orderedCooldownIDs) then
			self:SetHasPendingChanges(true);
		end

		self:WriteCooldownOrderToLayout(layout, orderedCooldownIDs);
	end
end

function CooldownViewerLayoutManagerMixin:ReadCooldownOrderFromActiveLayout()
	local layout = self:GetActiveLayout();
	if layout then
		return self:ReadCooldownOrderFromLayout(layout);
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:WriteCooldownOrderToLayout(layout, orderedCooldownIDs)
	-- NOTE: This should not trigger pending changes because its called when deserializing.
	-- NOTE: This must be a copy to ensure that tables are never reused because of how the dataProvider
	-- can pass its displayIDs to the current layout, we don't want to directly reference those.
	layout.orderedCooldownIDs = CopyTable(orderedCooldownIDs);
end

function CooldownViewerLayoutManagerMixin:ReadCooldownOrderFromLayout(layout)
	return layout.orderedCooldownIDs;
end

function CooldownViewerLayoutManagerMixin:WriteCooldownInfo_KeyValue(cooldownInfo, key, value)
	local staticCooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownInfo.cooldownID);
	local existingCooldownDataBlock = self:GetCooldownInfoDataBlock(cooldownInfo, DATA_BLOCK_ACCESS_ONLY);

	-- If this cooldown no longer exists, but we have save data for it, then nuke that data now.
	if not staticCooldownInfo then
		if existingCooldownDataBlock then
			self:RemoveCooldownInfoDataBlock(cooldownInfo);
			self:SetHasPendingChanges(true);
		end
		return;
	end

	-- At this point, we know that the static data exists and is usable, no longer need to check it.
	local isTryingToSaveDefaultValue = self:GetDataProvider():IsDefaultValue(cooldownInfo.cooldownID, key, value);

	if isTryingToSaveDefaultValue then
		-- When trying to save defaults, the cooldownInfo[key] should match the staticData value, so go ahead and just ensure that now.
		-- This couples the layoutManager to the systems that manage the display data...might need to rethink this.
		cooldownInfo[key] = value;

		-- Then clear the key on the saved data if it exists, potentially removing the entire data block, and bail; there's nothing else to do when saving a default.
		if existingCooldownDataBlock then
			existingCooldownDataBlock[key] = nil;
			if not next(existingCooldownDataBlock) then
				self:RemoveCooldownInfoDataBlock(cooldownInfo);
				self:SetHasPendingChanges(true);
			end
		end

		return;
	end

	-- At this point, the value isn't default, so write it to the layout data, creating a new entry and even an entire (working set) layout if necessary.
	local dataBlock = existingCooldownDataBlock or self:GetCooldownInfoDataBlock(cooldownInfo, DATA_BLOCK_ALLOW_CREATE);
	if dataBlock and dataBlock[key] ~= value then
		dataBlock[key] = value;
		cooldownInfo[key] = value;
		self:SetHasPendingChanges(true);
	end
end

function CooldownViewerLayoutManagerMixin:WriteCooldownInfo_Category(cooldownInfo, category)
	self:WriteCooldownInfo_KeyValue(cooldownInfo, "category", category);
end

function CooldownViewerLayoutManagerMixin:ReadCooldownInfoBlock(cooldownInfo)
	return self:GetCooldownInfoDataBlock(cooldownInfo, DATA_BLOCK_ACCESS_ONLY);
end

function CooldownViewerLayoutManagerMixin:WriteCooldownCategoryToLayout(layout, cooldownCategory, cooldownIDs)
	for cooldownIndex, cooldownID in pairs(cooldownIDs) do
		local block = self:GetCooldownIDDataBlockForLayout(layout, cooldownID, DATA_BLOCK_ALLOW_CREATE);

		-- just to make it obvious that this is copy paste...all the block writing should share as much as possible, especially at the
		-- level where key value pairs are being written to the data
		block["category"] = cooldownCategory;
	end
end

function CooldownViewerLayoutManagerMixin:DeserializeCooldownInfo(cooldownInfo)
	local block = self:ReadCooldownInfoBlock(cooldownInfo);
	if block then
		cooldownInfo.category = block.category or cooldownInfo.category;
	end
end

function CooldownViewerLayoutManagerMixin:CreateRestorePoint()
	local activeLayoutName = self:GetActiveLayoutName();
	local activeLayout = self:GetActiveLayout();
	local layoutCopy = activeLayout and CopyTable(activeLayout);
	self.restorePoint = { name = activeLayoutName, layout = layoutCopy };
end

function CooldownViewerLayoutManagerMixin:ResetToRestorePoint()
	if self.restorePoint then
		local restorePoint = self.restorePoint;

		local activeLayoutName = self:GetActiveLayoutName();
		if activeLayoutName then
			self:ClearActiveLayoutName();
			self:RemoveLayout(activeLayoutName);
		end

		if restorePoint.name and restorePoint.layout then
			self:SetLayout(restorePoint.name, restorePoint.layout);
			self:SetActiveLayoutName(restorePoint.name);
		end
	end
end
