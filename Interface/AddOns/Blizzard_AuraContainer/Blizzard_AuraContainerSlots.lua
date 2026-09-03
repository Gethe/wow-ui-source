-- Aura slots are used by containers that display at most one aura in a stable
-- location, such as per-spell indicators or priority aura/dispel type overlays.
--
-- Unlike aura groups, slots do not own dynamic frame lists. They are managed
-- as a child subsystem of managed containers.

AuraContainerAuraSlotConstants =
{
	CandidatesChanged = true;
	CandidatesNotChanged = false;
};

AuraContainerAuraSlotManagerMixin = {};

function AuraContainerAuraSlotManagerMixin:Init(owner)
	self.owner = owner;
	self.auraSlots = {};
	self.auraSlotsByKey = {};
end

function AuraContainerAuraSlotManagerMixin:RegisterAuraSlot(slotKey, description)
	assert(type(slotKey) == "string" and slotKey ~= "", "slotKey must be a non-empty string.");
	assert(self.auraSlotsByKey[slotKey] == nil, "An aura slot already exists with this key.");
	assert(type(description) == "table", "description must be a table.");

	local auraSlot = AuraContainerUtil.CreateAuraSlot(slotKey, description);
	self.auraSlotsByKey[slotKey] = auraSlot;
	table.insert(self.auraSlots, auraSlot);

	self:SignalAuraSlotsChanged();
	return auraSlot;
end

function AuraContainerAuraSlotManagerMixin:UnregisterAuraSlot(slotKey)
	local auraSlot = self.auraSlotsByKey[slotKey];

	if auraSlot ~= nil then
		self:ResetFrameAssignmentForSlot(auraSlot);
		self.auraSlotsByKey[slotKey] = nil;
		table.removevalue(self.auraSlots, auraSlot);
		self:SignalAuraSlotsChanged();
	end
end

function AuraContainerAuraSlotManagerMixin:ClearAuraSlots()
	for _index, auraSlot in self:EnumerateAuraSlots() do
		self:ClearAuraSlotFrame(auraSlot);
	end

	self.auraSlots = {};
	self.auraSlotsByKey = {};
	self:SignalAuraSlotsChanged();
end

function AuraContainerAuraSlotManagerMixin:SetAuraSlotEnabled(auraSlot, enabled)
	enabled = (enabled == true);

	if auraSlot:IsEnabled() ~= enabled then
		auraSlot:SetEnabled(enabled);

		if not enabled then
			auraSlot:ClearCandidates();
			self:ResetFrameAssignmentForSlot(auraSlot);
		end

		self:SignalAuraSlotsChanged();
	end
end

function AuraContainerAuraSlotManagerMixin:SignalAuraSlotsChanged()
	self.owner:OnAuraSlotsChanged();
end

function AuraContainerAuraSlotManagerMixin:HasAuraSlot(slotKey)
	return self.auraSlotsByKey[slotKey] ~= nil;
end

function AuraContainerAuraSlotManagerMixin:HasAnyAuraSlots()
	return self.auraSlots[1] ~= nil;
end

function AuraContainerAuraSlotManagerMixin:HasAnyEnabledAuraSlots()
	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			return true;
		end
	end

	return false;
end

function AuraContainerAuraSlotManagerMixin:GetAuraSlot(slotKey)
	return self.auraSlotsByKey[slotKey];
end

function AuraContainerAuraSlotManagerMixin:EnumerateAuraSlots()
	return ipairs(self.auraSlots);
end

function AuraContainerAuraSlotManagerMixin:RegisterAuraParseConsumers(registrar)
	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			registrar:RegisterAuraParseConsumer(auraSlot:GetFilterString(), self, auraSlot);
		end
	end
end

function AuraContainerAuraSlotManagerMixin:ProcessParsedAura(auraSlot, unitToken, auraData, hasMatchedFilterString)
	return self:UpdateAuraSlotCandidate(auraSlot, unitToken, auraData.auraInstanceID, auraData, hasMatchedFilterString);
end

function AuraContainerAuraSlotManagerMixin:AddAura(unitToken, auraData)
	local candidatesChanged = false;
	local hasMatchedFilterString = false;

	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			candidatesChanged = self:UpdateAuraSlotCandidate(auraSlot, unitToken, auraData.auraInstanceID, auraData, hasMatchedFilterString) or candidatesChanged;
		end
	end

	return candidatesChanged;
end

function AuraContainerAuraSlotManagerMixin:UpdateAura(unitToken, auraInstanceID, auraData)
	local candidatesChanged = false;
	local hasMatchedFilterString = false;

	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			candidatesChanged = self:UpdateAuraSlotCandidate(auraSlot, unitToken, auraInstanceID, auraData, hasMatchedFilterString) or candidatesChanged;
		end
	end

	return candidatesChanged;
end

function AuraContainerAuraSlotManagerMixin:RemoveAura(_unitToken, auraInstanceID)
	-- Unit token parameter is kept for symmetry with other APIs and to allow
	-- for future expansion.

	local candidatesChanged = false;

	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() then
			candidatesChanged = auraSlot:RemoveCandidate(auraInstanceID) or candidatesChanged;
		end
	end

	return candidatesChanged;
end

function AuraContainerAuraSlotManagerMixin:ClearAuraSlotCandidates()
	for _index, auraSlot in self:EnumerateAuraSlots() do
		auraSlot:ClearCandidates();
	end
end

function AuraContainerAuraSlotManagerMixin:UpdateAuraSlotCandidate(auraSlot, unitToken, auraInstanceID, auraData, hasMatchedFilterString)
	if auraData ~= nil and self.owner:ShouldIncludeAuraInSlot(auraSlot, unitToken, auraData, hasMatchedFilterString) then
		return auraSlot:SetCandidate(auraData);
	else
		return auraSlot:RemoveCandidate(auraInstanceID);
	end
end

function AuraContainerAuraSlotManagerMixin:RefreshFrameAssignments(unitToken)
	for _index, auraSlot in self:EnumerateAuraSlots() do
		if auraSlot:IsEnabled() and auraSlot:IsDirty() then
			self:RefreshAuraSlot(auraSlot, unitToken);
		end
	end

	return AuraContainerFrameRefreshResult.None;
end

function AuraContainerAuraSlotManagerMixin:RefreshAuraSlot(auraSlot, unitToken)
	local preferredAuraData = auraSlot:GetPreferredAuraData();
	local assignedAuraInstanceID = auraSlot:GetAssignedAuraInstanceID();

	if preferredAuraData ~= nil then
		local preferredAuraInstanceID = preferredAuraData.auraInstanceID;
		local forceReassignPreferredAura = auraSlot:ConsumeForceReassignPreferredAura();

		if forceReassignPreferredAura or assignedAuraInstanceID ~= preferredAuraInstanceID then
			self:AssignAuraFrameForSlot(auraSlot, unitToken, preferredAuraData);
			auraSlot:MarkAuraInstanceClean(preferredAuraInstanceID);
		elseif auraSlot:ConsumeAuraInstanceDirty(preferredAuraInstanceID) then
			self:UpdateAuraSlotFrame(auraSlot, unitToken, preferredAuraData);
		end
	elseif assignedAuraInstanceID ~= nil then
		self:ClearAuraSlotFrame(auraSlot);
	end

	auraSlot:MarkClean();
end

function AuraContainerAuraSlotManagerMixin:AssignAuraFrameForSlot(auraSlot, unitToken, auraData)
	local auraFrame = auraSlot:GetAuraFrame();
	self.owner:InitializeAuraSlotFrame(auraSlot, auraFrame, unitToken, auraData);
	auraSlot:SetAssignedAuraData(auraData);
end

function AuraContainerAuraSlotManagerMixin:UpdateAuraSlotFrame(auraSlot, unitToken, auraData)
	local auraFrame = auraSlot:GetAuraFrame();
	self.owner:UpdateAuraSlotFrame(auraSlot, auraFrame, unitToken, auraData);
	auraSlot:SetAssignedAuraData(auraData);
end

function AuraContainerAuraSlotManagerMixin:ClearAuraSlotFrame(auraSlot)
	local auraFrame = auraSlot:GetAuraFrame();
	self.owner:ClearAuraSlotFrame(auraSlot, auraFrame);
	auraSlot:SetAssignedAuraData(nil);
end

function AuraContainerAuraSlotManagerMixin:ResetFrameAssignmentForSlot(auraSlot)
	if auraSlot:HasAssignedAura() then
		self:ClearAuraSlotFrame(auraSlot);
	end

	auraSlot:MarkDirty();
end

function AuraContainerAuraSlotManagerMixin:ResetFrameAssignments()
	for _index, auraSlot in self:EnumerateAuraSlots() do
		self:ResetFrameAssignmentForSlot(auraSlot);
	end
end

AuraContainerAuraSlotMixin = {};

function AuraContainerAuraSlotMixin:Init(slotKey, description)
	self.enabled = true;
	self.slotKey = slotKey;
	self.auraFrame = description.auraFrame;
	self.filterString = nil;
	self.candidateFilters = nil;
	self.auraComparator = nil;

	self.assignedAuraInstanceID = nil;
	self.assignedAuraData = nil;
	self.candidates = nil;
	self.dirty = false;
	self.dirtyAuraInstanceIDs = {};
	self.forceReassignPreferredAura = false;

	self:SetAuraComparator(description.auraComparator);
	self:SetFilterString(description.filterString);
	self:SetCandidateFilters(description.candidateFilters);
end

function AuraContainerAuraSlotMixin:IsEnabled()
	return self.enabled == true;
end

function AuraContainerAuraSlotMixin:SetEnabled(enabled)
	self.enabled = (enabled == true);
end

function AuraContainerAuraSlotMixin:GetSlotKey()
	return self.slotKey;
end

function AuraContainerAuraSlotMixin:GetFilterString()
	return self.filterString;
end

function AuraContainerAuraSlotMixin:SetFilterString(filterString)
	assert(AuraUtil.IsValidFilterString(filterString));

	if self.filterString ~= filterString then
		self.filterString = filterString;
		self:ClearCandidates();
	end
end

function AuraContainerAuraSlotMixin:GetCandidateFilters()
	return self.candidateFilters;
end

function AuraContainerAuraSlotMixin:GetAuraComparator()
	return self.auraComparator;
end

function AuraContainerAuraSlotMixin:SetAuraComparator(auraComparator)
	auraComparator = auraComparator or AuraUtil.DefaultAuraCompare;

	if self.auraComparator ~= auraComparator then
		self.auraComparator = auraComparator;
		self:RebuildCandidates();
	end
end

function AuraContainerAuraSlotMixin:GetAuraFrame()
	return self.auraFrame;
end

function AuraContainerAuraSlotMixin:SetCandidateFilters(candidateFilters)
	self.candidateFilters = candidateFilters;
	self:ClearCandidates();
end

function AuraContainerAuraSlotMixin:GetCandidates()
	return self.candidates;
end

function AuraContainerAuraSlotMixin:ClearCandidates()
	-- Candidate clearing is expected to occur on full aura refreshes. In this
	-- case we want to force re-assignment of preferred auras - this avoids
	-- issues if post-update our preferred aura would have the same aura
	-- instance ID but refer to a fundamentally different aura entirely.
	self.candidates:Clear();
	self.forceReassignPreferredAura = true;
	self:MarkDirty();
	return AuraContainerAuraSlotConstants.CandidatesChanged;
end

function AuraContainerAuraSlotMixin:SetCandidate(auraData)
	self.candidates[auraData.auraInstanceID] = auraData;
	self.dirtyAuraInstanceIDs[auraData.auraInstanceID] = true;
	self:MarkDirty();
	return AuraContainerAuraSlotConstants.CandidatesChanged;
end

function AuraContainerAuraSlotMixin:RemoveCandidate(auraInstanceID)
	if self.candidates[auraInstanceID] == nil then
		return AuraContainerAuraSlotConstants.CandidatesNotChanged;
	end

	self.candidates[auraInstanceID] = nil;
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
	self:MarkDirty();
	return AuraContainerAuraSlotConstants.CandidatesChanged;
end

function AuraContainerAuraSlotMixin:RebuildCandidates()
	local oldCandidates = self.candidates;
	local newCandidates = TableUtil.CreatePriorityTable(self:GetAuraComparator(), TableUtil.Constants.AssociativePriorityTable);

	if oldCandidates then
		oldCandidates:Iterate(function(auraInstanceID, auraData) newCandidates[auraInstanceID] = auraData; end);
	end

	self.candidates = newCandidates;
	self:MarkDirty();
end

function AuraContainerAuraSlotMixin:IsAuraInstanceDirty(auraInstanceID)
	return self.dirtyAuraInstanceIDs[auraInstanceID] == true;
end

function AuraContainerAuraSlotMixin:MarkAuraInstanceClean(auraInstanceID)
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
end

function AuraContainerAuraSlotMixin:ConsumeAuraInstanceDirty(auraInstanceID)
	local isDirty = self.dirtyAuraInstanceIDs[auraInstanceID] == true;
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
	return isDirty;
end

function AuraContainerAuraSlotMixin:ShouldForceReassignPreferredAura()
	return self.forceReassignPreferredAura == true;
end

function AuraContainerAuraSlotMixin:ConsumeForceReassignPreferredAura()
	local forceReassignPreferredAura = self.forceReassignPreferredAura;
	self.forceReassignPreferredAura = false;
	return forceReassignPreferredAura;
end

function AuraContainerAuraSlotMixin:GetPreferredAuraData()
	return self.candidates:GetTop();
end

function AuraContainerAuraSlotMixin:GetAssignedAuraInstanceID()
	return self.assignedAuraInstanceID;
end

function AuraContainerAuraSlotMixin:GetAssignedAuraData()
	return self.assignedAuraData;
end

function AuraContainerAuraSlotMixin:SetAssignedAuraData(auraData)
	self.assignedAuraData = auraData;
	self.assignedAuraInstanceID = auraData and auraData.auraInstanceID or nil;
end

function AuraContainerAuraSlotMixin:HasAssignedAura()
	return self.assignedAuraInstanceID ~= nil;
end

function AuraContainerAuraSlotMixin:IsDirty()
	return self.dirty;
end

function AuraContainerAuraSlotMixin:MarkDirty()
	self.dirty = true;
end

function AuraContainerAuraSlotMixin:MarkClean()
	self.dirty = false;
end

AuraContainerAuraSlotOwnerMixin = {};

function AuraContainerAuraSlotOwnerMixin:OnAuraSlotsChanged()
	-- Override in the owner to be notified when the list of configured aura
	-- slots has changed.
end

function AuraContainerAuraSlotOwnerMixin:ShouldIncludeAuraInSlot(auraSlot, unitToken, auraData, hasMatchedFilterString)
	-- Override in the owner to customize logic to determine if incoming aura
	-- data should be a candidate for this slot.

	if not hasMatchedFilterString then
		if not AuraContainerUtil.ShouldIncludeAuraForFilterString(unitToken, auraData, auraSlot:GetFilterString()) then
			return false;
		end
	end

	if not AuraContainerUtil.DoesAuraPassCandidateFilters(unitToken, auraData, auraSlot:GetCandidateFilters()) then
		return false;
	end

	return true;
end

function AuraContainerAuraSlotOwnerMixin:InitializeAuraSlotFrame(_auraSlot, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to initialize an aura slot frame that has gained or changed candidates.
end

function AuraContainerAuraSlotOwnerMixin:UpdateAuraSlotFrame(_auraSlot, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to apply incremental updates to an aura slot frame.
end

function AuraContainerAuraSlotOwnerMixin:ClearAuraSlotFrame(_auraSlot, _auraFrame)
	-- Override in the owner to clear an aura slot frame that no longer has a candidate.
end

function AuraContainerUtil.CreateAuraSlot(slotKey, description)
	local auraSlot = CreateFromMixins(AuraContainerAuraSlotMixin);
	auraSlot:Init(slotKey, description);
	return auraSlot;
end

function AuraContainerUtil.CreateAuraSlotManager(owner)
	local auraSlotManager = CreateFromMixins(AuraContainerAuraSlotManagerMixin);
	auraSlotManager:Init(owner);
	return auraSlotManager;
end
