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

function AzeriteEssenceUtil.ShouldShowEmptySlotHelptip()
	if not C_AzeriteEssence.CanOpenUI() then
		return false;
	end

	local numValidSlots = 0;
	local numEmptySlots = 0;
	local milestones = C_AzeriteEssence.GetMilestones();
	if milestones then
		for i, milestoneInfo in ipairs(milestones) do
			if milestoneInfo.slot and milestoneInfo.unlocked then
				numValidSlots = numValidSlots + 1;
				local essenceID = C_AzeriteEssence.GetMilestoneEssence(milestoneInfo.ID);
				if not essenceID then
					numEmptySlots = numEmptySlots + 1;
				end
			end
		end
	end
	return numEmptySlots > 0 and C_AzeriteEssence.GetNumUnlockedEssences() >= numValidSlots;
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