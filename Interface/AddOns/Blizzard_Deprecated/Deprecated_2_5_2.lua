
-- These are functions are deprecated, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Item class/subclass enum conversions
do
	LE_ITEM_CLASS_CONSUMABLE = Enum.ItemClass.Consumable;
	LE_ITEM_CLASS_CONTAINER = Enum.ItemClass.Container;
	LE_ITEM_CLASS_WEAPON = Enum.ItemClass.Weapon;
	LE_ITEM_CLASS_GEM = Enum.ItemClass.Gem;
	LE_ITEM_CLASS_ARMOR = Enum.ItemClass.Armor;
	LE_ITEM_CLASS_REAGENT = Enum.ItemClass.Reagent;
	LE_ITEM_CLASS_PROJECTILE = Enum.ItemClass.Projectile;
	LE_ITEM_CLASS_TRADEGOODS = Enum.ItemClass.Tradegoods;
	LE_ITEM_CLASS_ITEM_ENHANCEMENT = Enum.ItemClass.ItemEnhancement;
	LE_ITEM_CLASS_RECIPE = Enum.ItemClass.Recipe;
	LE_ITEM_CLASS_QUIVER = Enum.ItemClass.Quiver;
	LE_ITEM_CLASS_QUESTITEM = Enum.ItemClass.Questitem;
	LE_ITEM_CLASS_KEY = Enum.ItemClass.Key;
	LE_ITEM_CLASS_MISCELLANEOUS = Enum.ItemClass.Miscellaneous;
	LE_ITEM_CLASS_GLYPH = Enum.ItemClass.Glyph;
	LE_ITEM_CLASS_BATTLEPET = Enum.ItemClass.Battlepet;
	LE_ITEM_CLASS_WOW_TOKEN = Enum.ItemClass.WoWToken;

	LE_ITEM_WEAPON_AXE1H = Enum.ItemWeaponSubclass.Axe1H;
	LE_ITEM_WEAPON_AXE2H = Enum.ItemWeaponSubclass.Axe2H;
	LE_ITEM_WEAPON_BOWS = Enum.ItemWeaponSubclass.Bows;
	LE_ITEM_WEAPON_GUNS = Enum.ItemWeaponSubclass.Guns;
	LE_ITEM_WEAPON_MACE1H = Enum.ItemWeaponSubclass.Mace1H;
	LE_ITEM_WEAPON_MACE2H = Enum.ItemWeaponSubclass.Mace2H;
	LE_ITEM_WEAPON_POLEARM = Enum.ItemWeaponSubclass.Polearm;
	LE_ITEM_WEAPON_SWORD1H = Enum.ItemWeaponSubclass.Sword1H;
	LE_ITEM_WEAPON_SWORD2H = Enum.ItemWeaponSubclass.Sword2H;
	LE_ITEM_WEAPON_WARGLAIVE = Enum.ItemWeaponSubclass.Warglaive;
	LE_ITEM_WEAPON_STAFF = Enum.ItemWeaponSubclass.Staff;
	LE_ITEM_WEAPON_BEARCLAW = Enum.ItemWeaponSubclass.Bearclaw;
	LE_ITEM_WEAPON_CATCLAW = Enum.ItemWeaponSubclass.Catclaw;
	LE_ITEM_WEAPON_UNARMED = Enum.ItemWeaponSubclass.Unarmed;
	LE_ITEM_WEAPON_GENERIC = Enum.ItemWeaponSubclass.Generic;
	LE_ITEM_WEAPON_DAGGER = Enum.ItemWeaponSubclass.Dagger;
	LE_ITEM_WEAPON_THROWN = Enum.ItemWeaponSubclass.Thrown;
	LE_ITEM_WEAPON_OBSOLETE3 = Enum.ItemWeaponSubclass.Obsolete3;
	LE_ITEM_WEAPON_CROSSBOW = Enum.ItemWeaponSubclass.Crossbow;
	LE_ITEM_WEAPON_WAND = Enum.ItemWeaponSubclass.Wand;
	LE_ITEM_WEAPON_FISHINGPOLE = Enum.ItemWeaponSubclass.Fishingpole;

	LE_ITEM_ARMOR_GENERIC = Enum.ItemArmorSubclass.Generic;
	LE_ITEM_ARMOR_CLOTH = Enum.ItemArmorSubclass.Cloth;
	LE_ITEM_ARMOR_LEATHER = Enum.ItemArmorSubclass.Leather;
	LE_ITEM_ARMOR_MAIL = Enum.ItemArmorSubclass.Mail;
	LE_ITEM_ARMOR_PLATE = Enum.ItemArmorSubclass.Plate;
	LE_ITEM_ARMOR_COSMETIC = Enum.ItemArmorSubclass.Cosmetic;
	LE_ITEM_ARMOR_SHIELD = Enum.ItemArmorSubclass.Shield;
	LE_ITEM_ARMOR_LIBRAM = Enum.ItemArmorSubclass.Libram;
	LE_ITEM_ARMOR_IDOL = Enum.ItemArmorSubclass.Idol;
	LE_ITEM_ARMOR_TOTEM = Enum.ItemArmorSubclass.Totem;
	LE_ITEM_ARMOR_SIGIL = Enum.ItemArmorSubclass.Sigil;
	LE_ITEM_ARMOR_RELIC = Enum.ItemArmorSubclass.Relic;

	LE_ITEM_GEM_INTELLECT = Enum.ItemGemSubclass.Intellect;
	LE_ITEM_GEM_AGILITY = Enum.ItemGemSubclass.Agility;
	LE_ITEM_GEM_STRENGTH = Enum.ItemGemSubclass.Strength;
	LE_ITEM_GEM_STAMINA = Enum.ItemGemSubclass.Stamina;
	LE_ITEM_GEM_SPIRIT = Enum.ItemGemSubclass.Spirit;
	LE_ITEM_GEM_CRITICALSTRIKE = Enum.ItemGemSubclass.Criticalstrike;
	LE_ITEM_GEM_MASTERY = Enum.ItemGemSubclass.Mastery;
	LE_ITEM_GEM_HASTE = Enum.ItemGemSubclass.Haste;
	LE_ITEM_GEM_VERSATILITY = Enum.ItemGemSubclass.Versatility;
	LE_ITEM_GEM_MULTIPLESTATS = Enum.ItemGemSubclass.Multiplestats;
	LE_ITEM_GEM_ARTIFACTRELIC = Enum.ItemGemSubclass.Artifactrelic;

	LE_ITEM_RECIPE_BOOK = Enum.ItemRecipeSubclass.Book;
	LE_ITEM_RECIPE_LEATHERWORKING = Enum.ItemRecipeSubclass.Leatherworking;
	LE_ITEM_RECIPE_TAILORING = Enum.ItemRecipeSubclass.Tailoring;
	LE_ITEM_RECIPE_ENGINEERING = Enum.ItemRecipeSubclass.Engineering;
	LE_ITEM_RECIPE_BLACKSMITHING = Enum.ItemRecipeSubclass.Blacksmithing;
	LE_ITEM_RECIPE_COOKING = Enum.ItemRecipeSubclass.Cooking;
	LE_ITEM_RECIPE_ALCHEMY = Enum.ItemRecipeSubclass.Alchemy;
	LE_ITEM_RECIPE_FIRST_AID = Enum.ItemRecipeSubclass.FirstAid;
	LE_ITEM_RECIPE_ENCHANTING = Enum.ItemRecipeSubclass.Enchanting;
	LE_ITEM_RECIPE_FISHING = Enum.ItemRecipeSubclass.Fishing;
	LE_ITEM_RECIPE_JEWELCRAFTING = Enum.ItemRecipeSubclass.Jewelcrafting;
	LE_ITEM_RECIPE_INSCRIPTION = Enum.ItemRecipeSubclass.Inscription;

	LE_ITEM_MISCELLANEOUS_JUNK = Enum.ItemMiscellaneousSubclass.Junk;
	LE_ITEM_MISCELLANEOUS_REAGENT = Enum.ItemMiscellaneousSubclass.Reagent;
	LE_ITEM_MISCELLANEOUS_COMPANION_PET = Enum.ItemMiscellaneousSubclass.CompanionPet;
	LE_ITEM_MISCELLANEOUS_HOLIDAY = Enum.ItemMiscellaneousSubclass.Holiday;
	LE_ITEM_MISCELLANEOUS_OTHER = Enum.ItemMiscellaneousSubclass.Other;
	LE_ITEM_MISCELLANEOUS_MOUNT = Enum.ItemMiscellaneousSubclass.Mount;
	LE_ITEM_MISCELLANEOUS_MOUNT_EQUIPMENT = Enum.ItemMiscellaneousSubclass.MountEquipment;
end