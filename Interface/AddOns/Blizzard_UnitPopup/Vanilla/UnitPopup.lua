
RAID_DIFFICULTY_MAP = {
	[DIFFICULTY_PRIMARYRAID_NORMAL] = { [10] = DIFFICULTY_RAID10_NORMAL, [25] = DIFFICULTY_RAID25_NORMAL }, -- Normal -> 10-man normal, 25-man normal
	[DIFFICULTY_PRIMARYRAID_HEROIC] = { [10] = DIFFICULTY_RAID10_HEROIC, [25] = DIFFICULTY_RAID25_HEROIC }, -- Heroic -> 10-man heroic, 25-man heroic
};

RAID_DIFFICULTY_SIZES = {
	[DIFFICULTY_RAID10_NORMAL] = 10,
	[DIFFICULTY_RAID25_NORMAL] = 25,
	[DIFFICULTY_RAID10_HEROIC] = 10,
	[DIFFICULTY_RAID25_HEROIC] = 25,
}

RAID_TOGGLE_MAP = {
	[DIFFICULTY_PRIMARYRAID_NORMAL] = { DIFFICULTY_RAID10_NORMAL, DIFFICULTY_RAID25_NORMAL },
	[DIFFICULTY_PRIMARYRAID_HEROIC] = { DIFFICULTY_RAID10_HEROIC, DIFFICULTY_RAID25_HEROIC },
	[DIFFICULTY_PRIMARYRAID_MYTHIC] = {},
}

function NormalizeLegacyDifficultyID(difficultyID)
	if not IsLegacyDifficulty(difficultyID) then
		return difficultyID;
	end

	-- Normal difficulties are 3 and 4 for 10-player and 25-player, heroic are 5 and 6 respectively.  To "normalize"
	-- it, we want to always use 3 and 4 (the normal versions), so we subtract 2 to go from heroic to normal.
	if difficultyID > 4 then
		difficultyID = difficultyID - 2;
	end
	return difficultyID;
end

function SetRaidDifficulties(primaryRaid, difficultyID)
	local otherDifficulty = 0;
	if primaryRaid then
		local toggleDifficultyID, force;
		local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
		if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
			 toggleDifficultyID = select(7, GetDifficultyInfo(instanceDifficultyID));
		end
		if (UnitLevel("player") >= MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA]) then
			if toggleDifficultyID ~= nil and IsLegacyDifficulty(toggleDifficultyID) then
				force = true;
			end
			SetRaidDifficultyID(difficultyID, force);
		end
		if (difficultyID == DIFFICULTY_PRIMARYRAID_MYTHIC) then
			return;
		end

		force = toggleDifficultyID ~= nil and not IsLegacyDifficulty(toggleDifficultyID);

		otherDifficulty = GetLegacyRaidDifficultyID();
		local size = RAID_DIFFICULTY_SIZES[otherDifficulty];
		local newDifficulty = RAID_DIFFICULTY_MAP[difficultyID][size];
		SetLegacyRaidDifficultyID(newDifficulty, force);
	else
		otherDifficulty = GetRaidDifficultyID();
		local size = RAID_DIFFICULTY_SIZES[difficultyID];
		local newDifficulty = RAID_DIFFICULTY_MAP[otherDifficulty][size];
		SetLegacyRaidDifficultyID(newDifficulty);
	end
end

function CheckToggleDifficulty(toggleDifficultyID, difficultyID)
	if IsLegacyDifficulty(toggleDifficultyID) then
		if not IsLegacyDifficulty(difficultyID) then
			return tContains(RAID_TOGGLE_MAP[difficultyID], toggleDifficultyID);
		else
			return NormalizeLegacyDifficultyID(difficultyID) == NormalizeLegacyDifficultyID(toggleDifficultyID);
		end
	else
		if IsLegacyDifficulty(difficultyID) then
			return toggleDifficultyID == difficultyID;
		end
	end
end