local MaxColumns = 6;
local MaxRows = 6;
local MaxUnscrolledCount = MaxColumns * MaxRows;
local HideUnavailableCvar = "professionsFlyoutHideUnowned";

local function CreateDataProviderItemElement(item)
	return
	{
		item = item,
		reagent = Professions.CreateItemReagent(item:GetItemID()),
	};
end

local function PopulateDataProviderWithCurrencies(dataProvider, elements)
	if elements.currencyReagents then
		for index, reagent in ipairs(elements.currencyReagents) do
			dataProvider:Insert({reagent = reagent});
		end
	end
end

local function FilterReagentByQuantity(currencyReagent)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyReagent.currencyID);
	return currencyInfo.quantity > 0;
end

local function FilterCurrencyReagents(reagents, filterAvailable)
	local currencyReagents = Professions.FilterReagentsByCurrencyID(reagents);

	if not filterAvailable then
		return currencyReagents;
	end

	local isIndexTable = true;
	return tFilter(currencyReagents, FilterReagentByQuantity, isIndexTable);
end

local function OnElementEnterImplementation(reagent, tooltip, transaction, reagentSlotSchematic)
	Professions.AddTooltipInfo(reagent, tooltip, transaction);

	local canAllocate = true;
	local useCharacterInventoryOnly = transaction:ShouldUseCharacterInventoryOnly();
	local count = ProfessionsUtil.GetReagentQuantityInPossession(reagent, useCharacterInventoryOnly);
	if count <= 0 then
		canAllocate = false;
	else
		local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, useCharacterInventoryOnly);
		if quantity < reagentSlotSchematic:GetQuantityRequired(reagent) then
			canAllocate = false;
		end
	end

	local quantity = reagentSlotSchematic:GetQuantityRequired(reagent);
	local name = Professions.GetReagentName(reagent);
	local allocationText = string.format(REAGENT_TOOLTIP_ALLOCATION_REQUIREMENT, quantity, name);

	GameTooltip_AddBlankLineToTooltip(tooltip);

	if canAllocate then
		GameTooltip_AddInstructionLine(tooltip, allocationText);
	else
		GameTooltip_AddErrorLine(tooltip, allocationText);
	end
end

local ProfessionsFlyoutButtonMixin = {};

function ProfessionsFlyoutButtonMixin:UpdateState(count, elementData, behavior)
	local valid = behavior:IsElementValid(elementData);
	if valid then
		SetItemButtonTextureVertexColor(self, 1, 1, 1);
		SetItemButtonNormalTextureVertexColor(self, 1, 1, 1);
	else
		SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
		SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
	end

	self.enabled = valid and count > 0 and behavior:IsElementEnabled(elementData, count);
	self:DesaturateHierarchy(self.enabled and 0 or 1);
end

function ProfessionsFlyoutButtonMixin:IsEnabled()
	local enabled = getmetatable(self).__index.IsEnabled(self);
	return enabled and self.enabled;
end

ProfessionsFlyoutItemButtonMixin = CreateFromMixins(ProfessionsFlyoutButtonMixin);

local function FindItemLocation(elementData)
	local itemLocation = elementData.itemLocation;
	if itemLocation then
		return itemLocation;
	end

	local item = elementData.item;
	itemLocation = item:GetItemLocation();
	if itemLocation then
		return itemLocation;
	end

	local itemGUID = elementData.itemGUID;
	if itemGUID then
		itemLocation = C_Item.GetItemLocation(itemGUID);
		if itemLocation then
			return itemLocation;
		end
	end

	return nil;
end

function ProfessionsFlyoutItemButtonMixin:Init(elementData, behavior)
	local item = elementData.item;
	local itemID = item:GetItemID();
	local itemLocation = FindItemLocation(elementData);
	if itemLocation then
		self:SetItemLocation(itemLocation);
	else
		self:SetItem(item:GetItemID());
	end
	
	-- Stackable items would all normally be accumulated, however in the case of salvage targets, the stacks
	-- cannot be combined because the craft API requires a specific item guid target, and that prevents us from
	-- merging multiple item stacks together to fulfill the reagent count requirement.
	local count = 0;
	local forceAccumulateInventory = elementData.forceAccumulateInventory;
	local accumulateInventory = forceAccumulateInventory or not itemLocation or (item:IsStackable() and not elementData.onlyCountStack);
	if accumulateInventory then
		count = ItemUtil.GetCraftingReagentCount(itemID, elementData.useCharacterInventoryOnly);
	elseif itemLocation then
		count = C_Item.GetStackCount(itemLocation);
	end

	local showCount = forceAccumulateInventory or C_Item.GetItemMaxStackSizeByID(itemID) > 1;
	self:SetItemButtonCount(showCount and count or 1);

	self:UpdateState(count, elementData, behavior);
end

ProfessionsFlyoutCurrencyButtonMixin = CreateFromMixins(ProfessionsFlyoutButtonMixin);

function ProfessionsFlyoutCurrencyButtonMixin:Init(elementData, behavior)
	local currencyID = elementData.reagent.currencyID;
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	self:SetItemButtonCount(currencyInfo.quantity);
	self:SetItemButtonTexture(currencyInfo.iconFileID);

	self:UpdateState(currencyInfo.quantity, elementData, behavior);
end

ProfessionsFlyoutMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsFlyoutMixin:GenerateCallbackEvents(
{
    "UndoClicked",
    "ItemSelected",
    "ShiftClicked",
});

local ReagentFlyoutEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function ProfessionsFlyoutMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.Text:SetText(PROFESSIONS_PICKER_NO_AVAILABLE_REAGENTS);
	self.HideUnownedCheckbox.text:SetText(PROFESSIONS_HIDE_UNOWNED_REAGENTS);
	self.HideUnownedCheckbox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		SetCVar(HideUnavailableCvar, checked);

		self:InitializeContents();

		PlaySound(SOUNDKIT.UI_PROFESSION_HIDE_UNOWNED_REAGENTS_CHECKBOX);
	end);

	local view = CreateScrollBoxListGridView(MaxColumns);
	local padding = 3;
	local spacing = 3;
	view:SetPadding(padding, padding, padding, padding, spacing, spacing);

	local function ButtonInitializer(button, elementData)
		button:Init(elementData, self:GetBehavior());

		button:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");

			self:GetBehavior():OnElementEnter(elementData, GameTooltip);

			GameTooltip:Show();
		end);

		button:SetScript("OnLeave", GameTooltip_Hide);

		button:SetScript("OnClick", function()
			if IsShiftKeyDown() then
				self:TriggerEvent(ProfessionsFlyoutMixin.Event.ShiftClicked, self, elementData);
			else
				if button:IsEnabled() then
					self:TriggerEvent(ProfessionsFlyoutMixin.Event.ItemSelected, self, elementData);

					CloseProfessionsItemFlyout();
				end
			end
		end);
	end

	view:SetElementFactory(function(factory, elementData)
		if elementData.item then
			factory("ProfessionsFlyoutItemButtonTemplate", ButtonInitializer);
		else
			factory("ProfessionsFlyoutCurrencyButtonTemplate", ButtonInitializer);
		end
	end);

	self.UndoItem:SetScript("OnClick", function(button, buttonName, down)
		if not IsShiftKeyDown() then
			self:TriggerEvent(ProfessionsFlyoutMixin.Event.UndoClicked, self);

			CloseProfessionsItemFlyout();
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function ProfessionsFlyoutMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ReagentFlyoutEvents);
end

function ProfessionsFlyoutMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ReagentFlyoutEvents);
	
	self:UnregisterEvents();

	self.ScrollBox:RemoveDataProvider();

	self.owner = nil;
	self.behavior = nil;
	--[[
		NOTE: OnHide triggers when the frame is no longer visible, not when it is no longer shown.
		This frame may become non-visible because its parent gets hidden, but it may itself still be shown.
		Setting a nil parent when shown, even if not visible, causes the frame to become visisble.
		This Hide call sets the frame to be explicitly hidden, and therefore not become visible when we nil out the parent.
	]]
	self:Hide();
	self:SetParent(nil);
end

function ProfessionsFlyoutMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFoci = GetMouseFoci();
		if not isRightButton and DoesAncestryIncludeAny(self.owner, mouseFoci) then
			return;
		end

		if isRightButton or (not DoesAncestryIncludeAny(self, mouseFoci) and not self:IsMouseMotionFocus()) then
			CloseProfessionsItemFlyout();
		end
	end
end

local function CountElements(elements)
	return TableUtil.SafeCountIndexTable(elements.items) + TableUtil.SafeCountIndexTable(elements.currencyReagents);
end

function ProfessionsFlyoutMixin:Init(owner, behavior)
	self.owner = owner;
	self:SetBehavior(behavior);

	self:InitializeContents();
end

function ProfessionsFlyoutMixin:SetBehavior(behavior)
	self.behavior = behavior;
end

function ProfessionsFlyoutMixin:GetBehavior()
	return self.behavior;
end

function ProfessionsFlyoutMixin:InitializeContents()
	PlaySound(SOUNDKIT.UI_PROFESSION_FILTER_MENU_OPEN_CLOSE);

	local behavior = self:GetBehavior();
	local cannotModifyHideUnavailable, alwaysShowUnavailable = behavior:GetUnownedFlags();

	local canModifyFilter = behavior:CanModifyFilter();
	local canShowCheckbox = (not cannotModifyHideUnavailable) and canModifyFilter;
	self.HideUnownedCheckbox:SetShown(canShowCheckbox);

	local hideUnavailableCvar = GetCVarBool(HideUnavailableCvar);
	if canShowCheckbox then
		self.HideUnownedCheckbox:SetChecked(hideUnavailableCvar);
	end

	local undoReagent = behavior:GetUndoElement();
	local hasUndoReagentButton = undoReagent ~= nil;
	self.UndoItem:SetShown(hasUndoReagentButton);
	self.UndoButton:SetShown(hasUndoReagentButton);

	local hideUnavailable;
	if cannotModifyHideUnavailable then
		-- Determined in data, supercedes player preference.
		hideUnavailable = not alwaysShowUnavailable;
	else
		local alwaysHide = not canModifyFilter;
		local preferHide = canShowCheckbox and hideUnavailableCvar;
		hideUnavailable = alwaysHide or preferHide;
	end

	local elements = behavior:GetElements(hideUnavailable);
	local count = CountElements(elements);
	local rows = math.min(MaxRows, math.ceil(count / MaxColumns));

	-- If the checkbox is displayed, the minimum number of columns is 4 to avoid localization fitting problems.
	local minColumns = canShowCheckbox and 4 or 1;
	local columns = math.max(minColumns, math.min(MaxColumns, count));

	local padding = self.ScrollBox:GetPadding();
	local vSpacing = padding:GetVerticalSpacing();
	local hSpacing = padding:GetHorizontalSpacing();
	local elementHeight = 37;
	local width = (columns * elementHeight) + (math.max(0, columns - 1) * hSpacing)+ (padding.left + padding.right);
	local height = (rows * elementHeight) + (math.max(0, rows - 1) * vSpacing) + (padding.top + padding.bottom);
	self.ScrollBox:SetSize(width, height);
	self.ScrollBox:ClearAllPoints();
	self.ScrollBox:SetPoint("TOPLEFT", 15, hasUndoReagentButton and -65 or -15);

	if count > 0 then
		local scrollBoxAnchorOffset = 15;
		local adjustment = 2 * scrollBoxAnchorOffset;
		local totalWidth = width + adjustment;
		local canShowScrollBar = count > MaxUnscrolledCount;
		if canShowScrollBar then
			totalWidth = totalWidth + self.ScrollBar:GetWidth() + 8;
		end

		local totalHeight = height + adjustment;
		if canShowCheckbox then
			totalHeight = totalHeight + self.HideUnownedCheckbox:GetHeight() - 7;
		end

		if hasUndoReagentButton then
			self.UndoItem:SetReagent(undoReagent);
			totalHeight = totalHeight + self.UndoItem:GetHeight() + 11;
		end

		self.ScrollBar:SetShown(canShowScrollBar);
		self.Text:Hide();
		self:SetSize(totalWidth, totalHeight);

		local continuableContainer = ContinuableContainer:Create();
		continuableContainer:AddContinuables(elements.items);

		local itemID = undoReagent and undoReagent.itemID;
		if itemID then
			local item = Item:CreateFromItemID(itemID);
			continuableContainer:AddContinuable(item);
		end

		for index1, item in ipairs(elements.items) do
			local reagent = Professions.CreateItemReagent(item:GetItemID());
			for index2, dependentReagent in ipairs(C_TradeSkillUI.GetDependentReagents(reagent)) do
				if dependentReagent.itemID then
					local dependentItem = Item:CreateFromItemID(dependentReagent.itemID)
					continuableContainer:AddContinuable(dependentItem);
				end
			end
		end

		continuableContainer:ContinueOnLoad(function()
			local dataProvider = CreateDataProvider();
			behavior:PopulateDataProvider(dataProvider, elements);
			self.ScrollBox:SetDataProvider(dataProvider);
		end);
	else
		self.ScrollBox:FlushDataProvider();
		self.ScrollBar:Hide();
		self.Text:Show();
		self:SetSize(250, 120);
	end
end

local FlyoutBehaviorMixin = {};

function FlyoutBehaviorMixin:Init(transaction)
	self.transaction = transaction;
end

function FlyoutBehaviorMixin:GetUnownedFlags()
	-- Only applicable if the behavior was initialized with a transaction.
	local cannotModifyHideUnavailable, alwaysShowUnavailable = false, false;
	local recipeID = self:GetRecipeID();
	if recipeID then
		cannotModifyHideUnavailable, alwaysShowUnavailable = C_TradeSkillUI.GetHideUnownedFlags(recipeID);	
	end
	return cannotModifyHideUnavailable, alwaysShowUnavailable;
end

function FlyoutBehaviorMixin:GetTransaction()
	return self.transaction;
end

function FlyoutBehaviorMixin:SetFlyout(flyout)
	self.flyout = flyout;
end

function FlyoutBehaviorMixin:GetRecipeID()
	local transaction = self:GetTransaction();
	if transaction then
		return transaction:GetRecipeID();
	end
end

function FlyoutBehaviorMixin:GetAnchorRegion()
	return self.flyout:GetParent();
end

function FlyoutBehaviorMixin:CanModifyFilter()
	return true;
end

function FlyoutBehaviorMixin:IsElementValid(elementData)
	return true;
end

function FlyoutBehaviorMixin:IsElementEnabled(elementData, count)
	return true;
end

function FlyoutBehaviorMixin:GetUndoElement()
	return nil;
end

function FlyoutBehaviorMixin:GetElements(hideUnavailable)
	error("FlyoutBehaviorMixin:GetElements(hideUnavailable) implementation required.");
end

function FlyoutBehaviorMixin:PopulateDataProvider(dataProvider, elements)
	error("FlyoutBehaviorMixin:PopulateDataProvider(dataProvider, elements) implementation required.");
end

local FlyoutSchematicSlotMixin = {};

function FlyoutSchematicSlotMixin:SetSlot(slot)
	self.slot = slot;
end

function FlyoutSchematicSlotMixin:GetSlot()
	return self.slot;
end

function FlyoutSchematicSlotMixin:SetReagentSlotSchematic(reagentSlotSchematic)
	self.reagentSlotSchematic = reagentSlotSchematic;
end

function FlyoutSchematicSlotMixin:GetReagentSlotSchematic()
	return self.reagentSlotSchematic;
end

local SelectRecraftMixin = CreateFromMixins(FlyoutBehaviorMixin);

function SelectRecraftMixin:GetElements(filterAvailable)
	local itemGUIDs = C_TradeSkillUI.GetRecraftItems(self:GetRecipeID());
	local items = ItemUtil.TransformItemGUIDsToItems(itemGUIDs);
	return {items = items, itemGUIDs = itemGUIDs};
end

function SelectRecraftMixin:PopulateDataProvider(dataProvider, elements)
	for index, item in ipairs(elements.items) do
		local elementData = CreateDataProviderItemElement(item);
		elementData.itemGUID = elements.itemGUIDs[index];
		dataProvider:Insert(elementData);
	end
end

function SelectRecraftMixin:OnElementEnter(elementData, tooltip)
	local itemGUID = elementData.itemGUID;
	tooltip:SetItemByGUID(itemGUID);

	if not C_TradeSkillUI.IsOriginalCraftRecipeLearned(itemGUID) then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, PROFESSIONS_ITEM_RECRAFT_UNLEARNED);
	end
end

function SelectRecraftMixin:IsElementEnabled(elementData, count)
	return C_TradeSkillUI.IsOriginalCraftRecipeLearned(elementData.itemGUID);
end

function SelectRecraftMixin:CanModifyFilter()
	return false;
end

function CreateProfessionsRecraftFlyout(transaction)
	local behavior = CreateFromMixins(SelectRecraftMixin);
	behavior:Init(transaction);
	return behavior;
end

local SelectEnchantMixin = CreateFromMixins(FlyoutBehaviorMixin);

function SelectEnchantMixin:GetElements(filterAvailable)
	local includeItems = {};
	local includeItemGUIDs = {};

	-- GetEnchantItems no longer returns items that would fail level eligibiity requirements.
	local transaction = self:GetTransaction();
	local reagentInfos = transaction:CreateCraftingReagentInfoTbl();
	local enchantItemGUIDs = C_TradeSkillUI.GetEnchantItems(self:GetRecipeID(), reagentInfos);
	for index, item in ipairs(ItemUtil.TransformItemGUIDsToItems(enchantItemGUIDs)) do
		table.insert(includeItems, item);
		table.insert(includeItemGUIDs, enchantItemGUIDs[index]);
	end

	local elementsData = {items = includeItems, itemGUIDs = includeItemGUIDs};
	return elementsData;
end

function SelectEnchantMixin:PopulateDataProvider(dataProvider, elements)
	for index, item in ipairs(elements.items) do
		local elementData = CreateDataProviderItemElement(item);
		elementData.itemGUID = elements.itemGUIDs[index];
		dataProvider:Insert(elementData);
	end
end

function SelectEnchantMixin:OnElementEnter(elementData, tooltip)
	tooltip:SetOwner(self:GetAnchorRegion(), "ANCHOR_RIGHT");
	tooltip:SetItemByGUID(elementData.itemGUID);
	tooltip:Show();
end

function SelectEnchantMixin:CanModifyFilter()
	return false;
end

function CreateProfessionsEnchantFlyout(transaction)
	local behavior = CreateFromMixins(SelectEnchantMixin);
	behavior:Init(transaction);
	return behavior;
end

do
	local SelectSalvageMixin = CreateFromMixins(FlyoutBehaviorMixin);
	
	local function ShouldEnableItem(self, item)
		local quantity = item:GetItemGUID() and item:GetStackCount() or nil;
		local recipeSchematic = self:GetTransaction():GetRecipeSchematic();
		return quantity and (quantity >= recipeSchematic.quantityMax);
	end

	function SelectSalvageMixin:GetElements(filterAvailable)
		local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(self:GetRecipeID());
		local items = {};

		-- GetCraftingTargetItems only returns the items in the player's possession, so
		-- it can be a smaller collection than `itemIDs`. Mark the itemIDs we've added
		-- here so we can skip them when not considering possession in the second loop below.
		local added = {};
		for index, targetItem in ipairs(C_TradeSkillUI.GetCraftingTargetItems(itemIDs)) do
			local item = Item:CreateFromItemGUID(targetItem.itemGUID);
			if not filterAvailable or ShouldEnableItem(self, item) then
				table.insert(items, Item:CreateFromItemGUID(targetItem.itemGUID));
				added[targetItem.itemID] = true;
			end
		end

		if not filterAvailable then
			for index, itemID in ipairs(itemIDs) do
				if not added[itemID] then
					table.insert(items, Item:CreateFromItemID(itemID));
				end
			end
		end
		return {items = items};
	end

	function SelectSalvageMixin:PopulateDataProvider(dataProvider, elements)
		for index, item in ipairs(elements.items) do
			local elementData = CreateDataProviderItemElement(item);
			elementData.onlyCountStack = true;
			dataProvider:Insert(elementData);
		end
	end

	function SelectSalvageMixin:OnElementEnter(elementData, tooltip)
		local item = elementData.item;
		local itemGUID = item:GetItemGUID();
		if itemGUID then
			tooltip:SetItemByGUID(itemGUID);
		else
			tooltip:SetItemByID(item:GetItemID());
		end
	
		if not ShouldEnableItem(self, item) then
			GameTooltip_AddErrorLine(tooltip, PROFESSIONS_INSUFFICIENT_REAGENTS);
		end
	end
	
	function SelectSalvageMixin:IsElementEnabled(elementData, count)
		return ShouldEnableItem(self, elementData.item);
	end

	function CreateProfessionsSalvageFlyout(transaction)
		local behavior = CreateFromMixins(SelectSalvageMixin);
		behavior:Init(transaction);
		return behavior;
	end
end

local MCRFlyoutMixin = CreateFromMixins(FlyoutBehaviorMixin, FlyoutSchematicSlotMixin);

function MCRFlyoutMixin:GetUndoElement()
	local slot = self:GetSlot();
	if not slot:IsOriginalReagentSet() then
		return slot:GetOriginalReagent();
	end
end

function MCRFlyoutMixin:GetElements(filterAvailable)
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local reagents = reagentSlotSchematic.reagents;
	local currencyReagents = FilterCurrencyReagents(reagents, filterAvailable);
	local items = Professions.GenerateItemsFromEligibleItemSlots(reagents, filterAvailable);
	local elementData = {currencyReagents = currencyReagents, items = items};
	return elementData;
end

function MCRFlyoutMixin:PopulateDataProvider(dataProvider, elements)
	for index, item in ipairs(elements.items) do
		local elementData = CreateDataProviderItemElement(item);
		elementData.forceAccumulateInventory = true;
		dataProvider:Insert(elementData);
	end

	PopulateDataProviderWithCurrencies(dataProvider, elements);
end

function MCRFlyoutMixin:OnElementEnter(elementData, tooltip)
	local reagent = elementData.reagent;
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local transaction = self:GetTransaction();
	OnElementEnterImplementation(reagent, tooltip, transaction, reagentSlotSchematic);
end

function MCRFlyoutMixin:IsElementEnabled(elementData, count)
	local reagent = elementData.reagent;
	local transaction = self:GetTransaction();
	if not transaction:AreDependentReagentsAllocated(reagent) then
		return false;
	end

	if (not reagent) or transaction:HasAllocatedReagent(reagent) then
		return false;
	end
	
	local recraftAllocation = transaction:GetRecraftAllocation();
	if recraftAllocation and not C_TradeSkillUI.IsRecraftReagentValid(recraftAllocation, reagent) then
		return false;
	end
	
	local quantity = nil;
	local item = elementData.item;
	if item then
		if item:GetItemGUID() then
			quantity = item:GetStackCount();
		else
			quantity = ItemUtil.GetCraftingReagentCount(item:GetItemID(), transaction:ShouldUseCharacterInventoryOnly());
		end
	else
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
		quantity = currencyInfo.quantity;
	end

	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	if (not quantity) or (quantity < reagentSlotSchematic:GetQuantityRequired(reagent)) then
		return false;
	end

	return true;
end

function MCRFlyoutMixin:IsElementValid(elementData)
	return self:GetTransaction():AreDependentReagentsAllocated(elementData.reagent);
end

function CreateProfessionsMCRFlyout(transaction, reagentSlotSchematic, slot)
	local behavior = CreateFromMixins(MCRFlyoutMixin);
	behavior:Init(transaction);
	behavior:SetReagentSlotSchematic(reagentSlotSchematic);
	behavior:SetSlot(slot);
	return behavior;
end

local OrderRecraftFlyoutMixin = CreateFromMixins(FlyoutBehaviorMixin);

function OrderRecraftFlyoutMixin:GetElements(filterAvailable)
	local isIndexTable = true;
	local itemGUIDs = tFilter(C_TradeSkillUI.GetRecraftItems(), Professions.AnyRecraftablePredicate, isIndexTable);
	local items = ItemUtil.TransformItemGUIDsToItems(itemGUIDs);
	local elementData = {items = items, itemGUIDs = itemGUIDs};
	return elementData;
end

function OrderRecraftFlyoutMixin:PopulateDataProvider(dataProvider, elements)
	for index, item in ipairs(elements.items) do
		local elementData = CreateDataProviderItemElement(item);
		elementData.itemGUID = elements.itemGUIDs[index];
		dataProvider:Insert(elementData);
	end
end

function OrderRecraftFlyoutMixin:OnElementEnter(elementData, tooltip)
	tooltip:SetItemByGUID(elementData.itemGUID);
end

function CreateProfessionsOrderRecraftFlyout(transaction)
	local behavior = CreateFromMixins(OrderRecraftFlyoutMixin);
	behavior:Init(transaction);
	return behavior;
end

local OrderMCRFlyoutMixin = CreateFromMixins(FlyoutBehaviorMixin, FlyoutSchematicSlotMixin);

function OrderMCRFlyoutMixin:GetElements(filterAvailable)
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local reagents = reagentSlotSchematic.reagents;
	local currencyReagents = FilterCurrencyReagents(reagents, filterAvailable);
	local items = Professions.GenerateItemsFromEligibleItemSlots(reagents, filterAvailable);
	local elementData = {currencyReagents = currencyReagents, items = items};
	return elementData;
end

function OrderMCRFlyoutMixin:PopulateDataProvider(dataProvider, elements)
	local useCharacterInventoryOnly = self:GetTransaction():ShouldUseCharacterInventoryOnly();
	for index, item in ipairs(elements.items) do
		local elementData = CreateDataProviderItemElement(item);
		elementData.useCharacterInventoryOnly = useCharacterInventoryOnly;
		dataProvider:Insert(elementData);
	end

	PopulateDataProviderWithCurrencies(dataProvider, elements);
end

function OrderMCRFlyoutMixin:OnElementEnter(elementData, tooltip)
	local reagent = elementData.reagent;
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	OnElementEnterImplementation(reagent, tooltip, self:GetTransaction(), reagentSlotSchematic);
end

function OrderMCRFlyoutMixin:IsElementEnabled(elementData, count)
	if count <= 0 then
		return false;
	end

	local reagent = elementData.reagent;
	local transaction = self:GetTransaction();
	if transaction:HasAllocatedReagent(reagent) then
		return false;
	end

	if not transaction:AreDependentReagentsAllocated(reagent) then
		return false;
	end

	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local quantityOwned = ProfessionsUtil.GetReagentQuantityInPossession(reagent, transaction:ShouldUseCharacterInventoryOnly());
	if quantityOwned < reagentSlotSchematic:GetQuantityRequired(reagent) then
		return false;
	end

	local recraftAllocation = transaction:GetRecraftAllocation();
	if recraftAllocation and not C_TradeSkillUI.IsRecraftReagentValid(recraftAllocation, reagent) then
		return false;
	end

	return true;
end

function OrderMCRFlyoutMixin:IsElementValid(elementData)
	return self:GetTransaction():AreDependentReagentsAllocated(elementData.reagent);
end

function OrderMCRFlyoutMixin:GetUndoElement()
	local slot = self:GetSlot();
	if not slot:IsOriginalReagentSet() then
		return slot:GetOriginalReagent();
	end
end

function CreateProfessionsOrderMCRFlyout(transaction, reagentSlotSchematic, slot)
	local behavior = CreateFromMixins(OrderMCRFlyoutMixin);
	behavior:Init(transaction);
	behavior:SetReagentSlotSchematic(reagentSlotSchematic);
	behavior:SetSlot(slot);
	return behavior;
end
