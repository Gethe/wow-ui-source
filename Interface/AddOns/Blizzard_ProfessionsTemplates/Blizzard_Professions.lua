
Professions = {};

Professions.ReagentInputMode = EnumUtil.MakeEnum("Fixed", "Quality", "Any");
Professions.ReagentContents = EnumUtil.MakeEnum("None", "Partial", "All");
Professions.ProfessionType = EnumUtil.MakeEnum("Crafting", "Gathering");

-- See native CraftingReagent
function Professions.CreateCraftingReagent(itemID, currencyID)
	assert(itemID ~= nil or currencyID ~= nil);
	return {itemID = itemID, currencyID = currencyID};
end

function Professions.CraftingReagentMatches(reagent1, reagent2)
	local function Matches(lhs, rhs)
		return lhs and lhs > 0 and (lhs == rhs);
	end

	return Matches(reagent1.itemID, reagent2.itemID) or 
		Matches(reagent1.currencyID, reagent2.currencyID);
end

function Professions.CreateCraftingReagentByItemID(itemID)
	return Professions.CreateCraftingReagent(itemID, nil);
end

function Professions.CreateCraftingReagentByCurrencyID(currencyID)
	return Professions.CreateCraftingReagent(nil, currencyID);
end


-- See native CraftingReagentInfo
function Professions.CreateCraftingReagentInfo(itemID, dataSlotIndex, quantity)
	assert(itemID ~= nil and dataSlotIndex ~= nil and quantity ~= nil);
	return {itemID = itemID, dataSlotIndex = dataSlotIndex, quantity = quantity };
end

function Professions.CreateCraftingReagentInfoBonusTbl(...)
	local tbls = {};
	for index = 1, select('#', ...) do
		local itemID = select(index, ...);
		local quantity = 1;
		table.insert(tbls, Professions.CreateCraftingReagentInfo(itemID, index, quantity));
	end
	return tbls;
end

function Professions.ExtractItemIDsFromCraftingReagents(reagents)
	local tbl = {};
	for index, reagent in ipairs(reagents) do
		local itemID = reagent.itemID;
		if itemID then
			table.insert(tbl, itemID);
		end
	end
	return tbl;
end

function Professions.AddCommonOptionalTooltipInfo(item, tooltip, recipeID, recraftItemGUID)
	local craftingReagents = Professions.CreateCraftingReagentInfoBonusTbl(item:GetItemID());
	local difficultyText = C_TradeSkillUI.GetReagentDifficultyText(1, craftingReagents);
	if difficultyText and difficultyText ~= "" then
		GameTooltip_AddHighlightLine(tooltip, difficultyText);
		GameTooltip_AddBlankLineToTooltip(tooltip);
	end

	local craftingReagentIndex = 1;
	local bonusText = C_TradeSkillUI.GetCraftingReagentBonusText(recipeID, craftingReagentIndex, craftingReagents, recraftItemGUID);
	for _, str in ipairs(bonusText) do
		GameTooltip_AddHighlightLine(tooltip, str);
	end

	local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(item:GetItemID());
	if quality then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		local atlasSize = 26;
		local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(quality, true), atlasSize, atlasSize);
		GameTooltip_AddHighlightLine(tooltip, PROFESSIONS_CRAFTING_QUALITY:format(atlasMarkup));
	end
end

function Professions.GenerateFlyoutItemsTable(itemIDs, filterOwned)
	local items = {};
	if filterOwned then
		for index, itemID in ipairs(itemIDs) do
			local foundItems = ItemUtil.FindPlayerInventoryAndEquipmentItemsMatchingItemID(itemID);
			tAppendAll(items, foundItems);
		end
	else
		for index, itemID in ipairs(itemIDs) do
			local foundItems = ItemUtil.FindPlayerInventoryAndEquipmentItemsMatchingItemID(itemID);
			if #foundItems == 0 then
				table.insert(items, Item:CreateFromItemID(itemID));
			else
				tAppendAll(items, foundItems);
			end
		end
	end
	return items;
end

function Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID, recraftItemGUID)
	local item = elementData.item;
		
	local colorData = item:GetItemQualityColor();
	GameTooltip_SetTitle(tooltip, item:GetItemName(), colorData.color);
	
	Professions.AddCommonOptionalTooltipInfo(item, tooltip, recipeID, recraftItemGUID);

	local count = ItemUtil.GetCraftingReagentCount(item:GetItemID());
	if count <= 0 then
		GameTooltip_AddErrorLine(tooltip, OPTIONAL_REAGENT_NONE_AVAILABLE);
	end
end

local recraftingTransitionData = nil;
function Professions.SetRecraftingTransitionData(data)
	recraftingTransitionData = data;
end

function Professions.GetRecraftingTransitionData()
	return recraftingTransitionData;
end

function Professions.EraseRecraftingTransitionData()
	local data = recraftingTransitionData;
	recraftingTransitionData = nil;
	return data;
end

function Professions.GetReagentSlotStatus(reagentSlotSchematic, recipeInfo)
	local slotInfo = reagentSlotSchematic.slotInfo;
	local locked, lockedReason = C_TradeSkillUI.GetReagentSlotStatus(slotInfo.mcrSlotID, recipeInfo.recipeID);
	if not locked then
		local categoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID);
		while not categoryInfo.skillLineCurrentLevel and categoryInfo.parentCategoryID do
			categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryInfo.parentCategoryID);
		end

		if categoryInfo.skillLineCurrentLevel then
			local requiredSkillRank = slotInfo.requiredSkillRank;
			locked = categoryInfo.skillLineCurrentLevel < requiredSkillRank;
			if locked then
				lockedReason = OPTIONAL_REAGENT_TOOLTIP_SLOT_LOCKED_FORMAT:format(requiredSkillRank);
			end
		end
	end

	return locked, lockedReason;
end

function Professions.GetReagentQuantityInPossession(reagent)
	if reagent.itemID then
		return ItemUtil.GetCraftingReagentCount(reagent.itemID);
	elseif reagent.currencyID then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
		return currencyInfo.quantity;
	end
	assert(false);
end

function Professions.AccumulateReagentsInPossession(reagents)
	return AccumulateOp(reagents, function(reagent)
		return Professions.GetReagentQuantityInPossession(reagent);
	end);
end

local function CanShowBar(professionInfo)
	if C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember() then
		return false;
	end

	if not C_TradeSkillUI.IsTradeSkillReady() or (not professionInfo.professionID) or professionInfo.maxSkillLevel == 0 then
		return false;
	end

	return true;
end

function Professions.UpdateRankBarVisibility(rankBar, professionInfo)
	local canShowBar = CanShowBar(professionInfo);
	rankBar:SetShown(canShowBar);
	return canShowBar;
end

function Professions.GetProfessionCategories(sorted)
	local categories = {};
	for index, categoryID in ipairs({C_TradeSkillUI.GetCategories()}) do
		local category = C_TradeSkillUI.GetCategoryInfo(categoryID);
		table.insert(categories, category);
	end

	if sorted then
		table.sort(categories, function(lhs, rhs)
			return lhs.uiOrder < rhs.uiOrder;
		end);
	end

	return categories;
end

function Professions.GetFirstRecipe(recipeInfo)
	local previousRecipeID = recipeInfo.previousRecipeID;
	while previousRecipeID do
		recipeInfo = C_TradeSkillUI.GetRecipeInfo(previousRecipeID);
		previousRecipeID = recipeInfo.previousRecipeID;
	end
	
	return recipeInfo;
end

function Professions.GetNextRecipe(recipeInfo)
	local nextRecipeID = recipeInfo.nextRecipeID;
	return nextRecipeID and C_TradeSkillUI.GetRecipeInfo(nextRecipeID) or nil;
end

function Professions.EnumerateRecipes(recipeInfo)
	local recipes = {};
	recipeInfo = Professions.GetFirstRecipe(recipeInfo);
	while recipeInfo do
		table.insert(recipes, recipeInfo);
		recipeInfo = Professions.GetNextRecipe(recipeInfo);
	end

	return CreateTableEnumerator(recipes);
end

function Professions.GetHighestLearnedRecipe(recipeInfo)
	local learnedRecipe = nil;
	for index, recipeInfo in Professions.EnumerateRecipes(recipeInfo) do
		if not recipeInfo.learned then
			break;
		end
		learnedRecipe = recipeInfo;
	end
	return learnedRecipe;
end

function Professions.GetRecipeRank(recipeInfo)
	local recipeID = recipeInfo.recipeID;
	for index, recipeInfo in Professions.EnumerateRecipes(recipeInfo) do
		if recipeID == recipeInfo.recipeID then
			return index;
		end
	end
	return 0;
end

function Professions.GetRecipeRankLearned(recipeInfo)
	local rank = 0;
	if Professions.HasRecipeRanks(recipeInfo) then
		for index, recipeInfo in Professions.EnumerateRecipes(recipeInfo) do
			if recipeInfo.learned then
				rank = rank + 1;
			end
		end
	end
	return rank;
end

function Professions.HasRecipeRanks(recipeInfo)
	return recipeInfo.previousRecipeID or recipeInfo.nextRecipeID;
end

function Professions.IsViewingExternalCraftingList()
	return C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember() or C_TradeSkillUI.IsTradeSkillLinked();
end

function Professions.InLocalCraftingMode()
	return not (C_TradeSkillUI.IsNPCCrafting() or Professions.IsViewingExternalCraftingList());
end

function Professions.TransitionToRecraft(itemGUID)
	local transitionData =
	{
		isRecraft = true,
		itemGUID = itemGUID;
	};
	Professions.SetRecraftingTransitionData(transitionData);

	local craftRecipeID = C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID);
	C_TradeSkillUI.OpenRecipe(craftRecipeID);
end

function Professions.SetupOutputIcon(outputIcon, transaction, outputItemInfo)
	local recipeSchematic = transaction:GetRecipeSchematic();
	local quantityMin, quantityMax = recipeSchematic.quantityMin, recipeSchematic.quantityMax;

	-- Quantity min and max in the context of salvage recipes means the reagent cost, not the output quantity.
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		quantityMin, quantityMax = 1, 1;
	end

	local quality = 0;
	if outputItemInfo.hyperlink then
		local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
		quality = item:GetItemQuality();
	end

	Professions.SetupOutputIconCommon(outputIcon, quantityMin, quantityMax, outputItemInfo.icon, outputItemInfo.hyperlink, quality);
end

function Professions.SetupOutputIconCommon(outputIcon, quantityMin, quantityMax, icon, itemIDOrLink, quality)
	if quantityMax > 1 then
		if quantityMin == quantityMax then
			outputIcon.Count:SetText(quantityMin);
		else
			outputIcon.Count:SetFormattedText("%d-%d", quantityMin, quantityMax);
		end
		local magicWidth = 39;
		if outputIcon.Count:GetWidth() > magicWidth then
			outputIcon.Count:SetFormattedText("~%d", math.floor(Lerp(quantityMin, quantityMax, .5)));
		end
		outputIcon.CountShadow:Show();
	else
		outputIcon.Count:SetText("");
		outputIcon.CountShadow:Hide();
	end
	outputIcon.Icon:SetTexture(icon);
	
	SetItemButtonQuality(outputIcon, quality, itemIDOrLink);
end

function Professions.GetQuantitiesAllocated(transaction, reagentSlotSchematic)
	local quantities = {0, 0, 0};
	for _, allocation in transaction:EnumerateAllocations(reagentSlotSchematic.slotIndex) do
		local index = FindInTableIf(reagentSlotSchematic.reagents, function(reagent)
			return Professions.CraftingReagentMatches(reagent, allocation.reagent);
		end);
		assert(index and quantities[index] ~= nil, index);
		quantities[index] = allocation.quantity;
	end
	return quantities;
end

function Professions.SetupQualityReagentTooltip(slot, transaction)
	local itemID = slot.Button:GetItemID();
	if itemID then
		GameTooltip:SetQualityReagentSlotItemByID(slot.Button:GetItemID());

		if not slot:IsUnallocatable() then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);

			local quantities = Professions.GetQuantitiesAllocated(transaction, slot:GetReagentSlotSchematic());
			local slotsAllocated = AccumulateOp(quantities, function(quantity)
				return math.min(quantity, 1);
			end);

			if slotsAllocated > 1 then
				GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_ALLOCATIONS_TOOLTIP:format(
					quantities[1], CreateAtlasMarkupWithAtlasSize("Professions-Icon-Quality-Tier1-Small"), 
					quantities[2], CreateAtlasMarkupWithAtlasSize("Professions-Icon-Quality-Tier2-Small"),  
					quantities[3], CreateAtlasMarkupWithAtlasSize("Professions-Icon-Quality-Tier3-Small")));
			end
			
			GameTooltip_AddInstructionLine(GameTooltip, BASIC_REAGENT_TOOLTIP_CLICK_TO_ALLOCATE);
		end
	end
end

function Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentType, slotText, exchangeOnly, recraftItemGUID)
	local itemID = slot.Button:GetItemID();
	if itemID then
		local item = Item:CreateFromItemID(itemID);
		local colorData = item:GetItemQualityColor();
		GameTooltip_SetTitle(GameTooltip, item:GetItemName(), colorData.color, false);
	
		Professions.AddCommonOptionalTooltipInfo(item, GameTooltip, recipeID, recraftItemGUID);

		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		if exchangeOnly then
			GameTooltip_AddInstructionLine(GameTooltip, OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_EXCHANGE);
		else
			local instruction = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_CLICK_TO_REMOVE or OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_REMOVE;
			GameTooltip_AddInstructionLine(GameTooltip, instruction);
		end
	else
		local title = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_TITLE:format(slotText) or EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE;
		GameTooltip_SetTitle(GameTooltip, title, nil, false);
		local instruction = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_CLICK_TO_ADD or OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_ADD;
		GameTooltip_AddInstructionLine(GameTooltip, instruction);
	end
end

local function AllocateReagents(allocations, reagentSlotSchematic, useBestQuality)
	allocations:Clear();

	local quantityRequired = reagentSlotSchematic.quantityRequired;
	local iterator = useBestQuality and ipairs_reverse or ipairs;
	for reagentIndex, reagent in iterator(reagentSlotSchematic.reagents) do
		local quantity = Professions.GetReagentQuantityInPossession(reagent);
		allocations:Allocate(reagent, math.min(quantity, quantityRequired));
		quantityRequired = quantityRequired - quantity;

		if quantityRequired <= 0 then
			break;
		end
	end

	if quantityRequired > 0 then
		allocations:Clear();
	end
end

local function AllocateBasicReagents(transaction, reagentSlotSchematic, slotIndex, useBestQuality)
	if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
		local allocations = transaction:GetAllocations(slotIndex);
		AllocateReagents(allocations, reagentSlotSchematic, useBestQuality);
	end
end

function Professions.AllocateBasicReagents(transaction, slotIndex, useBestQuality)
	transaction:SetManuallyAllocated(false);
	local reagentSlotSchematic = transaction:GetReagentSlotSchematic(slotIndex);
	AllocateBasicReagents(transaction, reagentSlotSchematic, slotIndex, useBestQuality);
end

function Professions.AllocateAllBasicReagents(transaction, useBestQuality)
	transaction:SetManuallyAllocated(false);
	local recipeSchematic = transaction:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		AllocateBasicReagents(transaction, reagentSlotSchematic, slotIndex, useBestQuality);
	end
end

local function HandleReagentLink(link)
	if not HandleModifiedItemClick(link) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		return false, link;
	end
	return true, link;
end

function Professions.TriggerReagentClickedEvent(link)
	if link then
		local itemID = GetItemInfoFromHyperlink(link);
		local item = Item:CreateFromItemID(itemID);
		EventRegistry:TriggerEvent("Professions.ReagentClicked", item:GetItemName());
	end
end

function Professions.HandleFixedReagentItemLink(recipeID, reagentSlotSchematic)
	local link = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex);
	return HandleReagentLink(link);
end

function Professions.HandleQualityReagentItemLink(recipeID, reagentSlotSchematic, qualityIndex)
	local link = C_TradeSkillUI.GetRecipeQualityReagentItemLink(recipeID, reagentSlotSchematic.dataSlotIndex, qualityIndex);
	return HandleReagentLink(link);
end

function Professions.FindFirstQualityAllocated(transaction, reagentSlotSchematic)
	local quantities = Professions.GetQuantitiesAllocated(transaction, reagentSlotSchematic);
	local function IsNonZeroQuantity(quantity)
		return quantity > 0;
	end
	return FindInTableIf(quantities, IsNonZeroQuantity);
end

function Professions.GetReagentInputMode(reagentSlotSchematic)
	if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
		local count = #reagentSlotSchematic.reagents;
		if count == 1 then
			return Professions.ReagentInputMode.Fixed;
		end

		if count == 3 then
			return Professions.ReagentInputMode.Quality;
		end

		assert(false, "Reagent slot schematic does not have an expected reagent setup.");
	end

	return Professions.ReagentInputMode.Any;
end

function Professions.CreateRecipeItemIDListByPredicate(recipeID, predicate)
	local itemIDs = {};
	local isRecraft = false;
	local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
	for _, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if predicate(reagentSlotSchematic) then
			for _, reagent in ipairs(reagentSlotSchematic.reagents) do
				if reagent.itemID then
					table.insert(itemIDs, reagent.itemID);
				end
			end
		end
	end
	return itemIDs;
end

function Professions.CreateRecipeItemIDsForAllBasicReagents(recipeID, predicate)
	local function IsBasicReagent(reagentSlotSchematic)
		return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic;
	end
	return Professions.CreateRecipeItemIDListByPredicate(recipeID, IsBasicReagent);
end

function Professions.GenerateCraftingDataProvider(professionID, searching, noStripCategories)
	local function CreateRecipeCategoryRecursive(categoryMap, categoryID)
		local categoryInfo = categoryMap[categoryID];
		if not categoryInfo then
			categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryID);
			if not categoryInfo then
				-- headers....
				return;
			end
			categoryInfo.subcategories = {};
			categoryInfo.recipes = {};
			categoryMap[categoryID] = categoryInfo;
		end

		if categoryInfo.parentCategoryID then
			local parentCategoryInfo = CreateRecipeCategoryRecursive(categoryMap, categoryInfo.parentCategoryID);
			-- headers....
			if parentCategoryInfo then
				table.insert(categoryInfo.subcategories, parentCategoryInfo);
			end
		end

		return categoryInfo;
	end

	local function CreateRecipeCategoryHierarchy(categoryMap, recipeInfos)
		for index, recipeInfo in pairs(recipeInfos) do
			local categoryInfo = CreateRecipeCategoryRecursive(categoryMap, recipeInfo.categoryID);
			if not categoryInfo then
				-- headers....
				return;
			end
			table.insert(categoryInfo.recipes, recipeInfo);
		end
	end
	
	local function SortCategoriesOrRecipes(lhs, rhs)
		local lhsData = lhs:GetData();
		local rhsData = rhs:GetData();
		local lhsCategoryInfo = lhsData.categoryInfo;
		local rhsCategoryInfo = rhsData.categoryInfo;
		if lhsCategoryInfo or rhsCategoryInfo then
			if lhsData.categoryInfo and not rhsCategoryInfo then
				return true;
			elseif not lhsCategoryInfo and rhsCategoryInfo then
				return false;
			elseif lhsCategoryInfo and rhsCategoryInfo then
				return lhsCategoryInfo.uiOrder < rhsCategoryInfo.uiOrder;
			end
		end

		if lhsData.topPadding or rhsData.topPadding then
			return lhsData.topPadding;
		end

		if lhsData.bottomPadding or rhsData.bottomPadding then
			return not lhsData.bottomPadding;
		end

		local lhsRecipeInfo = lhsData.recipeInfo;
		local rhsRecipeInfo = rhsData.recipeInfo;
		local lhsDifficulty = lhsRecipeInfo.difficulty;
		local rhsDifficulty = rhsRecipeInfo.difficulty;
		if lhsDifficulty ~= rhsDifficulty then
			return lhsDifficulty < rhsDifficulty;
		else
			local lhsMaxTrivialLevel = lhsRecipeInfo.maxTrivialLevel;
			local rhsMaxTrivialLevel = rhsRecipeInfo.maxTrivialLevel;
			if lhsMaxTrivialLevel ~= rhsMaxTrivialLevel then
				return lhsMaxTrivialLevel > rhsMaxTrivialLevel;
			else
				local lhsItemLevel = lhsRecipeInfo.itemLevel;
				local rhsItemLevel = rhsRecipeInfo.itemLevel;
				if lhsItemLevel ~= rhsItemLevel then
					return lhsItemLevel > rhsItemLevel;
				end
			end
		end
		return strcmputf8i(lhsRecipeInfo.name, rhsRecipeInfo.name) < 0;
	end

	local function AttachTreeDataRecursive(categoryMap, categoryNodes, categoryInfo, node)
		-- The root and any nodes passed as categories need a sort comparator.
		if not node:HasSortComparator() then
			local affectChildren = false;
			local skipSort = false;
			node:SetSortComparator(SortCategoriesOrRecipes, affectChildren, skipSort);
		end

		local parentCategoryID = categoryInfo.parentCategoryID;
		local parentCategoryInfo = categoryMap[parentCategoryID];
		if parentCategoryInfo then
			node = AttachTreeDataRecursive(categoryMap, categoryNodes, parentCategoryInfo, node);
		end

		local categoryNode = categoryNodes[categoryInfo];
		if not categoryNode then
			categoryNode = node:Insert({categoryInfo=categoryInfo});
			categoryNodes[categoryInfo] = categoryNode;

			-- The new category can have categories or recipes.
			local affectChildren = false;
			local skipSort = false;
			categoryNode:SetSortComparator(SortCategoriesOrRecipes, affectChildren, skipSort);
		end

		if categoryInfo.recipes and #categoryInfo.recipes > 0 then
			categoryNode:Insert({topPadding=true});
			for index, recipeInfo in ipairs(categoryInfo.recipes) do
				categoryNode:Insert({recipeInfo=recipeInfo});
				-- Recipes are leaf-most, so we don't need any sort comparator.
			end
			categoryNode:Insert({bottomPadding=true});
		end	

		return categoryNode;
	end

	
	local categoryMap = {};
	local categoryNodes = {};
	local recipeInfos = {};

	local favoritesCategoryInfo = {name = PROFESSIONS_CATEGORY_FAVORITE, recipes = {}, uiOrder = -1};

	for index, recipeID in ipairs(C_TradeSkillUI.GetFilteredRecipeIDs()) do
		local recipeInfo = Professions.GetFirstRecipe(C_TradeSkillUI.GetRecipeInfo(recipeID));
		if searching or C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRecipeInSkillLine(recipeID, professionID) then
			recipeInfos[recipeInfo.recipeID] = recipeInfo;
		end
		if not searching and recipeInfo.favorite then
			local favoritesRecipeInfo = CopyTable(recipeInfo);
			favoritesRecipeInfo.favoritesInstance = true;
			table.insert(favoritesCategoryInfo.recipes, favoritesRecipeInfo);
		end
	end

	local dataProvider = CreateLinearizedTreeListDataProvider();
	-- Create the category hierarchy for the recipe. This includes every category until
	-- a header, which we drop on the floor.
	CreateRecipeCategoryHierarchy(categoryMap, recipeInfos);

	if not searching or C_TradeSkillUI.IsNPCCrafting() then
		-- Strip out every root category if it doesnt have any recipes. We're only interested in seeing these if
		-- we're in a search so we can reconcile which expansion the recipe pertains to. For an example of
		-- a root category that has recipes, see ID 390.
		for _, category in ipairs(Professions.GetProfessionCategories()) do
			if not noStripCategories or not tContains(noStripCategories, category.categoryID) then
				local categoryInMap = categoryMap[category.categoryID];
				if not categoryInMap or not categoryInMap.recipes or #categoryInMap.recipes == 0 then
				categoryMap[category.categoryID] = nil;
			end
		end
	end
	end

	if next(favoritesCategoryInfo.recipes) ~= nil then
		categoryMap[-1] = favoritesCategoryInfo;
	end

	-- Insert the categories into the tree, using the group category data as the root parent.
	if next(recipeInfos) ~= nil then
		local node = dataProvider:GetRootNode();
		for _, categoryInfo in pairs(categoryMap) do
			AttachTreeDataRecursive(categoryMap, categoryNodes, categoryInfo, node);
		end
	end

	return dataProvider;
end

function Professions.ShouldAllocateBestQualityReagents()
	return GetCVarBool("professionsAllocateBestQualityReagents");
end

function Professions.SetShouldAllocateBestQualityReagents(shouldUse)
	SetCVar("professionsAllocateBestQualityReagents", shouldUse and "1" or "0");
end

function Professions.SetDefaultOrderDuration(index)
	SetCVar("professionsOrderDurationDropdown", index);
end

function Professions.GetDefaultOrderDuration()
	return tonumber(GetCVar("professionsOrderDurationDropdown"));
end

function Professions.SetDefaultOrderRecipient(index)
	SetCVar("professionsOrderRecipientDropdown", index);
end

function Professions.GetDefaultOrderRecipient()
	return tonumber(GetCVar("professionsOrderRecipientDropdown"));
end

function Professions.GetIconForQuality(quality, small)
	if small then
		return ("Professions-Icon-Quality-Tier%d-Small"):format(quality);
	end
	return ("Professions-Icon-Quality-Tier%d"):format(quality);
end

function Professions.GetOrderDurationText(duration)
	if duration == Enum.TradeskillOrderDuration.Short then
		return PROFESSIONS_LISTING_DURATION_ONE;
	elseif duration == Enum.TradeskillOrderDuration.Medium then
		return PROFESSIONS_LISTING_DURATION_TWO;
	elseif duration == Enum.TradeskillOrderDuration.Long then
		return PROFESSIONS_LISTING_DURATION_THREE;
	end
	error("Invalid duration enum provided.");
end

function Professions.GetOrderReagentsSummaryText(order)
	if order.reagentContents == Professions.ReagentContents.None then
		return PROFESSIONS_COLUMN_REAGENTS_NONE;
	elseif order.reagentContents == Professions.ReagentContents.Partial then
		return PROFESSIONS_COLUMN_REAGENTS_PARTIAL;
	elseif order.reagentContents == Professions.ReagentContents.All then
		return PROFESSIONS_COLUMN_REAGENTS_ALL;
	end
end

function Professions.ClearSlotFilter()
	C_TradeSkillUI.ClearInventorySlotFilter();
	C_TradeSkillUI.ClearRecipeCategoryFilter();
end

function Professions.SetInventorySlotFilter(inventorySlotIndex)
	Professions.ClearSlotFilter();

	if inventorySlotIndex then
		C_TradeSkillUI.SetInventorySlotFilter(inventorySlotIndex, true, true);
	end
end

function Professions.IsUsingDefaultFilters()
	local showAllRecipes = not C_TradeSkillUI.GetOnlyShowMakeableRecipes() and 
		not C_TradeSkillUI.GetOnlyShowSkillUpRecipes() and 
		not C_TradeSkillUI.GetOnlyShowFirstCraftRecipes();
	local newestKnownProfessionInfo = Professions.GetNewestKnownProfessionInfo()
	local isDefaultSkillLine = newestKnownProfessionInfo == nil or C_TradeSkillUI.GetChildProfessionInfo().professionID == Professions.GetNewestKnownProfessionInfo().professionID;
	return showAllRecipes and isDefaultSkillLine and not C_TradeSkillUI.AreAnyInventorySlotsFiltered() and 
		not C_TradeSkillUI.AnyRecipeCategoriesFiltered() and Professions.AreAllSourcesUnfiltered() and not C_TradeSkillUI.GetShowUnlearned() and C_TradeSkillUI.GetShowLearned();
end

function Professions.SetAllSourcesFiltered(filtered)
	local numSources = C_PetJournal.GetNumPetSources();
	for i = 1, numSources do
		if C_TradeSkillUI.IsAnyRecipeFromSource(i) then
			C_TradeSkillUI.SetRecipeSourceTypeFilter(i, filtered);
		end
	end
end

function Professions.AreAllSourcesFiltered()
	local numSources = C_PetJournal.GetNumPetSources();
	for i = 1, numSources do
		if C_TradeSkillUI.IsAnyRecipeFromSource(i) and not C_TradeSkillUI.IsRecipeSourceTypeFiltered(i) then
			return false;
		end
	end
	return true;
end

function Professions.AreAllSourcesUnfiltered()
	local numSources = C_PetJournal.GetNumPetSources();
	for i = 1, numSources do
		if C_TradeSkillUI.IsAnyRecipeFromSource(i) and C_TradeSkillUI.IsRecipeSourceTypeFiltered(i) then
			return false;
		end
	end
	return true;
end

function Professions.SetDefaultFilters()
	C_TradeSkillUI.SetShowLearned(true);
	C_TradeSkillUI.SetShowUnlearned(false);
	C_TradeSkillUI.SetOnlyShowMakeableRecipes(false);
	C_TradeSkillUI.SetOnlyShowSkillUpRecipes(false);
	C_TradeSkillUI.SetOnlyShowFirstCraftRecipes(false);
	C_TradeSkillUI.ClearInventorySlotFilter();
	Professions.SetAllSourcesFiltered(false);
	C_TradeSkillUI.ClearRecipeSourceTypeFilter();
	C_TradeSkillUI.ClearRecipeCategoryFilter();
	local newestKnownProfessionInfo = Professions.GetNewestKnownProfessionInfo();
	if newestKnownProfessionInfo then
		EventRegistry:TriggerEvent("Professions.SelectSkillLine", newestKnownProfessionInfo);
	end
end

function Professions.GetNewestKnownProfessionInfo()
	for index, professionInfo in ipairs(C_TradeSkillUI.GetChildProfessionInfos()) do
		if professionInfo.skillLevel > 0 then
			return professionInfo;
		end
	end
end

function Professions.InitFilterMenu(dropdown, level, onUpdate)
	local filterSystem = {};
	filterSystem.onUpdate = onUpdate;
	filterSystem.filters = 
	{
		{
			type = FilterComponent.Checkbox,
			text = PROFESSION_RECIPES_SHOW_LEARNED,
			set = C_TradeSkillUI.SetShowLearned,
			isSet = C_TradeSkillUI.GetShowLearned
		},
		{
			type = FilterComponent.Checkbox,
			text = PROFESSION_RECIPES_SHOW_UNLEARNED,
			set = C_TradeSkillUI.SetShowUnlearned,
			isSet = C_TradeSkillUI.GetShowUnlearned
		},
		{
			type = FilterComponent.Checkbox,
			text = CRAFT_IS_MAKEABLE,
			set = C_TradeSkillUI.SetOnlyShowMakeableRecipes,
			isSet = C_TradeSkillUI.GetOnlyShowMakeableRecipes
		}
	};

	if not C_TradeSkillUI.IsNPCCrafting() then
		local sourcesFilters = {
			type = FilterComponent.Submenu,
			text = SOURCES,
			value = 2,
			childrenInfo = {
				filters = {
					{
						type = FilterComponent.TextButton,
						text = CHECK_ALL,
						set = function()
							Professions.SetAllSourcesFiltered(false)
							UIDropDownMenu_Refresh(dropdown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
						end
					},
					{
						type = FilterComponent.TextButton,
						text = UNCHECK_ALL,
						set = function()
							Professions.SetAllSourcesFiltered(true)
							UIDropDownMenu_Refresh(dropdown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
						end
					},
					{
						type = FilterComponent.DynamicFilterSet,
						buttonType = FilterComponent.Checkbox,
						set = function(filter, value)
							C_TradeSkillUI.SetRecipeSourceTypeFilter(filter, not value)
						end,
						isSet = function(filter)
							return not C_TradeSkillUI.IsRecipeSourceTypeFiltered(filter)
						end,
						numFilters = C_PetJournal.GetNumPetSources,
						filterValidation = C_TradeSkillUI.IsAnyRecipeFromSource,
						globalPrepend = "BATTLE_PET_SOURCE_"
					}
				}
			}
		};
		table.insert(filterSystem.filters, sourcesFilters);

		local firstCraftFilters = {
			type = FilterComponent.Checkbox,
			text = PROFESSION_RECIPES_IS_FIRST_CRAFT,
			set = C_TradeSkillUI.SetOnlyShowFirstCraftRecipes,
			isSet = C_TradeSkillUI.GetOnlyShowFirstCraftRecipes
		};
		table.insert(filterSystem.filters, 3, firstCraftFilters);
	end

	local slotsFilters = {
		type = FilterComponent.Submenu,
		text = TRADESKILL_FILTER_SLOTS,
		value = 1,
		childrenInfo = {
			filters = {
				{
					type = FilterComponent.DynamicFilterSet,
					buttonType = FilterComponent.Checkbox,
					set = C_TradeSkillUI.SetInventorySlotFilter,
					isSet = function(filter)
						return not C_TradeSkillUI.IsInventorySlotFiltered(filter);
					end,
					numFilters = C_TradeSkillUI.GetAllFilterableInventorySlotsCount,
					nameFunction = C_TradeSkillUI.GetFilterableInventorySlotName,
				}
			}
		}
	};
	table.insert(filterSystem.filters, slotsFilters);

	if not C_TradeSkillUI.IsTradeSkillGuild() then
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		local isNPCCrafting = C_TradeSkillUI.IsNPCCrafting() and professionInfo.maxSkillLevel == 0;
		if not isNPCCrafting then
			local onlyShowSkillUpRecipes = { 
				type = FilterComponent.Checkbox, 
				text = TRADESKILL_FILTER_HAS_SKILL_UP, 
				set = C_TradeSkillUI.SetOnlyShowSkillUpRecipes, 
				isSet = C_TradeSkillUI.GetOnlyShowSkillUpRecipes,
			};
			table.insert(filterSystem.filters, 3, onlyShowSkillUpRecipes);
		end
	end

	do
		if not C_TradeSkillUI.IsNPCCrafting() then
			local childProfessionInfos = C_TradeSkillUI.GetChildProfessionInfos();
			if #childProfessionInfos > 0 then
				local spacer = { type = FilterComponent.Space };
				table.insert(filterSystem.filters, spacer);

				for index, professionInfo in ipairs(childProfessionInfos) do
					local skillLine = { 
						type = FilterComponent.Radio,
						text = professionInfo.expansionName,
						set = function() EventRegistry:TriggerEvent("Professions.SelectSkillLine", professionInfo); end, 
						isSet = function() return C_TradeSkillUI.GetChildProfessionInfo().professionID == professionInfo.professionID; end,
							hideMenuOnClick = true,
					};
					table.insert(filterSystem.filters, skillLine);
				end
			end
		end
	end

	FilterDropDownSystem.Initialize(dropdown, filterSystem, level);

	return filterSystem;
end

function Professions.OnRecipeListSearchTextChanged(text)
	local range = 2;
	local minLevel, maxLevel;
	local approxLevel = text:match("^~(%d+)");
	if approxLevel then
		minLevel = approxLevel - range;
		maxLevel = approxLevel + range;
	else
		minLevel, maxLevel = text:match("^(%d+)%s*-*%s*(%d*)$");
	end

	if minLevel then
		if not maxLevel or maxLevel == "" then
			maxLevel = minLevel;
		end
		minLevel = tonumber(minLevel);
		maxLevel = tonumber(maxLevel);

		minLevel = math.max(1, math.min(10000, minLevel));
		maxLevel = math.max(1, math.min(10000, math.max(minLevel, maxLevel)));

		C_TradeSkillUI.SetRecipeItemNameFilter(nil);
		C_TradeSkillUI.SetRecipeItemLevelFilter(minLevel, maxLevel);
	else
		C_TradeSkillUI.SetRecipeItemNameFilter(text);
		C_TradeSkillUI.SetRecipeItemLevelFilter(0, 0);
	end
end

function Professions.LayoutReagentSlots(reagentSlots, reagentsContainer, optionalReagentsSlots, optionalReagentsContainer, divider)
	local stride = 1;
	local spacing = -5;
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, spacing, spacing);
	
	local function Layout(slots, anchor, layout)
		if slots then
			AnchorUtil.GridLayout(slots, anchor, layout);
		end
	end
	
	do
		local anchor = CreateAnchor("TOPLEFT", reagentsContainer, "TOPLEFT", 0, -30);
		Layout(reagentSlots, anchor, layout);
		reagentsContainer:Layout();
	end

	do
		local optionalShown = optionalReagentsSlots and #optionalReagentsSlots > 0;
		if optionalShown then
			local anchor = CreateAnchor("TOPLEFT", optionalReagentsContainer, "TOPLEFT", 0, -30);
			Layout(optionalReagentsSlots, anchor, layout);
			optionalReagentsContainer:Layout();
		end
		optionalReagentsContainer:SetShown(optionalShown);
		if divider then
			divider:SetShown(optionalShown);
		end
	end
end

function Professions.LayoutFinishingSlots(finishingSlots, finishingSlotContainer)
	if finishingSlots then
		local stride = 2;
		local spacing = 15;
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, spacing, spacing, 40);
			
		local anchor;
		if #finishingSlots == 1 then
			anchor = CreateAnchor("TOP", finishingSlotContainer, "TOP", 60, -48)
		else
			anchor = CreateAnchor("TOPLEFT", finishingSlotContainer, "TOPLEFT", 70, -48)
		end

		AnchorUtil.GridLayout(finishingSlots, anchor, layout);
	end
end

local kitSpecifiers = tInvert(Enum.Profession);
function Professions.GetAtlasKitSpecifier(professionInfo)
	return professionInfo and professionInfo.profession and kitSpecifiers[professionInfo.profession];
end

local function GetProfessionBackground(professionInfo, atlasFormat)
	local kitSpecifier = Professions.GetAtlasKitSpecifier(professionInfo);
	local stylizedAtlasName = kitSpecifier ~= nil and atlasFormat:format(kitSpecifier);
	local stylizedInfo = stylizedAtlasName and C_Texture.GetAtlasInfo(stylizedAtlasName);
	return stylizedInfo and stylizedAtlasName or "Professions-Recipe-Background";
end

function Professions.GetProfessionBackgroundAtlas(professionInfo)
	return GetProfessionBackground(professionInfo, "Professions-Recipe-Background-%s");
end

function Professions.GetProfessionSpecializationBackgroundAtlas(professionInfo)
	return GetProfessionBackground(professionInfo, "Professions-Specializations-Background-%s");
end

function Professions.CanTrackRecipe(recipeInfo)
	if recipeInfo.isRecraft then
		return false;
	end

	if Professions.IsViewingExternalCraftingList() then
		return false;
	end

	if C_TradeSkillUI.IsRuneforging() then
		return false;
	end

	if recipeInfo.isSalvageRecipe or recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe then
		return false;
	end

	return true;
end

function Professions.GetCurrencyTypesID(nodeID)
	local traitCurrencyID = nodeID and C_ProfSpecs.GetSpendCurrencyForPath(nodeID);
	if traitCurrencyID then
		return select(3, C_Traits.GetTraitCurrencyInfo(traitCurrencyID));
	end
end

function Professions.GetCurrentProfessionCurrencyInfo()
	local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID();
	local currencyTypesID = Professions.GetCurrencyTypesID(nodeID);
	if currencyTypesID then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID);
		currencyInfo.currencyID = currencyTypesID;
		return currencyInfo;
	end
	
	return nil;
end

function Professions.SetupProfessionsCurrencyTooltip(currencyInfo, currencyCount)
	GameTooltip_AddHighlightLine(GameTooltip, currencyInfo.name, false);
	GameTooltip_AddNormalLine(GameTooltip, currencyInfo.description);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	local count = currencyCount or currencyInfo.quantity;
	GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_SPECIALIZATION_CURRENCY_TOTAL:format(count));
end

function Professions.DoesSchematicIncludeReagentQualities(recipeSchematic)
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local isMCR = reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent;
		if isMCR and (reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic) then
			if #reagentSlotSchematic.reagents > 1 then
				return true;
			end
		end
	end
	return false;
end

function Professions.GetProfessionType(professionInfo)
	local profession = professionInfo.profession;

	if profession == Enum.Profession.Mining or profession == Enum.Profession.Herbalism or profession == Enum.Profession.Skinning or profession == Enum.Profession.Fishing then
		return Professions.ProfessionType.Gathering;
	end

	return Professions.ProfessionType.Crafting;
end