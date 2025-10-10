
----------------- Global Strings -----------------
HOUSING_EXPERT_DECOR_GLOBAL_SPACE_ACTIVATE = "Switch to Global Space editing";--[ Do NOT add to global strings unless global/local space switching is kept as feature ]--
HOUSING_EXPERT_DECOR_GLOBAL_SPACE_DEACTIVATE = "Switch to Local Space editing";--[ Do NOT add to global strings unless global/local space switching is kept as feature ]--

----------------- Enum to Global String Lookups -----------------
HousingResultToErrorText = {
	[Enum.HousingResult.CannotAfford] = ERR_HOUSING_RESULT_CANNOT_AFFORD,
	[Enum.HousingResult.CollisionInvalid] = ERR_HOUSING_RESULT_COLLISION_INVALID,
	[Enum.HousingResult.DbError] = ERR_HOUSING_RESULT_DB_ERROR,
	[Enum.HousingResult.DecorNotFound] = ERR_HOUSING_RESULT_DECOR_NOT_FOUND,
	[Enum.HousingResult.FilterRejected] = ERR_HOUSING_RESULT_FILTER_REJECTED,
	[Enum.HousingResult.GenericFailure] = ERR_HOUSING_RESULT_GENERIC_FAILURE,
	[Enum.HousingResult.HouseNotFound] = ERR_HOUSING_RESULT_HOUSE_NOT_FOUND,
	[Enum.HousingResult.IncorrectFaction] = ERR_HOUSING_RESULT_INCORRECT_FACTION,
	[Enum.HousingResult.InvalidDecorItem] = ERR_HOUSING_RESULT_INVALID_DECOR_ITEM,
	[Enum.HousingResult.InvalidGuild] = ERR_HOUSING_RESULT_INVALID_GUILD,
	[Enum.HousingResult.InvalidInteraction] = ERR_HOUSING_RESULT_INVALID_INTERACTION,
	[Enum.HousingResult.InvalidNeighborhoodName] = ERR_HOUSING_RESULT_INVALID_NEIGHBORHOOD_NAME,
	[Enum.HousingResult.InvalidRoomLayout] = ERR_HOUSING_RESULT_INVALID_ROOM_LAYOUT,
	[Enum.HousingResult.LockedByOtherPlayer] = ERR_HOUSING_RESULT_LOCKED_BY_OTHER_PLAYER,
	[Enum.HousingResult.LockOperationFailed] = ERR_HOUSING_RESULT_LOCK_OPERATION_FAILED,
	[Enum.HousingResult.MaxDecorReached] = ERR_HOUSING_RESULT_MAX_DECOR_REACHED,
	[Enum.HousingResult.MoreHouseSlotsNeeded] = ERR_HOUSING_RESULT_MORE_HOUSE_SLOTS_NEEDED,
	[Enum.HousingResult.NeighborhoodNotFound] = ERR_HOUSING_RESULT_NEIGHBORHOOD_NOT_FOUND,
	[Enum.HousingResult.NotInDecorEditMode] = ERR_HOUSING_RESULT_NOT_IN_DECOR_EDIT_MODE,
	[Enum.HousingResult.NotInLayoutEditMode] = ERR_HOUSING_RESULT_NOT_IN_LAYOUT_EDIT_MODE,
	[Enum.HousingResult.NotInsideHouse] = ERR_HOUSING_RESULT_NOT_INSIDE_HOUSE,
	[Enum.HousingResult.NotOnOwnedPlot] = ERR_HOUSING_RESULT_NOT_ON_OWNED_PLOT,
	[Enum.HousingResult.OperationAborted] = ERR_HOUSING_RESULT_OPERATION_ABORTED,
	[Enum.HousingResult.PermissionDenied] = ERR_HOUSING_RESULT_PERMISSION_DENIED,
	[Enum.HousingResult.PlacementTargetInvalid] = ERR_HOUSING_RESULT_PLACEMENT_TARGET_INVALID,
	[Enum.HousingResult.PlotNotFound] = ERR_HOUSING_RESULT_PLOT_NOT_FOUND,
	[Enum.HousingResult.RoomNotFound] = ERR_HOUSING_RESULT_ROOM_NOT_FOUND,
	[Enum.HousingResult.RoomUpdateFailed] = ERR_HOUSING_RESULT_ROOM_UPDATE_FAILED,
	[Enum.HousingResult.RpcFailure] = ERR_HOUSING_RESULT_RPC_FAILURE,
	[Enum.HousingResult.ServiceNotAvailable] = ERR_HOUSING_RESULT_SERVICE_NOT_AVAILABLE,
	[Enum.HousingResult.TimeoutLimit] = ERR_HOUSING_RESULT_TIMEOUT_LIMIT,
	[Enum.HousingResult.TokenRequired] = ERR_HOUSING_RESULT_TOKEN_REQUIRED,
	[Enum.HousingResult.TransactionFailure] = ERR_HOUSING_RESULT_TRANSACTION_FAILURE,
	[Enum.HousingResult.UnlockOperationFailed] = ERR_HOUSING_RESULT_UNLOCK_OPERATION_FAILED,
};

NeighborhoodTypeStrings = {
	[Enum.NeighborhoodOwnerType.None] = HOUSING_NEIGHBORHOODTYPE_PUBLIC,
	[Enum.NeighborhoodOwnerType.Guild] = HOUSING_NEIGHBORHOODTYPE_GUILD,
	[Enum.NeighborhoodOwnerType.Charter] = HOUSING_NEIGHBORHOODTYPE_CHARTER,
};

HousingAccessTypeStrings = {
	[Enum.HouseSettingFlags.HouseAccessNeighbors] = HOUSING_HOUSE_SETTINGS_ACCESS_NEIGHBORS,
	[Enum.HouseSettingFlags.HouseAccessGuild] = HOUSING_HOUSE_SETTINGS_ACCESS_GUILD,
	[Enum.HouseSettingFlags.HouseAccessFriends] = HOUSING_HOUSE_SETTINGS_ACCESS_FRIENDS,
	[Enum.HouseSettingFlags.HouseAccessParty] = HOUSING_HOUSE_SETTINGS_ACCESS_PARTY,
	[Enum.HouseSettingFlags.PlotAccessNeighbors] = HOUSING_HOUSE_SETTINGS_ACCESS_NEIGHBORS,
	[Enum.HouseSettingFlags.PlotAccessGuild] = HOUSING_HOUSE_SETTINGS_ACCESS_GUILD,
	[Enum.HouseSettingFlags.PlotAccessFriends] = HOUSING_HOUSE_SETTINGS_ACCESS_FRIENDS,
	[Enum.HouseSettingFlags.PlotAccessParty] = HOUSING_HOUSE_SETTINGS_ACCESS_PARTY,

};

HouseOwnerErrorTypeStrings = {
	[Enum.HouseOwnerError.Faction] = ERR_HOUSING_HOUSE_SETTINGS_HOUSEOWNER_FACTION,
	[Enum.HouseOwnerError.Guild] = ERR_HOUSING_HOUSE_SETTINGS_HOUSEOWNER_GUILD,
    [Enum.HouseOwnerError.GenericPermission] = ERR_HOUSING_HOUSE_SETTINGS_HOUSEOWNER_PERMISSION,
};

HousingLayoutGenericRestrictionStrings = {
	[Enum.HousingLayoutRestriction.RoomNotFound] = ERR_HOUSING_LAYOUT_RESTRICTION_ROOM_NOT_FOUND,
	[Enum.HousingLayoutRestriction.NotInsideHouse] = ERR_HOUSING_LAYOUT_RESTRICTION_NOT_INSIDE_HOUSE,
	[Enum.HousingLayoutRestriction.NotHouseOwner] = ERR_HOUSING_LAYOUT_RESTRICTION_NOT_HOUSE_OWNER,
	[Enum.HousingLayoutRestriction.IsBaseRoom] = ERR_HOUSING_LAYOUT_RESTRICTION_BASE_ROOM,
	[Enum.HousingLayoutRestriction.RoomNotLeaf] = ERR_HOUSING_LAYOUT_RESTRICTION_NON_LEAF,
	[Enum.HousingLayoutRestriction.StairwellConnection] = ERR_HOUSING_LAYOUT_RESTRICTION_STAIRWELL,
	[Enum.HousingLayoutRestriction.LastRoom] = ERR_HOUSING_LAYOUT_RESTRICTION_LAST_ROOM,
	[Enum.HousingLayoutRestriction.UnreachableRoom] = ERR_HOUSING_LAYOUT_RESTRICTION_UNREACHABLE,
	[Enum.HousingLayoutRestriction.SingleDoor] = ERR_HOUSING_LAYOUT_RESTRICTION_SINGLE_DOOR,
};

HousingLayoutRotateRestrictionStrings = {
	[Enum.HousingLayoutRestriction.IsBaseRoom] = ERR_HOUSING_LAYOUT_ROTATE_RESTRICTION_BASE_ROOM,
	[Enum.HousingLayoutRestriction.RoomNotLeaf] = ERR_HOUSING_LAYOUT_ROTATE_RESTRICTION_NON_LEAF,
	[Enum.HousingLayoutRestriction.StairwellConnection] = ERR_HOUSING_LAYOUT_ROTATE_RESTRICTION_STAIRWELL,
	[Enum.HousingLayoutRestriction.SingleDoor] = ERR_HOUSING_LAYOUT_ROTATE_RESTRICTION_SINGLE_DOOR,
};

HousingLayoutRemoveRestrictionStrings = {
	[Enum.HousingLayoutRestriction.IsBaseRoom] = ERR_HOUSING_LAYOUT_REMOVE_RESTRICTION_BASE_ROOM,
	[Enum.HousingLayoutRestriction.RoomNotLeaf] = ERR_HOUSING_LAYOUT_REMOVE_RESTRICTION_NON_LEAF,
	[Enum.HousingLayoutRestriction.LastRoom] = ERR_HOUSING_LAYOUT_REMOVE_RESTRICTION_LAST_ROOM,
	[Enum.HousingLayoutRestriction.UnreachableRoom] = ERR_HOUSING_LAYOUT_REMOVE_RESTRICTION_UNREACHABLE,
};

HousingLayoutMoveRestrictionStrings = {
	[Enum.HousingLayoutRestriction.IsBaseRoom] = ERR_HOUSING_LAYOUT_MOVE_RESTRICTION_BASE_ROOM,
	[Enum.HousingLayoutRestriction.RoomNotLeaf] = ERR_HOUSING_LAYOUT_MOVE_RESTRICTION_NON_LEAF,
	[Enum.HousingLayoutRestriction.StairwellConnection] = ERR_HOUSING_LAYOUT_MOVE_RESTRICTION_STAIRWELL,
	[Enum.HousingLayoutRestriction.LastRoom] = ERR_HOUSING_LAYOUT_MOVE_RESTRICTION_LAST_ROOM,
	[Enum.HousingLayoutRestriction.UnreachableRoom] = ERR_HOUSING_LAYOUT_MOVE_RESTRICTION_UNREACHABLE,
};
