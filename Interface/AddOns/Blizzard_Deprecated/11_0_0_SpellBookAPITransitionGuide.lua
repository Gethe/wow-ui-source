--[[

This file is meant to help with converting lua code to use the updated Spell/SpellBook APIs post-SpellBook-UI-revamp.
Most functions have simply been moved under the C_SpellBook or C_Spell namespaces, but some changes/conversions are less obvious.


Relevant Blizzard_APIDocumentationGenerated files:
    - SpellBookDocumentation.lua
    - SpellBookConstantsDocumentation.lua
    - SpellDocumentation.lua
    - SpellSharedDocumentation.lua


Important Function Parameter changes
    SpellBook "bookType" string parameters have been replaced by "spellBank" Enum.SpellBookSpellBank parameters
        - "spell" / BOOKTYPE_SPELL = Enum.SpellBookSpellBank.Player
        - "pet" / BOOKTYPE_PET = Enum.SpellBookSpellBank.Pet
        - (Any other bookType values passed were being treated as "spell" so just use Enum.SpellBookSpellBank.Player for anything else)
    
    New "spellIdentifier" parameter type accepts a Spell ID, name, name(subtext), or link


-------------------------
-- Converted Functions --
-------------------------

GetSpellLink(spellID/name) = C_Spell.GetSpellLink(spellIdentifier)
GetSpellLink(index, bookType) = C_SpellBook.GetSpellBookItemLink(index, spellBank)

GetSpellTradeSkillLink(spellID/name) = C_Spell.GetSpellTradeSkillLink(spellIdentifier)
GetSpellTradeSkillLink(index, bookType) = C_SpellBook.GetSpellBookItemTradeSkillLink(index, spellBank)

IsPassiveSpell(spellID/name) = C_Spell.IsSpellPassive(spellIdentifier)
IsPassiveSpell(index, bookType) = C_SpellBook.IsSpellBookItemPassive(index, spellBank)

IsHelpfulSpell(spellID/name) = C_Spell.IsSpellHelpful(spellIdentifier)
IsHelpfulSpell(index, bookType) = C_SpellBook.IsSpellBookItemHelpful(index, spellBank)
IsHarmfulSpell(spellID/name) = C_Spell.IsSpellHarmful(spellIdentifier)
IsHarmfulSpell(index, bookType) = C_SpellBook.IsSpellBookItemHarmful(index, spellBank)

IsUsableSpell(spellID/name) = C_Spell.IsSpellUsable(spellIdentifier)
IsUsableSpell(index, bookType) = C_SpellBook.IsSpellBookItemUsable(index, spellBank)

SpellHasRange(spellID/name) = C_Spell.SpellHasRange(spellIdentifier)
SpellHasRange(index, bookType) C_SpellBook.SpellBookItemHasRange(index, spellBank)
IsSpellInRange(spellID/name) C_Spell.IsSpellInRange(spellIdentifier)
IsSpellInRange(index, bookType) C_SpellBook.IsSpellBookItemInRange(index, spellBank)

GetSpellLevelLearned(spellID/name) = C_Spell.GetSpellLevelLearned(spellIdentifier)
GetSpellLevelLearned(index, bookType) = C_SpellBook.GetSpellBookItemLevelLearned(index, spellBank)

-- Both return new SpellCooldownInfo table (see SpellSharedDocumentation.lua)
GetSpellCooldown(spellID/name) = C_Spell.GetSpellCooldown(spellIdentifier)
GetSpellCooldown(index, bookType) = C_SpellBook.GetSpellBookItemCooldown(index, spellBank)

GetSpellLossOfControlCooldown(spellID/name) = C_Spell.GetSpellLossOfControlCooldown(spellIdentifier)
GetSpellLossOfControlCooldown(index, bookType) = C_SpellBook.GetSpellBookItemLossOfControlCooldown(index, spellBank)

-- Both return new SpellChargeInfo table (see SpellSharedDocumentation.lua)
GetSpellCharges(spellID/name) = C_Spell.GetSpellCharges(spellIdentifier)
GetSpellCharges(index, bookType) = C_SpellBook.GetSpellBookItemCharges(index, spellBank)

GetSpellCount(spellID/name) = C_Spell.GetSpellCastCount(spellIdentifier)
GetSpellCount(index, bookType) = C_SpellBook.GetSpellBookItemCastCount(index, spellBank)

-- Both return array of new SpellPowerCostInfo tables (see SpellSharedDocumentation.lua) which matches old return table structure
GetSpellPowerCost(spellID/name) = C_Spell.GetSpellPowerCost(spellIdentifier)
GetSpellPowerCost(index, bookType) = C_SpellBook.GetSpellBookItemPowerCost(index, spellBank)

-- GetSpellAvailableLevel and GetSpellLevelLearned have been unified
GetSpellAvailableLevel/GetSpellLevelLearned(spellID/name) = C_Spell.GetSpellLevelLearned(spellIdentifier)
GetSpellAvailableLevel/GetSpellLevelLearned(index, bookType) = C_SpellBook.GetSpellBookItemLevelLearned(index, spellBank)

GetSpellAutocast(spellID/name) = C_Spell.GetSpellAutoCast(spellIdentifier)
GetSpellAutocast(index, bookType) = C_SpellBook.GetSpellBookItemAutoCast(index, spellBank)

ToggleSpellAutocast(spellID/name) = C_Spell.ToggleSpellAutoCast(spellIdentifier)
ToggleSpellAutocast(index, bookType) = C_SpellBook.ToggleSpellBookItemAutoCast(index, spellBank)

-- Enable/Disable auto cast functions have been merged into single Set Enabled functions
EnableSpellAutocast/DisableSpellAutocast(spellID/name) = C_Spell.SetSpellAutoCastEnabled(spellIdentifier, bool)
EnableSpellAutocast/DisableSpellAutocast(index, bookType) = C_SpellBook.SetSpellBookItemAutoCastEnabled(index, spellBank, bool)

PickupSpell(spellID/name) = C_Spell.PickupSpell(spellIdentifier)
PickupSpellBookItem(index, bookType) = C_SpellBook.PickupSpellBookItem(index, spellBank)

GetNumSpellTabs() = C_SpellBook.GetNumSpellBookSkillLines()

-- Returns new SpellBookSkillLineInfo table
GetSpellTabInfo(index) = C_SpellBook.GetSpellBookSkillLineInfo(index)

-- New C_SpellBook.GetSpellBookItemInfo contains far more info than old GetSpellBookItemInfo
-- C_SpellBook.GetSpellBookItemType is the direct replacement for just the type info that the old GetSpellBookItemInfo returned (+spellID as a new bonus 3rd return value)
GetSpellBookItemInfo(index, bookType) = C_SpellBook.GetSpellBookItemType(index, spellBank)

GetSpellBookItemTexture(index, bookType) = C_SpellBook.GetSpellBookItemTexture(index, spellBank)
GetSpellBookItemName(index, bookType) = C_SpellBook.GetSpellBookItemName(index, spellBank)

DoesSpellExist(spellID/name) = C_Spell.DoesSpellExist(spellIdentifier)

HasPetSpells() = C_SpellBook.HasPetSpells()

GetSpellDescription(spellID) = C_Spell.GetSpellDescription(spellIdentifier);
GetSpellSubtext(spellID) = C_Spell.GetSpellSubtext(spellIdentifier);
GetSpellTexture(spellID) = C_Spell.GetSpellTexture(spellIdentifier);
GetSpellRank(spellID) = C_Spell.GetSpellSkillLineAbilityRank(spellIdentifier);

IsAttackSpell(spellName) = C_Spell.IsAutoAttackSpell(spellIdentifier)
IsAttackSpell(index, bookType) = C_SpellBook.IsAutoAttackSpellBookItem(index, spellBank)
-- Ranged Auto Attack functions have also been added
                            C_Spell.IsRangedAutoAttackSpell(spellIdentifier)
                            C_SpellBook.IsRangedAutoAttackSpellBookItem(index, spellBank)

IsAutoRepeatSpell(spellID/name) = C_Spell.IsAutoRepeatSpell(spellIdentifier)
IsCurrentSpell(spellID/name) = C_Spell.IsCurrentSpell(spellIdentifier)
IsPressHoldReleaseSpell(spellID/name) = C_Spell.IsPressHoldReleaseSpell(spellIdentifier)

IsTalentSpell(spellID/name) = C_Spell.IsClassTalentSpell(spellIdentifier)
IsTalentSpell(index, bookType) = C_SpellBook.IsClassTalentSpellBookItem(index, spellBank)
IsPvpTalentSpell(spellID/name) = C_Spell.IsPvPTalentSpell(spellIdentifier)
IsPvpTalentSpell(index, bookType) = C_SpellBook.IsPvPTalentSpellBookItem(index, spellBank)

GameTooltip:SetSpellBookItem(index, bookType) = GameTooltip:SetSpellBookItem(index, spellBank)


---------------------
-- Moved Functions --
---------------------
                        
C_SpellBook.IsSpellDisabled = C_Spell.IsSpellDisabled

C_SpellBook.GetSpellInfo = C_Spell.GetSpellInfo;
-- If only a single spell field is needed, try using one of the new more specific getters in C_Spell instead of a full Get Info
                           C_Spell.GetSpellName
                           C_Spell.GetSpellTexture (etc)
                           

C_SpellBook.GetSpellLinkFromSpellID = C_Spell.GetSpellLink

C_SpellBook.GetDeadlyDebuffInfo = C_Spell.GetDeadlyDebuffInfo

C_SpellBook.GetOverrideSpell = C_Spell.GetOverrideSpell



--------------------
-- Updated Events --
--------------------

LearnedSpellInTab / LEARNED_SPELL_IN_TAB = LearnedSpellInSkillLine / LEARNED_SPELL_IN_SKILL_LINE



--]]