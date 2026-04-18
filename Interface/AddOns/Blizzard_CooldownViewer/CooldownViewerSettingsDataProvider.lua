CooldownViewerSettingsDataProviderMixin = {};

function CooldownViewerSettingsDataProviderMixin:Init(layoutManager)
	self:SetLayoutManager(layoutManager);
	self:SwitchToBestLayoutForSpec();

	-- This can be called very easily when the CooldownViewerSettings are hidden
	-- If the player switches specs the last active layout for a spec needs to be updated
	-- in the save data, so ensure that happens and that the PendingChanges on the layout manager are cleared
	local function OnTraitConfigUpdated()
		self:SwitchToBestLayoutForSpec();
		self:GetLayoutManager():SaveLayouts();
	end

	EventRegistry:RegisterFrameEventAndCallback("TRAIT_CONFIG_UPDATED", OnTraitConfigUpdated, self);

	local function RefreshFromExternalUpdate()
		self:MarkDirty();

		local layoutManager = self:GetLayoutManager();
		if layoutManager then
			layoutManager:NotifyListeners();
		end
	end

	EventRegistry:RegisterFrameEventAndCallback("COOLDOWN_VIEWER_TABLE_HOTFIXED", RefreshFromExternalUpdate, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_PVP_TALENT_UPDATE", RefreshFromExternalUpdate, self);
	EventRegistry:RegisterFrameEventAndCallback("SPELLS_CHANGED", RefreshFromExternalUpdate, self);
end

function CooldownViewerSettingsDataProviderMixin:SetLayoutManager(layoutManager)
	self.layoutManager = layoutManager;
end

function CooldownViewerSettingsDataProviderMixin:GetLayoutManager()
	local manager = self.layoutManager;
	return (manager and manager:IsLoaded()) and manager;
end

local cooldownCategories = {
	Enum.CooldownViewerCategory.Essential,
	Enum.CooldownViewerCategory.Utility,
	Enum.CooldownViewerCategory.TrackedBuff,
	Enum.CooldownViewerCategory.TrackedBar,
};

local cooldownCategoryToHiddenCategoryMapping = {
	[Enum.CooldownViewerCategory.Essential] = Enum.CooldownViewerCategory.HiddenSpell,
	[Enum.CooldownViewerCategory.Utility] = Enum.CooldownViewerCategory.HiddenSpell,
	[Enum.CooldownViewerCategory.TrackedBuff] = Enum.CooldownViewerCategory.HiddenAura,
	[Enum.CooldownViewerCategory.TrackedBar] = Enum.CooldownViewerCategory.HiddenAura,
};

-- Because the hidden categories are pseudo-categories, make sure that no valid enum value matches them
do
	local categoriesInverted = tInvert(cooldownCategories);
	assertsafe(categoriesInverted[Enum.CooldownViewerCategory.HiddenSpell] == nil, "CooldownViewerCategory for HiddenSpells has value overlap with valid cooldown category");
	assertsafe(categoriesInverted[Enum.CooldownViewerCategory.HiddenAura] == nil, "CooldownViewerCategory for HiddenAuras category has value overlap with valid cooldown category");

	for _, category in pairs(cooldownCategories) do
		assertsafe(cooldownCategoryToHiddenCategoryMapping[category] ~= nil, "CooldownViewerCategory[%d] is missing its Hidden category equivalent, add a hidden category mapping", category);
	end
end

function CooldownViewerSettingsDataProvider_GetCategories()
	return cooldownCategories;
end

local ALLOW_ALL_COOLDOWNS_IN_SET = true;

function CooldownViewerSettingsDataProviderMixin:GetDisplayData()
	return self.displayData;
end

function CooldownViewerSettingsDataProviderMixin:CheckBuildDisplayData()
	if not self:IsDirty() then
		return;
	end

	local cooldownInfoByID = {};
	local cooldownDefaultsByID = {};
	local defaultOrderedCooldownIDs = {};

	for categoryIndex, cooldownCategory in pairs(CooldownViewerSettingsDataProvider_GetCategories()) do
		local cooldownIDs = C_CooldownViewer.GetCooldownViewerCategorySet(cooldownCategory, ALLOW_ALL_COOLDOWNS_IN_SET);

		for cooldownIndex, cooldownID in ipairs(cooldownIDs) do
			local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID);
			if info then
				-- Experimental, this should disable the cooldown and put it into the right display bucket
				-- It should also allow the saved data to completely override whatever gets set here.
				-- The thing to test, even before moving this into an API somewhere is whether or not marking the provider dirty will overwrite saved data...
				local isDisabled = FlagsUtil.IsSet(info.flags, Enum.CooldownSetSpellFlags.HideByDefault);
				if isDisabled then
					info.category = cooldownCategoryToHiddenCategoryMapping[info.category];
				end

				-- Probably need to check and see that if there's actually saved data that exists for this info in the currently loaded save data that
				-- it is allowed to overwrite whatever is returned from the game at this point...

				-- Store defaults so that we know what to avoid saving
				cooldownDefaultsByID[cooldownID] = { category = info.category, };

				cooldownInfoByID[cooldownID] = info;
				table.insert(defaultOrderedCooldownIDs, cooldownID);
			end
		end
	end

	local layoutManager = self:GetLayoutManager();
	local currentTag = CooldownViewerUtil.GetCurrentClassAndSpecTag();
	local activeLayout = layoutManager and layoutManager:GetActiveLayout();
	local activeLayoutMatchesCurrentSpec = (activeLayout and currentTag) and (CooldownManagerLayout_GetClassAndSpecTag(activeLayout) == currentTag);
	local persistedLayoutOrderedCooldownIDs = activeLayoutMatchesCurrentSpec and CooldownManagerLayout_GetOrderedCooldownIDs(activeLayout);
	local layoutOrderedCooldownIDs = persistedLayoutOrderedCooldownIDs and CopyTable(persistedLayoutOrderedCooldownIDs);

	if layoutManager then
		layoutManager:CheckDisableNotifications();
	end

	if layoutOrderedCooldownIDs then
		-- Ensure there's nothing in saved data that's not in static data (don't save things that cannot exist)
		local invertedDefaultIDs = tInvert(defaultOrderedCooldownIDs); -- NOTE: tInvert returns a copy, it doesn't modify the original.
		for savedIndex = #layoutOrderedCooldownIDs, 1, -1 do
			local savedID = layoutOrderedCooldownIDs[savedIndex];
			if not invertedDefaultIDs[savedID] then
				table.remove(layoutOrderedCooldownIDs, savedIndex);
			end
		end

		-- Ensure that saved data contains all ids in static data (this needs to persist, just write to the end if there are new ones, allow the player to arrange/recategorize later)
		local invertedSavedIDs = tInvert(layoutOrderedCooldownIDs);
		for _, defaultID in ipairs(defaultOrderedCooldownIDs) do
			if not invertedSavedIDs[defaultID] then
				table.insert(layoutOrderedCooldownIDs, defaultID);
			end
		end

		assertsafe(#layoutOrderedCooldownIDs == #defaultOrderedCooldownIDs, "Length of CooldownIDs for saved and display data should match but don't.");
		layoutManager:WriteCooldownOrderToActiveLayout(layoutOrderedCooldownIDs);
	end

	if activeLayoutMatchesCurrentSpec then
		for cooldownID, cooldownInfo in pairs(cooldownInfoByID) do
			-- TODO: Rather than running through all the existing cooldowns in the provider, maybe come up with a way to enumerate all the
			-- cooldown overrides in the layoutManager and update only the relevant ones...maybe six of one, half dozen of the other, not sure yet.
			layoutManager:DeserializeCooldownInfo(cooldownInfo);
		end
	end

	if layoutManager then
		layoutManager:EnableNotifications();
	end

	self.displayDataDirty = false;
	self.displayData = {
		cooldownInfoByID = cooldownInfoByID,
		orderedCooldownIDs = layoutOrderedCooldownIDs or defaultOrderedCooldownIDs,
		defaultOrderedCooldownIDs = defaultOrderedCooldownIDs,
		cooldownDefaultsByID = cooldownDefaultsByID,
	};
end

local function RunDataProviderCallbackThatRequiresLayoutNotifications(dataProvider, callback)
	local layoutManager = dataProvider:GetLayoutManager();
	if layoutManager and dataProvider:GetDisplayData() then
		layoutManager:LockNotifications();

		dataProvider:MarkDirty();
		callback(layoutManager);

		-- Always make sure that a notification is sent after running the callback; even if it didn't result in state changes
		-- other systems still need to know that something needs to be rebuilt.
		local forceNotify = true;
		layoutManager:UnlockNotifications(forceNotify);
	end
end

function CooldownViewerSettingsDataProviderMixin:ResetCurrentToDefaults()
	RunDataProviderCallbackThatRequiresLayoutNotifications(self, function(layoutManager)
		layoutManager:ResetCurrentToDefaults();
	end);
end

-- Non-destructive, just deactivates the current layout, but doesn't delete anything
function CooldownViewerSettingsDataProviderMixin:UseDefaultLayout()
	RunDataProviderCallbackThatRequiresLayoutNotifications(self, function(layoutManager)
		layoutManager:UseDefaultLayout();
	end);
end

function CooldownViewerSettingsDataProviderMixin:ResetToRestorePoint()
	RunDataProviderCallbackThatRequiresLayoutNotifications(self, function(layoutManager)
		layoutManager:ResetToRestorePoint();
	end);
end

function CooldownViewerSettingsDataProviderMixin:SwitchToBestLayoutForSpec()
	RunDataProviderCallbackThatRequiresLayoutNotifications(self, function(layoutManager)
		layoutManager:SwitchToBestLayoutForSpec();
	end);
end

function CooldownViewerSettingsDataProviderMixin:SetActiveLayoutByID(layoutID)
	RunDataProviderCallbackThatRequiresLayoutNotifications(self, function(layoutManager)
		layoutManager:SetActiveLayoutByID(layoutID);
	end);
end

function CooldownViewerSettingsDataProviderMixin:MarkDirty()
	self.displayDataDirty = true;
end

function CooldownViewerSettingsDataProviderMixin:IsDirty()
	return self.displayDataDirty or not self:GetDisplayData();
end

function CooldownViewerSettingsDataProviderMixin:GetOrderedCooldownIDs()
	self:CheckBuildDisplayData();
	local displayData = self:GetDisplayData();
	return displayData and displayData.orderedCooldownIDs;
end

function CooldownViewerSettingsDataProviderMixin:GetDefaultOrderedCooldownIDs()
	self:CheckBuildDisplayData();
	local displayData = self:GetDisplayData();
	return displayData and displayData.defaultOrderedCooldownIDs;
end

function CooldownViewerSettingsDataProviderMixin:GetOrderedCooldownIDsForCategory(category, allowUnknown)
	local cooldownIDs = {};
	for index, cooldownID in ipairs(self:GetOrderedCooldownIDs()) do
		local cooldownInfo = self:GetCooldownInfoForID(cooldownID);
		if cooldownInfo.category == category and (cooldownInfo.isKnown or allowUnknown) then
			table.insert(cooldownIDs, cooldownID);
		end
	end

	return cooldownIDs;
end

function CooldownViewerSettingsDataProviderMixin:GetCooldownInfoForID(cooldownID)
	self:CheckBuildDisplayData();
	local displayData = self:GetDisplayData();
	return displayData and displayData.cooldownInfoByID[cooldownID];
end

function CooldownViewerSettingsDataProviderMixin:ChangeOrderIndex(sourceIndex, destIndex, reorderOffset)
	local cooldownIDs = self:GetOrderedCooldownIDs();
	local layoutManager = self:GetLayoutManager();
	if layoutManager and sourceIndex ~= destIndex then
		local orderChangeStatus = layoutManager:GetCooldownOrderChangeStatus(sourceIndex, destIndex, cooldownIDs);
		if orderChangeStatus ~= Enum.CooldownLayoutStatus.Success then
			return orderChangeStatus;
		end

		-- Lookup the objects before attempting any reordering.
		-- Also note that the order may remain the same, maybe just the category is changing (e.g. drag 1 from essential -> disabled, now order is still 1.
		-- Then drag 2 to after 1 in disabled, the order of 2 remains the same as well, it just becomes disabled.)
		local sourceID = cooldownIDs[sourceIndex];
		local destID = cooldownIDs[destIndex];

		layoutManager:LockNotifications();

		local categoryChangeStatus = self:ChangeCooldownInfoCategoryByID(sourceID, destID);
		if categoryChangeStatus ~= Enum.CooldownLayoutStatus.Success then
			layoutManager:UnlockNotifications();
			return categoryChangeStatus;
		end

		-- NOTE: Reorder offset is intended to mean "insert before" or "insert after" destIndex, reduce shenanigans by clamping.
		reorderOffset = Clamp(reorderOffset, 0, 1);

		local finalDestIndex = math.max(destIndex + reorderOffset, 1);

		if finalDestIndex > 0 and sourceIndex ~= finalDestIndex then
			-- If a cooldown info is moving "later" in the list then because the source is removed from the container first
			-- (collapsing everything that follows it) the dest must be reduced by one to account for that.
			if sourceIndex < finalDestIndex then
				finalDestIndex = finalDestIndex - 1;
			end

			table.remove(cooldownIDs, sourceIndex);
			table.insert(cooldownIDs, finalDestIndex, sourceID);

			layoutManager:WriteCooldownOrderToActiveLayout(cooldownIDs, Enum.CDMLayoutMode.AllowCreate);
		end

		layoutManager:UnlockNotifications();
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerSettingsDataProviderMixin:SetCooldownToCategory(sourceCooldownID, category)
	local sourceInfo = self:GetCooldownInfoForID(sourceCooldownID);
	if sourceInfo then
		return self:ChangeCooldownInfoInternal(sourceInfo, category);
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerSettingsDataProviderMixin:ChangeCooldownInfoCategoryByID(sourceCooldownID, destCooldownID)
	local sourceInfo = self:GetCooldownInfoForID(sourceCooldownID);
	local destInfo = self:GetCooldownInfoForID(destCooldownID);

	if sourceInfo and destInfo then
		return self:ChangeCooldownInfoInternal(sourceInfo, destInfo.category);
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerSettingsDataProviderMixin:ChangeCooldownInfoInternal(info, category)
	local layoutManager = self:GetLayoutManager();
	if layoutManager then
		local status = layoutManager:GetCooldownCategoryChangeStatus(info.cooldownID, category);
		if status ~= Enum.CooldownLayoutStatus.Success then
			return status;
		end

		return layoutManager:WriteCooldownInfo_Category(info, category);
	end

	return Enum.CooldownLayoutStatus.Success;
end

function CooldownViewerSettingsDataProviderMixin:GetCooldownDefaults(cooldownID)
	self:CheckBuildDisplayData();
	local displayData = self:GetDisplayData();
	return displayData and displayData.cooldownDefaultsByID[cooldownID];
end

function CooldownViewerSettingsDataProviderMixin:IsDefaultValue(cooldownID, key, value)
	local defaults = self:GetCooldownDefaults(cooldownID);
	if defaults then
		return value == defaults[key];
	end
end

CooldownViewerDataProvider = CreateFromMixins(CooldownViewerSettingsDataProviderMixin);
