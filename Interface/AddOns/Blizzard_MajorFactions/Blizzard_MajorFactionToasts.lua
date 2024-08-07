MajorFactionUnlockToasts = {};

-- Entry Ids in the UIScriptedAnimationEffect table.
local majorFactionSwirlEffects = 
{
	Expedition = {152},
	Centaur = {152},
	Tuskarr = {152},
	Valdrakken = {152},
	Niffen = {152},
	Dream = {152},
	web = {178},
	storm = {178},
	candle = {178},
	flame = {178},
};

-- Entries in the GlobalColor table.
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

function MajorFactionCelebrationBannerMixin:AddSwirlEffects(textureKit)
	local swirlEffects = MajorFactionUnlockToasts.GetSwirlEffectsByTextureKit(textureKit);
	if not swirlEffects then
		return;
	end

	for i, effect in ipairs(swirlEffects) do
		self.IconSwirlModelScene:AddEffect(effect, self);
	end
end

function MajorFactionCelebrationBannerMixin:GetFactionColorByTextureKit(textureKit)
	return _G[majorFactionColorFormat:format(strupper(textureKit))] or HIGHLIGHT_FONT_COLOR;
end