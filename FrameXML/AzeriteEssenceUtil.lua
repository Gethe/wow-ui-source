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

function AzeriteEssenceUtil.GetMilestoneAtPowerLevel(powerLevel)
	if not C_AzeriteEssence.CanOpenUI() then
		return nil;
	end

	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.requiredLevel == powerLevel then
				return milestoneInfo;
			end
			-- only supporting 1 ranked milestone
			if milestoneInfo.requiredLevel < powerLevel and milestoneInfo.rank then
				return milestoneInfo;
			end
		end
	end
	return nil;
end

function AzeriteEssenceUtil.GetMilestoneSpellInfo(milestoneID)
	local spellID = C_AzeriteEssence.GetMilestoneSpell(milestoneID);
	local spellName, _, spellTexture = GetSpellInfo(spellID);
	return spellName, spellTexture;
end