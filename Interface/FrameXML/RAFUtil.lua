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

function RAFUtil.DoesRAFVersionUseLegacyArt(rafVersion)
	return rafVersion == Enum.RecruitAFriendRewardsVersion.VersionTwo;
end