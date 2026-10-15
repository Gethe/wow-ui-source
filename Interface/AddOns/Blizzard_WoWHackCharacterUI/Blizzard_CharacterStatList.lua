
local STAT_NAME_TO_SPELL_TOOLTIP_IDS = {
	[WOWHACK_STAT_LINE_HEALTH] = 1249560,
	[WOWHACK_STAT_LINE_MANA] = 1249563,
	[WOWHACK_STAT_LINE_ENERGY] = 1249561,
	[WOWHACK_STAT_LINE_ABILITY_POWER] = 1249572,
	[WOWHACK_STAT_LINE_CRITICAL_STRIKE_CHANCE] = 1249568,
	[WOWHACK_STAT_LINE_CRITICAL_STRIKE_DAMAGE] = 1249411,
	[WOWHACK_STAT_LINE_GUARD] = 1249564,
	[WOWHACK_STAT_LINE_ABSORB] = 1249573,
	[WOWHACK_STAT_LINE_DODGE_CHANCE] = 1249570,
	[WOWHACK_STAT_LINE_EVADE_CHARGES] = 1249571,
};

local function GetHealth()
	return UnitHealthMax("player");
end

local function GetMana()
	return UnitPowerMax("player", Enum.PowerType.Mana);
end

local function GetEnergy()
	return UnitPowerMax("player", Enum.PowerType.Energy);
end

local function GetAbilityPower()
	return UnitAttackPower("player");
end

local function GetCriticalStrikeChance()
	return Round(GetCritChance());
end

local function GetCriticalStrikeDamage()
	return C_WoWHackCharacterStats.GetStatPointsBySpellID(STAT_NAME_TO_SPELL_TOOLTIP_IDS[WOWHACK_STAT_LINE_CRITICAL_STRIKE_DAMAGE]);
end

local function GetGuard()
	return C_WoWHackCharacterStats.GetStatPointsBySpellID(STAT_NAME_TO_SPELL_TOOLTIP_IDS[WOWHACK_STAT_LINE_GUARD]);
end

local function GetAbsorb()
	return C_WoWHackCharacterStats.GetStatPointsBySpellID(STAT_NAME_TO_SPELL_TOOLTIP_IDS[WOWHACK_STAT_LINE_ABSORB]);
end

local function GetDodge()
	return GetDodgeChance();
end

local function GetEvadeCharges()
	return C_WoWHackCharacterStats.GetStatPointsBySpellID(STAT_NAME_TO_SPELL_TOOLTIP_IDS[WOWHACK_STAT_LINE_EVADE_CHARGES]);
end

local function MakeStatLineEntry(statName, valueCallback)
	return {
		name = statName,
		spellTooltipID = STAT_NAME_TO_SPELL_TOOLTIP_IDS[statName],
		valueCallback = valueCallback,
	};
end



local STAT_LINE_ENTRIES = {
	MakeStatLineEntry(WOWHACK_STAT_LINE_HEALTH, GetHealth),
	MakeStatLineEntry(WOWHACK_STAT_LINE_MANA, GetMana),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ENERGY, GetEnergy),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ABILITY_POWER, GetAbilityPower),
	MakeStatLineEntry(WOWHACK_STAT_LINE_CRITICAL_STRIKE_CHANCE, GetCriticalStrikeChance),
	MakeStatLineEntry(WOWHACK_STAT_LINE_CRITICAL_STRIKE_DAMAGE, GetCriticalStrikeDamage),
	MakeStatLineEntry(WOWHACK_STAT_LINE_GUARD, GetGuard),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ABSORB, GetAbsorb),
	MakeStatLineEntry(WOWHACK_STAT_LINE_DODGE_CHANCE, GetDodge),
	MakeStatLineEntry(WOWHACK_STAT_LINE_EVADE_CHARGES, GetEvadeCharges),
};

local CHARACTER_STAT_LIST_EVENTS = {
	"UNIT_MAXHEALTH",
	"UNIT_POWER_UPDATE",
};

local CHARACTER_STAT_LIST_UNIT_EVENTS = {
	"UNIT_STATS",
};

CharacterStatListMixin = CreateFromMixins(CharacterSheetListMixin);

function CharacterStatListMixin:OnLoad()
	CharacterSheetListMixin.OnLoad(self);
end

function CharacterStatListMixin:OnShow()
	CharacterSheetListMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, CHARACTER_STAT_LIST_UNIT_EVENTS, "player");
end

function CharacterStatListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_STAT_LIST_UNIT_EVENTS);
end

function CharacterStatListMixin:OnEvent(_event)
	self:Refresh();
end

local function MakeStatTooltipCallback(spellID)
	return function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(spellID);
		GameTooltip:Show();
	end;
end

function CharacterStatListMixin:BuildElements()
	local entries = {};
	for _i, entry in ipairs(STAT_LINE_ENTRIES) do
		table.insert(entries, {
			name = entry.name,
			tooltipCallback = MakeStatTooltipCallback(entry.spellTooltipID),
			value = entry.valueCallback(),
		});
	end
	return entries;
end

CharacterStatSummaryMixin = {};

function CharacterStatSummaryMixin:OnLoad()
	self.Header:SetHeaderText(WOWHACK_CHARACTER_SECTION_STATS);
end
