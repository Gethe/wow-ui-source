PVPUtil = {};

function PVPUtil.GetTierName(tierEnum)
	return _G["PVP_RANK_"..tierEnum.."_NAME"];
end

function PVPUtil.GetTierDescription(tierEnum)
	return _G["PVP_RANK_"..tierEnum.."_NEXT_RANK_DESC"];
end
function PVPUtil.GetBracketName(bracket)
	return _G["PVP_BRACKET_"..bracket];
end

