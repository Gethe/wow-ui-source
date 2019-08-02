local ClubFinder =
{
	Name = "ClubFinderInfo",
	Type = "System",
	Namespace = "C_ClubFinder",

	Functions =
	{
		{
			Name = "ApplicantAcceptClubInvite",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ApplicantDeclineClubInvite",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CancelMembershipRequest",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CheckAllPlayerApplicantSettings",
			Type = "Function",
		},
		{
			Name = "ClearAllFinderCache",
			Type = "Function",
		},
		{
			Name = "ClearClubApplicantsCache",
			Type = "Function",
		},
		{
			Name = "ClearClubFinderPostingsCache",
			Type = "Function",
		},
		{
			Name = "DoesPlayerBelongToClubFromClubGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "belongsToClub", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetClubRecruitmentSettings",
			Type = "Function",

			Returns =
			{
				{ Name = "settings", Type = "ClubSettingsInfo", Nilable = false },
			},
		},
		{
			Name = "GetClubTypeFromFinderGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "clubType", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "GetFocusIndexFromFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "flags", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerApplicantSettings",
			Type = "Function",

			Returns =
			{
				{ Name = "settings", Type = "ClubSettingsInfo", Nilable = false },
			},
		},
		{
			Name = "GetPlayerSettingsFocusFlagsSelectedCount",
			Type = "Function",

			Returns =
			{
				{ Name = "focusCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecruitingClubInfoFromClubID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "clubInfo", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecruitingClubInfoFromFinderGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "clubInfo", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "GetTotalMatchingCommunityListSize",
			Type = "Function",

			Returns =
			{
				{ Name = "totalSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalMatchingGuildListSize",
			Type = "Function",

			Returns =
			{
				{ Name = "totalSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LookupClubPostingFromClubFinderGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "isLinkedPosting", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerGetClubInvitationList",
			Type = "Function",

			Returns =
			{
				{ Name = "inviteList", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "PlayerRequestPendingClubsList",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "PlayerReturnPendingCommunitiesList",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "PlayerReturnPendingGuildsList",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "PostClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "itemLevelRequirement", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "specs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},

			Returns =
			{
				{ Name = "succesful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestApplicantList",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "RequestClubsList",
			Type = "Function",

			Arguments =
			{
				{ Name = "guildListRequested", Type = "bool", Nilable = false },
				{ Name = "searchString", Type = "string", Nilable = false },
				{ Name = "specIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RequestMembershipToClub",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = false },
				{ Name = "specIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RequestNextCommunityPage",
			Type = "Function",
		},
		{
			Name = "RequestNextGuildPage",
			Type = "Function",
		},
		{
			Name = "RequestSubscribedClubPostingIDs",
			Type = "Function",
		},
		{
			Name = "ResetClubPostingMapCache",
			Type = "Function",
		},
		{
			Name = "RespondToApplicant",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "playerGUID", Type = "string", Nilable = false },
				{ Name = "shouldAccept", Type = "bool", Nilable = false },
				{ Name = "requestType", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "ReturnClubApplicantList",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "ClubFinderApplicantInfo", Nilable = false },
			},
		},
		{
			Name = "ReturnMatchingCommunityList",
			Type = "Function",

			Returns =
			{
				{ Name = "recruitingClubs", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "ReturnMatchingGuildList",
			Type = "Function",

			Returns =
			{
				{ Name = "recruitingClubs", Type = "table", InnerType = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "ReturnPendingClubApplicantList",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "table", InnerType = "ClubFinderApplicantInfo", Nilable = false },
			},
		},
		{
			Name = "SetAllRecruitmentSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPlayerApplicantSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRecruitmentSettings",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "checked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowClubFinder",
			Type = "Function",

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ClubFinderClubListReturned",
			Type = "Event",
			LiteralName = "CLUB_FINDER_CLUB_LIST_RETURNED",
			Documentation = { "Signals when we recieve club data that can be used" },
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "ClubFinderLinkedClubReturned",
			Type = "Event",
			LiteralName = "CLUB_FINDER_LINKED_CLUB_RETURNED",
			Documentation = { "When a player clicks a club link, this returns that information back about the club they clicked on" },
			Payload =
			{
				{ Name = "clubInfo", Type = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "ClubFinderMembershipListChanged",
			Type = "Event",
			LiteralName = "CLUB_FINDER_MEMBERSHIP_LIST_CHANGED",
		},
		{
			Name = "ClubFinderPlayerPendingListRecieved",
			Type = "Event",
			LiteralName = "CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED",
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
		{
			Name = "ClubFinderPostUpdated",
			Type = "Event",
			LiteralName = "CLUB_FINDER_POST_UPDATED",
		},
		{
			Name = "ClubFinderRecruitListChanged",
			Type = "Event",
			LiteralName = "CLUB_FINDER_RECRUIT_LIST_CHANGED",
		},
		{
			Name = "ClubFinderRecruitsUpdated",
			Type = "Event",
			LiteralName = "CLUB_FINDER_RECRUITS_UPDATED",
			Documentation = { "Signals when we recieve the recruits list" },
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PlayerClubRequestStatus",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "None", Type = "PlayerClubRequestStatus", EnumValue = 0 },
				{ Name = "Pending", Type = "PlayerClubRequestStatus", EnumValue = 1 },
				{ Name = "AutoApproved", Type = "PlayerClubRequestStatus", EnumValue = 2 },
				{ Name = "Declined", Type = "PlayerClubRequestStatus", EnumValue = 3 },
				{ Name = "Approved", Type = "PlayerClubRequestStatus", EnumValue = 4 },
				{ Name = "Joined", Type = "PlayerClubRequestStatus", EnumValue = 5 },
				{ Name = "JoinedAnother", Type = "PlayerClubRequestStatus", EnumValue = 6 },
				{ Name = "Canceled", Type = "PlayerClubRequestStatus", EnumValue = 7 },
			},
		},
		{
			Name = "ClubFinderApplicationUpdateType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "ClubFinderApplicationUpdateType", EnumValue = 0 },
				{ Name = "AcceptInvite", Type = "ClubFinderApplicationUpdateType", EnumValue = 1 },
				{ Name = "DeclineInvite", Type = "ClubFinderApplicationUpdateType", EnumValue = 2 },
				{ Name = "Cancel", Type = "ClubFinderApplicationUpdateType", EnumValue = 3 },
			},
		},
		{
			Name = "ClubFinderRequestType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "ClubFinderRequestType", EnumValue = 0 },
				{ Name = "Guild", Type = "ClubFinderRequestType", EnumValue = 1 },
				{ Name = "Community", Type = "ClubFinderRequestType", EnumValue = 2 },
				{ Name = "All", Type = "ClubFinderRequestType", EnumValue = 3 },
			},
		},
		{
			Name = "ClubFinderReportType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Any", Type = "ClubFinderReportType", EnumValue = 0 },
				{ Name = "InapropriateName", Type = "ClubFinderReportType", EnumValue = 1 },
				{ Name = "InapropriateComment", Type = "ClubFinderReportType", EnumValue = 2 },
			},
		},
		{
			Name = "ClubFinderSettingFlags",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 20,
			Fields =
			{
				{ Name = "None", Type = "ClubFinderSettingFlags", EnumValue = 0 },
				{ Name = "Dungeons", Type = "ClubFinderSettingFlags", EnumValue = 1 },
				{ Name = "Raids", Type = "ClubFinderSettingFlags", EnumValue = 2 },
				{ Name = "Pvp", Type = "ClubFinderSettingFlags", EnumValue = 3 },
				{ Name = "Rp", Type = "ClubFinderSettingFlags", EnumValue = 4 },
				{ Name = "Social", Type = "ClubFinderSettingFlags", EnumValue = 5 },
				{ Name = "Small", Type = "ClubFinderSettingFlags", EnumValue = 6 },
				{ Name = "Medium", Type = "ClubFinderSettingFlags", EnumValue = 7 },
				{ Name = "Large", Type = "ClubFinderSettingFlags", EnumValue = 8 },
				{ Name = "Tank", Type = "ClubFinderSettingFlags", EnumValue = 9 },
				{ Name = "Healer", Type = "ClubFinderSettingFlags", EnumValue = 10 },
				{ Name = "Damage", Type = "ClubFinderSettingFlags", EnumValue = 11 },
				{ Name = "EnableListing", Type = "ClubFinderSettingFlags", EnumValue = 12 },
				{ Name = "MaxLevelOnly", Type = "ClubFinderSettingFlags", EnumValue = 13 },
				{ Name = "AutoAccept", Type = "ClubFinderSettingFlags", EnumValue = 14 },
				{ Name = "FactionHorde", Type = "ClubFinderSettingFlags", EnumValue = 15 },
				{ Name = "FactionAlliance", Type = "ClubFinderSettingFlags", EnumValue = 16 },
				{ Name = "FactionNeutral", Type = "ClubFinderSettingFlags", EnumValue = 17 },
				{ Name = "SortRelevance", Type = "ClubFinderSettingFlags", EnumValue = 18 },
				{ Name = "SortMemberCount", Type = "ClubFinderSettingFlags", EnumValue = 19 },
				{ Name = "SortNewest", Type = "ClubFinderSettingFlags", EnumValue = 20 },
			},
		},
		{
			Name = "ClubFinderApplicantInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "playerGUID", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "ilvl", Type = "number", Nilable = false },
				{ Name = "specIds", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "requestStatus", Type = "PlayerClubRequestStatus", Nilable = false },
			},
		},
		{
			Name = "ClubFinderGuildTabardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "backgroundColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "borderColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemFileID", Type = "number", Nilable = false },
				{ Name = "emblemStyle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RecruitingClubInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "numActiveMembers", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "comment", Type = "string", Nilable = false },
				{ Name = "guildLeader", Type = "string", Nilable = false },
				{ Name = "isGuild", Type = "bool", Nilable = false },
				{ Name = "emblemInfo", Type = "number", Nilable = false },
				{ Name = "tabardInfo", Type = "ClubFinderGuildTabardInfo", Nilable = true },
				{ Name = "clubStatus", Type = "PlayerClubRequestStatus", Nilable = true },
				{ Name = "recruitingSpecIds", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "recruitmentFlags", Type = "number", Nilable = false },
				{ Name = "minILvl", Type = "number", Nilable = false },
				{ Name = "cached", Type = "number", Nilable = false },
				{ Name = "cacheRequested", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClubSettingsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "playStyleDungeon", Type = "bool", Nilable = false },
				{ Name = "playStyleRaids", Type = "bool", Nilable = false },
				{ Name = "playStylePvp", Type = "bool", Nilable = false },
				{ Name = "playStyleRP", Type = "bool", Nilable = false },
				{ Name = "playStyleSocial", Type = "bool", Nilable = false },
				{ Name = "roleTank", Type = "bool", Nilable = false },
				{ Name = "roleHealer", Type = "bool", Nilable = false },
				{ Name = "roleDps", Type = "bool", Nilable = false },
				{ Name = "sizeSmall", Type = "bool", Nilable = false },
				{ Name = "sizeMedium", Type = "bool", Nilable = false },
				{ Name = "sizeLarge", Type = "bool", Nilable = false },
				{ Name = "maxLevelOnly", Type = "bool", Nilable = false },
				{ Name = "enableListing", Type = "bool", Nilable = false },
				{ Name = "sortRelevance", Type = "bool", Nilable = false },
				{ Name = "sortMembers", Type = "bool", Nilable = false },
				{ Name = "sortNewest", Type = "bool", Nilable = false },
				{ Name = "autoAccept", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClubFinder);