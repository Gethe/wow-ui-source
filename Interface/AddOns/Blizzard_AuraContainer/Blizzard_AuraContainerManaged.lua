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
	FullAuraRebuild = Flags_CreateMask(AuraContainerDirtyFlag.ParseAuras, AuraContainerDirtyFlag.ResetAuraFrames),

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

AuraContainerManagedSharedMixin = CreateFromMixins(AuraContainerSharedMixin);

function AuraContainerManagedSharedMixin:UpdateAllAuras()
	self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
end

AuraContainerManagedInboundMixin = CreateFromMixins(AuraContainerInboundMixin, AuraContainerManagedSharedMixin);
AuraContainerManagedMixin = CreateFromMixins(AuraContainerPrivateMixin, AuraContainerManagedSharedMixin, DirtyPhaseMixin, AuraContainerAuraGroupsMixin);

function AuraContainerManagedMixin:OnLoad_Intrinsic()
	AuraContainerPrivateMixin.OnLoad_Intrinsic(self);

	self:InitDirtyPhases();
	self:InitAuraGroups();

	self:SetDirtyPhases({
		{ flag = AuraContainerDirtyFlag.ParseAuras, handler = function() return self:ProcessParseAuras(); end, },
		{ flag = AuraContainerDirtyFlag.ResetAuraFrames, handler = function() return self:ProcessResetAuraFrames(); end, },
		{ flag = AuraContainerDirtyFlag.RefreshAuraFrames, handler = function() return self:ProcessRefreshAuraFrames(); end, },
		{ flag = AuraContainerDirtyFlag.RefreshAuraFrameDisplay, handler = function() return self:ProcessRefreshAuraFrameDisplay(); end, },
		{ flag = AuraContainerDirtyFlag.RebuildLayoutGroups, handler = function() return self:ProcessRebuildLayoutGroups(); end, },
		{ flag = AuraContainerDirtyFlag.ApplyLayout, handler = function() return self:ProcessApplyLayout(); end, },
	});

	self.useEditModeSource = false;
end

function AuraContainerManagedMixin:OnUpdate(_elapsedTime)
	self:ProcessDirtyFlags();
end

function AuraContainerManagedMixin:OnDirtyChanged(dirty)
	if dirty then
		self:SetOnUpdateMode(Enum.OnUpdateMode.RunWhenVisibleOnce);
	end
end

function AuraContainerManagedMixin:OnUnitAuraUpdate(unitAuraUpdateInfo)
	if self:ShouldUseEditModeSource() then
		return;
	end

	self:ProcessUnitAuraUpdate(unitAuraUpdateInfo, AuraContainerPublicAuraSource);
end

function AuraContainerManagedMixin:OnUnitPrivateAuraUpdate(unitAuraUpdateInfo)
	if self:ShouldUseEditModeSource() then
		return;
	end

	self:ProcessUnitAuraUpdate(unitAuraUpdateInfo, AuraContainerPrivateAuraSource);
end

function AuraContainerManagedMixin:OnAuraDataProviderSwitch(useRealDataProvider)
	self:SetUseEditModeSource(not useRealDataProvider);
end

function AuraContainerManagedMixin:ShouldIncludePrivateAuraSource()
	return self:ShouldRegisterForPrivateAuras();
end

function AuraContainerManagedMixin:ShouldUseEditModeSource()
	return self.useEditModeSource;
end

function AuraContainerManagedMixin:SetUseEditModeSource(useEditModeSource)
	useEditModeSource = useEditModeSource == true;

	if self.useEditModeSource ~= useEditModeSource then
		self.useEditModeSource = useEditModeSource;
		self:UpdateAllAuras();
	end
end

function AuraContainerManagedMixin:GetAuraSources()
	if self:ShouldUseEditModeSource() then
		return AuraContainerAuraSourceLists.EditMode;
	elseif self:ShouldIncludePrivateAuraSource() then
		return AuraContainerAuraSourceLists.PublicAndPrivate;
	end

	return AuraContainerAuraSourceLists.PublicOnly;
end

function AuraContainerManagedMixin:EnumerateAuraSources()
	return ipairs(self:GetAuraSources());
end

function AuraContainerManagedMixin:ProcessUnitAuraUpdate(unitAuraUpdateInfo, auraSource)
	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
		-- Full updates defer the rebuild as, for example, if a unit's public
		-- auras require a full update, the private ones will probably also
		-- call into here as well.
		self:MarkDirty(AuraContainerDirtyMask.FullAuraRebuild);
		return;
	end

	local aurasChanged = false;

	if unitAuraUpdateInfo.addedAuras ~= nil then
		for _index, auraData in ipairs(unitAuraUpdateInfo.addedAuras) do
			self:PrepareAuraData(auraData, auraSource);
			aurasChanged = self:AddAura(auraData) or aurasChanged;
		end
	end

	if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
		for _index, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
			local auraData = self:GetAuraDataByAuraInstanceID(auraInstanceID, auraSource);
			aurasChanged = self:UpdateAura(auraInstanceID, auraData) or aurasChanged;
		end
	end

	if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
		for _index, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
			aurasChanged = self:RemoveAura(auraInstanceID) or aurasChanged;
		end
	end

	if aurasChanged then
		self:MarkDirty(AuraContainerDirtyMask.AuraFrameAssignments);
	end
end

function AuraContainerManagedMixin:GetAuraDataByAuraInstanceID(auraInstanceID, auraSource)
	local auraData = auraSource:GetAuraDataByAuraInstanceID(self:GetUnit(), auraInstanceID);

	if auraData ~= nil then
		self:PrepareAuraData(auraData, auraSource);
	end

	return auraData;
end

function AuraContainerManagedMixin:PrepareAuraData(auraData, auraSource)
	auraSource:ApplySourceMetadata(auraData);
	self:ApplyAuraMetadata(auraData);
end

function AuraContainerManagedMixin:ApplyAuraMetadata(_auraData)
	-- Override in the container to add container-specific aura metadata before
	-- group membership is checked. This is a good place to apply calls to
	-- AuraUtil.ProcessAura (and store the result on the aura data itself).
end

function AuraContainerManagedMixin:ClearAllAuras()
	for _index, auraGroup in self:EnumerateAuraGroups() do
		auraGroup:ClearAuras();
	end
end

function AuraContainerManagedMixin:ParseAllAuras()
	self:ClearAllAuras();

	for _sourceIndex, auraSource in self:EnumerateAuraSources() do
		for _groupIndex, auraGroup in self:EnumerateAuraGroups() do
			local filterString = auraGroup:GetFilterString();
			for _auraIndex, auraData in ipairs(auraSource:GetAllAuras(self:GetUnit(), filterString)) do
				self:PrepareAuraData(auraData, auraSource);
				self:UpdateAuraGroupMembership(auraGroup, auraData.auraInstanceID, auraData);
			end
		end
	end
end

function AuraContainerManagedMixin:ProcessParseAuras()
	self:ParseAllAuras();

	return AuraContainerDirtyFlag.RefreshAuraFrames;
end

function AuraContainerManagedMixin:ProcessResetAuraFrames()
	self:ResetAuraFrames();

	return AuraContainerDirtyFlag.RefreshAuraFrames;
end

function AuraContainerManagedMixin:ProcessRefreshAuraFrames()
	local refreshResult = self:RefreshAuraFrames();

	if bit.band(refreshResult, AuraContainerGroupRefreshResult.VisibilityChanged) ~= 0 then
		return AuraContainerDirtyFlag.RebuildLayoutGroups;
	elseif bit.band(refreshResult, AuraContainerGroupRefreshResult.FrameAssignmentsChanged) ~= 0 then
		return AuraContainerDirtyFlag.ApplyLayout;
	end

	return AuraContainerDirtyFlag.None;
end

function AuraContainerManagedMixin:ProcessRefreshAuraFrameDisplay()
	self:RefreshAuraFrameDisplay();
	return AuraContainerDirtyFlag.None;
end

function AuraContainerManagedMixin:ProcessRebuildLayoutGroups()
	self:RebuildLayoutGroups();
	return AuraContainerDirtyFlag.ApplyLayout;
end

function AuraContainerManagedMixin:ProcessApplyLayout()
	self:ApplyLayout();
	return AuraContainerDirtyFlag.None;
end

function AuraContainerManagedMixin:ResetAuraFrames()
	self:ResetAllAuraFrameGroups();
	self:OnAuraFramesReset();
end

function AuraContainerManagedMixin:RefreshAuraFrames()
	return self:RefreshDirtyAuraFrameGroups();
end

function AuraContainerManagedMixin:RefreshAuraFrameDisplay()
	-- Override to update frame state without rebinding auras.
end

function AuraContainerManagedMixin:RebuildLayoutGroups()
	-- Override to rebuild the frame groups used by layout.
end

function AuraContainerManagedMixin:ApplyLayout()
	-- Override to position and size aura frames.
end

function AuraContainerManagedMixin:OnAuraFramesReset()
	-- Override in the container to reset state after frame ownership is cleared.
end
