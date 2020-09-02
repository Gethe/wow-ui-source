GlowEmitterMixin = {}

GlowEmitterMixin.Anims =
{
	FadeAnim = 1,
	FaintFadeAnim = 2,
	NPE_RedButton_GreenGlow = 3,
};

function GlowEmitterMixin:Play(animType)
	if animType == GlowEmitterMixin.Anims.FadeAnim then
		self.FadeAnim:Play();
	elseif animType == GlowEmitterMixin.Anims.FaintFadeAnim then
		self.FaintFadeAnim:Play();
	elseif animType == GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow then
		self.NPE_RedButton_GreenGlow:Play();
	else
		error("Provide a play type")
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