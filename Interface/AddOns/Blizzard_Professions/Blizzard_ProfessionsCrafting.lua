

local helpTipSystem = "Professions Crafting Helptips";

ProfessionsGearSlotTemplateMixin = CreateFromMixins(PaperDollItemSlotButtonMixin);

CraftingSearchLGMixin = {};

function CraftingSearchLGMixin:Init(recipeInfo)
	self.Name:SetText(recipeInfo.name);
	self.Icon:SetTexture(recipeInfo.icon);
end

ProfessionsCraftingPageMixin = CreateFromMixins(ProfessionsRecipeListPanelMixin);

local ProfessionsCraftingPageEvents =
{
	"TRADE_SKILL_DATA_SOURCE_CHANGING",
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"UPDATE_TRADESKILL_CAST_STOPPED",
	"TRADE_SKILL_CLOSE",
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_FAILED",
};

function ProfessionsCraftingPageMixin:OnLoad()
	PaperDollItemSlotButton_SetAutoEquipSlotIDs(self.Prof0ToolSlot, self.Prof0Gear0Slot, self.Prof0Gear1Slot);
	PaperDollItemSlotButton_SetAutoEquipSlotIDs(self.Prof1ToolSlot, self.Prof1Gear0Slot, self.Prof1Gear1Slot);
	PaperDollItemSlotButton_SetAutoEquipSlotIDs(self.CookingToolSlot, self.CookingGear0Slot);
	PaperDollItemSlotButton_SetAutoEquipSlotIDs(self.FishingToolSlot--[[, self.FishingGear0Slot, self.FishingGear1Slot]]);

	EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", self.OnRecipeSelected, self);

	Professions.InitFilterMenu(self.RecipeList.FilterDropdown);

	self.CreateButton:SetScript("OnClick", GenerateClosure(self.Create, self));
	self.CreateAllButton:SetScript("OnClick", GenerateClosure(self.CreateAll, self));

	local function SyncSearchText(editBox)
		local text = editBox:GetText();
		if editBox ~= self.RecipeList.SearchBox then
			self.RecipeList.SearchBox:SetText(text);
		end
		if editBox ~= self.MinimizedSearchBox then
			self.MinimizedSearchBox:SetText(text);
		end
		Professions.OnRecipeListSearchTextChanged(text);
	end

	self.RecipeList.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);
		SyncSearchText(editBox);
	end);

	self.LinkButton:SetScript("OnClick", function()
		if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
			local link = C_TradeSkillUI.GetTradeSkillListLink();
			if strlenutf8(MacroFrameText:GetText()) + strlenutf8(link) <= MacroFrameText:GetMaxLetters() then
				MacroFrameText:Insert(link);
			end
		else
			if ChatEdit_GetActiveWindow() then
				local link = C_TradeSkillUI.GetTradeSkillListLink();
				ChatEdit_InsertLink(link);
			end
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end);

	self.ViewGuildCraftersButton:SetScript("OnClick", function() self:OnViewGuildCraftersClicked(); end);

	self.TutorialButton:SetScript("OnClick", function() self:ToggleTutorial(); end);

	local function OnUseBestQualityModified(o, checked)
		local transaction = self.SchematicForm:GetTransaction();
		Professions.AllocateAllBasicReagents(transaction, checked);

		self:ValidateControls();
	end

	self.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, OnUseBestQualityModified, self);
	
	local function OnAllocationsModified(o, checked)
		self:ValidateControls();
	end
	self.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, OnAllocationsModified);

	EventRegistry:RegisterCallback("Professions.ProfessionSelected", self.OnProfessionSelected, self);
	EventRegistry:RegisterCallback("Professions.ReagentClicked", self.OnReagentClicked, self);
	EventRegistry:RegisterCallback("Professions.TransactionUpdated", self.ValidateControls, self);

	self.flyoutSettings = 
	{
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		parent = self:GetParent(),
		anchorX = 6,
		anchorY = -3,
	};

	self.CraftingOutputLog:SetScript("OnShow", function()
		local p, r, rp, x, y = self.CraftingOutputLog:GetPointByName("TOPLEFT");
		local width = ProfessionsFrame:GetWidth() + self.CraftingOutputLog:GetMaxPossibleWidth() + x;
		SetUIPanelAttribute(ProfessionsFrame, "width", width);
		UpdateUIPanelPositions(ProfessionsFrame);
	end);

	self.CraftingOutputLog:SetScript("OnHide", function()
		ProfessionsCraftingOutputLogMixin.OnHide(self.CraftingOutputLog);
		local width = ProfessionsFrame:GetWidth();
		SetUIPanelAttribute(ProfessionsFrame, "width", width);
		UpdateUIPanelPositions(ProfessionsFrame);
	end);

	self.SchematicForm.postInit = function() self:SchematicPostInit(); end;

	ButtonFrameTemplate_HidePortrait(self.MinimizedSearchResults);
	self.MinimizedSearchResults:SetTitleOffsets(35);

	local function OnSearchButtonEnter(button, recipeInfo)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");

		local allocations = {};
		local allocationGUID = nil;
		local recipeLevel = recipeInfo.unlockedRecipeLevel;

		button:SetScript("OnUpdate", function() 
			GameTooltip:SetRecipeResultItem(recipeInfo.recipeID, allocations, allocationGUID, recipeLevel);
		end);
	end

	local function OnSearchButtonLeave(button)
		GameTooltip_Hide(); 
		button:SetScript("OnUpdate", nil);
	end

	local searchView = CreateScrollBoxListLinearView();
	searchView:SetElementInitializer("CraftingSearchLGTemplate", function(button, recipeInfo)
		button:Init(recipeInfo);

		button:SetScript("OnEnter", function(button)
			OnSearchButtonEnter(button, recipeInfo);
		end);

		button:SetScript("OnLeave", OnSearchButtonLeave);

		button:SetScript("OnClick", function()
			local skipSelectInList = false;
			self:SelectRecipe(recipeInfo, skipSelectInList);

			self.MinimizedSearchResults:Hide();
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.MinimizedSearchResults.ScrollBox, self.MinimizedSearchResults.ScrollBar, searchView);

	self.MinimizedSearchBox:SetScript("OnTextChanged", function(editBox)
		local valid, text = SearchBoxListMixin.OnTextChanged(editBox);
		SyncSearchText(editBox);

		self.MinimizedSearchResults:Hide();
	end);

	self.MinimizedSearchBox:SetScript("OnEditFocusGained", function(editBox)
		SearchBoxListMixin.OnFocusGained(editBox);

		self:UpdateSearchPreview();
	end);

	for index, button in ipairs(self.MinimizedSearchBox:GetButtons()) do
		button:SetScript("OnEnter", function(button)
			SearchBoxListElementMixin.OnEnter(button);
			OnSearchButtonEnter(button, button.recipeInfo);
		end);

		button:SetScript("OnLeave", OnSearchButtonLeave);

		button:SetScript("OnClick", function(button)
			SearchBoxListElementMixin.OnClick(button);

			self.MinimizedSearchBox:Close();

			local skipSelectInList = false;
			self:SelectRecipe(button.recipeInfo, skipSelectInList);
		end);

		local allResultsButton = self.MinimizedSearchBox:GetAllResultsButton();
		allResultsButton:SetScript("OnClick", function(button)
			SearchBoxListElementMixin.OnClick(button);

			self.MinimizedSearchBox:Close();

			self.MinimizedSearchResults.ScrollBox:SetDataProvider(self.searchDataProvider);
			self.MinimizedSearchResults:Show();
		end);
	end

	self.MinimizedSearchBox:SetSearchResultsFrame(self.MinimizedSearchResults);
end

function ProfessionsCraftingPageMixin:SetMaximized()
	self:Refresh(self.professionInfo);

	self.SchematicForm:ClearAllPoints();
	self.SchematicForm:SetPoint("TOPLEFT", self.RecipeList, "TOPRIGHT", 2, 0);
	self.SchematicForm:SetMaximized();
end

function ProfessionsCraftingPageMixin:SetMinimized()
	self:Refresh(self.professionInfo);

	self.SchematicForm:ClearAllPoints();
	self.SchematicForm:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -72);
	self.SchematicForm:SetMinimized();
end

function ProfessionsCraftingPageMixin:Cleanup()
	self.vellumItemID = nil;
	self:SetOverrideCastBarActive(false);
	self:ValidateControls();
end

function ProfessionsCraftingPageMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGING" then	
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		self:Reset();
		self.GuildFrame:Clear();
	elseif event == "UPDATE_TRADESKILL_CAST_STOPPED" then
		local isScrapping = ...;
		if not isScrapping then
			self:Cleanup();
		end
	elseif event == "TRADE_SKILL_CLOSE" then
		HideUIPanel(self);
	elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
		local transaction = self.SchematicForm:GetTransaction();
		if transaction then
			transaction:SanitizeTargetAllocations();
			-- If we are in the process of enchanting multiple vellums, we may need to reassign
			-- a valid target if the previous item stack was depleted. This will go away entirely
			-- once we update the API to accept the itemID and not require an actual item instance.
			if self.vellumItemID and not transaction:GetEnchantAllocation() then
				ItemUtil.IteratePlayerInventory(function(itemLocation)
					if C_Item.GetItemID(itemLocation) == self.vellumItemID then
						local item = Item:CreateFromItemGUID(C_Item.GetItemGUID(itemLocation));
						transaction:SetEnchantAllocation(item);
						return true;
					end
				end);
			end
		end

		-- This is also expected to refresh the UI from equipment changes because those
		-- also trigger the enclosing events.
		self.SchematicForm:Refresh();
		self:ValidateControls();
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
		self:Cleanup();
	elseif event == "UNIT_AURA" then
		self.SchematicForm:UpdateDetailsStats();
	end
end

function ProfessionsCraftingPageMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCraftingPageEvents);

	self:RegisterUnitEvent("UNIT_AURA", "player");

	self:SetTitle();
	self.RecipeList.SearchBox:SetText(C_TradeSkillUI.GetRecipeItemNameFilter());


	local function CreateChannelTbl(slashChannel, text, enabled)
		return { slashChannel = slashChannel, text = text, enabled = enabled};
	end

	self.LinkButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CRAFTING_PAGE");

		rootDescription:CreateTitle(TRADESKILL_POST);

		local channelTbls =
		{ 
			CreateChannelTbl(SLASH_GUILD1, GUILD, IsInGuild()),
			CreateChannelTbl(SLASH_PARTY1, PARTY, GetNumSubgroupMembers() > 0),
			CreateChannelTbl(SLASH_RAID1, RAID, IsInRaid()),
		};

	local channels = { GetChannelList() };
		for index = 1, #channels, 3 do
			local slashChannel = "/"..channels[index];
			local text = ChatFrame_ResolveChannelName(channels[index + 1]);
			local enabled = not (channels[index + 2]);
			table.insert(channelTbls, CreateChannelTbl(slashChannel, text, enabled));
		end

		for index, tbl in ipairs(channelTbls) do
			local button = rootDescription:CreateButton(tbl.text, function()
				local link = C_TradeSkillUI.GetTradeSkillListLink();
				if link then
					ChatFrame_OpenChat(string.format("%s %s", tbl.slashChannel, link), DEFAULT_CHAT_FRAME);
	end
			end);
			button:SetEnabled(tbl.enabled);
end
	end);

	FrameUtil.RegisterUpdateFunction(self, .75, GenerateClosure(self.Update, self));
end

function ProfessionsCraftingPageMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsCraftingPageEvents);

	self:UnregisterEvent("UNIT_AURA");

	self.CraftingOutputLog:Close();
	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end

	self:SetOverrideCastBarActive(false);
	HelpTip:HideAllSystem(helpTipSystem);

	FrameUtil.UnregisterUpdateFunction(self);

	self:StoreCollapses(self.RecipeList.ScrollBox);

end

function ProfessionsCraftingPageMixin:Update()
	local skipConstrainCount = true;
	self:ValidateControls(skipConstrainCount);
end

function ProfessionsCraftingPageMixin:Reset()
	self.professionInfo = nil;
end

function ProfessionsCraftingPageMixin:GetDesiredPageWidth()
	if ProfessionsUtil.IsCraftingMinimized() then
		return 404;
	end

	local compact = C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging();
	return compact and 786 or 942;
end

function ProfessionsCraftingPageMixin:OnReagentClicked(reagentName)
	self.RecipeList.SearchBox:SetText(reagentName);
end

function ProfessionsCraftingPageMixin:OnProfessionSelected(professionInfo)
	self:Init(professionInfo);
end

function ProfessionsCraftingPageMixin:OnRecipeSelected(recipeInfo, recipeList)
	if recipeList ~= nil and recipeList ~= self.RecipeList then
		return;
	end
	
	-- Only expect that if this is called, it is in response to selecting a recipe from the
	-- list, in which case we never want the recrafting version of a recipe to be displayed.
	Professions.EraseRecraftingTransitionData();

	self:SelectRecipe(recipeInfo);
	self:CheckShowHelptips();
end

function ProfessionsCraftingPageMixin:SelectRecipe(recipeInfo, skipSelectInList)
	-- The selected recipe from the list will be the first level. 
	-- Always forward the highest learned recipe to the schematic.
	local highestRecipe = Professions.GetHighestLearnedRecipe(recipeInfo);
	self.SchematicForm.Details:CancelAllAnims();

	self.SchematicForm:ClearTransaction();
	self.SchematicForm:Init(highestRecipe or recipeInfo);

	self.GuildFrame:Clear();

	self:ValidateControls();

	if not skipSelectInList then
		local scrollToRecipe = false;
		self.RecipeList:SelectRecipe(recipeInfo, scrollToRecipe);
	end
end

function ProfessionsCraftingPageMixin:SetupMultipleInputBox(count, countMax)
	if count > 0 and countMax > 0 then
		self.CreateMultipleInputBox:Enable();
		self.CreateMultipleInputBox:SetValue(count);
		self.CreateMultipleInputBox:SetMinMaxValues(1, countMax);
	else
		self.CreateMultipleInputBox:Disable();
		self.CreateMultipleInputBox:SetValue(0);
		self.CreateMultipleInputBox:ClearHighlightText();
	end
end

local function ShouldProcessReagentSlotAllocation(transaction, slotIndex)
	return not transaction:IsRecraft() or not transaction:IsModificationUnchangedAtSlotIndex(slotIndex);
end

local function CreateBadAllocationAssertMessage(item, itemLocation)
	local recipeInfo = ProfessionsFrame and ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo();
	local recipeID = recipeInfo and recipeInfo.recipeID or -1;

	return ("Item location invalid: GUID %s, ITEM ID %d, RECIPE ID %d, BAG ID %d, SLOT INDEX %d, EQUIP SLOT INDEX %d"):format(
		item.itemGUID or "INVALID",
		item.debugItemID or -1,
		recipeID or -1,
		itemLocation.bagID or -1, 
		itemLocation.slotIndex or -1, 
		itemLocation.equipmentSlotIndex or -1);
end

function ProfessionsCraftingPageMixin:GetCraftableCount()
	local transaction = self.SchematicForm:GetTransaction();
	local intervals = math.huge;

	local function ClampInvervals(quantity, quantityMax)
		intervals = math.min(intervals, math.floor(quantity / quantityMax));
	end

	local function ClampAllocations(allocations)
		for slotIndex, allocation in allocations:Enumerate() do
			local quantity = ProfessionsUtil.GetReagentQuantityInPossession(allocation:GetReagent(), transaction:ShouldUseCharacterInventoryOnly());
			local quantityMax = allocation:GetQuantity();
			ClampInvervals(quantity, quantityMax);
		end
	end

	if transaction:IsManuallyAllocated() then
		-- If manually allocated, we can only accumulate the reagents currently allocated.
		for slotIndex, allocations in transaction:EnumerateAllAllocations() do
			if transaction:IsSlotRequired(slotIndex) and ShouldProcessReagentSlotAllocation(transaction, slotIndex) then
				--[[ This is correct for both basic and modified-required because this
				accumulates allocated reagents only, which is correct for the case of
				modifying-required slots. Note that if we're recrafting, we should not
				process the slot when the modification is unchanged.]]--
				ClampAllocations(allocations);
			end
		end
	else
		--[[ If automatically allocated, we can accumulate every compatible reagent regardless of what
		is currently allocated. Note, this is not the case for modifying-required slots; those
		need to only account for what is allocated, which is accounted for below.]]--
		for slotIndex, reagents in transaction:EnumerateAllSlotReagents() do
			if transaction:IsSlotBasicReagentType(slotIndex) then
				local quantity = AccumulateOp(reagents, function(reagent)
					return ProfessionsUtil.GetReagentQuantityInPossession(reagent, transaction:ShouldUseCharacterInventoryOnly());
				end);

				local quantityMax = transaction:GetQuantityRequiredInSlot(slotIndex);
				ClampInvervals(quantity, quantityMax);
			elseif transaction:IsSlotModifyingRequired(slotIndex) then
				--[[ If we're crafting normally, this slot is treated like a basic slot. However if we're recrafting
				and the item's current modification is unchanged, then we do not need to require that any item exists
				in inventory because the existing modification will be unchanged.]]--
				if ShouldProcessReagentSlotAllocation(transaction, slotIndex) then
					local quantity = AccumulateOp(reagents, function(reagent)
						-- Only include the allocated reagents for modifying-required slots.
						if transaction:IsReagentAllocated(slotIndex, reagent) then
							return ProfessionsUtil.GetReagentQuantityInPossession(reagent, transaction:ShouldUseCharacterInventoryOnly());
						end
						return 0;
					end);
					local quantityMax = transaction:GetQuantityRequiredInSlot(slotIndex);
					ClampInvervals(quantity, quantityMax);
				end
			end
		end
	end

	-- Optionals and finishers are included unless the current reagent matches
	-- a recrafting modification.
	for slotIndex, allocations in transaction:EnumerateAllAllocations() do
		if not transaction:IsSlotRequired(slotIndex) then
			local allocs = allocations:SelectFirst();
			if allocs then
				local clamp = true;
				local modification = transaction:GetModificationAtSlotIndex(slotIndex);
				if modification then
					local reagent = allocs:GetReagent();
					if modification.itemID == reagent.itemID then
						clamp = false;
					end
				end
				
				if clamp then
					ClampAllocations(allocations);
				end
			end
		end
	end

	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		local salvageItem = transaction:GetSalvageAllocation();
		if salvageItem then
			-- Exposing some information to investigate an exception related to invalid salvage allocation.
			local success = true;
			do
				local itemLocation = salvageItem:GetItemLocation();
				if itemLocation and not salvageItem.assertShown then
					success = xpcall(C_Item.DoesItemExist, CallErrorHandler, itemLocation);
					assertsafe(success, CreateBadAllocationAssertMessage(salvageItem, itemLocation));
					if not success then
						salvageItem.assertShown = true;
						local recipeSchematic = transaction:GetRecipeSchematic();
						ClampInvervals(0, recipeSchematic.quantityMax); 
					end
				end
			end

			if success then
				local quantity = salvageItem:GetStackCount();
				if quantity then
					local recipeSchematic = transaction:GetRecipeSchematic();
					ClampInvervals(quantity, recipeSchematic.quantityMax); 
				end
			end
		end
	elseif transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
		local enchantItem = transaction:GetEnchantAllocation();
		if enchantItem then
			if enchantItem:IsStackable() then
				local quantity = ItemUtil.GetCraftingReagentCount(enchantItem:GetItemID(), transaction:ShouldUseCharacterInventoryOnly())
				local quantityMax = 1;
				ClampInvervals(quantity, quantityMax); 
			else
				local quantity = 1;
				local quantityMax = 1;
				ClampInvervals(quantity, quantityMax); 
			end
		end
	end

	if intervals ~= math.huge then
		return intervals;
	end
	return 0;
end

function ProfessionsCraftingPageMixin:SetCreateButtonTooltipText(tooltipText)
	if tooltipText then
		tooltipText = RED_FONT_COLOR:WrapTextInColorCode(tooltipText);
	end
	self.CreateButton.tooltipText = tooltipText;
	self.CreateAllButton.tooltipText = tooltipText;
end

local FailValidationReason = EnumUtil.MakeEnum("Cooldown", "InsufficientReagents", "PrerequisiteReagents", "Disabled", "Requirement", "LockedReagentSlot", "RecraftOptionalReagentLimit");

local FailValidationTooltips = {
	[FailValidationReason.Cooldown] = PROFESSIONS_RECIPE_COOLDOWN,
	[FailValidationReason.InsufficientReagents] = PROFESSIONS_INSUFFICIENT_REAGENTS,
	[FailValidationReason.PrerequisiteReagents] = PROFESSIONS_PREREQUISITE_REAGENTS,
	[FailValidationReason.Requirement] = PROFESSIONS_MISSING_REQUIREMENT,
	[FailValidationReason.LockedReagentSlot] = PROFESSIONS_INSUFFICIENT_REAGENT_SLOTS,
	[FailValidationReason.RecraftOptionalReagentLimit] = PROFESSIONS_UNIQUE_EQUIP_LIMITATION_DISC,
};

function ProfessionsCraftingPageMixin:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax)
	if not currentRecipeInfo.craftable or currentRecipeInfo.disabled then
		return FailValidationReason.Disabled;
	end

	if Professions.IsRecipeOnCooldown(currentRecipeInfo.recipeID) then
		return FailValidationReason.Cooldown;
	end
	
	local requirements = C_TradeSkillUI.GetRecipeRequirements(currentRecipeInfo.recipeID);
	local anyRequirementMissing = ContainsIf(requirements, function(requirement)
		return not requirement.met;
	end);
	if anyRequirementMissing then
		return FailValidationReason.Requirement;
	end
	
	if not transaction:HasMetPrerequisiteRequirements() then
		return FailValidationReason.PrerequisiteReagents;
	end

	if not isRuneforging and countMax <= 0 then
		return FailValidationReason.InsufficientReagents;
	end
	
	if not transaction:HasMetAllRequirements() then
		return FailValidationReason.InsufficientReagents;
	end

	local optionalReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Modifying);
	for _, slot in ipairs(optionalReagentSlots or {}) do
		local reagentSlotSchematic = slot:GetReagentSlotSchematic();
		local hasAllocation = transaction:HasAnyAllocations(reagentSlotSchematic.slotIndex);
		if hasAllocation and slot.Button.locked then
			return FailValidationReason.LockedReagentSlot;
		end
	end

	-- Separate loop from above so that ordering of errors is consistent
	local recraftingEquipped = transaction:HasRecraftAllocation() and C_TradeSkillUI.IsRecraftItemEquipped(transaction:GetRecraftAllocation());
	if recraftingEquipped then
		for _, slot in ipairs(optionalReagentSlots or {}) do
			local reagentSlotSchematic = slot:GetReagentSlotSchematic();
			local allocation = transaction:GetAllocations(reagentSlotSchematic.slotIndex);
			local allocs = allocation and allocation:SelectFirst();
			local reagent = allocs and allocs:GetReagent();
			if reagent and not C_TradeSkillUI.RecraftLimitCategoryValid(reagent.itemID) then
				return FailValidationReason.RecraftOptionalReagentLimit;
			end
		end
	end

	return nil;
end

local function DoesEnchantTargetSupportStacks(transaction)
	local enchantItem = transaction:GetEnchantAllocation();
	return enchantItem and enchantItem:IsStackable();
end

function ProfessionsCraftingPageMixin:ValidateControls(skipConstrainCount)
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();

	local isRuneforging = C_TradeSkillUI.IsRuneforging();
	if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
		and not currentRecipeInfo.isRecraft
		and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe then
		self.CreateButton:Show();
		self.ViewGuildCraftersButton:Hide();

		local transaction = self.SchematicForm:GetTransaction();
		local isEnchant = transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant);

		local canCreateMultiple = currentRecipeInfo.canCreateMultiple and 
			not isRuneforging and
			not transaction:HasRecraftAllocation() and
			(not isEnchant or DoesEnchantTargetSupportStacks(transaction));

		local castBarXOfs, castBarYOfs;
		if canCreateMultiple then
			self.CreateAllButton:Show();
			self.CreateMultipleInputBox:Show();
			castBarXOfs = 2;
			castBarYOfs = 17;
		else
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
			castBarXOfs = 120;
			castBarYOfs = 17;
		end
		self.OverlayCastBarAnchor:ClearAllPoints();
		self.OverlayCastBarAnchor:SetPoint("BOTTOM", self, "BOTTOM", castBarXOfs, castBarYOfs);

		local countMax = self:GetCraftableCount();
		if not skipConstrainCount then
			if countMax > 0 then
				local total = C_TradeSkillUI.GetRemainingRecasts() + 1;
				self:SetupMultipleInputBox(total, countMax);
			else
				self:SetupMultipleInputBox(0, 0);
			end
		end

		if isEnchant then
			self.CreateButton:SetTextToFit(CREATE_PROFESSION_ENCHANT);
			local quantity = math.max(1, countMax);
			self.CreateAllButton:SetTextToFit(PROFESSIONS_CREATE_ALL_FORMAT:format(PROFESSIONS_ENCHANT_ALL, quantity));
		else
			if currentRecipeInfo.abilityVerb then
				-- abilityVerb is recipe-level override
				self.CreateButton:SetTextToFit(currentRecipeInfo.abilityVerb);
			elseif currentRecipeInfo.alternateVerb then
				-- alternateVerb is profession-level override
				self.CreateButton:SetTextToFit(currentRecipeInfo.alternateVerb);
			elseif self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() then
				self.CreateButton:SetTextToFit(PROFESSIONS_CRAFTING_RECRAFT);
			else
				self.CreateButton:SetTextToFit(CREATE_PROFESSION);
			end

			local createAllFormat;
			if currentRecipeInfo.abilityAllVerb then
				-- abilityAllVerb is recipe-level override
				createAllFormat = currentRecipeInfo.abilityAllVerb;
			else
				createAllFormat = PROFESSIONS_CREATE_ALL;
			end
			self.CreateAllButton:SetTextToFit(PROFESSIONS_CREATE_ALL_FORMAT:format(createAllFormat, countMax));
		end

		-- CAIS not relevant anymore since the client is denied login. Nevertheless, this is carried over from the
		-- previous implementation in case the CAIS system changes.
		local enabled = true;
		if PartialPlayTime() then
			local reasonText = PLAYTIME_TIRED_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self:SetCreateButtonTooltipText(reasonText);
			enabled = false;
		elseif NoPlayTime() then
			local reasonText = PLAYTIME_UNHEALTHY_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self:SetCreateButtonTooltipText(reasonText);
			enabled = false;
		end

		if enabled then
			local failValidationReason = self:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax);
			enabled = failValidationReason == nil;
			self:SetCreateButtonTooltipText(FailValidationTooltips[failValidationReason]);
		end

		self.CreateButton:SetEnabled(enabled);
		self.CreateAllButton:SetEnabled(enabled and canCreateMultiple);
		self.CreateMultipleInputBox:SetEnabled(enabled and canCreateMultiple);
	else
		self.CreateButton:Hide();
		self.CreateAllButton:Hide();
		self.CreateMultipleInputBox:Hide();
		
		if C_TradeSkillUI.IsTradeSkillGuild() then
			self.ViewGuildCraftersButton:Show();
			self.ViewGuildCraftersButton:SetEnabled(currentRecipeInfo and currentRecipeInfo.learned);
		else
			self.ViewGuildCraftersButton:Hide();
		end
	end
end

local function FindFirstRecipe(dataProvider)
	-- Select an initial recipe. As mentioned above, every recipe in the data provider is the
	-- first recipe in the instance it has levels.
	for index, node in dataProvider:EnumerateEntireRange() do
		local data = node:GetData();
		local recipeInfo = data.recipeInfo;
		-- Don't select recrafting as the initial recipe, since its filtering can cause confusion
		if recipeInfo and not recipeInfo.isRecraft then
			return recipeInfo;
		end
	end
end

local function FindRecipeInfo(dataProvider, recipeID)
	if not recipeID then
		return nil;
	end

	local function IsRecipeMatch(node)
		local data = node:GetData();
		local recipeInfo = data.recipeInfo;
		return recipeInfo and recipeInfo.recipeID == recipeID;
	end

	local node = dataProvider:FindElementDataByPredicate(IsRecipeMatch, TreeDataProviderConstants.IncludeCollapsed);

	if node then
		local data = node:GetData();
		return data.recipeInfo;
	end
end

function ProfessionsCraftingPageMixin:UpdateSearchPreview()
	local dataProviderSize = (self.searchDataProvider ~= nil) and self.searchDataProvider:GetSize() or 0;
	if dataProviderSize == 0 then
		self.MinimizedSearchBox:HideSearchPreview();
		self.MinimizedSearchResults:Hide();
		return;
	end

	for index, button in ipairs(self.MinimizedSearchBox:GetButtons()) do
		if index <= dataProviderSize then
			local recipeInfo = self.searchDataProvider:Find(index);
			button.recipeInfo = recipeInfo;
			button.Name:SetText(recipeInfo.name);
			button.Icon:SetTexture(recipeInfo.icon);
			button:Show();
		else
			button:Hide();
		end
	end

	local finished = true;
	local dbLoaded = true;
	self.MinimizedSearchBox:UpdateSearchPreview(finished, dbLoaded, dataProviderSize);
end

function ProfessionsCraftingPageMixin:Init(professionInfo)
	-- We don't need to modify the recipe list if we're viewing the recrafting instance.
	local transitionData = Professions.GetRecraftingTransitionData();
	if transitionData and professionInfo.openRecipeID then
		local recraftRecipeInfo = C_TradeSkillUI.GetRecipeInfo(professionInfo.openRecipeID);
		if recraftRecipeInfo then
			local skipSelectInList = true;
			self:SelectRecipe(recraftRecipeInfo, skipSelectInList);
		end

		-- Wait to erase the recraft instance information until after the form updates. It's needed to
		-- understand the recipe being shown is a recraft instead of a regular craft.
		Professions.EraseRecraftingTransitionData();
		return;
	end

	local oldProfessionInfo = self.professionInfo;
	self.professionInfo = professionInfo;

	local noStripCategories;
	if C_TradeSkillUI.IsRuneforging() then
		professionInfo.professionID = Constants.ProfessionConsts.RUNEFORGING_SKILL_LINE_ID;
		noStripCategories = {Constants.ProfessionConsts.RUNEFORGING_ROOT_CATEGORY_ID};
	end

	local changedProfessionID = not oldProfessionInfo or oldProfessionInfo.professionID ~= self.professionInfo.professionID;
	if changedProfessionID then
		self.RecipeList:ProfessionChanged();
	end

	Professions.UpdateRankBarVisibility(self.RankBar, self.professionInfo);

	local searching = self.RecipeList.SearchBox:HasText();
	local dataProvider = Professions.GenerateCraftingDataProvider(self.professionInfo.professionID, searching, noStripCategories, self:GetCollapses());
	
	if searching or changedProfessionID then
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
	else
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end
	self.RecipeList.NoResultsText:SetShown(dataProvider:IsEmpty());
	
	local minimized = ProfessionsUtil.IsCraftingMinimized();
	if minimized and self.MinimizedSearchBox:IsCurrentTextValidForSearch() then
		self.searchDataProvider = CreateDataProvider();
		for index, node in dataProvider:EnumerateEntireRange() do
			local elementData = node:GetData();
			local recipeInfo = elementData.recipeInfo;
			if recipeInfo and recipeInfo.learned and not recipeInfo.favoritesInstance then
				self.searchDataProvider:Insert(elementData.recipeInfo);
			end
		end

		self.MinimizedSearchResults:GetTitleText():SetText(SEARCH_RESULTS_STRING_WITH_COUNT:format(
			self.MinimizedSearchBox:GetText(), self.searchDataProvider:GetSize()));

		if self.MinimizedSearchBox:HasFocus() then
			self:UpdateSearchPreview();
		end
	end
	
	if not minimized then
		self.searchDataProvider = nil;
	end

	--[[ Because we're rebuilding the data provider, we need to either make an initial selection or
	reselect the recipe we previously had selected. If we've selected a recipe from another profession
	we ignore any previous selection.--]]

	local currentRecipeInfo = nil;
	local openRecipeID = professionInfo.openRecipeID;
	if openRecipeID then
		currentRecipeInfo = FindRecipeInfo(dataProvider, openRecipeID);
	elseif changedProfessionID then
		currentRecipeInfo = FindFirstRecipe(dataProvider);
	end

	if not currentRecipeInfo then
		local previousRecipeID = self.RecipeList:GetPreviousRecipeID();
		currentRecipeInfo = FindRecipeInfo(dataProvider, previousRecipeID);
	end

	if not currentRecipeInfo then
		currentRecipeInfo = (not changedProfessionID) and self.SchematicForm:GetRecipeInfo();
		if currentRecipeInfo then
			-- The form may not be the base recipe ID, so find the first info
			-- if we expect to retrieve it from the data provider.
			currentRecipeInfo = Professions.GetFirstRecipe(currentRecipeInfo);
		else
			currentRecipeInfo = FindFirstRecipe(dataProvider);
		end
	end

	local hasRecipe = currentRecipeInfo ~= nil;
	if hasRecipe then
		local scrollToRecipe = openRecipeID ~= nil;
		self.RecipeList:SelectRecipe(currentRecipeInfo, scrollToRecipe);
	else
		self.SchematicForm:Init(nil);
	end

	self.ConcentrationDisplay:ShowProfessionConcentration(professionInfo);

	self:ValidateControls();
end

function ProfessionsCraftingPageMixin:Refresh(professionInfo)
	if self:IsVisible() then
		self:SetTitle();
	end

	self:Init(professionInfo);

	local isRuneforging = C_TradeSkillUI.IsRuneforging();

	local schematicWidth;
	local minimized = ProfessionsUtil.IsCraftingMinimized();
	if minimized then
		self.RecipeList:Hide();
		self.MinimizedSearchBox:Show();
		schematicWidth = 395;
	else
		self.RecipeList:Show();
		self.MinimizedSearchBox:Hide();
		self.MinimizedSearchResults:Hide();

	local useCondensedPanel = C_TradeSkillUI.IsNPCCrafting() or isRuneforging;
		schematicWidth = useCondensedPanel and 500 or 655;
	end
	self.SchematicForm:SetWidth(schematicWidth);
	
	if minimized then
		self.SchematicForm.MinimalBackground:SetAtlas("Professions-MinimizedView-Background", TextureKitConstants.UseAtlasSize);
		self.SchematicForm.MinimalBackground:Show();
		self.SchematicForm.Background:Hide();

		self.CreateButton:SetPoint("BOTTOMRIGHT", -9, 13);

		self.RecipeList:Hide();
		self.LinkButton:Hide();
		self.RankBar:Hide();
		self:HideInventorySlots();
	else
		self.SchematicForm.Background:SetAtlas(Professions.GetProfessionBackgroundAtlas(professionInfo), TextureKitConstants.IgnoreAtlasSize);
		self.SchematicForm.Background:Show();
		self.SchematicForm.MinimalBackground:Hide();

		self.CreateButton:SetPoint("BOTTOMRIGHT", -9, 7);

	if Professions.UpdateRankBarVisibility(self.RankBar, professionInfo) then
		self.RankBar:Update(professionInfo);
	end

	self:ConfigureInventorySlots(professionInfo);

	self.LinkButton:SetShown(C_TradeSkillUI.CanTradeSkillListLink() and Professions.InLocalCraftingMode());
	end

	if minimized then
		self.ConcentrationDisplay:SetPoint("TOPLEFT", 74, -32);
	else
		self.ConcentrationDisplay:SetPoint("TOPLEFT", 120, -35);
	end

	self.TutorialButton:SetShown(not isRuneforging);

	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end

	self:ValidateControls();
end

function ProfessionsCraftingPageMixin:CreateInternal(recipeID, count, recipeLevel)
	self:SetOverrideCastBarActive(true);
	local transaction = self.SchematicForm:GetTransaction();
	local applyConcentration = transaction:IsApplyingConcentration();
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		local salvageItem = transaction:GetSalvageAllocation();
		if salvageItem then
			local itemLocation = C_Item.GetItemLocation(salvageItem:GetItemGUID());
			if itemLocation then
				local craftingReagentTbl = transaction:CreateCraftingReagentInfoTbl();
				C_TradeSkillUI.CraftSalvage(recipeID, count, itemLocation, craftingReagentTbl, applyConcentration);
			end
		end
	else
		if transaction:HasRecraftAllocation() then
			local craftingReagentTbl = transaction:CreateCraftingReagentInfoTbl();
			local removedModifications = Professions.PrepareRecipeRecraft(transaction, craftingReagentTbl);
			
			local result = C_TradeSkillUI.RecraftRecipe(transaction:GetRecraftAllocation(), craftingReagentTbl, removedModifications, applyConcentration);
			if result then
				-- Create an expected table of item modifications so that we don't incorrectly deallocate
				-- an item modification slot on form refresh that has just been installed but hasn't been stamped
				-- with the item modification yet.
				transaction:GenerateExpectedItemModifications();
			end
		else
			local craftingReagentInfos;
			if transaction:IsManuallyAllocated() then
				craftingReagentInfos = transaction:CreateCraftingReagentInfoTbl();
			else
				craftingReagentInfos = transaction:CreateOptionalOrFinishingCraftingReagentInfoTbl();
			end

			local enchantItem = transaction:GetEnchantAllocation();
			if enchantItem then
				if count > 1 and C_TradeSkillUI.CanStoreEnchantInItem(enchantItem:GetItemGUID()) then
					self.vellumItemID = enchantItem:GetItemID();
				end
				C_TradeSkillUI.CraftEnchant(recipeID, count, craftingReagentInfos, enchantItem:GetItemLocation(), applyConcentration);
			else
				C_TradeSkillUI.CraftRecipe(recipeID, count, craftingReagentInfos, recipeLevel, nil, applyConcentration);
			end
		end
	end

	self.CreateMultipleInputBox:ClearFocus();
	self:ValidateControls();

	self.SchematicForm.Details:Reset();

	local animSpeedMultiplier = count > 1 and 2 or 1;
	self.SchematicForm.Details:SetQualityMeterAnimSpeedMultiplier(animSpeedMultiplier);

	if count == 1 then
		self.SchematicForm.Details:CancelAllAnims();
	end
end

function ProfessionsCraftingPageMixin:OnViewGuildCraftersClicked()
	local professionInfo = Professions.GetProfessionInfo();
	local effectiveSkillLineID = professionInfo.parentProfessionID or professionInfo.professionID;
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	if effectiveSkillLineID and currentRecipeInfo.recipeID then
		self.GuildFrame:ShowGuildRecipe(effectiveSkillLineID, currentRecipeInfo.recipeID, self.SchematicForm:GetCurrentRecipeLevel());
	end
end

function ProfessionsCraftingPageMixin:CreateAll()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	local craftableCount = self:GetCraftableCount();
	self:CreateInternal(currentRecipeInfo.recipeID, craftableCount, self.SchematicForm:GetCurrentRecipeLevel());
end

function ProfessionsCraftingPageMixin:Create()
	local function InvokeCreate()
		local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
		self:CreateInternal(currentRecipeInfo.recipeID, self.CreateMultipleInputBox:GetValue(), self.SchematicForm:GetCurrentRecipeLevel());
	end

	local canContinue = true;
	local transaction = self.SchematicForm:GetTransaction();
	if transaction:IsRecraft() then
		local itemIDs = TableUtil.Transform(transaction:CreateCraftingReagentInfoTbl(), function(craftingReagentInfo)
			return craftingReagentInfo.itemID;
		end);

		local warnings = C_TradeSkillUI.GetRecraftRemovalWarnings(transaction:GetRecraftAllocation(), itemIDs);
		canContinue = #warnings == 0;
		if not canContinue then
			local referenceKey = self;
			if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
				local data = { text = warnings[1], callback = InvokeCreate, showAlert = true};
				StaticPopup_ShowCustomGenericConfirmation(data);
			end
		end
	end

	if canContinue then
		InvokeCreate();
	end
	
end

function ProfessionsCraftingPageMixin:ConfigureInventorySlots(info)
	if (not Professions.InLocalCraftingMode()) or C_TradeSkillUI.IsRuneforging() or info.profession == nil then
		self:HideInventorySlots();
	else
		local professionSlots = C_TradeSkillUI.GetProfessionSlots(info.profession);
		local numShownSlots = 0;
		for index, inventorySlot in ipairs(self.InventorySlots) do
			local show = tContains(professionSlots, inventorySlot.slotID);
			inventorySlot:SetShown(show);
			if show then
				numShownSlots = numShownSlots + 1;
			end
		end
		self.GearSlotDivider:SetShown(numShownSlots > 1);
	end
end

function ProfessionsCraftingPageMixin:GetCurrentRecraftingRecipeID()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	if currentRecipeInfo and currentRecipeInfo.isRecraft then
		return currentRecipeInfo.recipeID;
	end
	return nil;
end

function ProfessionsCraftingPageMixin:HideInventorySlots()
	for index, inventorySlot in ipairs(self.InventorySlots) do
		inventorySlot:Hide();
	end
	self.GearSlotDivider:Hide();
end

function ProfessionsCraftingPageMixin:AnyInventorySlotShown()
	for index, inventorySlot in ipairs(self.InventorySlots) do
		if inventorySlot:IsShown() then
			return true;
		end
	end

	return false;
end

ProfessionsCraftingPage_HelpPlate = 
{
	FramePos = { x = 5,	y = -22 },
};

function ProfessionsCraftingPageMixin:UpdateTutorial()
	ProfessionsCraftingPage_HelpPlate.FrameSize = { width = self:GetDesiredPageWidth(), height = 635 };

	local maxTutorializedAreas = 8;
	for i = 1, maxTutorializedAreas do
		ProfessionsCraftingPage_HelpPlate[i] = nil;
	end

	local recipeSearchBar = { ToolTipDir = "DOWN", ToolTipText = ProfessionsFrame.professionType == Professions.ProfessionType.Gathering and PROFESSIONS_GATHERING_JOURNAL_LIST_HELP or PROFESSIONS_CRAFTING_HELP_FILTERS };
	if ProfessionsUtil.IsCraftingMinimized() then
		recipeSearchBar.ButtonPos = { x = 250, y = -3 };
		recipeSearchBar.HighLightBox = { x = 169, y = -9, width = 224, height = 30 };
	else
		recipeSearchBar.ButtonPos = { x = 125, y = -44 };
		recipeSearchBar.HighLightBox = { x = 0, y = -52, width = 271, height = 30 };
	end
	table.insert(ProfessionsCraftingPage_HelpPlate, recipeSearchBar);

	if self.SchematicForm.Reagents:IsShown() then
		local reagentsTopPoint = self.SchematicForm.Reagents:GetTop() - self:GetTop() + 24;
		local reagentsLeftPoint = self.SchematicForm.Reagents:GetLeft() - self:GetLeft() - 20;
		local basicReagentsBoxLeft = reagentsLeftPoint;
		local basicReagentsBoxTop = reagentsTopPoint;
		local reagentsBoxWidth = 359;
		local slots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Basic);
		local slotCount = slots and #slots or 0;
		local slotSpacing = (math.max(0, slotCount - 1) * -3);
		local slotHeight = (50 * math.min(4, slotCount));
		local reagentsBoxHeight = 32 + slotHeight + slotSpacing;
		local reagentsButtonXOfs = 150;
		local reagentsButtonYOfs = -5;

		local basicReagentsSection =
		{
			ButtonPos = { x = basicReagentsBoxLeft + reagentsBoxWidth - 25, y = basicReagentsBoxTop + reagentsButtonYOfs },
			HighLightBox = { x = basicReagentsBoxLeft, y = basicReagentsBoxTop, width = reagentsBoxWidth, height = reagentsBoxHeight },
			ToolTipDir = "UP",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BASIC_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, basicReagentsSection);

		if self.SchematicForm.OptionalReagents:IsShown() then
			local y = basicReagentsBoxTop - reagentsBoxHeight - 5;
			local optionalSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Optional);
			local optionalSlotCount = optionalSlots and #optionalSlots or 0;
			local optionalSlotSpacing = (math.max(0, optionalSlotCount - 1) * -5);
			local optionalSlotWidth = (50 * math.max(3, optionalSlotCount));
			local width = 25 + optionalSlotWidth + optionalSlotSpacing;

			local optionalReagentsSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + width - 25, y = y - 15 },
				HighLightBox = { x = basicReagentsBoxLeft, y = basicReagentsBoxTop - reagentsBoxHeight - 3, width = width, height = 85 },
				ToolTipDir = "UP",
				ToolTipText = PROFESSIONS_CRAFTING_HELP_OPTIONAL_REAGENTS,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, optionalReagentsSection);
		end

		if self.SchematicForm.AllocateBestQualityCheckbox:IsShown() then
			local width = 210;
			local y = -545;
			local bestQualityCheckboxSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + width - 25, y = y },
				HighLightBox = { x = basicReagentsBoxLeft, y = y, width = width, height = 50 },
				ToolTipDir = "RIGHT",
				ToolTipText = PROFESSIONS_CRAFTING_HELP_BEST_QUALITY,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, bestQualityCheckboxSection);
		end
	end

	local details = self.SchematicForm.Details;
	local detailsShown = details:IsShown();
	local qualityMeter = self.SchematicForm.Details.QualityMeter;
	local finishingReagents = self.SchematicForm.Details.CraftingChoicesContainer.FinishingReagentSlotContainer;
	if detailsShown and qualityMeter:IsShown() then
		local qualityMeterTopPoint = qualityMeter:GetTop() - self:GetTop() + 14;
		local qualityMeterLeftPoint = qualityMeter:GetLeft() - self:GetLeft() - 7;
		local qualityMeterBoxWidth = 251;
		local qualityMeterSection =
		{
			ButtonPos = { x = qualityMeterLeftPoint - 22, y = qualityMeterTopPoint - 5 },
			HighLightBox = { x = qualityMeterLeftPoint, y = qualityMeterTopPoint, width = qualityMeterBoxWidth, height = 54 },
			ToolTipDir = "DOWN",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BAR,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, qualityMeterSection);
	end
	if detailsShown and not ProfessionsUtil.IsCraftingMinimized() then
		local statsTopPoint = details:GetTop() - self:GetTop() + 6;
		local statsLeftPoint = details:GetLeft() - self:GetLeft();
		local statsBoxWidth = 251;
		local statsBoxHeight;
		if qualityMeter:IsShown() then
			statsBoxHeight = details:GetTop() - qualityMeter:GetTop() - 11;
		elseif finishingReagents:IsShown() then
			statsBoxHeight = details:GetTop() - finishingReagents:GetTop() - 2;
		else
			statsBoxHeight = details:GetHeight() - 40;
		end
		local statsSection =
		{
			ButtonPos = { x = statsLeftPoint - 23, y = statsTopPoint - 45},
			HighLightBox = { x = statsLeftPoint, y = statsTopPoint, width = statsBoxWidth, height = statsBoxHeight },
			ToolTipDir = "DOWN",
			ToolTipText = details.recipeInfo.isGatheringRecipe and PROFESSIONS_GATHERING_JOURNAL_STATS_HELP or PROFESSIONS_CRAFTING_HELP_STATS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, statsSection);
	end

	if detailsShown and finishingReagents:IsShown() then
		local finishingReagentsTopPoint = finishingReagents:GetTop() - self:GetTop();
		local finishingReagentsLeftPoint = finishingReagents:GetLeft() - self:GetLeft() - 5;
		local width = 130;
		local finishingReagentsSection =
		{
			ButtonPos = { x = finishingReagentsLeftPoint + width - 25, y = finishingReagentsTopPoint - 30 },
			HighLightBox = { x = finishingReagentsLeftPoint, y = finishingReagentsTopPoint, width = width, height = 80 },
			ToolTipDir = "DOWN",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_FINISHING_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, finishingReagentsSection);
	end

	if ProfessionsUtil.IsCraftingMinimized() and self.SchematicForm.FinishingReagents:IsShown() then
		local finishingReagentsTopPoint = self.SchematicForm.FinishingReagents:GetTop() - self:GetTop();
		local finishingReagentsLeftPoint = self.SchematicForm.FinishingReagents:GetLeft() - self:GetLeft();
		local slots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Finishing);
		local slotCount = slots and #slots or 0;
		local slotSpacing = (math.max(0, slotCount - 1) * -5);
		local slotWidth = (50 * math.max(3, slotCount));
		local width = 25 + slotWidth + slotSpacing;

		local finishingReagentsSection =
		{
			ButtonPos = { x = finishingReagentsLeftPoint + width - 42, y = finishingReagentsTopPoint + 9},
			HighLightBox = { x = finishingReagentsLeftPoint - 17, y = finishingReagentsTopPoint + 28, width = width, height = 85 },
			ToolTipDir = "UP",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_FINISHING_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, finishingReagentsSection);
	end

	if self:AnyInventorySlotShown() then
		local gearSection =
		{
			ButtonPos = { x = 894, y = -3 },
			HighLightBox = { x = 758, y = 1, width = 175, height = 56 },
			ToolTipDir = "DOWN",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_GEAR,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, gearSection);
	end
end

function ProfessionsCraftingPageMixin:ShowTutorial()
	self:UpdateTutorial();
	HelpPlate_Show(ProfessionsCraftingPage_HelpPlate, self, self.TutorialButton);
end

function ProfessionsCraftingPageMixin:IsTutorialShown()
	return HelpPlate_IsShowing(ProfessionsCraftingPage_HelpPlate);
end

function ProfessionsCraftingPageMixin:ToggleTutorial()
	if not self:IsTutorialShown() then
		self:ShowTutorial();
	else
		HelpPlate_Hide(true);
	end
end

function ProfessionsCraftingPageMixin:SetTitle()
	local professionFrame = self:GetParent();
	local professionInfo = professionFrame.professionInfo;
	if not professionInfo then
		return;
	end

	professionFrame:SetTitle(professionInfo.professionName or professionInfo.parentProfessionName);
end

function ProfessionsCraftingPageMixin:SetOverrideCastBarActive(active)
	if active == self.isOverrideCastBarActive then
		return;
	end

	if active then
		-- Only override the cast bar if the Player Cast Bar is currently locked to the Player Frame
		if PlayerCastingBarFrame:IsAttachedToPlayerFrame() then
			OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(self.OverlayCastBarAnchor, { hideBarText = true });
			self.isOverrideCastBarActive = true;
		end
	else
		OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
		self.isOverrideCastBarActive = false;
	end
end

function ProfessionsCraftingPageMixin:SchematicPostInit()
	local optionalReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Modifying);
	for _, slot in ipairs(optionalReagentSlots or {}) do
		local reagentSlotSchematic = slot:GetReagentSlotSchematic();
		local hasAllocation = self.SchematicForm.transaction:HasAnyAllocations(reagentSlotSchematic.slotIndex);
		if hasAllocation and slot.Button.locked then
			slot:SetOverrideNameColor(ERROR_COLOR);
            slot:SetColorOverlay(ERROR_COLOR);
		end
	end
end

function ProfessionsCraftingPageMixin:CheckShowHelptips()
	HelpTip:HideAllSystem(helpTipSystem);
	if not Professions.InLocalCraftingMode() or not self:IsVisible() or not self.SchematicForm.currentRecipeInfo then
		return;
	end

	-- NOTE: Helptips are shown on the next game frame to side-step a bug if the frame they are pointing at is instantiated in the same game frame the helptip is shown in.

	-- Quality reagent helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSION_QUALITY_REAGENTS) then
		local basicReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Basic);
		for _, slot in ipairs(basicReagentSlots or {}) do
			if Professions.GetReagentInputMode(slot:GetReagentSlotSchematic()) == Professions.ReagentInputMode.Quality then
				local helpTipInfo =
				{
					text = PROFESSIONS_TUTORIAL_REAGENT_QUALITY,
					buttonStyle = HelpTip.ButtonStyle.Close,
					targetPoint = HelpTip.Point.LeftEdgeCenter,
					system = helpTipSystem,
					acknowledgeOnHide = true,
					onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSION_QUALITY_REAGENTS,
				};
				RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, slot); end);
				return;
			end
		end
	end

	-- Quality bar helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSION_QUALITY_BAR) then
		if self.SchematicForm.Details.QualityMeter:IsVisible() then
			local helpTipInfo =
			{
				text = PROFESSIONS_TUTORIAL_QUALITY_BAR,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.LeftEdgeCenter,
				system = helpTipSystem,
				acknowledgeOnHide = true,
				onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSION_QUALITY_BAR,
			};
			RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, self.SchematicForm.Details.QualityMeter); end);
			return;
		end
	end

	-- New optional reagent helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSION_OPTIONAL_REAGENTS_NEW) then
		if self.SchematicForm.currentRecipeInfo.supportsCraftingStats then
			local optionalReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Modifying);
			for _, slot in ipairs(optionalReagentSlots or {}) do
				local _, haveAnyInPosession = slot:GetInventoryDetails();
				if haveAnyInPosession and not slot.Button.locked then
					local helpTipInfo =
					{
						text = PROFESSIONS_TUTORIAL_OPTIONAL_REAGENT,
						buttonStyle = HelpTip.ButtonStyle.Close,
						targetPoint = HelpTip.Point.LeftEdgeCenter,
						system = helpTipSystem,
						acknowledgeOnHide = true,
						onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
						cvarBitfield = "closedInfoFrames",
						bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSION_OPTIONAL_REAGENTS_NEW,
					};
					RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, slot); end);
					return;
				end
			end
		end
	end

	-- Old optional reagent helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_OPTIONAL_REAGENT_CRAFTING) then
		if not self.SchematicForm.currentRecipeInfo.supportsCraftingStats then
			local optionalReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Modifying);
			for _, slot in ipairs(optionalReagentSlots or {}) do
				local _, haveAnyInPosession = slot:GetInventoryDetails();
				if haveAnyInPosession and not slot.Button.locked then
					local helpTipInfo =
					{
						text = OPTIONAL_REAGENT_TUTORIAL_SLOT,
						buttonStyle = HelpTip.ButtonStyle.Close,
						targetPoint = HelpTip.Point.LeftEdgeCenter,
						system = helpTipSystem,
						acknowledgeOnHide = true,
						onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
						cvarBitfield = "closedInfoFrames",
						bitfieldFlag = LE_FRAME_TUTORIAL_OPTIONAL_REAGENT_CRAFTING,
					};
					RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, slot); end);
					return;
				end
			end
		end
	end

	-- Finishing reagent helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSION_FINISHING_REAGENTS) then
		local finishingReagentSlots = self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Finishing);
		for _, slot in ipairs(finishingReagentSlots or {}) do
			if not slot.Button.locked then
				local helpTipInfo =
				{
					text = PROFESSIONS_TUTORIAL_FINISHING_REAGENT,
					buttonStyle = HelpTip.ButtonStyle.Close,
					targetPoint = HelpTip.Point.LeftEdgeCenter,
					system = helpTipSystem,
					acknowledgeOnHide = true,
					onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSION_FINISHING_REAGENTS,
				};
				RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, slot.Button); end);
				return;
			end
		end
	end

	-- Recrafting helptip
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS_RECRAFT) then
		if self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() and not self.SchematicForm.transaction:GetRecraftAllocation() then
			local helpTipInfo =
			{
				text = PROFESSIONS_TUTORIAL_RECRAFT,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				system = helpTipSystem,
				acknowledgeOnHide = true,
				onAcknowledgeCallback = function() self:CheckShowHelptips(); end,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_RECRAFT,
			};
			RunNextFrame(function() HelpTip:Show(UIParent, helpTipInfo, self.SchematicForm.recraftSlot.InputSlot); end);
			return;
		end
	end
end