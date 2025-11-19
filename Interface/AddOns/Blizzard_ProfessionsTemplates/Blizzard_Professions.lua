
Professions = {};

Professions.ReagentInputMode = EnumUtil.MakeEnum("Fixed", "Quality", "Any");
Professions.ReagentContents = EnumUtil.MakeEnum("None", "Partial", "All");
Professions.ProfessionType = EnumUtil.MakeEnum("Crafting", "Gathering");

function Professions.IsValidReagent(reagent)
	local isItemIDValid = reagent.itemID and reagent.itemID > 0;
	local isCurrencyIDValid = reagent.currencyID and reagent.currencyID > 0;
	return isItemIDValid or isCurrencyIDValid and not (isItemIDValid and isCurrencyIDValid);
end

-- See native CraftingReagent
function Professions.CreateCraftingReagent(itemID, currencyID)
	assert((itemID ~= nil and itemID > 0) or (currencyID ~= nil and currencyID > 0));
	return {itemID = itemID, currencyID = currencyID};
end

function Professions.FindReagentInTable(reagents, findReagent)
	return FindInTableIf(reagents, function(reagent)
		return ProfessionsUtil.CraftingReagentMatches(reagent, findReagent);
	end);
end

function Professions.CreateItemReagent(itemID)
	return Professions.CreateCraftingReagent(itemID, nil);
end

function Professions.CreateCurrencyReagent(currencyID)
	return Professions.CreateCraftingReagent(nil, currencyID);
end

-- See native CraftingReagentInfo
function Professions.CreateCraftingReagentInfo(reagent, dataSlotIndex, quantity)
	assert(reagent ~= nil and dataSlotIndex ~= nil and quantity ~= nil);
	assert(reagent.itemID ~= nil or reagent.currencyID ~= nil);
	return {reagent = reagent, dataSlotIndex = dataSlotIndex, quantity = quantity };
end

function Professions.IsValidModification(modification)
	return modification and Professions.IsValidReagent(modification.reagent);
end

function Professions.DoesModificationContainReagent(modification, reagent)
	assert(modification.reagent ~= nil);
	assert(reagent ~= nil);
	return ProfessionsUtil.CraftingReagentMatches(modification.reagent, reagent);
end

function Professions.GetReagentQualityInfo(reagent)
	local itemID = reagent.itemID;
	if itemID then
		local qualityInfo = C_TradeSkillUI.GetItemReagentQualityInfo(itemID);
		return qualityInfo;
	end

	return nil;
end

function Professions.ReagentToString(reagent)
	if reagent.itemID then
		return string.format("itemID = %d", reagent.itemID);
	elseif reagent.currencyID then
		return string.format("currencyID = %d", reagent.currencyID);
	end
	return "invalid_reagent";
end

function Professions.CreateCraftingReagentInfoBonusTbl(...)
	local tbls = {};
	for index = 1, select('#', ...) do
		local reagent = select(index, ...);
		local quantity = 1;
		table.insert(tbls, Professions.CreateCraftingReagentInfo(reagent, index, quantity));
	end
	return tbls;
end

function Professions.AddTooltipInfo(reagent, tooltip, transaction)
	if reagent.currencyID then
		tooltip:SetCurrencyByID(reagent.currencyID);
	else
		local displayData = Professions.GetReagentDisplayData(reagent);
		GameTooltip_SetTitle(tooltip, displayData.name, displayData.color, false);
	end

	local addBlank = true;
	local craftingReagents = Professions.CreateCraftingReagentInfoBonusTbl(reagent);
	local difficultyText = C_TradeSkillUI.GetReagentDifficultyText(1, craftingReagents);
	if difficultyText and difficultyText ~= "" then
		GameTooltip_AddHighlightLine(tooltip, difficultyText);
		GameTooltip_AddBlankLineToTooltip(tooltip);
		addBlank = false;
	end
	
	local recipeID = transaction:GetRecipeID();
	local allocationItemGUID = transaction:GetAllocationItemGUID();
	local craftingReagentIndex = 1;
	local bonusText = C_TradeSkillUI.GetCraftingReagentBonusText(recipeID, craftingReagentIndex, craftingReagents, allocationItemGUID);
	for _, str in ipairs(bonusText) do
		GameTooltip_AddHighlightLine(tooltip, str);
		addBlank = true;
	end

	local qualityInfo = Professions.GetReagentQualityInfo(reagent);
	if qualityInfo then
		if addBlank then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			addBlank = false;
		end
		local atlasSize = 26;
		local atlasMarkup = CreateAtlasMarkup(qualityInfo.iconSmall, atlasSize, atlasSize);
		GameTooltip_AddHighlightLine(tooltip, PROFESSIONS_CRAFTING_QUALITY:format(atlasMarkup));
	end
	
	-- If this item is a flyout item, then the dependent reagents will have already been loaded when the
	-- flyout loaded all of its item options.
	local requirements = C_TradeSkillUI.GetDependentReagents(reagent);
	for index, requiredReagent in ipairs(requirements) do
		local name = Professions.GetReagentName(requiredReagent);
		local line = PROFESSIONS_REQUIRES_REAGENTS:format(name);
		if transaction:HasAllocatedReagent(requiredReagent) then
			GameTooltip_AddHighlightLine(tooltip, line);
		else
			GameTooltip_AddErrorLine(tooltip, line);
		end
	end

	local recraftAllocation = transaction:GetRecraftAllocation();
	if recraftAllocation and not C_TradeSkillUI.IsRecraftReagentValid(recraftAllocation, reagent) then
		GameTooltip_AddErrorLine(tooltip, PROFESSIONS_DISALLOW_DOWNGRADE);
	end
end

local CraftingAccessibleBags = 
{
	Enum.BagIndex.Backpack,
	Enum.BagIndex.Bag_1,
	Enum.BagIndex.Bag_2,
	Enum.BagIndex.Bag_3,
	Enum.BagIndex.Bag_4,
	Enum.BagIndex.ReagentBag,
	Enum.BagIndex.CharacterBankTab_1,
	Enum.BagIndex.CharacterBankTab_2,
	Enum.BagIndex.CharacterBankTab_3,
	Enum.BagIndex.CharacterBankTab_4,
	Enum.BagIndex.CharacterBankTab_5,
	Enum.BagIndex.CharacterBankTab_6,
	Enum.BagIndex.AccountBankTab_1,
	Enum.BagIndex.AccountBankTab_2,
	Enum.BagIndex.AccountBankTab_3,
	Enum.BagIndex.AccountBankTab_4,
	Enum.BagIndex.AccountBankTab_5,
};

function Professions.FindItemsInInventorySlots(itemID, maxFindCount)
	local items = {};
	local max = maxFindCount or math.huge;
	local function FindMatchingItemID(itemLocation)
		if C_Item.GetItemID(itemLocation) == itemID then
			local itemGUID = C_Item.GetItemGUID(itemLocation);
			table.insert(items, Item:CreateFromItemGUID(itemGUID));

			if #items >= max then
				return true;
			end
		end
	end

	for index, bagIndex in ipairs(CraftingAccessibleBags) do
		if ItemUtil.IterateBagSlots(bagIndex, FindMatchingItemID) then
			return items;
		end
	end

	ItemUtil.IterateInventorySlots(INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, FindMatchingItemID);
	return items;
end

do
	local function FilterReagentByCurrencyID(reagent)
		return reagent.currencyID ~= nil;
	end
	
	function Professions.FilterReagentsByCurrencyID(reagents)
		local isIndexTable = true;
		return tFilter(reagents, FilterReagentByCurrencyID, isIndexTable);
	end

	local function FilterReagentByItemID(reagent)
		return reagent.itemID ~= nil;
	end

	function Professions.FilterReagentsByItemID(reagents)
		local isIndexTable = true;
		return tFilter(reagents, FilterReagentByItemID, isIndexTable);
	end
end

function Professions.ForEachItemReagent(reagents, func)
	for index, reagent in ipairs(reagents) do
		if reagent.itemID ~= nil then
			func(reagent.itemID);
		end
	end
end

--[[
Creates Item objects for each item in the reagents list. When 'filterAvailable' is false, and
a non-zero quantity of items is found, an Item object is created for each instance.
]]--
function Professions.GenerateItemsFromEligibleItemSlots(reagents, filterAvailable)
	local items = {};
	local maxFindCount = 1;
	for index, reagent in ipairs(Professions.FilterReagentsByItemID(reagents)) do
		local itemID = reagent.itemID;
		local foundItems = Professions.FindItemsInInventorySlots(itemID, maxFindCount);
		tAppendAll(items, foundItems);

		-- Create an item to be displayed representing 0 quantity of the item.
		if not filterAvailable and #foundItems == 0 then
			table.insert(items, Item:CreateFromItemID(itemID));
		end
	end
	return items;
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
	local locked, lockedReason = false, nil;
	local slotInfo = reagentSlotSchematic.slotInfo;
	if slotInfo then
		locked, lockedReason = C_TradeSkillUI.GetReagentSlotStatus(slotInfo.mcrSlotID, recipeInfo.recipeID, recipeInfo.skillLineAbilityID);
		if not locked then
			local categoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID);
			while categoryInfo and not categoryInfo.skillLineCurrentLevel and categoryInfo.parentCategoryID do
				categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryInfo.parentCategoryID);
			end

			if categoryInfo and categoryInfo.skillLineCurrentLevel then
				local requiredSkillRank = slotInfo.requiredSkillRank;
				locked = categoryInfo.skillLineCurrentLevel < requiredSkillRank;
				if locked then
					lockedReason = OPTIONAL_REAGENT_TOOLTIP_SLOT_LOCKED_FORMAT:format(requiredSkillRank);
				end
			end
		end
	end
	return locked, lockedReason;
end

local function CanShowBar(professionInfo)
	if ProfessionsUtil.IsCraftingMinimized() then
		return false;
	end

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
	local previousRecipeID = recipeInfo and recipeInfo.previousRecipeID;
	while previousRecipeID do
		recipeInfo = C_TradeSkillUI.GetRecipeInfo(previousRecipeID);
		previousRecipeID = recipeInfo and recipeInfo.previousRecipeID;
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
	for index, enumRecipeInfo in Professions.EnumerateRecipes(recipeInfo) do
		if not enumRecipeInfo.learned then
			break;
		end
		learnedRecipe = enumRecipeInfo;
	end
	return learnedRecipe;
end

function Professions.GetRecipeRank(recipeInfo)
	local recipeID = recipeInfo.recipeID;
	for index, enumRecipeInfo in Professions.EnumerateRecipes(recipeInfo) do
		if recipeID == enumRecipeInfo.recipeID then
			return index;
		end
	end
	return 0;
end

function Professions.GetRecipeRankLearned(recipeInfo)
	local rank = 0;
	if Professions.HasRecipeRanks(recipeInfo) then
		for index, enumRecipeInfo in Professions.EnumerateRecipes(recipeInfo) do
			if enumRecipeInfo.learned then
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
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) or transaction:IsRecipeType(Enum.TradeskillRecipeType.Gathering) then
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
	local slotIndex = reagentSlotSchematic.slotIndex;
	for allocationIndex, allocation in transaction:EnumerateAllocations(slotIndex) do
		local index = FindInTableIf(reagentSlotSchematic.reagents, function(reagent)
			return ProfessionsUtil.CraftingReagentMatches(reagent, allocation.reagent);
		end);

		if not index or quantities[index] == nil then
			local reagent = allocation.reagent;
			local recipeID = transaction:GetRecipeID();
			local foundIndex = index and index or -1;
			local reagentsSize = (reagentSlotSchematic.reagents and #reagentSlotSchematic.reagents or 0);
			assert(false, ("Invalid allocation found: recipeID = %d, slotIndex = %d, allocationIndex = %d, foundIndex = %d, reagentsSize = %d, itemID = %d, currencyID = %d"):format(
				recipeID, slotIndex, allocationIndex, foundIndex, reagentsSize, reagent.itemID, reagent.currencyID));
		end
		quantities[index] = allocation.quantity;
	end
	return quantities;
end

function Professions.SetupReagentTooltip(reagent)
	local itemID = reagent.itemID;
	if itemID then
		GameTooltip:SetItemByID(itemID);
	else
		local currencyID = reagent.currencyID;
		if currencyID then
			GameTooltip:SetCurrencyByID(currencyID);
		end
	end
end

function Professions.SetupReagentQualityPickerTooltip(slot, transaction, noInstruction)
	-- Quality reagents do not support currencies.
	local reagent = slot:GetReagent();
	if reagent.currencyID then
		return;
	end

	local tooltipInfo = CreateBaseTooltipInfo("GetItemByID", reagent.itemID);
	tooltipInfo.excludeLines =
	{
		Enum.TooltipDataLineType.SellPrice,
		Enum.TooltipDataLineType.ProfessionCraftingQuality,
	};
	GameTooltip:ProcessInfo(tooltipInfo);

	local reagentSlotSchematic = slot:GetReagentSlotSchematic();
	local quantities = Professions.GetQuantitiesAllocated(transaction, reagentSlotSchematic);
	local quantitiesCount = AccumulateOp(quantities, function(quantity)
		return (quantity > 0) and 1 or 0;
	end);

	local hasMultipleAllocations = quantitiesCount > 1;
	if hasMultipleAllocations then
		local qualityInfos = {};
		for allocationIndex, allocation in transaction:EnumerateAllocations(reagentSlotSchematic.slotIndex) do
			local qualityInfo = Professions.GetReagentQualityInfo(allocation.reagent);
			table.insert(qualityInfos, qualityInfo);
		end

		table.sort(qualityInfos, function(lhs, rhs)
			return lhs.quality < rhs.quality;
		end);

		GameTooltip_AddBlankLineToTooltip(GameTooltip);

		local qualityInfosSize = #qualityInfos;
		if qualityInfosSize == 2 then
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_ALLOCATIONS_TOOLTIP_2:format(
				quantities[1], CreateAtlasMarkupWithAtlasSize(qualityInfos[1].iconSmall), 
				quantities[2], CreateAtlasMarkupWithAtlasSize(qualityInfos[2].iconSmall)));
		elseif qualityInfosSize == 3 then
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_ALLOCATIONS_TOOLTIP:format(
				quantities[1], CreateAtlasMarkupWithAtlasSize(qualityInfos[1].iconSmall),
				quantities[2], CreateAtlasMarkupWithAtlasSize(qualityInfos[2].iconSmall),
				quantities[3], CreateAtlasMarkupWithAtlasSize(qualityInfos[3].iconSmall)));
		else
			error(string.format("Unexpected quality info table size. size = %d, %s", qualityInfosSize,
				Professions.ReagentToString(reagent)));
		end
	end

	if (not noInstruction) and (not slot:IsUnallocatable()) then
		-- Add a blank line if one was not added above.
		if not hasMultipleAllocations then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
		end
		GameTooltip_AddInstructionLine(GameTooltip, BASIC_REAGENT_TOOLTIP_CLICK_TO_ALLOCATE);
	end
end

function Professions.GetReagentDisplayData(reagent)
	local data = {};
	local itemID = reagent.itemID;
	if itemID and itemID > 0 then
		local item = Item:CreateFromItemID(itemID);
		data.name = item:GetItemName();
		data.color = item:GetItemQualityColor().color;
	end

	local currencyID = reagent.currencyID;
	if currencyID and reagent.currencyID > 0 then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		data.name = currencyInfo.name;
		data.texture = currencyInfo.iconFileID;

		local quality = currencyInfo.quality;
		local colorData = ColorManager.GetColorDataForItemQuality(quality);
		data.color = colorData.color;
	end
	return data;
end

function Professions.GetReagentName(reagent)
	local displayData = Professions.GetReagentDisplayData(reagent);
	return displayData.name or UNKNOWN;
end

function Professions.SetupOptionalReagentTooltip(slot, transaction, reagentSlotSchematic, suppressInstruction, exchangeOnly)
	local reagentType = reagentSlotSchematic.reagentType;
	local reagent =  slot.Button:GetReagent();
	if reagent then
		Professions.AddTooltipInfo(reagent, GameTooltip, transaction);

		if (not suppressInstruction) and not (slot:IsUnallocatable()) then
			if exchangeOnly then
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddInstructionLine(GameTooltip, OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_EXCHANGE);
			else
				local instruction;
				if reagentType == Enum.CraftingReagentType.Finishing then
					instruction = FINISHING_REAGENT_TOOLTIP_CLICK_TO_REMOVE;
				elseif not ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
					instruction = OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_REMOVE;
				end

				if instruction then
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddInstructionLine(GameTooltip, instruction);
				end
			end
		end
		return;
	end

	local slotText = reagentSlotSchematic.slotInfo.slotText;
	local title;
	if reagentType == Enum.CraftingReagentType.Finishing then
		title = FINISHING_REAGENT_TOOLTIP_TITLE:format(slotText);
	else
		title = slotText or OPTIONAL_REAGENT_POSTFIX;
	end

	GameTooltip_SetTitle(GameTooltip, title, nil, false);

	if (not suppressInstruction) and not (slot:IsUnallocatable()) then
		local instruction;
		if reagentType == Enum.CraftingReagentType.Finishing then
			instruction = FINISHING_REAGENT_TOOLTIP_CLICK_TO_ADD;
		elseif ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
			instruction = REQUIRED_REAGENT_TOOLTIP_CLICK_TO_ADD;
		else
			instruction = OPTIONAL_REAGENT_TOOLTIP_CLICK_TO_ADD;
		end

		GameTooltip_AddInstructionLine(GameTooltip, instruction);
	end
end

local function AllocateReagents(allocations, reagentSlotSchematic, useBestQuality, useCharacterInventoryOnly)
	allocations:Clear();

	local quantityRequired = reagentSlotSchematic.quantityRequired;
	local iterator = useBestQuality and ipairs_reverse or ipairs;
	for reagentIndex, reagent in iterator(reagentSlotSchematic.reagents) do
		local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, useCharacterInventoryOnly);
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
		AllocateReagents(allocations, reagentSlotSchematic, useBestQuality, transaction:ShouldUseCharacterInventoryOnly());
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

function Professions.CanAllocateReagents(transaction, slotIndex)
	local reagentSlotSchematic = transaction:GetReagentSlotSchematic(slotIndex);
	local quantityRequired = reagentSlotSchematic.quantityRequired;
	for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
		local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, transaction:ShouldUseCharacterInventoryOnly());
		quantityRequired = quantityRequired - quantity;

		if quantityRequired <= 0 then
			return true;
		end
	end

	return false;
end

function Professions.InspectRecipe(recipeID)
	InspectRecipeFrame:Open(recipeID);
end

function Professions.HandleItemReagentLink(link)
	if not HandleModifiedItemClick(link) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		return false, link;
	end
	return true, link;
end

function Professions.HandleCurrencyReagentLink(link)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	-- No global currency handler at this time.
	return false, link;
end

function Professions.HandleReagentLink(reagent, count)
	local itemID = reagent.itemID;
	if itemID then
		local link = ItemUtil.GetItemHyperlink(itemID);
		return Professions.HandleItemReagentLink(link);
	end

	local currencyID = reagent.currencyID;
	if currencyID then
		local link = C_CurrencyInfo.GetCurrencyLink(currencyID, count or 1);
		return Professions.HandleCurrencyReagentLink(link);
	end
end

function Professions.CreateReagentFromLink(link)
	local currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(link);
	if currencyID > 0 then
		return Professions.CreateCurrencyReagent(currencyID);
	end

	local itemID = GetItemInfoFromHyperlink(link);
	if itemID then
		return Professions.CreateItemReagent(itemID);
	end
end

function Professions.HandleFixedReagentLink(recipeID, reagentSlotSchematic)
	local handled, link = false, nil;

	local reagent = reagentSlotSchematic.reagents[1];
	local dataSlotType = reagentSlotSchematic.dataSlotType;
	if dataSlotType == Enum.TradeskillSlotDataType.Reagent then
		link = ItemUtil.GetItemHyperlink(reagent.itemID);
		handled = Professions.HandleItemReagentLink(link);
	elseif dataSlotType == Enum.TradeskillSlotDataType.Currency then
		local quantity = reagentSlotSchematic.quantityRequired;
		link = C_CurrencyInfo.GetCurrencyLink(reagent.currencyID, quantity);
		handled = Professions.HandleCurrencyReagentLink(link);
	end

	if not handled then
		Professions.TriggerReagentClickedEvent(link);
	end
end

function Professions.HandleQualityReagentLink(recipeID, reagentSlotSchematic, qualityIndex)
	local link = C_TradeSkillUI.GetRecipeQualityReagentLink(recipeID, reagentSlotSchematic.dataSlotIndex, qualityIndex);
	local handled = Professions.HandleItemReagentLink(link);

	if not handled then
		Professions.TriggerReagentClickedEvent(link);
	end
end

function Professions.TriggerReagentClickedEvent(link)
	if not link then
		return;
	end

	local reagent = Professions.CreateReagentFromLink(link);
	if reagent then
		EventRegistry:TriggerEvent("Professions.ReagentClicked", reagent);
	end
end

function Professions.FindFirstQualityAllocated(transaction, reagentSlotSchematic)
	local quantities = Professions.GetQuantitiesAllocated(transaction, reagentSlotSchematic);
	local function IsNonZeroQuantity(quantity)
		return quantity > 0;
	end
	return FindInTableIf(quantities, IsNonZeroQuantity);
end

function Professions.GetReagentInputMode(reagentSlotSchematic)
	if reagentSlotSchematic and reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
		local count = #reagentSlotSchematic.reagents;
		if count == 1 then
			return Professions.ReagentInputMode.Fixed;
		end

		return Professions.ReagentInputMode.Quality;
	end

	return Professions.ReagentInputMode.Any;
end

local function SortRootData(lhs, rhs)
	local lhsData = lhs:GetData();
	local rhsData = rhs:GetData();
	local lhsGroup = lhsData.group;
	local rhsGroup = rhsData.group;

	if lhsGroup ~= rhsGroup then
		return lhsGroup < rhsGroup;
	end

	local lhsCategoryInfo = lhsData.categoryInfo;
	local rhsCategoryInfo = rhsData.categoryInfo;
	local lhsOrder = lhsCategoryInfo.uiOrder;
	local rhsOrder = rhsCategoryInfo.uiOrder;
	if lhsOrder ~= rhsOrder then
		return lhsOrder < rhsOrder;
	end

	return strcmputf8i(lhsCategoryInfo.name, rhsCategoryInfo.name) < 0;
end

local function SortCategoryData(lhs, rhs)
	local lhsData = lhs:GetData();
	local rhsData = rhs:GetData();
	local lhsCategoryInfo = lhsData.categoryInfo;
	local rhsCategoryInfo = rhsData.categoryInfo;

	if lhsCategoryInfo or rhsCategoryInfo then
		if lhsCategoryInfo and not rhsCategoryInfo then
			return true;
		elseif not lhsCategoryInfo and rhsCategoryInfo then
			return false;
		elseif lhsCategoryInfo and rhsCategoryInfo then
			local lhsOrder = lhsCategoryInfo.uiOrder;
			local rhsOrder = rhsCategoryInfo.uiOrder;
			if lhsOrder ~= rhsOrder then
				return lhsOrder < rhsOrder;
			end

			return strcmputf8i(lhsCategoryInfo.name, rhsCategoryInfo.name) < 0;
		end
	end

	local lhsOrder = lhsData.order;
	local rhsOrder = rhsData.order;
	if lhsOrder ~= rhsOrder then
		return lhsOrder < rhsOrder;
	end

	local lhsRecipeInfo = lhsData.recipeInfo;
	local rhsRecipeInfo = rhsData.recipeInfo;
	local lhsDifficulty = lhsRecipeInfo.difficulty;
	local rhsDifficulty = rhsRecipeInfo.difficulty;
	if lhsDifficulty ~= rhsDifficulty then
		return lhsDifficulty < rhsDifficulty;
	end

	local lhsMaxTrivialLevel = lhsRecipeInfo.maxTrivialLevel;
	local rhsMaxTrivialLevel = rhsRecipeInfo.maxTrivialLevel;
	if lhsMaxTrivialLevel ~= rhsMaxTrivialLevel then
		return lhsMaxTrivialLevel > rhsMaxTrivialLevel;
	end

	local lhsItemLevel = lhsRecipeInfo.itemLevel;
	local rhsItemLevel = rhsRecipeInfo.itemLevel;
	if lhsItemLevel ~= rhsItemLevel then
		return lhsItemLevel > rhsItemLevel;
	end

	return strcmputf8i(lhsRecipeInfo.name, rhsRecipeInfo.name) < 0;
end

local Group = EnumUtil.MakeEnum("Favorite", "Learned", "UnlearnedDivider", "Unlearned");
local favoritesCategoryID = -1; --used for remembering collapse state

function Professions.GenerateCraftingDataProvider(professionID, searching, noStripCategories, collapses)
	local recipeInfos = {};
	local favoritesCategoryInfo = {name = PROFESSIONS_CATEGORY_FAVORITE, uiOrder = 0, group = Group.Favorite, categoryID = favoritesCategoryID};
	local showAllRecipes = searching or C_TradeSkillUI.IsNPCCrafting();
	local favoriteRecipeIDs = {};
	for index, recipeID in ipairs(C_TradeSkillUI.GetFilteredRecipeIDs()) do
		local recipeInfo = Professions.GetFirstRecipe(C_TradeSkillUI.GetRecipeInfo(recipeID));
		local showRecipe = showAllRecipes or C_TradeSkillUI.IsRecipeInSkillLine(recipeID, professionID);
		if showRecipe then
			recipeInfos[recipeInfo.recipeID] = recipeInfo;
		end
		if not searching and recipeInfo.favorite and not favoriteRecipeIDs[recipeInfo.recipeID] then
			local favoritesRecipeInfo = CopyTable(recipeInfo);
			favoritesRecipeInfo.favoritesInstance = true;

			if not favoritesCategoryInfo.recipes then
				favoritesCategoryInfo.recipes = {};
			end
			table.insert(favoritesCategoryInfo.recipes, favoritesRecipeInfo);
			favoriteRecipeIDs[recipeInfo.recipeID] = true;
		end
	end

	local favoritesCategoryMap = {favoritesCategoryInfo};
	local learnedCategoryMap = {};
	local unlearnedCategoryMap = {};
	local categoryMaps = { learnedCategoryMap, unlearnedCategoryMap };

	local dataProvider = CreateTreeDataProvider();
	-- Create a category hierarchy for each recipe. Learned and unlearned recipes are now separated into potentially
	-- identical but cloned hierarchies for the sake of organization.
	do
		local function CreateCategoryInfoRecursive(categoryMap, categoryID, group, unlearned)
			local categoryInfo = categoryMap[categoryID];
			if not categoryInfo then
				categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryID);
				if categoryInfo then
					categoryInfo.group = group;
					categoryInfo.unlearned = unlearned;
					categoryMap[categoryID] = categoryInfo;
				end
			end

			if categoryInfo and categoryInfo.parentCategoryID then
				CreateCategoryInfoRecursive(categoryMap, categoryInfo.parentCategoryID, group, unlearned);
			end

			return categoryInfo;
		end

		for index, recipeInfo in pairs(recipeInfos) do
			local learned = recipeInfo.learned;
			local categoryMap = learned and learnedCategoryMap or unlearnedCategoryMap;
			local group = learned and Group.Learned or Group.Unlearned;
			local categoryInfo = CreateCategoryInfoRecursive(categoryMap, recipeInfo.categoryID, group, not learned);
			if categoryInfo then
				if not categoryInfo.recipes then
					categoryInfo.recipes = {};
				end
				table.insert(categoryInfo.recipes, recipeInfo);
			end
		end
	end

	local discardRootCategories = not searching or C_TradeSkillUI.IsNPCCrafting();
	if discardRootCategories then
		-- Strip out every category if it doesnt have any recipes. The intention here is to remove
		-- "header" categories (roots), but we can't isolate those easily. Once we've tagged categories as being
		-- visible in the default view we can be more specific in the culling. For an example of a root category 
		-- that has recipes, see ID 390.
		for _, category in ipairs(Professions.GetProfessionCategories()) do
			local categoryID = category.categoryID;
			if not noStripCategories or not tContains(noStripCategories, categoryID) then
				for _, categoryMap in ipairs(categoryMaps) do
					local categoryInfo = categoryMap[categoryID];
					if categoryInfo and not categoryInfo.recipes then
						categoryMap[categoryID] = nil;
					end
				end
			end
		end
	end

	-- Insert the categories into the tree, using the group category data as the root parent.
	if next(recipeInfos) ~= nil then
		local maps = {};
		if favoritesCategoryInfo.recipes and next(favoritesCategoryInfo.recipes) ~= nil then
			table.insert(maps, favoritesCategoryMap);
		end
		tAppendAll(maps, categoryMaps);
		
		do
			local function SetSortComparator(node)
				local affectChildren = false;
				local skipSort = false;
				node:SetSortComparator(SortCategoryData, affectChildren, skipSort);
			end
			
			local categoryNodes = {};
			local addedRecipe = false;
			local function AttachTreeDataRecursive(categoryMap, categoryNodes, categoryInfo, node)
				-- The root and any nodes passed as categories need a sort comparator.
				if not node:HasSortComparator() then
					SetSortComparator(node);
				end

				local parentCategoryID = categoryInfo.parentCategoryID;
				local parentCategoryInfo = categoryMap[parentCategoryID];
				if parentCategoryInfo then
					node = AttachTreeDataRecursive(categoryMap, categoryNodes, parentCategoryInfo, node);
				end

				local categoryNode = categoryNodes[categoryInfo];
				if not categoryNode then
					assert(categoryInfo.group ~= nil, "Missing group for category '%s' ", categoryInfo.name);
					categoryNode = node:Insert({categoryInfo = categoryInfo, group = categoryInfo.group});
					categoryNodes[categoryInfo] = categoryNode;

					-- The new category can have categories or recipes.
					SetSortComparator(categoryNode);
					if collapses and collapses[categoryInfo.categoryID] then
						categoryNode:SetCollapsed(true);
					end
				end

				if categoryInfo.recipes and #categoryInfo.recipes > 0 then
					categoryNode:Insert({topPadding=true, order = -1});
					for index, recipeInfo in ipairs(categoryInfo.recipes) do
						categoryNode:Insert({recipeInfo = recipeInfo, order = 0});
						addedRecipe = true;
						-- Recipes are leaf-most, so we don't need any sort comparator.
					end
					categoryNode:Insert({bottomPadding=true, order = 1});
				end	

				return categoryNode;
			end

			local addUnlearnedDivider = false;
			local addedKnownRecipe = false;
			local node = dataProvider:GetRootNode();

			local affectChildren = false;
			local skipSort = false;
			node:SetSortComparator(SortRootData, affectChildren, skipSort);

			for _, categoryMap in ipairs(maps) do
				for _, categoryInfo in pairs(categoryMap) do
					AttachTreeDataRecursive(categoryMap, categoryNodes, categoryInfo, node);
				end
				addUnlearnedDivider = addUnlearnedDivider or (addedRecipe and categoryMap == unlearnedCategoryMap);
				addedKnownRecipe = addedKnownRecipe or (addedRecipe and categoryMap == learnedCategoryMap);
				addedRecipe = false;
			end

			if addUnlearnedDivider and C_TradeSkillUI.GetShowUnlearned() then
				-- Categories and dividers ordered by group, position this divider just before the unlearned group.
				node:Insert({isDivider = true, dividerHeight = addedKnownRecipe and 70 or 30, group = Group.UnlearnedDivider});
			end
		end
	end

	return dataProvider;
end

local function GetBestQualityCVar(forCustomer)
	return forCustomer and "professionsAllocateBestQualityReagentsCustomer" or "professionsAllocateBestQualityReagents";
end

function Professions.ShouldAllocateBestQualityReagents(forCustomer)
	return GetCVarBool(GetBestQualityCVar(forCustomer));
end

function Professions.SetShouldAllocateBestQualityReagents(shouldUse, forCustomer)
	SetCVar(GetBestQualityCVar(forCustomer), shouldUse);
end

function Professions.SetDefaultOrderDuration(index)
	SetCVar("professionsOrderDurationDropdown", index);
end

function Professions.GetDefaultOrderDuration()
	local duration = tonumber(GetCVar("professionsOrderDurationDropdown"));
	if not duration or duration < Enum.CraftingOrderDuration.Short or duration > Enum.CraftingOrderDuration.Long then
		duration = Enum.CraftingOrderType.Medium;
	end
	return duration;
end

function Professions.SetDefaultOrderRecipient(index)
	SetCVar("professionsOrderRecipientDropdown", index);
end

function Professions.GetDefaultOrderRecipient()
	local recipient = tonumber(GetCVar("professionsOrderRecipientDropdown"));
	if recipient == Enum.CraftingOrderType.Guild and not IsInGuild() then
		recipient = Enum.CraftingOrderType.Public;
	end
	if not recipient or recipient < Enum.CraftingOrderType.Public or recipient > Enum.CraftingOrderType.Personal then
		recipient = Enum.CraftingOrderType.Public;
	end
	return recipient;
end

function Professions.GetChatIconMarkupForQuality(qualityInfo, small, overrideOffsetY)
	local atlas = qualityInfo.iconChat;
	local offsetX = nil;
	local offsetY = overrideOffsetY or (small and 0 or 1);
	local rVertexColor = nil;
	local gVertexColor = nil;
	local bVertexColor = nil;
	local scale = small and 0.4 or 0.5;
	return CreateAtlasMarkupWithAtlasSize(atlas, offsetX, offsetY, rVertexColor, gVertexColor, bVertexColor, scale);
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

function Professions.IsUsingDefaultFilters(ignoreSkillLine)
	local showAllRecipes = not C_TradeSkillUI.GetOnlyShowMakeableRecipes() and 
		not C_TradeSkillUI.GetOnlyShowSkillUpRecipes() and 
		not C_TradeSkillUI.GetOnlyShowFirstCraftRecipes();
	local newestKnownProfessionInfo = Professions.GetNewestKnownProfessionInfo();
	local isDefaultSkillLine = ignoreSkillLine or newestKnownProfessionInfo == nil or (Professions.GetProfessionInfo().professionID == Professions.GetNewestKnownProfessionInfo().professionID);
	return showAllRecipes and isDefaultSkillLine and not C_TradeSkillUI.AreAnyInventorySlotsFiltered() and 
		not C_TradeSkillUI.AnyRecipeCategoriesFiltered() and Professions.AreAllSourcesUnfiltered() and C_TradeSkillUI.GetShowUnlearned() and C_TradeSkillUI.GetShowLearned();
end


function Professions.SetAllInventorySlotsFiltered(filtered)
	local numSources = C_TradeSkillUI.GetAllFilterableInventorySlotsCount();
	for i = 1, numSources do
		C_TradeSkillUI.SetInventorySlotFilter(i, filtered);
	end

	return MenuResponse.Refresh;
end

function Professions.SetAllSourcesFiltered(filtered)
	local numSources = C_PetJournal.GetNumPetSources();
	if filtered then
		for i = 1, numSources do
			if C_TradeSkillUI.IsAnyRecipeFromSource(i) then
				C_TradeSkillUI.SetRecipeSourceTypeFilter(i, filtered);
			end
		end
	else
		C_TradeSkillUI.ClearRecipeSourceTypeFilter();
	end

	return MenuResponse.Refresh;
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

function Professions.SetDefaultFilters(ignoreSkillLine)
	C_TradeSkillUI.SetShowLearned(true);
	C_TradeSkillUI.SetShowUnlearned(true);
	C_TradeSkillUI.SetOnlyShowMakeableRecipes(false);
	C_TradeSkillUI.SetOnlyShowSkillUpRecipes(false);
	C_TradeSkillUI.SetOnlyShowFirstCraftRecipes(false);
	C_TradeSkillUI.ClearInventorySlotFilter();
	Professions.SetAllSourcesFiltered(false);
	C_TradeSkillUI.ClearRecipeSourceTypeFilter();
	C_TradeSkillUI.ClearRecipeCategoryFilter();

	-- Default filters are set when opening the UI, however we want want to stomp the desired
	-- profession info when we're talking to an NPC crafter.
	if not ignoreSkillLine and not C_TradeSkillUI.IsNPCCrafting() then
		local newestKnownProfessionInfo = Professions.GetNewestKnownProfessionInfo();
		if newestKnownProfessionInfo then
			EventRegistry:TriggerEvent("Professions.SelectSkillLine", newestKnownProfessionInfo);
		end
	end
end

function Professions.GetCurrentFilterSet()
	local filterSet =
	{
		textFilter = C_TradeSkillUI.GetRecipeItemNameFilter(),
		showOnlyMakeable = C_TradeSkillUI.GetOnlyShowMakeableRecipes(),
		showOnlySkillUps = C_TradeSkillUI.GetOnlyShowSkillUpRecipes(),
		showOnlyFirstCraft = C_TradeSkillUI.GetOnlyShowFirstCraftRecipes(),
		professionInfo = C_TradeSkillUI.GetChildProfessionInfo(),
		showUnlearned = C_TradeSkillUI.GetShowUnlearned(),
		showLearned = C_TradeSkillUI.GetShowLearned(),
		sourceTypeFilter = C_TradeSkillUI.GetSourceTypeFilter(),
	};

	filterSet.invTypeFilters = {};
	for idx = 1, C_TradeSkillUI.GetAllFilterableInventorySlotsCount() do
		filterSet.invTypeFilters[idx] = C_TradeSkillUI.IsInventorySlotFiltered(idx);
	end
	return filterSet;
end

function Professions.ApplyfilterSet(filterSet)
	if filterSet then
		Professions.OnRecipeListSearchTextChanged(filterSet.textFilter);
		C_TradeSkillUI.SetShowLearned(filterSet.showLearned);
		C_TradeSkillUI.SetShowUnlearned(filterSet.showUnlearned);
		C_TradeSkillUI.SetOnlyShowMakeableRecipes(filterSet.showOnlyMakeable);
		C_TradeSkillUI.SetOnlyShowSkillUpRecipes(filterSet.showOnlySkillUps);
		C_TradeSkillUI.SetOnlyShowFirstCraftRecipes(filterSet.showOnlyFirstCraft);
		C_TradeSkillUI.SetSourceTypeFilter(filterSet.sourceTypeFilter);

		for idx, filtered in ipairs(filterSet.invTypeFilters) do
			C_TradeSkillUI.SetInventorySlotFilter(idx, not filtered);
		end

		if filterSet.professionInfo then
			EventRegistry:TriggerEvent("Professions.SelectSkillLine", filterSet.professionInfo);
		end
	else
		Professions.OnRecipeListSearchTextChanged("");
		Professions.SetDefaultFilters();
	end
end

function Professions.GetNewestKnownProfessionInfo()
	for index, professionInfo in ipairs(C_TradeSkillUI.GetChildProfessionInfos()) do
		if professionInfo.skillLevel > 0 then
			return professionInfo;
		end
	end
end

function Professions.InitFilterMenu(dropdown, onUpdate, onDefault, ignoreSkillLine)
	dropdown:SetDefaultCallback(function()
		Professions.SetDefaultFilters(ignoreSkillLine);
		
		if onDefault then
			onDefault();
		end
	end);
	
	dropdown:SetUpdateCallback(onUpdate);

	dropdown:SetIsDefaultCallback(function()
		return Professions.IsUsingDefaultFilters(ignoreSkillLine);
	end);
	
	local function IsSourceChecked(filterIndex) 
		return not C_TradeSkillUI.IsRecipeSourceTypeFiltered(filterIndex);
	end

	local function SetSourceChecked(filterIndex) 
		C_TradeSkillUI.SetRecipeSourceTypeFilter(filterIndex, IsSourceChecked(filterIndex));
	end
	
	local function IsSlotChecked(filterIndex) 
		return not C_TradeSkillUI.IsInventorySlotFiltered(filterIndex);
	end

	local function SetSlotChecked(filterIndex) 
		C_TradeSkillUI.SetInventorySlotFilter(filterIndex, not IsSlotChecked(filterIndex));
	end

	local function IsExpansionChecked(professionInfo) 
		return C_TradeSkillUI.GetChildProfessionInfo().professionID == professionInfo.professionID;
	end

	local function SetExpansionChecked(professionInfo) 
		EventRegistry:TriggerEvent("Professions.SelectSkillLine", professionInfo);
	end

	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_FILTER");

		local isGatheringProfession = Professions.GetProfessionType(Professions.GetProfessionInfo()) == Professions.ProfessionType.Gathering;
		local isNPCCrafting = C_TradeSkillUI.IsNPCCrafting();

		rootDescription:CreateCheckbox(PROFESSION_RECIPES_SHOW_LEARNED, C_TradeSkillUI.GetShowLearned, function()
			C_TradeSkillUI.SetShowLearned(not C_TradeSkillUI.GetShowLearned());
		end);

		rootDescription:CreateCheckbox(PROFESSION_RECIPES_SHOW_UNLEARNED, C_TradeSkillUI.GetShowUnlearned, function()
			C_TradeSkillUI.SetShowUnlearned(not C_TradeSkillUI.GetShowUnlearned());
		end);

		if not C_TradeSkillUI.IsTradeSkillGuild() then
			local professionInfo = Professions.GetProfessionInfo();
			if not (isNPCCrafting and professionInfo.maxSkillLevel == 0) then
				rootDescription:CreateCheckbox(TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI.GetOnlyShowSkillUpRecipes, function()
					C_TradeSkillUI.SetOnlyShowSkillUpRecipes(not C_TradeSkillUI.GetOnlyShowSkillUpRecipes());
				end);
			end
		end

		if not isNPCCrafting and not isGatheringProfession then
			rootDescription:CreateCheckbox(PROFESSION_RECIPES_IS_FIRST_CRAFT, C_TradeSkillUI.GetOnlyShowFirstCraftRecipes, function()
				C_TradeSkillUI.SetOnlyShowFirstCraftRecipes(not C_TradeSkillUI.GetOnlyShowFirstCraftRecipes());
			end);
		end

		rootDescription:CreateCheckbox(CRAFT_IS_MAKEABLE, C_TradeSkillUI.GetOnlyShowMakeableRecipes, function()
			C_TradeSkillUI.SetOnlyShowMakeableRecipes(not C_TradeSkillUI.GetOnlyShowMakeableRecipes());
		end);

		if not isNPCCrafting then
			local sourceSubmenu = rootDescription:CreateButton(SOURCES);
			sourceSubmenu:CreateButton(CHECK_ALL, Professions.SetAllSourcesFiltered, false);
			sourceSubmenu:CreateButton(UNCHECK_ALL, Professions.SetAllSourcesFiltered, true);

			for filterIndex = 1, C_PetJournal.GetNumPetSources() do
				if C_TradeSkillUI.IsAnyRecipeFromSource(filterIndex) then
					sourceSubmenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsSourceChecked, SetSourceChecked, filterIndex);
				end
			end
		end

		if not isGatheringProfession then
			local slotsSubmenu = rootDescription:CreateButton(TRADESKILL_FILTER_SLOTS);
			slotsSubmenu:CreateButton(CHECK_ALL, Professions.SetAllInventorySlotsFiltered, true);
			slotsSubmenu:CreateButton(UNCHECK_ALL, Professions.SetAllInventorySlotsFiltered, false);

			for filterIndex = 1, C_TradeSkillUI.GetAllFilterableInventorySlotsCount() do
				local name = C_TradeSkillUI.GetFilterableInventorySlotName(filterIndex);
				slotsSubmenu:CreateCheckbox(name, IsSlotChecked, SetSlotChecked, filterIndex);
			end
		end

		if not ignoreSkillLine and not isNPCCrafting then
			local childProfessionInfos = C_TradeSkillUI.GetChildProfessionInfos();
			if #childProfessionInfos > 0 then
				rootDescription:CreateSpacer();

				for index, professionInfo in ipairs(childProfessionInfos) do
					rootDescription:CreateRadio(professionInfo.expansionName, IsExpansionChecked, SetExpansionChecked, professionInfo);
				end
			end
		end
	end);
end

function Professions.OnRecipeListSearchTextChanged(text)
	if strcmputf8i(C_TradeSkillUI.GetRecipeItemNameFilter(), text) == 0 then
		return;
	end

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


function Professions.LayoutReagentSlots(slots, slotContainer, spacingX, spacingY, stride, direction)
	if slots then
		local layout = AnchorUtil.CreateGridLayout(direction, stride, spacingX, spacingY);
		local anchor = CreateAnchor("TOPLEFT", slotContainer, "TOPLEFT", 1, -20);
		AnchorUtil.GridLayout(slots, anchor, layout);
		slotContainer:Layout();
	end
end

function Professions.LayoutAndShowReagentSlotContainer(slots, slotContainer)
	local slotsShown = slots and #slots > 0;
	if slotsShown then
		local stride = 4;
		local spacing = 3;
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, spacing, spacing, 40, 40);
		local anchor = CreateAnchor("TOPLEFT", slotContainer, "TOPLEFT", 1, -20);
		AnchorUtil.GridLayout(slots, anchor, layout);
		slotContainer:Layout();
	end
	slotContainer:SetShown(slotsShown);
end

function Professions.LayoutFinishingSlots(finishingSlots, finishingSlotContainer)
	if finishingSlots then
		local stride = 2;
		local spacing = 8;
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, spacing, spacing, 40);
			
		local anchor;
		if #finishingSlots == 1 then
			anchor = CreateAnchor("TOP", finishingSlotContainer, "TOP", 69, -40)
		else
			anchor = CreateAnchor("TOPLEFT", finishingSlotContainer, "TOPLEFT", 22, -40)
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

function Professions.GetProfessionSpecializationBackgroundAtlas(professionInfo, forPreview)
	local atlasFmt = forPreview and "Professions-Specializations-Preview-Art-%s" or "Professions-Specializations-Background-%s";
	return GetProfessionBackground(professionInfo, atlasFmt);
end

function Professions.CanTrackRecipe(recipeInfo)
	if Professions.IsViewingExternalCraftingList() then
		return false;
	end

	if C_TradeSkillUI.IsRuneforging() then
		return false;
	end

	if recipeInfo.isSalvageRecipe or recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe or recipeInfo.isRecraft then
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

function Professions.PrepareRecipeRecraft(transaction, craftingReagentTbl)
	local removedModifications = {};
	local modifications = transaction:GetRecraftItemMods();
	if not modifications then
		return removedModifications;
	end

	-- FIXME Needs a comment, the original one was not helpful. See callsite of PrepareRecipeRecraft to better
	-- understand the purpose of the comparisons.
	for dataSlotIndex, modification in ipairs(modifications) do
		if Professions.IsValidReagent(modification.reagent) then
			local shouldRemoveMod = true;

			for reagentInfoIndex, craftingReagentInfo in ipairs_reverse(craftingReagentTbl) do
				if Professions.DoesModificationContainReagent(modification, craftingReagentInfo.reagent) then
					shouldRemoveMod = false;

					if craftingReagentInfo.dataSlotIndex == modification.dataSlotIndex then
						table.remove(craftingReagentTbl, reagentInfoIndex);
						break;
					end
				end
			end

			if shouldRemoveMod then
				table.insert(removedModifications, modification);
			end
		end
	end

	return removedModifications;
end

function Professions.AnyRecraftablePredicate(itemGUID)
	local craftRecipeID, craftSkillLineAbility = C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID);
	return craftSkillLineAbility ~= nil and C_CraftingOrders.CanOrderSkillAbility(craftSkillLineAbility);
end

function Professions.GetProfessionType(professionInfo)
	local profession = professionInfo.profession;

	if profession == Enum.Profession.Mining or profession == Enum.Profession.Herbalism or profession == Enum.Profession.Skinning or profession == Enum.Profession.Fishing then
		return Professions.ProfessionType.Gathering;
	end

	return Professions.ProfessionType.Crafting;
end

function Professions.GetCraftingOrderRemainingTime(endTime)
	return math.max(endTime - C_CraftingOrders.GetCraftingOrderTime(), 0);
end

function Professions.IsRecipeOnCooldown(recipeID)
	local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(recipeID);
	if not cooldown then
		return false;
	end

	if charges > 0 then
		return false;
	end

	return true;
end

function Professions.CreateNewOrderInfo(itemID, spellID, skillLineAbilityID, isRecraft, unusableBOP)
	local newOrder =
	{
		itemID = itemID,
		spellID = spellID,
		skillLineAbilityID = skillLineAbilityID,
		orderType = Professions.GetDefaultOrderRecipient(),
		orderState = Enum.CraftingOrderState.None,
		tipAmount = 0,
		isRecraft = isRecraft,
		minQuality = 1,
		unusableBOP = unusableBOP,
	};

	return newOrder
end

ProfessionsSortOrder = EnumUtil.MakeEnum("Name", "Tip", "Reagents", "Quality", "Expiration", "ItemName", "Ilvl", "Slots", "Level", "Skill", "Status",
										 "AverageTip", "MaxTip", "NumAvailable", "CustomerName");
									 
local SortOrderToSortEnum =
{
	[ProfessionsSortOrder.ItemName] = Enum.CraftingOrderSortType.ItemName,
	[ProfessionsSortOrder.AverageTip] = Enum.CraftingOrderSortType.AveTip,
	[ProfessionsSortOrder.MaxTip] = Enum.CraftingOrderSortType.MaxTip,
	[ProfessionsSortOrder.NumAvailable] = Enum.CraftingOrderSortType.Quantity,
	[ProfessionsSortOrder.Reagents] = Enum.CraftingOrderSortType.Reagents,
	[ProfessionsSortOrder.Tip] = Enum.CraftingOrderSortType.Tip,
	[ProfessionsSortOrder.Expiration] = Enum.CraftingOrderSortType.TimeRemaining,
	[ProfessionsSortOrder.Status] = Enum.CraftingOrderSortType.Status,
};

function Professions.TranslateSearchSort(sort)
	if not sort or not SortOrderToSortEnum[sort.order] then
		return nil;
	end

	local translatedSort = 
	{
		sortType = SortOrderToSortEnum[sort.order],
		reversed = not sort.ascending,
	};
	return translatedSort;
end

-- See CraftingOrderInfo for table definition
function Professions.ApplySortOrder(sortOrder, lhs, rhs)
	if sortOrder == ProfessionsSortOrder.ItemName then
		local lhsItem = Item:CreateFromItemID(lhs.option.itemID);
		local rhsItem = Item:CreateFromItemID(rhs.option.itemID);
		local lhsItemName = lhsItem:GetItemName();
		local rhsItemName = rhsItem:GetItemName();
		return SortUtil.CompareUtf8i(lhsItemName, rhsItemName), lhsItemName == rhsItemName;

	elseif sortOrder == ProfessionsSortOrder.Status then
		return SortUtil.CompareNumeric(lhs.option.orderState, rhs.option.orderState), lhs.option.orderState == rhs.option.orderState;

	elseif sortOrder == ProfessionsSortOrder.Expiration then
		local lhsRemainingTime = Professions.GetCraftingOrderRemainingTime(lhs.option.expirationTime);
		local rhsRemainingTime = Professions.GetCraftingOrderRemainingTime(rhs.option.expirationTime);
		return SortUtil.CompareNumeric(lhsRemainingTime, rhsRemainingTime), lhsRemainingTime == rhsRemainingTime;

	elseif sortOrder == ProfessionsSortOrder.AverageTip then
		return SortUtil.CompareNumeric(lhs.option.tipAmountAvg, rhs.option.tipAmountAvg), lhs.option.tipAmountAvg == rhs.option.tipAmountAvg;

	elseif sortOrder == ProfessionsSortOrder.MaxTip then
		return SortUtil.CompareNumeric(lhs.option.tipAmountMax, rhs.option.tipAmountMax), lhs.option.tipAmountMax == rhs.option.tipAmountMax;

	elseif sortOrder == ProfessionsSortOrder.NumAvailable then
		return SortUtil.CompareNumeric(lhs.option.numAvailable, rhs.option.numAvailable), lhs.option.numAvailable == rhs.option.numAvailable;

	elseif sortOrder == ProfessionsSortOrder.Reagents then
		return SortUtil.CompareNumeric(lhs.option.reagentState, rhs.option.reagentState), lhs.option.reagentState == rhs.option.reagentState;

	elseif sortOrder == ProfessionsSortOrder.Tip then
		return SortUtil.CompareNumeric(lhs.option.tipAmount, rhs.option.tipAmount), lhs.option.tipAmount == rhs.option.tipAmount;

	end

	return nil, false;
end

function Professions.GetProfessionInfo()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();

	-- Child profession info will be unavailable in some NPC crafting contexts. In these cases,
	-- use the base profession info instead.
	if professionInfo.professionID == 0 then
		professionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	end
	professionInfo.displayName = professionInfo.parentProfessionName and professionInfo.parentProfessionName or professionInfo.professionName;

	return professionInfo;
end

Professions.OrderTimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
Professions.OrderTimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
Professions.OrderTimeLeftFormatter:SetStripIntervalWhitespace(true);

function Professions.OrderTimeLeftFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

function Professions.OrderTimeLeftFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end
