
-- These are functions that were deprecated in 9.2.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Pet battle enum conversions
do
	Enum.PetBattleState = Enum.PetbattleState;

	LE_PET_BATTLE_STATE_CREATED = Enum.PetbattleState.Created;
	LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE = Enum.PetbattleState.WaitingPreBattle;
	LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS = Enum.PetbattleState.RoundInProgress;
	LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS = Enum.PetbattleState.WaitingForFrontPets;
	LE_PET_BATTLE_STATE_CREATED_FAILED = Enum.PetbattleState.CreatedFailed;
	LE_PET_BATTLE_STATE_FINAL_ROUND = Enum.PetbattleState.FinalRound;
	LE_PET_BATTLE_STATE_FINISHED = Enum.PetbattleState.Finished;
end

-- Unit Sex enum conversions
do
	Enum.Unitsex = Enum.UnitSex;
end

do
	function GetBattlefieldFlagPosition(flagIndex)
		local uiMapId = C_Map.GetBestMapForUnit("player");
		return C_PvP.GetBattlefieldFlagPosition(flagIndex, uiMapId);
	end
end

-- Calendar constants
do
	-- Event Types
	CALENDAR_EVENTTYPE_RAID			= Enum.CalendarEventType.Raid;
	CALENDAR_EVENTTYPE_DUNGEON		= Enum.CalendarEventType.Dungeon;
	CALENDAR_EVENTTYPE_PVP			= Enum.CalendarEventType.PvP;
	CALENDAR_EVENTTYPE_MEETING		= Enum.CalendarEventType.Meeting;
	CALENDAR_EVENTTYPE_OTHER		= Enum.CalendarEventType.Other;
	CALENDAR_MAX_EVENTTYPE			= Enum.CalendarEventTypeMeta.MaxValue;

	-- Invite Statuses
	CALENDAR_INVITESTATUS_INVITED		= Enum.CalendarStatus.Invited;
	CALENDAR_INVITESTATUS_ACCEPTED		= Enum.CalendarStatus.Available;
	CALENDAR_INVITESTATUS_DECLINED		= Enum.CalendarStatus.Declined;
	CALENDAR_INVITESTATUS_CONFIRMED		= Enum.CalendarStatus.Confirmed;
	CALENDAR_INVITESTATUS_OUT			= Enum.CalendarStatus.Out;
	CALENDAR_INVITESTATUS_STANDBY		= Enum.CalendarStatus.Standby;
	CALENDAR_INVITESTATUS_SIGNEDUP		= Enum.CalendarStatus.Signedup;
	CALENDAR_INVITESTATUS_NOT_SIGNEDUP	= Enum.CalendarStatus.NotSignedup;
	CALENDAR_INVITESTATUS_TENTATIVE		= Enum.CalendarStatus.Tentative;
	CALENDAR_MAX_INVITESTATUS			= Enum.CalendarStatusMeta.MaxValue;

	-- Invite Types
	CALENDAR_INVITETYPE_NORMAL		= Enum.CalendarInviteType.Normal;
	CALENDAR_INVITETYPE_SIGNUP		= Enum.CalendarInviteType.Signup;
	CALENDAR_MAX_INVITETYPE			= Enum.CalendarInviteTypeMeta.MaxValue;
end