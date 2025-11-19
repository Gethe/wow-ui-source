local auraIconDataProvider;
local function GetSampleAuraIcon()
	if not auraIconDataProvider then
		local spellIconsOnly = true;
		auraIconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, spellIconsOnly);
	end

	local iconDataProviderNumIcons = auraIconDataProvider:GetNumIcons();
	return auraIconDataProvider:GetIconByIndex(math.random(1, iconDataProviderNumIcons));
end

local editModeAurasByInstanceID;
local editModeAurasBySlot;
local editModeAuraSlots;

local nextInstanceID = 1;
local function CreateAura(spellID, name, dispelName, sourceUnit, isHelpful, isHarmful, isRaid, isBoss)
	local aura =
	{
		auraInstanceID = nextInstanceID, name = name, icon = GetSampleAuraIcon(), applications = 1, dispelName = dispelName, duration = 0, expirationTime = 0, sourceUnit = sourceUnit,
		isStealable = false, nameplateShowPersonal = false, spellId = spellID, canApplyAura = true, isBossAura = isBoss, isHarmful = isHarmful, isHelpful = isHelpful, isRaid = isRaid,
		isFromPlayerOrPlayerPet = true, nameplateShowAll = false, timeMod = 1, points = {},
	};

	nextInstanceID = nextInstanceID + 1;
	return aura;
end

local function AddAura(...)
	local aura = CreateAura(...);
	table.insert(editModeAurasBySlot, aura);
	table.insert(editModeAuraSlots, #editModeAurasBySlot);
	editModeAurasByInstanceID[aura.auraInstanceID] = aura;
end

local function CreateAuras()
	if editModeAurasBySlot then
		return;
	end

	editModeAurasBySlot = {};
	editModeAurasByInstanceID = {};
	editModeAuraSlots = {};

	--		spellID		name			dispelName		sourceUnit		isHelpful		isHarmful		isRaid		isBoss
	AddAura(500, 		"SampleAura1", 	"Poison", 		"player", 		false, 			true, 			true, 		true);
	AddAura(501, 		"SampleAura2", 	"Magic", 		"player", 		false, 			true, 			true, 		false);
	AddAura(502, 		"SampleAura3", 	"Curse", 		"player", 		false, 			true, 			true, 		false);
	AddAura(500, 		"SampleAura4", 	nil, 			"player", 		true, 			false, 			false, 		false);
	AddAura(501, 		"SampleAura5", 	nil, 			"player", 		true, 			false, 			false, 		false);
	AddAura(502, 		"SampleAura6", 	nil, 			"player", 		true, 			false, 			false, 		false);
	AddAura(500, 		"SampleAura7", 	nil, 			"player", 		true, 			false, 			false, 		false);
	AddAura(501, 		"SampleAura8", 	nil, 			"player", 		true, 			false, 			false, 		false);
	AddAura(502, 		"SampleAura9", 	nil, 			"player", 		true, 			false, 			false, 		false);
end

local function BuildAuraSlotsFromFilter(filter)
	local slots = {};

	local wantsHarmful = string.find(filter, AuraUtil.AuraFilters.Harmful, 1, true) ~= nil;
	local wantsHelpful = string.find(filter, AuraUtil.AuraFilters.Helpful, 1, true) ~= nil;
	local wantsRaid = string.find(filter, AuraUtil.AuraFilters.Raid, 1, true) ~= nil;

	for i, aura in ipairs(editModeAurasBySlot) do
		if wantsHarmful == aura.isHarmful and wantsHelpful == aura.isHelpful and wantsRaid == aura.isRaid then
			table.insert(slots, i);
		end
	end

	return slots;
end

local editModeAuraDataProvider =
{
	GetAuraSlots = function(unit, filter, batchSize, continuationToken)
		CreateAuras();
		local slots = BuildAuraSlotsFromFilter(filter);
		return continuationToken, unpack(slots);
	end,

	GetAuraDataBySlot = function(unit, slot)
		CreateAuras();
		local auraData = editModeAurasBySlot[slot];
		assertsafe(auraData ~= nil, "EditMode SampleAura indexed by invalid slot: %s", tostring(slot));
		return auraData;
	end,

	GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
		CreateAuras();
		return editModeAurasByInstanceID[auraInstanceID];
	end
};

function GetEditModeAuraDataProvider()
	return editModeAuraDataProvider;
end
