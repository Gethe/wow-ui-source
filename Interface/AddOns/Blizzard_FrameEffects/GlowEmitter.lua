GlowEmitterMixin = {}

GlowEmitterMixin.Anims =
{
	FadeAnim = 1,
	FaintFadeAnim = 2,
	NPE_RedButton_GreenGlow = 3,
	GreenGlow = 4,
};

function GlowEmitterMixin:Play(animType)
	if animType == GlowEmitterMixin.Anims.FadeAnim then
		self.FadeAnim:Play();
	elseif animType == GlowEmitterMixin.Anims.FaintFadeAnim then
		self.FaintFadeAnim:Play();
	elseif animType == GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow then
		self.NPE_RedButton_GreenGlow:Play();
	elseif animType == GlowEmitterMixin.Anims.GreenGlow then
		self.GreenGlow:Play();
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
	frame.NineSlice:SetBorderBlendMode("ADD");

	frame:ClearAllPoints();

	local offsetX = self.offsetXOverride and self.offsetXOverride or 12;
	local offsetY = self.offsetYOverride and self.offsetYOverride or 0;
	frame:SetPoint("LEFT", target, -offsetX, offsetY);
	frame:SetPoint("RIGHT", target, offsetX, offsetY);

	self.offsetXOverride = nil;
	self.offsetYOverride = nil;

	if self.heightOverride then
		frame:SetHeight(self.heightOverride);
		self.heightOverride = nil;
	end
end

function GlowEmitterFactory:SetOffset(offsetX, offsetY)
	self.offsetXOverride = offsetX;
	self.offsetYOverride = offsetY;
end

function GlowEmitterFactory:SetHeight(height)
	self.heightOverride = height;
end

GlowEmitterFactory:OnLoad();