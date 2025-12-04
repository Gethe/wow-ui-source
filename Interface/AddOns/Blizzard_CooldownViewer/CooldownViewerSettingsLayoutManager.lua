-- Internal tracking for having a state where the user just wants to use the default layout without creating an actual layout.
-- AddLayout will check that this ID cannot be used; but this is to help differentiate between having an actual layout active or not
-- and having made a choice to use the default layout.
local DEFAULT_LAYOUT_ID = 0;

function CooldownManagerLayout_Create(id, name, classAndSpecTag)
	assertsafe(type(id) == "number" and id ~= DEFAULT_LAYOUT_ID, "Illegal use of default layout id to create a layout %s", tostring(name));
	return { layoutID = id, layoutName = name, classAndSpecTag = classAndSpecTag };
end

function CooldownManagerLayout_GetID(layout)
	return layout.layoutID;
end

function CooldownManagerLayout_GetType(layout)
	-- It's the only kind for now...
	return Enum.CooldownLayoutType.Character;
end

function CooldownManagerLayout_GetNameExplicit(layout)
	if layout.layoutName and layout.layoutName ~= "" then
		return layout.layoutName;
	end

	return nil;
end

function CooldownManagerLayout_GetName(layout)
	local explicitName = CooldownManagerLayout_GetNameExplicit(layout);
	if explicitName then
		return explicitName;
	end

	return CooldownViewerUtil.GetClassAndSpecTagText(layout.classAndSpecTag) or UNKNOWN;
end

function CooldownManagerLayout_SetName(layout, newLayoutName)
	layout.layoutName = newLayoutName;
end

function CooldownManagerLayout_GetClassAndSpecTag(layout)
	return layout.classAndSpecTag;
end

function CooldownManagerLayout_GetOrderedCooldownIDs(layout)
	return layout.orderedCooldownIDs;
end

function CooldownManagerLayout_SetOrderedCooldownIDs(layout, cooldownIDs)
	layout.orderedCooldownIDs = cooldownIDs;
end

function CooldownManagerLayout_GetCooldownInfo(layout, allowCreate)
	local info = layout.cooldownInfo;
	if not info and allowCreate then
		info = {};
		layout.cooldownInfo = info;
	end

	return info;
end

-- NOTE: "default layout" isn't something that will get saved, but when a layout is initially created it can be marked
-- as having come from a default layout before the user has had a chance to pick a name for it
function CooldownManagerLayout_IsDefaultLayout(layout)
	return layout.isDefault;
end

function CooldownManagerLayout_SetIsDefault(layout, isDefault)
	layout.isDefault = isDefault;
end

CooldownViewerLayoutManagerMixin = {};

function CooldownViewerLayoutManagerMixin:Init(dataProvider, serializer)
	self.dataProvider = dataProvider;
	self.serializer = serializer;
	self:InitMemberVariables();
end

function CooldownViewerLayoutManagerMixin:InitMemberVariables()
	self.layouts = {};
	self.lastActiveLayoutIDsPerSpec = {};
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
	if hadSomethingToSave then
		self:GetSerializer():WriteData();
	end

	self:SetHasPendingChanges(false);
	local isVerboseChange = self.isVerboseChange;
	self.isVerboseChange = nil;
	return hadSomethingToSave, isVerboseChange;
end

function CooldownViewerLayoutManagerMixin:GetDataProvider()
	return self.dataProvider;
end

function CooldownViewerLayoutManagerMixin:GetSerializer()
	return self.serializer;
end

function CooldownViewerLayoutManagerMixin:ResetToDefaults()
	self:GetSerializer():ResetToDefaults();
	self:ClearActiveLayout();
	self:InitMemberVariables();
end

function CooldownViewerLayoutManagerMixin:ResetCurrentToDefaults()
	local activeLayoutID = self:GetActiveLayoutID();
	if activeLayoutID then
		self:RemoveLayout(activeLayoutID);
	end
end

function CooldownViewerLayoutManagerMixin:UseDefaultLayout()
	local activeLayoutID = self:GetActiveLayoutID();
	if activeLayoutID then
		self:ClearActiveLayout();
	end

	local currentSpec = self:GetCurrentSpecTag();
	if currentSpec then
		if not self:IsPreviouslyActiveLayoutForSpecDefault(currentSpec) then
			self:SetPreviouslyActiveLayoutForSpecToDefault(currentSpec);
			local isVerboseChange = false;
			self:SetHasPendingChanges(true, isVerboseChange);
		end
	end
end

function CooldownViewerLayoutManagerMixin:IsUsingDefaultLayout()
	return self:GetActiveLayout(Enum.CDMLayoutMode.AccessOnly) == nil;
end

function CooldownViewerLayoutManagerMixin:IsDefaultLayoutID(id)
	return id == self:GetDefaultLayoutID();
end

function CooldownViewerLayoutManagerMixin:GetDefaultLayoutID()
	return DEFAULT_LAYOUT_ID;
end

function CooldownViewerLayoutManagerMixin:GetActiveLayout(accessMode)
	local activeLayoutID = self:GetActiveLayoutID();
	if activeLayoutID then
		local layout = self:GetLayout(activeLayoutID);
		assertsafe(layout ~= nil, "LayoutID [%s] was active, but there was no valid layout for it.", tostring(activeLayoutID));
		if layout then
			return layout;
		end
	end

	-- NOTE: This is intended to make a new layout since none was active, likely because the user started to make changes to the current state of things and there
	-- needs to be a layout that can contain the new cooldown categories, alerts, etc...
	if accessMode == Enum.CDMLayoutMode.AllowCreate then
		local triggerDisplayWarning = true;
		if self:AreChangesAllowed(triggerDisplayWarning) then
			local newLayout = self:AddLayout(nil, self:GetCurrentSpecTag());
			self:SetActiveLayout(newLayout);
			return newLayout;
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:GetActiveLayoutID()
	return self.activeLayoutID;
end

function CooldownViewerLayoutManagerMixin:SetActiveLayout(layout)
	local newLayoutID = CooldownManagerLayout_GetID(layout);
	if self:CanActivateLayout(layout) and self:GetActiveLayoutID() ~= newLayoutID then
		self.activeLayoutID = newLayoutID;
		self:SetPreviouslyActiveLayout(layout);

		local isVerboseChange = false;
		self:SetHasPendingChanges(true, isVerboseChange);
		return true;
	end

	return false;
end

function CooldownViewerLayoutManagerMixin:SetActiveLayoutByID(layoutID)
	return self:SetActiveLayout(self:GetLayout(layoutID));
end

function CooldownViewerLayoutManagerMixin:ClearActiveLayout()
	local hasPendingChanges = self.activeLayoutID ~= nil;
	self.activeLayoutID = nil;

	if hasPendingChanges then
		local isVerboseChange = false;
		self:SetHasPendingChanges(true, isVerboseChange);
	end
end

function CooldownViewerLayoutManagerMixin:CanActivateLayout(layout)
	local layoutID = CooldownManagerLayout_GetID(layout);
	local existingLayout = self:GetLayout(layoutID);
	assertsafe(existingLayout ~= nil, "Attempting to set active layout to a layout that doesn't exist: %s", tostring(layoutID));
	if existingLayout then
		return CooldownManagerLayout_GetClassAndSpecTag(existingLayout) == CooldownViewerUtil.GetCurrentClassAndSpecTag();
	end

	return false;
end

function CooldownViewerLayoutManagerMixin:GetCurrentSpecTag()
	if not self.currentSpecTag then
		self.currentSpecTag = CooldownViewerUtil.GetCurrentClassAndSpecTag();
	end

	return self.currentSpecTag;
end

function CooldownViewerLayoutManagerMixin:GetBestLayoutForSpec()
	-- Cache current spec
	self.currentSpecTag = nil;
	local specTag = self:GetCurrentSpecTag();

	if specTag then
		if self:IsPreviouslyActiveLayoutForSpecDefault(specTag) then
			return nil;
		end

		local lastActiveLayoutIDForSpec = self:GetPreviouslyActiveLayoutIDForSpec(specTag);
		if lastActiveLayoutIDForSpec then
			local layout = self:GetLayout(lastActiveLayoutIDForSpec);
			if layout then
				return layout;
			end
		end

		for layoutID, layout in self:EnumerateLayouts() do
			if CooldownManagerLayout_GetClassAndSpecTag(layout) == specTag then
				return layout;
			end
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:SwitchToBestLayoutForSpec()
	local layout = self:GetBestLayoutForSpec();
	if layout then
		self:SetActiveLayout(layout);
	else
		self:ClearActiveLayout();
	end
end

-- NOTE: This typically won't cause any pending changes if called, because it's just book-keeping and
-- usually just called when switching layouts or loading layout data.
function CooldownViewerLayoutManagerMixin:SetPreviouslyActiveLayout(layout)
	if not self.lastActiveLayoutIDsPerSpec then
		self.lastActiveLayoutIDsPerSpec = {};
	end

	local specTag = CooldownManagerLayout_GetClassAndSpecTag(layout);
	local layoutID = CooldownManagerLayout_GetID(layout);

	self.lastActiveLayoutIDsPerSpec[specTag] = layoutID;
end

function CooldownViewerLayoutManagerMixin:SetPreviouslyActiveLayoutByName(layoutName, specTag)
	local layout = self:GetLayoutByName(layoutName, specTag);
	if layout then
		self:SetPreviouslyActiveLayout(layout);
	end
end

function CooldownViewerLayoutManagerMixin:SetPreviouslyActiveLayoutForSpecToDefault(specTag)
	if self.lastActiveLayoutIDsPerSpec then
		if specTag then
			self.lastActiveLayoutIDsPerSpec[specTag] = DEFAULT_LAYOUT_ID;
		end
	end
end

function CooldownViewerLayoutManagerMixin:RemovePreviouslyActiveLayout(layout)
	local specTag = CooldownManagerLayout_GetClassAndSpecTag(layout);
	local layoutID = CooldownManagerLayout_GetID(layout);

	if self.lastActiveLayoutIDsPerSpec and self.lastActiveLayoutIDsPerSpec[specTag] == layoutID then
		self.lastActiveLayoutIDsPerSpec[specTag] = nil;
	end
end

function CooldownViewerLayoutManagerMixin:GetPreviouslyActiveLayoutIDForSpec(specTag)
	if self.lastActiveLayoutIDsPerSpec then
		return self.lastActiveLayoutIDsPerSpec[specTag];
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:IsPreviouslyActiveLayoutForSpecDefault(specTag)
	return self:GetPreviouslyActiveLayoutIDForSpec(specTag) == DEFAULT_LAYOUT_ID;
end

function CooldownViewerLayoutManagerMixin:EnumeratePreviouslyActiveLayoutIDs()
	if self.lastActiveLayoutIDsPerSpec then
		return pairs(self.lastActiveLayoutIDsPerSpec);
	end

	return nop;
end

-- Transforms a desired layoutID into one that will be valid for a new layout the current LayoutManager state.
-- Returns the transformed layoutID and a bool indicating whether or not the returned layoutID matches the input.
-- In cases where saved data is being loaded, and the returned ID doesn't match, this should be treated as an
-- error case.
function CooldownViewerLayoutManagerMixin:CheckGetLayoutID(layoutID)
	if type(layoutID) == "number" and not self:GetLayout(layoutID) then
		return layoutID;
	end

	local largestLayoutID = -math.huge;
	if self.layouts then
		for existingLayoutID in pairs(self.layouts) do
			largestLayoutID = math.max(largestLayoutID, existingLayoutID);
		end
	end

	local transformedID = (largestLayoutID == -math.huge) and 1 or (largestLayoutID + 1);
	assertsafe(self:GetLayout(transformedID) == nil, "CheckGetLayoutID found a layoutID that mapped to an existing layout");
	return transformedID;
end

function CooldownViewerLayoutManagerMixin:SetShouldCheckAddLayoutStatus(checkStatus)
	self.shouldCheckAddLayoutStatus = checkStatus;
end

function CooldownViewerLayoutManagerMixin:ShouldCheckAddLayoutStatus()
	return self.shouldCheckAddLayoutStatus;
end

function CooldownViewerLayoutManagerMixin:AddLayout(layoutName, classAndSpecTag, desiredLayoutID)
	assertsafe(classAndSpecTag ~= nil, "Unable to add layout without valid class and spec");

	local addLayoutStatus = self:GetAddLayoutStatus(layoutName);
	if addLayoutStatus ~= Enum.CooldownLayoutStatus.Success then
		return nil, addLayoutStatus;
	end

	local layoutID = self:CheckGetLayoutID(desiredLayoutID);
	local newLayout = CooldownManagerLayout_Create(layoutID, layoutName, classAndSpecTag);
	return self:CheckAddFullLayout(newLayout, desiredLayoutID);
end

function CooldownViewerLayoutManagerMixin:CheckAddFullLayout(layout, desiredLayoutID)
	-- TODO: Check maxed out layouts, this was never really done before.

	local layoutID = CooldownManagerLayout_GetID(layout);
	assertsafe(self:GetLayout(layoutID) == nil, "LayoutID %s already exists", tostring(layoutID));
	self.layouts[layoutID] = layout;

	local isVerboseChange = false;
	self:SetHasPendingChanges(true, isVerboseChange);

	-- NOTE: See GetActiveLayout (when access mode allows creation)
	-- If the caller supplied no name or id, it means this layout was a modification from a default state and should be considered
	-- a "default"/"starter" layout until the user can supply a name. The layout name can be auto-picked at this point, it just needs to
	-- be marked as a "default" layout.
	local explicitName = CooldownManagerLayout_GetNameExplicit(layout);
	local isDefaultLayoutModification = (not explicitName and not desiredLayoutID);
	CooldownManagerLayout_SetIsDefault(layout, isDefaultLayoutModification);

	return layout, Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:ImportLayout(layoutName, layout)
	-- This is copying an existing layout, the layoutInfo on the dialog has already been copied, just need to defer updating the id
	-- in case the user took some other action to add/delete other layouts while this dialog was shown.
	if self:IsValidLayoutName(layoutName) then
		layout = self:EnsureLayoutHasUniqueID(layout);
		CooldownManagerLayout_SetName(layout, layoutName);
		local layoutID = CooldownManagerLayout_GetID(layout);
		return self:CheckAddFullLayout(layout, layoutID);
	end

	return nil, Enum.CooldownLayoutStatus.InvalidLayoutName;
end

function CooldownViewerLayoutManagerMixin:CopyLayout(layout)
	local copy = CopyTable(layout);
	copy.layoutID = self:CheckGetLayoutID(); -- NOTE: Internal detail, maintain parity with CooldownManagerLayout_GetID, ids should ideally be immutable
	return copy;
end

function CooldownViewerLayoutManagerMixin:EnsureLayoutHasUniqueID(layout)
	-- Double check that this layout isn't already managed, otherwise there's more book-keeping to do.
	-- If this layout seems to exist, then copy it so that it's forced to have a unique id.
	local currentLayoutID = CooldownManagerLayout_GetID(layout);
	if self:GetLayout(currentLayoutID) then
		return self:CopyLayout(layout);
	end

	return layout;
end

function CooldownViewerLayoutManagerMixin:SetLayout(layoutID, layout)
	assertsafe(layout.classAndSpecTag ~= nil, "Unable to set layout without valid class and spec, is layout [%s] using correct format?", tostring(layoutID));
	self.layouts[layoutID] = layout;
	return layout;
end

function CooldownViewerLayoutManagerMixin:RemoveLayout(layoutID)
	if layoutID == self:GetActiveLayoutID() then
		self:ClearActiveLayout();
	end

	local layout = self:GetLayout(layoutID);
	if layout then
		self.layouts[layoutID] = nil;
		self:RemovePreviouslyActiveLayout(layout);
		local isVerboseChange = false;
		self:SetHasPendingChanges(true, isVerboseChange);
	end
end

function CooldownViewerLayoutManagerMixin:GetLayout(layoutID)
	local existingLayout = self.layouts[layoutID];
	if existingLayout then
		return existingLayout;
	end

	return nil;
end

-- NOTE: Since layouts can have duplicate names this returns the first one it finds
-- SpecTag can be passed in to help further narrow down the search
function CooldownViewerLayoutManagerMixin:GetLayoutByName(layoutName, specTag)
	for layoutID, layout in self:EnumerateLayouts() do
		if CooldownManagerLayout_GetName(layout) == layoutName and (not specTag or CooldownManagerLayout_GetClassAndSpecTag(layout) == specTag) then
			return layout;
		end
	end
end

function CooldownViewerLayoutManagerMixin:EnumerateLayouts()
	if self.layouts then
		return pairs(self.layouts);
	end

	return nop;
end

function CooldownViewerLayoutManagerMixin:GetCooldownIDDataBlockForLayout(layout, cooldownID, accessMode)
	local allowCreate = (accessMode == Enum.CDMLayoutMode.AllowCreate);

	local infoTable = CooldownManagerLayout_GetCooldownInfo(layout, allowCreate);
	if infoTable then
		if allowCreate and not infoTable[cooldownID] then
			infoTable[cooldownID] = {};
		end

		return infoTable[cooldownID], Enum.CooldownLayoutStatus.Success;
	end

	-- This isn't a failure, it just means that creating an info table isn't desired.
	return nil, Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:GetCooldownIDDataBlock(cooldownID, accessMode)
	local layout, status = self:GetActiveLayout(accessMode);
	if layout then
		return self:GetCooldownIDDataBlockForLayout(layout, cooldownID, accessMode);
	end

	return nil, status;
end

function CooldownViewerLayoutManagerMixin:GetCooldownInfoDataBlock(cooldownInfo, accessMode)
	return self:GetCooldownIDDataBlock(cooldownInfo.cooldownID, accessMode);
end

function CooldownViewerLayoutManagerMixin:RemoveCooldownInfoDataBlock(cooldownInfo)
	-- Only call this if you know the block exists.
	assertsafe(self:GetCooldownInfoDataBlock(cooldownInfo, Enum.CDMLayoutMode.AccessOnly) ~= nil, "Illegal call to RemoveCooldownInfoDataBlock, block must already exist");

	local layout, status = self:GetActiveLayout(Enum.CDMLayoutMode.AccessOnly);
	if layout then
		if layout.cooldownInfo then
			layout.cooldownInfo[cooldownInfo.cooldownID] = nil;
		end
	end

	return status;
end

function CooldownViewerLayoutManagerMixin:GetAlertsForLayout(layout, cooldownID, accessMode)
	local block, status = self:GetCooldownIDDataBlockForLayout(layout, cooldownID, accessMode);
	if block then
		local allowCreate = (accessMode == Enum.CDMLayoutMode.AllowCreate);
		if not block.alerts and allowCreate then
			block.alerts = {};
		end

		return block.alerts, status;
	end

	return nil, status;
end

function CooldownViewerLayoutManagerMixin:GetAlerts(cooldownID, accessMode)
	local layout, status = self:GetActiveLayout(accessMode);
	if layout then
		return self:GetAlertsForLayout(layout, cooldownID, accessMode);
	end

	return nil, status;
end

function CooldownViewerLayoutManagerMixin:GetNumAlerts(cooldownID, accessMode)
	local alerts, status = self:GetAlerts(cooldownID, accessMode);
	if alerts then
		return #alerts, status;
	end

	return 0, status;
end

function CooldownViewerLayoutManagerMixin:SetHasPendingChanges(hasPendingChanges, isVerboseChange)
	self.isVerboseChange = self.isVerboseChange or isVerboseChange;

	if self.hasPendingChanges ~= hasPendingChanges then
		self.hasPendingChanges = hasPendingChanges;
		EventRegistry:TriggerEvent("CooldownViewerSettings.OnPendingChanges", self, hasPendingChanges);
		self:NotifyListeners();
	elseif hasPendingChanges then
		-- If there are pending changes still always let listeners know so they can update.
		self:NotifyListeners();
	end
end

function CooldownViewerLayoutManagerMixin:HasPendingChanges()
	return not not self.hasPendingChanges;
end

function CooldownViewerLayoutManagerMixin:WriteCooldownOrderToActiveLayout(orderedCooldownIDs, accessMode)
	assertsafe(orderedCooldownIDs ~= nil, "Invalid orderedCooldownIDs");

	local layout = self:GetActiveLayout(accessMode);
	if layout then
		self:WriteCooldownOrderToLayout(layout, orderedCooldownIDs);
	end
end

function CooldownViewerLayoutManagerMixin:WriteCooldownOrderToLayout(layout, orderedCooldownIDs)
	-- NOTE: This must be a copy to ensure that tables are never reused because of how the dataProvider
	-- can pass its displayIDs to the current layout, we don't want to directly reference those.
	local currentCooldownIDs = CooldownManagerLayout_GetOrderedCooldownIDs(layout);
	if not currentCooldownIDs or not tCompare(currentCooldownIDs, orderedCooldownIDs) then
		CooldownManagerLayout_SetOrderedCooldownIDs(layout, CopyTable(orderedCooldownIDs));
		local isVerboseChange = true;
		self:SetHasPendingChanges(true, isVerboseChange);
	end
end

function CooldownViewerLayoutManagerMixin:WriteCooldownInfo_KeyValue(cooldownInfo, key, value)
	local staticCooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownInfo.cooldownID);
	local existingCooldownDataBlock = self:GetCooldownInfoDataBlock(cooldownInfo, Enum.CDMLayoutMode.AccessOnly);

	-- If this cooldown no longer exists, but we have save data for it, then nuke that data now.
	if not staticCooldownInfo then
		if existingCooldownDataBlock then
			self:RemoveCooldownInfoDataBlock(cooldownInfo);
			local isVerboseChange = true;
			self:SetHasPendingChanges(true, isVerboseChange);
		end

		return Enum.CooldownLayoutStatus.Success;
	end

	-- At this point, we know that the static data exists and is usable, no longer need to check it.
	local isTryingToSaveDefaultValue = self:GetDataProvider():IsDefaultValue(cooldownInfo.cooldownID, key, value);

	if isTryingToSaveDefaultValue then
		-- When trying to save defaults, the cooldownInfo[key] should match the staticData value, so go ahead and just ensure that now.
		-- NOTE: This couples the layoutManager to the systems that manage the display data
		cooldownInfo[key] = value;

		-- Then clear the key on the saved data if it exists, potentially removing the entire data block, and bail; there's nothing else to do when saving a default.
		if existingCooldownDataBlock then
			existingCooldownDataBlock[key] = nil;
			if not next(existingCooldownDataBlock) then
				self:RemoveCooldownInfoDataBlock(cooldownInfo);
				local isVerboseChange = true;
				self:SetHasPendingChanges(true, isVerboseChange);
			end
		end

		return Enum.CooldownLayoutStatus.Success;
	end

	-- At this point, the value isn't default, so write it to the layout data, creating a new entry and even an entire (working set) layout if necessary.
	local dataBlock = existingCooldownDataBlock;
	if not dataBlock then
		local status;
		dataBlock, status = self:GetCooldownInfoDataBlock(cooldownInfo, Enum.CDMLayoutMode.AllowCreate);
		if status ~= Enum.CooldownLayoutStatus.Success then
			return status;
		end
	end

	if dataBlock and dataBlock[key] ~= value then
		dataBlock[key] = value;
		cooldownInfo[key] = value;
		local isVerboseChange = true;
		self:SetHasPendingChanges(true, isVerboseChange);
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:WriteCooldownInfo_Category(cooldownInfo, category)
	return self:WriteCooldownInfo_KeyValue(cooldownInfo, "category", category);
end

function CooldownViewerLayoutManagerMixin:WriteCooldownCategoryToLayout(layout, cooldownCategory, cooldownIDs)
	for cooldownIndex, cooldownID in pairs(cooldownIDs) do
		local block = self:GetCooldownIDDataBlockForLayout(layout, cooldownID, Enum.CDMLayoutMode.AllowCreate);
		if block then
			block["category"] = cooldownCategory;
		end
	end
end

function CooldownViewerLayoutManagerMixin:WriteCooldownAlertsToLayout(layout, alerts)
	for cooldownID, alertList in pairs(alerts) do
		local blockAlerts = self:GetAlertsForLayout(layout, cooldownID, Enum.CDMLayoutMode.AllowCreate);
		assertsafe(#blockAlerts == 0, "Alerts table should be empty when loading saved data");
		for _, alert in ipairs(alertList) do
			table.insert(blockAlerts, alert);
		end
	end
end

function CooldownViewerLayoutManagerMixin:FindExistingAlert(cooldownID, alert)
	local alerts = self:GetAlerts(cooldownID, Enum.CDMLayoutMode.AccessOnly);

	if alerts then
		for _, existingAlert in ipairs(alerts) do
			if CooldownViewerAlert_Matches(existingAlert, alert) then
				return existingAlert;
			end
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:FindExactAlert(cooldownID, exactAlert)
	local alerts = self:GetAlerts(cooldownID, Enum.CDMLayoutMode.AccessOnly);

	if alerts then
		for _, alert in ipairs(alerts) do
			if exactAlert == alert then
				return alert;
			end
		end
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:AddAlert(cooldownID, alert)
	local status = self:GetAddAlertStatus(cooldownID, alert);
	if status == Enum.CooldownViewerAddAlertStatus.Success then
		local alerts = self:GetAlerts(cooldownID, Enum.CDMLayoutMode.AllowCreate);
		table.insert(alerts, alert);
		local isVerboseChange = true;
		self:SetHasPendingChanges(true, isVerboseChange);
	end

	return status;
end

function CooldownViewerLayoutManagerMixin:UpdateAlert(cooldownID, existingAlert, newAlert)
	local exactAlert = self:FindExactAlert(cooldownID, existingAlert);
	if exactAlert then
		CooldownViewerAlert_Assign(exactAlert, newAlert);
		local isVerboseChange = true;
		self:SetHasPendingChanges(true, isVerboseChange);
	end
end

function CooldownViewerLayoutManagerMixin:RemoveAlert(cooldownID, alert)
	local alerts = self:GetAlerts(cooldownID, Enum.CDMLayoutMode.AccessOnly);

	if alerts then
		for i, existingAlert in ipairs(alerts) do
			if CooldownViewerAlert_Matches(existingAlert, alert)  then
				-- NOTE: There's no need to remove the alerts table now, just leave it empty.
				-- When the layout is serialized, just don't write empty alert tables to saved data.
				table.remove(alerts, i);
				local isVerboseChange = true;
				self:SetHasPendingChanges(true, isVerboseChange);
				break;
			end
		end
	end
end

function CooldownViewerLayoutManagerMixin:RemoveAllAlerts(cooldownID)
	local alerts = self:GetAlerts(cooldownID, Enum.CDMLayoutMode.AccessOnly);

	if alerts then
		-- NOTE: There's no need to remove the alerts table now, just leave it empty.
		-- When the layout is serialized, just don't write empty alert tables to saved data.
		table.wipe(alerts);
	end
end

function CooldownViewerLayoutManagerMixin:DeserializeCooldownInfo(cooldownInfo)
	local block = self:GetCooldownInfoDataBlock(cooldownInfo, Enum.CDMLayoutMode.AccessOnly);
	if block then
		cooldownInfo.category = block.category or cooldownInfo.category;
	end
end

function CooldownViewerLayoutManagerMixin:CreateRestorePoint()
	local activeLayoutID = self:GetActiveLayoutID();
	local activeLayout = self:GetActiveLayout(Enum.CDMLayoutMode.AccessOnly);
	local layoutCopy = activeLayout and CopyTable(activeLayout);
	self.restorePoint = { layoutID = activeLayoutID, layout = layoutCopy };
end

function CooldownViewerLayoutManagerMixin:DestroyRestorePoint()
	self.restorePoint = nil;
end

function CooldownViewerLayoutManagerMixin:CanUseRestorePoint()
	return self.restorePoint ~= nil and self:HasPendingChanges();
end

function CooldownViewerLayoutManagerMixin:ResetToRestorePoint()
	if self.restorePoint then
		local restorePoint = self.restorePoint;

		local activeLayoutID = self:GetActiveLayoutID();
		if activeLayoutID then
			self:ClearActiveLayout();
			self:RemoveLayout(activeLayoutID);
		end

		if restorePoint.layoutID and restorePoint.layout then
			self:SetLayout(restorePoint.layoutID, restorePoint.layout);
			self:SetActiveLayoutByID(restorePoint.layoutID);
		end
	end
end

-- Tell all the listeners that their layouts probably need to be updated because something changed.
-- Heads up: Notifications can be locked if many changes will be made and we want to dial back the number
-- of updates; NotifyListners will be called after calling UnlockNotifications if something tried to
-- NotifyListners while the lock was active.
function CooldownViewerLayoutManagerMixin:NotifyListeners()
	if self:AreNotificationsLocked() then
		self.needsNotificationAfterUnlock = true;
	else
		self.needsNotificationAfterUnlock = false;

		if not self.notificationsCompletelyDisabled then
			assertsafe(not self.notifying, "This is not re-entrant");
			self.notifying = true;
			EventRegistry:TriggerEvent("CooldownViewerSettings.OnDataChanged");
			self.notifying = false;
		end
	end
end

function CooldownViewerLayoutManagerMixin:LockNotifications()
	self.notificationLockCount = (self.notificationLockCount or 0) + 1;
end

function CooldownViewerLayoutManagerMixin:UnlockNotifications(forceNotify)
	self.notificationLockCount = (self.notificationLockCount or 0) - 1;

	assertsafe(self.notificationLockCount >= 0, "CooldownLayoutManager notification lock count unbalanced: %d.", self.notificationLockCount);

	if self.notificationLockCount == 0 and (forceNotify or self.needsNotificationAfterUnlock) then
		self:NotifyListeners();
	end
end

function CooldownViewerLayoutManagerMixin:AreNotificationsLocked()
	return self.notificationLockCount and self.notificationLockCount > 0;
end

function CooldownViewerLayoutManagerMixin:CheckDisableNotifications()
	-- There's a somewhat less than ideal situation here. The dataProvider and layoutManager are coupled because
	-- when external systems need to ask the provider for displayData, the provider needs to load both static data
	-- and reconcile that against the currently active layout.
	-- Since the external system is likely responding to a layout manager "OnDataChanged" notification and the dataProvider
	-- might need to update the currently active layout with reconciled data, this could lead to OnDataChanged being triggered
	-- while OnDataChanged is being processed, nobody likes reentrancy. So, to handle this I am adding the concept of completely
	-- disabling OnDataChanged notifications while this is happening. The catch is that the only time this should be allowed to
	-- be disabled is while an OnDataChanged event is being processed, otherwise, listners will probably want to know about the
	-- updates.
	if self.notifying then
		self.notificationsCompletelyDisabled = true;
	end
end

function CooldownViewerLayoutManagerMixin:EnableNotifications()
	self.notificationsCompletelyDisabled = false;
end

function CooldownViewerLayoutManagerMixin:IsValidLayoutName(proposedLayoutName)
	return proposedLayoutName and proposedLayoutName ~= "" and C_EditMode.IsValidLayoutName(proposedLayoutName);
end

function CooldownViewerLayoutManagerMixin:RenameLayout(layoutID, newLayoutName)
	local layout = self:GetLayout(layoutID);
	if layout then
		if CooldownManagerLayout_GetName(layout) ~= newLayoutName and self:IsValidLayoutName(newLayoutName) then
			CooldownManagerLayout_SetName(layout, newLayoutName);
			local isVerboseChange = true;
			self:SetHasPendingChanges(true, isVerboseChange);
		end
	end
end

function CooldownViewerLayoutManagerMixin:GetMaxLayoutsForType(_layoutType)
	return 5;
end

function CooldownViewerLayoutManagerMixin:GetLayoutCountOfType(layoutType)
	local count = 0;
	for layoutID, layoutInfo in self:EnumerateLayouts() do
		local currentLayoutType = CooldownManagerLayout_GetType(layoutInfo);
		if layoutType == currentLayoutType then
			count = count + 1;
		end
	end

	return count;
end

function CooldownViewerLayoutManagerMixin:AreLayoutsOfTypeMaxed(layoutType)
	return self:GetLayoutCountOfType(layoutType) >= self:GetMaxLayoutsForType(layoutType);
end

function CooldownViewerLayoutManagerMixin:AreLayoutsFullyMaxed()
	-- TODO: Add account layout support.
	return self:AreLayoutsOfTypeMaxed(Enum.CooldownLayoutType.Character) -- and self:AreLayoutsOfTypeMaxed(Enum.CooldownLayoutType.Account);
end

function CooldownViewerLayoutManagerMixin:HasActiveChanges()
	return self:HasPendingChanges(); -- to implement EditMode layout manager API
end

function CooldownViewerLayoutManagerMixin:GetMaxLayoutsErrorText()
	return COOLDOWN_VIEWER_SETTINGS_ADD_ALERT_TOOLTIP_DISABLED_MAXED_LAYOUTS;
end

function CooldownViewerLayoutManagerMixin:CopyLayoutToClipboard(layout)
	if layout then
		local layoutID = CooldownManagerLayout_GetID(layout);
		local layoutData = self:GetSerializer():SerializeLayouts(layoutID);
		if layoutData then
			CopyToClipboard(layoutData);
			return true;
		end
	end

	return false;
end

function CooldownViewerLayoutManagerMixin:CreateLayoutsFromSerializedData(text)
	if type(text) == "string" and #text > 0 then
		local isUserInput = true;
		return self:GetSerializer():DeserializeLayouts(text, isUserInput);
	end

	return nil;
end

function CooldownViewerLayoutManagerMixin:IsCharacterSpecificLayout(layout)
	return true; -- always char-specific for now.
end

function CooldownViewerLayoutManagerMixin:GetLayoutName(layout)
	local layoutName = CooldownManagerLayout_GetName(layout);
	return layoutName;
end

function CooldownViewerLayoutManagerMixin:AreChangesAllowed()
	if self:IsUsingDefaultLayout() and self:AreLayoutsFullyMaxed() then
		return Enum.CooldownLayoutStatus.AttemptToModifyDefaultLayoutWouldCreateTooManyLayouts;
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:GetAddLayoutStatus(layoutName)
	-- During load time, don't worry about this, saved layouts can be loaded no matter what.
	if self:ShouldCheckAddLayoutStatus() then
		-- TODO: Will need to take layout type of character/account into consideration
		if self:AreLayoutsFullyMaxed() then
			return Enum.CooldownLayoutStatus.MaxLayoutsReached;
		end

		if layoutName then
			if not self:IsValidLayoutName(layoutName) then
				return Enum.CooldownLayoutStatus.InvalidLayoutName;
			end
		end
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:GetCooldownOrderChangeStatus(sourceIndex, destIndex, cooldownIDs)
	local changeStatus = self:AreChangesAllowed();
	if changeStatus ~= Enum.CooldownLayoutStatus.Success then
		return changeStatus;
	end

	local len = #cooldownIDs;
	if (sourceIndex <= 0 or sourceIndex > len) or (destIndex <= 0 or destIndex > len) then
		return Enum.CooldownLayoutStatus.InvalidOrderChange;
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:GetCooldownCategoryChangeStatus(_cooldownID, _newCategory)
	-- NOTE: This could be expanded to check categories and other criteria, for now it doesn't check that the category on this cooldown can be reassigned;
	-- only that we're allowed to make layout changes.
	return self:AreChangesAllowed();
end

function CooldownViewerLayoutManagerMixin:GetAddAlertStatus(cooldownID, optAlertToAdd)
	local changeStatus = self:AreChangesAllowed();
	if changeStatus ~= Enum.CooldownLayoutStatus.Success then
		return changeStatus;
	end

	if self:GetNumAlerts(cooldownID, Enum.CDMLayoutMode.AccessOnly) >= self:GetMaxNumAlertsPerItem() then
		return Enum.CooldownLayoutStatus.TooManyAlerts;
	end

	if optAlertToAdd then
		local alertStatus = CooldownViewerAlert_GetAlertStatus(optAlertToAdd);
		if alertStatus ~= Enum.CooldownViewerAddAlertStatus.Success then
			return alertStatus;
		end

		if self:FindExistingAlert(cooldownID, optAlertToAdd) ~= nil then
			return Enum.CooldownViewerAddAlertStatus.AlertAlreadyExists;
		end
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerLayoutManagerMixin:GetMaxNumAlertsPerItem()
	return 3;
end
