

local function GenerateAccountStoreCategoryInfo(cardTemplate, maxCards)
	return {
		cardTemplate = cardTemplate,
		maxCards = maxCards
	};
end

local AccountStoreCategoryToInfo = {
	[Enum.AccountStoreCategoryType.Creature] = GenerateAccountStoreCategoryInfo("AccountStoreCreatureCardTemplate", 4),
	[Enum.AccountStoreCategoryType.TransmogSet] = GenerateAccountStoreCategoryInfo("AccountStoreTransmogSetCardTemplate", 2),
	[Enum.AccountStoreCategoryType.Mount] = GenerateAccountStoreCategoryInfo("AccountStoreMountCardTemplate", 1),
	[Enum.AccountStoreCategoryType.Icon] = GenerateAccountStoreCategoryInfo("AccountStoreIconCardTemplate", 4),
};


AccountStoreItemRackMixin = {};

function AccountStoreItemRackMixin:SetCategoryType(categoryType)
	local categoryInfo = AccountStoreCategoryToInfo[categoryType];
	self.cardPool = CreateFramePool("BUTTON", self, categoryInfo.cardTemplate);
	self.maxCards = categoryInfo.maxCards;
end

function AccountStoreItemRackMixin:SetItems(items)
	self.items = items;
	self:Refresh();
end

function AccountStoreItemRackMixin:Refresh()
	self.cardPool:ReleaseAll();

	local items = self.items;
	local function AccountStoreItemRackFactoryFunction(index)
		local card = self.cardPool:Acquire();
		card:SetItemID(items[index]);
		return card;
	end

	local anchorPoint = (self.maxCards == 1) and "TOP" or "TOPLEFT";
	local initialAnchor =  AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint);
	local stride = 2;
	local paddingX = 5;
	local paddingY = 5;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(AccountStoreItemRackFactoryFunction, math.min(#items, self:GetMaxCards()), initialAnchor, layout);

	for card in self.cardPool:EnumerateActive() do
		card:Show();
	end
end

function AccountStoreItemRackMixin:GetMaxCards()
	return self.maxCards;
end
