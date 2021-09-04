WeeklyRewardMixin = {};

function WeeklyRewardMixin:HasUnlockedRewards(activityType)
	local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
		if (not activityType or activityInfo.type == activityType) and activityInfo.progress >= activityInfo.threshold then
			return true;
		end
	end

	return false;
end

function WeeklyRewardMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" and upInside then
		WeeklyRewards_ShowUI();
	end
end