function PrivateAurasTooltipMixin:ShowAuraTooltip(unit, auraInfo)
	-- TODO: Add support, this won't work in classic
	if not auraInfo.isPrivate then
		PrivateAurasTooltip:SetUnitAuraByAuraInstanceID(unit, auraInfo.auraInstanceID);
	end
end
