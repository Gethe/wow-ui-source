-- These are functions that were deprecated in 7.2.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if (not IsPublicBuild()) then
	return;
end

-- PvP

do
	local function RewardMapToRewardsArray(rewardsMap)
		local rewards;
		if (rewardsMap) then
			rewards = {};
			for i, reward in ipairs(rewardsMap) do
				rewards[i] = { reward.id, reward.name, reward.texture, reward.quantity; };
			end
		end
		return rewards;
	end

	-- Use C_PvP.GetRandomBGRewards() instead
	function GetRandomBGRewards()
		local honor, experience, rewardsMap = C_PvP.GetRandomBGRewards();
		local rewards = RewardMapToRewardsArray(rewardsMap);
		return honor, rewards;
	end

	-- Use C_PvP.GetArenaSkirmishRewards() instead
	function GetArenaSkirmishRewards()
		local honor, experience, rewardsMap = C_PvP.GetArenaSkirmishRewards();
		local rewards = RewardMapToRewardsArray(rewardsMap);
		local hasWon = C_PvP.HasArenaSkirmishWinToday();
		return honor, rewards, hasWon;
	end

	-- Use C_PvP.GetRatedBGRewards() instead
	function GetRatedBGRewards()
		local honor, experience, rewardsMap = C_PvP.GetRatedBGRewards();
		local rewards = RewardMapToRewardsArray(rewardsMap);
		return honor, rewards;
	end

	-- C_PvP.GetArenaRewards(teamSize) instead
	function GetArenaRewards(teamSize)
		local honor, experience, rewardsMap = C_PvP.GetArenaRewards(teamSize);
		local rewards = RewardMapToRewardsArray(rewardsMap);
		return honor, rewards;
	end
end

-- WorldMap

do
	function GetMapLandmarkInfo(index)
		local landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon, displayAsBanner = C_WorldMap.GetMapLandmarkInfo(index);
		return landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon;
	end
end

-- EquipmentSet

do
	-- Use C_EquipmentSet.SaveEquipmentSet(equipmentSetID[, newIcon]) instead
	function SaveEquipmentSet(equipmentSetName, newIcon)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		C_EquipmentSet.SaveEquipmentSet(equipmentSetID, newIcon);
	end

	-- Use C_EquipmentSet.DeleteEquipmentSet(equipmentSetID) instead
	function DeleteEquipmentSet(equipmentSetName)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		C_EquipmentSet.DeleteEquipmentSet(equipmentSetID);
	end

	-- Use C_EquipmentSet.ModifyEquipmentSet(equipmentSetID, newName, newIcon) instead
	function ModifyEquipmentSet(oldName, newName, newIcon)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(oldName);
		C_EquipmentSet.ModifyEquipmentSet(equipmentSetID, newName, newIcon);
	end

	-- Use C_EquipmentSet.IgnoreSlotForSave(slot) instead
	function EquipmentManagerIgnoreSlotForSave(slot)
		C_EquipmentSet.IgnoreSlotForSave(slot);
	end

	-- Use C_EquipmentSet.IsSlotIgnoredForSave(slot) instead
	function EquipmentManagerIsSlotIgnoredForSave(slot)
		return C_EquipmentSet.IsSlotIgnoredForSave(slot);
	end

	-- Use C_EquipmentSet.ClearIgnoredSlotsForSave() instead
	function EquipmentManagerClearIgnoredSlotsForSave()
		C_EquipmentSet.ClearIgnoredSlotsForSave();
	end

	-- Use C_EquipmentSet.UnignoreSlotForSave(slot) instead
	function EquipmentManagerUnignoreSlotForSave(slot)
		C_EquipmentSet.UnignoreSlotForSave(slot);
	end

	-- Use C_EquipmentSet.GetNumEquipmentSets() instead
	function GetNumEquipmentSets()
		return C_EquipmentSet.GetNumEquipmentSets();
	end

	-- Use C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID) instead
	function GetEquipmentSetInfo(equipmentSetIndex)
		local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
		return C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[equipmentSetIndex]);
	end

	-- Use C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID) instead
	function GetEquipmentSetInfoByName(equipmentSetName)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		return C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID);
	end

	-- Use C_EquipmentSet.EquipmentSetContainsLockedItems(equipmentSetID) instead
	function EquipmentSetContainsLockedItems(equipmentSetName)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		return C_EquipmentSet.EquipmentSetContainsLockedItems(equipmentSetID);
	end

	-- Use C_EquipmentSet.PickupEquipmentSet(equipmentSetID) instead
	function PickupEquipmentSetByName(equipmentSetName)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		C_EquipmentSet.PickupEquipmentSet(equipmentSetID);
	end

	-- Use C_EquipmentSet.PickupEquipmentSet(equipmentSetID) instead
	function PickupEquipmentSet(equipmentSetIndex)
		local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
		C_EquipmentSet.PickupEquipmentSet(equipmentSetIDs[equipmentSetIndex]);
	end

	-- Use C_EquipmentSet.UseEquipmentSet(equipmentSetID) instead
	function UseEquipmentSet(equipmentSetName)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		C_EquipmentSet.UseEquipmentSet(equipmentSetID);
	end

	-- Use C_EquipmentSet.CanUseEquipmentSets() instead
	function CanUseEquipmentSets()
		return C_EquipmentSet.CanUseEquipmentSets();
	end

	-- Use C_EquipmentSet.GetItemIDs(equipmentSetID) instead
	function GetEquipmentSetItemIDs(equipmentSetName, returnTable)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		returnTable = returnTable or {};
		return Mixin(returnTable, C_EquipmentSet.GetItemIDs(equipmentSetID));
	end

	-- Use C_EquipmentSet.GetItemLocations(equipmentSetID) instead
	function GetEquipmentSetLocations(equipmentSetName, returnTable)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		returnTable = returnTable or {};
		return Mixin(returnTable, C_EquipmentSet.GetItemLocations(equipmentSetID));
	end

	-- Use C_EquipmentSet.GetIgnoredSlots(equipmentSetID) instead
	function GetEquipmentSetIgnoreSlots(equipmentSetName, returnTable)
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
		returnTable = returnTable or {};
		return Mixin(returnTable, C_EquipmentSet.GetIgnoredSlots(equipmentSetID));
	end
end

-- Unit* functions

do
	-- Use UnitPower instead
	function UnitMana(unit)
		return UnitPower(unit, Enum.PowerType.Mana);
	end

	-- Use UnitPowerMax instead
	function UnitManaMax(unit)
		return UnitPowerMax(unit, Enum.PowerType.Mana);
	end
end

-- Calendar

do
	-- Use C_Calendar.GetDayEvent instead
	function CalendarGetDayEvent(monthOffset, monthDay, index)
		local event = C_Calendar.GetDayEvent(monthOffset, monthDay, index);
		if (event) then
			local hour, minute;
			if (event.sequenceType == "END") then
				hour = event.endTime.hour;
				minute = event.endTime.minute;
			else
				hour = event.startTime.hour;
				minute = event.startTime.minute;
			end
			return event.title, hour, minute, event.calendarType, event.sequenceType, event.eventType, event.iconTexture, event.modStatus, event.inviteStatus, event.invitedBy, event.difficulty, event.inviteType, event.sequenceIndex, event.numSequenceDays, event.difficultyName;
		else
			return nil, 0, 0, "", "", 0, "", "", 0, "", 0, 0, 0, 0, "";
		end
	end

	-- Use C_Calendar.GetHolidayInfo instead
	function CalendarGetHolidayInfo(monthOffset, monthDay, index)
		local holidayInfo = C_Calendar.GetHolidayInfo(monthOffset, monthDay, index);
		if (holidayInfo) then
			return holidayInfo.name, holidayInfo.description, holidayInfo.texture;
		end
	end
end