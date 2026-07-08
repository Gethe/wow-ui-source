AuraContainerDirtyFlag =
{
	None = nil,
	-- Re-read aura data from the active sources.
	ParseAuras = bit.lshift(1, 0),
	 -- Clear existing aura-to-frame ownership before frames are rebound.
	ResetAuraFrames = bit.lshift(1, 1),
	-- Match the current aura data to aura frames.
	RefreshAuraFrames = bit.lshift(1, 2),
	-- Update frame state that does not require rebinding auras.
	RefreshAuraFrameDisplay = bit.lshift(1, 3),
	-- Rebuild the frame groups used as layout input.
	RebuildLayoutGroups = bit.lshift(1, 4),
	-- Position and size the aura frames.
	ApplyLayout = bit.lshift(1, 5),
};

-- Dirty masks describe common update requests; each mask may include one or
-- more phases from AuraContainerDirtyFlag.
AuraContainerDirtyMask =
{
	None = 0,
	All = Flags_CreateMaskFromTable(AuraContainerDirtyFlag),

	-- Rebuild all aura data and reset frame ownership.
	FullAuraRebuild = Flags_CreateMask(AuraContainerDirtyFlag.ParseAuras, AuraContainerDirtyFlag.ResetAuraFrames, AuraContainerDirtyFlag.RebuildLayoutGroups),

	-- Match auras to frames again.
	AuraFrameAssignments = Flags_CreateMask(AuraContainerDirtyFlag.RefreshAuraFrames),

	-- Refresh display-only state on existing frames. Intended for cases where
	-- containers need to propagate settings to aura frames for updates but
	-- don't want to rebuild everything from scratch.
	AuraFrameDisplay = Flags_CreateMask(AuraContainerDirtyFlag.RefreshAuraFrameDisplay),

	-- Rebuild layout groups, then apply layout.
	AuraFrameLayoutGroups = Flags_CreateMask(AuraContainerDirtyFlag.RebuildLayoutGroups, AuraContainerDirtyFlag.ApplyLayout),

	-- Apply layout again.
	AuraFrameLayout = Flags_CreateMask(AuraContainerDirtyFlag.ApplyLayout),
};

ManagedAuraContainerSharedMixin = CreateFromMixins(AuraContainerSharedMixin);

function ManagedAuraContainerSharedMixin:UpdateAllAuras()
	self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
end

ManagedAuraContainerInboundMixin = CreateFromMixins(AuraContainerInboundMixin, ManagedAuraContainerSharedMixin);
ManagedAuraContainerPrivateMixin = CreateFromMixins(AuraContainerAuraGroupOwnerMixin, AuraContainerAuraSlotOwnerMixin, AuraContainerItemEnchantmentOwnerMixin, AuraContainerPrivateMixin, ManagedAuraContainerSharedMixin, DirtyPhaseMixin);

function ManagedAuraContainerPrivateMixin:OnLoad_Intrinsic()
	AuraContainerPrivateMixin.OnLoad_Intrinsic(self);

	self:InitDirtyPhases();

	self:SetDirtyPhases({
		{ flag = AuraContainerDirtyFlag.ParseAuras, handler = function() return self:ProcessParseAuras(); end, },
		{ flag = AuraContainerDirtyFlag.ResetAuraFrames, handler = function() return self:ProcessResetAuraFrames(); end, },
		{ flag = AuraContainerDirtyFlag.RefreshAuraFrames, handler = function() return self:ProcessRefreshAuraFrames(); end, },
		{ flag = AuraContainerDirtyFlag.RefreshAuraFrameDisplay, handler = function() return self:ProcessRefreshAuraFrameDisplay(); end, },
		{ flag = AuraContainerDirtyFlag.RebuildLayoutGroups, handler = function() return self:ProcessRebuildLayoutGroups(); end, },
		{ flag = AuraContainerDirtyFlag.ApplyLayout, handler = function() return self:ProcessApplyLayout(); end, },
	});

	self.auraGroupManager = AuraContainerUtil.CreateAuraGroupManager(self);
	self.auraSlotManager = AuraContainerUtil.CreateAuraSlotManager(self);
	self.itemEnchantmentManager = AuraContainerUtil.CreateItemEnchantmentManager(self);

	-- Local cache of aura data structures keyed by aura instance ID.
	self.aurasByInstanceID = {};
	-- Array of full-update parse filters and their consumers.
	self.auraParseFilters = {};
	-- As above, but structured as a map keyed by filter string.
	self.auraParseFiltersByFilterString = {};
	-- If true, source data exclusively from a fake data provider for edit mode.
	self.useEditModeSource = false;
end

function ManagedAuraContainerPrivateMixin:OnUpdate(_elapsedTime)
	self:ProcessDirtyFlags();
end

function ManagedAuraContainerPrivateMixin:OnDirtyChanged(dirty)
	if dirty then
		self:SetOnUpdateMode(Enum.OnUpdateMode.RunWhenVisibleOnce);
	end
end

function ManagedAuraContainerPrivateMixin:OnUnitAuraUpdate(unitToken, unitAuraUpdateInfo)
	if self:ShouldUseEditModeSource() then
		return;
	end

	self:ProcessUnitAuraUpdate(unitToken, unitAuraUpdateInfo, AuraContainerPublicAuraSource);
end

function ManagedAuraContainerPrivateMixin:OnUnitPrivateAuraUpdate(unitToken, unitAuraUpdateInfo)
	if self:ShouldUseEditModeSource() then
		return;
	end

	self:ProcessUnitAuraUpdate(unitToken, unitAuraUpdateInfo, AuraContainerPrivateAuraSource);
end

function ManagedAuraContainerPrivateMixin:OnAuraDataProviderSwitch(useRealDataProvider)
	self:SetUseEditModeSource(not useRealDataProvider);
end

function ManagedAuraContainerPrivateMixin:ShouldRegisterForUnitAuraEvents()
	-- Only process UNIT_AURA or private aura events if we've got things to
	-- render them into.
	return self.auraGroupManager:HasAnyAuraGroups() or self.auraSlotManager:HasAnyAuraSlots();
end

function ManagedAuraContainerPrivateMixin:ShouldRegisterForPrivateAuraEvents()
	return self:ShouldRegisterForUnitAuraEvents() and self:ShouldIncludePrivateAuraSource();
end

function ManagedAuraContainerPrivateMixin:ShouldIncludePrivateAuraSource()
	return true;
end

function ManagedAuraContainerPrivateMixin:ShouldUseEditModeSource()
	return self.useEditModeSource;
end

function ManagedAuraContainerPrivateMixin:SetUseEditModeSource(useEditModeSource)
	useEditModeSource = useEditModeSource == true;

	if self.useEditModeSource ~= useEditModeSource then
		self.useEditModeSource = useEditModeSource;
		self:UpdateAllAuras();
	end
end

function ManagedAuraContainerPrivateMixin:GetAuraSources()
	if self:ShouldUseEditModeSource() then
		return AuraContainerAuraSourceLists.EditMode;
	elseif self:ShouldIncludePrivateAuraSource() then
		return AuraContainerAuraSourceLists.PublicAndPrivate;
	end

	return AuraContainerAuraSourceLists.PublicOnly;
end

function ManagedAuraContainerPrivateMixin:EnumerateAuraSources()
	return ipairs(self:GetAuraSources());
end

function ManagedAuraContainerPrivateMixin:OnAuraGroupsChanged()
	self:UpdateEventRegistrations();
	self:RebuildAuraParseFilters();
end

function ManagedAuraContainerPrivateMixin:InitializeAuraGroupFrame(_auraGroup, auraFrame, unitToken, auraData)
	auraFrame:SetAuraInstance(unitToken, auraData);
	auraFrame:Show();
end

function ManagedAuraContainerPrivateMixin:UpdateAuraGroupFrame(_auraGroup, auraFrame, unitToken, auraData)
	auraFrame:UpdateAuraInstance(unitToken, auraData);
end

function ManagedAuraContainerPrivateMixin:RegisterAuraGroup(groupKey, description)
	return self.auraGroupManager:RegisterAuraGroup(groupKey, description);
end

function ManagedAuraContainerPrivateMixin:UnregisterAuraGroup(groupKey)
	self.auraGroupManager:UnregisterAuraGroup(groupKey);
end

function ManagedAuraContainerPrivateMixin:ClearAuraGroups()
	self.auraGroupManager:ClearAuraGroups();
end

function ManagedAuraContainerPrivateMixin:HasAuraGroup(groupKey)
	return self.auraGroupManager:HasAuraGroup(groupKey);
end

function ManagedAuraContainerPrivateMixin:GetAuraGroup(groupKey)
	return self.auraGroupManager:GetAuraGroup(groupKey);
end

function ManagedAuraContainerPrivateMixin:EnumerateAuraGroups()
	return self.auraGroupManager:EnumerateAuraGroups();
end

function ManagedAuraContainerPrivateMixin:RefreshDirtyAuraGroups()
	return self.auraGroupManager:RefreshDirtyAuraGroups(self:GetUnit());
end

function ManagedAuraContainerPrivateMixin:OnAuraSlotsChanged()
	self:UpdateEventRegistrations();
	self:RebuildAuraParseFilters();
end

function ManagedAuraContainerPrivateMixin:InitializeAuraSlotFrame(_auraSlot, auraFrame, unitToken, auraData)
	auraFrame:SetAuraInstance(unitToken, auraData);
	auraFrame:Show();
end

function ManagedAuraContainerPrivateMixin:UpdateAuraSlotFrame(_auraSlot, auraFrame, unitToken, auraData)
	auraFrame:UpdateAuraInstance(unitToken, auraData);
end

function ManagedAuraContainerPrivateMixin:ClearAuraSlotFrame(_auraSlot, auraFrame)
	auraFrame:ClearAuraInstance();
	auraFrame:Hide();
end

function ManagedAuraContainerPrivateMixin:RegisterAuraSlot(slotKey, description)
	return self.auraSlotManager:RegisterAuraSlot(slotKey, description);
end

function ManagedAuraContainerPrivateMixin:UnregisterAuraSlot(slotKey)
	self.auraSlotManager:UnregisterAuraSlot(slotKey);
end

function ManagedAuraContainerPrivateMixin:ClearAuraSlots()
	self.auraSlotManager:ClearAuraSlots();
end

function ManagedAuraContainerPrivateMixin:HasAuraSlot(slotKey)
	return self.auraSlotManager:HasAuraSlot(slotKey);
end

function ManagedAuraContainerPrivateMixin:GetAuraSlot(slotKey)
	return self.auraSlotManager:GetAuraSlot(slotKey);
end

function ManagedAuraContainerPrivateMixin:EnumerateAuraSlots()
	return self.auraSlotManager:EnumerateAuraSlots();
end

function ManagedAuraContainerPrivateMixin:RefreshDirtyAuraSlots()
	return self.auraSlotManager:RefreshDirtyAuraSlots(self:GetUnit());
end

function ManagedAuraContainerPrivateMixin:OnItemEnchantmentsChanged()
	self:UpdateEventRegistrations();
end

function ManagedAuraContainerPrivateMixin:InitializeItemEnchantmentFrame(_itemEnchantment, auraFrame, unitToken, auraData)
	auraFrame:SetAuraInstance(unitToken, auraData);
	auraFrame:Show();
end

function ManagedAuraContainerPrivateMixin:UpdateItemEnchantmentFrame(_itemEnchantment, auraFrame, unitToken, auraData)
	auraFrame:UpdateAuraInstance(unitToken, auraData);
end

function ManagedAuraContainerPrivateMixin:ClearItemEnchantmentFrame(_itemEnchantment, auraFrame)
	auraFrame:ClearAuraInstance();
	auraFrame:Hide();
end

function ManagedAuraContainerPrivateMixin:RegisterItemEnchantment(itemEnchantmentSlot, description)
	return self.itemEnchantmentManager:RegisterItemEnchantment(itemEnchantmentSlot, description);
end

function ManagedAuraContainerPrivateMixin:UnregisterItemEnchantment(itemEnchantmentSlot)
	self.itemEnchantmentManager:UnregisterItemEnchantment(itemEnchantmentSlot);
end

function ManagedAuraContainerPrivateMixin:ClearItemEnchantments()
	self.itemEnchantmentManager:ClearItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:HasItemEnchantment(itemEnchantmentSlot)
	return self.itemEnchantmentManager:HasItemEnchantment(itemEnchantmentSlot);
end

function ManagedAuraContainerPrivateMixin:HasAnyItemEnchantments()
	return self.itemEnchantmentManager:HasAnyItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:GetItemEnchantment(itemEnchantmentSlot)
	return self.itemEnchantmentManager:GetItemEnchantment(itemEnchantmentSlot);
end

function ManagedAuraContainerPrivateMixin:GetActiveItemEnchantmentFrames()
	return self.itemEnchantmentManager:GetActiveItemEnchantmentFrames();
end

function ManagedAuraContainerPrivateMixin:EnumerateItemEnchantments()
	return self.itemEnchantmentManager:EnumerateItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:SetItemEnchantmentSortMethod(sortMethod, sortDirection)
	self.itemEnchantmentManager:SetSortMethod(sortMethod, sortDirection);
end

function ManagedAuraContainerPrivateMixin:RefreshItemEnchantments()
	local refreshResult = self.itemEnchantmentManager:RefreshItemEnchantments();
	local dirtyFlags = self:ProcessItemEnchantmentRefreshResult(refreshResult);

	if dirtyFlags ~= AuraContainerDirtyFlag.None then
		self:MarkDirty(dirtyFlags);
	end

	return refreshResult;
end

function ManagedAuraContainerPrivateMixin:ProcessItemEnchantmentRefreshResult(refreshResult)
	return self:ProcessAuraFrameRefreshResult(refreshResult);
end

function ManagedAuraContainerPrivateMixin:ShouldRegisterForItemEnchantmentEvents()
	return self.itemEnchantmentManager:HasAnyItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:OnWeaponEnchantChanged()
	self:RefreshItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:OnWeaponSlotChanged()
	self:RefreshItemEnchantments();
end

function ManagedAuraContainerPrivateMixin:ProcessUnitAuraUpdate(unitToken, unitAuraUpdateInfo, auraSource)
	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
		-- Full updates defer the rebuild as, for example, if a unit's public
		-- auras require a full update, the private ones will probably also
		-- call into here as well.
		self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
		return;
	end

	local auraGroupManager = self.auraGroupManager:HasAnyAuraGroups() and self.auraGroupManager or nil;
	local auraSlotManager = self.auraSlotManager:HasAnyAuraSlots() and self.auraSlotManager or nil;
	local aurasChanged = false;

	if unitAuraUpdateInfo.addedAuras ~= nil then
		for _index, auraData in ipairs(unitAuraUpdateInfo.addedAuras) do
			self:PrepareAuraData(auraData, auraSource);
			self:SetCachedAuraData(auraData);

			if auraGroupManager then
				aurasChanged = auraGroupManager:AddAura(unitToken, auraData) or aurasChanged;
			end

			if auraSlotManager then
				aurasChanged = auraSlotManager:AddAura(unitToken, auraData) or aurasChanged;
			end
		end
	end

	if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
		for _index, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
			local auraData = self:FetchAuraDataByAuraInstanceID(unitToken, auraInstanceID, auraSource);
			self:UpdateCachedAuraData(auraInstanceID, auraData);

			if auraGroupManager then
				aurasChanged = auraGroupManager:UpdateAura(unitToken, auraInstanceID, auraData) or aurasChanged;
			end

			if auraSlotManager then
				aurasChanged = auraSlotManager:UpdateAura(unitToken, auraInstanceID, auraData) or aurasChanged;
			end
		end
	end

	if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
		for _index, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
			self:RemoveCachedAuraData(auraInstanceID);

			if auraGroupManager then
				aurasChanged = auraGroupManager:RemoveAura(unitToken, auraInstanceID) or aurasChanged;
			end

			if auraSlotManager then
				aurasChanged = auraSlotManager:RemoveAura(unitToken, auraInstanceID) or aurasChanged;
			end
		end
	end

	if aurasChanged then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameAssignments);
	end
end

function ManagedAuraContainerPrivateMixin:RebuildAuraParseFilters()
	self.auraParseFilters = {};
	self.auraParseFiltersByFilterString = {};

	-- Aura parse filters are effectively a list of consumers - ie. individual
	-- aura groups or slots - packed into arrays that are grouped by deduplicated
	-- filter strings.
	--
	-- The intent here is to avoid unnecessary aura queries on full updates; if
	-- you've got two+ groups or slots that both use the same filter string then
	-- we only read the aura instances for that string a single time, rather
	-- than re-querying the same data.
	--
	-- The setup here is that we go over our update managers and tell them to
	-- call back to us (in the RegisterAuraParseConsumer function below) the
	-- with information on the consumers and what filter string to key against.

	self.auraGroupManager:RegisterAuraParseConsumers(self);
	self.auraSlotManager:RegisterAuraParseConsumers(self);
end

function ManagedAuraContainerPrivateMixin:RegisterAuraParseConsumer(filterString, manager, consumer)
	local auraParseFilter = self:GetOrCreateAuraParseFilter(filterString);
	table.insert(auraParseFilter.registrants, { manager = manager, consumer = consumer });
end

function ManagedAuraContainerPrivateMixin:GetOrCreateAuraParseFilter(filterString)
	-- Aura filters are deduplicated by exact filter string. We don't go to
	-- the lengths of supporting equivalent strings with different token
	-- ordering.

	local auraParseFilter = self.auraParseFiltersByFilterString[filterString];

	if auraParseFilter == nil then
		auraParseFilter = {
			filterString = filterString;
			registrants = {};
		};

		self.auraParseFiltersByFilterString[filterString] = auraParseFilter;
		table.insert(self.auraParseFilters, auraParseFilter);
	end

	return auraParseFilter;
end

function ManagedAuraContainerPrivateMixin:EnumerateAuraParseFilters()
	return ipairs(self.auraParseFilters);
end

function ManagedAuraContainerPrivateMixin:ClearCachedAuraData()
	self.aurasByInstanceID = {};
end

function ManagedAuraContainerPrivateMixin:SetCachedAuraData(auraData)
	self.aurasByInstanceID[auraData.auraInstanceID] = auraData;
end

function ManagedAuraContainerPrivateMixin:UpdateCachedAuraData(auraInstanceID, auraData)
	if auraData then
		self:SetCachedAuraData(auraData);
	else
		self:RemoveCachedAuraData(auraInstanceID);
	end
end

function ManagedAuraContainerPrivateMixin:RemoveCachedAuraData(auraInstanceID)
	self.aurasByInstanceID[auraInstanceID] = nil;
end

function ManagedAuraContainerPrivateMixin:GetCachedAuraData(auraInstanceID)
	return self.aurasByInstanceID[auraInstanceID];
end

function ManagedAuraContainerPrivateMixin:GetOrFetchAuraDataByAuraInstanceID(unitToken, auraInstanceID, auraSource)
	local auraData = self:GetCachedAuraData(auraInstanceID);

	if auraData == nil then
		auraData = self:FetchAuraDataByAuraInstanceID(unitToken, auraInstanceID, auraSource);

		if auraData ~= nil then
			self:SetCachedAuraData(auraData);
		end
	end

	return auraData;
end

function ManagedAuraContainerPrivateMixin:FetchAuraDataByAuraInstanceID(unitToken, auraInstanceID, auraSource)
	local auraData = auraSource:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID);

	if auraData ~= nil then
		self:PrepareAuraData(auraData, auraSource);
	end

	return auraData;
end

function ManagedAuraContainerPrivateMixin:PrepareAuraData(auraData, auraSource)
	auraSource:ApplySourceMetadata(auraData);
	self:ApplyAuraMetadata(auraData);
end

function ManagedAuraContainerPrivateMixin:ApplyAuraMetadata(_auraData)
	-- Override in the container to add container-specific aura metadata before
	-- group membership is checked. This is a good place to apply calls to
	-- AuraUtil.ProcessAura (and store the result on the aura data itself).
end

function ManagedAuraContainerPrivateMixin:ParseAllAuras()
	self:ClearCachedAuraData();
	self.auraGroupManager:ClearAllAuras();
	self.auraSlotManager:ClearAuraSlotCandidates();

	local unitToken = self:GetUnit();

	for _sourceIndex, auraSource in self:EnumerateAuraSources() do
		for _filterIndex, auraParseFilter in self:EnumerateAuraParseFilters() do
			local auraInstanceIDs, hasMatchedFilterString = auraSource:GetAllAuraInstanceIDs(unitToken, auraParseFilter.filterString);

			for _auraIndex, auraInstanceID in ipairs(auraInstanceIDs) do
				local auraData = self:GetOrFetchAuraDataByAuraInstanceID(unitToken, auraInstanceID, auraSource);

				if auraData ~= nil then
					for _registrantIndex, registrant in ipairs(auraParseFilter.registrants) do
						registrant.manager:ProcessParsedAura(registrant.consumer, unitToken, auraData, hasMatchedFilterString);
					end
				end
			end
		end
	end
end

function ManagedAuraContainerPrivateMixin:ProcessParseAuras()
	self:ParseAllAuras();

	return AuraContainerDirtyFlag.RefreshAuraFrames;
end

function ManagedAuraContainerPrivateMixin:ProcessResetAuraFrames()
	self:ResetAuraFrames();

	return AuraContainerDirtyFlag.RefreshAuraFrames;
end

function ManagedAuraContainerPrivateMixin:ProcessRefreshAuraFrames()
	local refreshResult = self:RefreshAuraFrames();
	return self:ProcessAuraFrameRefreshResult(refreshResult);
end

function ManagedAuraContainerPrivateMixin:ProcessAuraFrameRefreshResult(refreshResult)
	-- Override in containers if different downstream dirty flags should be set
	-- in response to an aura frame refresh.
	--
	-- By default, frame assignment changes only require layout to be re-applied.
	-- Containers that rebuild layout groups or otherwise respond to visibility
	-- changes can opt in to processing that flag.

	if FlagsUtil.IsSet(refreshResult, AuraContainerFrameRefreshResult.FrameAssignmentsChanged) then
		return AuraContainerDirtyFlag.ApplyLayout;
	end

	return AuraContainerDirtyFlag.None;
end

function ManagedAuraContainerPrivateMixin:ProcessRefreshAuraFrameDisplay()
	self:RefreshAuraFrameDisplay();
	return AuraContainerDirtyFlag.None;
end

function ManagedAuraContainerPrivateMixin:ProcessRebuildLayoutGroups()
	self:RebuildLayoutGroups();
	return AuraContainerDirtyFlag.ApplyLayout;
end

function ManagedAuraContainerPrivateMixin:ProcessApplyLayout()
	self:ApplyLayout();
	return AuraContainerDirtyFlag.None;
end

function ManagedAuraContainerPrivateMixin:ResetAuraFrames()
	-- This is primarily intended for managers that implement pooled groups
	-- rather than fixed assignments. Hence, no work is done here for slot
	-- or enchantments.
	self.auraGroupManager:ResetAuraFrames();
	self:OnAuraFramesReset();
end

function ManagedAuraContainerPrivateMixin:RefreshAuraFrames()
	local refreshResult = self:RefreshDirtyAuraGroups();
	refreshResult = FlagsUtil.Combine(refreshResult, self:RefreshDirtyAuraSlots(), FlagsUtilConstants.CombineShouldSet);
	return refreshResult;
end

function ManagedAuraContainerPrivateMixin:RefreshAuraFrameDisplay()
	-- Override to update frame state without rebinding auras.
end

function ManagedAuraContainerPrivateMixin:RebuildLayoutGroups()
	-- Override to rebuild the frame groups used by layout.
end

function ManagedAuraContainerPrivateMixin:ApplyLayout()
	-- Override to position and size aura frames.
end

function ManagedAuraContainerPrivateMixin:OnAuraFramesReset()
	-- Override in the container to reset state after frame ownership is cleared.
end
