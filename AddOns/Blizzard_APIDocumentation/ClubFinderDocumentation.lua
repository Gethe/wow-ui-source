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
			Name = "GetClubFinderDisableReason",
			Type = "Function",

			Returns =
			{
				{ Name = "disableReason", Type = "ClubFinderDisableReason", Nilable = true },
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
			Name = "GetPlayerApplicantLocaleFlags",
			Type = "Function",

			Returns =
			{
				{ Name = "localeFlags", Type = "number", Nilable = false },
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
			Name = "GetPlayerClubApplicationStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "clubStatus", Type = "PlayerClubRequestStatus", Nilable = false },
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
			Name = "GetPostingIDFromClubFinderGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "postingID", Type = "number", Nilable = true },
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
				{ Name = "clubInfo", Type = "RecruitingClubInfo", Nilable = true },
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
				{ Name = "clubInfo", Type = "RecruitingClubInfo", Nilable = false },
			},
		},
		{
			Name = "GetStatusOfPostingFromClubId",
			Type = "Function",

			Arguments =
			{
				{ Name = "postingID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "postingFlags", Type = "table", InnerType = "ClubFinderClubPostingStatusFlags", Nilable = false },
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
			Name = "HasAlreadyAppliedToLinkedPosting",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAlreadyApplied", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPostingBeenDelisted",
			Type = "Function",

			Arguments =
			{
				{ Name = "postingID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "postingDelisted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsListingEnabledFromFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "flags", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isListed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPostingBanned",
			Type = "Function",

			Arguments =
			{
				{ Name = "postingID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "postingBanned", Type = "bool", Nilable = false },
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
				{ Name = "avatarId", Type = "number", Nilable = false },
				{ Name = "specs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},

			Returns =
			{
				{ Name = "succesful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ReportPosting",
			Type = "Function",

			Arguments =
			{
				{ Name = "reportType", Type = "ClubFinderPostingReportType", Nilable = false },
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "playerGUID", Type = "string", Nilable = false },
				{ Name = "complaintNote", Type = "string", Nilable = false },
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

			Arguments =
			{
				{ Name = "startingIndex", Type = "number", Nilable = false },
				{ Name = "pageSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestNextGuildPage",
			Type = "Function",

			Arguments =
			{
				{ Name = "startingIndex", Type = "number", Nilable = false },
				{ Name = "pageSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestPostingInformationFromClubId",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
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
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "forceAccept", Type = "bool", Nilable = false },
				{ Name = "reported", Type = "bool", Nilable = true },
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
			Name = "SetPlayerApplicantLocaleFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "localeFlags", Type = "number", Nilable = false },
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
			Name = "SetRecruitmentLocale",
			Type = "Function",

			Arguments =
			{
				{ Name = "locale", Type = "number", Nilable = false },
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
			Name = "ClubFinderApplicantInviteRecieved",
			Type = "Event",
			LiteralName = "CLUB_FINDER_APPLICANT_INVITE_RECIEVED",
			Payload =
			{
				{ Name = "clubFinderGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "ClubFinderApplicationsUpdated",
			Type = "Event",
			LiteralName = "CLUB_FINDER_APPLICATIONS_UPDATED",
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
				{ Name = "clubFinderGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},
		},
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
			Name = "ClubFinderClubReported",
			Type = "Event",
			LiteralName = "CLUB_FINDER_CLUB_REPORTED",
			Documentation = { "Sends an update to the UI about a reported guild or community." },
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubFinderCommunityOfflineJoin",
			Type = "Event",
			LiteralName = "CLUB_FINDER_COMMUNITY_OFFLINE_JOIN",
			Documentation = { "Signals to the UI that you (the player) have joined a community offline." },
			Payload =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ClubFinderEnabledOrDisabled",
			Type = "Event",
			LiteralName = "CLUB_FINDER_ENABLED_OR_DISABLED",
			Documentation = { "Sends an update to the UI that the club finder feature has been enabled or disabled." },
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
			Payload =
			{
				{ Name = "clubFinderGUIDs", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "ClubFinderRecruitListChanged",
			Type = "Event",
			LiteralName = "CLUB_FINDER_RECRUIT_LIST_CHANGED",
		},
		{
			Name = "ClubFinderRecruitmentPostReturned",
			Type = "Event",
			LiteralName = "CLUB_FINDER_RECRUITMENT_POST_RETURNED",
			Documentation = { "Signals when our recruitment post we just requested is returned back to us" },
			Payload =
			{
				{ Name = "type", Type = "ClubFinderRequestType", Nilable = false },
			},
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
			Name = "ClubFinderClubPostingStatusFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 0 },
				{ Name = "NeedsCacheUpdate", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 1 },
				{ Name = "ForceDescriptionChange", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 2 },
				{ Name = "ForceNameChange", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 3 },
				{ Name = "UnderReview", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 4 },
				{ Name = "Banned", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 5 },
				{ Name = "FakePost", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 6 },
				{ Name = "PendingDelete", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 7 },
				{ Name = "PostDelisted", Type = "ClubFinderClubPostingStatusFlags", EnumValue = 8 },
			},
		},
		{
			Name = "ClubFinderDisableReason",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Muted", Type = "ClubFinderDisableReason", EnumValue = 0 },
				{ Name = "Silenced", Type = "ClubFinderDisableReason", EnumValue = 1 },
				{ Name = "VeteranTrial", Type = "ClubFinderDisableReason", EnumValue = 2 },
			},
		},
		{
			Name = "ClubFinderPostingReportType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "PostersName", Type = "ClubFinderPostingReportType", EnumValue = 0 },
				{ Name = "ClubName", Type = "ClubFinderPostingReportType", EnumValue = 1 },
				{ Name = "PostingDescription", Type = "ClubFinderPostingReportType", EnumValue = 2 },
				{ Name = "ApplicantsName", Type = "ClubFinderPostingReportType", EnumValue = 3 },
				{ Name = "JoinNote", Type = "ClubFinderPostingReportType", EnumValue = 4 },
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
			Name = "ClubFinderSettingFlags",
			Type = "Enumeration",
			NumValues = 26,
			MinValue = 0,
			MaxValue = 25,
			Fields =
			{
				{ Name = "None", Type = "ClubFinderSettingFlags", EnumValue = 0 },
				{ Name = "Dungeons", Type = "ClubFinderSettingFlags", EnumValue = 1 },
				{ Name = "Raids", Type = "ClubFinderSettingFlags", EnumValue = 2 },
				{ Name = "PvP", Type = "ClubFinderSettingFlags", EnumValue = 3 },
				{ Name = "RP", Type = "ClubFinderSettingFlags", EnumValue = 4 },
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
				{ Name = "LanguageReserved1", Type = "ClubFinderSettingFlags", EnumValue = 21 },
				{ Name = "LanguageReserved2", Type = "ClubFinderSettingFlags", EnumValue = 22 },
				{ Name = "LanguageReserved3", Type = "ClubFinderSettingFlags", EnumValue = 23 },
				{ Name = "LanguageReserved4", Type = "ClubFinderSettingFlags", EnumValue = 24 },
				{ Name = "LanguageReserved5", Type = "ClubFinderSettingFlags", EnumValue = 25 },
			},
		},
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
			Name = "ClubFinderApplicantInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "clubFinderGUID", Type = "string", Nilable = false },
				{ Name = "playerGUID", Type = "string", Nilable = false },
				{ Name = "closed", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "ilvl", Type = "number", Nilable = false },
				{ Name = "specIds", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "requestStatus", Type = "PlayerClubRequestStatus", Nilable = false },
				{ Name = "lookupSuccess", Type = "bool", Nilable = false },
				{ Name = "lastUpdatedTime", Type = "number", Nilable = false },
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
				{ Name = "tabardInfo", Type = "GuildTabardInfo", Nilable = true },
				{ Name = "recruitingSpecIds", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "recruitmentFlags", Type = "number", Nilable = false },
				{ Name = "localeSet", Type = "bool", Nilable = false },
				{ Name = "recruitmentLocale", Type = "number", Nilable = false },
				{ Name = "minILvl", Type = "number", Nilable = false },
				{ Name = "cached", Type = "number", Nilable = false },
				{ Name = "cacheRequested", Type = "number", Nilable = false },
				{ Name = "lastPosterGUID", Type = "string", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "lastUpdatedTime", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClubFinder);