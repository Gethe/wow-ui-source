CovenantChoiceToasts = {};

local covenantSwirlEffects = 
{
	Kyrian = {91},
	Venthyr = {92},
	NightFae = {93, 96},
	Necrolord = {94},
};

function CovenantChoiceToasts.GetSwirlEffectsByTextureKit(textureKit)
	return covenantSwirlEffects[textureKit];
end

CovenantCelebrationBannerMixin = {};

function CovenantCelebrationBannerMixin:CancelIconSwirlEffects()
	self.IconSwirlModelScene:ClearEffects();
end

function CovenantCelebrationBannerMixin:OnHide()
	self:CancelIconSwirlEffects();
end

function CovenantCelebrationBannerMixin:SetCovenantTextureKit(covenantTextureKit)
	local textureKitRegions = {
		[self.GlowLineTop] = "CovenantChoice-Celebration-%sCloudyLine",
		[self.GlowLineTopAdditive] = "CovenantChoice-Celebration-%s-DetailLine",
		[self.Icon.Tex] = "CovenantChoice-Celebration-%sSigil",
	};

	SetupTextureKitOnFrames(covenantTextureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self:CancelIconSwirlEffects();

	self:AddSwirlEffects(covenantTextureKit);
end

function CovenantCelebrationBannerMixin:AddSwirlEffects(covenantTextureKit)
	local swirlEffects = CovenantChoiceToasts.GetSwirlEffectsByTextureKit(covenantTextureKit);
	for i, effect in ipairs(swirlEffects) do
		self.IconSwirlModelScene:AddEffect(effect, self);
	end
end