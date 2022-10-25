
ProfessionsGearSlotTemplateMixin = CreateFromMixins(PaperDollItemSlotButtonMixin);


ProfessionsCraftingPageMixin = {};

local ProfessionsCraftingPageEvents =
{
	"TRADE_SKILL_DATA_SOURCE_CHANGING",
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"UPDATE_TRADESKILL_CAST_COMPLETE",
	"TRADE_SKILL_CLOSE",
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
	"UNIT_SPELLCAST_INTERRUPTED",
};

function ProfessionsCraftingPageMixin:OnLoad()
	self.RecipeList.FilterButton:SetResetFunction(Professions.SetDefaultFilters);
	self.RecipeList.FilterButton:SetScript("OnMouseDown", function(button, buttonName, down)
		UIMenuButtonStretchMixin.OnMouseDown(self.RecipeList.FilterButton, buttonName);
		ToggleDropDownMenu(1, nil, self.RecipeList.FilterDropDown, self.RecipeList.FilterButton, 74, 15);
		PlaySound(SOUNDKIT.UI_PROFESSION_FILTER_MENU_OPEN_CLOSE);
	end);
	EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", self.OnRecipeSelected, self);

	UIDropDownMenu_SetInitializeFunction(self.RecipeList.FilterDropDown, GenerateClosure(self.InitFilterMenu, self));
	UIDropDownMenu_SetDisplayMode(self.RecipeList.FilterDropDown, "MENU");

	self.CreateButton:SetScript("OnClick", GenerateClosure(self.Create, self));
	self.CreateAllButton:SetScript("OnClick", GenerateClosure(self.CreateAll, self));

	self.RecipeList.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);
		Professions.OnRecipeListSearchTextChanged(editBox:GetText());
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
			else
				ToggleDropDownMenu(1, nil, self.LinkDropDown, self.LinkButton, 25, 25);
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

	UIDropDownMenu_Initialize(self.LinkDropDown, GenerateClosure(self.InitLinkDropdown, self), "MENU");

	self.flyoutSettings = 
	{
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		anchorX = 0,
		anchorY = -3,
		verticalAnchorX = 0,
		verticalAnchorY = 0,
		highlightSizeX = 45,
		highlightSizeY = 45,
		highlightOfsY = 3,
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
end

function ProfessionsCraftingPageMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGING" then	
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		self:Reset();
		self.GuildFrame:Clear();
	elseif event == "UPDATE_TRADESKILL_CAST_COMPLETE" then
		self:ContinueCrafting();
	elseif event == "TRADE_SKILL_CLOSE" then
		HideUIPanel(self);
	elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
		local transaction = self.SchematicForm:GetTransaction();
		if transaction then
			transaction:SanitizeTargetAllocations();
			-- If we are in the process of enchanting multiple vellums, we may need to reassign
			-- a valid target if the previous item stack was depleted.
			if self.craftingQueueEnchantID and not transaction:GetEnchantAllocation() then
				ItemUtil.IteratePlayerInventory(function(itemLocation)
					if C_Item.GetItemID(itemLocation) == self.craftingQueueEnchantID then
						local item = Item:CreateFromItemGUID(C_Item.GetItemGUID(itemLocation));
						transaction:SetEnchantAllocation(item);
						return true;
					end
				end);
			end
		end
		self:ValidateControls();
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		self:ClearCraftingQueue();
		self:ValidateControls();
	end
end

function ProfessionsCraftingPageMixin:InitLinkDropdown()
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = TRADESKILL_POST;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = true;
	info.func = function(_, channel)
		local link = C_TradeSkillUI.GetTradeSkillListLink();
		if link then
			ChatFrame_OpenChat(channel.." "..link, DEFAULT_CHAT_FRAME);
		end
	end;

	info.text = GUILD;
	info.arg1 = SLASH_GUILD1;
	info.disabled = not IsInGuild();
	UIDropDownMenu_AddButton(info);

	info.text = PARTY;
	info.arg1 = SLASH_PARTY1;
	info.disabled = (GetNumSubgroupMembers() == 0);
	UIDropDownMenu_AddButton(info);

	info.text = RAID;
	info.disabled = not IsInRaid();
	info.arg1 = SLASH_RAID1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false

	local channels = { GetChannelList() };
	for i = 1, #channels, 3 do
		info.text = ChatFrame_ResolveChannelName(channels[i + 1]);
		info.arg1 = "/"..channels[i];
		info.disabled = channels[i + 2];
		UIDropDownMenu_AddButton(info);
	end
end

function ProfessionsCraftingPageMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCraftingPageEvents);
end

function ProfessionsCraftingPageMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsCraftingPageEvents);

	self.CraftingOutputLog:Close();
	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end

	self:Reset();
end

function ProfessionsCraftingPageMixin:Reset()
	self.professionInfo = nil;
end

function ProfessionsCraftingPageMixin:GetDesiredPageWidth()
	local compact = C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging();
	return compact and 811 or 1105;
end

function ProfessionsCraftingPageMixin:OnReagentClicked(reagentName)
	self.RecipeList.SearchBox:SetText(reagentName);
end

function ProfessionsCraftingPageMixin:OnProfessionSelected(professionInfo)
	self:Init(professionInfo);
end

function ProfessionsCraftingPageMixin:InitFilterMenu(dropdown, level)
	Professions.InitFilterMenu(dropdown, level, GenerateClosure(self.UpdateFilterResetVisibility, self));
end

function ProfessionsCraftingPageMixin:UpdateFilterResetVisibility()
	self.RecipeList.FilterButton.ResetButton:SetShown(not Professions.IsUsingDefaultFilters());
end

function ProfessionsCraftingPageMixin:OnRecipeSelected(recipeInfo)
	-- Only expect that if this is called, it is in response to selecting a recipe from the
	-- list, in which case we never want the recrafting version of a recipe to be displayed.
	Professions.EraseRecraftingTransitionData();

	self:SelectRecipe(recipeInfo);
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
	end
end

function ProfessionsCraftingPageMixin:GetCraftableCount()
	local transaction = self.SchematicForm:GetTransaction();
	local intervals = math.huge;

	local function ClampInvervals(quantity, quantityMax)
		intervals = math.min(intervals, math.floor(quantity / quantityMax));
	end

	local function ClampAllocations(allocations)
		for index, allocation in allocations:Enumerate() do
			local quantity = Professions.GetReagentQuantityInPossession(allocation:GetReagent());
			local quantityMax = allocation:GetQuantity();
			ClampInvervals(quantity, quantityMax);
		end
	end

	if transaction:IsManuallyAllocated() then
		-- If manually allocated, we can only accumulate the reagents currently allocated.
		for index, allocations in transaction:EnumerateAllAllocations() do
			if transaction:IsSlotBasicReagentType(index) then
				ClampAllocations(allocations);
			end
		end
	else
		-- If automatically allocated, we can accumulate every compatible reagent regardless of what
		-- is currently allocated.
		for index, reagents in transaction:EnumerateAllSlotReagents() do
			if transaction:IsSlotBasicReagentType(index) then
				local quantity = AccumulateOp(reagents, function(reagent)
					return Professions.GetReagentQuantityInPossession(reagent);
				end);

				local quantityMax = transaction:GetQuantityRequiredInSlot(index);
				ClampInvervals(quantity, quantityMax);
			end
		end
	end

	-- Optionals and finishers are included unless the current reagent matches
	-- a recrafting modification.
	for index, allocations in transaction:EnumerateAllAllocations() do
		if not transaction:IsSlotBasicReagentType(index) then
			local allocs = allocations:SelectFirst();
			if allocs then
				local clamp = true;
				local modification = transaction:GetModificationAtIndex(index);
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
			local quantity = salvageItem:GetStackCount();
			if quantity then
				local recipeSchematic = transaction:GetRecipeSchematic();
				ClampInvervals(quantity, recipeSchematic.quantityMax); 
			end
		end
	elseif transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
		local enchantItem = transaction:GetEnchantAllocation();
		if enchantItem then
			if enchantItem:IsStackable() then
				local quantity = ItemUtil.GetCraftingReagentCount(enchantItem:GetItemID());
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

function ProfessionsCraftingPageMixin:ValidateControls()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();

	local isRuneforging = C_TradeSkillUI.IsRuneforging();
	if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
	   and not currentRecipeInfo.isRecraft
	   and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe then
		self.CreateButton:Show();
		self.ViewGuildCraftersButton:Hide();

		local transaction = self.SchematicForm:GetTransaction();
		if currentRecipeInfo.createsItem and not transaction:HasRecraftAllocation() then
			self.CreateAllButton:Show();
			self.CreateMultipleInputBox:Show();
		else
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
		end

		local countMax = self:GetCraftableCount();
		if countMax > 0 then
			local count = 0;
			if self.craftingQueue then
				count = self.craftingQueue:GetTotal() + 1;
			else
				count = C_TradeSkillUI.GetRecipeRepeatCount();
			end

			self:SetupMultipleInputBox(count, countMax);
		else
			self:SetupMultipleInputBox(0, 0);
		end


		if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
			self.CreateButton:SetTextToFit(CREATE_PROFESSION_ENCHANT);
			local quantity = math.min(1, countMax);
			self.CreateAllButton:SetTextToFit(PROFESSIONS_CREATE_ALL_FORMAT:format(PROFESSIONS_ENCHANT_ALL, quantity));
		else
			if currentRecipeInfo.abilityVerb then
				-- abilityVerb is recipe-level override
				self.CreateButton:SetTextToFit(currentRecipeInfo.abilityVerb);
			elseif currentRecipeInfo.alternateVerb then
				-- alternateVerb is profession-level override
				self.CreateButton:SetTextToFit(currentRecipeInfo.alternateVerb);
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
		
		local function IsRecipeOnCooldown(recipeID)
			local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(recipeID);
			if not cooldown then
				return false;
			end

			if charges > 0 then
				return false;
			end

			return true;
		end

		-- CAIS not relevant anymore since the client is denied login. Nevertheless, this is carried over from the
		-- previous implementation in case the CAIS system changes.
		local enabled;
		if PartialPlayTime() then
			local reasonText = PLAYTIME_TIRED_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltipText = reasonText;
			self.CreateAllButton.tooltipText = reasonText;
			enabled = false;
		elseif NoPlayTime() then
			local reasonText = PLAYTIME_UNHEALTHY_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltipText = reasonText;
			self.CreateAllButton.tooltipText = reasonText;
			enabled = false;
		elseif IsRecipeOnCooldown(currentRecipeInfo.recipeID) then
			self.CreateButton.tooltipText = PROFESSIONS_RECIPE_COOLDOWN;
			self.CreateAllButton.tooltipText = PROFESSIONS_RECIPE_COOLDOWN;
			enabled = false;
		else
			self.CreateButton.tooltipText = nil;
			self.CreateAllButton.tooltipText = nil;
			
			local requiresCount = not isRuneforging;
			if requiresCount and countMax <= 0 then
				enabled = false;
			elseif not currentRecipeInfo.craftable or currentRecipeInfo.disabled then
				enabled = false;
			else
				enabled = true;
			end
		end

		local restrictAllButton = false;
		if enabled then
			-- Enchanting does not require the optional target to be set. When it is not,
			-- clicking the create button creates a targeting cursor.
			if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
				enabled = transaction:HasAllocatedSalvageRequirements();
			else
				if not transaction:HasAllocatedReagentRequirements() then
					enabled = false;
				end

				if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
					local doesTargetSupportStacks = false;
					local enchantItem = transaction:GetEnchantAllocation();
					if enchantItem then
						doesTargetSupportStacks = enchantItem:IsStackable();
					end

					if not doesTargetSupportStacks then
						restrictAllButton = true;
					end
				end
			end

			if not enabled then
				self.CreateButton.tooltipText = PROFESSIONS_INSUFFICIENT_REAGENTS;
				self.CreateAllButton.tooltipText = PROFESSIONS_INSUFFICIENT_REAGENTS;
			end
		end

		self.CreateButton:SetEnabled(enabled);
		self.CreateAllButton:SetEnabled(enabled and not restrictAllButton);
		self.CreateMultipleInputBox:SetEnabled(enabled and not restrictAllButton);

		if isRuneforging then
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
		end
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

function ProfessionsCraftingPageMixin:Init(professionInfo)
	-- If we're reinitializing the crafting page due to selecting a recrafting recipe
	-- then don't modify the recipe list at all and just forward the desired recipe to the
	-- schematic form in SelectRecipe.
	local transitionData = Professions.GetRecraftingTransitionData();
	if transitionData then
		local dataProvider = self.RecipeList.ScrollBox:GetDataProvider();
		if dataProvider then
			local node = dataProvider:FindElementDataByPredicate(function(node)
				local data = node:GetData();
				local recipeInfo = data.recipeInfo;
				return recipeInfo and recipeInfo.recipeID == professionInfo.openRecipeID;
			end);

			if node then
				local data = node:GetData();
				local recipeInfo = data.recipeInfo;

				local skipSelectInList = true;
				self:SelectRecipe(recipeInfo, skipSelectInList);
				return;
			end
		end
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

	Professions.UpdateRankBarVisibility(self.RankBar, professionInfo);

	local searching = self.RecipeList.SearchBox:HasText();
	local dataProvider = Professions.GenerateCraftingDataProvider(self.professionInfo.professionID, searching, noStripCategories);
	
	if searching or changedProfessionID then
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
	else
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end

	-- Because we're rebuilding the data provider, we need to either make an initial selection or
	-- reselect the recipe we previously had selected. If we've selected a recipe from another profession
	-- we ignore any previous selection.

	local function SelectInitialRecipe()
		-- Select an initial recipe. As mentioned above, every recipe in the data provider is the
		-- first recipe in the instance it has levels.
		for index, node in dataProvider:Enumerate() do
			local data = node:GetData();
			local recipeInfo = data.recipeInfo;
			if recipeInfo then
				return recipeInfo;
			end
		end
	end

	local function SetCurrentRecipeInfo(recipeID)
		if not recipeID then
			return nil;
		end

		local node = dataProvider:FindElementDataByPredicate(function(node)
			local data = node:GetData();
			local recipeInfo = data.recipeInfo;
			return recipeInfo and recipeInfo.recipeID == recipeID;
		end);

		if node then
			local data = node:GetData();
			return data.recipeInfo;
		end
	end

	local currentRecipeInfo = nil;
	if changedProfessionID then
		currentRecipeInfo = SelectInitialRecipe();
	end

	local openRecipeID = professionInfo.openRecipeID;
	if not currentRecipeInfo then
		currentRecipeInfo = SetCurrentRecipeInfo(openRecipeID);
	end

	if not currentRecipeInfo then
		local previousRecipeID = self.RecipeList:GetPreviousRecipeID();
		currentRecipeInfo = SetCurrentRecipeInfo(previousRecipeID);
	end

	if not currentRecipeInfo then
		currentRecipeInfo = (not changedProfessionID) and self.SchematicForm:GetRecipeInfo();
		if currentRecipeInfo then
			-- The form may not be the base recipe ID, so find the first info
			-- if we expect to retrieve it from the data provider.
			currentRecipeInfo = Professions.GetFirstRecipe(currentRecipeInfo);
		else
			currentRecipeInfo = SelectInitialRecipe();
		end
	end

	local hasRecipe = currentRecipeInfo ~= nil;
	if hasRecipe then
		local scrollToRecipe = openRecipeID ~= nil;
		self.RecipeList:SelectRecipe(currentRecipeInfo, scrollToRecipe);
	else
		self.SchematicForm:Init(nil);
		self:ValidateControls();
	end
end

function ProfessionsCraftingPageMixin:Refresh(professionInfo)
	self.SchematicForm.Background:SetAtlas(Professions.GetProfessionBackgroundAtlas(professionInfo), TextureKitConstants.IgnoreAtlasSize);

	local isRuneforging = C_TradeSkillUI.IsRuneforging();
	local useCondensedPanel = C_TradeSkillUI.IsNPCCrafting() or isRuneforging;
	local schematicWidth = useCondensedPanel and 500 or 793;
	self.SchematicForm:SetWidth(schematicWidth);
	
	if Professions.UpdateRankBarVisibility(self.RankBar, professionInfo) then
		self.RankBar:Update(professionInfo);
	end

	self:ConfigureInventorySlots(professionInfo);

	self.LinkButton:SetShown(C_TradeSkillUI.CanTradeSkillListLink() and Professions.InLocalCraftingMode());
	self.TutorialButton:SetShown(not isRuneforging);
	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end
	self:UpdateFilterResetVisibility();

	self.SchematicForm:Refresh();
	self:ValidateControls();
end

function ProfessionsCraftingPageMixin:ContinueCrafting()
	if self.craftingQueue then
		if not self.craftingCallback() then
			self:ClearCraftingQueue();
		end
	else
		C_TradeSkillUI.ContinueRecast();
	end
	self:ValidateControls();
end

function ProfessionsCraftingPageMixin:ClearCraftingQueue()
	self.craftingCallback = nil;
	self.craftingQueue = nil;
	self.craftingQueueEnchantID = nil;
end

function ProfessionsCraftingPageMixin:CreateInternal(recipeID, count, recipeLevel)
	local transaction = self.SchematicForm:GetTransaction();
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		local salvageItem = transaction:GetSalvageAllocation();
		if salvageItem then
			local itemLocation = C_Item.GetItemLocation(salvageItem:GetItemGUID());
			if itemLocation then
				C_TradeSkillUI.CraftSalvage(recipeID, count, itemLocation);
			end
		end
	else
		if transaction:HasRecraftAllocation() then
			local craftingReagentTbl = transaction:CreateCraftingReagentInfoTbl();

			local itemMods = transaction:GetRecraftItemMods();
			if itemMods then
				for dataSlotIndex, modification in ipairs(itemMods) do
					if modification.itemID > 0 then
						for _, craftingReagentInfo in ipairs(craftingReagentTbl) do
							if (craftingReagentInfo.itemID == modification.itemID) and (craftingReagentInfo.dataSlotIndex == modification.dataSlotIndex) then
								-- If the modification still exists in the same position, set it's quantity to 0 to inform the server
								-- not to modify this reagent.
								craftingReagentInfo.quantity = 0;
								break;
							end
						end
					end
				end
			end
			
			local result = C_TradeSkillUI.RecraftRecipe(transaction:GetRecraftAllocation(), craftingReagentTbl);
			if result then
				-- Create an expected table of item modifications so that we don't incorrectly deallocate
				-- an item modification slot on form refresh that has just been installed but hasn't been stamped
				-- with the item modification yet.
				transaction:GenerateExpectedItemModifications();
			end
		else
			local function CraftRecipe(count, craftingReagentTbl)
				C_TradeSkillUI.CraftRecipe(recipeID, count, craftingReagentTbl, recipeLevel);
			end

			local enchantItem = transaction:GetEnchantAllocation();

			if count > 1 then
				local ascending = not Professions.ShouldAllocateBestQualityReagents();
				self.craftingQueue = CreateProfessionsCraftingQueue(transaction);
				if transaction:IsManuallyAllocated() then
					self.craftingQueue:SetPartitions(transaction, count);
				else
					self.craftingQueue:CalculatePartitions(transaction, count, ascending);
				end

				-- When creating multiple enchants, the server will remove the items in the order
				-- discovered in inventory. Until this is fixed, replicate the expected order
				-- so we always have a valid target.
				local enchantQueue;
				if enchantItem then
					self.craftingQueueEnchantID = enchantItem:GetItemID();
					enchantQueue = (function()
						local queue = {};
						ItemUtil.IteratePlayerInventoryAndEquipment(function(itemLocation)
							if C_Item.GetItemID(itemLocation) == self.craftingQueueEnchantID then
								local item = Item:CreateFromItemGUID(C_Item.GetItemGUID(itemLocation));
								table.insert(queue, {itemLocation = itemLocation, count = item:GetStackCount()});
							end
						end);
						return queue;
					end)();
				end

				self.craftingCallback = function()
					local partition = self.craftingQueue:Front();
					if not partition then
						return false;
					end
			
					partition.quantity = partition.quantity - 1;
					if partition.quantity <= 0 then
						self.craftingQueue:Pop();
					end
					
					local shallow = true;
					local craftingReagentTbl = CopyTable(partition.craftingReagentInfos, shallow);

					local count = 1;
					if enchantQueue then
						local index = 1;
						local next = enchantQueue[index];
						if next then
							local itemLocation = next.itemLocation;
							next.count = next.count - 1;
							if next.count <= 0 then
								table.remove(enchantQueue, index);
							end
							C_TradeSkillUI.CraftEnchant(recipeID, count, craftingReagentTbl, itemLocation);
						end
					else
						CraftRecipe(count, craftingReagentTbl);
					end
					
					return true;
				end
				self.craftingCallback();
			else
				local craftingReagentTbl = transaction:CreateCraftingReagentInfoTbl();
				if enchantItem then
					C_TradeSkillUI.CraftEnchant(recipeID, count, craftingReagentTbl, enchantItem:GetItemLocation());
				else
					CraftRecipe(count, craftingReagentTbl);
				end
			end
		end
	end

	self.CraftingOutputLog:StartListening();

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
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
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
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	self:CreateInternal(currentRecipeInfo.recipeID, self.CreateMultipleInputBox:GetValue(), self.SchematicForm:GetCurrentRecipeLevel());
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
	[1] = { ButtonPos = { x = 125,	y = -44 }, HighLightBox = { x = 0, y = -52, width = 297, height = 30 }, ToolTipDir = "DOWN", ToolTipText = PROFESSIONS_CRAFTING_HELP_FILTERS },
};

function ProfessionsCraftingPageMixin:UpdateTutorial()
	ProfessionsCraftingPage_HelpPlate.FrameSize = { width = self:GetDesiredPageWidth(), height = 635 };

	local numStaticAreas = 1;
	local maxTutorializedAreas = 7;
	for i = (numStaticAreas + 1), maxTutorializedAreas do
		ProfessionsCraftingPage_HelpPlate[i] = nil;
	end


	if self.SchematicForm.Reagents:IsShown() then
		local reagentsTopPoint = self.SchematicForm.Reagents:GetTop() - self:GetTop() + 30;
		local reagentsLeftPoint = self.SchematicForm.Reagents:GetLeft() - self:GetLeft() - 20;
		local basicReagentsBoxLeft = reagentsLeftPoint;
		local basicReagentsBoxTop = reagentsTopPoint;
		local reagentsBoxWidth = 225;
		local reagentsBoxHeight = 360;
		local reagentsButtonXOfs = 150;
		local reagentsButtonYOfs = -5;

		local basicReagentsSection =
		{
			ButtonPos = { x = basicReagentsBoxLeft + reagentsButtonXOfs, y = basicReagentsBoxTop + reagentsButtonYOfs },
			HighLightBox = { x = basicReagentsBoxLeft, y = basicReagentsBoxTop, width = reagentsBoxWidth, height = reagentsBoxHeight },
			ToolTipDir = "UP",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BASIC_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, basicReagentsSection);

		if self.SchematicForm.OptionalReagents:IsShown() then
			local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
			local padding = 5;
			local optionalReagentsSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + reagentsBoxWidth + padding + reagentsButtonXOfs, y = basicReagentsBoxTop + reagentsButtonYOfs },
				HighLightBox = { x = basicReagentsBoxLeft + reagentsBoxWidth + padding, y = basicReagentsBoxTop, width = reagentsBoxWidth, height = reagentsBoxHeight },
				ToolTipDir = "UP",
				ToolTipText = (currentRecipeInfo and currentRecipeInfo.supportsQualities and C_TradeSkillUI.RecipeCanBeRecrafted(currentRecipeInfo.recipeID)) and PROFESSIONS_CRAFTING_HELP_OPTIONAL_REAGENTS_RECRAFTABLE or PROFESSIONS_CRAFTING_HELP_OPTIONAL_REAGENTS,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, optionalReagentsSection);
		end

		if self.SchematicForm.AllocateBestQualityCheckBox:IsShown() then
			local width = 210;
			local y = basicReagentsBoxTop - reagentsBoxHeight - 5;
			local bestQualityCheckboxSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + width - 25, y = y },
				HighLightBox = { x = basicReagentsBoxLeft, y = y, width = width, height = 60 },
				ToolTipDir = "RIGHT",
				ToolTipText = PROFESSIONS_CRAFTING_HELP_BEST_QUALITY,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, bestQualityCheckboxSection);
		end
	end

	local detailsShown = self.SchematicForm.Details:IsShown();
	local qualityMeter = self.SchematicForm.Details.QualityMeter;
	if detailsShown and qualityMeter:IsShown() then
		local qualityMeterTopPoint = qualityMeter:GetTop() - self:GetTop() + 14;
		local qualityMeterLeftPoint = qualityMeter:GetLeft() - self:GetLeft() - 5;
		local qualityMeterBoxWidth = 250;
		local qualityMeterSection =
		{
			ButtonPos = { x = qualityMeterLeftPoint + qualityMeterBoxWidth - 25, y = qualityMeterTopPoint },
			HighLightBox = { x = qualityMeterLeftPoint, y = qualityMeterTopPoint, width = qualityMeterBoxWidth, height = 60 },
			ToolTipDir = "RIGHT",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BAR,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, qualityMeterSection);
	end

	local finishingReagents = self.SchematicForm.Details.FinishingReagentSlotContainer;
	if detailsShown and finishingReagents:IsShown() then
		local finishingReagentsTopPoint = finishingReagents:GetTop() - self:GetTop();
		local finishingReagentsLeftPoint = finishingReagents:GetLeft() - self:GetLeft() + 50;
		local width = 150;
		local finishingReagentsSection =
		{
			ButtonPos = { x = finishingReagentsLeftPoint + width - 25, y = finishingReagentsTopPoint - 25 },
			HighLightBox = { x = finishingReagentsLeftPoint, y = finishingReagentsTopPoint, width = width, height = 80 },
			ToolTipDir = "RIGHT",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_FINISHING_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, finishingReagentsSection);
	end

	if self:AnyInventorySlotShown() then
		local gearSection =
		{
			ButtonPos = { x = 1066, y = -3 },
			HighLightBox = { x = 937, y = 1, width = 153, height = 56 },
			ToolTipDir = "RIGHT",
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
