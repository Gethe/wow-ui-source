-- Used to mix in with the Mixins for pieces of nameplates such as the health bar, auras frame,
-- raid target frame, classification frame, etc. Has common functionality for some/all of the various pieces.
NamePlateComponentMixin = {};

function NamePlateComponentMixin:IsWidgetsOnlyMode()
	return self.widgetsOnly == true;
end

function NamePlateComponentMixin:SetWidgetsOnlyMode(widgetsOnly)
	if self.widgetsOnly == widgetsOnly then
		return;
	end

	self.widgetsOnly = widgetsOnly;

	-- Most pieces of the nameplate need to be hidden when in widgets only mode.
	self:UpdateShownState();
end
