RAID_TOGGLE_MAP = {
	[DifficultyUtil.ID.PrimaryRaidNormal] = { DifficultyUtil.ID.Raid10Normal, DifficultyUtil.ID.Raid25Normal },
	[DifficultyUtil.ID.PrimaryRaidHeroic] = { DifficultyUtil.ID.Raid10Heroic, DifficultyUtil.ID.Raid25Heroic },
	[DifficultyUtil.ID.PrimaryRaidMythic] = {},
}

function NormalizeLegacyDifficultyID(difficultyID)
	if (not IsLegacyDifficulty(difficultyID)) then
		return difficultyID;
	end

	-- Normal difficulties are 3 and 4 for 10-player and 25-player, heroic are 5 and 6 respectively.  To "normalize"
	-- it, we want to always use 3 and 4 (the normal versions), so we subtract 2 to go from heroic to normal.
	if (difficultyID > 4) then
		difficultyID = difficultyID - 2;
	end
	return difficultyID;
end

local function GetMappedLegacyDifficultyID(difficultyID, size)
	for i, mappedDifficultyID in ipairs(RAID_TOGGLE_MAP[difficultyID]) do
		if DifficultyUtil.GetMaxPlayers(mappedDifficultyID) == size then
			return mappedDifficultyID;
		end
	end
	return nil;
end

function SetRaidDifficulties(primaryRaid, difficultyID)
	if primaryRaid then
		local toggleDifficultyID, force;
		local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
		if isDynamicInstance and CanChangePlayerDifficulty() then
			_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
		end
		if toggleDifficultyID and IsLegacyDifficulty(toggleDifficultyID) then
			force = true;
		end
		SetRaidDifficultyID(difficultyID, force);
		if difficultyID == DifficultyUtil.ID.PrimaryRaidMythic then
			return;
		end
		force = nil;
		if toggleDifficultyID and not IsLegacyDifficulty(toggleDifficultyID) then
			force = true;
		end
		local otherDifficulty = GetLegacyRaidDifficultyID();
		local size = DifficultyUtil.GetMaxPlayers(otherDifficulty);
		local newDifficulty = GetMappedLegacyDifficultyID(difficultyID, size);
		SetLegacyRaidDifficultyID(newDifficulty, force);
	else
		local otherDifficulty = GetRaidDifficultyID();
		local size = DifficultyUtil.GetMaxPlayers(difficultyID);
		local newDifficulty = GetMappedLegacyDifficultyID(otherDifficulty, size)
		SetLegacyRaidDifficultyID(newDifficulty);
	end
end

function CheckToggleDifficulty(toggleDifficultyID, difficultyID)
	if (IsLegacyDifficulty(toggleDifficultyID)) then
		if (not IsLegacyDifficulty(difficultyID)) then
			return tContains(RAID_TOGGLE_MAP[difficultyID], toggleDifficultyID);
		else
			return NormalizeLegacyDifficultyID(difficultyID) == NormalizeLegacyDifficultyID(toggleDifficultyID);
		end
	else
		if (IsLegacyDifficulty(difficultyID)) then
			return false;
		else
			return toggleDifficultyID == difficultyID;
		end
	end

	return false;
end