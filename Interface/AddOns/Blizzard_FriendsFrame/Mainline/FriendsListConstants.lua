BattleNetFriendPartyInviteRestrictionType = EnumUtil.MakeEnum(
	"None",
	"NoGameAccounts",
	"Client",
	"Leader",
	"Faction",
	"Realm",
	"MissingRealmInfo",
	"DifferentWowProject",
	"WowProjectMainline",
	"WowProjectClassic",
	"Mobile",
	"DifferentRegion",
	"QuestSession",
	"IncompatibleGameMode"
);

-- For cases where a friend has multiple restrictions and we want to display the most important one
BattleNetFriendPartyInviteRestrictionPriority =
{
	[BattleNetFriendPartyInviteRestrictionType.NoGameAccounts] = 0,
	[BattleNetFriendPartyInviteRestrictionType.Client] = 1,
	[BattleNetFriendPartyInviteRestrictionType.Leader] = 2,
	[BattleNetFriendPartyInviteRestrictionType.Faction] = 3,
	[BattleNetFriendPartyInviteRestrictionType.Realm] = 4,
	[BattleNetFriendPartyInviteRestrictionType.MissingRealmInfo] = 5,
	[BattleNetFriendPartyInviteRestrictionType.DifferentWowProject] = 6,
	[BattleNetFriendPartyInviteRestrictionType.WowProjectMainline] = 7,
	[BattleNetFriendPartyInviteRestrictionType.WowProjectClassic] = 8,
	[BattleNetFriendPartyInviteRestrictionType.None] = 9,
	[BattleNetFriendPartyInviteRestrictionType.Mobile] = 10,
	[BattleNetFriendPartyInviteRestrictionType.DifferentRegion] = 11,
	[BattleNetFriendPartyInviteRestrictionType.QuestSession] = 12,
	[BattleNetFriendPartyInviteRestrictionType.IncompatibleGameMode] = 13,
};
