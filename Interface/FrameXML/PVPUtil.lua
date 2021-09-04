PVPUtil = {};

local tierEnumToName =
{
	[0] = PVP_RANK_0_NAME,
	[1] = PVP_RANK_1_NAME,
	[2] = PVP_RANK_2_NAME,
	[3] = PVP_RANK_3_NAME,
	[4] = PVP_RANK_4_NAME,
	[5] = PVP_RANK_5_NAME,
};

function PVPUtil.GetTierName(tierEnum)
	return tierEnumToName[tierEnum];
end

