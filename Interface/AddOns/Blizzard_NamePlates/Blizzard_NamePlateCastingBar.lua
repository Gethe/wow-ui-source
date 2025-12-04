-- Displays the info about the unit to which the nameplate is attached.
-- This mixin is a child of a frame that has been created in code and is using NamePlateBaseMixin.
NamePlateCastingBarMixin = CreateFromMixins(CastingBarMixin, NamePlateComponentMixin);

function NamePlateCastingBarMixin:OnLoad()
	local unit = nil;
	local showTradeSkills = false;
	local showShield = true;
	CastingBarMixin.OnLoad(self, unit, showTradeSkills, showShield);
end

function NamePlateCastingBarMixin:ShouldShowCastBar()
	if self:IsWidgetsOnlyMode() then
		return false;
	end

	return CastingBarMixin.ShouldShowCastBar(self);
end
