
function UIPanelWindows_Initialize()
	--Center Menu Frames
	UIPanelWindows["GameMenuFrame"] =				{ area = "center",		pushable = 0,	whileDead = 1, centerFrameSkipAnchoring = true };
	UIPanelWindows["HelpFrame"] =					{ area = "center",		pushable = 0,	whileDead = 1 };
	UIPanelWindows["EditModeManagerFrame"] =		{ area = "center",		pushable = 0,	whileDead = 1, neverAllowOtherPanels = 1 };

	-- Frames using the new Templates
	UIPanelWindows["CharacterFrame"] =				{ area = "left",			pushable = 3,	whileDead = 1};
	UIPanelWindows["ProfessionsBookFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1, width = 575, height = 545 };
	UIPanelWindows["PVPUIFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1, width = 563};
	UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
	UIPanelWindows["PVEFrame"] =					{ area = "left",			pushable = 1, 	whileDead = 1 };
	UIPanelWindows["EncounterJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
	UIPanelWindows["CollectionsJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 733};
	UIPanelWindows["TradeFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["LootFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["MerchantFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
	UIPanelWindows["MailFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["BankFrame"] =					{ area = "left",			pushable = 6,	width = 425 };
	UIPanelWindows["QuestLogPopupDetailFrame"] =	{ area = "left",			pushable = 0,	whileDead = 1 };
	UIPanelWindows["QuestFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["GuildRegistrarFrame"] =			{ area = "left",			pushable = 0};
	UIPanelWindows["GossipFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["DressUpFrame"] =				{ area = "left",			pushable = 2};
	UIPanelWindows["PetitionFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["ItemTextFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["FriendsFrame"] =				{ area = "left",			pushable = 0,	whileDead = 1 };
	UIPanelWindows["RaidParentFrame"] =				{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["RaidBrowserFrame"] =			{ area = "left",			pushable = 1,	};
	UIPanelWindows["DeathRecapFrame"] =				{ area = "center",			pushable = 0,	yoffset = -116, whileDead = 1, allowOtherPanels = 1};
	UIPanelWindows["AlliedRacesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["GuildControlUI"] =				{ area = "left",			pushable = 1,	whileDead = 1,		yoffset = 4, };
	UIPanelWindows["CommunitiesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["CommunitiesGuildLogFrame"] =	{ area = "left",			pushable = 1,	whileDead = 1, 		yoffset = 4, };
	UIPanelWindows["CommunitiesGuildTextEditFrame"] = 			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["CommunitiesGuildNewsFiltersFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["ClubFinderGuildRecruitmentDialog"] =		{ area = "left",			pushable = 1,	whileDead = 1 };

	-- Frames NOT using the new Templates
	UIPanelWindows["AnimaDiversionFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 0, allowOtherPanels = 1 };
	UIPanelWindows["CinematicFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
	UIPanelWindows["ChatConfigFrame"] =				{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 1 };
	UIPanelWindows["ChromieTimeFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 0, allowOtherPanels = 1 };
	UIPanelWindows["PVPMatchScoreboard"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -125,	whileDead = 1,	ignoreControlLost = true, };
	UIPanelWindows["PVPMatchResults"] =				{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -41,	whileDead = 1,	ignoreControlLost = true, };
	UIPanelWindows["PlayerChoiceFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -41,	whileDead = 0, allowOtherPanels = 1, ignoreControlLost = true };
	UIPanelWindows["GarrisonBuildingFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		width = 1002, 	allowOtherPanels = 1};
	UIPanelWindows["GarrisonMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
	UIPanelWindows["GarrisonShipyardFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
	UIPanelWindows["GarrisonLandingPage"] =			{ area = "left",			pushable = 1,		whileDead = 1, 		width = 830, 	yoffset = 9,	allowOtherPanels = 1};
	UIPanelWindows["GarrisonMonumentFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		width = 333, 	allowOtherPanels = 1};
	UIPanelWindows["GarrisonRecruiterFrame"] =		{ area = "left",			pushable = 0};
	UIPanelWindows["GarrisonRecruitSelectFrame"] =	{ area = "center",			pushable = 0};
	UIPanelWindows["OrderHallMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
	UIPanelWindows["OrderHallTalentFrame"] =		{ area = "left",			pushable = 0,		xoffset = 16};
	UIPanelWindows["ChallengesKeystoneFrame"] =		{ area = "center",			pushable = 0};
	UIPanelWindows["BFAMissionFrame"] =				{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
	UIPanelWindows["CovenantMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
	UIPanelWindows["BarberShopFrame"] =				{ area = "full",			pushable = 0,};
	UIPanelWindows["TorghastLevelPickerFrame"] =	{ area = "center",			pushable = 0, 		xoffset = -16,		yoffset = 12,	whileDead = 0, allowOtherPanels = 1 };
	UIPanelWindows["PerksProgramFrame"] =			{ area = "full",			pushable = 0,};
	UIPanelWindows["ExpansionLandingPage"] =		{ area = "left",			pushable = 1,		whileDead = 1, 		width = 880, 	allowOtherPanels = 1};
end
