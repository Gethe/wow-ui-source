NewFeatureLabelMixin = {};

function NewFeatureLabelMixin:ClearAlert()
	-- derive
	self:SetShown(false);
end

function NewFeatureLabelMixin:OnShow()
	if self.animateGlow then
		self.Fade:Play();
	end
end

function NewFeatureLabelMixin:OnHide()
	if self.animateGlow then
		self.Fade:Stop();
	end
end
