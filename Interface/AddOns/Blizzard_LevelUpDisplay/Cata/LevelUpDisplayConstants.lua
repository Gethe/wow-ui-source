LEVEL_UP_EVENTS = {
--  Level  = {unlock}
	[10] = {"TalentsUnlocked", "BGsUnlocked"},
	[15] = {"LFDUnlocked",},
	[25] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
	[30] = {"DuelSpec"},
	[50] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
	[75] = {"GlyphPrime"},--,"GlyphMajor", "GlyphMinor"},
}

LEVEL_UP_CLASS_HACKS = {
	
	["MAGEHorde"] 		= {
							--  Level  = {unlock}
								[24] = {"Teleports"},
								[42] = {"PortalsHorde"},
							},
	["MAGEAlliance"]	= {
							--  Level  = {unlock}
								[24] = {"Teleports"},
								[42] = {"PortalsAlliance"},
							},
	["WARLOCK"] 		= {
							--  Level  = {unlock}
								[20] = {"LockMount1"},
								[40] = {"LockMount2"},
							},
	["SHAMAN"] 		= {
							--  Level  = {unlock}
								[40] = {"Mail"},
							},
	["HUNTER"] 		= {
							--  Level  = {unlock}
								[4] = {"TrackBeast"},
								[12] = {"TrackHumanoid"},
								[18] = {"TrackUndead"},
								[26] = {"TrackHidden"},
								[34] = {"TrackElemental"},
								[36] = {"TrackDemons"},
								[40] = {"Mail"},
								[46] = {"TrackGiants"},
								[52] = {"TrackDragonkin"},
							},
							

	["WARRIOR"] 		= {
							--  Level  = {unlock}
								[40] = {"Plate"},
							},
							
	["PALADIN"] 		= {
							--  Level  = {unlock}
								[20] = {"PaliMount1"},
								[40] = {"PaliMount2", "Plate"},
							},
	["PALADINTauren"]	= {
							--  Level  = {unlock}
								[20] = {"PaliMountTauren1"},
								[40] = {"PaliMountTauren2", "Plate"},
							},	
	["PALADINDraenei"]	= {
							--  Level  = {unlock}
								[20] = {"PaliMountDraenei1"},
								[40] = {"PaliMountDraenei2", "Plate"},
							},	
}
