TorghastGemsAnimationMixin = {};

function TorghastGemsAnimationMixin:Reset()
	self.Anim:Stop();	
	self.FullGem:SetAlpha(0);
	self.Sheen:SetAlpha(0);
	self.Glow:SetAlpha(0);
end

function TorghastGemsAnimationMixin:Play()
	self.Anim:Play();
end
