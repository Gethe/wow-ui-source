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

local ESSENCE_SWAP_TUTORIAL_STATE_NOT_SEEN = 0;
local ESSENCE_SWAP_TUTORIAL_STATE_SEEN = 1;
local ESSENCE_SWAP_TUTORIAL_STATE_ACKNOWLEDGED = 2;

local function GetEssenceSwapTutorialState()
	return tonumber(GetCVar("azeriteEssenceSwapTutorial"));
end

function AzeriteEssenceUtil.ShouldShowEssenceSwapTutorial()
	if GetEssenceSwapTutorialState() == ESSENCE_SWAP_TUTORIAL_STATE_ACKNOWLEDGED then
		return false;
	end

	if not C_AzeriteEssence.CanOpenUI() then
		return false;
	end

	if C_AzeriteEssence.GetNumUnlockedEssences() < 2 then
		return false;
	end
	
	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.slot and C_AzeriteEssence.CanDeactivateEssence(milestoneInfo.ID) then
				return true;
			end
		end
	end
			
	return false;
end

function AzeriteEssenceUtil.SetEssenceSwapTutorialSeen()
	if GetEssenceSwapTutorialState() ~= ESSENCE_SWAP_TUTORIAL_STATE_ACKNOWLEDGED then
		SetCVar("azeriteEssenceSwapTutorial", ESSENCE_SWAP_TUTORIAL_STATE_SEEN);
	end
end

function AzeriteEssenceUtil.TryAcknowledgeEssenceSwapTutorial()
	if GetEssenceSwapTutorialState() == ESSENCE_SWAP_TUTORIAL_STATE_SEEN then
		SetCVar("azeriteEssenceSwapTutorial", ESSENCE_SWAP_TUTORIAL_STATE_ACKNOWLEDGED);
	end
end