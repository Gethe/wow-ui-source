ItemButtonUtil = {};

ItemButtonUtil.ItemContextEnum = {
	Scrapping = 1,
	CleanseCorruption = 2,
	PickRuneforgeBaseItem = 3,
	ReplaceBonusTree = 4,
	SelectRuneforgeItem = 5,
	SelectRuneforgeUpgradeItem = 6,
	Soulbinds = 7,
	MythicKeystone = 8,
	UpgradableItem = 9,
	RunecarverScrapping = 10,
	ItemConversion = 11,
	ItemRecrafting = 12,
	JumpUpgradeTrack = 13,
};

ItemButtonUtil.ItemContextMatchResult = {
	Match = 1,
	Mismatch = 2,
	DoesNotApply = 3,
};

local ItemButtonUtilRegistry = CreateFromMixins(CallbackRegistryMixin);
ItemButtonUtilRegistry:OnLoad();
ItemButtonUtilRegistry:GenerateCallbackEvents(
{
    "ItemContextChanged",
});

ItemButtonUtil.Event = ItemButtonUtilRegistry.Event;

function ItemButtonUtil.RegisterCallback(...)
	return ItemButtonUtilRegistry:RegisterCallback(...);
end

function ItemButtonUtil.UnregisterCallback(...)
	return ItemButtonUtilRegistry:UnregisterCallback(...);
end

function ItemButtonUtil.TriggerEvent(...)
	return ItemButtonUtilRegistry:TriggerEvent(...);
end

function ItemButtonUtil.GetItemContext()
	if ScrappingMachineFrame and ScrappingMachineFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.Scrapping;
	elseif ItemInteractionFrame and ItemInteractionFrame:IsShown() and ItemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.CleanseCorruption then
		return ItemButtonUtil.ItemContextEnum.CleanseCorruption;
	elseif ItemInteractionFrame and ItemInteractionFrame:IsShown() and ItemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.RunecarverScrapping then
		return ItemButtonUtil.ItemContextEnum.RunecarverScrapping;
	elseif ItemInteractionFrame and ItemInteractionFrame:IsShown() and ItemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion then
		return ItemButtonUtil.ItemContextEnum.ItemConversion;
	elseif ProfessionsFrame and ProfessionsFrame.CraftingPage:IsVisible() and ProfessionsFrame:GetCurrentRecraftingRecipeID() ~= nil then
		return ItemButtonUtil.ItemContextEnum.ItemRecrafting;
	elseif RuneforgeFrame and RuneforgeFrame:IsShown() then
		return RuneforgeFrame:GetItemContext();
	elseif C_Spell.TargetSpellReplacesBonusTree() then
		return ItemButtonUtil.ItemContextEnum.ReplaceBonusTree;
	elseif SoulbindViewer and SoulbindViewer:IsShown() then
		return ItemButtonUtil.ItemContextEnum.Soulbinds;
	elseif ChallengesKeystoneFrame and ChallengesKeystoneFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.MythicKeystone;
	elseif ItemUpgradeFrame and ItemUpgradeFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.UpgradableItem;
	elseif C_Spell.TargetSpellJumpsUpgradeTrack() then
		return ItemButtonUtil.ItemContextEnum.JumpUpgradeTrack;
	end
	return nil;
end

function ItemButtonUtil.OpenAndFilterBags(frame)
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	local openedCount = OpenAllBagsMatchingContext(frame);
	frame.closeBagsOnHide = openedCount > 0;
end

function ItemButtonUtil.CloseFilteredBags(frame)
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	if frame.closeBagsOnHide then
		local forceUpdate = true;
		CloseAllBags(frame, forceUpdate);
		frame.closeBagsOnHide = nil;
	end
end

function ItemButtonUtil.HasItemContext()
	return ItemButtonUtil.GetItemContext() ~= nil;
end

function ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation)
	local itemContext = ItemButtonUtil.GetItemContext();
	if itemContext == nil then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end
	
	if C_Item.DoesItemExist(itemLocation) then
		-- Ideally we'd only have 1 context active at a time, perhaps with a priority system.
		if itemContext == ItemButtonUtil.ItemContextEnum.Scrapping then
			return C_Item.CanScrapItem(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.CleanseCorruption then 
			return C_Item.IsItemCorrupted(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.RunecarverScrapping then 
			return C_LegendaryCrafting.IsRuneforgeLegendary(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.ItemConversion then
			return C_Item.IsItemConvertibleAndValidForPlayer(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.PickRuneforgeBaseItem then 
			return C_LegendaryCrafting.IsValidRuneforgeBaseItem(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.ReplaceBonusTree then 
			return C_Item.DoesItemMatchBonusTreeReplacement(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeItem then 
			return RuneforgeUtil.IsUpgradeableRuneforgeLegendary(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeUpgradeItem then 
			return RuneforgeFrame:IsUpgradeItemValidForRuneforgeLegendary(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.Soulbinds then
			local CONDUIT_UPGRADE_ITEMS = { 184359, 187148, 187216, 190184, 190640, 190644, 190956 };
			if C_Item.IsItemConduit(itemLocation) or tContains(CONDUIT_UPGRADE_ITEMS, C_Item.GetItemID(itemLocation)) then
				return ItemButtonUtil.ItemContextMatchResult.Match;
			end
			return ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.MythicKeystone then
			if C_Item.IsItemKeystoneByID(C_Item.GetItemID(itemLocation)) and C_ChallengeMode.CanUseKeystoneInCurrentMap(itemLocation) then
				return ItemButtonUtil.ItemContextMatchResult.Match;
			end
			return ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.UpgradableItem then
			if C_ItemUpgrade.CanUpgradeItem(itemLocation) then
				return ItemButtonUtil.ItemContextMatchResult.Match;
			end
			return ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.ItemRecrafting then
			local itemGUID = C_Item.GetItemGUID(itemLocation);
			if itemGUID and C_TradeSkillUI.IsOriginalCraftRecipeLearned(itemGUID) then
				local recipeID = ProfessionsFrame:GetCurrentRecraftingRecipeID();
				if recipeID and C_TradeSkillUI.DoesRecraftingRecipeAcceptItem(itemLocation, recipeID) then
					return ItemButtonUtil.ItemContextMatchResult.Match;
				end
			end
			return ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.JumpUpgradeTrack then
			return C_Item.DoesItemMatchTrackJump(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		else
			return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
		end
	end
	
	return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
end

function ItemButtonUtil.GetItemContextMatchResultForContainer(bagID)
	if ItemButtonUtil.GetItemContext() == nil then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end
	
	local itemLocation = ItemLocation:CreateEmpty();
	for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
		itemLocation:SetBagAndSlot(bagID, slotIndex);
		if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
			return ItemButtonUtil.ItemContextMatchResult.Match;
		end
	end
	
	return ItemButtonUtil.ItemContextMatchResult.Mismatch;
end

ItemUtil = {};
function ItemUtil.GetItemDetails(itemLink, quantity, isCurrency, lootSource)
	local itemName, itemRarity, itemTexture, _;
	if isCurrency then
		local currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(itemLink);
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink);
		itemName = currencyInfo.name;
		itemTexture = currencyInfo.iconFileID;
		itemRarity = currencyInfo.quality;
		itemName, itemTexture, quantity, itemRarity = CurrencyContainerUtil.GetCurrencyContainerInfoForAlert(currencyID, quantity, itemName, itemTexture, itemRarity);
		if lootSource == LOOT_SOURCE_GARRISON_CACHE then
			itemName = format(GARRISON_RESOURCES_LOOT, quantity);
		elseif quantity > 1 then
			itemName = format(CURRENCY_QUANTITY_TEMPLATE, quantity, itemName);
		end

		return itemName, itemTexture, quantity, itemRarity, itemLink;
	else
		itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemLink);
		return itemName, itemTexture, quantity, itemRarity, itemLink;
	end
end

function ItemUtil.GetItemHyperlink(itemID)
	return select(2, C_Item.GetItemInfo(itemID));
end

function ItemUtil.PickupBagItem(itemLocation)
	local bag, slot = itemLocation:GetBagAndSlot();
	if bag and slot then
		C_Container.PickupContainerItem(bag, slot);
	end
end

function ItemUtil.GetCraftingReagentCount(itemID)
	local includeBank = true;
	local includeUses = false;
	local includeReagentBank = true;
	return C_Item.GetItemCount(itemID, includeBank, includeUses, includeReagentBank);
end

function ItemUtil.IterateBagSlots(bag, callback)
	-- Only includes the backpack and held bag slots.
	for slot = 1, ContainerFrame_GetContainerNumSlots(bag) do
		local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
		if C_Item.DoesItemExist(itemLocation) then
			if callback(itemLocation) then
				return true;
			end
		end
	end
	return false;
end

function ItemUtil.IterateInventorySlots(firstSlot, lastSlot, callback)
	for slot = firstSlot, lastSlot do
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(slot);
		if C_Item.DoesItemExist(itemLocation) then
			if callback(itemLocation) then
				return;
			end
		end
	end
end

function ItemUtil.IteratePlayerInventory(callback)
	-- Only includes the backpack and held bag slots.
	for bag = Enum.BagIndex.Backpack, NUM_TOTAL_BAG_FRAMES do
		if ItemUtil.IterateBagSlots(bag, callback) then
			return true;
		end
	end

	return false;
end

function ItemUtil.IteratePlayerInventoryAndEquipment(callback)
	local found = ItemUtil.IteratePlayerInventory(callback);
	if not found then
		ItemUtil.IterateInventorySlots(INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, callback);
	end
end

function ItemUtil.FilterOwnedItems(itemIDs)
	local found = {};
	ItemUtil.IteratePlayerInventory(function(itemLocation)
		local itemID = C_Item.GetItemID(itemLocation);
		TableUtil.TrySet(found, itemID);
	end);

	local filtered = {};
	for index, itemID in ipairs(itemIDs) do
		if found[itemID] then
			table.insert(filtered, itemID);
		end
	end
	return filtered;
end

function ItemUtil.DoesAnyItemSlotMatchItemContext()
	local matchFound = false;
	local function ItemSlotMatchItemContextCallback(itemLocation)
		-- If we found a match in our inventory, we don't need to check equipment
		matchFound = matchFound or ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match;
		return matchFound;
	end

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemSlotMatchItemContextCallback);

	return matchFound;
end

function ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID)
	return CreateAndInitFromMixin(ItemTransmogInfoMixin, appearanceID, secondaryAppearanceID, illusionID);
end

function ItemUtil.TransformItemIDsToItems(itemIDs)
	local items = {};
	for index, itemID in ipairs(itemIDs) do
		table.insert(items, Item:CreateFromItemID(itemID));
	end
	return items;
end

function ItemUtil.TransformItemLocationsToItems(itemLocations)
	local items = {};
	for index, itemLocation in ipairs(itemLocations) do
		table.insert(items, Item:CreateFromItemLocation(itemLocation));
	end
	return items;
end

function ItemUtil.TransformItemGUIDsToItems(itemGUIDs)
	local items = {};
	for index, itemGUID in ipairs(itemGUIDs) do
		local item = Item:CreateFromItemGUID(itemGUID);
		table.insert(items, item);
	end
	return items;
end

function ItemUtil.TransformItemLocationItemsToGUIDItems(items)
	local items = {};
	for index, itemLocation in ipairs(itemLocations) do
		table.insert(items, Item:CreateFromItemLocation(itemLocation));
	end
	return items;
end

ItemTransmogInfoMixin = {};

function ItemTransmogInfoMixin:Init(appearanceID, secondaryAppearanceID, illusionID)
	self.appearanceID = appearanceID;
	self.secondaryAppearanceID = secondaryAppearanceID or Constants.Transmog.NoTransmogID;
	self.illusionID = illusionID or Constants.Transmog.NoTransmogID;
end

function ItemTransmogInfoMixin:IsEqual(itemTransmogInfo)
	if not itemTransmogInfo then
		return false;
	end
	return self.appearanceID == itemTransmogInfo.appearanceID and self.secondaryAppearanceID == itemTransmogInfo.secondaryAppearanceID and self.illusionID == itemTransmogInfo.illusionID;
end

function ItemTransmogInfoMixin:Clear()
	self.appearanceID = Constants.Transmog.NoTransmogID;
	self.secondaryAppearanceID = Constants.Transmog.NoTransmogID;
	self.illusionID = Constants.Transmog.NoTransmogID;
end

-- There is no slot info in ItemTransmogInfo so the following 3 MainHand functions must be used with correct itemTransmogInfo at call site
function ItemTransmogInfoMixin:ConfigureSecondaryForMainHand(isLegionArtifact)
	if isLegionArtifact then
		self.secondaryAppearanceID = Constants.Transmog.MainHandTransmogIsPairedWeapon;
	else
		self.secondaryAppearanceID = Constants.Transmog.MainHandTransmogIsIndividualWeapon;
	end
end

function ItemTransmogInfoMixin:IsMainHandIndividualWeapon()
	return self.secondaryAppearanceID == Constants.Transmog.MainHandTransmogIsIndividualWeapon;
end

function ItemTransmogInfoMixin:IsMainHandPairedWeapon()
	-- paired weapon can be value Constants.Transmog.MainHandTransmogIsPairedWeapon or greater
	return not self:IsMainHandIndividualWeapon();
end
