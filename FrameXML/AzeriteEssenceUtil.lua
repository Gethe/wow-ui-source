AzeriteEssenceUtil = {};

function AzeriteEssenceUtil.HasAnyUnlockableMilestones()
	if not C_AzeriteEssence.CanOpenUI() then
		return false;
	end

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

function AzeriteEssenceUtil.HasMilestoneAtPowerLevel(powerLevel)
	if not C_AzeriteEssence.CanOpenUI() then
		return false, nil;
	end

	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.requiredLevel == powerLevel then
				local milestoneIsSlot = milestoneInfo.slot and true or false;
				return true, milestoneIsSlot;
			end
		end
	end
	return false, nil;
end

function AzeriteEssenceUtil.HasAnyEmptySlots()
	if not C_AzeriteEssence.CanOpenUI() then
		return false;
	end

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