PVPUtil = {};

SL_START_SEASON = 30;

function PVPUtil.GetTierName(tierEnum)
	return _G["PVP_RANK_"..tierEnum.."_NAME"];
end

function PVPUtil.GetTierDescription(tierEnum)
	return _G["PVP_RANK_"..tierEnum.."_NEXT_RANK_DESC"];
end
function PVPUtil.GetBracketName(bracket)
	return _G["PVP_BRACKET_"..bracket];
end

function PVPUtil.IsInActiveBattlefield()
	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i);
		if status == "active" then
			return true, i;
		end
	end

	return false, nil;
end

function PVPUtil.GetCurrentSeasonNumber()
	return C_PvP.GetUIDisplaySeason();
end
