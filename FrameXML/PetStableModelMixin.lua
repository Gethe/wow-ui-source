--------------------------------------------------
-- PET STABLE MODEL FRAME MIXIN
PetStableModelFrameMixin = CreateFromMixins(ModelFrameMixin);

function PetStableModelFrameMixin:OnLoad()
	ModelFrameMixin.OnLoad(self, MODELFRAME_MAX_PLAYER_ZOOM);
	self:SetCamDistanceScale(1.3);
end

