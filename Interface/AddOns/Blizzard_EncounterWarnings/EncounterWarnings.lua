EncounterWarningsMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin);

function EncounterWarningsMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);
end

function EncounterWarningsMixin:OnShow()
end

function EncounterWarningsMixin:OnHide()
end

function EncounterWarningsMixin:OnEvent()
end

function EncounterWarningsMixin:IsEditing()
	return self.isEditing;
end

function EncounterWarningsMixin:SetIsEditing(isEditing)
	self.isEditing = isEditing;
	self:UpdateVisibility();
end

function EncounterWarningsMixin:EvaluteVisibilityState()
	-- EETODO: Real logic here.
	return self.isEditing;
end

function EncounterWarningsMixin:UpdateVisibility()
	self:SetShown(self:EvaluteVisibilityState());
end
