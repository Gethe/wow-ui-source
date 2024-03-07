PartyUtil = {};

local unitTags = { "player", "party1", "party2", "party3", "party4" };

function PartyUtil.GetMinLevel()
	local minLevel = math.huge;
	for index, unit in ipairs(unitTags) do
		if UnitExists(unit) then
			minLevel = math.min(minLevel, UnitLevel(unit));
		end
	end
	return minLevel;
end

local function GetChromieTimeLocationString(unitToken)
	local expansionID = UnitChromieTimeID(unitToken);
	local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID);
	local expansion = option and option.name or "";
	if unitToken == "player" then
		return PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION:format(expansion);
	else
		return PARTY_PLAYER_CHROMIE_TIME_OTHER_LOCATION:format(expansion);
	end
end

local function GetChromieTimeInstructionString(inChromieTime)
	local factionGroup = UnitFactionGroup("player");
	if factionGroup == "Horde" then
		if inChromieTime then
			return PARTY_PLAYER_CHROMIE_TIME_SELF_HORDE;
		else
			return PARTY_PLAYER_CHROMIE_TIME_OTHER_HORDE;
		end
	elseif factionGroup == "Alliance" then
		if inChromieTime then
			return PARTY_PLAYER_CHROMIE_TIME_SELF_ALLIANCE;
		else
			return PARTY_PLAYER_CHROMIE_TIME_OTHER_ALLIANCE;
		end
	end
end

local function GetChromieTimeString(unitToken)
	local inChromieTime = C_PlayerInfo.IsPlayerInChromieTime();
	if not (inChromieTime or C_PlayerInfo.CanPlayerEnterChromieTime()) then
		local location = GetChromieTimeLocationString(unitToken);
		return PARTY_PLAYER_CHROMIE_TIME_FMT:format(location, PARTY_PLAYER_CHROMIE_TIME_INELIGIBLE);
	else
		local location = GetChromieTimeLocationString(inChromieTime and "player" or unitToken);
		local instruction = GetChromieTimeInstructionString(inChromieTime);
		return PARTY_PLAYER_CHROMIE_TIME_FMT:format(location, instruction);
	end
end

local function GetShardedString(unitToken)
	if UnitInPartyShard("player") then
		return PARTY_PLAYER_SHARDED_TARGET_NOT_IN_PARTY_PHASE;
	else
		if UnitInPartyShard(unitToken) then
			return PARTY_PLAYER_SHARDED_NOT_IN_PARTY_SHARD;
		else
			return PARTY_PLAYER_SHARDED_NEITHER_IN_PARTY_SHARD;
		end
	end
end

function PartyUtil.GetPhasedReasonString(phaseReason, unitToken)
	if phaseReason == Enum.PhaseReason.WarMode then
		if C_PvP.IsWarModeDesired() then
			return PARTY_PLAYER_WARMODE_DISABLED;
		else
			return PARTY_PLAYER_WARMODE_ENABLED;
		end
	elseif phaseReason == Enum.PhaseReason.ChromieTime then
		return GetChromieTimeString(unitToken);
	elseif phaseReason == Enum.PhaseReason.Phasing then
		return PARTY_PHASED_MESSAGE;
	elseif phaseReason == Enum.PhaseReason.Sharding then
		return GetShardedString(unitToken);
	end
end

function GetGroupMemberCountsForDisplay()
	local data = GetGroupMemberCounts();
	data.DAMAGER = data.DAMAGER + data.NOROLE; --People without a role count as damage
	data.NOROLE = 0;
	return data;
end
