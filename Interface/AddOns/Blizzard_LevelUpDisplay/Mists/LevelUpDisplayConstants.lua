LEVEL_UP_EVENTS = {
--  Level  = {unlock}
	[10] = {"SpecializationUnlocked", "BGsUnlocked"},
	[15] = {"TalentsUnlocked","LFDUnlocked"},
	[25] = {"Glyphs"},
	[30] = {"DualSpec"},
	[50] = {"GlyphSlots"},
	[70] = {"HeroicBurningCrusade"},
	[75] = {"GlyphSlots"},
	[80] = {"HeroicWrathOfTheLichKing"},
	[85] = {"HeroicCataclysm"},
	[90] = {"HeroicMistsOfPandaria"},
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
								[40] = {"Mail"},
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
