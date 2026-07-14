-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- Old: Returned an arbitrary default int value when not in an owned house or plot
-- New: Returns nil when not in an owned house or plot
local originalGetSpentPlacementBudget = C_HousingDecor.GetSpentPlacementBudget;
C_HousingDecor.GetSpentPlacementBudget = function()
	return originalGetSpentPlacementBudget() or 0;
end

-- Old: Returned an arbitrary default int value when not in an owned house or plot
-- New: Returns nil when not in an owned house or plot
local originalGetMaxPlacementBudget = C_HousingDecor.GetMaxPlacementBudget;
C_HousingDecor.GetMaxPlacementBudget = function()
	return originalGetMaxPlacementBudget() or 0;
end

-- Old: Returned an arbitrary default int value when not in an owned house
-- New: Returns nil when not in an owned house
local originalGetSpentRoomPlacementBudget = C_HousingLayout.GetSpentPlacementBudget;
C_HousingLayout.GetSpentPlacementBudget = function()
	return originalGetSpentRoomPlacementBudget() or 0;
end

-- Old: Returned an arbitrary default int value when not in an owned house
-- New: Returns nil when not in an owned house or plot
local originalGetRoomPlacementBudget = C_HousingLayout.GetRoomPlacementBudget;
C_HousingLayout.GetRoomPlacementBudget = function()
	return originalGetRoomPlacementBudget() or 0;
end

-- API was updated to be plural, to account for one dye item being usable for multiple Dye Colors
C_DyeColor.GetDyeColorForItem = function(itemLinkOrID)
	local dyeColors = C_DyeColor.GetDyeColorsForItem(itemLinkOrID);
	if dyeColors and #dyeColors > 0 then
		return dyeColors[1];
	end

	return nil;
end

-- API was updated to be plural, to account for one dye item being usable for multiple Dye Colors
C_DyeColor.GetDyeColorForItemLocation = function(itemLocation)
	local dyeColors = C_DyeColor.GetDyeColorsForItemLocation(itemLocation);
	if dyeColors and #dyeColors > 0 then
		return dyeColors[1];
	end

	return nil;
end

-- API was renamed to be consistent with other similar APIs
C_Housing.IsInsideOwnHouse = C_Housing.IsInsideOwnedHouse;

-- Old: Returned the number of floors, which was always the maximum floor.
-- New: Returns the total number of floors based on the highest and lowest floor values.
C_HousingLayout.GetNumFloors = function()
	local highestIndex = C_HousingLayout.GetHighestOccupiedFloorIndex();
	local lowestIndex = C_HousingLayout.GetLowestOccupiedFloorIndex();
	return (highestIndex - lowestIndex) + 1;
end
