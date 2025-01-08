MajorFactionUnlockToasts = {};

-- Entry Ids in the UIScriptedAnimationEffect table.
local majorFactionSwirlEffects = 
{
	[LE_EXPANSION_DRAGONFLIGHT] = {152},
	[LE_EXPANSION_WAR_WITHIN] = {178},
};

function MajorFactionUnlockToasts.GetSwirlEffectsByExpansion(expansion)
	return majorFactionSwirlEffects[expansion];
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
end

function MajorFactionCelebrationBannerMixin:SetMajorFactionSwirlEffects(expansion)
	self:CancelIconSwirlEffects();
	self:AddSwirlEffects(expansion);
end

function MajorFactionCelebrationBannerMixin:SetMajorFactionExpansionLayoutInfo(expansionLayoutInfo)
	if not expansionLayoutInfo then
		return;
	end

	if not expansionLayoutInfo.textureDataTable then
		return;
	end

	--[[ Loop through each entry and set the values explicitly provided.
		Example format:
		textureDataTable = {
			["ToastBG"] = {
				atlas = "majorfaction-celebration-toastBG",
				useAtlasSize = true,
				anchors = {
					["TOP"] = { x = 0, y = -77, relativePoint = "TOP" },
				},
			},
	]]
	for textureKey, textureData in pairs(expansionLayoutInfo.textureDataTable) do
		local texture = self[textureKey];
		if texture then
			if textureData.atlas then
				local useAtlasSize = textureData.useAtlasSize or false;
				texture:SetAtlas(textureData.atlas, useAtlasSize);
			end

			if textureData.anchors then
				for anchorKey, anchorPoint in pairs(textureData.anchors) do
					texture:SetPoint(anchorKey, self, anchorPoint.relativePoint, anchorPoint.x, anchorPoint.y);
				end
			end
		end
	end
end

function MajorFactionCelebrationBannerMixin:AddSwirlEffects(expansion)
	local swirlEffects = MajorFactionUnlockToasts.GetSwirlEffectsByExpansion(expansion);
	if not swirlEffects then
		return;
	end

	for i, effect in ipairs(swirlEffects) do
		self.IconSwirlModelScene:AddEffect(effect, self);
	end
end