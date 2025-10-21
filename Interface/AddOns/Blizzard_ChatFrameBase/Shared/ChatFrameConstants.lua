ICON_LIST = {
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:",
}

--Links tags from Global Strings to indicies for entries in ICON_LIST. This way addons can easily replace icons
ICON_TAG_LIST =
{
	[strlower(ICON_TAG_RAID_TARGET_STAR1)] = 1,
	[strlower(ICON_TAG_RAID_TARGET_STAR2)] = 1,
	[strlower(ICON_TAG_RAID_TARGET_STAR3)] = 1,
	[strlower(ICON_TAG_RAID_TARGET_CIRCLE1)] = 2,
	[strlower(ICON_TAG_RAID_TARGET_CIRCLE2)] = 2,
	[strlower(ICON_TAG_RAID_TARGET_CIRCLE3)] = 2,
	[strlower(ICON_TAG_RAID_TARGET_DIAMOND1)] = 3,
	[strlower(ICON_TAG_RAID_TARGET_DIAMOND2)] = 3,
	[strlower(ICON_TAG_RAID_TARGET_DIAMOND3)] = 3,
	[strlower(ICON_TAG_RAID_TARGET_TRIANGLE1)] = 4,
	[strlower(ICON_TAG_RAID_TARGET_TRIANGLE2)] = 4,
	[strlower(ICON_TAG_RAID_TARGET_TRIANGLE3)] = 4,
	[strlower(ICON_TAG_RAID_TARGET_MOON1)] = 5,
	[strlower(ICON_TAG_RAID_TARGET_MOON2)] = 5,
	[strlower(ICON_TAG_RAID_TARGET_MOON3)] = 5,
	[strlower(ICON_TAG_RAID_TARGET_SQUARE1)] = 6,
	[strlower(ICON_TAG_RAID_TARGET_SQUARE2)] = 6,
	[strlower(ICON_TAG_RAID_TARGET_SQUARE3)] = 6,
	[strlower(ICON_TAG_RAID_TARGET_CROSS1)] = 7,
	[strlower(ICON_TAG_RAID_TARGET_CROSS2)] = 7,
	[strlower(ICON_TAG_RAID_TARGET_CROSS3)] = 7,
	[strlower(ICON_TAG_RAID_TARGET_SKULL1)] = 8,
	[strlower(ICON_TAG_RAID_TARGET_SKULL2)] = 8,
	[strlower(ICON_TAG_RAID_TARGET_SKULL3)] = 8,
	[strlower(RAID_TARGET_1)] = 1,
	[strlower(RAID_TARGET_2)] = 2,
	[strlower(RAID_TARGET_3)] = 3,
	[strlower(RAID_TARGET_4)] = 4,
	[strlower(RAID_TARGET_5)] = 5,
	[strlower(RAID_TARGET_6)] = 6,
	[strlower(RAID_TARGET_7)] = 7,
	[strlower(RAID_TARGET_8)] = 8,
}

GROUP_TAG_LIST =
{
	[strlower(GROUP1_CHAT_TAG1)] 	= 1,
	[strlower(GROUP1_CHAT_TAG2)] 	= 1,
	[strlower(GROUP2_CHAT_TAG1)] 	= 2,
	[strlower(GROUP2_CHAT_TAG2)] 	= 2,
	[strlower(GROUP3_CHAT_TAG1)] 	= 3,
	[strlower(GROUP3_CHAT_TAG2)] 	= 3,
	[strlower(GROUP4_CHAT_TAG1)] 	= 4,
	[strlower(GROUP4_CHAT_TAG2)] 	= 4,
	[strlower(GROUP5_CHAT_TAG1)] 	= 5,
	[strlower(GROUP5_CHAT_TAG2)] 	= 5,
	[strlower(GROUP6_CHAT_TAG1)] 	= 6,
	[strlower(GROUP6_CHAT_TAG2)] 	= 6,
	[strlower(GROUP7_CHAT_TAG1)] 	= 7,
	[strlower(GROUP7_CHAT_TAG2)] 	= 7,
	[strlower(GROUP8_CHAT_TAG1)] 	= 8,
	[strlower(GROUP8_CHAT_TAG2)] 	= 8,

	--Language independent:
	["g1"]				= 1;
	["g2"]				= 2;
	["g3"]				= 3;
	["g4"]				= 4;
	["g5"]				= 5;
	["g6"]				= 6;
	["g7"]				= 7;
	["g8"]				= 8;
};

GROUP_LANGUAGE_INDEPENDENT_STRINGS =
{
	"g1",
	"g2",
	"g3",
	"g4",
	"g5",
	"g6",
	"g7",
	"g8",
};
