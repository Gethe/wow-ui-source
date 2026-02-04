
MajorFactionCelebrationBannerMixin = {};

function MajorFactionCelebrationBannerMixin:SetMajorFactionTextureKit(textureKit)
	local textureKitRegions = {
		[self.TopIcon] = "majorfactions_icons_%s512",
	};
	
	SetupTextureKitOnFrames(textureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.IgnoreAtlasSize);
end
