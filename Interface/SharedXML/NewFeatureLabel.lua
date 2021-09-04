NewFeatureLabelMixin = {};

function NewFeatureLabelMixin:ClearAlert()
	-- derive
	self:SetShown(false);
end

function NewFeatureLabelMixin:OnShow()
	self.Fade:Play();
end

function NewFeatureLabelMixin:OnHide()
	self.Fade:Stop();
end
