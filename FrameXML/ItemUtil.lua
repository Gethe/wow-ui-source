
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
	elseif ItemInteractionFrame and ItemInteractionFrame:IsShown() and ItemInteractionFrame:GetFrameType() == Enum.ItemInteractionFrameType.CleanseCorruption then
		return ItemButtonUtil.ItemContextEnum.CleanseCorruption;
	elseif RuneforgeFrame and RuneforgeFrame:IsShown() then
		return RuneforgeFrame:GetItemContext();
	elseif TargetSpellReplacesBonusTree() then
		return ItemButtonUtil.ItemContextEnum.ReplaceBonusTree;
	elseif SoulbindViewer and SoulbindViewer:IsShown() then
		return ItemButtonUtil.ItemContextEnum.Soulbinds;
	elseif ChallengesKeystoneFrame and ChallengesKeystoneFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.MythicKeystone;
	elseif ItemUpgradeFrame and ItemUpgradeFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.UpgradableItem;
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
		elseif itemContext == ItemButtonUtil.ItemContextEnum.PickRuneforgeBaseItem then 
			return C_LegendaryCrafting.IsValidRuneforgeBaseItem(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.ReplaceBonusTree then 
			return C_Item.DoesItemMatchBonusTreeReplacement(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeItem then 
			return RuneforgeUtil.IsUpgradeableRuneforgeLegendary(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.SelectRuneforgeUpgradeItem then 
			return RuneforgeFrame:IsUpgradeItemValidForRuneforgeLegendary(itemLocation) and ItemButtonUtil.ItemContextMatchResult.Match or ItemButtonUtil.ItemContextMatchResult.Mismatch;
		elseif itemContext == ItemButtonUtil.ItemContextEnum.Soulbinds then
			local CONDUIT_UPGRADE_ITEMS = { 184359, 187148, 187216 };
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
	if (isCurrency) then
		local currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(itemLink);
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink);
		itemName = currencyInfo.name;
		itemTexture = currencyInfo.iconFileID;
		itemRarity = currencyInfo.quality;
		itemName, itemTexture, quantity, itemRarity = CurrencyContainerUtil.GetCurrencyContainerInfoForAlert(currencyID, quantity, itemName, itemTexture, itemRarity);
		if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
			itemName = format(GARRISON_RESOURCES_LOOT, quantity);
		elseif (quantity > 1) then
			itemName = format(CURRENCY_QUANTITY_TEMPLATE, quantity, itemName);
		end

		return itemName, itemTexture, quantity, itemRarity, itemLink;
	else
		itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
		return itemName, itemTexture, quantity, itemRarity, itemLink;
	end
end

function ItemUtil.PickupBagItem(itemLocation)
	local bag, slot = itemLocation:GetBagAndSlot();
	if bag and slot then
		PickupContainerItem(bag, slot);
	end
end

function ItemUtil.GetOptionalReagentCount(itemID)
	local includeBank = true;
	local includeUses = false;
	local includeReagentBank = true;
	return GetItemCount(itemID, includeBank, includeUses, includeReagentBank);
end

function ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID)
	return CreateAndInitFromMixin(ItemTransmogInfoMixin, appearanceID, secondaryAppearanceID, illusionID);
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