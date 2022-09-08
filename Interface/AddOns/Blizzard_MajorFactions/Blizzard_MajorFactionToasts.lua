MajorFactionUnlockToasts = {};

local majorFactionSwirlEffects = 
{
	Kyrian = {91},
	Venthyr = {92},
	NightFae = {93, 96},
	Necrolord = {94},
};

function MajorFactionUnlockToasts.GetSwirlEffectsByTextureKit(textureKit)
	return majorFactionSwirlEffects[textureKit];
end

MajorFactionCelebrationBannerMixin = {};

function MajorFactionCelebrationBannerMixin:CancelIconSwirlEffects()
	self.IconSwirlModelScene:ClearEffects();
end

function MajorFactionCelebrationBannerMixin:OnHide()
	self:CancelIconSwirlEffects();
end

function MajorFactionCelebrationBannerMixin:SetMajorFactionTextureKit(textureKit)
	local textureKitRegions = {
		[self.GlowLineTop] = "CovenantChoice-Celebration-%sCloudyLine",
		[self.GlowLineTopAdditive] = "CovenantChoice-Celebration-%s-DetailLine",
		[self.Icon.Tex] = "CovenantChoice-Celebration-%sSigil",
	};

	SetupTextureKitOnFrames(textureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self:CancelIconSwirlEffects();

	self:AddSwirlEffects(textureKit);
end

function MajorFactionCelebrationBannerMixin:AddSwirlEffects(textureKit)
	local swirlEffects = MajorFactionUnlockToasts.GetSwirlEffectsByTextureKit(textureKit);
	for i, effect in ipairs(swirlEffects) do
		self.IconSwirlModelScene:AddEffect(effect, self);
	end
end