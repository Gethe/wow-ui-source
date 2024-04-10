
--------------------------------------------------
-- TABARD MODEL FRAME MIXIN
TabardModelFrameMixin = CreateFromMixins(ModelFrameMixin);

function TabardModelFrameMixin:OnLoad()
	self.rotation = 0;
	self:SetRotation(self.rotation);
end

function TabardModelFrameMixin:OnUpdate(elapsedTime)
	self:UpdateRotation(TabardCharacterModelRotateLeftButton, TabardCharacterModelRotateRightButton, elapsedTime);
end

