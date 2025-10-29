-- These values aren't actually part of the enum
-- They exist so that disabled states can be managed using the same category enums
-- There are checks to ensure that they don't match any of the pre-existing enum values
Enum.CooldownViewerCategory.HiddenSpell = -1;
Enum.CooldownViewerCategory.HiddenAura = -2;

Enum.CDMLayoutMode =
{
	AccessOnly = false,
	AllowCreate = true,
};

-- TODO: Define in tag...or share with editmode?
Enum.CooldownLayoutType =
{
	Character = 1,
	Account = 2,
};

Enum.CooldownLayoutStatus =
{
	Success = 0,
	InvalidLayoutName = 1,
	TooManyLayouts = 2,
	AttemptToModifyDefaultLayoutWouldCreateTooManyLayouts = 3,
	TooManyAlerts = 4,
	InvalidOrderChange = 5,
	NoValidAlerts = 6,
};

Enum.CooldownLayoutAction =
{
	ChangeOrder = 0,
	ChangeCategory = 1,
	AddLayout = 2,
	AddAlert = 3,
};

-- NOTE: Never change CooldownViewerSound values, always add to the end or mark as placeholder These values are saved to persisted layout data!!!!
CooldownViewerSound = {
	TextToSpeech = 0,

	-- Animals
	AnimalsCat = 1,
	AnimalsChicken = 2,
	AnimalsCow = 3,
	AnimalsGnoll = 4,
	AnimalsGoat = 5,
	AnimalsLion = 6,
	AnimalsPanther = 7,
	AnimalsRattlesnake = 8,
	AnimalsSheep = 9,
	AnimalsWolf = 10,

	-- Devices (note: corrected "Devcies" typo)
	DevicesBoatHorn = 11,
	DevicesAirHorn = 12,
	DevicesBikeHorn = 13,
	DevicesCashRegister = 14,
	DevicesJackpotBell = 15,
	DevicesJackpotCoins = 16,
	DevicesJackpotFail = 17,
	DevicesRotaryPhoneDial = 18,
	DevicesRotaryPhoneRing = 19,
	DevicesStovePipe = 20,
	DevicesTrashcanLid = 21,

	-- Impacts
	ImpactsAnvilStrike = 22,
	ImpactsBubbleSmash = 23,
	ImpactsLowThud = 24,
	ImpactsMetalClanks = 25,
	ImpactsMetalRattle = 26,
	ImpactsMetalScrape = 27,
	ImpactsMetalWarble = 28,
	ImpactsPopClick = 29,
	ImpactsStrangeClang = 30,
	ImpactsSwordScrape = 31,

	-- Instruments
	InstrumentsBellRing = 32,
	InstrumentsBellTrill = 33,
	InstrumentsBrass = 34,
	InstrumentsChimeAscending = 35,
	InstrumentsGuitarChug = 36,
	InstrumentsGuitarPinch = 37,
	InstrumentsPitchPipeDistressed = 38,
	InstrumentsPitchPipeNote = 39,
	InstrumentsSynthBig = 40,
	InstrumentsSynthBuzz = 41,
	InstrumentsSynthHigh = 42,
	InstrumentsWarhorn = 43,

	-- War2
	War2AbstractWhoosh = 44,
	War2Choir = 45,
	War2Construction = 46,
	War2MagicChimes = 47,
	War2PigSqueal = 48,
	War2Saws = 49,
	War2Seal = 50,
	War2Slow = 51,
	War2Smith = 52,
	War2SynthStinger = 53,
	War2TrumpetRally = 54,
	War2ZippyMagic = 55,

	-- War3
	War3Bell = 56,
	War3CrunchyBell = 57,
	War3DrumSplash = 58,
	War3Error = 59,
	War3Fanfare = 60,
	War3GateOpen = 61,
	War3Gold = 62,
	War3MagicShimmer = 63,
	War3Ringout = 64,
	War3Rooster = 65,
	War3ShimmerBell = 66,
	War3WolfHowl = 67,
};
