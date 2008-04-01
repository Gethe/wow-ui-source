-- This file is executed at the end of addon load
BLIZZARD_COMBAT_LOG_MENU_OUTGOING =	"What did %s do?";
BLIZZARD_COMBAT_LOG_MENU_INCOMING =	"What happened to %s?";
BLIZZARD_COMBAT_LOG_MENU_BOTH =		"Show everything involving %s?"
BLIZZARD_COMBAT_LOG_MENU_EVERYTHING = 	"Show Everything";
BLIZZARD_COMBAT_LOG_MENU_REVERT = 	"Revert to Last Filter";
BLIZZARD_COMBAT_LOG_MENU_RESET = 	"Reset";
BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE = "Hide messages like this one. [%s]"
BLIZZARD_COMBAT_LOG_MENU_SPELL_LINK = "Link %s to chat."
BLIZZARD_COMBAT_LOG_MENU_SPELL_TYPE_HEADER = "Message Types"

-- Text Mode Strings
--
-- Text modes are here if we desire a system that supports multiple different formatting
-- or abbreviation styles for different localizations.
--

TEXT_MODE_A = "A";
TEXT_MODE_A_STRING = "$timestamp $source $spell $action $dest $value.$result";

-- Hyperlink format
--|cAARRGGBB|Hitem:####:0:0:0:0:0:0:0|h[Broken Fang]|h|r
--|Hcunit:$sourceGuid:source|h$sourceName|h|r

TEXT_MODE_A_TIMESTAMP = "%H:%M:%S";

TEXT_MODE_A_STRING_BRACE_UNIT  = "|c$braceColor[|r$unitName|c$braceColor]|r";
TEXT_MODE_A_STRING_BRACE_ITEM  = "|c$braceColor[|r$itemName|c$braceColor]|r";
TEXT_MODE_A_STRING_BRACE_SPELL = "|c$braceColor[|r$spellName|c$braceColor]|r";

TEXT_MODE_A_STRING_TOKEN_ICON = "$icon";
--TEXT_MODE_A_STRING_TOKEN_UNIT = "$unitName ($token)";
--TEXT_MODE_A_STRING_TOKEN_BASE = 64;

TEXT_MODE_A_STRING_POSSESSIVE = "$nameString$possessive";
TEXT_MODE_A_STRING_POSSESSIVE_STRING = "'s";

TEXT_MODE_A_STRING_SOURCE = "$sourceIcon$sourceString";

TEXT_MODE_A_STRING_SOURCE_UNIT = "|Hunit:$sourceGUID:$sourceName|h$sourceNameString|h";
TEXT_MODE_A_STRING_SOURCE_ICON = "|Hicon:$iconBit:source|h$iconTexture|h";
TEXT_MODE_A_STRING_SPELL = "|Hspell:$spellId:$eventType|h$spellName|h";
TEXT_MODE_A_STRING_SPELL_EXTRA = "|Hspell:$extraSpellId:$eventType|h$extraSpellName|h";
TEXT_MODE_A_STRING_ITEM = "|Hitem:$itemId|h$itemName|h";

TEXT_MODE_A_STRING_ACTION = "|Haction:$eventType|h$action|h";
TEXT_MODE_A_STRING_TIMESTAMP = "$time>";

TEXT_MODE_A_STRING_DEST = "$destIcon$destString";

TEXT_MODE_A_STRING_DEST_UNIT = "|Hunit:$destGUID:$destName|h$destNameString|h";
TEXT_MODE_A_STRING_DEST_ICON = "|Hicon:$iconBit:dest|h$iconTexture|h";

TEXT_MODE_A_STRING_VALUE = "$amount$amountType";
TEXT_MODE_A_STRING_VALUE_SCHOOL = "  $school";
TEXT_MODE_A_STRING_VALUE_TYPE = "  ($powerType)";

TEXT_MODE_A_STRING_RESULT = " ($resultString)";
TEXT_MODE_A_STRING_RESULT_FORMAT = "$resultAmount $resultType";

-- Result Types
TEXT_MODE_A_STRING_RESULT_RESISTED = "Resisted";
TEXT_MODE_A_STRING_RESULT_BLOCKED = "Blocked";
TEXT_MODE_A_STRING_RESULT_ABSORBED = "Absorbed";
TEXT_MODE_A_STRING_RESULT_CRITICAL = "Critical";
TEXT_MODE_A_STRING_RESULT_GLANCING = "Glancing";
TEXT_MODE_A_STRING_RESULT_CRUSHING = "Crushing";

-- You
UNIT_YOU = "You";
UNIT_YOU_SOURCE = "Your";
UNIT_YOU_DEST = "You";

-- The many action types
ACTION_SWING = "Melee"
ACTION_RANGED = "Shot"

-- Successful events
ACTION_SWING_DAMAGE = "Hits";
ACTION_SWING_DAMAGE_FULL_TEXT = "$source melee swing hit $dest for $value.$result";
ACTION_SWING_DAMAGE_FULL_TEXT_NO_SOURCE = "A melee swing hit $dest for $value.$result";
ACTION_RANGE_DAMAGE = "Hits";
ACTION_RANGE_DAMAGE_FULL_TEXT = "$source ranged shot hit $dest for $value.$result";
ACTION_RANGE_DAMAGE_FULL_TEXT_NO_SOURCE = "A ranged shot hit $dest for $value.$result";
ACTION_DAMAGE_SHIELD = "Damages";
ACTION_DAMAGE_SHIELD_FULL_TEXT = "$source $spell reflects $value $school damage to $dest.$result";
ACTION_DAMAGE_SHIELD_FULL_TEXT_NO_SOURCE = "$spell reflects $value $school damage to $dest.$result";
ACTION_SPELL_DAMAGE = "Hits";
ACTION_SPELL_DAMAGE_FULL_TEXT = "$source $spell hit $dest for $value.$result";
ACTION_SPELL_DAMAGE_FULL_TEXT_NO_SOURCE = "$spell hit $dest for $value.$result";
ACTION_SPELL_DRAIN = "Drains";
ACTION_SPELL_DRAIN_FULL_TEXT = "$source $spell drains $amount $powerType from $dest.";
ACTION_SPELL_DRAIN_FULL_TEXT_NO_SOURCE = " $spell drains $amount $powerType from $dest.";
ACTION_SPELL_ENERGIZE = "Energizes";
ACTION_SPELL_ENERGIZE_RESULT = "$extraAmount $powerType Gained";
ACTION_SPELL_ENERGIZE_FULL_TEXT = "$dest gains $amount $powerType from $source $spell.";
ACTION_SPELL_ENERGIZE_FULL_TEXT_NO_SOURCE = "$dest gains $amount $powerType from $spell.";
ACTION_SPELL_HEAL = "Heals";
ACTION_SPELL_HEAL_FULL_TEXT = "$source $spell heals $dest for $amount.";
ACTION_SPELL_HEAL_FULL_TEXT_NO_SOURCE = "$spell heals $dest for $amount.";
ACTION_SPELL_LEECH = "Drains";
ACTION_SPELL_LEECH_RESULT = "$extraAmount $powerType Gained";
ACTION_SPELL_LEECH_FULL_TEXT = "$source $spell drains $amount $powerType from $dest. $source gains $extraAmount $powerType.";
ACTION_SPELL_LEECH_FULL_TEXT_NO_SOURCE = "$spell drains $amount $powerType from $dest.";
ACTION_SPELL_PERIODIC_DAMAGE = "Damages";
ACTION_SPELL_PERIODIC_DAMAGE_FULL_TEXT = "$dest suffers $value damage from $source $spell.$result";
ACTION_SPELL_PERIODIC_DAMAGE_FULL_TEXT_NO_SOURCE = "$dest suffers $value damage from $spell.$result";
ACTION_SPELL_PERIODIC_DRAIN = "Drains";
ACTION_SPELL_PERIODIC_DRAIN_FULL_TEXT = "$source $spell drains $amount $powerType from $dest.";
ACTION_SPELL_PERIODIC_DRAIN_FULL_TEXT_NO_SOURCE = "$spell drains $amount $powerType from $dest.";
ACTION_SPELL_PERIODIC_ENERGIZE = "Energizes";
ACTION_SPELL_PERIODIC_ENERGIZE_RESULT = "$extraAmount $powerType Gained";
ACTION_SPELL_PERIODIC_ENERGIZE_FULL_TEXT = "$dest gains $amount $powerType from $source $spell.";
ACTION_SPELL_PERIODIC_ENERGIZE_FULL_TEXT_NO_SOURCE = "$dest gains $amount $powerType from $spell.";
ACTION_SPELL_PERIODIC_HEAL = "Heals";
ACTION_SPELL_PERIODIC_HEAL_FULL_TEXT = "$dest gains $value health from $source $spell.$result";
ACTION_SPELL_PERIODIC_HEAL_FULL_TEXT_NO_SOURCE = "$dest gains $value health from $spell.$result";
ACTION_SPELL_PERIODIC_LEECH = "Drains";
ACTION_SPELL_PERIODIC_LEECH_RESULT = "$extraAmount $powerType Gained";
ACTION_SPELL_PERIODIC_LEECH_FULL_TEXT = "$source $spell drains $amount $powerType from $dest. $source gains $extraAmount $powerType.";
ACTION_SPELL_PERIODIC_LEECH_FULL_TEXT_NO_SOURCE = "$spell drains $amount $powerType from $dest. $source gains $extraAmount $powerType.";

-- Aura events
ACTION_SPELL_AURA_APPLIED = "Applies";
ACTION_SPELL_AURA_APPLIED_BUFF = "Gains";
ACTION_SPELL_AURA_APPLIED_BUFF_FULL_TEXT = "$dest gains $spell.";
ACTION_SPELL_AURA_APPLIED_DEBUFF = "Afflicts";
ACTION_SPELL_AURA_APPLIED_DEBUFF_FULL_TEXT = "$dest is afflicted by $spell.";
ACTION_SPELL_AURA_APPLIED_DOSE = "Stacks";
ACTION_SPELL_AURA_APPLIED_DOSE_BUFF = "Stacks";
ACTION_SPELL_AURA_APPLIED_DOSE_BUFF_FULL_TEXT = "$dest gains $spell ($amount).";
ACTION_SPELL_AURA_APPLIED_DOSE_DEBUFF = "Afflicts";
ACTION_SPELL_AURA_APPLIED_DOSE_DEBUFF_FULL_TEXT = "$dest is afflicted by $spell ($amount).";
ACTION_SPELL_AURA_REMOVED = "Removes";
ACTION_SPELL_AURA_REMOVED_FULL_TEXT = "$spell was removed from $dest.";
ACTION_SPELL_AURA_REMOVED_BUFF = "Fades";
ACTION_SPELL_AURA_REMOVED_BUFF_FULL_TEXT = "$spell fades from $dest.";
ACTION_SPELL_AURA_REMOVED_DEBUFF = "Dissipates";
ACTION_SPELL_AURA_REMOVED_DEBUFF_FULL_TEXT = "$spell dissipates from $dest.";
ACTION_SPELL_AURA_REMOVED_DOSE = "Reduces";
ACTION_SPELL_AURA_REMOVED_DOSE_BUFF = "Reduces";
ACTION_SPELL_AURA_REMOVED_DOSE_BUFF_FULL_TEXT = "$source $spell ($amount) diminishes.";
ACTION_SPELL_AURA_REMOVED_DOSE_DEBUFF = "Diminishes";
ACTION_SPELL_AURA_REMOVED_DOSE_DEBUFF_FULL_TEXT = "$source $spell ($amount) subsides.";
ACTION_SPELL_AURA_DISPELLED = "Dispels";
ACTION_SPELL_AURA_DISPELLED_BUFF = "Dispels";
ACTION_SPELL_AURA_DISPELLED_BUFF_FULL_TEXT = "$dest $extraSpell is dispelled by $source $spell.";
ACTION_SPELL_AURA_DISPELLED_BUFF_FULL_TEXT_NO_SOURCE = "$dest $extraSpell is dispelled by $spell.";
ACTION_SPELL_AURA_DISPELLED_DEBUFF = "Cleanses";
ACTION_SPELL_AURA_DISPELLED_DEBUFF_FULL_TEXT = "$dest $extraSpell is cleansed by $source $spell.";
ACTION_SPELL_AURA_DISPELLED_DEBUFF_FULL_TEXT_NO_SOURCE = "$dest $extraSpell is cleansed by $spell.";
ACTION_SPELL_AURA_STOLEN = "Steals";
ACTION_SPELL_AURA_STOLEN_FULL_TEXT = "$source $spell steals $dest $extraSpell.";
ACTION_SPELL_AURA_STOLEN_FULL_TEXT_NO_SOURCE = "$spell steals $dest $extraSpell.";
ACTION_SPELL_AURA_STOLEN_BUFF = "Steals";
ACTION_SPELL_AURA_STOLEN_BUFF_FULL_TEXT = "$source $spell steals $dest $extraSpell.";
ACTION_SPELL_AURA_STOLEN_BUFF_FULL_TEXT_NO_SOURCE = "$spell steals $dest $extraSpell.";
ACTION_SPELL_AURA_STOLEN_DEBUFF = "Steals";
ACTION_SPELL_AURA_STOLEN_DEBUFF_FULL_TEXT = "$source $spell transfers $dest $extraSpell to $source.";
ACTION_SPELL_AURA_STOLEN_DEBUFF_FULL_TEXT_NO_SOURCE = "$spell transfers $dest $extraSpell.";

-- Miss events
ACTION_SWING_MISSED = "Misses";
ACTION_SWING_MISSED_FULL_TEXT = "$source attack misses $dest.";
ACTION_SWING_MISSED_MISS = "Missed";
ACTION_SWING_MISSED_MISS_FULL_TEXT = "$source attack misses $dest.";
ACTION_SWING_MISSED_ABSORB = "Absorbed";
ACTION_SWING_MISSED_ABSORB_FULL_TEXT = "$source attack was absorbed by $dest.";
ACTION_SWING_MISSED_BLOCK = "Blocked";
ACTION_SWING_MISSED_BLOCK_FULL_TEXT = "$source attack was blocked by $dest.";
ACTION_SWING_MISSED_DEFLECT = "Deflected";
ACTION_SWING_MISSED_DEFLECT_FULL_TEXT = "$source attack was deflected by $dest.";
ACTION_SWING_MISSED_DODGE = "Dodged";
ACTION_SWING_MISSED_DODGE_FULL_TEXT = "$source attack was dodged by $dest.";
ACTION_SWING_MISSED_EVADE = "Evaded";
ACTION_SWING_MISSED_EVADE_FULL_TEXT = "$source attack was evaded by $dest.";
ACTION_SWING_MISSED_IMMUNE = "Immune";
ACTION_SWING_MISSED_IMMUNE_FULL_TEXT = "$source attack failed. $dest was immune.";
ACTION_SWING_MISSED_PARRY = "Parried";
ACTION_SWING_MISSED_PARRY_FULL_TEXT = "$source attack was parried by $dest.";
ACTION_SWING_MISSED_RESIST = "Resisted";
ACTION_SWING_MISSED_RESIST_FULL_TEXT = "$source attack was fully resisted by $dest.";
ACTION_RANGE_MISSED = "Misses";
ACTION_RANGE_MISSED_FULL_TEXT = "$source shot misses $dest.";
ACTION_RANGE_MISSED_MISS = "Missed";
ACTION_RANGE_MISSED_MISS_FULL_TEXT = "$source shot misses $dest.";
ACTION_RANGE_MISSED_ABSORB = "Absorbed";
ACTION_RANGE_MISSED_ABSORB_FULL_TEXT = "$source shot was absorbed by $dest.";
ACTION_RANGE_MISSED_BLOCK = "Blocked";
ACTION_RANGE_MISSED_BLOCK_FULL_TEXT = "$source shot was blocked by $dest.";
ACTION_RANGE_MISSED_DEFLECT = "Deflected";
ACTION_RANGE_MISSED_DEFLECT_FULL_TEXT = "$source shot was deflected by $dest.";
ACTION_RANGE_MISSED_DODGE = "Dodged";
ACTION_RANGE_MISSED_DODGE_FULL_TEXT = "$source shot was dodged by $dest.";
ACTION_RANGE_MISSED_EVADE = "Evaded";
ACTION_RANGE_MISSED_EVADE_FULL_TEXT = "$source shot was evaded by $dest.";
ACTION_RANGE_MISSED_IMMUNE = "Immune";
ACTION_RANGE_MISSED_IMMUNE_FULL_TEXT = "$source shot failed. $dest was immune.";
ACTION_RANGE_MISSED_PARRY = "Parried";
ACTION_RANGE_MISSED_PARRY_FULL_TEXT = "$source shot was parried by $dest.";
ACTION_RANGE_MISSED_RESIST = "Resisted";
ACTION_RANGE_MISSED_RESIST_FULL_TEXT = "$source shot was fully resisted by $dest.";
ACTION_SPELL_MISSED = "Missed";
ACTION_SPELL_MISSED_FULL_TEXT = "$source $spell missed $dest.";
ACTION_SPELL_MISSED_FULL_TEXT_NO_SOURCE = "$spell missed $dest.";
ACTION_SPELL_MISSED_RESIST = "Resisted";
ACTION_SPELL_MISSED_RESIST_FULL_TEXT = "$source $spell was fully resisted by $dest.";
ACTION_SPELL_MISSED_RESIST_FULL_TEXT_NO_SOURCE = "$spell was fully resisted by $dest.";
ACTION_SPELL_MISSED_MISS = "Missed";
ACTION_SPELL_MISSED_MISS_FULL_TEXT = "$source $spell misses $dest.";
ACTION_SPELL_MISSED_MISS_FULL_TEXT_NO_SOURCE = "$spell misses $dest.";
ACTION_SPELL_MISSED_ABSORB = "Absorbed";
ACTION_SPELL_MISSED_ABSORB_FULL_TEXT = "$source $spell was absorbed by $dest.";
ACTION_SPELL_MISSED_ABSORB_FULL_TEXT_NO_SOURCE = "$spell was absorbed by $dest.";
ACTION_SPELL_MISSED_BLOCK = "Blocked";
ACTION_SPELL_MISSED_BLOCK_FULL_TEXT = "$source $spell was blocked by $dest.";
ACTION_SPELL_MISSED_BLOCK_FULL_TEXT_NO_SOURCE = "$spell was blocked by $dest.";
ACTION_SPELL_MISSED_DEFLECT = "Deflected";
ACTION_SPELL_MISSED_DEFLECT_FULL_TEXT = "$source $spell was deflected by $dest.";
ACTION_SPELL_MISSED_DEFLECT_FULL_TEXT_NO_SOURCE = "$spell was deflected by $dest.";
ACTION_SPELL_MISSED_DODGE = "Dodged";
ACTION_SPELL_MISSED_DODGE_FULL_TEXT = "$source $spell was dodged by $dest.";
ACTION_SPELL_MISSED_DODGE_FULL_TEXT_NO_SOURCE = "$spell was dodged by $dest.";
ACTION_SPELL_MISSED_EVADE = "Evaded";
ACTION_SPELL_MISSED_EVADE_FULL_TEXT = "$source $spell was evaded by $dest.";
ACTION_SPELL_MISSED_EVADE_FULL_TEXT_NO_SOURCE = "$spell was evaded by $dest.";
ACTION_SPELL_MISSED_IMMUNE = "Immune";
ACTION_SPELL_MISSED_IMMUNE_FULL_TEXT = "$source $spell failed. $dest was immune.";
ACTION_SPELL_MISSED_IMMUNE_FULL_TEXT_NO_SOURCE = "$spell failed. $dest was immune.";
ACTION_SPELL_MISSED_PARRY = "Parried";
ACTION_SPELL_MISSED_PARRY_FULL_TEXT = "$source $spell was parried by $dest.";
ACTION_SPELL_MISSED_PARRY_FULL_TEXT_NO_SOURCE = "$spell was parried by $dest.";
ACTION_SPELL_PERIODIC_MISSED = "Tick Misses";
ACTION_SPELL_PERIODIC_MISSED_FULL_TEXT = "$source $spell does not affect $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_FULL_TEXT_NO_SOURCE = "$spell does not affect $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_RESIST = "Tick Resisted";
ACTION_SPELL_PERIODIC_MISSED_RESIST_FULL_TEXT = "$source $spell does not affect $dest. $dest resisted.$result";
ACTION_SPELL_PERIODIC_MISSED_RESIST_FULL_TEXT_NO_SOURCE = "$spell does not affect $dest. $dest resisted.$result";
ACTION_SPELL_PERIODIC_MISSED_MISS = "Tick Missed";
ACTION_SPELL_PERIODIC_MISSED_MISS_FULL_TEXT = "$source $spell missed $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_MISS_FULL_TEXT_NO_SOURCE = "$spell missed $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_ABSORB = "Tick Absorbed";
ACTION_SPELL_PERIODIC_MISSED_ABSORB_FULL_TEXT = "$source $spell was absorbed by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_ABSORB_FULL_TEXT_NO_SOURCE = "$spell was absorbed by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_BLOCK = "Tick Blocked";
ACTION_SPELL_PERIODIC_MISSED_BLOCK_FULL_TEXT = "$source $spell was blocked by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_BLOCK_FULL_TEXT_NO_SOURCE = "$spell was blocked by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_DEFLECTED = "Tick Deflected";
ACTION_SPELL_PERIODIC_MISSED_DEFLECTED_FULL_TEXT = "$source $spell was deflected by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_DEFLECTED_FULL_TEXT_NO_SOURCE = "$spell was deflected by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_DODGE = "Tick Dodged";
ACTION_SPELL_PERIODIC_MISSED_DODGE_FULL_TEXT = "$source $spell was dodged by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_DODGE_FULL_TEXT_NO_SOURCE = "$spell was dodged by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_EVADED = "Tick Evaded";
ACTION_SPELL_PERIODIC_MISSED_EVADED_FULL_TEXT = "$source $spell was evaded by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_EVADED_FULL_TEXT_NO_SOURCE = "$spell was evaded by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_IMMUNE = "Tick Immune";
ACTION_SPELL_PERIODIC_MISSED_IMMUNE_FULL_TEXT = "$dest was immune to $source $spell for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_IMMUNE_FULL_TEXT_NO_SOURCE = "$dest was immune to $spell for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_PARRY = "Tick Parried";
ACTION_SPELL_PERIODIC_MISSED_PARRY_FULL_TEXT = "$source $spell was parried by $dest for a moment.$result";
ACTION_SPELL_PERIODIC_MISSED_PARRY_FULL_TEXT_NO_SOURCE = "$spell was parried by $dest for a moment.$result";
ACTION_DAMAGE_SHIELD_MISSED = "Missed";
ACTION_DAMAGE_SHIELD_MISSED_FULL_TEXT = "$source $spell missed $dest.";
ACTION_DAMAGE_SHIELD_MISSED_FULL_TEXT_NO_SOURCE = "$spell missed $dest.";
ACTION_DAMAGE_SHIELD_MISSED_RESIST = "Resisted";
ACTION_DAMAGE_SHIELD_MISSED_RESIST_FULL_TEXT = "$source $spell was fully resisted by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_RESIST_FULL_TEXT_NO_SOURCE = "$spell was fully resisted by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_MISS = "Missed";
ACTION_DAMAGE_SHIELD_MISSED_MISS_FULL_TEXT = "$source $spell misses $dest.";
ACTION_DAMAGE_SHIELD_MISSED_MISS_FULL_TEXT_NO_SOURCE = "$spell misses $dest.";
ACTION_DAMAGE_SHIELD_MISSED_BLOCK = "Blocked";
ACTION_DAMAGE_SHIELD_MISSED_BLOCK_FULL_TEXT = "$source $spell was blocked by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_BLOCK_FULL_TEXT_NO_SOURCE = "$spell was blocked by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_DEFLECTED = "Deflected";
ACTION_DAMAGE_SHIELD_MISSED_DEFLECTED_FULL_TEXT = "$source $spell was deflected by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_DEFLECTED_FULL_TEXT_NO_SOURCE = "$spell was deflected by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_DODGE = "Dodged";
ACTION_DAMAGE_SHIELD_MISSED_DODGE_FULL_TEXT = "$source $spell was dodged by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_DODGE_FULL_TEXT_NO_SOURCE = "$spell was dodged by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_EVADED = "Evaded";
ACTION_DAMAGE_SHIELD_MISSED_EVADED_FULL_TEXT = "$source $spell was evaded by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_EVADED_FULL_TEXT_NO_SOURCE = "$spell was evaded by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_IMMUNE = "Immune";
ACTION_DAMAGE_SHIELD_MISSED_IMMUNE_FULL_TEXT = "$source $spell failed. $dest was immune.";
ACTION_DAMAGE_SHIELD_MISSED_IMMUNE_FULL_TEXT_NO_SOURCE = "$spell failed. $dest was immune.";
ACTION_DAMAGE_SHIELD_MISSED_PARRY = "Parried";
ACTION_DAMAGE_SHIELD_MISSED_PARRY_FULL_TEXT = "$source $spell was parried by $dest.";
ACTION_DAMAGE_SHIELD_MISSED_PARRY_FULL_TEXT_NO_SOURCE = "$spell was parried by $dest.";

-- Spellcast
ACTION_SPELL_CAST_START = "Begins Casting";
ACTION_SPELL_CAST_START_FULL_TEXT = "$source began to cast $spell.";
ACTION_SPELL_CAST_SUCCESS = "Casts";
ACTION_SPELL_CAST_SUCCESS_FULL_TEXT = "$source cast $spell at $dest.";
ACTION_SPELL_CAST_SUCCESS_FULL_TEXT_NO_DEST = "$source cast $spell.";
ACTION_SPELL_CAST_FAILED = "Fails";
ACTION_SPELL_CAST_FAILED_FULL_TEXT = "$source failed to cast $spell.";

-- Unique Spell Events
ACTION_SPELL_EXTRA_ATTACKS = "Grants Extra Attacks";
ACTION_SPELL_EXTRA_ATTACKS_FULL_TEXT = "$source gains $amount extra attacks through $spell.";
ACTION_SPELL_EXTRA_ATTACKS_FULL_TEXT_NO_SOURCE = "$amount extra attacks granted by $spell.";
ACTION_SPELL_INTERRUPT = "Interrupts";
ACTION_SPELL_INTERRUPT_FULL_TEXT = "$source $spell interrupts $dest $extraSpell.";
ACTION_SPELL_INTERRUPT_FULL_TEXT_NO_SOURCE = "$spell interrupts $dest $extraSpell.";
ACTION_SPELL_INSTAKILL = "Instakills";
ACTION_SPELL_INSTAKILL_FULL_TEXT = "$source $spell instantly kills $dest.";
ACTION_SPELL_INSTAKILL_FULL_TEXT_NO_SOURCE = "$spell instantly kills $dest.";
ACTION_SPELL_DURABILITY_DAMAGE = "Durability Loss";
ACTION_SPELL_DURABILITY_DAMAGE_FULL_TEXT = "$source $spell damages $dest: $item damaged.";
ACTION_SPELL_DURABILITY_DAMAGE_ALL = "Full Durability Loss";
ACTION_SPELL_DURABILITY_DAMAGE_ALL_FULL_TEXT = "$source $spell damages $dest: all items damaged.";
ACTION_SPELL_DISPEL_FAILED = "Dispel Failed";
ACTION_SPELL_DISPEL_FAILED_FULL_TEXT = "$source $spell fails to dispel $dest $extraSpell.";
ACTION_SPELL_DISPEL_FAILED_FULL_TEXT_NO_SOURCE = "$spell fails to dispel $dest $extraSpell.";

-- Special Events
ACTION_PARTY_KILL = "Killed";
ACTION_PARTY_KILL_FULL_TEXT = "$source has slain $dest!";
ACTION_UNIT_DIED = "Dies";
ACTION_UNIT_DIED_FULL_TEXT = "$dest died.";
ACTION_UNIT_DESTROYED = "Destroy";
ACTION_UNIT_DESTROYED_FULL_TEXT = "$dest was destroyed.";
ACTION_DAMAGE_SPLIT = "Split Damage";
ACTION_DAMAGE_SPLIT_FULL_TEXT = "$source $spell causes $amount damage to $dest.";
ACTION_ENCHANT_APPLIED = "Enchant Applied";
ACTION_ENCHANT_APPLIED_FULL_TEXT = "$source casts $extraSpell on $dest $weapon.";
ACTION_ENCHANT_REMOVED = "Enchant Removed";
ACTION_ENCHANT_REMOVED_FULL_TEXT = "$extraSpell fades from $dest $weapon.";
ACTION_ENVIRONMENTAL_DAMAGE = "Damages";
ACTION_ENVIRONMENTAL_DAMAGE_FULL_TEXT = "$dest loses $amount health from environmental damage.";
ACTION_ENVIRONMENTAL_DAMAGE_DROWNING = "Drowning";
ACTION_ENVIRONMENTAL_DAMAGE_DROWNING_FULL_TEXT = "$dest is drowning and loses $amount health.";
ACTION_ENVIRONMENTAL_DAMAGE_FATIGUE = "Fatigue";
ACTION_ENVIRONMENTAL_DAMAGE_FATIGUE_FULL_TEXT = "$dest is exhasuted and loses $amount health.";
ACTION_ENVIRONMENTAL_DAMAGE_FALLING = "Falling";
ACTION_ENVIRONMENTAL_DAMAGE_FALLING_FULL_TEXT = "$dest falls and loses $amount health.";
ACTION_ENVIRONMENTAL_DAMAGE_FIRE = "Fire";
ACTION_ENVIRONMENTAL_DAMAGE_FIRE_FULL_TEXT = "$dest suffers $amount points of fire damage.";
ACTION_ENVIRONMENTAL_DAMAGE_LAVA = "Lava";
ACTION_ENVIRONMENTAL_DAMAGE_LAVA_FULL_TEXT = "$dest loses $amount health for swimming in lava.";
ACTION_ENVIRONMENTAL_DAMAGE_SLIME = "Slime";
ACTION_ENVIRONMENTAL_DAMAGE_SLIME_FULL_TEXT = "$dest loses $amount health for swimming in slime.";

-- The many school types
STRING_SCHOOL_PHYSICAL = "Physical"
STRING_SCHOOL_FIRE = "Fire"
STRING_SCHOOL_FROST = "Frost"
STRING_SCHOOL_ARCANE = "Arcane"
STRING_SCHOOL_NATURE = "Nature"
STRING_SCHOOL_SHADOW = "Shadow"
STRING_SCHOOL_HOLY = "Holy"
STRING_SCHOOL_UNKNOWN = "Unknown"

-- The power types
STRING_POWER_MANA = "Mana"
STRING_POWER_RAGE = "Rage"
STRING_POWER_ENERGY = "Energy"
STRING_POWER_HAPPINESS = "Happiness"
STRING_POWER_RUNES = "Runes"
STRING_POWER_FOCUS = "Focus"

-- The Environmental Damage Types
STRING_ENVIRONMENTAL_DAMAGE_FATIGUE = "Fatigue";
STRING_ENVIRONMENTAL_DAMAGE_DROWNING = "Drowning";
STRING_ENVIRONMENTAL_DAMAGE_FALLING = "Falling";
STRING_ENVIRONMENTAL_DAMAGE_LAVA = "Lava";
STRING_ENVIRONMENTAL_DAMAGE_SLIME = "Slime";
STRING_ENVIRONMENTAL_DAMAGE_FIRE = "Fire";

