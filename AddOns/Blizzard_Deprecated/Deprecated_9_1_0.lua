
-- These are functions that were deprecated in 9.1.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- HasAlternateForm has been moved and renamed.
do
	HasAlternateForm = C_PlayerInfo.GetAlternateFormInfo;
end

-- Transmog API Update
do
	C_TransmogCollection.GetIllusionSourceInfo = function(illusionID)
		local illusionInfo = C_TransmogCollection.GetIllusionInfo(illusionID);
		local name, hyperlink = C_TransmogCollection.GetIllusionStrings(illusionID);
		if illusionInfo then
			return illusionInfo.visualID, name, hyperlink, illusionInfo.icon;
		end
	end
	C_TransmogCollection.GetIllusionFallbackWeaponSource = function()
		return C_TransmogCollection.GetFallbackWeaponAppearance();
	end
	function WardrobeCollectionFrameModel_GetSourceTooltipInfo(source)
		local name, nameColor = WardrobeCollectionFrame:GetAppearanceNameTextAndColor(source);
		local sourceText, sourceColor = WardrobeCollectionFrame:GetAppearanceSourceTextAndColor(source);		
		return name, nameColor, sourceText, sourceColor;
	end
	
	function WardrobeCollectionFrame_SetContainer(...)
		WardrobeCollectionFrame:SetContainer(...);
	end
	function WardrobeCollectionFrame_SetTab(...)
		WardrobeCollectionFrame:SetTab(...);
	end
	function WardrobeCollectionFrame_OpenTransmogLink(...)
		WardrobeCollectionFrame:OpenTransmogLink(...)
	end
	function WardrobeCollectionFrame_SetAppearanceTooltip(...)
		WardrobeCollectionFrame:SetAppearanceTooltip(...);
	end
	function WardrobeCollectionFrame_UpdateProgressBar(...)
		WardrobeCollectionFrame:UpdateProgressBar(...);
	end
	function WardrobeCollectionFrame_ClearSearch(...)
		WardrobeCollectionFrame:ClearSearch(...);
	end	
	function WardrobeCollectionFrame_GetDefaultSourceIndex(...)
		return CollectionWardrobeUtil.GetDefaultSourceIndex(...);
	end
	function WardrobeCollectionFrame_SortSources(...)
		return CollectionWardrobeUtil.SortSources(...);
	end
	function WardrobeCollectionFrame_GetSortedAppearanceSources(...)
		return CollectionWardrobeUtil.GetSortedAppearanceSources(...);
	end
	function WardrobeUtils_GetValidIndexForNumSources(...)
		return CollectionWardrobeUtil.GetValidIndexForNumSources(...);
	end	
	function WardrobeCollectionFrame_GetWeaponInfoForEnchant(...)
		return WardrobeCollectionFrame.ItemsCollectionFrame:GetWeaponInfoForEnchant(...);
	end	
	function WardrobeUtils_IsCategoryRanged(...)
		return TransmogUtil.IsCategoryRangedWeapon(...);
	end	
	function WardrobeUtils_IsCategoryLegionArtifact(...)
		return TransmogUtil.IsCategoryLegionArtifact(...);
	end	
	function WardrobeFrame_IsAtTransmogrifier(...)
		return C_Transmog.IsAtTransmogNPC();
	end
	-- transmogrify	
	C_Transmog.GetCost = function()
		local cost = C_Transmog.GetApplyCost();
		if not cost then
			return 0, 0;
		else
			return cost, 1;
		end
	end
	LE_TRANSMOG_SEARCH_TYPE_ITEMS = Enum.TransmogSearchType.Items;
	LE_TRANSMOG_SEARCH_TYPE_BASE_SETS = Enum.TransmogSearchType.BaseSets;
	LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS = Enum.TransmogSearchType.UsableSets;
	-- collection
	C_TransmogCollection.GetShowMissingSourceInItemTooltips = function()
		return GetCVarBool("missingTransmogSourceInItemTooltips");
	end
	C_TransmogCollection.SetShowMissingSourceInItemTooltips = function(show)
		SetCVarBool("missingTransmogSourceInItemTooltips", show and true or false);
	end
	C_TransmogCollection.CanSetFavoriteInCategory = function()
		return true;
	end
	-- sets
	C_TransmogSets.GetSetSources = function(setID)
		local setAppearances = C_TransmogSets.GetSetPrimaryAppearances(setID);
		if not setAppearances then
			return nil;
		end
		local lookupTable = { };
		for i, appearanceInfo in ipairs(setAppearances) do
			lookupTable[appearanceInfo.appearanceID] = appearanceInfo.collected;
		end
		return lookupTable;
	end	
end

-- Quest log API conversion
do
	GetQuestLogPortraitGiver = C_QuestLog.GetQuestLogPortraitGiver;
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

-- Player Choice API Update
do
	-- Use GetCurrentPlayerChoiceInfo going forward, that returns everything you need in one call
	C_PlayerChoice.GetPlayerChoiceInfo = function()
		local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
		
		if choiceInfo then
			choiceInfo.numOptions = 0;

			for _, optionInfo in ipairs(choiceInfo.options) do
				choiceInfo.numOptions = choiceInfo.numOptions + #optionInfo.buttons;
			end
		end

		return choiceInfo;
	end

	-- Note that with this change, GetPlayerChoiceOptionInfo returns SLIGHTLY different things back for options that are part of a groupID than it used to
	-- Previously each of those grouped options would return their own descriptions, header, etc. 
	-- This data was mostly ignored for grouped options that were not the first in their group, because all we needed was a few pieces of data we used to set up the button
	-- After this change, GetPlayerChoiceOptionInfo will return back the same description, header, etc, for all options within a group, but with different button data for each
	C_PlayerChoice.GetPlayerChoiceOptionInfo = function(index)
		local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
		
		if choiceInfo then
			local processedButtons = 0;

			for optionIndex, optionInfo in ipairs(choiceInfo.options) do
				local buttonIndex = index - processedButtons;
				if buttonIndex <= #optionInfo.buttons then
					-- ok index is in this set of buttons, so get the button info
					local buttonInfo = optionInfo.buttons[buttonIndex];

					-- And add the stuff to optionInfo that was moved to buttonInfo
					optionInfo.responseIdentifier = buttonInfo.id;
					optionInfo.buttonText = buttonInfo.text;
					optionInfo.buttonTooltip = buttonInfo.tooltip;
					optionInfo.confirmation = buttonInfo.confirmation;
					optionInfo.rewardQuestID = buttonInfo.rewardQuestID;
					optionInfo.soundKitID = buttonInfo.soundKitID;
					optionInfo.disabledButton = buttonInfo.disabled;
					optionInfo.hasRewards = (optionInfo.hasRewards and buttonIndex == 1);

					-- Then if this options had more than 1 button use the optionIndex as the groupID
					if #optionInfo.buttons > 1 then
						optionInfo.groupID = optionIndex;
					end

					-- And then return optionInfo
					return optionInfo;
				else
					processedButtons = processedButtons + #optionInfo.buttons;
				end
			end
		end

		return nil;
	end

	-- Use GetCurrentPlayerChoiceInfo going forward, that returns everything you need in one call
	C_PlayerChoice.GetPlayerChoiceRewardInfo = function(index)
		local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
		
		if choiceInfo then
			local optionInfo = choiceInfo.options[index];
			if optionInfo and optionInfo.hasRewards then
				local rewardInfo = optionInfo.rewardInfo;

				-- Add in stuff that was removed
				for itemIndex, itemRewardInfo in ipairs(rewardInfo.itemRewards) do
					local _, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(itemRewardInfo.itemId);
					itemRewardInfo.itemLink = itemLink;
					itemRewardInfo.quality = itemQuality;
					itemRewardInfo.textureFileId = itemIcon;
				end

				return rewardInfo;
			end
		end

		return nil;
	end

	SendPlayerChoiceResponse = C_PlayerChoice.SendPlayerChoiceResponse;
	ClosePlayerChoice = function() HideUIPanel(PlayerChoiceFrame) end;
end

-- Runecarving updates
do
	C_LegendaryCrafting.GetRuneforgePowersByClassAndSpec = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant;
end

-- Pet battle enum conversions
do
	LE_BATTLE_PET_WEATHER = Enum.BattlePetOwner.Weather;
	LE_BATTLE_PET_ALLY = Enum.BattlePetOwner.Ally;
	LE_BATTLE_PET_ENEMY = Enum.BattlePetOwner.Enemy;

	LE_BATTLE_PET_ACTION_NONE = Enum.BattlePetAction.None;
	LE_BATTLE_PET_ACTION_ABILITY = Enum.BattlePetAction.Ability;
	LE_BATTLE_PET_ACTION_SWITCH_PET = Enum.BattlePetAction.SwitchPet;
	LE_BATTLE_PET_ACTION_TRAP = Enum.BattlePetAction.Trap;
	LE_BATTLE_PET_ACTION_SKIP = Enum.BattlePetAction.Skip;

	LE_PET_BATTLE_STATE_CREATED = Enum.PetBattleState.Created;
	LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE = Enum.PetBattleState.WaitingPreBattle;
	LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS = Enum.PetBattleState.RoundInProgress;
	LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS = Enum.PetBattleState.WaitingForFrontPets;
	LE_PET_BATTLE_STATE_CREATED_FAILED = Enum.PetBattleState.CreatedFailed;
	LE_PET_BATTLE_STATE_FINAL_ROUND = Enum.PetBattleState.FinalRound;
	LE_PET_BATTLE_STATE_FINISHED = Enum.PetBattleState.Finished;
end

-- Dressing room updates
do
	IsDressableItem = C_Item.IsDressableItemByID;
end