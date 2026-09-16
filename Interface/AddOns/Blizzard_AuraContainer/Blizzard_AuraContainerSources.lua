-- Aura sources describe where aura data comes from and how returned aura data
-- should be prepared before containers process it.

AuraContainerAuraSourceMixin = {};

function AuraContainerAuraSourceMixin:IsPrivate()
	return false;
end

function AuraContainerAuraSourceMixin:GetAuraDataByAuraInstanceID(_unitToken, _auraInstanceID)
	return nil;
end

function AuraContainerAuraSourceMixin:GetAllAuraInstanceIDs(_unitToken, _filterString)
	local auraInstanceIDs = {};
	local hasMatchedFilterString = true;

	return auraInstanceIDs, hasMatchedFilterString;
end

function AuraContainerAuraSourceMixin:GetAuraCasterGUID(_unitToken, _auraInstanceID)
	return nil;
end

function AuraContainerAuraSourceMixin:ApplySourceMetadata(_unitToken, auraData)
	-- Source-specific metadata can be added here before the aura is stored.
	auraData.auraType = AuraContainerAuraDataType.Aura;
	auraData.isPrivate = self:IsPrivate();
end

AuraContainerPublicAuraSourceMixin = CreateFromMixins(AuraContainerAuraSourceMixin);

function AuraContainerPublicAuraSourceMixin:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID)
	return C_UnitAuras.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID);
end

function AuraContainerPublicAuraSourceMixin:GetAllAuraInstanceIDs(unitToken, filterString)
	local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unitToken, filterString);
	local hasMatchedFilterString = true;

	return auraInstanceIDs, hasMatchedFilterString;
end

function AuraContainerPublicAuraSourceMixin:GetAuraCasterGUID(unitToken, auraInstanceID)
	return C_UnitAuras.GetAuraCasterGUID(unitToken, auraInstanceID);
end

-- Private auras currently have their own source and APIs. The reason this has
-- been retained for now is because we don't (yet) want UNIT_AURA being signaled
-- when private auras are applied or removed. Once that's no longer a problem,
-- we can likely just allow the regular C_UnitAuras APIs handle them.

AuraContainerPrivateAuraSourceMixin = CreateFromMixins(AuraContainerAuraSourceMixin);

function AuraContainerPrivateAuraSourceMixin:IsPrivate()
	return true;
end

function AuraContainerPrivateAuraSourceMixin:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID)
	return C_UnitAurasPrivate.GetAuraDataByAuraInstanceIDPrivate(unitToken, auraInstanceID);
end

function AuraContainerPrivateAuraSourceMixin:GetAllAuraInstanceIDs(unitToken, _filterString)
	-- Private auras currently ignore filter strings in this query. We instead
	-- filter them out over in ShouldIncludeAuraForFilterString.
	local auraInstanceIDs = C_UnitAurasPrivate.GetAllPrivateAuraInstanceIDs(unitToken);
	local hasMatchedFilterString = false;

	return auraInstanceIDs, hasMatchedFilterString;
end

function AuraContainerPrivateAuraSourceMixin:GetAuraCasterGUID(unitToken, auraInstanceID)
	return C_UnitAurasPrivate.GetPrivateAuraCasterGUID(unitToken, auraInstanceID);
end

-- Edit Mode uses AuraUtil so containers can display placeholder/test aura data
-- instead of live unit aura data (see AuraUtil.SetDataProvider).

AuraContainerEditModeAuraSourceMixin = CreateFromMixins(AuraContainerAuraSourceMixin);

function AuraContainerEditModeAuraSourceMixin:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID)
	return AuraUtil.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID);
end

function AuraContainerEditModeAuraSourceMixin:GetAllAuraInstanceIDs(unitToken, filterString)
	local auras = AuraUtil.GetUnitAuras(unitToken, filterString);
	local auraInstanceIDs = table.create(#auras);
	local hasMatchedFilterString = true;

	for index, auraData in ipairs(auras) do
		auraInstanceIDs[index] = auraData.auraInstanceID;
	end

	return auraInstanceIDs, hasMatchedFilterString;
end

AuraContainerPublicAuraSource = CreateFromMixins(AuraContainerPublicAuraSourceMixin);
AuraContainerPrivateAuraSource = CreateFromMixins(AuraContainerPrivateAuraSourceMixin);
AuraContainerEditModeAuraSource = CreateFromMixins(AuraContainerEditModeAuraSourceMixin);

AuraContainerAuraSourceLists =
{
	PublicOnly =
	{
		AuraContainerPublicAuraSource,
	},

	PublicAndPrivate =
	{
		AuraContainerPublicAuraSource,
		AuraContainerPrivateAuraSource,
	},

	EditMode =
	{
		AuraContainerEditModeAuraSource,
	},
};
