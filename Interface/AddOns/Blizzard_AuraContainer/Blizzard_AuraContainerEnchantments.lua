
-- Item enchantments are fixed player-owned display sources, such as temporary
-- enchantments on main-hand, off-hand, or ranged items. They are represented as
-- aura-button-compatible data, but do not participate in aura parsing,
-- candidate filters, aura groups, or aura slots.

local ItemEnchantmentUnitToken = "player";

local function GetExpirationTimeSeconds(enchantmentInfo)
	if enchantmentInfo.hasExpirationTime then
		return GetTime() + (enchantmentInfo.remainingTimeMs / 1000);
	end

	return 0;
end

local function GetDurationSeconds(enchantmentInfo)
	if enchantmentInfo.hasExpirationTime then
		return enchantmentInfo.remainingTimeMs / 1000;
	end

	return 0;
end

AuraContainerItemEnchantmentManagerMixin = {};

function AuraContainerItemEnchantmentManagerMixin:Init(owner)
	self.owner = owner;
	self.itemEnchantments = {};
	self.itemEnchantmentsBySlot = {};

	self.activeItemEnchantments = {};
	self.activeItemEnchantmentFrames = {};
	self.sortMethod = AuraContainerItemEnchantmentSortMethod.Slot;
	self.sortDirection = AuraContainerSortDirection.Normal;
end

function AuraContainerItemEnchantmentManagerMixin:GetSortMethod()
	return self.sortMethod;
end

function AuraContainerItemEnchantmentManagerMixin:GetSortDirection()
	return self.sortDirection;
end

function AuraContainerItemEnchantmentManagerMixin:SetSortMethod(sortMethod, sortDirection)
	sortDirection = sortDirection or AuraContainerSortDirection.Normal;

	assert(EnumUtil.IsValid(AuraContainerItemEnchantmentSortMethod, sortMethod), "sortMethod must be a valid AuraContainerItemEnchantmentSortMethod.");
	assert(EnumUtil.IsValid(AuraContainerSortDirection, sortDirection), "sortDirection must be a valid AuraContainerSortDirection.");

	if self.sortMethod ~= sortMethod or self.sortDirection ~= sortDirection then
		self.sortMethod = sortMethod;
		self.sortDirection = sortDirection;
		self:RebuildActiveItemEnchantments();
	end
end

function AuraContainerItemEnchantmentManagerMixin:RegisterItemEnchantment(itemEnchantmentSlot, description)
	assert(EnumUtil.IsValid(AuraContainerItemEnchantmentSlot, itemEnchantmentSlot), "itemEnchantmentSlot must be a valid AuraContainerItemEnchantmentSlot.");
	assert(self.itemEnchantmentsBySlot[itemEnchantmentSlot] == nil, "An item enchantment already exists with this slot.");
	assert(type(description) == "table", "description must be a table.");

	local itemEnchantment = AuraContainerUtil.CreateItemEnchantment(itemEnchantmentSlot, description);
	self.itemEnchantmentsBySlot[itemEnchantmentSlot] = itemEnchantment;
	table.insert(self.itemEnchantments, itemEnchantment);

	self:SignalItemEnchantmentsChanged();

	return itemEnchantment;
end

function AuraContainerItemEnchantmentManagerMixin:UnregisterItemEnchantment(itemEnchantmentSlot)
	local itemEnchantment = self.itemEnchantmentsBySlot[itemEnchantmentSlot];

	if itemEnchantment ~= nil then
		self:ResetFrameAssignmentForItemEnchantment(itemEnchantment);
		self.itemEnchantmentsBySlot[itemEnchantmentSlot] = nil;
		table.removevalue(self.itemEnchantments, itemEnchantment);
		self:RebuildActiveItemEnchantments();
		self:SignalItemEnchantmentsChanged();
	end
end

function AuraContainerItemEnchantmentManagerMixin:ClearItemEnchantments()
	for _index, itemEnchantment in self:EnumerateItemEnchantments() do
		self:ClearItemEnchantmentFrame(itemEnchantment);
	end

	self.itemEnchantments = {};
	self.itemEnchantmentsBySlot = {};
	self.activeItemEnchantments = {};
	self.activeItemEnchantmentFrames = {};

	self:SignalItemEnchantmentsChanged();
end

function AuraContainerItemEnchantmentManagerMixin:SetItemEnchantmentEnabled(itemEnchantment, enabled)
	enabled = (enabled == true);

	if itemEnchantment:IsEnabled() ~= enabled then
		itemEnchantment:SetEnabled(enabled);

		if not enabled then
			self:ResetFrameAssignmentForItemEnchantment(itemEnchantment);
		end

		self:RebuildActiveItemEnchantments();
		self:SignalItemEnchantmentsChanged();
	end
end

function AuraContainerItemEnchantmentManagerMixin:SignalItemEnchantmentsChanged()
	self.owner:OnItemEnchantmentsChanged();
end

function AuraContainerItemEnchantmentManagerMixin:HasItemEnchantment(itemEnchantmentSlot)
	return self.itemEnchantmentsBySlot[itemEnchantmentSlot] ~= nil;
end

function AuraContainerItemEnchantmentManagerMixin:HasAnyItemEnchantments()
	return self.itemEnchantments[1] ~= nil;
end

function AuraContainerItemEnchantmentManagerMixin:HasAnyEnabledItemEnchantments()
	for _index, itemEnchantment in self:EnumerateItemEnchantments() do
		if itemEnchantment:IsEnabled() then
			return true;
		end
	end

	return false;
end

function AuraContainerItemEnchantmentManagerMixin:GetItemEnchantment(itemEnchantmentSlot)
	return self.itemEnchantmentsBySlot[itemEnchantmentSlot];
end

function AuraContainerItemEnchantmentManagerMixin:GetActiveItemEnchantments()
	return self.activeItemEnchantments;
end

function AuraContainerItemEnchantmentManagerMixin:GetActiveItemEnchantmentFrames()
	return self.activeItemEnchantmentFrames;
end

function AuraContainerItemEnchantmentManagerMixin:EnumerateItemEnchantments()
	return ipairs(self.itemEnchantments);
end

function AuraContainerItemEnchantmentManagerMixin:EnumerateActiveItemEnchantments()
	return ipairs(self.activeItemEnchantments);
end

local function CalculateItemEnchantmentRefreshResult(oldActiveItemEnchantments, newActiveItemEnchantments, activeAssignmentsChanged)
	local refreshResult = AuraContainerFrameRefreshResult.None;

	if activeAssignmentsChanged then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerFrameRefreshResult.FrameAssignmentsChanged, FlagsUtilConstants.CombineShouldSet);
	end

	if (#oldActiveItemEnchantments > 0) ~= (#newActiveItemEnchantments > 0) then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerFrameRefreshResult.VisibilityChanged, FlagsUtilConstants.CombineShouldSet);
	end

	return refreshResult;
end

function AuraContainerItemEnchantmentManagerMixin:RebuildActiveItemEnchantments()
	local activeItemEnchantments = {};

	for _index, itemEnchantment in self:EnumerateItemEnchantments() do
		if itemEnchantment:IsEnabled() and itemEnchantment:IsActive() then
			table.insert(activeItemEnchantments, itemEnchantment);
		end
	end

	table.sort(activeItemEnchantments, AuraContainerUtil.GetItemEnchantmentSortComparator(self:GetSortMethod(), self:GetSortDirection()));

	local activeItemEnchantmentFrames = table.create(#activeItemEnchantments);
	for _index, itemEnchantment in ipairs(activeItemEnchantments) do
		table.insert(activeItemEnchantmentFrames, itemEnchantment:GetAuraFrame());
	end

	self.activeItemEnchantments = activeItemEnchantments;
	self.activeItemEnchantmentFrames = activeItemEnchantmentFrames;
	return activeItemEnchantments;
end

function AuraContainerItemEnchantmentManagerMixin:RefreshFrameAssignments()
	local oldActiveItemEnchantments = self:GetActiveItemEnchantments();
	local frameAssignmentsChanged = false;

	for _index, itemEnchantment in self:EnumerateItemEnchantments() do
		if itemEnchantment:IsEnabled() then
			frameAssignmentsChanged = self:RefreshItemEnchantment(itemEnchantment) or frameAssignmentsChanged;
		end
	end

	local newActiveItemEnchantments = self:RebuildActiveItemEnchantments();
	return CalculateItemEnchantmentRefreshResult(oldActiveItemEnchantments, newActiveItemEnchantments, frameAssignmentsChanged);
end

function AuraContainerItemEnchantmentManagerMixin:RefreshItemEnchantment(itemEnchantment)
	local wasActive = itemEnchantment:IsActive();
	local enchantmentInfo = AuraContainerUtil.GetItemEnchantmentInfo(itemEnchantment:GetItemEnchantmentSlot());

	-- This flag should be set to true if we've touched any aura frames for
	-- initialization, update, or clearing.
	local frameAssignmentsChanged = false;

	if enchantmentInfo ~= nil and itemEnchantment:ShouldHidePermanentEnchantments() and not enchantmentInfo.hasExpirationTime then
		enchantmentInfo = nil;
	end

	if enchantmentInfo ~= nil then
		local shouldReassign = itemEnchantment:ShouldReassignForEnchantmentInfo(enchantmentInfo);
		itemEnchantment:SetEnchantmentInfo(enchantmentInfo, shouldReassign);

		if shouldReassign then
			self:InitializeItemEnchantmentFrame(itemEnchantment);
		else
			self:UpdateItemEnchantmentFrame(itemEnchantment);
		end

		frameAssignmentsChanged = true;
	elseif wasActive then
		itemEnchantment:ClearEnchantmentInfo();
		self:ClearItemEnchantmentFrame(itemEnchantment);
		frameAssignmentsChanged = true;
	end

	return frameAssignmentsChanged;
end

function AuraContainerItemEnchantmentManagerMixin:InitializeItemEnchantmentFrame(itemEnchantment)
	self.owner:InitializeItemEnchantmentFrame(itemEnchantment, itemEnchantment:GetAuraFrame(), ItemEnchantmentUnitToken, itemEnchantment:GetAuraData());
end

function AuraContainerItemEnchantmentManagerMixin:UpdateItemEnchantmentFrame(itemEnchantment)
	self.owner:UpdateItemEnchantmentFrame(itemEnchantment, itemEnchantment:GetAuraFrame(), ItemEnchantmentUnitToken, itemEnchantment:GetAuraData());
end

function AuraContainerItemEnchantmentManagerMixin:ClearItemEnchantmentFrame(itemEnchantment)
	self.owner:ClearItemEnchantmentFrame(itemEnchantment, itemEnchantment:GetAuraFrame());
end

function AuraContainerItemEnchantmentManagerMixin:ResetFrameAssignmentForItemEnchantment(itemEnchantment)
	if itemEnchantment:IsActive() then
		self:ClearItemEnchantmentFrame(itemEnchantment);
		itemEnchantment:ClearEnchantmentInfo();
	end
end

function AuraContainerItemEnchantmentManagerMixin:ResetFrameAssignments()
	for _index, itemEnchantment in self:EnumerateActiveItemEnchantments() do
		self:ResetFrameAssignmentForItemEnchantment(itemEnchantment);
	end

	self.activeItemEnchantments = {};
	self.activeItemEnchantmentFrames = {};
end

AuraContainerItemEnchantmentMixin = {};

function AuraContainerItemEnchantmentMixin:Init(itemEnchantmentSlot, description)
	assert(description.auraFrame ~= nil, "Item enchantments must have an aura frame.");

	self.enabled = true;
	self.itemEnchantmentSlot = itemEnchantmentSlot;
	self.inventorySlot = AuraContainerUtil.GetItemEnchantmentInventorySlot(itemEnchantmentSlot);
	self.auraFrame = description.auraFrame;
	self.hidePermanent = description.hidePermanent == true;

	self.active = false;
	self.enchantID = nil;
	self.chargesRemaining = 0;
	self.remainingTimeMs = nil;
	self.hasExpirationTime = false;
	self.duration = 0;
	self.expirationTime = 0;
	self.auraData = nil;
end

function AuraContainerItemEnchantmentMixin:IsEnabled()
	return self.enabled == true;
end

function AuraContainerItemEnchantmentMixin:SetEnabled(enabled)
	self.enabled = (enabled == true);
end

function AuraContainerItemEnchantmentMixin:GetItemEnchantmentSlot()
	return self.itemEnchantmentSlot;
end

function AuraContainerItemEnchantmentMixin:GetInventorySlot()
	return self.inventorySlot;
end

function AuraContainerItemEnchantmentMixin:GetAuraFrame()
	return self.auraFrame;
end

function AuraContainerItemEnchantmentMixin:ShouldHidePermanentEnchantments()
	return self.hidePermanent;
end

function AuraContainerItemEnchantmentMixin:IsActive()
	return self.active;
end

function AuraContainerItemEnchantmentMixin:GetAuraData()
	return self.auraData;
end

function AuraContainerItemEnchantmentMixin:GetRemainingTimeMs()
	return self.remainingTimeMs;
end

function AuraContainerItemEnchantmentMixin:HasExpirationTime()
	return self.hasExpirationTime;
end

function AuraContainerItemEnchantmentMixin:ShouldReassignForEnchantmentInfo(enchantmentInfo)
	if not self:IsActive() then
		return true;
	end

	if self.enchantID ~= enchantmentInfo.enchantID then
		return true;
	end

	if self.hasExpirationTime ~= enchantmentInfo.hasExpirationTime then
		return true;
	end

	if enchantmentInfo.hasExpirationTime and enchantmentInfo.remainingTimeMs > self.remainingTimeMs then
		return true;
	end

	return false;
end

function AuraContainerItemEnchantmentMixin:SetEnchantmentInfo(enchantmentInfo, resetDuration)
	self.active = true;
	self.enchantID = enchantmentInfo.enchantID;
	self.chargesRemaining = enchantmentInfo.chargesRemaining;
	self.remainingTimeMs = enchantmentInfo.remainingTimeMs;
	self.hasExpirationTime = enchantmentInfo.hasExpirationTime;

	-- The native API only provides information on remaining time of an
	-- enchantment, and not a base duration. We snapshot the duration
	-- when we think an enchantment has been first applied and don't
	-- update it thereafter until we think it's been replaced or refreshed.

	if resetDuration then
		self.duration = GetDurationSeconds(enchantmentInfo);
	end

	self.expirationTime = GetExpirationTimeSeconds(enchantmentInfo);
	self.auraData = self:CreateAuraData();
end

function AuraContainerItemEnchantmentMixin:ClearEnchantmentInfo()
	self.active = false;
	self.enchantID = nil;
	self.chargesRemaining = 0;
	self.remainingTimeMs = nil;
	self.hasExpirationTime = false;
	self.duration = 0;
	self.expirationTime = 0;
	self.auraData = nil;
end

function AuraContainerItemEnchantmentMixin:CreateAuraData()
	return
	{
		auraType = AuraContainerAuraDataType.ItemEnchantment;

		-- Item enchantments are not unit aura instances.
		auraInstanceID = nil;

		itemEnchantmentSlot = self.itemEnchantmentSlot;
		inventorySlot = self.inventorySlot;
		itemEnchantmentID = self.enchantID;

		applications = self.chargesRemaining;
		duration = self.duration;
		expirationTime = self.expirationTime;
	};
end

AuraContainerItemEnchantmentOwnerMixin = {};

function AuraContainerItemEnchantmentOwnerMixin:OnItemEnchantmentsChanged()
	-- Override in the owner to be notified when the list of configured item
	-- enchantments has changed.
end

function AuraContainerItemEnchantmentOwnerMixin:InitializeItemEnchantmentFrame(_itemEnchantment, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to initialize an item enchantment frame that has
	-- gained or replaced display data.
end

function AuraContainerItemEnchantmentOwnerMixin:UpdateItemEnchantmentFrame(_itemEnchantment, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to apply retained updates to an item enchantment frame.
end

function AuraContainerItemEnchantmentOwnerMixin:ClearItemEnchantmentFrame(_itemEnchantment, _auraFrame)
	-- Override in the owner to clear an item enchantment frame that no longer
	-- has display data.
end

function AuraContainerUtil.CreateItemEnchantment(itemEnchantmentSlot, description)
	local itemEnchantment = CreateFromMixins(AuraContainerItemEnchantmentMixin);
	itemEnchantment:Init(itemEnchantmentSlot, description);
	return itemEnchantment;
end

function AuraContainerUtil.CreateItemEnchantmentManager(owner)
	local itemEnchantmentManager = CreateFromMixins(AuraContainerItemEnchantmentManagerMixin);
	itemEnchantmentManager:Init(owner);
	return itemEnchantmentManager;
end
