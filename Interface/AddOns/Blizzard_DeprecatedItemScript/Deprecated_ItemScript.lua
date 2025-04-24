-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	GetItemQualityColor = C_Item.GetItemQualityColor;
	GetItemInfoInstant = C_Item.GetItemInfoInstant;
	GetItemSetInfo = C_Item.GetItemSetInfo;
	GetItemChildInfo = C_Item.GetItemChildInfo;
	DoesItemContainSpec = C_Item.DoesItemContainSpec;
	GetItemGem = C_Item.GetItemGem;
	GetItemCreationContext = C_Item.GetItemCreationContext;
	GetItemIcon = C_Item.GetItemIconByID;
	GetItemFamily = C_Item.GetItemFamily;
	GetItemSpell = C_Item.GetItemSpell;
	IsArtifactPowerItem = C_Item.IsArtifactPowerItem;
	IsCurrentItem = C_Item.IsCurrentItem;
	IsUsableItem = C_Item.IsUsableItem;
	IsHelpfulItem = C_Item.IsHelpfulItem;
	IsHarmfulItem = C_Item.IsHarmfulItem;
	IsConsumableItem = C_Item.IsConsumableItem;
	IsEquippableItem = C_Item.IsEquippableItem;
	IsEquippedItem = C_Item.IsEquippedItem;
	IsEquippedItemType = C_Item.IsEquippedItemType;
	ItemHasRange = C_Item.ItemHasRange;
	IsItemInRange = C_Item.IsItemInRange;
	GetItemClassInfo = C_Item.GetItemClassInfo;
	GetItemInventorySlotInfo = C_Item.GetItemInventorySlotInfo;
	BindEnchant = C_Item.BindEnchant;
	ActionBindsItem = C_Item.ActionBindsItem;
	ReplaceEnchant = C_Item.ReplaceEnchant;
	ReplaceTradeEnchant = C_Item.ReplaceTradeEnchant;
	ConfirmBindOnUse = C_Item.ConfirmBindOnUse;
	ConfirmOnUse = C_Item.ConfirmOnUse;
	ConfirmNoRefundOnUse = C_Item.ConfirmNoRefundOnUse;
	DropItemOnUnit = C_Item.DropItemOnUnit;
	EndBoundTradeable = C_Item.EndBoundTradeable;
	EndRefund = C_Item.EndRefund;
	GetItemInfo = C_Item.GetItemInfo;
	GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo;
	GetItemSpecInfo = C_Item.GetItemSpecInfo;
	GetItemUniqueness = C_Item.GetItemUniqueness;
	GetItemCount = C_Item.GetItemCount;
	PickupItem = C_Item.PickupItem;
	GetItemSubClassInfo = C_Item.GetItemSubClassInfo;
	UseItemByName = C_Item.UseItemByName;
	EquipItemByName = C_Item.EquipItemByName;
	ReplaceTradeskillEnchant = C_Item.ReplaceTradeskillEnchant;
	GetItemCooldown = C_Item.GetItemCooldown;
	IsCorruptedItem = C_Item.IsCorruptedItem;
	IsCosmeticItem = C_Item.IsCosmeticItem;
    IsDressableItem = C_Item.IsDressableItem;
end