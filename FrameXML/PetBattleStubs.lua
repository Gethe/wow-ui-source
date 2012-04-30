--Events:
--PET_BATTLE_OPENING_START
--PET_BATTLE_OPENING_DONE
--PET_BATTLE_FINAL_ROUND winner
--PET_BATTLE_CLOSE
--PET_BATTLE_HEALTH_CHANGED petOwner, petIndex
--PET_BATTLE_TURN_STARTED
--PET_BATTLE_PET_CHANGED petOwner
--PET_BATTLE_ACTION_SELECTED

PBDebugFrame = CreateFrame("FRAME");
PBDebugFrame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
PBDebugFrame:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS");

--Debug frames:
PBDEBUG_TURN_TIME = 30;
PBDEBUG_ACTIVE_ALLY = 1;
PBDEBUG_ACTIVE_ENEMY = 2;

function PBSignalEvent(event, ...)
	PetBattleFrame_OnEvent(PetBattleFrame, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.ActiveAlly, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.ActiveEnemy, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.Ally2, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.Ally3, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.Enemy2, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.Enemy3, event, ...);
	PetBattleUnitFrame_OnEvent(PetBattleFrame.BottomFrame.PetSelectionFrame.Pet1, event, ...);
	PetBattleUnitFrame_OnEvent(TestTooltip, event, ...);
end

function PBDO(pet1, pet2)
	if ( not pet1 ) then
		petSpecies1, petName1, petDisplayID1 = 307, "Giant Sewer Rat", 38065;
	end
	if ( not pet2 ) then
		petSpecies2, petName2, petDisplayID2 = 193, "Lashtail Hatchling", 27627;
	end
	PetBattleOpeningFrame_OnEvent(PetBattleOpeningFrame, "PET_BATTLE_OPENING_START");
	PBDebugFrame.hideOpeningIn = 1; --Time in seconds to keep the frame up
	PBDebugFrame.lastTurnTimer = nil;
end

function PBDebugFrame_OnUpdate(self, elapsed)
	if ( self.hideOpeningIn ) then
		self.hideOpeningIn = self.hideOpeningIn - elapsed;
		if ( self.hideOpeningIn <= 0 ) then
			self.hideOpeningIn = nil;
			PetBattleOpeningFrame_OnEvent(PetBattleOpeningFrame, "PET_BATTLE_OPENING_DONE");
		end
	end

	local now = GetTime();
	if ( not self.lastTurnTimer ) then
		self.lastTurnTimer = now;
		self.skippedTurn = false;
		PetBattleFrame_OnEvent(PetBattleFrame, "PET_BATTLE_TURN_STARTED");
	end
end
PBDebugFrame:SetScript("OnUpdate", PBDebugFrame_OnUpdate);

function PBDebugFrame_OnEvent(self, event, ...)
	if ( event == "PET_BATTLE_PET_ROUND_RESULTS" ) then
		self.inPlayback = true;
		self.lastTurnTimer = nil; --Update the time next tick
	elseif ( event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE" ) then
		self.inPlayback = false;
	end
end
PBDebugFrame:SetScript("OnEvent", PBDebugFrame_OnEvent);

function PBDamagePet(petOwner, petIndex, damageAmount)
	local health = DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.CURRENTHEALTH];
	DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.CURRENTHEALTH] = health - damageAmount;
	PBSignalEvent("PET_BATTLE_HEALTH_CHANGED", petOwner, petIndex);
end

DEBUG_PET_INDEX = {
	NAME = 1,
	SPECIES= 2,
	SPECIESID = 3,
	DISPLAYID = 4,
	ICON = 5,
	LEVEL = 6,
	MAXHEALTH = 7,
	CURRENTHEALTH = 8,
	PETTYPE = 9,
};

DEBUG_PET_INFO = {
	{
		{ "Sir Claws", "Lashtail Hatchling", 307, 38065, "INTERFACE\\ICONS\\ABILITY_HUNTER_PET_RAPTOR", 20, 100, 100, 1},
		{ "Azure Whelpling", "Azure Whelpling", 57, 6293, "INTERFACE\\ICONS\\INV_MISC_HEAD_DRAGON_BLUE", 19, 90, 90, 2},
		{ "Jacob the Seagull", "Rustberg Seagull", 271, 36499, "INTERFACE\\ICONS\\INV_MISC_SEAGULLPET_01", 18, 80, 80, 3},
	},
	{
		{ "Comrade Whiskers", "Giant Sewer Rat", 193, 27627, "INTERFACE\\ICONS\\INV_MISC_MONSTERTAIL_03", 22, 120, 120, 5},
		{ "Teldrassil Sproutling", "Teldrassil Sproutling", 204, 28482, "INTERFACE\\ICONS\\INV_MISC_HERB_03", 21, 110, 110, 4},
		{ "Vampiric Batling", "Vampiric Batling", 187, 4185, "INTERFACE\\ICONS\\ABILITY_HUNTER_PET_BAT", 23, 130, 130, 6},
	},
};

DEBUG_ABILITY_INDEX = {
	NAME = 1,
	TEXTURE = 2,
	USABLE = 3,
	CURRENTCOOLDOWN = 4,
	COOLDOWN = 5,
};

DEBUG_ABILITY_INFO = {
	{
		{
			{"Raptor Strike Of Furious Death", "INTERFACE\\ICONS\\SPELL_DEATHKNIGHT_THRASH_GHOUL", true, 0, 3},
			{"Mega Bite", "INTERFACE\\ICONS\\ABILITY_DRUID_FEROCIOUSBITE", true, 0, 0},
			{"Extinction", "INTERFACE\\ICONS\\SPELL_SHAMAN_THUNDERSTORM", false, 2, 3},
		},
		{
			{"Dragonbreath", "INTERFACE\\ICONS\\ABILITY_MAGE_FIRESTARTER", false, 2, 3},
			{"Lift-off", "INTERFACE\\ICONS\\ABILITY_DRUID_FLIGHTFORM", true, 0, 0},
			{"Burnt Earth", "INTERFACE\\ICONS\\INV_ELEMENTAL_PRIMAL_FIRE", true, 0, 0},
		},
		{
			{"Angry Peck", "INTERFACE\\ICONS\\SPELL_NATURE_GIFTOFTHEWATERSPIRIT", false, 2, 3},
			{"Steal Food", "INTERFACE\\ICONS\\INV_MISC_FOOD_11", true, 0, 0},
			{"Hurricane", "INTERFACE\\ICONS\\SPELL_NATURE_EARTHBIND", true, 0, 0},
		},
	},
	{
	},
	MASTER = {"Tanaris Chili Bomb", "INTERFACE\\ICONS\\INV_Misc_Food_19", true, 0, 0},
};

if not C_PetBattles then 
	C_PetBattles = {};
end

--[[
function C_PetBattles.GetName(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.NAME], DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.SPECIES];
end

function C_PetBattles.GetDisplayID(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.DISPLAYID];
end

function C_PetBattles.GetIcon(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.ICON];
end

function C_PetBattles.GetActivePet(petOwner)
	return petOwner == LE_BATTLE_PET_ALLY and PBDEBUG_ACTIVE_ALLY or PBDEBUG_ACTIVE_ENEMY;
end
]]

function C_PetBattles.GetLevel(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.LEVEL];
end

--[[
function C_PetBattles.GetHealth(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.CURRENTHEALTH];
end

function C_PetBattles.GetMaxHealth(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.MAXHEALTH];
end

function C_PetBattles.GetPetType(petOwner, petIndex)
	return DEBUG_PET_INFO[petOwner][petIndex][DEBUG_PET_INDEX.PETTYPE];
end

function C_PetBattles.GetAbilityInfo(petOwner, petIndex, abilityIndex)
	local petAbilities = DEBUG_ABILITY_INFO[petOwner][petIndex];
	if ( petAbilities ) then
		local ability = petAbilities[abilityIndex];
		if ( ability ) then
			return unpack(ability);
		end
	end
end

function C_PetBattles.IsPetSwapAvailable(petIndex)
	return true
end

function C_PetBattles.IsTrapAvailable()
	return true
end

function C_PetBattles.IsSkipAvailable()
	return false;
end
]]

function C_PetBattles.GetMasterAbilityInfo()
	return unpack(DEBUG_ABILITY_INFO.MASTER);
end

--[[
function C_PetBattles.IsWaitingOnOpponent()
	return not not (C_PetBattles.GetSelectedAction());
	--return PBDebugFrame.skippedTurn;
end

function C_PetBattles.GetTurnTimeInfo()
	if ( not PBDebugFrame.lastTurnTimer ) then
		return 0;
	else
		return PBDEBUG_TURN_TIME - (GetTime() - PBDebugFrame.lastTurnTimer), PBDEBUG_TURN_TIME;
	end
end

function C_PetBattles.GetNumPets(petOwner)
	return 3;
end

function C_PetBattles.ChangePet(petIndex)
	assert(petIndex > 0 and petIndex <= 3);
	PBDEBUG_ACTIVE_ALLY = petIndex;
	PBSignalEvent("PET_BATTLE_PET_CHANGED", LE_BATTLE_PET_ALLY);
end
]]

function C_PetBattles.GetXP(petIndex)
	return 25 * petIndex, 100;
end

function C_PetBattles.GetPetStats(petOwner, petIndex)
	return petOwner + petIndex * 1, petOwner + petIndex * 2, petOwner + petIndex * 3;
end

function C_PetBattles.GetNumPetTypes()
	return 10;
end

function C_PetBattles.GetAttackModifier(attackType, defenseType)
	local numTypes = C_PetBattles.GetNumPetTypes();
	local offset = (defenseType - attackType) % numTypes;

	if ( offset == 1 or offset == 2 ) then
		return 0.5;
	elseif ( offset == 3 or offset == 4 ) then
		return 2;
	else
		return 1;
	end
end

function C_PetBattles.IsInRoundPlayback()
	return PBDebugFrame.inPlayback;
end

--[[
function C_PetBattles.GetSelectedAction()
	return LE_BATTLE_PET_ACTION_ABILITY, 2;
end

function C_PetBattles.UseAbility(abilityIndex)
	print("Using ability "..abilityIndex);
end

function C_PetBattles.SkipTurn()
	C_PetBattles.ChangePet(C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY));
end

function C_PetBattles.UseTrap()
	print("Using trap");
end

function C_PetBattles.ForfeitGame()
	print("Forfeiting");
end
]]
