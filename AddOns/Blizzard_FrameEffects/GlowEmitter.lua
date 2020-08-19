GlowEmitterMixin = {}

GlowEmitterMixin.Anims =
{
	FadeAnim = 1,
	FaintFadeAnim = 2,
};

function GlowEmitterMixin:Play(animType)
	if animType == GlowEmitterMixin.Anims.FadeAnim then
		self.FadeAnim:Play();
	elseif animType == GlowEmitterMixin.Anims.FaintFadeAnim then
		self.FaintFadeAnim:Play();
	end
end

GlowEmitterFactory = CreateFromMixins(EffectFactoryMixin);

function GlowEmitterFactory:OnLoad()
	EffectFactoryMixin.OnLoad(self, "GlowEmitterTemplate");
end

function GlowEmitterFactory:Attach(frame, target)
	frame:SetParent(target);
	frame:SetFrameStrata("DIALOG");
	
	frame:ClearAllPoints();

	local offset = 12;
	frame:SetPoint("LEFT", target, -offset, 0);
	frame:SetPoint("RIGHT", target, offset, 0);
end

GlowEmitterFactory:OnLoad();