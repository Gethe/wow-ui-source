-- Aura groups are used by containers that divide auras into logical sets, such
-- as buffs, debuffs, or dispelable auras.
--
-- A group stores the aura data that currently belongs to it, the frames showing
-- those auras, and a map from aura instance IDs to frames. The map lets a frame
-- stay attached to the same aura while the group's priority order changes.
--
-- Groups do not decide where frames come from, whether an aura belongs, or how
-- frames are positioned. Those rules belong to the owning container.

local function CreateSecureAuraInstanceMap(numElements)
	-- Aura frame association maps require that the aura instance ID not
	-- be a secret value, as secret keys in tables make all accesses into
	-- that table produce secrets.
	--
	-- Where this causes issues is around releasing frames back into pools;
	-- we'll trigger an assertsafe if attempting to release a secret script
	-- object into a pool.
	--
	-- We ban the use of secret values as keys in the association map so that
	-- attempts to do so immediately hard-error. Locations that need to use
	-- aura instance IDs as keys should unwrap them first. This should be
	-- safe as we're in the secure environment - and, it might be a good idea
	-- to instead solve this through dedicated C_UnitAurasPrivate APIs that
	-- never yield secrets.

	local auraInstanceMap = table.create(0, numElements);
	settablesecurity(auraInstanceMap, Enum.TableSecurityOption.DisallowSecretKeys);
	return auraInstanceMap;
end

AuraContainerAuraGroupManagerMixin = {};

function AuraContainerAuraGroupManagerMixin:Init(owner)
	self.owner = owner;
	self.auraGroups = {};
	self.auraGroupsByKey = {};
end

function AuraContainerAuraGroupManagerMixin:RegisterAuraGroup(groupKey, description)
	assert(type(groupKey) == "string" and groupKey ~= "", "groupKey must be a non-empty string.");
	assert(self.auraGroupsByKey[groupKey] == nil, "An aura group already exists with this key.");
	assert(type(description) == "table", "description must be a table.");

	local auraGroup = AuraContainerUtil.CreateAuraGroup(description);
	self.auraGroupsByKey[groupKey] = auraGroup;
	table.insert(self.auraGroups, auraGroup);

	self:SignalAuraGroupsChanged();
	return auraGroup;
end

function AuraContainerAuraGroupManagerMixin:UnregisterAuraGroup(groupKey)
	local auraGroup = self.auraGroupsByKey[groupKey];

	if auraGroup ~= nil then
		self:ResetAuraGroupFrames(auraGroup);
		self.auraGroupsByKey[groupKey] = nil;
		tUnorderedRemove(self.auraGroups, auraGroup);
		self:SignalAuraGroupsChanged();
	end
end

function AuraContainerAuraGroupManagerMixin:ClearAuraGroups()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		-- Note; we intentionally don't nuke aura and frame state in the
		-- aura group here. Groups can only be owned by one container and
		-- should not transfer. We do, however, need to release the frames.
		self:ReleaseAuraFramesForGroup(auraGroup);
	end

	self.auraGroups = {};
	self.auraGroupsByKey = {};
	self:SignalAuraGroupsChanged();
end

function AuraContainerAuraGroupManagerMixin:SignalAuraGroupsChanged()
	self.owner:OnAuraGroupsChanged();
end

function AuraContainerAuraGroupManagerMixin:HasAuraGroup(groupKey)
	return self.auraGroupsByKey[groupKey] ~= nil;
end

function AuraContainerAuraGroupManagerMixin:HasAnyAuraGroups()
	return self.auraGroups[1] ~= nil;
end

function AuraContainerAuraGroupManagerMixin:GetAuraGroup(groupKey)
	return self.auraGroupsByKey[groupKey];
end

function AuraContainerAuraGroupManagerMixin:EnumerateAuraGroups()
	return ipairs(self.auraGroups);
end

function AuraContainerAuraGroupManagerMixin:RegisterAuraParseConsumers(registrar)
	for _index, auraGroup in self:EnumerateAuraGroups() do
		registrar:RegisterAuraParseConsumer(auraGroup:GetFilterString(), self, auraGroup);
	end
end

function AuraContainerAuraGroupManagerMixin:ClearAllAuras()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		auraGroup:ClearAuras();
	end
end

function AuraContainerAuraGroupManagerMixin:ProcessParsedAura(auraGroup, unitToken, auraData, hasMatchedFilterString)
	return self:UpdateAuraGroupMembership(auraGroup, unitToken, auraData.auraInstanceID, auraData, hasMatchedFilterString);
end

function AuraContainerAuraGroupManagerMixin:AddAura(unitToken, auraData)
	local aurasChanged = false;

	if auraData ~= nil then
		aurasChanged = self:UpdateAuraInGroups(unitToken, auraData.auraInstanceID, auraData);
	end

	return aurasChanged;
end

function AuraContainerAuraGroupManagerMixin:UpdateAura(unitToken, auraInstanceID, updatedAuraData)
	return self:UpdateAuraInGroups(unitToken, auraInstanceID, updatedAuraData);
end

function AuraContainerAuraGroupManagerMixin:RemoveAura(unitToken, auraInstanceID)
	local auraData = nil;
	return self:UpdateAuraInGroups(unitToken, auraInstanceID, auraData);
end

function AuraContainerAuraGroupManagerMixin:UpdateAuraInGroups(unitToken, auraInstanceID, auraData)
	local aurasChanged = false;
	local hasMatchedFilterString = false;

	for _index, auraGroup in self:EnumerateAuraGroups() do
		aurasChanged = self:UpdateAuraGroupMembership(auraGroup, unitToken, auraInstanceID, auraData, hasMatchedFilterString) or aurasChanged;
	end

	return aurasChanged;
end

function AuraContainerAuraGroupManagerMixin:UpdateAuraGroupMembership(auraGroup, unitToken, auraInstanceID, auraData, hasMatchedFilterString)
	local auras = auraGroup:GetAuras();
	local hadAura = auras[auraInstanceID] ~= nil;
	local shouldHaveAura = auraData ~= nil and self.owner:ShouldIncludeAuraInGroup(auraGroup, unitToken, auraData, hasMatchedFilterString);
	local aurasChanged = false;

	if shouldHaveAura then
		-- Assignment can move the aura to a different priority position, so this
		-- counts as a change even if the aura was already in the group.
		auras[auraInstanceID] = auraData;
		auraGroup:MarkAuraInstanceChanged(auraInstanceID);
		aurasChanged = true;
	elseif hadAura then
		auras[auraInstanceID] = nil;
		auraGroup:MarkAuraInstanceRemoved(auraInstanceID);
		aurasChanged = true;
	end

	return aurasChanged;
end

function AuraContainerAuraGroupManagerMixin:RefreshDirtyAuraGroups(unitToken)
	local refreshResult = AuraContainerFrameRefreshResult.None;

	for _index, auraGroup in self:EnumerateAuraGroups() do
		if auraGroup:AreFrameAssignmentsDirty() then
			refreshResult = FlagsUtil.Combine(refreshResult, self:RefreshAuraGroup(auraGroup, unitToken), FlagsUtilConstants.CombineShouldSet);
		end
	end

	return refreshResult;
end

local function AssignAuraFrame(auraFrame, auraData, newFramesByIndex, newFramesByAura, frameIndex)
	local auraInstanceID = auraData.auraInstanceID;
	local auraFrameMapKey = secretunwrap(auraInstanceID);

	newFramesByIndex[frameIndex] = auraFrame;
	newFramesByAura[auraFrameMapKey] = auraFrame;
end

local function CalculateAuraGroupRefreshResult(oldFrameCount, newFrameCount, frameAssignmentsChanged)
	local refreshResult = AuraContainerFrameRefreshResult.None;

	if frameAssignmentsChanged or oldFrameCount ~= newFrameCount then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerFrameRefreshResult.FrameAssignmentsChanged, FlagsUtilConstants.CombineShouldSet);
	end

	if (oldFrameCount > 0) ~= (newFrameCount > 0) then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerFrameRefreshResult.VisibilityChanged, FlagsUtilConstants.CombineShouldSet);
	end

	return refreshResult;
end

function AuraContainerAuraGroupManagerMixin:RefreshAuraGroup(auraGroup, unitToken)
	-- Refreshing a group is performed in three phases:
	--   1. Retain frames owned by visible auras and record missing assignments.
	--   2. Release stale frames that are no longer needed.
	--   3. Acquire frames for missing assignments and commit the new ownership maps.
	--
	-- Releasing before acquiring allows providers with small fixed pools to reuse
	-- frames within the same refresh pass.

	local auras = auraGroup:GetAuras();
	local oldFramesByIndex = auraGroup:GetFramesByIndex();
	local oldFramesByAura = auraGroup:GetFramesByAura();
	local maxFrameCount = auraGroup:GetMaxFrameCount();

	local numExpectedFrames = math.min(auras:Size(), maxFrameCount);
	local newFramesByIndex = table.create(numExpectedFrames, 0);
	local newFramesByAura = CreateSecureAuraInstanceMap(numExpectedFrames);
	local deferredFrameIndices;

	-- This flag should be set to true when we've either changed overall frame
	-- count (be it acquire or release), or if a frame has shifted layout
	-- index.
	local frameAssignmentsChanged = false;

	-- Retain visible assignments and record missing frames.
	local frameIndex = 1;
	auras:Iterate(function(auraInstanceID, auraData)
		if frameIndex > maxFrameCount then
			return true;
		end

		local auraFrameMapKey = secretunwrap(auraInstanceID);
		local auraFrame = oldFramesByAura[auraFrameMapKey];

		if auraFrame ~= nil then
			-- This aura currently has a frame; preserve it across refresh.
			AssignAuraFrame(auraFrame, auraData, newFramesByIndex, newFramesByAura, frameIndex);

			if auraGroup:ConsumeAuraInstanceDirty(auraInstanceID) then
				self.owner:UpdateAuraGroupFrame(auraGroup, auraFrame, unitToken, auraData);
			end

			-- Remove retained frames from the old ownership map so only stale
			-- frames are released before deferred acquisitions.
			oldFramesByAura[auraFrameMapKey] = nil;

			if oldFramesByIndex[frameIndex] ~= auraFrame then
				frameAssignmentsChanged = true;
			end
		else
			-- This aura requires a frame allocation. Defer it until later.
			if deferredFrameIndices == nil then
				deferredFrameIndices = {};
			end

			-- Store aura data temporarily so the visible frame list remains dense.
			-- Deferred allocation replaces this with a frame after stale releases.
			newFramesByIndex[frameIndex] = auraData;
			table.insert(deferredFrameIndices, frameIndex);

			frameAssignmentsChanged = true;
		end

		frameIndex = frameIndex + 1;
	end);

	-- Release stale assignments before acquiring replacements.
	local hasReleasedFrames = self:ReleaseAuraGroupFrameMap(auraGroup, oldFramesByAura);
	if hasReleasedFrames then
		frameAssignmentsChanged = true;
	end

	-- Acquire frames for missing assignments from our first pass.
	if deferredFrameIndices ~= nil then
		for _index, deferredFrameIndex in ipairs(deferredFrameIndices) do
			-- Aura data was temporarily emplaced in the frames-by-index list.
			local auraData = newFramesByIndex[deferredFrameIndex];
			local auraFrame = self:AcquireAuraGroupFrame(auraGroup);

			AssignAuraFrame(auraFrame, auraData, newFramesByIndex, newFramesByAura, deferredFrameIndex);
			self.owner:InitializeAuraGroupFrame(auraGroup, auraFrame, unitToken, auraData);
			auraGroup:MarkAuraInstanceClean(auraData.auraInstanceID);
		end
	end

	local refreshResult = CalculateAuraGroupRefreshResult(#oldFramesByIndex, #newFramesByIndex, frameAssignmentsChanged);
	auraGroup:SetFrameAssignments(newFramesByIndex, newFramesByAura);
	return refreshResult;
end

function AuraContainerAuraGroupManagerMixin:AcquireAuraGroupFrame(auraGroup)
	local frameProvider = auraGroup:GetFrameProvider();

	local auraFrame = frameProvider:AcquireFrame();
	assert(auraFrame ~= nil, "Aura frame provider failed to acquire a frame.");

	return auraFrame;
end

function AuraContainerAuraGroupManagerMixin:ReleaseAuraGroupFrame(auraGroup, auraFrame)
	auraGroup:GetFrameProvider():ReleaseFrame(auraFrame);
end

function AuraContainerAuraGroupManagerMixin:ReleaseAuraGroupFrameMap(auraGroup, auraFrameMap)
	local auraInstanceID, auraFrame = next(auraFrameMap);
	local hasReleasedFrames = (auraInstanceID ~= nil);

	while auraInstanceID do
		self:ReleaseAuraGroupFrame(auraGroup, auraFrame);
		auraFrameMap[auraInstanceID] = nil;
		auraInstanceID, auraFrame = next(auraFrameMap);
	end

	return hasReleasedFrames;
end

function AuraContainerAuraGroupManagerMixin:ReleaseAuraFramesForGroup(auraGroup)
	local framesByAuraInstanceID = auraGroup:GetFramesByAura();
	self:ReleaseAuraGroupFrameMap(auraGroup, framesByAuraInstanceID);
end

function AuraContainerAuraGroupManagerMixin:ResetAuraFramesForGroup(auraGroup)
	self:ReleaseAuraFramesForGroup(auraGroup);
	auraGroup:ClearFrameAssignments();
end

function AuraContainerAuraGroupManagerMixin:ResetAuraFrames()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		self:ResetAuraFramesForGroup(auraGroup);
	end
end

AuraContainerAuraGroupMixin = {};

function AuraContainerAuraGroupMixin:Init(description)
	assert(AuraUtil.IsValidFilterString(description.filterString));
	assert(description.frameProvider, "Aura container groups must have a frame provider");

	self.auraComparator = nil;
	self.candidateFilters = nil;
	self.filterString = nil;
	self.frameProvider = description.frameProvider;
	self.maxFrameCount = math.huge;

	self.auras = nil;
	self.dirtyAuraInstanceIDs = {};
	self.framesByIndex = {};
	self.framesByAura = CreateSecureAuraInstanceMap();
	self.frameAssignmentsDirty = false;

	self:SetAuraComparator(description.auraComparator);
	self:SetCandidateFilters(description.candidateFilters);
	self:SetFilterString(description.filterString);
	self:SetMaxFrameCount(description.maxFrameCount or math.huge);

	-- Mark frame assignments clean on init - this is set to true by calls to
	-- SetFilterString and friends, but we have no auras on Init so there's
	-- no actual dirty state.
	self.frameAssignmentsDirty = false;
end

function AuraContainerAuraGroupMixin:GetAuras()
	return self.auras;
end

function AuraContainerAuraGroupMixin:GetFramesByIndex()
	return self.framesByIndex;
end

function AuraContainerAuraGroupMixin:GetFramesByAura()
	return self.framesByAura;
end

function AuraContainerAuraGroupMixin:GetFrameProvider()
	return self.frameProvider;
end

function AuraContainerAuraGroupMixin:SetFrameAssignments(visibleFrames, framesByAuraInstanceID)
	self.framesByIndex = visibleFrames;
	self.framesByAura = framesByAuraInstanceID;
	self.frameAssignmentsDirty = false;
end

function AuraContainerAuraGroupMixin:GetDirtyAuraInstanceIDs()
	return self.dirtyAuraInstanceIDs;
end

function AuraContainerAuraGroupMixin:AreFrameAssignmentsDirty()
	return self.frameAssignmentsDirty;
end

function AuraContainerAuraGroupMixin:MarkFrameAssignmentsDirty()
	self.frameAssignmentsDirty = true;
end

function AuraContainerAuraGroupMixin:IsAuraInstanceDirty(auraInstanceID)
	return self.dirtyAuraInstanceIDs[auraInstanceID] == true;
end

function AuraContainerAuraGroupMixin:MarkAuraInstanceChanged(auraInstanceID)
	-- Aura data changed; update its frame and refresh assignments.
	self.dirtyAuraInstanceIDs[auraInstanceID] = true;
	self.frameAssignmentsDirty = true;
end

function AuraContainerAuraGroupMixin:MarkAuraInstanceRemoved(auraInstanceID)
	-- Aura was removed; refresh assignments so its frame can be released.
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
	self.frameAssignmentsDirty = true;
end

function AuraContainerAuraGroupMixin:MarkAuraInstanceClean(auraInstanceID)
	-- This aura's frame has consumed its pending update.
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
end

function AuraContainerAuraGroupMixin:ConsumeAuraInstanceDirty(auraInstanceID)
	local isDirty = self.dirtyAuraInstanceIDs[auraInstanceID] == true;
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
	return isDirty;
end

function AuraContainerAuraGroupMixin:GetCandidateFilters()
	return self.candidateFilters;
end

function AuraContainerAuraGroupMixin:SetCandidateFilters(candidateFilters)
	self.candidateFilters = candidateFilters;
	self:ClearAuras();
end

function AuraContainerAuraGroupMixin:GetFilterString()
	return self.filterString;
end

function AuraContainerAuraGroupMixin:SetFilterString(filterString)
	if self.filterString ~= filterString then
		self.filterString = filterString;
		self:ClearAuras();
	end
end

function AuraContainerAuraGroupMixin:GetMaxFrameCount()
	return self.maxFrameCount;
end

function AuraContainerAuraGroupMixin:SetMaxFrameCount(maxFrameCount)
	if self.maxFrameCount ~= maxFrameCount then
		self.maxFrameCount = maxFrameCount;
		self:MarkFrameAssignmentsDirty();
	end
end

function AuraContainerAuraGroupMixin:GetAuraComparator()
	return self.auraComparator;
end

function AuraContainerAuraGroupMixin:SetAuraComparator(auraComparator)
	auraComparator = auraComparator or AuraUtil.DefaultAuraCompare;

	if self.auraComparator ~= auraComparator then
		self.auraComparator = auraComparator;
		self:RebuildAuras();
	end
end

function AuraContainerAuraGroupMixin:ClearAuras()
	-- Frames shouldn't be wiped here. When the owning container processes
	-- auras later, it'll observe that all of these auras we've cleared here
	-- have disowned their frames and will reclaim them into the pool.
	self.auras:Clear();
	self.dirtyAuraInstanceIDs = {};
	self:MarkFrameAssignmentsDirty();
end

function AuraContainerAuraGroupMixin:ClearFrameAssignments()
	-- The owning container is responsible for releasing frames before this is
	-- called. This only clears the group's internal book-keeping. Frame
	-- assignments are marked dirty to ensure the auras in this group are
	-- assigned new frames on the next update.
	self.framesByIndex = {};
	self.framesByAura = CreateSecureAuraInstanceMap();
	self.dirtyAuraInstanceIDs = {};
	self:MarkFrameAssignmentsDirty();
end

function AuraContainerAuraGroupMixin:RebuildAuras()
	local oldAuras = self.auras;
	local newAuras = TableUtil.CreatePriorityTable(self:GetAuraComparator(), TableUtil.Constants.AssociativePriorityTable);

	if oldAuras then
		oldAuras:Iterate(function(auraInstanceID, auraData) newAuras[auraInstanceID] = auraData; end);
	end

	self.auras = newAuras;
	self:MarkFrameAssignmentsDirty();
end

AuraContainerAuraGroupOwnerMixin = {};

function AuraContainerAuraGroupOwnerMixin:OnAuraGroupsChanged()
	-- Override in the owner to be notified when the list of configured aura
	-- groups has changed.
end

function AuraContainerAuraGroupOwnerMixin:ShouldIncludeAuraInGroup(auraGroup, unitToken, auraData, hasMatchedFilterString)
	-- Override in the owner for specialised group membership rules.

	if not hasMatchedFilterString then
		if not AuraContainerUtil.ShouldIncludeAuraForFilterString(unitToken, auraData, auraGroup:GetFilterString()) then
			return false;
		end
	end

	if not AuraContainerUtil.DoesAuraPassCandidateFilters(unitToken, auraData, auraGroup:GetCandidateFilters()) then
		return false;
	end

	return true;
end

function AuraContainerAuraGroupOwnerMixin:InitializeAuraGroupFrame(_auraGroup, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to initialize a newly assigned group frame.
end

function AuraContainerAuraGroupOwnerMixin:UpdateAuraGroupFrame(_auraGroup, _auraFrame, _unitToken, _auraData)
	-- Override in the owner to update a retained group frame.
end

function AuraContainerUtil.CreateAuraGroup(description)
	local auraGroup = CreateFromMixins(AuraContainerAuraGroupMixin);
	auraGroup:Init(description);
	return auraGroup;
end

function AuraContainerUtil.CreateAuraGroupManager(description)
	local auraGroupManager = CreateFromMixins(AuraContainerAuraGroupManagerMixin);
	auraGroupManager:Init(description);
	return auraGroupManager;
end
