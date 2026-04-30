PrivateAurasTooltipMixin = {};

function PrivateAurasTooltipMixin:OnLoad_PrivateAuraTooltip()
	GameTooltip_OnLoad(self);
	SharedTooltip_OnLoad(self);
end

function PrivateAurasTooltipMixin:ShowAuraTooltip(unit, auraInfo)
	if auraInfo.isPrivate then
		PrivateAurasTooltip:SetUnitPrivateAura(unit, auraInfo.auraInstanceID);
	else
		PrivateAurasTooltip:SetUnitAuraByAuraInstanceID(unit, auraInfo.auraInstanceID);
	end
end
