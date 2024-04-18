NewFeatureLabelMixin = {};

function NewFeatureLabelMixin:OnLoad()
	self.BGLabel:SetText(self.label);
	self.Label:SetText(self.label);
	self.Label:SetJustifyH(self.justifyH);
	self.BGLabel:SetJustifyH(self.justifyH);
end

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
