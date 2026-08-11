function PrivateAurasTooltipMixin:ShowAuraTooltip(unit, auraInfo)
	if not auraInfo.isPrivate then
		self:SetUnitAuraByAuraInstanceID(unit, auraInfo.auraInstanceID);
	end
end
