RAFUtil = {};

local rafVersionColors = {
	[Enum.RecruitAFriendRewardsVersion.VersionTwo] = RAF_VERSION_TWO_COLOR,
	[Enum.RecruitAFriendRewardsVersion.VersionThree] = RAF_VERSION_THREE_COLOR,
};

function RAFUtil.GetColorForRAFVersion(rafVersion)
	return rafVersionColors[rafVersion];
end

local rafVersionTextureKits = {
	[Enum.RecruitAFriendRewardsVersion.VersionTwo] = "V2",
	[Enum.RecruitAFriendRewardsVersion.VersionThree] = "V3",
};

function RAFUtil.GetTextureKitForRAFVersion(rafVersion)
	return rafVersionTextureKits[rafVersion];
end

-- Note: The art for RAF Version Two has the icons directly baked into the textures.
-- For RAF Version Three (and any future versions) we should use the new generic background textures and overlay the version icons in code.
-- This means that even if there are multiple "legacy versions" in the future, Version Two is the only one that should use the "legacy art".
function RAFUtil.DoesRAFVersionUseLegacyArt(rafVersion)
	return rafVersion == Enum.RecruitAFriendRewardsVersion.VersionTwo;
end