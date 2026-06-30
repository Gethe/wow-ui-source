-- Aura groups are used by containers that divide auras into logical sets, such
-- as buffs, debuffs, or dispelable auras.
--
-- A group stores the aura data that currently belongs to it, the frames showing
-- those auras, and a map from aura instance IDs to frames. The map lets a frame
-- stay attached to the same aura while the group's priority order changes.
--
-- Groups do not decide where frames come from, whether an aura belongs, or how
-- frames are positioned. Those rules belong to the owning container.

AuraContainerGroupRefreshResult =
{
	None = 0,

	-- If set, indicates that aura frames have been acquired, released, or
	-- have had their layout index changed in this fresh. Containers should
	-- respond to this by performing re-anchoring work.
	FrameAssignmentsChanged = bit.lshift(1, 0),

	-- If set, indicates that this group has transitioned between having zero
	-- and one acquired frames (in either direction). Containers may respond
	-- to this by collapsing groups in layout.
	VisibilityChanged = bit.lshift(1, 1),
};

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

AuraContainerGroupMixin = {};

function AuraContainerGroupMixin:Init(description)
	assert(AuraUtil.IsValidFilterString(description.filterString));
	assert(description.frameProvider, "Aura container groups must have a frame provider");

	self.auras = TableUtil.CreatePriorityTable(description.compareFunc or AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	self.dirtyAuraInstanceIDs = {};
	self.filterString = description.filterString;

	self.frames = {};
	self.framesByAuraInstanceID = CreateSecureAuraInstanceMap();
	self.frameAssignmentsDirty = false;
	self.frameProvider = description.frameProvider;
	self.maxFrameCount = description.maxFrameCount or math.huge;

	return self;
end

function AuraContainerGroupMixin:GetAuras()
	return self.auras;
end

function AuraContainerGroupMixin:GetFrames()
	return self.frames;
end

function AuraContainerGroupMixin:GetFramesByAuraInstanceID()
	return self.framesByAuraInstanceID;
end

function AuraContainerGroupMixin:GetFrameProvider()
	return self.frameProvider;
end

function AuraContainerGroupMixin:SetFrameAssignments(visibleFrames, framesByAuraInstanceID)
	self.frames = visibleFrames;
	self.framesByAuraInstanceID = framesByAuraInstanceID;
	self.frameAssignmentsDirty = false;
end

function AuraContainerGroupMixin:GetDirtyAuraInstanceIDs()
	return self.dirtyAuraInstanceIDs;
end

function AuraContainerGroupMixin:AreFrameAssignmentsDirty()
	return self.frameAssignmentsDirty;
end

function AuraContainerGroupMixin:MarkFrameAssignmentsDirty()
	self.frameAssignmentsDirty = true;
end

function AuraContainerGroupMixin:IsAuraInstanceDirty(auraInstanceID)
	return self.dirtyAuraInstanceIDs[auraInstanceID] == true;
end

function AuraContainerGroupMixin:MarkAuraInstanceChanged(auraInstanceID)
	-- Aura data changed; update its frame and refresh assignments.
	self.dirtyAuraInstanceIDs[auraInstanceID] = true;
	self.frameAssignmentsDirty = true;
end

function AuraContainerGroupMixin:MarkAuraInstanceRemoved(auraInstanceID)
	-- Aura was removed; refresh assignments so its frame can be released.
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
	self.frameAssignmentsDirty = true;
end

function AuraContainerGroupMixin:MarkAuraInstanceClean(auraInstanceID)
	-- This aura's frame has consumed its pending update.
	self.dirtyAuraInstanceIDs[auraInstanceID] = nil;
end

function AuraContainerGroupMixin:GetFilterString()
	return self.filterString;
end

function AuraContainerGroupMixin:SetFilterString(filterString)
	if self.filterString ~= filterString then
		self.filterString = filterString;
		self:MarkFrameAssignmentsDirty();
	end
end

function AuraContainerGroupMixin:GetMaxFrameCount()
	return self.maxFrameCount;
end

function AuraContainerGroupMixin:SetMaxFrameCount(maxFrameCount)
	if self.maxFrameCount ~= maxFrameCount then
		self.maxFrameCount = maxFrameCount;
		self:MarkFrameAssignmentsDirty();
	end
end

function AuraContainerGroupMixin:ClearAuras()
	-- Frames shouldn't be wiped here. When the owning container processes
	-- auras later, it'll observe that all of these auras we've cleared here
	-- have disowned their frames and will reclaim them into the pool.
	self.auras:Clear();
	self.dirtyAuraInstanceIDs = {};
	self:MarkFrameAssignmentsDirty();
end

function AuraContainerGroupMixin:ClearFrameAssignments()
	-- The owning container is responsible for releasing frames before this is
	-- called. This only clears the group's internal book-keeping. Frame
	-- assignments are marked dirty to ensure the auras in this group are
	-- assigned new frames on the next update.
	self.frames = {};
	self.framesByAuraInstanceID = CreateSecureAuraInstanceMap();
	self.dirtyAuraInstanceIDs = {};
	self:MarkFrameAssignmentsDirty();
end

function AuraContainerUtil.CreateAuraContainerGroup(description)
	local group = CreateFromMixins(AuraContainerGroupMixin);
	group:Init(description);
	return group;
end

AuraContainerAuraGroupsMixin = {};

function AuraContainerAuraGroupsMixin:InitAuraGroups()
	self.auraGroups = {};
end

function AuraContainerAuraGroupsMixin:AddAuraGroup(description)
	local auraGroup = AuraContainerUtil.CreateAuraContainerGroup(description);
	table.insert(self.auraGroups, auraGroup);
	return auraGroup;
end

function AuraContainerAuraGroupsMixin:ClearAuraGroups()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		-- Note; we intentionally don't nuke aura and frame state in the
		-- aura group here. Groups can only be owned by one container and
		-- should not transfer. We do, however, need to release the frames.
		self:ReleaseAllAuraFramesForGroup(auraGroup);
	end

	self.auraGroups = {};
end

function AuraContainerAuraGroupsMixin:GetAuraGroups()
	return self.auraGroups;
end

function AuraContainerAuraGroupsMixin:EnumerateAuraGroups()
	return ipairs(self.auraGroups);
end

function AuraContainerAuraGroupsMixin:AddAura(auraData)
	local aurasChanged = false;

	if auraData ~= nil then
		aurasChanged = self:UpdateAuraInGroups(auraData.auraInstanceID, auraData);
	end

	return aurasChanged;
end

function AuraContainerAuraGroupsMixin:UpdateAura(auraInstanceID, updatedAuraData)
	return self:UpdateAuraInGroups(auraInstanceID, updatedAuraData);
end

function AuraContainerAuraGroupsMixin:RemoveAura(auraInstanceID)
	local auraData = nil;
	return self:UpdateAuraInGroups(auraInstanceID, auraData);
end

function AuraContainerAuraGroupsMixin:UpdateAuraInGroups(auraInstanceID, auraData)
	local aurasChanged = false;

	for _index, auraGroup in self:EnumerateAuraGroups() do
		aurasChanged = self:UpdateAuraGroupMembership(auraGroup, auraInstanceID, auraData) or aurasChanged;
	end

	return aurasChanged;
end

function AuraContainerAuraGroupsMixin:UpdateAuraGroupMembership(auraGroup, auraInstanceID, auraData)
	local auras = auraGroup:GetAuras();
	local hadAura = auras[auraInstanceID] ~= nil;
	local shouldHaveAura = auraData ~= nil and self:ShouldIncludeAuraInGroup(auraGroup, auraData);
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

function AuraContainerAuraGroupsMixin:ShouldIncludeAuraInGroup(auraGroup, auraData)
	-- Override in the container for specialised group membership rules.
	return AuraContainerUtil.ShouldIncludeAuraForFilterString(self, auraGroup:GetFilterString(), auraData);
end

function AuraContainerAuraGroupsMixin:RefreshDirtyAuraFrameGroups()
	local refreshResult = AuraContainerGroupRefreshResult.None;

	for _index, auraGroup in self:EnumerateAuraGroups() do
		if auraGroup:AreFrameAssignmentsDirty() then
			refreshResult = FlagsUtil.Combine(refreshResult, self:RefreshAuraFrameGroup(auraGroup), FlagsUtilConstants.CombineShouldSet);
		end
	end

	return refreshResult;
end

function AuraContainerAuraGroupsMixin:RefreshAuraFrameGroup(auraGroup)
	local frameIndex = 1;
	local refreshResult = AuraContainerGroupRefreshResult.None;

	local auras = auraGroup:GetAuras();
	local oldFrames = auraGroup:GetFrames();
	local hadFrames = #oldFrames > 0;
	local oldFramesByAuraInstanceID = auraGroup:GetFramesByAuraInstanceID();
	local maxFrameCount = auraGroup:GetMaxFrameCount();

	-- Build a new ownership map for the visible auras. Retained frames are removed
	-- from the old map; anything left in the old map after binding is released.
	-- We also build a new visibility list to avoid needing to trim the 'oldFrames'
	-- array later on.
	local numExpectedFrames = math.min(auras:Size(), maxFrameCount);
	local newFrames = table.create(numExpectedFrames, 0);
	local newFramesByAuraInstanceID = CreateSecureAuraInstanceMap(numExpectedFrames);

	-- This flag should be set to true when we've either changed overall frame
	-- count (be it acquire or release), or if a frame has shifted layout
	-- index.
	local frameAssignmentsChanged = false;

	auras:Iterate(function(auraInstanceID, auraData)
		if frameIndex > maxFrameCount then
			return true;
		end

		-- Reuse the frame already owned by this aura instance, if one exists.
		local auraFrameMapKey = secretunwrap(auraInstanceID);
		local auraFrame = oldFramesByAuraInstanceID[auraFrameMapKey];
		local isNewlyAcquired = false;

		if auraFrame ~= nil then
			oldFramesByAuraInstanceID[auraFrameMapKey] = nil;
		else
			auraFrame = self:AcquireAuraFrameForGroup(auraGroup);
			isNewlyAcquired = true;
			frameAssignmentsChanged = true;
		end

		-- The aura kept its frame, but its display position may have changed.
		if oldFrames[frameIndex] ~= auraFrame then
			frameAssignmentsChanged = true;
		end

		newFrames[frameIndex] = auraFrame;
		newFramesByAuraInstanceID[auraFrameMapKey] = auraFrame;

		if isNewlyAcquired then
			self:InitializeAuraFrameForGroup(auraFrame, auraData, auraGroup);
		elseif auraGroup:IsAuraInstanceDirty(auraInstanceID) then
			self:UpdateAuraFrameForGroup(auraFrame, auraData, auraGroup);
		end

		auraGroup:MarkAuraInstanceClean(auraInstanceID);

		frameIndex = frameIndex + 1;
	end);

	local hasReleasedFrames = self:ReleaseAuraFrameMapForGroup(auraGroup, oldFramesByAuraInstanceID);

	if hasReleasedFrames then
		frameAssignmentsChanged = true;
	end

	if #newFrames ~= #oldFrames then
		frameAssignmentsChanged = true;
	end

	auraGroup:SetFrameAssignments(newFrames, newFramesByAuraInstanceID);

	if frameAssignmentsChanged then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerGroupRefreshResult.FrameAssignmentsChanged, FlagsUtilConstants.CombineShouldSet);
	end

	local hasFrames = #newFrames > 0;
	if hadFrames ~= hasFrames then
		refreshResult = FlagsUtil.Combine(refreshResult, AuraContainerGroupRefreshResult.VisibilityChanged, FlagsUtilConstants.CombineShouldSet);
	end

	return refreshResult;
end

function AuraContainerAuraGroupsMixin:AcquireAuraFrameForGroup(auraGroup)
	local frameProvider = auraGroup:GetFrameProvider();

	local auraFrame = frameProvider:AcquireFrame();
	assert(auraFrame ~= nil, "Aura frame provider failed to acquire a frame.");

	return auraFrame;
end

function AuraContainerAuraGroupsMixin:InitializeAuraFrameForGroup(auraFrame, auraData, _auraGroup)
	-- Override in the container to apply any frame state for a freshly acquired
	-- frame before display.

	auraFrame:SetAuraInstance(self:GetUnit(), auraData);
	auraFrame:Show();
end

function AuraContainerAuraGroupsMixin:UpdateAuraFrameForGroup(auraFrame, auraData, _auraGroup)
	-- Override in the container to apply any frame state to an incrementally
	-- updated frame before display.

	auraFrame:SetAuraInstance(self:GetUnit(), auraData);
end

function AuraContainerAuraGroupsMixin:ReleaseAuraFrameForGroup(auraGroup, auraFrame)
	auraGroup:GetFrameProvider():ReleaseFrame(auraFrame);
end

function AuraContainerAuraGroupsMixin:ReleaseAuraFrameMapForGroup(auraGroup, auraFrameMap)
	local auraInstanceID, auraFrame = next(auraFrameMap);
	local hasReleasedFrames = (auraInstanceID ~= nil);

	while auraInstanceID do
		self:ReleaseAuraFrameForGroup(auraGroup, auraFrame);
		auraFrameMap[auraInstanceID] = nil;
		auraInstanceID, auraFrame = next(auraFrameMap);
	end

	return hasReleasedFrames;
end

function AuraContainerAuraGroupsMixin:ReleaseAllAuraFramesForGroup(auraGroup)
	local framesByAuraInstanceID = auraGroup:GetFramesByAuraInstanceID();
	self:ReleaseAuraFrameMapForGroup(auraGroup, framesByAuraInstanceID);
end

function AuraContainerAuraGroupsMixin:ResetAuraFrameGroup(auraGroup)
	self:ReleaseAllAuraFramesForGroup(auraGroup);
	auraGroup:ClearFrameAssignments();
end

function AuraContainerAuraGroupsMixin:ResetAllAuraFrameGroups()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		self:ResetAuraFrameGroup(auraGroup);
	end
end
