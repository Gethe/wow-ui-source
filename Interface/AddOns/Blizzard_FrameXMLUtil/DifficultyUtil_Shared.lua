function DifficultyUtil.GetDifficultyName(difficultyID)
	return DifficultyUtil.DifficultyNames[difficultyID];
end

function DifficultyUtil.IsPrimaryRaid(difficultyID)
	return tContains(DifficultyUtil.PrimaryRaids, difficultyID);
end

function DifficultyUtil.GetNextPrimaryRaidDifficultyID(difficultyID)
	for i, id in ipairs(DifficultyUtil.PrimaryRaids) do
		if id == difficultyID then
			return DifficultyUtil.PrimaryRaids[i + 1];
		end
	end
	return nil;
end

function DifficultyUtil.InStoryRaid()
	if not DifficultyUtil.StoryRaidDifficultyID then
		return false;
	end

	local difficultyID = select(3, GetInstanceInfo());
	return difficultyID == DifficultyUtil.StoryRaidDifficultyID;
end

function DifficultyUtil.DoesCurrentRaidDifficultyMatch(compareDifficultyID)
	local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());

	-- Ensure we are using base difficulties for comparisons
	instanceDifficultyID = GetBaseDifficultyID(instanceDifficultyID);
	compareDifficultyID = GetBaseDifficultyID(compareDifficultyID);
	local raidDifficultyID = GetBaseDifficultyID(GetRaidDifficultyID());

	if isDynamicInstance then
		if IsLegacyDifficulty(instanceDifficultyID) then
			local validNormalSize = instanceDifficultyID == DifficultyUtil.ID.Raid10Normal or instanceDifficultyID == DifficultyUtil.ID.Raid25Normal;
			if validNormalSize and compareDifficultyID == DifficultyUtil.ID.PrimaryRaidNormal then
				return true;
			end

			local validHeroicSize = instanceDifficultyID == DifficultyUtil.ID.Raid10Heroic or instanceDifficultyID == DifficultyUtil.ID.Raid25Heroic;
			if validHeroicSize and compareDifficultyID == DifficultyUtil.ID.PrimaryRaidHeroic then
				return true;
			end
		elseif instanceDifficultyID == compareDifficultyID then
			return true;
		end
	elseif raidDifficultyID == compareDifficultyID then
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

function DifficultyUtil.GetWorldTierDifficultyName()
	if not DifficultyUtil.WorldTierDifficultyNames then
		return nil;
	end

	local worldTierDifficulty = C_DelvesUI.GetWorldTierDifficultyForActivePlayer();
	return DifficultyUtil.WorldTierDifficultyNames[worldTierDifficulty];
end