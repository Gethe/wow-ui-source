-- Replace these placeholder atlases with the Talebound difficulty art.
local difficultyAtlases = {
	[DifficultyUtil.ID.TaleboundNormal] = "ui-hud-minimap-guildbanner-normal-large",
	[DifficultyUtil.ID.TaleboundVeteran] = "ui-hud-minimap-guildbanner-veteran-large",
	[DifficultyUtil.ID.TaleboundHeroic] = "ui-hud-minimap-guildbanner-heroic-large",
	[DifficultyUtil.ID.TaleboundMythic] = "ui-hud-minimap-guildbanner-mythic-large",
};

function InstanceDifficultyMixin:GetDifficultyAtlas(difficultyID)
	return difficultyAtlases[difficultyID];
end

local InstanceDifficultyMixin_GetDifficultyTexture = InstanceDifficultyMixin.GetDifficultyTexture;
function InstanceDifficultyMixin:GetDifficultyTexture(difficultyTextureFrame, displayChallengeMode, displayMythic, displayHeroic, hasWorldTier)
	if difficultyTextureFrame then
		local normalTexture = difficultyTextureFrame.NormalTexture;
		local _, _, difficultyID = GetInstanceInfo();
		local atlas = self:GetDifficultyAtlas(difficultyID);
		local useAtlasSize = true;
		if atlas and normalTexture and not displayChallengeMode and not hasWorldTier then
			if not difficultyTextureFrame.originalNormalAtlas then
				difficultyTextureFrame.originalNormalAtlas = normalTexture:GetAtlas();
			end
			normalTexture:SetAtlas(atlas, useAtlasSize);
			return normalTexture;
		end

		if difficultyTextureFrame.originalNormalAtlas then
			normalTexture:SetAtlas(difficultyTextureFrame.originalNormalAtlas, useAtlasSize);
			difficultyTextureFrame.originalNormalAtlas = nil;
		end
	end

	return InstanceDifficultyMixin_GetDifficultyTexture(self, difficultyTextureFrame, displayChallengeMode, displayMythic, displayHeroic, hasWorldTier);
end
