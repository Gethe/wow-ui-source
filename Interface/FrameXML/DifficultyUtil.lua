DifficultyUtil = {};

DifficultyUtil.ID = {
	DungeonNormal = 1,
	DungeonHeroic = 2,
	Raid10Normal = 3,
	Raid25Normal = 4,
	Raid10Heroic = 5,
	Raid25Heroic = 6,
	RaidLFR = 7,
	DungeonChallenge = 8,
	Raid40 = 9,
	PrimaryRaidNormal = 14,
	PrimaryRaidHeroic = 15,
	PrimaryRaidMythic = 16,
	PrimaryRaidLFR = 17,
	DungeonMythic = 23,
	DungeonTimewalker = 24,
	RaidTimewalker = 33,
};

local DIFFICULTY_NAMES =
{
	[DifficultyUtil.ID.DungeonNormal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.DungeonHeroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.Raid10Normal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.Raid25Normal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.Raid10Heroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.Raid25Heroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.RaidLFR] = PLAYER_DIFFICULTY3,
	[DifficultyUtil.ID.DungeonChallenge] = CHALLENGE_MODE,
	[DifficultyUtil.ID.Raid40] = LEGACY_RAID_DIFFICULTY,
	[DifficultyUtil.ID.PrimaryRaidNormal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.PrimaryRaidHeroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.PrimaryRaidMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.PrimaryRaidLFR] = PLAYER_DIFFICULTY3,
	[DifficultyUtil.ID.DungeonMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.DungeonTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
	[DifficultyUtil.ID.RaidTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
}

local PRIMARY_RAIDS = { DifficultyUtil.ID.PrimaryRaidLFR, DifficultyUtil.ID.PrimaryRaidNormal, DifficultyUtil.ID.PrimaryRaidHeroic, DifficultyUtil.ID.PrimaryRaidMythic };

function DifficultyUtil.GetDifficultyName(difficultyID)
	return DIFFICULTY_NAMES[difficultyID];
end

function DifficultyUtil.IsPrimaryRaid(difficultyID)
	return tContains(PRIMARY_RAIDS, difficultyID);
end

function DifficultyUtil.GetNextPrimaryRaidDifficultyID(difficultyID)
	for i, id in ipairs(PRIMARY_RAIDS) do
		if id == difficultyID then
			return PRIMARY_RAIDS[i + 1];
		end
	end
	return nil;
end

local difficultyToMaxPlayersMap = { };
function DifficultyUtil.GetMaxPlayers(difficultyID)
	local maxPlayers = difficultyToMaxPlayersMap[difficultyID];
	if not maxPlayers then
		maxPlayers = select(10, GetDifficultyInfo(difficultyID));
		difficultyToMaxPlayersMap[difficultyID] = maxPlayers;
	end
	return maxPlayers;
end