
function UIPanelWindows_Initialize()
	--Center Menu Frames
	UIPanelWindows["GameMenuFrame"] =				{ area = "center",		pushable = 0,	whileDead = 1, centerFrameSkipAnchoring = true };
	UIPanelWindows["HelpFrame"] =					{ area = "center",		pushable = 0,	whileDead = 1, centerFrameSkipAnchoring = true };

	-- Frames using the new Templates
	UIPanelWindows["PVPUIFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1, width = 563};
	UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
	UIPanelWindows["PetStableFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["PVEFrame"] =					{ area = "left",			pushable = 1, 	whileDead = 1 };
	UIPanelWindows["PVPFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1 };
	UIPanelWindows["EncounterJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
	UIPanelWindows["CollectionsJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 733};
	UIPanelWindows["TradeFrame"] =					{ area = "left",			pushable = 1};
	UIPanelWindows["LootFrame"] =					{ area = "left",			pushable = 7};
	UIPanelWindows["MerchantFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["MailFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["QuestLogDetailFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["QuestLogPopupDetailFrame"] =	{ area = "left",			pushable = 0,	whileDead = 1 };
	UIPanelWindows["DressUpFrame"] =				{ area = "left",			pushable = 2};
	UIPanelWindows["PetitionFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["ItemTextFrame"] =				{ area = "left",			pushable = 0};
	UIPanelWindows["FriendsFrame"] =				{ area = "left",			pushable = 0,	whileDead = 1 };
	UIPanelWindows["RaidParentFrame"] =				{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["RaidBrowserFrame"] =			{ area = "left",			pushable = 1,	};
	UIPanelWindows["DeathRecapFrame"] =				{ area = "center",			pushable = 0,	yoffset = -116, whileDead = 1, allowOtherPanels = 1, centerFrameSkipAnchoring = true};
	UIPanelWindows["AlliedRacesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["GuildControlUI"] =				{ area = "left",			pushable = 1,	whileDead = 1,		yoffset = 4, };
	UIPanelWindows["CommunitiesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["CommunitiesGuildLogFrame"] =	{ area = "left",			pushable = 1,	whileDead = 1, 		yoffset = 4, };
	UIPanelWindows["CommunitiesGuildTextEditFrame"] = 			{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["CommunitiesGuildRecruitmentFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["GuildRegistrarFrame"] =			{ area = "left",			pushable = 0};
	UIPanelWindows["CommunitiesGuildNewsFiltersFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };
	UIPanelWindows["GossipFrame"] =					{ area = "left",			pushable = 0};
	UIPanelWindows["InspectFrame"] =				{ area = "left",			pushable = 2,	whileDead = 1 };

	-- Resurrected Classic Frames that don't use the new Templates.
	-- The offset and width values help the Classic frames blend in with modern frames that use ButtonFrameTemplate.
	UIPanelWindows["ClassTrainerFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["TradeSkillFrame"] =				{ area = "left",			pushable = 3,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["CraftFrame"] =					{ area = "left",			pushable = 4,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["BankFrame"] =					{ area = "left",			pushable = 6,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["BattlefieldFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["ArenaRegistrarFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["AuctionFrame"] =				{ area = "doublewide",		pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 840 }
	UIPanelWindows["ArenaFrame"] =					{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
	UIPanelWindows["PVPParentFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };

	-- Frames NOT using the new Templates
	UIPanelWindows["CinematicFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
	UIPanelWindows["ChatConfigFrame"] =				{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1,	centerFrameSkipAnchoring = true };
	UIPanelWindows["WorldStateScoreFrame"] =		{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1,	centerFrameSkipAnchoring = true,	ignoreControlLost = true };
	UIPanelWindows["QuestChoiceFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 0,	centerFrameSkipAnchoring = true,	allowOtherPanels = 1 };
	UIPanelWindows["ChallengesKeystoneFrame"] =		{ area = "center",			pushable = 0,		centerFrameSkipAnchoring = true};
end
