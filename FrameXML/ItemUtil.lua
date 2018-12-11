
ItemButtonUtil = {};

ItemButtonUtil.ItemContextEnum = {
	Scrapping = 1,
};

function ItemButtonUtil.GetItemContext()
	if ScrappingMachineFrame and ScrappingMachineFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.Scrapping;
	end
	
	return nil;
end

function ItemButtonUtil.HasItemContext()
	return ItemButtonUtil.GetItemContext() ~= nil;
end
