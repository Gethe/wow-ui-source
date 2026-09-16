-- Used to mix in with the Mixins for pieces of nameplates such as the health bar, auras frame,
-- raid target frame, classification frame, etc. Has common functionality for some/all of the various pieces.
NamePlateComponentMixin = {};

function NamePlateComponentMixin:IsShowOnlyName()
	return self.showOnlyName == true;
end

function NamePlateComponentMixin:SetShowOnlyName(showOnlyName)
	if self.showOnlyName == showOnlyName then
		return;
	end

	self.showOnlyName = showOnlyName;

	-- Most pieces of the nameplate need to be hidden when in show-only-names mode.
	self:UpdateShownState();
end

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
