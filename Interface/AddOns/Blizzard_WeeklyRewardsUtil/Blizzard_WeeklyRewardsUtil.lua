-- in activity data both of these are level 0 and are differentiated by difficultyID
WeeklyRewardsUtil = {
	HeroicLevel = -1,
	MythicLevel = 0,
};

function WeeklyRewardsUtil.GetNextMythicLevel(level)
	if level == WeeklyRewardsUtil.MythicLevel then
		return 2;	-- first keystone mythic is level 2
	end
	return level + 1;
end

-- returns level, count of that level
-- level is 0 for Heroic, 1 for regular Mythic, 2+ for MythicPlus
function WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(numRuns)
	local lowestLevel;
	local lowestCount = 0;

	local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns();
	-- if there are not enough MythicPlus runs, the lowest level might be either Heroic or Mythic
	if numRuns > numMythicPlus and (numHeroic + numMythic) > 0 then
		-- if there are not enough of both mythics combined, the lowest level might be Heroic
		if numRuns > numMythicPlus + numMythic and numHeroic > 0 then
			lowestLevel = WeeklyRewardsUtil.HeroicLevel;
			lowestCount = numRuns - numMythicPlus - numMythic;
		else
			lowestLevel = WeeklyRewardsUtil.MythicLevel;
			lowestCount = numRuns - numMythicPlus;
		end
		return lowestLevel, lowestCount;
	end

	local runHistory = C_MythicPlus.GetRunHistory();
	table.sort(runHistory, function(left, right) return left.level > right.level; end);
	for i = math.min(numRuns, #runHistory), 1, -1 do
		local run = runHistory[i];
		if not lowestLevel then
			lowestLevel = run.level;
		end
		if lowestLevel == run.level then
			lowestCount = lowestCount + 1;
		else
			break;
		end
	end
	return lowestLevel, lowestCount;
end

-- returns lastCompletedActivityInfo, nextActivityInfo
function WeeklyRewardsUtil.GetActivitiesProgress()
	local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities);
	table.sort(activities, function(left, right) return left.index < right.index; end);
	local lastCompletedIndex = 0;
	for i, activityInfo in ipairs(activities) do
		if activityInfo.progress >= activityInfo.threshold then
			lastCompletedIndex = i;
		end
	end
	if lastCompletedIndex == 0 then
		return nil, nil;
	else
		if lastCompletedIndex == #activities then
			local info = activities[lastCompletedIndex];
			return info, nil;
		else
			local nextInfo = activities[lastCompletedIndex + 1];
			return activities[lastCompletedIndex], nextInfo;
		end
	end
end

function WeeklyRewardsUtil.HasUnlockedRewards(activityType)
	local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
		if (not activityType or activityInfo.type == activityType) and activityInfo.progress >= activityInfo.threshold then
			return true;
		end
	end

	return false;
end

WeeklyRewardMixin = {};

function WeeklyRewardMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" and upInside then
		WeeklyRewards_ShowUI();
	end
end

function WeeklyRewardMixin:HasUnlockedRewards(activityType)
	return WeeklyRewardsUtil.HasUnlockedRewards(activityType);
end