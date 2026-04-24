local _, namespace = ...;

namespace.TrackedCooldownsBySpec = {
	[250] = { -- Blood DK
		49028, -- Dancing Rune Weapon
		48792, -- Icebound Fortitude
		48707, -- Anti-Magic Shell
		207167, -- Blinding Sleet
		221562, -- Asphyxiate
		51052, -- Anti-Magic Zone
	},
	[251] = { -- Frost DK
		1249658, -- Breath of Sindragosa
		48792, -- Icebound Fortitude
		48707, -- Anti-Magic Shell
		207167, -- Blinding Sleet
		221562, -- Asphyxiate
		51052, -- Anti-Magic Zone
	},
	[252] = { -- Unholy DK
		42650, -- Army of the Dead
		48792, -- Icebound Fortitude
		48707, -- Anti-Magic Shell
		207167, -- Blinding Sleet
		221562, -- Asphyxiate
		51052, -- Anti-Magic Zone
	},
	[577] = { -- Havoc DH
		191427, -- Metamorphosis
		198589, -- Blur
		196718, -- Darkness
		179057, -- Chaos Nova
		370965, -- The Hunt
	},
	[1480] = { -- Devourer DH
		1217605, -- Void Metamorphosis
		198589, -- Blur
		196718, -- Darkness
		1234195, -- Void Nova
		1246167, -- The Hunt
	},
	[581] = { -- Vengeance DH
		187827, -- Metamorphosis
		196718, -- Darkness
		202137, -- Sigil of Silence
		202138, -- Sigil of Chains
		179057, -- Chaos Nova
		204021, -- Fiery Brand
	},
	[102] = { -- Balance Druid
		194223, -- Celestial Alignment
		102560, -- Incarnation: Chosen of Elune (Override)
		390414, -- Incarnation: Chosen of Elune (Override)
		391528, -- Convoke the Spirits
		22812, -- Barkskin
		99, -- Incapacitating Roar
		5211, -- Mighty Bash
		1261867, -- Heart of the Wild
		29166, -- Innervate
	},
	[103] = { -- Feral Druid
		391528, -- Convoke the Spirits
		102543, -- Incarnation: Avatar of Ashamane (Override)
		22812, -- Barkskin
		61336, -- Survival Instincts
		99, -- Incapacitating Roar
		5211, -- Mighty Bash
		1261867, -- Heart of the Wild
		29166, -- Innervate
	},
	[104] = { -- Guardian Druid
		50334, -- Berserk
		102558, -- Incarnation: Guardian of Ursoc (Override)
		391528, -- Convoke the Spirits
		22812, -- Barkskin
		61336, -- Survival Instincts
		99, -- Incapacitating Roar
		5211, -- Mighty Bash
		1261867, -- Heart of the Wild
		29166, -- Innervate
	},
	[105] = { -- Restoration Druid
		740, -- Tranquility
		391528, -- Convoke the Spirits
		33891, -- Incarnation: Tree of Life
		22812, -- Barkskin
		102342, -- Ironbark
		29166, -- Innervate
		99, -- Incapacitating Roar
		5211, -- Mighty Bash
	},
	[1467] = { -- Devastation Evoker
		375087, -- Dragonrage
		363916, -- Obsidian Scales
		372048, -- Oppressing Roar
		357210, -- Deep Breath
		378441, -- Time Stop
		406732, -- Spatial Paradox
		374968, -- Time Spiral
		374227, -- Zephyr
	},
	[1468] = { -- Preservation Evoker
		363534, -- Rewind
		363916, -- Obsidian Scales
		357170, -- Time Dilation
		372048, -- Oppressing Roar
		406732, -- Spatial Paradox
		374968, -- Time Spiral
		374227, -- Zephyr
	},
	[1473] = { -- Augmentation Evoker
		404977, -- Time Skip
		403631, -- Breath of Eons
		363916, -- Obsidian Scales
		372048, -- Oppressing Roar
		406732, -- Spatial Paradox
		374968, -- Time Spiral
		374227, -- Zephyr
	},
	[253] = { -- Beast Mastery Hunter
		19574, -- Bestial Wrath
		186265, -- Aspect of the Turtle
		264735, -- Survival of the Fittest
		109304, -- Exhilaration
		19577, -- Intimidation
		187650, -- Freezing Trap
	},
	[254] = { -- Marksmanship Hunter
		288613, -- Trueshot
		186265, -- Aspect of the Turtle
		264735, -- Survival of the Fittest
		109304, -- Exhilaration
		474421, -- Intimidation
		187650, -- Freezing Trap
	},
	[255] = { -- Survival Hunter
		1250646, -- Takedown
		186265, -- Aspect of the Turtle
		264735, -- Survival of the Fittest
		109304, -- Exhilaration
		19577, -- Intimidation
		187650, -- Freezing Trap
	},
	[62] = { -- Arcane Mage
		365350, -- Arcane Surge
		45438, -- Ice Block
		414658, -- Ice Cold  (Override)
		342245, -- Alter Time
		31661, -- Dragon's Breath
		157980, -- Super Nova
		235450, -- Prismatic Barrier
	},
	[63] = { -- Fire Mage
		190319, -- Combustion
		45438, -- Ice Block
		414658, -- Ice Cold  (Override)
		342245, -- Alter Time
		31661, -- Dragon's Breath
		157980, -- Super Nova
		235313, -- Blazing Barrier
	},
	[64] = { -- Frost Mage
		205021, -- Ray of Frost
		45438, -- Ice Block
		414658, -- Ice Cold  (Override)
		342245, -- Alter Time
		31661, -- Dragon's Breath
		157980, -- Super Nova
		11426, -- Ice Barrier
	},
	[268] = { -- Brewmaster Monk
		132578, -- Invoke Niuzao, the Black Ox
		115203, -- Fortifying Brew
		119381, -- Leg Sweep
		116844, -- Ring of Peace
		198898, -- Song of Chi-Ji
		322109, -- Touch of Death
	},
	[269] = { -- Windwalker Monk
		123904, -- Invoke Xuen, the White Tiger
		115203, -- Fortifying Brew
		119381, -- Leg Sweep
		116844, -- Ring of Peace
		198898, -- Song of Chi-Ji
		322109, -- Touch of Death
	},
	[270] = { -- Mistweaver Monk
		322118, -- Invoke Yu'lon, the Jade Serpent
		325197, -- Invoke Chi-Ji, the Red Crane
		115203, -- Fortifying Brew
		116849, -- Life Cocoon
		119381, -- Leg Sweep
		322109, -- Touch of Death
	},
	[65] = { -- Holy Paladin
		31884, -- Avenging Wrath
		216331, -- Avenging Crusader
		31821, -- Aura Mastery
		642, -- Divine Shield
		6940, -- Blessing of Sacrifice
		633, -- Lay on Hands
	},
	[66] = { -- Protection Paladin
		31884, -- Avenging Wrath
		389539, -- Sentinel
		86659, -- Guardian of Ancient Kings
		642, -- Divine Shield
		6940, -- Blessing of Sacrifice
		633, -- Lay on Hands
	},
	[70] = { -- Retribution Paladin
		31884, -- Avenging Wrath
		642, -- Divine Shield
		6940, -- Blessing of Sacrifice
		1022, -- Blessing of Protection
		633, -- Lay on Hands
	},
	[256] = { -- Discipline Priest
		10060, -- Power Infusion
		62618, -- Power Word: Barrier
		421453, -- Ultimate Penitence
		19236, -- Desperate Prayer
		33206, -- Pain Suppression
		472433, -- Evangelism
		8122, -- Psychic Scream
	},
	[257] = { -- Holy Priest
		10060, -- Power Infusion
		200183, -- Apotheosis
		64843, -- Divine Hymn
		47788, -- Guardian Spirit
		19236, -- Desperate Prayer
		8122, -- Psychic Scream
	},
	[258] = { -- Shadow Priest
		10060, -- Power Infusion
		228260, -- Voidform
		19236, -- Desperate Prayer
		47585, -- Dispersion
		8122, -- Psychic Scream
	},
	[259] = { -- Assassination Rogue
		360194, -- Deathmark
		31224, -- Cloak of Shadows
		31230, -- Cheat Death
		5277, -- Evasion
		1856, -- Vanish
		2094, -- Blind
	},
	[260] = { -- Outlaw Rogue
		13750, -- Adrenaline Rush
		51690, -- Killing Spree
		31224, -- Cloak of Shadows
		5277, -- Evasion
		1856, -- Vanish
	},
	[261] = { -- Subtlety Rogue
		121471, -- Shadow Blades
		185313, -- Shadow Dance
		31224, -- Cloak of Shadows
		5277, -- Evasion
		1856, -- Vanish
	},
	[262] = { -- Elemental Shaman
		114050, -- Ascendance
		191634, -- Stormkeeper
		108271, -- Astral Shift
		51490, -- Thunderstorm
		192058, -- Capacitor Totem
		198103, -- Earth Elemental
	},
	[263] = { -- Enhancement Shaman
		114051, -- Ascendance
		384352, -- Doom Winds
		108271, -- Astral Shift
		192058, -- Capacitor Totem
		198103, -- Earth Elemental
	},
	[264] = { -- Restoration Shaman
		108280, -- Healing Tide Totem
		114052, -- Ascendance
		98008, -- Spirit Link Totem
		108271, -- Astral Shift
		192058, -- Capacitor Totem
		198103, -- Earth Elemental
	},
	[265] = { -- Affliction Warlock
		205180, -- Summon Darkglare
		104773, -- Unending Resolve
		108416, -- Dark Pact
		30283, -- Shadowfury
		6789, -- Mortal Coil
	},
	[266] = { -- Demonology Warlock
		265187, -- Summon Demonic Tyrant
		104773, -- Unending Resolve
		108416, -- Dark Pact
		30283, -- Shadowfury
		6789, -- Mortal Coil
	},
	[267] = { -- Destruction Warlock
		1122, -- Summon Infernal
		104773, -- Unending Resolve
		108416, -- Dark Pact
		30283, -- Shadowfury
		6789, -- Mortal Coil
	},
	[71] = { -- Arms Warrior
		107574, -- Avatar
		97462, -- Rallying Cry
		118038, -- Die by the Sword
		46968, -- Shockwave
		228920, -- Ravager
		227847, -- Bladestorm
	},
	[72] = { -- Fury Warrior
		107574, -- Avatar
		227847, -- Bladestorm
		97462, -- Rallying Cry
		184364, -- Enraged Regeneration
		46968, -- Shockwave
		1719, -- Recklessness
	},
	[73] = { -- Protection Warrior
		107574, -- Avatar
		871, -- Shield Wall
		97462, -- Rallying Cry
		46968, -- Shockwave
		386071, -- Disrupting Shout
	},
};

namespace.RacialCooldowns = {
	-- Horde Core
	Orc       = 20572, -- Blood Fury
	Troll     = 26297, -- Berserking
	Scourge   = 7744,  -- Will of the Forsaken (Undead)
	Tauren    = 20549, -- War Stomp
	BloodElf  = {      -- Arcane Torrent
		DEATHKNIGHT = 50613,
		DEMONHUNTER = 202719,
		HUNTER      = 80483,
		MAGE        = 28730,
		MONK        = 129597,
		PALADIN     = 155145,
		PRIEST      = 232633,
		ROGUE       = 25046,
		WARLOCK     = 28730,
		WARRIOR     = 69179,
	},
	Goblin    = 69070, -- Rocket Jump

	-- Alliance Core
	Human     = 59752, -- Will to Survive
	Dwarf     = 20594, -- Stoneform
	NightElf  = 58984, -- Shadowmeld
	Gnome     = 20589, -- Escape Artist
	Draenei   = {      -- Gift of the Naaru
		DEATHKNIGHT = 59545,
		HUNTER      = 59543,
		MAGE        = 59548,
		MONK        = 121093,
		PALADIN     = 59542,
		PRIEST      = 59544,
		ROGUE       = 370626,
		SHAMAN      = 59547,
		WARLOCK     = 416250,
		WARRIOR     = 28880,
	},
	Worgen    = 68992, -- Darkflight

	-- Neutral Core
	Pandaren = 107079, -- Quaking Palm
	Dracthyr = 357214, -- Wing Buffet

	-- Horde Allied Races
	Nightborne         = 260364, -- Arcane Pulse
	HighmountainTauren = 255654, -- Bull Rush
	MagharOrc          = 274738, -- Ancestral Call
	ZandalariTroll     = 291944, -- Regeneratin'
	Vulpera            = 312411, -- Bag of Tricks

	-- Alliance Allied Races
	VoidElf            = 256948, -- Spatial Rift
	LightforgedDraenei = 255647, -- Light's Judgment
	DarkIronDwarf      = 265221, -- Fireblood
	KulTiran           = 287712, -- Haymaker
	Mechagnome         = 312924, -- Hyper Organic Light Originator

	-- Neutral Allied Races
	EarthenDwarf  = 436344,  -- Azerite Surge
	Harronir      = 1237885, -- Thorn Bloom
};
