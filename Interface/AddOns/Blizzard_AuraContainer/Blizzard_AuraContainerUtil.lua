AuraContainerUtil = {};

function AuraContainerUtil.ShouldIncludeAuraForFilterString(container, filterString, auraData)
	return not C_UnitAuras.IsAuraFilteredOutByInstanceID(container:GetUnit(), auraData.auraInstanceID, filterString);
end
