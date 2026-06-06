function PrivateAurasTooltipMixin:ShowAuraTooltip(unit, auraInfo)
	if not auraInfo.isPrivate then
		PrivateAurasTooltip:SetUnitAuraByAuraInstanceID(unit, auraInfo.auraInstanceID);
	end
end
