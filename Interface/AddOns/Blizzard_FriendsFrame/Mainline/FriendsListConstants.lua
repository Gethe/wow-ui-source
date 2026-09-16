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
	[BattleNetFriendPartyInviteRestrictionType.Mobile] = 9,
	[BattleNetFriendPartyInviteRestrictionType.DifferentRegion] = 10,
	[BattleNetFriendPartyInviteRestrictionType.QuestSession] = 11,
	[BattleNetFriendPartyInviteRestrictionType.IncompatibleGameMode] = 12,
	-- If we can invite even one of their game accounts, that beats every reason the others can't be invited
	[BattleNetFriendPartyInviteRestrictionType.None] = 13,
};

assertsafe(table.count(BattleNetFriendPartyInviteRestrictionType) == table.count(BattleNetFriendPartyInviteRestrictionPriority), "Not all BattleNetFriendPartyInviteRestrictionTypes have a priority defined in BattleNetFriendPartyInviteRestrictionPriority!");
