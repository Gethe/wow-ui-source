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
	RaidStory = 220,
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
	[DifficultyUtil.ID.DungeonChallenge] = PLAYER_DIFFICULTY_MYTHIC_PLUS,
	[DifficultyUtil.ID.Raid40] = LEGACY_RAID_DIFFICULTY,
	[DifficultyUtil.ID.PrimaryRaidNormal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.PrimaryRaidHeroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.PrimaryRaidMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.PrimaryRaidLFR] = PLAYER_DIFFICULTY3,
	[DifficultyUtil.ID.DungeonMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.DungeonTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
	[DifficultyUtil.ID.RaidTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
	[DifficultyUtil.ID.Raid40] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.RaidStory] = PLAYER_DIFFICULTY_STORY_RAID,
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

function DifficultyUtil.InStoryRaid()
	local difficultyID = select(3, GetInstanceInfo());
	return difficultyID == DifficultyUtil.ID.RaidStory;
end

function DifficultyUtil.DoesCurrentRaidDifficultyMatch(compareDifficultyID)
	local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance then
		if IsLegacyDifficulty(difficultyID) then
			local validNormalSize = difficultyID == DifficultyUtil.ID.Raid10Normal or difficultyID == DifficultyUtil.ID.Raid25Normal;
			if validNormalSize and compareDifficultyID == DifficultyUtil.ID.PrimaryRaidNormal then
				return true;
			end
			
			local validHeroicSize = difficultyID == DifficultyUtil.ID.Raid10Heroic or difficultyID == DifficultyUtil.ID.Raid25Heroic;
			if validHeroicSize and compareDifficultyID == DifficultyUtil.ID.PrimaryRaidHeroic then
				return true;
			end
		elseif difficultyID == compareDifficultyID then
			return true;
		end
	elseif GetRaidDifficultyID() == compareDifficultyID then
		return true;
	end
	return false; 
end

function DifficultyUtil.IsRaidDifficultyEnabled(compareDifficultyID)
	if IsInInstance() then
		return false;
	end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return false;
	end

	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return false;
	end

	local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance and CanChangePlayerDifficulty() then
		local toggleDifficultyID = select(7, GetDifficultyInfo(difficultyID));
		if toggleDifficultyID then
			return CheckToggleDifficulty(toggleDifficultyID, compareDifficultyID);
		end
	end

	return true; 
end

function DifficultyUtil.IsDungeonDifficultyEnabled(difficultyID)
	-- difficultyID not currently checked. Dungeon difficulties are collectively enabled or disabled.
	local inInstance, instanceType = IsInInstance();
	if inInstance then
		return false;
	end

	if instanceType == "raid" then
		return false;
	end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return false;
	end

	return not UnitPopupSharedUtil.HasLFGRestrictions();
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