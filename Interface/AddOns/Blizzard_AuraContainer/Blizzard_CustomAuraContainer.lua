local function IsNonNegativeIntegerOrInfinity(value)
	return value == math.huge or (type(value) == "number" and value >= 0 and value == math.floor(value));
end

local function IsNonNegativeNumber(value)
	return type(value) == "number" and value >= 0;
end

local function IsNonEmptyString(value)
	return type(value) == "string" and value ~= "";
end

local function ValidateTemplateNames(templateNames)
	if templateNames ~= nil then
		assert(type(templateNames) == "table", "templateNames must be a table or nil.");

		for _index, templateName in ipairs(templateNames) do
			assert(type(templateName) == "string", "templateNames must contain only strings.");
		end
	end
end

local function ValidateInitializeFrame(initializeFrame)
	if initializeFrame ~= nil then
		assert(type(initializeFrame) == "function", "initializeFrame must be a function or nil.");
	end
end

local function ValidateSortOptions(sortMethod, sortDirection)
	assert(EnumUtil.IsValid(AuraContainerSortMethod, sortMethod), "sortMethod must be a valid AuraContainerSortMethod.");
	assert(EnumUtil.IsValid(AuraContainerSortDirection, sortDirection), "sortDirection must be a valid AuraContainerSortDirection.");
end

local function ValidateMaxFrameCount(maxFrameCount)
	assert(IsNonNegativeIntegerOrInfinity(maxFrameCount), "maxFrameCount must be a non-negative integer or infinity.");
end

local function ValidateAuraProcessingPolicy(policy)
	assert(EnumUtil.IsValid(CustomAuraContainerAuraProcessingPolicy, policy), "policy must be a valid CustomAuraContainerAuraProcessingPolicy.");
end

local function ValidateProcessAuraPolicyOptions(options)
	assert(options == nil or type(options) == "table", "options must be a table or nil.");

	if options == nil then
		return;
	end

	if options.displayOnlyDispellableDebuffs ~= nil then
		assert(type(options.displayOnlyDispellableDebuffs) == "boolean", "displayOnlyDispellableDebuffs must be a boolean or nil.");
	end

	if options.ignoreBuffs ~= nil then
		assert(type(options.ignoreBuffs) == "boolean", "ignoreBuffs must be a boolean or nil.");
	end

	if options.ignoreDebuffs ~= nil then
		assert(type(options.ignoreDebuffs) == "boolean", "ignoreDebuffs must be a boolean or nil.");
	end

	if options.ignoreDispelDebuffs ~= nil then
		assert(type(options.ignoreDispelDebuffs) == "boolean", "ignoreDispelDebuffs must be a boolean or nil.");
	end
end

local function ValidateProcessedAuraType(processedAuraType)
	-- Probably should redefine this enum without the "None" element; skipping for now.
	assert(EnumUtil.IsValid(AuraUtil.AuraUpdateChangedType, processedAuraType), "processedAuraType must be a valid AuraUpdateChangedType.");
	assert(processedAuraType ~= AuraUtil.AuraUpdateChangedType.None, "processedAuraType must be a Buff, Debuff, or Dispel.");
end

local function ValidateCandidateFilters(candidateFilters)
	assert(candidateFilters == nil or type(candidateFilters) == "table", "candidateFilters must be a table or nil.");

	if candidateFilters == nil then
		return;
	end

	-- Map of permitted spell IDs. Any spell IDs outside of this set are ignored
	-- and will not be visible in the container. Spell ID matching is only permitted
	-- for helpful buffs on assistable units, and harmful buffs on non-assistable
	-- units.
	if candidateFilters.includeSpellIDs ~= nil then
		assert(type(candidateFilters.includeSpellIDs) == "table", "includeSpellIDs must be a table or nil");
	end

	-- As above, but as a map of excluded spell IDs.
	if candidateFilters.excludeSpellIDs ~= nil then
		assert(type(candidateFilters.excludeSpellIDs) == "table", "excludeSpellIDs must be a table or nil");
	end

	-- Map of permitted dispel type names (eg. "Magic"). Any dispel types not
	-- contained in this set will not be visible in the container.
	if candidateFilters.includeDispelTypes ~= nil then
		assert(type(candidateFilters.includeDispelTypes) == "table", "includeDispelTypes must be a table or nil");
	end

	-- As above, but as a map of excluded dispel type names.
	if candidateFilters.excludeDispelTypes ~= nil then
		assert(type(candidateFilters.excludeDispelTypes) == "table", "excludeDispelTypes must be a table or nil");
	end

	-- Maximum upper bound (inclusive) for aura durations to be visible in the
	-- container. This is derived from maximum aura duration, not remaining
	-- duration. Any non-nil value implicitly hides permanent auras.
	if candidateFilters.maxDuration ~= nil then
		assert(IsNonNegativeNumber(candidateFilters.maxDuration), "maxDuration must be a non-negative number or nil.");
	end

	-- Restricts visible auras to those that match enum values returned by the
	-- AuraUtil.ProcessAura function (see AuraUtil.AuraUpdateChangedType).
	--
	-- This requires the use of SetAuraProcessingPolicy with type ProcessAura.
	-- If other policies are used, any non-nil value here will hide all auras.
	if candidateFilters.processedAuraType ~= nil then
		ValidateProcessedAuraType(candidateFilters.processedAuraType);
	end

	-- Additional filters for booleans on auras.
	local BooleanOnlyCandidateFilterFields =
	{
		"isFromPlayerOrPlayerPet",
		"isRoleAura",
		"isPriorityAura",
		"isStealable",
		"nameplateShowAll",
		"nameplateShowPersonal",
		"canApplyAura",
		"isBossAura",
		"isBossOrRoleAura"
	};

	for _index, fieldName in ipairs(BooleanOnlyCandidateFilterFields) do
		if candidateFilters[fieldName] ~= nil then
			assert(type(candidateFilters[fieldName]) == "boolean", fieldName .. " must be a boolean or nil.");
		end
	end
end

local function ValidateAuraGroupLayoutOptions(layoutOptions)
	if layoutOptions == nil then
		return;
	end

	assert(type(layoutOptions) == "table", "layout must be a table or nil.");

	if layoutOptions.elementSpacing ~= nil then
		assert(type(layoutOptions.elementSpacing) == "number", "elementSpacing must be a number.");
	end

	if layoutOptions.lineSpacing ~= nil then
		assert(type(layoutOptions.lineSpacing) == "number", "lineSpacing must be a number.");
	end

	if layoutOptions.groupSpacing ~= nil then
		assert(type(layoutOptions.groupSpacing) == "number", "groupSpacing must be a number.");
	end

	if layoutOptions.groupLineSpacing ~= nil then
		assert(type(layoutOptions.groupLineSpacing) == "number", "groupLineSpacing must be a number.");
	end

	if layoutOptions.forceNewLine ~= nil then
		assert(type(layoutOptions.forceNewLine) == "boolean", "forceNewLine must be a boolean.");
	end

	if layoutOptions.elementWidth ~= nil then
		assert(IsNonNegativeNumber(layoutOptions.elementWidth), "elementWidth must be a non-negative number.");
	end

	if layoutOptions.elementHeight ~= nil then
		assert(IsNonNegativeNumber(layoutOptions.elementHeight), "elementHeight must be a non-negative number.");
	end

	if layoutOptions.layoutIndex ~= nil then
		assert(type(layoutOptions.layoutIndex) == "number", "layoutIndex must be a number.");
	end
end

local function ValidateAuraDisplayOptions(options)
	ValidateTemplateNames(options.templateNames);
	ValidateInitializeFrame(options.initializeFrame);
	ValidateCandidateFilters(options.candidateFilters);
	ValidateSortOptions(options.sortMethod, options.sortDirection);
end

local function ValidateAddAuraGroupOptions(options)
	ValidateAuraDisplayOptions(options);
	ValidateAuraGroupLayoutOptions(options.layout);
	ValidateMaxFrameCount(options.maxFrameCount);
end

local function ValidateAddAuraSlotOptions(options)
	ValidateAuraDisplayOptions(options);
end

local function ValidateItemEnchantmentSlot(itemEnchantmentSlot)
	assert(EnumUtil.IsValid(AuraContainerItemEnchantmentSlot, itemEnchantmentSlot), "itemEnchantmentSlot must be a valid AuraContainerItemEnchantmentSlot.");
end

local function ValidateAddItemEnchantmentOptions(options)
	ValidateTemplateNames(options.templateNames);
	ValidateInitializeFrame(options.initializeFrame);

	assert(options.hidePermanent == nil or type(options.hidePermanent) == "boolean", "hidePermanent must be a boolean or nil.");
end

local function ValidateItemEnchantmentSortOptions(sortMethod, sortDirection)
	assert(EnumUtil.IsValid(AuraContainerItemEnchantmentSortMethod, sortMethod), "sortMethod must be a valid AuraContainerItemEnchantmentSortMethod.");
	assert(EnumUtil.IsValid(AuraContainerSortDirection, sortDirection), "sortDirection must be a valid AuraContainerSortDirection.");
end

local function ValidateItemEnchantmentLayoutOptions(layoutOptions)
	ValidateAuraGroupLayoutOptions(layoutOptions);

	if layoutOptions == nil then
		return;
	end

	if layoutOptions.placement ~= nil then
		assert(EnumUtil.IsValid(CustomAuraContainerItemEnchantmentPlacement, layoutOptions.placement), "placement must be a valid CustomAuraContainerItemEnchantmentPlacement.");
	end
end

local function CopyAndValidateInboundTable(untrustedOptions, defaultOptions, validationFunction)
	local mergedOptions = {};
	MergeTable(mergedOptions, defaultOptions);

	if untrustedOptions ~= nil then
		MergeTable(mergedOptions, securecopy(untrustedOptions));
	end

	validationFunction(mergedOptions);
	return mergedOptions;
end

local function GetInboundCandidateFilters(untrustedCandidateFilters)
	return CopyAndValidateInboundTable(untrustedCandidateFilters, {}, ValidateCandidateFilters);
end

local function GetInboundProcessAuraPolicyOptions(untrustedOptions)
	return CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerProcessAuraPolicyDefaultOptions, ValidateProcessAuraPolicyOptions);
end

local function GetInboundAuraGroupLayoutOptions(untrustedOptions)
	return CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerGroupLayoutDefaultOptions, ValidateAuraGroupLayoutOptions);
end

local function GetInboundAddAuraGroupOptions(untrustedOptions)
	local options = CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerGroupDefaultOptions, ValidateAddAuraGroupOptions);
	options.layout = GetInboundAuraGroupLayoutOptions(options.layout);
	return options;
end

local function GetInboundAddAuraSlotOptions(untrustedOptions)
	return CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerSlotDefaultOptions, ValidateAddAuraSlotOptions);
end

local function GetInboundItemEnchantmentLayoutOptions(untrustedOptions)
	return CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerItemEnchantmentLayoutDefaultOptions, ValidateItemEnchantmentLayoutOptions);
end

local function GetInboundAddItemEnchantmentOptions(untrustedOptions)
	return CopyAndValidateInboundTable(untrustedOptions, CustomAuraContainerItemEnchantmentDefaultOptions, ValidateAddItemEnchantmentOptions);
end

local function GetRequiredAuraGroup(container, groupKey)
	local auraGroup = container:GetAuraGroup(groupKey);
	assertf(auraGroup ~= nil, "aura group '%s' was not found with this key.", tostring(groupKey));

	return auraGroup;
end

local function GetRequiredAuraSlot(container, slotKey)
	local auraSlot = container:GetAuraSlot(slotKey);
	assertf(auraSlot ~= nil, "aura slot '%s' was not found with this key.", tostring(slotKey));

	return auraSlot;
end

CustomAuraContainerSharedMixin = CreateFromMixins(ManagedAuraContainerSharedMixin);

function CustomAuraContainerSharedMixin:AddAuraGroup(groupKey, filterString, options)
	assert(IsNonEmptyString(groupKey), "groupKey must be a non-empty string.");
	assert(AuraUtil.IsValidFilterString(filterString));
	assertf(not self:HasAuraGroup(groupKey), "aura group '%s' already exists with this key.", tostring(groupKey));

	options = GetInboundAddAuraGroupOptions(options);

	local frameProvider = AuraContainerUtil.CreateCustomFrameProvider(self,
		{
			batchSize = CustomAuraContainerConstants.FrameCreationBatchSize,
			templateNames = options.templateNames,
			initializeFrame = options.initializeFrame,
			accessRestrictions = CustomAuraContainerConstants.AccessRestrictionFlags,
		});

	-- Allocate a batch of frames up-front to make it harder to observe the
	-- transition between zero/non-zero auras on setup.

	frameProvider:CreateFrameBatch();

	local auraGroup = self:RegisterAuraGroup(groupKey,
		{
			auraComparator = AuraContainerUtil.GetAuraSortComparator(options.sortMethod, options.sortDirection),
			candidateFilters = options.candidateFilters,
			filterString = filterString,
			frameProvider = frameProvider,
			maxFrameCount = options.maxFrameCount,
		});

	self.layoutOptionsByAuraGroup[auraGroup] = options.layout;

	-- Aura groups resize the container, and so adding any to a group should
	-- disable OnSizeChanged. This has the side effect of making it impossible
	-- for user addons to anchor other frames that don't have this aspect
	-- applied to the container once a group is set - for that, they can
	-- inherit DisableUntrustedLayoutScriptsTemplate on those frames at the
	-- point of creation to opt-in to this aspect.

	self:AddForbiddenAspects(Enum.ForbiddenAspect.UntrustedLayoutScriptExecution);

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function CustomAuraContainerSharedMixin:HasAuraGroup(groupKey)
	-- Exposing private interface.
	return ManagedAuraContainerPrivateMixin.HasAuraGroup(self, groupKey);
end

function CustomAuraContainerSharedMixin:GetAuraGroupFrame(groupKey, frameIndex)
	-- Non-existent groups are modeled as empty groups for the purpose of
	-- frame enumeration and access.
	local auraGroup = self:GetAuraGroup(groupKey);
	local auraFrame;

	if auraGroup then
		auraFrame = auraGroup:GetFrameProvider():GetOwnedFrame(frameIndex);
	end

	return auraFrame;
end

function CustomAuraContainerSharedMixin:GetAuraGroupFrameCount(groupKey)
	local auraGroup = self:GetAuraGroup(groupKey);
	local auraFrameCount = 0;

	if auraGroup then
		auraFrameCount = auraGroup:GetFrameProvider():GetOwnedFrameCount();
	end

	return auraFrameCount;
end

function CustomAuraContainerSharedMixin:IsAuraGroupEnabled(groupKey)
	return GetRequiredAuraGroup(self, groupKey):IsEnabled();
end

function CustomAuraContainerSharedMixin:SetAuraGroupEnabled(groupKey, enabled)
	assert(type(enabled) == "boolean", "enabled must be a boolean.");

	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	ManagedAuraContainerPrivateMixin.SetAuraGroupEnabled(self, auraGroup, enabled);
end

function CustomAuraContainerSharedMixin:SetAuraGroupFilterString(groupKey, filterString)
	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	assert(AuraUtil.IsValidFilterString(filterString));

	if auraGroup:GetFilterString() ~= filterString then
		auraGroup:SetFilterString(filterString);
		self:RebuildAuraParseFilters();
		self:UpdateAllAuras();
	end
end

function CustomAuraContainerSharedMixin:SetAuraGroupMaxFrameCount(groupKey, maxFrameCount)
	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	ValidateMaxFrameCount(maxFrameCount);

	if auraGroup:GetMaxFrameCount() ~= maxFrameCount then
		auraGroup:SetMaxFrameCount(maxFrameCount);
		self:RequestFrameAssignmentRefresh();
	end
end

function CustomAuraContainerSharedMixin:SetAuraGroupCandidateFilters(groupKey, candidateFilters)
	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	candidateFilters = GetInboundCandidateFilters(candidateFilters);

	auraGroup:SetCandidateFilters(candidateFilters);

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function CustomAuraContainerSharedMixin:SetAuraGroupSortMethod(groupKey, sortMethod, sortDirection)
	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	ValidateSortOptions(sortMethod, sortDirection);

	auraGroup:SetAuraComparator(AuraContainerUtil.GetAuraSortComparator(sortMethod, sortDirection));
	self:RequestFrameAssignmentRefresh();
end

function CustomAuraContainerSharedMixin:SetAuraGroupLayout(groupKey, layoutOptions)
	local auraGroup = GetRequiredAuraGroup(self, groupKey);
	layoutOptions = GetInboundAuraGroupLayoutOptions(layoutOptions);

	self.layoutOptionsByAuraGroup[auraGroup] = layoutOptions;
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
end

function CustomAuraContainerSharedMixin:AddAuraSlot(slotKey, filterString, options)
	assert(IsNonEmptyString(slotKey), "slotKey must be a non-empty string.");
	assert(AuraUtil.IsValidFilterString(filterString));
	assertf(not self:HasAuraSlot(slotKey), "aura slot '%s' already exists with this key.", tostring(slotKey));

	options = GetInboundAddAuraSlotOptions(options);

	local auraFrame = self:CreateAuraSlotFrame(options);

	self:RegisterAuraSlot(slotKey,
		{
			filterString = filterString,
			auraFrame = auraFrame,
			candidateFilters = options.candidateFilters,
			auraComparator = AuraContainerUtil.GetAuraSortComparator(options.sortMethod, options.sortDirection),
		});

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();

	-- Translates to public object reference automatically for inbound calls.
	return auraFrame;
end

function CustomAuraContainerSharedMixin:GetAuraSlotFrame(slotKey)
	local auraSlot = self:GetAuraSlot(slotKey);

	-- Translates to public object reference automatically for inbound calls.
	return auraSlot and auraSlot:GetAuraFrame() or nil;
end

function CustomAuraContainerSharedMixin:IsAuraSlotEnabled(slotKey)
	return GetRequiredAuraSlot(self, slotKey):IsEnabled();
end

function CustomAuraContainerSharedMixin:SetAuraSlotEnabled(slotKey, enabled)
	assert(type(enabled) == "boolean", "enabled must be a boolean.");

	local auraSlot = GetRequiredAuraSlot(self, slotKey);
	ManagedAuraContainerPrivateMixin.SetAuraSlotEnabled(self, auraSlot, enabled);
end

function CustomAuraContainerSharedMixin:SetAuraSlotFilterString(slotKey, filterString)
	local auraSlot = GetRequiredAuraSlot(self, slotKey);
	assert(AuraUtil.IsValidFilterString(filterString));

	if auraSlot:GetFilterString() ~= filterString then
		auraSlot:SetFilterString(filterString);
		self:RebuildAuraParseFilters();
		self:UpdateAllAuras();
	end
end

function CustomAuraContainerSharedMixin:SetAuraSlotCandidateFilters(slotKey, candidateFilters)
	local auraSlot = GetRequiredAuraSlot(self, slotKey);
	candidateFilters = GetInboundCandidateFilters(candidateFilters);

	auraSlot:SetCandidateFilters(candidateFilters);

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function CustomAuraContainerSharedMixin:SetAuraSlotSortMethod(slotKey, sortMethod, sortDirection)
	local auraSlot = GetRequiredAuraSlot(self, slotKey);
	ValidateSortOptions(sortMethod, sortDirection);

	auraSlot:SetAuraComparator(AuraContainerUtil.GetAuraSortComparator(sortMethod, sortDirection));
	self:RequestFrameAssignmentRefresh();
end

function CustomAuraContainerSharedMixin:AddItemEnchantment(itemEnchantmentSlot, options)
	ValidateItemEnchantmentSlot(itemEnchantmentSlot);
	assertf(not self:HasItemEnchantment(itemEnchantmentSlot), "item enchantment already exists with this slot.");

	options = GetInboundAddItemEnchantmentOptions(options);

	local auraFrame = self:CreateAuraSlotFrame(options);

	self:RegisterItemEnchantment(itemEnchantmentSlot,
		{
			auraFrame = auraFrame;
			hidePermanent = options.hidePermanent;
		});

	self:RequestFrameAssignmentRefresh();
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);

	-- Translates to public object reference automatically for inbound calls.
	return auraFrame;
end

function CustomAuraContainerSharedMixin:GetItemEnchantmentFrame(itemEnchantmentSlot)
	local itemEnchantment = self:GetItemEnchantment(itemEnchantmentSlot);

	-- Translates to public object reference automatically for inbound calls.
	return itemEnchantment and itemEnchantment:GetAuraFrame() or nil;
end

function CustomAuraContainerSharedMixin:IsItemEnchantmentEnabled(itemEnchantmentSlot)
	local itemEnchantment = self:GetItemEnchantment(itemEnchantmentSlot);
	assertf(itemEnchantment ~= nil, "item enchantment was not found with this slot.");
	return itemEnchantment:IsEnabled();
end

function CustomAuraContainerSharedMixin:SetItemEnchantmentEnabled(itemEnchantmentSlot, enabled)
	ValidateItemEnchantmentSlot(itemEnchantmentSlot);
	assert(type(enabled) == "boolean", "enabled must be a boolean.");

	local itemEnchantment = self:GetItemEnchantment(itemEnchantmentSlot);
	assertf(itemEnchantment ~= nil, "item enchantment was not found with this slot.");

	ManagedAuraContainerPrivateMixin.SetItemEnchantmentEnabled(self, itemEnchantment, enabled);
end

function CustomAuraContainerSharedMixin:SetItemEnchantmentSortMethod(sortMethod, sortDirection)
	ValidateItemEnchantmentSortOptions(sortMethod, sortDirection);

	ManagedAuraContainerPrivateMixin.SetItemEnchantmentSortMethod(self, sortMethod, sortDirection);
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
end

function CustomAuraContainerSharedMixin:SetItemEnchantmentLayout(layoutOptions)
	self.itemEnchantmentLayoutOptions = GetInboundItemEnchantmentLayoutOptions(layoutOptions);
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
end

function CustomAuraContainerSharedMixin:ResetItemEnchantmentLayout()
	self:ResetItemEnchantmentLayoutInternal();
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayout);
end

function CustomAuraContainerSharedMixin:GetAuraProcessingPolicy()
	-- Omitting options for now. If someone comes here to add them, please
	-- securecopy() them on the way out. Thank you.
	return self.auraProcessingPolicy;
end

function CustomAuraContainerSharedMixin:SetAuraProcessingPolicy(policy, options)
	ValidateAuraProcessingPolicy(policy);

	if policy == CustomAuraContainerAuraProcessingPolicy.ProcessAura then
		options = GetInboundProcessAuraPolicyOptions(options);

		self.auraProcessingPolicy = policy;
		self.processAuraPolicyOptions = options;
	else
		assert(options == nil, "options must be nil for this aura processing policy.");

		self.auraProcessingPolicy = policy;
		self.processAuraPolicyOptions = nil;
	end

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

CustomAuraContainerInboundMixin = CreateFromMixins(ManagedAuraContainerInboundMixin, AuraContainerFlowLayoutInboundMixin, CustomAuraContainerSharedMixin);
CustomAuraContainerPrivateMixin = CreateFromMixins(ManagedAuraContainerPrivateMixin, AuraContainerFlowLayoutPrivateMixin, CustomAuraContainerSharedMixin);

function CustomAuraContainerPrivateMixin:OnLoad()
	self.auraProcessingPolicy = CustomAuraContainerAuraProcessingPolicy.None;
	self.layoutOptionsByAuraGroup = {};
	self.flowLayout = CreateAndInitFromMixin(CustomAuraContainerFlowLayoutMixin);
	self.flowLayoutGroups = {};
	self.processAuraPolicyOptions = nil;

	self:ResetItemEnchantmentLayoutInternal();
	self:ApplyFlowLayoutDefaults(self.flowLayout);
	self:MarkDirty(AuraContainerDirtyMask.All);
end

local FullAuraRefreshEvents =
{
	["PLAYER_ENTERING_WORLD"] = true,
	["PLAYER_LEAVING_WORLD"] = true,
	["PLAYER_REGEN_DISABLED"] = true,
	["PLAYER_REGEN_ENABLED"] = true,
	["PLAYER_SPECIALIZATION_CHANGED"] = true,
	["UNIT_FACTION"] = true,
	["UNIT_FLAGS"] = true,
};

function CustomAuraContainerPrivateMixin:OnEvent_Intrinsic(event, ...)
	ManagedAuraContainerPrivateMixin.OnEvent_Intrinsic(self, event, ...);

	if FullAuraRefreshEvents[event] then
		self:UpdateAllAuras();
	end
end

function CustomAuraContainerPrivateMixin:GetDynamicFrameEvents()
	local frameEvents = ManagedAuraContainerPrivateMixin.GetDynamicFrameEvents(self);

	if self.auraProcessingPolicy == CustomAuraContainerAuraProcessingPolicy.ProcessAura then
		frameEvents["PLAYER_ENTERING_WORLD"] = true;
		frameEvents["PLAYER_LEAVING_WORLD"] = true;
		frameEvents["PLAYER_REGEN_DISABLED"] = true;
		frameEvents["PLAYER_REGEN_ENABLED"] = true;
		frameEvents["PLAYER_SPECIALIZATION_CHANGED"] = true;
	end

	return frameEvents;
end

function CustomAuraContainerPrivateMixin:GetDynamicUnitEvents()
	local unitEvents = ManagedAuraContainerPrivateMixin.GetDynamicUnitEvents(self);
	local unitToken = self:GetUnit();

	for _index, auraGroup in self:EnumerateAuraGroups() do
		if auraGroup:IsEnabled() then
			AuraContainerUtil.AppendCandidateFilterUnitEvents(unitEvents, auraGroup:GetCandidateFilters(), unitToken);
		end
	end

	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			AuraContainerUtil.AppendCandidateFilterUnitEvents(unitEvents, auraSlot:GetCandidateFilters(), unitToken);
		end
	end

	return unitEvents;
end

function CustomAuraContainerPrivateMixin:ClearAuraGroups()
	-- Intentionally not exposed via the inbound interface for now at least;
	-- as we internally manage pools of frames clearing aura groups would
	-- have the effect of making those frames irrecoverable. Instead, prefer
	-- allowing users of this container to reconfigure attributes of filters
	-- where possible.

	ManagedAuraContainerPrivateMixin.ClearAuraGroups(self);
	self.layoutOptionsByAuraGroup = {};

	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function CustomAuraContainerPrivateMixin:ClearItemEnchantments()
	ManagedAuraContainerPrivateMixin.ClearItemEnchantments(self);
	self:MarkDirty(AuraContainerDirtyMask.AuraFrameLayoutGroups);
end

function CustomAuraContainerPrivateMixin:ApplyAuraMetadata(unitToken, auraData, auraSource)
	auraData.casterGUID = auraSource:GetAuraCasterGUID(unitToken, auraData.auraInstanceID);

	if self.auraProcessingPolicy == CustomAuraContainerAuraProcessingPolicy.ProcessAura then
		local options = self.processAuraPolicyOptions;

		-- Can be inspected via candidate filters.
		auraData.processedAuraType = AuraUtil.ProcessAura(auraData,
				options.displayOnlyDispellableDebuffs,
				options.ignoreBuffs,
				options.ignoreDebuffs,
				options.ignoreDispelDebuffs);
	end
end

function CustomAuraContainerPrivateMixin:GetFlowLayoutGroupDescriptions()
	local descriptions = {};

	for index, auraGroup in self:EnumerateAuraGroups() do
		if auraGroup:IsEnabled() then
			local layoutOptions = self.layoutOptionsByAuraGroup[auraGroup];

			local description = {};
			-- Closures are intentional because aura processing replaces each
			-- group's visible frame list during refresh.
			description.elements = function() return auraGroup:GetFramesByIndex(); end;
			description.layoutIndex = layoutOptions.layoutIndex;
			description.layoutOptions = layoutOptions;
			description.registrationIndex = index;

			table.insert(descriptions, description);
		end
	end

	if self:HasAnyEnabledItemEnchantments() then
		local layoutOptions = self.itemEnchantmentLayoutOptions;

		local description = {};
		description.elements = function() return self:GetActiveItemEnchantmentFrames(); end;
		description.layoutIndex = layoutOptions.layoutIndex;
		description.layoutOptions = layoutOptions;

		-- Placement support is retained as a convenience over layout indices
		-- and defines a fallback registration order for sorting.
		if layoutOptions.placement == CustomAuraContainerItemEnchantmentPlacement.AfterAuraGroups then
			description.registrationIndex = math.huge;
		else
			description.registrationIndex = -math.huge;
		end

		table.insert(descriptions, description);
	end

	return descriptions;
end

local function GetEffectiveFlowLayoutIndex(description)
	return description.layoutIndex or description.registrationIndex or math.huge;
end


local function SortFlowLayoutDescriptions(a, b)
	local layoutIndexA = GetEffectiveFlowLayoutIndex(a);
	local layoutIndexB = GetEffectiveFlowLayoutIndex(b);

	if layoutIndexA ~= layoutIndexB then
		return layoutIndexA < layoutIndexB;
	end

	return a.registrationIndex < b.registrationIndex;
end

function CustomAuraContainerPrivateMixin:RebuildLayoutGroups()
	local flowLayoutGroupDescriptions = self:GetFlowLayoutGroupDescriptions();
	local flowLayoutGroups = table.create(#flowLayoutGroupDescriptions);

	table.sort(flowLayoutGroupDescriptions, SortFlowLayoutDescriptions);

	for index, description in ipairs(flowLayoutGroupDescriptions) do
		local layoutOptions = description.layoutOptions;

		flowLayoutGroups[index] = {
			elements = description.elements,
			elementSpacing = layoutOptions.elementSpacing,
			lineSpacing = layoutOptions.lineSpacing,
			groupSpacing = layoutOptions.groupSpacing,
			groupLineSpacing = layoutOptions.groupLineSpacing,
			forceNewLine = layoutOptions.forceNewLine,
			elementWidth = layoutOptions.elementWidth,
			elementHeight = layoutOptions.elementHeight,
		};
	end

	self.flowLayoutGroups = flowLayoutGroups;
end

function CustomAuraContainerPrivateMixin:ResetItemEnchantmentLayoutInternal()
	self.itemEnchantmentLayoutOptions = GetInboundItemEnchantmentLayoutOptions();
end

function CustomAuraContainerPrivateMixin:ApplyFlowLayoutDefaults(flowLayout)
	flowLayout:SetLayoutAxis(CustomAuraContainerLayoutDefaults.axis);
	flowLayout:SetAnchorPoint(CustomAuraContainerLayoutDefaults.anchorPoint);
	flowLayout:SetGrowthDirection(CustomAuraContainerLayoutDefaults.horizontalGrowthDirection, CustomAuraContainerLayoutDefaults.verticalGrowthDirection);
	flowLayout:SetPadding(CustomAuraContainerLayoutDefaults.paddingLeft, CustomAuraContainerLayoutDefaults.paddingRight, CustomAuraContainerLayoutDefaults.paddingTop, CustomAuraContainerLayoutDefaults.paddingBottom);
	flowLayout:SetMaximumLineSize(CustomAuraContainerLayoutDefaults.maximumLineSize);
end

function CustomAuraContainerPrivateMixin:ApplyLayout()
	self:ApplyFlowLayout();
end

function CustomAuraContainerPrivateMixin:CreateAuraSlotFrame(options)
	-- Something about hammers and nails probably applies here. Frame creation
	-- should probably be lifted out of the provider and to a util, but this
	-- is also fine.
	local frameProvider = AuraContainerUtil.CreateCustomFrameProvider(self,
	{
		batchSize = 1,
		templateNames = options.templateNames,
		initializeFrame = options.initializeFrame,
		accessRestrictions = CustomAuraContainerConstants.AccessRestrictionFlags,
	});

	return frameProvider:AcquireFrame();
end

CustomAuraContainerFlowLayoutMixin = CreateFromMixins(AnchorUtil.FlowLayoutMixin);

function CustomAuraContainerFlowLayoutMixin:GetElementSize(_container, element, group)
	local width, height = element:GetSize();
	return group.elementWidth or width, group.elementHeight or height;
end

function CustomAuraContainerFlowLayoutMixin:ApplyElementLayout(container, element, anchorPoint, offsetX, offsetY, _width, _height)
	element:ClearAllPoints();
	element:SetPoint(secretwrap(anchorPoint, container, anchorPoint, offsetX, offsetY));
end

function CustomAuraContainerFlowLayoutMixin:OnLayoutComplete(container, width, height, _hasPlacedElement, _lineCount)
	container:SetSize(secretwrap(width, height));
end
