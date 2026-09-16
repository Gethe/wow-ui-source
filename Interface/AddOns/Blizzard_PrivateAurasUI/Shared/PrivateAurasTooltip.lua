PrivateAurasTooltipMixin = {};

function PrivateAurasTooltipMixin:OnLoad_PrivateAuraTooltip()
	GameTooltip_OnLoad(self);
	SharedTooltip_OnLoad(self);
end

function PrivateAurasTooltipMixin:ShowAuraTooltip(unit, auraInfo)
	if auraInfo.isPrivate then
		self:SetUnitPrivateAura(unit, auraInfo.auraInstanceID);
	else
		self:SetUnitAuraByAuraInstanceID(unit, auraInfo.auraInstanceID);
	end
end
