AzeriteEssenceUtil = {};

function AzeriteEssenceUtil.HasAnyUnlockableMilestones()
	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.canUnlock then
				local firstUnlockableIsSlot = milestoneInfo.slot and true or false;
				return true, firstUnlockableIsSlot;
			end
		end
	end
	return false, nil;
end

function AzeriteEssenceUtil.HasAnyEmptySlots()
	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.slot and milestoneInfo.unlocked then
				local essenceID = C_AzeriteEssence.GetMilestoneEssence(milestoneInfo.ID);
				if not essenceID then
					return true;
				end
			end
		end
	end
	return false;
end