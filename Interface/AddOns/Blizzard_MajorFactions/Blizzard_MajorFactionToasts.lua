MajorFactionUnlockToasts = {};

local majorFactionSwirlEffects = 
{
	Expedition = {152},
	Centaur = {152},
	Tuskarr = {152},
	Valdrakken = {152},
};

local majorFactionColorFormat = "%s_MAJOR_FACTION_COLOR";

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
		[self.Icon.Texture] = "majorfaction-celebration-%s",
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

function MajorFactionCelebrationBannerMixin:GetFactionColorByTextureKit(textureKit)
	return _G[majorFactionColorFormat:format(strupper(textureKit))];
end