
ItemButtonUtil = {};

ItemButtonUtil.ItemContextEnum = {
	Scrapping = 1,
};

ItemButtonUtil.ItemContextMatchResult = {
	Match = 1,
	Mismatch = 2,
	DoesNotApply = 3,
};

local ItemButtonUtilRegistry = CreateFromMixins(CallbackRegistryBaseMixin);
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
	end
	
	return nil;
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

