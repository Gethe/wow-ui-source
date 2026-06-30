-- Aura sources describe where aura data comes from and how returned aura data
-- should be prepared before containers process it.

AuraContainerAuraSourceMixin = {};

function AuraContainerAuraSourceMixin:IsPrivate()
	return false;
end

function AuraContainerAuraSourceMixin:GetAuraDataByAuraInstanceID(_unitToken, _auraInstanceID)
	return nil;
end

function AuraContainerAuraSourceMixin:GetAllAuras(_unitToken, _filterString)
	return {};
end

function AuraContainerAuraSourceMixin:ApplySourceMetadata(auraData)
	-- Source-specific metadata can be added here before the aura is stored.
	auraData.isPrivate = self:IsPrivate();
end

AuraContainerPublicAuraSourceMixin = CreateFromMixins(AuraContainerAuraSourceMixin);

function AuraContainerPublicAuraSourceMixin:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID)
	return C_UnitAuras.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID);
end

function AuraContainerPublicAuraSourceMixin:GetAllAuras(unitToken, filterString)
	return C_UnitAuras.GetUnitAuras(unitToken, filterString);
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

function AuraContainerPrivateAuraSourceMixin:GetAllAuras(unitToken, filterString)
	return C_UnitAurasPrivate.GetAllPrivateAuras(unitToken, filterString);
end

-- Edit Mode uses AuraUtil so containers can display placeholder/test aura data
-- instead of live unit aura data (see AuraUtil.SetDataProvider).

AuraContainerEditModeAuraSourceMixin = CreateFromMixins(AuraContainerAuraSourceMixin);

function AuraContainerEditModeAuraSourceMixin:GetAuraDataByAuraInstanceID(unitToken, auraInstanceID)
	return AuraUtil.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID);
end

function AuraContainerEditModeAuraSourceMixin:GetAllAuras(unitToken, filterString)
	return AuraUtil.GetUnitAuras(unitToken, filterString);
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
