GlowEmitterMixin = {}

GlowEmitterMixin.Anims =
{
	FadeAnim = 1,
	FaintFadeAnim = 2,
	NPE_RedButton_GreenGlow = 3,
	GreenGlow = 4,
};

function GlowEmitterMixin:OnLoad()
	self.anims = {
		[GlowEmitterMixin.Anims.FadeAnim] = self.FadeAnim,
		[GlowEmitterMixin.Anims.FaintFadeAnim] = self.FaintFadeAnim,
		[GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow] = self.NPE_RedButton_GreenGlow,
		[GlowEmitterMixin.Anims.GreenGlow] = self.GreenGlow,
	};

	self.NineSlice:SetBorderBlendMode("ADD");
end

function GlowEmitterMixin:Play(animType)
	local anim = self.anims[animType];
	assert(anim, string.format("Missing an animation for animType %d", animType));
	anim:Play();
end

GlowEmitterFactory = CreateFromMixins(EffectFactoryMixin);

function GlowEmitterFactory:Attach(frame, target, offsetX, offsetY, width, height)
	EffectFactoryMixin.Attach(self, frame, target, offsetX, offsetY, width, height);

	if offsetX == nil then
		offsetX = 12;
	end

	if offsetY == nil then
		offsetY = 0;
	end

	if width then
		frame:SetPoint("CENTER");
	else
		frame:SetPoint("LEFT", target, -offsetX, offsetY);
		frame:SetPoint("RIGHT", target, offsetX, offsetY);
	end
end

GlowEmitterFactory:Init("Frame", "GlowEmitterTemplate");
